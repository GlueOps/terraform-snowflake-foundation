resource "snowflake_database" "foundation_databases" {
  provider = snowflake
  for_each = toset(var.databases)

  name = each.key
}
