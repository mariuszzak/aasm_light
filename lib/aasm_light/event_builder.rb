module AasmLight
  class EventBuilder
    attr_reader :legal_in_states, :target_state

    def initialize(&block)
      @legal_in_states = []
      @target_state    = nil
      instance_eval(&block)
    end

    def transitions(**options)
      @target_state    = options[:to]
      @legal_in_states = Array(options[:from])
    end
  end
end
