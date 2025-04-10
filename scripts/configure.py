"""
This script configures the chezmoi configuration file while preserving
any skipped configuration items.
"""

from __future__ import annotations

import os
import stat
from typing import Any
import tomllib
import toml


TEMPLATE_DIR: str = os.path.expanduser("~/.local/share/chezmoi")
TEMPLATE_FILE: str = os.path.join(TEMPLATE_DIR, "chezmoi.toml")
CONFIG_DIR: str = os.path.expanduser("~/.config/chezmoi")
CONFIG_FILE: str = os.path.join(CONFIG_DIR, "chezmoi.toml")


class PrettyConfigSection:
    def __init__(self, section: dict[str, Any]) -> None:
        self.section = section

    def __str__(self) -> str:
        return self._pretty_print(self.section)

    def _pretty_print(self, obj: Any, indent: int = 0) -> str:
        spacer = "  " * indent
        result = ""
        if isinstance(obj, dict):
            for key, value in obj.items():
                emoji = self._emoji_for_key(key)
                result += f"{spacer}{emoji}{key}:\n"
                result += self._pretty_print(value, indent + 1)
        elif isinstance(obj, list):
            for i, item in enumerate(obj, start=1):
                result += f"{spacer}🔢 Entry {i}:\n"
                result += self._pretty_print(item, indent + 1)
        else:
            result += f"{spacer}- {obj}\n"
        return result

    def _emoji_for_key(self, key: str) -> str:
        return {
            "url": "🌐 ",
            "username": "👤 ",
            "token": "🔑 ",
            "enabled": "✅ " if self.section.get(key) else "❌ ",
            "http": "📡 ",
            "https": "🔒 ",
            "noProxy": "🚫 ",
            "machines": "🖥️ ",
            "proxy": "🌐 ",
        }.get(key, "📄 ")


def load_config() -> dict[str, Any]:
    """
    Load the existing configuration if it exists. If not, try to copy the template.
    If no template exists, return an empty configuration.
    """
    if os.path.exists(CONFIG_FILE):
        with open(CONFIG_FILE, "rb") as f:
            config = tomllib.load(f)
        print("📂 Loaded existing configuration.")
        return config

    print("⚠️ Configuration file not found.")
    if os.path.exists(TEMPLATE_FILE):
        with open(TEMPLATE_FILE, "rb") as f:
            config = tomllib.load(f)
        os.makedirs(CONFIG_DIR, exist_ok=True)
        with open(CONFIG_FILE, "w", encoding="utf-8") as f:
            toml.dump(config, f)
        print("🧪 Template copied to configuration file.")
        return config
    else:
        print("🆕 No template found. Starting with an empty configuration.")
        return {}


def ask_yes_no(prompt: str) -> bool | None:
    """
    Ask the user a yes/no/skip question.

    Returns:
        True if the answer is yes,
        False if no,
        None if skip.
    """
    while True:
        answer = input(f"{prompt} (y/n/skip): ").strip().lower()
        match answer:
            case "y" | "yes" | "ye" | "yeah" | "yep" | "bet" | "sure":
                return True
            case "n" | "no" | "nah" | "nope" | "never" | "not really":
                return False
            case "skip" | "s" | "sk" | "pass":
                return None
            case _:
                print("❓ Please answer with 'y', 'n', or 'skip'.")


def ask_value(prompt: str, default: str = "") -> str:
    """
    Ask the user for a value, showing an optional default.

    Args:
        prompt: The prompt message.
        default: The default value to use if no input is given.

    Returns:
        The user input or the default if no input was provided.
    """
    value: str = input(f"{prompt} [{default}]: ").strip()
    return value if value else default


def configure_netrc(config: dict[str, Any]) -> dict[str, Any]:
    """
    Update (or preserve) the netrc configuration section.

    Args:
        config: The current configuration dictionary.

    Returns:
        The updated configuration dictionary.
    """
    netrc_existing = config.get("data", {}).get("netrc", {})
    if netrc_existing:
        print("🔐 Current netrc configuration found:")
        print(PrettyConfigSection(netrc_existing))

    answer: bool | None = ask_yes_no("🧾 Do you want to configure netrc machines?")
    if answer is None:
        print("⏭️ Skipping netrc configuration, preserving current values.")
        return config

    machines: list[dict[str, str]] = []
    while True:
        print("➕ Adding a new machine:")
        machine: dict[str, str] = {
            "url": ask_value("🌐 Enter URL"),
            "username": ask_value("👤 Enter Username"),
            "token": ask_value("🔑 Enter Token"),
        }
        machines.append(machine)
        if ask_yes_no("➕ Do you want to add another netrc machine?") in (None, False):
            break

    config.setdefault("data", {})
    config["data"]["netrc"] = {"machines": machines}
    return config


def configure_proxy(config: dict[str, Any]) -> dict[str, Any]:
    """
    Update (or preserve) the proxy configuration section.

    Args:
        config: The current configuration dictionary.

    Returns:
        The updated configuration dictionary.
    """
    proxy_existing = config.get("data", {}).get("machine", {}).get("proxy", {})
    if proxy_existing:
        print("🌐 Current proxy configuration found:")
        print(PrettyConfigSection(proxy_existing))

    answer = ask_yes_no("🕸️ Enable proxy?")
    if answer is None:
        print("⏭️ Skipping proxy configuration, preserving current values.")
        return config

    if answer:
        enabled = True
        http = ask_value("📡 HTTP Proxy", default=proxy_existing.get("http", ""))
        https = ask_value("🔒 HTTPS Proxy", default=proxy_existing.get("https", ""))
        no_proxy = ask_value("🚫 No Proxy", default=proxy_existing.get("noProxy", ""))
    else:
        enabled = False
        http = "http://proxy.example.com:8080"
        https = "https://proxy.example.com:8080"
        no_proxy = "example.com"

    config.setdefault("data", {}).setdefault("machine", {})["proxy"] = {
        "enabled": enabled,
        "http": http,
        "https": https,
        "noProxy": no_proxy,
    }
    return config


def save_config(config: dict[str, Any]) -> None:
    """
    Write the updated configuration back to CONFIG_FILE.

    The file permissions are set so that only the owner can read and write the file.
    """
    with open(CONFIG_FILE, "w", encoding="utf-8") as f:
        toml.dump(config, f)
    os.chmod(CONFIG_FILE, stat.S_IRUSR | stat.S_IWUSR)
    print(f"✅ Configuration updated successfully and saved to 📄 {CONFIG_FILE}")


def main() -> None:
    print("🚀 Starting chezmoi configurator...\n")
    config = load_config()
    config = configure_netrc(config)
    config = configure_proxy(config)
    save_config(config)
    print("🎉 Done! Have a great day ✨")


if __name__ == "__main__":
    main()
