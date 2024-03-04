FROM ubuntu:22.04

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update && apt install -y sudo curl

RUN useradd -m testuser && echo "testuser:testuser" | chpasswd && adduser testuser sudo
RUN echo 'testuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

USER testuser
WORKDIR /home/testuser

RUN sh -c "$(curl -fsLS get.chezmoi.io) && echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc"

COPY --chown=testuser:testuser . /home/testuser/.local/share/chezmoi

CMD [ "/bin/bash", "-c", "/home/testuser/bin/chezmoi apply --verbose --force && /bin/zsh" ]
