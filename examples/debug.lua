screen = require(".cctinker"):new(term, true)

screen:text{
  x=2,
  y=2,
  text="This is Text",
  color=colors.white,
  background=colors.black,
}

screen:textarea{
  x=2,
  y=4,
  width=25,
  height=2,
  color=colors.white,
  background=colors.gray,
  text="This is a Textarea, text wraps automatically.",
}

screen:button{
  x=2,
  y=7,
  text="This is a Button",
  color=colors.white,
  background=colors.green,
  callback=function()
    screen:exit()
  end
}

radioText = screen:text{
  x=2,
  y=9,
  text="This is a Radio",
  color=colors.white,
  background=colors.black,
}

screen:radio{
  x=2,
  y=10,
  color=colors.white,
  background=colors.cyan,
  options={"Option 1", "Option 2", "Option 3"},
  callback=function(index)
    radioText.text = "You selected " .. index
  end
}

screen:checkbox{
  x=2,
  y=14,
  color=colors.white,
  background=colors.orange,
  text="This is a Checkbox"
}

screen:input{
  x=2,
  y=16,
  width=25,
  placeholder="This is an Input",
  color = colors.white,
  background = colors.blue,
  placeholderColor = colors.lightBlue
}

screen:switch{
  x=28,
  y=7,
  text="This is a Switch",
  color=colors.white,
  background=colors.black,
  state=true
}

screen:inputArea{
  x=28,
  y=2,
  width=20,
  height=4,
  placeholder="This is an InputArea, which can fit multiple lines of written text.",
  color = colors.white,
  background = colors.purple,
  placeholderColor = colors.pink
}

screen:tabSwitch{
  x=2,
  y=screen.Y,
  color=colors.white,
  background=colors.lime,
  selectedColor=colors.white,
  selectedBackground=colors.cyan,
  tabs={"This", "is", "a", "Tab", "Switch"},
  callback=function(index)
    progress.progress = index/5
  end
}

progress = screen:progressBar{
  x=28,
  y=9,
  width=20,
  color=colors.white,
  background=colors.red,
  progress=0.2
}

sliderText = screen:text{
  x=28,
  y=11,
  text="This is a Slider",
  color=colors.white,
  background=colors.black,
}

slider = screen:slider{
  x=28,
  y=12,
  width=20,
  min=0,
  max=100,
  color=colors.white,
  background=colors.cyan,
  callback=function(value)
    sliderText.text = "You selected " .. value
    progress.progress = value/100
  end
}

screen:switch{
  x=28,
  y=screen.Y-2,
  text="Debug Mode",
  color=colors.white,
  background=colors.black,
  state=screen.debug,
  callback=function(_, _, _, state)
    screen.debug = state
  end
}

screen:text{
  x=28,
  y=screen.Y-1,
  text="Shows Screen Updates",
  color=colors.white,
  background=colors.black,
}

screen:loop()