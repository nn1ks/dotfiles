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
              (uri (string-append "file://" (getenv "HOME")
                                  "/.cache/guix-rust-bin/rust-bin-"
                                  version "-x86_64-unknown-linux-gnu.tar.gz"))
              (sha256 (base32 "0nqw7vfrqi3qdywyms0y68y8wgk208r8dim64c6d5zhhz9cksvml"))))
    (supported-systems '("x86_64-linux"))
    (build-system binary-build-system)
    (arguments
      `(#:strip-binaries? #f
        #:patchelf-plan
        `(("lib/libLLVM-11-rust-1.49.0-stable.so"
           ("glibc" "gcc:lib" "zlib"))
          ("lib/libstd-e12de7683a34c500.so"
           ("glibc" "gcc:lib"))
          ("lib/librustc_driver-74849affecce5bb0.so"
           ("glibc" "gcc:lib" "out"))
          ("lib/libchalk_derive-8cbf2a95fc944986.so"
           ("glibc" "gcc:lib"))
          ("lib/librustc_macros-6003eb18afe8b8c1.so"
           ("glibc" "gcc:lib"))
          ("lib/libtest-6609e81d71a1bf05.so"
           ("gcc:lib" "out"))
          ("lib/libtracing_attributes-916696aac246fd21.so"
           ("glibc" "gcc:lib"))
          ("bin/rustc"
           ("glibc" "out"))
          ("bin/rustdoc"
           ("gcc:lib" "out"))
          ("lib/rustlib/x86_64-unknown-linux-gnu/bin/rust-lld"
           ("glibc" "gcc:lib" "out"))
          ("lib/rustlib/x86_64-unknown-linux-gnu/lib/libstd-e12de7683a34c500.so"
           ("glibc" "gcc:lib"))
          ("lib/rustlib/x86_64-unknown-linux-gnu/lib/libtest-6609e81d71a1bf05.so"
           ("gcc:lib" "out"))
          ("bin/cargo"
           ("glibc" "gcc:lib"))
          ("bin/cargo-clippy"
           ("glibc" "gcc:lib"))
          ("bin/clippy-driver"
           ("gcc:lib" "out"))
          ("bin/rustfmt"
           ("glibc" "gcc:lib"))
          ("bin/cargo-fmt"
           ("glibc" "gcc:lib")))
        #:install-plan
        `(("bin" "bin")
          ("etc" "etc")
          ("lib" "lib")
          ("share" "share"))))
    (inputs
      `(("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")
        ("zlib" ,zlib)))
    (synopsis "The Rust programming language (binary package)")
    (description "Rust is a systems programming language that provides memory safety and thread safety guarantees.")
    (home-page "https://rust-lang.org")
    (license (list license:asl2.0 license:expat))))

(define-public rust-analyzer-bin
  (package
    (name "rust-analyzer-bin")
    (version "2021-01-18")
    (source (origin
              (method url-fetch)
              (uri (string-append "https://github.com/rust-analyzer/rust-analyzer/releases/download/"
                                  version "/rust-analyzer-linux"))
              (sha256 (base32 "1j970fn9bbick39n6jjks3bcc7mchsy9wqn2z1wlndjhsz0kvk2l"))))
    (build-system binary-build-system)
    (arguments
      `(#:patchelf-plan
        `(("rust-analyzer"
           ("glibc" "gcc:lib")))
        #:phases
        (modify-phases %standard-phases
          (replace 'unpack
            (lambda* (#:key source #:allow-other-keys)
              (copy-file source "rust-analyzer")
              (chmod "rust-analyzer" #o755)))
          (replace 'install
            (lambda* (#:key inputs outputs #:allow-other-keys)
              (let ((out (assoc-ref outputs "out")))
                (install-file "rust-analyzer" (string-append out "/bin"))))))))
    (inputs
      `(("glibc" ,glibc)
        ("gcc:lib" ,gcc "lib")))
    (synopsis "An experimental Rust compiler front-end for IDEs")
    (description "Rust-analyzer is an experimental modular compiler frontend for the Rust language.")
    (home-page "https://rust-analyzer.github.io")
    (license (list license:asl2.0 license:expat))))
