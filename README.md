# sul-solr-configs

This repository manages the Solr configuration files in our solrcloud.

## Required configuration

To run a solr collection in the cloud, you must include some required configuration. For Solr 4.x, the [required solr configuration](https://wiki.apache.org/solr/SolrCloud#Required_Config) is documented on the Solr wiki.

## Updating configurations

If you want to add or update configurations, you should send a pull request (tagging [@sul-dlss/devops](https://github.com/orgs/sul-dlss/teams/devops)) with your changes.

[Example pull request](https://github.com/sul-dlss/sul-solr-configs/pull/1)

Once the pull request is merged, pull the changes into the deployed repository, push them to the Zookeeper cluster, and have solr update or create the collection. There is a script located at `sul-solr-a:/home/lyberadmin/bin/upconfig` that will perform these steps, or you can:

```
$ git pull
$ /usr/share/java/solr/server/scripts/cloud-scripts/zkcli.sh -zkhost <zkhost_here>:2181 -cmd upconfig -confname <collectionname_here> -confdir <repo_dirname_here>
```

then

```
$ curl "https://<solr_server>/solr/admin/collections?action=CREATE&name=<collectionname_here>&numShards=1&replicationFactor=3"
```

or

```
$ curl "https://<solr_server>/solr/admin/collections?action=RELOAD&name=<collectionname_here>""
```

If you find that changes haven't propagated to the collection, check to see whether the `schema.xml` of the collection matches the `managed-schema`. In one case, before re-running the above process, reconciling the two with a `cp schema.xml managed-schema` propagated the changes.

## Testing configurations

This repository has a set of rspec tests that will verify your configuration has all the required SolrCloud fields, and will sanity-check it against Solr 5. To run the tests, simply run:

```
$ bundle install
$ rake
```

## Spinning up a solr instance

```
$ collection=searchworks-dev bundle exec solr_wrapper
```
