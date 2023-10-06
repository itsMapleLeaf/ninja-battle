Menu = {}

function Menu:init()
	self.options = {
		{'1 player', function()
			gamestate.switch(Gameplay, 1)
		end},
		{'2 player', function()
			gamestate.switch(Gameplay, 2)
		end},
		{'exit', love.event.quit},
	}

	self.selection = 1
	self.vibration = 0
end

function Menu:shakeOption()
	self.vibration = 1
	flux.to(self, 0.2, { vibration = 0 })
	Sounds.select:stop()
	Sounds.select:play()
end

function Menu:next()
	self.selection = self.selection < #self.options and self.selection + 1 or 1
	self:shakeOption()
end

function Menu:prev()
	self.selection = self.selection > 1 and self.selection - 1 or #self.options
	self:shakeOption()
end

function Menu:select()
	self.options[self.selection][2]()
end

function Menu:update(dt)
	flux.update(dt)
end

function Menu:keypressed(key)
	if key == 'up' then
		self:prev()
	elseif key == 'down' then
		self:next()
	elseif key == 'return' then
		self:select()
	end
end

function Menu:gamepadpressed(joystick, button)
	if button == 'dpup' then
		self:prev()
	elseif button == 'dpdown' then
		self:next()
	elseif button == 'a' then
		self:select()
	end
end

function Menu:gamepadaxis(joystick, axis, value)
	if axis == 'lefty' then
		if value == -1 then
			self:prev()
		elseif value == 1 then
			self:next()
		end
	end
end

function Menu:draw()
	scaler.draw(function()
		local sw,sh = scaler.getDimensions()

		love.graphics.setColor(255, 255, 255)
		love.graphics.draw(Images.background)

		do
			local image = Images.logo
			local iw,ih = image:getDimensions()
			love.graphics.draw(image, sw/2 - iw/2, 30 + math.sin(GameTime*2)*5)
		end

		do
			local vibration = self.vibration * 4
			local vx, vy = love.math.random(-vibration, vibration), love.math.random(-vibration, vibration)

			love.graphics.setFont(Fonts.normal)

			for i=1, #self.options do
				local text = self.options[i][1]

				local x = 0
				local y = sh/2 + 20 + (i - 1)*30

				love.graphics.setColor(30, 30, 30)
				if i == self.selection then
					love.graphics.setColor(30, 100, 200)
					x = x + vx
					y = y + vy
				end

				love.graphics.printf(text, x, y, sw, 'center')
			end

			love.graphics.setColor(255, 255, 255)
		end
	end)
end
