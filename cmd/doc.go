// Package cmd implements the CLI commands for the dotfiles binary.
package cmd

// Version is injected at build time.
var Version = "dev"

const (
	// ShortDescription is the short description of the CLI.
	ShortDescription = "Manage your dotfiles with an interactive configuration wizard"

	// Description is the long description of the CLI.
	Description = `dotfiles is a wrapper around chezmoi that provides an interactive
configuration wizard for setting up your development environment.

It ensures your chezmoi configuration is in place before applying
dotfiles, eliminating chicken-and-egg dependency issues.

Any unknown subcommands are passed through to chezmoi directly.`

	// Example shows example usage.
	Example = `  # Run the interactive configuration wizard
  dotfiles configure

  # Apply dotfiles (runs wizard if no config exists)
  dotfiles apply

  # Pass through to chezmoi
  dotfiles diff
  dotfiles status`
)
