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

libdevuansdk is the core of any part of the Devuan SDK. It holds the
common knowledge between all of the upper wrappers such as live-sdk,
vm-sdk, and arm-sdk. Simply put, it is a shell script library to unify
the use and creation of various functions spread throughout the complete
Devuan SDK.

The wrappers are designed to be used interactively from a terminal, as
well as automated from shell scripts. libdevuansdk uses an additional
zsh library called [zuper](https://github.com/dyne/zuper) to ease the
variable declaration and scoping, as well as error checking and
debugging. However, zuper is not included in libdevuansdk itself - one
is required to include it in its respective wrapper. live-sdk, vm-sdk,
and arm-sdk can be taken as example. libdevuansdk itself has some
software dependencies though:

```
zsh
debootstrap
sudo
kpartx
cgpt
xz-utils
```


### Workflow

Working with libdevuansdk splits into categories of what you want to do.
_zlibs_ are files separated into these categories:

* ***bootstrap*** Contains the functions for the bootstrap process.
  Creating a minimal debootstrap base, and making it into a tarball for
  later use so one does not have to wait for the lengthy bootstrap
  process on each consequent build.

* ***helpers*** Contains the helper functions for libdevuansdk that make
  the workflow a bit easier to use and handle.

* ***imaging*** Contains the functions necessary for creating raw
  dd-able images.

* ***rsync*** Contains rsync and copying functions.

* ***sysconf*** Contains the default system configuration.


### Usage

As libdevuansdk is not very helpful when being used on its own, its
usage will be explained at later parts, for each specific wrapper. The
Technical documentation of libdevuansdk will follow in its appropriate
section.


The wrappers
------------

As mentioned, libdevuansdk is the core library we wrap around. The
currently existing wrappers are called _live-sdk_, _vm-sdk_, and
_arm-sdk_. These facilitate the builds of liveCDs, virtual machines, and
images for embedded ARM devices, respectively. Each of them have their
own section in this paper.

Since all of these wrappers, along with libdevuansdk, hold a vanilla
Devuan configuration, you might prefer not to change their code. Due to
this, a concept called *blends* was introduced. Blends are a simple way
to customize the base image before building it, allowing you to very
easily add packages, kernels, and virtually anything one might want to
do in the image. This exactly is the case with DECODE OS.


arm-sdk
-------

The _arm-sdk_ is our way of facilitating builds for embedded ARM boards
such as Allwinner-based CPUs, Raspberry Pis, Chromebooks, etc. It holds
a knowledgebase for a number of embedded devices, and how to build
according kernels and bootloaders.


### Directory structure

arm-sdk's directory structure is separated into places where we hold our
boards and their kernel configurations, device-specific directories with
firmware and/or configuration, and a lib directory (where we keep
libdevuansdk and the like).


### Obtaining arm-sdk

The SDK, like any other, should be obtained via git. The repositories
are hosted on Devuan's Gitlab. To grab it, we simply issue a _git clone_
command, an since it contains git submodules - we append _--recursive_
to it:

```
$ git clone https://git.devuan.org/sdk/arm-sdk --recursive
```

Consult the README.md file found in this repository to see what are the
required dependencies to use arm-sdk.


### Using arm-sdk

Once the build system is obtained, it can now be used interactively. The
process is very simple, and to build an image one can actually use a
single shell command. However, we shall first show how it works.

In arm-sdk, every board has its own script located in the _boards_
directory. In most cases, these scripts contain functions to build the
Linux kernel, and a bootloader needed for the board to boot. This is the
only difference between all the boards, which requires every board to
have their own script. We are able to reuse the rootfs that is
bootstrapped before. For our example, let's take the _Nokia N900_ build
script. To build a vanilla image for it, we simply issue:


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
functions to build our image. The _load_ command takes an optional third
argument which is the name of our blend (the way to customize our
vanilla image) which will be explained later. So in this case, our
oneliner would look like:

```
$ zsh -f -c 'source sdk && load devuan n900 decode && build_image_dist'
```

This would create an image with the _"decode"_ blend, which is available
by cloning the DECODE OS git repository. The *build_image_dist* command
is a helper function located in libdevuansdk that wraps around the 8
functions needed to build our image. They are all explained in the
technical part of this paper.


live-sdk
--------

The _live-sdk_ is used to build bootable images, better known as Live
CDs. Its structure is very similar to _vm-sdk_ and is a lot smaller than
_arm-sdk_.


### Directory structure

Unlike arm-sdk, in live-sdk we have no need for specific boards or
setups, so in this case we only host the interactive shell init, and
libraries.


### Obtaining live-sdk

The SDK, like any other, should be obtained via git. The repositories
are hosted on Devuan's Gitlab. To grab it, we simply issue a _git clone_
command, an since it contains git submodules - we append _--recursive_
to it:

```
$ git clone https://git.devuan.org/sdk/live-sdk --recursive
```

Consult the README.md file found in this repository to see what are the
required dependencies to use live-sdk.


### Using live-sdk

Much like _arm-sdk_, the _live-sdk_ is used the same way. With two
specific differences. Since we don't have any need for specific boards,
with loading we don't specify a board, but rather the CPU architecture
we are building for. Currently supported are *i386* and *amd64* which
represent 32bit and 64bit respectively. To build a vanilla live ISO, we
issue:

```
$ zsh -f -c 'source sdk && load devuan amd64 && build_iso_dist'
```

This will start the build process, and after a certain amount of time we
will have our ISO ready and inside the _dist_ directory.

Just like in arm-sdk, we can use a _blend_ and customize our OS:

```
$ zsh -f -c 'source sdk && load devuan amd64 decode && build_iso_dist'
```

So this would create a live ISO of DECODE OS. Again as noted, this can
be obtained by recursively cloning the decode-os git repository.

The *build_iso_dist* command is a helper function located in
libdevuansdk that wraps around the 9 functions needed to build our
image. They are all explained in the technical part of this manual.


vm-sdk
------

The _vm-sdk_ is used to build VirtualBox/Vagrant boxes, and virtual
images for emulation, in QCOW2 format, which is a nifty byproduct of
building a Vagrant box. Its structure is very similar to _live-sdk_ and
is the smallest of the three wrappers currently found in the Devuan SDK.


### Directory structure

Like with live-sdk, in vm-sdk we have no need for specific boards or
setups, so in this case we only host the interactive shell init, and
libraries.


### Obtaining vm-sdk

The SDK, like any other, should be obtained via git. The repositories
are hosted on Devuan's Gitlab. To grab it, we simply issue a _git clone_
command, an since it contains git submodules - we append _--recursive_
to it:

```
$ git clone https://git.devuan.org/sdk/vm-sdk --recursive
```

Consult the README.md file found in this repository to see what are the
required dependencies to use vm-sdk.


### Using vm-sdk

Once obtained, we can use it interactively. The process is very simple,
and to build an image we use the oneliner we've already seen above.

Also like with live-sdk, we don't need specific boards, however we also
do not create any non-amd64 images, so we don't have to pass an
architecture to the load command either. To build a vanilla Vagrant Box,
VirtualBox image, qcow2 image, and a cloud-based qcow2 image, we issue:

```
$ zsh -f -c 'source sdk && load devuan && build_vagrant_dist'
```

This line would create al the four types of the VM image.

As shown with the previous two, the _blend_ concept works as advertised
here as well:

```
$ zsh -f -c 'source sdk && load deuvan decode && build_vagrant_dist'
```

The *build_vagrant_dist* command is a helper function located in
libdevuansdk that wraps around the 11 functions needed to build our
image. They are all explained in the technical part of this manual.
