Blends
======


Introduction
------------

In the Devuan SDK, a _blend_ is the preferred way we use to make
customizations to the vanilla image. Using blends we can very easily
create different flavors of our image, by easily including/excluding
certain software packages, files, or anything we wish to do as a matter
of fact. Blends can become a very quick way of creating entire new
derivatives of the vanilla distribution we are building.

This time, we will take the DECODE OS as a blend example. In DECODE OS
we provide a blend called _decode_  which is the blend we use to create
a production release of DECODE OS. The blend's files are contained
within their own directory in the decode-os git repository.


Configuration
-------------

Any SDK requires a single file to act as a blend. This file is also a
zsh script, and, at the very least, it must contain two functions
called:

```
blend_preinst()
blend_postinst()
```

These functions are your pathway to expanding your blend into whatever
you would like to do. The _preinst_ function is usually called right
after bootstrapping the vanilla root filesystem, and the _postinst_
function is called near the very end, just before packing or compressing
the image. These two strategic places should be enough to do changes
within the image. If this is not enough, blends also allow you to simply
**override any variable or function** contained within libdevuansdk or
the sdk you are using.

Our _decode_ blend is such an example. It is a somewhat expanded blend,
not contained within a single file, but rather a directory. This allows
easier maintenance and makes the scripts clearer and cleaner.


### Adding and removing packages

When we want to add or remove specific packages to our build, we have to
override or append to libdevuansdk's arrays. The array for packages we
want installed is called *extra_packages*, and the array for packages we
want purged is called *purge_packages*. In the decode blend, these can
be found in the _config_ file located inside the decode-os blend
directory.  Keep in mind that these arrays could already contain
specific packages, so you are advised to rather append to them, than
overriding them.

If the packages you want to install are not available in the repos, you
still have a way of automatically installing them. All you need to do to
take care of it is at some point in your blend - copy your .deb files to
the following directory:

```
$R/extra/custom-packages/
```

And when that is done, just call the function *install-custdebs*


Creating a blend
----------------

Rather than explaining theory, you are best off viewing the blend files
that are provided with _decode-os_. It is a fairly simple blend and
should give you enough insight on creating your own blend. Here are some
important guidelines for creating a blend:


* The blend should always contain at least two functions

This means you must provide *blend_preinst* and *blend_postinst* in your
blend.  They don't even have to do anything, but they should be there.
These two functions open the path for you to call any other functions
you created for your blend.


* When overriding functions, make sure they provide a result that
  doesn't break the API

Breaking the API may result in unwanted behavior. You should always
study well the functions you are planning to override and figure out if
it is safe to override them in the way you want. The same goes for any
variables as well.


* Any arguments used after the blend name when loading from the SDK are
  free for you to use in the blend.

This means you can use anything **after $4** inside your blend if you
require passing arguments to it.

These are some of the more important guidelines. There is plenty more
tricks and quirks, but it's easy to find out once you read a blend or
two on your own...


### Enable the blend

To use your blend in the first place, you need to make the sdk know
about it. To make this work, you need to append the path to your new
blend inside the **blend_map** of the _sdk_ file:

```
blend_map=(
    "devuan-live"    "$R/blends/devuan-live/devuan-live.blend"
    "decode"         "$R/../decode.blend"
    "heads"          "$R/../heads.blend"
    "ournewblend"    "$R/blends/newblend/new-blend.blend"
)
```

As you can see, the map is a key-value storage. So you can have an alias
(name) for your blend, and just use that to point to the path of the
blend. The blend file will be sourced by the sdk once it is told to do
so.


### A configuration file

For having a finer-grained control of what goes into our build, we can
create a config file for our blend. From here we can easily control any
configurable aspect of our blend, such as packages that go in or out,
the blend name, and much more. **Make sure you source this file from
your blend.**

Adding and removing packages was abstractly mentioned earlier: it goes
into two separate arrays holding package names. To add packages, we
append to the **extra_packages** array, which would look like this:

```
extra_packages+=(
    my_new_package
    foo
    bar
    baz
)
```

This would install these four packages, along with the ones predefined
in either libdevuansdk or the sdk you are using. You may also want to
see which those are in case you wish to exclude them, but they are sane
and useful utilities which should be included in your build if possible.
Overriding all those packages, you would need to reset the whole array,
so you would simply issue this:

```
extra_packages=(
    my_new_package
    foo
    bar
    baz
)
```

As you can see, we no longer have the _+=_, but rather only _=_, which
means we are not appending to the array, but rather redefining it.

All of the above applies as well for removing packages, but in this case
the array is called **purge_packages**.


#### Custom packages

If you want to install deb packages that aren't in any repositories, put
them in the blend directory and simply add them to another array in the
configuration file. The contents of the arrays are the paths to the
debs, relative to this configuration file:

```
custom_deb_packages=(
    yad_0.27.0-1_amd64.deb
    palemoon_27.2.0~repack-1_amd64.deb
)
```

To trigger installation of these packages, you will need to copy them to
`$R/extra/custom_packages`, and then call the **install_custdebs**
function somewhere from your blend.


### Custom files

Any files you want to add to the system to override what's there by
default you can add using a *rootfs overlay*. Create a directory inside
your blend directory called *rootfs-overlay* and simply put files inside
it. The directory structure is absolute to the image we are building.
For example what's in "rootfs-overlay/etc/" would end up in the "/etc"
of our final image. See _hier(7)_ from the Linux manpages for more
explanation on this directory hierarchy.

If you end up with any files here, to actually copy them, you will need
to `cp -f` it, or `rsync` it if you prefer.


### The .blend file

We listed a path to the .blend file in our first step. We need to create
this file now.

Start your blend file with the following, so the sdk is aware of the
environment:

```
BLENDPATH="${BLENDPATH:-$(dirname $0)}"
source $BLENDPATH/config
```

The minimum blend should contain two functions: **blend_preinst** and
**blend_postinst**. These functions are called at specific points in the
build, where they give the most power: just after bootstrapping the
vanilla system, and just before packaging the final build, respectively.


#### blend_preinst

A preinst function can look like this:

```
blend_preinst() {
    fn blend_preinst
    req=(BLENDPATH R)
    ckreq || return 1

    notice "executing blend preinst"

    add-user "user" "pass"
    cp -fv "$BLENDPATH"/*.deb "$R/extra/custom-packages" || zerr
    install-custdebs || zerr
}
```

So as you can see, the preinst function will add a new user with the
credentials `user:pass`, it will copy our custom debs where they can be
used, and finally it will trigger their installation.

The `fn, req, ckreq` part on the top of the function is a safety check
for the function that is enabled by zuper. It allows us to check if
variables are defined when the function is called and fail if it is
wrong. You should utilize this as much as possible. The `zerr` calls are
used to exit if the function fails.


#### blend_postinst

A postinst function can look like the following:

```
blend_postinst() {
    fn blend_postinst
    req=(BLENDPATH strapdir)
    ckreq || return 1

    notice "executing blend postinst"

    sudo cp -vf "$BLENDPATH"/rootfs-overlay/* $strapdir || zerr

    blend_finalize || zerr
}
```

This function would copy the `rootfs-overlay` to the `strapdir` (which
holds our image's filesystem) and it would call the `blend_finalize`
function. By default this function doesn't exist, but it's an example so
you can see you can call your own functions as well. You can define them
within the blend file.


Using a blend
-------------

As explained in previous chapters, you can use your blends through the
interactive SDK shell. In decode-os the blend is placed in the root of
the git repository, and the sdk wrappers are located within. Therefore
an sdk would have to source it with such a path:

```
$R/../decode.blend
```

If you take a look at vm-sdk's *sdk* file, you can see it in the
*blend_map*.  Using a new blend requires you to add it to this map in
the same manner. The map is key-value formatted, and on the left you
have an alias of your blend, and on the right you have a script you have
to write. It can either be the blend itself or any helper file you might
need to initialize your blend.

After you've added it to the blend map, you simply initialize the sdk,
and use the same *load* command we learned earlier, while appending the
blend alias and any optional argument.

```
$ zsh -f
$ source sdk
$ load devuan decode <these> <arguments> <we> <can> <use> <in> <the> <blend>
```

And we've initialized our *decode* blend. It's always good to add a
*notice()* call to your blend to signal it's been loaded successfully.

After this is done, we simply build the image the same way we learned
before:

```
$ build_vagrant_dist
```

Consult the vm-sdk chapter for this.
