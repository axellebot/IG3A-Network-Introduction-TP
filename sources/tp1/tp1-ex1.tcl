set ns [new Simulator]

set nf [open tp1_ex1.nam w ]

$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]

# Data Link
$ns duplex-link $n0 $n1 1Mb 10ms DropTail

# node 0
## transport
set transpUDP [new Agent/UDP]
$ns attach-agent $n0 $transpUDP
## application
set cbr [new Application/Traffic/CBR]
$cbr set packetSize_ 500
$cbr set interval_ 5ms
$cbr attach-agent $transpUDP

# node 1
## transport
set transpNull [new Agent/Null]
$ns attach-agent $n1 $transpNull

# connect transportation
$ns connect $transpUDP $transpNull

# config simulation
$ns at 1.0 "$cbr start"
$ns at 4.5 "$cbr stop"
$ns at 5.0 "finish"

$ns run
