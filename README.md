# Raffle Bot!

Raffle Bot simply picks a "winner" from the people in the channel.  It is triggered by typing "rafflebot" into slack.

## To run the bot

1. Run `bundle install`
2. [Get a slack token](https://github.com/FreedomBen/slackbot_frd#step-1)
3. [Set your token](https://github.com/FreedomBen/slackbot_frd#step-2).  Either edit `slackbot-frd.conf` and put it there, or set the environment variable:

    ```
    export SLACKBOT_FRD_TOKEN="<your-token>"
    ```
4. Run the bot (from the root directory, or where `ls` reveals the `bots` folder):

    ```
    slackbot-frd start
    ```

## Extra Info

Raffle bot is built on top of [slackbot_frd](https://github.com/FreedomBen/slackbot_frd)
