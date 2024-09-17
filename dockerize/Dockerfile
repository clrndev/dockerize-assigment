FROM golang:1.22 as builder

ENV USER=appuser 
ENV UID=10001

WORKDIR /app
COPY . .

RUN adduser \    
    --disabled-password \    
    --gecos "" \    
    --home "/nonexistent" \    
    --shell "/sbin/nologin" \    
    --no-create-home \    
    --uid "${UID}" \    
    "${USER}" && \
    touch log.txt && \
    chown -R ${USER}:${USER} /app

RUN go mod tidy && \
    CGO_ENABLED=0 GO111MODULES=on go build -ldflags="-s -w" -o dockerize .

FROM scratch

ENV USER=appuser

COPY --from=builder /etc/passwd /etc/passwd
COPY --from=builder /etc/group /etc/group
COPY --from=builder /app/log.txt /log.txt

WORKDIR /app
COPY --from=builder /app/dockerize /app
COPY --from=builder /app/src /app/src

USER $USER

ENTRYPOINT ["/app/dockerize"]
