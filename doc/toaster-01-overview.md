toaster.do
==========

The **toaster.do** setup is an ecosystem of modular parts of software
used to facilitate builds of customized Devuan images using Dockerfiles
and a web interface. It allows us to have a seamless way of using the
Dockerfiles that are used in testing to make production images using the
same Dockerfile. This brings a deterministic approach to debugging and
allows centralization of resources, while avoiding extra work needed to
write a Devuan blend.

The setup is comprised of a web interface written in Clojure, a backend
glue written in Python, the Devuan SDK, and the Jenkins CI system.


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
