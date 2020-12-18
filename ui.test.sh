#! /usr/bin/env bash

# xrc ./ui
. ./ui

# $(ui.cowsay "$(ui.style info -- "$text")")
# $(ui.cowsay "$(ui.style info -- "Hi Good work")" )
# $(ui.cowsay "$text")
# $(ui.cowsay "$(ui.style info -- "Hi Good work")" )
# $(ui.cowsay "$(ui.style info -- "Hi Good work")" )


update_ui(){
    cat <<A
$(ui.seperator)
$(ui.style $style -- Initializing the storage)
$(ui.style info -- Prepare the UI "$percentage")
$(ui.progress "$percentage" "$symbol")

$(ui.style bold black -- Initializing the storage)
$(ui.cowsay "$(ui.style warn -- "Hi Good work")" )
$(ui.cowsay Hi Good work)
$(ui.style info -- "$text")
$(ui.seperator)
A
}

main(){

    local percentage text
    ui.region.init

    for ((percentage=0; percentage+=4; percentage < 100)); do

        # Do the logic
        case $(( percentage / 10 % 2 )) in
            0) 
            style=warn
            text="Important to say: Percentage is even.
1
2"
;;
            1) 
            style=error
            text="Hia hia. Percentage is odd.
hi";;
        esac

        # Update the UI
        ui.region.update \
            symbol="*" update_ui

        if [ "$percentage" -ge 100 ]; then
            break
        fi

        sleep 0.01s
    done

}

main


