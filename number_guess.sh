#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USER

SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))

FIND=$($PSQL "SELECT name FROM users WHERE name='$USER'")

if [[ -z $FIND ]]; then
  echo "Welcome, $USER! It looks like this is your first time here."
  ADD=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USER', 0, NULL)")
  echo "Guess the secret number between 1 and 1000:"
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USER'")
  GAMES=$($PSQL "SELECT games_played FROM users WHERE name='$USER'")
  echo "Welcome back, $USER! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  echo "Guess the secret number between 1 and 1000:"
fi

NUMBER_OF_GUESSES=0
while true; do
  read GUESS

  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  ((NUMBER_OF_GUESSES++))

  if [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    UPDATE=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE name='$USER'")

    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE name='$USER'")
    fi
    break
  fi
done
