
w(){
    local abc
    echo "here: $abc"
}

abc=4 w
abc=4 w

@env.set abc 4
@env.set abc 5

abc=100 w
abc=500 w

work -q 
