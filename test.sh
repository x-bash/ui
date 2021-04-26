. "$HOME/.x-cmd/boot" 2>/dev/null || eval "$(curl https://get.x-cmd.com/script)"

. ./v0

# ui_check_cmd "Step-1:  Running Sleep 3"     "sleep 5"
# ui_check_cmd "Step-2:  Running Sleep 3"     "sleep 1; false"
# ui_check_cmd "Step-3:  Running Sleep 3"     "sleep 2; true"

for i in `seq 0 10 100`; do 
    if [ $i -eq 60 ]; then
        echo -$i
    else
        echo $i
    fi
    sleep 0.2s; 
done | ui_progressbar


for i in `seq 0 10 100`; do 
    echo $i
    sleep 0.2s; 
done | ui_progressbar

