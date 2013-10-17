require 'yaml/store'

class IdeaStore

  def self.database
    return @database if @database

    @database ||= YAML::Store.new('db/ideabox')
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
    # idea = IdeaStore.find(id)
    # new_idea_info = idea.to_h.merge(data)
    database.transaction do
      database['ideas'][id] = data
    end
  end

  def self.create(data)
    database.transaction do
      database['ideas'] << data
    end
  end

  # def self.all_tags
    # all.collect do |idea|
    #   idea.tags.collect do |tag|
    #     tag
    #   end
    # end.flatten.uniq.sort
  # end

  # def self.find_all_by_tag(tag)
  #   all.find_all { |idea| idea.tags.include? tag }
  # end

  # def self.group_by_tags
  #   tags.each_with_object({}) do |tag, group|
  #     group[tag] = find_all_by_tag(tag)
  #   end
  # end


end
