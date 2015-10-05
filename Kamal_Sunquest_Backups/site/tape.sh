lsdev -C > tape
awk '/rmt/ {print}' tape > tapes
