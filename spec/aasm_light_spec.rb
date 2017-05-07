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
end
