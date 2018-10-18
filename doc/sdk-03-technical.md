The Devuan SDK more in-depth
============================

The following parts will explain the Devuan SDK more technically. It
will show its configuration, important functions, and show how it all
glues together.


Configuration
-------------

Much of the libdevuansdk configuration is done in `libdevuansdk/config`.
Here you can edit the defaults if you wish to do something your needs
are expressing. However, overriding these through upper levels is
recommended.


### `config` file

`vars` and `arrs` are global arrays for holding other global variables
and arrays, respectively. This is required for `zuper` and helps a lot
with debugging. If you declare new variables or arrays, add them to the
aforementioned variables.


* `os` holds the name of the distribution being worked on.

* `release` holds the release codename of the distribution. Used for apt
  repositories mostly.

* `version` is the version of the distribution being worked on.

* `mirror` is a mirror holding the required packages for `debootstrap`.

* `section` are the sections of the repository. For adding in
  `/etc/apt/sources.list`. Separate them with whitespaces.

* `image_name` is the output name of the raw image. If you declare a
  blend or a device name (arm-sdk), they will be appended to this name.

* `rootcredentials` and `usercredentials` are currently placeholders.

* `core_packages` is an array holding the core packages that will be
  installed in the bootstrap process.

* `base_packages` is an array holding the base packages that will be
  installed at a later point in the bootstrap process.

* `purge_packages` is an array of packages that will get purged at the
  end of the bootstrap process.


Helper functions
----------------

You can find useful helper functions in `libdevuansdk/zlibs/helpers`.
They are intended to help when it comes to writing wrappers, as well as
making the developers' jobs easier for developing libdevuansdk. Some of
these functions are required for libdevuansdk to work properly as well.


### `build_image_dist()`

This function is a kind of a wrapper function. It's used in arm-sdk to
build a complete dd-able image from start to end. To run, it requires
`$arch`, `$size`, `$parted_type`, `$workdir`, `$strapdir`, and
`$image_name` to be declared. See the part of "Creating wrappers" for
insight on these variables.

The workflow of this function is bootstrapping a complete rootfs,
creating a raw image, installing/compiling a kernel, rsyncing everything
to the raw image, and finally compressing the raw image.

This same workflow is applied in the next two functions in this file,
which are `build_iso_dist` and `build_vagrant_dist`. To get a better
understanding of libdevuansdk, it's recommended to go through one of
these functions and following it deeper to find and figure out the other
functions and how they work together.


### `devprocsys()`

This function is a simple helper function that takes two arguments. It
mounts or unmounts `/dev`, `/proc`, and `/sys` filesystems to or from
wherever you tell it to. For example:

```
$ devprocsys mount $strapdir
$ devprocsys umount $strapdir

```

It is very necessary to use this if one wants to do anything requiring
access to hardware or the system's resources, i.e. cryptography.


### `dpkgdivert()`

This function, like `devprocsys` takes two arguments and will create or
remove a dpkg diversion in the place you tell it to and remove
`invoke-rc.d` so that apt does not autostart daemons when they are
installed.


### `chroot-script()`

This very useful functions allows you to chroot into `$strapdir` and
execute the script/binary that's passed as a parameter to this function.
It also takes an optional argument `-d` that will call dpkgdivert on and
off before and after execution.

The `chroot-script` is also an example on its own that shows how to use
the `chroot-script` function.


Mandatory variables
-------------------

* `$R` is the root directory of a wrapper. It's defined already in all
  the existing ones. In almost evert situation it can be `$PWD`.

* `$workdir` is the working directory of the current build. A sane
  default is `$R/tmp/workdir`

* `$strapdir` is the bootstrap directory of the build. It holds the
  rootfs when you debootstrap it, and customize it further on. Default
  is `$workdir/rootfs`.

* `$arch` is the CPU architecture of the build. I.e. `amd64`, `armhf`,
  etc.
