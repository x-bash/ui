
shopt -s expand_aliases

. str
. list
. dict
. ./gitee.sh


echo "set current owner"
gt.current-owner.set x-bash

echo "create repo"
gt.org.repo.create --owner x-bash test123

echo "list repo"
gt.org.repo.list x-bash

echo "destroy repo"
gt.repo.destroy x-bash/test123


owner="edwinjhlee"
gt.repo.create x-bash

gt.owner(){
    param.default app/gt owner "$1"
}

gt.owner edwinjhlee
gt.repo.create x-bash

gh.owner edwin.jh.lee
gh.repo.create x-bash



