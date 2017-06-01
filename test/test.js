'use strict'

require('coffee-script/register')
const Helper = require('hubot-test-helper')
const expect = require('chai').expect
const proxyquire = require('proxyquire')

class KitsuStub {
  searchAnime (query, offset) {
    return new Promise((resolve, reject) => {
      const result = {
        ageRating: 'PG',
        averageRating: '3.52',
        titles: {
          canonical: 'One Piece'
        },
        coverImage: {
          original: 'http://coverImage.png'
        },
        endDate: null,
        episodeCount: null,
        episodeLength: 24,
        popularityRank: 1234,
        posterImage: {
          original: 'http://posterImage.png'
        },
        ratingRank: 2345,
        slug: 'one-piece',
        startDate: '2000-01-01',
        synopsis: 'Gol D. Roger was known as the Pirate King',
        youtubeVideoId: 'um-tFlVamOI'
      }
      if (query === 'not found') {
        resolve([])
      } else if (query === 'error') {
        reject(new Error('Server error'))
      } else if (query === 'endDate') {
        result.endDate = '2002-01-01'
        result.episodeCount = 25
        result.youtubeVideoId = null
        result.coverImage = null
        resolve([result])
      } else if (query === 'endDate2') {
        const nextYear = (new Date()).getFullYear() + 1
        result.endDate = `${nextYear}-01-01`
        result.episodeCount = 25
        result.coverImage = null
        result.posterImage = null
        resolve([result])
      } else {
        resolve([result])
      }
    })
  };
};

class FuseStub {
  constructor (list, options) {
    this.list = list
    this.options = options
  }

  search () {
    return this.list
  };
}

proxyquire('./../src/script.js', {
  'kitsu.js': KitsuStub,
  'fuse.js': FuseStub
})

const helper = new Helper('./../src/index.js')

describe('hubot-kitsu', function () {
  beforeEach(() => {
    this.room = helper.createRoom()
  })
  afterEach(() => {
    this.room.destroy()
  })
  context('Server error', () => {
    beforeEach(done => {
      this.room.user.say('user', 'hubot kitsu error')
      this.room.robot.adapter.client = {
        web: {
          chat: {
            postMessage: (channel, text, options) => {
              this.postMessage = {
                channel: channel,
                text: text,
                options: options
              }
            }
          }
        }
      }
      setTimeout(done, 100)
    })
    it('should respond with an error', () => {
      expect(this.room.messages).to.eql([['user', 'hubot kitsu error'], ['hubot', 'An error has occurred: Server error']])
    })
  })
  context('Not found', () => {
    beforeEach(done => {
      this.room.user.say('user', 'hubot kitsu not found')
      this.room.robot.adapter.client = {
        web: {
          chat: {
            postMessage: (channel, text, options) => {
              this.postMessage = {
                channel: channel,
                text: text,
                options: options
              }
            }
          }
        }
      }
      setTimeout(done, 100)
    })
    it('should respond with an not found', () => {
      expect(this.room.messages).to.eql([['user', 'hubot kitsu not found'], ['hubot', 'Not found *not found*']])
    })
  })
  context('Get data', () => {
    beforeEach(done => {
      this.room.user.say('user', 'hubot kitsu one piece')
      this.room.robot.adapter.client = {
        web: {
          chat: {
            postMessage: (channel, text, options) => {
              this.postMessage = {
                channel: channel,
                text: text,
                options: options
              }
              done()
            }
          }
        }
      }
    })
    it('should respond with results', done => {
      expect(this.postMessage.text).to.eql(null)
      expect(this.postMessage.options.as_user).to.eql(false)
      expect(this.postMessage.options.username).to.eql('Kitsu')
      expect(this.postMessage.options.icon_url).to.eql('https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png')
      expect(this.postMessage.options.link_names).to.equal(1)
      expect(this.postMessage.options.attachments).to.eql([
        {
          fallback: 'One Piece\n' + 'Gol D. Roger was known as the Pirate King\n' + 'Average Rating: :star2: 3.52\n' + 'Popularity Rank: :heart: 1234\n' + 'Rating Rank: :star: 2345\n' + 'Rating: PG\n' + 'Aired: 2000-01-01\n' + 'Status: Currently Airing\n' + 'Duration: 24 min\n' + 'Video: https://www.youtube.com/watch?v=um-tFlVamOI',
          color: '#36a64f',
          title: 'One Piece',
          title_link: 'https://kitsu.io/anime/one-piece',
          text: 'Gol D. Roger was known as the Pirate King',
          fields: [
            {
              short: true,
              title: 'Average Rating',
              value: ':star2: 3.52'
            }, {
              short: true,
              title: 'Popularity Rank',
              value: ':heart: 1234'
            }, {
              short: true,
              title: 'Rating Rank',
              value: ':star: 2345'
            }, {
              short: true,
              title: 'Rating',
              value: 'PG'
            }, {
              short: true,
              title: 'Aired',
              value: '2000-01-01'
            }, {
              short: true,
              title: 'Status',
              value: 'Currently Airing'
            }, {
              short: true,
              title: 'Duration',
              value: '24 min'
            }, {
              short: false,
              title: 'Video',
              value: 'https://www.youtube.com/watch?v=um-tFlVamOI'
            }
          ],
          image_url: 'http://coverImage.png'
        }
      ])
      done()
    })
  })
  context('Get data with end date', () => {
    beforeEach(done => {
      this.room.user.say('user', 'hubot kitsu endDate')
      this.room.robot.adapter.client = {
        web: {
          chat: {
            postMessage: (channel, text, options) => {
              this.postMessage = {
                channel: channel,
                text: text,
                options: options
              }
              done()
            }
          }
        }
      }
    })
    it('should respond with results', done => {
      expect(this.postMessage.text).to.eql(null)
      expect(this.postMessage.options.as_user).to.eql(false)
      expect(this.postMessage.options.username).to.eql('Kitsu')
      expect(this.postMessage.options.icon_url).to.eql('https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png')
      expect(this.postMessage.options.link_names).to.equal(1)
      expect(this.postMessage.options.attachments).to.eql([
        {
          fallback: 'One Piece\n' + 'Gol D. Roger was known as the Pirate King\n' + 'Average Rating: :star2: 3.52\n' + 'Popularity Rank: :heart: 1234\n' + 'Rating Rank: :star: 2345\n' + 'Rating: PG\n' + 'Aired: 2000-01-01\n' + 'Status: Finished Airing\n' + 'Eposides: 25\n' + 'Duration: 24 min\n',
          color: '#36a64f',
          title: 'One Piece',
          title_link: 'https://kitsu.io/anime/one-piece',
          text: 'Gol D. Roger was known as the Pirate King',
          fields: [
            {
              short: true,
              title: 'Average Rating',
              value: ':star2: 3.52'
            }, {
              short: true,
              title: 'Popularity Rank',
              value: ':heart: 1234'
            }, {
              short: true,
              title: 'Rating Rank',
              value: ':star: 2345'
            }, {
              short: true,
              title: 'Rating',
              value: 'PG'
            }, {
              short: true,
              title: 'Aired',
              value: '2000-01-01'
            }, {
              short: true,
              title: 'Status',
              value: 'Finished Airing'
            }, {
              short: true,
              title: 'Eposides',
              value: 25
            }, {
              short: true,
              title: 'Duration',
              value: '24 min'
            }
          ],
          image_url: 'http://posterImage.png'
        }
      ])
      done()
    })
  })
  context('Get data with end date 2', () => {
    beforeEach(done => {
      this.room.user.say('user', 'hubot kitsu endDate2')
      this.room.robot.adapter.client = {
        web: {
          chat: {
            postMessage: (channel, text, options) => {
              this.postMessage = {
                channel: channel,
                text: text,
                options: options
              }
              done()
            }
          }
        }
      }
    })
    it('should respond with results', done => {
      expect(this.postMessage.text).to.eql(null)
      expect(this.postMessage.options.as_user).to.eql(false)
      expect(this.postMessage.options.username).to.eql('Kitsu')
      expect(this.postMessage.options.icon_url).to.eql('https://kitsu.io/favicon-32x32-3e0ecb6fc5a6ae681e65dcbc2bdf1f17.png')
      expect(this.postMessage.options.link_names).to.equal(1)
      expect(this.postMessage.options.attachments).to.eql([
        {
          fallback: 'One Piece\n' + 'Gol D. Roger was known as the Pirate King\n' + 'Average Rating: :star2: 3.52\n' + 'Popularity Rank: :heart: 1234\n' + 'Rating Rank: :star: 2345\n' + 'Rating: PG\n' + 'Aired: 2000-01-01\n' + 'Status: Currently Airing\n' + 'Eposides: 25\n' + 'Duration: 24 min\n' + 'Video: https://www.youtube.com/watch?v=um-tFlVamOI',
          color: '#36a64f',
          title: 'One Piece',
          title_link: 'https://kitsu.io/anime/one-piece',
          text: 'Gol D. Roger was known as the Pirate King',
          fields: [
            {
              short: true,
              title: 'Average Rating',
              value: ':star2: 3.52'
            }, {
              short: true,
              title: 'Popularity Rank',
              value: ':heart: 1234'
            }, {
              short: true,
              title: 'Rating Rank',
              value: ':star: 2345'
            }, {
              short: true,
              title: 'Rating',
              value: 'PG'
            }, {
              short: true,
              title: 'Aired',
              value: '2000-01-01'
            }, {
              short: true,
              title: 'Status',
              value: 'Currently Airing'
            }, {
              short: true,
              title: 'Eposides',
              value: 25
            }, {
              short: true,
              title: 'Duration',
              value: '24 min'
            }, {
              short: false,
              title: 'Video',
              value: 'https://www.youtube.com/watch?v=um-tFlVamOI'
            }
          ]
        }
      ])
      done()
    })
  })
})
