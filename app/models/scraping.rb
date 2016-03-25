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
    elements = page.at('.r a')
    title = page.at('.moveInfoBox h1').inner_text
    image_url = page.at('.pictBox img')[:src] if page.at('.pictBox img')

    product = Product.where(:title => title, :image_url => image_url).first_or_initialize
    product.save
  end

end
