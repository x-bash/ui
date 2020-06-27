
<<TEST
> str.join "a" 1 2 3
1a2a3
> echo hi
hi
> echo world
world
TEST
# str.join(){
#     local sep=$1
#     shift 1
#     local bar
#     bar=$(printf "${sep}%s" "$@")
#     bar=${bar:${#sep}}
#     echo "$bar"
# }


<<TESTA
> str.join "a" 1 2 3
1a2a3
> echo hi
hi
> echo world
world1
TESTA
