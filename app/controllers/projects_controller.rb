require 'rubygems'
require 'nokogiri'
require 'open-uri'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  def index
    @projects = Array.new
    get_kickstarter_projects
    get_indiegogo_projects
  end

  private

    def get_kickstarter_projects
      
      kickstarter_projects = scrape_kickstarter
      kickstarter_projects.each do |project|
        kickstarter_project = Hash.new
        kickstarter_project[:source] = "Kickstarter"
        kickstarter_project[:title] = project.css(".bbcard_name strong a").text
        kickstarter_project[:pledged] = project.css(".project-stats .pledged strong .money").text
        kickstarter_project[:project_link] = "https://www.kickstarter.com/" + project.css(".project-thumbnail a").first.attr('href')
        @projects << kickstarter_project
      end
    end

    def scrape_kickstarter
      url = "https://www.kickstarter.com/discover/advanced?category_id=16&sort=most_funded#"
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

    def get_indiegogo_projects
      
      indiegogo_projects = scrape_indiegogo
      indiegogo_projects.each do |project|
        indiegogo_project = Hash.new
        indiegogo_project[:source] = "Indiegogo"
        indiegogo_project[:title] = project.css(".project-details .name").text
        indiegogo_project[:pledged] = project.css("#project-stats-funding-amt .currency").text
        indiegogo_project[:project_link] = "http://www.indiegogo.com/" + project.css(".image a").first.attr('href')
        @projects << indiegogo_project
      end

    end

    def scrape_indiegogo
      indiegogo = "http://www.indiegogo.com/projects?filter_category=Technology&filter_country=CTRY_CA&filter_quick=most_funded"
      indiegogo_page = Nokogiri::HTML(open(indiegogo))
      indiegogo_projects = indiegogo_page.css("html 
      .indiegogo-main 
      .content .container.clearfix 
      .fr .browse-results 
      .badges.clearfix 
      .fl.badge.rounded.shadow")
    end
end
