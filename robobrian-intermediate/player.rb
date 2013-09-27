require 'delegate'

RubyWarrior::Config.delay = 0.1

class Player

  def initialize
    @world = World.new
  end

  def play_turn(warrior)
    turn = @world.update warrior
    direction = warrior.direction_of_stairs
    case
      when @world.free_enemies?    then turn.bind!   @world.free_enemy_direction[0]
      when @world.captives?        then turn.rescue! @world.captive_direction[0]
      when warrior.health < 13     then warrior.rest!
      when @world.captive_enemies? then turn.attack! @world.enemy_direction[0]
    else
      warrior.walk! direction
    end
  end
end

class World

  def initialize
    @x, @y = 0, 0
    @spaces = Hash.new
  end

  def update warrior
    directions.each do |direction, adjustment|
      index = coords(adjustment)
      if warrior.feel(direction).empty?
        @spaces[index] = warrior.feel direction
      else
        @spaces[index] ||= warrior.feel direction
      end
    end
    Combine.new(warrior,self)
  end

  def captives?
    directions.find do |direction, adjustment|
      @spaces[coords adjustment].captive?
    end
  end
  alias captive_direction captives?

  def free_enemies?
    directions.find do |direction, adjustment|
      @spaces[coords adjustment].enemy?
    end
  end
  alias free_enemy_direction free_enemies?

  def captive_enemies?
    directions.find do |direction, adjustment|
      @spaces[coords adjustment].is_a? BoundEnemy
    end
  end
  alias enemy_direction captive_enemies?

  def bind! direction
    @spaces[at direction] = BoundEnemy.new(@spaces[at direction])
  end

  def rescue! direction
    puts direction.inspect
    @spaces[at direction] = nil
  end

  def attack! direction
    @spaces[at direction] = @spaces[at direction].__getobj__
  end

private

  def at direction
    coords directions[direction]
  end

  def directions
    { forward: [1,0], backward: [-1,0], left: [0,1], right: [0,-1] }
  end

  def coords adjustment
    [@x+adjustment[0],@y+adjustment[1]]
  end

end

class BoundEnemy < SimpleDelegator
  def enemy?
    false
  end
  def captive?
    false
  end
end

class Combine
  def initialize *args
    @actors = args
  end

  def method_missing name, *args
    @actors.each { |actor| actor.send(name, *args) }
  end
end
