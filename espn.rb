#!/usr/bin/env ruby
# coding: utf-8

bad = " "

bad2 = " "

require "csv"
require "mechanize"

agent = Mechanize.new{ |agent| agent.history.max_size=0 }
agent.user_agent = 'Mozilla/5.0'

base = "http://games.espn.go.com/ffl/leaders"

#options = "scoringPeriodId=17&seasonId=2010&startIndex=50"

#table_xpath = "/html/body/div/table/tbody/tr/td/div[2]/div/div/div/div[3]/div/div/div[2]/div[3]/div/table/tbody/tr/th"

#table_xpath = "/html/body/div/table/tr/td/div[2]/div/div/div[1]/div[3]/div/div/div[2]/div[3]/div/table/tr"

row_xpath = '//tr[starts-with(@id,"plyr")]'

first_week = 1
last_week = 3

first_year = 2014
last_year = 2014

pages = 10

(first_year..last_year).each do |year|

  out = CSV.open("#{year}.csv","w")

  (first_week..last_week).each do |week|

    found = 0
    print "ESPN Fantasy (#{year}/#{week})"

    (0..pages-1).each do |page|

      start = 50*page
      rk = start

      #scoringPeriodId=17&seasonId=2010&startIndex=50
      url = "#{base}?&scoringPeriodId=#{week}&seasonId=#{year}&startIndex=#{start}"

      begin
        page = agent.get(url)
      rescue
        retry
      end

      page.parser.xpath(row_xpath).each do |r|

        row = []

        r.xpath("td|th").each_with_index do |e,i|

          et = e.inner_text.strip
          eh = e.inner_html.strip

          #p et
          #p eh

          if (e==nil) or (et.size==0)
            next
          end

          et.gsub!(bad," ")

          if (i==1)
            next
          end

          if (i==0)
            #p et
            #p eh

            if (et =~ /D\/ST/)
              x = et.split(" ")
              row += x
            else
              x = et.split(",")
              name = x[0]
              #p x[1]
              y = x[1].strip.split(" ")
              team = y[0]
              position = y[1]
              row += [name,team,position]
            end
          else
            if (et.size==0)
              et = nil
            end
            row += [et]
          end

        end

        if (row.size > 0)
          rk += 1
          found += 1
          out << [year,week,rk]+row
        end

      end

    end
    print " - found #{found}\n"
  end
  out.close
end

