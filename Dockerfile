# Stage 1: Build binary
FROM golang:1.21-alpine as builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy source code
COPY . .

# Build filebrowser binary
RUN go build -o filebrowser .

# Stage 2: Runtime image
FROM alpine:latest

RUN apk --update add ca-certificates \
                     mailcap \
                     curl \
                     jq

COPY --from=builder /app/filebrowser /filebrowser
COPY docker_config.json /.filebrowser.json
COPY healthcheck.sh /healthcheck.sh

RUN chmod +x /filebrowser /healthcheck.sh

HEALTHCHECK --start-period=2s --interval=5s --timeout=3s \
    CMD /healthcheck.sh || exit 1

VOLUME /srv
EXPOSE 80

ENTRYPOINT ["/filebrowser"]
