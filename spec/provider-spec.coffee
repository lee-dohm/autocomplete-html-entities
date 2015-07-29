provider = require '../lib/provider'

describe 'provider', ->
  beforeEach ->
    provider.loadCompletions()

  it 'returns an empty list for an invalid request', ->
    expect(provider.getSuggestions()).toEqual([])

  it 'returns a non-empty list for a valid request', ->
    request =
      editor: {}
      bufferPosition: [7, 11]
      scopeDescriptor: ['text.html.basic']
      prefix: '&'

    expect(provider.getSuggestions(request)).not.toEqual([])
