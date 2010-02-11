#
# a tool to inspect the language model
#

import org.dashnine.preditor.* from: lib/spellutils.jar;
use(^SpellingUtils);

# misc junk
include("lib/dictionary.sl");
global('$__SCRIPT__ $model $rules $dictionary $network $dsize %edits $hnetwork $account $usage $endings $lexdb $trigrams $verbs');
$model      = get_language_model();
$dictionary = dictionary();
$dsize      = size($dictionary);

print("> ");

while $command (readln())
{
   @temp = split('\s+', $command);
   if (size(@temp) == 3)
   {
      println("Trigram " . @temp . " = " . Ptrigram(@temp[0], @temp[1], @temp[2]));
   }
   else if (size(@temp) == 2)
   {
      println("Bigram b, a->b " . @temp . " = " . Pbigram1(@temp[0], @temp[1]) );
      println("Bigram b, b<-a " . @temp . " = " . Pbigram2(@temp[0], @temp[1]) );
   }
   else if (size(@temp) == 1)
   {
      println("Unigram " . @temp . " = " . Pword(@temp[0]));
      println("Count " . @temp . " = " . count(@temp[0]));
   }

   print("> ");
}
