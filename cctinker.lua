-- Computercraft tkinter like Screen Library

local cctinker = {}

function cctinker:new(termObject)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  self.term = termObject or term
  self.screenObjects = {}
  self.background = colors.black
  self.COLORS = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
  local x, y = self.term.getSize()
  self.X = x
  self.Y = y
  return o
end

function cctinker:_checkArgs(args, requiredArgs)
  if type(args) ~= "table" then error("Args is not a table") end
  for i, v in pairs(requiredArgs) do
    if args[v] == nil then
      error("Missing required argument: " .. v)
    end
  end
end

function cctinker:_draw()
  self.term.setBackgroundColor(self.background)
  self.term.clear()
  for i, v in pairs(self.screenObjects) do
    v:draw()
  end
end

function cctinker:_generateId()
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

function cctinker:loop()
  local eventLoop = function()
    while self.looping do
      local event, button, x, y = os.pullEvent()
      if event == "mouse_click" then
        for i, obj in pairs(self.screenObjects) do
          if obj ~= nil then
            if obj.click ~= nil and y >= obj.y and y <= obj.y + obj.height - 1 and x >= obj.x and x <= obj.x + obj.width - 1 then
              obj:click(x, y, button)
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

function cctinker:setBackground(color)
  self.background = color
end

function cctinker:stopLoop()
  self.looping = false
end

function cctinker:exit()
  self:stopLoop()
  self.term.setTextColor(colors.white)
  self.term.setBackgroundColor(colors.black)
  self.term.clear()
  self.term.setCursorPos(1, 1)
end

function cctinker:getObject(id)
  return self.screenObjects[id]
end

function cctinker:remove(screenObject)
  if type(screenObject) == "string" then
    self.screenObjects[screenObject] = nil
  else
    self.screenObjects[screenObject.id] = nil
  end
end

function cctinker:clear()
  self.screenObjects = {}
end

function cctinker:text(args)
  local requiredArgs = {"x", "y", "text"}
  self:_checkArgs(args, requiredArgs) -- Error if required args are missing
  local textObject = {
    type = "text",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black
  }
  textObject.draw = function()
    self.term.setCursorPos(textObject.x, textObject.y)
    self.term.setTextColor(textObject.color)
    self.term.setBackgroundColor(textObject.background)
    self.term.write(textObject.text)
  end
  self.screenObjects[textObject.id] = textObject
  return textObject
end

function cctinker:textarea(args)
  local requiredArgs = {"x", "y", "width", "height", "text"}
  self:_checkArgs(args, requiredArgs) -- Error if required args are missing
  local textareaObject = {
    type = "textarea",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = args.width,
    height = args.height,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black
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
  self.screenObjects[textareaObject.id] = textareaObject
  return textareaObject
end

function cctinker:button(args)
  local requiredArgs = {"x", "y", "text", "callback"}
  self:_checkArgs(args, requiredArgs) -- Error if required args are missing
  local buttonObject = {
    type = "button",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    click = args.callback
  }
  buttonObject.draw = function()
    self.term.setCursorPos(buttonObject.x, buttonObject.y)
    self.term.setTextColor(buttonObject.color)
    self.term.setBackgroundColor(buttonObject.background)
    self.term.write(buttonObject.text)
  end
  self.screenObjects[buttonObject.id] = buttonObject
  return buttonObject
end

function cctinker:checkbox(args)
  local requiredArgs = {"x", "y", "text"}
  self:_checkArgs(args, requiredArgs) -- Error if required args are missing
  local checkboxObject = {
    type = "checkbox",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text + 4,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    checked = args.checked or false,
    callback = args.callback
  }
  checkboxObject.draw = function()
    self.term.setCursorPos(checkboxObject.x, checkboxObject.y)
    self.term.setTextColor(checkboxObject.color)
    self.term.setBackgroundColor(checkboxObject.background)
    self.term.write("[")
    if checkboxObject.checked then
      self.term.write("x")
    else
      self.term.write(" ")
    end
    self.term.write("] " .. checkboxObject.text)
  end
  checkboxObject.click = function(x, y, button)
    checkboxObject.checked = not checkboxObject.checked
    if checkboxObject.callback ~= nil then
      checkboxObject.callback(x, y, button, checkboxObject.checked)
    end
  end
  self.screenObjects[checkboxObject.id] = checkboxObject
  return checkboxObject
end

function cctinker:toggleSwitch(args)
  local requiredArgs = {"x", "y", "text"}
  self:_checkArgs(args, requiredArgs) -- Error if required args are missing
  local switchObject = {
    type = "toggleSwitch",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text + 4,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    state = args.state or false,
  }
  switchObject.click = function(x, y, button)
    switchObject.state = not switchObject.state
    if args.click then
      args.click(x, y, button, switchObject.state)
    end
  end
  switchObject.draw = function()
    self.term.setCursorPos(switchObject.x, switchObject.y)
    self.term.setTextColor(colors.white)
    if switchObject.state then
      self.term.setBackgroundColor(colors.lime)
      self.term.write("  \127")
    else
      self.term.setBackgroundColor(colors.red)
      self.term.write("\127  ")
    end
    self.term.setTextColor(switchObject.color)
    self.term.setBackgroundColor(switchObject.background)
    self.term.write(" " .. switchObject.text)
  end
  
  self.screenObjects[switchObject.id] = switchObject 
  return switchObject
end

return cctinker