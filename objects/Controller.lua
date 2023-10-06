Controller = Object:extend()
Controller:implement(Stately)

function Controller:new(player, controlsImage)
	self.player = player
	self.enabled = true
	self.controlsImage = controlsImage
	self.displayOpacity = 1
end

function Controller:setEnabled(enabled)
	self.enabled = enabled
	if not enabled then
		self.player:stopJumping()
		self.player:setWalking(0)
	end
end

function Controller:displayControls()
	flux.to(self, 0.5, { displayOpacity = 1 })
end

function Controller:hideControls()
	flux.to(self, 0.5, { displayOpacity = 0 })
end

function Controller:draw()
	if self.controlsImage then
		local px,py = self.player:getCenter()
		local w,h = self.controlsImage:getDimensions()

		love.graphics.setColor(30, 30, 30, 255 * self.displayOpacity)
		love.graphics.draw(self.controlsImage, px - w/2, py - 80)
		love.graphics.setColor(255, 255, 255)
	end
end


function Controller:update(dt) end
function Controller:keypressed(key) end
function Controller:keyreleased(key) end
function Controller:gamepadpressed(joystick, button) end
function Controller:gamepadreleased(joystick, button) end
function Controller:gamepadaxis(joystick, axis, value) end
