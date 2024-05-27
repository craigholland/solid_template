#!/bin/bash
script=$(readlink -f $0)
script_loc=$(dirname "$script")
curr_loc="$(pwd)"
cd "${script_loc}" || exit 1
. common_funcs.sh
cd "${curr_loc}" || exit 1


module_name="database"
module_path="$(module_project_root $module_name)"
module_app_path="${module_path}/${DB_MODULE_NAME}"

function alembic_ini_exists {
    if file_exists "$1/alembic.ini"; then
        return 0
    fi
    return 1
}
function alembic_dir_exists {
    if directory_exists "$1/alembic"; then
        return 0
    fi
    return 1
}
function alembic_versions_dir_exists {
    if directory_exists "$1/alembic/versions"; then
        return 0
    fi
    return 1
}
function alembic_infra_exists {
  if alembic_ini_exists "$1" || alembic_dir_exists "$1"; then
        return 0
    fi
    return 1
}

function alembic_dependency_exists {
    if poetry show | grep -q alembic; then
        return 0
    fi
    return 1
}
function add_alembic_dependency {
    if ! alembic_dependency_exists; then
        poetry add alembic
    fi
}
function remove_existing_alembic_infra {
   if file_exists "$1/alembic.ini"; then
        rm -rf "$1/alembic.ini"
    fi

    if directory_exists "$1/alembic"; then
        rm -rf "$1/alembic"
    fi
}
function add_alembic {
  cd "$1" || exit 1
  poetry run alembic init alembic
  cd ../
}


set_env

install_alembic=false
overwrite_alembic_ini=false
overwrite_alembic_dir=false
overwrite_alembic_versions_dir=false

# Check for existence of alembic.ini and alembic directory
if alembic_infra_exists "${module_app_path}"; then
    echo "Alembic found in $module_app_path"
    if alembic_ini_exists "${module_app_path}"; then
        echo "Alembic.ini file found in $module_app_path"
        confirm_prompt "Would you like to overwrite the alembic.ini file? [y/n]: " && overwrite_alembic_ini=true || overwrite_alembic_ini=false
    fi
    if alembic_dir_exists "${module_app_path}"; then
      if file_exists "${module_app_path}/alembic/env.py"; then
        echo "File 'env.py' found in alembic directory ${module_app_path}/alembic."
        confirm_prompt "Would you like to overwrite the env.py file? [y/n]: " && overwrite_alembic_dir=true || overwrite_alembic_dir=false
      else
        overwrite_alembic_dir=true
      fi
      if alembic_versions_dir_exists "${module_app_path}"; then
        echo "Alembic 'versions' directory found in $module_app_path/alembic"
        confirm_prompt "Would you like to overwrite the alembic versions directory? [y/n]: " && overwrite_alembic_versions_dir=true || overwrite_alembic_versions_dir=false
      else
        overwrite_alembic_versions_dir=true
      fi
    fi
else
    echo "Alembic not found in $module_app_path"
    confirm_prompt "Would you like to create an alembic directory? [y/n]: " && install_alembic=true || install_alembic=false
fi

if [ "$install_alembic" == true ]; then
    echo "Installing alembic"
    add_alembic_dependency
    remove_existing_alembic_infra module_app_path
    echo "Creating alembic directory"
    add_alembic "$module_app_path"
    echo "Alembic installed..."
    cd "$module_app_path" || exit 1
    sleep 5
    poetry run alembic upgrade head
    cd ../
fi

if [ "$overwrite_alembic_ini" == true ]; then
    echo "Writing alembic.ini..."
    cd "$module_app_path" || exit 1
    rm -rf alembic.ini
    cp ../setup_files/alembic.ini alembic.ini
    cd ../
fi

if [ "$overwrite_alembic_dir" == true ]; then
    echo "Writing alembic directory..."
    cd "$module_app_path" || exit 1
    poetry run alembic init alembic_temp
    if ! directory_exists alembic; then
       cp alembic_temp alembic
    fi
    cp ../setup_files/env.py alembic/env.py
    cd ../
fi

if directory_exists "${module_app_path}/alembic_temp"; then
  rm -rf "${module_app_path}/alembic_temp"
fi

if [ "$overwrite_alembic_versions_dir" == true ]; then
    echo "Writing alembic versions directory..."
    cd "$module_app_path" || exit 1
    rm -rf alembic/versions
    mkdir alembic/versions
    cd ../
fi


cd "$module_app_path" || exit 1
poetry run alembic upgrade head
if directory_empty "${module_app_path}/alembic/versions"; then
  echo "Running initial migration..."
  poetry run alembic revision --autogenerate -m "db initialization"
  poetry run alembic upgrade head
fi
echo "...Alembic setup complete"
poetry run alembic current
cd ../
exit 0
