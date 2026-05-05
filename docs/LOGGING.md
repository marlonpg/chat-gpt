# Logging Guide

The Daily Devotional Bot includes comprehensive logging for observability and debugging.

## Log Output

Logs are written to:
- **Console**: Real-time output to your terminal
- **File**: `logs/app.log` - persistent log file with rolling rotation

## Log Levels

Default log levels:
- `com.dailyjesus.*` - **INFO** level
- `org.springframework` - **WARN** level
- `org.telegram` - **INFO** level

## What Gets Logged

### TelegramDevotionalBot
- `INFO` - User subscriptions, /start and /stop commands
- `DEBUG` - Individual messages received, message delivery
- `ERROR` - Failed message sends

Example logs:
```
User /start command: chatId=123456789, username=john_doe, firstName=John
User subscribed: chatId=123456789
Message sent to chatId=123456789, length=456
```

### DevotionalService
- `INFO` - Devotional generation, model calls
- `WARN` - AI timeout, failures, fallback usage
- `DEBUG` - Field extraction, cache hits

Example logs:
```
Calling AI model: openai/gpt-4o-mini with command: gh
Created devotional: topic='Hope', reference='Matthew 11:28'
Using fallback devotional content
```

### DispatchScheduler
- `INFO` - Scheduled task start/end, user counts, delivery summary
- `WARN` - Individual user send failures
- `DEBUG` - Per-user delivery details

Example logs:
```
Starting daily devotional dispatch
Dispatching devotional to 5 active users
Daily dispatch completed: sent=5, failed=0, duration=2345ms
```

## Changing Log Levels

### At Runtime (via environment variable)
```bash
# Enable DEBUG logging for Daily Devotional
LOG_LEVEL_COM_DAILYJESUS=DEBUG ./run.sh
```

### In application.yml
Edit `src/main/resources/application.yml`:
```yaml
logging:
  level:
    com.dailyjesus: DEBUG  # Change to DEBUG for verbose logging
    org.springframework: WARN
```

### Development Mode
Start with the dev profile:
```bash
LOG_LEVEL_ROOT=DEBUG ./run.sh
```

## Log File Rotation

The `logs/app.log` file automatically:
- Rotates when it reaches 10MB
- Keeps the last 30 days of logs
- Has a total cap of 300MB

Old logs are archived as `logs/app-YYYY-MM-DD.N.log`

## Common Log Patterns

### User Subscribes
```
User /start command: chatId=12345, username=user123, firstName=John
User subscribed: chatId=12345
```

### Devotional Sent via /test
```
User /test command: chatId=12345, username=user123
Test devotional sent to chatId=12345
```

### Daily Dispatch Runs
```
Starting daily devotional dispatch
Dispatching devotional to 3 active users
Daily dispatch completed: sent=3, failed=0, duration=1234ms
```

### AI Model Fallback
```
Calling AI model: openai/gpt-4o-mini with command: gh
AI model call timed out after 40 seconds
Using fallback devotional content
```

## Debugging Tips

1. **Enable DEBUG logging** to see detailed execution flow
2. **Check logs/app.log** for persistent records when console is closed
3. **Search by chatId** to trace a specific user's interactions
4. **Look for ERROR or WARN** to identify problems
5. **Watch send/delivery logs** to verify message delivery

## Performance Monitoring

Key metrics logged:
- Daily dispatch duration (in milliseconds)
- Send success/failure counts
- AI model call duration and status
- User subscription/unsubscription events
