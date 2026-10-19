#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

# Insert unique teams
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ "$YEAR" != "year" ]]; then
    for TEAM in "$WINNER" "$OPPONENT"
    do
      TEAM_EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name='$TEAM'")

      if [[ -z $TEAM_EXISTS ]]; then
        INSERT_TEAM=$($PSQL "INSERT INTO teams(name) VALUES('$TEAM')")
      fi
    done
  fi
done < games.csv

# Insert games
while IFS=, read -r YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ "$YEAR" != "year" ]]; then
    WINNER_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    OPPONENT_ID=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")

    INSERT_GAME=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $WINNER_ID, $OPPONENT_ID, $WINNER_GOALS, $OPPONENT_GOALS)")
  fi
done < games.csv
