# shellcheck shell=sh
# shellcheck disable=SC2039

# author:       Li Junhao           edwin.jh.lee@gmail.com    edwinjhlee.github.io
# maintainer:   Li Junhao

# shellcheck disable=SC2142
alias param='{ eval "$(_param_main "$@")"; }'


_param_main(){
    local IFS
    IFS="$(printf "\005")"

    local param_definition
    param_definition="$(cat)"

    local default
    local s=""

    if default="$(awk '{ if ($1 == "default") { printf("%s", $2); exit 0; } else { exit 1; } }' - <<A
$param_definition
A
)"; then
        s=$(eval printf "%s" \"\$PARAM_DEFAULT_${default}\" | tr "\n" "$(printf "\006")")
    fi

    awk -v ARGSTR="$*"  -v ARG_SEP="$IFS" \
        -v scope_str="$s" \
        -v O="${O}" -f param.awk - <<A
$param_definition
A
}

# Because awk split bug in unprintable seperators. We have to encode the string by transposing the newline character
PARAM_DEFAULT_VAR_PREFIX=___X_CMD_X_BASH_PARAM_DEFAULT

param_default_clear(){
    local O="${1:?Provide default scope}"
    eval "${PARAM_DEFAULT_VAR_PREFIX}_$O=\"\""
}

PARAM_NEWLINE_TR="$(printf "\001")"

param_default_set(){
    local O="${1:?Provide default scope}"

    local s
    s="$(awk \
        -v key="$(printf "%s" "${2:?Provide key}" | tr "\n" "${PARAM_NEWLINE_TR}")" \
        -v val="$(printf "%s" "${3:?Provide value}" | tr "\n" "${PARAM_NEWLINE_TR}")" '

BEGIN {
    RS="\n"
    is_keyline = 0
    sw = 1
}

{
    if (is_keyline == 0) {
        keyline=$0
    } else {
        if (keyline == key) {
            print key
            print val
            sw = 0
        } else {
            print keyline
            print $0
        }
        
    }
    is_keyline = 1 - is_keyline
}

END {
    if (sw == 1) {
        print key
        print val
    }
}

' <<A
$(eval printf "%s" \"\$${PARAM_DEFAULT_VAR_PREFIX}_${O}\")
A
)"
    eval "PARAM_DEFAULT_$O=\"\$s\""
}


param_default_get(){
    awk -v key="$(printf "%s" "${2:?Provide key}" | tr "\n" "${PARAM_NEWLINE_TR}")" '

NR%2==1{
    if ($0 == key) {
        getline
        print $0
        exit 0
    }
}
END { exit 1; }
' <<A
$(eval printf "%s" \"\$${PARAM_DEFAULT_VAR_PREFIX}_${1:?Provide default scope}\")
A
}

param_default_list(){
    eval printf "%s" \"\$${PARAM_DEFAULT_VAR_PREFIX}_${1:?Provide default scope}\" | awk 'NR%2==1{
        keyline=$0
    }
    NR%2==0{
        gsub("\001", "\n", $0)
        print keyline "=" $0
    }'
}

param_default_set GITEE_OBJECT_NAME repo xk1

w(){
    w.param <<A
    default     GITEE_${O:?Provide object name}
    --repo      -r  "Provide repo name"         =~      [A-Za-z0-9]+
    --user=el   -u  "Provide user name"         =~      [A-Za-z0-9]+
    --access    -a  "Access Priviledge"         =       public private
    --verbose   -v  "Display in verbose mode"   =FLAG
A

    echo -e "\n-----"

    echo "repo: $repo"
    echo "user: $user"
    echo "verbose: $verbose"

    echo "$HELP_DOC"
}

# w --repo hi
O=OBJECT_NAME w --access public

