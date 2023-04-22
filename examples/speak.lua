screen = require(".cctinker"):new()

function speak(text)
  local url = "https://music.madefor.cc/tts?text=" .. textutils.urlEncode(text) .. "&voice=" .. languages[language]
  local response, err = http.get { url = url, binary = true }
  if not response then error(err, 0) end

  local speaker = peripheral.find("speaker")
  local decoder = require("cc.audio.dfpwm").make_decoder()

  while true do
    local chunk = response.read(16 * 128)
    if not chunk then break end

    local buffer = decoder(chunk)
    while not speaker.playAudio(buffer) do
      os.pullEvent("speaker_audio_empty")
    end
  end
end

screen:setBackground(colors.cyan)

language = 1
languages = {
  "en",
  "de",
  "fr",
  "es",
  "et",
  "nl",
}
language_names = {
  "English",
  "Deutsch",
  "Français",
  "Español",
  "Eesti",
  "Nederlands",
}

screen:radio({
  x=2,
  y=5,
  color=colors.white,
  background=colors.cyan,
  options=language_names,
  callback=function(index)
    language = index
  end
})

speakButton = screen:button({
  x=2,
  y=3,
  text="Speak",
  color=colors.white,
  background=colors.green,
  callback=function()
    speakButton.text = "Speaking..."
    speakButton.background = colors.red
    speak(input.text)
    speakButton.text = "Speak"
    speakButton.background = colors.green
  end
})

screen:button({
  x=2,
  y=screen.Y-1,
  text="Exit",
  color=colors.red,
  background=colors.white,
  callback=function()
    screen:exit()
  end
})

input = screen:input({
  x=2,
  y=2,
  width=screen.X-2,
  placeholder="Enter something to speak",
  color = colors.white,
  background = colors.cyan,
  placeholderColor = colors.gray
})

screen:loop()