require_relative '../lib/raffle_bot_database'

module RaffleHelper
  def self.winners
    %w[dan greg todd eddy dave]
  end

  def self.raffles
    %w[one two three four five six seven]
  end

  def self.owner
    "celita"
  end

  def self.db_with_data
    db = RaffleBotDatabase.new(`mktemp -u`.chomp)
    raffles.each_with_index do |raffle, i|
      db.create_raffle(owner, raffle)
      db.set_option(owner, raffle, true, "slc") if i % 3
    end
    db.raffles.each do |raffle|
      winners.each do |name|
        db.add_winner(owner, raffle, name)
      end
    end
    db
  end
end
