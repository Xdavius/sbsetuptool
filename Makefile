# Configuration
PREFIX  ?= /usr/local
DESTDIR ?=

# Couleurs
RED    = \033[0;31m
GREEN  = \033[0;32m
YELLOW = \033[1;33m
CYAN   = \033[0;36m
RESET  = \033[0m

.PHONY: default all install uninstall check logo

# Dépendances requises
REQUIRED_CMDS := git mokutil sbsign dkms

# Fichiers requis
REQUIRED_FILES := zz-sign-kernel zz-sign-modules 00-ensure_sign_file sbsetuptool

default:
	@printf "$(RED)[ERROR] No target specified. Use one of: install, uninstall, check$(RESET)\n"; exit 1

check:
	@missing=0; \
	for cmd in $(REQUIRED_CMDS); do \
		if ! command -v "$$cmd" >/dev/null 2>&1; then \
			printf "$(RED)[ERROR] Missing dependency: %s$(RESET)\n" "$$cmd"; \
			missing=1; \
		fi; \
	done; \
	if [ ! -d "/usr/src/linux-headers-$(shell uname -r)" ]; then \
		printf "$(RED)[ERROR] Kernel headers not found: /usr/src/linux-headers-$(shell uname -r)$(RESET)\n"; \
		missing=1; \
	fi; \
	if [ "$$missing" -eq 1 ]; then exit 1; fi; \
	for file in $(REQUIRED_FILES); do \
		if [ ! -f "$$file" ]; then \
			printf "$(RED)[ERROR] Missing file: %s$(RESET)\n" "$$file"; \
			exit 1; \
		fi; \
	done; \
	printf "$(GREEN)[OK]    All requirements are met.$(RESET)\n"
	@printf "$(RESET)\n"


install: logo check
	@printf "$(BLUE)[INFO]  Installing...$(RESET)\n"

	install -dm 755 $(DESTDIR)/etc/kernel/postinst.d
	install -Dm 755 zz-sign-kernel   $(DESTDIR)/etc/kernel/postinst.d/zz-sign-kernel
	install -Dm 755 zz-sign-modules  $(DESTDIR)/etc/kernel/postinst.d/zz-sign-modules
	install -Dm 755 00-ensure_sign_file $(DESTDIR)/etc/kernel/header_postinst.d/00-ensure_sign_file
	install -Dm 755 sbsetuptool $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	@printf "$(GREEN)[OK]    Installation complete.$(RESET)\n"
	@printf "$(RESET)\n"

uninstall: logo
	@printf "$(BLUE)[INFO]  Uninstalling...$(RESET)\n"

	rm -f $(DESTDIR)/etc/kernel/postinst.d/zz-sign-kernel
	rm -f $(DESTDIR)/etc/kernel/postinst.d/zz-sign-modules
	rm -f $(DESTDIR)/etc/kernel/header_postinst.d/00-ensure_sign_file
	rm -f $(DESTDIR)$(PREFIX)/bin/sbsetuptool

	@printf "$(GREEN)[OK]    Uninstallation complete.$(RESET)\n"
	@printf "$(RESET)\n"

all: logo
	@printf "$(YELLOW)[WARN]  Nothing to build. Use 'make install' to install the files.$(RESET)\n"

logo:
	@printf "$(CYAN)"
	@printf "███████╗██████╗ ███████╗███████╗████████╗██╗   ██╗██████╗ ████████╗ ██████╗  ██████╗ ██╗       \n"
	@printf "██╔════╝██╔══██╗██╔════╝██╔════╝╚══██╔══╝██║   ██║██╔══██╗╚══██╔══╝██╔═══██╗██╔═══██╗██║       \n"
	@printf "███████╗██████╔╝███████╗█████╗     ██║   ██║   ██║██████╔╝   ██║   ██║   ██║██║   ██║██║       \n"
	@printf "╚════██║██╔══██╗╚════██║██╔══╝     ██║   ██║   ██║██╔═══╝    ██║   ██║   ██║██║   ██║██║       \n"
	@printf "███████║██████╔╝███████║███████╗   ██║   ╚██████╔╝██║        ██║   ╚██████╔╝╚██████╔╝███████╗  \n"
	@printf "╚══════╝╚═════╝ ╚══════╝╚══════╝   ╚═╝    ╚═════╝ ╚═╝        ╚═╝    ╚═════╝  ╚═════╝ ╚══════╝  \n"
	@printf "$(RESET)\n"
