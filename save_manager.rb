# frozen_string_literal: true

require 'json'
require 'fileutils'
require_relative 'character'

# Save the state , details , specs , currenthp of the character
module SaveManager
  SAVE_DIR = 'saves'

  def self.ensure_save_dir
    FileUtils.mkdir_p(SAVE_DIR) unless Dir.exist?(SAVE_DIR)
  end

  def self.save(character)
    ensure_save_dir
    filename = "#{SAVE_DIR}/#{character.id}.json"
    data = character.to_hash
    
     # Replace stats["health"] with the live current_hp
    data["stats"]["health"] = character.current_hp if character.current_hp

     # No separate current_hp field
    data.delete("current_hp")

    write_file(filename, data)
  end

  def self.write_file(filename, data)
    File.write(filename, JSON.pretty_generate(data))
    puts "Progress saved to #{filename}."
    true
  rescue StandardError => e
    puts "Failed to save: #{e.message}"
    false
  end

  def self.list_saves
    ensure_save_dir
    Dir.glob("#{SAVE_DIR}/*.json")
  end

  def self.load_from_file(path)
    raise "File not found: #{path}" unless File.exist?(path)

    data = parse_file(path)
    validate_save_file(data)
    build_character(data)
  end

  def self.parse_file(path)
    content = File.read(path)
    JSON.parse(content)
  rescue JSON::ParserError => e
    raise "Failed to parse save file: #{e.message}"
  end

  def self.validate_save_file(data)
    required = %w[id name class level xp stats]
    raise 'Save file is missing fields' unless required.all? { |k| data.key?(k) }
  end

  # def self.build_character(data)
  #   Character.new(
  #     name: data['name'],
  #     class_type: data['class'],
  #     id: data['id'],
  #     level: data['level'],
  #     xp: data['xp'],
  #     stats: stringify_stats_keys(data['stats']),
  #     current_hp: data['current_hp']
  #   )
  # end

  def self.build_character(data)
   Character.new(
    name: data['name'],
    class_type: data['class'],
    id: data['id'],
    level: data['level'],
    xp: data['xp'],
    stats: stringify_stats_keys(data['stats']),
    current_hp: data['stats']['health']
    )
 end


  def self.stringify_stats_keys(hash)
    hash.transform_keys(&:to_s)
  end
end
