. gitee
gt.new a

echo "setting token"

a.token.set af18e9ba5d177e1af9215b987a4a0f24
echo "$(a.token.get)"

# a.user.info

# a.enterprise.info "lteam18"
# a.owner.query_type "x-bash"

# owner="lteam18" a.repo.list

# a.repo.create "lteam18/test1"
# a.repo.url lteam18/aircraft

a.repo.create test1
# a.repo.info edwinjhlee/test1
a.repo.destroy edwinjhlee/test1
echo code: $?

a.repo.destroy edwinjhlee/test2
echo code: $?

# owner="d-y-innovations" a.repo.list 1>a.txt

# curl --fail \
#     -D /var/folders/7b/3td44bks6hj5_c03tr00b2y00000gn/T/x-cmd-x-bash-std-http-_x_cmd_x_bash_gitee_a \
#     -X GET -G \
#     --data-urlencode "access_token=2bb5d93272d45d9179d2315086af46e3" \
#     --data-urlencode "type=all" --data-urlencode "page=0" --data-urlencode "per_page=100" \
#     -H "Content-Type: application/json;charset=utf-8" \
#     https://gitee.com/api/v5/organization/lteam18/repos

# curl --fail \
#     -X GET -G \
#     --data-urlencode "access_token=2bb5d93272d45d9179d2315086af46e3" \
#     -H "Content-Type: application/json;charset=utf-8" \
#     https://gitee.com/api/v5/organization/lteam18/repos
