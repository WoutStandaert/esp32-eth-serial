#!/bin/bash

if [ -z "$1" ]; then
    echo -e "Call $0 <esp32 IP address> to run this test"
    exit 1
fi

fifo=/tmp/esp32-eth-echo
cktx=echo_test_tx.txt
ckrx=echo_test_rx.txt

rm -f $fifo
mkfifo $fifo

echo Sending / receiving random data ...

for (( ; ; )); do
    sum $fifo > $cktx &
    sum_pid=$!

    dd if=/dev/urandom bs=1M count=10 2>/dev/null | tee $fifo | nc -N $1 3333 | sum > $ckrx
    wait $sum_pid

    if diff $cktx $ckrx; then
        echo -n .
        continue
    fi

    echo
    echo !!! send and receive data don\'t match !!!
    exit 1
done
