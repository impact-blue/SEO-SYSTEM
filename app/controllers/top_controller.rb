require "open-uri"

class TopController < ApplicationController

  def index
    @search_word = MetaInfo.uniq.pluck(:search_word)
  end

  def test
    @csv = MetaInfo.where(search_word: params[:word])
    #CSVダウンロード
    #<a href="/admin/products.csv/?status=all&page={{data.search_products.current_page}}">CSV</a>
    respond_to do |format|
      format.html and return
      format.csv do
        send_data render_to_string, filename: "products-#{Time.now.to_date.to_s}.csv", type: :csv
      end
    end
  end

#次へのやつがまだできてない。
  def google
        agent = Mechanize.new
        agent.user_agent_alias = 'Windows Mozilla'
        # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
        ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
        agent.user_agent = ua
        agent.open_timeout = 1800
        keyword = params[:search]#'site:http://www.kangoworks.com'
        escaped_keyword = CGI.escape(keyword)
        # 検索結果を開く
        page = agent.get("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{escaped_keyword}")

        while true
            elements = page.search('.g .r a')
            elements.each do |ele|
              meta_info = MetaInfo.new
              meta_info.search_word = keyword
              meta_info.search_engin = "google"
              href = ele.attribute("href")
              #link_address
              meta_info.link_address =  ele.attribute("href").value
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
              #h1
              page.search("h1").each do |t,i|
                if i == 0
                  meta_info.h1 << t.text
                else
                  meta_info.h1 << ",,," + t.text
                end
              end

              meta_info.save
            end
          page = page.link_with(:text => "次へ").click
        end
     # rescue
     #   redirect_to root_path
  end


#途中から次へがなくなってしまう
  def yahoo
        agent = Mechanize.new
        agent.user_agent_alias = 'Windows Mozilla'
        # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
        ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
        agent.user_agent = ua
        agent.open_timeout = 1800
        keyword = params[:search] #'site:http://www.kangoworks.com'
        escaped_keyword = CGI.escape(keyword)
        # 検索結果を開く
        page = agent.get("http://search.yahoo.co.jp/search?p=#{escaped_keyword}&ei=UTF-8&dups=1")

          while true
                  elements = page.search('.hd h3 a')
                  elements.each do |ele|
                      meta_info = MetaInfo.new
                      meta_info.search_word = keyword
                      meta_info.search_engin = "yahoo"
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

                      #h1
                      page.search("h1").each do |t,i|
                        if i == 0
                          meta_info.h1 << t.text
                        else
                          meta_info.h1 << ",,," + t.text
                        end
                      end

                      meta_info.save
                  end
              page = page.link_with(:text => "次へ>").href
              page = agent.get(page)
          end

#      rescue
#        redirect_to root_path
  end
end