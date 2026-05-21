#!/usr/bin/env bash

set -euo pipefail

if [[ ${EUID:-$(id -u)} -ne 0 ]]; then
	printf '\033[1;31m%s\033[0m\n' "Script này cần chạy với quyền sudo hoặc root. Hãy chạy lại bằng lệnh như: sudo -E bash install.sh" >&2
	exit 1
fi

if [[ -t 1 ]]; then
	BOLD="\033[1m"
	CYAN="\033[36m"
	GREEN="\033[32m"
	YELLOW="\033[33m"
	MAGENTA="\033[35m"
	RESET="\033[0m"
else
	BOLD=""
	CYAN=""
	GREEN=""
	YELLOW=""
	MAGENTA=""
	RESET=""
fi

info() {
	printf '%b%s%b\n' "${BOLD}${CYAN}" "$1" "$RESET"
}

success() {
	printf '%b%s%b\n' "${BOLD}${GREEN}" "$1" "$RESET"
}

warn() {
	printf '%b%s%b\n' "${BOLD}${YELLOW}" "$1" "$RESET"
}

WARP_URL="https://downloads.cloudflareclient.com/v1/download/fedora35-intel/version/2026.1.150.0"
RPM_FILE="warp.rpm"

info "Đang tải gói cài đặt Cloudflare WARP..."
wget -O "$RPM_FILE" "$WARP_URL"

info "Đang cài đặt Cloudflare WARP..."
sudo dnf install -y "./$RPM_FILE"

warn "Đang đăng ký WARP, nhập y để tiếp tục..."
warp-cli registration new

info "Đang đặt chế độ WARP..."
warp-cli mode warp+doh

info "Đang đặt tunnel protocol..."
warp-cli tunnel protocol set MASQUE

if pgrep -x gnome-shell >/dev/null 2>&1; then
	warn "Bạn đang dùng GNOME, hãy cài (nếu chưa cài) extension AppIndicator and KStatusNotifierItem Support để hiện WARP trên system tray: https://extensions.gnome.org/extension/615/appindicator-support/"
fi

success "Đã hoàn tất cài đặt và cấu hình Cloudflare WARP."
