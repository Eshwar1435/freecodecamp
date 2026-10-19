#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess --tuples-only --no-align -c"

echo "Enter your username:"
read -r USERNAME

# Escape single quotes in usernames for SQL.
USERNAME_ESCAPED=$(printf '%s' "$USERNAME" | sed "s/'/''/g")

# Get the existing user's information from the database.
USER_DATA=$($PSQL "SELECT username || '|' || games_played || '|' || COALESCE(best_game::text, '') FROM users WHERE username='$USERNAME_ESCAPED';")

if [[ -z "$USER_DATA" ]]; then
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    $PSQL "INSERT INTO users (username) VALUES ('$USERNAME_ESCAPED');" > /dev/null
else
    DB_USERNAME=$(printf '%s' "$USER_DATA" | cut -d '|' -f 1)
    GAMES_PLAYED=$(printf '%s' "$USER_DATA" | cut -d '|' -f 2)
    BEST_GAME=$(printf '%s' "$USER_DATA" | cut -d '|' -f 3)

    echo "Welcome back, $DB_USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

SECRET_NUMBER=$((RANDOM % 1000 + 1))
NUMBER_OF_GUESSES=0

echo "Guess the secret number between 1 and 1000:"
read -r GUESS

while true; do
    # Accept integers, including negative integers.
    if [[ ! "$GUESS" =~ ^-?[0-9]+$ ]]; then
        echo "That is not an integer, guess again:"
        read -r GUESS
        continue
    fi

    # Force base 10 to handle leading zeros correctly.
    if [[ "$GUESS" == -* ]]; then
        GUESS_NUM=$((-10#${GUESS#-}))
    else
        GUESS_NUM=$((10#$GUESS))
    fi

    # Count each valid integer guess exactly once.
    ((NUMBER_OF_GUESSES++))

    if (( GUESS_NUM < SECRET_NUMBER )); then
        echo "It's higher than that, guess again:"
    elif (( GUESS_NUM > SECRET_NUMBER )); then
        echo "It's lower than that, guess again:"
    else
        break
    fi

    read -r GUESS
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

# Update the completed game and best score.
$PSQL "UPDATE users SET games_played = games_played + 1, best_game = CASE WHEN best_game IS NULL OR $NUMBER_OF_GUESSES < best_game THEN $NUMBER_OF_GUESSES ELSE best_game END WHERE username='$USERNAME_ESCAPED';" > /dev/null
