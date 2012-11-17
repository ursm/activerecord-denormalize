require 'bundler/setup'

$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
$LOAD_PATH.unshift File.dirname(__FILE__)

require 'rspec'
require 'rspec/autorun'

require 'active_record-denormalize'
