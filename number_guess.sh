#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USER

SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))

# Check if the user exists
FIND=$($PSQL "SELECT name FROM users WHERE name='$USER'")

if [[ -z $FIND ]]; then
  echo "Welcome, $USER! It looks like this is your first time here."

  # Set best_game to NULL for first-time users (since we don't know the best score yet)
  ADD=$($PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USER', 0, NULL)")

  # Prompt for the first guess
  echo "Guess the secret number between 1 and 1000:"
else
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USER'")
  GAMES=$($PSQL "SELECT games_played FROM users WHERE name='$USER'")
  echo "Welcome back, $USER! You have played $GAMES games, and your best game took $BEST_GAME guesses."
  echo "Guess the secret number between 1 and 1000:"
fi

# Start guessing loop
NUMBER_OF_GUESSES=0
while true; do
  read GUESS

  # Validate that input is an integer
  if ! [[ $GUESS =~ ^[0-9]+$ ]]; then
    echo "That is not an integer, guess again:"
    continue
  fi

  # Increment the guess counter
  ((NUMBER_OF_GUESSES++))

  # Check the guess
  if [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"

    # Increment games_played
    UPDATE=$($PSQL "UPDATE users SET games_played = games_played + 1 WHERE name='$USER'")

    # If this is the user's best game, update best_game
    if [[ -z $BEST_GAME || $NUMBER_OF_GUESSES -lt $BEST_GAME ]]; then
      UPDATE_BEST_GAME=$($PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE name='$USER'")
      echo "Congratulations! You set a new best game with $NUMBER_OF_GUESSES guesses."
    fi
    break
  fi
done
