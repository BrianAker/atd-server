#
# generates the probability of the context file
#

debug(debug() | 7 | 34);

global('$stream $entry $handle $data $count $key $value $key1 $value1 %value $enum');
$count = 0L;

import java.util.zip.*;
import java.io.*;

$stream = [new ZipFile: "models/corpus.zip"];
$enum   = [$stream entries];

while ([$enum hasMoreElements] == 1)
{
   $entry = [$enum nextElement];

   if ([$entry isDirectory])
   {
   }
   else
   {
      $handle = [SleepUtils getIOHandle: [$stream getInputStream: $entry], $null];
      $data   = readObject($handle);
      closef($handle);

      foreach $key => $value ($data)
      {
         $count += $value;       
      }
   }
}
println($count);
