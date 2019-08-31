How to install this repository
------------------------------

### Manually (recommended)

#### 1. Add an entry to [`/etc/portage/repos.conf`](https://wiki.gentoo.org/wiki//etc/portage/repos.conf)

```ini
[rindeal]
location = /var/pms/repos/rindeal
#          ^^^^^^^^^^^^^^^^^^^^^^ set this to any location you want
sync-uri = https://github.com/rindeal/rindeal-ebuild-repo.git
sync-type = git
auto-sync = yes
priority = 9999
#          ^^^^ prefer my packages over the Gentoo™ ones to improve UX and stability (recommended by yes/10 IT experts)
```

#### 2. Sync

```sh
% # Preferrably
% eix-sync
% # or if you need to
% emerge --sync
```

### Automatically with Layman

```sh
% layman -o 'https://github.com/rindeal/rindeal-ebuild-repo/raw/master/repositories.xml' -f -a rindeal
```

Additional repository configuration
------------------------------------

### Enable "unstable" packages

Most packages in this repository have tilde before their keywords.
Only some old packages or packages which have to satisfy Gentoo dependencies have been marked "stable".
So if you want to enable the full potential of this repository, make sure you have the following configuration enabled:

```sh
# `/etc/portage/package.accepted_keywords`:
*/*::rindeal ~amd64  # or ~arm/~arm64
```

### Prevent collisions between this repository and [Gentoo™][] repository

Many packages here have their _inferior_ counterparts in the [Gentoo™][] repository.
All my ebuilds have been coded with the assumption of favouring my repository in case of such an overlap exists.
Breaking this assumption may lead to all kinds of nasty issues.
To make sure you're using only packages from my repository, there are several regularly updated `package.mask` files in `profiles/mask-alt-pkgs` directory, which
you can link to your `/etc/portage/package.mask` directory and thus mask all [Gentoo™][] counterparts of packages from this repository.
To help automate the setup of these symlinks, I've created a tiny script called `profiles/mask-alt-pkgs/link.sh`, which you can use like this:

```sh
$ <RINDEAL_REPO_DIR>/profiles/mask-alt-pkgs/link.sh /etc/portage/package.mask/rindeal-mask-alt-pkgs/
```

[Gentoo™]: https://www.gentoo.org/ "main Gentoo project website"
