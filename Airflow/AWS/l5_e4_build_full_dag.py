from datetime import datetime, timedelta

from airflow.decorators import dag, task
from airflow.operators.empty import EmptyOperator

from custom_operators.facts_calculator import FactsCalculatorOperator
from custom_operators.has_rows import HasRowsOperator
from custom_operators.s3_to_redshift import S3ToRedshiftOperator

#
# TODO: Create a DAG which performs the following functions:
#
#       1. Loads Trip data from S3 to RedShift
#       2. Performs a data quality check on the Trips table in RedShift
#       3. Uses the FactsCalculatorOperator to create a Facts table in Redshift
#           a. **NOTE**: to complete this step you must complete the FactsCalcuatorOperator
#              skeleton defined in plugins/operators/facts_calculator.py
#
@dag(start_date=datetime.now())
def full_pipeline():
    copy_trips_task = S3ToRedshiftOperator(
        task_id='load_trips_from_s3_to_redshift',
        table='trips',
        redshift_conn_id='redshift',
        aws_credentials_id='aws_credentials',
        s3_bucket='jammals3',
        s3_key='data-pipelines/divvy/unpartitioned/divvy_trips_2018.csv'
    )

    check_trips = HasRowsOperator(
        task_id='check_trips_data',
        redshift_conn_id='redshift',
        table='trips'
    )

    calculate_facts = FactsCalculatorOperator(
        task_id='calculate_trip_facts',
        redshift_conn_id='redshift',
        origin_table='trips',
        destination_table='trip_facts',
        fact_column='tripduration',
        groupby_column='bikeid'
    )

    copy_trips_task >> check_trips >> calculate_facts

full_pipeline_dag = full_pipeline()