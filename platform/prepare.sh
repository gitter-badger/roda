# clean up workspace
rm -rf workspace

# define workspace
mkdir workspace
cp Dockerfile workspace
cp docker-compose.yml workspace
cd workspace
git clone https://github.com/etalab/udata.git

# delete default docker-machine
docker-machine stop default
docker-machine rm default

# create default docker-machine
docker-machine create --driver virtualbox default

# connect to docker-machine
docker-machine start default
eval $(docker-machine env default)

# clean up docker-machine
docker kill $(docker ps -q)
docker rm -v $(docker ps -a -q -f status=exited)
docker rm -v $(docker ps -a -q -f status=created)
docker rmi $(docker images -f "dangling=true" -q)
