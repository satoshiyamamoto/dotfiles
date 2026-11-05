-- Migrated from tmux, Herdr, Ghostty and kitty.

rex.host({
  id = "host:0a1bce78-f25e-48d6-b50a-213951fc80c1",
  label = "Home",
  endpoint = "https://kenya-rex.tail4ad78.ts.net",
  icon = "globe",
})

rex.host({
  id = "host:3483188f-66ba-415c-93f5-c8ff97c051dc",
  label = "Work",
  endpoint = "https://devcontainer01-rex.tail4ad78.ts.net",
  icon = "globe",
})

-- Keep programs that use ctrl+b themselves working (the prefix is a sequence start).
rex.bind("ctrl+b>ctrl+b", "pane.send_key", { key = "ctrl+b" })

-- tmux
rex.bind("ctrl+b>shift+\\", "pane.split", { direction = "right" })
rex.bind("ctrl+b>-", "pane.split", { direction = "down" })
rex.bind("ctrl+b>x", "pane.close")
rex.bind("alt+s", "session.switch")

-- Herdr
rex.bind("ctrl+b>1", "client.tab.goto", { index = 1 })
rex.bind("ctrl+b>2", "client.tab.goto", { index = 2 })
rex.bind("ctrl+b>3", "client.tab.goto", { index = 3 })
rex.bind("ctrl+b>4", "client.tab.goto", { index = 4 })
rex.bind("ctrl+b>5", "client.tab.goto", { index = 5 })
rex.bind("ctrl+b>6", "client.tab.goto", { index = 6 })
rex.bind("ctrl+b>7", "client.tab.goto", { index = 7 })
rex.bind("ctrl+b>8", "client.tab.goto", { index = 8 })
rex.bind("ctrl+b>9", "client.tab.goto", { index = 9 })
