Stable DECODE OS release
========================

This document accompanies the stable release of the DECODE OS, one of
the core development outputs of the DECODE project, aimed at providing
a reliable operating system to run application space development in an
environment ensuring privacy by design outside of the application
domain. This deliverable references, without duplication of
information, the research and development done and detailed in
previous deliverables D4.1 and D4.4.

The DECODE OS is a GNU+Linux distribution based on Devuan.org to
provide a minimalist base for distributed computing micro-services
capable of targeting any mainstream hardware platform, from
virtual-machines to ARM boards to bare-metal server racks.

The main website for this distribution is https://decodeos.dyne.org


As part of the DECODE OS distribution, backend software applications
have been developed to implement

1. a front-end web application to facilitate the adoption of the
   DECODE continuous integration infrastructure (toaster)
   https://toaster.dyne.org
2. a continuous integration system to release and customize new
   versions of DECODE OS (SDK) https://git.devuan.org/sdk
3. a private peer-to-peer network over the Tor protocol (tor-dam)
   https://github.com/decodeproject/tor-dam

These core features of these three components will be described in the
following sections of this document, along with operational
instructions.

Due to the experimental stage of development of other components in
DECODE and according to the LEAN principles declared in the project,
this stable release doesn't only constitute a final point of arrival
for this development task. What DECODE OS can do today is facilitating
the deployment of lab-tested software applications (for example made
in a Docker format, widely adopted by other partners in DECODE) and
render these prototypes into a production ready format that can be
deployed on the open-hardware DECODE BOX as well on virtual-machines.

We consider this achievement highly beneficial for a project whose
development is still in-flux, as well for the free and open source
community out there, since the access to the powerful features of the
SDK is now made very easy via an integrated continuous pipeline.

In light of these advantages, there is a clear intention within our
organisation (mainly by DYNE) to keep maintaining DECODE OS also
beyond the span of the project and this very task now concluded, since
it greatly helps the manning of prototypes into stable production
environments.


