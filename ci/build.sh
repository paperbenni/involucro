#!/usr/bin/env bash
set -euo pipefail

PKGS=(./internal/... ./auth)
VERSION="$(git describe --tags --always)"
LDFLAGS="-s -w -X github.com/involucro/involucro/app.version=$VERSION"

if [[ "$MODE" == "unit" ]]; then
    go test -v -short "${PKGS[@]}"
fi

if [[ "$MODE" == "windows-amd64" ]]; then
    go get -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo
    "$GOPATH"/bin/goversioninfo "-product-version=$VERSION"

    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o involucro.exe -ldflags "$LDFLAGS" ./cmd/involucro
    file involucro.exe

elif [[ "$MODE" == "linux-amd64" ]]; then
    CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    file "$FILENAME"

elif [[ "$MODE" == "linux-arm64" ]]; then
    CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    file "$FILENAME"

elif [[ "$MODE" == "linux-arm-v7" ]]; then
    CGO_ENABLED=0 GOOS=linux GOARCH=arm GOARM=7 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    file "$FILENAME"

else
    CGO_ENABLED=0 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    "./$FILENAME" --version
fi

if [[ "$MODE" == "integration" ]]; then
    "./$FILENAME" wrap-yourself && go test -v "${PKGS[@]}"
fi
