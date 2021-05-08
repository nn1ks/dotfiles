(use-modules (gnu))
(use-service-modules certbot dbus docker desktop linux networking ssh web)

(define %nginx-deploy-hook
  (program-file
    "nginx-deploy-hook"
    #~(let ((pid (call-with-input-file "/var/run/nginx/pid" read)))
        (kill pid SIGHUP))))

(operating-system
  (host-name "vps-guix")
  (timezone "Europe/Berlin")
  (locale "en_US.UTF-8")
  (keyboard-layout (keyboard-layout "de"))
  (users (cons (user-account
                 (name "niklas")
                 (comment "Niklas Sauter")
                 (group "users")
                 (home-directory "/home/niklas")
                 (supplementary-groups '("wheel")))
               %base-user-accounts))
  (packages
    (append
      (list (specification->package "nss-certs"))
      %base-packages))
  (services
    (cons*
      (service dhcp-client-service-type)
      (service openssh-service-type
        (openssh-configuration
          (password-authentication? #f)
          (authorized-keys
            `(("niklas" ,(local-file "niklas_rsa.pub"))
              ("root" ,(local-file "niklas_rsa.pub"))))))
      (service zram-device-service-type
        (zram-device-configuration (size "2G")))
      (service certbot-service-type
        (certbot-configuration
          (email "niklas@n1ks.net")
          (certificates
            (list (certificate-configuration
                    (domains '("n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("vault.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("feed.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))
                  (certificate-configuration
                    (domains '("searx.n1ks.net"))
                    (deploy-hook %nginx-deploy-hook))))))
      (service nginx-service-type
        (nginx-configuration
          (server-blocks
            (list ;; Matrix
                  ;; https://github.com/matrix-org/synapse/blob/master/docs/reverse_proxy.md
                  (nginx-server-configuration
                    (server-name '("n1ks.net"))
                    (listen '("443 ssl"
                              "[::]:443 ssl"
                              "8448 ssl default_server"
                              "[::]:8448 ssl default_server"))
                    (ssl-certificate "/etc/letsencrypt/live/n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "~* ^(\\/_matrix|\\/_synapse\\/client)")
                          (body '("proxy_pass http://localhost:8008;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"
                                  "client_max_body_size 50M;"))))))

                  ;; Bitwarden
                  ;; https://github.com/dani-garcia/vaultwarden/wiki/Proxy-examples
                  (nginx-server-configuration
                    (server-name '("vault.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/vault.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/vault.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:8081;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;")))
                        (nginx-location-configuration
                          (uri "/notifications/hub")
                          (body '("proxy_pass http://localhost:8082;"
                                  "proxy_set_header Upgrade $http_upgrade;"
                                  "proxy_set_header Connection \"upgrade\";")))
                        (nginx-location-configuration
                          (uri "/notifications/hub/negotiate")
                          (body '("proxy_pass http://localhost:8081;")))))
                    (raw-content '("client_max_body_size 128M;")))

                  ;; Miniflux
                  (nginx-server-configuration
                    (server-name '("feed.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/feed.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/feed.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:8083;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"))))))

                  ;; Searx
                  (nginx-server-configuration
                    (server-name '("searx.n1ks.net"))
                    (listen '("443 ssl" "[::]:443 ssl"))
                    (ssl-certificate "/etc/letsencrypt/live/searx.n1ks.net/fullchain.pem")
                    (ssl-certificate-key "/etc/letsencrypt/live/searx.n1ks.net/privkey.pem")
                    (locations
                      (list
                        (nginx-location-configuration
                          (uri "/")
                          (body '("proxy_pass http://localhost:4040;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;"
                                  "proxy_set_header X-Script-Name /searx;")))
                        (nginx-location-configuration
                          (uri "/morty/")
                          (body '("proxy_pass http://localhost:3000;"
                                  "proxy_set_header Host $host;"
                                  "proxy_set_header X-Real-IP $remote_addr;"
                                  "proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;"
                                  "proxy_set_header X-Forwarded-Proto $scheme;")))))
                    (raw-content '("access_log /dev/null;")))))))

      (dbus-service) ;; Required for `docker-service-type`
      (elogind-service) ;; Required for `docker-service-type`
      (service docker-service-type)
      %base-services))
  (initrd-modules
    (cons "virtio_scsi"
          %base-initrd-modules))
  (bootloader
    (bootloader-configuration
      (bootloader grub-bootloader)
      (target "/dev/sda")))
  (file-systems
    (cons (file-system
            (device (file-system-label "my-drive"))
            (mount-point "/")
            (type "ext4"))
          %base-file-systems)))
