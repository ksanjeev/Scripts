# single char regex
$\  ="\n"; $, = "\t";
#  /t/	matches t
#  /\t/	matches a tab;  escape to give a special meaning
#  /\// matches a / ; escape to remove special meaning
#

# match a lowercase vowel of English
# /a|e|i|o|u/
# 	| alternator
# 	too powerful to choose a char
#
# /[aeiou]/
# 	character class
# 	matches a char
# 	is a set
#
# /aaa/ 3 consecutive a
# /[aaa]/ a

# Rule 1 :
# 	match from subject to pattern; find the leftmost match
$_ = "heat";
if(/[aeiou]/)
{
	print "matched : $& "; # e
}

# match a digit of decimal number system
#@subjects = (0, 5, 9, ".", "-", "5a", "b6");
# qw : quotes each word with single quotes and also puts comma bet elements
@subjects = qw(0 5 9 . - 5a b6);
foreach $sub (@subjects)
{
#	print $sub;
}

foreach  (@subjects) # default variable : $_
{
#	print ; # print $_
}

# digit

@subjects = qw(0 5 9 . - 5a b6);
$pat = '[0123456789]';
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# .. : not the range op in regex
# range :
# 	perl :
# 		..
#		25 .. 79  => 25, 26, 27 ... 78 79
# 	char class in regex :
# 		-	
# 		/[25-79]/ => 2 5 6 7 9 # char range
# 		/[A-z]/   matches extra 6 char other than letter of English
# 		/[A-Za-z]/ matches a letter of English
#
$pat = '[0..9]'; # 0 or . or 9
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

$pat = '[0-9]'; # 0 to 9 
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# - is special in the middle of a char class
$pat = '[09-]'; # 0  9 -
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";


$pat = '[0\-9]'; # 0  9 -
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";



$pat = '[^0-9]'; # inverts pattern matching
print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";

# /[0-9^]/    digit or caret
# caret is special only in the beginning of the char class
# /[^^]/	matches anything other than a caret
# /[\^^]/	matches  a caret
# /[^\^]/	matches anything other than a caret

# macros
#  /[0-9]/	/\d/
#  /[^0-9]/	/\D/
#  /[a-zA-Z0-9_]/ /\w/
#  /[^a-zA-Z0-9_]/ /\W/
#  /[ \t\n\r\f]/ /\s/
#  /[^ \t\n\r\f]/ /\S/
#


# hex digit
# /[0-9a-fA-F]/
# /[\da-fA-F]/
#
$_ = "123abc";
if(/[\d\D]/)
{
	print "matched $&";
}

if(/\d\D/)
{
	print "matched $&";
}


# match c and then a  char and then t
@subjects = qw(cat cot cut c+t c.t ct coat);
# shell :
# 	? : matches a char
# regex :
# 	? : char preceding is optional
#	. : match  a char
$pat = 'c?t';   # ct or t

print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";


print "";
$pat = 'c.t';   # c anychar t

print "pattern : $pat";
foreach (@subjects)
{
	if(/$pat/)
	{
		print "matches $_ : $&";
	}
	else
	{
		print "no match $_";
	}
}
print "";



































