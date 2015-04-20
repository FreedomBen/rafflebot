require 'securerandom'

require_relative '../lib/raffle_bot_database'

class RaffleBot < SlackbotFrd::Bot
  def initialize
    @db = RaffleBotDatabase.new
    @rafflebot_cli = File.expand_path("#{__FILE__}/../lib/rafflebot-cli.rb")
  end

  def add_callbacks(slack_connection)
    slack_connection.on_message do |user, channel, message|
      regex_no_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)/i
      regex_with_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/i
      if message =~ /^\s*rafflebot/i
        if message =~ regex_no_rafname
          command = sanitize_commands(message)
          slack_connection.send_message_as_user(channel, "command is: '#{message}'", "Raffle Bot", ":raphael:", true)
        elsif message =~ regex_with_rafname
          command = sanitize_commands(message)
          slack_connection.send_message_as_user(channel, "command is: '#{message}'", "Raffle Bot", ":raphael:", true)


          target_channel = channel

          users = slack_connection.users_in_channel(target_channel)
          winner = users[SecureRandom.random_number(users.length)]
          slack_connection.send_message_as_user(channel, "@#{winner} wins!!!", "Raffle Bot", ":raphael:", true)
        else
          slack_connection.send_message_as_user(channel, "Sorry friend, I didn't quite catch that:\n#{`#{@rafflebot_cli}`}", "Raffle Bot", ":raphael:", true)
        end
      end
    end
  end

  private
  def sanitize_commands(input)
    input.gsub(/[A-Za-z0-9_]/i, '')
  end
end
