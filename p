#shellcheck shell=bash

str.repr(){
    # echo "\"$(echo "$1" | sed s/\"/\\\\\"/g)\""
    # echo "\"${1//\"/\\\\\"}\""
    echo "\"${1//\"/\\\"}\""
}

str.trim(){
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

alias @p='if ! eval "$(p.__parse "$@")"; then return $?; fi <<<'

# TODO: avoid IFS influence on this function
p.__parse(){

    local i IFS=

    local varlist=()
    local typelist=()
    local vallist=()
    local deslist=()
    local deflist=()
    local oplist=()
    local choicelist=()

    while read -r line; do
        line="$(str.trim "$line")"
        [ "$line" = "" ] && continue

        # echo "$line" >&2
        # echo "!!!!!!!!!!!!!!!" >&2
     
        local operator="str"

        local all_arg_arr=() IFS=
        # all_arg_arr=( "$(str.arg "$line")" )
        IFS=$'\n' # different from '\n'
        # shellcheck disable=SC2207 # this rule is wrong
        all_arg_arr=( $(echo "$line" | xargs -n 1) )

        varname=${all_arg_arr[0]}

        if [[ $varname == *=* ]]; then
            local default="${varname#*=}"
            varname="${varname%%=*}"
            varlist+=("$varname")
            vallist+=("$default")
            deflist+=("$default")
        else
            varlist+=("$varname")
            vallist+=("")
            deflist+=("")
        fi

        IFS=$'\n'

        case "${all_arg_arr[1]}" in
        = | =~ | str | float | int) 
            oplist+=( "${all_arg_arr[1]}" )
            choicelist+=( "${all_arg_arr[*]}" )
            ;;
        *)
            description="${all_arg_arr[1]}"
            oplist+=( "${all_arg_arr[2]}" )
            choicelist+=( "${all_arg_arr[*]}" )
            ;;
        esac

        deslist+=("$description")
        typelist+=("argenv")
    done <<< "$(cat -)"

    # echo "--------"
    # echo "var list: ${varlist[@]}"
    # echo "val list: ${vallist[@]}"
    # echo "deslist: ${#deslist[@]}"
    # echo "dflist: ${deflist[@]}"
    # echo "op list: ${oplist[@]}"
    # echo "--------"

    # echo setup environment value >&2
    
    for (( i=0; i < ${#varlist[@]}; ++i )); do
        [[ ! "${typelist[i]}" = *env ]] && continue
        local name=${varlist[i]}
        vallist[i]=${!name}
    done
    
    # echo setup parameter value >&2
    while [ ! "$#" -eq 0 ]; do
        local parameter_name=$1
        shift
        if [[ "$parameter_name" == --* ]]; then
            parameter_name=${parameter_name:2}
            local sw=0
            for i in "${!varlist[@]}"; do
                [[ ! "${typelist[i]}" = arg* ]] && continue
                local _varname=${varlist[i]}
                if [ "$parameter_name" == "$_varname" ]; then
                    vallist[i]=$1
                    shift
                    sw=1
                    break
                fi
            done
            if [ $sw -eq 0 ]; then
                echo "ERROR: Unsupported parameter: --$parameter_name" >&2
                echo "return 1 2>/dev/null"
                return 0
            fi
        fi
    done
    

    # setup default value
    for i in $(seq "${#varlist[@]}"); do
        local name="${varlist[$i]}"
        local val="${vallist[$i]}"
        if [ "$val" == "" ]; then
            vallist[$i]=${deflist[$i]}
        fi
    done

    # using local value
    for i in $(seq "${#varlist[@]}"); do
        (( i=i-1 ))
        local name="${varlist[i]}"
        local val="${vallist[i]}"

        local op="${oplist[$i]}"
        local choice=( ${choicelist[i]} )

        case "$op" in
        =~)
            local match=0
            for c in "${choice[@]}"; do
                if [[ "$val" =~ $c ]]; then
                    match=1
                    break
                fi
            done

            if [ $match -eq 0 ]; then
                echo "echo ERROR: Value of $name: $val is not one of the regex set >&2"
                # echo "echo '$val' expected to be ${choice[@]} >&2"
                echo 'return 1 2>/dev/null'
                return 0;
            fi;;
        =)
            local match=0
            for c in "${choice[@]}"; do
                if [ "$c" == "$val" ]; then
                    match=1
                    break
                fi
            done

            if [ $match -eq 0 ]; then
                echo "echo ERROR: Value of $name is not one of the candidate set >&2"
                echo 'return 2 2>/dev/null'
                return 0
            fi ;;
        str | int)
            if [[ "$op" = "int" && ! "$val" =~ ^[\ \t]+[0-9]+[\ \t]+$ ]]; then
                echo "echo ERROR: Value of $name is integer >&2"
                echo 'return 1 2>/dev/null'
                return 1
            fi
            local match=0
            for c in "${choice[@]}"; do
                if [ "$c" = "$val" ]; then
                    match=1
                    break
                fi
            done

            if [ $match -eq 0 ]; then
                echo "echo ERROR: Value of $name is not one of the $op set >&2"
                echo 'return 1 2>/dev/null'
                return 0
            fi ;;
        *) [ "$op" == "" ] || echo ": TODO: $op" >&2
        ;;
        esac

        # TODO: notice the '' inside the string
        # echo "$val: $val" >&2
        echo "local $name"
        echo "$name=$(str.repr "$val")"
        # echo "local $name=$(str.repr "$val")"
        # echo "--------"
    done

}
