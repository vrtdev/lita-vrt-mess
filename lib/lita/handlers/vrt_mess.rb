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
        result = []
        menus = fetch_menu 'week'
        menus.each do |menu|
          result << format_day(menu)
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
          value.strip!
          value = "geen #{name.downcase} :(" if value.empty?
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
