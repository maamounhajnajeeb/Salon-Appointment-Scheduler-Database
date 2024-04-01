#!/bin/bash

echo -e "\n~~~~~ MY SALON ~~~~~\n"

PSQL="psql -X --username=freecodecamp --dbname=salon --tuples-only -c"


MAIN_MENU() {

  # check if there is any args (when re-call)
  if [[ $1 ]]
  then
    echo "$1"
  fi

  echo -e "\nWelcome to My Salon, how can I help you?"

  SERVICES_LIST=$($PSQL "select service_id, name from services;")
  echo "$SERVICES_LIST" | while read SERVICE_ID BAR SERVICE_NAME
  do
    echo "$SERVICE_ID) $SERVICE_NAME"
  done

  read SERVICE_ID_SELECTED
  SERVICE_QUERY=$($PSQL "select service_id from services where service_id=$SERVICE_ID_SELECTED")

  if [[ -z $SERVICE_QUERY ]]
  then
    MAIN_MENU "I could not find that service. What would you like today?"
  else

    # if it exists, we should ask for number
    SERVICE_NAME=$($PSQL "select name from services where service_id=$SERVICE_ID_SELECTED")

    echo -e "\nWhat's your phone number?"
    read CUSTOMER_PHONE
    CHECK_PHONE=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")
    if [[ $CHECK_PHONE ]]

    then
      # if the phone exists
      CUSTOMER_NAME=$($PSQL "select name from customers where phone='$CUSTOMER_PHONE';")
      echo -e "\nWhat time would you like your$SERVICE_NAME,$CUSTOMER_NAME?"
      read SERVICE_TIME
      CREATE_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time)
                                  values($CHECK_PHONE, $SERVICE_QUERY, '$SERVICE_TIME');")
      
      echo -e "\nI have put you down for a cut at $SERVICE_TIME,$CUSTOMER_NAME."

    else
      # if the phone doesn't exists, create customer
      echo -e "\nI don't have a record for that phone number, what's your name?"
      read CUSTOMER_NAME
      CUSTOMER_INSERTION=$($PSQL "insert into customers(name, phone) values('$CUSTOMER_NAME', '$CUSTOMER_PHONE');")

      # query customer id
      CUSTOMER_ID=$($PSQL "select customer_id from customers where phone='$CUSTOMER_PHONE';")

      # then choose time
      echo -e "\nWhat time would you like your$SERVICE_NAME, $CUSTOMER_NAME?"
      read SERVICE_TIME
      CREATE_APPOINTMENT=$($PSQL "insert into appointments(customer_id, service_id, time)
                                  values($CUSTOMER_ID, $SERVICE_QUERY, '$SERVICE_TIME');")
      
      echo -e "\nI have put you down for a cut at $SERVICE_TIME, $CUSTOMER_NAME."

    fi

  fi
}

MAIN_MENU