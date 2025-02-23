# Use the official Debian 12 (Bookworm) image as the base image
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

ADD https://github.com/gdraheim/docker-systemctl-replacement/raw/refs/heads/master/files/docker/systemctl3.py /usr/bin/systemctl

# Install necessary packages and set up the environment
RUN apt-get update && apt-get install -y python3 python3-dev build-essential \
    && apt-get clean && chmod 755 /usr/bin/systemctl

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
