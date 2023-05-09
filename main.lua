LongerCustomNames = LongerCustomNames or {}
LongerCustomNames.mod_path = LongerCustomNames.mod_path or ModPath
LongerCustomNames.save_path = LongerCustomNames.save_path or SavePath .. "longercustomnames_settings.txt"
LongerCustomNames.settings = { -- Defaults from WolfHud.
	mask_weapon_name_max_letters = 30,
	skillset_max_letters = 25,
	profile_max_letters = 30
}

--[[
Several code from:
	WolfHUD by Kamikaze94
	Closed Captions by Offyerrocker

This code was written back when I did not have much Lua knowledge.
Nonetheless this should be of use for anyone who wants long names.
]]

function LongerCustomNames:save()
	local file = io.open(self.save_path,"w+")
	if file then
		file:write(json.encode(self.settings))
		file:close()
	end
end

function LongerCustomNames:load()
	local file = io.open(self.save_path, "r")
	if file then
		for k, v in pairs(json.decode(file:read("*all"))) do
			self.settings[k] = v
		end
	else
		self:save()
	end
end

Hooks:Add("LocalizationManagerPostInit", "LocalizationManagerPostInit_LongerCustomNames", function( loc )
	-- no other languages, just load English
	loc:load_localization_file( LongerCustomNames.mod_path .. "localization/english.txt")
end)

LongerCustomNames:load()

if string.lower(RequiredScript) == "lib/tweak_data/guitweakdata" then
	local GuiTweakData_init_orig = GuiTweakData.init
	function GuiTweakData:init(...)
		GuiTweakData_init_orig(self, ...)
		self.rename_max_letters = LongerCustomNames.settings.mask_weapon_name_max_letters
		self.rename_skill_set_max_letters = LongerCustomNames.settings.skillset_max_letters
	end
elseif string.lower(RequiredScript) == "lib/managers/menu/multiprofileitemgui" then
	local init_orig = MultiProfileItemGui.init
	function MultiProfileItemGui:init(...)
		init_orig(self, ...)

		self._max_length = LongerCustomNames.settings.profile_max_letters
	end
elseif string.lower(RequiredScript) == "lib/managers/menumanager" then
	Hooks:Add( "MenuManagerInitialize", "MenuManagerInitialize_LongerCustomNames", function(menu_manager)
		MenuCallbackHandler.callback_longercustomnames_mask_weapon_name = function(self,item)
			LongerCustomNames.settings.mask_weapon_name_max_letters = tonumber(item:value())
		end

		MenuCallbackHandler.callback_longercustomnames_skillset = function(self,item)
			LongerCustomNames.settings.skillset_max_letters = tonumber(item:value())
		end

		MenuCallbackHandler.callback_longercustomnames_profile = function(self,item)
			LongerCustomNames.settings.profile_max_letters = tonumber(item:value())
		end
		
		MenuCallbackHandler.callback_longercustomnames_close = function(self)
			LongerCustomNames:save()
			
			QuickMenu:new(
				managers.localization:text("longercustomnames_restart_required"),
				managers.localization:text("longercustomnames_restart_required_desc"),
				{
					{
						text = managers.localization:text("longercustomnames_button_ok"),
						is_cancel_button = true
					}
				},
				true
			)
		end
		LongerCustomNames:load()
		MenuHelper:LoadFromJsonFile(LongerCustomNames.mod_path .. "menu/options.txt", LongerCustomNames, LongerCustomNames.settings)
	end)
end