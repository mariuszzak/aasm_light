require 'aasm_light/version'
require 'aasm_light/exceptions'
require 'aasm_light/state_machine_builder'
require 'aasm_light/event_builder'

module AasmLight
  def self.included(base_class)
    base_class.extend(ClassMethods)
  end

  module ClassMethods
    def aasm(&block)
      StateMachineBuilder.new(&block).build_instance_methods(self)
    end
  end
end
