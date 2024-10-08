#!/bin/bash
# Coded by Ilhamrzr

make_request() {
    local video_url="$1"
    local user_agent="$2"
    local type="$3"

    local encoded_url=$(echo -n "$video_url" | jq -sRr @uri)
    local api_url="https://mr-apis.com/api/smm/tiktok-${type}?url=${encoded_url}"

    response=$(curl -s -X 'GET' "$api_url" -H "accept: application/json" -A "$user_agent")
    echo "$response"
}

if [[ ! -f "user-agent.txt" ]]; then
    echo "File user-agent.txt tidak ditemukan!"
    exit 1
fi

type=""
video_url=""
list_file=""

while getopts ":s:l:vhl" opt; do
    case $opt in
        s)
            video_url="$OPTARG"
            ;;
        l)
            list_file="$OPTARG"
            ;;
        v)
            type="view"
            ;;
        h)
            type="like"
            ;;
        \?)
            echo "Pilihan tidak valid: -$OPTARG" >&2
            exit 1
            ;;
        :)
            echo "Opsi -$OPTARG memerlukan argumen." >&2
            exit 1
            ;;
    esac
done

if [[ -z "$type" ]]; then
    echo "Gunakan: $0 -v -s <url> untuk single views, -h -s <url> untuk single like, -v -l <list.txt> untuk daftar views, atau -h -l <list.txt> untuk daftar like"
    exit 1
fi

if [[ -n "$video_url" ]]; then
    user_agent=$(shuf -n 1 user-agent.txt)
    make_request "$video_url" "$user_agent" "$type"
fi

if [[ -n "$list_file" ]]; then
    if [[ -f "$list_file" ]]; then
        while IFS= read -r video_url; do
            user_agent=$(shuf -n 1 user-agent.txt)
            make_request "$video_url" "$user_agent" "$type"
            sleep 900
        done < "$list_file"
    else
        echo "File $list_file tidak ditemukan!"
        exit 1
    fi
fi
