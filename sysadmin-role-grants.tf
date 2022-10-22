#== Grant All Service User and Principal Roles to SYSADMIN so they can be managed
locals {
  all_roles = concat(
    [for k, v in snowflake_role.principal_roles : v.name],
    [for k, v in snowflake_role.service_user_roles : v.name],
  )
}

resource "snowflake_role_grants" "grant_all_user_roles_to_sysadmin" {
  provider = snowflake
  for_each = toset(local.all_roles)

  role_name = each.key

  roles = ["SYSADMIN"]
  users = []

  depends_on = [
    snowflake_role.principal_roles,
    snowflake_role.service_user_roles
  ]
}
