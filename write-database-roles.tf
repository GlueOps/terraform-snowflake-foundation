resource "snowflake_role" "write_database_role" {
  provider = snowflake
  for_each = toset(var.databases)

  name = "WRITE_${each.key}"
}

output "test_write_db_role" {
  value = snowflake_role.write_database_role
}

# #=== Grants
# #= database
resource "snowflake_database_grant" "write_db_cs_grant" {
  provider = snowflake
  for_each = toset(var.databases)

  database_name = each.key
  privilege     = "CREATE SCHEMA"
  roles         = [snowflake_role.write_database_role[each.key].name]
  shares        = []

  with_grant_option = true
}

resource "snowflake_database_grant" "write_db_m_grant" {
  provider = snowflake
  for_each = toset(var.databases)

  database_name = each.key
  privilege     = "MONITOR"
  roles         = [snowflake_role.write_database_role[each.key].name]
  shares        = []

  with_grant_option = true
}

resource "snowflake_database_grant" "write_dev_db_mod_grant" {
  provider = snowflake
  for_each = toset(var.databases)

  database_name = each.key
  privilege     = "MODIFY"
  roles         = [snowflake_role.write_database_role[each.key].name]
  shares        = []

  with_grant_option = true
}
