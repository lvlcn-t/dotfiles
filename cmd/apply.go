package cmd

import (
	"fmt"

	"github.com/charmbracelet/huh"
	"github.com/spf13/cobra"

	"github.com/lvlcn-t/dotfiles/internal/chezmoi"
	"github.com/lvlcn-t/dotfiles/internal/config"
	"github.com/lvlcn-t/dotfiles/internal/wizard"
)

const (
	apply = "apply"
)

func newApplyCmd() *cobra.Command {
	return &cobra.Command{
		Use:   apply,
		Short: "Apply dotfiles (runs wizard if no config exists)",
		Long:  "Applies chezmoi dotfiles. Runs the configuration wizard when needed.",
		RunE: func(cmd *cobra.Command, args []string) error {
			ctx := cmd.Context()

			if IsNonInteractive() {
				if !config.Exists() {
					fmt.Fprintln(cmd.OutOrStdout(), "No configuration found. Writing template defaults.")
					if err := config.CopyTemplate(); err != nil {
						return err
					}
				}
				return chezmoi.Exec(ctx, append([]string{apply}, args...)...)
			}

			if !config.Exists() {
				if err := wizard.Run(ctx); err != nil {
					return err
				}
				return chezmoi.Exec(ctx, append([]string{apply}, args...)...)
			}

			var reconfigure bool
			form := huh.NewForm(
				huh.NewGroup(
					huh.NewConfirm().
						Title("Configuration already exists. Reconfigure?").
						Value(&reconfigure),
				),
			)
			if err := form.RunWithContext(ctx); err != nil {
				return fmt.Errorf("reconfigure prompt: %w", err)
			}

			if reconfigure {
				if err := wizard.Run(ctx); err != nil {
					return err
				}
			}

			return chezmoi.Exec(ctx, append([]string{apply}, args...)...)
		},
	}
}
