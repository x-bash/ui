#shellcheck shell=bash

# param.__parse '
#     argenv[org] "Provide organization"
#     arg[repo] "repo name" =~ [:alpha:][[:alnum:]-_]+
#     arg[access] = public private inner-source
# '

<<A
@p '
    org "Provide organization" =~ [abc]+ [[:alnum:]]+
    repo "Repository name"
    access=public = public private inner-source
'
A

p.__parse(){

    local ARG_NUM=$(( ${#@} ))
    local ARG_NUM_1=$(( ${#@} - 1 ))
    local ARGS=("${@:1:$ARG_NUM_1}")

    local STR="${@:$ARG_NUM}"

    local varlist=()
    local deslist=()
    local deflist=()
    local oplist=()
    local choicelist=()

    while read line; do
        # line="$(str.trim "$line")"

        if [ "$line" == "" ]; then
            continue
        fi

        echo "--- $line"

        local sw=0
        local operator="str"
        local declaration_block=()
        local choice_block=()
        while read i; do
            if [ $sw -eq 0 ]; then
                declaration_block+=($i)
            else
                choice_block+=($i)
                continue
            fi

            case "$i" in
            = | =~ | str | float | int) 
                sw=1
                operator=$i
                ;;
            esac

        done <<< "$(echo "$line" | xargs -n 1)"

        # echo "${declaration_block[@]}"

        local varname="${declaration_block[0]}" description=""
        if [ "${#declaration_block[@]}" -eq 3 ]; then
            description=${declaration_block[1]}
        fi

        deslist+=("$description")
        
        if [[ $varname == *=* ]]; then
            local default="${varname#*=}"
            varname="${varname%%=*}"
            varlist+=($varname)
            deflist+=($default)
        else
            varlist+=($varname)
            deflist+=("")
        fi

        oplist+=("$operator")
        local IFS=$'\n'
        choicelist+=( "${choice_block[*]}" )
    done <<< "$STR"

    if [ "$_X_BASH_PARAM_TYPE" = "arg" ]; then
        for param in "${ARGS[@]}"; do
            if 
        done

        for i in "$(seq ${#varlist[@]})"; do
            echo "local $i=\${$i:-${deflist[$i]}}"
        done
    fi

    if [ "$_X_BASH_PARAM_TYPE" = "env" ]; then
        for i in "$(seq ${#varlist[@]})"; do
            echo "local $i=\${$i:-${deflist[$i]}}"
        done
    fi




    


    done

    echo "${varlist[@]}"
    echo "${#deslist[@]}"
    echo "${deflist[@]}"
    echo "${oplist[@]}"

}

p.__parse '
    org "Provide organization" =~ [abc]+ [[:alnum:]]+
    repo "Repository name"
    access=public = public private inner-source
'

