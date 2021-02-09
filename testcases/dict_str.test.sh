

xrc std/test

. dict_str

test_push(){
    dict_make a
    O=a dict_push 1 2 3 4 5 6
    @assert "$(O=a dict_get 1)" = 2
    @assert "$(O=a dict_get 5)" = 6
}

@run test_push

