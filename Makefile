SHELL := /usr/bin/env bash

install:
	@echo starting Nil installer
	bash ./utils/installer/install.sh

install-bin:
	@echo starting Nil bin-installer
	bash ./utils/installer/install_bin.sh

install-neovim-binary:
	@echo installing Neovim from github releases
	bash ./utils/installer/install-neovim-from-release

uninstall:
	@echo starting Nil uninstaller
	bash ./utils/installer/uninstall.sh

lint: lint-lua lint-sh

lint-lua:
	luacheck *.lua lua/* tests/*

lint-sh:
	shfmt -f . | grep -v jdtls | xargs shellcheck

style: style-lua style-sh

style-lua:
	stylua --config-path .stylua.toml --check .

style-sh:
	shfmt -f . | grep -v jdtls | xargs shfmt -i 2 -ci -bn -l -d

.PHONY: install install-neovim-binary uninstall lint style test
