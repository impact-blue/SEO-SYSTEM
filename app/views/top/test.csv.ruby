require 'csv'
require 'nkf'

column_names = %w(id 検索ワード リンクアドレス リンクテキスト title description keywords)

csv_str = CSV.generate do |csv|
  csv << column_names
  @csv.each do |meta|
    csv << [
    meta.id,
    meta.search_word,
    meta.link_address,
    meta.link_text,
    meta.title,
    meta.description,
    meta.keywords
    ]
  end
end

NKF::nkf('--sjis -Lw', csv_str)