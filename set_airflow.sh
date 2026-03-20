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
echo "Setting up Apache Airflow (3.1.8)"
echo "=========================================="

# ---------------------------------
# Step 0: Setup Python environment
# ---------------------------------
echo ""
echo "Step 0: Setting up Python environment..."

rm -rf "$AIRFLOW_HOME"
rm -rf "$VENV_PATH"

python3 --version

python3 -m venv "$VENV_PATH"
source "$VENV_PATH/bin/activate"

pip install --upgrade pip setuptools wheel

echo "✓ Python virtual environment ready"

# ---------------------------
# Step 1: Install Airflow
# ---------------------------
echo ""
echo "Step 1: Installing Apache Airflow..."

pip install "apache-airflow[amazon,postgres]==3.1.8" 
  --constraint "https://raw.githubusercontent.com/apache/airflow/constraints-3.1.8/constraints-3.12.txt"

echo "✓ Apache Airflow installed"

# ---------------------------
# Step 2: Environment variables
# ---------------------------
echo ""
echo "Step 2: Setting environment variables..."

export AIRFLOW_HOME="$AIRFLOW_HOME"
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="sqlite:///$AIRFLOW_HOME/airflow.db"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True

# Auto-create admin user (Airflow 3 way)
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_USERNAME="$ADMIN_USER"
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_PASSWORD="$ADMIN_PASSWORD"
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_FIRSTNAME="$ADMIN_FIRSTNAME"
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_LASTNAME="$ADMIN_LASTNAME"
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_EMAIL="$ADMIN_EMAIL"
export AIRFLOW__WEBSERVER__DEFAULT_UI_USER_ROLE="Admin"

# Persist settings
grep -q 'AIRFLOW_HOME="/workspaces/Data_Engineering/airflow_home"' ~/.bashrc || {
cat >> ~/.bashrc <<EOF

# Airflow settings
export AIRFLOW_HOME="/workspaces/Data_Engineering/airflow_home"
export AIRFLOW__CORE__LOAD_EXAMPLES=False
export AIRFLOW__DATABASE__SQL_ALCHEMY_CONN="sqlite:////workspaces/Data_Engineering/airflow_home/airflow.db"
export AIRFLOW__WEBSERVER__ENABLE_PROXY_FIX=True
EOF
}

echo "✓ Environment variables set"

# ---------------------------
# Step 3: Create directories
# ---------------------------
echo ""
echo "Step 3: Creating directories..."

mkdir -p "$AIRFLOW_HOME"
mkdir -p "$DAGS_FOLDER/aws"
mkdir -p "$DAGS_FOLDER/pipelines"

echo "✓ Directories created"

# ---------------------------
# Step 4: Link DAG files
# ---------------------------
echo ""
echo "Step 4: Linking DAG files..."

if [ -d "$PROJECT_DIR/AWS" ]; then
    for file in "$PROJECT_DIR/AWS"/.py; do
        [ -f "$file" ] && ln -sf "$file" "$DAGS_FOLDER/aws/$(basename "$file")"
    done
fi

if [ -d "$PROJECT_DIR/Data_pipelines" ]; then
    for file in "$PROJECT_DIR/Data_pipelines"/.py; do
        [ -f "$file" ] && ln -sf "$file" "$DAGS_FOLDER/pipelines/$(basename "$file")"
    done
fi

echo "✓ DAG linking complete"

# ---------------------------
# Step 5: Initialise database
# ---------------------------
echo ""
echo "Step 5: Initialising database..."

airflow db migrate

echo "✓ Database initialised"

# ---------------------------
# Step 6: Final instructions
# ---------------------------
echo ""
echo "=========================================="
echo "Airflow setup complete"
echo "=========================================="

echo ""
echo "Next steps:"
echo "1. Activate venv:"
echo "   source ~/airflow_venv/bin/activate"
echo ""
echo "2. Start webserver:"
echo "   airflow webserver --port 8080 --host 0.0.0.0"
echo ""
echo "3. Start scheduler (new terminal):"
echo "   airflow scheduler"
echo ""
echo "4. Open Airflow UI (Codespaces → Ports → 8080)"
echo ""
echo "Login credentials:"
echo "  Username: $ADMIN_USER"
echo "  Password: $ADMIN_PASSWORD"
echo ""
echo "Helpful commands:"
echo "  airflow dags list"
echo "  airflow dags list-import-errors"