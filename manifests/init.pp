# Class: mediawiki
#
class mediawiki(
  $role = 'all',
  $site_hostname = $::fqdn,
  $mediawiki_location = '/srv/mediawiki/w',
  $mediawiki_images_location = '/srv/mediawiki/images',
  $ssl_cert_file = '/etc/ssl/certs/ssl-cert-snakeoil.pem',
  $ssl_key_file = '/etc/ssl/private/ssl-cert-snakeoil.key',
  $ssl_chain_file = undef,
  $ssl_cert_file_contents = undef, # If left empty puppet will not create file.
  $ssl_key_file_contents = undef,  # If left empty puppet will not create file.
  $ssl_chain_file_contents = undef, # If left empty puppet will not create file.
  $wg_dbpassword = undef,
  $wg_secretkey = undef,
  $wg_upgradekey = undef,
  # TODO(pabelanger): Remove this once 284418 lands.
  $wg_captchaquestions_answer = undef,
  $wg_captchaquestions = {},
  $wg_googleanalyticsaccount = undef,
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

    # Disable external access to prevent spamming.
    # Original permission was 0644
    file { '/srv/mediawiki/w/includes/specials':
      ensure  => file,
      mode    => '0000',
      require => Class['::mediawiki::app'],
    }

    include ::httpd
    include ::mediawiki::php
    include ::mediawiki::app

    package { ['libapache2-mod-php5',
      'lua5.2']:
      ensure => present,
    }

    if $ssl_cert_file_contents != undef {
      file { $ssl_cert_file:
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => $ssl_cert_file_contents,
        before  => Httpd::Vhost[$site_hostname],
      }
    }

    if $ssl_key_file_contents != undef {
      file { $ssl_key_file:
        owner   => 'root',
        group   => 'ssl-cert',
        mode    => '0640',
        content => $ssl_key_file_contents,
        before  => Httpd::Vhost[$site_hostname],
      }
    }

    if $ssl_chain_file_contents != undef {
      file { $ssl_chain_file:
        owner   => 'root',
        group   => 'root',
        mode    => '0640',
        content => $ssl_chain_file_contents,
        before  => Httpd::Vhost[$site_hostname],
      }
    }

    ::httpd::vhost { $site_hostname:
      port     => 443,
      docroot  => 'MEANINGLESS ARGUMENT',
      priority => '50',
      template => 'mediawiki/apache/mediawiki.erb',
      ssl      => true,
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
