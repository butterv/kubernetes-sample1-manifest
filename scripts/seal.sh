#!/bin/bash
set -eu

if [ $1 = "-h" -o $1 = "--help" ]; then
cat <<EOF
Seal yaml format file

Usage:
  ./seal.sh [input] [output]
EOF
  exit 0
fi

kubeseal --format=yaml --cert=cert.pem < $1 > $2
