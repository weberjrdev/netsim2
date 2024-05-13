#!/bin/bash

module load netsim  # After this
echo $APPTAINER_IMAGE
echo $(pwd)
# Number of times to run NS2
num_runs=50

# Loop to run NS2 multiple times
for ((i=1; i<=$num_runs; i++)); do
    echo "Running NS2 simulation #$i"
    which ns
    ns ~/my_cs462/ns-project/radio/shadowing_indoor_opaque_rand.tcl       
    ns ~/my_cs462/ns-project/radio/shadowing_indoor_transparent_rand.tcl       
    ns ~/my_cs462/ns-project/radio/shadowing_outdoor_rand.tcl       

    echo "NS2 simulation #$i completed"
    awk -f awk-scripts/throughput2.awk ~/my_cs462/ns-project/radio/tr-files/shadowing_outdoor_rand.tr >> ~/my_cs462/ns-project/radio/norm-data/outdoor.data
    awk -f awk-scripts/throughput2.awk ~/my_cs462/ns-project/radio/tr-files/shadowing_indoor_opaque_rand.tr >> ~/my_cs462/ns-project/radio/norm-data/indoor_o.data
    awk -f awk-scripts/throughput2.awk ~/my_cs462/ns-project/radio/tr-files/shadowing_indoor_transparent_rand.tr >> ~/my_cs462/ns-project/radio/norm-data/indoor_t.data
done

