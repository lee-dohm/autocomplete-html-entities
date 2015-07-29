module.exports =
  selector: '.text.html.basic, .source.gfm'

  # Public: Gets the current set of suggestions.
  #
  # * `request` Relevant editor state to inform the list of suggestions returned. It consists of:
  #   * `editor` {TextEditor} the suggestions are being requested for.
  #   * `bufferPosition` Position of the cursor in the file.
  #   * `scopeDescriptor` The [scope descriptor](https://atom.io/docs/latest/behind-atom-scoped-settings-scopes-and-scope-descriptors#scope-descriptors)
  #     for the current cursor position.
  #   * `prefix` Prefix that triggered the request for suggestions.
  getSuggestions: ({editor, bufferPosition}) ->
    prefix = @getPrefix(editor, bufferPosition)

    if prefix.length > 0
      new Promise (resolve) =>
        resolve(@buildSuggestions(prefix))
    else
      []

  buildSuggestions: (prefix) ->
    suggestions = []
    for completion in @completions
      completion.replacementPrefix = prefix
      suggestions.push(completion)

    suggestions

  loadCompletions: ->
    @completions = [
      {
        text: '&copy;'
        rightLabelHTML: '&copy;'
        description: 'copyright symbol'
      }
    ]

  getPrefix: (editor, bufferPosition) ->
    # Whatever your prefix regex might be
    regex = /&[A-Za-z0-9]+$/

    # Get the text for the line up to the triggered buffer position
    line = editor.getTextInRange([[bufferPosition.row, 0], bufferPosition])

    # Match the regex to the line, and return the first capture
    line.match(regex)?[0] or ''
