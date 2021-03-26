(define-module (bisc)
  #:use-module (gnu packages haskell-xyz)
  #:use-module (gnu packages haskell-check)
  #:use-module (guix packages)
  #:use-module (guix download)
  #:use-module (guix build-system haskell)
  #:use-module ((guix licenses) #:prefix license:))

(define-public bisc
  (package
    (name "bisc")
    (version "0.2.3.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://hackage.haskell.org/package/bisc/bisc-"
               version
               ".tar.gz"))
        (sha256
          (base32
            "0x03smkfx0qnsxznlp1591gi938f15w057hywfp9497mhvkr7mxg"))))
    (build-system haskell-build-system)
    (inputs
      `(("ghc-selda" ,ghc-selda)
        ("ghc-selda-sqlite" ,ghc-selda-sqlite)
        ("ghc-configurator" ,ghc-configurator)))
    (home-page
      "https://maxwell.ydns.eu/git/rnhmjoj/bisc")
    (synopsis
      "A small tool that clears qutebrowser cookies.")
    (description
      "Bisc clears qutebrowser cookies and javascript local storage by domains, stored in a whitelist.")
    (license license:gpl3)))

(define-public ghc-direct-sqlite
  (package
    (name "ghc-direct-sqlite")
    (version "2.3.26")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://hackage.haskell.org/package/direct-sqlite/direct-sqlite-"
               version
               ".tar.gz"))
        (sha256
          (base32
            "1z7rwaqhxl9hagbcndg3dkqysr5n2bcz2jrrvdl9pdi905x2663y"))))
    (build-system haskell-build-system)
    (inputs `(("ghc-semigroups" ,ghc-semigroups)))
    (native-inputs
      `(("ghc-hunit" ,ghc-hunit)
        ("ghc-base16-bytestring" ,ghc-base16-bytestring)
        ("ghc-temporary" ,ghc-temporary)))
    (home-page
      "https://github.com/IreneKnapp/direct-sqlite")
    (synopsis
      "Low-level binding to SQLite3.  Includes UTF8 and BLOB support.")
    (description
      "This package is not very different from the other SQLite3 bindings out there, but it fixes a few deficiencies I was finding.  As compared to bindings-sqlite3, it is slightly higher-level, in that it supports marshalling of data values to and from the database.  In particular, it supports strings encoded as UTF8, and BLOBs represented as ByteStrings.")
    (license license:bsd-3)))

(define-public ghc-selda-sqlite
  (package
    (name "ghc-selda-sqlite")
    (version "0.1.7.1")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://hackage.haskell.org/package/selda-sqlite/selda-sqlite-"
               version
               ".tar.gz"))
        (sha256
          (base32
            "1a1rik32h8ijd98v98db1il10ap76rqdwmjwhj0hc0h77mm6qdfb"))))
    (build-system haskell-build-system)
    (inputs
      `(("ghc-selda" ,ghc-selda)
        ("ghc-direct-sqlite" ,ghc-direct-sqlite)
        ("ghc-exceptions" ,ghc-exceptions)
        ("ghc-uuid-types" ,ghc-uuid-types)))
    (arguments
      `(#:cabal-revision
        ("1"
         "05zdf07fizf97yby0ld4qkd5padxg9fhmpfiiii4jl7xklccnl6p")))
    (home-page "https://github.com/valderman/selda")
    (synopsis
      "SQLite backend for the Selda database EDSL.")
    (description
      "Allows the Selda database EDSL to be used with SQLite databases.")
    (license license:expat)))

(define-public ghc-selda
  (package
    (name "ghc-selda")
    (version "0.5.1.0")
    (source
      (origin
        (method url-fetch)
        (uri (string-append
               "https://hackage.haskell.org/package/selda/selda-"
               version
               ".tar.gz"))
        (sha256
          (base32
            "1gd7fdgqw6q507wn7h1pln9wb7kh65vd7iv0s1ydg54r36qdlrgl"))))
    (build-system haskell-build-system)
    (inputs
      `(("ghc-exceptions" ,ghc-exceptions)
        ("ghc-random" ,ghc-random)
        ("ghc-uuid-types" ,ghc-uuid-types)))
    (arguments
      `(#:cabal-revision
        ("1"
         "0sdzfgsmgw20idxnvvf4sbp8bkl3n7qa7qkphv63pfmqvzyplkwg")))
    (home-page "https://selda.link")
    (synopsis
      "Multi-backend, high-level EDSL for interacting with SQL databases.")
    (description
      "This package provides an EDSL for writing portable, type-safe, high-level database code. Its feature set includes querying and modifying databases, automatic, in-process caching with consistency guarantees, and transaction support. See the project website for a comprehensive tutorial. To use this package you need at least one backend package, in addition to this package. There are currently two different backend packages: selda-sqlite and selda-postgresql.")
    (license license:expat)))
