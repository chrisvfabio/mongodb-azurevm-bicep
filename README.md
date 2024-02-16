# mongodb-azurevm-bicep

This repo will walk you through how to deploy a MongoDB instance on Azure VM using Bicep templates.

## Steps

Login to Azure CLI.
```bash
az login
```

<br>

> Before running the next command, modify the `main.parameters.json` file to include your IP address in the `allowedIPAddresses` array.


Deploy the Bicep template to Azure.
```bash
az deployment sub create \
    --name mongodb \
    --location australiaeast \
    --template-file ./main.bicep \
    --parameters ./main.parameters.json
```

Enter secure parameter values:

```bash
Please provide securestring value for 'adminUsername' (? for help): *******
Please provide securestring value for 'adminPasswordOrKey' (? for help): ************
```

Verify the deployment, ensuring docker is installed on the Azure VM.

Find the public FQDN or IP address of the Azure VM.
```bash
HOSTNAME=$(az vm show --name mongodb-vm-01 --resource-group  mongodb-rg  --show-details --output tsv --query fqdns)

echo $HOSTNAME
```

Connect to the Azure VM using SSH.

```bash
ssh <username>@<hostname>
```

For example:

```bash
ssh mongodb-admin@mongodb-vm-01-lh4u4yygolcwk.australiaeast.cloudapp.azure.com
```

```bash
mongodb-admin@mongodb-vm-01:~$
```

Test docker is running:

```bash
docker ps

# Output: 

# CONTAINER ID   IMAGE       COMMAND                  CREATED          STATUS          PORTS                                           NAMES
```

Deploy the mongo:7.0 container.

```bash
docker run -d \
    --restart on-failure \
    -p 27017:27017 \
    --name mongodb \
    -v /opt/data/mongo:/data/db \
    mongo:7.0 --auth
```

`/opt/data/mongo` - The Azure Data Disk is mounted to this directory, which is then mounted to the `/data/db` directory inside the mongo container.

`--auth` - this flag enables authentication for the MongoDB instance.

<br>

Open a shell to the MongoDB container to create a user with root role.

```bash
docker exec -it mongodb /bin/mongosh
```

Run the following commands to create a user with root role.
```bash
use admin

# Create a user with root role
db.createUser({user: "root", pwd: "supersecret", roles: ["root"]})
```

Exit the mongo container shell and virtual machine. 


## Connecting to the MongoDB Instance

### Using mongodb-tools (CLI)

> Ensure your IP Address is added into the Network Security Group (NSG) allow list to access the MongoDB instance.

```bash
On your local machine, spin up an alpine container.

```bash
docker run -it --rm  alpine
```

Inside the alpine container, install the mongodb-tools package.
```bash
apk add --update mongodb-tools
```

Run `mongotop` to monitor the MongoDB instance on the Azure VM.

```bash
mongotop --uri=mongodb://<username>:<password>@<hostname>:27017
```

Replace `<hostname>` with the public FQDN or IP address of the Azure VM.

For example:

```bash
mongotop --uri=mongodb://root:supersecret@mongodb-vm-01-lh4u4yygolcwk.australiaeast.cloudapp.azure.com:27017
```


### Using MongoDB Compass (GUI)

If you prefer a GUI tool, you can use [MongoDB Compass](https://www.mongodb.com/try/download/compass) to connect to the MongoDB instance.

![MongoDB Compass](https://github.com/chrisvfabio/mongodb-azurevm-bicep/assets/5626828/8bd4834c-c4ad-467d-9089-37565384f030)