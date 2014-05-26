React = require 'react/addons'
Utils = require './utils.coffee'

ALL_TODOS = 'all'
ACTIVE_TODOS = 'active'
COMPLETED_TODOS = 'completed'

{button,footer,span,strong,ul,li,a} = React.DOM

TodoFooter = React.createClass
  render: ->
    activeTodoWord = Utils.pluralize(@props.count, 'item')
    
    clearButton =
      if @props.completedCount > 0
        button {id:"clear-completed",onClick:@props.onClearCompleted},
          "Clear completed (#{@props.completedCount})"
      else
        null

    #React idiom for shortcutting to classSet since it'll be used often
    cx = React.addons.classSet

    nowShowing = @props.nowShowing
    
    footer {id:'footer'},
      span {id:'todo-count'},
        (strong {}, @props.count)
        "#{activeTodoWord} left"
      ul {id:'filters'},
        li {},
          a {
            href:'#/'
            className:cx({selected: (nowShowing is ALL_TODOS)})
            },
            'All'
        ' '
        li {},
          a {
            href:'#/active'
            className:cx({selected: (nowShowing is ACTIVE_TODOS)})
            },
            'Active'
        ' '
        li {},
          a {
            href:'#/completed'
            className:cx({selected: (nowShowing is COMPLETED_TODOS)})
            },
            'Completed'
      clearButton

module.exports = TodoFooter