O=github http.make https://api.github.io/v2

(
    O=github
    http.header.content-type.eq.json
    http.http.body.put "token" "asdfaffasf"
    (
        http.body.put "user" "el"
        http.body.put "job" "test"
        http.get "/create-repo"
    )

    O=github http.body.put "user" "el"
    O=github http.body.put "job" "test"
    O=github http.get "/create-repo"

    (
        http.body.put "user" "el"
        http.body.put "job" "test"
        http.get "/create-repo"
    )
)

http.new github https://api.github.io/v2
github.header.content-type.eq.json
github.http.body.put "token" "asdfaffasf"
(
    github.body.put "user" "el"
    github.body.put "job" "test"
    github.get "/create-repo"
)

(
    github.body.put "user" "el"
    github.body.put "job" "test"
    github.get "/create-repo"
)

