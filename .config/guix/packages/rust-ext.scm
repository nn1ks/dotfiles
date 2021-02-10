(define-module (rust-ext)
  #:use-module (gnu packages)
  #:use-module (gnu packages base)
  #:use-module (gnu packages compression)
  #:use-module (gnu packages gcc)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module ((guix licenses) #:prefix license:)
  #:use-module (nonguix build-system binary))

(define-public rust-bin
  (package
    (name "rust-bin")
    (version "1.49.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://static.rust-lang.org/dist/2020-12-31/rust-"
                                  version "-x86_64-unknown-linux-gnu.tar.gz"))
              (sha256 (base32 "1099x7ip1vw8jbwblqhwca8zy2wfy69fv3zmkkb0fdrgz1nl854b"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
      `(#:patchelf-plan
        `(("rustc/lib/libLLVM-11-rust-1.49.0-stable.so"
           ("glibc" "gcc:lib" "zlib"))
          ("rustc/lib/libstd-e12de7683a34c500.so"
           ("glibc" "gcc:lib"))
          ("rustc/lib/librustc_driver-74849affecce5bb0.so"
           ("glibc" "gcc:lib" "out"))
          ("rustc/lib/libchalk_derive-8cbf2a95fc944986.so"
           ("glibc" "gcc:lib"))
          ("rustc/lib/librustc_macros-6003eb18afe8b8c1.so"
           ("glibc" "gcc:lib"))
          ("rustc/lib/libtest-6609e81d71a1bf05.so"
           ("gcc:lib" "out"))
          ("rustc/lib/libtracing_attributes-916696aac246fd21.so"
           ("glibc" "gcc:lib"))
          ("rustc/bin/rustc"
           ("glibc" "out"))
          ("rustc/bin/rustdoc"
           ("gcc:lib" "out"))
          ("rustc/lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-lld"
           ("glibc" "gcc:lib" "out"))
          ("rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libstd-e12de7683a34c500.so"
           ("glibc" "gcc:lib"))
          ("rust-std-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/libtest-6609e81d71a1bf05.so"
           ("gcc:lib" "out"))
          ("cargo/bin/cargo"
           ("glibc" "gcc:lib"))
          ("clippy-preview/bin/cargo-clippy"
           ("glibc" "gcc:lib"))
          ("clippy-preview/bin/clippy-driver"
           ("gcc:lib" "out"))
          ("rustfmt-preview/bin/rustfmt"
           ("glibc" "gcc:lib"))
          ("rustfmt-preview/bin/cargo-fmt"
           ("glibc" "gcc:lib")))
        #:phases
        (modify-phases %standard-phases
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                ;; rustc
                ;;(copy-recursively "rustc/lib" (string-append out "/lib"))
                (install-file "rustc/lib/libLLVM-11-rust-1.49.0-stable.so" (string-append out "/lib"))
                (install-file "rustc/lib/libstd-e12de7683a34c500.so" (string-append out "/lib"))
                (install-file "rustc/lib/librustc_driver-74849affecce5bb0.so" (string-append out "/lib"))
                (install-file "rustc/lib/libchalk_derive-8cbf2a95fc944986.so" (string-append out "/lib"))
                (install-file "rustc/lib/librustc_macros-6003eb18afe8b8c1.so" (string-append out "/lib"))
                (install-file "rustc/lib/libtest-6609e81d71a1bf05.so" (string-append out "/lib"))
                (install-file "rustc/lib/libtracing_attributes-916696aac246fd21.so" (string-append out "/lib"))
                (copy-recursively "rustc/lib/rustlib/etc" (string-append out "/lib/rustlib/etc"))
                ;;(copy-recursively "rustc/lib/rustlib/x86_64-unknown-linux-gnu" (string-append out "/lib/rustlib/x86_64-unknown-linux-gnu"))
                (copy-recursively "rustc/share" (string-append out "/share"))
                (install-file "rustc/bin/rustc" (string-append out "/bin"))
                (install-file "rustc/bin/rustdoc" (string-append out "/bin"))
                (install-file "rustc/bin/rust-gdb" (string-append out "/bin"))
                (install-file "rustc/bin/rust-gdbgui" (string-append out "/bin"))
                (install-file "rustc/bin/rust-lldb" (string-append out "/bin"))
                ;; std
                (copy-recursively "rust-std-x86_64-unknown-linux-gnu/lib" (string-append out "/lib"))
                ;; cargo
                (copy-recursively "cargo/etc" (string-append out "/etc"))
                (copy-recursively "cargo/share" (string-append out "/share"))
                (install-file "cargo/bin/cargo" (string-append out "/bin"))
                ;; clippy
                (copy-recursively "clippy-preview/share" (string-append out "/share"))
                (install-file "clippy-preview/bin/clippy-driver" (string-append out "/bin"))
                (install-file "clippy-preview/bin/cargo-clippy" (string-append out "/bin"))
                ;; rustfmt
                (copy-recursively "rustfmt-preview/share" (string-append out "/share"))
                (install-file "rustfmt-preview/bin/rustfmt" (string-append out "/bin"))
                (install-file "rustfmt-preview/bin/cargo-fmt" (string-append out "/bin"))
                ;; rust-docs
                (copy-recursively "rust-docs/share" (string-append out "/share"))
                ;; rust-src
                (copy-recursively (string-append (assoc-ref inputs "rust-src") "/lib") (string-append out "/lib"))))))))
    (inputs
      `(("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")
        ("zlib" ,zlib)))
    (native-inputs
      `(("rust-src" ,rust-src)))
    (synopsis "The Rust programming language (binary package)")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))

(define-public rust-src
  (package
    (name "rust-src")
    (version "1.49.0")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://static.rust-lang.org/dist/2020-12-31/rust-src-"
                                  version ".tar.gz"))
              (sha256 (base32 "13kgaswywpxjq4c3lcv5nag5k9q2sz77673hzawhwwnsq780yjj7"))))
    (build-system binary-build-system)
    (arguments
      `(#:install-plan
        `(("rust-src/lib" "./"))))
    (synopsis "Source for the Rust programming language")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))

(define-public rust-analyzer-bin
  (package
    (name "rust-analyzer-bin")
    (version "2021-01-25")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/rust-analyzer/rust-analyzer/releases/download/"
                                  version "/rust-analyzer-linux"))
              (sha256 (base32 "05kv9ipccqshqiw0gylgf0mbii2ra5pphk7b7s9g0b00jmkqv6vq"))))
    (build-system binary-build-system)
    (arguments
      `(#:patchelf-plan
        `(("rust-analyzer"
           ("glibc" "gcc:lib")))
        #:install-plan
        `(("rust-analyzer" "bin/"))
        #:phases
        (modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (copy-file source "rust-analyzer")
              (chmod "rust-analyzer" #o755))))))
    (inputs
      `(("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")))
    (synopsis "An experimental Rust compiler front-end for IDEs (binary package)")
    (description "Rust-analyzer is an experimental modular compiler frontend for the Rust language.")
    (home-page "https://rust-analyzer.github.io")
    (license (list license:asl2.0 license:expat))))
