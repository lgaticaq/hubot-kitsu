Helper = require("hubot-test-helper")
expect = require("chai").expect
proxyquire = require("proxyquire")

icon = "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png"

kitsuStub =
  searchAnime: (query, offset, cb) ->
    result =
      attributes:
        ageRating: "PG"
        averageRating: 3.52345
        canonicalTitle: "One Piece"
        coverImage:
          original: "http://coverImage.png"
        endDate: null
        episodeCount: null
        episodeLength: 24
        popularityRank: 1234
        posterImage:
          original: "http://posterImage.png"
        ratingRank: 2345
        slug: "one-piece"
        startDate: "2000-01-01"
        synopsis: "Gol D. Roger was known as the Pirate King"
        youtubeVideoId: "um-tFlVamOI"
    if query is "not found"
      cb(null, [])
    else if query is "error"
      cb(new Error("Server error"))
    else if query is "endDate"
      result.attributes.endDate = "2002-01-01"
      result.attributes.episodeCount = 25
      result.attributes.youtubeVideoId = null
      result.attributes.coverImage = null
      cb(null, [result])
    else if query is "endDate2"
      nextYear = (new Date).getFullYear() + 1
      result.attributes.endDate = "#{nextYear}-01-01"
      result.attributes.episodeCount = 25
      result.attributes.coverImage = null
      result.attributes.posterImage = null
      cb(null, [result])
    else
      cb(null, [result])

proxyquire("./../src/script.coffee", {"node-kitsu": kitsuStub})
helper = new Helper("./../src/index.coffee")

describe "hubot-kitsu", ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context "test", ->
    beforeEach (done) ->
      @room.user.say("user", "hubot kitsu error")
      @room.robot.adapter.client =
        web:
          chat:
            postMessage: (channel, text, options) =>
              @postMessage =
                channel: channel
                text: text
                options: options
      setTimeout(done, 100)

    it "should reply", ->
      expect(@room.messages).to.eql([
        ["user", "hubot kitsu error"],
        ["hubot", "An error has occurred: Server error"]
      ])

  context "test", ->
    beforeEach (done) ->
      @room.user.say("user", "hubot kitsu not found")
      @room.robot.adapter.client =
        web:
          chat:
            postMessage: (channel, text, options) =>
              @postMessage =
                channel: channel
                text: text
                options: options
      setTimeout(done, 100)

    it "should reply", ->
      expect(@room.messages).to.eql([
        ["user", "hubot kitsu not found"],
        ["hubot", "Not found *not found*"]
      ])

  context "test", ->
    beforeEach (done) ->
      @room.user.say("user", "hubot kitsu one piece")
      @room.robot.adapter.client =
        web:
          chat:
            postMessage: (channel, text, options) =>
              @postMessage =
                channel: channel
                text: text
                options: options
              done()

    it "should reply", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.true
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: 3.52\n" +
          "Popularity Rank: 1234\n" +
          "Rating Rank: 2345\n" +
          "Rating: PG\n" +
          "Aired: 2000-01-01\n" +
          "Status: Currently Airing\n" +
          "Video: https://www.youtube.com/watch?v=um-tFlVamOI"
        color: "#36a64f"
        title: "One Piece"
        title_link: "https://kitsu.io/anime/one-piece"
        text: "Gol D. Roger was known as the Pirate King"
        fields: [
          short: true
          title: "Average Rating"
          value: "3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: 1234
        ,
          short: true
          title: "Rating Rank"
          value: 2345
        ,
          short: true
          title: "Rating"
          value: "PG"
        ,
          short: true
          title: "Aired"
          value: "2000-01-01"
        ,
          short: true
          title: "Status"
          value: "Currently Airing"
        ,
          short: false
          title: "Video"
          value: "https://www.youtube.com/watch?v=um-tFlVamOI"
        ]
        footer: "Kitsu API"
        footer_icon: icon
        image_url: "http://coverImage.png"
      ]
      done()

  context "test", ->
    beforeEach (done) ->
      @room.user.say("user", "hubot kitsu endDate")
      @room.robot.adapter.client =
        web:
          chat:
            postMessage: (channel, text, options) =>
              @postMessage =
                channel: channel
                text: text
                options: options
              done()

    it "should reply", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.true
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: 3.52\n" +
          "Popularity Rank: 1234\n" +
          "Rating Rank: 2345\n" +
          "Rating: PG\n" +
          "Aired: 2000-01-01\n" +
          "Status: Finished Airing\n" +
          "Eposides: 25\n" +
          "Duration: 24 min\n"
        color: "#36a64f"
        title: "One Piece"
        title_link: "https://kitsu.io/anime/one-piece"
        text: "Gol D. Roger was known as the Pirate King"
        fields: [
          short: true
          title: "Average Rating"
          value: "3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: 1234
        ,
          short: true
          title: "Rating Rank"
          value: 2345
        ,
          short: true
          title: "Rating"
          value: "PG"
        ,
          short: true
          title: "Aired"
          value: "2000-01-01"
        ,
          short: true
          title: "Status"
          value: "Finished Airing"
        ,
          short: true
          title: "Eposides"
          value: 25
        ,
          short: true
          title: "Duration"
          value: "24 min"
        ]
        footer: "Kitsu API"
        footer_icon: icon
        image_url: "http://posterImage.png"
      ]
      done()

  context "test", ->
    beforeEach (done) ->
      @room.user.say("user", "hubot kitsu endDate2")
      @room.robot.adapter.client =
        web:
          chat:
            postMessage: (channel, text, options) =>
              @postMessage =
                channel: channel
                text: text
                options: options
              done()

    it "should reply", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.true
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: 3.52\n" +
          "Popularity Rank: 1234\n" +
          "Rating Rank: 2345\n" +
          "Rating: PG\n" +
          "Aired: 2000-01-01\n" +
          "Status: Currently Airing\n" +
          "Eposides: 25\n" +
          "Duration: 24 min\n" +
          "Video: https://www.youtube.com/watch?v=um-tFlVamOI"
        color: "#36a64f"
        title: "One Piece"
        title_link: "https://kitsu.io/anime/one-piece"
        text: "Gol D. Roger was known as the Pirate King"
        fields: [
          short: true
          title: "Average Rating"
          value: "3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: 1234
        ,
          short: true
          title: "Rating Rank"
          value: 2345
        ,
          short: true
          title: "Rating"
          value: "PG"
        ,
          short: true
          title: "Aired"
          value: "2000-01-01"
        ,
          short: true
          title: "Status"
          value: "Currently Airing"
        ,
          short: true
          title: "Eposides"
          value: 25
        ,
          short: true
          title: "Duration"
          value: "24 min"
        ,
          short: false
          title: "Video"
          value: "https://www.youtube.com/watch?v=um-tFlVamOI"
        ]
        footer: "Kitsu API"
        footer_icon: icon
      ]
      done()