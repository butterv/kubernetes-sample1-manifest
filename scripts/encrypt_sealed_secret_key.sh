#!/bin/bash
set -eu

if [ $1 = "-h" -o $1 = "--help" ]; then
cat <<EOF
Encrypt from plaintext to ciphertext with using the KMS of GCP

Usage:
  ./encrypt_sealed_secret_key.sh [env]
EOF
  exit 0
fi

scripts_dir="$(dirname "$0")"
$scripts_dir/enable_env_name.sh $1

gcloud config set project kubernetes-sample1
gcloud kms encrypt \
    --project=kubernetes-sample1 \
    --location=global \
    --keyring=sealed-secret \
    --key=sealed-secret \
    --plaintext-file=sealed-secrets-key-$1.yaml \
    --ciphertext-file=sealed-secrets-key-$1.yaml.enc
