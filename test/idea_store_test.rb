ENV['RACK_ENV'] = 'test'
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require 'rack/test'
require './lib/idea_box/idea_store'
require './lib/idea_box/idea'
require 'yaml/store'

class IdeaStoreTest < Minitest::Test

  def setup
    IdeaStore.database
    IdeaStore.create("title" => "Hello", "Description" => "World")
    IdeaStore.create("title" => "Hola", "Description" => "Mundo")
  end

  def teardown
    IdeaStore.destroy_database
  end

  def test_the_database_exists
    assert_kind_of Psych::Store, IdeaStore.database
  end

  def test_it_creates_a_new_idea_and_stores_in_database
    IdeaStore.create("title" => "Hello")
    result = IdeaStore.database.transaction {|db| db["ideas"].first}
    assert_equal "Hello", result["title"]
  end

  def test_all_gives_all_ideas_as_idea_objects
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    assert_equal 4, IdeaStore.all.count
    assert_equal "Hello", IdeaStore.all.first.title
    assert_equal "Howdy", IdeaStore.all.last.title
  end

  def test_it_deletes_an_idea_by_position_in_database
    IdeaStore.create("title" => "Hello")
    IdeaStore.create("title" => "Howdy")
    IdeaStore.create("title" => "Heyo")
    assert_equal 5, IdeaStore.all.count
    IdeaStore.delete(2)
    assert_equal "Heyo", IdeaStore.all.last.title
    assert_equal "Hello", IdeaStore.all.first.title
  end

  def test_it_destroys_database_contents
    IdeaStore.create("title" => "Hello")
    assert_equal 3, IdeaStore.all.count
    IdeaStore.destroy_database
    assert_equal 0, IdeaStore.all.count
  end

  def test_find_method_finds_by_id
    result = IdeaStore.find(1)
    assert_equal 1, result.id
    assert_equal "Hola", result.title
    assert_kind_of Idea, result
  end

  def test_it_can_update_an_idea
    IdeaStore.create("title" => "Hello")
    IdeaStore.update(0, "title" => "Howdy")
    result = IdeaStore.find(0)
    assert_equal "Howdy", result.title
  end

  def test_it_does_not_reset_rank_when_updating_idea
    IdeaStore.create("title" => "Blah", "rank" => 2)
    IdeaStore.update(2, "title" => "Heyo")
    result = IdeaStore.find(2)
    assert_equal 2, result.rank
  end

  def test_like_method_updates_rank_in_database
    IdeaStore.create("title" => "Hello")
    idea = IdeaStore.find(0)
    assert_equal 0, idea.rank
    idea.like!
    assert_equal 1, idea.rank
    idea.like!
    assert_equal 2, idea.rank
  end

  def test_it_leaves_others_unchanged_when_updating_idea
    IdeaStore.create("title" => "Hello")
    IdeaStore.update(2, "title" => "Bonjour")
    assert_equal "Hello", IdeaStore.all.first.title
    assert_equal "Bonjour", IdeaStore.all.last.title
    updated_idea = IdeaStore.find(2)
    assert_equal "Bonjour", updated_idea.title
  end

  def test_it_groups_by_tag
    IdeaStore.create("title" => "Hello", "Description" => "World", "tags" => "English")
    IdeaStore.create("title" => "Hola", "Description" => "Mundo", "tags" => "Spanish")
    IdeaStore.create("title" => "Howdy", "Description" => "Partner", "tags" => "English")
    assert_equal 2, IdeaStore.tag_hash["English"].count
    assert_equal 1, IdeaStore.tag_hash["Spanish"].count
    assert_equal 2, IdeaStore.tag_hash["no tag"].count
  end



end
