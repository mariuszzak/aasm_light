require "spec_helper"

RSpec.describe AasmLight do
  it "has a version number" do
    expect(AasmLight::VERSION).not_to be nil
  end

  it "allows to include AasmLight module to any class" do
    expect do
      Class.new do
        include AasmLight
      end
    end.not_to raise_exception
  end

  it "doesn't allow to define multiple initial states" do
    expect do
      Class.new do
        include AasmLight

        aasm do
          state [:sleeping, :running], :initial => true
        end
      end
    end.to raise_exception AasmLight::MultipleInitialStates

    expect do
      Class.new do
        include AasmLight

        aasm do
          state :sleeping, :initial => true
          state :running, :initial => true
        end
      end
    end.to raise_exception AasmLight::MultipleInitialStates
  end

  it "doesn't allow to define two states with the same name" do
    expect do
      Class.new do
        include AasmLight

        aasm do
          state :sleeping
          state :sleeping
        end
      end
    end.to raise_exception AasmLight::StateAlreadyDefined, /States already defined: sleeping/

    expect do
      Class.new do
        include AasmLight

        aasm do
          state [:sleeping, :sleeping]
        end
      end
    end.to raise_exception AasmLight::StateAlreadyDefined, /Duplicated state in given array/

    expect do
      Class.new do
        include AasmLight

        aasm do
          state :sleeping, :dup1, :dup2
          state :running
          state :foo, :dup1, :bar, :dup2
        end
      end
    end.to raise_exception AasmLight::StateAlreadyDefined, /States already defined: dup1, dup2/
  end

  context "when the aasm is properly defined" do
    let(:klass_with_correct_aasm) do
      Class.new do
        include AasmLight

        aasm do
          state :sleeping, :initial => true
          state :running, :cleaning

          event :run do
            transitions :from => :sleeping, :to => :running
          end

          event :clean do
            transitions :from => :running, :to => :cleaning
          end

          event :sleep do
            transitions :from => [:running, :cleaning], :to => :sleeping
          end
        end
      end
    end

    let(:job) { klass_with_correct_aasm.new }

    it "allows to define states and events" do
      expect { job }.not_to raise_exception
    end

    it "allows to define initial state" do
      expect(job.current_state).to eq :sleeping
    end

    it "allows to ask about the state" do
      expect(job.sleeping?).to eq true
      expect(job.running?).to eq false
    end

    it "allows to ask if a transition is legal" do
      expect(job.may_run?).to eq true
      expect(job.may_clean?).to eq false
      expect(job.may_sleep?).to eq false
    end

    it "allows to perform an transition" do
      expect(job.running?).to eq false
      expect(job.current_state).not_to eq :running
      expect { job.run }.not_to raise_exception
      expect(job.running?).to eq true
      expect(job.current_state).to eq :running
    end

    it "raises an exception when transition is illegal" do
      expect(job.may_clean?).to eq false
      expect { job.clean }.to raise_exception AasmLight::InvalidTransition
    end

    it "behaves the same like AASM gem" do
      expect(job.sleeping?).to eq true
      expect(job.may_run?).to eq true
      expect { job.run }.not_to raise_exception
      expect(job.running?).to eq true
      expect(job.sleeping?).to eq false
      expect(job.may_run?).to eq false
      expect { job.run }.to raise_exception AasmLight::InvalidTransition
    end
  end

  context "when whiny_transitions option is set as false" do
    let(:klass) do
      Class.new do
        include AasmLight

        attr_accessor :foo

        aasm :whiny_transitions => false do
          state :sleeping
          state :running, :initial => true

          event :run do
            transitions :from => :sleeping, :to => :running
          end

          event :sleep do
            transitions :from => :running, :to => :sleeping
          end
        end
      end
    end

    let(:job) { klass.new }

    it "allows to define whiny_transitions option" do
      expect { job }.not_to raise_exception
    end

    it "return booleans instead of raising exceptions" do
      expect(job.running?).to eq true
      expect(job.may_run?).to eq false
      expect(job.run).to eq false
    end

    it "allows to pass a callback which runs when transition succeeds" do
      expect(job.foo).to eq nil
      job.run do
        job.foo = 'bar'
      end
      expect(job.running?).to eq true
      expect(job.foo).to eq nil

      job.sleep do
        job.foo = 'bar'
      end
      expect(job.running?).to eq false
      expect(job.foo).to eq 'bar'
    end
  end
end
