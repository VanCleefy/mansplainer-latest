#!/bin/bash

############################################################
# Help                                                     #
############################################################
Help() {
  # Display Help
  echo -e "\e[34mAdd description of the script functions here.\e[0m"
  echo
  echo -e "\e[34mSyntax: mansplainer.sh [-a|-d|-r|-l|-i|-b|-L|-D|-h] [OPTIONAL_ARGUMENT]\e[0m"
  echo -e "\e[34moptions:\e[0m"
  echo -e "\e[32m-a     Add a new mansplanation.\e[0m"
  echo -e "\e[32m-q     Ask chatGPT.\e[0m"
  echo -e "\e[32m-d     Delete a specific mansplanation by providing the mansplanation name.\e[0m"
  echo -e "\e[32m-r     Retrieve the contents of a specific mansplanation by providing the mansplanation name.\e[0m"
  echo -e "\e[32m-l     List all available mansplanations.\e[0m"
  echo -e "\e[32m-i     Initialize the directory for mansplanation documents.\e[0m"
  echo -e "\e[32m-b     Create a backup of the mansplanation documents directory.\e[0m"
  echo -e "\e[32m-L     List all available backups.\e[0m"
  echo -e "\e[32m-D     Delete a specific backup by providing the backup name.\e[0m"
  echo -e "\e[32m-h     Display this help message.\e[0m"
  
  echo
}

############################################################
# Main program                                             #
############################################################
# Set variables
dir_path_docs="./mansplainer-docs"
dir_path_backup="./mansplainer-backups"

############################################################
# Process the input options. Add options as needed.        #
############################################################

while getopts "ad:r:liqbLD:h" option; do
  case $option in
  q)
    clear
    echo -e "\e[34m
############################################################
# Query ChatGPT and save the response as a mansplanation   #
############################################################\n\e[0m"
    echo -en "\e[33mEnter your question: \e[0m"
    read -r question
    response=$(curl -X POST "https://api.openai.com/v1/engines/text-davinci-003/completions" \
      -H "Authorization: Bearer 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" \
      -H "Content-Type: application/json" \
      -d '{
        "prompt": "'"${question//\"/\\\"}"'",
        "max_tokens": 100
      }' | jq -r '.choices[].text')
    echo -en "\e[33mEnter the Name of the mansplanation: \e[0m"
    read -r man_name
    echo "$response" > "$dir_path_docs/$man_name"
    echo -e "\n\e[34mResponse from ChatGPT saved as mansplanation: \e[35m$man_name\e[0m\n"
    echo -e "\n\e[34mMansplanation content:\n\e[32m$response\e[0m\n"
    ;;
  a)
    clear
    echo -e "\e[34m
############################################################
# The student has become the teacher and so it is time to  #
# leave your mark on the world, please... mansplain        #
############################################################\n\e[0m"
    echo -en "\e[33mEnter the Name of the mansplanation: \e[0m"
    read -r man_name
    if [[ ! -f "$dir_path_docs/$man_name" ]]; then
      touch "$dir_path_docs/$man_name"

      # Prompt the user for input
      echo -e "\e[33mEnter text (press Ctrl+D to finish):\e[0m"

      echo -e "\n\e[34m Mansplanation \e[35m $man_name \e[34m has been initiated\e[0m\n"
      echo -en "\n\e[34mInput the mansplanation: \e[0m"

      # Read each line of input and append it to the file
      while IFS= read -r line; do
        echo "$line" >>$dir_path_docs/$man_name
      done

      # Print a message indicating the file has been created
      echo -e "\n\e[34mMansplanation complete!\n\e[0m"
    else
      echo -e "\n\e[34mMansplanation already exists: \e[35m $man_name\e[0m\n"
    fi
    ;;
  d)
    clear
    if [[ -n "${OPTARG}" ]]; then
      man_name="${OPTARG}"

      file="$dir_path_docs/$man_name"
      if [[ -f "$file" ]]; then
        rm -f "$file"
        echo -e "\n\e[34mMansplanation: \e[35m$man_name \e[34mhas been deleted.\n"
      else
        echo -e "\n\e[31mMansplanation does not exist: $man_name\e[0m\n"
      fi
    else
      echo -e "\n\e[31mInvalid usage. Please provide the mansplanation name.\e[0m\n"
    fi
    ;;
  r)
    clear
    if [[ -n "${OPTARG}" ]]; then
      mansplanation_name="${OPTARG}"

      file="$dir_path_docs/$mansplanation_name"
      if [[ -f "$file" ]]; then
        contents=$(cat "$file")
        echo -e "\n\e[32m$contents\e[0m\n"
      else
        echo -e "\n\e[31mMansplanation does not exist: $mansplanation_name\e[0m\n"
      fi
    else
      echo -e "\n\e[31mInvalid usage. Please provide the mansplanation name.\e[0m\n"
    fi
    ;;
  l)
    clear
    echo -e "\e[34m
############################################################
# This is a list of all the Mansplanations available.      #
# To add more use the -h (help) option or the -a option    #
############################################################\n\e[0m"

    files=$(ls -l "$dir_path_docs" | awk '{print $9}')

    # Store the filenames in an array
    readarray -t filenames <<<"$files"

    # Calculate the maximum length of filenames
    max_length=0
    for filename in "${filenames[@]}"; do
      length=${#filename}
      if ((length > max_length)); then
        max_length=$length
      fi
    done

    # Calculate the number of columns and column width
    terminal_width=$(tput cols)
    column_width=$((max_length + 2))
    column_count=$((terminal_width / column_width))

    # Display the filenames in columns with green color
    index=0
    for filename in "${filenames[@]}"; do
      printf "\e[32m%-*s\e[0m" "$column_width" "$filename"
      index=$((index + 1))
      if ((index % column_count == 0)); then
        printf "\n"
      fi
    done
    printf "\n\n"
    ;;
  i)
    if [[ ! -d "$dir_path_docs" ]]; then
      mkdir -p "$dir_path_docs"
      echo -e "\e[32mDirectory created: $dir_path_docs\e[0m"
    else
      echo -e "\e[34mDirectory already exists: $dir_path_docs\e[0m"
    fi
    ;;
  b)
    if [[ ! -d "$dir_path_docs" ]]; then
      echo -e "\n\e[30mDirectory \e[35m$dir_path_docs \e[30mdoes not exist\e[0m\n"
    else
      if [[ ! -d "$dir_path_backup" ]]; then
        mkdir -p "$dir_path_backup"
        echo -e "\n\e[32mBackup directory created: $dir_path_backup\e[0m"
      fi
      cp -r "$dir_path_docs/" "$dir_path_backup/$(date +"%Y%m%d_%H%M%S")"
      echo -e "\n\e[34mMansplanation documents directory backed up to: \e[35m$dir_path_backup\e[0m\n"
    fi
    ;;
  L)
    clear
    echo -e "\e[34m
############################################################
# This is a list of all available backups.                  #
############################################################\n\e[0m"

    backups=$(ls -l "$dir_path_backup" | awk '{print $9}')

    # Store the backup names in an array
    readarray -t backup_names <<<"$backups"

    # Calculate the maximum length of backup names
    max_length=0
    for backup_name in "${backup_names[@]}"; do
      length=${#backup_name}
      if ((length > max_length)); then
        max_length=$length
      fi
    done

    # Calculate the number of columns and column width
    terminal_width=$(tput cols)
    column_width=$((max_length + 2))
    column_count=$((terminal_width / column_width))

    # Display the backup names in columns with green color
    index=0
    for backup_name in "${backup_names[@]}"; do
      printf "\e[32m%-*s\e[0m" "$column_width" "$backup_name"
      index=$((index + 1))
      if ((index % column_count == 0)); then
        printf "\n"
      fi
    done
    printf "\n\n"
    ;;
  D)
    clear
    if [[ -n "${OPTARG}" ]]; then
      backup_name="${OPTARG}"

      backup_dir="$dir_path_backup/$backup_name"
      if [[ -d "$backup_dir" ]]; then
        rm -rf "$backup_dir"
        echo -e "\n\e[34mBackup deleted: \e[35m$backup_name\e[0m\n"
      else
        echo -e "\n\e[31mBackup does not exist: $backup_name\e[0m\n"
      fi
    else
      echo -e "\n\e[31mInvalid usage. Please provide the backup name.\e[0m\n"
    fi
    ;;
  h)
    Help
    ;;
  \?)
    echo -e "\n\e[31mInvalid option: -$OPTARG\e[0m\n"
    Help
    ;;
  esac
done


_autocomplete() {
    local cur prev words cword
    _get_comp_words_by_ref -n : cur prev words cword

    local options_with_descriptions=(
        "-a:Add a new mansplanation"
        "-q:Ask chatGPT"
        "-d:Delete a specific mansplanation by providing the mansplanation name"
        "-r:Retrieve the contents of a specific mansplanation by providing the mansplanation name"
        "-l:List all available mansplanations"
        "-i:Initialize the directory for mansplanation documents"
        "-b:Create a backup of the mansplanation documents directory"
        "-L:List all available backups"
        "-D:Delete a specific backup by providing the backup name"
        "-h:Display this help message"
    )

    local options_with_descriptions_formatted=()

    for opt_desc in "${options_with_descriptions[@]}"; do
        option=$(echo "$opt_desc" | cut -d ':' -f 1)
        description=$(echo "$opt_desc" | cut -d ':' -f 2)
        formatted="${option} ${description}"
        options_with_descriptions_formatted+=("$formatted")
    done

    COMPREPLY=("${options_with_descriptions_formatted[@]}")
}

complete -F _autocomplete mansplainer.sh



