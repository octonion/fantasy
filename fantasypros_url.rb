#!/usr/bin/env ruby
# coding: utf-8

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://www.fantasypros.com/nfl/players/"

positions = Hash.new
positions["RB"]="rb.php"
positions["WR"]="wr.php"
positions["K"]="k.php"
positions["QB"]="qb.php"
positions["TE"]="te.php"

year = 2011
week = 8
out = CSV.open("fantasypros_url.csv","w")

positions.each do |position|

  plays = position[0]
  u = position[1]
  url = "#{base}/#{u}"

  begin
    page = agent.get(url)
  rescue
    retry
  end

  page.parser.xpath("//a").each do |e|
    href = e.attribute("href")
    name = e.inner_text
    if not(href.to_s.include?("php"))
      next
    end
    if not(href.to_s.include?("-"))
      next
    end
    out << [plays,href,name]
  end
end
