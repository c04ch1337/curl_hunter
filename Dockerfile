FROM debian:bullseye

LABEL maintainer="Your Name <you@example.com>"
LABEL description="HTTP Threat Hunting and Recon Tool Using Curl"

RUN apt-get update && \
    apt-get install -y curl nmap openssl && \
    apt-get clean

COPY curl_hunt.sh /usr/local/bin/curl_hunt.sh
RUN chmod +x /usr/local/bin/curl_hunt.sh

ENTRYPOINT ["/usr/local/bin/curl_hunt.sh"]
