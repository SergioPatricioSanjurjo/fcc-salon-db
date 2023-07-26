#! /bin/bash

PSQL="psql -t --username=freecodecamp --dbname=salon -c"


FIRST(){
SERVICES_INTRO=$($PSQL "SELECT * FROM services")
echo "$SERVICES_INTRO" | while read SERVICE_ID BAR NAME
do
  echo "$SERVICE_ID) $NAME"
done
}
FIRST

MAIN_MENU(){
  if [[ $1 ]]
  then
    echo -e "\n$1"
  fi

  #select a service
  read SERVICE_ID_SELECTED
  if [[ ! $SERVICE_ID_SELECTED =~ [1-3] ]]
  then
    echo -e "\nSelect a valid option"
    FIRST
  fi

  SERVICE=$($PSQL "SELECT * 
  			FROM services 
  			WHERE service_id = $SERVICE_ID_SELECTED")
  if [[ -z $SERVICE ]]
  then

    MAIN_MENU "Select a valid option"
  else
    # get customer phone
    echo -e "\n What's your phone number?"
    read CUSTOMER_PHONE
    CUSTOMER_ID=$($PSQL "SELECT customer_id 
    				FROM customers 
    				WHERE phone = '$CUSTOMER_PHONE'")
    if [[ -z $CUSTOMER_ID ]]
    then
      # get customer name
      echo -e "\n What's your name?"
      read CUSTOMER_NAME
      # insert new customer
      INSERT_CUSTOMER_RESULT=$($PSQL "INSERT INTO customers(phone, name) 
      					VALUES ('$CUSTOMER_PHONE', '$CUSTOMER_NAME')")
    fi
    # get customer id
    CUSTOMER_ID=$($PSQL "SELECT customer_id 
    				FROM customers WHERE phone = '$CUSTOMER_PHONE'")
    # get appointment time
    echo -e "\n Give us  an appointment time:"
    read SERVICE_TIME
    # insert new appointment
    INSERT_APPOINTMENT_RESULT=$($PSQL "INSERT INTO appointments(customer_id, service_id, time) 
    					VALUES ($CUSTOMER_ID, $SERVICE_ID_SELECTED, '$SERVICE_TIME')")
    SERVICE_NAME=$($PSQL "SELECT name 
    				FROM services 
    				WHERE service_id = $SERVICE_ID_SELECTED")
    echo ""
    if [[ -z $INSERT_APPOINTMENT_RESULT ]]
    then
      MAIN_MENU "We fail to proces you request"
    else
      CUSTOMER_NAME=$($PSQL "SELECT name 
      				FROM customers 
      				WHERE customer_id = $CUSTOMER_ID")
      FORMATED_CUSTOMER_NAME=$(echo $CUSTOMER_NAME | sed 's/^ *| *$//')
      FORMATED_SERVICE_NAME=$(echo $SERVICE_NAME | sed 's/^ *| *$//')
      echo "I have put you down for a $FORMATED_SERVICE_NAME at $SERVICE_TIME, $FORMATED_CUSTOMER_NAME."
    fi
  fi
}
MAIN_MENU
