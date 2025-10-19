#!/bin/bash
# generate_install_commands.sh
# Generates a numbered list of Arch install commands with notes for manual steps

set -euo pipefail

BACKUP_DIR="$HOME/backupdrive"
COMMANDS_FILE="$BACKUP_DIR/arch_install_commands.txt"

mkdir -p "$BACKUP_DIR"

{
    echo "============================="
    echo "ARCH INSTALL COMMANDS CHECKLIST"
    echo "============================="
    echo
    echo "Generated on: $(date)"
    echo
    echo "1) Boot from Arch ISO and set keyboard layout if needed:"
    echo "   # loadkeys us (or your preferred layout)"
    echo
    echo "2) Verify internet connectivity:"
    echo "   # ping -c 3 archlinux.org"
    echo
    echo "3) Update system clock:"
    echo "   # timedatectl set-ntp true"
    echo
    echo "4) Partition disks (example using nvme0n1 as root, adjust for your setup and include home):"
    echo "   and other drives as needed"
    echo "   # cfdisk /dev/nvme0n1"
    echo "   # cfdisk other drives"
    echo "   STOP: Refer to cheatsheet for partition sizes, EFI, swap, and Windows partitions."
    echo
    echo "5) Format partitions:"
    echo "   # mkfs.fat -F32 /dev/nvme0n1p1   # EFI"
    echo "   # mkfs.ext4 /dev/nvme0n1p3       # root"
    echo "   # mkswap /dev/nvme0n1p2          # swap"
    echo "   format other drives including home e.g. sudo mkfs.ext4 /dev/sdxX"
    echo "   STOP: Adjust commands for your partitions using lsblk output."
    echo
    echo "6) Mount partitions:"
    echo "   # mount /dev/nvme0n1p3 /mnt"
    echo "   # mkdir -p /mnt/boot/efi"
    echo "   # mount /dev/nvme0n1p1 /mnt/boot/efi"
    echo "   # swapon /dev/nvme0n1p2"
    echo "   # mkdir -p /mnt/home"
    echo "   mount other drives as necessary including home e.g. sudo mount /dev/sdxX /mnt/home"
    echo
    echo "7) Install base system:"
    echo "   # pacstrap /mnt base base-devel linux linux-firmware vim sof-firmware networkmanager nano"
    echo
    echo "8) Generate fstab:"
    echo "   # genfstab -U /mnt >> /mnt/etc/fstab"
    echo "   STOP: Compare with your backup cheatsheet fstab if needed."
    echo
    echo "9) Chroot into new system:"
    echo "   # arch-chroot /mnt"
    echo
    echo "10) Set timezone and locale:"
    echo "   # ln -sf /usr/share/zoneinfo/America/New_York /etc/localtime"
    echo "   # hwclock --systohc"
    echo "   # vim /etc/locale.gen (uncomment en_US.UTF-8 UTF-8)"
    echo "   # locale-gen"
    echo "   # echo LANG=en_US.UTF-8 > /etc/locale.conf"
    echo
    echo "11) Set hostname and hosts file:"
    echo "   # echo myhostname > /etc/hostname"
    echo "   # add file /etc/hosts and enter the content replacing hostname with megajeff or other name:"
    echo "   # Loopback addresses"
    echo "   127.0.0.1	localhost"
    echo "   ::1		localhost"
    echo
    echo "   # Local machine" 
    echo "   127.0.1.1	hostname.localdomain	hostname"
    echo
    echo "12) Set root password:"
    echo "   # passwd"
    echo
    echo "12.1) Add user (replace name with jeff or other name"
    echo "   # useradd -m -G wheel -s /bin/bash name"
    echo "   # passwd name"
    echo "   # exit"
    echo "   # EDITOR=vim visudo"
    echo "   uncomment the %wheel ALL=(ALL) ALL"
    echo
    echo "13) Install bootloader:"
    echo "   # pacman -S grub efibootmgr os-prober"
    echo "   # grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB"
    echo "   # grub-mkconfig -o /boot/grub/grub.cfg"
    echo "   STOP: Verify that os-prober detects Windows partitions correctly."
    echo
    echo "13.1) Enabling core systems"
    echo "   # systemctl enable NetworkManager"
    echo
    echo "14) Exit chroot and reboot:"
    echo "   # exit"
    echo "   # umount -R /mnt"
    echo "   # reboot"
    echo
    echo "15) After reboot: verify system, configure users, install packages selectively."
    echo "   STOP: Refer to package list backup and cheatsheet for selective installation."
} > "$COMMANDS_FILE"

echo "Install commands checklist created: $COMMANDS_FILE"

