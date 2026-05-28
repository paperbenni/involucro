package integrationtest

import (
	"flag"
	"os"
	"testing"

	"github.com/involucro/involucro/ilog"
)

func TestMain(m *testing.M) {
	flag.Parse()
	if !testing.Verbose() {
		ilog.StdLog.SetPrintFunc(func(b ilog.Bough) {})
	}
	os.Exit(m.Run())
}
