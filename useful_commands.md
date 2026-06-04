# Commands to find what is using port 80 or any other

```
  sudo lsof -i :80
  sudo ss -tulpn | grep :80

```
# Runbook: Configure `https://myapp.local` on WSL Apache with a trusted self-signed certificate

## Overview

This runbook documents the end-to-end setup and troubleshooting process used to make `https://myapp.local` work from Windows against Apache running inside WSL. The final working state required correct Windows name resolution, correct Apache virtual host behavior on port 443, a self-signed certificate containing Subject Alternative Name (SAN), and trust installation in the Windows certificate store.[1][2][3]

## Environment

- Windows host system.
- WSL Ubuntu instance hosting Apache.
- Local application domain: `myapp.local`.
- Browser: Chrome on Windows.
- Apache SSL certificate path: `/etc/ssl/certs/myapp.local.crt`.
- Apache SSL key path: `/etc/ssl/private/myapp.local.key`.

## Task completed

### 1. Verify hostname resolution

The first issue observed was that `myapp.local` was resolving to a loopback-style address instead of the WSL IP, which meant requests were not reaching the intended Apache service correctly. Correct local HTTPS troubleshooting starts with confirming the hostname resolves to the right target system.[1]

Commands used:

```cmd
ping myapp.local
```

Action taken:
- Verified the hostname mapping in the Windows hosts file.
- Corrected the entry so `myapp.local` points to the active WSL IP instead of an incorrect `127.x.x.x` value.[1]

### 2. Inspect Apache virtual host configuration

Apache virtual host inspection was required to determine which site was handling ports 80 and 443. This step confirmed that `myapp.local` existed as a configured site and later revealed that the default SSL site was still interfering on port 443.[5][2]

Commands used:

```bash
sudo apache2ctl -S
```

Action taken:
- Confirmed `myapp.local` was configured on `*:80`.
- Confirmed HTTPS behavior on `*:443`.
- Identified that `default-ssl.conf` was still enabled as the default 443 virtual host earlier in the process.

### 3. Inspect certificate file paths in Apache

Apache needed to be checked to confirm which certificate and key files were actually configured for the site. SSL behavior in Apache depends directly on the `SSLCertificateFile` and `SSLCertificateKeyFile` directives inside the enabled vhost files.[4][5]

Commands used:

```bash
sudo grep -R "SSLCertificateFile\|SSLCertificateKeyFile" /etc/apache2
```

Action taken:
- Verified that Apache referenced `/etc/ssl/certs/myapp.local.crt`.
- Verified that Apache referenced `/etc/ssl/private/myapp.local.key`.
- Confirmed that `default-ssl.conf` still pointed to the snakeoil certificate before it was disabled.

### 4. Remove conflicting default SSL virtual host

The default SSL virtual host had to be disabled because Apache can serve the default certificate on port 443 when multiple SSL vhosts are enabled and one remains the default. This is a common reason a browser receives the wrong certificate even when a custom vhost exists.[2][6]

Commands used:

```bash
sudo a2dissite default-ssl.conf
sudo systemctl reload apache2
sudo apache2ctl -S
```

Action taken:
- Disabled `default-ssl.conf`.
- Reloaded Apache.
- Re-ran vhost inspection to confirm that `myapp.local` became the active HTTPS site on `*:443`.

### 5. Check the configured certificate identity

The certificate on disk was checked to confirm issuer, subject, and validity dates. This step established that the certificate was self-signed because the issuer and subject were the same.[3][7]

Commands used:

```bash
sudo openssl x509 -in /etc/ssl/certs/myapp.local.crt -noout -issuer -subject -dates
```

Observed result:
- `issuer = subject`.
- Validity window existed.
- Common Name was `myapp.local`.

### 6. Check the live certificate served by Apache

The live certificate served over HTTPS was inspected to confirm Apache was actually presenting the same certificate configured in the vhost file. This distinguishes a configuration file issue from a live runtime issue.[5][4]

Commands used:

```bash
echo | openssl s_client -servername myapp.local -connect myapp.local:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
```

Action taken:
- Confirmed the live certificate matched the configured certificate on disk.

### 7. Check Subject Alternative Name (SAN)

The certificate was inspected for Subject Alternative Name because modern browsers validate the hostname against SAN rather than relying only on the Common Name. The initial check returned no SAN output, which meant the original certificate was structurally incomplete for modern browser validation.[3]

Commands used:

```bash
sudo openssl x509 -in /etc/ssl/certs/myapp.local.crt -noout -text | grep -A1 "Subject Alternative Name"
```

Observed result:
- Initial output was blank, showing SAN was missing.

### 8. Regenerate the certificate with SAN

A new self-signed certificate had to be generated with SAN set to `DNS:myapp.local`. A SAN-enabled certificate is required for modern browser hostname validation on local HTTPS setups.[3][8]

Commands used:

```bash
nano ~/myapp.local.cnf
```

Configuration used:

```ini
[req]
default_bits = 2048
prompt = no
default_md = sha256
distinguished_name = dn
x509_extensions = v3_req

[dn]
C = IN
ST = UP
L = Noida
O = Sukh
OU = myapp.local
CN = myapp.local

[v3_req]
subjectAltName = @alt_names

[alt_names]
DNS.1 = myapp.local
```

Certificate generation and restart:

```bash
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/myapp.local.key \
-out /etc/ssl/certs/myapp.local.crt \
-config ~/myapp.local.cnf \
-extensions v3_req
sudo systemctl restart apache2
```

Action taken:
- Replaced the old certificate and key with a SAN-enabled version.
- Restarted Apache to activate the new certificate.

### 9. Re-verify SAN after regeneration

The SAN check was repeated after regeneration to verify the certificate now included the correct DNS name. This validation confirmed that the certificate structure was now correct for `myapp.local`.

Commands used:

```bash
sudo openssl x509 -in /etc/ssl/certs/myapp.local.crt -noout -text | grep -A1 "Subject Alternative Name"
```

Observed result:

```text
X509v3 Subject Alternative Name:
    DNS:myapp.local
```

This result confirmed the certificate now contained the required SAN entry.

### 10. Copy the certificate from WSL to Windows

The certificate had to be copied from the Linux filesystem into the Windows filesystem so it could be opened and installed through the Windows certificate import flow. WSL exposes the Windows C drive under `/mnt/c` for this purpose.

Commands used:

```bash
cp /etc/ssl/certs/myapp.local.crt /mnt/c/Users/solutionara/Downloads/
```

Important note:
- This command must be run in WSL, not plain PowerShell, because Linux paths such as `/etc/ssl/...` are not native Windows filesystem paths.

### 11. Install the certificate into Windows trust store

The self-signed certificate then had to be installed into the Windows trusted root store because self-signed certificates are not trusted automatically by Chrome on Windows. Trust installation is required even after the certificate name and SAN are correct.

Windows steps performed:
- Open `C:\Users\solutionara\Downloads`.
- Double-click `myapp.local.crt`.
- Click **Install Certificate**.
- Choose **Local Machine**.
- Choose **Place all certificates in the following store**.
- Select **Trusted Root Certification Authorities**.
- Complete the wizard and accept the trust warning.

### 12. Restart browser and validate final access

After importing the certificate, the browser had to be fully restarted so it would reload the updated Windows trust state. The expected end state was successful access to `https://myapp.local` without the privacy warning.

Validation target:

```text
https://myapp.local
```

Expected result:
- Chrome opens the page successfully without `NET::ERR_CERT_AUTHORITY_INVALID`.

## Commands used during the task

```bash
sudo apache2ctl -S
sudo grep -R "SSLCertificateFile\|SSLCertificateKeyFile" /etc/apache2
sudo a2dissite default-ssl.conf
sudo systemctl reload apache2
sudo openssl x509 -in /etc/ssl/certs/myapp.local.crt -noout -issuer -subject -dates
echo | openssl s_client -servername myapp.local -connect myapp.local:443 2>/dev/null | openssl x509 -noout -issuer -subject -dates
sudo openssl x509 -in /etc/ssl/certs/myapp.local.crt -noout -text | grep -A1 "Subject Alternative Name"
nano ~/myapp.local.cnf
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
-keyout /etc/ssl/private/myapp.local.key \
-out /etc/ssl/certs/myapp.local.crt \
-config ~/myapp.local.cnf \
-extensions v3_req
sudo systemctl restart apache2
cp /etc/ssl/certs/myapp.local.crt /mnt/c/Users/solutionara/Downloads/
```

## Challenges faced

### 1. Incorrect hostname mapping

The initial hostname resolution pointed to `127.25.6.164`, which indicated a wrong local mapping and prevented correct routing to the WSL-hosted service. Local development domains must resolve to the correct WSL IP to reach Apache successfully.

### 2. Misleading browser SSL error

Once the site became reachable over HTTPS, the browser reported `NET::ERR_CERT_AUTHORITY_INVALID`. This did not mean Apache was unreachable; it meant the certificate was being served but was not trusted by the browser.

### 3. Apache default SSL vhost conflict

The enabled `default-ssl.conf` caused Apache to keep a default HTTPS site active on port 443. This can result in the wrong certificate being presented before the intended vhost is selected.

### 4. Certificate initially lacked SAN

The first certificate had `CN=myapp.local` but no Subject Alternative Name section. Modern browsers require SAN such as `DNS:myapp.local`, so the certificate had to be regenerated.


## Validation checklist

- `ping myapp.local` resolves to the correct WSL IP instead of a loopback typo.
- `sudo apache2ctl -S` shows `myapp.local` as the active HTTPS vhost on `*:443`.
- `openssl s_client` shows Apache serving the intended certificate.
- SAN output shows `DNS:myapp.local`.
- `myapp.local.crt` is installed in **Trusted Root Certification Authorities** on Windows.
- Chrome opens `https://myapp.local` without the privacy warning.
