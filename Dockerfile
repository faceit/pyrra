FROM --platform=linux/amd64 node:20.18.0-alpine3.20 as ui-builder

WORKDIR /ui
COPY ui/ .
RUN npm install react-scripts
RUN npm install
RUN npm run build

FROM --platform=linux/amd64 golang:1.23.3-alpine3.20 as go-builder
WORKDIR /app
COPY . .
COPY --from=ui-builder /ui/build ui/build
RUN CGO_ENABLED=0 go build -v -ldflags '-w -extldflags '-static'' -o pyrra

FROM --platform=linux/amd64 docker.io/alpine:3.20.3 AS runner
WORKDIR /
COPY --chown=0:0 --from=go-builder /app/pyrra /usr/bin/pyrra
USER 65533

ENTRYPOINT ["/usr/bin/pyrra"]
