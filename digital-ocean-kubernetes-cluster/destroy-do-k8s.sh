#!/bin/bash
# Export your Digital Ocean Personal Access Token as DO_PAT

if [ -z "${DO_PAT}" ]; then
    echo "Please export your Digital Ocean PAT as DO_PAT and retry"
    exit 1
fi

tofu destroy -var "do_token=${DO_PAT}" -auto-approve

echo "Destroyed"
