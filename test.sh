run(){
    local msg="${1:?Please Provide message}"; shift
    
    touch a.txt
    {
        eval "$@"
        rm a.txt
    } | {
        i="-"
        printf "%s %s" "$i" "$msg"
        while [ -f a.txt ]; do
            sleep 0.1
            case "$i" in
                -)  i="\\"  ;;
                \\) i="|"   ;;
                \|) i="/"   ;;
                /)  i="-"   ;;
            esac
            printf "\r\033[0;34m%s\033[0m   %s" "$i" "$msg"
        done

        printf "\r\033[0;32m%s\033[0m   %s\n" "√" "$msg"
    }
    
    # | {
    #     printf "Here starts"
    #     i="-"
    #     while read -t 1 a; do
    #         printf "Here starts"
    #         case "$i" in
    #             -)  i="\\"  ;;
    #             \\) i="|"   ;;
    #             \|) i="/"   ;;
    #             /)  i="-"   ;;
    #         esac
    #         printf "%s %s" "$i" "$msg"
    #     done

    #     printf "\n"
    # }
}

run "Running Sleep 3" sleep 5
