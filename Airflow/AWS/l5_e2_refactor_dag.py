from datetime import datetime
import logging
import sys

from airflow.decorators import dag, task
from airflow.hooks.postgres_hook import PostgresHook
from airflow.providers.postgres.operators.postgres import PostgresOperator
from custom_operators.s3_to_redshift import S3ToRedshiftOperator
from custom_operators.has_rows import HasRowsOperator

import sql_statement


@dag (
    start_date=datetime.now()
)
def demonstrating_refactoring():

    # TODO: Finish refactoring this function into the appropriate set of tasks, instead of keeping this one large task.

    @task()
    def create_younger_riders():
        redshift_hook = PostgresHook("redshift")
        # Find all trips where the rider was under 18
        redshift_hook.run("""
            BEGIN;
            DROP TABLE IF EXISTS younger_riders;
            CREATE TABLE younger_riders AS (
                SELECT * FROM trips WHERE birthyear > 2000
            );
            COMMIT;
        """)
        records = redshift_hook.get_records("""
            SELECT birthyear FROM younger_riders ORDER BY birthyear DESC LIMIT 1
        """)
        if len(records) > 0 and len(records[0]) > 0:
            logging.info(f"Youngest rider was born in {records[0][0]}")

    @task()
    def create_lifetime_rides():
        redshift_hook = PostgresHook("redshift")
        redshift_hook.run("""
            BEGIN;
            DROP TABLE IF EXISTS lifetime_rides;
            CREATE TABLE lifetime_rides AS (
                SELECT bikeid, COUNT(bikeid)
                FROM trips
                GROUP BY bikeid
            );
            COMMIT;
        """)

    @task()
    def create_city_station_counts():
        redshift_hook = PostgresHook("redshift")
        # Count the number of stations by city
        redshift_hook.run("""
            BEGIN;
            DROP TABLE IF EXISTS city_station_counts;
            CREATE TABLE city_station_counts AS(
                SELECT city, COUNT(city)
                FROM stations
                GROUP BY city
            );
            COMMIT;
        """)

    @task()
    def log_oldest():
        redshift_hook = PostgresHook("redshift")
        records = redshift_hook.get_records("""
            SELECT birthyear FROM older_riders ORDER BY birthyear ASC LIMIT 1
        """)
        if len(records) > 0 and len(records[0]) > 0:
            logging.info(f"Oldest rider was born in {records[0][0]}")

    create_younger_riders_task = create_younger_riders()
    create_lifetime_rides_task = create_lifetime_rides()
    create_city_station_counts_task = create_city_station_counts()

    create_oldest_task = PostgresOperator(
        task_id="create_oldest",
        sql="""
            BEGIN;
            DROP TABLE IF EXISTS older_riders;
            CREATE TABLE older_riders AS (
                SELECT * FROM trips WHERE birthyear > 0 AND birthyear <= 1945
            );
            COMMIT;
        """,
        postgres_conn_id="redshift"
    )

    log_oldest_task = log_oldest()

    create_younger_riders_task >> create_oldest_task 
    create_lifetime_rides_task >> create_oldest_task
    create_city_station_counts_task >> create_oldest_task
    create_oldest_task >> log_oldest_task

demonstrating_refactoring_dag = demonstrating_refactoring()