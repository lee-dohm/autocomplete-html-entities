CSON = require 'season'
{filter} = require 'fuzzaldrin'

module.exports =
  selector: '.text.html.basic, .source.gfm'

  # Public: Gets the current set of suggestions.
  #
  # * `request` Relevant editor state to inform the list of suggestions returned. It consists of:
  #   * `editor` {TextEditor} the suggestions are being requested for.
  #   * `bufferPosition` Position {Point} of the cursor in the file.
  #   * `scopeDescriptor` The [scope descriptor](https://atom.io/docs/latest/behind-atom-scoped-settings-scopes-and-scope-descriptors#scope-descriptors)
  #     for the current cursor position.
  #   * `prefix` Prefix that triggered the request for suggestions.
  #
  # Returns a {Promise} that resolves to the list of suggestions or returns an empty list
  # immediately.
  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)
    return [] unless prefix.length > 0

    new Promise (resolve) =>
      resolve(@buildSuggestions(prefix))

  # Public: Loads the full set of completions.
  loadCompletions: ->
    @completions = []
    path = CSON.resolve("#{__dirname}/../data/completions")
    CSON.readFile path, (error, object) =>
      return if error?

      {completions} = object
      @completions = for description, entity of completions
        {
          text: entity
          rightLabelHTML: entity
          description: description
          type: 'constant'
        }

  # Private: Builds the list of suggestions from the current set of completions and the `prefix`.
  #
  # Once the list of suggestions is built, it is ranked and filtered using the fuzzaldrin library.
  #
  # * `prefix` {String} containing the text to match and replace.
  #
  # Returns a list of applicable suggestions.
  buildSuggestions: (prefix) ->
    suggestions = []
    for completion in @completions
      completion.replacementPrefix = prefix
      suggestions.push(completion)

    filter(suggestions, prefix, key: 'text')

  # Private: Gets the appropriate prefix text to search for.
  #
  # * `editor` {TextEditor} where the autocompletion was requested.
  # * `bufferPosition` A {Point} or point-compatible {Array} indicating where the cursor is located.
  #
  # Returns a {String} containing the prefix text.
  getPrefix: (editor, bufferPosition) ->
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

    line.match(/&[A-Za-z0-9]+$/)?[0] or ''
