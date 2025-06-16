# Totesys - Data Engineering Pipeline Project

This is the final group project for the Northcoders data engineering course. In it, we created an ETL pipeline to handle the data for a fictional company.

Every 15 minutes, the pipeline ingests data from a Postgres database and stores it as JSON in an S3-hosted data lake. It then transforms data into parquet, and loads it into a star schema data warehouse. The process is orchestrated with a Step Function, whose execution is monitored by CloudWatch and whose errors generate email alerts through SNS.

Testing and infrastructure deployment are automated with GitHub Actions. Documentation for our functions [can be found here](https://cduguid.github.io/Northcoders-Project/), courtesy of pdoc.

Data visualisations were created with Tableau.

![Pipeline](./visualisations/AWS-diagram.png)


## Technologies used

- Python
  - boto3
  - moto
  - pandas
  - pg8000
  - pytest
  - requests
  - awswrangler
  - dotenv
  - currency_codes

- AWS services 
  - Lambda
  - Step Functions
  - CloudWatch
  - SNS
  - IAM
  - S3
  - SecretsManager
  - RDS

- Terraform

- Postgres (SQL)

- GitHub Actions

- Make


## Installation and setup
This project is intended to run on Linux. It is assumed that you have access to a Postgres databse for data ingestion and warehouse for data loading.

Start with [forking](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/fork-a-repo) the repository on GitHub and cloning it to your local machine. To do this, make a separate directory on your machine and input the following command:
```bash
git clone <forked repository link>
```

 Once cloned, move into your cloned repository:
 ```bash
 cd Northcoders-Project
```

Installing dependencies and requirements is automated, but first you'll need to install Make to be able to run the required command:
```bash
pip install make
```

Once this is done, you can use the following command to automatically set up requirements:
```bash
make run-setup
```

### Setting up AWS credentials
You will need access to an AWS account to run this project.

First, create an [IAM User](https://docs.aws.amazon.com/IAM/latest/UserGuide/getting-started.html) with access to at least the AWS services mentioned previously. In your GitHub repo, go to Settings > Secrets and variables > Actions. Click on 'New repository secret'. You will need to add two secrets with the information from creating your IAM user: `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY`.

Second, you need to set up [AWS Secrets Manager](https://docs.aws.amazon.com/secretsmanager/latest/userguide/intro.html) with your database and warehouse credentials. The secrets you store should have the following key-value pairs:
```
user: <username>
password: <password>
host: <host>
database: <database name>
port: <port>
```

Third, copy the ARN of the secrets you just made. You will need to replace two lines of the code with the database secret:

In `lambda_handler` in `src/ingestion/ingest_lambda.py`:
```python
secret_name = "<your-database-secret_arn>"  
```
In `database_credentials` in `terraform/vars.tf`:
```HCL
default = "<your-database-secret_arn>"
```

And two lines of code with the warehouse secret:

In `lambda_handler` in `src/load/load_lambda.py`:
```python
secret_name = "<your-warehouse-secret_arn>"  
```
In `warehouse_credentials` in `terraform/vars.tf`:
```HCL
default = "<your-warehouse-secret_arn>"
```

Fourth, [create an S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/userguide/create-bucket-overview.html) to store the Terraform state file. You will need to replace one line in the `terraform/main.tf` file:
```HCL
bucket = "<the_name_of_your_S3_bucket>"
```

## Testing
While testing happens automatically on push to GitHub, if you wish to test files locally you will need to set up a .env file:
```bash
touch .env
```

With the following credentials:
```
DBUSER = <your-postgres-user>
DBNAME = mock_totesys
DBPASSWORD = <your-postgres-password>
PORT = 5432
HOST = localhost
```

**Note:** Testing of the load functions happens separately from testing of the extract/transform/utility functions. To test the load functions locally, change the value of `DBNAME` to be `mock_warehouse`.

If not already installed, you will need to set up Postgres on your machine. A guide to doing this on Ubuntu can be found [here](https://documentation.ubuntu.com/server/how-to/databases/install-postgresql/index.html). Once this is installed, run the following two commands:
```bash
psql -f data/seed_mock_db.sql
psql -f data/seed_mock_warehouse.sql
```

You can now run either of these commands to run extract/transform/utility tests or load tests respectively:
```bash
make unit-test-initial
make unit-test-load
```

## Execution and usage

### CI/CD Execution using GitHub Actions
The project is configured to be fully automated. The GitHub Actions workflow triggers on [push](https://github.com/git-guides/git-push) to your GitHub repository. This triggers a series of tests as well as security, linting and formatting checks. After those checks are passed, the AWS infrastructure will be deployed.

For this to work correctly, ensure that you have enabled the project's workflow under the Actions tab of your GitHub repo.

Manual deployment is not recommended, due to the code for the Lambda functions being stored in an S3 bucket that is provisioned during deployment. If you wish to try this anyway, follow the sequence of steps in the `.github/workflows/github_actions.yml` file.

### Errors
In order to receive e-mail notifications for Lambda alarms caused by errors in the pipeline, you will need to go to `terraform/vars.tf` and change `default` in `alerts_email` to include your e-mail instead.

When the changes are applied, you will receive three e-mails to confirm your SNS subscriptions. Once confirmed, you will be notified any time a problem occurs and can diagnose the problem using AWS CloudWatch log streams.


## Data

The original `totesys` database simulates the back-end data of a commercial application and has 11 tables, out of which we use 7 to complete the MVP.

![database schema](./visualisations/db_schema.png)

The tables that we use from `totesys` are:
|totesys tables|
|----------|
|counterparty|
|currency|
|department|
|design|
|staff|
|sales_order|
|address|

We then transform the data to populate the following tables in the data warehouse: 
|warehouse tables|
|---------|
|fact_sales_order|
|dim_staff|
|dim_location|
|dim_design|
|dim_date|
|dim_currency|
|dim_counterparty|

The resulting data warehouse has the following structure: 

![warehouse schema](./visualisations/warehouse_schema.png)


### Data insights

We prepared various visualisations of data using Tableau software. These can be found in the `visualisations` folder.

Note that the data was artificially generated and therefore offers limited insights.

## Contributing

If you'd like to contribute to expanding this project, please fork the repo, work on your changes and then make a pull request.

## Authors

Callum, Cristine, Marc, Marta, Nahisah, Taimoor

## Acknowledgements

This project was created as a part of the Northcoders Data Engineering Bootcamp.

https://www.northcoders.com/
