React = require 'react'
Director = require 'director'

{section,input,ul,div,header,h1} = React.DOM

TodoFooter = require './footer.coffee'
TodoItem = require './todoItem.coffee'
TodoModel = require './todoModel.coffee'

ALL_TODOS = 'all'
ACTIVE_TODOS = 'active'
COMPLETED_TODOS = 'completed'

ENTER_KEY = 13

TodoApp = React.createClass
  getInitialState: ->
    {
      nowShowing: ALL_TODOS
      editing: null
    }

  componentDidMount: ->
    setState = @setState
    router = Director.Router({
      '/': setState.bind(this,{nowShowing: ALL_TODOS})
      '/active': setState.bind(this,{nowShowing: ACTIVE_TODOS})
      '/completed': setState.bind(this,{nowShowing: COMPLETED_TODOS})
      })
    router.init('/')
    return

  handleNewTodoKeyDown: (event) ->
    if (event.which isnt ENTER_KEY)
      return

    val = @refs.newField.getDOMNode().value.trim()

    if val?.length
      @props.model.addTodo val
      @refs.newField.getDOMNode().value = ''
    
    return false

  toggleAll: (event) ->
    checked = event.target.checked
    @props.model.toggleAll checked
    return

  toggle: (todoToToggle) ->
    @props.model.toggle todoToToggle
    return
  
  destroy: (todoToDestroy) ->
    @props.model.destroy todoToDestroy
    return

  # refer to todoItem.js handleEdit for the reasoning behind the
  # callback
  edit: (todo, callback) ->
    @setState {editing: todo.id}, (->callback())
    return

  save: (todoToSave, text) ->
    @props.model.save todoToSave, text
    @setState {editing: null}
    return

  cancel: ()->
    @setState {editing: null}
    return

  clearCompleted: () ->
    @props.model.clearCompleted()
    return
  

  render: ()->
    todos = @props.model.todos

    # TODO remove parentheses
    shownTodos = (
      todo for todo in todos when (
        switch @state.nowShowing
          when ACTIVE_TODOS then (not todo.completed)
          when COMPLETED_TODOS then (todo.completed)
          else true
        )
      )

    activeTodoCount = todos.reduce(
      ((accum, todo) -> (if todo.completed then accum else accum + 1)),
      0
      )

    completedCount = todos.length - activeTodoCount

    todoItems =
      for todo in shownTodos
        TodoItem {
          key:todo.id
          todo:todo
          onToggle:@toggle.bind(this, todo)
          onDestroy:@destroy.bind(this, todo)
          onEdit:@edit.bind(this, todo)
          editing:@state.editing is todo.id
          onSave:@save.bind(this, todo)
          onCancel:@cancel
        }

    footer =
      if activeTodoCount > 0 or completedCount > 0
        TodoFooter {
          count:activeTodoCount
          completedCount:completedCount
          nowShowing:@state.nowShowing
          onClearCompleted:@clearCompleted
        }
      else
        null


    main =
      if todos.length >0
        section {id:'main'},
          input {
            id:'toggle-all',
            type:'checkbox',
            onChange:@toggleAll,
            checked:activeTodoCount is 0
            }
          ul {id:'todo-list'},
            todoItems
      else
        null

    div {},
      header {id:'header'},
        h1 {}, 'todos'
        input {
          ref:'newField',
          id:'new-todo',
          placeholder:'What needs to be done?',
          onKeyDown:@handleNewTodoKeyDown,
          autoFocus:true
          }
      main
      footer

model = new TodoModel('react-todos')

render = () ->
  React.renderComponent(
    TodoApp({model:model}),
    document.getElementById('todoapp')
  )

model.subscribe(render)

render()
