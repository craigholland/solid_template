#!/bin/bash
script=$(readlink -f $0)
script_loc=$(dirname "$script")
echo "HERE:: $script_loc"
source "$script_loc/common_funcs.sh"
# MUST RUN WITH POETRY: poetry run ./scripts/run_local_db.sh {clean|purge}

# Make sure the following environment variables are set:
# DOCKER_IMAGE_REPO          (us-west1-docker.pkg.dev/cholland-form/dockerhub/postgres)
# DOCKER_DB_IMAGE_TAG        (12)
# DOCKER_DB_CONTAINER_NAME   (solidapp_postgres)
# DOCKER_DATABASE_NAME       (solidapp_db)
# DOCKER_LOCAL_VOLUME_PATH   (/opt/docker-volumes/)
# DOCKER_LOCAL_VOLUME_SUFFIX (_data)

# This script will start a local postgres database instance using docker
# It will pull the postgres image from private pypi repo if it does not exist
set -e

DOCKER_IMAGE="$DOCKER_IMAGE_REPO:$DOCKER_DB_IMAGE_TAG"
DOCKER_LOCAL_VOLUME_PATH="${DOCKER_LOCAL_VOLUME_PATH}${DOCKER_DATABASE_NAME}${DOCKER_LOCAL_VOLUME_SUFFIX}"

purge=false # Reinitialize the docker container and nuke the local volume
clean=false # Rebuild the docker image and nuke the local volume
dump=false  # Dump the database to ~/dump.sql (if the container is running) and remove the container, image, and local volume

if [ "$1" == "purge" ]; then
    purge=true
elif [ "$1" == "clean" ]; then
    clean=true
    purge=true
elif [ "$1" == "dump" ]; then
    dump=true
    clean=true
    purge=true
fi

# DEBUG
echo "DOCKER_IMAGE: $DOCKER_IMAGE"
echo "DOCKER_LOCAL_VOLUME_PATH: $DOCKER_LOCAL_VOLUME_PATH"
echo "DOCKER_DB_CONTAINER_NAME: $DOCKER_DB_CONTAINER_NAME"
echo "DOCKER_DATABASE_NAME: $DOCKER_DATABASE_NAME"
echo "clean: $clean"
echo "purge: $purge"
echo "docker_container_running: $(if docker_container_running; then echo "true"; else echo "false"; fi)"
echo "docker_container_exists: $(if docker_container_exists; then echo "true"; else echo "false"; fi)"
echo "local_volume_exists: $(if local_volume_exists; then echo "true"; else echo "false"; fi)"
echo "docker_image_exists: $(if docker_image_exists; then echo "true"; else echo "false"; fi)"
# END DEBUG

# Clean up
if docker_container_running "${DOCKER_DB_CONTAINER_NAME}"; then
    if [ "$dump" == true ]; then
        echo "Dumping database to ~/dump.sql"
        docker exec -t "${DOCKER_DB_CONTAINER_NAME}" pg_dump -U postgres -d "${DOCKER_DATABASE_NAME}" > ~/dump.sql
    fi
    echo "Stopping Docker Container '${DOCKER_DB_CONTAINER_NAME}'"
    _="$(docker stop "${DOCKER_DB_CONTAINER_NAME}" 2> /dev/null)"
fi

if [ "$purge" == true ]; then
  if docker_container_exists "${DOCKER_DB_CONTAINER_NAME}"; then
    echo "Removing existing container '$DOCKER_DB_CONTAINER_NAME'"
    _="$(docker rm "${DOCKER_DB_CONTAINER_NAME}" 2> /dev/null)"
  fi

  if directory_exists "$DOCKER_LOCAL_VOLUME_PATH"; then
    echo "Purging ${DOCKER_DB_CONTAINER_NAME} data"
    sudo rm -rf "$DOCKER_LOCAL_VOLUME_PATH"
    sudo mkdir -p "$DOCKER_LOCAL_VOLUME_PATH"
    sudo chown -Rf "$USER":"$USER" "$DOCKER_LOCAL_VOLUME_PATH"
  fi
fi

if [ "$clean" == true ]; then
    if docker_image_exists "${DOCKER_IMAGE}"; then
        echo "Removing existing docker image: ${DOCKER_IMAGE}"
        _="$(docker rmi "${DOCKER_IMAGE}" 2> /dev/null)"
    fi
fi

if [ "$dump" == true ]; then
    echo "Removed docker container '${DOCKER_DB_CONTAINER_NAME}',
          image '${DOCKER_IMAGE}',
          and local data volume: $DOCKER_LOCAL_VOLUME_PATH. Exiting."
    exit 0
fi

# Start up
if ! directory_exists "$DOCKER_LOCAL_VOLUME_PATH"; then
    echo "Creating postgres volume: $DOCKER_LOCAL_VOLUME_PATH"
    sudo mkdir -p "$DOCKER_LOCAL_VOLUME_PATH"
    sudo chown -Rf "$USER":"$USER" "$DOCKER_LOCAL_VOLUME_PATH"
fi

if docker_image_exists "${DOCKER_IMAGE}"; then
    echo "Found existing Docker image: ${DOCKER_IMAGE}"
else
    echo "Docker image not found...Pulling new image: ${DOCKER_IMAGE}"
    docker pull "${DOCKER_IMAGE}"
    pull_id=$!
    wait $pull_id
    echo "Docker image is ready: $DOCKER_IMAGE"
fi

if docker_container_exists "${DOCKER_DB_CONTAINER_NAME}"; then
    echo "Starting up Docker Container '${DOCKER_DB_CONTAINER_NAME}'"
    _="$(docker start "${DOCKER_DB_CONTAINER_NAME}")"
else
    echo "Initializing Docker Container '${DOCKER_DB_CONTAINER_NAME}' for first time use..."
    run_str="\
docker run -d \
--name ${DOCKER_DB_CONTAINER_NAME} \
--net=host \
-e POSTGRES_DB=${DOCKER_DATABASE_NAME} \
-e POSTGRES_USER=postgres \
-e POSTGRES_PASSWORD=postgres \
-e POSTGRES_HOST_AUTH_METHOD=trust \
-e PGDATA=/var/lib/postgresql/data/pgdata \
-v ${DOCKER_LOCAL_VOLUME_PATH}:/var/lib/postgresql/data \
${DOCKER_IMAGE}"

    echo "${run_str}"
    _="$(${run_str})"
fi

if docker_container_running "${DOCKER_DB_CONTAINER_NAME}"; then
  echo "Container '${DOCKER_DB_CONTAINER_NAME}' is now running"
else
  echo "Container '$DOCKER_DB_CONTAINER_NAME' failed to start. Exiting."
  exit 1
fi
