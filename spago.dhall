{ name = "purescript-fetch-h2"
, dependencies =
  [ "aff-promise"
  , "argonaut-codecs"
  , "arraybuffer-types"
  , "console"
  , "debug"
  , "effect"
  , "psci-support"
  , "profunctor-lenses"
  , "spec"
  ]
, packages = ./packages.dhall
, sources =
  [ "src/**/*.purs"
  ]
}
