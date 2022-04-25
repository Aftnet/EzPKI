#! /bin/bash

SCRIPT_PATH="${BASH_SOURCE:-$0}"
ABS_SCRIPT_PATH="$(realpath "${SCRIPT_PATH}")"
ABS_DIRECTORY="$(dirname "${ABS_SCRIPT_PATH}")"

echo "Organization name for branding/onboarding"
read ORG_DISPLAY_NAME

ONBOARDING_ROOT_DIR="${ABS_DIRECTORY}/pki/onboarding"
mkdir -p "${ONBOARDING_ROOT_DIR}"
cp -r "${ABS_DIRECTORY}/templates/onboarding/"* "${ONBOARDING_ROOT_DIR}"
sed -i "s/%ORGNAME%/${ORG_DISPLAY_NAME}/g" "${ONBOARDING_ROOT_DIR}/index.html"
cp "${ABS_DIRECTORY}/pki/root/publish/ca.cer" "${ONBOARDING_ROOT_DIR}/publish/ca.cer"

MOBILECONFIG_PATH="${ABS_DIRECTORY}/pki/onboarding/publish/ca.mobileconfig"
MOBILECONFIG="$(<"${ABS_DIRECTORY}/templates/provisioning/appleprovisioning.mobileconfig")"

NEW_UUID=$(uuidgen)
MOBILECONFIG=${MOBILECONFIG//%UUID0%/${NEW_UUID}}
NEW_UUID=$(uuidgen)
MOBILECONFIG=${MOBILECONFIG//%UUID1%/${NEW_UUID}}
NEW_UUID=$(uuidgen)
MOBILECONFIG=${MOBILECONFIG//%UUID2%/${NEW_UUID}}

MOBILECONFIG=${MOBILECONFIG//%ORGNAME%/${ORG_DISPLAY_NAME}}

CERT_CONTENT="$(<"${ABS_DIRECTORY}/pki/onboarding/publish/ca.cer")"
CERT_CONTENT=$(echo -n "${CERT_CONTENT}" | base64)
MOBILECONFIG=${MOBILECONFIG//%BASE64CERT%/${CERT_CONTENT}}
echo "${MOBILECONFIG}" > "${MOBILECONFIG_PATH}"
