build:
    docker build -t chatmail .

container-shell:
    just build
    docker run -it chatmail