require "open-uri"

class TopController < ApplicationController

  def index
    @search_word = MetaInfo.uniq.pluck(:search_word)
  end

  def test
    @csv = MetaInfo.where(search_word: params[:word])
    #特定のカラムがユニークなのだけ抽出
    if params[:uniq].present?
      @csv = MetaInfo.all.to_a.uniq{|meta_info| meta_info.title}
    end
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

              begin
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
                  link.css("h1").each_with_index do |t,i|
                    if i == 0
                      meta_info.h1 = t.text
                    else
                      meta_info.h1 << "      &&      " + t.text
                    end
                  end

                rescue OpenURI::HTTPError => e
                  if e.message == '404 Not Found'
                    meta_info.error_page = '404 Not Found'
                  else
                    raise e
                  end
                end

              meta_info.save
            end
          page = page.link_with(:text => "次へ").click
        end
      rescue
        redirect_to root_path
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

                      begin
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
                          link.css("h1").each_with_index do |t,i|
                            if i == 0
                              meta_info.h1 = t.text
                            else
                              meta_info.h1 << ",,," + t.text
                            end
                          end
                      rescue OpenURI::HTTPError => e
                          if e.message == '404 Not Found'
                            meta_info.error_page = '404 Not Found'
                          else
                            raise e
                          end
                      end
                      #
                      meta_info.save
                  end

#next_pageがない場合、10回同じurlをリロードしてなければbreak、あれば続ける
#next_pageを読み込んだ場合、うまく表示されない場合は同じurlを再度10回リロード
#この場合だと、検索結果2件の時とかまずい。10個目でやるべき
              unless page.link_with(:text => "次へ>").present?

                i = 0
                info = MetaInfo.select("link_address").pluck(:link_address)
                while i <= 10 do
                  page = agent.get(page.uri.to_s)
                    if  page.link_with(:text => "次へ>").present?
                      next_page = page.link_with(:text => "次へ>").href
                      test = agent.get(next_page)
                      href = test.search('.hd h3 a')[0].attribute("href").value

                      c = 0
                      while  true
                        if test.search('.hd h3 a')[9].attribute("href").value.present?
                          break
                        end
                        c += 1

                        test = agent.get(next_page)
                        href = test.search('.hd h3 a')[0].attribute("href").value

                        if info.include?(href)
                          test = agent.get(next_page)
                          href = test.search('.hd h3 a')[0].attribute("href").value
                        else
                          break
                        end

                        if c >= 10
                          break
                        end
                      end
                      page = test
                    end

                    if test.search('.hd h3 a')[9].attribute("href").value.present?
                      page = test
                          break
                    end

                  i += 1
                end
              else
                next_page = page.link_with(:text => "次へ>").href
                page = agent.get(next_page)
              end
          end
  end

  def search_by_link
    meta_infos = MetaInfo.where(search_word: nil)
    meta_infos.each do |meta_info|
      meta_info.search_word = "なし"
      meta_info.search_engin = "直接検索"

      begin
        agent = Mechanize.new
        agent.user_agent_alias = 'Windows Mozilla'
        # Mechanizeは便利なUAのエイリアスがあるので、その中から設定が簡単です。
        ua = "Mozilla/5.0 (Windows NT 10.0; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/47.0.2526.106 Safari/537.36"
        agent.user_agent = ua
        agent.open_timeout = 1800

        page = agent.get("#{meta_info.link_address}")
        #title
        meta_info.title = page.title
        #description
        if page.search('meta[@name="description"]').present?
          meta_info.description = page.search('meta[@name="description"]').attribute("content").value
        elsif page.search('meta[@name="Description"]').present?
          meta_info.description = page.search('meta[@name="Description"]').attribute("content").value
        end
        #keywords
        if page.search('meta[@name="keywords"]').present?
          meta_info.keywords = page.search('meta[@name="keywords"]').attribute("content").value
        elsif page.search('meta[@name="Keywords"]').present?
          meta_info.keywords = page.search('meta[@name="Keywords"]').attribute("content").value
        end
        #h1
        page.search('h1').each_with_index do |t,i|
          if i == 0
            meta_info.h1 = t.text
          else
            meta_info.h1 << "     &&&     " + t.text
          end
        end

      rescue OpenURI::HTTPError => e
        redirect_to root_path
      end
      meta_info.save
    end
    redirect_to root_path
  end


  def import
    MetaInfo.import(params[:file])
    redirect_to root_path
  end

  def delete
    Metainfo.delete.all
  end

  def downroad_templete
    @csv = Templete.all
    #CSVダウンロード
    respond_to do |format|
      format.html and return
      format.csv do
        send_data render_to_string, filename: "products-#{Time.now.to_date.to_s}.csv", type: :csv
      end
    end
  end


private

  def open_uri_error_retry(&nokogiri_process)
    retry_count = 0
    begin
      result = yield
    rescue OpenURI::HTTPError, Errno::ECONNRESET, Errno::ETIMEDOUT => ex
      if retry_count <= 5
        log.error "#{ex.message} retry..."
        sleep 1
        retry
      else
        log.error ex.message
      end
    rescue => ex
      log.error ex
    end
    result
  end

end