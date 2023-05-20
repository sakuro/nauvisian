# frozen_string_literal: true

module Nauvisian
  module CLI
    module MessageHelper
      private def message(exception_or_message)
        case exception_or_message
        in Exception
          puts exception_or_message.message
        in String
          puts exception_or_message
        else
          raise TypeError, "must be Exception or String: %p" % message_or_exception
        end
      end
    end
  end
end
