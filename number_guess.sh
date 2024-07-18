#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

get_username() {
  echo "Enter your username:"
  read USERNAME

  USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
  

  if [[ -z $USER_ID ]]
  then
    INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username) VALUES ('$USERNAME')")
    USER_ID=$($PSQL "SELECT user_id FROM users WHERE username='$USERNAME'")
    echo Welcome, $USERNAME! It looks like this is your first time here.
  else
    GAMES_PLAYED=$($PSQL "SELECT COUNT(*) FROM games WHERE user_id=$USER_ID")
    BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id=$USER_ID")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
  fi
}

play_game() {
  SECRET_NUMBER=$((RANDOM % 1000 + 1))
  GUESSES=0
  echo "Guess the secret number between 1 and 1000:"

  while true; do
    read USERGUESS
    ((GUESSES++))

    if [[ ! $USERGUESS =~ ^[0-9]+$ ]]
    then
      echo "That is not an integer, guess again:"
    elif [[ $USERGUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
    elif [[ $USERGUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      echo "You guessed it in $GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"
      break
    fi

  done
  INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(user_id, guesses, secret_number) VALUES($USER_ID, $GUESSES, $SECRET_NUMBER)")
}

get_username
play_game
