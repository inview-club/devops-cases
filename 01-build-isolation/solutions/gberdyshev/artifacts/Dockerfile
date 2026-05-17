FROM golang:1.26@sha256:595c7847cff97c9a9e76f015083c481d26078f961c9c8dca3923132f51fe12f1 AS builder

WORKDIR /src


ENV GOPROXY="http://10.166.0.5:8081/repository/golang-proxy"
ENV GOINSECURE="10.166.0.5:8081"

COPY go.mod go.sum ./

RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /bin/main ./main.go


FROM scratch

COPY --from=builder /bin/main /bin/main

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

CMD ["/bin/main"]