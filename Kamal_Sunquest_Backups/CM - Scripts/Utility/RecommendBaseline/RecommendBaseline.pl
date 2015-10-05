#!D:\Perl\bin\perl.exe
#=========================================================================
#  (c) COPYRIGHT, 2005,
#  Misys Helathcare Systems, Inc., as an unpublished work.
#  THIS IS A CONFIDENTIAL WORK OF AUTHORSHIP SUBJECT
#  TO LIMITED USE AGREEMENTS AND IS A TRADE SECRET WHICH IS
#  THE PROPERTY OF MISYS HEALTHCARE SYSTEMS, INC. ALL USE,
#  DISCLOSURE AND/OR REPRODUCTION NOT SPECIFICALLY AUTHORIZED
#  IN WRITING BY MISYS HEALTHCARE SYSTEMS, INC.
#  IS PROHIBITED. All rights reserved.
#
#=========================================================================
# RecommendBaseline.pl
#      This script is used for recommending the baseline as part of the build process.
#      The script gets input from the configuration file ( CC_Build.cfg ). 
#
#
# Usage:
#      1) 
#
#
# Returns:
#      1) Sends an email about the recommended baseline.
#
#=========================================================================
# Edit history:
#
#	Initial creation:	Saju Carlos on 05/21/07
#
#=========================================================================
# Edit below
    my $ConfigFile = 'CC_Build.cfg';            # Absolute path to the "CC_Build.cfg"
    my $log_File = 'RecommendBaseline_';
    my $log_Error = 'RecommendBaseline_';

    # Email server configurations
    my $SMTPserver = 'mhimail.mhi.onemisys.com';
    my $SMTPport   = 25;
    my $Emailheader		= "X-Mailer";
    my $Emailheadervalue	= "Recommending Baseline";

    # Call the required modules 
    use strict;
    use warnings;
    use Cwd;
    use Config::IniFiles;
    use Misys::SendMail;

    # The global variables 
    my (%Build,%NewRecommendedBl,%PreviousRecommendedBl) = ();
    my $Integration_Stream = '';
    
    # Initialise
    &Init;
    print "\n**** Start ****\n\n";
    
    exit if ($Build{Recommend_Baseline} !~ ?^y$?i);
    &GetRecommendedBaselines();    
    my @BaselineInfo = ();
    my @Recommend_Component = split (/,/,$Build{Recommend_Component});
    my %rec = ();
    print "\n\nThe new baselines availabe are:";
    foreach (@Recommend_Component)
    {
        # cleartool lsbl -s -com component:RX_6x_GUI@\RX_PVOB
        my $Command = 'cleartool lsbl -s -com component:'.$_.'@\\'.$Build{ProductVOB} if ($_ !~ /(?:\_pvob)/i);
        next if (!defined $Command);
        @BaselineInfo = `$Command`;
        if (&CheckBaseline(\@BaselineInfo,$_))
        {
            print "\nBaseline: $NewRecommendedBl{$_} has already been recommended for the VOB $_.\n";
        }
        else
        {
            print "Recomending Baseline: $NewRecommendedBl{$_} for the VOB $_.\n";
        }
    }
    &RecommendBaseline(\@Recommend_Component);
    print "\n**** End ****\n";
    
    &CloseInit;
    exit;


sub CheckBaseline
{
    my $baseline = shift;
    my $vob = shift;
    my $size = @{$baseline};
    print "\n$vob => $baseline->[$size-1]";
    $NewRecommendedBl{$vob} = $baseline->[$size-1];
    chomp $NewRecommendedBl{$vob};
    my $flag = 0;
    $flag = 1 if ($NewRecommendedBl{$vob} eq $PreviousRecommendedBl{$vob});
    return $flag;
}


sub GetRecommendedBaselines
{
    my $Command = '';
    
    # cleartool describe -l stream:RAD_5.0.1_Int@\RAD_PVOB
    $Command = 'cleartool describe -l stream:'.$Integration_Stream;
    my @details = `$Command`;
    my $details = join('',@details);
    print "The current recommended baseline for the components:\n";
    ($details) = ($details =~ /(?:recommended\sbaselines\:(?:(.+?)(?=\:)))/is);
    while ($details =~ /(?:(?:\n\s+(.+?)(?:\@(?:[^\(]+\())([^\s]+)(?:\@[^\(]+)(?=\n))+?)/isg)
    {
        print "$2 => $1\n";
        $PreviousRecommendedBl{$2} = $1;
    }
}






sub RecommendBaseline
{
    my $vlist = shift;
    my $EmailBody = &EmailTemplate;
    my ($previouslist,$newlist) = '';
    
    # Product
    my $product = $Build{Product}.$Build{Build_No};
    $EmailBody =~ s/\{\{PRODUCT\}\}/$product/;
    
    # Recommend Component
    my $Recommend_Component = 'Recommend_Component='.$Build{Recommend_Component};
    $EmailBody =~ s/\{\{RECOMMEND_COMPONENT\}\}/$Recommend_Component/;
    
    map {
        $previouslist .= "\t$_ => $PreviousRecommendedBl{$_}\n" if ($_ !~ /(?:\_pvob)/i);
        $newlist .= "\t$_ => $NewRecommendedBl{$_}\n";
    } (@{$vlist});
    
    $EmailBody =~ s/\{\{PREVIOUS_BASELINES\}\}/$previouslist/;
    $EmailBody =~ s/\{\{NEW_BASELINES\}\}/$newlist/;
    
    # Get the recipient list
    my @recipients = split(/,/,$Build{Email_List});
    
    # The sender will be the first recipient
    my $sender = $recipients[0];
    
    my ($firstname,$lastname) = ($sender =~ /(?:(?:(.+)\.(.+))(?=\@))/);
    $sender = $firstname.' '.$lastname."\n(".$sender.')';
    $EmailBody =~ s/\{\{SENDER\}\}/$sender/;
    
    my $subject = "Baseline Recommended For $product";
    &SendMail($subject,$EmailBody);
}




sub EmailTemplate
{
    my $template = <<'TEMPLATE';
Hi,

Following Baselines have been recommended for {{PRODUCT}}

{{RECOMMEND_COMPONENT}}

New Recommended baseline(s):

{{NEW_BASELINES}}

Previous Recommended Baseline(s):
{{PREVIOUS_BASELINES}}

Please Rebase your Development\Bridge Streams accordingly.

Any question\query please let me know.


Thanks & Regards,
{{SENDER}}

TEMPLATE
    return $template;
}


#************** Start of Init() ***************
# Description:  Initialise the variables and functions
# Usage:        &Init();
#
sub Init
{
    my %cfg = ();
    # Read the config file into hash
    tie %cfg, 'Config::IniFiles', ( -file => "$ConfigFile" );

    # Get the section into a hash
    %Build = %{$cfg{CLEARCASE}};

    $log_File .= $Build{Product}.'.log';
    $log_Error .= $Build{Product}.'_error.log';
    
    $Integration_Stream = $Build{Integration_Stream}.'@\\'.$Build{ProductVOB};
    

    open(OLDOUT, ">&STDOUT");
    open(OLDERR, ">&STDERR");
    
    open STDOUT, ">$log_File" or die "\nUnable to open $log_File: $!\n";
    open STDERR, ">$log_Error" or die "\nUnable to open $log_Error: $!\n";

}

#************** End of init() ***************




sub CloseInit
{
    
    close(STDOUT)|| die "Can't close log file";
    close(STDERR) || die "Can't close log file";

    # restore stdout and stderr
    open(STDERR, ">&OLDERR")  or die "Can't restore stderr: $!";
    open(STDOUT, ">&OLDOUT")  or die "Can't restore stdout: $!";
    
    # avoid leaks by closing the independent copies
    close(OLDOUT)  or die "Can't close OLDOUT: $!";
    close(OLDERR)  or die "Can't close OLDERR: $!";

}




#************** Start of SendMail() ***************
# Description:  Used to send email to the address specified in the configuration file.
#               The first email address in the configuration file is the sender and the
#               rest is the recipient list.
#
# Usage:        &SendMail([Subject],[Body]);
#
sub SendMail
{
    # Get the subject
    my $subject = shift;
    
    # Get the body of the email
    my $mailbodydata = shift;
    
    # Get the recipient list
    my @recipients = split(/,/,$Build{Email_List});
    
    # The sender will be the first recipient
    my $sender = $recipients[0];
    
    # Create an email object
    my $Email = new SendMail($SMTPserver, $SMTPport);

    $Email->From($sender);
    $Email->Subject($subject);
    $Email->To(@recipients);
    $Email->setMailHeader($Emailheader, $Emailheadervalue);
    $Email->setMailBody($mailbodydata);
  
    # Send the email 
    if ($Email->sendMail() != 0) {
        print $Email->{'error'}."\n";
    }

    # Clear the recipient list
    $Email->clearTo();
    
    # Reset
    $Email->reset();

}

  #************** End of SendMail() ***************




