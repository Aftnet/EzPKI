# EzPKI

EzPKI is a starting point for creating a two-tier PKI infrastructure with sane defaults and an emphasis on using name constraints to provide protection in case private keys are comproimised.

Artefacts to publish (certificate and crl) are placed in each ca directory's `publish` directory, for ease of picking up and publishing to some webserver if wanted.
Use `gencrls.sh` to update all CAs' CRLs.

Availability is prioritized over strict security in this setup: a copy of the generated ca folder structure and knowledge of the private keys' passwords is all that's needed to keep the system operational - which means using strong passwords is a **must**, as there's no protection against brute forcing the encrypted files offline.

It is highly recommended to put the generated `pki` directory under source control in a different repository: this is where each CA sores their state and needs to be kept consistent as new certificates are issued. Doing so allows operating on the PKI infrastructure from multiple devices as needed.

x509 templates can be modified to include AIA, CRL and OCSP information if wanted.

### Why not just use Let's Encrypt?

Let's encrypt does not cover all use cases, in particular:

- No code signing, no ability to request custom OIDs
- Impossible to use in a fully airgapped infrastructure
- Some embedded devices have no way to automate acme renewals

### Running on Windows

Use WSL: OpenSSL Windows builds do not allow specifying passswords for private keys when running commands, and passing them as parameters is a bad idea security wise. Also, scripts are bash only.

## Generate root CA cert and key

Run `genroot.sh`

Change x509 extension templates in `pki/openssl.conf`, *not* in the root folder one.

Change parameters in `pki/root/openssl.conf` as needed.

## Generate intermediate CA

Run `genintermediate.sh`

Change parameters in the CA folder's `openssl.conf` as needed.

## Onboarding

Generating a root CA also generates an onboarding website (like [this one](https://pki.aftnet.net/)) in `pki/onboarding`: it holds a copy of the CA's public certificate as well as a corresponding configuration profile (.mobileconfig) for easy installation on Apple devices.

Run `genmsprov.ps1` on a system with the [Windows Configuration Designer](https://www.microsoft.com/store/productId/9NBLGGH4TX22) installed to generate an equivalent Windows provisioning package.

Using these allows for easy installation/uninstallation of the certificate in the appropriate OS system wide trust stores.

The onboarding website is static HTML and CSS: just copy the contents of the folder to an appropriate folder in a webserver to deploy.

## Web server certificate

Generate a CSR, for example

```
openssl req -newkey rsa:2048 -keyout server.key -out server.csr -subj "/CN=Subject" -addext "subjectAltName = DNS:mydomain.fqdn, DNS:www.mydomain.fqdn"
```

In the issuing ca directory

```
openssl ca -config openssl.conf -notext -keyfile private/ca.key -in path/to/server.csr -out path/to/server.crt
```

## Code signing

It is recommended to set `copy_extensions = none` for CAs mainly issuing Authenticode certificates, since x509 extensions are fixed (no Subject Alternate Name to worry about)

Generate a CSR, for example

```
openssl req -newkey rsa:2048 -keyout codesign.key -out codesign.csr -subj "/CN=Subject"
```

In the issuing ca directory

```
openssl ca -config openssl.conf -extensions X509_Exts_CodeSign -notext -keyfile private/ca.key -in path/to/server.csr -out path/to/server.crt
```

## Revoking

In the issuing ca directory

```
openssl ca -config openssl.conf -revoke /path/to/cert.crt
```
