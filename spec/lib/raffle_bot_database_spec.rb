require_relative '../../lib/raffle_bot_database'

require_relative '../raffle_helper'

RSpec.describe RaffleBotDatabase do
  let(:testraffle) { 'test_raffle_name' }
  let(:db) { RaffleBotDatabase.new(`mktemp -u`.chomp) }
  let(:db_with_data) { RaffleHelper.db_with_data }
  let(:dan) { "dan" }
  let(:owner) { "celita" }
  let(:not_owner) { "angela" }
  let(:channel_pool) { "crazy_channel" }

  context "ops" do
    it "creates file during init" do
      tempfile = `mktemp -u`.chomp
      expect{RaffleBotDatabase.new(tempfile)}.to change{File.exists?(tempfile)}.from(false).to(true)
    end

    it "supports raffle creation and reading" do
      expect{db.create_raffle(testraffle, owner)}.to change{db.raffles}.from([]).to([testraffle])
    end

    it "supports reading and writing options" do
      db.create_raffle(testraffle, owner)
      expect{db.set_option(owner, testraffle, 'allow_dup_winners', true)}.to change{db.get_option(testraffle, 'allow_dup_winners')}.from(false).to(true)
      expect{db.set_option(owner, testraffle, 'channel_pool', 'bps_test_graveyard')}.to change{db.get_option(testraffle, 'channel_pool')}.from('none').to('bps_test_graveyard')
      expect{db.set_option(owner, testraffle, 'restrict_ops_to_owner', false)}.to change{db.get_option(testraffle, 'restrict_ops_to_owner')}.from(true).to(false)
      expect{db.set_option(owner, testraffle, 'owner', 'bps_test_graveyard')}.to change{db.get_option(testraffle, 'owner')}.from(owner).to('bps_test_graveyard')
    end

    it "suports winner creation and reading" do
      db.create_raffle(testraffle, owner)
      expect(db.raffles).to include(testraffle)
      expect(db.winner?(testraffle, dan)).to be_falsey
      expect(db.num_winners(testraffle)).to be_zero

      expect{db.add_winner(owner, testraffle, "dan")}.to change{db.winners(testraffle)}.from([]).to([dan])

      expect(db.winner?(testraffle, dan)).to be_truthy
      expect(db.num_winners(testraffle)).to eq(1)
      expect(db.winner_num(testraffle, dan)).to eq(1)
    end

    it "supports clearing the winners from a raffle" do
      expect{db_with_data.clear(owner, RaffleHelper.raffles.first)}.to change{db_with_data.winners(RaffleHelper.raffles.first)}.from(RaffleHelper.winners).to([])
    end
  end

  context "ownership" do
    let(:allow_dup_winners)     { false }
    let(:restrict_ops_to_owner) { true }

    before :each do
      db.create_raffle(testraffle, owner, allow_dup_winners, channel_pool, restrict_ops_to_owner)
    end

    it "allows reading options when not the owner" do
      RaffleBotDatabase.allowed_options.each do |opt|
        expect{db.get_option(testraffle, opt)}.not_to raise_error
        expect(db.get_option(testraffle, opt)).not_to be_nil
      end
    end

    it "allows writing options when not the owner when the option is set" do
      expect{db.set_option(owner, testraffle, 'restrict_ops_to_owner', false)}.to change{db.get_option(testraffle, 'restrict_ops_to_owner')}.to(false)
      expect{db.set_option(not_owner, testraffle, 'allow_dup_winners', true)}.to change{db.get_option(testraffle, 'allow_dup_winners')}.from(false).to(true)
    end

    it "disallows writing options when not the owner" do
      expect(db.get_option(testraffle, 'restrict_ops_to_owner')).to be_truthy
      expect{db.set_option(not_owner, testraffle, 'allow_dup_winners', false)}.not_to change{db.get_option(testraffle, 'allow_dup_winners')}
    end
  end
end
