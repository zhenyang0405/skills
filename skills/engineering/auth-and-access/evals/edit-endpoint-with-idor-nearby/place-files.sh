#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
bash setup-repo.sh && rm setup-repo.sh
