package cmd

import (
	"github.com/spf13/cobra"

	"github.com/lvlcn-t/dotfiles/internal/wizard"
)

func newConfigureCmd() *cobra.Command {
	return &cobra.Command{
		Use:   "configure",
		Short: "Run the interactive configuration wizard",
		Long:  "Launches an interactive TUI wizard to configure chezmoi settings.",
		RunE: func(cmd *cobra.Command, _ []string) error {
			return wizard.Run(cmd.Context())
		},
	}
}
