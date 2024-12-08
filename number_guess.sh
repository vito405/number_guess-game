#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

echo -e "\nEnter your username:"
read USER

SECRET_NUMBER=$(( (RANDOM % 1000) + 1 ))
echo $SECRET_NUMBER
# Check if the user exists
FIND=$($PSQL "SELECT name FROM users WHERE name='$USER'")

if [[ -z $FIND ]]; then
  echo "Welcome, $USER! It looks like this is your first time here."

  ADD=$($PSQL "INSERT INTO users(name) VALUES('$USER')")

  # Prompt for the first guess
  echo "Guess the secret number between 1 and 1000:"
else
  echo "Welcome back, $USER! You have played <games_played> games, and your best game took <best_game> guesses."
  echo "Guess the secret number between 1 and 1000:"
fi

# Start guessing loop
NUMBER_OF_GUESSES=0
while true; do
  read GUESS

  # Increment the guess counter
  ((NUMBER_OF_GUESSES++))

  # Check the guess
  if [[ $GUESS -gt $SECRET_NUMBER ]]; then
    echo "It's lower than that, guess again:"
  elif [[ $GUESS -lt $SECRET_NUMBER ]]; then
    echo "It's higher than that, guess again:"
  else
    echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
    break
  fi
done
