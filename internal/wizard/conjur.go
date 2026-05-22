package wizard

import (
	"context"
	"fmt"

	"github.com/charmbracelet/huh"

	"github.com/lvlcn-t/dotfiles/internal/config"
)

// ConjurSection handles Conjur configuration.
type ConjurSection struct {
	cfg *config.Config
}

func (s *ConjurSection) Name() string { return "Conjur" }

func (s *ConjurSection) Status() string {
	c := s.cfg.Data.Machine.Conjur
	if c.URL == "" {
		return "(not configured)"
	}
	return fmt.Sprintf("(%s)", c.Account)
}

func (s *ConjurSection) Configure(ctx context.Context) error {
	c := &s.cfg.Data.Machine.Conjur

	form := huh.NewForm(
		huh.NewGroup(
			huh.NewInput().
				Title("Conjur URL").
				Placeholder("https://conjur.example.com").
				Value(&c.URL),
			huh.NewInput().
				Title("Account").
				Placeholder("my-account").
				Value(&c.Account),
			huh.NewInput().
				Title("Secret Namespace").
				Placeholder("example/secret/namespace").
				Value(&c.SNS),
			huh.NewInput().
				Title("Login Host").
				Placeholder("$CONJUR_SNS/my-host").
				Value(&c.LoginHost),
			huh.NewInput().
				Title("API Key").
				EchoMode(huh.EchoModePassword).
				Value(&c.APIKey),
		),
	)

	if err := form.RunWithContext(ctx); err != nil {
		return fmt.Errorf("conjur configuration: %w", err)
	}
	return nil
}
