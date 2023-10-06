Gameplay = {}

local p1bindings = {
	left = 'left',
	right = 'right',
	jump = 'up',
	shuriken = { 'lalt', 'ralt', 'z' },
}

local p2bindings = {
	left = 'a',
	right = 'd',
	jump = 'w',
	shuriken = 'g',
}

function Gameplay:getPlayer2Controller(player, maybeJoystick, player1IsJoystick)
	if self.playerNum == 1 then
		return AIController(player)
	end
	if maybeJoystick then
		return JoystickController(player, Images.joystickControls, maybeJoystick)
	end
	-- if the first player is using the joystick, the second player can use the full keyboard
	if player1IsJoystick then
		return KeyboardController(player, Images.p1keyboardControls, p1bindings)
	end
	return KeyboardController(player, Images.p2keyboardControls, p2bindings)
end

function Gameplay:enter(prev, playerNum)
	timer.clear()
	signals.clear()

	self.world = bump.newWorld()

	self.map = Map(self.world, {
		"#                  #",
		"#                  #",
		"#                  #",
		"#                  #",
		"#    @        @    #",
		"#                  #",
		"#    ##      ##    #",
		"#                  #",
		"##                ##",
		"###      ##      ###",
		"####    ####    ####",
		"####################",
	})

	self.players = {}
	self.playerNum = playerNum
	self.deadPlayers = {}
	self.numDead = 0

	self.gameOver = false
	self.winnerText = nil
	self.winnerTextOpacity = 0

	self.controllers = {}

	self.bombs = {}

	self.screenShake = 0

	local spawns = self.map.spawns
	local p1 = Player(spawns[1].x, spawns[1].y, { 1, 1, 1 }, self.world)
	local p2 = Player(spawns[2].x, spawns[2].y, { 0, 0, 0 }, self.world)
	p2:setWalking(-1)
	p2:setWalking(0)

	table.insert(self.players, p1)
	table.insert(self.players, p2)

	local joysticks = util.filter(love.joystick.getJoysticks(), function(joystick)
		return joystick:isGamepad()
	end)

	local p1controller =
			joysticks[1]
			and JoystickController(p1, Images.joystickControls, joysticks[1])
			or KeyboardController(p1, Images.p1keyboardControls, p1bindings)

	local p2controller = self:getPlayer2Controller(p2, joysticks[2], joysticks[1] ~= nil)

	table.insert(self.controllers, p1controller)
	table.insert(self.controllers, p2controller)

	local callbacks = {
		'keyreleased',
		'gamepadreleased',
		'gamepadaxis',
	}

	for i = 1, #callbacks do
		local callback = callbacks[i]
		self[callback] = function(self, ...)
			util.map(self.controllers, callback, ...)
		end
	end

	signals.register('playerDied', function(player)
		self.deadPlayers[player] = true
		self.numDead = self.numDead + 1
		if self.numDead + 1 >= self.playerNum then
			self:setControllersEnabled(false)

			timer.add(1, function()
				if not self.winnerText then
					self.winnerText = "TIE"
					for i = 1, #self.players do
						local player = self.players[i]
						if not self.deadPlayers[player] then
							self.winnerText = "player " .. i .. "\nwins"
						end
					end
					timer.add(1, function() self.gameOver = true end)
					flux.to(self, 0.5, { winnerTextOpacity = 1 })
				end
			end)
		end
	end)

	signals.register('bombExploded', function()
		self.screenShake = 1
		flux.to(self, 0.3, { screenShake = 0 })
	end)

	self:setControllersEnabled(false)
	self.countdown = Countdown()
	function self.countdown.finished()
		self:setControllersEnabled(true)
	end

	timer.add(4, function()
		for i = 1, #self.controllers do
			self.controllers[i]:hideControls()
		end
	end)

	local function spawnBomb()
		if not self.winnerText then
			self:spawnBomb()
			timer.add(util.prandom(2, 4), spawnBomb)
		end
	end

	timer.add(util.prandom(5, 10), spawnBomb)
end

function Gameplay:getWorldObjects()
	return self.world:queryRect(self.map:getRect())
end

function Gameplay:setControllersEnabled(enabled)
	util.map(self.controllers, function(controller)
		controller:setEnabled(enabled)
	end)
end

function Gameplay:spawnBomb()
	local x, y, width, height = self.map:getRect()

	local leader = self.players[1]
	for i = 2, #self.players do
		if self.players[i].health > leader.health then
			leader = self.players[i]
		end
	end

	local x, y = leader:getCenter()

	local bomb = Bomb(x, -100, love.math.random(-300, 300), self.world)

	table.insert(self.bombs, bomb)
end

function Gameplay:sweepBombs()
	for i = #self.bombs, 1, -1 do
		if not self.world:hasItem(self.bombs[i]) then
			table.remove(self.bombs, i)
		end
	end
end

function Gameplay:pause()
	gamestate.push(Paused)
end

function Gameplay:keypressed(key)
	if self.gameOver then
		gamestate.switch(Menu)
	else
		if key == 'escape' or key == 'p' then
			self:pause()
		else
			util.map(self.controllers, 'keypressed', key)
		end
	end
end

function Gameplay:gamepadpressed(joystick, button)
	if self.gameOver then
		gamestate.switch(Menu)
	else
		if button == 'start' then
			self:pause()
		else
			util.map(self.controllers, 'gamepadpressed', joystick, button)
		end
	end
end

function Gameplay:update(dt)
	self.countdown:update(dt)

	self:sweepBombs()

	util.map(self.players, 'update', dt)
	util.map(self.controllers, 'update', dt)
	util.map(self.bombs, 'update', dt)

	flux.update(dt)
	timer.update(dt)
end

function Gameplay:draw()
	scaler.draw(function()
		love.graphics.push()

		local vibration = self.screenShake * 8
		love.graphics.translate(
			love.math.random(-vibration, vibration),
			love.math.random(-vibration, vibration)
		)

		love.graphics.draw(Images.background)

		util.map(self.players, 'drawShurikens')
		util.map(self.players, 'draw')
		util.map(self.map.mapBlocks, 'draw')
		util.map(self.bombs, 'draw')

		self.countdown:draw()

		if self.winnerText then
			love.graphics.setColor(30, 30, 30, 255 * self.winnerTextOpacity)
			love.graphics.setFont(Fonts.endgame)
			love.graphics.printf(self.winnerText, 0, 100 - math.abs(math.sin(GameTime * 3)) * 10, scaler.getWidth(), 'center')

			if self.gameOver then
				love.graphics.setColor(255, 255, 255)
				love.graphics.setFont(Fonts.normal)
				love.graphics.printf("press any key to continue", 0, 250, scaler.getWidth(), 'center')
			end
			love.graphics.setColor(255, 255, 255)
		end

		util.map(self.controllers, 'draw')

		love.graphics.pop()
	end)
end
