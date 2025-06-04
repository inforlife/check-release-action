ENV["GITHUB_REPOSITORY"] = "inforlife/existing-repo"
ENV["GITHUB_ACCESS_TOKEN"] = "dummy"

require "lib/check_suite"

RSpec.describe CheckSuite do
  before do
    # Avoid to print outputs when running the specs
    allow(STDOUT).to receive(:puts)
  end

  context "when milestone does not exist" do
    it "exits with status 1" do
      ENV["GITHUB_MILESTONE"] = "2017.0"

      VCR.use_cassette("inexisting_milestone") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when milestone has still at least an open issue" do
    it "exits with status 1" do
      ENV["GITHUB_MILESTONE"] = "2017.2"

      VCR.use_cassette("open_issue") do
         expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when not all the issues included in milestone has the expected labels" do
    it "exits with status 1" do
      ENV["GITHUB_MILESTONE"] = "2018.1"

      VCR.use_cassette("unlabeled_issue") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when tag exists already" do
    it "exits with status 1" do
      ENV["GITHUB_MILESTONE"] = "2017.1"

      VCR.use_cassette("existing_tag") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when at least a required status check did not pass" do
    it "exits with status 1" do
      ENV["GITHUB_MILESTONE"] = "2021.1"

      VCR.use_cassette("failed_check") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when all the checks pass" do
    ENV["GITHUB_MILESTONE"] = "2021.1"

    it "exits with status 0" do
      VCR.use_cassette("drafted_release") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end
  end
end
