local scaler = {}
local currentScale = 1

function scaler.setScale(newScale)
	currentScale = newScale
end

function scaler.getScale()
	return currentScale
end

function scaler.getWidth()
	return love.graphics.getWidth() / currentScale
end

function scaler.getHeight()
	return love.graphics.getHeight() / currentScale
end

function scaler.getDimensions()
	return scaler.getWidth(), scaler.getHeight()
end

function scaler.draw(func)
	love.graphics.push()
	love.graphics.scale(currentScale)
	func()
	love.graphics.pop()
end

return scaler
