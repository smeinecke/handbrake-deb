#!/bin/bash

set -e

# shellcheck disable=SC2145
echo "::group::Debug Information"
echo "Script started with parameters: $*"
echo "GITHUB_REPOSITORY_OWNER: ${GITHUB_REPOSITORY_OWNER:-Not set}"
echo "GITHUB_REPOSITORY: ${GITHUB_REPOSITORY:-Not set}"
echo "GITHUB_OUTPUT: ${GITHUB_OUTPUT:-Not set}"

GITHUB_OUTPUT="${GITHUB_OUTPUT:-/dev/null}"

# Normalize a version-ish string: strip leading 'v', 'V', or 'Release/',
# and rewrite pre-release markers (-rc, -beta, -alpha, -pre) to ~ so they
# sort correctly (older) against the final release.
normalize_version() {
    printf '%s' "$1" | sed -e 's/^[Rr][Ee][Ll][Ee][Aa][Ss][Ee]\///' \
                           -e 's/^v//' \
                           -e 's/^V//' \
                           -e 's/-\(rc\|beta\|alpha\|pre\)/~\1/g'
}

# Compare two versions. Returns:
#   0 if equal
#   1 if $1 > $2 (newer)
#   2 if $1 < $2 (older)
vercomp() {
    local v1 v2
    v1=$(normalize_version "$1")
    v2=$(normalize_version "$2")

    if [ -z "$v1" ] || [ -z "$v2" ]; then
        return 0
    fi

    # Prefer dpkg's version comparison when available; it handles ~ and pre.
    if command -v dpkg >/dev/null 2>&1; then
        if dpkg --compare-versions "$v1" gt "$v2"; then
            return 1
        elif dpkg --compare-versions "$v1" lt "$v2"; then
            return 2
        else
            return 0
        fi
    fi

    # Fallback: pure numeric dot comparison.
    if [ "$v1" = "$v2" ]; then
        return 0
    fi

    local IFS=.
    local a1 a2 i
    read -r -a a1 <<< "$v1"
    read -r -a a2 <<< "$v2"

    for ((i=${#a1[@]}; i<${#a2[@]}; i++)); do
        a1[i]=0
    done
    for ((i=0; i<${#a1[@]}; i++)); do
        if [ -z "${a2[i]:-}" ]; then
            a2[i]=0
        fi
        local n1="${a1[i]%%[^0-9]*}"
        local n2="${a2[i]%%[^0-9]*}"
        [ -z "$n1" ] && n1=0
        [ -z "$n2" ] && n2=0
        if ((10#${n1} > 10#${n2})); then
            return 1
        fi
        if ((10#${n1} < 10#${n2})); then
            return 2
        fi
    done
    return 0
}

if [ -z "$1" ]; then
    echo "::error::Required parameter missing!"
    echo "Usage: $0 <remote_repo> [local_repo]"
    echo "Example: $0 HandBrake/HandBrake"
    exit 1
fi

echo "Checking for updates for repository: $1"

echo "Fetching latest release from GitHub for $1..."
remote_current_release=$(curl -sL "https://api.github.com/repos/$1/releases/latest" | jq -r '.tag_name')
echo "Raw tag name from remote: ${remote_current_release}"
echo "remote_current_release=${remote_current_release}" >> "$GITHUB_OUTPUT"

remote_current_release=$(normalize_version "$remote_current_release")
echo "remote_current_release=${remote_current_release}" >> "$GITHUB_OUTPUT"
if [ -z "$remote_current_release" ]; then
    echo "::error::Failed to get remote current release!"
    exit 1
fi

local_repo="${2:-${GITHUB_REPOSITORY:-}}"
if [ -z "$local_repo" ]; then
    echo "::error::Local repository not specified and GITHUB_REPOSITORY not set!"
    exit 1
fi

echo "Fetching latest release from GitHub for ${local_repo}..."
own_current_release=$(curl -sL "https://api.github.com/repos/${local_repo}/releases/latest" | jq -r '.tag_name')
echo "Raw tag name from local: ${own_current_release}"
echo "own_current_release=${own_current_release}" >> "$GITHUB_OUTPUT"

own_current_release=$(normalize_version "$own_current_release")
echo "own_current_release=${own_current_release}" >> "$GITHUB_OUTPUT"
if [ -z "$own_current_release" ]; then
    echo "::warning::Could not determine current local release!"
    echo "This might be the first release or the local package is not yet published"
fi

echo "Comparing versions:"
echo "- Remote version: ${remote_current_release}"
echo "- Local version:  ${own_current_release:-None (first release)}"

if [ -z "$own_current_release" ]; then
    echo "No local version found, treating as new release"
    op='newer'
else
    vercomp "$remote_current_release" "$own_current_release"
    case $? in
        0) op='equal' ;;
        1) op='newer' ;;
        2) op='older' ;;
    esac
fi

echo "Version comparison result: ${op}"
echo "vercomp=${op}" >> "$GITHUB_OUTPUT"
echo "::endgroup::"
