require "open-uri"

class TopController < ApplicationController

  def index
    agent = Mechanize.new
    agent.user_agent_alias = 'Windows Mozilla'
    # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
    ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
    agent.user_agent = ua
    agent.open_timeout = 180
    keyword = 'site:http://www.kangoworks.com'
    escaped_keyword = CGI.escape(keyword)
    # 検索結果を開く
    page = agent.get("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{escaped_keyword}")
    num = 1
    while true
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

      href = page.search("td .b a")[0].attributes["href"]
      if num == 1
        page = page.links[60].click
        num += 1
      else
        page = page.links[62].click
      end

      unless href
        break
      end
    end
  end

  def yahoo
        agent = Mechanize.new
    agent.user_agent_alias = 'Windows Mozilla'
    # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
    ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
    agent.user_agent = ua
    agent.open_timeout = 180
    keyword = 'site:http://www.kangoworks.com'
    escaped_keyword = CGI.escape(keyword)
    # 検索結果を開く
    page = agent.get("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{escaped_keyword}")
    num = 1
    while true
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

      href = page.search("td .b a")[0].attributes["href"]
      if num == 1
        page = page.links[60].click
        num += 1
      else
        page = page.links[62].click
      end

      unless href
        break
      end
    end
  end
end
