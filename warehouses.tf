locals {
  warehouses = concat(
    [for k, v in var.service_users : k],
    [for k, v in var.principal_roles : k]
  )

  default_warehouse_config = {
    for k in local.warehouses : k => {
      "warehouse_size" = "x-small",
      "auto_suspend"   = "60"
    }
  }

  warehouse_config_with_overrides = {
    for k, v in local.default_warehouse_config : k => merge(
      v, lookup(var.warehouse_overrides, k, local.default_warehouse_config[k])
    )
  }
}

#= Warehouses
resource "snowflake_warehouse" "warehouse" {
  provider = snowflake
  for_each = local.warehouse_config_with_overrides

  name = each.key

  warehouse_size = each.value.warehouse_size
  auto_suspend   = each.value.auto_suspend
}

#= Grants
resource "snowflake_warehouse_grant" "prod_warehouse" {
  provider = snowflake
  for_each = snowflake_warehouse.warehouse

  warehouse_name = each.key
  privilege      = "USAGE"

  roles = [each.key]
}
