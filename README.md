# terraform snowflake foundation

This module offers an opinionated starting point for setting up a Snowflake account with affordances for the infrastructure and RBAC features generally found in "the modern data stack."

The module can be used in conjunction with [terraform-snowflake-data-integrator](https://github.com/GlueOps/terraform-snowflake-data-integrator), which creates the infrastructure and access required by common data integrator tools, like [Hevo Data](https://hevodata.com/) and [Fivetran](https://www.fivetran.com/).

Specifically, the module creates and manages the following Snowflake resources:
 * Databases
 * Warehouses
 * Users (human and service)
 * RBAC (roles and policies)

---

 ## Databases

By default, this module creates three databases: `RAW`, `DEVELOPMENT`, and `PRODUCTION`.

* **`RAW`** - Dropzone for data landed in Snowflake via first-party services, such as data copied from an object store datalake (e.g. GCS or S3).  Third-party data integration tools, like Airbyte are intended to be configured with the [terraform-snowflake-data-integrator](https://github.com/GlueOps/terraform-snowflake-data-integrator) so they receive their own warehouses and databases.
* **`DEVELOPMENT`** - Testing area for creating derived data sets that is isolated from any production dependencies.
* **`PRODUCTION`** - Final versions of databases that are expected to have production dependencies.

## Warehouses

To ease resource contention and enable more granular tracking of compute usage, the module creates a number of warehouses, one for each `principal_role` and one for each `service_user`.

## Users

The module creates two types of users: `human_users` and `service_users`, with the following characteristics.

* **`human_users`**: Users assigned to humans.  These users are created without a password and a password must be set for each user in console to enable an initial login.  That password must be changed upon first login.  The following SQL will reset a user's password and enable that user to create a password.
```sql
ALTER USER <user> RESET PASSWORD;
```

* **`service_users`**: Users created for services that must access Snowflake and use a username/password combination.  The passwords for these users are declared in `variables.tf` and it is recommended that the passwords are protected, such as via encryption, so as to not store them as as plaintext in your VCS.  Each `service_user` is granted a role and a warehouse that have an identical name to the `service_user`.  The `privilege_roles` for each `service_user` are determined by the configuration in `variables.tf`.

## RBAC

The module separates roles into two categories:

* **`principal_roles`**: Roles to be assigned to entities using the roles, such as `human_users` and `service_users`.  These roles collect the various privileges required by a given principal to perform tasks in Snowflake.
* **`privilege_roles`**: Roles that are logical groupings of privileges that are composably assigned to `principal_roles`.  By default, the module creates a `READ_ALL` privilege role that enables reading from all data sources and a collection of `WRITE_*` roles, which enable writing to each database, respectively.

The relationships among roles can be visualized using the [Snowflake Inspector](http://snowflakeinspector.hashmapinc.com/).
