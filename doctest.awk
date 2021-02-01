BEGIN{
    SEP="\001"; RESULT_SEP="\002"
    # SEP="\t"; RESULT_SEP="\n"
    false=0;    true=1;
    is_block=false;     block_name="";   cmd="";  result=""
}

function panic(err){
    print "Panic: " err >"/dev/stderr"
    exit(1)
}

{
    if (is_block != false) {
        if ($0 == block_name) {
            if (cmd != "") {
                if ((block_name != "DOCTEST-NO-SH") || (sh == false)) print cmd SEP result
                cmd=""; result=""
            }

            is_block=false;
        } else if (match($0, /^> /)) {
            if (cmd != "") {
                if ((block_name != "DOCTEST-NO-SH") || (sh == false)) print cmd SEP result
                cmd=""; result=""
            }
            cmd = substr($0, 3);
        } else {
            if (result == "")   result = $0
            else                result = result RESULT_SEP $0
        }
    } else {
        if (match($0, /^ *: *<<\'?(DOCTEST(-NO-SH)?)\'?/)) {
            if (is_block != false)  panic("Expect to be no block start before: " NR "\t" $0)
            is_block=true
            if (match($0, "DOCTEST-NO-SH")) block_name="DOCTEST-NO-SH"
            else                            block_name="DOCTEST"
        }
    }
}

