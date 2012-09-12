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
  require tomcat::clean
  require tomcat::lib::xalan

  $war_source = "$solr::mirror/$solr::version/apache-solr-${solr::version}.tgz"
  $war_target = "$solr::home/dist/apache-solr-${solr::version}.tgz"

  file{[
    "$solr::home",
    "$solr::home/dist",
    "$solr::home/conf",
    "$solr::home/data",
  ]:
    ensure => directory,
    owner => $solr::owner, group => $solr::group, mode => 0755;
  }
  exec{'fetch_solr_war':
    command => "wget -O $war_target $war_source",
    creates => $war_target,
    require => File["$solr::home/dist"],
    notify => Service['tomcat'],
    user => $solr::owner,
    group => $solr::group,
  }
  file{"/etc/tomcat${lsbmajdistrelease}/Catalaina/localhost/solr.xml":
    content => template('solr/solr.xml.erb'),
    notify => Service['tomcat'],
    owner => root, group => root, mode => 0644;
  }
  file{"$solr::home/conf/solrcore.properties":
    content => template('solrcore.properties'),
    require => File["$solr::home/conf"],
    notify => Service['tomcat'],
    owner => $solr::owner, group => $solr::group, mode => 0755;
  }
  solr::configfile{[
    'scripts.conf',
    'schema.xml',
    'solrconfig.xml',
  ]:}
}
