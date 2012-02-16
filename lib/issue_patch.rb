require_dependency 'issue'

# Patches Redmine's Issues Status dynamically.  Adds a new method
# is_new that means that the issue status can be marked as new
# in tracker.
module IssuePatch
  def self.included(base) # :nodoc:
    unloadable
    ### looks like extend will not override already existing class
    ### methods but only add new ones .TODO: check this out i.e. if
    ### the extend will override already existsing class methods.
    base.extend(ClassMethods)
    base.send(:include, InstanceMethods)
    #debugger
    base.class_eval do
      base.after_initialize.delete_if do
        |callback| callback.method == :after_initialize
      end
      base.send(:after_initialize, :after_initialize_patched)
    end
  end
  
  module ClassMethods
  end
  
  module InstanceMethods
    def after_initialize_patched
      if new_record?
        # set default values for new records only
        ### Since the IssueStatus was patched to return an array - we
        ### need a first call here.
        self.status ||= IssueStatus.default.first
        self.priority ||= IssuePriority.default
      end
    end
  end
end
