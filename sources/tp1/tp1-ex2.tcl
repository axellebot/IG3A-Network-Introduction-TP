set ns [new Simulator]

set nf [open tp1-ex2.nam w ]

$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam tp1-ex2.nam &
	exit 0
}

# Create nodes
set n0 [$ns node]
set n1 [$ns node]
set n2 [$ns node]
set n3 [$ns node]

# Data Link
$ns duplex-link $n0 $n2 2Mb 10ms DropTail
$ns duplex-link-op $n0 $n2 orient right-down
$ns duplex-link $n1 $n2 2Mb 10ms DropTail
$ns duplex-link-op $n1 $n2 orient right-up
$ns duplex-link $n2 $n3 1.7Mb 20ms DropTail
$ns duplex-link-op $n2 $n3 orient right
## Buffer
$ns queue-limit $n2 $n3 10 

# node 0
## transport
set transpTCP0 [new Agent/TCP]
$ns attach-agent $n0 $transpTCP0
## application
set ftp0 [new Application/FTP]
$ftp0 attach-agent $transpTCP0


# node 1
## transport
set transpUDP1 [new Agent/UDP]
$ns attach-agent $n1 $transpUDP1
## application
set cbr1 [new Application/Traffic/CBR]
$cbr1 set packetSize_ 500
$cbr1 set interval_ 5ms
$cbr1 attach-agent $transpUDP1

# node 3
## transport
set transpNull3 [new Agent/Null]
$ns attach-agent $n3 $transpNull3
set transpTCPSink3 [new Agent/TCPSink]
$ns attach-agent $n3 $transpTCPSink3

# Connect transportation
$ns connect $transpUDP1 $transpNull3
$ns connect $transpTCP0 $transpTCPSink3

# colorize			
## set color 1 to blue
$ns color 1 blue
$ns color 2 red
$transpUDP1 set class_ 1
$transpTCP0 set class_ 2

# config simulation
$ns at 0.1 "$cbr1 start"
$ns at 4.0 "$cbr1 stop"
$ns at 1.0 "$ftp0 start"
$ns at 4.5 "$ftp0 stop"

$ns at 5.0 "finish"

$ns run
