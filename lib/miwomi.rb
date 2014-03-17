require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path('..', __FILE__)

module Miwomi
  autoload :NamedThing , 'miwomi/named_thing'
  autoload :Block      , 'miwomi/block'
  autoload :Item       , 'miwomi/item'
  autoload :Patch      , 'miwomi/patch'
  # Work in Progress
  autoload :FileLandscape, 'miwomi/file_landscape'
end
