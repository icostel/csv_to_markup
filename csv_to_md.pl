#!/usr/bin/perl -w

use strict;

=item parse_csv
Parse csv from STDIN and write it to markup
=cut
sub parse_csv {
    # read file
    my $file = $ARGV[0];
    open my $fh, "<:encoding(utf8)", $file or die "$file: $!";

    # read the file
    my $read_flag = 0;
    my $input = "";
    # buffer everything
    while (<$fh>) {
        $input = $input . $_;
    }
    # get the attributes
    my $attr_string = substr($input, 0, index($input, '"'));
    # remove the attributes from the values string
    $input =~ s/$attr_string//;
    # store the attributes in a array
    my @attr_list = split(',', $attr_string);
    # polishing the data and spacing
    $input =~ s/",\n"/","/g;
    $input =~ s/,"\n#/,"#/g;
    # remove the first " we split by ","
    $input =~ s/.//;
    # get all the values from the remaining string
    my @values = split('","', $input);
    # map each value with the attribute and write it
    my $attr_max = $#attr_list + 1;
    for (my $c_values = 0, my $c_attr = 0; $c_values <= $#values; $c_values++) {
        if ($c_attr == $attr_max) {
            $c_attr = 0;
            # new element add ---
            print("\n---\n\n");
        }
        my $val = $values[$c_values];
        # trim start and end spacings for value and attribute
        $val =~ s/^\s+|\s+$//g;
        $attr_list[$c_attr] =~ s/^\s+|\s+$//g;
        # replace double-double quotes in value with double quotes
        $val =~ s/""/"/g;
        # for the last value, remove the last split trailing -> ",
        if ($c_values == $#values) {
            $val = substr($val, 0, length($val) - 2);
        }
        # print the entry
        print("<!--$attr_list[$c_attr]-->$val\n");
        $c_attr++;
    }
}

sub parse_args {
    # quit unless we have the correct number of command-line args
    my $num_args = $#ARGV + 1;
    if ($num_args != 1) {
        print("Missing argument");
        print_usage();
        exit;
    }
    # check to see if we have a .csv file
    my @file = split(/\./, $ARGV[0]);
    my $file_extension = $file[-1];
    if ("$file_extension" ne "csv") {
        print("Wrong file type");
        print_usage();
        exit;
    }
}

sub print_usage {
    printf("\nUsage: perl csv_to_md.pl <csv_file>\nMake sure the file has the correct extension (.csv)\n");
}

parse_args();
parse_csv();
