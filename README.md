Rindeal's Ebuild Repository <img src="./assets/logo_96.png" title="Sir Benjamin the Bull" alt="logo" align="right">
============================

<i>Packages done right™</i>

<!---
----------------------------------- BADGES -------------------------------------
--->

[![][badge-ci-master]](https://travis-ci.com/rindeal/rindeal-ebuild-repo)
[![][badge-docker-label]![][badge-docker]](https://hub.docker.com/r/rindeal/portage-amd64-base/)
[![][badge-code-quality]](https://www.codacy.com/app/rindeal/rindeal-ebuild-repo)
<br/>
[![][badge-commit-stats-label]][git-commits-master]
[![][badge-first-commit]][git-first-commit][![][badge-last-commit]][git-commits-master]
[![][badge-commit-cadence-label]![][badge-commit-cadence-week]![][badge-commit-cadence-month]![][badge-commit-cadence-year]][github-pulse]
[![][badge-commits-queued]][git-compare-master-dev]

<!---
----------------------------------- MENU ---------------------------------------
--->

[Homepage][homepage] | [Issue tracker][issue-tracker] | **[Installation instructions][installation-instructions]**

<!---
------------------------------ DOCUMENT_START ----------------------------------
--->

In this repository you can find [ebuild](https://wiki.gentoo.org/wiki/Ebuild)s for [PMS](https://wiki.gentoo.org/wiki/Package_Manager_Specification)-compatible package managers.

Many ebuilds here are my own creatures,
others are <em>heavily</em> modified forks,
but all share the following features:

- so much USE **flags**, many appreciated
- unique **experience** from the start with i<sup>n</sup><sup><sub><em>s</em></sub></sup><sub>a</sub>n<sup>e</sup> **default** configurations
- wild patches and scripts to hit **annoy**ances in software where it hurts the most
- source **code smells** like freshly cut grass and looks even better <sub><sup>(doesn't work as much)</sup></sub>
- gay-like builds - completely irreproducible without **laboratory** equipment
- support for:
  - **_systemd_** exclusively
  - **x86_64**/**armv6**/**armv7**/**armv8** architectures only
  - **locales** (`nls`/`l10n_*` USE-flags)
- limited support for:
  - [<i>Prefix</i>](https://wiki.gentoo.org/wiki/Project:Prefix)
  - [<i>binpkgs</i>](https://wiki.gentoo.org/wiki/Binary_package_guide)
- no support for:
  - non-native targets (32-bit ABI, cross-compilation)
  - <i>libav</i>, <i>libressl</i>, ...
  - `src_test` phase

--------------------------------------------------------------------------------

### Legal notice

- All code in this repo is licenced under [GPL-2](./LICENSE), if not stated otherwise.
- _[Gentoo™][]_ is a trademark of the _Gentoo Foundation, Inc._
- [Animal vector designed by Freepik](https://www.freepik.com/free-vector/polygonal-bull-head_747949.htm)

<!---
------------------------------ END_OF_DOCUMENT ---------------------------------
--->

[Gentoo™]: https://www.gentoo.org/ "main Gentoo project website"

[homepage]: https://github.com/rindeal/rindeal-ebuild-repo
[issue-tracker]: https://github.com/rindeal/rindeal-ebuild-repo/issues
[installation-instructions]: ./INSTALL.md#how-to-install-this-repository

[github-pulse]: https://github.com/rindeal/rindeal-ebuild-repo/pulse "GitHub Pulse for rindeal-ebuild-repo"
[docker-hub-project]: https://hub.docker.com/r/rindeal/portage-amd64-base/
[git-first-commit]:            https://github.com/rindeal/rindeal-ebuild-repo/commit/a7fdc35fde3388c2bf95b8beab8a14afb7082f31
[git-commits-master]:          https://github.com/rindeal/rindeal-ebuild-repo/commits/master
[git-compare-master-dev]:      https://github.com/rindeal/rindeal-ebuild-repo/compare/master...dev/rindeal

[badge-ci-master]:             https://img.shields.io/travis/rindeal/rindeal-ebuild-repo/master.svg?style=flat-square&label=CI@master&cacheSeconds=300
[badge-docker-label]:          https://img.shields.io/badge/-image-gray.svg?style=flat-square&logo=docker&cacheSeconds=86400
[badge-docker]:                https://semaphoreci.com/api/v1/rindeal/portage-docker-images/branches/master/shields_badge.svg
[badge-code-quality]:          https://img.shields.io/codacy/grade/3705846277d040f0946ac4d4e34c715f?logo=Codacy&style=flat-square&cacheSeconds=60
[badge-commit-stats-label]:    https://img.shields.io/badge/-commit%20stats:-gray.svg?style=flat-square&cacheSeconds=86400
[badge-first-commit]:          https://img.shields.io/date/1439332378.svg?label=first&style=flat-square&cacheSeconds=86400
[badge-last-commit]:           https://img.shields.io/github/last-commit/rindeal/rindeal-ebuild-repo/master.svg?label=last&style=flat-square&cacheSeconds=300
[badge-commit-cadence-label]:  https://img.shields.io/badge/-cadence-gray.svg?style=flat-square&cacheSeconds=86400
[badge-commit-cadence-week]:   https://img.shields.io/github/commit-activity/w/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[badge-commit-cadence-month]:  https://img.shields.io/github/commit-activity/m/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[badge-commit-cadence-year]:   https://img.shields.io/github/commit-activity/y/rindeal/rindeal-ebuild-repo.svg?label=&style=flat-square&cacheSeconds=60
[badge-commits-queued]:        https://img.shields.io/github/commits-since/rindeal/rindeal-ebuild-repo/master/dev/rindeal.svg?label=queued&style=flat-square&cacheSeconds=600
