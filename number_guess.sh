#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

echo Enter your username:
read NAME

USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")
if [[ -z $USER_ID ]]
then
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$NAME');")
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")
else
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID';")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:
USER_NUMBER=0
NUM_GUESSES=0
until [[ $USER_NUMBER =~ $SECRET_NUMBER ]]
do
  read USER_NUMBER
  if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    NUM_GUESSES=$(($NUM_GUESSES+1))
    if [[ $USER_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      if [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

GAMES_PLAYED=$(($GAMES_PLAYED+1))
UPDATE_USER_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
if [[ -z $BEST_GAME || $BEST_GAME -gt $NUM_GUESSES ]]
then
  BEST_GAME=$(($NUM_GUESSES))
  UPDATE_USER_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE user_id=$USER_ID;")
fi

echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"