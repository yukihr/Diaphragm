confs = require 'confs'
base = confs.api.baseURL
oauthclient = new (require 'lib/oauthclient')(confs.auth)

# Override Backbone.sync
sync = (method, model, options = {}) ->
  Backbone.sync method, model, _.extend
    data:
      access_token: oauthclient.accessToken()
    dataType: 'jsonp'
    , options

class ModelForAPI extends Backbone.Model
  sync: sync

class Media extends Backbone.Model
  urlRoot: base + '/media'

class User extends Backbone.Model
  urlRoot: base + '/users'


class CollectionForAPI extends Backbone.Collection
  # url: 'https://api.instagram.com/v1/users/self/feed',
  sync: sync
  parse: (res) ->
    this.additional ={}
    for key,val of res
      if key isnt 'data'
        this.additional[key] = val
    res.data

  fetchNext: (options) ->
    this.fetch _.extend
        url: this.additional.pagination.next_url
        add: true
      , options

class UserSpecificCollection extends CollectionForAPI
  initialize: (models, options = {}) ->
    @userId = if options.userId then options.userId else 'self'

class MediaFeed extends UserSpecificCollection
  model: Media
  url: ->
    base + "/users/#{@userId}/feed"

class LikedMedia extends UserSpecificCollection
  model: Media
  url: ->
    base + "/users/#{@userId}/media/liked"

class RecentMedia extends UserSpecificCollection
  model: Media
  url: ->
    base + "/users/#{@userId}/media/recent"

class FollowingUsers extends UserSpecificCollection
  model: User
  url: ->
    base + "/users/#{@userId}/follows"

class FollowedUsers extends UserSpecificCollection
  model: User
  url: ->
    base + "/users/#{@userId}/followed-by"

module.exports =
  Media: Media
  User: User
  MediaFeed: MediaFeed
  LikedMedia: LikedMedia
  RecentMedia: RecentMedia
  FollowingUsers: FollowingUsers
  FollowedUsers: FollowedUsers
