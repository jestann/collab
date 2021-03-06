class WikisController < ApplicationController
  before_action :authenticate_user!, except: [:index, :show]
  before_action :authorize_user
  
  def index
    @wikis = policy_scope(Wiki)
    # strip markdown
    @stripper = Redcarpet::Markdown.new(Redcarpet::Render::StripDown)
  end

  def show
    @wiki = Wiki.find(params[:id])
    # render markdown
    @markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML, extensions = {
      fenced_code_blocks: true, 
      disable_indented_code_blocks: true,
      underline: true, 
      highlight: true, 
      strikethrough: true
    })
  end

  def new
    @wiki = Wiki.new
  end

  def create
    @wiki = Wiki.new(wiki_params_create)
    @wiki.user = current_user

    if @wiki.save
      flash[:notice] = "Space was saved."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the space. Please try again."
      render :new
    end
  end

  def edit
    @wiki = Wiki.find(params[:id])
  end
  
  def update
    @wiki = Wiki.find(params[:id])
    @wiki.assign_attributes(wiki_params_update)

    if @wiki.save
      flash[:notice] = "Space was updated."
      redirect_to @wiki
    else
      flash.now[:alert] = "There was an error saving the space. Please try again."
      render :edit
    end
  end
  
  def destroy
    @wiki = Wiki.find(params[:id])
    
    if @wiki.destroy
      flash[:notice] = "\"#{@wiki.title}\" was deleted successfully."
      redirect_to wikis_path
    else
      flash.now[:alert] = "There was an error deleting the space."
      render :show
    end
  end


  private
  
  def wiki_params_create
    params.require(:wiki).permit(policy(Wiki).permitted_attributes_for_create)
  end
  
  def wiki_params_update
    params.require(:wiki).permit(policy(@wiki).permitted_attributes_for_update)
  end
    
  def authorize_user
    if (wiki_id = params[:id])
      wiki = Wiki.find(wiki_id)
      authorize wiki
    else
      authorize Wiki # authorize Class instance
    end
  end
  
end