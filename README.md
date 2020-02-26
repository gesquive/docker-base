# docker-base
[![Build Status](https://img.shields.io/circleci/build/github/gesquive/docker-base?style=flat-square)](https://circleci.com/gh/gesquive/docker-base)
[![Docker Pulls](https://img.shields.io/docker/pulls/gesquive/docker-base?style=flat-square)](https://hub.docker.com/r/gesquive/docker-base)

A base docker container to help run other containers

Configures and includes the following:

 - User/Group is set to `runner:runner`
 - Installs [fixuid](https://github.com/boxboat/fixuid)
 - Installs an entrypoint `run` script that wraps `fixuid`

