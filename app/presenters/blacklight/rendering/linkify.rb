# frozen_string_literal: true

module Blacklight
  module Rendering
    class Linkify < Blacklight::Rendering::AbstractStep
      include ApplicationHelper
      def render
        return next_step(values) unless config.linkify == true

        next_step(values.map { |x| linkify(x) })
      end
    end
  end
end
