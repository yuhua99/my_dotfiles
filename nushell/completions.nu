# tmux completions
def tmux_sessions [] { (tmux ls | lines | each { |ses| $ses | split row ':' | first }) }

export def "tmux a -t" [sessions: string@tmux_sessions] {
  ^tmux a -t $sessions
}
export def "tmux kill-ses -t" [sessions: string@tmux_sessions] {
  ^tmux kill-ses -t $sessions
}

def git_files [] {
  git status --porcelain --no-renames | lines | each {
    |line|
    {
      staged: ($line | str substring 0..0)
      unstaged: ($line | str substring 1..1)
      file: ($line | str substring 3..)
    }
  }
}
def git_staged_files [] {
  git_files | where {|file| $file.staged =~ "[ADM]" } | get file
}
def git_unstaged_files [] {
  git_files | where {|file| $file.unstaged =~ "[ADM]" } | get file
}
def git_unstaged_untracked_files [] {
  git_files | where {|file| $file.unstaged =~ "[ADM?]" } | get file
}

export def "git add" [files: string@git_unstaged_untracked_files] {
  ^git add $files
}
export def "git restore" [files: string@git_unstaged_files] {
  ^git restore $files
}
export def "git restore --staged" [files: string@git_staged_files] {
  ^git restore --staged $files
}
