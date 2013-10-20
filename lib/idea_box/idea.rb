class Idea
  include Comparable

  attr_reader   :title,
                :description,
                :rank,
                :id,
                :tags
  attr_accessor :created_at,
                :updated_at

  def initialize(attributes = {})
    @title       = attributes["title"]
    @description = attributes["description"]
    @rank        = attributes["rank"] || 0
    @id          = attributes["id"]
    @tags        = attributes["tags"] || "no tag"
    @created_at  = attributes["created_at"] ||= Time.now
    @updated_at  = attributes["updated_at"] = Time.now

  end

  def save
    IdeaStore.create(to_h)
  end

  def to_h
    {
      "title" => title,
      "description" => description,
      "rank" => rank,
      "tags" => tags,
      "created_at" => created_at,
      "updated_at" => updated_at
    }
  end

  def idea_tags
    @tags.split(',')
  end

  def like!
    @rank += 1
  end

  def dislike!
    @rank -= 1
  end

  def <=>(other)
    other.rank <=> rank
  end

end
