#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"

echo -e "\n~~~~~ MY SALON ~~~~~"

echo -e "\nWelcome to My Salon, how can I help you?\n"

MAIN_MENU() {
  if [[ $1 ]]
  then
    echo -e "\n$1\n"
  fi

  LIST_OF_SERVICES=$($PSQL "SELECT * FROM services")
  #NUMBER_OF_SERVICES=$($PSQL "SELECT COUNT(*) FROM services")
  
  echo "$LIST_OF_SERVICES" | while read SERVICE_ID PIPE SERVICE_NAME
  do
    if [[ $SERVICE_ID =~ ^[0-9]$ ]]
    then
      echo "$SERVICE_ID) $SERVICE_NAME"
    fi
  done

  read SERVICE_ID_SELECTED
  if [[ $SERVICE_ID_SELECTED =~ [a-z]+ ]] || [[ $SERVICE_ID_SELECTED -gt 6 ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"

  else
    SERVICE_CHOICE=$($PSQL "SELECT name FROM services WHERE service_id = $SERVICE_ID_SELECTED")
    SERVICE_CHOICE_FORMATTED=$(echo $SERVICE_CHOICE | sed -E 's/^ *| *$//g')

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE

    CUSTOMER_NAME=$($PSQL "SELECT name FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    if [[ -z $CUSTOMER_NAME ]]
    then 
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME

      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(name, phone) VALUES('$CUSTOMER_NAME','$CUSTOMER_PHONE')")
    fi

    CUSTOMER_ID=$($PSQL "SELECT customer_id FROM customers WHERE phone = '$CUSTOMER_PHONE'")

    CUSTOMER_NAME_FORMATTED=$(echo $CUSTOMER_NAME | sed -E 's/^ *| *$//g')

    echo -e "\nWhat time would you like your $SERVICE_CHOICE_FORMATTED, $CUSTOMER_NAME_FORMATTED?"
    read SERVICE_TIME
    
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) VALUES($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")

    echo -e "\nI have put you down for a $SERVICE_CHOICE_FORMATTED at $SERVICE_TIME, $CUSTOMER_NAME_FORMATTED."

  fi

}

MAIN_MENU

### still working on this project