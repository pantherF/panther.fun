#!/bin/bash

date="$1"

if [ -z "$1" ]; then
    now=$(date +'%Y-%m-%d')
    echo "WARN: No date provided. Defaulting to today: $now"
    date=$now
fi

echo $date

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
    git status

    CUSTOM_DATE="${date}T12:31:10+01:00"
    
    export GIT_AUTHOR_DATE="$CUSTOM_DATE"
    export GIT_COMMITTER_DATE="$CUSTOM_DATE"
    
    git add $1
    
    git commit -m "Todays contribution: $1"
    git push -u origin main
    
    unset GIT_AUTHOR_DATE
    unset GIT_COMMITTER_DATE
}

write_word_to_file () {
    timestamp=$(date +%s)
    echo "Writing random words to todays file"
    echo "$timestamp - $(random_words)" >> $1
}

touch $date.txt

number=$(($RANDOM% 3 + 1))

for ((i=1; i<=number; i++)); do
    echo "---"
    echo "Iteration ($i/$number)"
    echo "---"

    write_word_to_file "$date.txt"
    git_commands "$date.txt"
done
#echo "${now}T12:31:10+01:00"
