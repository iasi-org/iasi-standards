local Compiler = {}

local OUTPUT_FORMAT = "png"

local SUPPORTED_FORMATS = {
  png = "image/png",
  svg = "image/svg+xml"
}

local function trim_trailing_slash(value)
  return (value:gsub("/+$", ""))
end

local function normalize_styles(styles)
  if styles == nil then
    return {}
  end

  if type(styles) == "table" then
    return styles
  end

  return { tostring(styles) }
end

local function read_file(path)
  local file, message = io.open(path, "rb")

  if file == nil then
    error(
      "No se pudo leer el estilo PlantUML "
        .. tostring(path)
        .. ": "
        .. tostring(message)
    )
  end

  local contents = file:read("*a")
  file:close()

  return contents
end

local function inject_after_startuml(source, styles_source)
  if styles_source == "" then
    return source
  end

  local _, end_position = source:find("@startuml[^\r\n]*")

  if end_position == nil then
    return styles_source .. "\n" .. source
  end

  return source:sub(1, end_position)
    .. "\n"
    .. styles_source
    .. "\n"
    .. source:sub(end_position + 1)
end

local function validate_format(format)
  format = tostring(format):lower()

  if SUPPORTED_FORMATS[format] == nil then
    local supported = {}

    for name, _ in pairs(SUPPORTED_FORMATS) do
      table.insert(supported, name)
    end

    table.sort(supported)

    error(
      "Formato PlantUML no soportado: "
        .. format
        .. ". Formatos soportados: "
        .. table.concat(supported, ", ")
        .. "."
    )
  end

  return format
end

local function pipe_error_detail(problem)
  if type(problem) ~= "table" then
    return tostring(problem)
  end

  local parts = {}

  if problem.error_code ~= nil then
    table.insert(parts, "codigo: " .. tostring(problem.error_code))
  end

  if problem.output ~= nil and problem.output ~= "" then
    table.insert(parts, tostring(problem.output))
  end

  if #parts == 0 then
    return tostring(problem)
  end

  return table.concat(parts, "\n")
end

function Compiler.prepare(source, config)
  config.format = OUTPUT_FORMAT

  local style_files = normalize_styles(config.styles)

  if #style_files == 0 then
    return source
  end

  local fragments = {}

  for _, style_file in ipairs(style_files) do
    table.insert(fragments, read_file(tostring(style_file)))
  end

  return inject_after_startuml(
    source,
    table.concat(fragments, "\n")
  )
end

function Compiler.mime_type(config)
  local format = validate_format(config.format)

  return SUPPORTED_FORMATS[format]
end

function Compiler.compile(source, config)
  local format = validate_format(config.format)
  local url = trim_trailing_slash(tostring(config.server))
    .. "/"
    .. format

  local ok, contents = pcall(
    pandoc.pipe,
    "curl",
    {
      "--fail",
      "--silent",
      "--show-error",
      "--location",
      "--request",
      "POST",
      "--header",
      "Content-Type: text/plain; charset=utf-8",
      "--data-binary",
      "@-",
      url
    },
    source
  )

  if not ok then
    error(
      "No se pudo obtener el diagrama PlantUML mediante POST.\n"
        .. "URL: "
        .. url
        .. "\nDetalle: "
        .. pipe_error_detail(contents)
    )
  end

  if contents == nil or contents == "" then
    error(
      "PlantUML devolvio una respuesta vacia mediante POST: "
        .. url
    )
  end

  return SUPPORTED_FORMATS[format], contents
end

return Compiler
