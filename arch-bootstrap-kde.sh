#!/usr/bin/env bash
set -euo pipefail
# LHM Arch Bootstrap (TTY friendly)
# Goal: Start from Arch minimal (TTY), run once, reboot into KDE Plasma.
# -----------------------------
# Colours (LHM style)
# -----------------------------
GREEN='\033[38;2;0;255;0m'
ORANGE='\033[38;2;255;153;0m'
RED='\033[38;2;255;68;68m'
WHITE='\033[38;2;249;249;249m'
RESET='\033[0m'
BOLD='\033[1m'
section() { printf "\n${BOLD}${GREEN}==> %s${RESET}\n" "$1"; }
info() { printf "${WHITE}%s${RESET}\n" "$1"; }
warn() { printf "${BOLD}${RED}Warning:${RESET} ${WHITE}%s${RESET}\n" "$1"; }
cmdhint() { printf "${ORANGE}%s${RESET}\n" "$1"; }
require_root() {
  if [[ ${EUID} -ne 0 ]]; then
    warn "Run with sudo:"
    cmdhint "sudo bash $0"
    exit 1
  fi
}
get_target_user() {
  if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
    printf "%s" "${SUDO_USER}"
  else
    printf "%s" "$(logname 2>/dev/null || echo root)"
  fi
}
printf "${BOLD}${GREEN}Linux Gamer Life Arch KDE Bootstrap${RESET}\n"
require_root
TARGET_USER="$(get_target_user)"
info "Target user: ${TARGET_USER}"
# -----------------------------
# 1) Update system and core tools
# -----------------------------
section "Base update and core tools"
pacman -Syu --noconfirm
pacman -S --noconfirm \
  curl wget git base-devel fastfetch btop htop \
  python python-pip \
  flatpak \
  distrobox \
  lm_sensors \
  vlc
# Full FFmpeg codec support
pacman -S --noconfirm ffmpeg \
  x264 x265 libvpx dav1d svt-av1 libaom \
  opus lame libvorbis libwebp libass || true
# -----------------------------
# Enable multilib
# -----------------------------
echo "Enabling multilib..."
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    echo "multilib repo section missing from pacman.conf"
fi
sed -i '/^\#\[multilib\]/,/^\#Include/s/^#//' /etc/pacman.conf
pacman -Syy
# -----------------------------
# 2) CachyOS kernel
# -----------------------------
section "CachyOS kernel"
# Add CachyOS repo signing keys
pacman-key --recv-keys F3B607488DB35A47 --keyserver keyserver.ubuntu.com
pacman-key --lsign-key F3B607488DB35A47
# Install CachyOS repo package
pacman -U --noconfirm \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-keyring-20240331-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-mirrorlist-18-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-v3-mirrorlist-18-1-any.pkg.tar.zst' \
  'https://mirror.cachyos.org/repo/x86_64/cachyos/cachyos-repo-1-1-any.pkg.tar.zst'
# Add CachyOS repos to pacman.conf if not already present
if ! grep -q "^\[cachyos\]" /etc/pacman.conf; then
  cat >> /etc/pacman.conf << 'EOF'

[cachyos-v3]
Include = /etc/pacman.d/cachyos-v3-mirrorlist

[cachyos]
Include = /etc/pacman.d/cachyos-mirrorlist
EOF
fi
pacman -Syy
# Install CachyOS kernel and headers
pacman -S --noconfirm \
  linux-cachyos \
  linux-cachyos-headers
# Update bootloader to include new kernel entry
if command -v grub-mkconfig &>/dev/null; then
  grub-mkconfig -o /boot/grub/grub.cfg
  info "GRUB config updated for CachyOS kernel."
elif command -v bootctl &>/dev/null; then
  bootctl update
  info "systemd-boot updated for CachyOS kernel."
else
  warn "Could not detect bootloader. Update your bootloader manually to include linux-cachyos."
fi
info "CachyOS kernel installed."
# -----------------------------
# 3) Paru AUR helper
# -----------------------------
section "Installing Paru AUR helper"
if command -v paru &>/dev/null; then
  info "Paru is already installed, skipping."
else
  PARU_BUILD_DIR="$(mktemp -d)"
  git clone https://aur.archlinux.org/paru.git "${PARU_BUILD_DIR}/paru"
  chmod -R 777 "${PARU_BUILD_DIR}"
  sudo -u "${TARGET_USER}" bash -c "cd ${PARU_BUILD_DIR}/paru && makepkg -si --noconfirm"
  rm -rf "${PARU_BUILD_DIR}"
  info "Paru installed successfully."
fi
# -----------------------------
# 4) KDE Plasma (minimal)
# -----------------------------
section "KDE Plasma"
pacman -S --noconfirm \
  plasma-desktop \
  plasma-workspace \
  kde-system-meta \
  sddm \
  konsole \
  spectacle \
  ark \
  okular \
  gwenview \
  discover
# -----------------------------
# 5) Multimedia and Nvidia Beta stack
# -----------------------------
section "Multimedia and Nvidia Beta drivers"
pacman -S --noconfirm \
  nvidia-open-dkms \
  nvidia-utils \
  lib32-nvidia-utils \
  nvidia-settings \
  egl-wayland \
  vulkan-icd-loader \
  gst-plugins-base \
  gst-plugins-good \
  gst-plugins-bad \
  gst-plugins-ugly \
  gst-libav
# -----------------------------
# 6) Gaming tools
# -----------------------------
section "Gaming tools"
pacman -S --noconfirm \
  steam \
  lutris \
  mangohud
# -----------------------------
# 7) Flatpak apps
# -----------------------------
section "Flatpak apps"
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
flatpak install -y flathub com.github.tchx84.Flatseal
flatpak install -y flathub net.davidotek.pupgui2
flatpak install -y flathub com.heroicgameslauncher.hgl
flatpak install -y flathub org.onlyoffice.desktopeditors
flatpak install -y flathub io.github.lact_ui
flatpak install -y flathub io.github.lawstorant.boxflat
# -----------------------------
# 8) AUR apps
# -----------------------------
section "AUR apps"
sudo -u "${TARGET_USER}" paru -S --noconfirm coolercontrol
systemctl enable --now coolercontrold
info "CoolerControl installed."
# -----------------------------
# 9) Virtualization
# -----------------------------
section "Virtualization"
pacman -S --noconfirm \
  virt-manager \
  qemu-full \
  libvirt \
  virt-install \
  virt-viewer \
  edk2-ovmf \
  swtpm
systemctl enable --now libvirtd
usermod -aG libvirt "${TARGET_USER}"
# -----------------------------
# 10) Boot target
# -----------------------------
section "Boot configuration"
systemctl set-default graphical.target
systemctl enable sddm
# -----------------------------
# Finish
# -----------------------------
section "Complete"
info "Bootstrap finished"
info "Reboot to start KDE Plasma:"
cmdhint "reboot"
