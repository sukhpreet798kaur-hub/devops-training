# SonarQube on Ubuntu: One-Page Install Note

This note gives a copy-paste setup for installing SonarQube on Ubuntu with PostgreSQL. The official SonarQube install flow is to prepare the database first, then install SonarQube Server from ZIP or Docker, and then complete basic setup.[1][2]

## 1) Install required packages

```bash
sudo apt update
sudo dpkg --configure -a
sudo apt --fix-broken install -y
sudo apt install -y openjdk-17-jdk unzip zip wget postgresql postgresql-contrib
java -version
psql --version
```

- `apt update` refreshes Ubuntu package metadata before installation.[3]
- `dpkg --configure -a` repairs interrupted package installation state if `dpkg` was left unfinished.[3]
- `apt --fix-broken install` fixes broken dependencies before retrying package installation.[3]
- The package install command adds Java, archive tools, a downloader, and PostgreSQL, which are the normal dependencies used in Ubuntu SonarQube setups.[3][4]
- `java -version` and `psql --version` confirm that Java and PostgreSQL were installed correctly.[3]

## 2) Create the PostgreSQL user and database

```bash
sudo -u postgres psql
```

Run the following inside PostgreSQL:

```sql
CREATE ROLE sonaruser WITH LOGIN ENCRYPTED PASSWORD 'StrongPassword123';
CREATE DATABASE sonarqube OWNER sonaruser;
\c sonarqube
GRANT USAGE, CREATE ON SCHEMA public TO sonaruser;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO sonaruser;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO sonaruser;
ALTER DATABASE sonarqube OWNER TO sonaruser;
\q
```

- This creates a dedicated PostgreSQL login and a dedicated database for SonarQube.[5]
- SonarSource’s database guidance says the SonarQube user must be able to create, update, and delete objects in its schema.[5]
- The schema grants are important because PostgreSQL can otherwise fail with `permission denied for schema public`, which prevents SonarQube from creating required tables such as `schema_migrations`.[6][5]

## 3) Download and extract SonarQube

Open the official downloads page and copy the exact ZIP filename first: [SonarQube Downloads](https://www.sonarsource.com/products/sonarqube/downloads/).[7]

```bash
cd /opt
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-<exact-version>.zip
sudo unzip sonarqube-<exact-version>.zip
ls -lh /opt
sudo mv sonarqube-<exact-folder-name> /opt/sonarqube
```

- `wget` downloads the ZIP package from SonarSource’s official binaries location.[7][4]
- `unzip` extracts the downloaded archive into `/opt`.[4]
- `ls -lh /opt` helps identify the exact extracted folder name before renaming it.[3]
- `mv` renames the extracted folder to a stable path, `/opt/sonarqube`, which makes future commands simpler.[3]

## 4) Create a Linux user for SonarQube

```bash
sudo groupadd sonar
sudo useradd -d /opt/sonarqube -g sonar sonar
sudo chown -R sonar:sonar /opt/sonarqube
```

- These commands create a dedicated Linux group and service user for SonarQube.[3]
- SonarQube should not run as `root` on Unix systems, so ownership must be given to the service account.[4]
- `chown` gives the service account permission to write logs, temp files, and PID files inside the installation directory.[3]

## 5) Configure the database connection

```bash
sudo nano /opt/sonarqube/conf/sonar.properties
```

Add or update these lines:

```properties
sonar.jdbc.username=sonaruser
sonar.jdbc.password=StrongPassword123
sonar.jdbc.url=jdbc:postgresql://localhost:5432/sonarqube
#sonar.web.port=9000
```

- `sonar.jdbc.username`, `sonar.jdbc.password`, and `sonar.jdbc.url` tell SonarQube how to connect to PostgreSQL.[4][3]
- Leave `#sonar.web.port=9000` as default unless port 9000 is already busy on the machine.[4]
- If port 9000 is busy, set `sonar.web.port=9001` and restart SonarQube.[8][9]

## 6) Start SonarQube

```bash
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh start
sudo -u sonar /opt/sonarqube/bin/linux-x86-64/sonar.sh status
```

- `sonar.sh start` launches SonarQube as the dedicated Linux service account.[4]
- `sonar.sh status` confirms whether the SonarQube service is currently running.[4]

## 7) Verify the web UI

```bash
sudo ss -ltnp | grep 9000
```

- `ss` checks whether SonarQube is actually listening on the expected web port.[10]
- Open `http://localhost:9000` in the browser by default, or `http://localhost:9001` if you changed the port.[4][8]
- The default login is `admin` / `admin`, and SonarQube prompts for a password change on first login.[4][3]

## 8) Troubleshooting commands

```bash
tail -n 50 /opt/sonarqube/logs/sonar.log
tail -n 50 /opt/sonarqube/logs/web.log
tail -n 50 /opt/sonarqube/logs/es.log
```

- `sonar.log` shows the high-level startup sequence and process lifecycle.[4]
- `web.log` shows application and database startup failures, including permission errors in PostgreSQL.[5]
- `es.log` shows internal Elasticsearch startup details, which matter because SonarQube depends on Elasticsearch to start correctly.[4]

