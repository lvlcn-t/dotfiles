package wizard

import (
	"context"
	"fmt"

	"github.com/charmbracelet/huh"

	"github.com/lvlcn-t/dotfiles/internal/config"
)

// ProxySection handles proxy configuration.
type ProxySection struct {
	cfg *config.Config
}

func (s *ProxySection) Name() string { return "Proxy" }

func (s *ProxySection) Status() string {
	p := s.cfg.Data.Machine.Proxy
	if p.HTTP == "" && p.HTTPS == "" {
		return "(not configured)"
	}
	if p.Enabled {
		return "(enabled)"
	}
	return "(disabled)"
}

func (s *ProxySection) Configure(ctx context.Context) error {
	p := &s.cfg.Data.Machine.Proxy

	form := huh.NewForm(
		huh.NewGroup(
			huh.NewConfirm().
				Title("Enable proxy?").
				Value(&p.Enabled),
			huh.NewInput().
				Title("HTTP Proxy").
				Placeholder("http://proxy.example.com:8080").
				Value(&p.HTTP),
			huh.NewInput().
				Title("HTTPS Proxy").
				Placeholder("https://proxy.example.com:8080").
				Value(&p.HTTPS),
			huh.NewInput().
				Title("No Proxy").
				Placeholder("localhost,127.0.0.1,.example.com").
				Value(&p.NoProxy),
		),
	)

	if err := form.RunWithContext(ctx); err != nil {
		return fmt.Errorf("proxy configuration: %w", err)
	}
	return nil
}
