# frozen_string_literal: true

require "rails_helper"

RSpec.describe PolicyTerm, type: :model do
  let(:term) { create(:policy_term, version_date: 1.year.ago) }

  describe "reject version_date if difference is less than 60 seconds" do
    let(:version_date) { term.version_date }
    it "will not change version date if change is less than 1 minute" do
      term.version_date = version_date + 59.seconds
      expect(term).to be_valid
      term.save
      expect(term.version_date).to eq version_date
    end

    it "will not change version date if change is less than 1 minute in the past" do
      term.version_date = version_date - 59.seconds
      expect(term).to be_valid
      term.save
      expect(term.version_date).to eq version_date
    end

    it "Will update the version date if it is set 60 seconds or more later" do
      term.version_date = version_date + 60.seconds
      expect(term).to be_valid
      term.save
      expect(term.version_date).to eq version_date + 60.seconds
    end
  end

  describe "set older version date" do
    let(:user) { create(:user) }
    let(:term_acceptance) { create(:term_acceptance, policy_term: term, created_at: 2.months.ago, user: user) }
    let(:term_acceptance2) { create(:term_acceptance, policy_term: term, created_at: 3.months.ago, user: user) }

    context "without changing version date" do
      it "is possible to apply changes" do
        expect(term.update(description: "new text")).to be_truthy
      end
    end

    it "must not be possible to set a version date older than the newest acceptance date" do
      term.version_date = term_acceptance.created_at
      expect(term).not_to be_valid, lambda { "Term Version date: #{term.version_date},
Latest acceptance date: #{term.last_known_acceptance_date},
Diff: #{term.version_date.to_f - term.last_known_acceptance_date.to_f},
New Record: #{term.new_record?},
Date Changed: #{term.version_date_changed?},
Expression Result: #{term.last_known_acceptance_date >= term.version_date}" }
    end

    it "is possible to set a version date that is bigger than the latest term acceptance" do
      term.version_date = term_acceptance.created_at + 1.second
      expect(term).to be_valid
    end
  end

end
