# luar

Luar is a minimalist plugin to execute [Lua](https://www.lua.org/) code from within [Kakoune](http://kakoune.org/). It's not designed to expose Kakoune's internals like [Vis](https://github.com/martanne/vis) or [Neovim](https://neovim.io/) do. Instead, it's conceived with Kakoune's extension model in mind. It does so by defining a sole command (`lua`) which can execute whathever string is passed to it in an external `lua` interpreter. By doing so, it can act as a complement for the `%sh{}` expansion when you need to run some logic inside Kakoune.

## Usage

The `lua` command executes the code passed to it in an external `lua` interpreter. The code is interpreted as the body of an anonymous function. So, the following code:

```lua
lua %{
	return "Olá!"
}
```
echoes `Olá!` in the status line.

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

Since Kakoune does not parse expansions inside this `lua %{}` blocks, this is the way you can inspect Kakoune's state:

```lua
lua %val{client} %{
	local client = args()
	return string.format("I'm client “%s”", client)
}
```

Finally, you can run Kakoune's commands from `lua` using the provided `kak` module:

```lua
lua %{
	kak.set_register("/", "Search this!")
}
```
As you can see, hyphens are replaced with underscores in command names.

Switches can be passed as a table in the last argument of a command:

```lua
lua %{
	kak.info("Olha aqui!", { anchor = "10.5", style = "above", markup = true })
}
```
