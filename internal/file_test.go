package runtime

import (
	"testing"

	"github.com/fsouza/go-dockerclient"
)

func TestIsRemoteInstance(t *testing.T) {
	variables := make(map[string]string)

	var client *docker.Client
	var err error

	client, err = docker.NewClient("tcp://blah.de")
	if err != nil {
		t.Fatal("Unexpected error", err)
	}
	inv := New(variables, client, ".", "")
	if !inv.isUsingRemoteInstance() {
		t.Error("expected remote instance")
	}

	client, err = docker.NewClient("unix:///var/run/docker.sock")
	if err != nil {
		t.Fatal("Unexpected error", err)
	}
	inv = New(variables, client, ".", "")
	if inv.isUsingRemoteInstance() {
		t.Error("expected local instance")
	}
}

func TestPlatformInjectedIntoValues(t *testing.T) {
	variables := make(map[string]string)
	inv := New(variables, nil, ".", "linux/arm64")
	if v, ok := inv.Values["platform"]; !ok || v != "linux/arm64" {
		t.Errorf("Expected platform=linux/arm64 in Values, got %q (ok=%v)", v, ok)
	}
}

func TestPlatformEmptyNotInjectedIntoValues(t *testing.T) {
	variables := make(map[string]string)
	inv := New(variables, nil, ".", "")
	if _, ok := inv.Values["platform"]; ok {
		t.Error("Expected platform key to not be present in Values when empty")
	}
}

func TestPlatformAccessibleViaVAR(t *testing.T) {
	inv := New(make(map[string]string), nil, ".", "linux/arm64")
	if err := inv.RunString(`
		local p = VAR.platform
		if p ~= 'linux/arm64' then
			error('Expected linux/arm64 but got ' .. tostring(p))
		end
	`); err != nil {
		t.Fatal(err)
	}
}
