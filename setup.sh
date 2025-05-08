#!/bin/bash

declare -a tasks
tasks=(
  "gitconfig"
  "nvim"
  "tmux"
  "alacritty"
  "nushell"
  "mcphub"
  "starship"
)

################
##  Function  ##
################

gitconfig() {
  CopyToHome ".gitconfig"
  echo "Remember to change the name and email in .gitconfig file!"
}

nvim() {
  CopyToHome "nvim" "$HOME/.config"
}

tmux() {
  CopyToHome ".tmux.conf"
  mkdir -p "$HOME/.tmux"
  cp "$current_path/tmux-popup.sh" "$HOME/.tmux/"
  echo "Remember to install tpm and run prefix + I to install plugins!"
}

alacritty() {
  CopyToHome "alacritty" "$HOME/.config"
}

nushell() {
  CopyToHome "nushell" "$HOME/.config"
}

mcphub() {
  CopyToHome "mcphub" "$HOME/.config"
  echo "Remember to update the api key in servers.json file"
}

starship() {
  CopyToHome "starship.toml" "$HOME/.config"
}

################
##    Main    ##
################

current_path=$(pwd)

CopyToHome() {
  local target=$1
  local target_path=${2:-"$HOME"}

  if [[ -e $target_path/$target ]]; then
    echo "File $target_path/$target exists!!"
    printf "Do you want to proceed with backup? [y/n]: "
    read answer
    if [[ $answer == "y" ]]; then
      if mv $target_path/$target "$target_path/$target-bak"; then
        echo "File backup to $target_path/$target-bak successfully!!"
      else
        echo "Failed to backup $target_path/$target"
        echo "Aborting..."
        return 1
      fi
    else
      echo "Skip $target"
    fi
  fi

  if ln -s "$current_path/$target" "$target_path/"; then
    echo "Link $target to $target_path/ successfully!!"
  else
    echo "Failed to link $target to $target_path/" >&2
  fi
}

AskTask() {
  if [[ -n "$1" ]]; then
    Num=$1
  else
    echo "Please choice task to do:"
    for ((num = 0; num < ${#tasks[@]}; num++)); do
      echo -e "  [$((num + 1))]\t${tasks[$num]}"
    done
    printf "Enter the number: "
    read Num
  fi

  # Check if the task exists in the tasks array
  if [[ -n "${tasks[$Num - 1]}" ]]; then
    ${tasks[$Num - 1]}
  else
    echo "Unknown selection!!"
    exit 1
  fi
}

AskTask $1
