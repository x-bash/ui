# shellcheck shell=bash

xrc std/http std/param

############################
# Section 1: Instantiation & Utilities
# Section 2: Dict & Path
# Section 3: Header
# Section 4: QueryString & Body
# Section 5: Request & Response
# Section 6: CRUD -- post get put delete
############################

############################
# Section 1: Token & Config management
############################
gt.token(){
    local O="${O:-GITEE_DEFAULT}"
    param.default "app/gitee/$O" "token" "$@"

    if [ -n "$1" ]; then    # token set
        O="_x_cmd_x_bash_gitee_$O"
        http.body.put access_token "$1"
        http.qs.put access_token "$1"
    fi
}

# Current Repo

# shellcheck disable=SC2120
gt.current_repo(){
    local O="${O:-GITEE_DEFAULT}"
    param.default "app/gitee/$O" "repo" "$@"
}

# Current User-Type

# shellcheck disable=SC2120
gt.current_owner(){
    local O="${O:-GITEE_DEFAULT}"

    if [ -n "$1" ]; then
        param.default "app/gitee/$O" owner "$1"
        param.default.delete "app/gitee/$O" owner_type
        # gt.current_owner_type || echo "Fetch owner type wrong. Please manually set owner-type using 'gt.current_owner_type <owner_type>'." >&2
        return 0
    fi

    # get owner type
    data="$(gt.user.info | jq -r .login)"
    [ -z "$data" ] && return 1
    param.default "app/gitee/$O" owner "$data"
    echo "$data"
}

# shellcheck disable=SC2120
gt.current_owner_type(){
    if [ -n "$1" ]; then
        # Set owner type
        param.default "app/gitee/$O" owner_type "$1"
        return
    fi

    local data
    data="$(param.default "app/gitee/$O" owner_type "$1")"

    if [ -z "$data" ]; then
        owner="$(gt.current-owner.get)"
        if [ -z "$owner" ]; then
            echo "Owner is empty. While owner not set." >&2
            return 1
        fi

        data=$(gt.owner_type.query "$owner")
        [ -z "$data" ] && return 1

        param.default "app/gitee/$O" owner_type "$data"
    fi
    printf "%s" "$data"
}

# Current User

gt.config.save(){
    param.default.save "app/gitee/$O" "${1:?$HOME/.x-cmd.com/config/x-bash/.app.gitee.config}"
}

gt.config.load(){
    local O="${O:-GITEE_DEFAULT}" token
    param.default.load "app/gitee/$O" "${1:?$HOME/.x-cmd.com/config/x-bash/.app.gitee.config}"

    token="$(gt.token)"
    [ -n "$token" ] && gt.token "$token"
}

############################
# Section 2: Wrapping std/http module with object naming changing
############################
gt.resp.header(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.resp.header "$@"
}

# TODO: Not supported yet
gt.resp.body(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.resp.body "$@"
}

gt.get()(
    http.qs.put access_token "$(gt.token)"
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.get "$@";
)

gt.get.multi(){
    local i=1 total_page=100000
    for (( i=1; i <= total_page; i++ )); do
        # echo gt.get "$@" page=$i per_page=100 >&2
        gt.get "$@" page=$i per_page=100
        total_page="$(gt.resp.header "total_page")"
        # echo "total_page:$total_page" >&2
    done
}

# gt.post(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.post "$@"; }
gt.post.json()(
    http.body.put access_token "$(gt.token)"
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.post.json "$@"; 
)

# gt.put(){ O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.put "$@"; }
gt.put.json()(
    http.body.put access_token "$(gt.token)"
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.put.json "$@"; 
)

gt.delete()(
    http.qs.put access_token "$(gt.token)"
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.delete "$@";
)

gt.dict.getput(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.getput "$@";
}

gt.dict.get(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.get "$@";
}

gt.dict.put(){
    O="_x_cmd_x_bash_gitee_${O:-GITEE_DEFAULT}" http.dict.put "$@";
}

############################
# Section 3: Parameter Utilities
############################
gt.param.normalize.repo(){
    case "$1" in
    */*)
        printf "%s" "$1";;
    "")
        local _owner _repo
        _owner="$(gt.current-owner)"
        if [ -z "$_owner" ]; then
            printf "No owner provided. Default owner NOT set.\n" >&2
            return 1
        fi

        _repo="$(gt.current-repo)"
        if [ -z "$_repo" ]; then
            printf "No repo provided. Default repo NOT set.\n" >&2
            return 1
        fi
        
        printf "%s/%s" "$_owner" "$_repo";;
    *)     
        local _owner
        _owner="$(gt.current-owner)"
        if [ -z "$_owner" ]; then
            printf "No owner provided. Default owner not set.\n" >&2
        fi
        printf "%s" "$_owner/$1";;
    esac
}

### Repo #1

gt.parse_owner_repo(){
    local O="${O:-GITEE_DEFAULT}"

    if [ -z "$repo" ]; then
        repo="$(gt.current_repo)"
    fi

    if [[ "$repo" = */* ]]; then
        owner=${repo%%/*}
        repo=${repo##*/}
    fi

    if [ -z "$owner" ]; then
        owner="$(gt.current_owner)"
    fi
}

# shellcheck disable=SC2142,SC2154
alias gt.param.repo.list='
    param '\''
        ... "Provide repo list"
    '\''

    if [ ${#_rest_argv[@]} -eq 0 ]; then
        # Notice, $() should not quote!!!
        _rest_argv=( "" )
    fi

    local repo_list
    repo_list=( $(
        for repo in "${_rest_argv[@]}"; do
            repo="$(gt.param.normalize.repo "$repo")"
            if [ $? -ne 0 ]; then
                return 1
            fi
            printf "%s\n" "$repo"
        done
    ) )
'

############################
# Section 4: Info & Org Creation
############################
# TODO: better solution?
gt.owner_type.query(){
    local owner="${1:?Provide owner name}"
    
    gt.org.info "$owner" 1>/dev/null 2>&1 && printf "org" && return 0
    gt.enterprise.info "$owner" 1>/dev/null 2>&1 && printf "enterprise" && return 0
    gt.user.info "$owner" 1>/dev/null 2>&1 && printf "user" && return 0

    return 1
}

gt.user.info(){
    gt.get "/v5/user"
}

gt.enterprise.info(){
    gt.get "/v5/enterprises/${1:?Provide enterprise}"
}

gt.org.info(){
    gt.get "/v5/orgs/${1:?Provide organization}"
}

# It is very rare
gt.org.create(){
    param '
        ... "organization name" =str
    '
    local org
    for org in "${_rest_argv[@]}"; do
        gt.post "/v5/users/organization" name="$org" org="$org"
    done
}

############################
# Section 5: List Repos
############################
gt.repo.list(){
    param '
        #1  "Provide owner"
    '

    local owner owner_type
    owner="${_rest_argv[0]}"
    if [ -z "$owner" ]; then
        gt.user.repo.list "$@"
    else
        owner_type="$(gt.owner_type.query "$owner")"
    fi

    if [ -n "$owner_type" ] && [ -n "$owner" ]; then
        "gt.${owner_type}.repo.list" "$@"
    else
        printf "Please provide owner and owner_type\n" >&2
        param.help.show
    fi
}

# https://gitee.com/api/v5/swagger#/getV5EnterprisesEnterpriseRepos
gt.enterprise.repo.list(){
    param '
        #1 "Provide enterprise"
        type=all "repo type" = all public internal private
        direct=true "" = true false
    '

    local owner=${_rest_argv[0]}
    gt.get.multi "/v5/enterprises/$owner/repos" type=all | jq -r ".[] | .full_name"
}

# https://gitee.com/api/v5/swagger#/getV5OrgsOrgRepos
gt.org.repo.list(){
    param '
        #1 "Provide organization"
        type=all "repo type" = all public privates
    '

    local owner=${_rest_argv[0]}
    gt.get.multi "/v5/orgs/$owner/repos" type=all | jq -r ".[] | .full_name"
}

# https://gitee.com/api/v5/swagger#/getV5UserRepos
gt.user.repo.list(){
    param '
        visibility=all "" = public private all
        affiliation=owner =, owner collaborator organization_member enterprise_member admin
        sort=created "" = created updated pushed full_name
        direction="desc" = asc desc
    '

    gt.get.multi "/v5/user/repos" visibility affiliation sort direction\
        | jq -r ".[] | .full_name"
}

############################
# Section 6: Repo Path & Clone
############################
gt.repo.url.http(){
    param '
        ... "Provide repo list"
    '

    local repo
    for repo in "${_rest_argv[@]}"; do
        printf "https://gitee.com/%s.git\n" "$(gt.param.normalize.repo "$repo")"
    done
}

gt.repo.url(){
    gt.repo.url.ssh "$@"
}

gt.repo.url.ssh(){
    param '
        ... "Provide repo list"
    '

    local repo
    for repo in "${_rest_argv[@]}"; do
        printf "git@gitee.com:%s.git\n" "$(gt.param.normalize.repo "$repo")"
    done
}

gt.repo.clone(){
    gt.repo.clone.ssh "$@" && return 0
    gt.repo.clone.https "$@" && return 0
    return $?
}

# shellcheck disable=SC2120
gt.repo.clone.ssh(){
    git clone "$(gt.repo.url.ssh "$@")"
}

# shellcheck disable=SC2120
gt.repo.clone.https(){
    git clone "$(gt.repo.url.http "$@")"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoForks
gt.repo.fork(){
    param '
        owner=""   "Repo Owner" =str
        repo    "Repo name" =str
        organization=""    "Provide organization"  =str
    '

    
    gt.post.json "https://gitee.com/api/v5/repos/${owner}/${repo}/forks" organization
}


############################
# Section 7: Repo - Deletion & Info & Creation
############################
gt.repo.info(){
    param '
        #1      "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$1")"

    gt.get "/v5/repos/${owner_repo}"
    # gt.get "/v5/repos/${owner}/${repo}"
}

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepo
gt.repo.destroy(){
    param '
        ... "Provide repo list"
    '

    local owner_repo i

    for i in "${_rest_argv[@]}"; do
        owner_repo=$(gt.param.normalize.repo "$1")

        echo "Deleting repo: $owner_repo" >&2
        gt.delete "/v5/repos/$owner_repo" >/dev/null \
            || echo "Code is $?. Deleting repo failure: $1. Probably because it desn't exists." >&2
    done
}

# arguments NAME
gt.repo.create(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        has_issues=true  "Provide issue"   = true false
        has_wiki=true    "Provide wiki"   = true false
        access=private   "Provide access"   = public private innerSource
    '

    local private
    case "$access" in
        public)  private=false;;
        private) private=true;;
    esac

    if [ "$#" -eq 0 ]; then
        param.help.show
        return 1
    fi

    local name
    for name in "${_rest_argv[@]}"; do
        { 
            gt.post.json "/v5/user/repos" name has_issues has_wiki private 2>/dev/null
            code=$?
            if [ $code -ne 0 ]; then
                echo "Creating repo failure: $name. Code is $code. " >&2
                # gt.resp.header "" >&2
                return $code
            fi
        } | jq -r .full_name
    done
}

# ORGANIZATION NAME
# shellcheck disable=SC2154,SC2034

# https://gitee.com/api/v5/swagger#/postV5OrgsOrgRepos
gt.org.repo.create(){
    # TODO: I don't know what does path means for an organization repo
    param '
        owner   "organization name" =~ [A-Za-z][A-Za-z0-9-]+
        path "provide path"
        description "repo description"
        homepage "repo home page"
        has_issues=true     = true false
        has_wiki=true       = true false
        can_comment=true    = true false
        access=private      = public private innerSource
        auto_init=false     = true false
        gitignore_template
        license_template
        ...     "repo list to create" =str
    '

    local public
    case "$access" in
        private)  public=0;;
        public) public=1;;
        innerSource) public=2;;
    esac

    local name
    for name in "${_rest_argv[@]}"; do
        local resp
        {
            gt.post.json "/v5/orgs/$owner/repos" \
                name path description homepage has_issues has_wiki public\
                can_comment auto_init gitignore_template license_template
            code=$?
            if [ $code -ne 0 ]; then
                echo "Creating repo failure: $name. Code is $code. " >&2
                # gt.resp.header "" >&2
                return $code
            fi
        } | jq -r .full_name
    done
}

# https://gitee.com/api/v5/swagger#/postV5EnterprisesEnterpriseRepos
# shellcheck disable=SC2154
gt.enterprise.repo.create(){
    param '
        owner   "enterprise name"
        has_issues=true     = true false
        has_wiki=true       = true false
        access=private      = public private innerSource
        outsourced=false    = true false
        ...     "repo list to create" =str
    '

    local private
    # shellcheck disable=SC2034
    case "$access" in
        public)  private=0;;
        private) private=1;;
        innerSource) private=2;;
    esac

    local name
    for name in "${_rest_argv[@]}"; do
        gt.post.json "/v5/enterprises/$owner/repos" name has_issues has_wiki private
    done
    return 0
}

############################
# Section 8: Repo Member
############################
# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoCollaborators
gt.repo.member.list(){
    param.example \
        "list all members, using argument" \
        "gt.repo.member.list x-bash/std" \
        "list all members, using naming argument" \
        "gt.repo.member.list --repo x-bash/std"
    
    param '
        #1      "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$1")"

    gt.get "/v5/repos/${owner_repo}/collaborators"
}

# gt.repo.member.add pull:edwinjhlee,work,adf push:work,adf admin:edwinjhlee

# https://gitee.com/api/v5/swagger#/putV5ReposOwnerRepoCollaboratorsUsername
gt.repo.member.add(){
    param.example \
        "Add user with pull permission" \
        "gt.repo.member.add --repo=x-bash/work --permission pull user1 user2"
        "Add user with push permission" \
        "gt.repo.member.add --repo=x-bash/work --permission push user3"\
        "Add user with push permission" \
        "gt.repo.member.add --repo=x-bash/work pull:user1,user2 push:user3s"\

    param '
        repo="" "Repo name"
        permission=pull "Repo permission" = push push admin
        ... "User list"
    '

    repo="$(gt.param.normalize.repo "$repo")" || return 1

    local username
    for username in "${_rest_argv[@]}"; do
        gt.put.json "/v5/repos/$owner/$repo/collaborators/$username" permission
    done
}

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepoCollaboratorsUsername
gt.repo.member.remove(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    local username
    for username in "$@"; do
        gt.delete "/v5/repos/$owner_repo/collaborators/$username"
    done
}

############################
# Section 9: Repo Page Managment
############################
# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPages
gt.repo.page.info(){
    param '
        #1      "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$1")"
    gt.get "/v5/repos/${owner_repo}/pages"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPagesBuilds
# Even we could use it
# {"message":"非付费pages，不允许部署 pages"}
gt.repo.page.build(){
    param '
        #1      "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$1")"
    gt.post.json "/v5/repos/${owner_repo}/pages/builds"
}


### gitee release infomation. Using this to optimize the integration action workflow

############################
# Section 10: Release
############################
# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoReleases
gt.repo.release.list(){
    param '
        #1      "Provide repo"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$1")"
    gt.get.multi "https://gitee.com/api/v5/repos/${owner_repo}/releases"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoReleases
gt.repo.release.create(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo    "Provide repo"
        tag_name "Please provide tag name"
        name    "Release name"
        body    "Release Description"
        prerelease  "Is release version"
        target_commitish="master"  "Default is master"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    gt.post "https://gitee.com/api/v5/repos/$owner_repo/releases" \
        tag_name name body prerelease target_commitish
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoReleasesId
gt.repo.release.update(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo "Provide repo"
        id  "Release ID"
        tag_name "Please provide tag name"
        name    "Release name"
        body    "Release Description"
        prerelease  "Is release version"
        target_commitish="master"  "Default is master"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
    gt.post "https://gitee.com/api/v5/repos/$owner_repo/releases" \
        id tag_name name body prerelease target_commitish
}

# ?
gt.repo.release.get_or_create(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo "Provide repo"
        owner="" "Repo Owner"
    '
    gt.parse_owner_repo
}

# https://gitee.com/api/v5/swagger#/deleteV5ReposOwnerRepoReleasesId
gt.repo.release.delete(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo "Provide repo"
    '
    gt.parse_owner_repo
}

gt.repo.release.attachment(){
    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

gt.repo.release.attachment.list(){

    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# Provide multiple files
gt.repo.release.attachment.upload(){

    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}

# Delete the file in attachment list
gt.repo.release.attachment.remove(){

    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        owner="" "Repo Owner"
        repo="" "Repo name"
    '
    gt.parse_owner_repo
}


############################
# Section 10: Pull Request
############################
### Pull Request Facility. It should fit it the pull request workflow.
# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPulls
gt.repo.pr.create(){

    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        owner="" "Repo Owner"
        repo    "Repo name"
        title "pr title"
        head "source branch. Format: [username:]<branch>"
        base "target branch. Format: [username:]<branch>"
        body="" "pull request content"
        milestone_number="" "milestone id"
        labels="" "labels"
        assignees="" "reviewer username list. Format: <username>[,<username>]"
        testers="" "tester username list. Format: <username>[,<username>]"
        prune_source_branch=false = true false
    '

}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPullsNumberAssignees
gt.repo.pr.assign(){

    local O="${O:-GITEE_DEFAULT}"

    param "
        default-scope app/gitee/$O
    "'
        repo "Repo name"
        number "pull request id"
        labels=""
        assignees="" "reviewer username list. Format: <username>[,<username>]"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    gt.parse_owner_repo
    gt.post.json "/v5/repos/${owner_repo}/pulls/${number}/assignees"
}

# https://gitee.com/api/v5/swagger#/postV5ReposOwnerRepoPullsNumberTesters
gt.repo.pr.assign.testers(){
    
    param "
        default-scope app/gitee/$O
    "'
        repo "Repo name"
        number "pull request id"
        labels=""
        testers="" "testers username list. Format: <username>[,<username>]"
    '
    
    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    gt.parse_owner_repo
    gt.post.json "/v5/repos/${repo}/pulls/${number}/testers" labels testers
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPulls
gt.repo.pr.list(){

    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
        state=open = open closed merged all
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    gt.get.multi "/v5/repos/${owner_repo}/pulls" state
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.open(){

    param "
        default-scope app/gitee/$O
    "'
        repo="" "Repo name"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.status(){
    state=all gt.repo.pr.list
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoPullsNumberAssignees
gt.repo.pr.review-status.reset(){
    
    param "
        default-scope app/gitee/$O
    "'
        repo="" "Repo name"
    '
    
    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}

# https://gitee.com/api/v5/swagger#/patchV5ReposOwnerRepoPullsNumberTesters
gt.repo.pr.test-status.reset(){
    
    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}

# open navigator, using the viewer
# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumber
gt.repo.pr.view(){
    
    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
        id  "pull request id"
    '
    
    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1

    http.browse "https://gitee.com/${owner_repo}/pulls/${id}"
}

gt.repo.pr.checkout.http(){
    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}

# git clone to local disk to compare
gt.repo.pr.merge.http(){
    local source_branch="${1:?Provide source branch}"
    local target_branch="${1:?Provide target branch}"

    local repo_name=${repo_url##*/}
    repo_name=${repo_name%.git}

    if ! git branch; then
        git clone "$repo_url"
        cd repo_name || return 1
    fi

    git checkout "$target_branch"
    git pull "$repo_url" "$source_branch"
    echo "Please open the current folder to merge the code" >&2
    # git push origin issue_I1N19D_ljh_using-java-10
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumberIssues
gt.repo.pr.issue.list(){
    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}

# https://gitee.com/api/v5/swagger#/getV5ReposOwnerRepoPullsNumberComments
gt.repo.pr.comment.list(){
    : TODO: assitance
    : list all of the comment in the terminal

    param "
        default-scope app/gitee/$O
    "'
        repo    "Repo name"
    '

    local owner_repo
    owner_repo="$(gt.param.normalize.repo "$repo")" || return 1
}


############################
# Section 10: OO Style
############################
gt.new(){
    oo.create_new_function gt "$@"
}

gt.repo.new(){
    local owner repo="${1:?Provide enterprise name}"
    gt.parse_owner_repo
    local instance_name="${2:-$repo}"

    eval "
        $instance_name.member.list(){ gt.repo.member.list \"\$@\"; }
        $instance_name.member.add(){ gt.repo.member.add \"\$@\"; }
        $instance_name.member.remove(){ gt.repo.member.remove \"\$@\"; }
    "
}

gt.org.new(){
    local owner="${1:?Provide organization name}"
    local instance_name="${2:-$owner}"
    eval "
        $instance_name.info(){ gt.org.info $owner; }
        $instance_name.repo.create(){ gt.org.repo.create --owner $owner \"\$@\"; }
        $instance_name.repo.list(){ gt.org.repo.list --owner $owner \"\$@\"; }
    "
}

gt.enterprise.new(){
    local owner="${1:?Provide enterprise name}"
    local instance_name="${2:-$owner}"
    eval "
        $instance_name.info(){ gt.enterprise.info $owner; }
        $instance_name.repo.create(){ gt.enterprise.repo.create --owner $owner \"\$@\"; }
        $instance_name.repo.list(){ gt.enterprise.repo.list  --owner $owner \"\$@\"; }
    "
}

############################
# Section 11: Instantiation
############################
gt.make(){
    local O_ORIGINAL=${1:?Provide client name by O environment}

    if [ -n "$GITEE_DEFAULT" ] && [ "$O_ORIGINAL" = "GITEE_DEFAULT" ]; then
        echo "Name 'GITEE_DEFAULT' is reserved for internal use."
        return 1
    fi

    local O="_x_cmd_x_bash_gitee_$O_ORIGINAL"

    http.make "$O" 'https://gitee.com/api'
    http.header.content-type.eq.json+utf8

    local TOKEN=${2:-""}
    if [ -n "$TOKEN" ]; then
        printf "Init token by second parameter \n" >&2
        O=$O_ORIGINAL gt.token.set "$TOKEN"
    elif [ -n "$GITEE_TOKEN" ]; then
        printf "Init token with env GITEE_TOKEN\n" >&2
        O=$O_ORIGINAL gt.token.set "$GITEE_TOKEN"
    else
        gt.token.load default
    fi
}


if [ -z "$DO_NOT_INIT_GITEE_DEFAULT" ]; then
    gt.make "GITEE_DEFAULT"
fi
