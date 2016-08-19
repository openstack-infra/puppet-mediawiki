# Class: mediawiki::app
#
class mediawiki::app {
  $revision = 'origin/REL1_27',
  vcsrepo { '/srv/mediawiki/w':
    ensure   => present,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    revision => $revision,
  }
  vcsrepo { '/srv/mediawiki/w/vendor':
    ensure   => present,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git',
    revision => $revision,
  }
  file { '/srv/mediawiki/w/cache':
    ensure  => directory,
    recurse => true,
    owner   => 'www-data',
    group   => 'www-data',
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
