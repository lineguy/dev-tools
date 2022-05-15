FROM alpine:3.15

# Install base
RUN apk update \
  && apk add wget git zsh vim tzdata openssh-client \
  && cp -r /usr/share/zoneinfo/Europe/Berlin /etc/localtime

# Switch user to non-root user
RUN adduser -D developer
USER developer
WORKDIR /home/developer

ENV PLATFORM="x86_64"

# Oh My Zsh
RUN git clone -q https://github.com/robbyrussell/oh-my-zsh ~/.oh-my-zsh \
  && cp ~/.oh-my-zsh/templates/zshrc.zsh-template ~/.zshrc \
  && mkdir -p ~/.local/bin \
  && echo 'export PATH="${PATH}:${HOME}/.local/bin"' >> ~/.zshrc \
  && git clone -q https://github.com/zsh-users/zsh-syntax-highlighting ~/.oh-my-zsh/plugins/zsh-syntax-highlighting \
  && sed -i "s/plugins=(git)/plugins=(git zsh-syntax-highlighting)/g" ~/.zshrc

# Starship Prompt
RUN wget -q "https://github.com/starship/starship/releases/latest/download/starship-${PLATFORM}-unknown-linux-musl.tar.gz" \
  && tar -xf "starship-${PLATFORM}-unknown-linux-musl.tar.gz" \
  && rm -f "starship-${PLATFORM}-unknown-linux-musl.tar.gz" \
  && chmod +x starship \
  && mv starship ~/.local/bin/starship \
  && mkdir -p ~/.config \
  && printf "[container]\ndisabled = true" > ~/.config/starship.toml \
  && echo 'eval "$(starship init zsh)"' >> ~/.zshrc

# Exa
RUN wget -q "https://github.com/ogham/exa/releases/download/v0.10.1/exa-linux-${PLATFORM}-musl-v0.10.1.zip" \
  && unzip "exa-linux-${PLATFORM}-musl-v0.10.1.zip" \
  && rm -rf "exa-linux-${PLATFORM}-musl-v0.10.1.zip" "completions/" "man/" \
  && chmod +x bin/exa \
  && mv bin/exa ~/.local/bin/exa \
  && rm -rf "bin/" \
  && printf "alias ls='exa'\nalias ll='exa -la'" >> ~/.zshrc

ENTRYPOINT [ "/bin/zsh" ]
