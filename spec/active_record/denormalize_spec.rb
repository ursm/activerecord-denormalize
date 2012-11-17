require 'spec_helper'

describe ActiveRecord::Denormalize do
  subject(:message) { Message.create!(sender: sender) }

  context 'normal case' do
    let(:sender) { User.create!(name: 'foo') }

    its(:sender_name) { should == sender.name }

    specify do
      expect {
        sender.update_attribute :name, 'bar'
      }.to change { message.reload.sender_name }.to('bar')
    end
  end

  context 'not associated' do
    let(:sender) { nil }

    its(:sender_name) { should be_nil }
  end
end
