#!/usr/bin/perl -w
use File::Path qw(make_path);
use File::Copy;

my $branch = 'master';

if (@ARGV == 0) {
  usage();
} else {
  # add extra space to match regex
  my $input = join(' ', @ARGV) . ' ';

  if ($input =~ /init/) {
    # init legit folder
    init();
  } elsif ($input =~ /add/) {
    # .+ because there must be at least one file
    if ($input =~ /add (.+)/) {
      # valid add command
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
    } else {
      # print error message
      print "legit.pl: error: internal error Nothing specified, nothing added.\n";
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
  } elsif ($input =~ /log/) {
    # show past commits so basically cat commit
    open my $f, '<', ".legit/$branch/commit" or die;
    print <$f>;
    close $f;
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

# append content to file
sub write_file {
  my ($path, $message) = @_;
  open my $f, '>>', $path or die;
  print $f $message;
  close $f;
}

# check if path is empty
sub empty_folder {
  my ($path) = @_;
  my @files = glob $path;
  if (@files == 0) {
    return 1;
  }
  return 0;
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
  copy($f, ".legit/$branch/index");
}

# commit files with mode
sub commit {
  my ($message, $mode) = @_;
  if (empty_folder(".legit/$branch/index/*")) {
    print "Nothing to commit\n";
  } else {
    # check for next commit folder
    my $commit_count = 0;
    while (-d ".legit/$branch/$commit_count") {
      # remember to use while to keep checking
      $commit_count++;
    }

    # create commit folder and move index to become the new folder
    my $commit_folder = ".legit/$branch/$commit_count";
    make_path $commit_folder or die;
    move(".legit/$branch/index", $commit_folder) or die;
    # create another index folder
    make_path ".legit/$branch/index/" or die;
    # record this commit
    write_file(".legit/$branch/commit", "$commit_count $message\n");

    print "Committed as commit $commit_count\n";
  }
}
