window.CommandZ = require('commandz')
var img = document.getElementById('img'),
    ul = document.getElementById('list'),
    width = document.getElementById('width'),
    height = document.getElementById('height'),
    form = document.getElementById('form'),
    buttons = {
      undo: document.getElementById('undo'),
      redo: document.getElementById('redo')
    }

// Capitalize
String.prototype.capitalize = function() {
 return this.charAt(0).toUpperCase() + this.slice(1)
}

// Size
window.handleInput = function(type) {
  var ratio = 400 / 215

  if (type == 'width') { height.value = width.value / ratio }
  else                 { width.value = height.value * ratio }
}

form.addEventListener('submit', function(e) {
  e.preventDefault()
  if (!width.value || !height.value) { return }
  addSize({ width: width.value, height: height.value })
  width.value = height.value = ''
})

var handleSize = function(size) {
  img.width = size.width
  img.height = size.height
}

var addSize = function(size) {
  CommandZ.store(size)
  handleSize(size)
}

var resetList = function() {
  html = ''
  for (var i = 0; i < CommandZ.history.length; i++) {
    command = CommandZ.history[i]
    data = command.data
    object = '{ width: ' + data.width + ', height: ' + data.height + ' }'
    if (i == CommandZ.index) {
      object = '<span class="current">' + object + '</span>'
    }

    html += '<li>' + object + '</li>'
  }

  ul.innerHTML = html
}

// Handle status
CommandZ.onStatusChange(function(status) {
  var actions = ['undo', 'redo']
  resetList()

  for (var i = 0; i < actions.length; i++) {
    var action = actions[i],
        canDo = status['can' + action.capitalize()],
        button = buttons[action]

    if (canDo) { attributes = ['_href', 'href'] }
    else       { attributes = ['href', '_href'] }

    attrToRemove = attributes[0]
    attrToAdd = attributes[1]

    if (button.hasAttribute(attrToRemove)) {
      button.setAttribute(attrToAdd, button.getAttribute(attrToRemove))
      button.removeAttribute(attrToRemove)
    }
  }
})

// Default value
CommandZ.onStorageChange(handleSize)
addSize({ width: 400, height: 215 })
