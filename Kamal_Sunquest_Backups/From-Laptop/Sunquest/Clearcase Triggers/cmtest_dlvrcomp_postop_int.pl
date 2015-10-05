use File::Copy;

# initializing variables and arrays
my $change_set_acts = $ENV{CLEARCASE_DLVR_ACTS};
my $activities_folder = "\\\\az-cctest\\my testing";
my @activities = ();
my $activity_id;
my $t1,$t2;		# temporary variable
my $change_set;
my $copy_path;
my @result = ();
my @attributes = ();
my $attribute;
my $attr_value;


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
		chomp($_);
		$full_cc_path = $_;
		@attributes = `cleartool describe -aattr -all $full_cc_path`;

		if (-d $full_cc_path) { #if a dir, do nothing
		} else { #not a dir, go ahead and process
			($cc_path,$t2) = split(/\@\@/,$full_cc_path);

	        foreach (@attributes) {
        	chomp($_);
            $_ =~ s/\s+\b//g;
            	if (substr($_,0,12) eq "dev_activity") {
                	($attribute,$attr_value) = split(/ = /,$_);
                	($t1,$attr_value,$t2) = split(/"/,$attr_value);
					$activity_id = $attr_value;
				}
            }		

            # make activity folder
            $copy_path = $activities_folder . "\\" . $activity_id . "\\";
            mkdir("$copy_path") unless (-e "$copy_path");
            # copy file to activity folder
#            `xcopy /Y \"$cc_path\" \"$copy_path\"`;
            copy($cc_path, $copy_path);
#print "xcopy /Y \"$cc_path\" \"$copy_path\"\n";
        }
    }
}
           
						