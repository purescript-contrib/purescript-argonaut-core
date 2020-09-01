{ name = "argonaut-core"
, dependencies =
  [ "arrays"
  , "console"
  , "control"
  , "effect"
  , "either"
  , "foreign-object"
  , "functions"
  , "gen"
  , "maybe"
  , "nonempty"
  , "prelude"
  , "psci-support"
  , "quickcheck"
  , "strings"
  , "tailrec"
  ]
, packages = ./packages.dhall
, sources = [ "src/**/*.purs", "test/**/*.purs" ]
}
