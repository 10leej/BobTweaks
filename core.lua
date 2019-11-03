-------------------------------------------------------
--Max out the camera
function SetMaxCameraDistance()
	SetCVar("cameraDistanceMaxZoomFactor", 3.5)
end
local addon = CreateFrame("Frame")

--Register
addon:RegisterEvent("PLAYER_ENTERING_WORLD")
--Call
addon:SetScript("OnEvent", function(self, event, ...)
	SetMaxCameraDistance()
end)

-------------------------------------------------------
--auto repair and sell trash
local g = CreateFrame("Frame")
g:RegisterEvent("MERCHANT_SHOW")
g:SetScript("OnEvent", function()  
local bag, slot
  for bag = 0, 4 do
    for slot = 0, GetContainerNumSlots(bag) do
      local link = GetContainerItemLink(bag, slot)
      if link and (select(3, GetItemInfo(link)) == 0) then
        UseContainerItem(bag, slot)
      end
    end
  end
  if(CanMerchantRepair()) then
    local cost = GetRepairAllCost()
    if cost > 0 then
      local money = GetMoney()
      if IsInGuild() then
        local guildMoney = GetGuildBankWithdrawMoney()
        if guildMoney > GetGuildBankMoney() then
          guildMoney = GetGuildBankMoney()
        end
        if guildMoney > cost and CanGuildBankRepair() then
          RepairAllItems(1)
          print(format("|cfff07100Repair cost covered by Guild Bank: %.1fg|r", cost * 0.0001))
        return
        end
      end
      if money > cost then
        RepairAllItems()
        print(format("|cffead000Repair cost: %.1fg|r", cost * 0.0001))
      else
        print("Not enough gold to cover the repair cost.")
      end
    end
  end
end)
-------------------------------------------------------
--Some slash commands
SlashCmdList["TICKET"] = function() ToggleHelpFrame() end
SLASH_TICKET1 = "/??"
SLASH_TICKET2 = "/gm"

SlashCmdList["READYCHECK"] = function() DoReadyCheck() end
SLASH_READYCHECK1 = '/rc'
SLASH_READYCHECK2 = '/??'

SlashCmdList["CHECKROLE"] = function() InitiateRolePoll() end
SLASH_CHECKROLE1 = '/cr'
SLASH_CHECKROLE2 = '/??'

SlashCmdList["CLCE"] = function() CombatLogClearEntries() end
SLASH_CLCE1 = "/clc"

SlashCmdList['RELOADUI'] = function() ReloadUI() end
SLASH_RELOADUI1 = '/rl'
SLASH_RELOADUI2 = '/??'

-----------------------------------------------------
--Minimap mods

-- Enable mouse scrolling on the Minimap
Minimap:EnableMouseWheel(true)
Minimap:SetScript("OnMouseWheel", function(self, d)
	if d > 0 then
		_G.MinimapZoomIn:Click()
	elseif d < 0 then
		_G.MinimapZoomOut:Click()
	end
end)
-- Hide Zoom Buttons
MinimapZoomIn:Hide()
MinimapZoomOut:Hide()
-- Hide world map button
MiniMapWorldMapButton:Hide()
-- Hide North texture at top
MinimapNorthTag:SetTexture(nil) --I mean seriously? We know which way is north

-----------------------------------------------------
--Chat mods

--Channel names
--guild
CHAT_GUILD_GET = "|Hchannel:GUILD|h[G]|h %s "
CHAT_OFFICER_GET = "|Hchannel:OFFICER|hO|h %s "

--raid
CHAT_RAID_GET = "|Hchannel:RAID|h[R]|h %s "
CHAT_RAID_WARNING_GET = "[RW] %s "
CHAT_RAID_LEADER_GET = "|Hchannel:RAID|h[RL]|h %s "

--party
CHAT_PARTY_GET = "|Hchannel:PARTY|h[P]|h %s "
CHAT_PARTY_LEADER_GET =  "|Hchannel:PARTY|h[PL]|h %s "
CHAT_PARTY_GUIDE_GET =  "|Hchannel:PARTY|h[PG]|h %s "

--bg and instances
CHAT_INSTANCE_CHAT_GET = "|Hchannel:INSTANCE_CHAT|h[I]|h %s: "
CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:INSTANCE_CHAT|h[IL]|h %s: "
  
--whisper  
CHAT_WHISPER_INFORM_GET = "to %s "
CHAT_WHISPER_GET = "from %s "
CHAT_BN_WHISPER_INFORM_GET = "to %s "
CHAT_BN_WHISPER_GET = "from %s "
  
--say / yell
CHAT_SAY_GET = "%s "
CHAT_YELL_GET = "%s "
  
--flags
CHAT_FLAG_AFK = "[AFK] "
CHAT_FLAG_DND = "[DND] "
CHAT_FLAG_GM = "[GM] "

local gsub = _G.string.gsub
      
for i = 1, NUM_CHAT_WINDOWS do
	if ( i ~= 2 ) then
		local f = _G["ChatFrame"..i]
		local am = f.AddMessage
		f.AddMessage = function(frame, text, ...)
			return am(frame, text:gsub('|h%[(%d+)%. .-%]|h', '|h%1|h'), ...)
		end
    end
end

--Chat Scroll Module
hooksecurefunc('FloatingChatFrame_OnMouseScroll', function(self, dir)
	if dir > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollUp()
			self:ScrollUp()
		end
	elseif dir < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			--only need to scroll twice because of blizzards scroll
			self:ScrollDown()
			self:ScrollDown()
		end
	end
end)


--URL copy
local SetItemRef_orig = SetItemRef;
function ReURL_SetItemRef(link, text, button)
	if (strsub(link, 1, 3) == "url") then
		local url = strsub(link, 5);
		local activeWindow = ChatEdit_GetActiveWindow();
		if ( activeWindow ) then
			activeWindow:Insert(url);
			ChatEdit_FocusActiveWindow();
		else
			ChatEdit_GetLastActiveWindow():Show();
			ChatEdit_GetLastActiveWindow():Insert(url);
			ChatEdit_GetLastActiveWindow():SetFocus();
		end
	else
		SetItemRef_orig(link, text, button);
	end
end
SetItemRef = ReURL_SetItemRef;

function ReURL_AddLinkSyntax(chatstring)
	if (type(chatstring) == "string") then
		local extraspace;
		if (not strfind(chatstring, "^ ")) then
			extraspace = true;
			chatstring = " "..chatstring;
		end
		chatstring = gsub (chatstring, " www%.([_A-Za-z0-9-]+)%.(%S+)%s?", ReURL_Link("www.%1.%2"))
		chatstring = gsub (chatstring, " (%a+)://(%S+)%s?", ReURL_Link("%1://%2"))
		chatstring = gsub (chatstring, " ([_A-Za-z0-9-%.]+)@([_A-Za-z0-9-]+)(%.+)([_A-Za-z0-9-%.]+)%s?", ReURL_Link("%1@%2%3%4"))
		chatstring = gsub (chatstring, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?):(%d%d?%d?%d?%d?)%s?", ReURL_Link("%1.%2.%3.%4:%5"))
		chatstring = gsub (chatstring, " (%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%.(%d%d?%d?)%s?", ReURL_Link("%1.%2.%3.%4"))
		if (extraspace) then
			chatstring = strsub(chatstring, 2);
		end
	end
	return chatstring
end

REURL_COLOR = "FFFF55";
ReURL_Brackets = nil;
ReUR_CustomColor = true;

function ReURL_Link(url)
	if (ReUR_CustomColor) then
		if (ReURL_Brackets) then
			url = " |cff"..REURL_COLOR.."|Hurl:"..url.."|h["..url.."]|h|r "
		else
			url = " |cff"..REURL_COLOR.."|Hurl:"..url.."|h"..url.."|h|r "
		end
	else
		if (ReURL_Brackets) then
			url = " |Hurl:"..url.."|h["..url.."]|h "
		else
			url = " |Hurl:"..url.."|h"..url.."|h "
		end
	end
	return url
end

--Hook all the AddMessage funcs
for i=1, NUM_CHAT_WINDOWS do
	local frame = _G["ChatFrame"..i]
	local addmessage = frame.AddMessage
	frame.AddMessage = function(self, text, ...) addmessage(self, ReURL_AddLinkSyntax(text), ...) end
end