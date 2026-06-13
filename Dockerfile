FROM ubuntu:26.04

ARG DEBIAN_FRONTEND=noninteractive
ARG TARGETPLATFORM

RUN apt-get update && \
    apt-get install -y sudo curl passwd adduser

RUN useradd -m testuser && echo "testuser:testuser" | chpasswd && adduser testuser sudo
RUN echo 'testuser ALL=(ALL) NOPASSWD: ALL' >> /etc/sudoers

COPY ${TARGETPLATFORM}/dotfiles /usr/local/bin/dotfiles

USER testuser
WORKDIR /home/testuser

RUN sh -c "$(curl -fsLS get.chezmoi.io)" && echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc

CMD ["dotfiles", "apply", "--non-interactive"]
