from datetime import datetime
import logging
import sys
from airflow.decorators import dag, task
from airflow.secrets.metastore import MetastoreBackend
from airflow.hooks.postgres_hook import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator

import sql_statement

@dag(
    start_date=datetime(2026, 3, 19)
)
def load_data_to_redshift():

    @task
    def load_task():    
        metastoreBackend = MetastoreBackend()
        aws_connection=metastoreBackend.get_connection("aws_credentials")
# TODO: create the redshift_hook variable by calling PostgresHook()
        redshift_hook=PostgresHook("redshift")
        redshift_hook.run(sql_statement.COPY_ALL_TRIPS_SQL.format(aws_connection.login, aws_connection.password))

# TODO: create the create_table_task by calling PostgresOperator()
    create_table_task = PostgresOperator(
        task_id="create_table",
        postgres_conn_id="redshift",
        sql=sql_statement.CREATE_TRIPS_TABLE_SQL
    )

# TODO: create the location_traffic_task by calling PostgresOperator()
    location_traffic_task = PostgresOperator(
        task_id="calculate_location_traffic",
        postgres_conn_id="redshift",
        sql=[sql_statement.LOCATION_TRAFFIC_SQL_DROP, sql_statement.LOCATION_TRAFFIC_SQL_CREATE]
    )

    load_data = load_task()   
    create_table_task >> load_data
    load_data >> location_traffic_task

s3_to_redshift_dag = load_data_to_redshift()