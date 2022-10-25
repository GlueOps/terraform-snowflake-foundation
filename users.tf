#=== Configure Human Users
resource "snowflake_user" "human_users" {
  provider = snowflake
  for_each = var.human_users

  name                 = each.key
  must_change_password = true
  default_role         = snowflake_role.principal_roles[each.value[0]].name
}

#= Principal Roles for Human Users
resource "snowflake_role" "principal_roles" {
  provider = snowflake
  for_each = var.principal_roles

  name = each.key
}

locals {
  roles_to_grant_to_human_users = distinct(flatten([
    for k, v in snowflake_user.human_users : [
      for granted_role in var.human_users[k] : {
        target_user  = k
        granted_role = granted_role
      }
    ]
  ]))
}
resource "snowflake_role_grants" "human_user_role_grants" {
  provider = snowflake
  for_each = { for role_map in local.roles_to_grant_to_human_users : "${role_map.target_user}-${role_map.granted_role}" => role_map }

  role_name = each.value.granted_role
  users     = [each.value.target_user]

}

locals {
  privilege_roles_to_grant_to_principal_roles = distinct(flatten([
    for k, v in snowflake_role.principal_roles : [
      for granted_role in var.principal_roles[k] : {
        target_role    = k
        privilege_role = granted_role
      }
    ]
  ]))
}
resource "snowflake_role_grants" "principal_role_grants" {
  provider = snowflake
  for_each = { for role_map in local.privilege_roles_to_grant_to_principal_roles : "${role_map.target_role}-${role_map.privilege_role}" => role_map }

  role_name = each.value.privilege_role
  roles     = [each.value.target_role]
}

#=== Configure Service Users
resource "snowflake_user" "service_users" {
  provider = snowflake
  for_each = var.service_users

  name     = each.key
  password = each.value.password

  default_role      = each.key
  default_warehouse = each.key
}

resource "snowflake_role" "service_user_roles" {
  provider = snowflake
  for_each = var.service_users

  name = each.key
}

resource "snowflake_role_grants" "service_user_role_grants" {
  provider = snowflake
  for_each = snowflake_user.service_users

  role_name = each.key
  users     = [each.key]

}

locals {
  roles_to_grant_to_service_users = distinct(flatten([
    for k, v in snowflake_role.service_user_roles : [
      for granted_role in var.service_users[k]["privilege_roles"] : {
        target_role    = k
        privilege_role = granted_role
      }
    ]
  ]))
}
resource "snowflake_role_grants" "service_user_privilege_role_grants" {
  provider = snowflake
  for_each = { for role_map in local.roles_to_grant_to_service_users : "${role_map.target_role}-${role_map.privilege_role}" => role_map }

  role_name = each.value.privilege_role
  roles     = [each.value.target_role]
}
