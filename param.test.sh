#! /usr/bin/env 


# shellcheck disable=SC2142
alias param='_param "$@"'

_param(){
    eval "$(_param_main "$@")"
}

# dict_key  dict_value
_param_main(){
    echo "$SCOPE" >/dev/stderr
    local IFS="$(printf "\005")"
    awk -v ARGSTR="$*" -v ARG_SEP="$IFS" -v O="${O}" -f param.awk -
}

# Because awk split bug in unprintable seperators. We have to encode the string by transposing the newline character

PARAM_DEFAULT_DICT_KV_SEP="$(printf "\001")"
PARAM_DEFAULT_DICT_LINE_SEP="$(printf "\002")"

param_default_clear(){
    local O="${O:-default}"
    eval "PARAM_DEFAULT_$O=\"\""
}

# BEGIN {  ORS=RS; sw = 1;  }
# {
#     if ($0 != "") {
#         print "<" $0 ">" >"/dev/stderr"
#         if ($1 == key) {
#             print key FS value
#             sw = 0
#         } else {
#             print $1 FS $2
#         }
#     }
# }
# END { if (1 == sw) print key FS value; print key FS value; }

# There is a common bug in awk.
# awk 'BEGIN{ RS="\034"; } { print length($0); print split($0, arr, "\t");  print arr[2]; }' <<<"a"
# docker run -i centos awk 'BEGIN{ RS="\034"; } { gsub("\n$", "", $0); print length($0); print split($0, arr, "\t");  print arr[2]; }' <<<"aa"

# awk '{ a="\n"; print split(a, arr, "\033"); }'

param_default_set(){
    local O="${O:-default}"
    local tt="$(eval printf "%s" "\$PARAM_DEFAULT_$O")"

    # change \n to \001
    # split key - value to 

    echo "ffffff"
    # eval "PARAM_DEFAULT_$O"="\${PARAM_DEFAULT_$O}${PARAM_DEFAULT_DICT_LINE_SEP}${1:?Provide key}${PARAM_DEFAULT_DICT_KV_SEP}${2:?Provide value}"
    local s="$(awk -v key="${1:?Provide key}" -v value="${2?Provide value}" -v KV_SEP="${PARAM_DEFAULT_DICT_KV_SEP}" -v LINE_SEP="${PARAM_DEFAULT_DICT_LINE_SEP}" '

BEGIN {  
    print "hello" >"/dev/stderr"; 
    RS="\034"; sw = 1;  
}

{
    gsub("\n$", "", $0)
    arr_len = split($0, arr, LINE_SEP)
    key_val = arr[1]

    sw = 1
    ret = ""
    LINE_SEP_ACTUAL = ""
    for (i=2; i<=arr_len; ++i) {
        kv = arr[i]
        split(kv, kvarr, KV_SEP)
        if (kvarr[1] == key) {
            ret = ret LINE_SEP_ACTUAL key KV_SEP value
            sw = 0
        } else {
            ret = ret LINE_SEP_ACTUAL kvarr[1] KV_SEP kvarr[2]
        }
        LINE_SEP_ACTUAL = LINE_SEP
    }
    if (sw == 1) ret = ret LINE_SEP_ACTUAL key KV_SEP value
    printf("%s", ret)
}
' <<A
${1:?Provide key}${PARAM_DEFAULT_DICT_KV_SEP}${2?Provide value}${PARAM_DEFAULT_DICT_LINE_SEP}$tt
A
)"
    eval "PARAM_DEFAULT_$O=\"\$s\""
}


param_default_get(){
    local O="${O:-default}"
    local s="$(eval echo "\$PARAM_DEFAULT_${O}")"

    awk -v key="${1:?Provide key}" -v KV_SEP="${PARAM_DEFAULT_DICT_KV_SEP}" -v LINE_SEP="${PARAM_DEFAULT_DICT_LINE_SEP}" '

BEGIN{  RS="\034";  }    
    
{
    arr_len = split($0, arr, LINE_SEP)
    for (i=1; i<=arr_len; ++i) {
        kv = arr[i]
        split(kv, kvarr, KV_SEP)
        if (kvarr[1] == key) {
            print kvarr[2]
            exit 0
        }
    }
    exit 1
}' <<A
$(eval echo "\$PARAM_DEFAULT_${O}")
A
}

param_default_list(){
    local O="${O:-default}"

    # eval echo "\$PARAM_DEFAULT_${O}" | tr "${PARAM_DEFAULT_DICT_LINE_SEP}" " "
    eval echo "\$PARAM_DEFAULT_${O}" | tr "${PARAM_DEFAULT_DICT_KV_SEP}${PARAM_DEFAULT_DICT_LINE_SEP}" "=\n"
}

w(){
    SCOPE=SCOPE123 param <<A
    --repo  -r  "Provide repo name"     =~  [A-Za-z0-9]+
    --user=el  -u  "Provide user name"     =~  [A-Za-z0-9]+
    --access   "Access Priviledge"      =  pulbic private
    --verbose  -v  "Display in verbose mode"    =FLAG
A

    echo -e "\n\n\n-----"

    echo "repo: $repo"
    echo "user: $user"
    echo "verbose: $verbose"

    echo "$HELP_DOC"
}

# w --repo hi
w --repo hi --access ss
