##################################################################
#	    Setting the Default Parameters			 #
##################################################################

set val(chan)		Channel/WirelessChannel
set val(rayprop)	Propagation/TwoRayGround
set val(freeprop)	Propagation/FreeSpace
set val(shadprop)	Propagation/Shadowing
set val(netif)		Phy/WirelessPhy
set val(mac)            Mac/802_11

set val(a_height) 1.5
set val(freq) 2.4GHz
set val(power) 0.1W
set val(rThresh) 2.0mW

set val(ifq)		Queue/DropTail/PriQueue
#set val(ifq)		Queue/RED
#set val(ifq) 		CMUPriQueue; 
# Wired Interface queue type DropTail, RED, CBQ, FQ, SFQ, DRR, diffserv RED queues
# Wireless Interface queue type Queue/DropTail/PriQueue, CMUPriQueue

set val(ll)		LL
set val(ant)            Antenna/OmniAntenna
set val(x)		1000	
set val(y)		1000	
set val(ifqlen)		50		
set val(nn)		2		
set val(stop)		10.0		
set val(rp)             AODV       

##################################################################
#	    Creating New Instance of a Scheduler		 #
##################################################################

set ns_		[new Simulator]

##################################################################
#		Creating Trace files				 #
##################################################################

set tracefd	[open tr-files/shadowing.tr w]
$ns_ trace-all $tracefd

##################################################################
#	        Creating NAM Trace files			 #
##################################################################

set namtrace [open nam-files/shadowing.nam w]
$ns_ namtrace-all-wireless $namtrace $val(x) $val(y)

set prop	[new $val(shadprop)]

#$prop set pathlossExp_ 2.0
#$prop set std_db_ 4.0
#$prop set dist0_ 1.0
#$prop seed predef 0

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
			 -propInstance $prop \
			 -phyType $val(netif) \
			 -channelType $val(chan) \
			 -topoInstance $topo \
			 -agentTrace ON \
			 -routerTrace ON \
			 -macTrace ON

#$ns_ node-config -adhocRouting OFF
#$ns_ node-config -propagationModel FreeSpace/Shadowing

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
#		Configuring Nodes				 	 #
##################################################################

$node_(0) set X_ 258
$node_(0) set Y_ 500
$node_(0) set antennaHeight_ a_height  ;# Antenna height
$node_(0) set frequency_ freq        ;# Frequency
$node_(0) set Pt_ power                 ;# Transmit Power
$node_(0) set RxThresh_ rThresh          ;# Receive Threshold

$node_(1) set X_ 400
$node_(1) set Y_ 500
$node_(1) set antennaHeight_ a_height  ;# Antenna height
$node_(1) set frequency_ freq        ;# Frequency
$node_(1) set Pt_ power                 ;# Transmit Power
$node_(1) set RxThresh_ rThresh          ;# Receive Threshold

#$node_(2) set antennaHeight_ a_height  ;# Antenna height
#$node_(2) set frequency_ freq        ;# Frequency
#$node_(2) set Pt_ power                 ;# Transmit Power
#$node_(2) set RxThresh_ rThresh          ;# Receive Threshold

##################################################################
#		Topology Design				 	 #
##################################################################



$ns_ at 0.1 "$node_(0) setdest 250.0 500.0 1000.0"
$ns_ at 0.1 "$node_(1) setdest 450.0 500.0 1000.0"
$ns_ at 1.0 "$node_(1) setdest 500.0 500.0 1000.0"
$ns_ at 1.5 "$node_(1) setdest 530.0 500.0 1000.0"


##################################################################
#		Generating Traffic				 #
##################################################################

set tcp0 [new Agent/TCP]
set sink0 [new Agent/TCPSink]
$ns_ attach-agent $node_(1) $tcp0
$ns_ attach-agent $node_(0) $sink0
$ns_ connect $tcp0 $sink0
set ftp0 [new Application/FTP]
$ftp0 attach-agent $tcp0
$ns_ at 0.2 "$ftp0 start" 
$ns_ at 9.0 "$ftp0 stop"

#set tcp1 [new Agent/TCP]
#set sink1 [new Agent/TCPSink]
#$ns_ attach-agent $node_(1) $tcp1
#$ns_ attach-agent $node_(0) $sink1
#$ns_ connect $tcp1 $sink1
#set ftp1 [new Application/FTP]
#$ftp1 attach-agent $tcp1
#$ns_ at 1.0 "$ftp1 start"
#$ns_ at 1.6 "$ftp1 stop"

#set tcp1 [new Agent/TCP]
#set sink1 [new Agent/TCPSink]
#$ns_ attach-agent $node_(1) $tcp1
#$ns_ attach-agent $node_(0) $sink1
#$ns_ connect $tcp1 $sink1
#set ftp1 [new Application/FTP]
#$ftp1 attach-agent $tcp1
#$ns_ at 1.8 "$ftp1 start" 
#$ns_ at 2.4 "$ftp1 stop"

##################################################################
#		Simulation Termination				 #
##################################################################

for {set i 0} {$i < $val(nn) } {incr i} {
    $ns_ at $val(stop) "$node_($i) reset";
}
$ns_ at $val(stop) "puts \"NS EXITING...\" ; $ns_ halt"

puts "Starting Simulation..."

$ns_ run
