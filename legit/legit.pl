#!/usr/bin/perl -w
use File::Path qw(make_path);
use File::Copy;
use File::Compare;

my $branch = 'master';

if (@ARGV == 0) {
  usage();
} else {
  # add extra space to match regex
  my $input = join(' ', @ARGV) . ' ';

  if ($input =~ /init/) {
    # init legit folder
    init();
  } elsif (legit_exist()) {
    if ($input =~ /add/) {
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
            exit 1 if print "legit.pl: error: invalid filename '$f'\n";
          }
        }
      } else {
        # print error message
        exit 1 if print "legit.pl: error: internal error Nothing specified, nothing added.\n";
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
        exit 1 if printf "usage: legit.pl commit [-a] -m commit-message\n";
      }

      commit($message, $mode);
    } elsif ($input =~ /log/) {
      # show past commits so basically cat commit
      print_file(".legit/$branch/commit");
    } elsif ($input =~ /show (.*)/) {
      my $input = $1;
      # check for correct amounts of input
      if (@ARGV == 2) {
        my $folder = "index";
        my $file = "";
        if ($input =~ /^([0-9]+):([^ ]+)/) {
          # show 0:filename, so go into that folder
          $folder = $1;
          $file = $2;
        } elsif ($input =~ /^:([^ ]+)/) {
          # show :filename, ignore extra space, display files in index
          $file = $1;
        } else {
          # somehow it does not match
          exit 1 if print "usage: legit.pl show <commit>:<filename>\n";
        }

        show($folder, $file);
      } else {
        # usage message
        exit 1 if print "usage: legit.pl show <commit>:<filename>\n";
      }
    } elsif ($input =~ /status/) {
      status();
    } elsif ($input =~ /rm (.*)/) {
      my $input = $1;
    } else {
      usage();
    }
  }
}

# create a new empty file
sub make_file {
  my ($path) = @_;
  open my $f, '>', $path or die;
  close $f;
}

# append content to file
sub prepend_file {
  my ($path, $message) = @_;
  # save old text
  open my $f, '<', $path or die;
  my @old = <$f>;
  close $f;
  # prepend
  open $f, '>', $path or die;
  print $f $message;
  print $f @old;
  close $f;
}

sub print_file {
  my ($path) = @_;
  open my $f, '<', $path or die;
  print <$f>;
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

# check folder to another one
sub copy_folder {
  my ($path, $des) = @_;
  if (-d $path && -d $des) {
    # copy is possible
    foreach my $file (glob "$path/*") {
      copy($file, $des);
    }
  } else {
    # show error
    exit 1 if print "error: could not copy folder";
  }
}

sub legit_exist {
  return 1 if (-d '.legit');
  # stop if there is not legit folder
  exit 1 if print "legit.pl: error: no .legit directory containing legit repository exists\n";
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
    exit 1 if print "legit.pl: error: .legit already exists\n";
  } else {
    make_path ".legit/$branch/index" or die;
    make_file ".legit/$branch/commit";
    exit 1 if print "Initialized empty legit repository in .legit\n";
  }
}

# add files
sub add {
  my ($f) = @_;
  # check if file exists
  if (-e $f) {
    # different copy
    if (compare($f, ".legit/$branch/index/$f") != 0) {
      print "Copy\n";
      copy($f, ".legit/$branch/index");
    }
  } else {
    exit 1 if print "legit.pl: error: can not open '$f'\n";
  }
}

# commit files with mode
sub commit {
  my ($message, $mode) = @_;
  if (empty_folder(".legit/$branch/index/*")) {
    
  } else {
    # check for next commit folder
    my $commit_count = 0;
    while (-d ".legit/$branch/$commit_count") {
      # remember to use while to keep checking
      $commit_count++;
    }

    # create commit folder and copy index to new commit
    my $commit_folder = ".legit/$branch/$commit_count";
    make_path $commit_folder or die;
    copy_folder(".legit/$branch/index", $commit_folder);
    # record this commit
    prepend_file(".legit/$branch/commit", "$commit_count $message\n");

    print "Committed as commit $commit_count\n";
  }
}

# show commited file
sub show {
  my ($folder, $name) = @_;
  # the messages are a bit different, some include quotes
  my $message = 'index';
  if (-d ".legit/$branch/$folder") {
    # there is such folder so that we could print that file
    my $file = ".legit/$branch/$folder/$name";
    if (-e $file) {
      # check if such file also exits before printing
      print_file($file);
    } else {
      $message = "commit $folder" if ($folder ne 'index');
      exit 1 if print "legit.pl: error: '$name' not found in $message\n";
    }
  } else {
    $message = "commit '$folder'" if ($folder ne 'index');
    exit 1 if print "legit.pl: error: unknown $message\n";
  }
}

# show status
sub status {
  # my $total = 
  foreach my $file (glob "*") {
    print "$file - ";
    if (compare($file, ".legit/$branch/index/$file") == 0) {
      print "same as repo";
    } else {
      print "file changed, ";
    }
    print "\n";
  }
}

# remove files from index or current directory
sub remove {
  
}