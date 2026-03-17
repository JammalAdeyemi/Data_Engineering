import logging
from datetime import datetime
from airflow.decorators import dag, task

# @dag decorators the greet_task to denote it's the main function
@dag(
    start_date=datetime(2025, 3, 27)
)
def greet_flow():

    @task
    def hello_world():
        logging.info("Hello World!")
        # logging.info("Welcome to Airflow 2!")

    hello_world_task=hello_world()

greet_flow_dag=greet_flow()

