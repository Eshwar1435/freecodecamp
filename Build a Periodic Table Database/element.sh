#!/bin/bash
# Look up an element by atomic number, symbol, or name.
# Connect to the periodic_table PostgreSQL database.

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

# Handle a missing element argument.
# Handle a missing element argument.
if [[ -z "$1" ]]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT=$($PSQL "
  SELECT e.atomic_number, e.name, e.symbol, t.type,
         p.atomic_mass, p.melting_point_celsius,
         p.boiling_point_celsius
  FROM elements e
  JOIN properties p USING (atomic_number)
  JOIN types t USING (type_id)
  WHERE e.atomic_number::TEXT = '$1'
     OR e.symbol = '$1'
     OR e.name = '$1'
")

if [[ -z "$ELEMENT" ]]; then
  echo "I could not find that element in the database."
  exit 0
fi

IFS='|' read -r ATOMIC_NUMBER NAME SYMBOL TYPE MASS MELTING BOILING <<< "$ELEMENT"

echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $MASS amu. $NAME has a melting point of $MELTING celsius and a boiling point of $BOILING celsius."
