#!/usr/bin/perl

$SHVER = '2024.09.04.01';
$shbanner = '
                    ******************************************
                    *              PERLSH                    *
                    *      A simple shell wrapper            *
                    *      Version __SHVER__             *
                    ******************************************
';

$shbanner =~s/__SHVER__/$SHVER/;
print $shbanner;
                    
$codeflag = 0; @code =();

while(1){
	print ">";
	$input = <STDIN>;
	chomp($input);
       if($input !~/[\S]/){ next; }
    $input =~s/^[\s]+//g;

    if($input eq "exit"){ exit; }

# Provide a way to save perl data to the Native shells ENVIRONMENT
   if($input=~/^setenv /){ 
    $input =~s/^setenv //g;
   ($name, $value) = split(/\=/, $input);
   $ENV{$name} = eval $value;
   print "\nSetting $name => $value\n";
   next;
   }
# Provide a way to reload a module.. helpful for custom PM files
  if($input=~/^reload/){ 
    $input =~s/^reload //;
    delete $INC{$input."\.pm"};
     eval "use $input";
    next;
  }

    
# CD is special as we need to use perl chdir to keep up with current dir
   if($input =~/^cd [\S]+$/){
     $input =~s/^cd //;
     chdir($input);
  }

# The following statement attempts to detect select PERL Statements and EVAL them 

 $PERL_KEYWORDS = '^chomp[\S]+$|^@[\S]+.*\=|^\$[\S]+|^use [\S]+|^push|^\%[\S]+.*\=|^print | 
^chop|^chr|^crypt|^fc|^hex|^index|^lc|^lcfirst|^length|^oct|^ord|^pack|^reverse|^rindex|
^sprintf|^substr|^tr\/|^uc|^ufirst|^split|^abs|^atan|^cos|^exp|^int|^rand|^sin|^sqrt|^srand|
^foreach|^keys|^pop|^shift|^unshift|^splice|^values|^\(|^join|^map|^reverse|^sort|
^unpack|^delete|^each|^exists|^unpack|^open|^close|^die|^read|^eval|^write|^opendir|^rename|
^utime|^do|^if.*\(|^localtime|^when|^unless';
$PERL_KEYWORDS=~s/\n//g; 

   if($input =~/$PERL_KEYWORDS/ && !$codeflag){
     eval $input;
     next;
   }

# CALL A SUB ROUTINE
   if($input=~/^\&[\S]+/){ 
     $input=~s/^\&//;
    eval $input; 
    next;
   }

# SAVE the output of the last evaled code block to file
if($input=~/^SAVEOUTPUT/){
 open my $fh, '>', $ENV{"HOME"}.'/.perlsh_stdout' or die $!;
 my $old_fh = select $fh;
 eval $PLSTACK;
 select $old_fh;
 print "Saved output to ~.perlsh_stdout..\n";
}

##### IF there is a PERL TAG then allow for blocks of CODE
      if($input =~/<perl>/){
	      $codeflag=1;
      }
     elsif($input=~/<\/perl>/){
       $codeflag = 0; 
       $PLSTACK = "@code";
       # execute the code array
        eval "@code";
      @code = ();
      next;
     }
     else{
      if($codeflag == 1){   
        push(@code, $input);
         next;
         } else {
          # IF ITS A LEGIT SHELL COMMAND THEN RUN SYSTEM
              system($input);
          }

       }
}
