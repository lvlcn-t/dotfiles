IMAGE_NAME=dotfiles-debug
DOCKERFILE_DEBUG=Dockerfile

debug:
	docker build -f $(DOCKERFILE_DEBUG) -t $(IMAGE_NAME) .
	docker run -it --rm $(IMAGE_NAME) /bin/bash -c "chmod +x .local/share/chezmoi/scripts/run_once_before_install-deps.zsh.tmpl && .local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl && bash"

lint:
	pre-commit run -a
