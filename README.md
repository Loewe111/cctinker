# `cctinker`, a tkinter-like Computercraft Graphics API

![grafik](https://user-images.githubusercontent.com/78087018/233185599-eb1d55aa-c96a-4d94-8621-ce2b0b83ff19.png)

## How to use

1. Install using `wget https://raw.githubusercontent.com/Loewe111/cctinker/master/cctinker.lua`
2. Import using `local cctinker = require("cctinker")`
3. Create a screen object using `local screen = cctinker:new(term)`
4. At the end of your program, call `screen:loop()` to start the event loop

Example:

```lua
local cctinker = require("cctinker")
local screen = cctinker:new(term)

screen:text({x=1, y=1, text="Hello, world!", color=colors.white, background=colors.black})

screen:loop()
```

## Important notes

- The event loop is blocking, so it will not return until the program is closed
- The cctinker API is object-oriented, meaning you need to call functions with a colon, not a dot (`screen:loop()` instead of `screen.loop`)

## Documentation

Documentation is available at [the wiki](https://github.com/Loewe111/cctinker/wiki)

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details
