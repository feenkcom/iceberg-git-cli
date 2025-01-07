# What is the rationale for a git CLI implementation ?


Like any sophisticated IDE, [Glamorous Toolkit](https://gtoolkit.com) must support [git](https://en.wikipedia.org/wiki/Git), the de facto standard for version control. GT's main Git tool is a custom UI on top of [Iceberg](https://github.com/pharo-vcs/iceberg), [Pharo Smalltalk](https://pharo.org)'s tool to work with git.

[Git](https://git-scm.com) ([source code](https://github.com/git/git)) itself is both a specification of a distributed version control system as well as the reference implementation. There exist [various alternative implementations of git](https://en.wikipedia.org/wiki/Git#Implementations) that do not share any code.

The Iceberg implementation in Pharo uses [Libgit2](https://libgit2.org), a C library built specifically for such use cases, as an FFI library. [Libgit2](https://github.com/libgit2/libgit2) does not share any code with git itself, it is effectively an alternative implementation.

The reference git implementation, a command line tool, is quite complex and extensive. It has more than 150 subcommands, each with 10s to 100s of options. It has many, many features, both high as well as low level ones.

Our git CLI implementation directly invokes the git CLI executable as an external subprocess, passing in various command line options and parsing the resulting output. Many other git tools use the same approach. This technique is used to give Iceberg an alternative implementation but also for a new Pure Git tool set that is independent of Iceberg.


# Why ?

Even though the answers are all on a technical level, the net result is that these improve the basis on which we build better and novel higher level user oriented features.


## Understandability

When you look up some advanced git feature or some edge case, the documentation or explanation will almost certainly use git CLI invocations. Most developer's main experience with git is also through CLI usage. By directly leveraging that knowledge, it becomes easier to add new functionality and to explain how we implemented existing features. There is no intermediary, no gap to explain as everything is just a git CLI invocation. 


## Direct feature parity

When git evolves and adds new features, it might take a while for libgit2 to follow. Furthermore, libgit2 most probably never covers 100% of git's complex feature set. By directly using git CLI we stay close to the source itself. 


## Non-blocking operations

Though git is often very fast, some operations do take more time. When using most command FFI libraries from Pharo, the time spent inside an FFI call blocks the whole VM. Though it is not impossible to work around this, it requires lots of work from both sides and is error prone for complex APIs. Our use of git CLI uses GT's sophisticated external process library that allows for easy to use asynchronous usage, even while just waiting for something. Furthermore, operations where the data transfer and/or subsequent processing take a significant amount of time can use asynchronous result streams to provide a snappier UI in many cases.


## Special setups

By using git CLI we can fall back on git being usable outside GT before we use it from within GT. In other words: if it works fine on the command line, we can work with it as well. This is especially important in special setups like enterprise contexts. At the moment, the GT side does not do anything special regarding authentication or authorisation: the requirement being that git works unattended, without any user interaction like passwords prompts. There are several ways to accomplish this, the most common one being SSH keys used with a credential helper like ssh-agent, but in principle any solution should work.


## Future proofing

Currently only a small portion of git is available through git CLI from GT. This is enough to support both Iceberg as well as Pure Git. Since we stay so close to standard git CLI, it is really easy to add more features or variations to existing features.
