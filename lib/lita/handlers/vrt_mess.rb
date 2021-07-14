require 'httparty'
require 'nokogiri'

require 'json'

module Lita
  module Handlers
    # Handle the VRT Mess requests for the Lita.io bot
    class VrtMess < Handler
      help = { 'mess' => 'Show menu from ishetlekkerindemess.be.' }
      route(/mess(.|$)+?(?<w>week)?/, :handle_mess, command: true, help: help)

      def handle_mess(response)
        week = response.match_data[:w]
        if week == 'week'
          response.reply(weekmenu)
        else
          response.reply(daymenu)
        end
      end

      def weekmenu
        header = []
        result = []
        menu = fetch_menu 'week'
        table = menu.at('table')
        table.search('tr').each do |tr|
          cells = tr.search('th')
          cells.each do |d|
            header << d.text
          end
        end
        table.search('tr').each do |tr|
          cells = tr.search('td')
          cells.each_with_index do |d, i|
            result << "#{header[i]} : #{d.text}"
          end
          result << '--------------------------' unless result.empty?
        end
        result = ['Geen menu gevonden :(', 'Kijk eens op https://rto365.sharepoint.com/sites/MijnEten'] if result.empty?
        result.join("\n")
      end

      def daymenu
        menu = fetch_menu
        result = format_day(menu)
        result = ['Geen menu gevonden :(', 'Kijk eens op https://rto365.sharepoint.com/sites/MijnEten'] if result.empty?
        result.join("\n")
      end

      def format_day(menu)
        result = []
        date = menu.delete(:date)
        return result if menu.empty?
        result << "Menu voor #{date}"
        menu.each do |name, value|
          result << "#{name}: #{value}"
        end
        result
      end

      def fetch_menu(page = '')
        page = HTTParty.get("http://ishetlekkerindemess.be/#{page}")
        json = Nokogiri::HTML(page).css('script#__NEXT_DATA__').text
        menu = JSON.parse(json, symbolize_names: true)
        menu[:props][:pageProps][:initialData]
      end

      Lita.register_handler(self)
    end
  end
end
