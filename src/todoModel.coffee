Utils = require './utils.coffee'

# Note: its usually better to use immutable data structures since theyre
# easier to reason about and React works very well with them. Thats why we
# use map() and filter() everywhere instead of mutating the array or todo
# items themselves.
class TodoModel
  constructor: (key) ->
    @key=key
    @todos = Utils.store key
    @onChanges = []

  subscribe: (onChange) ->
    @onChanges.push(onChange)
    return

  inform: ->
    Utils.store(@key, @todos)
    for onChange in @onChanges
      onChange()
    return

  addTodo: (title) ->
    @todos = @todos.concat { id: Utils.uuid(), title: title, completed: false}
    @inform()

  toggleAll: (checked) ->
    @todos = for todo in @todos
      Utils.extend {}, todo, {completed: checked}
    @inform()

  toggle: (todoToToggle) ->
    @todos = for todo in @todos
      if todo isnt todoToToggle
        todo
      else
        Utils.extend {}, todo, {completed: !todo.completed}
    @inform()

  destroy: (todoToDestroy) ->
    @todos = for todo in @todos when todo isnt todoToDestroy
      todo
    @inform()

  save: (todoToSave, text) ->
    @todos = for todo in @todos
      if todo isnt todoToSave
        todo
      else
        Utils.extend {}, todo, {title: text}
    @inform()

  clearCompleted: ->
    @todos = for todo in @todos when not todo.completed
      todo
    @inform()

module.exports = TodoModel
