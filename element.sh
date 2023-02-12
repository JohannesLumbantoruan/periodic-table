#!/bin/bash
PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only -c"
if [[ -z $1 ]]
then
  echo "Please provide an element as an argument."
else
  ATOMIC_NUMBER=0
  ELEMENT_CHECK=""

  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ELEMENT_CHECK=$($PSQL "SELECT * FROM elements WHERE atomic_number = $1")
    ATOMIC_NUMBER=$1
  elif [[ $1 =~ ^[A-Z]$|^[A-Z][a-z]$ ]]
  then
    ELEMENT_CHECK=$($PSQL "SELECT * FROM elements WHERE symbol = '$1'")
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE symbol = '$1'")
  elif [[ $1 =~ ^[A-Z][a-z]+$ ]]
  then
    ELEMENT_CHECK=$($PSQL "SELECT * FROM elements WHERE name = '$1'")
    ATOMIC_NUMBER=$($PSQL "SELECT atomic_number FROM elements WHERE name = '$1'")
  fi

  if [[ -z $ELEMENT_CHECK ]]
  then
    echo "I could not find that element in the database."
  else
    ELEMENT_INFO=$($PSQL "SELECT * FROM properties WHERE atomic_number = $ATOMIC_NUMBER")
    echo $ELEMENT_INFO | while read ATOM_NUMBER BAR MASS BAR MELTING_POINT BAR BOILING_POINT BAR TYPE_ID
    do
      ELEMENT_NAME=$($PSQL "SELECT name FROM elements INNER JOIN properties USING(atomic_number) WHERE atomic_number = $ATOMIC_NUMBER")
      ELEMENT_SYMBOL=$($PSQL "SELECT symbol FROM elements INNER JOIN properties USING(atomic_number) WHERE atomic_number = $ATOMIC_NUMBER")
      TYPE=$($PSQL "SELECT DISTINCT(type) FROM types INNER JOIN properties USING(type_id) WHERE type_id = $TYPE_ID")
      echo "The element with atomic number $ATOM_NUMBER is $(echo $ELEMENT_NAME | sed -r 's/^ *//g' ) ($(echo $ELEMENT_SYMBOL | sed -r 's/^ *//g' )). It's a $(echo $TYPE | sed -r 's/^ *//g' ), with a mass of $(echo $MASS | sed -r 's/^ *//g' ) amu. $(echo $ELEMENT_NAME | sed -r 's/^ *//g' ) has a melting point of $(echo $MELTING_POINT | sed -r 's/^ *//g' ) celsius and a boiling point of $(echo $BOILING_POINT | sed -r 's/^ *//g' ) celsius."
    done
  fi
fi
