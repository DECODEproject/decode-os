The DECODE SDK
==============

The DECODE SDK is a unique build framework written to ease maintenance
and production of various types of the Devuan distribution images,
such as: live ISOs, virtual machine images, and images targeted at
embedded ARM boards. This section explains how to use the SDK, gives
and inside look at its various parts and documents the workflow to be
used when modifying its code.

The SDK is designed in such a way that there are levels of priority
within the scripts. First there is `libdevuansdk`, which holds the
vanilla configuration, then come the various wrappers targeted around
specific targets (`live`, `virtual`, `embedded`), and afterwards we
optionally add more on top of it if we need to customize or override
specific functions.  This is for example the case with DECODE OS,
where we have to add additional software and extra components on top
of the base Devuan system.


libdevuansdk
------------

_libdevuansdk_ is the core of any part of the Devuan SDK. It holds the
common knowledge between all of the upper wrappers such as _live-sdk_,
_vm-sdk_, and _arm-sdk_. Simply put, it is a shell script library to
unify the use and creation of various functions spread throughout the
complete Devuan SDK.

The wrappers are designed to be used interactively from a terminal, as
well as automated from shell scripts. _libdevuansdk_ uses an
additional _zsh_ library called [zuper](https://github.com/dyne/zuper)
to ease the variable declaration and scoping, as well as error
checking and debugging. However, _zuper_ is not included in
_libdevuansdk_ itself - one is required to include it in its
respective wrapper. _live-sdk_, _vm-sdk_, and _arm-sdk_ can be taken
as example. libdevuansdk itself has some software dependencies that
should be installed prior to use:

```
zsh
debootstrap
sudo
kpartx
cgpt
xz-utils
```


### Workflow

Working with _libdevuansdk_ splits into categories of what you want to
do. _zlibs_ are files separated into the following categories:

* ***bootstrap*** Contains the functions for the bootstrap process.
  Creating a minimal debootstrap base system, and making it into a
  compressed file (tar.gz) for later use so one does not have to wait
  for the lengthy bootstrap process on each consequent build.

* ***helpers*** Contains the helper functions for _libdevuansdk_ that
  make the workflow a bit easier to use and handle.

* ***imaging*** Contains the functions necessary for creating raw
  dd-able images.

* ***rsync*** Contains rsync and file copying functions.

* ***sysconf*** Contains the default system configuration.


### Usage

As libdevuansdk is not very useful when invoked on its own, its usage
will be explained at later parts, for each specific wrapper. The
technical documentation of _libdevuansdk_ will follow in its
appropriate section.


The wrappers
------------

As mentioned, _libdevuansdk_ is the core library we wrap around. The
currently existing wrappers are called _live-sdk_, _vm-sdk_, and
_arm-sdk_. These facilitate the builds of liveCDs, virtual machines, and
images for embedded ARM devices, respectively. Each of them have their
own section in this paper.

Since all of these wrappers, along with _libdevuansdk_, hold a
_vanilla_ Devuan configuration, it is best to keep their code
untouched. To allow for custom configurations, we introduced a concept
called *blends*. Blends are a simple way to customize the base image
of the OS-to-be before building it, allowing to easily add packages,
kernels, and virtually anything one might want to do in the
image. This exactly is the case with DECODE OS.


arm-sdk
-------

The _arm-sdk_ is our way of facilitating builds for embedded ARM boards
such as Allwinner-based CPUs, Raspberry Pis, Chromebooks, etc. It holds
a knowledgebase for a number of embedded devices, and how to build
according kernels and bootloaders.


### Directory structure

_arm-sdk_'s directory structure is separated into places where we hold
our boards and their kernel configurations, device-specific
directories with firmware and/or configuration, and a _lib_ directory
(where we keep _libdevuansdk_ and the like).


### Obtaining arm-sdk

The SDK, like any other part of Devuan's software toolchain, should be
obtained via _git_. The repositories are hosted on Devuan's Gitlab. To
grab it, we simply issue a _git clone_ command on a terminal, and
since it contains linked git submodules - we append _--recursive_ to
it:

```
$ git clone https://git.devuan.org/sdk/arm-sdk --recursive
```

Consult the _README.md_ file found in this repository to see what are
the required dependencies to use _arm-sdk_.


### Using arm-sdk

Once the build system is obtained, it can now be used interactively. The
process is very simple, and to build an image one can actually use a
single shell command. However, we shall first show how it works.

In _arm-sdk_, every board has its own script located in the _boards_
directory. In most cases, these scripts contain functions to build the
Linux kernel, and a bootloader needed for the board to boot. This is
the only difference between all the boards, which requires every board
to have their own script. We are able to reuse the _rootfs_ that was
bootstrapped before. For our example, let's take the _Nokia N900_
build script. To build a _vanilla_ image for it, we simply issue:


```
$ zsh -f -c 'source sdk && load devuan n900 && build_image_dist'

```

This will fire up the build process, and after a certain amount of time
we will have our compressed image ready and checksummed inside the
_dist_ directory.

The oneliner above is self-explanatory: We first start a new untainted
shell, source the sdk file to get an interactive SDK shell, then we
initialize the operating system along with the board we are building,
and finally we issue a helper command that calls all the necessary
functions to build our image. The _load_ command takes an optional
third argument which is the name of our _blend_ (the way to customize
our _vanilla_ image) which will be explained later. So in this case,
our oneliner would look like:

```
$ zsh -f -c 'source sdk && load devuan n900 decode && build_image_dist'
```

This would create an image with the _"decode"_ blend, which is available
by cloning the DECODE OS git repository. The *build_image_dist* command
is a helper function located in _libdevuansdk_ that wraps around the 8
functions needed to build our image. They are all explained in the
technical part of this paper.


live-sdk
--------

The _live-sdk_ is used to build bootable images, better known as Live
CDs. Its structure is very similar to _vm-sdk_ and is a lot smaller than
_arm-sdk_.


### Directory structure

Unlike _arm-sdk_, in _live-sdk_ we have no need for specific boards or
setups, so in this case we only host the interactive shell init, and
libraries.


### Obtaining live-sdk

The SDK, like any other, should be obtained via _git_. The repositories
are hosted on Devuan's Gitlab. To grab it, we simply issue a _git clone_
command, an since it contains git submodules - we append _--recursive_
to it:

```
$ git clone https://git.devuan.org/sdk/live-sdk --recursive
```

Consult the _README.md_ file found in this repository to see what are
the required dependencies to use _live-sdk_.


### Using live-sdk

Much like _arm-sdk_, the _live-sdk_ is used the same way. With two
specific differences. Since we don't have any need for specific
boards, when loading we don't specify a board, but rather the CPU
architecture we are building for. Currently supported are *i386* and
*amd64* which represent 32bit and 64bit respectively. To build a
_vanilla_ live ISO, we issue:

```
$ zsh -f -c 'source sdk && load devuan amd64 && build_iso_dist'
```

This will start the build process, and after a certain amount of time we
will have our ISO ready and inside the _dist_ directory.

Just like in _arm-sdk_, we can use a _blend_ and customize our OS:

```
$ zsh -f -c 'source sdk && load devuan amd64 decode && build_iso_dist'
```

So this would create a live ISO of DECODE OS. Again as noted, this can
be obtained by recursively cloning the corresponding (DECODE-OS) git
repository.

The *build_iso_dist* command is a helper function located in
_libdevuansdk_ that wraps around the 9 functions needed to build our
image. They are all explained in the technical part of this manual.


vm-sdk
------

The _vm-sdk_ is used to build VirtualBox/Vagrant boxes, and virtual
images for emulation, in QCOW2 format, which is the byproduct of
building a Vagrant box. Its structure is very similar to _live-sdk_
and is the smallest of the three wrappers currently found in the
Devuan SDK.


### Directory structure

Like with _live-sdk_, in _vm-sdk_ we have no need for specific boards
or setups, so in this case we only host the interactive shell init,
and libraries.


### Obtaining vm-sdk

The SDK, like any other, should be obtained via _git_. The
repositories are hosted on Devuan's Gitlab. To grab it, we simply
issue a _git clone_ command, an since it contains git submodules - we
append _--recursive_ to it:

```
$ git clone https://git.devuan.org/sdk/vm-sdk --recursive
```

Consult the _README.md_ file found in this repository to see what are
the required dependencies to use _vm-sdk_.


### Using vm-sdk

Once obtained, we can use it interactively. The process is very simple,
and to build an image we use the oneliner we've already seen above.

Also like with _live-sdk_, we don't build for specific boards, however
we also do not create any non-amd64 images, so we don't have to pass
an architecture to the load command either. To build a _vanilla_
Vagrant Box, VirtualBox image, QCOW2 image, and a cloud-based QCOW2
image, we issue:

```
$ zsh -f -c 'source sdk && load devuan && build_vagrant_dist'
```

This line would create all the four types of the VM image.

As shown with the previous two wrappers, the _blend_ concept works as
advertised here as well:

```
$ zsh -f -c 'source sdk && load deuvan decode && build_vagrant_dist'
```

The *build_vagrant_dist* command is a helper function located in
_libdevuansdk_ that wraps around the 11 functions needed to build our
image. They are all explained in the technical part of this manual.
