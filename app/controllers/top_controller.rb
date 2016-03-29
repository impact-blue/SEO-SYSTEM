

require "open-uri"

class TopController < ApplicationController
  def index
    agent = Mechanize.new
    keyword = 'site:http://www.kangoworks.com'
    escaped_keyword = CGI.escape(keyword)
    # 検索結果を開く
    page = agent.get("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{escaped_keyword}")
    elements = page.search('.g .r a')

    elements.each do |ele|
      meta_info = MetaInfo.new
        href = ele.attribute("href")
      #link_address
      meta_info.link_address = URI.parse(href).query.split("&")[0].split("=")[1]
      #link_text
      meta_info.link_text = ele.inner_text
      link = Nokogiri.HTML(open(meta_info.link_address))
      #title
      meta_info.title = link.title
      #description
      if link.css('//meta[name$=description]/@content').to_s.blank?
        meta_info.description = link.css('//meta[name$=Description]/@content').to_s
      else
        meta_info.description = link.css('//meta[name$=description]/@content').to_s
      end
      #keywords
      if link.css('//meta[name$=keywords]/@content').to_s.blank?
        meta_info.keywords = link.css('//meta[name$=Keywords]/@content').to_s
      else
        meta_info.keywords = link.css('//meta[name$=keywords]/@content').to_s
      end
      meta_info.save
    end

    binding.pry
    href = page.search("td .b a")[0].attributes["href"]
    next_link = URI.parse(href).query[2..-1]
    next_page = 

  end
end

#URI.parse(elements)
#URI.parse(elements).query.split(/&/)
#doc = agent.get("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{escaped_keyword}")