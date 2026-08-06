local Config = {}

local function copy_table(source)
  local target = {}

  for key, value in pairs(source or {}) do
    target[key] = value
  end

  return target
end

local function normalize_cache(value)
  if value == true or value == false then
    return value
  end

  local text = tostring(value):lower()

  if text == "true" then
    return true
  elseif text == "false" then
    return false
  elseif text == "clean" then
    return "clean"
  end

  error(
    'Valor de cache no valido: '
      .. tostring(value)
      .. '. Use true, false o "clean".'
  )
end

function Config.load(meta, engine_name, defaults, metadata)
  local result = copy_table(defaults)
  local engines = meta.engines

  if engines ~= nil and engines[engine_name] ~= nil then
    local values = engines[engine_name]

    for key, value in pairs(values) do
      result[key] = metadata.value(value, result[key])
    end
  end

  result.enabled = metadata.boolean(result.enabled, true)
  result.cache = normalize_cache(result.cache)

  return result
end

return Config
