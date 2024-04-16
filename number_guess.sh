#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
# get random number between 1 and 1000
SECRET_NUMBER=$(( RANDOM % 1000 + 1 ))

# ask for user's name
echo Enter your username:
read NAME

# get user id
USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")
# if not found
if [[ -z $USER_ID ]]
then
  # create new user
  echo "Welcome, $NAME! It looks like this is your first time here."
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users (name) VALUES ('$NAME');")
  # get new user's id
  USER_ID=$($PSQL "SELECT user_id FROM users WHERE name='$NAME';")
else
  # get and display user's past history
  GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE user_id='$USER_ID';")
  BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE user_id='$USER_ID';")
  echo "Welcome back, $NAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo Guess the secret number between 1 and 1000:
USER_NUMBER=0
NUM_GUESSES=0
# until user guesses correctly
until [[ $USER_NUMBER =~ $SECRET_NUMBER ]]
do
  # get user's guess
  read USER_NUMBER
  # if input is a valid number
  if [[ $USER_NUMBER =~ ^[0-9]+$ ]]
  then
    # increment the number of guesses made for this current game
    NUM_GUESSES=$(($NUM_GUESSES+1))
    # notify user if guess is higher
    if [[ $USER_NUMBER -gt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
    else
      # notify user if guess is lower
      if [[ $USER_NUMBER -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      fi
    fi
  else
    # notify user to input a number only
    echo "That is not an integer, guess again:"
  fi
done

# update user's history
GAMES_PLAYED=$(($GAMES_PLAYED+1))
UPDATE_USER_GAMES_PLAYED_RESULT=$($PSQL "UPDATE users SET games_played=$GAMES_PLAYED WHERE user_id=$USER_ID;")
# update user's best_game value if it is the user's first game or the current game's guesses was lower
if [[ -z $BEST_GAME || $BEST_GAME -gt $NUM_GUESSES ]]
then
  BEST_GAME=$(($NUM_GUESSES))
  UPDATE_USER_BEST_GAME_RESULT=$($PSQL "UPDATE users SET best_game=$BEST_GAME WHERE user_id=$USER_ID;")
fi

# notify user of game's result and exit
echo "You guessed it in $NUM_GUESSES tries. The secret number was $SECRET_NUMBER. Nice job!"