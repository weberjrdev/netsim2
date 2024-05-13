#!/usr/bin/awk -f

{
    sum += $4
    count++
}

END {
    if (count > 0) {
        average = sum / count
        print "Average throughput:", average, "[kbps]"
    } else {
        print "No data found"
    }
}
