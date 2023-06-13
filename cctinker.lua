-- Computercraft tkinter like Screen Library

local cctinker = {}

function cctinker:new(termObject)
  local o = {}
  setmetatable(o, self)
  self.__index = self
  o.term = termObject or term
  o.X, o.Y = o.term.getSize()
  o.background = colors.black
  o.COLORS = {colors.white, colors.orange, colors.magenta, colors.lightBlue, colors.yellow, colors.lime, colors.pink, colors.gray, colors.lightGray, colors.cyan, colors.purple, colors.blue, colors.brown, colors.green, colors.red, colors.black}
  o.children = {}
  return o
end

function cctinker:_checkArgs(args, requiredArgs, optionalArgs)
  if type(args) ~= "table" then error("Args is not a table") end
  for arg_name, arg_type in pairs(requiredArgs) do
    if args[arg_name] == nil then
      error("Missing required argument: '" .. arg_name .. "' of type " .. arg_type)
    end
    if type(args[arg_name]) ~= arg_type then
      error("Argument '" .. arg_name .. "' is of type " .. type(args[arg_name]) .. ", expected " .. arg_type)
    end
  end
  for arg_name, arg_type in pairs(optionalArgs) do
    if args[arg_name] ~= nil and type(args[arg_name]) ~= arg_type then
      error("Argument '" .. arg_name .. "' is of type " .. type(args[arg_name]) .. ", expected " .. arg_type)
    end
  end
end

function cctinker:_draw()
  self.term.setBackgroundColor(self.background)
  self.term.clear()
  for i, v in pairs(self.children) do
    if v.visible == true then
      v:draw()
    end
  end
end

function cctinker:_handleEvent(event, eventData)

  if event == "mouse_click" then
    local button, x, y = eventData[2], eventData[3], eventData[4]
    for i, obj in pairs(self.children) do
      local insideBounds = (y >= obj.y and y <= obj.y + obj.height - 1 and x >= obj.x and x <= obj.x + obj.width - 1)
      if obj.visible and obj.children ~= nil and insideBounds then
        -- offset x and y
        eventData[3] = x - obj.x + 1
        eventData[4] = y - obj.y + 1
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_click ~= nil and insideBounds then
        obj.event_click(x, y, button)
      elseif obj.event_defocus ~= nil and not insideBounds then
        obj.event_defocus()
      end
    end
  elseif event == "mouse_scroll" then
    local direction, x, y = eventData[2], eventData[3], eventData[4]
    for i, obj in pairs(self.children) do
      local insideBounds = (y >= obj.y and y <= obj.y + obj.height - 1 and x >= obj.x and x <= obj.x + obj.width - 1)
      if obj.visible and obj.children ~= nil and insideBounds then
        -- offset x and y
        eventData[3] = x - obj.x + 1
        eventData[4] = y - obj.y + 1
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_scroll ~= nil and insideBounds then
        obj.event_scroll(x, y, direction)
      end
    end
  elseif event == "mouse_drag" then
    local button, x, y = eventData[2], eventData[3], eventData[4]
    for i, obj in pairs(self.children) do
      if obj.visible and obj.children then
        -- offset x and y
        eventData[3] = x - obj.x + 1
        eventData[4] = y - obj.y + 1
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_drag ~= nil then
        obj.event_drag(x, y, button)
      end
    end
  elseif event == "char" then
    local char = eventData[2]
    for i, obj in pairs(self.children) do
      if obj.visible and obj.children ~= nil then
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_char ~= nil then
        obj.event_char(char)
      end
    end
  elseif event == "key" then
    local keycode, isHeld = eventData[2], eventData[3]
    local key = keys.getName(keycode)
    for i, obj in pairs(self.children) do
      if obj.visible and obj.children ~= nil then
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_key ~= nil then
        obj.event_key(key, keycode, isHeld)
      end
    end
  elseif event == "paste" then
    local text = eventData[2]
    for i, obj in pairs(self.children) do
      if obj.visible and obj.children ~= nil then
        obj:_handleEvent(event, eventData)
      end
      if obj.visible and obj.event_paste ~= nil then
        obj.event_paste(text)
      end
    end
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
  until self.children[id] == nil
  return id
end

function cctinker:loop()
  local eventLoop = function()
    while self.looping do
      local eventData = {os.pullEvent()}
      local event = eventData[1]
      self:_handleEvent(event, eventData)
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
  return self.children[id]
end

function cctinker:remove(screenObject)
  if type(screenObject) == "string" then
    self.children[screenObject] = nil
  else
    self.children[screenObject.id] = nil
  end
end

function cctinker:clear()
  self.children = {}
end

function cctinker:getObjects()
  return self.children
end

function cctinker:setObjects(objects)
  self.children = objects
end

function cctinker:frame(args)
  local requiredArgs = {x="number", y="number", width="number", height="number"}
  local optionalArgs = {background="number", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing

  local o = self:new(window.create(self.term.current(), args.x, args.y, args.width, args.height, true)) 
  o.background = args.background or colors.black
  o.visible = args.visible == nil or args.visible == true
  o.draw = o._draw
  o.width = args.width
  o.height = args.height
  o.x = args.x
  o.y = args.y
  o.type = "frame"
  table.insert(self.children, o)
  return o
end

function cctinker:text(args)
  local requiredArgs = {x="number", y="number", text="string"}
  local optionalArgs = {color="number", background="number", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local textObject = {
    type = "text",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    visible = args.visible == nil or args.visible == true
  }
  textObject.draw = function()
    self.term.setCursorPos(textObject.x, textObject.y)
    self.term.setTextColor(textObject.color)
    self.term.setBackgroundColor(textObject.background)
    self.term.write(textObject.text)
  end
  self.children[textObject.id] = textObject
  return textObject
end

function cctinker:textarea(args)
  local requiredArgs = {x="number", y="number", width="number", height="number", text="string"}
  local optionalArgs = {color="number", background="number", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local textareaObject = {
    type = "textarea",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = args.width,
    height = args.height,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    visible = args.visible == nil or args.visible == true
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
  self.children[textareaObject.id] = textareaObject
  return textareaObject
end

function cctinker:button(args)
  local requiredArgs = {x="number", y="number", text="string", callback="function"}
  local optionalArgs = {color="number", background="number", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
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
    event_click = args.callback,
    visible = args.visible == nil or args.visible == true
  }
  buttonObject.draw = function()
    self.term.setCursorPos(buttonObject.x, buttonObject.y)
    self.term.setTextColor(buttonObject.color)
    self.term.setBackgroundColor(buttonObject.background)
    self.term.write(buttonObject.text)
  end
  self.children[buttonObject.id] = buttonObject
  return buttonObject
end

function cctinker:checkbox(args)
  local requiredArgs = {x="number", y="number", text="string"}
  local optionalArgs = {color="number", background="number", checked="boolean", callback="function", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
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
    callback = args.callback,
    visible = args.visible == nil or args.visible == true
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
  checkboxObject.event_click = function(x, y, button)
    checkboxObject.checked = not checkboxObject.checked
    if checkboxObject.callback ~= nil then
      checkboxObject.callback(x, y, button, checkboxObject.checked)
    end
  end
  self.children[checkboxObject.id] = checkboxObject
  return checkboxObject
end

function cctinker:radio(args)
  local requiredArgs = {x="number", y="number", options="table"}
  local optionalArgs = {color="number", background="number", selected="number", callback="function", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local radioObject = {
    type = "radio",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = 0,
    height = #args.options,
    options = args.options,
    color = args.color or colors.white,
    background = args.background or colors.black,
    selected = args.selected or 1,
    callback = args.callback,
    visible = args.visible == nil or args.visible == true
  }
  for i = 1, #radioObject.options do
    radioObject.width = math.max(radioObject.width, #radioObject.options[i] + 4)
  end
  radioObject.draw = function()
    for i = 1, #radioObject.options do
      self.term.setCursorPos(radioObject.x, radioObject.y + i - 1)
      self.term.setTextColor(radioObject.color)
      self.term.setBackgroundColor(radioObject.background)
      self.term.write("(")
      if radioObject.selected == i then
        self.term.write("\007")
      else
        self.term.write(" ")
      end
      self.term.write(") " .. radioObject.options[i])
    end
  end

  radioObject.event_click = function(x, y, button)
    local index = y - radioObject.y + 1
    if index >= 1 and index <= #radioObject.options then
      radioObject.selected = index
      if radioObject.callback ~= nil then
        radioObject.callback(radioObject.selected)
      end
    end
  end

  self.children[radioObject.id] = radioObject
  return radioObject
end

function cctinker:switch(args)
  local requiredArgs = {x="number", y="number", text="string"}
  local optionalArgs = {color="number", background="number", state="boolean", callback="function", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local switchObject = {
    type = "switch",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = #args.text + 4,
    height = 1,
    text = args.text,
    color = args.color or colors.white,
    background = args.background or colors.black,
    state = args.state or false,
    visible = args.visible == nil or args.visible == true
  }
  switchObject.event_click = function(x, y, button)
    switchObject.state = not switchObject.state
    if args.callback then
      args.callback(x, y, button, switchObject.state)
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
  
  self.children[switchObject.id] = switchObject 
  return switchObject
end

function cctinker:tabSwitch(args)
  local requiredArgs = {x="number", y="number", tabs="table"}
  local optionalArgs = {color="number", background="number", selectedColor="number", selectedBackground="number", selected="number", callback="function", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local tabSwitchObject = {
    type = "tabSwitch",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = 0,
    height = 1,
    tabs = args.tabs,
    color = args.color or colors.white,
    background = args.background or colors.black,
    selectedColor = args.selectedColor or colors.white,
    selectedBackground = args.selectedBackground or colors.red,
    selected = args.selected or 1,
    callback = args.callback,
    visible = args.visible == nil or args.visible == true
  }
  for i = 1, #tabSwitchObject.tabs do
    tabSwitchObject.width = tabSwitchObject.width + #tabSwitchObject.tabs[i] + 2
  end
  tabSwitchObject.draw = function()
    local x = tabSwitchObject.x
    for i = 1, #tabSwitchObject.tabs do
      self.term.setCursorPos(x, tabSwitchObject.y)
      self.term.setTextColor(tabSwitchObject.color)
      self.term.setBackgroundColor(tabSwitchObject.background)
      if tabSwitchObject.selected == i then
        self.term.setTextColor(tabSwitchObject.selectedColor)
        self.term.setBackgroundColor(tabSwitchObject.selectedBackground)
      end
      self.term.write("\149" .. tabSwitchObject.tabs[i] .. " ")
      x = x + #tabSwitchObject.tabs[i] + 2
    end
  end
  tabSwitchObject.event_click = function(x, y, button)
    local index = 1
    local tabX = tabSwitchObject.x
    for i = 1, #tabSwitchObject.tabs do
      if x >= tabX and x <= tabX + #tabSwitchObject.tabs[i] + 1 then
        index = i
        break
      end
      tabX = tabX + #tabSwitchObject.tabs[i] + 2
    end
    if index ~= tabSwitchObject.selected then
      tabSwitchObject.selected = index
      if tabSwitchObject.callback ~= nil then
        tabSwitchObject.callback(tabSwitchObject.selected)
      end
    end
  end
  
  self.children[tabSwitchObject.id] = tabSwitchObject
  return tabSwitchObject
end

function cctinker:input(args)
  local requiredArgs = {x="number", y="number", placeholder="string"}
  local optionalArgs = {color="number", placeholderColor="number", background="number", callback="function", width="number", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local inputObject = {
    type = "input",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = args.width or #args.placeholder,
    height = 1,
    placeholder = args.placeholder,
    color = args.color or colors.white,
    placeholderColor = args.placeholderColor or colors.gray,
    background = args.background or colors.black,
    callback = args.callback,
    input = {
      text = "",
      cursor = 1,
      focused = false
    },
    text = "",
    visible = args.visible == nil or args.visible == true
  }
  inputObject.draw = function()
    local ccstrings = require("cc.strings")
    self.term.setCursorPos(inputObject.x, inputObject.y)
    if inputObject.input.text == "" then
      self.term.setTextColor(inputObject.placeholderColor)
      self.term.setBackgroundColor(inputObject.background)
      self.term.write(ccstrings.ensure_width(string.sub(inputObject.placeholder, -inputObject.width), inputObject.width))
    else
      self.term.setTextColor(inputObject.color)
      self.term.setBackgroundColor(inputObject.background)
      self.term.write(ccstrings.ensure_width(string.sub(inputObject.input.text, -inputObject.width), inputObject.width))
    end
    if inputObject.input.cursor > inputObject.width then
      self.term.setCursorPos(inputObject.x + inputObject.width, inputObject.y)
    else
      self.term.setCursorPos(inputObject.x + inputObject.input.cursor - 1, inputObject.y)
    end
    self.term.setCursorBlink(inputObject.input.focused)
  end
  inputObject.event_click = function(x, y, button)
    inputObject.input.focused = true
  end
  inputObject.event_defocus = function()
    if(inputObject.input.focused) then
      inputObject.input.focused = false
      if inputObject.callback ~= nil then
        inputObject.callback(inputObject.input.text)
      end
    end
    inputObject.text = inputObject.input.text
  end
  inputObject.event_char = function(char)
    if inputObject.input.focused then
      inputObject.input.text = string.sub(inputObject.input.text, 1, inputObject.input.cursor - 1) .. char .. string.sub(inputObject.input.text, inputObject.input.cursor)
      inputObject.input.cursor = inputObject.input.cursor + 1
    end
  end
  inputObject.event_paste = function(text)
    if inputObject.input.focused then
      inputObject.input.text = string.sub(inputObject.input.text, 1, inputObject.input.cursor - 1) .. text .. string.sub(inputObject.input.text, inputObject.input.cursor)
      inputObject.input.cursor = inputObject.input.cursor + #text
    end
  end
  inputObject.event_key = function(key)
    if key == "backspace" then
      if inputObject.input.cursor > 1 then
        inputObject.input.text = string.sub(inputObject.input.text, 1, inputObject.input.cursor - 2) .. string.sub(inputObject.input.text, inputObject.input.cursor)
        inputObject.input.cursor = inputObject.input.cursor - 1
      end
    elseif key == "delete" then
      if inputObject.input.cursor <= #inputObject.input.text then
        inputObject.input.text = string.sub(inputObject.input.text, 1, inputObject.input.cursor - 1) .. string.sub(inputObject.input.text, inputObject.input.cursor + 1)
      end
    elseif key == "left" then
      if inputObject.input.cursor > 1 then
        inputObject.input.cursor = inputObject.input.cursor - 1
      end
    elseif key == "right" then
      if inputObject.input.cursor <= #inputObject.input.text then
        inputObject.input.cursor = inputObject.input.cursor + 1
      end
    elseif key == "enter" then
      inputObject.input.focused = false
      if inputObject.callback ~= nil then
        inputObject.callback(inputObject.input.text)
      end
      inputObject.text = inputObject.input.text
    end
  end
  self.children[inputObject.id] = inputObject
  return inputObject
end

function cctinker:inputArea(args)
  local requiredArgs = {x="number", y="number", width="number", height="number", placeholder="string"}
  local optionalArgs = {color="number", placeholderColor="number", background="number", callback="function", visible="boolean"}
  self:_checkArgs(args, requiredArgs, optionalArgs) -- Error if required args are missing
  local inputAreaObject = {
    type = "inputArea",
    id = args.id or self:_generateId(),
    x = args.x,
    y = args.y,
    width = args.width,
    height = args.height,
    placeholder = args.placeholder,
    color = args.color or colors.white,
    placeholderColor = args.placeholderColor or colors.gray,
    background = args.background or colors.black,
    callback = args.callback,
    input = {
      text = "",
      cursor = 1,
      focused = false
    },
    text = "",
    visible = args.visible == nil or args.visible == true
  }
  inputAreaObject.draw = function()
    local ccstrings = require("cc.strings")
    self.term.setCursorPos(inputAreaObject.x, inputAreaObject.y)
    if inputAreaObject.input.text == "" then
      self.term.setTextColor(inputAreaObject.placeholderColor)
      self.term.setBackgroundColor(inputAreaObject.background)
      local placeholder = ccstrings.wrap(inputAreaObject.placeholder, inputAreaObject.width)
      for i = 1, inputAreaObject.height do
        local text = ccstrings.ensure_width(placeholder[i] or "", inputAreaObject.width)
        self.term.setCursorPos(inputAreaObject.x, inputAreaObject.y + i - 1)
        self.term.write(text)
      end
    else
      self.term.setTextColor(inputAreaObject.color)
      self.term.setBackgroundColor(inputAreaObject.background)
      local texts = ccstrings.wrap(inputAreaObject.input.text, inputAreaObject.width)
      for i = 1, inputAreaObject.height do
        local text = ccstrings.ensure_width(texts[i] or "", inputAreaObject.width)
        self.term.setCursorPos(inputAreaObject.x, inputAreaObject.y + i - 1)
        self.term.write(text)
      end
    end
    if inputAreaObject.input.cursor > inputAreaObject.width then
      self.term.setCursorPos(inputAreaObject.x + inputAreaObject.width, inputAreaObject.y)
    else
      self.term.setCursorPos(inputAreaObject.x + inputAreaObject.input.cursor - 1, inputAreaObject.y)
    end
    self.term.setCursorBlink(inputAreaObject.input.focused)
  end
  inputAreaObject.event_click = function(x, y, button)
    inputAreaObject.input.focused = true
  end
  inputAreaObject.event_defocus = function()
    if(inputAreaObject.input.focused) then
      inputAreaObject.input.focused = false
      if inputAreaObject.callback ~= nil then
        inputAreaObject.callback(inputAreaObject.input.text)
      end
    end
    inputAreaObject.text = inputAreaObject.input.text
  end
  inputAreaObject.event_char = function(char)
    if inputAreaObject.input.focused then
      inputAreaObject.input.text = string.sub(inputAreaObject.input.text, 1, inputAreaObject.input.cursor - 1) .. char .. string.sub(inputAreaObject.input.text, inputAreaObject.input.cursor)
      inputAreaObject.input.cursor = inputAreaObject.input.cursor + 1
    end
  end
  inputAreaObject.event_paste = function(text)
    if inputAreaObject.input.focused then
      inputAreaObject.input.text = string.sub(inputAreaObject.input.text, 1, inputAreaObject.input.cursor - 1) .. text .. string.sub(inputAreaObject.input.text, inputAreaObject.input.cursor)
      inputAreaObject.input.cursor = inputAreaObject.input.cursor + #text
    end
  end
  inputAreaObject.event_key = function(key)
    if key == "backspace" then
      if inputAreaObject.input.cursor > 1 then
        inputAreaObject.input.text = string.sub(inputAreaObject.input.text, 1, inputAreaObject.input.cursor - 2) .. string.sub(inputAreaObject.input.text, inputAreaObject.input.cursor)
        inputAreaObject.input.cursor = inputAreaObject.input.cursor - 1
      end
    elseif key == "delete" then
      if inputAreaObject.input.cursor <= #inputAreaObject.input.text then
        inputAreaObject.input.text = string.sub(inputAreaObject.input.text, 1, inputAreaObject.input.cursor - 1) .. string.sub(inputAreaObject.input.text, inputAreaObject.input.cursor + 1)
      end
    elseif key == "left" then
      if inputAreaObject.input.cursor > 1 then
        inputAreaObject.input.cursor = inputAreaObject.input.cursor - 1
      end
    elseif key == "right" then
      if inputAreaObject.input.cursor <= #inputAreaObject.input.text then
        inputAreaObject.input.cursor = inputAreaObject.input.cursor + 1
      end
    elseif key == "up" then
      if inputAreaObject.input.cursor > inputAreaObject.width then
        inputAreaObject.input.cursor = inputAreaObject.input.cursor - inputAreaObject.width
      end
    elseif key == "down" then
      if inputAreaObject.input.cursor <= #inputAreaObject.input.text - inputAreaObject.width then
        inputAreaObject.input.cursor = inputAreaObject.input.cursor + inputAreaObject.width
      end
    elseif key == "enter" then
      inputAreaObject.input.focused = false
      if inputAreaObject.callback ~= nil then
        inputAreaObject.callback(inputAreaObject.input.text)
      end
      inputAreaObject.text = inputAreaObject.input.text
    end
  end

  self.children[inputAreaObject.id] = inputAreaObject
  return inputAreaObject
end

return cctinker