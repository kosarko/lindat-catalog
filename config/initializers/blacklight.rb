# frozen_string_literal: true

Rails.application.reloader.to_prepare do
  # -1, last, is join; insert before that
  unless Blacklight::Rendering::Pipeline.operations[-2] == Blacklight::Rendering::Linkify
    Blacklight::Rendering::Pipeline.operations.insert(-2, Blacklight::Rendering::Linkify)
  end
end
