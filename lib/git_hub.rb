require "octokit"

class GitHub
  def initialize(repository:, milestone:)
    @repository = repository
    @milestone_title = milestone
    @client ||= Octokit::Client.new(access_token: ENV["GITHUB_ACCESS_TOKEN"])
  end

  def exist_milestone?
    milestone != nil
  end

  def all_issues_closed?
    milestone[:open_issues] == 0
  end

  def all_issues_labeled?
    milestone_issues.map { |issue| issue[:labels].map { |label| label[:name] } }
                    .all? { |label_list| label_list.include?("accepted") &&
                                        (label_list.include?("approved") ||
                                         label_list.include?("confirmed")) }
  end

  def missing_tag?
    @client.tags(@repository).none? { |tag| tag[:name] == @milestone_title }
  end

  def required_checks_pass?
    @client.check_runs_for_ref(@repository, default_branch)
           .check_runs.select { |check| required_status_checks.include?(check[:name]) }
           .all? { |check| check[:status] == "completed" && check[:conclusion] == "success" }
  end

  private

  def milestone
    @milestone ||= @client.milestones(@repository, state: "all")
                             .detect { |milestone| milestone[:title] == @milestone_title }
  end

  def milestone_issues
    @client.issues(@repository, milestone: milestone[:number], state: "all")
  end

  def required_status_checks
    protection = @client.branch_protection(@repository, default_branch)

    if protection
      protection[:required_status_checks][:contexts]
    else
      @client.get("repos/#{@repository}/rules/branches/#{default_branch}")
             .select { |rule| rule[:type] = "required_status_checks" }
             .flat_map { |rule| rule.dig(:parameters, :required_status_checks) }
             .compact!
             .map { |check| check[:context] }
    end
  end

  def default_branch
    @default_branch ||= @client.repository(@repository)[:default_branch]
  end
end
