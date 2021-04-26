. "$HOME/.x-cmd/boot" 2>/dev/null || eval "$(curl https://get.x-cmd.com/script)"

. ./v0

ui_check_cmd "Step-1:  Running Sleep 3"     "sleep 5"
ui_check_cmd "Step-2:  Running Sleep 3"     "sleep 1; false"
ui_check_cmd "Step-3:  Running Sleep 3"     "sleep 2; true"
