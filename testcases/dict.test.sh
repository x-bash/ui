. dict

dict.make a

for i in $(seq 3); do
    O=a dict.push $i $i
done

for i in $(seq 3); do
    O=a dict.get $i
done
