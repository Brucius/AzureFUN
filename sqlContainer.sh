# Pull and run the container image
# Pull the SQL Server 2017 Linux container image from Microsoft Container Registry.
sudo docker pull mcr.microsoft.com/mssql/server:2017-latest

# The previous command pulls the latest SQL Server 2017 container image. 
# If you want to pull a specific image, you add a colon and the tag name (for example, mcr.microsoft.com/mssql/server:2017-GA-ubuntu). 
# To see all available images, see the mssql-server Docker hub page.

# For the bash commands in this article, sudo is used. On MacOS, sudo might not be required. 
# On Linux, if you do not want to use sudo to run Docker, you can configure a docker group and add users to that group. 
# For more information, see Post-installation steps for Linux.

# To run the container image with Docker, you can use the following command from a bash shell (Linux/macOS) or elevated PowerShell command prompt.
sudo docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=Password' \
   -p 1433:1433 --name sql2 \
   -d mcr.microsoft.com/mssql/server:2017-latest

# Note
# The password should follow the SQL Server default password policy, otherwise the container can not setup SQL server and will stop working. 
# By default, the password must be at least 8 characters long and contain characters from three of the following four sets: 
# Uppercase letters, Lowercase letters, Base 10 digits, and Symbols. You can examine the error log by executing the docker logs command.

# Note
# By default, this creates a container with the Developer edition of SQL Server 2017. 
# The process for running production editions in containers is slightly different. 
# For more information, see Run production container images. https://docs.microsoft.com/en-us/sql/linux/sql-server-linux-configure-docker?view=sql-server-2017#production

# To view your Docker containers, use the docker ps command.
sudo docker ps -a

# The SA account is a system administrator on the SQL Server instance that gets created during setup. 
# After creating your SQL Server container, the MSSQL_SA_PASSWORD environment variable you specified is discoverable by running echo $MSSQL_SA_PASSWORD in the container. 
# For security purposes, change your SA password.

# Choose a strong password to use for the SA user.

# Use docker exec to run sqlcmd to change the password using Transact-SQL. Replace <YourStrong!Passw0rd> and <YourNewStrong!Passw0rd> with your own password values.
#Change SA password
sudo docker exec -it sql1 /opt/mssql-tools/bin/sqlcmd \
   -S localhost -U SA -P '<YourStrong!Passw0rd>' \
   -Q 'ALTER LOGIN SA WITH PASSWORD="<YourNewStrong!Passw0rd>"'

# The following steps use the SQL Server command-line tool, sqlcmd, inside the container to connect to SQL Server.

# Use the docker exec -it command to start an interactive bash shell inside your running container. 
# In the following example sql1 is name specified by the --name parameter when you created the container.
#Connect to SQL container instance through shell
sudo docker exec -it sql1 "bash"

# Once inside the container, connect locally with sqlcmd. Sqlcmd is not in the path by default, so you have to specify the full path.
# Start sqlcmd
   /opt/mssql-tools/bin/sqlcmd -S localhost -U SA -P 'Password123'

# Create and query data
# The following sections walk you through using sqlcmd and Transact-SQL to create a new database, add data, and run a simple query.
# Create a new database
# The following steps create a new database named TestDB.
CREATE DATABASE TestDB
SELECT Name from sys.Databases
GO

USE TestDB
CREATE TABLE Inventory (id INT, name NVARCHAR(50), quantity INT)
INSERT INTO Inventory VALUES (1, 'banana', 150); INSERT INTO Inventory VALUES (2, 'orange', 154);
GO

SELECT * FROM Inventory WHERE quantity > 152;
GO

QUIT

#start container
docker start CONTAINER_ID
#Stop and remove Container Image
sudo docker stop sql1
sudo docker rm sql1

#Reference https://docs.microsoft.com/en-us/sql/linux/quickstart-install-connect-docker?view=sql-server-2017&pivots=cs1-bash