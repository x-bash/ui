

# Anaylysis
# analysis the code
# 1. generate help
# 2. parsing the arguments
# 3. generate the flag

# param '
#     title "Provide title"
#     text "Provide text"
#     orientation=0 "button orientation 0 = vertical, 1=horizontal, default is 0" int 0 1
#     singleTitle "Provide singtalTitle"
#     singleURL "Provide url to jump"
# '

# 5ms

function f(text){
    # print line
    gsub("^\n+|\n+$", "", text)

    gsub("[\ \t\v\b]+\n[\ \t\v\b]+", "\n", text)
    # print line
    gsub(/\\\\/, "\001", text)
    gsub(/\\"/, "\002", text)
    gsub(/\\ /, "\003", text)

    gsub(/"[^"]*"|[^ \t\n\v\b]+/, TOKEN_SEP "&", text)
    gsub("\001", /\\\\/, text)
    gsub("\002", /\\"/, text)   # "
    gsub("\003", /\\ /, text)

    gsub("[ \t\v\b]+" TOKEN_SEP, TOKEN_SEP, text)
    return text
}


function parse_item_to_generate_help(line,      token_arr, token_arr_len, ret, name, name_idx, i, default, desc, op) {
    token_arr_len = split(line, token_arr, TOKEN_SEP)

    for (name_idx=2; name_idx <= token_arr_len; ++name_idx) {
        name = token_arr[name_idx]
        # gsub("(^ +)|( +$)", "", name)
        if (! match(name, "(^--?[A-Za-z_0-9]+$)|(^--?[A-Za-z_0-9]+=)")) {
            break
        }
    }
    name_idx --

    name = token_arr[2]
    gsub("=.+$", "", name)
    if (name == token_arr[2])    default = null
    else {
        default = token_arr[2]
        gsub("^[^=]+=", "", default)
    }

    desc = token_arr[name_idx+1];     op = token_arr[name_idx+2]

    if (op == "=FLAG") {
        for (i=2; i<=name_idx; ++i){
            arg_has_value[token_arr[i]] = false
        }
    } else {
        for (i=2; i<=name_idx; ++i){
            arg_has_value[token_arr[i]] = true
        }
    }

    # TODO: make it better
    ret = "    " name "\t"  default "\t"      desc    "\t"    op
    
    if (name_idx > 2) {
        ret = ret "\n        alias:"
        for (i=3; i<=name_idx; ++i){
            ret = ret " " token_arr[i]
        }
    }

    return ret
}

function assert_arr_eq(value, sep, token_arr_len, token_arr,    j, value_arr_len, value_arr, sw){
    value_arr_len = split(value, value_arr, sep)
    for (j=1; j<=value_arr_len; ++j) {
        sw = false
        for (idx=5; idx<=token_arr_len; ++idx) {
            if (match(value_arr[j], token_arr[idx])) {
                sw = true
                break
            }
        }
        if ( sw == false) {
            # show help
            exit_print(1)
        }
    }
}

function quote_string(str){
    gsub(/\"/, "\\\"", str)
    return "\"" str "\""
}


function append_code(code){
    CODE=CODE "\n" code
}

function error(s){
    print s > "/dev/stderr"
}

function print_helpdoc(){
    print "----------------------" > "/dev/stderr"
    print HELP_DOC > "/dev/stderr"
}

function exit_print(code){
    print "return " code " 2>/dev/null || exit " code
    exit code
}

function parse_item(line,   
    token_arr_len, token_arr, 
    value, name, default, idx, i, j, sw, value_arr, value_arr_len, sep){
   
    token_arr_len = split(line, token_arr, TOKEN_SEP)
    value = null

    for (name_idx=2; name_idx <= token_arr_len; ++name_idx) {
        name = token_arr[name_idx]
        if (! match(name, "(^--?[A-Za-z_0-9]+$)|(^--?[A-Za-z_0-9]+=)")) break
    }
    name_idx --

    name = token_arr[2]
    gsub("=.+$", "", name)
    if (name == token_arr[2])    default = null
    else {
        default = token_arr[2]
        gsub("^[^=]+=", "", default)
    }
    gsub("^--?", "", name)

    value = null
    for (i=2; i<=name_idx; ++i){
        idx = token_arr[i]   # idx is temp variable, here meaning _name
        if (idx in arg_map) {
            value = arg_map[idx]
            break
        }
    }

    desc = token_arr[name_idx + 1]
    op = token_arr[name_idx + 2]

    if (op == "=FLAG") {
        if (value == null) {
            append_code( "local " name "= " " 2>/dev/null" )
        } else {
            append_code( "local " name "=true" " 2>/dev/null" )
        }
        return true
    }


    if (value == null) {
        # TODO: get value from default scope
        if (name in default_scope) {
            value = default_scope[name]
        } else {
            if (default == null) {
                error("Arg: " name " SHOULD NOT be null.")
                print_helpdoc()
                exit_print(1)
            } else {
                value = default
            }
        }
    }

    if (op == "") {
        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
        return true
    }

    if (op == "=int") {
        if (! match(value, /[+-]?[0-9]+/) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            error( "Arg: [" name "] value is [" value "]\nIs NOT an integer." )
            print_helpdoc()
            exit_print(1)
        }
        append_code( "local " name "=" value " 2>/dev/null" )
    } else if (op == "=") {
        sw = false
        for (idx=5; idx<=token_arr_len; ++idx) {
            if (value == token_arr[idx]) {
                sw = true
                break
            }
        }
        if (sw == false) {
            gsub(TOKEN_SEP, "\n" line)
            error( "Arg: [" name "] value is [" value "]\nFail to match any candidates:\n" line )
            print_helpdoc()
            exit_print(1)
        }

        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    }else if (op == "=~") {
        sw = false
        for (idx=5; idx<=token_arr_len; ++idx) {
            if (match(value, "^"token_arr[idx]"$")) {
                sw = true
                break
            }
        }
        if (sw == false) {
            gsub(TOKEN_SEP, "\n" line)
            error( "Arg: [" name "] value is [" value "]\nFail to match any candidates:\n" line )
            print_helpdoc()
            exit_print(1)
        }

        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    } else if (op ~ /^=.$/) {
        sep = substr(op, 2, 1)
        assert_arr_eq(value, sep, token_arr_en, token_arr)
        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    } else if (op ~ /^=[.]$/) {
        sep = substr(op, 3, 1)
        assert_arr_eq(value, sep, token_arr_en, token_arr)
        gsub(sep, "\034", value)    # how to do that?
        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    } else if (op ~ /^=~.$/) {
        sep = substr(op, 3, 1)
        assert_arr_eq(value, sep, token_arr_en, token_arr)
        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    } else if (op ~ /^=~[.]$/) {
        sep = substr(op, 4, 1)
        assert_arr_eq(value, sep, token_arr_en, token_arr)
        gsub(sep, "\034", value)    # how to do that?
        append_code( "local " name "=" quote_string(value) " 2>/dev/null" )
    }else {
        print "Op Not Match any candidates: \n" line > "/dev/stderr"
        exit_print(1)
    }
}

function parse(text,    text_arr, text_arr_len, i, start){
    text_arr_len = split(f(text), text_arr, "\n")
    # There is TOKEN_SEP before "default"
    start = (text_arr[1] ~ /^.default/) ? 2 : 1

    # Step 1: Generate help
    HELP_DOC = "Command Info:"
    for (i=start; i<=text_arr_len; i++) {
        HELP_DOC = HELP_DOC "\n" parse_item_to_generate_help(text_arr[i])
    }
    HELP_DOC = HELP_DOC "\n"

    # Step 2: Prepare arguments
    prepare_arg_map(ARGSTR)

    # Step 3: Get item Value, then validate it.
    for (i=start; i<=text_arr_len; i++) {
        line = text_arr[i]
        parse_item(line)
    }
}


function prepare_arg_map(argstr,        arg_arr_len, arg_arr, i, e, key, tmp){
    key = null
    arg_arr_len = split(argstr, arg_arr, ARG_SEP)
    for (i=1; i<=arg_arr_len; ++i) {
        e = arg_arr[i]
        if (match(e, "^--?")){
            if (key != null) {
                # TODO: bug
            }
            if (arg_has_value[e] == true){
                key = e
            } else {
                arg_map[e] = FLAG_ENALED
                key = null # unecessary
            }
        } else if (key != null) {
            arg_map[key] = e
            key = null
        } else {
            break
        }
    }

    tmp = i

    for (; i<=arg_arr_len; ++i) {
        # rest: rest_arguments
        rest[i-tmp+1] = arg_arr[i]
    }
}

BEGIN{
    if (ARG_SEP == 0) {
        print "Please provide ARG_SEP as below:\n  awk -v ARG_SEP=<value>" > "/dev/stderr"
        exit 1
    }

    TOKEN_SEP = "\005"
    false = 0;  true = 1;
    FLAG_ENALED = "\002"
    null="\001"
    return_code = 0

    part_one = true

    text = ""

    text_arr_len = 0
    keyline = ""
}

{
    if ($0 == "\001\001\001") {
        part_one = false
    } else {
        if (part_one == false) {
            if (text == "") text = $0
            else text = text "\n" $0
        } else {
            if (keyline == "") {
                keyline = $0
            } else {
                default_scope[keyline] = $0
                keyline = ""
            }
        }
    }
}

END{
    parse(text)
    print CODE
    # print "local HELP_DOC=" quote_string(HELP_DOC) " 2>/dev/null"
    exit return_code
}

