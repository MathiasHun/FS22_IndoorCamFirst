--
-- Mod: IndoorCamFirst
--
-- Author: Stephan
-- email: Stephan910@web.de
-- @Date: 13.03.2019
-- @Version: 1.0.0

-- #############################################################################

IndoorCamFirst = {};
IndoorCamFirst.Version = "1.0.0.0";
local myName = "FS22_gameplay_IndoorCamFirst";

IndoorCamFirst.directory = g_currentModDirectory;

function IndoorCamFirst:prerequisitesPresent(specializations)
	return true;
end;

function IndoorCamFirst:delete()

end;

function IndoorCamFirst:loadMap(name)
end;

function IndoorCamFirst.registerEventListeners(vehicleType)
	for _,n in pairs( {"onEnterVehicle", "onLeaveVehicle"} ) do
		SpecializationUtil.registerEventListener(vehicleType, n, IndoorCamFirst);
	end
end

function IndoorCamFirst:init(vehicle)
	vehicle.indoorCamFirst = {};
	vehicle.indoorCamFirst.initialized = true;

	if vehicle.spec_enterable ~= nil and registerIndoorCamFirst.indoorActivationState == 1 then
		for camIndex, camera in pairs(vehicle.spec_enterable.cameras) do
			if camera.isInside then
				vehicle.spec_enterable:setActiveCameraIndex(camIndex);
			end;
		end;
	end;
end;

function IndoorCamFirst:onEnterVehicle()
	if self.spec_enterable ~= nil and self.getIsEntered ~= nil and self:getIsEntered() then
		if self.indoorCamFirst == nil and registerIndoorCamFirst.indoorActivationState == 1 then
			IndoorCamFirst:init(self);
		else
			if self.lastCam ~= nil and registerIndoorCamFirst.indoorActivationState == 1 then
				if g_gameSettings:getValue("resetCamera") and (self.lastCam ~= self.spec_enterable.camIndex) then
					self.spec_enterable:setActiveCameraIndex(self.lastCam);
				else
					self.spec_enterable:setActiveCameraIndex(2);
				end;
			end;
		end;
	end;
end;

function IndoorCamFirst:onLeaveVehicle()
	if self.spec_enterable ~= nil then
		self.lastCam = self.spec_enterable.camIndex;
	end;
end;

addModEventListener(IndoorCamFirst);
