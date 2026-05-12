set shell := ["bash", "-eu", "-o", "pipefail", "-c"]

default:
    @just --list

format:
    gofmt -w $(find . -path ./vendor -prune -o -name '*.go' -print)
    shfmt -w ci/*.sh
    stylua $(find . -path ./vendor -prune -o -name '*.lua' -print)
    prettier --write .github/workflows/*.yml appveyor.yml
    just --fmt --justfile justfile
