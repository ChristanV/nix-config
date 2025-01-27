switch:
	@echo 'Copying configuration.nix to /etc/nixos/'
	@cp -f configuration.nix /etc/nixos/configuration.nix
	@echo 'Switching to new NixOs configuration'
	@nixos-rebuild switch

build:
	@echo 'Copying configuration.nix to /etc/nixos/'
	@cp -f configuration.nix /etc/nixos/configuration.nix
	@echo 'Building new NixOs configuration'
	@nixos-rebuild build

boot:
	@echo 'Copying configuration.nix to /etc/nixos/'
	@cp -f configuration.nix /etc/nixos/configuration.nix
	@echo 'Boot to new NixOs configuration'
	@nixos-rebuild boot

test:
	@echo 'Copying configuration.nix to /etc/nixos/'
	@cp -f configuration.nix /etc/nixos/configuration.nix
	@echo 'Test new NixOs configuration'
	@nixos-rebuild test

channel-update:
	@nix-channel --update

cleanup:
	@nix-collect-garbage -d --delete-older-than 10d

upgrade:
	@echo 'Copying configuration.nix to /etc/nixos/'
	@cp -f configuration.nix /etc/nixos/configuration.nix
	@echo 'Upgrade to new NixOs configuration'
	@nixos-rebuild switch --upgrade
