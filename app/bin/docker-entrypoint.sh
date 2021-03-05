#!/bin/sh
set -xeuo pipefail

bundle exec rails db:create
bundle exec rails db:migrate

exec "$@"
