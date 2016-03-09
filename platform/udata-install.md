# Very basic installation

This installation may be enough for working on general code or interface integration.
Note that to gain searching and some more advanced feature you will need the [advanced installation(#advanced-installation).

## Prerequirements

- git
- Python 2.7
- [MongoDB](https://www.mongodb.org/)
- [LESS](http://lesscss.org/)
- a dump of Mongo data for fixtures
- a copy of images assets


## Download the project

Run the following replacing _/my/work_ with your root folder where to install the projects.

    mkdir /my/work/datagouv && cd $_
    git clone https://github.com/etalab/udata
    git clone https://github.com/etalab/udata-gouvfr
    mkdir static
    touch udata.cfg

After these steps you should have the following tree structure:

- datagouv/        # projects root
  - udata/         # core project
  - udata-gouvfr/  # theme project
  - udata.cfg      # udata configuration file


## Installation

1. [Create a virtualenv](http://docs.python-guide.org/en/latest/dev/virtualenvs/) with python 2.7
2. activate your environment if it's not done automatically.

Then install Python and JavaScript dependencies:

    cd datagouv/udata
    pip install -r requirements/all.pip
    npm install
    cd ../udata-gouvfr && npm install && cd -
    npm install -g webpack


## Configure
  
Open the _udata.cfg_ file in your _datagouv_ folder and copy/paste the following:

    import os
    DEBUG = True
    ASSETS_DEBUG = True
    ASSETS_AUTO_BUILD = True
    CACHE_TYPE = 'null'
    CACHE_NO_NULL_WARNING = True
    ROOT_DIR = os.path.dirname(os.path.realpath(__file__))
    PLUGINS = ['gouvfr']
    THEME = 'gouvfr'
    SITE_ID = 'data.gouv.dev'
    FS_PREFIX = '/s'
    FS_ROOT = /fs  # We will use Docker to store here
    STATIC_DIRS = [('avatars', os.path.join(FS_ROOT, 'avatars')),
                   ('images', os.path.join(FS_ROOT, 'images'))]
    SERVER_NAME = 'data.gouv.dev:7000'


edit your _/etc/hosts_ to add:

    127.0.0.1 data.gouv.dev


Somewhere in your virtualenv's postactivate or where you can `source`, add the following:

    export UDATA_SETTINGS=/my-project/etalab/udata.cfg
    export PYTHON_PATH=/path/to/datagouv/udata:/path/to/datagouv/udata-gouvfr:$PYTHON_PATH


Edit your _/etc/hosts_ file and add the following line:

    127.0.0.1 data.gouv.dev


## Getting an account

To access the admin (http://data.gouv.dev:7000/admin) or account pages you need to register.
To do so run `python manage.py create user` and follow the steps.

### Create an admin/super-user

An exising user (see above) can get promoted to super-user: `python manage.py user set_admin user@email` (replace _user@email_ with the user email address you inserted in the `create user` command).


## Running the project

    cd datagouv/udata
    python udata/manage.py serve


## Database

See below for installing a MongoDB database (using Docker or native).

Open your browser at http://data.gouv.dev:7000/ (do not go to _localhost:7000_!).


----------


# Advanced installation

In addition to the basic installation above, these steps will provide search indexing, autocompletion on the interface, statistics, …


## Working with CSS

CSS are processed from LESS.

In one terminal run: `cd datagouv/udata && inv watch` 
In another terminal run: `cd datagouv/udata-datagouv && inv watch`


## Docker way for ElasticSearch, Redis, MongoDB

To make it easy it is adviced to use [Docker](https://www.docker.com/).

> On MacOSX and Windows, Docker run in a virtual machine (VirtualBox). Therefore the IPs to access your services are not localhost nor 127.0.0.1 but the ip of that VirtualBox (ie. http://192.168.99.100:9200 for ElasticSearch). You should adapt your _udata.cfg_ file and the lines of code below accordingly.

1. Install [Docker Compose](https://docs.docker.com/compose/install/)
2. run `mongorestore -h 127.0.0.1 -p 27017 -d udata /my/folder/to/mongo/data/dump # replace 127.0.0.1 with you DockerMachine IP
3. run `python udata/manage.py db migrate`
4. run `docker-compose run search plugin install elasticsearch/elasticsearch-analysis-icu/2.7.0`
5. run `python udata/manage.py search init`

Everytime you come back to the project, simply run `docker-compose up` to start the services.

> You can test your elasticsearch installation and indexation with `curl http://localhost:9200/udata`. It should return a JSON in case of success indexing. (replace _localhost_ with the IP of your Docker Machine if MacOSX or Windows).


### Statics images using Docker

Copy your static assets (ie images) into the _/fs_ folder of your _data_ Docker machine.


## Native way for ElasticSearch, Redis, MongoDB – no Docker

Follow this if you do not want to use Docker.

Install Redis and MongoDB accordingly to your system.
Get yourself a dump of the MongoDB and _restore_ it to your local database. `mongorestore -h localhost -p 27017 -d udata /my/dump/folder/`.

### ElasticSearch

1. install [elastisearch](https://www.elastic.co/) 1.7 (not currently working with 2.x or above) and elastisearch _analysis-icu_ plugin (see below instructions for an easy installation).
2. add indexes to elasticsearch: `cd datagouv && python udata/manage.py search init`. This will take a few minutes.


#### Installing analysis-icu for elasticsearch – the easy way

  1. find your plugin installer: `curl "localhost:9200/_nodes/settings?pretty=true" | grep '"home" :'`.
    This will output the path, something like _"home" : "/usr/local/Cellar/elasticsearch17/1.7.3"_
  2. install _icu_ based on the previous URL: `/usr/local/Cellar/elasticsearch17/1.7.3/bin/plugin install elasticsearch/elasticsearch-analysis-icu/2.7.0`

#### Testing ES and troubleshooting

You can test your elasticsearch installation and indexation with `curl http://localhost:9200/udata`. It should return a JSON in case of success indexing.

If you meet some Elastisearch error about the _udata_ index, just call `http DELETE http://localhost:9200/udata` to clear out the index and run the indexing again.


#### Run the services

We use _Honcho_ with a _/Procfile_ containing the following:

```
mongodb: mongod --dbpath=/usr/local/var/mongodb
es: elasticsearch
redis: redis-server

worker: celery -A udata.worker worker
beat: celery -A udata.worker beat
```

Then run `honcho -f ../Procfile start`


## Working process

For Docker or native.

You will probably end up with a few terminal running the following:

- terminal 1: `docker-compose up` or `honcho -f ../Procfile start`
- terminal 2: `cd udata && inv watch` # watching _udata_ js/css changes
- terminal 3: `cd udata-gouvfr && inv watch` # watching _udata-gouvfr_ js/css changes
- terminal 4: `cd udata && python udata/manage.py serve` # run the _udata_ server

Now open your browser at http://data.gouv.dev:7000 (not _localhost:7000_!).

---

# Optional

## Adding statistics

    cd datagouv
    git clone https://github.com/etalab/udata-piwik
    
Now edit your udata.cfg file and replace `PLUGINS = ['gouvfr']` by `PLUGINS = ['gouvfr', 'piwik']`.
Add _/path/to/datagouv/udata-piwik_ (get the correct path!) to your _PYTHON\_PATH_.

--- 

# Troubleshooting

### error indexing

You may reach a point where you have duplicates if you restart your ``udata/manage.py search init``.
In that case check the key that is crashing in the output and delete it (possibly _udata_): `http DELETE http://localhost:9200/<name of the duplicate key>`.


### IPDB stdout not accessible

Start your server with `python udata/manage.py serve` instead of `inv serve`