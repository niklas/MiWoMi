require 'rubygems'
require 'bundler/setup'
Bundler.require(:default)

$: << File.expand_path('..', __FILE__)

module Miwomi
  autoload :FileLandscape, 'miwomi/file_landscape'
end
