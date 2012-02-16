require 'dispatcher'
require 'redmine'
require_dependency 'issue_status_patch'
require_dependency 'issue_patch'
#require_dependency File.dirname(__FILE__) + '/app/models/issue.rb'
#require_dependency 'lib/issue'

Redmine::Plugin.register :redmine_redmine_mutiple_start_issues do
  name 'Redmine Redmine Mutiple Start Issues plugin'
  author 'Tsirkin Evgeny'
  description 'Allow multiple start issue states'
  version '0.0.1'
  url 'http://example.com/path/to/plugin'
  author_url 'http://example.com/about'
end
Dispatcher.to_prepare do
  IssueStatus.send(:include, IssueStatusPatch)
  Issue.send(:include, IssuePatch)
end
