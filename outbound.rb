#!/usr/bin/env ruby

require 'anemone'
require 'nokogiri'
require 'open-uri'

require 'uri'

class Outbound
  def resume (url)
    unless url.empty?
      hostname = URI(url)
      Anemone.crawl(url) do |anemone|
	anemone.on_every_page do |page|
	  if page.url.to_s.include? hostname.host.to_s and page.url.to_s.include? "http://"
	      puts "<h1>#{page.url}</h1>"
	      
	      begin
		body = Nokogiri::HTML(open(page.url))
		
		puts '<ul>'
		body.css("body a").map do |link|
		  unless link['href'].to_s.include? hostname.host.to_s
		    if link['href'].to_s.include? "http"
		      puts "<li>#{link['href']}</li>"
		    end
		  end
		end
		puts '</ul>'
	      rescue OpenURI::HTTPError => error
		response = error.io
		puts "<li>#{page.url} - #{response.status}</li>"
	      end
	      end
	end
      end
      
    end
  end
end

link = Outbound.new
link.resume ARGV[0]