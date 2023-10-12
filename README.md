# sul-solr-configs

This repository manages the Solr configuration files in our SolrCloud.

## Required configuration

To run a Solr collection in our SolrCloud, you must include some required configuration. For Solr 4.x, the [required solr configuration](https://wiki.apache.org/solr/SolrCloud#Required_Config) is documented on the Solr wiki.

### managed-schema

schema.xml is NO LONGER where all the schema fields come from, due to SolrCloud "managed_schema".

From https://solr.apache.org/guide/8_11/overview-of-documents-fields-and-schema-design.html:

"managed-schema is the name for the schema file Solr uses by default to support making Schema changes at runtime via the Schema API, or Schemaless Mode features. You may explicitly configure the managed schema features to use an alternative filename if you choose, but the contents of the files are still updated automatically by Solr. ...

"If you are using SolrCloud you may not be able to find any file by these names on the local filesystem. You will only be able to see the schema through the Schema API (if enabled) or through the Solr Admin UI’s Cloud Screens."

Schema API: https://solr.apache.org/guide/8_11/schema-api.html

## Updating configurations

If you want to add or update configurations, you should make a pull request.

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
