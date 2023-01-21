# frozen_string_literal: true

module Nauvisian
  class Mod
    Release = Data.define(:mod, :download_url, :file_name, :released_at, :version, :sha1)

    class Release
      class << self
        private :new
      end
    end
  end
end
