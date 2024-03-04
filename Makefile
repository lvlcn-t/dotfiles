IMAGE_NAME=dotfiles-debug
DOCKERFILE_DEBUG=Dockerfile

debug:
	docker build -f $(DOCKERFILE_DEBUG) -t $(IMAGE_NAME) .
	docker run -it --rm $(IMAGE_NAME) /bin/bash -c "\
		chezmoi execute-template < ~/.local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl > ~/.local/share/chezmoi/scripts/script.sh && \
		chmod +x ~/.local/share/chezmoi/scripts/script.sh && \
		~/.local/share/chezmoi/scripts/script.sh && \
		chezmoi apply --verbose --force && \
		zsh"

lint:
	pre-commit run -a
