require 'miwomi'
require 'rspec/matchers'
require 'diff_matcher'

module RSpec
  module Matchers
    class BeMatching
      attr_reader :expected

      def initialize(expected, opts)
        @expected = expected
        @opts = opts.update(:color_enabled=>RSpec::configuration.color_enabled?)
      end

      def matches?(actual)
        @difference = DiffMatcher::Difference.new(expected, actual, @opts)
        @difference.matching?
      end

      def failure_message_for_should
        @difference.to_s
      end
    end

    def be_hash_matching(expected, opts={})
      Matchers::BeMatching.new(expected, opts)
    end

    def be_hash_matching_partially(expected, opts={})
      Matchers::BeMatching.new(expected, opts.merge(ignore_additional: true))
    end
  end
end

module StubbedFactorySpecHelpers
  def thing(id=nil, attrs={})
    if id.is_a?(Hash)
      attrs = id
      id = nil
    end
    double('NamedThing', {id: id || attrs.object_id, to_s: id}.merge(attrs))
  end

  def collection(*list)
    Miwomi::Collection.new(list)
  end

  def finder(attrs={})
    double('Finder', {weight: 1, internal_name_with_weight: 'hihi:23'}.merge(attrs))
  end
end

RSpec.configure do |config|
  config.before :each do
    Miwomi::Finder.undefine_all
  end

  config.include StubbedFactorySpecHelpers
end
