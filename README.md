## Linux Gamer Life Arch KDE Bootstrap

This script installs the Linux Gamer Life KDE Plasma environment on a fresh Arch Linux system. It is designed to be run once from TTY after completing a minimal Arch install using archinstall.

The script installs KDE Plasma, Nvidia graphics support, gaming tools, Flatpak apps, virtualization support, multimedia codecs, and configures the system to boot into a graphical desktop.

The end result is a complete KDE desktop ready for gaming, content creation, and daily use.

---

# Step 1: Install Arch Linux using archinstall

Boot the Arch ISO and start the installer:

```bash
archinstall
```

Configure your system normally:

- Select your disk
- Select filesystem (btrfs or ext4 recommended)
- Select bootloader (GRUB recommended)
- Create your username and password
- Select PipeWire for audio
- Select your GPU if prompted

Critical requirement:

When choosing Profile, select:

Minimal

Do NOT select any desktop environment.

Do NOT select:

- KDE Plasma  
- GNOME  
- XFCE  
- Cinnamon  
- Any window manager  

This script installs KDE and everything else.

Complete the install and reboot when finished.

---

# Step 2: Boot into your new Arch system

After archinstall completes, reboot into your new system.

You will land at a TTY login prompt.

Log in using your username and password.

Example:

```bash
archlogin: lgl
password: ********
```

---

# Step 3: Install wget (if not already installed)

wget is required to download the bootstrap script.

If you added wget during archinstall under Additional packages, you can skip this step.

Otherwise install it now:

```bash
sudo pacman -S wget
```

---

# Step 4: Download the Linux Gamer Life bootstrap script

Run:

```bash
wget https://tinyurl.com/lgl-arch-kde
```

This downloads the script to your current directory.

---

# Step 5: Make the script executable

Run:

```bash
chmod +x lgl-arch-kde
```

This allows the script to run.

---

# Step 6: Run the script

Run:

```bash
sudo ./lgl-arch-kde
```

Enter your password when prompted.

The script will install and configure:

- KDE Plasma desktop  
- SDDM display manager
- CachyOS Kernel  
- Nvidia Drivers
- Steam  
- Lutris  
- OBS Studio  
- MangoHud  
- Flatpak and Flathub  
- Heroic Games Launcher  
- ProtonUp-Qt  
- ProtonPlus  
- LibreOffice  
- Virt-Manager  
- QEMU and libvirt virtualization stack  
- Full multimedia codec support  
- System utilities  

It will also configure the system to boot into the graphical desktop automatically.

This process can take several minutes depending on your internet speed.

---

# Step 7: Reboot into KDE Plasma

Once the script finishes, reboot:

```bash
reboot
```

Your system will boot into the KDE Plasma graphical login screen.

Log in and your Linux Gamer Life Arch setup is ready.

---

# Notes

This script is designed to be run once on a fresh Arch install.

This script assumes:

- Arch was installed using archinstall  
- Minimal profile was used  
- No desktop environment was installed  
- You are running the script from TTY  
- You are connected to the internet  

---

# Linux Gamer Life

Arch Linux. KDE Plasma. Gaming ready.
