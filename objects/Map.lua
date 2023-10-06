MapBlock = GameObject:extend()

function MapBlock:draw()
	love.graphics.draw(Images.ground, self.x, self.y)
end


Map = Object:extend()

local blockSize = 25

function Map:new(world, mapdata)
	self.width = #mapdata[1] * blockSize
	self.height = #mapdata * blockSize
	self.mapBlocks = {}
	self.spawns = {}

	for y=1, #mapdata do
		local line = mapdata[y]
		for x=1, #line do
			local char = line:sub(x,x)
			local bx = (x - 1) * blockSize
			local by = (y - 1) * blockSize

			if char == '#' then
				table.insert(self.mapBlocks, MapBlock(bx, by, blockSize, blockSize, world))

			elseif char == '@' then
				table.insert(self.spawns, {
					x = bx + blockSize/2,
					y = by + blockSize/2,
				})
			end
		end
	end
end

function Map:getRect()
	return 0, 0, self.width, self.height
end
