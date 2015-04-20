#!/usr/bin/env ruby

require 'thor'
require 'securerandom'

require_relative 'raffle_bot_database'

class RafflebotCli < Thor
  desc "list", "List all raffles"
  def list
    puts "Raffles: #{db.raffles.join("\n")}"
  end

  desc "new <rafflename>", "Create a new raffle"
  def new(rafflename)
    return unless valid_raffle(rafflename)
    db.create_raffle(rafflename)
  end

  desc "settings <rafflename>", "Print out settings and their values for <rafflename>"
  def settings(rafflename)
    return unless valid_raffle(rafflename)
    puts "Raffle: #{rafflename}"
    db.options(rafflename).each do |key, val|
      puts "    #{key}: #{val}"
    end
  end

  desc "set_setting <rafflename> <option> <value>", "Set the <value> of <option> for <rafflename>"
  def set_setting(rafflename, option, value)
    return unless valid_raffle(rafflename)
    db.set_option(rafflename, option, value)
  end

  desc "winners <rafflename>", "Display list of previous winners of <rafflename>"
  def winners(rafflename)
    return unless valid_raffle(rafflename)
    winners = db.winners_with_number(rafflename).inject([]) do |acc, val|
                acc.push("\n#{val[:number]}: #{val[:name]}")
              end
    puts "Winners:#{winners.join}"
  end

  desc "pick_winner <rafflename>", "Draw a name for a new raffle winner for <rafflename>"
  def pick_winner(rafflename, *possible_users)
    return unless valid_raffle(rafflename)
    winner = possible_users[SecureRandom.random_number(possible_users.length)]
    db.add_winner(rafflename, winner)
    puts "New winner is #{winner}!"
  end

  private
  def db
    @db ||= RaffleBotDatabase.new
    @db
  end

  private
  def valid_raffle(rafflename)
    return true if db.raffles.include?(rafflename)
    puts "Invalid rafflename '#{rafflename}'.  Try creating it first"
    false
  end
end

RafflebotCli.start(ARGV)
