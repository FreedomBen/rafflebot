require 'securerandom'

require_relative '../lib/raffle_bot_database'

class RaffleBot < SlackbotFrd::Bot
  def initialize
    @db = RaffleBotDatabase.new
    @rafflebot_cli = File.expand_path("#{__FILE__}/../../lib/rafflebot_cli.rb")
  end

  def add_callbacks(slack_connection)
    slack_connection.on_message do |user, channel, message|
      regex_no_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)/i
      regex_with_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/i

      if message =~ /^\s*rafflebot/i && user != :bot
        if message =~ regex_with_rafname
          command = sanitize_commands(message)

          if command =~ /^pick_winner\s([a-zA-Z0-9_]+)/
            send_msg(slack_connection, channel, "Choosing a new winner at random...")
            channel_pool = `#{@rafflebot_cli} settings #{$1} channel_pool`
            channel_pool.gsub(/#/, '') # just in case
            users = if channel_pool =~ /any|all|none/
                      slack_connection.users_in_channel(channel)
                    else
                      slack_connection.users_in_channel(channel_pool)
                    end
            `#{@rafflebot_cli} pick_winner #{$1} #{users.join(" ")}`
          else
            pr = parse_response(`#{@rafflebot_cli} #{command}`)
            send_msg(slack_connection, channel, pr)
          end
        elsif message =~ regex_no_rafname
          command = sanitize_commands(message)
          send_msg(slack_connection, channel, parse_response(`#{@rafflebot_cli} #{command}`))

          #target_channel = channel
          #users = slack_connection.users_in_channel(target_channel)
          #slack_connection.send_message_as_user(channel, "@#{winner} wins!!!", "Raffle Bot", ":raphael:", true)
        else
          send_msg(
            slack_connection,
            channel,
            "Sorry friend, I didn't quite catch that:\n```\n#{`#{@rafflebot_cli}`.gsub(/_cli\.rb/i, '')}```"
          )
        end
      end
    end
  end

  private
  def sanitize_commands(input)
    retval = input.gsub(/[^A-Za-z0-9_\s]/i, '').split
    retval.shift
    retval.join(" ")
  end

  private
  def parse_response(resp)
    return resp unless resp.empty?
    "Sorry friend, I don't know that command.\n```\n#{`#{@rafflebot_cli}`.gsub(/_cli\.rb/i, '')}```"
  end

  private
  def send_msg(sc, channel, message)
    sc.send_message_as_user(
      channel,
      message,
      "Raffle Bot",
      ":raphael:",
      true
    )
  end
end
