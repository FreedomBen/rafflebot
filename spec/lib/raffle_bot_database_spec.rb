require_relative '../../lib/raffle_bot_database'

require_relative '../raffle_helper'

RSpec.describe RaffleBotDatabase do
  context "ops" do
    let(:testraffle) { 'test_raffle_name' }
    let(:db) { RaffleBotDatabase.new(`mktemp -u`.chomp) }
    let(:db_with_data) { RaffleHelper.db_with_data }
    let(:dan) { "dan" }

    it "creates file during init" do
      tempfile = `mktemp -u`.chomp
      expect{RaffleBotDatabase.new(tempfile)}.to change{File.exists?(tempfile)}.from(false).to(true)
    end

    it "supports raffle creation and reading" do
      expect{db.create_raffle(testraffle)}.to change{db.raffles}.from([]).to([testraffle])
    end

    it "supports reading and writing options" do
      db.create_raffle(testraffle)
      expect{db.set_option(testraffle, 'allow_dup_winners', true)}.to change{db.get_option(testraffle, 'allow_dup_winners')}.from(false).to(true)
      expect{db.set_option(testraffle, 'channel_pool', 'bps_test_graveyard')}.to change{db.get_option(testraffle, 'channel_pool')}.from('none').to('bps_test_graveyard')
    end

    it "suports winner creation and reading" do
      db.create_raffle(testraffle)
      expect(db.raffles).to include(testraffle)
      expect(db.winner?(testraffle, dan)).to be_falsey
      expect(db.num_winners(testraffle)).to be_zero

      expect{db.add_winner(testraffle, "dan")}.to change{db.winners(testraffle)}.from([]).to([dan])

      expect(db.winner?(testraffle, dan)).to be_truthy
      expect(db.num_winners(testraffle)).to eq(1)
      expect(db.winner_num(testraffle, dan)).to eq(1)
    end

    it "supports clearing the winners from a raffle" do
      expect{db_with_data.clear(RaffleHelper.raffles.first)}.to change{db_with_data.winners(RaffleHelper.raffles.first)}.from(RaffleHelper.winners).to([])
    end
  end
end
