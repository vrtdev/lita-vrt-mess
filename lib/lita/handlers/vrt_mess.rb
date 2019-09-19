require 'HTTParty'
require 'nokogiri'

module Lita
  module Handlers
    # Handle the VRT Mess requests for the Lita.io bot
    class VrtMess < Handler
      help = { 'mess' => 'Show menu from ishetlekkerindemess.be.' }
      route(/mess/, :handle_mess, command: true, help: help)

      def handle_mess(response)
        response.reply(getmenu)
      end

      def getmenu
        result = []
        menu = parse_menu
        items = menu.css('div.item')
        items.each do |item|
          name = item.css('h3 img')[0]['alt']
          result << "#{name} : #{item.text.strip}"
        end
        result.join("\n")
      end

      def parse_menu
        menu = HTTParty.get('http://ishetlekkerindemess.be')
        Nokogiri::HTML(menu)
      end

      Lita.register_handler(self)
    end
  end
end
