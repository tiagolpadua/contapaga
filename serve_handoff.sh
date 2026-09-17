#!/bin/sh

cd "$(dirname "$0")" || exit 1
exec npx --yes serve handoff
