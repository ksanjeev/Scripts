# i/o modes
# 	not insert modes
# 	overwrite modes
# C : r+ w+
# perl : +< +>
#
#open FH, "+<z.dat" or die $!;
#print FH "fat";
#close FH;

open FH, "+>z.dat" or die $!;
print FH "thin";
close FH;

# < : can read, cannot write
# > : can write, cannot read, file truncated
# +< : can read, can write, file intact
# +> : can read, can write, file truncated
# >> : append, cannot read
#
