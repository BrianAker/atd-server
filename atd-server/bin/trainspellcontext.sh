#
# train and test the spellchecker models
#

java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/spell/trainspell.sl trainWithContext

echo "=== CONTEXTUAL DATA ==========================================================================="

java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/spell/test.sl runSpellingContextTest sp_test_wp_context1.txt
java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/spell/test.sl runSpellingContextTest sp_test_wp_context2.txt
java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/spell/test.sl runSpellingContextTest sp_test_gutenberg_context1.txt
java -Xmx3536M -XX:+AggressiveHeap -XX:+UseParallelGC -jar lib/sleep.jar utils/spell/test.sl runSpellingContextTest sp_test_gutenberg_context2.txt

