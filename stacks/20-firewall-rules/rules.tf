resource "azurerm_firewall_policy_rule_collection_group" "hubspoke" {
  name               = "rcg-hubspoke"
  firewall_policy_id = data.azurerm_firewall_policy.fw_policy.id
  priority           = 200

  dynamic "network_rule_collection" {
    for_each = var.network_rule_collections
    content {
      name     = network_rule_collection.key
      priority = network_rule_collection.value.priority
      action   = network_rule_collection.value.action

      dynamic "rule" {
        for_each = network_rule_collection.value.rules
        content {
          name                  = rule.value.name
          protocols             = rule.value.protocols
          destination_ports     = rule.value.destination_ports
          source_addresses      = rule.value.source_addresses
          destination_addresses = rule.value.destination_addresses
          source_ip_groups      = [for k in rule.value.source_ip_groups : azurerm_ip_group.this[k].id]
          destination_ip_groups = [for k in rule.value.destination_ip_groups : azurerm_ip_group.this[k].id]
        }
      }
    }
  }

  application_rule_collection {
    name     = "allow-web-out"
    priority = 400
    action   = "Allow"

    rule {
      name              = "spokes-to-internet-web"
      source_ip_groups  = [azurerm_ip_group.this["prod"].id, azurerm_ip_group.this["nonprod"].id]
      destination_fqdns = ["*"]

      protocols {
        type = "Http"
        port = 80
      }
      protocols {
        type = "Https"
        port = 443
      }
    }
  }
}