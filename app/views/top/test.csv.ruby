require 'csv'
require 'nkf'

column_names = %w(id 検索ワード 検索エンジン リンクアドレス リンクテキスト title description keywords h1)

csv_str = CSV.generate do |csv|
  csv << column_names
  @csv.each do |meta|
    csv << [
    meta.id,
    meta.search_word,
    meta.search_engin,
    meta.link_address,
    meta.link_text,
    meta.title,
    meta.description,
    meta.keywords,
    meta.h1
    ]
  end
end

NKF::nkf('--sjis -Lw', csv_str)