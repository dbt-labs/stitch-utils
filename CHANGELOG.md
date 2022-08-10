# stitch-utils 0.4.2

- Add support for `ti` (timestamp) type ([#26](https://github.com/dbt-labs/stitch-utils/pull/26))

### Contributors
- [@nathan-protempo](https://github.com/nathan-protempo) ([#26](https://github.com/dbt-labs/stitch-utils/pull/26))

# stitch-utils 0.4.1

- Add support for `bo` (boolean) type ([#20](https://github.com/dbt-labs/stitch-utils/pull/20))
- Add support for `decimal` type ([#24](https://github.com/dbt-labs/stitch-utils/pull/24))

### Contributors
- [@jeremyyeo](https://github.com/jeremyyeo) ([#20](https://github.com/dbt-labs/stitch-utils/pull/20))
- [@cnlee1702](https://github.com/cnlee1702) ([#24](https://github.com/dbt-labs/stitch-utils/pull/24))

# stitch-utils 0.4.0

This release supports any version (minor and patch) of v1, which means far less need for compatibility releases in the future.

## Under the hood
- Change `require-dbt-version` to `[">=1.0.0", "<2.0.0"]`
- Bump dbt-utils dependency
- Replace `source-paths` and `data-paths` with `model-paths` and `seed-paths` respectively
- Rename `data` and `analysis` directories to `seeds` and `analyses` respectively
- Replace `dbt_modules` with `dbt_packages` in `clean-targets`

# stitch-utils v0.3.1
🚨 This is a compatibility release in preparation for `dbt-core` v1.0.0 (🎉). Projects using this version with `dbt-core` v1.0.x can expect to see a deprecation warning. This will be resolved in the next minor release.
