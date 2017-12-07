set ns [new Simulator]

set nf [open out.nam w ]

$ns namtrace-all $nf

proc finish {} {
	global ns nf
	$ns flush-trace
	close $nf
	exec nam out.nam &
	exit 0
}

# Create nodes
set a [$ns node]
set b [$ns node]
set c [$ns node]
set d [$ns node]
for {set i 1} {$i<=3} {set i [expr $i+1]} {set m($i) [$ns node]}

# Data Link
$ns duplex-link $a $b 10Mb 10ms DropTail
$ns duplex-link-op $a $b orient left-down
$ns duplex-link $b $d 10Mb 10ms DropTail
$ns duplex-link-op $b $d orient right-down
$ns duplex-link $c $a 10Mb 10ms DropTail
$ns duplex-link-op $c $a orient left-up
$ns duplex-link $b $c 10Mb 10ms DropTail
$ns duplex-link-op $b $c orient right
## cost
$ns duplex-link $c $m(1) 10Mb 10ms DropTail
$ns duplex-link-op $c $m(1) orient down
$ns duplex-link $m(1) $m(2) 10Mb 10ms DropTail
$ns duplex-link-op $m(1) $m(2) orient down
$ns duplex-link $m(2) $m(3) 10Mb 10ms DropTail
$ns duplex-link-op $m(2) $m(3) orient down
$ns duplex-link $m(3) $d 10Mb 10ms DropTail
$ns duplex-link-op $m(3) $d orient down

# node 1
## transport
set transpTCP1 [new Agent/TCP]
$ns attach-agent $a $transpTCP1
## application
set ftp1 [new Application/FTP]
$ftp1 attach-agent $transpTCP1

# node 4
## transport
set transpTCPSink4 [new Agent/TCPSink]
$ns attach-agent $d $transpTCPSink4

# Connect transport
$ns connect $transpTCP1 $transpTCPSink4

# colorize
## labelize (on play)
$a label "A"
$b label "B"
$c label "C"
$d label "D"
## set shape
$a shape box
$b shape box
$c shape box
$d shape box
## set color 1 to blue
$ns color 1 blue
$ns color 2 red
$transpTCP1 set class_ 1
$transpTCPSink4 set class_ 2

# config dynamic routing protocol DV|LS
$ns rtproto DV
# config simulation
$ns at 1.0 "$ftp1 start"
$ns at 7.0 "$ftp1 stop"
## Cut link between nodes
$ns rtmodel-at 3.48 down $b $d
$ns rtmodel-at 4.95 up $b $d
$ns at 8.0 "finish"

$ns run
