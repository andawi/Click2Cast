local L = LibStub("AceLocale-3.0"):GetLocale("Click2Cast", true)
local Click2Cast = LibStub("AceAddon-3.0"):NewAddon("Click2Cast")
local AceDB = LibStub("AceDB-3.0")

local bindingFrame = CreateFrame("Button",nil,UIParent)

local defaults = {
	char = {
		clickOptions = {
			["*"] = { action = "none" },
			BUTTON1 = { action = "target" },
			BUTTON2 = { action = "menu" },
		}
	}	
}

Click2Cast.actionText = {
	macro = true,
	macroID = true,
	spell = true,
	macroname = true
}


function Click2Cast:Enable_BlizzCompactUnitFrames()
   if not ClickCastFrames then
		ClickCastFrames = {}
	end
	self.clickFrames = ClickCastFrames
	ClickCastFrames[PlayerFrame] = true
	ClickCastFrames[TargetFrame] = true
	ClickCastFrames[PetFrame] = true
	ClickCastFrames[PartyMemberFrame1] = true
	ClickCastFrames[PartyMemberFrame2] = true
	ClickCastFrames[PartyMemberFrame3] = true
	ClickCastFrames[PartyMemberFrame4] = true
	ClickCastFrames[PartyMemberFrame1PetFrame] = true
	ClickCastFrames[PartyMemberFrame2PetFrame] = true
	ClickCastFrames[PartyMemberFrame3PetFrame] = true
	ClickCastFrames[PartyMemberFrame4PetFrame] = true
	ClickCastFrames[TargetFrame] = true
	ClickCastFrames[TargetFrameToT] = true
	
	
	hooksecurefunc("CompactUnitFrame_SetUpFrame", function(frame, ...)
        local name = frame and frame.GetName and frame:GetName()
       	ClickCastFrames[frame] = true
	end)
	
	
-- no idea for what's this
	
	setmetatable(self.clickFrames, { __newindex = function(self,k,v)
		
		if v == nil then
			Click2Cast:UnregisterFrame(k)
		else
			Click2Cast:RegisterFrame(k)
		end
		rawset(self, k, v)
	end })

    
end

		
function Click2Cast:OnInitialize()
	self.db = AceDB:New("Click2CastDB", defaults, "global")
	self:CreateMenu()
	self:Enable_BlizzCompactUnitFrames()
end

function Click2Cast:OnEnable()
	

	self:SetAllFrames()
	self:SetKeyboardBindings()

	LibStub:GetLibrary("LibDataBroker-1.1"):NewDataObject("Click2Cast", {
		type = "data source",
		icon = "Interface\\CURSOR\\Cast",
		OnClick = function(clickedframe, button)
			if button == "RightButton" then
				InterfaceOptionsFrame_OpenToCategory(Click2Cast.menu)
			end
		end,
		label = "Click2Cast",
		OnTooltipShow = function(tooltip)
			Click2Cast:OnTooltipShow(tooltip)
		end
	})
end

function Click2Cast:OnProfileEnable()
	self:SetAllFrames()
	self:DisableKeyboardBindings()
	self:SetKeyboardBindings()
end

function Click2Cast:SetAllFrames()
	if InCombatLockdown() and not self.OOCSetAllFrames then
		self:ScheduleLeaveCombatAction("SetAllFrames")
		self.OOCSetAllFrames = true
		return
	end
	for frame in pairs(self.clickFrames) do
		self:UnregisterFrame(frame)
		self:RegisterFrame(frame)
	end
	self.OOCSetAllFrames = nil
end

function Click2Cast:OnDisable()
	if InCombatLockdown() and not self.OOCOnDisable then
		self:ScheduleLeaveCombatAction("OnDisable")
		self.OOCOnDisable = true
		return
	end
	for frame in pairs(self.clickFrames) do
		self:UnregisterFrame(frame)
	end
	self:DisableKeyboardBindings()
	self.OOCOnDisable = nil
end

function Click2Cast:RegisterFrame(frame)
	--if FrameIsValid(frame) then
		frame:RegisterForClicks("LeftButtonDown", "MiddleButtonDown", "RightButtonDown")
		for k,v in pairs(self.db.char.clickOptions) do
			if k:find("BUTTON") then
				local button = k:match("(%d+)")
				local modifier = k:gsub("BUTTON%d+", "")
				if self.actionText[v.action] then
					local actionText,lAction
					if v.action == "spell" and v.rank and v.rank:find("(%d+)") then
						frame:SetAttribute(modifier .. "type" .. button, v.action)
						actionText = L["%s(Rank %s)"]:format(v.actiontext or UNKNOWN, v.rank)
					elseif v.action == "macro" then
						frame:SetAttribute(modifier .. "type" .. button, "macro")
						lAction = "macrotext"
					elseif v.action == "macroname" then
						frame:SetAttribute(modifier .. "type" .. button, "macro")
						lAction = "macro"     
					else
						frame:SetAttribute(modifier .. "type" .. button, v.action)
					end

					frame:SetAttribute(modifier .. (lAction or v.action) .. button, actionText or v.actiontext)
				else
					frame:SetAttribute(modifier .. "type" .. button, v.action)
				end
			end
		end
	--end
end

function Click2Cast:UnregisterFrame(frame)
	--if FrameIsValid(frame) then
		for k,v in pairs(self.db.char.clickOptions) do
			if k:find("BUTTON") then
				local button = k:match("(%d+)")
				local modifier = k:gsub("BUTTON%d+", "")
				frame:SetAttribute(modifier .. "type" .. button, nil)
				frame:SetAttribute(modifier .. v.action .. button, nil)
			end
		end
	--end
end

function Click2Cast:SetKeyboardBindings()
	for k,v in pairs(self.db.char.clickOptions) do
		if k:find("BUTTON") then
			if v.outside == true then
				SetOverrideBindingSpell(bindingFrame, false, k, v.actiontext or "")
			else
				SetOverrideBinding(bindingFrame, false, k)
			end
		else
			if v.action == "spell" then
				SetOverrideBindingSpell(bindingFrame, false, k, v.actiontext or "")
			elseif v.action == "macroID" then
				SetOverrideBindingMacro(bindingFrame, false, k, v.actiontext or "")
			elseif v.action == "none" then
				SetOverrideBinding(bindingFrame, false, k)
			end
		end
	end
end

function Click2Cast:DeleteAction(value)
	for frame in pairs(self.clickFrames) do
		if value:find("BUTTON") then
			local button = value:match("(%d+)")
			local modifier = value:gsub("BUTTON%d+", "")
			frame:SetAttribute(modifier .. "type" .. button, nil)
		elseif value then
			SetOverrideBinding(bindingFrame, false, value)
		end
	end
end

function Click2Cast:DisableKeyboardBindings(binding)
	if binding then
		SetOverrideBinding(bindingFrame, false, binding)
	else
		ClearOverrideBindings(bindingFrame)
	end
end
