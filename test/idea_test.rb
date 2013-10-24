ENV['RACK_ENV'] = 'test'
gem 'minitest'
require 'minitest/autorun'
require 'minitest/pride'
require './lib/idea_box/idea.rb'

class IdeaTest < Minitest::Test

  def test_basic_idea
    idea = Idea.new("title" => "dinner",
                    "description" => "chicken BBQ",
                    "id" => "1")
    assert_equal "dinner", idea.title
    assert_equal "chicken BBQ", idea.description
    assert_equal "1", idea.id
  end

  def test_it_has_a_data_hash_with_data_passed_in
    idea = Idea.new("title" => "dinner", "description" => "chicken BBQ", "id" => "1", "tags" => "tag", "created_at" => "Time",  "updated_at" => "Updated"  )
    expected = {"title" => "dinner", "description" => "chicken BBQ", "rank" => 0, "tags" => "tag", "created_at" => "Time", "updated_at" => "Updated", "group" => "No Group" }
    assert_equal expected, idea.to_h
    idea.like!
    expected2 = {"title" => "dinner", "description" => "chicken BBQ", "rank" => 1, "tags" => "tag", "created_at" => "Time", "updated_at" => "Updated", "group" => "No Group" }
    assert_equal expected2, idea.to_h
  end

  def test_it_gets_a_votes_of_0_initially
    idea = Idea.new
    assert_equal 0, idea.rank
  end

  def test_like_method_raises_the_vote_count_by_one_each_time
    idea = Idea.new
    assert_equal 0, idea.rank
    idea.like!
    assert_equal 1, idea.rank
    idea.like!
    assert_equal 2, idea.rank
  end

  def test_spaceship_operator_compares_votes
    idea = Idea.new
    bad_idea = Idea.new
    assert_equal 0, idea.<=>(bad_idea)
    idea.like!
    assert_equal -1, idea.<=>(bad_idea)
    bad_idea.like!
    bad_idea.like!
    assert_equal 1, idea.<=>(bad_idea)
  end

  def test_it_has_a_created_at_timestamp
    idea = Idea.new("created_at" => "2013-10-17 16:44:01 -0600")
    assert_equal "2013-10-17 16:44:01 -0600", idea.created_at
  end


end
