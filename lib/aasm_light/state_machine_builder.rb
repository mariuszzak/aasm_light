module AasmLight
  class StateMachineBuilder
    def initialize(options, &block)
      @initial_state = nil
      @states        = []
      @events        = {}
      @options       = options
      instance_eval(&block)
    end

    def state(*state_names, **options)
      state_names.flatten!
      validate_states(states, state_names)
      set_initial_state(state_names) if options[:initial]
      @states += state_names
    end

    def event(action, &block)
      @events[action] = EventBuilder.new(&block)
    end

    def build_instance_methods(klass)
      define_current_state_method(klass)
      define_methods_with_question_mark(klass)
      define_transition_methods(klass)
    end

    private

    attr_reader :initial_state, :states, :events, :options

    def validate_states(states, state_names)
      if state_names.uniq.size != state_names.size
        raise StateAlreadyDefined, 'Duplicated state in given array'
      end

      duplicated_states = (states & state_names)
      unless duplicated_states.empty?
        raise StateAlreadyDefined, "States already defined: #{duplicated_states.join(', ')}"
      end
    end

    def set_initial_state(state_names)
      raise MultipleInitialStates unless state_names.size == 1
      raise MultipleInitialStates if initial_state
      @initial_state = state_names.first
    end

    def define_current_state_method(klass)
      klass.class_exec(initial_state) do |initial_state|
        define_method :current_state do
          @current_state ||= initial_state
        end
      end
    end

    def define_methods_with_question_mark(klass)
      klass.class_exec(states) do |states|
        states.each do |state|
          define_method "#{state}?" do
            current_state == state
          end
        end
      end
    end

    def define_transition_methods(klass)
      whiny_transitions = options[:whiny_transitions] != false
      klass.class_exec(events) do |events|
        events.each do |event_name, event_builder|
          define_method "may_#{event_name}?" do
            event_builder.legal_in_states.include?(current_state)
          end

          define_method event_name do
            unless public_send("may_#{event_name}?")
              raise(InvalidTransition) if whiny_transitions
              return false
            end
            @current_state = event_builder.target_state
          end
        end
      end
    end
  end
end
