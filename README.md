# Operating System for Private and Anonymous Computation Clusters

[![software by Dyne.org](https://www.dyne.org/wp-content/uploads/2015/12/software_by_dyne.png)](http://www.dyne.org)

<div class="center">

The DECODE operating system is a brand new GNU+Linux distribution
designed to run on servers, embedded computers and virtual machines to
automatically connect micro-services to a private and anonymous
peer-to-peer network cluster.

</div>

<img src="https://decodeos.dyne.org/img/decodeos_logo-800px.jpg" class="pic" alt="DECODE OS logo">

| Features                                   | Components                                                                                                                                                                                                  |
|--------------------------------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Wide compatibility with industry standards | GNU + Linux minimal base                                                                                                                                                                                    |
| Anonimity and privacy by design            | [Tor](https://torproject.org) hidden service family                                                                                                                                                         |
| Very secure, restricted environment        | [grsec](https://github.com/minipli/linux-unofficial_grsec/wiki) community fork                                                                                                                              |
| Customisable to run different applications | [Devuan](https://devuan.org) GNU+Linux SDK                                                                                                                                                                  |
| Pluggable consensus algorithm              | [Redis](https://redis.io) based consensus broker                                                                                                                                                            |
| Read-only and authenticated system         | [SquashFS](http://tldp.org/HOWTO/SquashFS-HOWTO/whatis.html) + [overlayfs](https://www.kernel.org/doc/Documentation/filesystems/overlayfs.txt) + [Btrfs](https://btrfs.wiki.kernel.org/index.php/Main_Page) |
| Integrated updating mechanism              | [Roundshot](https://github.com/DECODEproject/roundshot) initramfs                                                                                                                                           |
| Built-in Graphical dashboard		     | [Netdata](https://github.com/netdata/netdata) resource monitor                                                                                                                                              |
| Low power consumption, outdoor usage       | Ports to embedded ARM boards                                                                                                                                                                                |
| Extensible platform support                | Includes latest JDK, Golang, Python etc.                                                                                                                                                                    |
| Minimal resource consumption               | Online with less than 64MB of RAM                                                                                                                                                                           |

## For stable releases see <a href="https://files.dyne.org/decode">files.dyne.org/decode</a>

## For more information see <a href="https://decodeproject.eu">the DECODE project</a>

In particular, the following publications:

- <a href="https://decodeproject.eu/publications/privacy-design-strategies-decode-architecture">Privacy Design Strategies for the DECODE Architecture</a>
- <a href="https://decodeproject.eu/publications/decode-os-first-release">Decode OS first release</a>
- <a href="https://decodeproject.eu/publications/decode-os-software-development-kit">DECODE OS Software Development Kit</a> (soon to be superseeded by the upcoming Devuan's Developer Manual)

## Usage instructions

DECODE OS comes in a variety of flavors:

- for ARM based boxes (embedded)
- for virtual machines (cloud)
- live desktop (boot from usb)

Running systems provide a dashboard by connecting using a browser
using HTTP on port 19999.

The default username is `decode` with password `decode`

The default `root` password is `toor`.

## Get in touch!

Developers of the Dyne.org foundation are available to support
customisations and adaptations of this operating system for particular
purposes in line with the foundation's goals.

You are welcome to contact us:

 - **#devuan-dev** on **freenode** IRC (public, logged IPs)
 - **#dyne** on <a href="https://irc.dyne.org">irc.dyne.org</a> (public and private, no IPs logged)
 - E-mail **info@dyne.org**

This project is a work in progress proceeding along a clear roadmap
agreed for the DECODE project. The DECODE OS **stable release is planned
for 1st quarter 2019**.

<img alt="Horizon 2020" src="https://zenroom.dyne.org/img/ec_logo.png" class="pic">

This project is receiving funding from the **European Union’s Horizon
2020 research and innovation programme under grant agreement
nr. 732546**.

## Build from source

The following instructions illustrate how one can build DECODE OS from
scratch, eventually adding software to it. This section is a work in
progress.

Building can be done from any GNU+Linux distribution, it entails
bootstrapping a new Devuan base and then customising it via its SDK
using a "blend", root access is needed in order to operate in `chroot`
and in KVM accellerated `qemu`.

More information on this process is provided by the "Devuan's
Developers Manual", here is an outline on the steps to be taken.



### System requirements

A GNU/Linux system is required in order to build DECODE OS.

Here a list of package dependencies:
```
zsh sudo cgpt xz-utils qemu qemu-utils
```

To clone this repository:

```
git clone https://github.com/DECODEproject/os-build-system --recursive
```

To update the repository:

```
git pull origin master && git submodule update --init --recursive --checkout
```


### Building for ARM targets

```
cd arm-sdk # (or vm-sdk or live-sdk depending from your target)
source sdk
load devuan raspi3 decode # (replace "raspi3" with the board name you want to build, from this list https://git.devuan.org/sdk/arm-sdk/blob/master/sdk )
bootstrap_complete_base
```


### Building for VM targets


To enter the build console just run `./console.sh`.

To build a vagrant virtual machine, run `build_vagrant_dist`.

To build a live iso image, run `build_iso_dist`.

To build an ARM installer image, run `build_image_dist`.

Here below the sequences of build steps executed by each target:

```sh
build_image_dist() {
	bootstrap_complete_base
	blend_preinst
	image_prepare_raw
	image_partition_raw_${parted_type}
	build_kernel_${arch}
	blend_postinst
	rsync_to_raw_image
	image_pack_dist
}

build_iso_dist() {
	bootstrap_complete_base
	blend_preinst
	iso_prepare_strap
	build_kernel_${arch}
	iso_setup_isolinux
	iso_write_isolinux_cfg
	blend_postinst
	fill_apt_cache
	iso_squash_strap
	iso_xorriso_build
}

build_vagrant_dist() {
	image_${imageformat}_as_strapdir
	bootstrap_complete_base
	vm_inject_overrides
	blend_preinst
	vm_setup_grub
	blend_postinst
	vm_umount_${imageformat}
	vm_vbox_setup
	vm_vagrant_package
	vm_pack_dist
}
```

The `build_vagrant_dist` target is a helper that executes a sequence
of steps, some of them common to other helpers (hence
combinable). Here below the full list of build steps executed by
`build_vagrant_dist`

The `bootstrap_complete_base` step creates a base system tarball that
can be reused by any target, it is found inside `*_sdk/tmp` for each
sdk and to save time and computation it can be copied in place for
each sdk if the base system doesn't differ.

## Acknowledgments

DECODE OS is Copyright (c) 2017-2018 by the Dyne.org Foundation

DECODE OS and its core components are designed, written and maintained
by Denis Roio and Ivan J.

Devuan is a registered trademark of the Dyne.org foundation.

The Devuan SDK used to build the DECODE OS was originally conceived
during a period of residency at the Schumacher college in Dartington,
UK. Greatly inspired by the laborious and mindful atmosphere of its
wonderful premises.

Devuan SDK components are designed, written and maintained by Denis
Roio, Enzo Nicosia and Ivan J.

This source code is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This software is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along
with this source code. If not, see <http://www.gnu.org/licenses/>.
