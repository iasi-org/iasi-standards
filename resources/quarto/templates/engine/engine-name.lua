local script_dir = pandoc.path.directory(PANDOC_SCRIPT_FILE)

local Engine = dofile(
  pandoc.path.normalize(
    pandoc.path.join({
      script_dir,
      "..",
      "..",
      "core",
      "engine.lua"
    })
  )
)

local Compiler = dofile(
  pandoc.path.join({
    script_dir,
    "compiler.lua"
  })
)

local Defaults = dofile(
  pandoc.path.join({
    script_dir,
    "defaults.lua"
  })
)

return Engine.create({
  name = "engine-name",
  block_class = "engine-name",
  version = "0.1.0",
  compiler = Compiler,
  defaults = Defaults
})
