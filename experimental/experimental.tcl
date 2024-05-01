# Tcl Experiments by Jacob Weber

set ns [new Simulator]

set nr [open "experimental.tr" w]
$ns trace-all $nr

set nt [open experimental.nam w]
$ns namtrace-all $nt

set n0 [$ns node]
$n0 shape box
$n0 color green

set n1 [$ns node]
$n1 color red

$ns duplex-link $n0 $n1 2Mb 4ms DropTail

set tcp1 [new Agent/TCP]
set sink [new Agent/TCPSink]

$ns attach-agent $n0 $tcp1
$ns attach-agent $n1 $sink

$ns connect $tcp1 $sink

set ftp [new Application/FTP]
$ftp attach-agent $tcp1



proc finish {} {
    global ns nr nt
    $ns flush-trace
    close $nr
    close $nt
    exec nam experimental.nam &
    exit
}

$ns at 0.1 "$ftp start"
$ns at 2.0 "$ftp stop"

$ns at 2.1 "finish"

$ns run

