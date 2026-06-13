// Package config handles loading and saving the chezmoi configuration file.
package config

import (
	"fmt"
	"io/fs"
	"os"
	"path/filepath"

	"github.com/pelletier/go-toml/v2"
)

const (
	dirMode  fs.FileMode = 0o755
	fileMode fs.FileMode = 0o600
)

// defaultConfig is the out-of-the-box configuration written when no config
// exists and the wizard is skipped (non-interactive mode).
var defaultConfig = Config{
	Git: Git{
		AutoCommit:            true,
		AutoPush:              false,
		CommitMessageTemplate: `{{ promptString "Commit message" }}`,
	},
	Edit: Edit{
		Command: "code",
		Args:    "--wait",
	},
	Data: Data{
		Netrc: Netrc{
			Machines: []NetrcMachine{
				{URL: "https://gitlab.com", Username: "__token__", Token: "glpat-xxxxxxx"},
				{URL: "https://github.com", Username: "__token__", Token: "ghp_xxxxxxx"},
				{URL: "https://jira.example.com", Username: "username", Token: "api_token"},
			},
		},
		Machine: Machine{
			Proxy: Proxy{
				Enabled: false,
				HTTP:    "http://proxy.example.com:8080",
				HTTPS:   "https://proxy.example.com:8080",
				NoProxy: "example.com",
			},
			Conjur: Conjur{
				URL:       "https://conjur.example.com",
				Account:   "my-account",
				SNS:       "example/secret/namespace",
				LoginHost: "$CONJUR_SNS/my-host",
				APIKey:    "my-api-key",
			},
		},
	},
}

// Default returns a copy of the default configuration.
func Default() Config {
	return defaultConfig
}

// DefaultPath returns the default chezmoi config file path.
func DefaultPath() string {
	home, _ := os.UserHomeDir()
	return filepath.Join(home, ".config", "chezmoi", "chezmoi.toml")
}

// Exists checks whether the config file exists.
func Exists() bool {
	_, err := os.Stat(DefaultPath())
	return err == nil
}

// CopyTemplate writes the default config to disk without overwriting an
// existing file.
func CopyTemplate() error {
	if Exists() {
		return nil
	}
	return Save(&defaultConfig)
}

// Config represents the full chezmoi configuration.
type Config struct {
	Git  Git  `toml:"git,omitempty"`
	Edit Edit `toml:"edit,omitempty"`
	Data Data `toml:"data"`
}

// Git holds git-related chezmoi settings.
type Git struct {
	AutoCommit            bool   `toml:"autoCommit,omitempty"`
	AutoPush              bool   `toml:"autoPush,omitempty"`
	CommitMessageTemplate string `toml:"commitMessageTemplate,omitempty"`
}

// Edit holds editor settings.
type Edit struct {
	Command string `toml:"command,omitempty"`
	Args    string `toml:"args,omitempty"`
}

// Data holds the [data] section.
type Data struct {
	Netrc   Netrc   `toml:"netrc"`
	Machine Machine `toml:"machine"`
}

// Netrc holds netrc machine credentials.
type Netrc struct {
	Machines []NetrcMachine `toml:"machines"`
}

// NetrcMachine represents a single netrc entry.
type NetrcMachine struct {
	URL      string `toml:"url"`
	Username string `toml:"username"`
	Token    string `toml:"token"`
}

// Machine holds machine-specific configuration.
type Machine struct {
	Proxy  Proxy  `toml:"proxy"`
	Conjur Conjur `toml:"conjur"`
}

// Proxy holds proxy configuration.
type Proxy struct {
	Enabled bool   `toml:"enabled"`
	HTTP    string `toml:"http"`
	HTTPS   string `toml:"https"`
	NoProxy string `toml:"no_proxy"`
}

// Conjur holds Conjur configuration.
type Conjur struct {
	URL       string `toml:"url"`
	Account   string `toml:"account"`
	SNS       string `toml:"sns"`
	LoginHost string `toml:"login_host"`
	APIKey    string `toml:"api_key"`
}

// Load reads the config from disk. Returns the default config if no file
// exists.
func Load() (*Config, error) {
	data, err := os.ReadFile(DefaultPath())
	if err != nil {
		if os.IsNotExist(err) {
			cfg := Default()
			return &cfg, nil
		}
		return nil, fmt.Errorf("reading config: %w", err)
	}

	var cfg Config
	if err := toml.Unmarshal(data, &cfg); err != nil {
		return nil, fmt.Errorf("parsing config: %w", err)
	}
	return &cfg, nil
}

// Save writes the config to disk with 0600 permissions.
func Save(cfg *Config) error {
	path := DefaultPath()
	if err := os.MkdirAll(filepath.Dir(path), dirMode); err != nil {
		return fmt.Errorf("creating config directory: %w", err)
	}

	data, err := toml.Marshal(cfg)
	if err != nil {
		return fmt.Errorf("marshaling config: %w", err)
	}

	if err := os.WriteFile(path, data, fileMode); err != nil {
		return fmt.Errorf("writing config: %w", err)
	}
	return nil
}
