source ./ui

update_ui(){

    cat <<-A
$(ui.style info -- Prepare the UI "$1")
# $(ui.progress "$1")
$(ui.style bold black -- Initializing the storage)
A
}

i=-1
ui.cursor.save

while true; do

    # Do the logic
    (( i++ ))
    
    # Update the UI
    ui.cursor.restore
    update_ui $(( i * 10 ))

    if [ "$i" -ge 10 ]; then
        break
    fi

    sleep 1s
done


