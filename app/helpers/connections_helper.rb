module ConnectionsHelper

  def connections
    @suggestion = profile.suggested_profiles.of_community.enabled.find_by(suggestion_id: params[:id])
    if @suggestion
      @tags = @suggestion.tag_connections
      @profiles = @suggestion.profile_connections
    else
      redirect_to :action => 'suggest'
    end
  end
