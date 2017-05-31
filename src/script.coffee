# Description
#   A Hubot script to get anime data from kitsu
#
# Dependencies:
#   node-kitsu
#
# Configuration:
#   None
#
# Commands:
#   hubot kitsu <anime name> - Get anime info
#
# Author:
#   lgaticaq

kitsu = require("node-kitsu")
icon = "https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png"

module.exports = (robot) ->
  robot.respond /kitsu (.+)$/, (res) ->
    query = res.match[1]
    kitsu.searchAnime(query, 0).then (results) ->
      if results.length is 0
        res.send("Not found *#{query}*")
        return
      result = results[0]
      now = new Date()
      if result.attributes.endDate is null
        status = "Currently Airing"
      else
        end = new Date(result.attributes.endDate)
        if end < now
          status = "Finished Airing"
        else
          status = "Currently Airing"
      averageRating = result.attributes.averageRating
      text = "#{result.attributes.canonicalTitle}\n"
      text += "#{result.attributes.synopsis}\n"
      text += "Average Rating: :star2: #{averageRating}\n"
      text += "Popularity Rank: :heart: #{result.attributes.popularityRank}\n"
      text += "Rating Rank: :star: #{result.attributes.ratingRank}\n"
      text += "Rating: #{result.attributes.ageRating}\n"
      text += "Aired: #{result.attributes.startDate}\n"
      text += "Status: #{status}\n"
      if result.attributes.episodeCount isnt null
        text += "Eposides: #{result.attributes.episodeCount}\n"
        text += "Duration: #{result.attributes.episodeLength} min\n"
      if result.attributes.youtubeVideoId isnt null
        youtubeVideoId = result.attributes.youtubeVideoId
        text += "Video: https://www.youtube.com/watch?v=#{youtubeVideoId}"
      # Room is in test
      if robot.adapter.constructor.name in ["SlackBot", "Room"]
        options =
          as_user: false
          link_names: 1
          icon_url: icon
          username: "Kitsu"
          unfurl_links: false
          attachments: [
            fallback: text
            color: "#36a64f"
            title: result.attributes.canonicalTitle
            title_link: "https://kitsu.io/anime/#{result.attributes.slug}"
            text: result.attributes.synopsis
            fields: [
              title: "Average Rating"
              value: ":star2: #{averageRating}"
              short: true
            ,
              title: "Popularity Rank"
              value: ":heart: #{result.attributes.popularityRank}"
              short: true
            ,
              title: "Rating Rank"
              value: ":star: #{result.attributes.ratingRank}"
              short: true
            ,
              title: "Rating"
              value: result.attributes.ageRating
              short: true
            ,
              title: "Aired"
              value: result.attributes.startDate
              short: true
            ,
              title: "Status"
              value: status
              short: true
            ]
          ]
        if result.attributes.coverImage isnt null
          image = result.attributes.coverImage.original
          options.attachments[0].image_url = image
        else if result.attributes.posterImage isnt null
          image = result.attributes.posterImage.original
          options.attachments[0].image_url = image
        if result.attributes.episodeCount isnt null
          options.attachments[0].fields.push
            title: "Eposides"
            value: result.attributes.episodeCount
            short: true
          options.attachments[0].fields.push
            title: "Duration"
            value: "#{result.attributes.episodeLength} min"
            short: true
        if result.attributes.youtubeVideoId isnt null
          youtubeVideoId = result.attributes.youtubeVideoId
          options.attachments[0].fields.push
            title: "Video"
            value: "https://www.youtube.com/watch?v=#{youtubeVideoId}"
            short: false
        robot.adapter.client.web.chat.postMessage(
          res.message.room, null, options)
      else
        res.send(text)
    .catch (err) ->
      robot.emit("error", err)
      res.send("An error has occurred: #{err.message}")
      return
