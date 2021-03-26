(define-module (firefox-custom)
  #:use-module (guix packages)
  #:use-module (guix utils)
  #:use-module (gnu packages gnome)
  #:use-module (nongnu packages mozilla))

;; Adds native notification support by adding `libnotify` as a input.
(define-public firefox-custom
  (package
    (inherit firefox)
    (name "firefox-custom")
    (arguments
      (substitute-keyword-arguments (package-arguments firefox)
         ((#:phases phases)
          `(modify-phases ,phases
             (replace 'wrap-program
               (lambda* (#:key inputs outputs #:allow-other-keys)
                 (let* ((out (assoc-ref outputs "out"))
                        (lib (string-append out "/lib"))
                        (ld-libs (map (lambda (x)
                                        (string-append (assoc-ref inputs x)
                                                       "/lib"))
                                      ;; Only change here is to add libnotify
                                      '("libnotify" "pulseaudio" "mesa")))
                        (gtk-share (string-append (assoc-ref inputs "gtk+")
                                                  "/share")))
                   (wrap-program (car (find-files lib "^firefox$"))
                     `("LD_LIBRARY_PATH" prefix ,ld-libs)
                     `("XDG_DATA_DIRS" prefix (,gtk-share))
                     `("MOZ_LEGACY_PROFILES" = ("1"))
                     `("MOZ_ALLOW_DOWNGRADE" = ("1")))
                   #t)))))))
    (inputs
     `(("libnotify" ,libnotify)
       ,@(package-inputs firefox)))))
