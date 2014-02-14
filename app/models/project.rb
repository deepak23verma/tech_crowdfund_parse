require 'rubygems'
require 'nokogiri'
require 'open-uri'

class Project < ActiveRecord::Base

def self.kickstarter_projects
  url = "https://www.kickstarter.com/discover/advanced?category_id=16&sort=most_funded#"
  page = Nokogiri::HTML(open(url))
  kickstarter_projects = page.css("html 
  #discover_advanced 
  #main_content list-simple
  #advanced_container 
  #projects 
  .container 
  #projects_list.clearfix.list-simple 
  .project.grid_4 
  .project-card-wrap 
  .project-card")

  kickstarter_projects.each do |project|
    record = Project.new
    record[:title] = project.css(".bbcard_name strong a").text
    record[:pledged] = project.css(".project-stats .pledged strong .money.usd.no-code").text
    record[:funded] = project.css(".project-stats .first.funded").text
    Project.new(params[:record])
  end
end

end
