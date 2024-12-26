local luar = require 'luarmodule'

args, kak, addpackagepath = luar.args, luar.kak, luar.addpackagepath

local function abort(action, chunk, err)
    err = err:match('%[string "luar"%]:(.+)') or err
    local message = "error while %s lua block:\n\nlua %%{%s}\n\nlua:%s\n"
    luar.debug(message:format(action, chunk, err))
    print([[fail "'lua': check *debug* buffer"]])
    os.exit(1)
end

local function eval(chunk)
    local fn, err = load(chunk, "luar")
    if not fn then abort("parsing", chunk, err) end
    return fn()
end

luar.execute(eval, abort)
