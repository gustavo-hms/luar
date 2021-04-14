# Luar

Luar is a minimalist plugin to script [Kakoune](http://kakoune.org/) using [Lua](https://www.lua.org/). It's not designed to expose Kakoune's internals like [Vis](https://github.com/martanne/vis) or [Neovim](https://neovim.io/) do. Instead, it's conceived with Kakoune's extension model in mind. It does so by defining a sole command (`lua`) which can execute whatever string is passed to it in an external `lua` interpreter. By doing so, it can act as a complement for the `%sh{}` expansion when you need to run some logic inside Kakoune.

## Usage

First of all, require the provided module:

```kak
require-module luar
```

The `luar` module exports a `lua` command, which executes the code passed to it in an external `lua` interpreter. The code is interpreted as the body of an anonymous function, and whatever this anonymous function returns replaces the current selections. So, the following code:

```lua
lua %{
    return "Olá!"
}
```
replaces your selections with `Olá!`.

In the same vein, if you have, say, three selections, the code:

```lua
lua %{
    return 17, 19, 23
}
```

replaces each selection with `17`, `19` and `23` respectivelly. The same can be achieved by returning a single table with three elements:


```lua
lua %{
    return {17, 19, 23}
}
```

The two forms are equivalent.

This anonymous function can take arguments by passing values before the `%{}` block:

```lua
lua 17 19 %{
    return arg[1] + arg[2]
}
```

The above code will echo `36` in the status line. As you can see, the arguments can be accessed with the `arg` table.

As a convenience, you can use the provided `args` function to name your arguments:

```lua
lua 17 19 %{
    local first, second = args()
    return second - first
}
```

Since Kakoune does not process expansions inside these `lua %{}` blocks, you need to pass expansions as arguments if you need to inspect Kakoune's state:

```lua
lua %val{client} %{
    local client = args()
    return string.format("I'm client “%s”", client)
}
```

Finally, you can run all commands defined in Kakoune (including third party ones) from `lua` code using the provided `kak` module:

```lua
lua %{
    kak.set_register("/", "Search this!")
    kak.execute_keys('%s<ret>cSearch that!<esc>')
}
```
As you can see, hyphens are replaced by underscores in command names.

## External modules

Since Lua modules are just plain tables and `require` is just a simple function, you can import modules everywhere in your program, not just at the beginning of a file. In particular, you can import external modules inside the `:lua` command. For instance, if you need to parse the contents of a file, you can use the elegant [LPeg](http://www.inf.puc-rio.br/~roberto/lpeg/) library:

```lua
lua %val{buffile} %{
    local lpeg = require "lpeg"
    
    local function parse(file)
        -- do the lpeg's magic here
    end
    
    local tree = parse(arg[1])
    -- ...
}
```

You can also use this functionality to split your plugin into separate modules and use `:lua` to glue them together.

## Some examples
The following examples are for didactic purposes. There are other ways to achieve the same results.

Suppose you want to execute `ctags-update-tags` whenever you write to a file, but only if there's already a `tags` file in the current directory. Using `:lua` you can write the following lines to your `kakrc`:

```lua
hook global BufWritePost .* %{
    lua %{
        if io.open("tags") then kak.ctags_update_tags() end
    }
}
```

Now suppose you want to define a mapping to toggle the highlight of search patterns in the current window when you press `F2`. To achieve that, you can do something like this:

```lua
declare-option -hidden bool highlight_search_on false

define-command highlight-search-toggle %{
    lua %opt{highlight_search_on} %{
        local is_on = args()

        if is_on then
            kak.remove_highlighter("window/highlight-search")
        else
            kak.add_highlighter("window/highlight-search", "dynregex", "%reg{/}", "0:default,+ub")
        end

        kak.set_option("window", "highlight_search_on", not is_on)
    }
}

map global normal <F2> ': highlight-search-toggle<ret>'
```

You can find more examples [searching Github by topic](https://github.com/search?q=topic%3Akakoune+topic%3Aplugin+topic%3Alua).

## Installation

You must have a `lua` interpreter installed on your system. Then you can add the following line to your `kakrc` (supposing you use [plug.kak](https://github.com/robertmeta/plug.kak)):

```kak
plug "gustavo-hms/luar" %{
    require-module luar
}
```
