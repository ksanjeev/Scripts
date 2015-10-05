# quotes
$\ = "\n";
$, = "\t";
$a = "key";
# variable is substituted in double quotes
print "what : $a"; # key
# escape sequences are expanded
print "hello \n world";


# variable not substituted
# no expansion of escape seq
print 'what : $a'; # $a
print 'hello \n world'; # \n

print "\$a =  $a";

print "what :  $aword"; # undef
print "what :  $a.word"; # key.word
print "what : ${a}word"; # keyword  


#print `ls`; # back quotes
# execute the cmd of the OS
#

# 1. backticks : output can be captured
@a = `ls`;
# 2. system : cannot capture the output
system("ls");

print "os : ", $^O;











