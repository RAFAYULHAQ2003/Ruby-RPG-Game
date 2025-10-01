
require 'securerandom'


require 'yaml'


require_relative 'logger_module'

class Character


  attr_accessor :id, :name, :class_type, :level, :xp, :stats, :current_hp




CLASS_BASE = {
  "Warrior" => { "health" => 120, "attack" => 20, "defense" => 15 },
  "Mage"    => { "health" => 80,  "attack" => 25, "defense" => 8  },
  "Rogue"   => { "health" => 100, "attack" => 18, "defense" => 10 }
}


  def initialize(name:, class_type:, id: nil, level: 1, xp: 0, stats: nil, current_hp: nil)
    @id = SecureRandom.uuid
    @name = name
    @class_type = class_type

    @level = level
    @xp = xp
    @stats = CLASS_BASE[class_type].clone
    @current_hp = current_hp || @stats["health"]  
  end




  def to_hash
    {
      "id" => @id,
      "name" => @name,
      "class" => @class_type,
      "level" => @level,
      "xp" => @xp,
      "stats" => @stats,
      "current_hp" => @current_hp
    }


  end

  def gain_xp(amount)
    @xp += amount
    LoggerModule.log("Player #{@id} gained #{amount} XP (total #{@xp}).")
    check_level_up
  end



  def xp_needed_for_next_level
    @level * 100
  end



  def check_level_up
    leveled = false


    while @xp >= xp_needed_for_next_level
      @xp -= xp_needed_for_next_level
      @level += 1
      leveled = true
   
   


      message = "Player #{@id} (#{@name}) reached Level #{@level}!"


      puts message

      LoggerModule.log(message)
    end
    leveled
  end


  def stats_str
    "HP: #{@stats['health']} | ATK: #{@stats['attack']} | DEF: #{@stats['defense']}"
  end


  def ident
    "#{@name} #{@id}"
  end
end


