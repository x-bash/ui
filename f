f(){
    local IFS=$'\n'
    # local IFS=
    a='a /dev/null
b
    '

    for i in $a; do
        echo "--- $i"
    done
}

f



f1(){
    local IFS=
    # local IFS=
    local a='/dev/null
/dev/abc
c /dev
b'

    while read -r i; do
        echo "--- $i"

    done <<A
$a
A
}

f1


f2(){
    local IFS=,
    # local IFS=
    local a='a,b,c'

    while read -r i; do
        echo "--- $i"

    done <<A
$a
A
}

f2
