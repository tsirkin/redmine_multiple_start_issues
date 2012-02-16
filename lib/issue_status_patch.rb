require_dependency 'issue_status'

# Patches Redmine's Issues Status dynamically.  Adds a new method
# is_new that means that the issue status can be marked as new
# in tracker.
module IssueStatusPatch
  def self.included(base) # :nodoc:
    unloadable
    ### looks like extend will not override already existing class
    ### methods but only add new ones .TODO: check this out i.e. if
    ### the extend will override already existsing class methods.
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)

    base.class_eval do
      base.after_save.delete_if{
        |callback| callback.method == :update_default
      }
      def base.default
        #find(:first, :conditions =>["is_default=?", true])
        find(:all, :conditions =>["is_default=?", true])
      end 
      alias_method_chain :new_statuses_allowed_to, :multiple_defaults
    end
  end
  
  module ClassMethods
    # Returns the default status for new issues
    def default
      #find(:first, :conditions =>["is_default=?", true])
      find(:all, :conditions =>["is_default=?", true])
    end
  end
  
  module InstanceMethods
    def new_statuses_allowed_to_with_multiple_defaults(user, include_default=false)
      statuses = status.find_new_statuses_allowed_to(
          user.roles_for_project(project),
          tracker,
          author == user,
          assigned_to_id_changed? ? assigned_to_id_was == user.id : assigned_to_id == user.id
      )
      statuses << status unless statuses.empty?
      statuses = statuses + IssueStatus.default if include_default
      statuses = statuses.uniq.sort
      blocked? ? statuses.reject {|s| s.is_closed?} : statuses
    end
  end
end

# Add module to Issue
# moved to init.rb
# IssueStatus.send(:include, IssueStatusPatch)

