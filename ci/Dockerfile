FROM scratch

ARG TARGETARCH
ARG TARGETVARIANT

COPY docker-context/${TARGETARCH}${TARGETVARIANT}/involucro /involucro

ENTRYPOINT ["/involucro"]
