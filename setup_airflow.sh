#!/bin/bash
set -euo pipefail

# ---------------------------
# Config
# ---------------------------
AIRFLOW_HOME="/workspaces/Data_Engineering/airflow_home"
DAGS_FOLDER="$AIRFLOW_HOME/dags"
PROJECT_DIR="/workspaces/Data_Engineering/Airflow"
VENV_PATH="$HOME/airflow_venv"

ADMIN_USER="${ADMIN_USER:-admin}"
ADMIN_FIRSTNAME="${ADMIN_FIRSTNAME:-aStudent}"
ADMIN_LASTNAME="${ADMIN_LASTNAME:-aStudent}"
ADMIN_EMAIL="${ADMIN_EMAIL:-admin@example.com}"
ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin}"

echo "=========================================="
echo "Setting up Apache Airflow"
echo "=========================================="

# ---------------------------------
# Step 0: Setup Python(Virtual) env
# ---------------------------------
echo ""
echo "Step 0: Setting up Python environment..."

rm -rf "$AIRFLOW_HOME"
rm -rf "$VENV_PATH"

python3 --version

# Create virtual environment
python3 -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"

# Upgrade core tools
pip install --upgrade pip setuptools wheel

echo "✓ Python virtual environment ready"

# ---------------------------
# Step 1: Install Airflow + AWS
# ---------------------------
echo ""
echo "Step 1: Installing Apache Airflow..."

pip install "apache-airflow[amazon]==2.10.4"
pip install "apache-airflow-providers-postgres==5.12.0"
pip install psycopg2-binary

echo "✓ Apache Airflow installed"

# ---------------------------
# Step 2: Set environment variables
# ---------------------------
echo ""
echo "Step 2: Setting up environment variables..."
export AIRFLOW_HOME="$AIRFLOW_HOME"
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="sqlite:///$AIRFLOW_HOME/airflow.db"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
export PYTHONPATH="/workspaces/Data_Engineering:${PYTHONPATH:-}"

# Persist only if not already present
grep -q 'export AIRFLOW_HOME="/workspaces/Data_Engineering/airflow_home"' ~/.bashrc || {
    cat >> ~/.bashrc <<EOF
    
# Airflow settings
export AIRFLOW_HOME="/workspaces/Data_Engineering/airflow_home"
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="sqlite:////workspaces/Data_Engineering/airflow_home/airflow.db"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
export PYTHONPATH="/workspaces/Data_Engineering:\${PYTHONPATH:-}"
EOF
}

echo "✓ Environment variables set"

# ---------------------------
# Step 3: Create directories
# ---------------------------
echo ""
echo "Step 3: Creating Airflow home directory..."
mkdir -p "$AIRFLOW_HOME"
mkdir -p "$DAGS_FOLDER"
mkdir -p "$DAGS_FOLDER/aws"
mkdir -p "$DAGS_FOLDER/pipelines"
mkdir -p "$AIRFLOW_HOME/plugins"

echo "✓ Directories created"

# ---------------------------
# Step 4: Link modules and DAG files
# ---------------------------
echo ""
echo "Step 4: Linking DAG files..."

if [ -d "$PROJECT_DIR/AWS" ]; then
    for file in "$PROJECT_DIR/AWS"/*.py; do
        if [ -f "$file" ]; then
            ln -sf "$file" "$DAGS_FOLDER/aws/$(basename "$file")"
            echo "  ✓ Linked AWS DAG: $(basename "$file")"
        fi
    done
fi

if [ -d "$PROJECT_DIR/Data_pipelines" ]; then
    for file in "$PROJECT_DIR/Data_pipelines"/*.py; do
        if [ -f "$file" ]; then
            ln -sf "$file" "$DAGS_FOLDER/pipelines/$(basename "$file")"
            echo "  ✓ Linked pipeline DAG: $(basename "$file")"
        fi
    done
fi

# Copy shared SQL statements to Airflow plugins folder
if [ -f "$PROJECT_DIR/udacity/common/sql_statement.py" ]; then
    cp "$PROJECT_DIR/udacity/common/sql_statement.py" "$AIRFLOW_HOME/plugins/sql_statement.py"
    echo "  ✓ Copied sql_statement.py to plugins folder"
fi

# Copy custom operators to Airflow plugins folder
if [ -d "/workspaces/Data_Engineering/custom_operators" ]; then
    cp -r "/workspaces/Data_Engineering/custom_operators" "$AIRFLOW_HOME/plugins/"
    echo "  ✓ Copied custom_operators to plugins folder"
fi

echo "✓ Linking complete"

# ---------------------------
# Step 5: Initialise database
# ---------------------------
echo ""
echo "Step 5: Initialising Airflow database..."
airflow db migrate
echo "✓ Database initialised"

# ---------------------------
# Step 6: Create admin user
# ---------------------------
echo ""
echo "Step 6: Creating admin user..."

if airflow users list | grep -q "$ADMIN_USER"; then
    echo "✓ Admin user already exists: $ADMIN_USER"
else
    airflow users create \
        --username "$ADMIN_USER" \
        --firstname "$ADMIN_FIRSTNAME" \
        --lastname "$ADMIN_LASTNAME" \
        --role Admin \
        --email "$ADMIN_EMAIL" \
        --password "$ADMIN_PASSWORD"
    echo "✓ Admin user created: $ADMIN_USER"
fi

# ---------------------------
# Step 7: Show summary
# ---------------------------
echo ""
echo "=========================================="
echo "Airflow setup complete"
echo "=========================================="
echo ""
echo "Configuration Summary:"
echo "  AIRFLOW_HOME: $AIRFLOW_HOME"
echo "  DAGs Folder: $DAGS_FOLDER"
echo "  Database: $AIRFLOW_HOME/airflow.db"
echo "  Admin User: $ADMIN_USER"
echo ""
echo "Next steps:"
echo "1. Run: source ~/airflow_venv/bin/activate"
echo "2. Start webserver: airflow webserver --port 8080 --host 0.0.0.0"
echo "3. In another terminal, start scheduler: airflow scheduler"
echo "4. Open Airflow from the Codespaces PORTS tab on port 8080"
echo ""
echo "Helpful checks:"
echo "  airflow dags list"
echo "  airflow dags list-import-errors"