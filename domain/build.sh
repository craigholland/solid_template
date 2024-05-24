#!/bin/bash

set -e

# Run tests
echo "Running tests"
poetry run python -m pytest -v -s

# Run linters
echo "Running linters"
poetry run black solidapp_domain -l 79
poetry run flake8 solidapp_domain --ignore=E203,W503,W504

# Update the version in pyproject.toml based on CHANGELOG.md
echo "Updating the version"
python update_version.py

echo "Building the project"
poetry build


# Build the project
poetry build
