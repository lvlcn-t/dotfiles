IMAGE_NAME=dotfiles-debug
DOCKERFILE_DEBUG=Dockerfile

debug:
	docker build -f $(DOCKERFILE_DEBUG) -t $(IMAGE_NAME) .
	docker run -it --rm $(IMAGE_NAME) /bin/bash -c "\
		~/bin/chezmoi execute-template < ~/.local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl > ~/.local/share/chezmoi/scripts/script.sh && \
		chmod +x ~/.local/share/chezmoi/scripts/script.sh && \
		~/.local/share/chezmoi/scripts/script.sh && \
		~/bin/chezmoi apply --verbose --force && \
		zsh"

create-install-deps-script:
	chezmoi execute-template < ~/.local/share/chezmoi/scripts/run_once_before_install-deps.sh.tmpl > ./scripts/install-deps.sh
	chmod +x ./scripts/install-deps.sh

lint:
	pre-commit run -a

chezmoidata-exclude:
	git update-index --skip-worktree .chezmoidata.yaml

chezmoidata-include:
	git update-index --no-skip-worktree .chezmoidata.yaml
