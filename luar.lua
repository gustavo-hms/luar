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

local function compile(chunk)
	local fn, err = load(chunk, "luar")

	if fn then return fn end

	err = err:match('%[string "luar"%]:(.+)')
	local message = "error while parsing lua block:\n\nlua %%{%s}\n\nLine %s\n"
	debug(message:format(chunk, err))
	os.exit(1)
end

local lambda = arg[#arg]
-- Remove reference to file's name and to lambda's code
arg[0], arg[#arg] = nil, nil

for i, v in ipairs(arg) do
	if arg[i] == "true" then
		arg[i] = true
	elseif arg[i] == "false" then
		arg[i] = false
	else
		arg[i] = tonumber(v) or v
	end
end

local fn = compile(lambda)
local result = { fn() }
if #result > 0 then
	print("echo " .. table.concat(result, "\t"))
end
