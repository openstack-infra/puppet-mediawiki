# Class: mediawiki::php
#
class mediawiki::php {
  package { ['php5',
    'php5-cli',
    'php5-mysql',
    'php-apc',
    'php5-intl',
    'php-openid',
    'php5-memcached']:
    ensure => present,
  }
  # TODO: apc configuration
}
