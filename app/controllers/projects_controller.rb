require 'rubygems'
require 'nokogiri'
require 'open-uri'

class ProjectsController < ApplicationController
  before_action :set_project, only: [:show, :edit, :update, :destroy]

  # GET /projects
  # GET /projects.json
  # def index
  #   @projects = Project.all
  # end

  def index
    @projects = Array.new
    get_kickstarter_projects
    get_indiegogo_projects
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
  end

  # GET /projects/new
  def new
    @project = Project.new
  end

  # GET /projects/1/edit
  def edit
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = Project.new(project_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render action: 'show', status: :created, location: @project }
      else
        format.html { render action: 'new' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /projects/1
  # PATCH/PUT /projects/1.json
  def update
    respond_to do |format|
      if @project.update(project_params)
        format.html { redirect_to @project, notice: 'Project was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project.destroy
    respond_to do |format|
      format.html { redirect_to projects_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_project
      @project = Project.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def project_params
      params[:project]
    end

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
        indiegogo_project[:link] = "http://www.indiegogo.com/" + project.css(".image a").first.attr('href')
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
