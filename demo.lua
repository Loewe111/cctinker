local lib = require("cctinker")
local screen = lib:new(term)

local lorem = "> Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptate repellendus omnis, adipisci deleniti quo eos explicabo nesciunt!"

screen:text({x=2, y=2, text = "ccTinker demo", color = colors.lime})

screen:button({x=2, y=4, text="Change the color!", color=colors.black, background=colors.blue, callback=function()
  screen:setBackground(screen.COLORS[math.random(1, #screen.COLORS)])
end})

screen:button({x=screen.X-5, y=screen.Y-1, text="Exit", color=colors.white, background=colors.red, callback=function()
  screen:exit()
end})

screen:textarea({x=2, y=6, width=45, height=5, text="cctinker is a tkinter-like Computercraft Graphics API by Loewe_111. You are reading this inside of a Textarea, which wraps its text.", color=colors.black, background=colors.white})

checkbox = screen:checkbox({x=2, y=12, text="Enable Cool Lorem Ipsum", color=colors.black, background=colors.white, callback=function(_, _, _, checked)
  toggle.state = checked
  if checked then
    screen:textarea({x=2, y=14, width=40, height=4, text=lorem, color=colors.lime, background=colors.black, id="lorem"})
  else
    screen:remove("lorem")
  end
end})

toggle = screen:switch({x=screen.X-10, y=2, text="Switch", callback=function(_, _, _, state)
  checkbox.event_click()
end})

screen:loop()