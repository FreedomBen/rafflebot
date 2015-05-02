require 'byebug'

RAFFLEBOT_DATABASE_FILE = `mktemp -u`.chomp

RSpec.describe "RafflebotCli" do

  let(:rafflebot_cli) { File.expand_path("#{__FILE__}/../../../lib/rafflebot") }
  let(:rafname) { "test_raffle" }
  let(:user) { "celita" }
  let(:notuser) { "not_a_user" }

  before :all do
    File.write("rafflebot_database_file.txt", `mktemp -u`.chomp)
  end

  after :all do
    File.delete("rafflebot_database_file.txt")
  end

  def rafbot_new(name)
    `#{rafflebot_cli} new #{name} --user="#{user}"`
  end

  def rafbot_list
    `#{rafflebot_cli} list --user="#{user}"`
  end

  def rafbot_setting(name, setting)
    `#{rafflebot_cli} setting #{name} #{setting_name} --user="#{user}"`
  end

  def rafbot_settings(name)
    `#{rafflebot_cli} settings #{name} --user="#{user}"`
  end

  def set(name, setting, value)
    `#{rafflebot_cli} set #{name} #{setting} #{value} --user="#{user}"`
  end

  def winners(name)
    `#{rafflebot_cli} winners #{name} --user="#{user}"`
  end

  def pick_winner(name, users)
    `#{rafflebot_cli} pick_winner #{name} #{users.join} --user="#{user}"`
  end

  context "commands" do
    it "supports list" do
      rafbot_list
    end

    it "supports new" do
      # rafbot_new(rafname)
    end
  end

  context "security" do

  end
end
