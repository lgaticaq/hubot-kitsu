Helper = require("hubot-test-helper")
expect = require("chai").expect
proxyquire = require("proxyquire")

icon = "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png"

kitsuStub =
  searchAnime: (query, offset) ->
    return new Promise (resolve, reject) ->
      result =
        attributes:
          ageRating: "PG"
          averageRating: "3.52"
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
        resolve([])
      else if query is "error"
        reject(new Error("Server error"))
      else if query is "endDate"
        result.attributes.endDate = "2002-01-01"
        result.attributes.episodeCount = 25
        result.attributes.youtubeVideoId = null
        result.attributes.coverImage = null
        resolve([result])
      else if query is "endDate2"
        nextYear = (new Date).getFullYear() + 1
        result.attributes.endDate = "#{nextYear}-01-01"
        result.attributes.episodeCount = 25
        result.attributes.coverImage = null
        result.attributes.posterImage = null
        resolve([result])
      else
        resolve([result])

proxyquire("./../src/script.coffee", {"node-kitsu": kitsuStub})
helper = new Helper("./../src/index.coffee")

describe "hubot-kitsu", ->
  beforeEach ->
    @room = helper.createRoom()

  afterEach ->
    @room.destroy()

  context "Server error", ->
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

    it "should respond with an error", ->
      expect(@room.messages).to.eql([
        ["user", "hubot kitsu error"],
        ["hubot", "An error has occurred: Server error"]
      ])

  context "Not found", ->
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

    it "should respond with an not found", ->
      expect(@room.messages).to.eql([
        ["user", "hubot kitsu not found"],
        ["hubot", "Not found *not found*"]
      ])

  context "Get data", ->
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

    it "should respond with results", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.false
      expect(@postMessage.options.username).to.eql("Kitsu")
      expect(@postMessage.options.icon_url).to.eql(
        "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png")
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: :star2: 3.52\n" +
          "Popularity Rank: :heart: 1234\n" +
          "Rating Rank: :star: 2345\n" +
          "Rating: PG\n" +
          "Aired: 2000-01-01\n" +
          "Status: Currently Airing\n" +
          "Duration: 24 min\n" +
          "Video: https://www.youtube.com/watch?v=um-tFlVamOI"
        color: "#36a64f"
        title: "One Piece"
        title_link: "https://kitsu.io/anime/one-piece"
        text: "Gol D. Roger was known as the Pirate King"
        fields: [
          short: true
          title: "Average Rating"
          value: ":star2: 3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: ":heart: 1234"
        ,
          short: true
          title: "Rating Rank"
          value: ":star: 2345"
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
          title: "Duration"
          value: "24 min"
        ,
          short: false
          title: "Video"
          value: "https://www.youtube.com/watch?v=um-tFlVamOI"
        ]
        image_url: "http://coverImage.png"
      ]
      done()

  context "Get data with end date", ->
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

    it "should respond with results", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.false
      expect(@postMessage.options.username).to.eql("Kitsu")
      expect(@postMessage.options.icon_url).to.eql(
        "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png")
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: :star2: 3.52\n" +
          "Popularity Rank: :heart: 1234\n" +
          "Rating Rank: :star: 2345\n" +
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
          value: ":star2: 3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: ":heart: 1234"
        ,
          short: true
          title: "Rating Rank"
          value: ":star: 2345"
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
        image_url: "http://posterImage.png"
      ]
      done()

  context "Get data with end date 2", ->
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

    it "should respond with results", (done) ->
      expect(@postMessage.text).to.be.null
      expect(@postMessage.options.as_user).to.be.false
      expect(@postMessage.options.username).to.eql("Kitsu")
      expect(@postMessage.options.icon_url).to.eql(
        "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png")
      expect(@postMessage.options.link_names).to.equal 1
      expect(@postMessage.options.attachments).to.eql [
        fallback: "One Piece\n" +
          "Gol D. Roger was known as the Pirate King\n" +
          "Average Rating: :star2: 3.52\n" +
          "Popularity Rank: :heart: 1234\n" +
          "Rating Rank: :star: 2345\n" +
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
          value: ":star2: 3.52"
        ,
          short: true
          title: "Popularity Rank"
          value: ":heart: 1234"
        ,
          short: true
          title: "Rating Rank"
          value: ":star: 2345"
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
      ]
      done()
