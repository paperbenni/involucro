#!/usr/bin/env bash
set -euo pipefail

PKGS=(./internal/... ./auth)
VERSION="$(git describe --tags --always)"
LDFLAGS="-s -w -X github.com/involucro/involucro/app.version=$VERSION"

if [[ "$MODE" == "unit" ]]; then
    go test -v -short "${PKGS[@]}"
fi

if [[ "$MODE" == "windows-build" ]]; then
    go get -u github.com/josephspurrier/goversioninfo/cmd/goversioninfo
    "$GOPATH"/bin/goversioninfo "-product-version=$VERSION"

    CGO_ENABLED=0 GOOS=windows GOARCH=amd64 go build -o involucro.exe -ldflags "$LDFLAGS" ./cmd/involucro
    CGO_ENABLED=0 GOOS=windows GOARCH=386 go build -o involucro32.exe -ldflags "$LDFLAGS" ./cmd/involucro
    file involucro.exe involucro32.exe

elif [[ "$MODE" == "cross-arm64" ]]; then
    CGO_ENABLED=0 GOARCH=arm64 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    file "$FILENAME"

elif [[ "$MODE" == "cross-arm" ]]; then
    CGO_ENABLED=0 GOARCH=arm go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    file "$FILENAME"

else
    CGO_ENABLED=0 go build -o "$FILENAME" -ldflags "$LDFLAGS" ./cmd/involucro
    "./$FILENAME" --version
fi

if [[ "$MODE" == "integration" ]]; then
    "./$FILENAME" wrap-yourself && go test -v "${PKGS[@]}"
fi
