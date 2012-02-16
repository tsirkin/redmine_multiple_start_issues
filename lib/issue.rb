require_dependency 'issue'

# Patches Redmine's Issues Status dynamically.  Adds a new method
# is_new that means that the issue status can be marked as new
# in tracker.
class Issue
  logger.debug "INCLUDIN ISSUE MONKEY"
  if after_initialize 
    logger.debug "MONKEY after_initialize"
    after_initialize.delete_if do
      |callback| callback.method == :after_initialize
    end
    after_initialize :after_initialize_patched
  end 
  
  def after_initialize_patched
    if new_record?
      # set default values for new records only
      ### Since the IssueStatus was patched to return an array - we
      ### need a first call here.
      self.status ||= IssueStatus.default.first
      self.priority ||= IssuePriority.default
    end
  end
  def new_statuses_allowed_to(user, include_default=false)
      statuses = status.find_new_statuses_allowed_to(
          user.roles_for_project(project),
          tracker,
          author == user,
          assigned_to_id_changed? ? assigned_to_id_was == user.id : assigned_to_id == user.id
      )
    statuses << status unless statuses.empty?
    ### This is the line we patch the new_statuses_allowed_to for
    statuses = statuses + IssueStatus.default if include_default
    statuses = statuses.uniq.sort
    blocked? ? statuses.reject {|s| s.is_closed?} : statuses
  end
end


