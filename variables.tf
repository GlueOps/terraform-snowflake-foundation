variable "databases" {
  description = "Foundational databases to create within snowflake."
  type        = list(string)

  default = [
    "RAW",
    "DEVELOPMENT",
    "PRODUCTION",
  ]
}

variable "warehouse_overrides" {
  description = "Override size and auto-suspend for warehouses.  The default values for all warehouses are 'x-small' and '60'"
  type        = map(any)

  default = {
    "TRANSFORMER_DEVELOPMENT" = {
      warehouse_size = "x-small"
      auto_suspend   = "60"
    }
  }
}


variable "human_users" {
  description = "Human users to create in snowflake and the roles assigned to them. The first role is the default role"
  type        = map(any)

  default = {
    ANDREA_ANALYST        = ["REPORTER"]
    BARBARA_DATA_ENGINEER = ["TRANSFORMER_DEVELOPMENT"]
  }
}

variable "principal_roles" {
  description = "Roles to be assigned to principals, either humans or service users.  Map of role and privilege roles to attach to that role."
  type        = map(any)

  default = {
    "REPORTER" : [
      "READ_ALL",
    ]
    "TRANSFORMER_DEVELOPMENT" : [
      "READ_ALL",
      "WRITE_DEVELOPMENT",
    ]
    "TRANSFORMER_PRODUCTION" : [
      "READ_ALL",
      "WRITE_PRODUCTION",
    ]
  }
}

variable "service_users" {
  description = "Service users to create in snowflake, the default role assigned to each, and their desired password - it is strongly recommended that the passwords are encyrpted."
  type        = map(any)

  default = {
    DBT = {
      privilege_roles = [
        "READ_ALL",
        "WRITE_PRODUCTION"
      ]
      password = "secretPassword"
    }
    VISUALIZATION_TOOL = {
      privilege_roles = [
        "READ_ALL",
      ]
      password = "secretPassword"
    }
  }
}
