# frozen_string_literal: true

require "rspec/expectations"

module HashHelpers
  def self.normalize(actual)
    actual.with_indifferent_access
  end

  def self.missing_attributes(actual, expected)
    missing_keys = missing_keys(actual, expected)
    expected = normalize(expected)
    actual = normalize(actual)
    different_values = expected.reject { |key| actual[key] == expected[key] }

    {
        missing: missing_keys,
        different_values: different_values,
        are_equal: (missing_keys.empty? && different_values.empty?)
    }
  end

  def self.missing_keys(actual, expected)
    actual = normalize(actual)
    expected.reject { |key| actual.key?(key) }
  end
end

RSpec::Matchers.define :have_default_value do |attribute, value|
  match do |actual|
    actual.public_send(attribute) == value
  end
end

RSpec::Matchers.define :have_sorting_on do |attr, dir = :asc|
  match do |list|
    comp_asc = lambda { |pair| pair[0] < pair[1] }
    comp_desc = lambda { |pair| pair[0] > pair[1] }
    comparator = dir == :asc ? comp_asc : comp_desc

    list.map(&attr).each_cons(2).inject(true) do |matches, items|
      matches && comparator.call(items)
    end
  end
end

RSpec::Matchers.define :contain_keys do |expected|
  match do |actual|
    HashHelpers.missing_keys(actual, expected).blank?
  end

  failure_message do |actual|
    "Expected that #{actual} include all of #{expected} but differed: #{HashHelpers.missing_keys(actual, expected)}"
  end
end

RSpec::Matchers.define :contain_hash_values do |expected|
  match do |actual|
    HashHelpers.missing_attributes(actual, expected)[:are_equal]
  end

  failure_message do |actual|
    "Expected that #{actual} include all of #{expected} but differed: #{HashHelpers.missing_attributes(actual, expected)}"
  end
end

RSpec::Matchers.define :have_sorting do |dir = :asc|
  match do |list|
    comp_asc = lambda { |pair| pair[0] < pair[1] }
    comp_desc = lambda { |pair| pair[0] > pair[1] }
    comparator = dir == :asc ? comp_asc : comp_desc

    list.each_cons(2).inject(true) do |matches, items|
      matches && comparator.call(items)
    end
  end
end
