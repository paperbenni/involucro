set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

format:
    gofmt -w $(find . -name '*.go' -print)
    shfmt -i 4 -w ci/*.sh
    stylua $(find . -name '*.lua' -print)
    prettier --write .github/workflows/*.yml
    just --fmt --justfile justfile

install:
    go install ./cmd/involucro
