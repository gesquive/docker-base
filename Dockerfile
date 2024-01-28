ARG BASE_IMAGE=scratch
FROM golang:1.20-alpine AS builder

ENV GO111MODULE=on
RUN go install github.com/boxboat/fixuid@v0.6.0 && chmod 4755 ${GOPATH}/bin/fixuid

# Runner user/group
RUN addgroup -g 1000 runner && \
    adduser -u 1000 -G runner -h /home/runner -s /bin/sh -D runner

RUN apk update && apk add --no-cache ca-certificates tzdata && update-ca-certificates

RUN mkdir -p /etc/fixuid
RUN mkdir -p /var/run
COPY fixuid.yml /etc/fixuid/config.yml

# =============================================================================
FROM ${BASE_IMAGE}
LABEL maintainer="Gus Esquivel <gesquive@gmail.com>"
ENV BIN /usr/local/bin

# Import from builder
COPY --from=builder /usr/share/zoneinfo /usr/share/zoneinfo
COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Import the user/group files from builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Import from builder
COPY --from=builder /go/bin/fixuid ${BIN}/fixuid
COPY --from=builder /etc/fixuid /etc/fixuid
COPY --from=builder /var/run/ /var/run

# Add entrypoint script fixuid
COPY run.sh ${BIN}/run

# Use an unprivileged user
ONBUILD USER runner:runner
