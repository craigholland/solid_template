# Solid Template Database
Database Subpackage for solid_template app
```
stuff here
```
## Setup
Most of the setup is handled by the `poetry` package manager. As such, most of the code in `/scripts` is dependent on being run by Poetry in order to load in the appropriate environment variables:
```bash
poetry run ./scripts/some_script.sh arg1 arg2
```
The following steps should be taken to setup the database subpackage:
- Check DB Environment Variables
  - Ensure that the `.env` file in the root of the project is properly configured with the appropriate database connection information.
  - `DB_MODULE_NAME` := `solid_template_db`
  - `DOCKER_IMAGE_REPO` := `us-west1-docker.pkg.dev/cholland-form/dockerhub/postgres`
  - `DOCKER_DB_IMAGE_TAG` := `12`
  - `DOCKER_DB_CONTAINER_NAME` := `solidapp_postgres`
  - `DOCKER_DATABASE_NAME` := `solidapp_db`
  - `DOCKER_LOCAL_VOLUME_PATH` := `/opt/docker-volumes/`
  - `DOCKER_LOCAL_VOLUME_SUFFIX` := `_data`
- Install dependencies
  ```
  poetry install
  ```
- Create/Start local PostgreSQL database
  ```
  poetry run ./scripts/run_local_db.sh
  ```
- Initialize Alembic migration tool
  ```
  poetry run ./scripts/alembic.sh
  ```
  