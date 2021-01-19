# frozen_string_literal: true

require 'builder'

# This module exposes xml stored in original_metadata_ss
module Blacklight::Document::OriginalMetadata
  def self.extended(document)
    # Register our exportable formats
    document.will_export_as(:xml)
  end

  def export_as_xml
    self[:original_metadata_ss]
  end

end
