#!/bin/bash


# Gmail SMTP settings
SMTP_SERVER=""
SMTP_PORT=""
SMTP_USER=""
SMTP_PASS=""

# Recipient email address
RECIPIENT=""

# Initialize variables
consecutive_failures=0

# Send email
send_email() {
    echo "Subject: Ping Alert" > /tmp/email.txt
    echo "From: $SMTP_USER" >> /tmp/email.txt
    echo "To: $RECIPIENT" >> /tmp/email.txt
    echo "Content-Type: text/plain; charset=utf-8" >> /tmp/email.txt
    echo "" >> /tmp/email.txt
    echo "Ping to 8.8.8.8 has exceeded 250ms for 5 consecutive pings." >> /tmp/email.txt
    cat /tmp/email.txt | sendmail -S "$SMTP_SERVER:$SMTP_PORT" -au"$SMTP_USER" -ap"$SMTP_PASS" -f"$SMTP_USER" "$RECIPIENT"
}

# Main loop
while true; do
    # Perform the ping and capture the response time in milliseconds
    response_time=$(ping -c 1 8.8.8.8 | grep -oP 'time=\K\d+')

    # Check if the response time is greater than 250ms
    if [[ $response_time -gt 250 ]]; then
        ((consecutive_failures++))

        # If 5 consecutive failures are detected, send an email and reset the counter
        if [[ $consecutive_failures -ge 5 ]]; then
            send_email
            consecutive_failures=0
        fi
    else
        # Reset the consecutive failures counter
        consecutive_failures=0
    fi

    # Sleep before the next ping
    sleep 5
done
