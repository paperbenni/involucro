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

local is_pull_request = ENV.TRAVIS_PULL_REQUEST
if is_pull_request == "" and ENV.GITHUB_ACTIONS == "true" then
	is_pull_request = ENV.GITHUB_EVENT_NAME == "pull_request" and "true" or "false"
end

if is_pull_request == "false" then
	local tag = ENV.TRAVIS_TAG

	if tag == "" and ENV.GITHUB_REF_TYPE == "tag" then
		tag = ENV.GITHUB_REF_NAME
	end

	if tag == "" then
		tag = ENV.TRAVIS_BRANCH
	end

	if tag == "" and ENV.GITHUB_REF_TYPE == "branch" then
		tag = ENV.GITHUB_REF_NAME
	end

	if tag == "main" then
		tag = "latest"
	end

	inv.task("upload-to-hub").tag(repo .. ":latest").as(repo .. ":" .. tag).push(repo .. ":" .. tag)
end
