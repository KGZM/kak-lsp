PKGNAME ?= kak-lsp
PREFIX ?= /usr

BIN_DIR = $(DESTDIR)$(PREFIX)/bin
SHARE_DIR = $(DESTDIR)$(PREFIX)/share

.PHONY: build install package

build:
	cargo build --release --locked

install:
	install -Dm755 -t "$(BIN_DIR)" target/release/$(PKGNAME)
	install -Dm644 -t "$(SHARE_DIR)/$(PKGNAME)/rc/" rc/lsp.kak rc/servers.kak
	install -Dm644 UNLICENSE "$(SHARE_DIR)/licenses/$(PKGNAME)/LICENSE"

# Package a stripped binary + rc scripts into dist/$(DIST_TARGET)/.
# strip = true in Cargo.toml handles stripping at build time (cross-safe).
#
# Usage:
#   make package DIST_TARGET=x86_64-linux
#   make package DIST_TARGET=aarch64-linux
DIST_TARGET = unknown-linux
CARGO_TARGET_x86_64-linux = x86_64-unknown-linux-musl
CARGO_TARGET_aarch64-linux = aarch64-unknown-linux-musl
package:
	@test "$(DIST_TARGET)" != "unknown-linux" || \
		{ echo "usage: make package DIST_TARGET=x86_64-linux"; exit 1; }
	cargo zigbuild --release --locked --target $(CARGO_TARGET_$(DIST_TARGET))
	rm -rf dist/$(DIST_TARGET)
	mkdir -p dist/$(DIST_TARGET)/bin dist/$(DIST_TARGET)/share/kak-lsp/rc
	cp target/$(CARGO_TARGET_$(DIST_TARGET))/release/$(PKGNAME) dist/$(DIST_TARGET)/bin/
	cp rc/lsp.kak rc/servers.kak dist/$(DIST_TARGET)/share/kak-lsp/rc/
	@printf 'packaged: dist/%s/  (%s)\n' "$(DIST_TARGET)" "$$(ls -lh dist/$(DIST_TARGET)/bin/$(PKGNAME) | awk '{print $$5}')"

