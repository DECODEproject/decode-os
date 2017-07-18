# DECODE OS - build system

DECODE's operating system is designed to run a DECODE NODE that
automatically connects to DECODE's P2P network and executes smart
rules according to authenticated entitlements on attributes.

For stable releases see https://files.dyne.org/decode

## Requirements

A GNU/Linux system is required in order to build DECODE OS.

Here a list of package dependencies:
```
zsh debootstrap sudo kpartx cgpt xz-utils qemu qemu-utils
```

In addition one must install `vagrant` and `virtualbox` from latest
published packages (do not use distro provided packages, as they are
updated).


## Getting started

To enter the build console just run `./console.sh`.

To build a vagrant virtual machine, run `build_vagrant_dist`.

To build a live iso image, run `build_iso_dist`.

To build an ARM installer image, run `build_image_dist`.

Here below the sequences of build steps executed by each target:

```zsh
build_image_dist() {
	bootstrap_complete_base            || { zerr; wrapup }
	blend_preinst                      || { zerr; wrapup }
	image_prepare_raw                  || { zerr; wrapup }
	image_partition_raw_${parted_type} || { zerr; wrapup }
	build_kernel_${arch}               || { zerr; wrapup }
	blend_postinst                     || { zerr; wrapup }
	rsync_to_raw_image                 || { zerr; wrapup }
	image_pack_dist                    || { zerr; wrapup }
}

build_iso_dist() {
	bootstrap_complete_base || { zerr; wrapup }
	blend_preinst           || { zerr; wrapup }
	iso_prepare_strap       || { zerr; wrapup }
	build_kernel_${arch}    || { zerr; wrapup }
	iso_setup_isolinux      || { zerr; wrapup }
	iso_write_isolinux_cfg  || { zerr; wrapup }
	#[[ $INSTALLER = 1 ]] && iso_setup_installer || zerr
	blend_postinst          || { zerr; wrapup }
	fill_apt_cache          || { zerr; wrapup }
	iso_squash_strap        || { zerr; wrapup }
	iso_xorriso_build       || { zerr; wrapup }
}

build_vagrant_dist() {
	image_${imageformat}_as_strapdir   || { zerr; wrapup }
	bootstrap_complete_base            || { zerr; wrapup }
	vm_inject_overrides                || { zerr; wrapup }
	blend_preinst                      || { zerr; wrapup }
	vm_setup_grub                      || { zerr; wrapup }
	blend_postinst                     || { zerr; wrapup }
	vm_umount_${imageformat}           || { zerr; wrapup }
	vm_vbox_setup                      || { zerr; wrapup }
	vm_vagrant_package                 || { zerr; wrapup }
	vm_pack_dist                       || { zerr; wrapup }
}
```




The `build_vagrant_dist` target is a helper that executes a sequence
of steps, some of them common to other helpers (hence
combinable). Here below the full list of build steps executed by
`build_vagrant_dist`


## Acknowledgments

The Devuan SDK used to build the DECODE OS was originally conceived
during a period of residency at the Schumacher college in Dartington,
UK. Greatly inspired by the laborious and mindful atmosphere of its
wonderful premises.

The Devuan SDK is Copyright (c) 2015-2017 by the Dyne.org Foundation

Devuan SDK components were designed, and are written and maintained by:

- Ivan J. <parazyd@dyne.org>
- Denis Roio <jaromil@dyne.org>
- Enzo Nicosia <katolaz@freaknet.org>

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
