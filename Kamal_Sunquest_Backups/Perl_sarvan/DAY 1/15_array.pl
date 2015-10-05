# push pop shift unshift sort reverse 
# split join

#@a = (11, 22, 33, 44);
#($x, @a) = @a;
# ($x, @a) = (11, 22, 33, 44)
# $x = 11  @a = (22, 33, 44)
# remove the first element
#
$x = shift(@a);

# unshift : add at the beginning
unshift(@a, $X);

# push : add at the end
push(@a, 55);

# remove at the end
$x = pop(@a);



# scalar to list
# split
# 	split /pattern/, scalar => list
$x = "sachin,rahul,lakshman";
$\ = "\n"; $, = "\t";
print split(/,/, $x);


#join 
#	list => scalar
#	join "separator", list
print join("+", 10, 20, 30, 40);


# reverse
@x = (5, 15, 9, 25, 3);
print @x;
@y = reverse(@x);
print @y;


@y = sort(@x);
# $a, $b are variables of the sort fn
#@y = sort{ $a cmp $b } (@x); # code block
print @y;



@y = sort{  $a <=> $b } (@x);
print @y;

@y = sort{  $b <=> $a } (@x);
print @y;










