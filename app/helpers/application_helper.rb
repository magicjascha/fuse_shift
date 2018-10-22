require 'hasher'

module ApplicationHelper
  include Hasher
  include RegistrationsHelper
  
  def locale_link(locale_key)
    namespace = locale_key.split('.')[0]
    link = locale_key.split('.')[1]
    link_to(I18n.t("#{namespace}.#{link}_text"),I18n.t("#{namespace}.#{link}"))
  end
  
#   def festival_start
#     
#   end
end
