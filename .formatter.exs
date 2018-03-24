export_locals_without_parens = [
  job: 2,
  job: 3,
  broadcast!: 1,
  broadcast!: 2,
  broadcast!: 3
]

[
  import_deps: [:plug],
  inputs: ["mix.exs", "{config,lib}/**/*.{ex,exs}"],
  locals_without_parens: export_locals_without_parens,
  export: [locals_without_parens: export_locals_without_parens]
]
