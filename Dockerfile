# Stage 1: Build binary
FROM golang:1.21-alpine as builder

WORKDIR /app

RUN apk add --no-cache git

# Copy the whole source
COPY . .

# Move to the directory where go.mod and main.go exist
WORKDIR /app/cmd/filebrowser

# Build the binary
RUN go build -o /filebrowser

# Stage 2: Runtime image
FROM alpine:latest

RUN apk --update add ca-certificates \
                     mailcap \
                     curl \
                     jq

# Copy the built binary from builder
COPY --from=builder /filebrowser /filebrowser
COPY docker_config.json /.filebrowser.json
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /filebrowser /healthcheck.sh

HEALTHCHECK --start-period=2s --interval=5s --timeout=3s \
    CMD /healthcheck.sh || exit 1

VOLUME /srv
EXPOSE 80

ENTRYPOINT ["/filebrowser"]
