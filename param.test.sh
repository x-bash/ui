

# Enable config file. 

param '
    org     "Provide organization"
    repo    "Provide work"
    direction=abc "" == abc dec a
    meter=333   ""   =~ [0-9]{1,3}
'

echo $org

O=gitee D='
    org     "Provide organization"
    repo    "Provide work"
    direction=abc "" == abc dec a
    meter=333   ""   =~ [0-9]{1,3}
' param

