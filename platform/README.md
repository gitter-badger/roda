
# Install system dependencies (on Debian/APT based system)
apt-get install build-essential pkg-config python-dev python-virtualenv libjpeg-dev zlib1g-dev libpng12-dev libtiff5-dev libfreetype6-dev liblcms2-dev libopenjpeg-dev libwebp-dev libpng12-dev libxml2-dev libxslt1-dev liblzma-dev

# Create workspace
mkdir workspace && cd workspace

# Clone the uData project into your workspace
git clone https://github.com/etalab/udata.git

#
# Install Python dependencies 
#

# Create and activate your virtualenv
virtualenv . && source bin/activate 

# Install the development dependencies and install the project as editable
pip install -r udata/requirements/develop.pip
pip install --no-deps -e udata/

#
# Install JavaScript dependencies
#

#JavaScript dependencies are managed by npm and requires webpack to be installed globaly.
sudo npm install -g webpack

# Fetch the udata dependencies:
cd udata
npm install

# Build the assets in production mode once and for all
inv assets

#
# Middleware installation
#

cp udata/docker-compose.yml .
docker-compose up -d

#
# Initialization
#

# Initialize database, indexes...
udata init

# Fetch and load licenses
udata licenses https://www.data.gouv.fr/api/1/datasets/licenses

cd udata
# Fetch last translations
tx pull

Compile translations
$ inv i18nc

#
# Running the processes
#

# uData requires at least 3 processes:
# 	a frontend process
#	a worker process
#	a beat process (for scheduled tasks)

honcho start

#
# docker clean up
# 
docker rm -v $(docker ps -a -q -f status=exited) # or status created


