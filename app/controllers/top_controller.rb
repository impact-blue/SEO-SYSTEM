require "open-uri"

class TopController < ApplicationController

  def index
  end

  def test
    @csv = MetaInfo.all
    #CSVダウンロード
    #<a href="/admin/products.csv/?status=all&page={{data.search_products.current_page}}">CSV</a>
    respond_to do |format|
      format.html and return
      format.csv do
        send_data render_to_string, filename: "products-#{Time.now.to_date.to_s}.csv", type: :csv
      end
    end
  end


  def google
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
          meta_info.search_word = keyword
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


#途中から次へがなくなってしまう
  def yahoo
    begin
        agent = Mechanize.new
        agent.user_agent_alias = 'Windows Mozilla'
        # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
        ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
        agent.user_agent = ua
        agent.open_timeout = 180
        keyword = params[:search] #'site:http://www.kangoworks.com'
        escaped_keyword = CGI.escape(keyword)
        # 検索結果を開く
        page = agent.get("http://search.yahoo.co.jp/search?p=#{escaped_keyword}&ei=UTF-8&dups=1")

          while true
                  elements = page.search('.hd h3 a')
                  elements.each do |ele|
                      meta_info = MetaInfo.new
                      #link_address
                      meta_info.link_address = ele.attribute("href").value
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
              page = page.link_with(:text => "次へ>").href
              page = agent.get(page)
          end
      rescue
        redirect_to 'index'
      end
  end
end