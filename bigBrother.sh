#!/bin/bash

TRACK_PATH=$1
#echo "$TRACK_PATH"

if ! [ -d "$TRACK_PATH" ]; then
    >&2 echo "Must include valid path"
    exit 1
fi

shift
TRACK_ITEMS="$@"
#echo "$TRACK_ITEMS"

PREV_FILE_ITEMS_PATH="${TRACK_PATH}/.track_files"
PREV_FOLDER_ITEMS_PATH="${TRACK_PATH}/.track_folders"

FIRST_RUN=false
if [ ! -f "$PREV_FILE_ITEMS_PATH" ] && [ ! -f "$PREV_FOLDER_ITEMS_PATH" ]; then
  echo "Welcome to the Big Brother"
  FIRST_RUN=true
fi

touch "${PREV_FILE_ITEMS_PATH}"
touch "${PREV_FOLDER_ITEMS_PATH}"

SAVE_IFS=$IFS
IFS=$'\n'

if [ -z "$TRACK_ITEMS" ]; then
  TRACK_ITEMS=$(ls "${TRACK_PATH}")
fi

TRACK_ITEMS=(${TRACK_ITEMS})

PREV_FILE_ITEMS=($(cat "$PREV_FILE_ITEMS_PATH"))
#echo "PREV_FILE_ITEMS - ${PREV_FILE_ITEMS[*]}"

PREV_FOLDER_ITEMS=($(cat "$PREV_FOLDER_ITEMS_PATH"))
#echo "PREV_FOLDER_ITEMS - ${PREV_FOLDER_ITEMS[*]}"

CURRENT_FILE_ITEMS=($(ls -p "${TRACK_PATH}" | grep -v /))
#echo "CURRENT_FILE_ITEMS - ${CURRENT_FILE_ITEMS[*]}"

CURRENT_FOLDER_ITEMS=($(ls -p "${TRACK_PATH}" | grep /))
#echo "CURRENT_FOLDER_ITEMS- ${CURRENT_FOLDER_ITEMS[*]}"

IFS=$SAVE_IFS

if [ "$FIRST_RUN" = false ]; then
  for prev_item in "${PREV_FOLDER_ITEMS[@]}"; do
    FOUND=false
    for curr_item in "${CURRENT_FOLDER_ITEMS[@]}"; do
      if [ "$prev_item" = "$curr_item" ]; then
        FOUND=true
        break
      fi
    done
    if [ "$FOUND" = 'false' ]; then
      >&2 echo "Folder deleted: ${prev_item}"
    fi
  done

  for curr_item in "${CURRENT_FOLDER_ITEMS[@]}"; do
      FOUND=false
    for prev_item in "${PREV_FOLDER_ITEMS[@]}"; do
      if [ "$prev_item" = "$curr_item" ]; then
        FOUND=true
        break
      fi
    done
    if [ "$FOUND" = 'false' ]; then
      >&2 echo "Folder created: ${curr_item}"
    fi
  done


  for prev_item in "${PREV_FILE_ITEMS[@]}"; do
    FOUND=false
    for curr_item in "${CURRENT_FILE_ITEMS[@]}"; do
      if [ "$prev_item" = "$curr_item" ]; then
        FOUND=true
        break
      fi
    done
    if [ "$FOUND" = 'false' ]; then
      >&2 echo "File deleted: ${prev_item}"
    fi
  done

  for curr_item in "${CURRENT_FILE_ITEMS[@]}"; do
      FOUND=false
    for prev_item in "${PREV_FILE_ITEMS[@]}"; do
      if [ "$prev_item" = "$curr_item" ]; then
        FOUND=true
        break
      fi
    done
    if [ "$FOUND" = 'false' ]; then
      >&2 echo "File created: ${curr_item}"
    fi
  done
fi

printf "%s\n" "${CURRENT_FOLDER_ITEMS[@]}" > "$PREV_FOLDER_ITEMS_PATH"
printf "%s\n" "${CURRENT_FILE_ITEMS[@]}" > "$PREV_FILE_ITEMS_PATH"
