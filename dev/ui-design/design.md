
```bash
update_ui(){
    ui.seperator
    ui.style info -- Prepare the UI "$percentage"
    ui.progress "$percentage" "$symbol"

    ui.style bold black -- Initializing the storage
    ui.style info -- "$text"
    ui.cowsay Hi Good work
    ui.cowsay "$(ui.style info -- "Hi Good work")"
    ui.seperator
}
```

```bash
update_ui(){
    cat <<A
$(ui.seperator)
$(ui.style info -- Prepare the UI "$percentage")
$(ui.progress "$percentage" "$symbol")

$(ui.style bold black -- Initializing the storage)
$(ui.style info -- "$text")
$(ui.cowsay Hi Good work)
$(ui.cowsay "$(ui.style info -- "Hi Good work")" )
$(ui.seperator)
A
}
```

```bash
update_ui(){
    cat <<A
<seperator/>
<style info> Prepare the UI "$percentage" </style>
<progress :percentage :symbol> </progress>

<style bold black> Initializing the storage </style>
<style info> $text </style>
<cowsay> Hi Good work </cowsay>
<cowsay> <style info> Hi Good work </style> </cowsay>
<seperator/>
A
}
```
