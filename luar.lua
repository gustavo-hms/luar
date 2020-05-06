local function switches(t)
	local switches_ = {}

	for switch, value in pairs(t) do
    	if value == true then
        	switches_[#switches_ + 1] = "-" .. switch
    	else
        	switches_[#switches_ + 1] = string.format("-%s '%s'", switch, value)
    	end
	end

	return table.concat(switches_, " ")
end

kak = setmetatable({}, {
    __index = function(_, command)
		local words = { (command:gsub("_", "-")) }
    	return function(...)
    		local args = {...}
    		local last = args[#args]

    		if type(last) == "table" then
        		words[2] = switches(last)
        		args[#args] = nil
    		end

    		for _, v in ipairs(args) do
        		words[#words + 1] = string.format("'%s'", v)
    		end

    		print(table.concat(words, " "))
    	end
    end
})

args = function() return table.unpack(arg) end

local function compile(chunk)
	local fn, err = load(chunk, "luar")

	if fn then return fn end

	err = err:match('%[string "luar"%]:(.+)')
	local message = "Error while parsing lua block\nlua %%{%s}\nLine %s\n"
	io.stderr:write(message:format(chunk, err))
	os.exit(1)
end

local lambda = arg[#arg]
-- Remove reference to file's name and to lambda's code
arg[0], arg[#arg] = nil, nil

for i, v in ipairs(arg) do
    arg[i] = tonumber(v) or v
end

local fn = compile(lambda)
local result = { fn() }
if #result > 0 then
    print("echo " .. table.concat(result, "\t"))
end
