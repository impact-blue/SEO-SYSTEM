class Scraping < ActiveRecord::Base
  def self.meta_info
    links = []
    agent = Mechanize.new
    next_url = "/now/"

    while true
      main_page = agent.get("http://eiga.com" + next_url)
      elements = main_page.search('.m_unit h3 a')
      elements.each do |ele|
        links << ele.get_attribute('href')
      end

      links.each do |link|
        get_product('http://eiga.com' + link)
      end

      next_link = main_page.at('.next_page')
      next_url = next_link.get_attribute('href')

      unless next_url
        break
      end
    end
  end

  def self.get_info(link)
    agent = Mechanize.new
    page = agent.get('https://www.google.co.jp/search?q=site:http://www.kangoworks.com/')
    elements = page.search('li a')
    title = page.at('.moveInfoBox h1').inner_text
    image_url = page.at('.pictBox img')[:src] if page.at('.pictBox img')

    product = MetaInfo.where(:search_word => link, :link_address => image_url).first_or_initialize
    product.save
  end

end



keyword = "site:http://www.kangoworks.com/"
escaped_keyword = CGI.escape(keyword)
# 検索結果を開く
doc = Nokogiri.HTML(open("http://www.google.co.jp/search?ie=UTF-8&oe=UTF-8&q=#{keyword}"))



# スクレイピング先のURL
url = 'https://www.google.co.jp/search?q=site:http://www.kangoworks.com/'

charset = nil
html = open(url) do |f|
  charset = f.charset # 文字種別を取得
  f.read # htmlを読み込んで変数htmlに渡す
end

# htmlをパース(解析)してオブジェクトを生成
doc = Nokogiri::HTML.parse(html, nil, charset)
doc = Nokogiri::HTML(open("http://www.google.com/search?q=site:http://www.kangoworks.com"))
# タイトルを表示
p doc.title