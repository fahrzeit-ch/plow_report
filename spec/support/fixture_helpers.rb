# frozen_string_literal: true

module FixtureHelpers
  # returns the absolute path to the given file.
  # Assumes file to be in fixtures folder.
  def file_path(file)
    Rails.root.join("spec/fixtures", file)
  end

  def file_upload_fixture(file)
    Rack::Test::UploadedFile.new(file_path(file))
  end
end
