#!/bin/bash

random_words () {
    random=$(shuf -i 10-27 -n 1)
    response=$(curl -s "https://random-word-api.herokuapp.com/word?number=$random")

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to fetch data from the API."
        exit 1
    fi  

    if [ -z "$response" ]; then
        echo "ERROR: Empty response from the API."
        exit 1
    fi  

    sentence=$(echo "$response" | jq -r '.[]' | tr '\n' ' ' | sed 's/ $//')

    if [ $? -ne 0 ]; then
        echo "ERROR: Failed to parse JSON."
        exit 1
    fi  

    echo $sentence
}

git_commands () {
    git add $1
    
    CUSTOM_DATE="2026-02-23T12:31:10+01:00"

    export GIT_AUTHOR_DATE="$CUSTOM_DATE"
    export GIT_COMMITTER_DATE="$CUSTOM_DATE"

    git add .
    git commit -m "your message"
    
    unset GIT_AUTHOR_DATE
    unset GIT_COMMITTER_DATE

    git commit -m "Todays contribution: $1"
    git push -u origin main
}

generate_and_push () {
    number=$(($RANDOM%(10-15)+10))

    for ((i=1; i<=number; i++)); do
        timestamp=$(date +%s)
	echo "---"
	echo "Iteration ($i/$number)"
	echo "---"
        echo "$timestamp - $(random_words)" >> $1

    done
}

now=$(date +'%Y-%m-%d')

touch $now.txt

generate_and_push $now.txt

git_commands "$now.txt"
