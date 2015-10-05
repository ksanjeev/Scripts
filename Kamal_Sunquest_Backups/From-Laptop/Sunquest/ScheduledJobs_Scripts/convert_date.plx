#!/usr/local/bin/perl -i.bk -p

# Convert date and time to a format that Excel understands
s{
  ( (?: 19 | 20) \d{2} )        # Capture the year
  -                             # Match the date separator
  ([01]\d)                      # Capture the month
  -                             # Match the date separator
  ([0-3]\d)                     # Capture the day
 }
 {$2/$3/$1}xms;                 # Reformat the date

s{
  T                             # Match the time separator
  ( [0-2]\d (?: : [0-5]\d){2} ) # Capture the time
  -\d{2}                        # Match the UTC offset
 }
 { $1}xms;                      # Reformat the time
