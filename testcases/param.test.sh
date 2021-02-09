# shellcheck shell=sh
# shellcheck disable=SC2039

. ../param

test_param_main(){
    @assert "$(param_main -v --repo el --user work <<A
    --user "Provider user name"
    --repo "Provide repo name"
    -v  "verbose mode"  =FLAG
A
    )"  "

<coding here>
local
    "

}

test_param_alias(){

    local repo="outside-repo"
    local user="outside-user"
    local verbose=

    test_param_alias_inner(){
        param <<A
        --user "Provider user name"
        --repo "Provide repo name"
        --verbose -v  "verbose mode"  =FLAG
A
        @assert "$repo" = x-bash
        @assert "$user" = el
        @assert "$verbose" = true

        local IFS=" "
        @assert "$*" "1 2 3"
    }


    test_param_function_inner -v --repo x-bash --user el 1 2 3

    # param in test_param_alias_inner() should not effect the outside env
    @assert "$repo" = "outside-repo"
    @assert "$user" = "outside-user"
    @assert "$verbose" = ""
}

@run test_param_main test_param_alias

