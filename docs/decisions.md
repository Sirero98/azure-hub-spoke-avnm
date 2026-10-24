# Design decisions

Short records of the main decisions: context, what was decided and its trade-offs.

## 1. Independent stacks with isolated state

**Context.** A single root module would put networking, security and VMs in one state: every plan touches everything and one mistake can affect the whole environment.

**Decision.** One stack per layer (`00`–`60`), each with its own state file in the same remote backend (Azure Storage, Entra ID auth, blob versioning).

**Consequences.** Smaller blast radius and faster plans. Stacks must be applied in order, and they need a way to reference each other (see 2).

## 2. Cross-stack references by naming convention, not remote state

**Context.** `terraform_remote_state` would give one stack read access to another stack's whole state, including secrets: the foundation state contains the VPN pre-shared key.

**Decision.** Stacks find each other's resources with **data sources and predictable names** (`vnet-hub`, `fwpol-hub`, `pip-vpngw-hub`). The Key Vault has a random suffix, so it is found by type with `azurerm_resources`.

**Consequences.** No stack reads another stack's state. The naming convention becomes a contract: renaming a resource breaks the stacks that read it, but they fail safely at plan time.

## 3. Firewall policy in the hub, rules in their own stack

**Context.** The firewall needs its policy when it is created, while rules change much more often than infrastructure.

**Decision.** `10-hub` creates an empty Basic policy attached to the firewall. `20-firewall-rules` reads it and manages the rules, which are data-driven (`tfvars` + nested `dynamic` blocks) and use IP Groups.

**Consequences.** A rule change can never recreate the firewall, and adding a rule means editing data, not code.

## 4. AVNM for spoke connectivity and routing

**Context.** Four spokes need eight peerings and four route tables, and every new spoke repeats the work.

**Decision.** AVNM with two network groups (`ng-prod`, `ng-nonprod`, static members), a hub-and-spoke connectivity configuration with gateway transit, and a routing configuration that sends `0.0.0.0/0` and the on-premises range to the firewall. Direct connectivity inside groups is disabled, so even spokes in the same group talk through the firewall.

The **GatewaySubnet** gets a classic route table (in `10-hub`) that sends spoke traffic to the firewall. AVNM routing applies to network groups, and adding the hub to a group would also route the firewall subnet to itself.

**Consequences.** Adding a spoke is one line in `tfvars` (plus its range in the GatewaySubnet route). Configurations only take effect after an AVNM deployment, which is modelled as a Terraform resource with explicit `depends_on` and `triggers`.

## 5. VPN pre-shared key

**Context.** Both VPN connections need the same key, and it must not be written in the code.

**Decision.** `random_password` generates it, it is stored in Key Vault (RBAC mode) and `50-onprem-sim` reads it with a data source.

**Consequences.** The key is never in the repository. **Known limitation:** it is stored in plain text in the `00-foundation` and `50-onprem-sim` states. This is mitigated by the backend (Entra ID only, shared keys disabled, no anonymous blob access). Future improvements: ephemeral resources and write-only arguments, and a private endpoint for the state storage.

## 6. Automated connectivity tests

**Context.** A successful `apply` only proves that resources exist, not that traffic flows as designed.

**Decision.** `scripts/test-connectivity.sh` runs `curl` from inside the VMs with `az vm run-command` (no SSH, no public IPs) and checks both allowed and **blocked** paths against the expected result. It exits non-zero on any failure, so it can run in a pipeline.

**Consequences.** The design is verifiable with one command. Each test takes 20–40 s, so a full run takes several minutes.

## Lab trade-offs

- **Basic SKUs** (Firewall, Bastion) to keep costs low. Production would use Firewall Standard/Premium (IDPS, TLS inspection).
- **Single region**, no BGP, one active gateway instance.
- **On-premises is simulated** with an Azure VNet, so both VPN connections live in `50-onprem-sim`. In a real environment only the hub-side connection would be in Azure. The simulated office uses Azure default outbound access as its own internet breakout.

## Lessons learned

- **Asymmetric routing.** Traffic from on-premises reached the spokes directly through the peering while the replies went through the firewall, which dropped them. Code review did not catch it; the connectivity test did. Fixed with a GatewaySubnet route table.
- **Partially failed applies.** When an Azure operation fails halfway, the resource may exist even though Terraform did not record it, and the next apply fails with "already exists". Check the resource in Azure: import it if healthy, delete it if failed. Applying stacks sequentially avoids most of these failures.
- **Leftovers from previous deployments.** Diagnostic settings are not deleted with their resource and reattach to a new resource with the same ID. A leftover from an earlier portal lab had to be imported.
- **Moving resources between states.** During the migration to stacks, the source stack stopped tracking the hub before the destination had imported it, leaving it orphaned. It was caught because the plan showed 8 resources instead of 3, and fixed with `import` blocks without downtime. Since then: verify `terraform state list` in the destination before using `removed` in the source.