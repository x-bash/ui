json.extract(){
    if [ "$#" -eq 0 ]; then
        return 1
    fi

    local line str="*\[\"$1\""
    shift
    for i in "$@"; do
        if [[ "$i" =~ [0-9]+ ]]; then
            str+=",$i"
            continue
        fi
        str+=",\"$i\""
    done
    str+="\]*"

    # echo "$str"

    local s
    while read -r line; do
        if [[ "$line" == $str ]]; then
            s="${line#$str}"
            echo "${s:1}"
        fi
    done <<<"$(awk -f "$(xrc.which awk/JSON.awk)" a.json)"
}








: <<<A

json.query \
    -p '
    .a.b=3
    .c.d=4
'   -p '
    .a.b=6
'   -a '
    _("a", "b")
    _set("a", "b", 3)
    _json()
'

json.query -o yml
json.query -o xml
json.query -o json
json.query -o toml



A

