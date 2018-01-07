set ns [new Simulator]

# Config Visualisation Nam
set nf [open tp3.nam w ]
$ns namtrace-all $nf

# Colors
$ns color 1 red
$ns color 2 green
$ns color 3 blue
set colorCount 0

# Ouvertures des fichiers
set f0 [open tp3-out0.tr w ]
set f1 [open tp3-out1.tr w ]
set f2 [open tp3-out2.tr w ]

# Creation des noeuds
## Envoyeur 0
set n0 [$ns node]
## Envoyeur 1
set n1 [$ns node]
## Envoyeur 2
set n2 [$ns node]
## Switch
set n3 [$ns node]
## Recepteur
set n4 [$ns node]

# Creation de liens duplex entre les différents noeuds ( ex : Cable éthernet)
$ns duplex-link $n0 $n3 1Mb 100ms DropTail
$ns duplex-link $n1 $n3 1Mb 100ms DropTail
$ns duplex-link $n2 $n3 1Mb 100ms DropTail
$ns duplex-link $n3 $n4 1Mb 100ms DropTail

# Procedure de fin
proc finish {} {
	global f0 f1 f2
  # Fermeture des flux fichiers
	close $f0
  close $f1
  close $f2

	# Exécution du logiciel xgraph avec les différents résultats
	exec xgraph tp3-out0.tr tp3-out1.tr tp3-out2.tr -geometry 800x400 &

	# Exécution du logiciel nam pour Visualisation
	exec nam tp3.nam &
	exit 0
}

# Créations d'un agent
proc attach-expoo-traffic { node sink size burst idle rate } {

		# Récupération d'une instance du simulateur
  	set ns [Simulator instance]

		# Création d'un agent UDP
    set source [new Agent/UDP]
		# Attache de l'agent au noeud
    $ns attach-agent $node $source

		# Coloriage
		global colorCount
		set colorCount [expr {$colorCount + 1}]
		$source set class_ $colorCount++

		# Création d'un agent de traffic exponentiel et assignation de ses paramètres
    set traffic [new Application/Traffic/Exponential]
    $traffic set packetSize_ $size
    $traffic set burst_time_ $burst
    $traffic set idle_time_ $burst
		$traffic set rate_ $rate

		# Association du traffic source au générateur de traffic
    $traffic attach-agent $source
		# Connexion de la source a l'application récepteur
    $ns connect $source $sink
    return $traffic
}

# Procedure d'écriture des résultats
proc record { } {
    global sink0 sink1 sink2 f0 f1 f2
    set ns [Simulator instance]
		# Temps après lequel la procédure devra être rappelé
    set time 1.0
		# Savoir combien d'octet ont été transmit par les	 récepteurs de traffic (sink)
    set bw0 [$sink0 set bytes_]
    set bw1 [$sink1 set bytes_]
    set bw2 [$sink2 set bytes_]
		# Établir le temps actuel
    set now [$ns now]
		# Calcule de la bande passante (en MBit/s) et écriture des résultats dans les fichiers
    puts $f0 "$now [expr $bw0/$time*8/1000000]"
    puts $f1 "$now [expr $bw1/$time*8/1000000]"
    puts $f2 "$now [expr $bw2/$time*8/1000000]"
		# Réinitiaisation des valeurs des récepteurs de traffic
		$sink0 set bytes_ 0;
    $sink1 set bytes_ 0;
    $sink2 set bytes_ 0;
		# Re-plannification de l'appel à la procédure
    $ns at [expr $now+$time] "record"
}

# Creation des recepteurs de traffic pour monitoré
set sink0 [new Agent/LossMonitor]
set sink1 [new Agent/LossMonitor]
set sink2 [new Agent/LossMonitor]

# Association des récepteurs aux noeud 4
$ns attach-agent $n4 $sink0
$ns attach-agent $n4 $sink1
$ns attach-agent $n4 $sink2

# Attachement des traffics aux noeuds n0, n1, n2 et connexion à 3 récepteurs de traffic sur n4 (créé précédemment)
set source0 [attach-expoo-traffic $n0 $sink0 200 2s 1s 100k]
set source1 [attach-expoo-traffic $n1 $sink1 200 2s 1s 200k]
set source2 [attach-expoo-traffic $n2 $sink2 200 2s 1s 300k]

$ns at 0.0 "record"

# Programmation des événements
$ns at 10.0 "$source0 start"
$ns at 10.0 "$source1 start"
$ns at 10.0 "$source2 start"
$ns at 50.0 "$source0 stop"
$ns at 50.0 "$source1 stop"
$ns at 50.0 "$source2 stop"
$ns at 60.0 "finish"

$ns run
