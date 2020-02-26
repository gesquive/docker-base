FROM gesquive/go-builder:latest AS builder

ENV GO111MODULE=on
RUN go get -v github.com/boxboat/fixuid && chmod 4755 ${GOPATH}/bin/fixuid

# Create build user/group
# RUN addgroup -g 1000 runner && \
#     adduser -u 1000 -G runner -h /home/runner -s /bin/sh -D runner

RUN mkdir -p /etc/fixuid
COPY fixuid.yml /etc/fixuid/config.yml

FROM scratch
LABEL maintainer="Gus Esquivel <gesquive@gmail.com>"
ENV BIN /usr/local/bin

# Import the user/group files from builder
COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

# Import from builder
COPY --from=builder /go/bin/fixuid ${BIN}/fixuid
COPY --from=builder /etc/fixuid /etc/fixuid

# Add entrypoint script fixuid
COPY run.sh ${BIN}/run

# Use an unprivileged user
USER runner:runner
