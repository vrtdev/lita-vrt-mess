require 'spec_helper'
require 'pry'

describe Lita::Handlers::VrtMess, lita_handler: true do
  it { is_expected.to route_command('mess').to(:handle_mess) }

  it 'returns the VRT Mess menu' do
    send_command('mess')
    expect(replies.first).to include('Soep : ')
  end

  it 'returns the VRT Mess weekmenu' do
    send_command('mess week')
    expect(replies.first).to include('Datum : ')
  end
end
