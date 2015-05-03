require 'byebug'

RAFFLEBOT_DATABASE_FILE = `mktemp -u`.chomp

RSpec.describe "RafflebotCli" do

  let(:rafflebot_cli) { File.expand_path("#{__FILE__}/../../../lib/rafflebot") }
  let(:rafname) { "test_raffle" }
  let(:user) { "celita" }
  let(:notuser) { "not_a_user" }

  let(:settings) do
    {
      "allow_dup_winners" => { default: "false", change: "true" },
      "channel_pool" => { default: "none", change: "bps_graveyard" },
      "restrict_ops_to_owner" => { default: "true", change: "false" },
    }
  end

  before :each do
    File.write("rafflebot_database_file.txt", `mktemp -u`.chomp)
  end

  after :each do
    File.delete("rafflebot_database_file.txt")
  end

  def rafbot_new(name)
    `#{rafflebot_cli} new #{name} --user="#{user}"`.chomp
  end

  def rafbot_list
    `#{rafflebot_cli} list --user="#{user}"`.chomp
  end

  def rafbot_setting(name, setting)
    `#{rafflebot_cli} setting #{name} #{setting} --user="#{user}"`.chomp
  end

  def rafbot_settings(name)
    `#{rafflebot_cli} settings #{name} --user="#{user}"`.chomp
  end

  def rafbot_set(name, setting, value)
    `#{rafflebot_cli} set #{name} #{setting} #{value} --user="#{user}"`.chomp
  end

  def rafbot_winners(name)
    `#{rafflebot_cli} winners #{name} --user="#{user}"`.chomp
  end

  def rafbot_pick_winner(name, users)
    `#{rafflebot_cli} pick_winner #{name} #{users.join} --user="#{user}"`.chomp
  end

  def list_to_rafname_array
    retval = rafbot_list.gsub(/```\s*/, '').split
    2.times { retval.shift }
    retval.select{ |el| el != "-"}
  end

  def settings_to_hash(raffle)
    arr = rafbot_settings(raffle).split
    3.times{ arr.shift }
    arr.pop
    retval = {}
    last_key = nil
    arr.each_with_index do |str, i|
      if i.even?
        last_key = str.gsub(":", '')
      else
        retval[last_key] = str
      end
    end
    retval
  end

  def check_setting_value(rafname, setting, value)
    expect(settings_to_hash(rafname)[setting]).to eq(value)
    expect(rafbot_setting(rafname, setting)).to eq(value)
  end

  context "commands" do
    it "supports new" do
      rafs = %w[one two three four five six]
      expect{ rafbot_new(rafname) }.to change{list_to_rafname_array}.from([]).to([rafname])
      rafs.each do |new_raf|
        expect{ rafbot_new(new_raf) }.to change{ list_to_rafname_array.count }.by(1)
      end
      expect(list_to_rafname_array).to match_array(rafs.push(rafname))
    end

    it "supports reading/writing settings" do
      rafbot_new(rafname)
      settings.each{ |setting, values| check_setting_value(rafname, setting, values[:default]) }
      settings.each do |setting, values|
        expect{rafbot_set(rafname, setting, values[:change])}.to change{rafbot_setting(rafname, setting)}.from(values[:default]).to(values[:change])
        check_setting_value(rafname, setting, values[:change])
      end
    end

    it "supports reading winners and picking winners" do

    end
  end

  context "security" do

  end
end
