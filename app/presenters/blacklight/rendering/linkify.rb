# frozen_string_literal: true

module Blacklight
  module Rendering
    class Linkify < Blacklight::Rendering::AbstractStep
      include ActionView::Helpers::TagHelper
      def render
        return next_step(values) unless config.linkify == true

        next_step(values.map { |x| linkify(x) })
      end

      private

      def linkify(val)
        return val unless val.start_with?('http')

        tag.a val, href: val
      end
    end
  end
end
