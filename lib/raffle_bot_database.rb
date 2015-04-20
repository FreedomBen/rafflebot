require 'sqlite3'
require 'fileutils'

class RaffleBotDatabase
  def self.sanitize_raffle_name(name)
    name.gsub(/[^a-zA-Z0-9_]/, '')
  end

  def initialize(db_file = nil)
    @db_file = db_file || File.expand_path("#{__FILE__}/../db/rafflebot.sqlite3")
    FileUtils::mkdir_p(File.dirname(@db_file))
    @db = SQLite3::Database.new(@db_file)
    @db.results_as_hash = true
    create_schema
  end

  def create_schema
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS raffles (
        name TEXT UNIQUE,
        allow_dup_winners INTEGER,
        channel_pool TEXT
      )
    SQL
    @db.execute <<-SQL
      CREATE TABLE IF NOT EXISTS winners (
        raffle_id INTEGER,
        number INTEGER,
        name TEXT
      );
    SQL
  end

  def create_raffle(name, allow_dup_winners = false, channel_pool = 'none')
    raffle = RaffleBotDatabase.sanitize_raffle_name(name)
    @db.execute("INSERT INTO raffles (name, allow_dup_winners, channel_pool) VALUES (?, ?, ?)", [raffle, (allow_dup_winners ? 1 : 0), channel_pool])
  end

  def raffles
    @db.execute("SELECT raffles.name FROM raffles").map{ |d| d["name"] }
  end

  def raffle_id(name)
    raffle = RaffleBotDatabase.sanitize_raffle_name(name)
    @db.execute("SELECT raffles.rowid FROM raffles WHERE name = ?", [raffle]).first[0]
  end

  def options(raffle)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    @db.execute("SELECT raffles.allow_dup_winners, raffles.channel_pool FROM raffles WHERE raffles.name = ? LIMIT 1", [rafname]).map do |val|
      {
        "allow_dup_winners" => val["allow_dup_winners"] != 0,
        "channel_pool"      => val["channel_pool"]
      }
    end.first
  end

  def set_option(raffle, option, value)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    return nil unless %w[allow_dup_winners channel_pool].include?(option)
    value = value ? 1 : 0 if option == 'allow_dup_winners'
    @db.execute("UPDATE raffles SET #{option} = ? WHERE raffles.name = ?", [value, rafname])
  end

  def winner_num(raffle, name)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    return nil unless winner?(rafname, name)
    @db.execute("SELECT winners.number FROM winners WHERE #{where_raffle_is(rafname)} AND name = ?", [name]).first[0]
  end

  def num_winners(raffle)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    @db.execute("SELECT COUNT(*) FROM winners WHERE #{where_raffle_is(rafname)}").first[0]
  end

  def winner?(raffle, name)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    !@db.execute("SELECT 1 FROM winners WHERE #{where_raffle_is(rafname)} AND name = ? LIMIT 1", [name]).empty?
  end

  def add_winner(raffle, name, number = nil)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    number = num_winners(rafname) + 1 unless number
    @db.execute("INSERT INTO winners (number, name, raffle_id) VALUES (?, ?, ?)", [number, name, raffle_id(rafname)])
  end

  def winners(raffle)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    @db.execute("SELECT winners.name FROM winners WHERE #{where_raffle_is(rafname)}").map{ |winner| winner["name"] }
  end

  def winners_with_number(raffle)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    @db.execute("SELECT winners.number, winners.name FROM winners WHERE #{where_raffle_is(rafname)}").map do |winner|
      { name: winner['name'], number: winner['number'] }
    end
  end

  def clear(raffle)
    rafname = RaffleBotDatabase.sanitize_raffle_name(raffle)
    @db.execute("DELETE FROM winners WHERE #{where_raffle_is(rafname)}")
  end

  private
  def where_raffle_is(name)
    raffle = RaffleBotDatabase.sanitize_raffle_name(name)
    "winners.raffle_id = #{raffle_id(raffle)}"
  end
end
