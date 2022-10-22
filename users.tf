resource "snowflake_user" "human_users" {
  provider = snowflake
  for_each = var.human_users

  name                 = each.key
  must_change_password = true
  default_role         = snowflake_role.principal_roles[each.value[0]].name
}

resource "snowflake_role" "principal_roles" {
  provider = snowflake
  for_each = var.principal_roles

  name = each.key
}

resource "snowflake_role_grants" "principal_role_grants" {
  provider = snowflake
  for_each = snowflake_role.principal_roles

  role_name = each.key
  roles     = var.principal_roles[each.key]
}


resource "snowflake_user" "service_users" {
  provider = snowflake
  for_each = var.service_users

  name     = each.key
  password = each.value.password

  default_role      = each.key
  default_warehouse = each.key
}

# Grant Read All Role to identified principals
resource "snowflake_role" "service_user_roles" {
  provider = snowflake
  for_each = var.service_users

  name = each.key
}

resource "snowflake_role_grants" "service_user_role_grants" {
  provider = snowflake
  # for_each = var.service_users
  for_each = snowflake_user.service_users

  role_name = each.key
  users     = [each.key]
}
