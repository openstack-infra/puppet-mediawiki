define mediawiki::extension (
  $type     = 'extension',
  $ensure   = latest, # keep up to date
  $source   = undef, # actual default conditionally applied below
  $revision = 'origin/REL1_27',
) {
  if $type != 'extension' and $type != 'skin' {
    fail( '$type must be extension or skin' )
  }
  if $source == undef {
    # Set our actual default for $source here since we can't interpolate $type
    # in it for the resource parameter default
    $src = "https://gerrit.wikimedia.org/r/p/mediawiki/${type}s/${name}.git"
  } else {
    $src = $source
  }

  vcsrepo { "/srv/mediawiki/w/${type}s/${name}":
    ensure   => $ensure,
    provider => git,
    source   => $src,
    revision => $revision,
    require  => Vcsrepo['/srv/mediawiki/w'],
  }
}
