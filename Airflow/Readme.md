# Data Engineering with Apache Airflow

This repository contains a comprehensive data engineering project using Apache Airflow for ETL pipelines, data quality checks, and custom operators for AWS Redshift integration.

## Project Structure

```
Airflow/
├── AWS/                          # DAGs for AWS services
│   ├── l3_e2_sql_statements.py   # SQL-based data loading
│   ├── l3_e3_connections_hooks.py # Connection and hook usage
│   ├── l3_e4_s3_to_redshift.py   # S3 to Redshift data transfer
│   ├── l4_e1_data_lineage.py     # Data lineage tracking
│   ├── l4_e2_schedule_backfills.py # Scheduling and backfills
│   ├── l4_e3_data_partitioning.py # Data partitioning strategies
│   ├── l4_e4_data_quality.py     # Data quality checks and monitoring
│   ├── l5_e1_custom_operators.py # Custom operators demonstration
│   ├── l5_e2_refactor_dag.py     # DAG refactoring for modularity
│   ├── l5_e3_convert_airflow_1.py # Airflow 1 to 2 migration
│   └── l5_e4_build_full_dag.py   # Complete ETL pipeline
├── Data_pipelines/               # General data pipeline DAGs
│   ├── l2_e1_airflow_dags.py     # Basic DAG creation
│   ├── l2_e2_run_the_schedules.py # Scheduling concepts
│   └── l2_e3_task_dependencies.py # Task dependency management
└── udacity/                      # Shared utilities
   └── common/
      └── sql_statement.py      # SQL statement definitions

custom_operators/                 # Custom Airflow operators
├── facts_calculator.py           # Facts calculation operator
├── has_rows.py                   # Data quality check operator
└── s3_to_redshift.py             # S3 to Redshift transfer operator

airflow_home/                     # Airflow configuration and runtime
├── dags/                         # Symlinked DAGs
├── plugins/                      # Custom plugins and operators
├── logs/                         # Execution logs
└── airflow.cfg                   # Airflow configuration
```

## Key Features

### Custom Operators
- **FactsCalculatorOperator**: Calculates aggregate facts (min, max, avg) grouped by a column
- **HasRowsOperator**: Performs data quality checks to ensure tables contain data
- **S3ToRedshiftOperator**: Transfers data from S3 to Redshift with proper credentials

### DAG Examples
- **Custom Operators Demo** (`l5_e1_custom_operators.py`): Showcases usage of custom operators
- **DAG Refactoring** (`l5_e2_refactor_dag.py`): Demonstrates splitting monolithic tasks
- **Airflow Migration** (`l5_e3_convert_airflow_1.py`): Converts legacy Airflow 1 syntax to Airflow 2
- **Full Pipeline** (`l5_e4_build_full_dag.py`): Complete ETL pipeline with data loading, quality checks, and fact calculation

## Quick Start

Run these commands in order from the repository root:

```bash
bash setup_airflow.sh
source ~/airflow_venv/bin/activate
bash set_connections.sh
```

`set_connections.sh` creates:
- Airflow connection `aws_credentials`
- Airflow connection `redshift`
- Airflow variables `s3_bucket` and `s3_prefix`

## GitHub Codespaces Secrets

This project reads credentials from environment variables. Put your keys in Codespaces secrets before running `set_connections.sh`.

Required secrets:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `REDSHIFT_USER`
- `REDSHIFT_PASSWORD`
- `REDSHIFT_HOST`
- `REDSHIFT_PORT`
- `REDSHIFT_DB`

How to add them in GitHub:
1. Open your repository on GitHub.
2. Go to `Settings`.
3. Select `Secrets and variables` -> `Codespaces`.
4. Click `New repository secret`.
5. Add each secret name/value above.

## Usage

1. Start Airflow webserver: `airflow webserver --port 8080 --host 0.0.0.0`
2. In another terminal, start scheduler: `airflow scheduler`
3. Open port `8080` from the Codespaces Ports tab.

## Development Notes

- Custom operators are copied to `airflow_home/plugins/` by setup.
- DAG files are symlinked into `airflow_home/dags/` for local development.
