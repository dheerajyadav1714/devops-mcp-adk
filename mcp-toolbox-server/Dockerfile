FROM debian:bullseye-slim
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*
COPY toolbox /app/toolbox
COPY tools.yaml /app/tools.yaml
WORKDIR /app
RUN chmod +x toolbox
CMD ./toolbox serve --address 0.0.0.0 --port ${PORT}
