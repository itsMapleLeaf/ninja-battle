KeyboardController = Controller:extend()

local defaultBindings = {
	left = 'left',
	right = 'right',
	jump = 'up',
	shuriken = 'z',
}

function KeyboardController:new(player, controlsImage, bindings)
	Controller.new(self, player, controlsImage)

	self.bindings = bindings or defaultBindings
end

function KeyboardController:update(dt)
	if self.enabled then
		local down = love.keyboard.isDown

		local dir = 0
		if down(self.bindings.left) then dir = dir - 1 end
		if down(self.bindings.right) then dir = dir + 1 end
		self.player:setWalking(dir)
	end
end

function KeyboardController:keypressed(key)
	if self.enabled then
		if key == self.bindings.jump then
			self.player:jump()
		end

		if type(self.bindings.shuriken) == 'string' then
			if key == self.bindings.shuriken then
				self.player:throwShuriken()
			end
		elseif type(self.bindings.shuriken) == 'table' then
			for i=1, #self.bindings.shuriken do
				local binding = self.bindings.shuriken[i]
				if key == binding then
					self.player:throwShuriken()
				end
			end
		end
	end
end

function KeyboardController:keyreleased(key)
	if self.enabled then
		if key == self.bindings.jump then
			self.player:stopJumping()
		end
	end
end
