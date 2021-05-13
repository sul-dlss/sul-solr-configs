# sul-solr-configs

This repository manages the Solr configuration files in our solrcloud.

## Required configuration

To run a solr collection in the cloud, you must include some required configuration. For Solr 4.x, the [required solr configuration](https://wiki.apache.org/solr/SolrCloud#Required_Config) is documented on the Solr wiki.

## Updating configurations

If you want to add or update configurations, you should send a pull request with your changes and @cbeer will deploy them.

[Example pull request](https://github.com/sul-dlss/sul-solr-configs/pull/1)

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
