# Class: mediawiki::app
#
class mediawiki::app {
  vcsrepo { '/srv/mediawiki/w':
    ensure   => present,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    revision => 'origin/master', # TODO: This is madness.
  }
  vcsrepo { '/srv/mediawiki/w/vendor':
    ensure   => present,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git',
    revision => 'origin/master', # TODO: No.
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
