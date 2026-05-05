# Starting the Daily Devotional Bot
 claude code --resume divine-word --dangerously-skip-permissions

session divine-word
## Prerequisites
- Java 25 installed at `C:\Users\gamba\.jdks\corretto-25.0.1`
- PostgreSQL Docker container running on port 5433
- Maven wrapper (`mvnw`) available

## Quick Start

### Option 1: Windows Command Prompt
```bash
run.bat
```

### Option 2: Git Bash / WSL / Linux
```bash
./run.sh
```

### Option 3: Manual Maven command
```bash
set JAVA_HOME=C:\Users\gamba\.jdks\corretto-25.0.1
mvnw spring-boot:run
```

## Starting PostgreSQL
Before running the app, ensure PostgreSQL is running:

```bash
docker-compose up -d
```

Check status:
```bash
docker-compose ps
```

## Logs
When the app starts, you'll see logs showing:
- Spring Boot initialization
- Database connection
- Telegram bot webhook setup
- "Started DailyDevotionalApplication in X seconds"

## Stopping the App
Press `Ctrl+C` in the terminal running the app.

## Default Configuration
- **Database**: PostgreSQL on localhost:5433
- **Bot Token**: Configured in `application.yml`
- **Scheduled Task**: Daily devotional send at 12:00 UTC
