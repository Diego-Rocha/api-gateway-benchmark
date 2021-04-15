FROM golang:1.16-alpine AS builder
ADD app.go $GOPATH/src/krakend/app/
WORKDIR $GOPATH/src/krakend/app/

RUN go mod init krakend/app
RUN go mod tidy

RUN go get -d -v
RUN go build -o /go/bin/app

FROM alpine:latest
COPY --from=builder /go/bin/app .
ENTRYPOINT ./app