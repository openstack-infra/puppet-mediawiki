# Class: mediawiki::image_scaler
#
class mediawiki::image_scaler {
  if $::lsbdistcodename == 'precise' {
    package { [
      # TODO: This seems to have been copied from wikimedia's mediawiki::multimedia,
      # and wikimedia have the TimedMediaHandler extension installed which uses ffmpeg.
      # But we don't, so is this needed?
      'ffmpeg',
      'libvips15',
      'ttf-arphic-ukai',
      'ttf-arphic-uming',
      'ttf-farsiweb',
      'ttf-khmeros',
      'ttf-lao',
      'ttf-manchufont',
      'ttf-mgopen',
      'ttf-nafees',
      'ttf-sil-abyssinica',
      'ttf-sil-ezra',
      'ttf-sil-padauk',
      'ttf-takao-gothic',
      'ttf-takao-mincho',
      'ttf-thai-tlwg',
      'ttf-tmuni']:
      ensure => present,
    }
  } elsif $::lsbdistcodename == 'trusty' {
    # No ffmpeg - it should work without?
    # If it's needed it could be a pain as Ubuntu doesn't package it for trusty
    package { [ 'libvips37',
      'fonts-arphic-ukai',
      'fonts-arphic-uming',
      'fonts-farsiweb',
      'fonts-khmeros',
      'fonts-lao',
      'fonts-manchufont',
      'fonts-mgopen',
      'fonts-nafees',
      'fonts-sil-abyssinica',
      'fonts-sil-ezra',
      'fonts-sil-padauk',
      'fonts-takao-gothic',
      'fonts-takao-mincho',
      'fonts-thai-tlwg',
      'fonts-tibetan-machine']:
      ensure => present,
    }
  }
  package { [ 'djvulibre-bin',
    'ffmpeg2theora',
    'ghostscript',
    'gsfonts',
    'imagemagick',
    'libogg0',
    'librsvg2-bin',
    'libtheora0',
    'libvips-tools',
    'libvorbisenc2',
    'netpbm',
    'oggvideotools',
    'texlive-fonts-recommended',
    'ttf-alee',
    'ttf-arabeyes',
    'ttf-bengali-fonts',
    'ttf-devanagari-fonts',
    'ttf-gujarati-fonts',
    'ttf-kacst',
    'ttf-kannada-fonts',
    'ttf-liberation',
    'ttf-linux-libertine',
    'ttf-malayalam-fonts',
    'ttf-oriya-fonts',
    'ttf-punjabi-fonts',
    'ttf-sil-scheherazade',
    'ttf-sil-yi',
    'ttf-tamil-fonts',
    'ttf-ubuntu-font-family',
    'ttf-unfonts-extra',
    'ttf-wqy-zenhei',
    'xfonts-100dpi',
    'xfonts-75dpi',
    'xfonts-base',
    'xfonts-mplus',
    'xfonts-scalable']:
    ensure => present,
  }
  include ::tmpreaper
}
