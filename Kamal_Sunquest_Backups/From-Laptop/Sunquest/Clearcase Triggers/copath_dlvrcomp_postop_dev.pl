# initializing variables and arrays
my $change_set_acts = $ENV{CLEARCASE_DLVR_ACTS};
my @activities = ();
my $activity_id;
my $t1;		# temporary variable
my $change_set;
my @result = ();
my @attributes = ();
my $attr_set;


# get activities associated with this delivery
@activities = split(/ /,$change_set_acts);

# get information for each activity to get changeset
foreach $element (@activities) {
	($activity_id, $t1) = split(/\@/,$element);
	$change_set = `cleartool lsactivity -fmt \"%[versions]Cp\" $activity_id`;
	@result = split(/, /,$change_set);
	@result = sort (@result);  # sort ascending
	
	# parse through output file to grab file paths of only the highest version
	foreach (@result) {
		$attr_set = 0;
		chomp($_);
		$full_cc_path = $_;
		@attributes = `cleartool describe -aattr -all $full_cc_path`;
		
		if (-d $full_cc_path) { #if a dir, do nothing
		} else { #not a dir, go ahead and process
			($cc_path,$t2) = split(/\@\@/,$full_cc_path);            
        }
        
        foreach (@attributes) {
        	chomp($_);
            $_ =~ s/\s+\b//g;
            if (substr($_,0,12) eq "dev_activity") {
                ($attribute,$attr_value) = split(/ = /,$_);
                ($t1,$attr_value,$t2) = split(/"/,$attr_value);
                $commandline = "cleartool mkattr -replace $attribute \\\"$attr_value\\\" $cc_path";  # move attribute forward
                `$commandline`;
                $attr_set = 1;
			}
        }
        
        if ($attr_set == 0) {  # attribute not found and not moved forward; originating stream
        	$commandline = "cleartool mkattr -replace dev_activity \\\"$activity_id\\\" $cc_path"; # set current activity id on destination stream
        	`$commandline`;
        }
    }
}
           
						