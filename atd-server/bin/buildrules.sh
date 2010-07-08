#
# This script creates the AtD rules
#

java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/rules/rules.sl
