use File::Find;
my %hash = ();
my @folder = ();
my $output_file = "CompareFiles.xls";
my $cnt = unlink $output_file;
my $FileCount = 0;
my $FolderCount = 0;
my %list = ();


    if (@ARGV != 2)
    {
        print"\n Please give two directories for comparison \n";
        exit;
    }

    my $count = 0;
    my %check = ();
    open (FO, ">$output_file");
    print FO "\n\n# Comparison chart for the directories $ARGV[0] and $ARGV[1] \n\n";

    foreach (@ARGV)
    {
      $count++;
      @folder = ();
      finddepth(\&wanted, $_);
      my $path = $_;
      my $pathlength = length($_);
      $FileCount = $FolderCount = 0;
      
      my %hash = ();
      foreach (@folder)
      {
        $FileCount++ if (-f $_);
        $FolderCount++ if (-d $_);

        my @details=();
        my ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
        $atime,$mtime,$ctime,$blksize,$blocks)
           = stat($_);
        $mtime = localtime($mtime);
        $size = $size/1024;
        push @details,$size,$mtime;
        $size = $mtime = "";
        my $key = "$_";
        my $rm = substr($key,$pathlength);
        $hash{$rm} = \@details;
      }
      $check{$count} = \%hash;
      print FO "$path\tTotal number of files: $FileCount\tTotal folders and subfolders: $FolderCount\n";

    }
    print FO "\nFilename\tSize (kb)\tLast Modify Time\t\tStatus in other\n";
    WriteComparison(1);
    WriteComparison(2);
    close (FO);




    
    sub WriteComparison
    {
       my $f = shift;
       my $otherf = "";
       my $root = "";
       if ($f == 1)
       {
         $otherf = $f + 1;
         $root = $ARGV[0];
       } elsif ($f == 2)
       {
         $otherf = $f - 1;
         $root = $ARGV[1];
       }

       foreach (keys %{$check{$f}})
       {
           next if !$_;
           my $d = $check{$f}->{$_};

           if (!(exists $check{$otherf}->{$_}))
           {
             # Print the file that doesnot exists in second folder
             print FO "$root$_\t$d->[0]\t$d->[1]\t$f\tNot Found\n" if (!exists $list{$_});
             $list{$_} = "\t$d->[0]\t$d->[1]\t$f\tNot Found\n" if (!exists $list{$_});
           } else
           {
               # Check size
               if ($check{$otherf}->{$_}->[0] != $check{$f}->{$_}->[0])
               {
                  print FO "$root$_\t$d->[0]\t$d->[1]\t$f\tSize differs\n" if (!exists $list{$_});
                  $list{$_} = "\t$d->[0]\t$d->[1]\t$f\tSize differs\n" if (!exists $list{$_});
               }
             
               # Check time stamp
               if ($check{$otherf}->{$_}->[1] ne $check{$f}->{$_}->[1])
               {
                  print FO "$root$_\t$d->[0]\t$d->[1]\t$f\tTime stamp differs\n" if (!exists $list{$_});
                  $list{$_} = "\t$d->[0]\t$d->[1]\t$f\tTime stamp differs\n" if (!exists $list{$_});
               }
           }
           $d = "";
       }
    } # end of sub WriteComparison()


    sub wanted {
        $path = $File::Find::name;
        push @folder,$path;
    } # end of sub wanted()


