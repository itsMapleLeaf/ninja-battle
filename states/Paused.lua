Paused = {}

function Paused:enter(prev)
	self.prevState = prev
end

function Paused:keypressed(key)
	if key == 'escape' or key == 'p' then
		gamestate.pop()
	end
end

function Paused:gamepadpressed(joystick, button)
	if button == 'start' then
		gamestate.pop()
	end
end

function Paused:draw()
	self.prevState:draw()

	scaler.draw(function()
		love.graphics.setColor(0, 0, 0, 50)
		love.graphics.rectangle('fill', 0, 0, scaler.getDimensions())
		love.graphics.setColor(255, 255, 255)
		love.graphics.setFont(Fonts.endgame)
		love.graphics.printf("paused", 0, 120, scaler.getWidth(), 'center')
	end)
end
