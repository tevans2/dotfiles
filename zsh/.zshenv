# XDG Base Directories
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# Path
[[ -f "$HOME/.zsh/path.zsh" ]] && . "$HOME/.zsh/path.zsh"

# Rust/Cargo
export CARGO_HOME="$XDG_DATA_HOME/cargo"
export RUSTUP_HOME="$XDG_DATA_HOME/rustup"

# Docker
export DOCKER_CONFIG="$XDG_CONFIG_HOME/docker"

# Deno
export DENO_DIR="$XDG_CACHE_HOME/deno"

# Haskell Stack
export STACK_ROOT="$XDG_DATA_HOME/stack"

# Python tools
export IPYTHONDIR="$XDG_CONFIG_HOME/ipython"
export JUPYTER_CONFIG_DIR="$XDG_CONFIG_HOME/jupyter"
export MPLCONFIGDIR="$XDG_CONFIG_HOME/matplotlib"

# Conda
export CONDARC="$XDG_CONFIG_HOME/conda/condarc"
export CONDA_PKGS_DIRS="$XDG_CACHE_HOME/conda/pkgs"

# Git
export GIT_CONFIG_GLOBAL="$XDG_CONFIG_HOME/git/config"

# Redis CLI
export REDISCLI_HISTFILE="$XDG_STATE_HOME/redis/history"

# wget
export WGETRC="$XDG_CONFIG_HOME/wget/wgetrc"

# Terraform
export TF_CLI_CONFIG_FILE="$XDG_CONFIG_HOME/terraform/credentials.tfrc.json"

# Cargo env
[[ -f "$CARGO_HOME/env" ]] && . "$CARGO_HOME/env"
. "/Users/tate/.local/share/cargo/env"
