class TagImplicationsController < ApplicationController
  before_filter :admin_only, :only => [:new, :create, :approve]
  respond_to :html, :xml, :json, :js

  def show
    @tag_implication = TagImplication.find(params[:id])
    respond_with(@tag_implication)
  end

  def edit
    @tag_implication = TagImplication.find(params[:id])
  end

  def update
    @tag_implication = TagImplication.find(params[:id])

    if @tag_implication.is_pending? && @tag_implication.editable_by?(CurrentUser.user)
      @tag_implication.update_attributes(params[:tag_implication])
    end

    respond_with(@tag_implication)
  end

  def index
    @search = TagImplication.search(params[:search])
    @tag_implications = @search.order("(case status when 'pending' then 1 when 'queued' then 2 when 'active' then 3 else 0 end), antecedent_name, consequent_name").paginate(params[:page], :limit => params[:limit])
    respond_with(@tag_implications) do |format|
      format.xml do
        render :xml => @tag_implications.to_xml(:root => "tag-implications")
      end
    end
  end

  def destroy
    @tag_implication = TagImplication.find(params[:id])
    if @tag_implication.deletable_by?(CurrentUser.user)
      @tag_implication.reject!
      respond_with(@tag_implication) do |format|
        format.html do
          flash[:notice] = "Tag implication was deleted"
          redirect_to(tag_implications_path)
        end
      end
    else
      access_denied
    end
  end

  def approve
    @tag_implication = TagImplication.find(params[:id])
    @tag_implication.update_column(:status, "queued")
    @tag_implication.delay(:queue => "default").process!
    respond_with(@tag_implication, :location => tag_implication_path(@tag_implication))
  end
end
