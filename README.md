Rindeal's Ebuild Repository <img src="./assets/logo_96.png" title="Sir Benjamin the Bull" alt="logo" align="right">
============================

_Packages done right™_

[![Master Build Status][ci-master-badge]][ci-master]
[![Docker Build Status][docker-label-badge]][docker-hub-project][![Docker Build Status][docker-badge]][docker-hub-project]
<br/>
[![Last Commit Status][last-commit-badge]](https://github.com/rindeal/rindeal-ebuild-repo/commits/master)


Many ebuilds here are my own creatures, others are heavily modified forks, but all share the following features:

 - code in ebuilds is **clean and documented**
 - **USE flags** are provided for almost any build-time option
 - _mostly_ sane **default configurations** (default USE-flags, config files, ...)
 - exclusive **_systemd_** support
 - no _libav_, _libressl_, ... support
 - **locales** support (`nls`/`l10n_*` USE-flags)
 - **x86_64**/**armv6**/**armv7**/**armv8** architectures only
 - only the **native targets** are supported

You can visit a user-friendly [list of packages][LISTING], where the chances are high for you to discover some great new software!
Also if you know about a not-yet-packaged software that is really worth packaging, you can demand it [on the issue tracker][New issue].


How to install this repository
-------------------------------

### Manually (recommended)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/cache/portage/repos/rindeal
sync-uri = https://ebuilds.janchren.eu/repos/rindeal/.git
sync-type = git
auto-sync = yes
## prefer my packages over the Gentoo™ ones to improve UX and stability (recommended by 9/10 IT experts)
priority = 9999
```

#### 2. Sync

```sh
# Preferrably
$ eix-sync
# or if you need to
$ emerge --sync
```

### Automatically with Layman

```sh
$ layman -o 'https://ebuilds.janchren.eu/repos/rindeal/repositories.xml' -f -a rindeal
```


Additional repository configuration
------------------------------------

### Enable "unstable" packages

Most packages in this repository have tilde before their keywords.
Only some old packages or packages which have to satisfy Gentoo dependencies have been marked "stable".
So if you want to enable the full potential of this repository, make sure you have the following configuration enabled:

`/etc/portage/package.accepted_keywords`:
```sh
*/*::rindeal ~amd64  # or ~arm/~arm64
```

### Prevent collisions between this repository and [Gentoo™] repository

Many packages here have their _inferior_ counterparts in the [Gentoo™] repository.
All my ebuild have been coded with the assumption that if there is such an overlap, it's always resolved in favour of my repository.
Breaking this assumption may lead to all kinds of nasty issues.
To make sure you're using only packages from my repository, there are several regularly updated `package.mask` files in `profiles/mask-alt-pkgs` directory, which
you can link to your `/etc/portage/package.mask` directory and thus mask all [Gentoo™] counterparts of packages from this repository.
To help automate the setup of these symlinks, I've created a small script called `profiles/mask-alt-pkgs/link.sh`, which you can use like this:

```sh
$ <RINDEAL_REPO_DIR>/profiles/mask-alt-pkgs/link.sh /etc/portage/package.mask/rindeal-mask-alt-pkgs/
```


Quality Assurance
------------------

You should be able to use any package from my repository without regrets, because I do and I have quite high standards.
To achieve this goal I'm using several safety guards:

- my brain (not always so obvious)
- continuous integration servers, which run:
    - _[repoman](https://wiki.gentoo.org/wiki/Repoman)_ checks
    - custom checks
    - [_Docker_ image](https://hub.docker.com/r/rindeal/portage-amd64-base/) builds
- last but not least I wish _really hard_ it would all just work :unicorn: :rainbow:

This all, of course, doesn't prevent build failures, missing dependencies, etc. So, should you find
any issues, don't like something or just want to report morning news, please send me a PR or [file an issue][New issue].


-------------------------------------------------------------------------------


### Colophon

- All code in this repo is licenced under GPL-2 ([full licence](./LICENSE)), if not stated otherwise.
- As opposed to other similar repositories the copyright to work that goes into developing this repository
is not dedicated to the&nbsp;_Gentoo&nbsp;Foundation,&nbsp;Inc._, which means it cannot be legally copied
to the main [Gentoo™] ebuild repository.
<br />TL;DR: if you're trying to get a code from here to the main [Gentoo™] ebuild repository, you're out of luck.
- _Gentoo_ is a trademark of the _Gentoo Foundation, Inc._
- [Animal vector designed by Freepik](http://www.freepik.com/free-photos-vectors/animal)

[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/rindeal-ebuild-repo/issues/new
[ci-master]: https://travis-ci.org/rindeal/rindeal-ebuild-repo
[docker-hub-project]: https://hub.docker.com/r/rindeal/portage-amd64-base/
[Gentoo™]: https://www.gentoo.org/ "main Gentoo project website"

[ci-master-badge]:           https://badge-proxy.janchren.eu/ttl=60/https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square&label=CI@master
[docker-label-badge]:        https://badge-proxy.janchren.eu/ttl=86400/https://img.shields.io/badge/docker-image-gray.svg?style=flat-square&longCache=true
[docker-badge]:              https://badge-proxy.janchren.eu/ttl=60/https://semaphoreci.com/api/v1/rindeal/portage-docker-images/branches/master/shields_badge.svg
[last-commit-badge]:         https://badge-proxy.janchren.eu/ttl=600/https://img.shields.io/github/last-commit/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square
