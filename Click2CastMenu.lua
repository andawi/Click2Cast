local L = LibStub("AceLocale-3.0"):GetLocale("Click2Cast", true)
local Click2Cast = LibStub("AceAddon-3.0"):GetAddon("Click2Cast")

local actions = {
	menu = L["Menu"],
	spell = L["Spell"],
	target = L["Target"],
	focus = L["Focus"],
	assist = L["Assist"],
	macro = L["Macro"],
	macroname = L["Macro Name"],
	none = L["None"],
}

local actionstring = {
	spell = L["Spell Name"],
	macro = L["Macro Text"],
	macroID = L["Macro ID"],
	macroname = L["Macro Name"],
}

local actiondesc = {
	spell = L["Enter the name of the spell to cast."],
	macro = L["Enter the macro code to execute."],
	macroname = L["Enter the name of the macro to execute. Useful for multi-line macros."],
	macroID = L["Enter the ID of the macro to execute. Useful for multi-line macros."],
}

local kbactions = {
	spell = L["Spell"],
	macroID = L["Macro"],
	none = L["None"],
}

local translatedModifiers = {
	SHIFT = L["Shift"],
	ALT = L["Alt"],
	CTRL = L["Ctrl"],
}

local bindCreateMouse = {
	button = "BUTTON1",
	modifier1 = "1",
	modifier2 = "1",
}

local bindCreateKB = {
	button = "",
	modifier1 = "1",
	modifier2 = "1",
}

local options = {
	type = "group",
	args = {
		help = {
			type = "description",
			order = 1,
			name = L["Click2Cast allows you to bind spells, macros and other actions to mouse clicks and keyboard strokes. For example this allows you to heal and buff your party and raid members easily just by clicking on them."],
		},
		group1 = {
			name = "Bindings",
			type = "group",
			inline = true,
			args = {
				binds = {
					type = "description",
					order = 2,
					name = function() return Click2Cast:BindingDisplay() end
				}
			}
		}
	}
}

local mouseOptions = {
	name = L["Mouse Bindings"],
	type = "group",
	hidden = false,	
	get = function(info)
		return bindCreateMouse[info[#info]]
	end,
	set = function(info, value)
		bindCreateMouse[info[#info]] = value
	end,
	childGroups = "tree",
	args = {
		group1 = {
			name = "",
			type = "group",
			inline = true,
			order = 1,
			args = {
				button = {
					name = L["Button"],
					type = "select",
					desc = L["Select binding button."],
					values = {BUTTON1 = L["Button 1"], BUTTON2 = L["Button 2"], BUTTON3 = L["Button 3"], BUTTON4 = L["Button 4"], BUTTON5 = L["Button 5"], BUTTON6 = L["Button 6"], BUTTON7 = L["Button 7"], BUTTON8 = L["Button 8"], BUTTON9 = L["Button 9"], BUTTON10 = L["Button 10"], BUTTON11 = L["Button 11"], BUTTON12 = L["Button 12"], BUTTON13 = L["Button 13"], BUTTON14 = L["Button 14"], BUTTON15 = L["Button 15"]},
					order = 1,
				},
			}
		},
		group2 = {
			name = "",
			type = "group",
			inline = true,
			order = 2,
			args = {
				modifier1 = {
					name = L["Modifier 1"],
					type = "select",
					desc = L["Select modifier button."],
					values = {["1"] = L["None"], SHIFT = L["Shift"], ALT = L["Alt"], CTRL = L["Ctrl"]},
					order = 2,
					width = "half",
				},
				modifier2 = {
					name = L["Modifier 2"],
					type = "select",
					desc = L["Select modifier button."],
					values = function() 
						local t = {["1"] = L["None"], SHIFT = L["Shift"], ALT = L["Alt"], CTRL = L["Ctrl"]}
						if bindCreateMouse.modifier1 ~= "1" then
							t[bindCreateMouse.modifier1] = nil
							if bindCreateMouse.modifier2 == bindCreateMouse.modifier1 then
								bindCreateMouse.modifier2 = "1"
							end							
						end
						return t
					end,
					order = 3,
					width = "half",
					disabled = function() return bindCreateMouse.modifier1 == "1" end
				},
			},
		},
		group3 = {
			name = "",
			type = "group",
			inline = true,
			order = 3,
			args = {
				create = {
					name = L["Create New Binding"],
					type = "execute",
					desc = L["Creates a configurable click binding."],
					func = function() Click2Cast:CreateSubmenu("mouse") end,
				},
			}
		}
	}
}

local kbOptions = {
	name = L["Keyboard Bindings"],
	type = "group",
	hidden = false,	
	get = function(info)
		return bindCreateKB[info[#info]]
	end,
	set = function(info, value)
		bindCreateKB[info[#info]] = value
	end,
	childGroups = "tree",
	args = {
		group1 = {
			name = "",
			type = "group",
			inline = true,
			order = 1,
			args = {
				button = {
					name = L["Button"],
					type = "input",
					desc = L["Select binding button."],
					order = 1,
					width = "half",
					set = function(info, value)
						bindCreateKB[info[#info]] = string.match(value, "%S") or ""
					end,
				},
				modifier1 = {
					name = L["Modifier 1"],
					type = "select",
					desc = L["Select modifier button."],
					values = {["1"] = L["None"], SHIFT = L["Shift"], ALT = L["Alt"], CTRL = L["Ctrl"]},
					order = 2,
					width = "half",
				},
				modifier2 = {
					name = L["Modifier 2"],
					type = "select",
					desc = L["Select modifier button."],					
					values = function() 
						local t = {["1"] = L["None"], SHIFT = L["Shift"], ALT = L["Alt"], CTRL = L["Ctrl"]}
						if bindCreateKB.modifier1 ~= "1" then
							t[bindCreateKB.modifier1] = nil
							if bindCreateKB.modifier2 == bindCreateKB.modifier1 then
								bindCreateKB.modifier2 = "1"
							end
						end
						return t
					end,
					order = 3,
					width = "half",
					disabled = function() return bindCreateKB.modifier1 == "1" end
				},
			}
		},
		group2 = {
			name = "",
			type = "group",
			inline = true,
			order = 2,
			args = {
				create = {
					name = L["Create New Binding"],
					type = "execute",
					desc = L["Creates a configurable click binding."],
					func = function() Click2Cast:CreateSubmenu("kb") end,
					disabled = function()
						if string.match(bindCreateKB.button, "%a(%a+)") or bindCreateKB.button == "" then
							return true
						end
					end
				},	
			}
		}			
	}
}

local function getBindingLocale(text)
	if text == nil or text == "NONE" then
		return nil
	end
	text = tostring(text):upper()
	local shift, ctrl, alt
	local modifier
	while true do
		if text == "-" then
			break
		end
		modifier, text = strsplit('-', text, 2)
		if text then
			if modifier ~= "SHIFT" and modifier ~= "CTRL" and modifier ~= "ALT" then
				return false
			end
			if modifier == "SHIFT" then
				if shift then
					return false
				end
				shift = true
			end
			if modifier == "CTRL" then
				if ctrl then
					return false
				end
				ctrl = true
			end
			if modifier == "ALT" then
				if alt then
					return false
				end
				alt = true
			end
		else
			text = modifier
			break
		end
	end
	local s
	if text == "BUTTON1" then
		s = L["Button 1"]
	elseif text == "BUTTON2" then
		s = L["Button 2"]
	elseif text == "BUTTON3" then
		s = L["Button 3"]
	elseif text == "BUTTON4" then
		s = L["Button 4"]
	elseif text == "BUTTON5" then
		s = L["Button 5"]
    elseif text == "BUTTON6" then
		s = L["Button 6"]
    elseif text == "BUTTON7" then
		s = L["Button 7"]
    elseif text == "BUTTON8" then
		s = L["Button 8"]
    elseif text == "BUTTON9" then
		s = L["Button 9"]
    elseif text == "BUTTON10" then
		s = L["Button 10"]
    elseif text == "BUTTON11" then
		s = L["Button 11"]
    elseif text == "BUTTON12" then
		s = L["Button 12"]
    elseif text == "BUTTON13" then
		s = L["Button 13"]
    elseif text == "BUTTON14" then
		s = L["Button 14"]
    elseif text == "BUTTON15" then
		s = L["Button 15"]
	else
		s = GetBindingText(text, "KEY_") or text
	end
	if shift then
		s = "Shift-" .. s
	end
	if ctrl then
		s = "Ctrl-" .. s
	end
	if alt then
		s = "Alt-" .. s
	end
	return s
end

local function getOrder(binding)
	local num = 0
	if binding:find("ALT%-") then
		num = num + 1
	end
	if binding:find("CTRL%-") then
		num = num + 2
	end
	if binding:find("SHIFT%-") then
		num = num + 3
	end

	local button = tonumber(binding:match("BUTTON(%d+)$"))
	if binding:find("BUTTON") then
		num = num + button * 8
	end
	return num
end

local bindOptions = {
	name = function(info) return getBindingLocale(info[#info]) end,
	order = function(info) return getOrder(info[#info]) end,
	type = "group",
	hidden = false,
	get = function(info) return Click2Cast.db.char.clickOptions[info[#info-1]][info[#info]] end,
	set = function(info, value) Click2Cast.db.char.clickOptions[info[#info-1]][info[#info]] = value Click2Cast:SetAllFrames() Click2Cast:SetKeyboardBindings() end,
	args = {
		action = {
			name = L["Action"],
			type = "select",
			desc = L["Select binding action."],
			values = function(info)
				if info.appName == "Click2CastMouse" then
					return actions
				else
					return kbactions
				end
			end,
			order = 1,
			set = function(info, value)
				Click2Cast.db.char.clickOptions[info[#info-1]][info[#info]] = value
				Click2Cast.db.char.clickOptions[info[#info-1]].actiontext = nil
				Click2Cast:SetAllFrames() 
				Click2Cast:SetKeyboardBindings() 
			end,
		},
		actiontext = {
			name = function(info)
				local action = Click2Cast.db.char.clickOptions[info[#info-1]].action
				return actionstring[action]
			end,
			desc = function(info)
				local action = Click2Cast.db.char.clickOptions[info[#info-1]].action
				return actiondesc[action]
			end,
			type = "input",
			order = 2,
			hidden = function(info)
				local action = Click2Cast.db.char.clickOptions[info[#info-1]].action
				if not (Click2Cast.actionText[action]) then
					return true
				end
			end
		},
		rank = {
			name = L["Spell Rank"],
			type = "input",
			desc = L["Set spell rank."],
			order = 3,
			hidden = function(info)
				local action = Click2Cast.db.char.clickOptions[info[#info-1]].action
				if action ~= "spell" then
					return true
				end
			end,
			set = function(info, value)
				Click2Cast.db.char.clickOptions[info[#info-1]][info[#info]] = value:match("(%d+)")
				Click2Cast:SetAllFrames()
				Click2Cast:SetKeyboardBindings()
			end
		},
		outside = {
			name = L["Outside Unitframes"],
			type = "toggle",
			desc = L["Allows you to use the mouse click binding everywhere, not just on unit frames."],
			order = 4,
			hidden = function(info)
				if info.appName == "Click2CastKB" then
					return true
				end
				local action = Click2Cast.db.char.clickOptions[info[#info-1]].action
				if action ~= "spell" then
					return true
				end
			end,
		},		
	}
}

function Click2Cast:CreateMenu()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Click2Cast", options)
	Click2Cast.menu = LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Click2Cast", "Click2Cast")
	
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Click2CastMouse", mouseOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Click2CastMouse", L["Mouse Bindings"], "Click2Cast")

	LibStub("AceConfig-3.0"):RegisterOptionsTable("Click2CastKB", kbOptions)
	LibStub("AceConfigDialog-3.0"):AddToBlizOptions("Click2CastKB", L["Keyboard Bindings"], "Click2Cast")	
	self:UpdateMenu()
end

function Click2Cast:CreateSubmenu(input)
	local tbl, options, k
	if input == "mouse" then
		tbl = bindCreateMouse
		options = mouseOptions
	else
		tbl = bindCreateKB
		options = kbOptions
	end
	local alt, shift, ctrl
	if tbl.modifier1 == "ALT" or tbl.modifier2 == "ALT" then
		alt = true
	end
	if tbl.modifier1 == "SHIFT" or tbl.modifier2 == "SHIFT" then
		shift = true
	end
	if tbl.modifier1 == "CTRL" or tbl.modifier2 == "CTRL" then
		ctrl = true
	end
	
	k = tbl.button
	if shift then
		k = "SHIFT-" .. k
	end
	if ctrl then
		k = "CTRL-" .. k
	end
	if alt then
		k = "ALT-" .. k
	end	
	
	if not options.args[k] then
		options.args[k] = bindOptions
	end
end

function Click2Cast:UpdateMenu()
	for k, v in pairs(self.db.char.clickOptions) do
		if v.action ~= "none" then
			if string.find(k,"BUTTON%d+") then
				mouseOptions.args[k] = bindOptions
			else
				kbOptions.args[k] = bindOptions
			end
		end
	end
end

local niceModifier = setmetatable({}, {__index =
	function(self, key)
		if type(key) ~= "string" then return nil end
		local x1, x2, x3 = strsplit("-", key)
		local t = {}
		for i = 1, select("#", x1, x2, x3) do
			local cur = (select(i, x1, x2, x3))
			if not translatedModifiers[cur] then break end
			t[#t + 1] = translatedModifiers[cur]
		end
		if #t < 1 then return nil end
		self[key] = table.concat(t, "-")
		for i in ipairs(t) do t[i] = nil end
		return self[key]
	end
})

local tmp = {}
local function mysort(alpha, bravo)
	if not alpha or not bravo then
		return false
	end
	return getOrder(alpha) < getOrder(bravo)
end

function Click2Cast:OnTooltipShow(tooltip)
	if not (tooltip.fake) then
		tooltip:AddLine("Click2Cast")
		tooltip:AddLine(" ")
	end
	
	local db = self.db.char.clickOptions
	for k,v in pairs(db) do
		table.insert(tmp, k)
	end
	table.sort(tmp, mysort)
	local last_button = nil
	for i,k in ipairs(tmp) do
		if k:find("BUTTON") then
			tmp[i] = nil
			local v = db[k]
			local button = tonumber(k:match("BUTTON(%d+)$"))
			if last_button ~= nil and last_button ~= button then
				last_button = button
				tooltip:AddLine(" ")
				tooltip:AddLine(getBindingLocale("BUTTON" .. button), 1,1,1)
			elseif last_button ~= button then
				last_button = button
				tooltip:AddLine(getBindingLocale("BUTTON" .. button), 1,1,1)
			end
			local text
			if not k:find("%-") then
				text = L["No Modifier"]
			else
				text = niceModifier[k]
			end
			
			if v.action and v.action ~= "none" then
				if v.actiontext and v.action == "spell" then
					tooltip:AddDoubleLine(text, v.actiontext, 1,1,0, 1,1,1)
				elseif string.find(k, "BUTTON") then
					tooltip:AddDoubleLine(text, actions[v.action], 1,1,0, 1,1,1)
				else
					tooltip:AddDoubleLine(text, kbactions[v.action] or v.action, 1,1,0, 1,1,1)
				end
			end
		end
	end
	if not (tooltip.fake) then
		tooltip:AddLine(" ")
		tooltip:AddLine(L["|cffeda55fRight-Click|r to configure clickcast actions."], 0.2, 1, 0.2, 1)
	end
end

local function giveHex(r,g,b)
	local r = math.min((r or 0)*255,255)
	local g = math.min((g or 0)*255,255)
	local b = math.min((b or 0)*255,255)
	return string.format("|cff%2x%2x%2x", r, g, b) or ""
end

local faketip = {}
faketip.fake = true
faketip.text = ""
function faketip:AddLine(text, r, g, b)
	local color = giveHex(r, g, b)
	faketip.text = string.format("%s%s%s%s", faketip.text, color, text:upper(), "|r\n")
end

function faketip:AddDoubleLine(text, text2, r1, g1, b1, r2, g2, b2)
	local color1 = giveHex(r1, g1, b1)
	local color2 = giveHex(r2, g2, b2)
	faketip.text = string.format("%s%s%s%s%s%s%s", faketip.text, color1, text, ":|r ", color2, text2, "|r\n")
end

function Click2Cast:BindingDisplay()
	Click2Cast:OnTooltipShow(faketip)
	local text = faketip.text
	faketip.text = ""
	return text
end