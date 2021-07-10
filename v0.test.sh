
. ./v0

echo "$(ui underline)Rule     Route      Method  Name     $(ui end)"
cat <<A
think    <Cloure>   get     work123  
think    <Cloure>   get     work123  
think    <Cloure>   get     work123  
think    <Cloure>   get     work123  
think    <Cloure>   get     work123  
A

echo "$(ui underline)think    <Cloure>   get     work     $(ui end)"

# echo "$(ui underline)--------------------------------$(ui end)"


table 5 3 2 1 3 4 5
table xx xx xx xx xx xx

table \
    xx xx xx xx xx --\
    yy yy yy yy yy yy --\
    zz zz zz zz zz zz

