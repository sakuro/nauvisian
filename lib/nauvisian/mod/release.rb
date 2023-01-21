# frozen_string_literal: true

module Nauvisian
  class Mod
    Release = Data.define(:download_url, :file_name, :released_at, :version, :sha1) # rubocop:disable Style/ConstantVisibility

    class Release
      class << self
        private :new
      end
    end
  end
end