local repo = "involucro/tool"

local tag = ENV.IMAGE_TAG or "latest"
local arch = ENV.TARGETARCH or "amd64"

-- Map architecture names to Docker platform strings
local platformMap = {
	amd64 = "linux/amd64",
	arm64 = "linux/arm64",
	armv7 = "linux/arm/v7",
}
local platform = platformMap[arch] or ("linux/" .. arch)

inv.task("wrap")
	.wrap("docker-context/" .. arch)
	.at("/")
	.withConfig({ entrypoint = { "/involucro" } })
	.withPlatform(platform)
	.as(repo .. ":" .. tag .. "-" .. arch)

inv.task("push").push(repo .. ":" .. tag .. "-" .. arch)

-- Keep wrap-yourself for local dev/integration testing on the host arch
inv.task("wrap-yourself")
	.using("busybox:latest")
	.run("mkdir", "-p", "dist/tmp/")
	.run("cp", "involucro", "dist/")
	.wrap("dist")
	.at("/")
	.withConfig({ entrypoint = { "/involucro" } })
	.as(repo .. ":latest")
	.using("busybox:latest")
	.run("rm", "-rf", "dist")
