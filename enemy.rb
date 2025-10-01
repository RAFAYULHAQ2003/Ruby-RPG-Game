require 'securerandom'

class Enemy
  ENEMY_TYPES = {
    "Goblin" => { base_health: 50,  base_attack: 8,  base_defense: 3 },
    "Troll"  => { base_health: 120, base_attack: 15, base_defense: 8 },
    "Dragon" => { base_health: 300, base_attack: 30, base_defense: 20 }
  }

  attr_accessor :id, :name, :level, :health, :attack, :defense, :max_health

  def initialize(type:, level: 1)
    
    @id = SecureRandom.uuid
    @name = type
    @level = level
    base = ENEMY_TYPES[type]
    
    @max_health = base[:base_health]

    @health = @max_health
    @attack = base[:base_attack]
    @defense = base[:base_defense]

  end

  def ident
    "#{@name} #{@id}"
  end

  def alive?
    @health > 0
  end

  def take_damage(amount)
    @health -= amount
    @health = 0 if @health < 0
  end
end
