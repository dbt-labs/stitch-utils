
test-postgres:
	dbt deps
	dbt seed --target postgres --full-refresh
	dbt run --target postgres --full-refresh
	dbt test --target postgres

test-redshift:
	dbt deps
	dbt seed --target redshift --full-refresh
	dbt run --target redshift --full-refresh
	dbt test --target redshift

test-snowflake:
	dbt deps
	dbt seed --target snowflake --full-refresh
	dbt run --target snowflake --full-refresh
	dbt test --target snowflake

test-bigquery:
	dbt deps
	dbt seed --target bigquery --full-refresh
	dbt run --target bigquery --full-refresh
	dbt test --target bigquery

test-all: test-postgres test-redshift test-snowflake test-bigquery
	echo "Completed successfully"
