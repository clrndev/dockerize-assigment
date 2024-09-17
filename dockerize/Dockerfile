FROM golang:1.22 as builder

ENV USER=appuser 
ENV UID=10001

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}"

WORKDIR /app
COPY . .

RUN go mod tidy && \
    CGO_ENABLED=0 GO111MODULES=on go build -ldflags="-s -w" -o dockerize .

FROM scratch

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group

WORKDIR /app
COPY --from=builder /app/dockerize /app
COPY --from=builder /app/src /app/src

USER $USER

ENTRYPOINT ["/app/dockerize"]
