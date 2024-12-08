FROM golang:1.23 as build

WORKDIR /go/src/app
COPY . .

RUN go mod download
RUN CGO_ENABLED=0 go build -o /go/bin/app
#RUN mkdir -p /var/run/secrets/kubernetes.io/serviceaccount && echo "tokenstub" > "/var/run/secrets/kubernetes.io/serviceaccount/token"

# Now copy it into our base image.
FROM gcr.io/distroless/static-debian12
COPY --from=build /go/bin/app /
COPY fc.tmpl.yaml /
CMD ["/app"]
