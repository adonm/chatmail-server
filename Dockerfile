# Use the official Debian 12 (Bookworm) image as the base image
FROM debian:bookworm-slim

# Set environment variables
ENV DEBIAN_FRONTEND=noninteractive

# Install necessary packages
RUN apt-get update && apt-get install -y \
    curl \
    rsync \
    ssh \
    python3 \
    python3-venv \
    python3-pip \
    openssh-client \
    openssh-server \
    nsd \
    && apt-get clean

# Set up the working directory
WORKDIR /app

# Copy the application code to the container
COPY . /app

# Add venv/bin to PATH
ENV PATH="/app/venv/bin:${PATH}"

# Run the initialization script
RUN scripts/initenv.sh

# Run formatting checks
RUN cmdeploy fmt -v

# Run offline tests
RUN pytest --pyargs cmdeploy

# Initialize the deployment
RUN cmdeploy init chat.localhost

# Run the deployment (likely will fail need to adjust for container)
RUN cmdeploy run --verbose

# Default command to run the container (need to flip to start systemd)
CMD ["tail", "-f", "/dev/null"]
