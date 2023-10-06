AIController = Controller:extend()

function AIController:new(player)
	Controller.new(self, player)

	self.actionPeriod = 0.1
	self.time = self.actionPeriod

	self.target = nil
end

function AIController:update(dt)
	if self.enabled then
		self.time = self.time + dt
		if self.time > self.actionPeriod then
			self.time = self.time - self.actionPeriod
			self:action()
		end
	end
end

function AIController:action()
	local player = self.player
	if not self.target then
		local x, y, width, height = Gameplay.map:getRect()
		local players = player.world:queryRect(x, y, width, height,
			function(item)
				return item:is(Player) and item ~= player
			end)

		self.target = util.trandom(players)
	end

	local targetDir = util.sign(self.target.x - player.x)
	if player.dir ~= targetDir then
		player:setWalking(targetDir)
	else
		player:setWalking(0)
	end

	if math.abs(self.target.y - player.y) < 25 then
		if math.random() > 0.5 then
			player:throwShuriken()
		end
	else
		if math.abs(self.target.x - player.x) > 50 then
			player:setWalking(targetDir)
		else
			player:setWalking(-targetDir)
		end
	end


	local cx, cy = player:getCenter()
	local ahead = player.world:querySegment(
		cx, cy,
		cx + 50 * player.dir,
		cy,
		function(item)
			return item:is(MapBlock)
		end)

	if #ahead > 0 or self.target.y < player.y then
		player:jump()
	else
		player:stopJumping()
	end
end
