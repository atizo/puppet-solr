define solr::configfile() {
  file{"$solr::home/conf/$name":
    source => [
      "puppet://$server/modules/site-solr/$name",
      "puppet://$server/modules/solr/$name",
    ],
    notify => Service['tomcat'],
    owner => $solr::owner, group => $solr::group, mode => 0755;
  }
}
