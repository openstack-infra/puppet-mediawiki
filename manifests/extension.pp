define mediawiki::extension (
  $type     = 'extension',
  $ensure   = latest, # keep up to date
  $source   = "https://gerrit.wikimedia.org/r/p/mediawiki/${type}/${name}.git"
  $revision = 'origin/REL1_27',
) {
  if $type != 'extension' and $type != 'skin' {
    fail( '$type must be extension or skin' )
  }
  vcsrepo { "/srv/mediawiki/w/${type}/${name}":
    ensure   => $ensure,
    provider => git,
    source   => $source,
    revision => $revision,
  }
}
