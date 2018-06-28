# attr_accessor for class variable
#
# Usage:
# '''
#   class Pod
#       class_attr_accessor :is_prebuild_stage
#   end
# '''
def class_attr_accessor(class_variable_name)
    self.class.send(:attr_accessor, class_variable_name)
end