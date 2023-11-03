# Set up your local development environment (Deprecated)

# Introduction
Set up your local environment for database development with Azure SQL or SQL Server. The program replicates the **metadata** and **data** of a source database in a destination database.

To set up your local environment, use the `extract_and_publish.sh` script to extract data and metadata from your prod database and publish to the feature database. The script requires a `env.sh` file to be present within this directory.

# Requirements

- Docker

# Setup
## Step 1

Create an `env.sh` file in this directory and paste the following. Provide the **correct** config details

```bash
# Source Server Config details
export SOURCE_SERVER="host.docker.internal"
export SOURCE_USERNAME="sa"
export SOURCE_PASSWORD="yourStrong(!)Password"
export SOURCE_DB="productionDB"
export SOURCE_PORT=1435

# Destination Server Config details
export TARGET_SERVER="host.docker.internal"
export TARGET_USERNAME="sa"
export TARGET_PASSWORD="yourStrong(!)Password"
export TARGET_DB="developmentDB"
export TARGET_PORT=1435

# Set to -1 to replicate all records
export NUMBER_OF_RECORDS_TO_REPLICATE=-1
```

## Step 2

Use the `table_config.conf` file to get data from specific tables. For e.g., if you need data from the following tables:

- `production.categories`
- `production.brands`
- `production.products`
- `sales.orders`

This should be the content of the `table_config.conf` file
```text
production.categories
production.brands
production.products
sales.orders
```

## Step 3

Run the following command to set up your local database development environment 

```bash
# Make sure you're in the create_local_env directory
. ./extract_and_publish.sh | tee extract_and_publish.log
```
