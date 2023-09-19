#!/bin/bash

export GCP_CREDS=GCP_CREDS

# Parse command line arguments
while [[ "$#" -gt 0 ]]; do
    case $1 in
        --tf_dir) TF_DIR="$2"; shift ;;
        --prefix) PREFIX="$2"; shift ;;
        --gcp_creds) GCP_CREDS="$2"; shift ;;
        *) echo "Unknown parameter passed: $1"; exit 1 ;;
    esac
    shift
done

# Check if TF_DIR and PREFIX are set
if [ -z "$TF_DIR" ] || [ -z "$PREFIX" ] || [ -z "$GCP_CREDS" ]; then
    echo "TF_DIR, PREFIX, and GCP_CREDS must be set. Exiting."
    exit 1
fi

cd "$TF_DIR" || exit 1
ssh-keygen -t rsa -b 4096 -C "test@redpanda.com" -N "" -f testkey <<< y && chmod 0700 testkey
terraform init || exit 1

# Trap to handle terraform destroy on exit
trap cleanup EXIT INT TERM
cleanup() {
    error_code=$?
    terraform destroy --auto-approve --var="gcp_creds=$GCP_CREDS" --var="deployment_prefix=$PREFIX" --var="public_key_path=testkey" --var="project_id=hallowed-ray-376320"
    rm -f testkey
    rm -f testkey.pub
    exit $error_code
}

terraform apply --auto-approve --var="deployment_prefix=$PREFIX" --var="gcp_creds=$GCP_CREDS" --var="public_key_path=testkey" --var="project_id=hallowed-ray-376320"

# Trap will handle destroy so just exit
exit $?