# Stage 1: Build
FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install git (required by Go if modules pull from GitHub)
RUN apk add --no-cache git

# Copy all source code into the image
COPY . .

# Build the filebrowser binary from root (where go.mod is)
RUN go build -o /filebrowser

# Stage 2: Runtime
FROM alpine:latest

# Install runtime dependencies
RUN apk --no-cache add ca-certificates mailcap curl jq

# Copy the built binary and config files from builder stage
COPY --from=builder /filebrowser /filebrowser
COPY docker_config.json /.filebrowser.json
COPY healthcheck.sh /healthcheck.sh

# Make healthcheck and binary executable
RUN chmod +x /filebrowser /healthcheck.sh

# Setup healthcheck
HEALTHCHECK --start-period=2s --interval=5s --timeout=3s \
    CMD /healthcheck.sh || exit 1

VOLUME /srv
EXPOSE 80

ENTRYPOINT ["/filebrowser"]
