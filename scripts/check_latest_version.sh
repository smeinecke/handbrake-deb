#!/bin/bash

vercomp () {
    if [[ $1 == $2 ]]
    then
        return 0
    fi
    local IFS=.
    local i ver1=($1) ver2=($2)
    # fill empty fields in ver1 with zeros
    for ((i=${#ver1[@]}; i<${#ver2[@]}; i++))
    do
        ver1[i]=0
    done
    for ((i=0; i<${#ver1[@]}; i++))
    do
        if [[ -z ${ver2[i]} ]]
        then
            # fill empty fields in ver2 with zeros
            ver2[i]=0
        fi
        if ((10#${ver1[i]} > 10#${ver2[i]}))
        then
            return 1
        fi
        if ((10#${ver1[i]} < 10#${ver2[i]}))
        then
            return 2
        fi
    done
    return 0
}

if [ -z $1 ]; then
    echo "Required parameter missing!"
    exit 1
fi

remote_current_release=$(curl -sL https://api.github.com/repos/$1/releases/latest | jq -r ".tag_name")
echo "::set-output name=remote_current_release::${remote_current_release}"
local_current_tag=$(curl -sL https://api.github.com/repos/$2/releases/latest | jq -r ".tag_name")
echo "::set-output name=own_current_release::${local_current_tag}"
vercomp ${remote_current_release} ${local_current_tag}
case $? in
    0) op='equal';;
    1) op='newer';;
    2) op='older';;
esac
echo "::set-output name=vercomp::$op"
