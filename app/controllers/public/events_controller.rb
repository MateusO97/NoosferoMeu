class EventsController < PublicController

  needs_profile
  before_filter :allow_access_to_page
  before_filter :load_events

  def events
    events_in_range = profile.events.by_range((@date - 1.month).at_beginning_of_month .. (@date + 1.month).at_end_of_month)
    @calendar = populate_calendar(@date, events_in_range)
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
  end

  def events_by_date
    @events = @events.paginate(:per_page => per_page, :page => params[:page])
    render :partial => 'events', locals: { xhr_links: true }
  end

  protected

  include EventsHelper

  def per_page
    20
  end

  def load_events
    begin
      @date = build_date params[:year], params[:month], params[:day]
    rescue ArgumentError # invalid date
      return render_not_found
    end

    if params[:year] && params[:month] && params[:day]
      @events = profile.events.by_day(@date)
    else
      @events = profile.events.by_month(@date)
    end
  end
end
