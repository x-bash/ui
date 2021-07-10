BEGIN {
    RS = "\002"
    KSEP = ","


    LEN = "len"
    # data 

    # col_max = 0
    col_num = 0
}

NR > 1{
    line_idx = NR - 1

    data[ LEN ] = line_idx
    
    # TODO: Problably deal with \n
    arr_len = split($0, arr, "\003")

    data[ line_idx KSEP LEN ] = arr_len

    if (col_num < arr_len)  col_num = arr_len

    for (i=1; i<=arr_len; ++i) {
        data[ line_idx KSEP i ] = arr[i]
        
        arr_i_len = length(arr[i])
        
        if (col_max[i] < arr_i_len) col_max[i] = arr_i_len
    }
}

function fixout(size, str){
    printf("%-" size "s", str)
}

function col_max_sum(   i, sum){
    sum = 0
    for (i=1; i<=col_num; ++i) {
        sum += col_max[i]
    }
    return sum
}

function style0(    i, j){
    printf "\033[4m"
    for (i=1; i<=data[LEN]; ++i) {
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j] + 3, data[i KSEP j])
        }
        printf "\033[0m\n"
    }
}

function style1(    i, j){
    printf "\033[4m"
    for (i=1; i<=data[LEN]; ++i) {
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j] + 3, data[i KSEP j])
        }

        if ( i == data[LEN]-1 ) {
            printf "\033[4m"
        } else {
            printf "\033[0m"
        }
        printf "\n"
    }
}

function style2(corner,    i, j){

    if (corner == "") corner = "*"

    tmp = corner
    col_wid = col_max_sum()
    for (i=1; i<col_wid-1 + 3 * col_num + 3; ++i) {
        tmp = tmp "-"
    }
    tmp = tmp corner

    print tmp

    for (i=1; i<=data[LEN]; ++i) {
        printf "| "
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j] + 3, data[i KSEP j])
        }

        printf "|\n"

        if ( i == 1 ) {
            print tmp
        }
    }
    print tmp
}

function style3(corner,    i, j){
    if (corner == "") corner = "*"

    tmp = corner
    col_wid = col_max_sum()
    for (i=1; i<col_wid-1 + 3 * col_num + 3; ++i) {
        tmp = tmp "-"
    }
    tmp = tmp corner

    print tmp

    for (i=1; i<=data[LEN]; ++i) {
        printf "| "
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j] + 3, data[i KSEP j])
        }

        printf "|\n"

        if ( i == 1 ) {
            print tmp
        }
    }
    print tmp
}

function style4(corner,    i, j){
    if (corner == "") corner = "o"

    tmp = corner "-"
    tmp1 = corner "-"
    col_wid = col_max_sum()

    for (i=1; i<=col_num; ++i) {
        for (j=1; j<=col_max[i]; ++j) {
            tmp = tmp "-"
            tmp1 = tmp1 "-"
        }

        if (i == col_num)   tmp = tmp "---"
        else                tmp = tmp "-+-"
        tmp1 = tmp1 "---"
    }

    tmp = tmp corner
    tmp1 = tmp1 corner

    print tmp

    for (i=1; i<=data[LEN]; ++i) {
        printf "| "
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j] + 3, data[i KSEP j])
        }

        printf "|\n"

        if ( i == 1 ) {
            print tmp
        }
    }
    print tmp1
}

function style5(corner,    i, j){
    if (corner == "") corner = "o"

    tmp = corner "-"
    tmp1 = corner "-"
    col_wid = col_max_sum()

    for (i=1; i<=col_num; ++i) {
        for (j=1; j<=col_max[i]; ++j) {
            tmp = tmp "-"
            tmp1 = tmp1 "-"
        }

        if (i == col_num)   tmp = tmp "---"
        else                tmp = tmp "-+-"
        tmp1 = tmp1 "---"
    }

    tmp = tmp corner
    tmp1 = tmp1 corner

    print tmp

    for (i=1; i<=data[LEN]; ++i) {
        printf "| "
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j], data[i KSEP j])
            if (j != col_num)   printf("%s", " | ")
            else                printf("%s", "   ")
        }

        printf "|\n"

        if ( i == 1 ) {
            print tmp
        }
    }
    print tmp1
}

function style6(corner,    i, j){
    if (corner == "") corner = "o"

    tmp = corner "-"
    tmp1 = corner "-"
    col_wid = col_max_sum()

    for (i=1; i<=col_num; ++i) {
        for (j=1; j<=col_max[i]; ++j) {
            tmp = tmp "-"
            tmp1 = tmp1 "-"
        }

        if (i == col_num)   tmp = tmp "---"
        else                tmp = tmp "-+-"
        tmp1 = tmp1 "---"
    }

    tmp = tmp corner
    tmp1 = tmp1 corner

    print tmp1

    for (i=1; i<=data[LEN]; ++i) {
        printf "| "
        for (j=1; j<=col_num; ++j) {
            fixout(col_max[j], data[i KSEP j])
            if (j != col_num)   printf("%s", " | ")
            else                printf("%s", "   ")
        }

        printf "|\n"

        if ( i == 1 ) {
            print tmp
        }
    }
    print tmp1
}

function show_all(){
    print "style 0: "
    style0()
    printf "\n"

    print "style 1: "
    style1()
    printf "\n"

    print "style 2: "
    style2()
    printf "\n"

    print "style 3: "
    style3()
    printf "\n"

    print "style 4: "
    style4()
    printf "\n"

    print "style 5: "
    style5()
    printf "\n"

    print "style 6: "
    style6()
    printf "\n"
}

END{
    if (out == "0") {
        style0()
        exit 0
    }

    if (out == "1") {
        style1()
        exit 0
    }

    if (out == "2") {
        style2()
        exit 0
    }

    if (out == "3") {
        style3()
        exit 0
    }

    if (out == "4") {
        style4()
        exit 0
    }

    if (out == "5") {
        style5()
        exit 0
    }

    if (out == "6") {
        style6()
        exit 0
    }

    show_all()
}


