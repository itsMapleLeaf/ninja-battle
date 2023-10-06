---@alias RGBA { [1]: number, [2]: number, [3]: number, [4]: number? }

-- compatibility with new love colors
local setColor = love.graphics.setColor
---@param r number
---@param g number
---@param b number
---@param a number?
---@overload fun(rgba: RGBA)
---@diagnostic disable-next-line: duplicate-set-field
function love.graphics.setColor(r, g, b, a)
  if type(r) == 'table' then
    setColor(r[1] / 255, r[2] / 255, r[3] / 255, (r[4]) / 255)
  else
    setColor(r / 255, g / 255, b / 255, (a or 255) / 255)
  end
end

local getColor = love.graphics.getColor
---@return number r
---@return number g
---@return number b
---@return number a
---@diagnostic disable-next-line: duplicate-set-field
function love.graphics.getColor()
  local r, g, b, a = getColor()
  return r * 255, g * 255, b * 255, a * 255
end
