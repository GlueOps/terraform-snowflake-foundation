terraform {
  required_version = ">= 1.2.9"
  required_providers {
    snowflake = {
      source  = "Snowflake-Labs/snowflake"
      version = ">=0.46.0"
    }
  }
}
