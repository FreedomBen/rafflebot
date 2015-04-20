require 'securerandom'

require_relative '../lib/raffle_bot_database'

class RaffleBot < SlackbotFrd::Bot
  def initialize
    @db = RaffleBotDatabase.new
  end

  def add_callbacks(slack_connection)
    slack_connection.on_message do |user, channel, message|
      regex = /^\s*rafflebot\s+([a-zA-Z]+)/i
      if message =~ /^rafflebot/i
        users = slack_connection.users_in_channel(channel)
        winner = users[SecureRandom.random_number(users.length)]
        slack_connection.send_message_as_user(channel, "@#{winner} wins!!!", "Raffle Bot", ":raphael:", true)
      end
    end
  end
end
