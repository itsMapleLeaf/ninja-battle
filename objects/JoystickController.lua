JoystickController = Controller:extend()

function JoystickController:new(player, controlsImage, joystick)
	Controller.new(self, player, controlsImage)
	self.joystick = joystick
end

function JoystickController:update(dt)
	if self.enabled then
		local joystick = self.joystick
		local ax = util.multiple(joystick:getGamepadAxis('leftx'))

		if ax ~= 0 then
			self.player:setWalking(ax)
		else
			local dir = 0
			if joystick:isGamepadDown('dpleft') then
				dir = dir - 1
			end
			if joystick:isGamepadDown('dpright') then
				dir = dir + 1
			end
			self.player:setWalking(dir)
		end
	end
end

function JoystickController:gamepadpressed(joystick, button)
	if self.enabled then
		if joystick == self.joystick then
			if button == 'a' then self.player:jump() end
			if button == 'x' then self.player:throwShuriken() end
		end
	end
end

function JoystickController:gamepadreleased(joystick, button)
	if self.enabled then
		if joystick == self.joystick then
			if button == 'a' then
				self.player:stopJumping()
			end
		end
	end
end
