-- Computercraft tkinter like Screen Library

local screenlib = {}

function screenlib:new(termObject)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.term = termObject or term
  self.screenObjects = {}
  self.background = colors.black
  self.COLORS = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
  return o
end

function screenlib:_draw()
  self.term.setBackgroundColor(self.background)
  self.term.clear()
  for i, v in pairs(self.screenObjects) do
    v:draw()
  end
end

function screenlib:_generateId()
  local chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz1234567890"
  local id
  repeat
    id = ""
    for i = 1, 16 do
      local charIndex = math.random(1, #chars)
      id = id .. string.sub(chars, charIndex, charIndex)
    end
  until self.screenObjects[id] == nil
  return id
end

function screenlib:loop()
  local eventLoop = function()
    while self.looping do
      local event, button, x, y = os.pullEvent()
      if event == "mouse_click" then
        for i, obj in pairs(self.screenObjects) do
          if obj ~= nil then
            if obj.click ~= nil and y >= obj.y and y <= obj.y + obj.height - 1 and x >= obj.x and x <= obj.x + obj.width - 1 then
              obj:click()
            end
          end
        end
      end
    end
  end
  local drawLoop = function()
    while self.looping do
      self:_draw()
      sleep(0.05)
    end
  end
  self.looping = true
  parallel.waitForAny(eventLoop, drawLoop)
end

function screenlib:setBackground(color)
  self.background = color
end

function screenlib:stopLoop()
  self.looping = false
end

function screenlib:getObject(id)
  return self.screenObjects[id]
end

function screenlib:getSize()
  return self.term.getSize()
end

function screenlib:remove(screenObject)
  if type(screenObject) == "string" then
    self.screenObjects[screenObject] = nil
  else
    self.screenObjects[screenObject.id] = nil
  end
end

function screenlib:clear()
  self.screenObjects = {}
end

function screenlib:text(x, y, text, color, background, id)
  local id =  id or self:_generateId()
  local textObject = {
    id = id,
    type = "text",
    x = x,
    y = y,
    width = #text,
    height = 1,
    text = text,
    color = color,
    background = background
  }
  textObject.draw = function()
    self.term.setCursorPos(textObject.x, textObject.y)
    self.term.setTextColor(textObject.color)
    self.term.setBackgroundColor(textObject.background)
    self.term.write(textObject.text)
  end
  self.screenObjects[id] = textObject
  return textObject
end

function screenlib:textarea(x, y, width, height, text, color, background, id)
  local id =  id or self:_generateId()
  local textareaObject = {
    id = id,
    type = "textarea",
    x = x,
    y = y,
    width = width,
    height = height,
    text = text,
    color = color,
    background = background
  }
  textareaObject.draw = function()
    self.term.setTextColor(textareaObject.color)
    self.term.setBackgroundColor(textareaObject.background)
    local ccstrings = require("cc.strings")
    local texts = ccstrings.wrap(textareaObject.text, textareaObject.width)
    for i = 1, textareaObject.height do
      local text = ccstrings.ensure_width(texts[i] or "", textareaObject.width)
      self.term.setCursorPos(textareaObject.x, textareaObject.y + i - 1)
      self.term.write(text)
    end
  end
  self.screenObjects[id] = textareaObject
  return textareaObject
end

function screenlib:button(x, y, text, color, background, callback, id)
  local id =  id or self:_generateId()
  local buttonObject = {
    id = id,
    type = "button",
    x = x,
    y = y,
    width = #text,
    height = 1,
    text = text,
    color = color,
    background = background,
    click = callback
  }
  buttonObject.draw = function()
    self.term.setCursorPos(buttonObject.x, buttonObject.y)
    self.term.setTextColor(buttonObject.color)
    self.term.setBackgroundColor(buttonObject.background)
    self.term.write(buttonObject.text)
  end
  self.screenObjects[id] = buttonObject
  return buttonObject
end

function screenlib:checkbox(x, y, text, color, background, callback, id)
  local id =  id or self:_generateId()
  local checkboxObject = {
    id = id,
    type = "checkbox",
    x = x,
    y = y,
    width = #text + 4,
    height = 1,
    text = text,
    color = color,
    background = background,
    checked = false
  }
  checkboxObject.draw = function()
    self.term.setCursorPos(checkboxObject.x, checkboxObject.y)
    self.term.setTextColor(checkboxObject.color)
    self.term.setBackgroundColor(checkboxObject.background)
    self.term.write("[")
    if checkboxObject.checked then
      self.term.write("X")
    else
      self.term.write(" ")
    end
    self.term.write("] " .. checkboxObject.text)
  end
  checkboxObject.click = function()
    checkboxObject.checked = not checkboxObject.checked
    if callback ~= nil then
      callback(checkboxObject.checked)
    end
  end
  self.screenObjects[id] = checkboxObject
  return checkboxObject
end

return screenlib