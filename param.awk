

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

function parse_token(s, idx){

}

function f(text){
    # print line
    gsub("[\ \t\v\b]+\n[\ \t\v\b]+", "\n", text)
    # print line
    gsub(/\\\\/, "\001", text)
    gsub(/\\"/, "\002", text)

    gsub(/"[^"]*"|[-A-Za-z0-9_=]+/, "\003&", text)
    gsub("\001", /\\\\/, text)
    gsub("\002", /\\"/, text)   # "
}

function get_value(){
    # 
}

function parse_item_to_generate_help(line,      line_arr, line_arr_len, ret, name, default, desc, op) {
    line_arr_len = split(line, line_arr, "\003")
    name = line[2];     desc = line[3];     op = line[4]
    default = name
    name = gsub("=.+$", "", name)

    if (name == line[2])    default = null
    else                    default = gsub("^.+=", "", name)

    if (op == "=NONE") {
        arg_has_value[name] = false
    } else {
        arg_has_value[name] = true
    }

    # TODO: make it better
    return "    --" name "\t"  default "\t"      desc
}

function assert_arr_eq(value, sep, line_arr_len, line_arr,    j, value_arr_len, value_arr, sw){
    value_arr_len = split(value, value_arr, sep)
    for (j=1; j<=value_arr_len; ++j) {
        sw = false
        for (idx=5; idx<=line_arr_len; ++idx) {
            if (match(value_arr[j], line_arr[idx]) {
                sw = true
                break
            }
        }
        if ( sw == false) {
            # show help
            exit 1
        }
    }
}


function parse_item(line,   line_arr_len, line_arr, value, name, default, idx, j, sw, value_arr, value_arr_len, sep){
    line_arr_len = split(line, line_arr, "\003")
    name = line[2]
    desc = line[3]
    op = line[4]

    value = arg_map[name]
    if (op == "") {
        return
    }

    if (op == "=NONE") {
        if (value == ARG_ENABLED)
    }

    if (op == "=int") {
        if (! match(value, /[+-]?[0-9]+/) ) {    # float is: /[+-]?[0-9]+(.[0-9]+)?/
            # show help
            exit 1
        }
    } else if (op == "=") {
        sw = false
        for (idx=5; idx<=line_arr_len; ++idx) {
            if (value == line_arr[idx]) {
                sw = true
                break
            }
        }
        if (sw == false) {
            # show help
            exit 1
        }
    } else if (op =~ /^=.$/) {
        assert_arr_eq(value, substr(op, 2, 1), line_arr_en, line_arr)
    } else if (op =~ /^=[.]$/) {
        assert_arr_eq(value, substr(op, 3, 1), line_arr_en, line_arr)
    } else {
        # Wrong
    }
}

function parse(text,    text_arr, text_arr_len){
    text_arr_len = split(f(text), text_arr, "\n")

    # Step 1: Generate help
    help_doc = "Command Info:"
    for (i=1; i<=text_arr_len; i++) {
        line = text_arr[i]
        help_doc = help_doc "\n" parse_item_to_generate_help(line)
    }
    help_doc = help_doc "\n"

    # Step 2: Prepare arguments
    prepare_arg_map()

    # Step 3: Get item Value, then validate it.
    for (i=1; i<=text_arr_len; i++) {
        line = text_arr[i]
        parse_item(line)
    }
}

BEGIN{
    RS="\001"
    ARG_SEP="\002"
    false = 0;  true = 1;
    ARG_ENABLED = "\002"
    null="\001"
    return_code = 0
    # arg_map
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
                arg_map[e] = ARG_ENABLED
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
        rest[i-tmp+1] = arg_arr[i]
    }
}


END {
    parse($0)
    exit return_code
}

