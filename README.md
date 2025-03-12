# macOS Environment Setup Script

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

This Bash script automates the setup of a macOS environment. It installs Xcode Command Line Tools, Homebrew, and a customizable list of commonly used command-line tools (formulae) and GUI applications (casks). It's designed to be idempotent (safe to run multiple times) and includes a dry-run mode for testing.

## Features

*   **Installs Xcode Command Line Tools:** Ensures the necessary developer tools are installed.
*   **Installs Homebrew:** The package manager for macOS.
*   **Installs Formulae:** Installs a predefined list of command-line tools (easily customizable).
*   **Installs Casks:** Installs a predefined list of GUI applications (easily customizable).
*   **Dry-Run Mode:** Allows you to see what actions the script *would* take without actually making any changes.
*   **Idempotent:** The script can be run multiple times without causing problems. It checks if components are already installed before attempting to install them.
*   **Error Handling:** Includes error checking and provides informative error messages.
*   **Zsh Integration:** Configures Homebrew for use with Zsh (the default shell on modern macOS).
*   **User Confirmation:** Asks the user for confirmation before making changes.

## Prerequisites

*   macOS (tested on macOS Ventura and later, but should work on older versions)
*   An internet connection

## Usage

1.  **Clone the repository:**

    ```bash
    git clone [https://github.com/YOUR_GITHUB_USERNAME/macos-env-setup.git](https://github.com/YOUR_GITHUB_USERNAME/macos-env-setup.git)
    cd macos-env-setup
    ```
    (Replace `YOUR_GITHUB_USERNAME` with your actual GitHub username.)

2.  **Make the script executable:**

    ```bash
    chmod +x setup.sh
    ```

3.  **Run the script:**

    ```bash
    ./setup.sh
    ```

4.  **Dry-Run (Optional):**

    To see what the script *would* do without making changes, use the `--dry-run` flag:

    ```bash
    ./setup.sh --dry-run
    ```

## Customization

You can easily customize the script to install your preferred tools and applications.

*   **Edit the `formulae` array:** Add or remove command-line tools (Homebrew formulae) in this array.
*   **Edit the `casks` array:** Add or remove GUI applications (Homebrew casks) in this array.

```bash
# --- Configuration ---
# List of formulae (command-line tools) to install, in alphabetical order
declare -a formulae=(
  git
  python
  terraform
  # Add more formulae here
)

# List of casks (GUI applications) to install, in alphabetical order
declare -a casks=(
  appcleaner
  boop
  brave-browser
  docker
  dockdoor
  ghostty
  gifox
  iina
  keka
  keepingyouawake
  logi-options+
  monitorcontrol
  notion
  notion-calendar
  onyx
  postman
  rectangle
  spotify
  stats
  utm
  visual-studio-code
  # Add more casks here
)
