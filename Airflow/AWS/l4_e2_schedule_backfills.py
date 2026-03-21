from datetime import datetime
import logging
import sys
from airflow.decorators import dag, task
from airflow.secrets.metastore import MetastoreBackend
from airflow.hooks.postgres_hook import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator

import sql_statement

@dag(
    start_date=datetime(2018, 1, 1),
    # TODO: Set the end date to February first
    end_date=datetime(2018, 2, 1),
    # TODO: Set the schedule to be monthly
    schedule_interval='@monthly',
    # TODO: set the number of max active runs to 1
    max_active_runs=1
)
def schedule_backfills():

    @task()
    def load_trip_data_to_redshift(*args, **kwargs):
        metastoreBackend = MetastoreBackend()
        aws_connection=metastoreBackend.get_connection("aws_credentials")

        redshift_hook = PostgresHook("redshift")
        sql_stmt = sql_statement.COPY_ALL_TRIPS_SQL.format(
            aws_connection.login,
            aws_connection.password,
        )
        redshift_hook.run(sql_stmt)

    @task()
    def load_station_data_to_redshift(*args, **kwargs):
        metastoreBackend = MetastoreBackend()
        aws_connection=metastoreBackend.get_connection("aws_credentials")
        redshift_hook = PostgresHook("redshift")
        sql_stmt = sql_statement.COPY_STATIONS_SQL.format(
            aws_connection.login,
            aws_connection.password,
        )
        redshift_hook.run(sql_stmt)

    create_trips_table = PostgresOperator(
        task_id="create_trips_table",
        postgres_conn_id="redshift",
        sql=sql_statement.CREATE_TRIPS_TABLE_SQL
    )

    create_stations_table = PostgresOperator(
        task_id="create_stations_table",
        postgres_conn_id="redshift",
        sql=sql_statement.CREATE_STATIONS_TABLE_SQL,
    )    

    load_trips_task = load_trip_data_to_redshift()
    load_stations_task = load_station_data_to_redshift()


    create_trips_table >> load_trips_task
    create_stations_table >> load_stations_task

schedule_backfills_dag = schedule_backfills()