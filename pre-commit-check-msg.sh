#!/bin/bash
#
# Reject pushes to master that contain commits with messages that do not fit the regex
#

set -e

zero_commit='0000000000000000000000000000000000000000'
msg_regex='^(fix:|feat:|build:|chore:|ci:|docs:|style:|refactor:|perf:|breaking.*:).*JAG-[0-9]+'


while read -r oldrev newrev refname; do

	# Branch or tag got deleted, ignore the push
    [ "$newrev" = "$zero_commit" ] && continue

    # Calculate range for new branch/updated branch
    [ "$oldrev" = "$zero_commit" ] && range="$newrev" || range="$oldrev..$newrev"
	if [[ ${refname#refs/heads/} == "master" ]]; then
		for commit in $(git rev-list "$range" --not --all); do
			if ! [[ $(git log --max-count=1 --format=%B ${commit}) =~ $msg_regex ]]; then
				echo "ERROR:"
				echo "ERROR: Your push to Master was rejected because the commit"
				echo "ERROR: $commit in ${refname#refs/heads/}"
				echo "ERROR:"
				echo "ERROR: Please fix the commit message and push again."
				echo "ERROR: Example feat: update new feature JAG-0000"
				echo "ERROR"
				exit 1
			fi
		done
	fi
done
