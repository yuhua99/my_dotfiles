#!/bin/bash

declare -a tasks
tasks=(
  "gitconfig"
  "nvim"
  "tmux"
  "alacritty"
)

################
##  Function  ##
################

gitconfig() {
  AskOption ".gitconfig"
  echo "Remember to change the name and email in .gitconfig file!"
}

nvim() {
  AskOption "nvim" "$HOME/.config"
}

tmux() {
  AskOption ".tmux.conf"
  echo "Remember to install tpm and run prefix + I to install plugins!"
  echo "Remember to copy the tmux-popup.sh to ~/.tmux/"
}

alacritty() {
  AskOption "alacritty" "$HOME/.config"
}

################
##    Main    ##
################

current_path=$(pwd)

CopyToHome()
{
  target=$1
  target_path=$2


  if [[ -e $target_path/$target ]]; then
    echo "File $target_path/$target exists!!"
    printf "Do you want to overwrite it? [y/n]: "
    read answer
    if [[ $answer == "y" ]]; then
      cp -r $current_path/$target $target_path/
      echo "Overwrite $target_path/$target successfully!!"
    else
      echo "Skip $target"
    fi
  else
    cp -r $current_path/$target $target_path/
    echo "Copy $target to $target_path/ successfully!!"
  fi
}

AskOption()
{
  local task=$1
  local target_path=${2:-"$HOME"}

  echo "Please choise an option:"
  echo "  [1] Apply $task"
  echo "  [2] Show diff"
  echo "  [3] Copy $task to here"
  printf "Enter your choice: "
  read option
  case $option in
    1)
      CopyToHome $task $target_path
      ;;
    2)
      if command -v delta >/dev/null 2>&1; then
        echo "Diff between $current_path/$task and $target_path/$task:"
        delta $current_path/$task $target_path/$task
      else
        echo "delta command not found. Please install delta to use this option."
      fi
      ;;
    3)
      if [[ -e $target_path/$task ]]; then
        cp -r $target_path/$task $current_path/
        echo "Copy $target_path/$task to $current_path/ successfully!!"
      else
        echo "$target_path/$task doesn't exists!!"
      fi
      ;;
    *)
      echo "Invalid option!!"
      exit 1
      ;;
  esac
}

AskTask()
{
  if [[ -n "$1" ]]; then
    Num=$1
  else
    echo "Please choice task to do:"
    for ((num=0; num<${#tasks[@]}; num++)); do
      echo -e "  [$((num+1))]\t${tasks[$num]}"
    done
    printf "Enter the number: "
    read Num
  fi

  # Check if the task exists in the tasks array
  if [[ -n "${tasks[$Num-1]}" ]]; then
    ${tasks[$Num-1]}
  else
    echo "Unknown selection!!"
    exit 1
  fi
}

# If the help option is provided, display help and exit
if [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
  displayHelp
  exit 0
fi

AskTask $1

