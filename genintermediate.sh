#! /bin/bash

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
ABS_DIRECTORY="$(dirname "${ABS_SCRIPT_PATH}")"

echo "Directory name for new ca"
read CA_SHORT_NAME
CA_ROOT_DIR="${ABS_DIRECTORY}/pki/${CA_SHORT_NAME}"
CA_PRIVKEY_PATH="${CA_ROOT_DIR}/private/ca.key"

GEN_COMMAND="openssl req -config openssl.conf -new -key ${CA_PRIVKEY_PATH} -out ca.csr"

echo "Root domain for name constraints. Leave empty to not apply"
read ROOT_DOMAIN
if [ "${ROOT_DOMAIN}" != "" ]
then
    GEN_COMMAND="${GEN_COMMAND} -addext \"nameConstraints = critical, permitted;DNS:${ROOT_DOMAIN}, permitted;DNS:.${ROOT_DOMAIN}, permitted;email:${ROOT_DOMAIN}, permitted;email:.${ROOT_DOMAIN}, permitted;otherName:1.3.6.1.4.1.311.20.2.3;UTF8:${ROOT_DOMAIN}, permitted;otherName:1.3.6.1.4.1.311.20.2.3;UTF8:.${ROOT_DOMAIN}\""
fi

rm -rf "${CA_ROOT_DIR}"
mkdir "${CA_ROOT_DIR}"
cp -r "${ABS_DIRECTORY}/templates/ca_folder/"* "${CA_ROOT_DIR}"
cp "${ABS_DIRECTORY}/openssl.conf_issuing" "${CA_ROOT_DIR}/openssl.conf"
cd "${CA_ROOT_DIR}"

echo "Generating CA private key"
openssl genpkey -algorithm rsa -pkeyopt rsa_keygen_bits:4096 -aes-256-cbc -out "${CA_PRIVKEY_PATH}"
echo "Generating CA CSR"
eval "${GEN_COMMAND}"
cd ../root
echo "Signing CSR with root CA"
openssl ca -config openssl.conf -notext -keyfile private/ca.key -in "${CA_ROOT_DIR}/ca.csr" -out "${CA_ROOT_DIR}/publish/ca.cer"
rm "${CA_ROOT_DIR}/ca.csr"
