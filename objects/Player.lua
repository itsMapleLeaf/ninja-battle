Player = GameObject:extend()

local gravity = 1600
local accel = 10

local function playerFilter(item, other)
	if other:is(MapBlock) then
		return 'slide'
	end
	return 'cross'
end

local recolor = love.graphics.newShader [[
	extern vec3 newColor;
	extern number painDegree;

	vec4 effect(vec4 drawColor, Image texture, vec2 texCoords, vec2 screenCoords) {
		vec4 pixel = Texel(texture, texCoords);

		if (pixel.rgb == vec3(0, 0, 0)) {
			pixel.rgb = newColor;
		}

		pixel.rgb += (vec3(1,0,0) - pixel.rgb) * painDegree;
		return pixel * drawColor;
	}
]]

function Player:new(x, y, color, world)
	GameObject.new(self, x, y, 20, 20, world)
	self.x = self.x - self.width / 2
	self.y = self.y - self.height / 2

	local grid = anim8.newGrid(22, 22, Images.ninja:getDimensions())
	self.anim = anim8.newAnimation(grid('1-5', 1), 0.03)

	self.walking = false
	self.walkSpeed = 200
	self.dir = 1

	self.jumpSpeed = 300
	self.jumpTime = 0
	self.maxJumpTime = 0.3
	self.jumping = false

	self.maxHealth = 25
	self.health = self.maxHealth

	self.shurikens = {}
	self.shurikenTimeout = 0

	self.color = color
	self.pain = 0
end

function Player:updateWalkingAnimation(dt)
	if self.walking then
		self.anim:resume()
	else
		self.anim:pause()
		self.anim:gotoFrame(1)
	end
	self.anim:update(dt)
end

function Player:updateJumping(dt)
	if self.jumping then
		self.jumpTime = self.jumpTime + dt
		if self.jumpTime < self.maxJumpTime then
			self.yvel = -self.jumpSpeed
		end
	end
end

function Player:updateVelocity(dt)
	local xvel = self.walking and self.walkSpeed * self.dir or 0

	self.xvel = util.interpolate(self.xvel, xvel, dt * accel)
	self.yvel = self.yvel + gravity * dt
end

function Player:moveColliding(dt)
	local fx = self.x + self.xvel * dt
	local fy = self.y + self.yvel * dt

	local cols
	self.x, self.y, cols = self.world:move(self, fx, fy, playerFilter)
	return cols
end

function Player:updateShurikens(dt)
	util.map(self.shurikens, 'update', dt)

	for i = #self.shurikens, 1, -1 do
		local shuriken = self.shurikens[i]
		if not self.world:hasItem(shuriken) then
			table.remove(self.shurikens, i)
		end
	end

	self.shurikenTimeout = self.shurikenTimeout - dt
end

function Player:throwShuriken()
	if self.shurikenTimeout <= 0 then
		local x, y = self:getCenter()
		table.insert(self.shurikens, Shuriken(x + 10 * self.dir, y, self.dir, self.world, self))

		self.shurikenTimeout = 0.2

		Sounds.throw:stop()
		Sounds.throw:play()
	end
end

function Player:update(dt)
	self:updateWalkingAnimation(dt)
	self:updateJumping(dt)
	self:updateVelocity(dt)
	self:updateShurikens(dt)

	local cols = self:moveColliding(dt)

	self:resolveVelocity(cols)
	self:resolveJumps(cols)
end

function Player:resolveJumps(cols)
	for i = 1, #cols do
		if cols[i].normal.y < 0 then
			self.jumpTime = 0
			-- self.jumping = false
			return
		end
	end

	-- this happens if we found no ground collisions
	if not self.jumping then
		self.jumpTime = self.maxJumpTime
	end
end

function Player:setWalking(dir)
	dir = util.sign(dir)
	if dir ~= 0 then
		if self.dir ~= dir then
			self.anim:flipH()
		end
		self.dir = dir
		self.walking = true
	else
		self.walking = false
	end
end

function Player:jump()
	if not self.jumping then
		Sounds.jump:stop()
		Sounds.jump:play()
	end
	self.jumping = true
end

function Player:stopJumping()
	self.jumping = false
	self.jumpTime = self.maxJumpTime
end

function Player:damage(knockbackDir, n)
	if self.health > 0 then
		self.health = self.health - (n or 1)
	end
	if self.health <= 0 then
		signals.trigger('playerDied', self)
	end

	self.xvel = 300 * knockbackDir
	self.yvel = -150

	self.pain = 1
	flux.to(self, 0.3, { pain = 0 })

	if self.health > 0 then
		Sounds.hurt:stop()
		Sounds.hurt:play()
	else
		Sounds.died:stop()
		Sounds.died:play()
	end
end

function Player:draw()
	recolor:send('newColor', self.color)
	recolor:send('painDegree', self.pain)

	love.graphics.push("all")

	love.graphics.setShader(recolor)

	if self.health > 0 then
		self.anim:draw(Images.ninja, self.x, self.y)
	else
		love.graphics.draw(Images.ninjaDead, self.x, self.y)
	end

	local cx, cy = self:getCenter()
	local textWidth = Fonts.health:getWidth(self.health .. "")

	love.graphics.setColor(30, 30, 30)
	love.graphics.setFont(Fonts.health)
	love.graphics.print(self.health .. "", cx - textWidth / 2, self.y - 20)

	love.graphics.pop()
end

function Player:drawShurikens()
	util.map(self.shurikens, 'draw')
end
