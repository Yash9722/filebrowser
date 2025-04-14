# Stage 1: Build the binary
FROM golang:1.19-alpine as builder

WORKDIR /go/src/app

# Copy the go.mod and go.sum files from the cmd directory
COPY cmd/go.mod cmd/go.sum ./

# Download dependencies
RUN go mod tidy

# Copy the rest of the application code from the cmd directory
COPY cmd/ ./cmd/

# Build the binary
RUN go build -o /filebrowser ./cmd

# Stage 2: Runtime image
FROM alpine:latest

# Copy the built binary from the build stage
COPY --from=builder /filebrowser /filebrowser

# Copy other necessary files like healthcheck script, etc.
COPY healthcheck.sh /healthcheck.sh
RUN chmod +x /healthcheck.sh  # Make the script executable

HEALTHCHECK --start-period=2s --interval=5s --timeout=3s \
    CMD /healthcheck.sh || exit 1

VOLUME /srv
EXPOSE 80

COPY docker_config.json /.filebrowser.json
ENTRYPOINT [ "/filebrowser" ]
