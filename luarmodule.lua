local function debug(text)
    local first = true

    for line in text:gmatch('[^\n]*') do
        if first then
            print(string.format([[echo -debug %%{luar: %s}]], line))
            first = false
        else
            print(string.format([[echo -debug %%{    %s}]], line))
        end
    end
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

local function execute(fn, abort)
    local chunk = parseargs()
    local results = { pcall(fn, chunk) }
    if not results[1] then abort("executing", chunk, results[2]) end

    if #results > 1 then
        table.remove(results, 1)
        -- Allow returning either many values or a single table
        if type(results[1]) == "table" then results = results[1] end

        local command = string.format([[
            evaluate-commands -save-regs dquote %%{
                set-register dquote %s
                execute-keys R
            }
        ]], quote(results))
        print(command)
    end
end

return {
    args           = args,
    addpackagepath = addpackagepath,
    kak            = kak,
    execute        = execute,
    debug          = debug,
}
