set ns [new Simulator]

set nf [open tp2_ex1.nam w ]

$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

# Create nodes
for {set i 1} {$i<=8} {set i [expr $i+1]} {set n($i) [$ns node]}

# Data Link
$ns duplex-link $n(1) $n(3) 10Mb 10ms DropTail
$ns duplex-link-op $n(1) $n(3) orient right-down
$ns duplex-link $n(3) $n(2) 10Mb 10ms DropTail
$ns duplex-link-op $n(3) $n(2) orient right-up
$ns duplex-link $n(3) $n(4) 10Mb 10ms DropTail
$ns duplex-link-op $n(3) $n(4) orient right-down
$ns duplex-link $n(3) $n(5) 10Mb 10ms DropTail
$ns duplex-link-op $n(3) $n(5) orient left-down
$ns duplex-link $n(4) $n(6) 10Mb 10ms DropTail
$ns duplex-link-op $n(4) $n(6) orient right
$ns duplex-link $n(5) $n(8) 10Mb 10ms DropTail
$ns duplex-link-op $n(5) $n(8) orient down
$ns duplex-link $n(8) $n(7) 10Mb 10ms DropTail
$ns duplex-link-op $n(8) $n(7) orient right
$ns duplex-link $n(7) $n(6) 10Mb 10ms DropTail

# node 1
## transport
set transpUDP1 [new Agent/UDP]
$ns attach-agent $n(1) $transpUDP1
## application
set cbr1 [new Application/Traffic/CBR]
$cbr1 attach-agent $transpUDP1

# node 2
## transport
set transpUDP2 [new Agent/UDP]
$ns attach-agent $n(2) $transpUDP2
## application
set cbr2 [new Application/Traffic/CBR]
$cbr2 attach-agent $transpUDP2

# node 8
## transport
set transpNull8 [new Agent/Null]
$ns attach-agent $n(8) $transpNull8

# Connect transportation
$ns connect $transpUDP1 $transpNull8
$ns connect $transpUDP2 $transpNull8

# colorize			
## set color 1 to blue
$ns color 1 blue
$ns color 2 red
$transpUDP1 set class_ 1
$transpUDP2 set class_ 2

$ns rtproto LS
# config simulation
$ns at 1.0 "$cbr1 start"
$ns at 7.0 "$cbr1 stop"
$ns at 2.0 "$cbr2 start"
$ns at 6.0 "$cbr2 stop"
## Cut link between nodes
$ns rtmodel-at 4.0 down $n(5) $n(8)
$ns rtmodel-at 5.0 up $n(5) $n(8)
$ns at 8.0 "finish"

$ns run
