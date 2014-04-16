# Using betabuilder gem
# Build via 'rake beta:build'
# Deploy via 'rake beta:deploy'


require 'rubygems'
require 'betabuilder'
require 'rubygems/package_task'


BetaBuilder::Tasks.new do |config|
  config.auto_archive = true
  config.target = "dbldbl"
  config.configuration = "Adhoc"   
  config.xcode4_archive_mode = true

  # configure deployment via TestFlight
  config.deploy_using(:testflight) do |tf|
    tf.api_token  = "d4a64e6eace3509856a2c5313b15edae_MjQzNjU2MjAxMS0xMi0wOCAxMzoyOTo1Mi41NDA3Nzg" # Select "Account" on the top right of TestFlight, its at the bottom
    tf.team_token = "83bc629ff04f06008181d0d5c010e146_NzEwMzQyMDEyLTAzLTE5IDEyOjIzOjUyLjkxNDk0NQ" # Select "(edit)" beside current team on the top left of TestFlight
    # tf.distribution_lists = %w{Roos} # I've had issues with spaces in the name in the past
  end
end

# BetaBuilder::Tasks.new do |config|
#   config.auto_archive = true
#   config.target = "dbldbl" # This should be the same as your Product Name as well
#   config.configuration = "Ad hoc" # Release/ Debug / Ad Hoc, etc
#   config.xcode4_archive_mode = true

#   # configure deployment via TestFlight
  
    
#     # If you comment out the next 3 lines you will be prompted for release notes before uploading
#     #tf.generate_release_notes do
#     #	"Latest updates"
#     #end
    
#     # Uncomment this to automatically send notification emails to the members of your distribution list
#     # tf.notify = true
#   # end
# end



