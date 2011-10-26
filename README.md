Secure is the ruby sandboxing gem that powers http://rubymonk.com

Copyright (c) Tejas Dinkar and C42 Engineering

How To Install:
===============
$ gem install secure

or add the following to your Gemfile

gem 'secure'

API Documentation:
==================
```ruby
Secure.ly do
  File.read("some file")
end
```

You can pass options to tweak what security checks are put in place. If the option is not there, then the security check is not put in place by default

```ruby
Secure.ly
  :timeout => 0.15
  :limit_memory => 10000000
  :limit_cpu => 2
  :pipe_stdout => File.open("foo", "w") do
  # Some secure operation here
end
```

Options:
========
* :timeout => Guard thread that monitors the child process. If this elapses, this raises a Secure::TimeoutError
* :limit_memory => This is an absolute value of how much memory your block can take in bytes. Remember, absolute. I'll be getting relative support in soon
* :limit_cpu => This is the limit of how many cpu-seconds your process can use. MUST be an integer. This should be used as a fallback in case :timeout is not honored
* :run_before => A block, or array of blocks that is run before your code is sandboxed. Be careful. Remember how lambdas are bound in ruby. Refer to this for more details: http://blog.sidu.in/2007/11/ruby-blocks-gotchas.html
* :pipe_stdin, :pipe_stdout, :pipe_stderr => A File to pipe the stdin, out ond stderr to
* :safe => An integer that represents the new safe mode (default 3)
* :limit_files => Maximum file descriptor the block can open. If you want to say no files, set this to 0
* :limit_procs => Maximum number of processes that the user can create. Set this to 0 if you want to ensure no one forks

Errors:
=======
* Secure::TimeoutError => This is thrown if the :timeout limit is reached. The stack trace will be whatever line of code the app was running at the time
* Secure::ChildKilledError => This is thrown if one of the kernel level checks cause the child to die. The stack trace for this exception will be junk
* SecurityError => This is thrown if ruby tries to execute some code which is not allowed. The stack trace will help you figure out what was in violation
* Any other Error will be thrown as if it had happened in the parent process. We do our best to preserve the stack trace.

How Does it work:
=================

* Secure runs your ruby code in SAFE mode 3, which prevents evaluation of tainted strings and opening of new files.
* It also puts in kernel level RLIMIT checks, to make sure that your ruby process behaves itself
* It also spawns a monitoring thread, to make sure the thread doesn't take too long
* Secure runs in a new process, so people can screw up the Ruby tree as much as they like :-)

Known Issues:
=============
* :limit_memory and :limit_procs does not work on OSX (at least whatever version I use), but it does work on linux
* :pipe_stdout is not tested because of some rspec weirdness
* A block bound before $SAFE is set sees the old safe value. Refer to this for some clue about the reason why this happens: http://blog.sidu.in/2007/11/ruby-blocks-gotchas.html
* Stdout cannot be piped to a StringIO. You need to open a unix PIPE. There are two reasons for this. The code runs in a child process, so you need to use and IPC mechanism, and a string IO is not recognized as a file at the C level

Soon:
=====
* Getting rid of SAFE level 3, and moving everything into the kernel space. cgroups sounds hopeful here. As does more rlimit stuff

Performance:
============
RubyMonk is backed by an code evaluation server that uses secure gem in the backend. A single small (EC2) instance was able to consistently handle 150 code evaluation requests per minute, and we were able to horizontally scale when load went above this. YMMV

Contributing:
=============
Feel free to file bugs. However, if it is a security issue, we appreciate it if you shoot me a mail at tejas@c42.in before you file a bug.
