#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
bash setup-repo.sh honest && rm setup-repo.sh
