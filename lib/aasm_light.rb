require 'aasm_light/version'
require 'aasm_light/exceptions'
require 'aasm_light/transition_failure_strategy'
require 'aasm_light/state_machine_builder'
require 'aasm_light/event_builder'

module AasmLight
  def self.included(base_class)
    base_class.extend(ClassMethods)
  end

  module ClassMethods
    def aasm(**options, &block)
      transition_failure_strategy = TransitionFailureStrategy.select_strategy(options)
      StateMachineBuilder.new(transition_failure_strategy, &block).build_instance_methods(self)
    end
  end
end
