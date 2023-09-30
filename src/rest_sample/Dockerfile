FROM golang:1.21 AS builder

WORKDIR /src

COPY ./src/rest_sample/go.mod ./

RUN go mod download

COPY ./src/rest_sample/ .

RUN CGO_ENABLED=0 GOOS=linux go build -o app .

FROM gcr.io/distroless/base-debian12:nonroot

WORKDIR /bin

EXPOSE 8888

USER nonroot:nonroot

COPY --from=builder --chown=nonroot:nonroot /src/app .

ENTRYPOINT ["/bin/app"]