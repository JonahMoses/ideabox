require 'sinatra/base'
require_relative 'idea_box/idea_store'
require_relative 'idea_box/idea'

class IdeaBoxApp < Sinatra::Base
  set :method_override, true
  set :root, 'lib/app'

  not_found do
    erb :error
  end

  get '/' do
    erb :index, locals: {ideas: IdeaStore.all.sort, idea: Idea.new, tags: IdeaStore.all_tags}
  end

  post '/' do
    IdeaStore.create(params['idea'])
    redirect '/'
  end

  delete '/:id' do |id|
    IdeaStore.delete(id.to_i)
    redirect '/'
  end

  get '/:id/edit' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea_submission, locals: {idea: idea, rank: idea.rank}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect back
  end

  post '/:id/dislike' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.dislike!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect back
  end

  get '/tags' do
    erb :tags, locals: {tags: IdeaStore.all_tags, ideas: IdeaStore, tag: "all"}
  end

  get '/tags/:tag' do
    erb :tags, locals: {ideas: IdeaStore, tag: params[:tag]}
  end

  get '/:id/info' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea, locals: {idea: idea, location: "not_front_page"}
  end

  get '/new_idea' do
    erb :new_idea, locals: {idea: Idea.new}
  end

  get '/search' do
    searched_items = IdeaStore.search(params[:search])
    erb :search, locals: {search: searched_items}
  end

  get '/ideas' do
    sort_by = params[:sort_by]
    if sort_by == 'day' || sort_by == 'time'
      if params[:sort_by] == 'day'
        ideas = IdeaStore.all.group_by { |idea| idea.created_at.strftime("%a") }
      elsif params[:sort_by] == 'time'
        ideas = IdeaStore.all.group_by { |idea| idea.created_at.strftime("%I %p") }.sort
      end
      header = "Statistics:"
    else
      ideas = {"" => IdeaStore.all.sort}
      header = "Existing Ideas:"
    end
    erb :ideas, locals: {grouped_ideas: ideas, idea: Idea.new, tags: IdeaStore.all_tags, header: header}
  end

  get '/dates/:day' do
    day_of_week = params[:day]
    ideas = IdeaStore.find_by_wday(day_of_week)
    erb :dates, locals: {ideas: ideas, day_of_week: day_of_week}
  end

end
