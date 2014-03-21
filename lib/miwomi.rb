require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path('..', __FILE__)

module Miwomi
  autoload :NamedThing , 'miwomi/named_thing'
  autoload :Block      , 'miwomi/block'
  autoload :Item       , 'miwomi/item'
  autoload :Patch      , 'miwomi/patch'

  autoload :Collection , 'miwomi/collection'

  autoload :Parser     , 'miwomi/parser'
  autoload :CsvParser  , 'miwomi/csv_parser'
  autoload :DumpParser , 'miwomi/dump_parser'
  # Work in Progress
  autoload :FileLandscape, 'miwomi/file_landscape'
end
