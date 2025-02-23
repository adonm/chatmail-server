# Use the official Debian 12 (Bookworm) image as the base image
FROM ghcr.io/astral-sh/uv:python3.13-bookworm

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get -y update && apt-get install -y dnsutils rsync unbound unbound-anchor opendkim opendkim-tools mtail curl acl \
    postfix dovecot-imapd dovecot-lmtpd nginx libnginx-mod-stream fcgiwrap cron && apt-get -y dist-upgrade && apt-get -y clean

# Patch systemctl for pyinfra to work
ADD https://github.com/gdraheim/docker-systemctl-replacement/raw/refs/heads/master/files/docker/systemctl3.py /usr/bin/systemctl
RUN chmod 755 /usr/bin/systemctl

# Set up the working directory
WORKDIR /app

# Copy the application code to the container
COPY . /app

# Add venv/bin to PATH
ENV PATH="/app/venv/bin:${PATH}"

# Configure cmdeploy to target local system
ENV CMDEPLOY_LOCAL_BUILD="True"

# Prepare cmdeploy
RUN scripts/initenv.sh \
    && cmdeploy fmt -v \
    && pytest --pyargs cmdeploy \
    && cmdeploy init chatmail.replaceme.local

# Run cmdeploy against local target
RUN cmdeploy run --verbose

# Default command to run the container (need to flip to use entrypoint to reconfigure and start systemd)
CMD ["bash"]
