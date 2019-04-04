### Stitch utilities

**coalesce_fields** ([source](macros/coalesce_fields.sql))

This macro coalesces fields that Stitch splits by datatype as a result of incremental
loading.

The argument `relation` takes a Stitch-loaded table relation, either:
* by dbt `source()` expression
* by dbt `ref()` expression
* by calling dbt adapter function `adapter.get_relation(schema_name, table_name)` or
`api.Relation.create(identifier, schema, database,  type='table')`

If a Stitch-loaded table contains columns `field`, `field__fl`, and `field__st`,
this macro will return a `select` statement with a combined column `field` of type string.

Usage:

```sql
{{ stitch_utils.coalesce_fields(relation = source('stitch','table_name')) }}
```
