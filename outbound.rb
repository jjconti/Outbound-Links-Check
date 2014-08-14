#!/usr/bin/env ruby

require 'anemone'
require 'nokogiri'
require 'open-uri'

require 'uri'

class Outbound
  
  def head
    return "<html>
	    <head>
	      <title>Domain Outbound Links Check</title>
	    </head>
	    <body><h1>Domain Outbound Links Check</h1>"
  end

  def footer
    return "</body>
	    </html>"
  end  
  
  def resume (url)
    unless url.empty?
      html = nil
      hostname = URI(url)
      Anemone.crawl(url) do |anemone|
	anemone.on_every_page do |page|
	  if page.url.to_s.include? hostname.host.to_s and page.url.to_s.include? "http://"
	      html = "<h2>#{page.url}</h2>"
	      
	      begin
		body = Nokogiri::HTML(open(page.url))
		
		html = html + '<ul>'
		body.css("body a").map do |link|
		  unless link['href'].to_s.include? hostname.host.to_s
		    if link['href'].to_s.include? "http"
		      html = html + "<li>#{link['href']}</li>"
		    end
		  end
		end
		html = html + '</ul>'
	      rescue OpenURI::HTTPError => error
		response = error.io
		html = html + "<li>#{page.url} - #{response.status}</li>"
	      end
	      end
	end
      end
      
    end
    return self.head + html + self.footer
  end
  
end

link = Outbound.new

file = File.open "log_001.html", "w"
file.write link.resume ARGV[0]