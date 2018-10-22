toaster.do
==========

The **toaster.do** setup is a modular web app relying on different
parts of DECODE's CI (continuous integration) and operating system
development software (SDK) used to facilitate builds of customized
Devuan images using Dockerfiles and a web interface. It allows us to
have a seamless way of using the Dockerfiles that are used in testing
to make production images using the same Dockerfile. This brings a
deterministic approach to debugging and allows centralization of
resources, while avoiding extra work needed to write a Devuan blend.

The web application is public on https://toaster.dyne.org

All following documentation contained in this document details the
internals of this application, of the components and infrastructure
that it is using. Unless specifically interested in these
implementation details, the web application facilitates the adoption
of all features described through a simple visual workflow.

The setup is comprised of a web interface written in Clojure, a backend
glue written in Python, the Devuan SDK, and the Jenkins CI system.

The main repository of this software component is
https://github.com/decodeproject/toaster.do


Clojure frontend
----------------

The Clojure frontend is an embedded web server with its own database,
which allows for managing of users. A user registered within this part
is then allowed to upload Dockerfiles and manage their image builds.

The frontend talks to the Python backend through SSH, and runs a
specific command to enable or disable a build job.


Jenkins backend
---------------

The backend glue is a Python tool which talks to Jenkins itself and
does all the managing and configuration of build jobs. It serves as the
backend to the Devuan SDK's web interface and is executed by the web CGI
when a build function is requested.
