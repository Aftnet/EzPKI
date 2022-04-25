#! /bin/bash

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
ABS_DIRECTORY="$(dirname "${ABS_SCRIPT_PATH}")"
PKI_ROOT_DIR="${ABS_DIRECTORY}/pki"

find "${PKI_ROOT_DIR}" -name openssl.conf -execdir pwd \; -execdir openssl ca -config openssl.conf -gencrl -out publish/ca.crl \;