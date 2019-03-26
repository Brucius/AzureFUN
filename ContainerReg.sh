# Create an Azure container registry
# Create an Azure container registry with the az acr create command. 
# The container registry name must be unique within Azure and contain between 5 and 50 alphanumeric characters.
# In this example, a premium registry SKU is deployed. The premium SKU is required for geo-replication.
# To begin, we'll define an environment variable in the Cloud Shell called ACR_NAME 
# to hold the name we want to give our new container registry.

#Create a Resource Group
az group create --name acrRG --location southeastasia

# Run the following command to define a variable called ACR_NAME.
ACR_NAME=containeReg


# The following snippet is an example response from the az acr create command. 
az acr create --resource-group 66039662-880f-47be-9161-9c026368e06f --name $ACR_NAME --sku Premium

# In this example, the registry name was containeReg. 
# Note that the loginServer value below is the registry name in lowercase, by default.
# In this unit, you created an Azure Container Registry using the Azure CLI.
# We'll use that new container registry in the next unit when we build container images.

# Suppose your company makes use of container images to manage compute workloads. 
# You use the local Docker tooling to build your container images.
# You can now use Azure Container Registry Tasks to build these containers. 
# Container Registry Tasks also allows for DevOps process integration with automated build on source code commit.
# Let's automate the creation of a container image using Azure Container Registry Tasks.

# Create a container image with Azure Container Registry Tasks
# A standard Dockerfile provides build instructions. 
# Azure Container Registry Tasks allows you to reuse any Dockerfile currently in your environment, including multi-staged builds.
# We'll use a new Dockerfile for our example.

# The first step is to create a new file named Dockerfile. 
# You can use any text editor to edit the file. We'll use Cloud Shell Editor for this example.
# Enter the following command into the Cloud Shell window to open the editor.
code

#Copy the following contents into the editor.
FROM    node:9-alpine
ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/package.json /
ADD     https://raw.githubusercontent.com/Azure-Samples/acr-build-helloworld-node/master/server.js /
RUN     npm install
EXPOSE  80
CMD     ["node", "server.js"]

# Use the key combination Ctrl+S (Cmd+S for Mac) to save your changes. Name the file Dockerfile when prompted.
# This configuration adds a Node.js application to the node:9-alpine image. 
# After that, it configures the container to serve the application on port 80 via the EXPOSE instruction.

# Run the following Azure CLI command to build the container image from the Dockerfile. 
# $ACR_NAME is the variable you defined in the preceding unit to hold your container registry name.
# Don't forget the period . at the end of the preceding command. 
# It represents the source directory containing the docker file, which in our case is the current directory. 
# Since we didn't specify the name of a file with the --file parameter, 
# the command looks for a file called Dockerfile in our current directory.
az acr build --registry $ACR_NAME --image helloacrtasks:v1 .

# Verify the image
# Run the following command in the Cloud Shell to verify that the image has been created and stored in the registry.
az acr repository list --name $ACR_NAME --output table
# The helloacrtasks image is now ready to be used.

# Container images can be pulled from Azure Container Registry using many container management platforms, 
# such as Azure Container Instances, Azure Kubernetes Service, and Docker for Windows or Mac. 
# Here, we will deploy our image to an Azure Container Instance.

# First, create a variable in the Cloud Shell named ACR_NAME with the name of your container registry in lowercase 
# (for example, instead of "MyContainer" make the value "mycontainer"). This variable is used throughout this unit.
ACR_NAME=containeReg

# About registry authentication
# Azure Container Registry does not support unauthenticated access; all operations on a registry require a login. 
# Registries support two types of identities:
# Azure Active Directory identities, including both user and service principals. 
# Access to a registry with an Azure Active Directory identity is role-based, 
# and identities can be assigned one of three roles: reader (pull access only), 
# contributor (push and pull access), or owner (pull, push, and assign roles to other users).
# The admin account included with each registry. The admin account is disabled by default.
# The admin account provides a quick option to try a new registry. 
# You enable the account and use its username and password in workflows and apps that need access. 
# Once you have confirmed that the registry works as expected, you should disable the admin account and use 
# Azure Active Directory identities exclusively to ensure the security of your registry.

#  Important
# Only use the registry admin account for early testing and exploration, and do not share the username and password. Disable the admin account and use only role-based access with Azure Active Directory identities to maximize the security of your registry.

# Enable the registry admin account
# In this exercise, we will enable the registry admin account and use it to deploy your image to an Azure Container Instance from the command line.

# Run the following commands to enable the admin account on your registry and retrieve its username and password.
az acr update -n $ACR_NAME --admin-enabled true
az acr credential show --name $ACR_NAME

#The output is similar to below. Take note of the username and the value for password.
{
  "passwords": [
    {
      "name": "password",
      "value": "hIf7uSosEEd/VTPNE1FTd6jeZu27EPLm"
    },
    {
      "name": "password2",
      "value": "=LMrEika1EB5q9KzIaM82WXB9L4enaO8"
    }
  ],
  "username": "containeReg"
}

# Deploy a container with Azure CLI
# Execute the following az container create command to deploy a container instance. 
# Replace <username> and <password> in the following command with your registry's admin username and password.

az container create \
    --resource-group 66039662-880f-47be-9161-9c026368e06f \
    --name acr-tasks \
    --image $ACR_NAME.azurecr.io/helloacrtasks:v1 \
    --registry-login-server $ACR_NAME.azurecr.io \
    --ip-address Public \
    --location eastus \
    --registry-username containeReg \
    --registry-password hIf7uSosEEd/VTPNE1FTd6jeZu27EPLm

#Get the IP address of the Azure container instance using the following command.
az container show --resource-group  66039662-880f-47be-9161-9c026368e06f --name acr-tasks --query ipAddress.ip --output table

# Open a browser and navigate to the IP address of the container. 
# If everything has been configured correctly, you should see the Hello World

# Suppose your company has compute workloads deployed to several regions to 
# make sure you have a local presence to serve your distributed customer base.
# Your aim is to place a container registry in each region where images are run. 
# This strategy will allow for network-close operations, enabling fast, reliable image layer transfers.
# Geo-replication enables an Azure container registry to function as a single registry, 
# serving several regions with multi-master regional registries.
# A geo-replicated registry provides the following benefits:
# Single registry/image/tag names can be used across multiple regions
# Network-close registry access from regional deployments
# No additional egress fees, as images are pulled from a local, replicated registry in the same region as your container host
# Single management of a registry across multiple regions

# Replicate a registry to multiple locations
# In this exercise, you'll use the az acr replication create Azure CLI command to replicate your registry from one region to another.
# Run the following command to replicate your registry to another region. In this example, we are replicating 
# to the japaneast region. $ACR_NAME is the variable you defined earlier in the module to hold your container registry name.
az acr replication create --registry $ACR_NAME --location japaneast

#Here's an example of what the output from this command looks like:
{
  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myresourcegroup/providers/Microsoft.ContainerRegistry/registries/myACR0007/replications/japaneast",
  "location": "japaneast",
  "name": "japaneast",
  "provisioningState": "Succeeded",
  "resourceGroup": "myresourcegroup",
  "status": {
    "displayStatus": "Syncing",
    "message": null,
    "timestamp": "2018-08-15T20:22:09.275792+00:00"
  },
  "tags": {},
  "type": "Microsoft.ContainerRegistry/registries/replications"
}

#As a final step, retrieve all container image replicas created by running the following command.
az acr replication list --registry $ACR_NAME --output table

# The output should look similar to the following:
# NAME       LOCATION    PROVISIONING STATE    STATUS
# ---------  ----------  --------------------  --------
# japaneast  japaneast   Succeeded             Ready
# eastus     eastus      Succeeded             Ready

# Keep in mind that you are not limited to the Azure CLI to list your image replicas. 
# From within the Azure portal, selecting Replications for an Azure Container Registry displays a map 
# that details current replications. Container images can be replicated to additional regions by selecting the regions on the map.

#Clean up , go delete instances
az acr delete --resource-group 66039662-880f-47be-9161-9c026368e06f --name $ACR_NAME

az group create --name acrRG --location southeastasia