// Package wizard provides the interactive TUI configuration wizard.
package wizard

import (
	"context"
	"fmt"
	"os"

	"github.com/charmbracelet/huh"

	"github.com/lvlcn-t/dotfiles/internal/config"
)

// Run launches the interactive configuration wizard.
func Run(ctx context.Context) error {
	cfg, err := config.Load()
	if err != nil {
		return fmt.Errorf("loading config: %w", err)
	}

	sections := []Section{
		&ProxySection{cfg: cfg},
		&NetrcSection{cfg: cfg},
		&ConjurSection{cfg: cfg},
	}

	for {
		if err := ctx.Err(); err != nil {
			return err
		}

		choice, err := showMenu(ctx, sections)
		if err != nil {
			return err
		}

		switch choice {
		case actionSave:
			if err := config.Save(cfg); err != nil {
				return fmt.Errorf("saving config: %w", err)
			}
			fmt.Fprintln(os.Stdout, "Configuration saved.")
			return nil
		case actionQuit:
			return nil
		default:
			idx := int(choice)
			if idx >= 0 && idx < len(sections) {
				if err := sections[idx].Configure(ctx); err != nil {
					return err
				}
			}
		}
	}
}

type menuAction int

const (
	actionSave menuAction = -1
	actionQuit menuAction = -2
)

func showMenu(ctx context.Context, sections []Section) (menuAction, error) {
	options := make([]huh.Option[int], 0, len(sections)+2)
	for i, s := range sections {
		label := fmt.Sprintf("%s %s", s.Name(), s.Status())
		options = append(options, huh.NewOption(label, i))
	}
	options = append(options,
		huh.NewOption("Save & exit", int(actionSave)),
		huh.NewOption("Quit without saving", int(actionQuit)),
	)

	var choice int
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[int]().
				Title("What would you like to configure?").
				Options(options...).
				Value(&choice),
		),
	).WithAccessible(false)

	if err := form.RunWithContext(ctx); err != nil {
		return actionQuit, err
	}

	return menuAction(choice), nil
}
