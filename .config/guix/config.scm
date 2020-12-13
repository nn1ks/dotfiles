(use-modules
  (guix channels)
  (guix inferior)
  (srfi srfi-1)
  (gnu)
  (nongnu packages linux)
  (nongnu system linux-initrd))
(use-service-modules desktop networking pm ssh virtualization xorg)

(operating-system
  (kernel
    (let*
      ((channels
        (list (channel
                (name 'nonguix)
                (url "https://gitlab.com/nonguix/nonguix")
                (commit "c79056e9bf2c7c57fcdc8e0cca488b87960c87a5"))
              (channel
                (name 'guix)
                (url "https://git.savannah.gnu.org/git/guix.git")
                (commit "f350df405fbcd5b9e27e6b6aa500da7f101f41e7"))))
        (inferior
          (inferior-for-channels channels)))
       (first (lookup-inferior-packages inferior "linux" "5.9.14"))))
  (initrd microcode-initrd)
  (firmware (list linux-firmware))
  (locale "en_US.utf8")
  (timezone "Europe/Berlin")
  (keyboard-layout (keyboard-layout "de"))
  (host-name "t14-guix")
  (users (cons* (user-account
                  (name "niklas")
                  (comment "Niklas Sauter")
                  (group "users")
                  (home-directory "/home/niklas")
                  (supplementary-groups
                    '("wheel" "netdev" "audio" "video" "kvm" "libvirt")))
                %base-user-accounts))
  (packages
    (append
      (list (specification->package "nss-certs"))
      (list (specification->package "btrfs-progs"))
      %base-packages))
  (services
    (append
      (list (service gnome-desktop-service-type)
            (set-xorg-configuration
              (xorg-configuration
                (keyboard-layout keyboard-layout)))
            (service tlp-service-type)
            (service virtlog-service-type)
            (service libvirt-service-type
              (libvirt-configuration (unix-sock-group "libvirt"))))
      %desktop-services))
  (bootloader
    (bootloader-configuration
      (bootloader grub-bootloader)
      (target "/dev/sda")
      (keyboard-layout keyboard-layout)))
  (file-systems
    (cons* (file-system
             (mount-point "/")
             (device
               (uuid "8cea89ec-0940-494b-adbb-730eaf82ca13"
                     'btrfs))
             (type "btrfs"))
           %base-file-systems)))
