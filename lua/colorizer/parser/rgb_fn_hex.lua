---Helper function to parse argb

local parser = {}

local CSS_RGBA_FN_MINIMUM_LENGTH = #"rgba(0,0,0)" - 1
local CSS_RGB_FN_MINIMUM_LENGTH = #"rgb(0,0,0)" - 1
---Parse for rgb() rgba() css function and return rgb hex.
-- For more info: https://developer.mozilla.org/en-US/docs/Web/CSS/color_value/rgb
---@param line string: Line to parse
---@param i number: Index of line from where to start parsing
---@param opts table: Values passed from matchers like prefix
---@return number|nil: Index of line where the rgb/rgba function ended
---@return string|nil: rgb hex value
function parser.rgb_function_hex_parser(line, i, opts, multiply_by_alpha)
  local min_len = CSS_RGBA_FN_MINIMUM_LENGTH
  local pattern = "^"
      .. opts.prefix
      ..
      "%(%s*0x([%d%a]+)%s*,%s*0x([%d%a]+)%s*,%s*0x([%d%a]+)%s*,%s*0x([%d%a]*)%s*%)()"

  if opts.prefix == "rgb" then
    min_len = CSS_RGB_FN_MINIMUM_LENGTH
  end

  if #line < i + min_len then
    return
  end

  local r,  g,  b,  a,  match_end =
      line:sub(i):match(pattern)
   vim.api.nvim_echo({ { string.format("[ %s] [%s] [%s] [%s]", r,g,b,a) , 'None' }, { ' second chunk to echo', 'None' } }, true, {});
  if not match_end then
    return
  end

  if a == "" then
    a = nil
  end


  if not a then
    a = 1
  else
    a = tonumber(a,16)
  end

  r = tonumber(r,16)
  if not r then
    return
  end
  g = tonumber(g,16)
  if not g then
    return
  end
  b = tonumber(b,16)
  if not b then
    return
  end
  -- although r,g,b doesn't support larger values than 255, css anyways renders it at 255
  if r > 255 then
    r = 255
  end
  if g > 255 then
    g = 255
  end
  if b > 255 then
    b = 255
  end


  local rgb_hex
  if multiply_by_alpha then
    rgb_hex = string.format("%02x%02x%02x", r * a, g * a, b * a)
  else
    rgb_hex = string.format("%02x%02x%02x", r, g, b)
  end
  return match_end - 1, rgb_hex
end

return parser.rgb_function_hex_parser
