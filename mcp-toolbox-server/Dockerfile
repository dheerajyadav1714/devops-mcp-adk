FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates curl && rm -rf /var/lib/apt/lists/*

# Download the latest toolbox binary for Linux amd64
ARG VERSION=0.23.0
RUN curl -L -o /app/toolbox https://storage.googleapis.com/genai-toolbox/v${VERSION}/linux/amd64/toolbox && \
    chmod +x /app/toolbox

COPY tools.yaml /app/tools.yaml
WORKDIR /app
CMD ./toolbox serve --address 0.0.0.0 --port ${PORT}
