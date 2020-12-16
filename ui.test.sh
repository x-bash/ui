#! /usr/bin/env bash

# xrc ./ui
. ./ui

# $(ui.cowsay "$(ui.style info -- "$text")")
# $(ui.cowsay "$text")

update_ui(){
    cat <<A
$(ui.seperator)
$(ui.style info -- Prepare the UI "$percentage")
$(ui.progress "$percentage" "$symbol")

$(ui.style bold black -- Initializing the storage)
$(ui.style info -- "$text")
$(ui.cowsay Hi Good work)
$(ui.seperator)
A
}

main(){

    local percentage text
    ui.region.start

    for ((percentage=0; percentage+=10; percentage < 100)); do

        # Do the logic
        case $(( percentage / 10 % 2 )) in
            0) text="Important to say: Percentage is even.
1
2"
;;
            1) text="Hia hia. Percentage is odd.
hi";;
        esac

        # Update the UI
        ui.region.reset \
            symbol="*" update_ui

        if [ "$percentage" -ge 100 ]; then
            break
        fi

        sleep 1s
    done

}

main


