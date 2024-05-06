##################################################################
#		Setting RED Parameters				 #
##################################################################

Queue/RED set thresh_ 5
Queue/RED set maxthresh_ 15
Queue/RED set q_weight_ 0.001
Queue/RED set bytes_ false
Queue/RED set queue_in_bytes_ false
Queue/RED set gentle_ false
Queue/RED set mean_pktsize_ 1000
Queue/RED set setbit_ true
Queue/RED set old_ecn_ true
#Queue/RED set use_mark_p_ true

##################################################################
#	    Setting the Default Parameters			 #
##################################################################

set val(chan)		Channel/WirelessChannel
set val(rayprop)	Propagation/TwoRayGround
set val(freeprop)	Propagation/FreeSpace
set val(shadprop)	Propagation/Shadowing
set val(netif)		Phy/WirelessPhy
set val(mac)            Mac/802_11

set val(ifq)		Queue/DropTail/PriQueue
#set val(ifq)		Queue/RED
#set val(ifq) 		CMUPriQueue; 
# Wired Interface queue type DropTail, RED, CBQ, FQ, SFQ, DRR, diffserv RED queues
# Wireless Interface queue type Queue/DropTail/PriQueue, CMUPriQueue

set val(ll)		LL
set val(ant)            Antenna/OmniAntenna
set val(x)		500	
set val(y)		500	
set val(ifqlen)		50		
set val(nn)		9		
set val(stop)		10.0		
set val(rp)             AODV       

##################################################################
#	    Creating New Instance of a Scheduler		 #
##################################################################

set ns_		[new Simulator]

##################################################################
#		Creating Trace files				 #
##################################################################

set tracefd	[open 002.tr w]
$ns_ trace-all $tracefd

##################################################################
#	        Creating NAM Trace files			 #
##################################################################

set namtrace [open 002.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop	[new $val(freeprop)]

set topo	[new Topography]
$topo load_flatgrid $val(x) $val(y)

create-god $val(nn)

##################################################################
#	                 802.11b Settings			 #
##################################################################

#Phy/WirelessPhy set freq_ 2.4e+9
#Mac/802_11 set dataRate_ 11.0e6 

##################################################################
#	                 802.11g Settings			 #
##################################################################

Phy/WirelessPhy set freq_ 2.4e+9
Phy/WirelessPhy set RXThresh_ 1000
Mac/802_11 set dataRate_ 54.0e6                   
        
##################################################################
#		Node Configuration				 #
##################################################################

        $ns_ node-config -adhocRouting $val(rp) \
			 -llType $val(ll) \
			 -macType $val(mac) \
			 -ifqType $val(ifq) \
			 -ifqLen $val(ifqlen) \
			 -antType $val(ant) \
			 -propType $val(freeprop) \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON

##################################################################
#		Creating Nodes					 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
     set node_($i) [$ns_ node]	
     $node_($i) random-motion 0	
}


##################################################################
#		Initial Positions of Nodes			 #
##################################################################

for {set i 0} {$i < $val(nn)} {incr i} {
	$ns_ initial_node_pos $node_($i) 40
}

##################################################################
#		Topology Design				 	 #
##################################################################

$ns_ at 0.1 "$node_(0) setdest 400.0 400.0 2000.0"
$ns_ at 0.1 "$node_(1) setdest 10.0 160.0 2000.0"
$ns_ at 0.1 "$node_(2) setdest 160.0 310.0 2000.0"
$ns_ at 0.1 "$node_(3) setdest 310.0 160.0 2000.0"
$ns_ at 0.1 "$node_(4) setdest 160.0 10.0 2000.0"
$ns_ at 0.1 "$node_(5) setdest 85.0 235.0 2000.0"
$ns_ at 0.1 "$node_(6) setdest 235.0 235.0 2000.0"
$ns_ at 0.1 "$node_(7) setdest 85.0 85.0 2000.0"
$ns_ at 0.1 "$node_(8) setdest 235.0 85.0 2000.0"


##################################################################
#		Generating Traffic				 #
##################################################################
#$ns_ node-config -ifqType Queue/RED

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp0
$ns_ attach-agent $node_(0) $sink0
$ns_ connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns_ at 1.0 "$ftp0 start" 
$ns_ at 2.0 "$ftp0 stop"

#$ns_ node-config -ifqType Queue/RED
$ns_ node-config -propType $val(rayprop)


set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp1
$ns_ attach-agent $node_(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 3.0 "$ftp1 start" 
$ns_ at 4.0 "$ftp1 stop"

$ns_ node-config -propType $val(shadprop)

set tcp1 [new Agent/TCP]
set sink1 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp1
$ns_ attach-agent $node_(0) $sink1
$ns_ connect $tcp1 $sink1
set ftp1 [new Application/FTP]
$ftp1 attach-agent $tcp1
$ns_ at 5.0 "$ftp1 start" 
$ns_ at 6.0 "$ftp1 stop"

##################################################################
#		Simulation Termination				 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."

$ns_ run
