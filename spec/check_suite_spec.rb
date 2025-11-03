ENV["GITHUB_REPOSITORY"] = "inforlife/existing-repo"

require "lib/check_suite"

RSpec.describe CheckSuite do
  before do
    # Avoid to print outputs when running the specs
    allow(STDOUT).to receive(:puts)
  end

  context "when the milestone does not exist" do
    before do
      ENV["GITHUB_MILESTONE"] = "2017.0"
    end

    it "returns a feedback message" do
      VCR.use_cassette("inexisting_milestone") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/milestone 2017.0 does not exist/i).to_stdout
      end
    end

    it "exits with status 1" do
      VCR.use_cassette("inexisting_milestone") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when the milestone has still at least an open issue" do
    before do
      ENV["GITHUB_MILESTONE"] = "2017.2"
    end

    it "returns a feedback message" do
      VCR.use_cassette("open_issue") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/at least an issue is still open/i).to_stdout
      end
    end

    it "exits with status 1" do
      VCR.use_cassette("open_issue") do
         expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when not all the issues included in the milestone has the expected labels" do
    before do
      ENV["GITHUB_MILESTONE"] = "2018.1"
    end

    it "returns a feedback message" do
      VCR.use_cassette("unlabeled_issue") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/at least an issue doesn't have the required labels/i).to_stdout
      end
    end

    it "exits with status 1" do
      VCR.use_cassette("unlabeled_issue") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when tag exists already" do
    before do
      ENV["GITHUB_MILESTONE"] = "2017.1"
    end

    it "returns a feedback message" do
      VCR.use_cassette("existing_tag") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/tag 2017.1 already exists/i).to_stdout
      end
    end

    it "exits with status 1" do
      VCR.use_cassette("existing_tag") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when at least a required status check did not pass" do
    before do
      ENV["GITHUB_MILESTONE"] = "2021.1"
    end

     it "returns a feedback message" do
      VCR.use_cassette("failed_check") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/at least a required check didn't pass during the last run on the default branch/i).to_stdout
      end
    end

    it "exits with status 1" do
      VCR.use_cassette("failed_check") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(1)
        end
      end
    end
  end

  context "when all the checks pass" do
    before do
      ENV["GITHUB_MILESTONE"] = "2021.1"
    end

    it "returns a feedback message" do
      VCR.use_cassette("drafted_release") do
        allow_any_instance_of(CheckSuite).to receive(:exit)

        expect { CheckSuite.new.run }.to output(/all checks passed. 2021.1 can be released/i).to_stdout
      end
    end

    it "exits with status 0" do
      VCR.use_cassette("drafted_release") do
        expect { CheckSuite.new.run }.to raise_error(SystemExit) do |error|
          expect(error.status).to eq(0)
        end
      end
    end
  end
end
