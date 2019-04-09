# Class: mediawiki::php
#
class mediawiki::php {
  package { ['php',
    'php-cli',
    'php-mysql',
    'php-apc',
    'php-intl',
    'php-openid',
    'php-memcached']:
    ensure => present,
  }
  # TODO: apc configuration
}
