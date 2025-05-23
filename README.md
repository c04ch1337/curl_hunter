# curl_hunter

`curl_hunter` is a lightweight, bash-based tool designed to perform basic HTTP threat hunting, reconnaissance, and troubleshooting using `curl`. It works for both individual IP addresses and CIDR ranges.

## 🔍 Features

- Scans HTTP(S) root and sensitive paths.
- Parses and explains HTTP status codes.
- Attempts SSL/TLS certificate extraction from HTTPS.
- CIDR-based host discovery using `nmap`.
- Docker-ready CLI.

## 🚀 Usage

```bash
./curl_hunt.sh <IP_ADDRESS or CIDR_RANGE>
```

### Examples

```bash
./curl_hunt.sh 192.168.1.1
./curl_hunt.sh 10.0.0.0/24
```

## 🐳 Docker Support

### Build Docker Image

```bash
docker build -t curl_hunt .
```

### Run Scan via Docker

```bash
docker run --rm -v $(pwd)/output:/output curl_hunt 192.168.1.1
```

## 🧠 HTTP Status Code Reference

The script will log and annotate each HTTP response code.

## 📂 Output

Results are saved in `/output/<IP>_<timestamp>` with separate files for:

- `http_headers.txt`
- `sensitive_paths.txt`
- `root_response_body.html`
- `https_cert.txt`

## 📄 License

MIT
