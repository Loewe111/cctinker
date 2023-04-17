lib = require("cctinker")
screen = lib:new(term)

lorem = "> Lorem ipsum dolor sit amet consectetur adipisicing elit. Voluptate repellendus omnis, adipisci deleniti quo eos explicabo nesciunt!"

screen:text(10, 2, "ccTinker Demo by Loewe_111", colors.lime, colors.black)

screen:button(2, 4, "Change the color!", colors.black, colors.blue, function()
  screen:setBackground(screen.COLORS[math.random(1, #screen.COLORS)])
end)

screen:button(2, 2, "EXIT", colors.red, colors.black, function()
  screen:clear()
  screen:stopLoop()
end)

screen:textarea(2, 6, 45, 5, "cctinker is a tkinter-like Computercraft Graphics API by Loewe_111. You are reading this inside of a Textarea, which wraps its text.", colors.black, colors.white)

screen:checkbox(2, 12, "Enable Cool Lorem Ipsum", colors.black, colors.white, function(checked)
  if checked then
    screen:textarea(2, 14, 40, 4, lorem, colors.lime, colors.black, "lorem")
  else
    screen:remove("lorem")
  end
end)

screen:loop()