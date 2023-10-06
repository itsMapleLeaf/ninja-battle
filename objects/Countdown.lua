Countdown = Object:extend()

function Countdown:new()
	self.period = 0.8
	self.time = 0
	self.texts = { '', '3', '2', '1', 'GO' }
	self.textIndex = 1

	self.opacity = 1
	self.vibration = 0

	self.active = true
end

function Countdown:update(dt)
	if self.active then
		self.time = self.time - dt
		if self.time <= 0 then
			self.time = self.time + self.period
			if self.textIndex < #self.texts then
				self.textIndex = self.textIndex + 1
				self.vibration = 1
				flux.to(self, 0.3, { vibration = 0 })
			end
			if self.textIndex == #self.texts then
				self.active = false
				self.finished()
				flux.to(self, 0.5, { opacity = 0 }):delay(0.5)
				Sounds.roundStart:stop()
				Sounds.roundStart:play()
			else
				Sounds.ding:stop()
				Sounds.ding:play()
			end
		end
	end
end

function Countdown.finished()
end

function Countdown:draw()
	local vibration = self.vibration * 20
	local vx = love.math.random(-vibration, vibration)
	local vy = love.math.random(-vibration, vibration)

	love.graphics.setColor(30, 30, 30, 255 * self.opacity)
	love.graphics.setFont(Fonts.countdown)
	love.graphics.printf(self.texts[self.textIndex], 0 + vx, 100 + vy, scaler.getWidth(), 'center')
	love.graphics.setColor(255, 255, 255)
end
