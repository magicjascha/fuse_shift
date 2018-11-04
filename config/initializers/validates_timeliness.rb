ValidatesTimeliness.setup do |config|
  # Extend ORM/ODMs for full support (:active_record, :mongoid).
#   config.extend_orms = [ :active_record ]
# 
#   # Re-display invalid values in date/time selects
#   config.enable_date_time_select_extension!
# 
#   # Handle multiparameter date/time values strictly
#   config.enable_multiparameter_extension!
# 
#   # Shorthand date and time symbols for restrictions
#   config.restriction_shorthand_symbols.update(
#      :now   => lambda { Time.current },
#      :today => lambda { Date.current }
#    )
  # Use the plugin date/time parser which is stricter and extendable
  config.use_plugin_parser = true
end