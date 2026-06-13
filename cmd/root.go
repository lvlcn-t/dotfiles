package cmd

import (
	"github.com/spf13/cobra"

	"github.com/lvlcn-t/dotfiles/internal/chezmoi"
)

var nonInteractive bool

// IsNonInteractive reports whether the --non-interactive flag was set.
func IsNonInteractive() bool { return nonInteractive }

// Dotfiles is the root command for the dotfiles CLI.
var Dotfiles = &cobra.Command{
	Use:               "dotfiles",
	Short:             ShortDescription,
	Long:              Description,
	Example:           Example,
	Version:           Version,
	DisableAutoGenTag: true,
	SilenceUsage:      true,
	SilenceErrors:     true,
	Args:              cobra.ArbitraryArgs,
	RunE: func(cmd *cobra.Command, args []string) error {
		return chezmoi.Exec(cmd.Context(), args...)
	},
}

func init() { //nolint:gochecknoinits // Cobra convention
	Dotfiles.PersistentFlags().BoolVar(
		&nonInteractive,
		"non-interactive",
		false,
		"Skip all prompts and use template defaults (for CI/testing)",
	)

	Dotfiles.AddCommand(newConfigureCmd())
	Dotfiles.AddCommand(newApplyCmd())
}
