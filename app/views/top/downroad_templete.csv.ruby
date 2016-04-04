require 'csv'
require 'nkf'

column_names = %w(id サイト名 リンクアドレス)

csv_str = CSV.generate do |csv|
  csv << column_names
  @csv.each do |meta|
    csv << [
    meta.id,
    meta.search_word,
    meta.link_address
    ]
  end
end

NKF::nkf('--sjis -Lw', csv_str)