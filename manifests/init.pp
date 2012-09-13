#
# solr module
#
# Copyright 2012, Atizo AG
# Simon Josi simon.josi+puppet(at)atizo.com
#
#
# This program is free software; you can redistribute 
# it and/or modify it under the terms of the GNU 
# General Public License version 3 as published by 
# the Free Software Foundation.
#

class solr(
  $version = '3.6.1',
  $home = '/var/lib/solr',
  $mirror = 'http://mirror.switch.ch/mirror/apache/dist/lucene/solr/',
  $owner = 'tomcat',
  $group = 'tomcat',
  $properties = {}
) {
  include tomcat::clean
  include tomcat::lib::xalan

  $dist_source = "$solr::mirror/$solr::version/apache-solr-${solr::version}.tgz"
  $dist_tgz = "$solr::home/dist/apache-solr-${solr::version}.tgz"
  $dist_war = "$solr::home/dist/apache-solr-${solr::version}/dist/apache-solr-${solr::version}.war"

  file{[
    "$solr::home",
    "$solr::home/dist",
    "$solr::home/conf",
    "$solr::home/data",
  ]:
    ensure => direictory,
    before => Service['tomcat'],
    owner => $solr::owner, group => $solr::group, mode => 0755;
  }
  exec{'fetch_solr_tgz':
    command => "wget -O $dist_tgz $dist_source",
    creates => $dist_tgz,
    user => $solr::owner,
    group => $solr::group,
    require => File["$solr::home/dist"],
    notify => Exec['extract_solr_tgz'],
  }
  exec{'extract_solr_tgz':
    command => "tar xzf apache-solr-${solr::version}.tgz",
    cwd => "$solr::home/dist",
    user => $solr::owner,
    group => $solr::group,
    refreshonly => true,
    before => Service['tomcat'],
    notify => [
      Exec['clean_tomcat_webapp'],
      Service['tomcat'],
    ],
  }
  exec{'clean_tomcat_webapp':
    command => "rm -rf /var/lib/tomcat${lsbmajdistrelease}/webapps/solr"
    onlyif => 'test -d /var/lib/tomcat${lsbmajdistrelease}/webapps/solr',
    refreshonly => true,
    before => Service['tomcat'],
  }
  file{"/etc/tomcat${lsbmajdistrelease}/Catalina/localhost/solr.xml":
    content => template('solr/solr.xml.erb'),
    require => Package['tomcat'],
    notify => Service['tomcat'],
    owner => root, group => root, mode => 0644;
  }
  file{"$solr::home/conf/solrcore.properties":
    content => template('solr/solrcore.properties.erb'),
    require => File["$solr::home/conf"],
    notify => Service['tomcat'],
    owner => $solr::owner, group => $solr::group, mode => 0644;
  }
  solr::configfile{[
    'schema.xml',
    'solrconfig.xml',
    'scripts.conf',
  ]:}
}
