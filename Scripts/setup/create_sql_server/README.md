# Start a SQL Server Instance

Use the `run_sql_server_2022.sh` script to start a sql server (on x86) or azure sql edge (on arm) instance for local development. The script requires an `env.sh` file to be present in the directory. Do **NOT** commit this file.

Create an `env.sh` file in this directory and paste the following. Provide the correct config details

```bash
#!/bin/bash

export PASSWORD="<enter your password>"
export PORT="<enter your port>"
```


```bash
# Start SQL Server
. ./run_sql_server_2022.sh
```