Rindeal's Ebuild Repository <img src="./assets/logo_96.png" title="Sir Benjamin the Bull" alt="logo" align="right">
============================

_Packages done right™_

[![Master Build Status][ci-master-badge]][ci-master]
[![Docker Build Status][docker-label-badge]][docker-hub-project][![Docker Build Status][docker-badge]][docker-hub-project]
<br/>
![Commit Stats][commit-stats-label-badge]
![First commit date][first-commit-badge][![Last commit date][last-commit-badge]](https://github.com/rindeal/rindeal-ebuild-repo/commits/master)[![Commit cadence][commit-cadence-label-badge]][pulse][![Commit cadence per week][commit-cadence-week-badge]][pulse][![Commit cadence per month][commit-cadence-month-badge]][pulse][![Commit cadence per year][commit-cadence-year-badge]][pulse][![Commits queued][commits-queued-badge]](https://github.com/rindeal/rindeal-ebuild-repo/compare/master...dev/rindeal)


Many ebuilds here are my own creatures, others are heavily modified forks, but all share the following features:

 - code in ebuilds is **clean and documented**
 - **USE flags** are provided for almost any build-time option
 - _mostly_ sane **default configurations** (default USE-flags, config files, ...)
 - exclusive **_systemd_** support
 - no _libav_, _libressl_, ... support
 - **locales** support (`nls`/`l10n_*` USE-flags)
 - **x86_64**/**armv6**/**armv7**/**armv8** architectures only
 - only the **native targets** are supported


How to install this repository
-------------------------------

### Manually (recommended)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf):

```ini
[rindeal]
## set this to any location you want
location = /var/pms/repos/rindeal
sync-uri = https://github.com/rindeal/rindeal-ebuild-repo.git
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
$ layman -o 'https://github.com/rindeal/rindeal-ebuild-repo/raw/master/repositories.xml' -f -a rindeal
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
All my ebuilds have been coded with the assumption of favouring my repository in case of such an overlap exists.
Breaking this assumption may lead to all kinds of nasty issues.
To make sure you're using only packages from my repository, there are several regularly updated `package.mask` files in `profiles/mask-alt-pkgs` directory, which
you can link to your `/etc/portage/package.mask` directory and thus mask all [Gentoo™] counterparts of packages from this repository.
To help automate the setup of these symlinks, I've created a tiny script called `profiles/mask-alt-pkgs/link.sh`, which you can use like this:

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

This all, of course, doesn't prevent build failures, missing dependencies, etc. Should you find
any issues, don't like something or just want to report morning news, please send me a PR or [file an issue][New issue].


-------------------------------------------------------------------------------


### Colophon

- All code in this repo is licenced under GPL-2 ([full licence](./LICENSE)), if not stated otherwise.
- As opposed to other similar repositories the copyright to work that goes into developing this repository
is not dedicated to the&nbsp;_Gentoo&nbsp;Foundation,&nbsp;Inc._ or any similar umbrella entity,
which means it **cannot** be legally contributed to the [Gentoo™] ebuild repository as their own guidelines forbid so.
<br />TL;DR: if you're trying to get code from here to the [Gentoo™] ebuild repository (legally), you are out of luck!
- _Gentoo_ is a trademark of the _Gentoo Foundation, Inc._
- [Animal vector designed by Freepik](https://www.freepik.com/free-vector/polygonal-bull-head_747949.htm)

[protected branches]: https://help.github.com/articles/about-protected-branches/
[LISTING]: ./LISTING.md
[New issue]: https://github.com/rindeal/rindeal-ebuild-repo/issues/new
[ci-master]: https://travis-ci.com/rindeal/rindeal-ebuild-repo
[docker-hub-project]: https://hub.docker.com/r/rindeal/portage-amd64-base/
[Gentoo™]: https://www.gentoo.org/ "main Gentoo project website"
[pulse]: https://github.com/rindeal/rindeal-ebuild-repo/pulse "GitHub Pulse for rindeal-ebuild-repo"

[ci-master-badge]:             https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square&label=CI@master&cacheSeconds=300
[docker-label-badge]:          https://img.shields.io/badge/-image-gray.svg?style=flat-square&logo=docker&cacheSeconds=86400
[docker-badge]:                https://semaphoreci.com/api/v1/rindeal/portage-docker-images/branches/master/shields_badge.svg
[commit-stats-label-badge]:    https://img.shields.io/badge/-commit%20stats:-gray.svg?style=flat-square&cacheSeconds=86400
[first-commit-badge]:          https://img.shields.io/date/1439332378.svg?label=first&style=flat-square&cacheSeconds=86400
[last-commit-badge]:           https://img.shields.io/github/last-commit/rindeal/rindeal-ebuild-repo/master.svg?label=last&style=flat-square&cacheSeconds=300
[commit-cadence-label-badge]:  https://img.shields.io/badge/-cadence-gray.svg?style=flat-square&cacheSeconds=86400
[commit-cadence-week-badge]:   https://img.shields.io/github/commit-activity/w/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[commit-cadence-month-badge]:  https://img.shields.io/github/commit-activity/m/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[commit-cadence-year-badge]:   https://img.shields.io/github/commit-activity/y/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[commits-queued-badge]:        https://img.shields.io/github/commits-since/rindeal/rindeal-ebuild-repo/master/dev/rindeal.svg?label=queued&style=flat-square&cacheSeconds=600
