build:
    docker build -t chatmail .

container-shell:
    just build
    docker run -it chatmail

test:
    docker build -t chatmail .
    trivy image chatmail:latest