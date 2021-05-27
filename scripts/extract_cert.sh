#!/bin/bash
set -eu

if [ $1 = "-h" -o $1 = "--help" ]; then
cat <<EOF
Extract a value of 'items.*.data."tls.crt"' from 'sealed-secrets-key-\${env}.yaml'

Usage:
  ./extract_cert.sh [env]
EOF
  exit 0
fi

scripts_dir="$(dirname "$0")"
$scripts_dir/enable_env_name.sh $1

yq r sealed-secrets-key-$1.yaml 'items.*.data."tls.crt"' | base64 --decode > cert.pem
