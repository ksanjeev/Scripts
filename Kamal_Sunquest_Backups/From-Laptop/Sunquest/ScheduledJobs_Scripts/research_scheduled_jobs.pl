#!/usr/local/bin/perl
#
# research_scheduled_jobs.plx
#
# This program mines data regarding scheduled jobs on the VOB servers.
#
# Edit History:
#
# 1.00  GGG  09/04/2008
# Initial creation.

use strict;
use warnings;

use Carp;
use English qw( -no_match_vars );
use File::Basename;
use Getopt::Long qw(:config bundling);

use constant COMMA => q{,};
use constant EMPTY => q{};
use constant HELP  => <<'END_HELP';
Options:
    -c|--csv     CSV file
    -k|--key     Job keys to display
    -l|--level   Level of reporting detail
    -s|--servers Server names

    --help       Display this summary
    --man        Display the manpage
    --usage      Display a brief usage line
    --version    Display the version number
END_HELP
use constant USAGE => 'Usage: '
    . basename($0)
    . ' [-c file]'
    . ' [-k key[,...]]'
    . ' [-l 1-9]'
    . ' [-s server[,...] ...]'
    . " [scheduled_job_file ...]\n";
use constant VERSION => '1.00';
my $comma = COMMA;

# Set the command-line options.
my $csv_file;
my $job_key;
my $report_level = 9;
my @servers;
my $options_okay = GetOptions(
    'c|csv=s'    => \$csv_file,
    'k|key=s'    => \$job_key,
    'l|level=i'  => \$report_level,
    's|server=s' => \@servers,

    # Standard meta-options.
    'help|?' => sub {
        warn USAGE;
        warn HELP;
        exit 0;
    },
    'man' => sub {
        warn "--man: not yet implemented\n";
        exit 0;
    },
    'usage' => sub {
        warn USAGE;
        exit 0;
    },
    'version' => sub {
        warn 'Version ', VERSION, "\n";
        exit 0;
    },
);

# Usage check.
my $program_name = basename($0);
die qq(Type "$program_name --help" for help.\n) if !$options_okay;

# Split any comma-separated server list.
if (@servers) {
    @servers = split( /$comma/, join( $comma, @servers ) );
}

# Make the job key into a regexp.  Reset the report level so it will display.
if ( defined $job_key ) {
    $job_key = "\Q$job_key";
    $job_key =~ s{\\$comma}{|}gxms;
    $report_level = 9;
}

# Put the contents of the scheduled jobs into a data structure.
my $scheduled_job_ref = parse_scheduled_jobs( \@servers, @ARGV );

# Mine the data structure for information.
research_scheduled_jobs( $scheduled_job_ref, $report_level, $job_key,
    $csv_file );

##############################################################################
# Usage       : parse_scheduled_jobs($servers_ref, @job_files)
#
# Purpose     : Parse the job data by asking the servers for the schedule or
#               by reading the contents of scheduled job files.  Create job
#               files as output if passed a server list.
#
# Returns     : $scheduled_job_ref - Reference to scheduled job hash.
#
# Parameters  : $servers_ref - Reference to list of server names.
#               @job_files   - Scheduled job data files.
#
# Throws      : Cannot open the job file.
#               Cannot close the job file.
#
# Comments    : Assume that the first part of the scheduled job file name is
#               also the name of the server.
#
# See Also    : N/A
sub parse_scheduled_jobs {
    my ( $servers_ref, @job_files ) = @_;
    my @default_servers = qw(
        az-ccvob1 az-ccvob2 az-ccmulti1 mhicc-ms mhicc-vob
    );
    my %scheduled_job;

    # No server list and no job files means query all known servers.
    if ( !@$servers_ref && !@job_files ) {
        $servers_ref = \@default_servers;
    }

    # Create job files if passed a server list.
    if (@$servers_ref) {
        @job_files = ();
        for my $server (@$servers_ref) {
            my $job_file = "${server}_scheduled_jobs.txt";
            print "Querying $server for schedule.\n";
            system(
                "cleartool schedule -host $server -get -schedule > $job_file")
                == 0
                or croak
                "Cannot get schedule from host $server ($OS_ERROR).\n";
            push @job_files, $job_file;
        }
    }
    else {

        # Glob the file list in case the shell doesn't do it.
        @job_files = map {glob} @job_files;
    }

    # Process each file.
    for my $job_file (@job_files) {
        open my $jf, '<', $job_file
            or croak "Cannot open $job_file ($OS_ERROR).\n";
        my %job;

        # We are not in a stanza, description, or completion message before we
        # start.
        my $in_job             = 0;
        my $in_description     = 0;
        my $in_completion_info = 0;

        # Process each line.
        while ( my $line = <$jf> ) {

            # Strip terminators and leading whitespace.
            chomp $line;
            $line =~ s{\A \s+}{}xms;

            # If we are in a job stanza, parse the line data.
            if ($in_job) {

                # When the stanza ends, move the data into a hash structure.
                if ( $line eq 'Job.End' ) {
                    $in_job = 0;

                    # Assume the first part of the file is the server name.
                    my $server = ( split /[_.]/, $job_file )[0];
                    build_job_structure( \%scheduled_job, \%job, $server );
                    %job = ();
                }

                # Detect the start of a description.
                elsif ( $line eq 'Job.Description.Begin:' ) {
                    $in_description = 1;
                }

                # If we are in a description, store it.
                elsif ($in_description) {
                    if ( $line eq 'Job.Description.End:' ) {
                        $in_description = 0;
                    }
                    else {
                        $job{'Job.Description'} .= "$line\n";
                    }
                }

                # Detect the start of a completion message.
                elsif ( $line eq 'Job.LastCompletionInfo.Messages.Begin:' ) {
                    $in_completion_info = 1;
                }

                # If we are in a completion message, store it.
                elsif ($in_completion_info) {
                    if ( $line eq 'Job.LastCompletionInfo.Messages.End:' ) {
                        $in_completion_info = 0;
                    }
                    else {
                        $job{'Job.LastCompletionInfo.Messages'} .= "$line\n";
                    }
                }

                # Store unexceptional data.
                else {
                    my ( $key, $value ) = split m{: \s}xms, $line, 2;

                  # Convert the commented job task line into something normal.
                    if ( $key eq '# Job.Task' ) {
                        $key = 'Job.TaskName';
                    }

                    # Strip otiose quotation marks and store the value.
                    $value =~ s{"}{}gxms;
                    $job{$key} = $value;
                }
            }

        # If we are not processing job data, look for the start of the stanza.
            elsif ( $line eq 'Job.Begin' ) {
                $in_job = 1;
            }
        }

        # Close the file handle.
        close $jf or croak "Cannot close $job_file ($OS_ERROR).\n";
    }

    return \%scheduled_job;
}

##############################################################################
# Usage       : research_scheduled_jobs($scheduled_job_ref, $report_level,
#                                       $job_key, $csv_file)
#
# Purpose     : Research the scheduled jobs on the VOB servers.
#
# Returns     : Nothing.
#
# Parameters  : $scheduled_job_ref - Reference to scheduled job hash.
#               $report_level      - Level of reporting detail.
#               $job_key           - Job key(s) to display.
#               $csv_file          - CSV output file.
#
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A
sub research_scheduled_jobs {
    my ( $scheduled_job_ref, $report_level, $job_key, $csv_file ) = @_;

    # Open an optional CSV output file.
    my $csv_out;
    if ( defined $csv_file ) {
        open $csv_out, '>', $csv_file
            or croak "Cannot open $csv_file ($OS_ERROR).\n";

        # Print header.
        print {$csv_out} "VOB,Task Name,Job Name,Job Element,Job Value\n";
    }

    # Display the scheduled jobs information.
    my $prev_server    = EMPTY;
    my $prev_task_name = EMPTY;
    my $prev_job_name  = EMPTY;
    while ( my ( $server, $server_ref ) = each %$scheduled_job_ref ) {
        if ( !defined $job_key ) {
            print "$server\n";
        }
        elsif ( $server ne $prev_server ) {
            print "$server\n";
            $prev_server = $server;
        }
        if ( $report_level > 1 ) {
            while ( my ( $task_name, $task_name_ref ) = each %$server_ref ) {
                if ( !defined $job_key ) {
                    print "  $task_name\n";
                }
                elsif ( $task_name ne $prev_task_name ) {
                    print "  $task_name\n";
                    $prev_task_name = $task_name;
                }
                if ( $report_level > 2 ) {
                    while ( my ( $job_name, $job_name_ref )
                        = each %$task_name_ref )
                    {
                        if ( !defined $job_key ) {
                            print "    $job_name\n";
                        }
                        elsif ( $job_name ne $prev_job_name ) {
                            print "    $job_name\n";
                            $prev_job_name = $job_name;
                        }
                        if ( $report_level > 3 ) {
                            for my $job_element ( sort keys %$job_name_ref ) {
                                if ( !defined $job_key ) {
                                    print "      $job_element\n";
                                }
                                if ( $report_level > 4 ) {
                                    my $job_value
                                        = $job_name_ref->{$job_element};
                                    if ( defined $job_key ) {
                                        if ( $job_element =~ qr{$job_key}xms )
                                        {
                                            print "      $job_element\n";
                                            print "\t$job_value\n";
                                            if ( defined $csv_out ) {
                                                for ($job_value) {
                                                    s{\n}{<CR>}gxms;
                                                    s{"}{""}gxms;
                                                }
                                                print {$csv_out} join( COMMA,
                                                    $server,
                                                    $task_name,
                                                    $job_name,
                                                    $job_element,
                                                    qq{"$job_value"\n} );
                                            }
                                        }
                                    }
                                    else {
                                        print "\t$job_value\n";
                                        if ( defined $csv_out ) {
                                            for ($job_value) {
                                                s{\n}{<CR>}gxms;
                                                s{"}{""}gxms;
                                            }
                                            print {$csv_out} join( COMMA,
                                                $server,
                                                $task_name,
                                                $job_name,
                                                $job_element,
                                                qq{"$job_value"\n} );
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    if ( defined $csv_out ) {
        close $csv_out or croak "Cannot close $csv_file ($OS_ERROR).\n";
    }

    return;    # Explicitly return nothing meaningful.
}

##############################################################################
# Usage       : build_job_structure($scheduled_job_ref, $job_ref, $server)
#
# Purpose     : Store tagged data from a single job stanza into a scheduled
#               job data structure.
#
# Returns     : Nothing.
#
# Parameters  : $scheduled_job_ref - Scheduled job hash reference.
#               $job_ref - Reference to a job stanza hash.
#               $server  - The server name.
#
# Throws      : No exceptions.
#
# Comments    : None.
#
# See Also    : N/A
sub build_job_structure {
    my ( $scheduled_job_ref, $job_ref, $server ) = @_;

    my $task_name = $job_ref->{'Job.TaskName'};
    my $job_name  = $job_ref->{'Job.Name'};
    while ( my ( $key, $value ) = each %$job_ref ) {

        # We already use the task and job names as keys, so skip them.
        next if $key eq 'Job.TaskName';
        next if $key eq 'Job.Name';
        $scheduled_job_ref->{$server}{$task_name}{$job_name}{$key} = $value;
    }

    return;    # Explicitly return nothing meaningful.
}
