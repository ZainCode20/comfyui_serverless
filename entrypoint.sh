#!/usr/bin/env bash
set -e

# Run the linking script
/opt/init-models.sh

# Hand off to the base image's default startup command
exec "$@"
