--[[
   ADDON_NAME by MooreaTV moorea@ymail.com (c) 2019 All rights reserved
   Licensed under LGPLv3 - No Warranty
   (contact the author if you need a different license)

   ADDON_LONG_DESCRIPTION

   Get this addon binary release using curse/twitch client or on wowinterface
   The source of the addon resides on https://github.com/mooreatv/ADDON_NAME
   (and the MoLib library at https://github.com/mooreatv/MoLib)

   Releases detail/changes are on https://github.com/mooreatv/ADDON_NAME/releases
   ]] --
--
-- our name, our empty default (and unused) anonymous ns
local addon, _ns = ...

-- Table and base functions created by MoLib
local ADDON_NS = _G[addon]
-- localization
ADDON_NS.L = ADDON_NS:GetLocalization()
local L = ADDON_NS.L

-- ADDON_NS.debug = 9 -- to debug before saved variables are loaded

-- TODO: move most of this to MoLib

function ADDON_NS:SetupMenu()
  ADDON_NS:WipeFrame(ADDON_NS.mmb)
  local b = ADDON_NS:minimapButton(ADDON_NS.buttonPos)
  local _nw, _nh, s, w, h = ADDON_NS:PixelPerfectSnap(b)
  self:Debug("new w % h %", w, h)
  local icon = CreateFrame("Frame", nil, b)
  -- set scale to be pixels
  icon:SetScale(s / icon:GetEffectiveScale())
  ADDON_NS:Debug("Scale is now % es % ppf es %", icon:GetScale(), icon:GetEffectiveScale(), s)
  local delta = math.floor((w - 32) / 2)
  icon:SetPoint("BOTTOMLEFT", delta, delta)
  icon:SetFlattensRenderLayers(true)
  icon:SetSize(48, 48)
  icon:SetIgnoreParentAlpha(true)
  -- based on 32x32
  -- TODO draw something or load texture
  b:SetScript("OnClick", function(_w, button, _down)
    if button == "RightButton" then
      ADDON_NS.Slash("config")
    else
      ADDON_NS:PrintDefault("ADDON_NAME TODO: do something when clicked...")
    end
  end)
  b.tooltipText = "|cFFF2D80CADDON_TITLE|r:\n" ..
                    L["|cFF99E5FFLeft|r click to TODO\n" .. "|cFF99E5FFRight|r click for options\n\n" ..
                      "Drag to move this button."]
  b:SetScript("OnEnter", function()
    ADDON_NS:ShowToolTip(b, "ANCHOR_LEFT")
    ADDON_NS.inButton = true
  end)
  b:SetScript("OnLeave", function()
    GameTooltip:Hide()
    ADDON_NS.inButton = false
    ADDON_NS:Debug("Hide tool tip...")
  end)
  ADDON_NS:MakeMoveable(b, ADDON_NS.SavePositionCB)
  ADDON_NS.mmb = b
  ADDON_NS.mmb.icon = icon
end

function ADDON_NS.SavePositionCB(_f, pos, _scale)
  ADDON_NS:SetSaved("buttonPos", pos)
end

ADDON_NS.EventHdlrs = {

  PLAYER_ENTERING_WORLD = function(_self, ...)
    ADDON_NS:Debug("OnPlayerEnteringWorld " .. ADDON_NS:Dump(...))
    ADDON_NS:CreateOptionsPanel()
    ADDON_NS:SetupMenu()
  end,

  DISPLAY_SIZE_CHANGED = function(_self)
    if ADDON_NS.mmb then
      ADDON_NS:SetupMenu() -- should be able to just RestorePosition() but...
    end
  end,

  UI_SCALE_CHANGED = function(_self, ...)
    ADDON_NS:DebugEvCall(1, ...)
    if ADDON_NS.mmb then
      ADDON_NS:SetupMenu() -- buffer with the one above?
    end
  end,

  ADDON_LOADED = function(_self, _event, name)
    ADDON_NS:Debug(9, "Addon % loaded", name)
    if name ~= addon then
      return -- not us, return
    end
    -- check for dev version (need to split the tags or they get substituted)
    if ADDON_NS.manifestVersion == "@" .. "project-version" .. "@" then
      ADDON_NS.manifestVersion = "vX.YY.ZZ"
    end
    ADDON_NS:PrintDefault("ADDON_NAME " .. ADDON_NS.manifestVersion ..
                            " by MooreaTv: type /ADDON_SLASH for command list/help.")
    if ADDON_NAMESaved == nil then
      ADDON_NS:Debug("Initialized empty saved vars")
      ADDON_NAMESaved = {}
    end
    ADDON_NAMESaved.addonVersion = ADDON_NS.manifestVersion
    ADDON_NAMESaved.addonHash = "@project-abbreviated-hash@"
    ADDON_NS:deepmerge(ADDON_NS, nil, ADDON_NAMESaved)
    ADDON_NS:Debug(3, "Merged in saved variables.")
    ADDON_NS.savedVar = ADDON_NAMESaved -- reference not copy, changes to one change the other
  end
}

function ADDON_NS:Help(msg)
  ADDON_NS:PrintDefault("ADDON_NAME: " .. msg .. "\n" .. "/ADDON_SLASH config -- open addon config\n" ..
                          "/ADDON_SLASH bug -- report a bug\n" ..
                          "/ADDON_SLASH debug on/off/level -- for debugging on at level or off.\n" ..
                          "/ADDON_SLASH version -- shows addon version")
end

function ADDON_NS.Slash(arg) -- can't be a : because used directly as slash command
  ADDON_NS:Debug("Got slash cmd: %", arg)
  if #arg == 0 then
    ADDON_NS:Help("commands, you can use the first letter of each:")
    return
  end
  local cmd = string.lower(string.sub(arg, 1, 1))
  local posRest = string.find(arg, " ")
  local rest = ""
  if not (posRest == nil) then
    rest = string.sub(arg, posRest + 1)
  end
  if cmd == "b" then
    local subText = L["Please submit on discord or on curse or github or email"]
    ADDON_NS:PrintDefault(L["ADDON_NAME bug report open: "] .. subText)
    -- base molib will add version and date/timne
    ADDON_NS:BugReport(subText, "@project-abbreviated-hash@\n\n" .. L["Bug report from slash command"])
  elseif cmd == "v" then
    -- version
    ADDON_NS:PrintDefault("ADDON_NAME " .. ADDON_NS.manifestVersion ..
                            " (@project-abbreviated-hash@) by MooreaTv (moorea@ymail.com)")
  elseif cmd == "c" then
    -- Show config panel
    -- InterfaceOptionsList_DisplayPanel(ADDON_NS.optionsPanel)
    InterfaceOptionsFrame:Show() -- onshow will clear the category if not already displayed
    InterfaceOptionsFrame_OpenToCategory(ADDON_NS.optionsPanel) -- gets our name selected
  elseif ADDON_NS:StartsWith(arg, "debug") then
    -- debug
    if rest == "on" then
      ADDON_NS:SetSaved("debug", 1)
    elseif rest == "off" then
      ADDON_NS:SetSaved("debug", nil)
    else
      ADDON_NS:SetSaved("debug", tonumber(rest))
    end
    ADDON_NS:PrintDefault("ADDON_NAME debug now %", ADDON_NS.debug)
  else
    ADDON_NS:Help('unknown command "' .. arg .. '", usage:')
  end
end

-- Run/set at load time:

-- Slash

SlashCmdList["ADDON_NAME_Slash_Command"] = ADDON_NS.Slash

SLASH_ADDON_NAME_Slash_Command1 = "/ADDON_SLASH"

-- Events handling
ADDON_NS:RegisterEventHandlers()

-- Options panel

function ADDON_NS:CreateOptionsPanel()
  if ADDON_NS.optionsPanel then
    ADDON_NS:Debug("Options Panel already setup")
    return
  end
  ADDON_NS:Debug("Creating Options Panel")

  local p = ADDON_NS:Frame(L["ADDON_NAME"])
  ADDON_NS.optionsPanel = p
  p:addText(L["ADDON_NAME options"], "GameFontNormalLarge"):Place()
  p:addText(L["ADDON_LONG_DESCRIPTION"]):Place()
  p:addText(L["These options let you control the behavior of ADDON_NAME"] .. " " .. ADDON_NS.manifestVersion ..
              " @project-abbreviated-hash@"):Place()

  -- TODO add some option

  p:addText(L["Development, troubleshooting and advanced options:"]):Place(40, 20)

  p:addButton("Bug Report", L["Get Information to submit a bug."] .. "\n|cFF99E5FF/ADDON_SLASH bug|r", "bug"):Place(4,
                                                                                                                    20)

  p:addButton(L["Reset minimap button"], L["Resets the minimap button to back to initial default location"], function()
    ADDON_NS:SetSaved("buttonPos", nil)
    ADDON_NS:SetupMenu()
  end):Place(4, 20)

  local debugLevel = p:addSlider(L["Debug level"], L["Sets the debug level"] .. "\n|cFF99E5FF/ADDON_SLASH debug X|r", 0,
                                 9, 1, "Off"):Place(16, 30)

  function p:refresh()
    ADDON_NS:Debug("Options Panel refresh!")
    if ADDON_NS.debug then
      -- expose errors
      xpcall(function()
        self:HandleRefresh()
      end, geterrorhandler())
    else
      -- normal behavior for interface option panel: errors swallowed by caller
      self:HandleRefresh()
    end
  end

  function p:HandleRefresh()
    p:Init()
    debugLevel:SetValue(ADDON_NS.debug or 0)
  end

  function p:HandleOk()
    ADDON_NS:Debug(1, "ADDON_NS.optionsPanel.okay() internal")
    --    local changes = 0
    --    changes = changes + ADDON_NS:SetSaved("lineLength", lineLengthSlider:GetValue())
    --    if changes > 0 then
    --      ADDON_NS:PrintDefault("ADDON_NS: % change(s) made to grid config", changes)
    --    end
    local sliderVal = debugLevel:GetValue()
    if sliderVal == 0 then
      sliderVal = nil
      if ADDON_NS.debug then
        ADDON_NS:PrintDefault("Options setting debug level changed from % to OFF.", ADDON_NS.debug)
      end
    else
      if ADDON_NS.debug ~= sliderVal then
        ADDON_NS:PrintDefault("Options setting debug level changed from % to %.", ADDON_NS.debug, sliderVal)
      end
    end
    ADDON_NS:SetSaved("debug", sliderVal)
  end

  function p:cancel()
    ADDON_NS:Warning("Options screen cancelled, not making any changes.")
  end

  function p:okay()
    ADDON_NS:Debug(3, "ADDON_NS.optionsPanel.okay() wrapper")
    if ADDON_NS.debug then
      -- expose errors
      xpcall(function()
        self:HandleOk()
      end, geterrorhandler())
    else
      -- normal behavior for interface option panel: errors swallowed by caller
      self:HandleOk()
    end
  end
  -- Add the panel to the Interface Options
  InterfaceOptions_AddCategory(ADDON_NS.optionsPanel)
end

-- bindings / localization
_G.ADDON_UPPERCASE_NAME = "ADDON_NAME"
_G.BINDING_HEADER_ADDON_NS = L["ADDON_TITLE addon key bindings"]
_G.BINDING_NAME_ADDON_NS_SOMETHING = L["TODO something"] .. " |cFF99E5FF/ADDON_SLASH todo|r"

-- ADDON_NS.debug = 2
ADDON_NS:Debug("ADDON_SLASH main file loaded")
