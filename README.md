# dotfiles 🛠️

This repository contains my personal dotfiles for setting up and maintaining a consistent and productive development environment across different machines. Dotfiles are configuration files that are used to customize and automate the setup of software applications and tools on Unix/Linux systems. By managing these files in a repository, it becomes easier to synchronize preferences and settings across multiple environments.

## About this component 📝

This dotfiles collection includes configurations for Zsh, Git, wget and npm, along with a Brewfile for managing software installations through Homebrew. Here's a brief overview of each component:

- 💻 **dot_zshrc**: Customizes the Zsh shell environment, including aliases, functions, and shell options for improved command-line efficiency.
- 🎨 **dot_p10k.zsh**: Configuration for the Powerlevel10k Zsh theme, enabling a highly customizable prompt that is both aesthetically pleasing and informative.
- 🌍 **dot_gitconfig**: Manages global Git settings, enhancing security and workflow efficiency. It configures the default branch name, enables conditional includes for separating personal and work-related configurations, and ensures all commits are signed. This setup provides a seamless transition between personal and professional projects while maintaining a high standard of code integrity.
- 🏡 **dot_gitconfig-personal** & 💼 **dot_gitconfig-work**: Define specific Git configurations for personal and work contexts, automatically applied based on the repository's remote URL. This allows for a smooth workflow differentiation, keeping personal and professional contributions distinct and properly configured without manual switching.
- 🗝️ **dot_netrc**: Includes credentials for accessing remote servers, allowing for automated authentication. I use it to store GitLab credentials for automated access to private repositories.
- 📥 **dot_wgetrc**: Configuration for wget, customizing options for downloads.
- 📦 **dot_npmrc**: npm configuration file for managing node package settings.
- 🍺 **Brewfile**: A list of software to be installed via Homebrew, facilitating quick setup of new machines with necessary tools and applications.

Feel free to explore and adapt these configurations to suit your own development needs and preferences. Happy coding! 😄

## Installation 🚀

This installation process will **overwrite** any existing configuration files, so make sure to back up your current dotfiles before proceeding.

To install my dotfiles, simply run the following command in your terminal:

```bash
sh -c "$(curl -fsLS get.chezmoi.io)" -- init --apply lvlcn-t
```

This command will install [chezmoi](https://chezmoi.io/) and apply my dotfiles to your system. Chezmoi is a tool for managing dotfiles across multiple machines, and it provides a simple and secure way to manage your configuration files. You can find more information about chezmoi and its usage in the [official documentation](https://www.chezmoi.io/docs/).
