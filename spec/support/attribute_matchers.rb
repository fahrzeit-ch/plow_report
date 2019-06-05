require 'rspec/expectations'

module HashHelpers
  def self.missing_attributes(actual, expected)
    indiff_expected = expected.with_indifferent_access
    indiff_actual = actual.with_indifferent_access

    missing_keys = indiff_expected.reject { |key| indiff_actual.key?(key) }
    different_values = indiff_expected.reject { |key| indiff_actual[key] == indiff_expected[key] }

    {
        missing: missing_keys,
        different_values: different_values,
        are_equal: (missing_keys.empty? && different_values.empty?)
    }
  end
end

RSpec::Matchers.define :have_default_value do |attribute, value|
  match do |actual|
    actual.public_send(attribute) == value
  end
end

RSpec::Matchers.define :have_sorting_on do |attr, dir=:asc|
  match do |list|
    comp_asc = lambda { |pair| pair[0] < pair[1] }
    comp_desc = lambda { |pair| pair[0] > pair[1] }
    comparator = dir == :asc ? comp_asc : comp_desc

    list.map(&attr).each_cons(2).inject(true) do |matches, items|
      matches && comparator.call(items)
    end
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

RSpec::Matchers.define :have_sorting do |dir=:asc|
  match do |list|
    comp_asc = lambda { |pair| pair[0] < pair[1] }
    comp_desc = lambda { |pair| pair[0] > pair[1] }
    comparator = dir == :asc ? comp_asc : comp_desc

    list.each_cons(2).inject(true) do |matches, items|
      matches && comparator.call(items)
    end
  end
end