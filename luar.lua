local function debug(text)
	local first = true
	for line in text:gmatch('[^\n]*') do
		if first then
			print(string.format([[echo -debug %%@lua: %s@]], line))
			first = false
		else
			print(string.format([[echo -debug %%@    %s@]], line))
		end
	end
end

local write = print

if arg[1] == "-debug" then
	write = debug
	table.remove(arg, 1)
end

kak = setmetatable({}, {
	__index = function(_, command)
		local words = { (command:gsub("_", "-")) }

		return function(...)
			for _, v in ipairs({...}) do
				words[#words + 1] = string.format("'%s'", v)
			end

			write(table.concat(words, " "))
		end
	end
})

args = function() return table.unpack(arg) end

local chunk = arg[#arg]
arg[0], arg[#arg] = nil, nil -- Hide file name and chunk

for i, v in ipairs(arg) do
	if v == "true" then
		arg[i] = true
	elseif v == "false" then
		arg[i] = false
	else
		arg[i] = tonumber(v) or v
	end
end

local function abort(action, err)
	err = err:match('%[string "luar"%]:(.+)')
	local message = "error while %s lua block:\n\nlua %%{%s}\n\nline %s\n"
	debug(message:format(action, chunk, err))
	os.exit(1)
end

local function check(success, ...)
	local result = {...}
	if success then return result end
	abort("executing", result[1])
end

local fn, err = load(chunk, "luar")
if not fn then abort("parsing", err) end

local result = check(pcall(fn))

if #result > 0 then
	print("echo " .. table.concat(result, "\t"))
end
