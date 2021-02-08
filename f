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
    local a='a,b,c,'

    while read  -r i; do
        echo "--- $i"

    done <<A
$a
A
}

f2

ff1(){
    for i in `seq 100`; do
        echo "abcc" | awk '$0=="abcc"{ print $0; }'  >/dev/null
    done
}

ff2(){
    for i in `seq 100`; do
        echo "abcc" | sed -n /abcc/p >/dev/null
    done
}

ff3(){
    for i in `seq 100`; do
        echo "abcc" | awk '$0~"^abc"{ print $0; }'  >/dev/null
    done
}

ff4(){
    for i in `seq 100`; do
        echo "abcc" | sed -n /^abc/p >/dev/null
    done
}

ff5(){
    for i in `seq 100`; do
        str_regex "abcc" "^abc"
    done
}

ff6(){
    for i in `seq 100`; do
        [[ "abcc" =~ ^abc ]]
    done
}


ff6(){
    for i in `seq 100`; do
        echo "abcc" | grep "abc" && echo hi
    done
}


ff7(){
    while read -r line; do
        echo "-- $line"
    done <<A
$(seq 100)
A
}

ff8(){
    for i in $(seq 100); do
        echo "-- $i"
    done
}


f9(){
    for i in $(seq 100); do eval echo "$i"; done
}


