module ScrumHelper

  def render_hours(hours, options = {})
    if hours.nil?
      ""
    else
      if hours.is_a?(Integer)
        text = ("%d" % hours) unless options[:ignore_zero] and hours == 0
      elsif hours.is_a?(Float)
        text = ("%g" % hours) unless options[:ignore_zero] and hours == 0.0
      else
        text = hours unless options[:ignore_zero] and (hours.blank? or (hours == "0"))
      end
      unless text.blank?
        text = "#{text} h"
        unless options[:link].nil?
          text = link_to(text, options[:link])
        end
        render :inline => "<span title=\"#{options[:title]}\">#{text}</span>"
      end
    end
  end

end
