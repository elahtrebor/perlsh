# perlsh
```
A simple perl shell wrapper that helps integrate perl code into the existing native shell
Note: This is toy test code but may be expanded upon.

This shell has a very simple rule set:
 1. read data while in a loop from the user
 2. If the input starts with a perl keyword then EVAL the statement.
 3. if the input starts with the PERL function '&' sign then Execute the function.
 4. If the input starts with a PERL TAG IE: <PERL> then keep buffering the input until </PERL> end tag is reached and then eval the input as a block of code.
 5. Otherwise if doesnt match PERL syntax then treat the statement as a SHELL statement and run SYSTEM.

It also allows saving the output of the last evaled statement to file and setting SHELL environmental variables.

Its best to use rlwrap -c ./perlsh.pl  to get tab completion and command line history.
Example test drive:


                    ******************************************
                    *              PERLSH                    *
                    *      A simple shell wrapper            *
                    *      Version 2024.09.04.01             *
                    ******************************************
>


>ls
file1.txt
file2.txt
perlsh.pl

>ps -ef|grep -i perl
  501 97669 94929   0  6:22PM ttys000    0:00.03 /usr/bin/perl ./perlsh.pl
  501 97671 97669   0  6:22PM ttys000    0:00.01 sh -c ps -ef|grep -i perl
  501 97673 97671   0  6:22PM ttys000    0:00.00 grep -i perl
> 

>cat file1.txt
this
is
a
test


>@lines = `cat file1.txt`;


>print @lines;
this
is
a
test
>



>print @lines[0..2]
this
is
a


>$hash{$_}=1 for @lines;
>
>use Data::Dumper;
>print Dumper %hash;
$VAR1 = 'a
';
$VAR2 = 1;
$VAR3 = 'this
';
$VAR4 = 1;
$VAR5 = 'test
';
$VAR6 = 1;
$VAR7 = 'is
';
$VAR8 = 1;
>



><perl>
>  foreach $elem(@lines){
>   chomp($elem);
>   print "got $elem\n";
>  }
></perl>
got this
got is
got a
got test
>


><perl>
> sub hello{
>  print "hello @_\n";
>  }
></perl>

>&hello("rob");
hello rob


><perl>
> $a = 5;
> print "a is $a\n";
></perl>
a is 5

>SAVEOUTPUT
Saved output to ~.perlsh_stdout..
>cat .perlsh_stdout
a is 5
>


>
>cat testme.pm
package testme;

sub test{

  print "@_\n";

}
1;

>use lib './'
>use testme;
>&testme::test("hello");
hello
>

#### note we can interactively then use vi on the module and add hi in the function named test.
### we can then use the reload command to "reload" the updated module dynamically

>cat testme.pm
package testme;

sub test{

  print "hi @_\n";

}
1;

>reload testme
>&testme::test("me");
hi me
>

```















