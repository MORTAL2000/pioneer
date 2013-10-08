-- Copyright © 2008-2013 Pioneer Developers. See AUTHORS.txt for details
-- Licensed under the terms of the GPL v3. See licenses/GPL-3.txt

local Game = import("Game")
local Engine = import("Engine")
local Translate = import("Translate")
local Lang = import("Lang")
local TabGroup = import("ui/TabGroup")

local ui = Engine.ui
local t = Translate:GetTranslator()

local optionCheckBox = function (getter, setter, caption, negate)
	local cb = ui:CheckBox()
	local initial = getter()
	if negate then initial = not initial; end
	cb:SetState(initial)
	cb.onClick:Connect(function ()
		local value = cb.isChecked
		if negate then
			setter(not value)
		else
			setter(value)
		end
	end)
	return ui:HBox(5):PackEnd({cb, ui:Label(caption)})
end

local optionListOrDropDown = function (widget, getter, setter, settingCaption, captions, values)
	local list = ui[widget](ui)
	local initial_value = getter()
	local initial_index
	for i = 1, #values do
		list:AddOption(captions[i])
		if initial_value == values[i] then
			initial_index = i
		end
	end
	initial_index = initial_index or 1
	list:SetSelectedIndex(initial_index)
	list.onOptionSelected:Connect(function ()
		setter(values[list.selectedIndex])
	end)
	return ui:VBox(5):PackEnd({ui:Label(settingCaption), list})
end

local optionDropDown = function (getter, setter, settingCaption, captions, values)
	return optionListOrDropDown('DropDown', getter, setter, settingCaption, captions, values)
end

local optionList = function (getter, setter, settingCaption, captions, values)
	return optionListOrDropDown('List', getter, setter, settingCaption, captions, values)
end

-- FIXME: put these somewhere
-- local navTunnelCheckBox = optionCheckBox('DisplayNavTunnel', t("Display navigation tunnel"), false)
-- local invertMouseCheckBox = optionCheckBox('InvertMouseY', t("Invert MouseY"), false)

ui.templates.Settings = function (args)
	local videoTemplate = function()
		local videoModes = Engine.GetVideoModeList()
		local videoModeLabels = {}
		local videoModeValues = {}
		for i = 1, #videoModes do
			local mode = videoModes[i]
			local token = mode.width .. 'x' .. mode.height
			videoModeLabels[i] = token
			videoModeValues[token] = mode
		end
		local GetVideoMode = function ()
			local w, h = Engine.GetVideoResolution()
			return w .. 'x' .. h -- return a string token (matches the tokens used as keys in videoModeValues)
		end
		local SetVideoMode = function (token)
			local mode = videoModeValues[token]
			Engine.SetVideoResolution(mode.width, mode.height)
		end
		local modeDropDown = optionDropDown(GetVideoMode, SetVideoMode, t("Video mode"), videoModeLabels, videoModeLabels)

		local aaLabels = { t("Off"), "x2", "x4", "x8", "x16" }
		local aaModes = { 0, 2, 4, 8, 16 }
		local aaDropDown = optionDropDown(Engine.GetMultisampling, Engine.SetMultisampling, t("AA"), aaLabels, aaModes)

		local vsyncCheckBox = optionCheckBox(Engine.GetVSyncEnabled, Engine.SetVSyncEnabled, t("VSync"), false)

		local detailLevels = { 'VERY_LOW', 'LOW', 'MEDIUM', 'HIGH', 'VERY_HIGH' }
		local detailLabels = { t("Very low"), t("Low"), t("Medium"), t("High"), t("Very high") }

		local planetDetailDropDown = optionDropDown(
			Engine.GetPlanetDetailLevel, Engine.SetPlanetDetailLevel,
			t("Planet detail distance"), detailLabels, detailLevels)

		local planetTextureCheckBox = optionCheckBox(
			Engine.GetPlanetFractalColourEnabled, Engine.SetPlanetFractalColourEnabled,
			t("Planet textures"), false)

		local fractalDetailDropDown = optionDropDown(
			Engine.GetFractalDetailLevel, Engine.SetFractalDetailLevel,
			t("Fractal detail"), detailLabels, detailLevels)

		local cityDetailDropDown = optionDropDown(
			Engine.GetCityDetailLevel, Engine.SetCityDetailLevel,
			t("City detail level"), detailLabels, detailLevels)

		local fullScreenCheckBox = optionCheckBox(
			Engine.GetFullscreen, Engine.SetFullscreen,
			t("Full screen"), false)
		local shadersCheckBox = optionCheckBox(
			Engine.GetShadersEnabled, Engine.SetShadersEnabled,
			t("Use shaders"), false)
		local compressionCheckBox = optionCheckBox(
			Engine.GetTextureCompressionEnabled, Engine.SetTextureCompressionEnabled,
			t("Compress Textures"), false)

		return ui:Grid({1,1}, 1)
			:SetCell(0,0, ui:Margin(5, 'ALL', ui:Background(ui:VBox(5):PackEnd({
				ui:Label(t("Video configuration (restart game to apply)")),
				modeDropDown,
				aaDropDown,
				fullScreenCheckBox,
				vsyncCheckBox,
				shadersCheckBox,
				compressionCheckBox,
			}))))
			:SetCell(1,0, ui:Margin(5, 'ALL', ui:Background(ui:VBox(5):PackEnd({
				planetDetailDropDown,
				planetTextureCheckBox,
				fractalDetailDropDown,
				cityDetailDropDown,
			}))))
	end

	local soundTemplate = function()
		local volumeSlider = function (caption, getter, setter)
			local initial_value = getter()
			local slider = ui:HSlider()
			local label = ui:Label(caption .. " " .. math.floor(initial_value * 100))
			slider:SetValue(initial_value)
			slider.onValueChanged:Connect(function (new_value)
					label:SetText(caption .. " " .. math.floor(new_value * 100))
					setter(new_value)
				end)
			return ui:VBox():PackEnd({label, slider})
		end

		local muteBox = function(getter, setter)
			return optionCheckBox(getter, setter, t("Mute"), false)
		end

		return ui:VBox():PackEnd(ui:Grid({1,2,1}, 3)
			:SetCell(0,0,muteBox(Engine.GetMasterMuted, Engine.SetMasterMuted))
			:SetCell(1,0,volumeSlider(t("Master:"), Engine.GetMasterVolume, Engine.SetMasterVolume))
			:SetCell(0,1,muteBox(Engine.GetMusicMuted, Engine.SetMusicMuted))
			:SetCell(1,1,volumeSlider(t("Music:"), Engine.GetMusicVolume, Engine.SetMusicVolume))
			:SetCell(0,2,muteBox(Engine.GetEffectsMuted, Engine.SetEffectsMuted))
			:SetCell(1,2,volumeSlider(t("Effects:"), Engine.GetEffectsVolume, Engine.SetEffectsVolume)))
	end

	local languageTemplate = function()
		local langs = Lang.GetCoreLanguages()
		return optionList(Lang.GetCurrentLanguage, Lang.SetCurrentLanguage, t("Language (restart game to apply)"), langs, langs)
	end

	local keysTemplate = function()
		local box = ui:VBox()
		local pages = Engine.GetKeyBindings()
		for page_title, groups in pairs(pages) do
			box:PackEnd(ui:Label(page_title):SetFont('HEADING_LARGE'))
			for group_title, group in pairs(groups) do
				box:PackEnd(ui:Label(group_title):SetFont('HEADING_NORMAL'))
				local grid = ui:Grid({0.5, 0.5}, #group)
				for i = 1, #group do
					local binding = group[i]
					grid:SetCell(0, i - 1, ui:Label(binding.label))
					grid:SetCell(1, i - 1, ui:Label(binding.bindingDescription))
				end
				box:PackEnd(grid)
			end
		end
		return box
	end

	local function wrapWithScroller(template)
		return function (...)
			local inner = template(...)
			return ui:Expand():SetInnerWidget(ui:Scroller():SetInnerWidget(inner))
		end
	end

	local setTabs = nil
	setTabs = TabGroup.New()
	setTabs:AddTab({ id = "Video",    title = t("Video"),    icon = "VideoCamera", template = wrapWithScroller(videoTemplate)    })
	setTabs:AddTab({ id = "Sound",    title = t("Sound"),    icon = "Speaker",     template = wrapWithScroller(soundTemplate)    })
	setTabs:AddTab({ id = "Language", title = t("Language"), icon = "Globe1",      template = wrapWithScroller(languageTemplate) })
	setTabs:AddTab({ id = "Controls", title = t("Controls"), icon = "Gamepad",     template = wrapWithScroller(keysTemplate)     })

	local close_buttons = {}
	do
		local items = args.closeButtons
		for i = 1, #items do
			local btn = ui:Button():SetInnerWidget(ui:Label(items[i].text))
			btn.onClick:Connect(items[i].onClick)
			close_buttons[i] = btn
		end
	end

	if #close_buttons > 1 then
		close_buttons = ui:HBox(5):PackEnd(close_buttons)
	else
		close_buttons = close_buttons[1]
	end

	return ui:Background():SetInnerWidget(ui:VBox(10):PackEnd({setTabs, close_buttons}))
end

ui.templates.SettingsInGame = function ()
	return ui.templates.Settings({
		closeButtons = {
			{ text = t("Save"), onClick = function ()
				local settings_view = ui.layer.innerWidget
				ui:NewLayer(
					ui.templates.FileDialog({
						title        = t("Save"),
						helpText     = t("Select a file to save to or enter a new filename"),
						path         = "savefiles",
						allowNewFile = true,
						selectLabel  = t("Save"),
						onSelect     = function (filename)
							Game.SaveGame(filename)
							ui:DropLayer()
						end,
						onCancel    = function ()
							ui:DropLayer()
						end
					})
				)
			end },
			{ text = t("Exit this game"), onClick = Game.EndGame }
		}
	})
end
