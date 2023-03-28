class Feature
  FEATURE_PREFIX = 'FEATURE_'
  def self.enabled?(feature)
    ENV[FEATURE_PREFIX + feature.to_s.upcase]
  end
end