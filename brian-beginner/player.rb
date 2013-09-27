RubyWarrior::Config.delay = 0.1
class Player

  def initialize
    @health = 20
  end

  def under_attack?
    @warrior.health < @health
  end

  def see_enemy?
    @warrior.look.any? { |s| s.enemy? && !s.captive? }
  end

  def play_turn(warrior)
    @warrior = warrior

    case
    when !@pivoted             then @pivoted ||= warrior.pivot!
    when see_enemy?            then warrior.shoot!
    when warrior.feel.wall?    then warrior.pivot!
    when warrior.feel.captive? then warrior.rescue!
    when !warrior.feel.empty? then warrior.attack!
    when (under_attack? and (warrior.health < 15)) then warrior.walk! :backward
    when under_attack?        then warrior.walk!
    when warrior.health < 20  then warrior.rest!
    else
      warrior.walk!
    end
    @health = warrior.health
  end
end
