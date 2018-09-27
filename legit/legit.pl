#!/usr/bin/perl -w
use File::Path qw(make_path);

if (@ARGV == 0) {
  usage();
} else {
  my $input = join " ", @ARGV;
  if ($input =~ /init/) {
    # init legit folder
    init();
  } elsif ($input =~ /add (.*)/) {
    my @files = split ' ', $1 or die;
    if (@files == 0) {

    } else {
      
    }
    print @files;
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
  if (-d '.legit') {
    print "legit.pl: error: .legit already exists\n";
  } else {
    make_path '.legit/master/index' or die;
    print "Initialized empty legit repository in .legit\n";
  }
}

# add files
sub add {

}