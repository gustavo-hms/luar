declare-option -hidden str luar_path %sh{ dirname $kak_source }
define-command lua -params 1.. %{ eval %sh{
    lua $kak_opt_luar_path/luar.lua "$kak_quoted_$@"
} }

require-module lua

add-highlighter shared/kakrc/lua1 region -recurse '\{' '(^|\h)\K%?lua([\s{}\w%/"])* %\{' '\}' ref lua
add-highlighter shared/kakrc/lua2 region -recurse '\{' '(^|\h)\K%?lua([\s{}\w%/"])* %\(' '\)' ref lua
add-highlighter shared/kakrc/lua3 region -recurse '\{' '(^|\h)\K%?lua([\s{}\w%/"])* %\[' '\]' ref lua
add-highlighter shared/kakrc/lua4 region -recurse '\{' '(^|\h)\K%?lua([\s{}\w%/"])* %<' '>' ref lua
