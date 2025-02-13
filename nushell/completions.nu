# tmux completions
def tmux_sessions [] { (tmux ls | lines | each { |ses| $ses | split row ':' | first }) }

export def "tmux a -t" [sessions: string@tmux_sessions] {
  ^tmux a -t $sessions
}
export def "tmux kill-ses -t" [sessions: string@tmux_sessions] {
  ^tmux kill-ses -t $sessions
}
