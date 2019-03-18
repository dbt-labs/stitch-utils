### dbt integration test suite for dbt-utils

This directory contains an example dbt project which tests the macros in the `stitch-utils` package. An integration test typically involves making 1) a new seed file 2) a new model file 3) a schema test.

For an example integration tests, check out the tests for the `coalesce_fields` macro:

1. [Macro definition](https://github.com/fishtown-analytics/stitch-utils/blob/master/macros/coalesce_fields.sql)
2. [Seed file with fake data](https://github.com/fishtown-analytics/stitch-utils/blob/master/integration_tests/data/data_coalesce_fields.csv)
3. [Model to test the macro](https://github.com/fishtown-analytics/stitch-utils/blob/master/integration_tests/models/test_coalesce_fields.sql)
4. [A schema test to assert the macro works as expected](https://github.com/fishtown-analytics/stitch-utils/blob/master/integration_tests/models/schema.yml#L2)
by [asserting equality](https://github.com/fishtown-analytics/dbt-utils/blob/master/macros/schema_tests/equality.sql) with an [expected output](https://github.com/fishtown-analytics/stitch-utils/blob/master/integration_tests/data/data_coalesce_fields_expected.csv)


Once you've added all of these files, you should be able to run:
```
$ dbt seed
$ dbt run --model {your_model_name}
$ dbt test --model {your_model_name}
```

If the tests all pass, then you're good to go! All tests will be run automatically when you create a PR against this repo.
