# fnm
set FNM_PATH "/root/.local/share/fnm"
if test -d "$FNM_PATH"
    fish_add_path "$FNM_PATH"
    fnm env --use-on-cd | source
end
