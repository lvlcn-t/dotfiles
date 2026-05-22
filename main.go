package main

import (
	"context"
	"os"
	"os/signal"
	"syscall"

	"github.com/lvlcn-t/dotfiles/cmd"
)

// version is set at build time via ldflags.
var version = "dev"

func main() {
	cmd.Dotfiles.Version = version
	os.Exit(run(context.Background()))
}

func run(ctx context.Context) int {
	ctx, cancel := signal.NotifyContext(ctx, syscall.SIGINT, syscall.SIGTERM)
	defer cancel()
	if err := cmd.Dotfiles.ExecuteContext(ctx); err != nil {
		return 1
	}
	return 0
}
