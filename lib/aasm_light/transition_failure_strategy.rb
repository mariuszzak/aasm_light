module AasmLight
  module TransitionFailureStrategy
    module_function
    def select_strategy(options)
      case options[:whiny_transitions]
        when false then TransitionFailureStrategy::ReturnFalse
        else TransitionFailureStrategy::RaiseError
      end
    end

    module ReturnFalse
      module_function
      def fail!
        false
      end
    end

    module RaiseError
      module_function
      def fail!
        raise(InvalidTransition)
      end
    end
  end
end
