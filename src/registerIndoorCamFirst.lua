--
-- Mod: registerIndoorCamFirst
--
-- Author: MathiasHun
-- ############################

registerIndoorCamFirst = {};

local modName = g_currentModName;
local modDirectory = g_currentModDirectory;
registerIndoorCamFirst.modDirectory = modDirectory;

local modSettingsDirectory = g_currentModSettingsDirectory
registerIndoorCamFirst.modSettingsDir = modSettingsDirectory

registerIndoorCamFirst.indoorActivation = true;
registerIndoorCamFirst.indoorActivationState = 1;

function registerIndoorCamFirst.initSimpleICGui(self)
	if not self.initIndoorCamFirstGuiDone then
		local target = registerIndoorCamFirst

		local title = TextElement.new()
		title:applyProfile("settingsMenuSubtitle", true)
		title:setText(g_i18n:getText("setting_IndoorCamFirst_title"))

		self.boxLayout:addElement(title)

		self.IndoorCamFirst = self.checkUseEasyArmControl:clone()
		self.IndoorCamFirst.target = target
		self.IndoorCamFirst.id = "IndoorCamFirst"
		self.IndoorCamFirst:setCallback("onClickCallback", "onIndoorCamFirstActivationChanged")

		self.IndoorCamFirst.elements[4]:setText(g_i18n:getText("setting_IndoorCamFirst_label"))
		self.IndoorCamFirst.elements[6]:setText(g_i18n:getText("setting_IndoorCamFirst_description"))

		self.boxLayout:addElement(self.IndoorCamFirst)

		self.IndoorCamFirst:setState(registerIndoorCamFirst.indoorActivationState)

		self.IndoorCamFirst:setTexts({g_i18n:getText("setting_IndoorCamFirst_selection_on"), g_i18n:getText("setting_IndoorCamFirst_selection_off")})

		self.initIndoorCamFirstGuiDone = true
	end
end

function registerIndoorCamFirst.updateSimpleICGui(self)
	if self.initIndoorCamFirstGuiDone and self.IndoorCamFirst ~= nil then
		self.IndoorCamFirstActivation:setState(registerIndoorCamFirst.indoorActivationState)
	end
end

function registerIndoorCamFirst:onIndoorCamFirstActivationChanged(state)
	self.indoorActivationState = state;
	if state == 1 then
		self.indoorActivation = true;
	else
		self.indoorActivation = false;
	end;
	registerIndoorCamFirst:saveSettings()
end

function registerIndoorCamFirst.saveSettings(self)
	print("registerIndoorCamFirst saveSettings")
	local filename = registerIndoorCamFirst.modSettingsDir.."settings.xml"
	local key = "settings"
	local saved = false
	
	createFolder(registerIndoorCamFirst.modSettingsDir)
	local xmlFile = XMLFile.create("settingsXML", filename, key)

	if xmlFile ~= nil then
		xmlFile:setBool(key..".indoorActivation", self.indoorActivation)
		xmlFile:setInt(key..".indoorActivationState", self.indoorActivationState)

		xmlFile:save()
		xmlFile:delete()
		saved = true
		print("registerIndoorCamFirst saveSettings finished")
	end
	return saved
end

function registerIndoorCamFirst.loadSettings(self)
	local loaded = false
	local filename = registerIndoorCamFirst.modSettingsDir.."settings.xml"
	local key = "settings"

	createFolder(registerIndoorCamFirst.modSettingsDir)
	local xmlFile = XMLFile.loadIfExists("settingsXML", filename, key)

	if xmlFile ~= nil then
		self.indoorActivation = xmlFile:getBool(key..".indoorActivation") or self.indoorActivation
		self.indoorActivationState = xmlFile:getInt(key..".indoorActivationState") or self.indoorActivationState

		xmlFile:delete()
		loaded = true
	end
	return loaded
end

function init()
	InGameMenuGeneralSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameOpen, registerIndoorCamFirst.initSimpleICGui)
	InGameMenuGeneralSettingsFrame.updateGameSettings = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.updateGameSettings, registerIndoorCamFirst.updateSimpleICGui)	
end

function registerIndoorCamFirst:register(name)

	if registerIndoorCamFirst.installed == nil then

		g_specializationManager:addSpecialization("IndoorCamFirst", "IndoorCamFirst", modDirectory.."src/IndoorCamFirst.lua", nil)

		for vehicleType, typeDef in pairs(g_vehicleTypeManager.types) do

			if typeDef ~= nil then
				local isDrivable = false
				local isEnterable = false
				local hasMotor = false
				for name, spec in pairs(typeDef.specializationsByName) do
					if name == "drivable" then
						isDrivable = true
					elseif name == "motorized" then
						hasMotor = true
					elseif name == "enterable" then
						isEnterable = true
					end
				end

				if isDrivable and isEnterable and hasMotor and vehicleType ~= "locomotive" and vehicleType ~= "conveyorBelt" and vehicleType ~= "pickupConveyorBelt" and vehicleType ~= "woodCrusherTrailerDrivable" and vehicleType ~= "baleWrapper" then
					if typeDef.specializationsByName["IndoorCamFirst"] == nil then
						g_vehicleTypeManager:addSpecialization(vehicleType, "FS22_gameplay_IndoorCamFirst.IndoorCamFirst")
					end;
				end
			end
		end

		registerIndoorCamFirst.installed = true
	end
end

function registerIndoorCamFirst:loadMap()
	registerIndoorCamFirst:loadSettings()
end

TypeManager.finalizeTypes = Utils.prependedFunction(TypeManager.finalizeTypes, registerIndoorCamFirst.register)

init()

addModEventListener(registerIndoorCamFirst)
