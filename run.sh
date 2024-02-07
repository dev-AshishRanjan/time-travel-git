#!/bin/bash

if [ "$#" -lt 3 ] || [ "$#" -gt 4 ]; then
    echo "Usage: $0 <username> <repo> <no._of_days> <past?:optoinal>"
    exit 1
fi

USERNAME="$1"
USERID=""
REPO="$2"

CURRENT_DAY=$3
PAST=${4:- true}
DAY_APPEND=""
TEMPLATE_DIR="Template"
DATABASE_DIR="database"
DATA_FILE="$DATABASE_DIR/data.yaml"
# FETCH_DATA=$1

if $PAST; then
    DAY_APPEND=""
else
    DAY_APPEND=".5"
fi

initialize_git_and_add_templates() {
    # Initialize Git
    if [ -d ".git" ]; then
        echo "Repository is already initialized. Skipping initialization."
        git checkout -b dev
        copy_template_files "$TEMPLATE_DIR" "./"
        return
    fi
    rm -rf .git
    git init
    git checkout -b dev
    copy_template_files "$TEMPLATE_DIR" "./"
}

copy_template_files() {
    local source="$1"
    local destination="$2"

    
    # Copy files from source to destination
    for item in "$source"/*; do
        local item_name=$(basename "$item")
        local target="$destination/$item_name"
        if [ ! -e "$target" ]; then
            if [ "$item_name" = "node_modules" ]; then
                continue  # Skip the node_modules directory
            fi
            if [ -d "$item" ]; then
                mkdir -p "$target"
                copy_template_files "$item" "$target"
            else
                cp "$item" "$target"
                # Commit files for the current directory
                local RANDOM_NUMBER=$((RANDOM + 1))
                local date="$((CURRENT_DAY))$DAY_APPEND.days.$((RANDOM_NUMBER%3)).hours.$((RANDOM_NUMBER%60)).minutes.$((RANDOM_NUMBER%60)).seconds.ago"
                local message="chore: add $item_name"
                echo "$date"
                git add $target
                git commit --date=format:relative:"$date" --author="$USERNAME < $USERID+$USERNAME@users.noreply.github.com>" -m "$message"
                ((CURRENT_DAY--))
            fi
        fi
    done
}

fetch_and_append_users_data() {
    local fetchdays=$((CURRENT_DAY*10))
    local url="https://api.github.com/users?per_page=100"
    local response=""
    while(($fetchdays > 1)); do
        response+=$(curl -s "$url")
        ((fetchdays-=100))
    done

    # Parse JSON response and extract required fields
    local id_list=($(echo "$response" | grep -oP '"id":\s*\K\d+'))
    local logins=($(echo "$response" | grep -oP '(?<="login": ")[^"]*'))
    local html_urls=($(echo "$response" | grep -oP '(?<="html_url": ")[^"]*'))
    local avatar_urls=($(echo "$response" | grep -oP '(?<="avatar_url": ")[^"]*'))

    # Check if data.yaml file exists, if not, create it with initial YAML structure
    if [ ! -f "$DATA_FILE" ]; then
        echo "[]" > "$DATA_FILE"
    fi

    # git checkout -b  users-update
    # Loop through extracted data and append it to the data.yaml file
    for ((i=0; i<${#logins[@]}&&CURRENT_DAY>=0; i++)); do
        local RANDOM_NUMBER=$((RANDOM + 1))
        local date="$((CURRENT_DAY))$DAY_APPEND.days.$((RANDOM_NUMBER%3)).hours.$((RANDOM_NUMBER%60)).minutes.$((RANDOM_NUMBER%60)).seconds.ago"
        local message="chore: add data for ${logins[i]}"

        # Append fetched data to the data.yaml file
        # echo "---" >> "$DATA_FILE"
        echo "- id: ${id_list[i]}" >> "$DATA_FILE"
        echo "  login: ${logins[i]}" >> "$DATA_FILE"
        echo "  html_url: ${html_urls[i]}" >> "$DATA_FILE"
        echo "  avatar_url: ${avatar_urls[i]}" >> "$DATA_FILE"
        
        git add "$DATA_FILE"
        git commit --date=format:relative:"$date" --author="$USERNAME < $USERID+$USERNAME@users.noreply.github.com>" -m "$message"
        
        # ((CURRENT_DAY--))
        ((CURRENT_DAY=CURRENT_DAY-(RANDOM % 2)))
        # echo $CURRENT_DAY
        # if $((RANDOM % 2 == 0)); then
        #     ((i--))
        # fi
    done

    # git checkout dev
    # git merge users-update dev
}

fetch_github_user(){
    local url="https://api.github.com/users/$USERNAME"
    local response=$(curl -s "$url")
    echo $response
    # Parse JSON response and extract required fields
    USERID=($(echo "$response" | grep -oP '"id":\s*\K\d+'))
    echo $USERID
}

push_to_remote(){
    # git checkout dev
    git remote add origin  https://github.com/$USERNAME/$REPO.git
    # git pull origin dev
    git config user.email $USERID+$USERNAME@users.noreply.github.com
    git config user.name $USERNAME
    git push --no-verify origin dev -f
}

# fetch userid
fetch_github_user


# repo initilize
# git checkout -b  repo-init
initialize_git_and_add_templates
# git checkout dev
# git merge repo-init
echo "Initialization complete."
git log --graph --oneline --decorate

# data fetching
# git checkout -b  users-update
fetch_and_append_users_data
# git checkout dev
# git merge users-update

# push
push_to_remote
git log --graph --oneline --decorate