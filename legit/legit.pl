#!/usr/bin/perl -w
my $legit = ".legit";

if (@ARGV == 0) {
  usage();
} else {
  my $input = join " ", @ARGV;
  if ($input =~ /init/) {
    # init legit folder
    init();
  } elsif ($input =~ //) {

  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  } elsif ($input =~ //) {
    
  }
}

# show usage
sub usage {
  print "Usage...\n";
}

# init legit folder
sub init {
  if (-d $legit) {
    print "legit.pl: error: .legit already exists\n";
  } else {
    mkdir $legit
  }
}