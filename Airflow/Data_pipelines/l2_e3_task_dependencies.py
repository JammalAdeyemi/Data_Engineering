import logging
from datetime import datetime
from airflow.decorators import dag, task

# @dag decorators the greet_task to denote it's the main function
@dag(
    schedule_interval='@hourly',
    start_date=datetime(2026, 3, 18),
    catchup=False,
    max_active_runs=1
)
def task_dependencies():

    @task()
    def hello_world():
        logging.info("Hello World!")

    @task()
    def addition(first, second):
        logging.info(f"{first} + {second} = {first+second}")
        return first+second
    
    @task()
    def subtraction(first, second):
        logging.info(f"{first - second} = {first-second}")
        return first-second
    
    @task()
    def division(first, second):
        logging.info(f"{first} / {second} = {int(first/second)}")
        return int(first/second)

    hello_world_task=hello_world()
    addition_task=addition(10,20)
    subtraction_task=subtraction(30,15)
    division_task=division(15,3)
    sum=addition(5,5)
    difference=subtraction(6,4)
    sum_divided_by_difference=division(sum,difference)

    hello_world_task >> addition_task 
    hello_world_task >> subtraction_task

    addition_task >> division_task
    subtraction_task >> division_task

    sum >> sum_divided_by_difference
    difference >> sum_divided_by_difference

task_dependencies_dag=task_dependencies()