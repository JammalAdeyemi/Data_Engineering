# Airflow Setup in GitHub Codespaces

## Overview

This document outlines how I set up Apache Airflow in GitHub Codespaces, created a user, and accessed the Airflow UI. This setup avoids Docker and runs Airflow directly in a Python environment.

---

## 1. Clean Previous Setup

Remove any existing Airflow installation to avoid conflicts:

```bash
rm -rf ~/airflow
pip uninstall apache-airflow -y
```

---

## 2. Install Airflow

Install a version compatible with Python 3.12:

```bash
pip install apache-airflow==2.9.0
```

---

## 3. Configure Airflow Home

Set the Airflow home directory:

```bash
export AIRFLOW_HOME=~/airflow
```

---

## 4. Initialise Database

Initialise the metadata database:

```bash
airflow db init
```

---

## 5. Create Admin User

Create a user to access the Airflow UI:

```bash
airflow users create \
  --username admin \
  --firstname admin \
  --lastname admin \
  --role Admin \
  --email admin@email.com \
  --password admin
```

---

## 6. Configure Codespaces Access

Set environment variables to allow access via Codespaces:

```bash
export AIRFLOW__WEBSERVER__BASE_URL="http://localhost:8080"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
```

---

## 7. Start Airflow Services

### Terminal 1 – Webserver

```bash
airflow webserver --port 8080 --host 0.0.0.0
```

### Terminal 2 – Scheduler

```bash
airflow scheduler
```

---

## 8. Access Airflow UI

* Open the **Ports tab** in VS Code
* Locate port **8080**
* Click **Open in Browser**

Login details:

* Username: `admin`
* Password: `admin`

---

## 9. Add DAG Files

Airflow reads DAGs from the following directory:

```bash
~/airflow/dags
```

Create the folder and copy your DAG:

```bash
mkdir -p ~/airflow/dags
cp <your_dag_file>.py ~/airflow/dags/
```

---

## 10. Common Issues & Fixes

### DAG not showing

* Confirm file exists in `~/airflow/dags`
* Restart scheduler:

```bash
Ctrl + C
airflow scheduler
```

---

### Changes not reflecting

* Overwrite DAG file:

```bash
cp -f <your_dag_file>.py ~/airflow/dags/
```

* Restart scheduler and webserver

---

### UI not loading (Codespaces)

* Ensure environment variables are set:

```bash
export AIRFLOW__WEBSERVER__BASE_URL="http://localhost:8080"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
```

* Open via **Ports tab**, not manual URL
