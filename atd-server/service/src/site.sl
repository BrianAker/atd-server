debug(7 | 34);

include("lib/quality.sl");
include("lib/engine.sl");

if (-exists "local.sl")
{
   sub service_init { }
   include("local.sl");
}

global('$lang');

$lang = systemProperties()["atd.lang"];
if ($lang ne "" && -exists "lang/ $+ $lang $+ /load.sl")
{ 
   include("lang/ $+ $lang $+ /load.sl"); 
}

sub data
{
   local('$data');

   $data = [$session getSharedData];

   if ($data is $null)
   {
      $data = wait(fork(
      {
         local('$f');
         $f = lambda(
         {
            this('%shared $temp');

            local('$start');
           
            $start = ticks();

            warn("Working to load models...");

            global('$__SCRIPT__ $model $rules $dictionary $network $dsize %edits $hnetwork $usage $endings $lexdb $trigrams $verbs $locks $trie $lang');

            $lang = systemProperties()["atd.lang"];
            if ($lang ne "" && -exists "lang/ $+ $lang $+ /load.sl")
            { 
               include("lang/ $+ $lang $+ /load.sl"); 
            }

            $locks      = semaphore(1);
            initAllModels();

            $usage      = %(__last => ticks());

            warn("Models loaded in " . (ticks() - $start) . "ms");

            %shared = %(model => $model, dictionary => $dictionary, rules => $rules, network => $network, hnetwork => $hnetwork, 
                        edits => %edits, size => $dsize, usage => $usage, endings => $endings, lexdb => 
                        $lexdb, trigrams => $trigrams, verbs => $verbs, locks => $locks, trie => $trie);
   
            while (1)
            {
               if ($0 eq "edits")
#               if ($0 eq "context" || $0 eq "edits")
               {
                  $temp = ohasha();

                  setRemovalPolicy($temp,
                  lambda({
                      return iff([[$1 getData] size] > 128);
                  }));

                  setMissPolicy($temp, lambda({
                      local('$v');
                      acquire($typel);
                      $v = $source[$2];
                      release($typel);
                      return $v;
                  }, $source => %shared[$0], $typel => %shared["locks"]));

                  yield $temp;
               }
               else
               {
                  yield %shared[$0];
               }
            }
         });

         [$f rules];
         return $f;
      }));

      [$session setSharedData: $data];
   }
   return $data;
}

acquire([$session getSiteLock]);
   global('$__SCRIPT__ $model $rules $dictionary $network $dsize %edits $hnetwork $usage $endings $lexdb $trigrams $verbs $locks $trie');
   $dictionary = [data() dictionary]; 
   $model      = [data() model];    # this is safe to load for any session
   $rules      = [data() rules];
   $network    = [data() network];
   $hnetwork   = [data() hnetwork];
   %edits      = [data() edits];
   $dsize      = [data() size];
   $usage      = [data() usage];
   $endings    = [data() endings];
   $lexdb      = [data() lexdb];
   $trigrams   = [data() trigrams];
   $verbs      = [data() verbs];
   $locks      = [data() locks];
   $trie       = [data() trie];
release([$session getSiteLock]);

[$session addHook: "/checkDocument", 
{
   local('$data');
   $data = stripHTML(%parms["data"]);
   display("view/service.slp", processDocument($data));
   return %(Content-type => "text/xml");
}];

[$session addHook: "/stats",
{
   local('$data');

   $data = stripHTML(%parms['data']);
   display("view/quality.slp", processDocumentQuality($data));

   return %(Content-type => "text/xml");     
}]; 

[$session addHook: "/verify",
{
   println('valid');
}];

[$session addHook: "/info.slp",
{
   local('$rule');
   $rule = copy( processSingle(%parms["text"], iff("tags" in %parms, %parms["tags"], $null)) );

   if ($rule is $null)
   {
      warn("Null rule: " . %parms);
      return;
   }

   $rule['rule'] = strrep($rule['rule'], 'Cliches', 'Clich&eacute;s');

   if (%parms["theme"] eq "wordpress")
   {
      display("view/wordpress_gen.slp", $rule, %parms["text"]);
   }
   else if (%parms["theme"] eq "tinymce")
   {
      display("view/wordpress_gen.slp", $rule, %parms["text"]);
   }
   else
   {
      display("view/rule.slp", $rule, %parms["text"]);
   }
}];

service_init();
