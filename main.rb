# frozen_string_literal: true

require_relative 'character'
require_relative 'enemy'
require_relative 'combat_engine'
require_relative 'save_manager'
require_relative 'logger_module'

def clear_screen
  system('clear')
end

def prompt_main_menu
  puts 'Welcome to Legends of the Ruby Realm!'
  puts '1. Start New Game'
  puts '2. Load Game'
  puts '3. Exit'
  print '> '
  gets.chomp
end

def choose_class
  classes = Character::CLASS_BASE.keys
  puts 'Choose class:'
  classes.each_with_index { |c, i| puts "#{i + 1}. #{c}" }
  loop do
    print '> '
    input = $stdin.gets&.chomp
    idx = input.to_i
    return classes[idx - 1] if idx >= 1 && idx <= classes.length

    puts 'Invalid selection. Choose a valid class number.'
  end
end

def create_new_character
  print 'Enter your name: '
  name = $stdin.gets&.chomp
  name = 'Hero' if name.nil? || name.strip.empty?
  class_type = choose_class
  char = Character.new(name: name, class_type: class_type)
  puts "You are #{char.name} the #{char.class_type}! (ID: #{char.id})"
  LoggerModule.log("Created new character: #{char.ident} (class #{char.class_type}).")
  char
end

def load_character_flow
  saves = SaveManager.list_saves
  return no_saves_found if saves.empty?

  display_saves(saves)
  choose_save(saves)
end

def no_saves_found
  puts 'No save files found.'
  nil
end

def display_saves(saves)
  puts 'Available saves:'
  saves.each_with_index { |s, i| puts "#{i + 1}. #{s}" }
  puts "#{saves.size + 1}. Cancel"
end

def choose_save(saves)
  loop do
    print '> '
    idx = $stdin.gets.to_i
    return nil if idx == saves.size + 1

    return try_load_save(saves[idx - 1]) if (1..saves.size).cover?(idx)

    puts 'Invalid selection.'
  end
end

def try_load_save(path)
  char = SaveManager.load_from_file(path)
  puts "Loaded #{char.name} (Level #{char.level})"
  LoggerModule.log("Loaded character #{char.ident} from #{path}.")
  char
rescue StandardError => e
  puts "Failed to load save: #{e.message}"
  nil
end

def game_loop(character)
  loop do
    enemy = CombatEngine.random_enemy_for(character)
    engine = CombatEngine.new(character)
    result = engine.fight(enemy)
    case result
    when :won

      post_battle_menu(character)
    when :ran
      puts 'You live to fight another day...'
    when :lost
      puts "Game over for #{character.name}."
      break
    end

    puts 'Continue exploring? (y/n)'
    print '> '
    input = $stdin.gets&.chomp&.downcase
    break unless %w[y yes].include?(input)
  end
end

def post_battle_menu(character)
  loop do
    puts "\nDo you want to save progress? (y/n)"
    print '> '
    input = $stdin.gets&.chomp&.downcase
    if %w[y yes].include?(input)
      SaveManager.save(character)
      break
    elsif %w[n no].include?(input)
      break
    else
      puts 'Please answer y or n.'
    end
  end
end

def run
  LoggerModule.ensure_log
  loop do
    clear_screen
    choice = prompt_main_menu
    case choice
    when '1'
      char = create_new_character
      game_loop(char)
    when '2'
      char = load_character_flow
      game_loop(char) if char
    when '3'
      puts 'Goodbye!'
      break
    else
      puts 'Invalid option. Try again.'
    end
    puts 'Press Enter to return to main menu...'
    $stdin.gets
  end
end

# Start game
run if __FILE__ == $PROGRAM_NAME
