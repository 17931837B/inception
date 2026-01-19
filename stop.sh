# clean
sudo docker stop $(sudo docker ps -qa)
sudo docker rm $(sudo docker ps -qa)
sudo docker rmi -f $(sudo docker images -qa)
sudo docker volume rm $(sudo docker volume ls -q)
sudo docker network rm $(sudo docker network ls -q)
sudo docker system prune -a -f
sudo rm -Rf ~/data/*

# git clone 

# cp ~/Desktop/work/.env  ${repo_name}/srcs/.env 
