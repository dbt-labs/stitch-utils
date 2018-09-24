### Stitch utilities

**coalesce_fields** ([source](macros/coalesce_fields.sql))

This macro coalesces fields that Stitch splits by datatype as a result of incremental
loading.

The argument `from` takes a Stitch-loaded table, either:
* by schema, table, and database (optional)
* by dbt `ref()` expression

E.g. If a Stitch-loaded table contains columns `field__fl` and `field__st`,
this macro will return a `select` statement with a combined column `field` of type string.

Update [9/24]: This macro will also return a combined string-type column `field`
if a table contains both `field` and `field__type`.

Usage:

```sql
{{ stitch_utils.coalesce_fields(from = 'database.schema_name.table_name') }}
{{ stitch_utils.coalesce_fields(from = 'schema_name.table_name') }} -- uses current database
{{ stitch_utils.coalesce_fields(from = ref('table_name'))}} -- dbt reference
```