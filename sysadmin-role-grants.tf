#== Grant All Service User and Principal Roles to SYSADMIN so they can be managed
locals {
    all_roles = merge(
      var.principal_roles,
      var.service_users
    )
}

resource "snowflake_role_grants" "grant_all_user_roles_to_sysadmin" {
  provider = snowflake
  for_each = local.all_roles

  role_name = each.key

  roles = ["SYSADMIN"]
  users = []
}
