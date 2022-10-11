data "snowflake_databases" "all" {}


locals {
  read_all_role_name = "READ_ALL"

  all_databases = setsubtract([
    for d in data.snowflake_databases.all.databases :
    d.name
  ], ["SNOWFLAKE", "SNOWFLAKE_SAMPLE_DATA"]) # remove default databases
}


#==== Privilege Roles and Grands
#= Read All role
resource "snowflake_role" "read_all_role" {
  provider = snowflake

  name = local.read_all_role_name
}

resource "snowflake_database_grant" "read_all_databases" {
  provider = snowflake
  for_each = toset(local.all_databases)

  database_name = each.value
  privilege     = "USAGE"
  roles         = [snowflake_role.read_all_role.name]
  shares        = []
}

resource "snowflake_schema_grant" "read_all_schemas" {
  provider = snowflake
  for_each = toset(local.all_databases)

  database_name = each.value
  privilege     = "USAGE"
  roles         = [snowflake_role.read_all_role.name]

  on_future = true
}

resource "snowflake_table_grant" "read_all_table_select_grant" {
  provider = snowflake
  for_each = toset(local.all_databases)

  database_name = each.value
  privilege     = "SELECT"
  roles         = [snowflake_role.read_all_role.name]

  on_future = true
}

resource "snowflake_view_grant" "read_all_view_select_grant" {
  provider = snowflake
  for_each = toset(local.all_databases)

  database_name = each.value
  privilege     = "SELECT"
  roles         = [snowflake_role.read_all_role.name]

  on_future = true
}
