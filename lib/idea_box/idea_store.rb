require 'yaml/store'

class IdeaStore
  class << self

    def database
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

    def all
      ideas = []
      raw_ideas.each_with_index do |data, i|
        ideas << Idea.new(data.merge("id" => i))
      end
      ideas
    end

    def destroy_database
      database.transaction do |db|
        db["ideas"] = []
      end
    end

    def raw_ideas
      database.transaction do |db|
        db['ideas'] || []
      end
    end

    def delete(position)
      database.transaction do
        database['ideas'].delete_at(position)
      end
    end

    def find(id)
      raw_idea = find_raw_idea(id)
      Idea.new(raw_idea.merge("id" => id))
    end

    def find_raw_idea(id)
      database.transaction do
        database['ideas'].at(id)
      end
    end

    def update(id, data)
      idea = IdeaStore.find(id)
      updated_idea = data.merge("updated_at" => Time.now)
      database.transaction do
        database['ideas'][id] = idea.to_h.merge(updated_idea)
      end
    end

    def create(data)
      new_idea = Idea.new(data)
      database.transaction do
        database['ideas'] << new_idea.to_h
      end
    end

    def all_tags
      all_tags = []
      all.each do |idea|
        idea.tags.split(', ').each do |tag|
          all_tags << tag
        end
      end
      all_tags.uniq
    end

    def tag_hash
      all_tags.each_with_object({}) do |tag, hash|
        hash[tag] = all.select {|idea| idea.to_h["tags"].include? tag}
      end
    end

    def search(keyword)
      all.select do |idea|
        idea.to_h["title"].include?(keyword) ||
        idea.to_h["description"].include?(keyword) ||
        idea.to_h["tags"].include?(keyword)
      end
    end

  end
end
