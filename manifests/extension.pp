define mediawiki::extension (
  $type     = 'extension',
  $ensure   = undef,
  $source   = undef,
  $revision = undef,
) {
  if $type != 'extension' and $type != 'skin' {
    fail( '$type must be extension or skin' )
  }

  if $ensure == undef {
    $vcsensure = $::lsbdistcodename ? {
      'precise' => present,
      'trusty'  => latest, # keep up to date
    }
  } else {
    $vcsensure = $ensure
  }
  if $revision == undef {
    $vcsrevision = $::lsbdistcodename ? {
      'precise' => 'origin/master', # madness
      'trusty'  => 'origin/REL1_27',
    }
  } else {
    $vcsrevision = $revision
  }
  if $type == 'extension' {
    $path = "extensions/{$name}"
  } elsif $type == 'skin' {
    $path = "skins/{$name}"
  }
  if $source == undef {
    $vcssource = "https://gerrit.wikimedia.org/r/p/mediawiki/{$path}.git"
  } else {
    $vcssource = $source
  }
  vcsrepo { "/srv/mediawiki/w/{$path}":
    ensure   => $vcsensure,
    provider => git,
    source   => $vcssource,
    revision => $vcsrevision,
  }
}
