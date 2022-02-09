# frozen_string_literal: true

module Blacklight
  class PrefixSearch < ::ViewComponent::Base
    def initialize(facet_field_presenter:)
      @facet_field_presenter = facet_field_presenter
    end

    delegate :in_modal?, :modal_path, :paginator, :search_state, to: :@facet_field_presenter

    def render?
      if @facet_field_presenter.facet_field.prefix_search == true
        unless in_modal?
          return !modal_path.blank?
        end
        true
      end
    end

    def action
      if in_modal?
        paginator.params_for_resort_url(paginator.sort, search_state.to_h.except(name))
      else
        modal_path
      end
    end

    def name
      paginator.request_keys[:prefix]
    end

    def value
      search_state.to_h[name] || ''
    end

    def clear_prefix_url
      paginator.params_for_resort_url(paginator.sort, search_state.to_h.except(paginator.request_keys[:prefix]))
    end
  end
end
