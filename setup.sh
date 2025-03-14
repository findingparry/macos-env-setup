#!/bin/bash

# --- Configuration ---
# List of formulae (command-line tools) to install, in alphabetical order
declare -a formulae=(
  git
  hashicorp/tap/terraform
  python
  ruby
)

# List of casks (GUI applications) to install, in alphabetical order
declare -a casks=(
  appcleaner
  boop
  docker
  ghostty
  keka
  keepingyouawake
  monitorcontrol
  postman
  rectangle
  stats
  utm
  visual-studio-code
)

# --- Global Variables ---
DRY_RUN=false  # Set to true to enable dry-run mode

# --- Functions ---

# Function to check if a command exists
command_exists() {
  command -v "$1" &> /dev/null
}

# Function to execute a command, handling dry-run and errors
execute_command() {
  local cmd="$1"
  local error_message="$2"
  if $DRY_RUN; then
    echo "[DRY RUN] Would execute: $cmd"
  else
    echo "Executing: $cmd"
    if ! bash -c "$cmd"; then  # Use bash -c for consistent command execution
      echo "ERROR: $error_message" >&2
      exit 1
    fi
  fi
}

# Function to install Xcode Command Line Tools, handling errors
install_xcode_tools() {
  echo "Installing Xcode Command Line Tools..."

  # Dry-run compatible check for existing installation
  if $DRY_RUN; then
    echo "[DRY RUN] Skipping Xcode CLT check (would check for git)."
  elif command_exists git; then
    echo "Xcode Command Line Tools are already installed (git found)."
    return 0
  fi


    # Trigger the installation and handle potential errors (no change in dry-run here, it's an interactive command)
    if ! xcode-select --install; then
        echo "ERROR: Failed to initiate Xcode Command Line Tools installation." >&2
        echo "Please install them manually and then re-run this script." >&2
        exit 1
    fi

    # Wait only if NOT in dry-run
    if ! $DRY_RUN; then
        echo "Waiting for Xcode Command Line Tools installation to complete..."
        while [[ ! -f /Library/Developer/CommandLineTools/usr/bin/git ]]; do
            sleep 5
        done

        # Verify git is installed after waiting (no change in dry-run)
        if command_exists git; then
            echo "Xcode Command Line Tools installed successfully."
        else
            echo "ERROR: Failed to install Xcode Command Line Tools installation seems to have failed." >&2
            echo "Please check the installation manually." >&2
            exit 1
        fi
    else
        echo "[DRY RUN] Xcode CLT installation would be triggered and waited for."
    fi
}

# Function to install a Homebrew formula, handling errors
install_formula() {
  local formula_name="$1"
  execute_command "brew install $formula_name" "Failed to install $formula_name"
}

# Function to install a Homebrew cask, handling errors
install_cask() {
  local cask_name="$1"
  execute_command "brew install --cask $cask_name" "Failed to install $cask_name"
}

# --- Main Script ---

# Check for dry-run flag
if [[ "$1" == "--dry-run" ]]; then
  DRY_RUN=true
  echo "Running in DRY-RUN mode. No changes will be made."
fi

# User confirmation prompt (skip in dry-run mode)
if ! $DRY_RUN; then
  echo "This script will install Xcode Command Line Tools, Homebrew, and several applications."
  echo "It will modify your shell configuration (~/.zprofile)."
  read -r -p "Do you want to continue? (y/N) " response
  case "$response" in
    [yY][eE][sS]|[yY])
      # Proceed with installation
      ;;
    *)
      echo "Installation cancelled."
      exit 0
      ;;
  esac
fi

# 1. Install Xcode Command Line Tools (if not already installed)
install_xcode_tools

# 2. Install Homebrew (if not already installed)
if ! command_exists brew; then
  echo "Installing Homebrew..."
  # Install Homebrew (this is a multi-line command, so we don't use execute_command)
  if $DRY_RUN; then
      echo "[DRY RUN] Would execute Homebrew installation script:"
      echo '  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"'
  else
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  fi

  # Determine Homebrew's bin directory (works on both Intel and Apple Silicon)
  # This needs to be done outside of execute_command because it's used in the next step
  if $DRY_RUN; then
      HOMEBREW_PREFIX="[DRY RUN - HOMEBREW_PREFIX]"
      echo "[DRY RUN] Would determine HOMEBREW_PREFIX"
  else
     HOMEBREW_PREFIX=$(/opt/homebrew/bin/brew --prefix || /usr/local/bin/brew --prefix)
  fi


  # Add Homebrew to the PATH *and* source the environment for the current shell.
    execute_command "echo 'eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\"' >> ~/.zprofile" "Failed to add Homebrew to ~/.zprofile"
    if ! $DRY_RUN; then
        eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    else
        echo "[DRY RUN] Would eval: eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\""
    fi


  echo "Homebrew installed."
else
  echo "Homebrew is already installed."
    # Determine Homebrew's bin directory, in case a reinstall changes it
    if $DRY_RUN; then
        HOMEBREW_PREFIX="[DRY RUN - HOMEBREW_PREFIX]"
        echo "[DRY RUN] Would determine HOMEBREW_PREFIX (already installed case)"
    else
        HOMEBREW_PREFIX=$(brew --prefix)
    fi
  # Ensure that the shell environment is set, even if Homebrew was already installed.
    if ! $DRY_RUN; then
        eval "$($HOMEBREW_PREFIX/bin/brew shellenv)"
    else
         echo "[DRY RUN] Would eval (already installed case): eval \"\$($HOMEBREW_PREFIX/bin/brew shellenv)\""
    fi
fi

# 3. Update Homebrew
execute_command "brew update" "Failed to update Homebrew"

# 4. Install Formulae
for formula in "${formulae[@]}"; do
  install_formula "$formula"
done

# 5. Install Casks
for cask in "${casks[@]}"; do
  install_cask "$cask"
done

echo "Installation complete!"
exit 0
