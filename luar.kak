declare-option -hidden str luar_path %sh{ dirname "$kak_source" }

declare-option -docstring "The Lua interpreter used to execute Lua code" str luar_interpreter lua

provide-module luar %#
    define-command lua -params 1.. -docstring %{
        lua [<switches>] [args...] code: Execute provided Lua code as an anonymous function whose arguments are the args list.
        Switches:
            -debug Print Kakoune commands to *debug* buffer instead of executing them.
    } %{
        evaluate-commands %sh{
            export LUA_PATH="$kak_opt_luar_path/?.lua;$LUA_PATH"
            exec "$kak_opt_luar_interpreter" "$kak_opt_luar_path/luar.lua" "$@"
        }
    }

    define-command fennel -params 1.. -docstring %{
        fennel [<switches>] [args...] code: Execute provided Fennel code as an anonymous function whose arguments are the args list.
        Switches:
            -debug Print Kakoune commands to *debug* buffer instead of executing them.
    } %{
        evaluate-commands %sh{
            export LUA_PATH="$kak_opt_luar_path/?.lua;$LUA_PATH"
            exec fennel "$kak_opt_luar_path/luar.fnl" "$@"
        }
    }

    require-module kak
    require-module lua
    require-module fennel

    add-highlighter shared/kakrc/code/lua regex (?:\s|\A)\Klua(?:(?=\s)|\z) 0:keyword
    add-highlighter shared/kakrc/lua1 region -recurse '\{' '(^|\h)lua([\s{}\w%/$-|''"])* %\{\K' '\}' ref lua
    add-highlighter shared/kakrc/lua2 region -recurse '\(' '(^|\h)lua([\s{}\w%/$-|''"])* %\(\K' '\)' ref lua
    add-highlighter shared/kakrc/lua3 region -recurse '\[' '(^|\h)lua([\s{}\w%/$-|''"])* %\[\K' '\]' ref lua
    add-highlighter shared/kakrc/lua4 region -recurse '<' '(^|\h)lua([\s{}\w%/$-|''"])* %<\K' '>' ref lua

    add-highlighter shared/kakrc/code/fennel regex (?:\s|\A)\Kfennel(?:(?=\s)|\z) 0:keyword
    add-highlighter shared/kakrc/fennel1 region -recurse '\{' '(^|\h)fennel([\s{}\w%/$-|''"])* %\{\K' '\}' ref fennel
    add-highlighter shared/kakrc/fennel2 region -recurse '\(' '(^|\h)fennel([\s{}\w%/$-|''"])* %\(\K' '\)' ref fennel
    add-highlighter shared/kakrc/fennel3 region -recurse '\[' '(^|\h)fennel([\s{}\w%/$-|''"])* %\[\K' '\]' ref fennel
    add-highlighter shared/kakrc/fennel4 region -recurse '<' '(^|\h)fennel([\s{}\w%/$-|''"])* %<\K' '>' ref fennel
#
