--[[-----------------------------------------------------------------------------
InteractiveLabel Widget
-------------------------------------------------------------------------------]]
local Type, Version = "CalendarDay", 1
local AceGUI = LibStub and LibStub("AceGUI-3.0", true)
if not AceGUI or (AceGUI:GetWidgetVersion(Type) or 0) >= Version then return end

-- Lua APIs
local select, pairs = select, pairs

--[[-----------------------------------------------------------------------------
Scripts
-------------------------------------------------------------------------------]]
local function Frame_OnEnter(frame)
	frame.obj:Fire("OnEnter")
end

local function Frame_OnLeave(frame)
	frame.obj:Fire("OnLeave")
end

local function Frame_OnClick(frame, button)
	frame.obj:Fire("OnClick", button)
	AceGUI:ClearFocus()
end

--[[-----------------------------------------------------------------------------
Methods
-------------------------------------------------------------------------------]]
local methods = {
	["OnAcquire"] = function(self)
		self:SetDay("?");
		self:SetFlag("");
		self:SetText("");
		self:UpdateColors();
	end,

	-- ["OnRelease"] = nil,

	["SetDay"] = function(self, ...)
		self.day:SetText(...)
	end,

	["SetFlag"] = function(self, ...)
		self.flag:SetText(...)
	end,

	["SetText"] = function(self, ...)
		self.text:SetText(...)
	end,

	["SetActive"] = function(self, active)
		self.active = active;
		self:UpdateColors();
	end,

	["SetMuted"] = function(self, muted)
		self.muted = muted;
		self:UpdateColors();
	end,

	["UpdateColors"] = function(self)
		if self.active then
			self.day:SetTextColor(1, 1, 1);
			self.backgroundOuter:SetColorTexture(1, 1, 1, 0.4);
		else
			if self.muted then
				self.day:SetTextColor(1, 1, 1);
				self.backgroundOuter:SetColorTexture(0.4, 0.4, 0.4, 0.4);
			else
				self.day:SetTextColor(0.8, 0.8, 0.4);
				self.backgroundOuter:SetColorTexture(0.8, 0.8, 0.4, 0.4);
			end
		end
	end
}

--[[-----------------------------------------------------------------------------
Constructor
-------------------------------------------------------------------------------]]
local function Constructor()
	local name = "AceGUI30CalendarDay" .. AceGUI:GetNextWidgetNum(Type);
	local frame = CreateFrame("Button", name, UIParent);
	frame:Hide();
	frame:EnableMouse(true);
	frame:SetScript("OnEnter", Frame_OnEnter);
	frame:SetScript("OnLeave", Frame_OnLeave);
	frame:SetScript("OnMouseDown", Frame_OnClick);

	local backgroundOuter = frame:CreateTexture(nil, "BORDER");
	backgroundOuter:SetColorTexture(0.4, 0.4, 0.4, 0.4);
	backgroundOuter:SetPoint("TOPLEFT", 2, -2);
	backgroundOuter:SetPoint("BOTTOMRIGHT", -2, 2);
	local backgroundInner = frame:CreateTexture(nil, "ARTWORK");
	backgroundInner:SetColorTexture(0, 0, 0, 0.8);
	backgroundInner:SetPoint("TOPLEFT", 3, -3);
	backgroundInner:SetPoint("BOTTOMRIGHT", -3, 3);

	local textDay = frame:CreateFontString(nil, "OVERLAY");
	textDay:SetFont("Fonts\\FRIZQT__.TTF", 13, "THICKOUTLINE");
	textDay:SetPoint("TOPLEFT", 4, -4);

	local textFlag = frame:CreateFontString(nil, "OVERLAY");
	textFlag:SetFont("Fonts\\FRIZQT__.TTF", 13);
	textFlag:SetPoint("TOPRIGHT", 4, 4);

	local textContent = frame:CreateFontString(nil, "OVERLAY");
	textContent:SetFont("Fonts\\FRIZQT__.TTF", 10);
	textContent:SetJustifyH("LEFT");
	textContent:SetJustifyV("TOP");
	textContent:SetNonSpaceWrap(true);
	textContent:SetPoint("TOPLEFT", 4, -16);
	textContent:SetPoint("BOTTOMRIGHT", -4, -2);

	local widget = {
		frame = frame, text  = text, type  = Type,
		active = false, muted = false,
		backgroundOuter = backgroundOuter, backgroundInner = backgroundInner,
		day = textDay, flag = textFlag, text = textContent
	}
	for method, func in pairs(methods) do
		widget[method] = func
	end

	return AceGUI:RegisterAsWidget(widget)
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
