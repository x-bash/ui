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

PARAM_NEWLINE_TR="$(printf "\001")"

param_default_set(){
    local O="${O:-default}"

    local s
    s="$(awk \
        -v key="$(printf "%s" "${1:?Provide key}" | tr "\n" "${PARAM_NEWLINE_TR}")" \
        -v val="$(printf "%s" "${2:?Provide value}" | tr "\n" "${PARAM_NEWLINE_TR}")" '

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
        print "here" >"/dev/stderr"
        print key
        print val
    }
}

' <<A
$(eval printf "%s" \"\$PARAM_DEFAULT_${O}\")
A
)"
    echo "$s"
    eval "PARAM_DEFAULT_$O=\"\$s\""
}


param_default_get(){
    awk -v key="$(printf "%s" "${1:?Provide key}" | tr "\n" "${PARAM_NEWLINE_TR}")" '

NR%2==1{
    if ($0 == key) {
        getline
        print $0
        exit 0
    }
}
END { exit 1; }
' <<A
$(eval printf "%s" \"\$PARAM_DEFAULT_${O:-default}\")
A
}

param_default_list(){
    eval printf "%s" \"\$PARAM_DEFAULT_${O:-default}\" | awk 'NR%2==1{
        keyline=$0
    }
    NR%2==0{
        gsub("\001", "\n", $0)
        print keyline "=" $0
    }'
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
