;; This is an operating system configuration generated
;; by the graphical installer.
;;
;; Once installation is complete, you can learn and modify
;; this file to tweak the system configuration, and pass it
;; to the 'guix system reconfigure' command to effect your
;; changes.


;; Indicate which modules to import to access the variables
;; used in this configuration.
(use-modules (gnu))
(use-service-modules cups desktop networking ssh xorg) ; xorg
(use-package-modules admin shells window-management)

;; Log-in: greetd runs tuigreet on VT 7, which starts sway.  It replaces GDM,
;; whose 49.x greeter needs GNOME's schemas and a working GL stack.
(define sway-session
  (greetd-user-session
   (command (file-append sway "/bin/sway"))
   (command-args '())
   (xdg-session-type "wayland")))

(define tuigreet-greeter
  (program-file
   "tuigreet-greeter"
   #~(execl #$(file-append tuigreet "/bin/tuigreet") "tuigreet"
            "--time" "--remember" "--asterisks" "--cmd" #$sway-session)))

(operating-system
  (locale "en_AU.utf8")
  (timezone "Australia/Melbourne")
  (keyboard-layout (keyboard-layout "au"))
  (host-name "guix")

  ;; The list of user accounts ('root' is implicit).
  (users (cons* (user-account
                  (name "david")
                  (comment "David")
                  (group "users")
                  (home-directory "/home/david")
                  ;; Its rc files come from Guix Home (~/guix/home.scm).
                  (shell (file-append zsh "/bin/zsh"))
                  (supplementary-groups '("wheel" "netdev" "audio" "video")))
                %base-user-accounts))

  ;; Packages installed system-wide.  Users can also install packages
  ;; under their own account: use 'guix search KEYWORD' to search
  ;; for packages and 'guix install PACKAGE' to install a package.
  (packages (append (list (specification->package "emacs")
			  ;(specification->package "neovim")
                          ;(specification->package "emacs-exwm")
                          ;(specification->package
                          ;"emacs-desktop-environment")
                          (specification->package "sway")
                          (specification->package "wmenu")
                          (specification->package "foot")) %base-packages))

  ;; Below is the list of system services.  To search for available
  ;; services, run 'guix system search KEYWORD' in a terminal.
  (services
   (append (list

                 ;; To configure OpenSSH, pass an 'openssh-configuration'
                 ;; record as a second argument to 'service' below.
                 (service openssh-service-type)
                 (service greetd-service-type
                  (greetd-configuration
                   (terminals
                    (list (greetd-terminal-configuration
                           (terminal-vt "7")
                           (terminal-switch #t)
                           (default-session-command tuigreet-greeter)))))))

           ;; This is the default list of services we
           ;; are appending to.
           (modify-services %desktop-services
             (delete gdm-service-type)
             ;; Binaries for nonguix packages (firefox, signal-desktop...);
             ;; without them, firefox builds from source.
             (guix-service-type
              config => (guix-configuration
                         (inherit config)
                         (substitute-urls
                          (append (list "https://substitutes.nonguix.org")
                                  %default-substitute-urls))
                         (authorized-keys
                          (append (list (plain-file "nonguix.pub" "\
(public-key (ecc (curve Ed25519)
  (q #C1FD53E5D4CE971933EC50C9F307AE2171A2D3B52C804642A7A35F84F3A4EA98#)))"))
                                  %default-authorized-guix-keys)))))))
  (bootloader (bootloader-configuration
                (bootloader grub-efi-bootloader)
                (targets (list "/boot/efi"))
                (keyboard-layout keyboard-layout)))
  (swap-devices (list (swap-space
                        (target (uuid
                                 "db8be27f-287b-42bc-9ab7-6d5601b099cc")))))

  ;; The list of file systems that get "mounted".  The unique
  ;; file system identifiers there ("UUIDs") can be obtained
  ;; by running 'blkid' in a terminal.
  (file-systems (cons* (file-system
                         (mount-point "/boot/efi")
                         (device (uuid "1399-EECD"
                                       'fat32))
                         (type "vfat"))
                       (file-system
                         (mount-point "/")
                         (device (uuid
                                  "aee6185f-1e8d-4b3a-8460-45addf7862ba"
                                  'ext4))
                         (type "ext4")) %base-file-systems)))
