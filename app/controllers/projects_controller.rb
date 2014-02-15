require 'rubygems'
require 'nokogiri'
require 'open-uri'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def most_funded
    @projects = Array.new
    get_kickstarter_projects("most_funded")
    get_indiegogo_projects("most_funded")
  end

  def most_popular
    @projects = Array.new
    get_kickstarter_projects("popularity")
    get_indiegogo_projects("popular_all")
  end

  private

    def get_kickstarter_projects(sort)
      
      kickstarter_projects = scrape_kickstarter(sort)
      kickstarter_projects.each do |project|
        kickstarter_project = Hash.new
        kickstarter_project[:source] = "Kickstarter"
        kickstarter_project[:title] = project.css(".bbcard_name strong a").text
        kickstarter_project[:pledged] = project.css(".project-stats .pledged strong .money").text
        kickstarter_project[:location] = project.css(".project-meta li .location-name").text || "No location provided"
        kickstarter_project[:project_link] = "https://www.kickstarter.com" + project.css(".project-thumbnail a").first.attr('href')
        @projects << kickstarter_project
      end
    end

    def scrape_kickstarter(sort)
      url = "https://www.kickstarter.com/discover/advanced?category_id=16&sort=#{sort}"
      page = Nokogiri::HTML(open(url))
      kickstarter_projects = page.css("html 
      #discover_advanced 
      #main_content
      #advanced_container 
      #projects 
      .container 
      #projects_list.clearfix.list-simple 
      .project.grid_4 
      .project-card-wrap 
      .project-card")
    end

    def get_indiegogo_projects(sort)
      
      indiegogo_projects = scrape_indiegogo(sort)
      indiegogo_projects.each do |project|
        indiegogo_project = Hash.new
        indiegogo_project[:source] = "Indiegogo"
        indiegogo_project[:title] = project.css(".project-details .name").text
        indiegogo_project[:pledged] = project.css("#project-stats-funding-amt .currency").text
        indiegogo_project[:location] = project.css(".project-details .location #project_location").text || "No location provided"
        indiegogo_project[:project_link] = "http://www.indiegogo.com" + project.css(".image a").first.attr('href')
        @projects << indiegogo_project
      end

    end

    def scrape_indiegogo(sort)
      indiegogo = "http://www.indiegogo.com/projects?filter_category=Technology&filter_country=CTRY_CA&filter_quick=#{sort}"
      indiegogo_page = Nokogiri::HTML(open(indiegogo))
      indiegogo_projects = indiegogo_page.css("html 
      .indiegogo-main 
      .content .container.clearfix 
      .fr .browse-results 
      .badges.clearfix 
      .fl.badge.rounded.shadow")
    end
end
