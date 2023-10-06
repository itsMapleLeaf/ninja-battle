local timer = {}
local tasks = {}

function timer.add(time, func, ...)
	table.insert(tasks, {
		currentTime = 0,
		targetTime = time,
		func = func,
		args = {...},
	})
end

function timer.update(dt)
	for i=#tasks, 1, -1 do
		local task = tasks[i]

		task.currentTime = task.currentTime + dt
		if task.currentTime > task.targetTime then
			task.func(unpack(task.args))
			table.remove(tasks, i)
		end
	end
end

function timer.clear()
	tasks = {}
end

return timer
