# dotfiles 🛠️

Welcome to my dotfiles repository! Here you'll find everything you need to set up and maintain a consistent and productive development environment across different machines. Dotfiles are configuration files that customize and automate the setup of software applications and tools on Unix/Linux systems. By managing these files in a repository, you can easily synchronize your preferences and settings across multiple environments.

## About This Component 📝

This dotfiles collection includes configurations for Zsh, Git, wget, and npm, along with a Brewfile for managing software installations through Homebrew. Here's a brief overview of each component:

- 💻 **dot_zshrc**: Customize your Zsh shell environment with aliases, functions, and shell options for improved command-line efficiency.
- 🎨 **dot_p10k.zsh**: Configure the Powerlevel10k Zsh theme for a highly customizable, aesthetically pleasing, and informative prompt.
- 🌍 **dot_gitconfig**: Manage global Git settings to enhance security and workflow efficiency. This setup provides a seamless transition between personal and professional projects while maintaining a high standard of code integrity.
- 🏡 **dot_gitconfig-personal** & 💼 **dot_gitconfig-work**: Automatically apply specific Git configurations for personal and work contexts based on the repository's remote URL, keeping personal and professional contributions distinct and properly configured.
- 🗝️ **dot_netrc**: Store credentials for accessing remote servers, allowing for automated authentication. Used for storing GitLab credentials for automated access to private repositories.
- 📥 **dot_wgetrc**: Customize options for wget downloads.
- 📦 **dot_npmrc**: Manage npm settings for your node packages.
- 🍺 **Brewfile**: Quickly set up new machines with necessary tools and applications using Homebrew.

Feel free to explore and adapt these configurations to suit your own development needs and preferences. Happy coding! 😄

## Installation 🚀

**Warning:** This installation process will **overwrite** any existing configuration files. Make sure to back up your current dotfiles before proceeding.

To install my dotfiles, simply run the following command in your terminal:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lvlcn-t
```

This command will install [chezmoi](https://chezmoi.io/) and apply my dotfiles to your system. Chezmoi is a tool for managing dotfiles across multiple machines, providing a simple and secure way to handle your configuration files. For more information, check out the [official documentation](https://www.chezmoi.io/docs/).

My dotfiles will bootstrap your system with the following:
- Passwordless `sudo` access for `$USER`.
- `zsh` as the default shell.
- Install all dependencies listed in the [`Brewfile`](Brewfile) using [Homebrew](https://brew.sh/).
- Configure Zsh with custom aliases and environment variables from [`dot_zshrc.d/`](./dot_zshrc.d/).
- Apply the Powerlevel10k theme configuration from [`dot_p10k.zsh`](dot_p10k.zsh).
- Set up Git with global settings from [`dot_gitconfig`](dot_gitconfig) and context-specific configurations from [`dot_gitconfig-personal`](dot_gitconfig-personal) and [`dot_gitconfig-work`](dot_gitconfig-work).
- Store and manage credentials for remote servers using [`dot_netrc`](dot_netrc.tmpl).
- Customize wget options with [`dot_wgetrc`](dot_wgetrc.tmpl).
- Configure npm settings with [`dot_npmrc`](dot_npmrc.tmpl).

Feel free to adapt these steps to your specific needs!