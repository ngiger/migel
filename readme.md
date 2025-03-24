# migel

* https://github.com/zdavatz/migel

## DESCRIPTION:

migel daemon for ch.oddb.org

## FEATURES/PROBLEMS:

## REQUIREMENTS:

Use bundler to install all dependencies mentioned in the Gemfile
Ruby-Version 3.2 or higher

* bundle install

## INSTALL:

* sudo gem install migel

### Non standard path of postgres

If you have a non standard path of postgres use something like

    gem install pg -- ---with-pg-config=/usr/local/pg-10_1/bin/pg_config

Or if you are using bundler

    bundle config build.pg ----with-pg-config=/usr/local/pg-10_1/bin/pg_config
    bundle install

## USEAGE:
* Adapt the configuration to your needs
  * By default it uses (in this order) the following files
    * etc/migel.yml
    * /etc/migel/migel.yml
    
And example is:

    ---
    db_name: ';dbname=migel;host=127.0.0.1;port=5432'
    server_url: 'druby://127.0.0.1:33000'
    db_user: 'postgres'
    db_auth: ''

    admins:
    - ngiger@ywesee.com
    mail_from: admin@ywesee.com
    smtp_domain: ywesee.com
    smtp_server: smtp.gmail.com
    smtp_user: admin@ywesee.com
    smtp_pass: 'your Secret'

* Start the migel server using `bundle exec ruby bin/migeld`
* Start importing all the data `bundle exec ruby jobs/update_migel`

## TEST/COVERAGE

Don't forget to manually call `jobs/update_migel_products_with_report`, as this is a job run only twice a year!

We use .github/workflows/ruby.yml to run the tests after each push using `bundle exec rake spec`

The coverage output can be found under coverage/index.html.

## Overview of jobs/update_migel_products

jobs/update_migel calls update_all in
lib/migel/util/importer.rb:
* ODDB::Swissindex::SwissindexMigel is used to get list of all migel_id
  MiGeL.xls downloaded from https://github.com/zdavatz/oddb2xml_files/raw/master/MiGeL.xls
* save_all_products
  * saves /migel_products_de.csv.
  * For each migel_id search_migel_table is called.
  * SwissindexMigel.search_migel_table 010101001 query_key  MiGelCode lang IT
    * ext/swissindex/src/swissindex.rb calls ODDB::Swissindex::SwissindexMigel
    * calls RefdataArticle.get_refdata is called to get EAN/GTIN (Hash)


## DEVELOPERS:

* Masaomi Hatakeyama
* Yasuhiro Asaka
* Zeno Davatz
* Niklaus Giger

## LICENSE:

* GPLv2
