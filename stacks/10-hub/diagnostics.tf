resource "azurerm_monitor_diagnostic_setting" "fw" {
  name                           = "diag-${local.fw_name}"
  target_resource_id             = azurerm_firewall.fw.id
  log_analytics_workspace_id     = data.azurerm_log_analytics_workspace.law.id
  log_analytics_destination_type = "Dedicated"

  dynamic "enabled_log" {
    for_each = local.fw_log_categories
    content {
      category = enabled_log.value
    }
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
