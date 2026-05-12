local repo = "involucro/tool"

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

if ENV.GITHUB_ACTIONS == "true" and ENV.GITHUB_EVENT_NAME ~= "pull_request" then
	local tag = ENV.GITHUB_REF_NAME

	if tag == "main" then
		tag = "latest"
	end

	inv.task("upload-to-hub").tag(repo .. ":latest").as(repo .. ":" .. tag).push(repo .. ":" .. tag)
end
