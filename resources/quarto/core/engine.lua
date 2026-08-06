local Engine = {}

local function has_class(block, expected)
  for _, class_name in ipairs(block.classes) do
    if class_name == expected then
      return true
    end
  end

  return false
end

local function merge_block_config(global_config, block)
  local result = {}

  for key, value in pairs(global_config) do
    result[key] = value
  end

  for _, key in ipairs({ "server", "format", "cache" }) do
    if block.attributes[key] ~= nil then
      result[key] = block.attributes[key]
    end
  end

  return result
end

function Engine.create(specification)
  assert(specification.name, "Falta specification.name")
  assert(specification.compiler, "Falta specification.compiler")
  assert(specification.defaults, "Falta specification.defaults")
  assert(specification.load_core, "Falta specification.load_core")

  local Metadata = specification.load_core("metadata")
  local Config = specification.load_core("config")
  local Filesystem = specification.load_core("filesystem")
  local Cache = specification.load_core("cache")
  local MediaBag = specification.load_core("mediabag")

  local function Pandoc(document)
    local config = Config.load(
      document.meta,
      specification.name,
      specification.defaults,
      Metadata
    )

    if config.enabled == false then
      return document
    end

    local cache = Cache.open({
      filesystem = Filesystem,
      directory = pandoc.path.join({
        ".quarto",
        specification.name
      }),
      extension = tostring(config.format),
      mode = config.cache
    })

    local function CodeBlock(block)
      if not has_class(
        block,
        specification.block_class or specification.name
      ) then
        return nil
      end

      local block_config = merge_block_config(config, block)
      local source = block.text

      if specification.compiler.prepare ~= nil then
        source = specification.compiler.prepare(source, block_config)
      end

      local digest = pandoc.utils.sha1(table.concat({
        source,
        tostring(block_config.server or ""),
        tostring(block_config.format or ""),
        tostring(specification.version or "")
      }, "\n"))

      local contents = cache.get(digest)
      local mime_type

      if contents == nil or block_config.cache == false then
        mime_type, contents = specification.compiler.compile(
          source,
          block_config
        )

        if block_config.cache ~= false then
          cache.put(digest, contents)
        end
      else
        mime_type = specification.compiler.mime_type(block_config)
      end

      local media_path = table.concat({
        specification.name,
        "/",
        digest,
        ".",
        tostring(block_config.format)
      })

      return MediaBag.publish(
        block,
        media_path,
        mime_type,
        contents
      )
    end

    return document:walk({
      CodeBlock = CodeBlock
    })
  end

  return {
    {
      Pandoc = Pandoc
    }
  }
end

return Engine