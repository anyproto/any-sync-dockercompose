FROM golang:1.19

ARG REPO_DIR=.

# git+ssh {{
RUN apt-get update && apt-get install -y ca-certificates git-core ssh rsync
RUN mkdir -p -m 0700 ~/.ssh && ssh-keyscan github.com >> ~/.ssh/known_hosts
RUN git config --global url.ssh://git@github.com/.insteadOf https://github.com/
# }}

WORKDIR /app

# download go modules
COPY ${REPO_DIR}/go.mod ${REPO_DIR}/go.sum /
RUN --mount=type=ssh go mod download

COPY ${REPO_DIR} .

# build
RUN --mount=type=ssh make deps CGO_ENABLED=0
RUN --mount=type=ssh make build CGO_ENABLED=0
RUN rsync -a bin/ /bin/
