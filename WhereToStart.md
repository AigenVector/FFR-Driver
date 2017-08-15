
# FFR-Resistance Driver - where to start

To the poor suckers following in our footsteps, here is some of the things I have learned along the way.  To complete this task you will need to learn a lot of things... circuitry, software and computer terminology just being a start.  So here are some of my suggestions on where to start.  If you ever get really stuck... I may decide to help you.

## Suggestions:

### Download a VM with Ubuntu installed
  - This is a linux system.  This is what the Raspberry Pi uses so it will do you some good to have it set up on your own computer.  If you don't know what you are doing read below.

#### VM install:
  1. Download [Xubuntu](http://xubuntu.org/getxubuntu/) (64 amd.iso)
  1. Download and install [Oracle VirtualBox](https://www.virtualbox.org/wiki/Downloads)
    - Oracle virtual box config (these are the settings I used)
      1. Name, linux, 64 bit ubuntu
      1. 4096 MB
      1. Create virtual harddisk now
      1. VMDK
      1. Dynamically allocated
      1. Disk size = 80GB (pain in butt to resize after created)
      1. Setting: System tab
      1. Processor: turn cpu up to 2 (half of what you got)
      1. Storage- cd under controller IDE- click on CD and selected downloaded xubuntu
      1. Network- bridged adaptor- select name of device using to connect to internet
        - If doesn't work flip back to NAT
      1. Open VM
      1. Install Xubuntu with LVM
      1. Allow to install and then delete cd from storage tab

### Linux terminal
- Learn how to navigate the Linux terminal.  Some notes I took while learning the terminal are below:

   - Serial communication: talking to computer and waiting for a response (conversational).
   - Working directory- where you are working (i.e. folder/file)
   - Commands to know:
     - ``pwd`` (print working directory) -Where am I? -
     - ``ls -lrt`` (list of things in directory) -What's inside where I am?
       - ``-`` is a short option
       - ``--`` is a long form option
     - ``cd <foldername>`` -Change directory
     - ``which <command name>`` - do you know the command/ where is it installed?
     - ``sudo``- super user do
     - ``mkdir``- make directory
     - ``man <command>`` is a manual, gives details related to associated command
       - use j and k to scroll, q to quit
       - search ``/searchterm`` and press enter. n cycles through forward N-backwards
       - Synopsis is how to form command (brackets- optional, angles- required)
   - Random notes:
     - No \ only /
     - Case sensitive
     - Scrolling- shift page up/page down


### Ruby
  1. The code is written in a language called Ruby.  It is a pretty easily readable language.  Learn the syntax by reading this book below.  It's really not too bad.... it has comics.
    - Read [Why's poignant guide to Ruby](http://www.rubyinside.com/media/poignant-guide.pdf)
  1. While you are reading the book you should be practicing with example code.  Install ruby into your VM using the instructions below.
  #### Potential IDE to use:
  - Atom: allows you to read and write ruby code with syntax highlighting.  Also allows markdown
  code commentary (like this document).


#### Installing Ruby
  1. [RVM](rvm.io)- Ruby Version Manager
  1. ``rvm install ruby-2.4.0``
- Using rvm
  - ``rvm gemset list`` -  lists gemsets (collections of libraries) rvm has
    - ``rvm gemset create <name>``-gemset - isolated place where you can install a set of gems
    - ``rvm use @<name>`` - switch to project gemset we created
    - ``gem list``- lists all the libraries used on the project
    - ``gem install <library>`` -sinatra and pi piper
  - Gems to install
    - ``bundler`` - reads gemfile (list of gems/versions) and install missing gems
      - list gems in gemfile, bundler installs them ``vi Gemfile``
      - Gemfiles allows to pin versions
    - ``gemrat``- installs gems and writes into gemfile
      - gemrat <gem> - downloads latest version/ pins to gemfile

### Git
- Understanding the linux terminal helps with the next step... Understanding Git.  Git is a code management tool and is very helpful so read up on it to understand the basics and open a GitHub account.  The best reason to use this for this project is to send code from your laptop to the Pi.  Below is notes I took on Git.  Hope they help.

- Concepts
  - Distributed version control- many copies of code floating around
    - Merging strategy- push merging to later to avoid lack of parallel work
  - Repository- copy of code
    - Remote repository- github
    - Local repository - pi/ computer
  - Commit - grouping of logical changes
    - Has unique identifier (SHA)
    - Happens in chronological order (timestamps and branch)
    - Branch- multiple commits in certain order

#### Setup
##### Cloning repository-Gets my code repository on your laptop.
  1. Find url link on github of repository under clone
  1. Open terminal
  1. Cd to directory you want the code to be in
  1. Git clone URL -- only needs to be done for the first time
  1. cd into code

##### Committing change in code
  1. ``git status``
    - Untracked files - git never seen before
    - Unstaged files - git has seen before/modified before but changes haven't checked in and changes won't be included in next commit
    - Staged changes - git has seen before/ changes haven't been checked in yet-> changes will be apart of next commit
  1. ``git add <filename>`` - add untracked/unstaged to staged (if sure of all ``git add --all`` make sure to check git status after)
  1. ``git commit`` - makes commit and brings up text editor
  1. ``git log`` - shows commits / ``git branch`` -shows which branch you are on
  1. ``git remote -v`` -shows remotes we have (lists of copies that you know about)
  1. ``git remote add <nickname> URL (github remote)``
  1. ``git push <remote name> <remote branchname>`` - sends changes to github repositiory

Once you have the code you need to install the gems
##### Installing dependencies/gems/libraries
1. Install ``bundler``
    ```
     gem install bundler
    ```
1. Cd to directory with gemfile and install dependencies by:
    ```
     bundle install
    ```
1. To make a file type executable on your system:
```
chmod0755 filename.rb
```
1. To run the script
```
./filename.rb
```

### What to do when it feels hopeless...?
1. Curse... A lot
1. Pray to the code gods
1. Threaten to throw things
1. Realize if it was working a second ago and now it is broken you are probably the asshole who broke it and you need to pay attention to the little details because that's probably it.
1. Try to narrow down the problem
1. Google it.  
1. Talk someone else through it. It will help you realize your mistake.

1. If all else fails you can get my number from Lauren... don't make me have to google it for you :P
