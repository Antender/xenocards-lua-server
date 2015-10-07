local socket = require("socket")
local server = {}

function server:start()
  self.server = socket.bind("*",6666)
  self.players = {}
  return self:accept_player()
end

function server:accept_player()
  local player = self.server:accept()
  if player ~= nil then
    player:send("welcome\n")
  end
  if self.players[1] ~= nil then
    self.players[2] = {}
    self.players[2].client = player
    return self:game_starts()
  else
    self.players[1] = {}
    self.players[1].client = player
    return self:accept_player()
  end
end

function server:reconnect(player_index)
  self.server:settimeout(60)
  self.players[player_index].client = self.server:accept()
  self.server:settimeout(0)
  return self[self.rp]()
end

function server:game_starts()
  self:deal()
  sleep(2.9)
  return self:game_started()
end

function sleep(sec)
  socket.select(nil,nil,sec)
end

function server:deal()
  for i=1,2 do
    self.players[i].deck = {}
  end

  local deck = {}
  for i = 1, 52 do
    deck[i] = i
  end

  for i = 1, 51 do
    rand = math.random(i, 52)
    deck[i], deck[rand] = deck[rand], deck[i]
  end

  for i = 1, 2 do
    for j = 1, 26 do
      self.players[i].deck[j] = deck[j + 26 * (i - 1)]
    end
  end

  for i = 1, 2 do
    self.players[i].decksize = 26
  end

  for i = 1, 2 do
    self.players[i].hand = {}
    for j = 1, 4 do
      self.players[i].hand[j] = self:pop_deck(i)
    end
    self.players[i].handsize = 4
  end
end

function server:pop_deck(player)
  local decksize = self.players[player].decksize
   local card = 59
  if decksize > 0 then
    card = self.players[player].deck[decksize]
    table.remove(self.players[player].deck, decksize)
    self.players[player].decksize = self.players[player].decksize - 1
  else
    card = 59 -- 59 means free space
  end
  return card
end

function server:game_started()
  for k, player in ipairs(self.players) do
    local data = "hand:"
    for i = 1, 4 do
      data = data .. " " .. player.hand[i]
    end
    player.client:send(data .. "\n")
    data = "deck:"
    for i = 1, player.decksize do
      data = data .. " " .. player.deck[i]
    end
    player.client:send(data .. "\n")
    sleep(60)
    player.client:close()
  end
  self.players[1] = nil
  self.players[2] = nil
  return self:accept_player()
end

--[[
function checkNear(first,second)
  local difference = math.abs(hands[player][position] % 13 - targets[target] % 13)
  return difference == 1 or difference == 12
end



function resolve()
  local candidates = {}

  for i = 1, 2 do
    if decksSizes[i] == 0 then
      for j = 1, 4 do
        if hands[i][j] ~= 59 then
          candidates[i] = hands[i][j]
          hands[i][j] = 59
          handsSizes[i] = handsSizes[i] - 1
          isGameOver()
          break --Might be causing an unknown bug.
        end
      end
    else
    candidates[i] = popDeck(i)
    end
  end

  targets[1] = candidates[2]
  targets[2] = candidates[1]

  if isStalemate() then
    return resolve()
  end
end

function isStalemate()
  local invalidity = true

  for i = 1, 2 do
    for j = 1, 4 do
      for k = 1, 2 do
        if isValid(i, j, k) then
          invalidity = false
        end
      end
    end
  end
  return invalidity
end

function isGameOver()
  local condition = false --false — none, 1 — first, 2 — second, 3 — both players win(draw).

  if handsSizes[1] == 0 and handsSizes[2] == 0 then
    condition = 3
  elseif handsSizes[1] == 0 then
    condition = 1
  elseif handsSizes[2] == 0 then
    condition = 2
  end

  if condition ~= false then --Placeholder for a return.
    gameOver(condition)
  end
end
]]--

server:start()
