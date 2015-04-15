class RaffleBot < SlackbotFrd::Bot
  def add_callbacks(slack_connection)
    slack_connection.on_message do |user, channel, message|
      if message =~ /^rafflebot/i
        winner = slack_connection.users_in_channel(channel).sample
        slack_connection.send_message_as_user(channel, "@#{winner} wins!!!", "Raffle Bot", ":raphael:", true)
      end
    end
  end
end
