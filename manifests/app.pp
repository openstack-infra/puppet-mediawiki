# Class: mediawiki::app
#
class mediawiki::app {
  $ensure = $::lsbdistcodename ? {
    'precise' => present,
    'trusty'  => latest, # keep up to date
  }
  $revision = $::lsbdistcodename ? {
    'precise' => 'origin/master', # madness
    'trusty'  => 'origin/REL1_27',
  }
  vcsrepo { '/srv/mediawiki/w':
    ensure   => $ensure,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/core.git',
    revision => $revision,
  }
  vcsrepo { '/srv/mediawiki/w/vendor':
    ensure   => $ensure,
    provider => git,
    source   => 'https://gerrit.wikimedia.org/r/p/mediawiki/vendor.git',
    revision => $revision,
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
