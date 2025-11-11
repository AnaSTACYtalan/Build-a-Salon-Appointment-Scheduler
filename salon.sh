#! /bin/bash

# Connect to the PostgreSQL database
PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

# Function to display services
DISPLAY_SERVICES() {
  echo -e "\nWelcome to Salon! Here are our services:"
  $PSQL "SELECT service_id, name FROM services ORDER BY service_id;" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done
}

# Display services first
DISPLAY_SERVICES

# Prompt for service selection
echo -e "\nPlease enter the service ID you would like:"
read SERVICE_ID_SELECTED

# Check if service exists
SERVICE_NAME=$($PSQL "SELECT name FROM services WHERE service_id=$SERVICE_ID_SELECTED;")
if [[ -z $SERVICE_NAME ]]; then
  echo -e "\nI could not find that service. Please choose again."
  exec $0  # Restart script
  exit
fi

# Ask for customer's phone number
echo -e "\nWhat's your phone number?"
read CUSTOMER_PHONE

# Check if customer exists
CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone='$CUSTOMER_PHONE';")

# If customer does not exist, get name and insert into customers table
if [[ -z $CUSTOMER_NAME ]]; then
  echo -e "\nI don't have a record for that phone number, what's your name?"
  read CUSTOMER_NAME
  $PSQL "INSERT INTO customers(phone, name) VALUES('$CUSTOMER_PHONE', '$CUSTOMER_NAME');"
fi

# Ask for appointment time
echo -e "\nWhat time would you like your appointment?"
read SERVICE_TIME

# Get customer_id
CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone='$CUSTOMER_PHONE';")

# Insert appointment
$PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME');"

# Output confirmation
echo -e "\nI have put you down for a $SERVICE_NAME at $SERVICE_TIME, $CUSTOMER_NAME."
