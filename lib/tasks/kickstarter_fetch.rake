desc "Parse Kickstarter site for technology projects"
task :fetch_projects => :environment do
  require 'nokogiri'
  require 'open-uri'

  url = "https://www.kickstarter.com/discover/advanced?category_id=16&sort=most_funded"
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

  record = Hash.new
  kickstarter_projects.each do |project|
    record[:title] = project.css(".bbcard_name strong a").text
    record[:pledged] = project.css(".project-stats .pledged strong .money.usd.no-code").text
    record[:funded] = project.css(".project-stats .first.funded").text
    @project = Project.new(record)
    @project.save
  end

end