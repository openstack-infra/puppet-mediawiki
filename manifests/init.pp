# Class: mediawiki
#
class mediawiki(
  $mediawiki_location         = '/srv/mediawiki/w',
  $mediawiki_images_location  = '/srv/mediawiki/images',
  $role                       = 'all',
  $site_hostname              = $::fqdn,
  $serveradmin                = "webmaster@${::fqdn}",
  $ssl_cert_file              = undef,
  $ssl_cert_file_contents     = undef,
  $ssl_chain_file             = undef,
  $ssl_chain_file_contents    = undef,
  $ssl_key_file               = undef,
  $ssl_key_file_contents      = undef,
  $wg_recaptchapublickey      = undef, # TODO: remove (no longer used)
  $wg_recaptchaprivatekey     = undef, # TODO: remove (no longer used)
  $wg_recaptchasitekey        = undef,
  $wg_recaptchasecretkey      = undef,
  $wg_googleanalyticsaccount  = undef,
  $wg_dbserver                = 'localhost',
  $wg_dbname                  = 'openstack_wiki',
  $wg_dbuser                  = 'wikiuser',
  $wg_dbpassword              = undef,
  $wg_secretkey               = undef,
  $wg_upgradekey              = undef,
) {

  if ($role == 'app' or $role == 'all') {
    # This is equivalent to apache::dev which is not puppet3
    # compatible with puppetlabs-apache 0.0.4:
    package { ['libaprutil1-dev', 'libapr1-dev', 'apache2-prefork-dev']:
      ensure => present,
    }

    file { '/srv/mediawiki':
      ensure => directory,
    }

    file { '/srv/mediawiki/Settings.php':
      ensure  => file,
      content => template('mediawiki/Settings.php.erb'),
      group   => 'www-data',
      mode    => '0640',
      owner   => 'root',
      require => File['/srv/mediawiki'],
    }

    include ::httpd
    include ::mediawiki::php
    include ::mediawiki::app

    mediawiki::extension { [ 'ConfirmEdit',
        'OpenID',
        'Renameuser',
        'WikiEditor',
        'CodeEditor',
        'Scribunto',
        'Gadgets',
        'CategoryTree',
        'ParserFunctions',
        'SyntaxHighlight_GeSHi',
        'Cite',
        'cldr',
        'Babel',
        'Translate',
        'Collection',
        'Nuke',
        'AntiSpoof',
        'Mantle',
        'MobileFrontend',
        'SubPageList3',
        'ReplaceText',
        'googleAnalytics',
        'Echo',
        'UniversalLanguageSelector',
        'Elastica',
        'CirrusSearch',
        'SpamBlacklist',
        'SmiteSpam' ]:
    }

    mediawiki::extension { 'EmbedVideo':
        ensure   => present,
        source   => 'https://github.com/HydraWiki/mediawiki-embedvideo.git',
        revision => 'origin/master', # Not from Wikimedia repos :(
    }

    mediawiki::extension { 'strapping':
        type   => 'skin',
        source => 'https://gerrit.wikimedia.org/r/p/mediawiki/skins/mediawiki-strapping.git',
    }

    file { '/srv/mediawiki/w/LocalSettings.php':
        ensure  => link,
        target  => '/srv/mediawiki/Settings.php',
        require => Vcsrepo['/srv/mediawiki/w'],
    }

    package { ['libapache2-mod-php5',
      'lua5.2']:
      ensure => present,
    }

    # To use the standard ssl-certs package snakeoil certificate, leave both
    # $ssl_cert_file and $ssl_cert_file_contents empty. To use an existing
    # certificate, specify its path for $ssl_cert_file and leave
    # $ssl_cert_file_contents empty. To manage the certificate with puppet,
    # provide $ssl_cert_file_contents and optionally specify the path to use for
    # it in $ssl_cert_file.
    if ($ssl_cert_file == undef) and ($ssl_cert_file_contents == undef) {
      $cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem'
      if ! defined(Package['ssl-cert']) {
        package { 'ssl-cert':
          ensure => present,
          before => Httpd::Vhost[$site_hostname],
        }
      }
    } else {
      if $ssl_cert_file == undef {
        $cert_file = "/etc/ssl/certs/${::fqdn}.pem"
        if ! defined(File['/etc/ssl/certs']) {
          file { '/etc/ssl/certs':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            before => File[$cert_file],
          }
        }
      } else {
        $cert_file = $ssl_cert_file
      }
      if $ssl_cert_file_contents != undef {
        file { $cert_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $ssl_cert_file_contents,
          before  => Httpd::Vhost[$site_hostname],
        }
      }
    }

    # To avoid using an intermediate certificate chain, leave both
    # $ssl_chain_file and $ssl_chain_file_contents empty. To use an existing
    # chain, specify its path for $ssl_chain_file and leave
    # $ssl_chain_file_contents empty. To manage the chain with puppet, provide
    # $ssl_chain_file_contents and optionally specify the path to use for it in
    # $ssl_chain_file.
    if ($ssl_chain_file == undef) and ($ssl_chain_file_contents == undef) {
      $chain_file = undef
    } else {
      if $ssl_chain_file == undef {
        $chain_file = "/etc/ssl/certs/${::fqdn}_intermediate.pem"
        if ! defined(File['/etc/ssl/certs']) {
          file { '/etc/ssl/certs':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0755',
            before => File[$chain_file],
          }
        }
      } else {
        $chain_file = $ssl_chain_file
      }
      if $ssl_chain_file_contents != undef {
        file { $chain_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0644',
          content => $ssl_chain_file_contents,
          before  => Httpd::Vhost[$site_hostname],
        }
      }
    }

    # To use the standard ssl-certs package snakeoil key, leave both
    # $ssl_key_file and $ssl_key_file_contents empty. To use an existing key,
    # specify its path for $ssl_key_file and leave $ssl_key_file_contents empty.
    # To manage the key with puppet, provide $ssl_key_file_contents and
    # optionally specify the path to use for it in $ssl_key_file.
    if ($ssl_key_file == undef) and ($ssl_key_file_contents == undef) {
      $key_file = '/etc/ssl/private/ssl-cert-snakeoil.key'
      if ! defined(Package['ssl-cert']) {
        package { 'ssl-cert':
          ensure => present,
          before => Httpd::Vhost[$site_hostname],
        }
      }
    } else {
      if $ssl_key_file == undef {
        $key_file = "/etc/ssl/private/${::fqdn}.key"
        if ! defined(File['/etc/ssl/private']) {
          file { '/etc/ssl/private':
            ensure => directory,
            owner  => 'root',
            group  => 'root',
            mode   => '0700',
            before => File[$key_file],
          }
        }
      } else {
        $key_file = $ssl_key_file
      }
      if $ssl_key_file_contents != undef {
        file { $key_file:
          ensure  => present,
          owner   => 'root',
          group   => 'root',
          mode    => '0600',
          content => $ssl_key_file_contents,
          before  => Httpd::Vhost[$site_hostname],
        }
      }
    }

    ::httpd::vhost { $site_hostname:
      port       => 443, # Is required despite not being used.
      docroot    => '/var/www',
      priority   => '50',
      template   => 'mediawiki/apache/mediawiki.erb',
      ssl        => true,
      vhost_name => $site_hostname,
    }
    httpd_mod { 'rewrite':
      ensure => present,
      before => Service['httpd'],
    }
    httpd_mod { 'expires':
      ensure => present,
      before => Service['httpd'],
    }
  }
  if ($role == 'image-scaler' or $role == 'all') {
    include ::mediawiki::image_scaler
    include ::mediawiki::php
    include ::mediawiki::app
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
