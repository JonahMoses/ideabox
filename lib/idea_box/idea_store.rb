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
      updated_idea = data.merge("updated_at" => Time.now )
      database.transaction do
        database['ideas'][id] = idea.to_h.merge(updated_idea)
      end
    end

    def create(data)
      new_idea = Idea.new(data)
      database.transaction do
        database['ideas'] << new_idea.to_h
      end
      new_idea
    end

    def all
      raw_ideas.each_with_index.map do |data, i|
        Idea.new(data.merge("id" => i))
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
        idea.to_h["tags"].include?(keyword) ||
        idea.to_h["group"].include?(keyword)
      end
    end

    def day_string_to_num(week_day)
     if week_day == "Monday"
        day_num = 1
      elsif week_day == "Tuesday"
        day_num = 2
      elsif week_day == "Wednesday"
        day_num = 3
      elsif week_day == "Thursday"
        day_num = 4
      elsif week_day == "Friday"
        day_num = 5
      elsif week_day == "Saturday"
        day_num = 6
      else
        day_num = 7
      end
    end

    def find_by_wday(day_of_week)
      all.select do |idea|
        idea.created_at.wday == day_string_to_num(day_of_week)
      end
    end

    def find_by_group(group)
      all.select do |idea|
        idea.group == group
      end
    end

    def group_hash
      all.group_by { |idea| idea.group }
    end

    def all_groups
      group_hash.collect { |key, value| key }
    end

  end
end
