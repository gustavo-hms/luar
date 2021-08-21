local function debug(text)
    local first = true

    for line in text:gmatch('[^\n]*') do
        if first then
            print(string.format([[echo -debug %%{lua: %s}]], line))
            first = false
        else
            print(string.format([[echo -debug %%{    %s}]], line))
        end
    end
end

local function abort(action, chunk, err)
    err = err:match('%[string "luar"%]:(.+)') or err
    local message = "error while %s lua block:\n\nlua %%{%s}\n\nline %s\n"
    debug(message:format(action, chunk, err))
    kak.fail("'lua': check *debug* buffer")
    os.exit(1)
end

local function quote(words)
    for i, v in ipairs(words) do
        words[i] = string.format("%%☾%s☾", v)
    end

    return table.concat(words, " ")
end

local function args()
    local unpack = unpack or table.unpack
    return unpack(arg)
end

local function addpackagepath(path)
    package.path = string.format("%s/?.lua;%s", path, package.path)
end

local write = print

local kak = setmetatable({}, {
    __index = function(t, command)
        local name = command:gsub("_", "-")
        t[command] = function(...)
            write(name .. " " .. quote {...})
        end

        return t[command]
    end
})

local function parseargs()
    local chunk = arg[#arg]
    arg[0], arg[#arg] = nil, nil -- Hide file name and chunk
    local debug_flag

    for i, v in ipairs(arg) do
        if v == "-debug" then
            write = debug
            debug_flag = i

        elseif v == "true" then
            arg[i] = true

        elseif v == "false" then
            arg[i] = false

        else
            arg[i] = tonumber(v) or v
        end
    end

    if debug_flag then
        table.remove(arg, debug_flag)
    end

    return chunk
end

return {
    args           = args,
    addpackagepath = addpackagepath,
    kak            = kak,
    parseargs      = parseargs,
}
