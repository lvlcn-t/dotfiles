package wizard

import "context"

// Section represents a configurable section in the wizard.
type Section interface {
	// Name returns the display name of the section.
	Name() string
	// Status returns a short status string (e.g. "enabled", "3 machines").
	Status() string
	// Configure runs the interactive configuration for this section.
	Configure(ctx context.Context) error
}
