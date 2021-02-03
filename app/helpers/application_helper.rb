module ApplicationHelper

  include ActionView::Helpers::TagHelper
  include Blacklight::IconHelperBehavior

  def linkify(val)
    return val unless val.start_with?('http')

    tag.a(val, href: val) + blacklight_icon('fa_cc_by_4.0_international/external-link-alt-solid')

  end
end
