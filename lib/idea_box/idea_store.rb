require 'yaml/store'

class IdeaStore

  def self.database
    return @database if @database

    if ENV['RACK_ENV'] == 'test'
      @database = YAML::Store.new "db/ideabox_test"
    else
      @database = YAML::Store.new "db/ideabox"
    end
    @database.transaction do
      @database['ideas'] ||= []
    end
    @database
  end

  def self.all
    ideas = []
    raw_ideas.each_with_index do |data, i|
      ideas << Idea.new(data.merge("id" => i))
    end
    ideas
  end

  def self.destroy_database
    database.transaction do |db|
      db["ideas"] = []
    end
  end

  def self.raw_ideas
    database.transaction do |db|
      db['ideas'] || []
    end
  end

  def self.delete(position)
    database.transaction do
      database['ideas'].delete_at(position)
    end
  end

  def self.find(id)
    raw_idea = find_raw_idea(id)
    Idea.new(raw_idea.merge("id" => id))
  end

  def self.find_raw_idea(id)
    database.transaction do
      database['ideas'].at(id)
    end
  end

  def self.update(id, data)
    idea = IdeaStore.find(id)
    database.transaction do
      database['ideas'][id] = idea.to_h.merge(data)
    end
  end

  def self.create(data)
    database.transaction do
      database['ideas'] << data
    end
  end

  def self.all_tags
    all_tags = []
    all.each do |idea|
      idea.tags.split(', ').each do |tag|
        all_tags << tag
      end
    end
    all_tags.uniq
  end

  def self.tag_hash
    all_tags.each_with_object({}) do |tag, hash|
      hash[tag] = all.select {|idea| idea.to_h["tags"].include? tag}
    end
  end


end
