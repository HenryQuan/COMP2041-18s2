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
  print "Usage: legit.pl <command> [<args>]

These are the legit commands:
  init       Create an empty legit repository
  add        Add file contents to the index
  commit     Record changes to the repository
  log        Show commit log
  show       Show file at particular state
  rm         Remove files from the current directory and from the index
  status     Show the status of files in the current directory, index, and repository
  branch     list, create or delete a branch
  checkout   Switch branches or restore current directory files
  merge      Join two development histories together\n\n"
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