require 'HTTParty'
require 'nokogiri'

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
        menu = parse_menu 'week'
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
          result << '--------------------------'
        end
        result.join("\n")
      end

      def daymenu
        result = []
        menu = parse_menu
        items = menu.css('div.item')
        items.each do |item|
          name = item.css('h3 img')[0]['alt']
          result << "#{name} : #{item.text.strip}"
        end
        result.join("\n")
      end

      def parse_menu(page = '')
        menu = HTTParty.get("http://ishetlekkerindemess.be/#{page}")
        Nokogiri::HTML(menu)
      end

      Lita.register_handler(self)
    end
  end
end
