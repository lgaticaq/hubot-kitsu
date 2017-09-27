// Description
//   A Hubot script to get anime data from kitsu
//
// Dependencies:
//   node-kitsu
//
// Configuration:
//   None
//
// Commands:
//   hubot kitsu <anime name> - Get anime info
//
// Author:
//   lgaticaq

'use strict'

const Kitsu = require('kitsu.js')
const Fuse = require('fuse.js')

const icon = 'https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png'

module.exports = robot => {
  const fuzzzySearch = (name, list) => {
    const options = {
      shouldSort: true,
      threshold: 0.6,
      location: 0,
      distance: 100,
      maxPatternLength: 32,
      keys: ['titles.canonical']
    }
    const fuse = new Fuse(list, options)
    return fuse.search(name)
  }

  robot.respond(/kitsu (.+)$/, res => {
    const query = res.match[1]
    const kitsu = new Kitsu()
    kitsu.searchAnime(query).then(results => {
      if (results.length === 0) {
        return res.send(`Not found *${query}*`)
      }
      const result = fuzzzySearch(query, results)[0]
      const now = new Date()
      let status
      if (result.endDate === null) {
        status = 'Currently Airing'
      } else {
        const end = new Date(result.endDate)
        if (end < now) {
          status = 'Finished Airing'
        } else {
          status = 'Currently Airing'
        }
      }
      const averageRating = result.averageRating
      let text = `${result.titles.canonical}\n`
      text += `${result.synopsis}\n`
      text += `Average Rating: :star2: ${averageRating}\n`
      text += `Popularity Rank: :heart: ${result.popularityRank}\n`
      text += `Rating Rank: :star: ${result.ratingRank}\n`
      text += `Rating: ${result.ageRating}\n`
      text += `Aired: ${result.startDate}\n`
      text += `Status: ${status}\n`
      if (result.episodeCount !== null) {
        text += `Episodes: ${result.episodeCount}\n`
      }
      if (result.episodeLength !== null) {
        text += `Duration: ${result.episodeLength} min\n`
      }
      if (result.youtubeVideoId !== null) {
        const youtubeVideoId = result.youtubeVideoId
        text += `Video: https://www.youtube.com/watch?v=${youtubeVideoId}`
      }
      if (['SlackBot', 'Room'].includes(robot.adapter.constructor.name)) {
        const options = {
          as_user: false,
          link_names: 1,
          icon_url: icon,
          username: 'Kitsu',
          unfurl_links: false,
          attachments: [
            {
              fallback: text,
              color: '#36a64f',
              title: result.titles.canonical,
              title_link: `https://kitsu.io/anime/${result.slug}`,
              text: result.synopsis,
              fields: [
                {
                  title: 'Average Rating',
                  value: `:star2: ${averageRating}`,
                  short: true
                }, {
                  title: 'Popularity Rank',
                  value: `:heart: ${result.popularityRank}`,
                  short: true
                }, {
                  title: 'Rating Rank',
                  value: `:star: ${result.ratingRank}`,
                  short: true
                }, {
                  title: 'Rating',
                  value: result.ageRating,
                  short: true
                }, {
                  title: 'Aired',
                  value: result.startDate,
                  short: true
                }, {
                  title: 'Status',
                  value: status,
                  short: true
                }
              ]
            }
          ]
        }
        let image
        if (result.coverImage !== null) {
          image = result.coverImage.original
          options.attachments[0].image_url = image
        } else if (result.posterImage !== null) {
          image = result.posterImage.original
          options.attachments[0].image_url = image
        }
        if (result.episodeCount !== null) {
          options.attachments[0].fields.push({
            title: 'Episodes',
            value: result.episodeCount,
            short: true
          })
        }
        if (result.episodeLength !== null) {
          options.attachments[0].fields.push({
            title: 'Duration',
            value: `${result.episodeLength} min`,
            short: true
          })
        }
        if (result.youtubeVideoId !== null) {
          const youtubeVideoId = result.youtubeVideoId
          options.attachments[0].fields.push({
            title: 'Video',
            value: `https://www.youtube.com/watch?v=${youtubeVideoId}`,
            short: false
          })
        }
        return robot.adapter.client.web.chat.postMessage(res.message.room, null, options)
      } else {
        return res.send(text)
      }
    }).catch(err => {
      robot.emit('error', err)
      res.send(`An error has occurred: ${err.message}`)
    })
  })
}
