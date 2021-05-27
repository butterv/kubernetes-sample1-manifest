#!/bin/bash
set -eu

case "$1" in
  "local" | "dev" | "staging" | "production") ;;
  * )
    echo "The environment is not exist."
    exit 1
    ;;
esac
