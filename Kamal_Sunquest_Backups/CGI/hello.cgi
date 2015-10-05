#! /usr/bin/perl -w
use CGI qw/:standard/;

print header,
	start_html({-title=>"Hello World",
		    -bgcolor=>"#FFFFFF"}),
		"Hello World",
		end_html;
