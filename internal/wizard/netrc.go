package wizard

import (
	"context"
	"fmt"

	"github.com/charmbracelet/huh"

	"github.com/lvlcn-t/dotfiles/internal/config"
)

// NetrcSection handles netrc machine configuration.
type NetrcSection struct {
	cfg *config.Config
}

func (s *NetrcSection) Name() string { return "Netrc" }

func (s *NetrcSection) Status() string {
	n := len(s.cfg.Data.Netrc.Machines)
	if n == 0 {
		return "(no machines)"
	}
	return fmt.Sprintf("(%d machines)", n)
}

func (s *NetrcSection) Configure(ctx context.Context) error {
	for {
		if err := ctx.Err(); err != nil {
			return err
		}

		action, err := s.showMachineMenu(ctx)
		if err != nil {
			return err
		}

		switch action {
		case netrcActionAdd:
			if err := s.addMachine(ctx); err != nil {
				return err
			}
		case netrcActionBack:
			return nil
		default:
			// Edit existing machine at index
			idx := int(action)
			if idx >= 0 && idx < len(s.cfg.Data.Netrc.Machines) {
				if err := s.editMachine(ctx, idx); err != nil {
					return err
				}
			}
		}
	}
}

type netrcAction int

const (
	netrcActionAdd  netrcAction = -1
	netrcActionBack netrcAction = -2
)

func (s *NetrcSection) showMachineMenu(ctx context.Context) (netrcAction, error) {
	machines := s.cfg.Data.Netrc.Machines
	options := make([]huh.Option[int], 0, len(machines)+2)

	for i, m := range machines {
		label := fmt.Sprintf("%s (%s)", m.URL, m.Username)
		options = append(options, huh.NewOption(label, i))
	}
	options = append(options,
		huh.NewOption("+ Add machine", int(netrcActionAdd)),
		huh.NewOption("← Back", int(netrcActionBack)),
	)

	var choice int
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[int]().
				Title("Netrc machines").
				Options(options...).
				Value(&choice),
		),
	)

	if err := form.RunWithContext(ctx); err != nil {
		return netrcActionBack, err
	}
	return netrcAction(choice), nil
}

func (s *NetrcSection) addMachine(ctx context.Context) error {
	m := config.NetrcMachine{}
	if err := s.machineForm(ctx, &m); err != nil {
		return err
	}
	s.cfg.Data.Netrc.Machines = append(s.cfg.Data.Netrc.Machines, m)
	return nil
}

func (s *NetrcSection) editMachine(ctx context.Context, idx int) error {
	m := &s.cfg.Data.Netrc.Machines[idx]

	var action string
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewSelect[string]().
				Title(fmt.Sprintf("Machine: %s", m.URL)).
				Options(
					huh.NewOption("Edit", "edit"),
					huh.NewOption("Delete", "delete"),
					huh.NewOption("Back", "back"),
				).
				Value(&action),
		),
	)

	if err := form.RunWithContext(ctx); err != nil {
		return err
	}

	switch action {
	case "edit":
		return s.machineForm(ctx, m)
	case "delete":
		s.cfg.Data.Netrc.Machines = append(
			s.cfg.Data.Netrc.Machines[:idx],
			s.cfg.Data.Netrc.Machines[idx+1:]...,
		)
	}
	return nil
}

func (s *NetrcSection) machineForm(ctx context.Context, m *config.NetrcMachine) error {
	form := huh.NewForm(
		huh.NewGroup(
			huh.NewInput().
				Title("URL").
				Placeholder("github.com").
				Value(&m.URL),
			huh.NewInput().
				Title("Username").
				Placeholder("__token__").
				Value(&m.Username),
			huh.NewInput().
				Title("Token").
				Placeholder("ghp_xxx or glpat-xxx").
				EchoMode(huh.EchoModePassword).
				Value(&m.Token),
		),
	)

	if err := form.RunWithContext(ctx); err != nil {
		return fmt.Errorf("netrc machine form: %w", err)
	}
	return nil
}
