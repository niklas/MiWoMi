require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

require 'active_support/inflector'
require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/class/attribute'

$: << File.expand_path('..', __FILE__)

module Miwomi
  autoload :NamedThing , 'miwomi/named_thing'
  autoload :Block      , 'miwomi/block'
  autoload :Item       , 'miwomi/item'
  autoload :Patch      , 'miwomi/patch'
  autoload :Finder     , 'miwomi/finder'
  autoload :Matcher    , 'miwomi/matcher'

  autoload :Collection , 'miwomi/collection'

  autoload :Parser     , 'miwomi/parser'
  autoload :CsvParser  , 'miwomi/csv_parser'
  autoload :DumpParser , 'miwomi/dump_parser'
  # Work in Progress
  autoload :FileLandscape, 'miwomi/file_landscape'

  autoload :Logger, 'miwomi/logger'
end
