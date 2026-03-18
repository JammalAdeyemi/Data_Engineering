import logging
from datetime import datetime
from airflow.decorators import dag, task

# @dag decorators the greet_task to denote it's the main function
@dag(
    schedule_interval='@daily',
    start_date=datetime(2026, 3, 17),
    catchup=False,
    max_active_runs=1
)
def greet_flow_schedule():

    @task
    def hello_world_schedule():
        logging.info("Hello World!")

    hello_world_task=hello_world_schedule()

greet_flow_dag=greet_flow_schedule()