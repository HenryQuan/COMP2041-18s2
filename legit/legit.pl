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
  if ($input =~ /^init/) {
    # init legit folder
    init();
  } elsif (legit_exist()) {
    if ($input =~ /^add/) {
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
    } elsif ($input =~ /^commit (.*)/) {
      # save $1 for multiple if, after first if $1 will be gone
      my @input = (split ' ', $1)[-3..-1];
      my $message = "";
      my $mode = "normal"; # -a will trigger "all" mode

      my $input = join ' ', @input;
      print $input;
      # -a -m first. Otherwise, -m will always match
      if ($input =~ /-a -m (.+)$/ && (@ARGV - 2) % 2 == 0) {
        $message = $1;
        $mode = "all";
      } elsif ($input =~ /-m (.+)$/ && (@ARGV - 1) % 2 == 0) {
        $message = $1;
      } else {
        exit 1 if printf "usage: legit.pl commit [-a] -m commit-message\n";
      }
      # it must not start with an argument  
      if ($message =~ /^-/) {
        exit 1 if printf "usage: legit.pl commit [-a] -m commit-message\n";
      }

      commit($message, $mode);
    } elsif ($input =~ /^log/) {
      # show past commits so basically cat commit
      print_file(".legit/$branch/COMMIT");
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
    } elsif ($input =~ /^status/) {
      status();
    } elsif ($input =~ /^rm/) {
      if ($input =~ /rm (.+)/) {
        # valid remove command
        my @files = split ' ', $1 or die;
        foreach $f (@files) {
          remove($f);
        }
      } else {
        # print error message
        exit 1 if print "legit.pl: error: internal error usage: git rm [<options>] [--] <file>...

    -n, --dry-run         dry run
    -q, --quiet           do not list removed files
    --cached              only remove from the index
    -f, --force           override the up-to-date check
    -r                    allow recursive removal
    --ignore-unmatch      exit with a zero status even if nothing matched\n\n";
      }
    } else {
      usage();
    }
  }
}

# write to file
sub write_file {
  my ($path, $message) = @_;
  # write to file
  open $f, '>', $path or die;
  print $f $message;
  close $f;
}

# return all text from file
sub read_file {
  my ($path) = @_;
  # write to file
  open $f, '<', $path or die;
  my @content = <$f>;
  close $f;
  return @content;
}

# create a new empty file
sub make_file {
  my ($path) = @_;
  write_file($path, '');
}

# append content to file
sub prepend_file {
  my ($path, $message) = @_;
  # save old text
  my @old = read_file($path);
  # prepend
  write_file($path, $message . (join '', @old))
}

# append to a file
sub append_file {
  my ($path, $message) = @_;
  # append
  open $f, '>>', $path or die;
  print $f $message;
  close $f;
}

# check if a file contains certain string
sub file_contains {
  my ($path, $text) = @_;
  # see if file already contains $text
  my $file = join '', read_file($path);
  if ($file =~ /$text/) {
    return 1;
  } else {
    return 0;
  }
}

# cat a file
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

# check if legit folder exists
sub legit_exist {
  return 1 if (-d '.legit');
  # stop if there is not legit folder
  exit 1 if print "legit.pl: error: no .legit directory containing legit repository exists\n";
}

# check for last commit folder
sub last_commit {
  my $commit_count = 0;
  while (-d ".legit/$branch/$commit_count") {
    # remember to use while to keep checking
    $commit_count++;
  }
  return $commit_count;
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
    # record all commits
    make_file ".legit/$branch/COMMIT";
    # record tracked files
    make_file ".legit/$branch/TRACKED";
    # record whether files are changed
    write_file(".legit/$branch/CHANGED", "");
    exit 1 if print "Initialized empty legit repository in .legit\n";
  }
}

# add files
sub add {
  my ($f) = @_;
  # check if file exists
  if (-e $f) {
    if (file_contains(".legit/$branch/TRACKED", "$f ")) {
      # it is already being tracked so we have to check if there is any changes
      my $result = compare(".legit/$branch/index/$f", $f);
      if ($result == 0) {
        # no changes
        append_file(".legit/$branch/CHANGED", "0");
      } elsif ($result > 0) {
        # There is a change and copy
        copy($f, ".legit/$branch/index");
        append_file(".legit/$branch/CHANGED", "1");
      }
    } else {
      # append to TRACKED, a new file
      append_file(".legit/$branch/TRACKED", "$f ");
      append_file(".legit/$branch/CHANGED", "1");
      copy($f, ".legit/$branch/index");
    }
  } else {
    exit 1 if print "legit.pl: error: can not open '$f'\n";
  }
}

# commit files with mode
sub commit {
  my ($message, $mode) = @_;

  # add tracked file
  if ($mode eq "all") {
    my $tracked = join('', read_file(".legit/$branch/TRACKED"));
    foreach my $file (split ' ', $tracked) {
      # add them all
      add($file);
    }
  }

  # check whether there are any new updates
  my @changed = read_file(".legit/$branch/CHANGED");
  if (join('', @changed) =~ /^0+$/) {
    print "nothing to commit\n";
  } else {
    # check for next commit folder
    my $commit_count = last_commit();

    # create commit folder and copy index to new commit
    my $commit_folder = ".legit/$branch/$commit_count";
    make_path $commit_folder or die;
    copy_folder(".legit/$branch/index", $commit_folder);
    # record this commit
    prepend_file(".legit/$branch/COMMIT", "$commit_count $message\n");

    print "Committed as commit $commit_count\n";
    # no changes after commit
  }

  # reset changed
  write_file(".legit/$branch/CHANGED", "");
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
  # there must be at least one commit
  if (-d ".legit/$branch/0") {
    foreach my $file (glob "*") {
      print "$file - ";
      if (compare($file, ".legit/$branch/index/$file") == 0) {
        print "same as repo";
      } else {
        print "file changed, ";
      }
      print "\n";
    }
  } else {
    exit 1 if print "legit.pl: error: your repository does not have any commits yet\n";
  }
}

# remove files from index or current directory
sub remove {
  my ($f, $mode) = @_;
  if (-e $f) {
    my $index = compare($f, ".legit/$branch/index/$f");
    my $last = last_commit();
    my $commit = compare($f, ".legit/$branch/$last/$f");
    # different messages
    if ($index && $commit) {
      exit 1 if print "\n";
    } elsif ($index) {
      exit 1 if print "\n";
    } elsif ($commit) {
      exit 1 if print "\n";
    } else {
      # remove both files
    }
  } else {
    exit 1 if print "legit.pl: error: '$f' is not in the legit repository\n";
  }
}