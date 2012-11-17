require 'active_record'

require 'activerecord-denormalize/version'
require 'active_record/denormalize'

class ActiveRecord::Associations::Builder::HasMany
  include ActiveRecord::Denormalize
end
