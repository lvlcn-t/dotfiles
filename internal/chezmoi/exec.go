// Package chezmoi provides helpers for executing chezmoi commands.
package chezmoi

import (
	"context"
	"fmt"
	"os"
	"os/exec"
	"syscall"
)

// Exec executes chezmoi with the given arguments. If no context work needs to
// happen after the call (pure passthrough), it replaces the current process.
// Otherwise it uses exec.CommandContext for cancellation support.
func Exec(ctx context.Context, args ...string) error {
	binary, err := exec.LookPath("chezmoi")
	if err != nil {
		return fmt.Errorf("chezmoi not found in PATH: %w", err)
	}

	// For a pure passthrough we replace the process so signals are handled
	// natively by chezmoi.
	if ctx.Err() != nil {
		return ctx.Err()
	}

	return syscall.Exec(binary, append([]string{"chezmoi"}, args...), os.Environ())
}

// Run executes chezmoi with the given arguments and waits for completion.
// Use this when you need to do work after chezmoi finishes.
func Run(ctx context.Context, args ...string) error {
	binary, err := exec.LookPath("chezmoi")
	if err != nil {
		return fmt.Errorf("chezmoi not found in PATH: %w", err)
	}

	cmd := exec.CommandContext(ctx, binary, args...)
	cmd.Stdin = os.Stdin
	cmd.Stdout = os.Stdout
	cmd.Stderr = os.Stderr
	return cmd.Run()
}
