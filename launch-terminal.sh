# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# initialize terminal when started in VSCode, script is called in settings.json
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
# 
# probe whether terminal is opened on Mac with zsh and
# source $HOME/.zshrc for zsh (Mac) or $HOME/.bashrc otherwise
type setopt 2>/dev/null | grep builtin >/dev/null
[ $? = 0 ] && \
    source ~/.zshrc ||
    source ~/.bashrc
# 
# On Windows, change default code page (437) to UTF-8 (65001), see:
# https://superuser.com/questions/269818/change-default-code-page-of-windows-console-to-utf-8/269857#269857
type chcp.com 2>/dev/null | grep "chcp.com" >/dev/null
[ $? = 0 ] && \
    chcp.com 65001
# 
# source the project when a new terminal is opened in VSCode
for env in "env.sh" ".env/env.sh"; do
    [ -f "$env" ] && builtin source "$env" && break
done
