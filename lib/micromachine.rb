class MicroMachine
  InvalidEvent = Class.new(NoMethodError)
  Transition = Struct.new(:event, :from, :to)

  attr :transitions_for
  attr :state

  def initialize(initial_state)
    @state = initial_state
    @transitions_for = Hash.new
    @callbacks = Hash.new { |hash, key| hash[key] = [] }
  end

  def on(key, &block)
    @callbacks[key] << block
  end

  def when(event, transitions)
    transitions_for[event] = transitions
  end

  def trigger(event)
    if trigger?(event)
      from = @state
      @state = transitions_for[event][@state]
      transition = Transition.new(event, from, @state)
      callbacks = @callbacks[@state] + @callbacks[:any]
      callbacks.each { |callback| callback.call(transition) }
      true
    else
      false
    end
  end

  def trigger?(event)
    raise InvalidEvent unless transitions_for.has_key?(event)
    transitions_for[event][state] ? true : false
  end

  def events
    transitions_for.keys
  end

  def ==(some_state)
    state == some_state
  end
end
