FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        curl \
        git \
    && rm -rf /var/lib/apt/lists/*

# Install as vscode user
USER vscode

# Install AI CLI tools
RUN curl -fsSL https://claude.ai/install.sh | bash \
    && curl -fsSL https://gh.io/copilot-install | bash

# Install mise
RUN curl --proto '=https' --tlsv1.2 -fsSL https://mise.run | sh

# Install oh-my-zsh plugins (pinned to known commits)
RUN git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
    && git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
        fetch --depth=1 origin 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5 \
    && git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions \
        checkout 85919cd1ffa7d2d5412f6d3fe437ebdbeeec4fc5 \
    && git clone --depth=1 https://github.com/zsh-users/zsh-syntax-highlighting \
        ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
    && git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
        fetch --depth=1 origin 1d85c692615a25fe2293bdd44b34c217d5d2bf04 \
    && git -C ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting \
        checkout 1d85c692615a25fe2293bdd44b34c217d5d2bf04 \
    && sed -i 's/^plugins=(git)$/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/' ~/.zshrc

# Install tools defined in .mise.toml (cached in image layer)
# GITHUB_TOKEN avoids GitHub API rate limits for aqua backend downloads
ARG GITHUB_TOKEN
COPY --chown=vscode:vscode .mise.toml /home/vscode/.mise.toml
# NOTE: `mise install` may report "all tools are installed" in Docker even
# when they are not. We install node/pnpm explicitly, then reference
# npm via its mise install path to install Codex CLI and Gemini CLI.
RUN ~/.local/bin/mise trust /home/vscode/.mise.toml \
    && ~/.local/bin/mise install node@24 pnpm@10 \
    && export PATH="$HOME/.local/bin:$HOME/.local/share/mise/installs/node/24/bin:$PATH" \
    && npm install -g @openai/codex @google/gemini-cli \
    && ~/.local/bin/mise install \
    && rm /home/vscode/.mise.toml

# Switch back to root for remaining setup
USER root
RUN chsh -s /bin/zsh vscode \
    && echo 'eval "$(/home/vscode/.local/bin/mise activate bash)"' >> /etc/bash.bashrc \
    && echo 'eval "$(/home/vscode/.local/bin/mise activate zsh)"' >> /etc/zsh/zshrc \
    && echo 'export HISTFILE="$HOME/.zsh_history"' >> /etc/zsh/zshrc \
    && echo 'export HISTSIZE=10000' >> /etc/zsh/zshrc \
    && echo 'export SAVEHIST=10000' >> /etc/zsh/zshrc \
    && echo '# Write history in-place; the default copy-and-rename fails on bind-mounted files' >> /etc/zsh/zshrc \
    && echo 'unsetopt HIST_SAVE_BY_COPY' >> /etc/zsh/zshrc
