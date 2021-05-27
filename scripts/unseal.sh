#!/bin/bash
set -eu

if [ $1 = "-h" -o $1 = "--help" ]; then
cat <<EOF
Unseal yaml format file with using 'sealed-secrets-key-\${env}.yaml'

Usage:
  ./unseal.sh [env] [input] [output]
EOF
  exit 0
fi

scripts_dir="$(dirname "$0")"
$scripts_dir/enable_env_name.sh $1

kubeseal \
    --controller-namespace=kube-system \
    --controller-name=sealed-secrets-controller \
    < $2 \
    --recovery-unseal \
    --recovery-private-key sealed-secrets-key-$1.yaml -o yaml > $3
