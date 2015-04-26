require 'securerandom'

require_relative '../lib/raffle_bot_database'

class RaffleBot < SlackbotFrd::Bot
  def initialize
    @db = RaffleBotDatabase.new
    @rafflebot_cli = File.expand_path("#{__FILE__}/../../lib/rafflebot")
  end

  def add_callbacks(slack_connection)
    slack_connection.on_message do |user, channel, message|
      # Don't answer unless directed to us and it's not a bot
      if message =~ /^\s*rafflebot/i && user != :bot
        handle_response(slack_connection, user, channel, message)
      end
    end
  end

  private
  def handle_response(slack_connection, user, channel, message)
    regex_no_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)/i
    regex_with_rafname = /^\s*rafflebot\s+([a-zA-Z0-9_]+)\s+([a-zA-Z0-9_]+)/i

    command = sanitize_commands(message)

    if message =~ regex_with_rafname
      handle_response_with_rafname(slack_connection, user, channel, command)
    elsif message =~ regex_no_rafname
      straight_pass(slack_connection, user, channel, command)
    else
      send_bad_command_msg(slack_connection, channel)
    end
  end

  private
  def handle_response_with_rafname(slack_connection, user, channel, command)
    if command =~ /^pick_winner\s([a-zA-Z0-9_]+)/
      raffle = $1
      send_msg(slack_connection, channel, "Choosing a new winner at random...")
      channel_pool = `#{@rafflebot_cli} setting #{raffle} channel_pool`.chomp
      channel_pool.gsub(/#/, '') # just in case
      users = if channel_pool.empty? || channel_pool =~ /any|all|none/
                slack_connection.users_in_channel(channel)
              else
                slack_connection.users_in_channel(channel_pool)
              end
      send_msg(slack_connection, channel, `#{@rafflebot_cli} pick_winner #{raffle} #{users.join(" ")} --user="#{user}"`)
    else
      straight_pass(slack_connection, user, channel, command)
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

  private
  def straight_pass(sc, user, channel, command)
    pr = if command =~ /^help/
           parse_response("```#{parse_response(`#{@rafflebot_cli} #{command}`)}```".gsub(/(Options|\[\-\-user).*\n/i, ''))
         else
           parse_response(`#{@rafflebot_cli} #{command} --user="#{user}"`)
         end
    send_msg(sc, channel, pr)
  end

  private
  def send_bad_command_msg(slack_connection, channel)
    send_msg(
      slack_connection,
      channel,
      "Sorry friend, I didn't quite catch that:\n```\n#{`#{@rafflebot_cli}`.gsub(/_cli\.rb/i, '')}```"
    )
  end
end
