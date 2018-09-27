#!/usr/bin/perl -w
use File::Path qw(make_path);
use File::Copy;

my $branch = 'master';

if (@ARGV == 0) {
  usage();
} else {
  my $input = join ' ', @ARGV;

  if ($input =~ /init/) {
    # init legit folder
    init();
  } elsif ($input =~ /add (.*)/) {
    my @files = split ' ', $1 or die;
    foreach $f (@files) {
      if ($f =~ /^[a-zA-Z0-9][a-zA-Z0-9.-_]*/) {
        # only match alpha-numeric start + alpha-numeric [.-_]
        add($f);
      } else {
        # show error message
        exit if print "legit.pl: error: invalid filename '$f'\n";
      }
    }
  } elsif ($input =~ /commit (.*)/) {
    # save $1 for multiple if, after first if $1 will be gone
    my $input = $1;
    my $message = "";
    my $mode = "normal"; # -a will trigger "all" mode
    # use argument numbers to check if input is valid
    if ($input =~ /^-m/ && @ARGV == 3) {
      $message = $ARGV[2];
    } elsif ($input =~ /^-a -m/ && @ARGV == 4) {
      $message = $ARGV[3];
      $mode = "all";
    } else {
      exit if printf "usage: legit.pl commit [-a] -m commit-message\n";
    }

    commit($message, $mode);
  } else {
    usage();
  }
}

# create a new empty file
sub make_file {
  my ($path) = @_;
  open my $f, '>', $path or die;
  close $f;
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
    make_path ".legit/$branch/index" or die;
    make_file ".legit/$branch/commit";
    print "Initialized empty legit repository in .legit\n";
  }
}

# add files
sub add {
  my ($f) = @_;
  copy($f, ".legit/$branch/index") or die;
}

# commit files with mode
sub commit {
  my ($message, $mode) = @_;
}
