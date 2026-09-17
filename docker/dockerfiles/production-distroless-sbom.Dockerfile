# last_verified: 2026-09-17 · Docker n/a

FROM golang:alpine AS build
WORKDIR /src
COPY src/main.go .
RUN CGO_ENABLED=0 GOOS=linux go build -o /out/app ./main.go

FROM anchore/syft:latest AS sbom
WORKDIR /src
COPY --from=build /out/app /app
RUN syft /app -o spdx-json > /sbom.spdx.json

FROM gcr.io/distroless/static:nonroot AS runtime
COPY --from=build /out/app /app
COPY --from=sbom /sbom.spdx.json /sbom.spdx.json
USER nonroot:nonroot
EXPOSE 8080
ENTRYPOINT ["/app"]
