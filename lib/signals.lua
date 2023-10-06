local signals = {}
local registry = {}

function signals.register(id, func)
	if not registry[id] then
		registry[id] = {}
	end
	table.insert(registry[id], func)
end

function signals.trigger(id, ...)
	if registry[id] then
		for i=1, #registry[id] do
			registry[id][i](...)
		end
	end
end

function signals.clear()
	registry = {}
end

return signals
