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
    erb :edit, locals: {idea: idea, rank: idea.rank}
  end

  put '/:id' do |id|
    IdeaStore.update(id.to_i, params[:idea])
    redirect '/'
  end

  post '/:id/like' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.like!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  post '/:id/dislike' do |id|
    idea = IdeaStore.find(id.to_i)
    idea.dislike!
    IdeaStore.update(id.to_i, idea.to_h)
    redirect '/'
  end

  get '/tags' do
    erb :tags, locals: {tags: IdeaStore.all_tags, ideas: IdeaStore, tag: "all"}
  end

  get '/tags/:tag' do
    erb :tags, locals: {ideas: IdeaStore, tag: params[:tag]}
  end

  get '/:id/info' do |id|
    idea = IdeaStore.find(id.to_i)
    erb :idea, locals: {idea: idea}
  end

  get '/new_idea' do
    erb :new_idea, locals: {idea: Idea.new}
  end

end
