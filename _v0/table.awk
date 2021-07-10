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

function style2(    i, j){
    tmp = "+"
    col_wid = col_max_sum()
    for (i=1; i<col_wid-1 + 3 * col_num + 3; ++i) {
        tmp = tmp "-"
    }
    tmp = tmp "+"

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

function style3(    i, j){
    tmp = "+"
    col_wid = col_max_sum()
    for (i=1; i<col_wid-1 + 3 * col_num + 3; ++i) {
        tmp = tmp "-"
    }
    tmp = tmp "+"

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



END{
    style0()
    printf "\n"

    style1()
    printf "\n"

    style2()
    printf "\n"
}


