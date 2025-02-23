build:
    docker build --pull -t chatmail .

container-shell:
    just build
    docker run -it chatmail

test:
    docker build -t chatmail .
    trivy image chatmail:latest -s HIGH,CRITICAL