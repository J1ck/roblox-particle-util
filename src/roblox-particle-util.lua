local Selection = game:GetService("Selection")
local CoreGui = game:GetService("CoreGui")

local MainGui = script.Parent:WaitForChild("MainGui")
local EmitCountBox = MainGui:WaitForChild("EmitCount")
local EmitDelayBox = MainGui:WaitForChild("DelayTime")
local EmitButton = MainGui:WaitForChild("EmitButton")
local SelectionModeButton = MainGui:WaitForChild("SelectionMode")

local Connections = {}
local SelectedParticles = {}

local SelectionModeCycle = {
	Default = "Children",
	Children = "Descendants",
	Descendants = "Default"
}

-- // Plugin Init

if plugin:GetSetting("Enabled") == nil then
	plugin:SetSetting("Enabled", true)
	plugin:SetSetting("SelectionMode", "Default")
end

local PluginToolbar = plugin:CreateToolbar("ParticleUtil")

local EnableDisableButton = PluginToolbar:CreateButton("Enable/Disable", "Enable / Disable", "rbxassetid://1507949215", "Enable / Disable")
EnableDisableButton.ClickableWhenViewportHidden = false
EnableDisableButton:SetActive(plugin:GetSetting("Enabled"))

table.insert(Connections, EnableDisableButton.Click:Connect(function()
	local NewSetting = not plugin:GetSetting("Enabled")
	plugin:SetSetting("Enabled", NewSetting)
	EnableDisableButton:SetActive(NewSetting)
	
	MainGui.Parent = NewSetting and CoreGui or script
end))

-- // Events Init

table.insert(Connections, Selection.SelectionChanged:Connect(function()
	local CurrentSelectionMode = plugin:GetSetting("SelectionMode")
	local NewSelection = Selection:Get()
	
	local ShouldBeActive = false
	local DifferentProperties = false
	local CurrentCount, CurrentDelay = nil, nil
	
	SelectedParticles = {}
	
	local function CheckParticle(v)
		if v:IsA("ParticleEmitter") == false then return end
		
		ShouldBeActive = true
		table.insert(SelectedParticles, v)

		if CurrentCount == nil and CurrentDelay == nil then
			CurrentCount, CurrentDelay = v:GetAttribute("EmitCount"), v:GetAttribute("EmitDelay")
		elseif v:GetAttribute("EmitCount") ~= CurrentCount or v:GetAttribute("EmitDelay") ~= CurrentDelay then
			DifferentProperties = true
		end
	end
	
	for _,v in NewSelection do
		CheckParticle(v)
		
		if CurrentSelectionMode == "Children" then
			for _,vv in v:GetChildren() do
				CheckParticle(vv)
			end
		elseif CurrentSelectionMode == "Descendants" then
			for _,vv in v:GetDescendants() do
				CheckParticle(vv)
			end
		end
	end
	
	if DifferentProperties == true then
		EmitCountBox.Text = "..."
		EmitDelayBox.Text = "..."
	else
		EmitCountBox.Text = CurrentCount or ""
		EmitDelayBox.Text = CurrentDelay or ""
	end
	
	MainGui.Enabled = ShouldBeActive
end))

table.insert(Connections, EmitButton.Activated:Connect(function()
	for _,v in SelectedParticles do
		task.delay(v:GetAttribute("EmitDelay") or 0, v.Emit, v, v:GetAttribute("EmitCount") or 1)
	end
end))

local OldEmitCountText = EmitCountBox.Text
table.insert(Connections, EmitCountBox:GetPropertyChangedSignal("Text"):Connect(function()
	local New = EmitCountBox.Text
	
	if New == "..." then return end
	
	if tonumber(New) == nil and New ~= "" and New ~= "." then
		EmitCountBox.Text = OldEmitCountText
	else
		OldEmitCountText = New
		for _,v in SelectedParticles do
			v:SetAttribute("EmitCount", tonumber(New))
		end
	end
end))

local OldDelayTimeText = EmitDelayBox.Text
table.insert(Connections, EmitDelayBox:GetPropertyChangedSignal("Text"):Connect(function()
	local New = EmitDelayBox.Text
	
	if New == "..." then return end
	
	if tonumber(New) == nil and New ~= "" and New ~= "." then
		EmitDelayBox.Text = OldDelayTimeText
	else
		OldDelayTimeText = New
		for _,v in SelectedParticles do
			v:SetAttribute("EmitDelay", tonumber(New))
		end
	end
end))

table.insert(Connections, SelectionModeButton.Activated:Connect(function()
	local CurrentSelectionMode = plugin:GetSetting("SelectionMode")
	local NextMode = SelectionModeCycle[CurrentSelectionMode]
	
	SelectionModeButton.Text = `Selection Mode: {NextMode}`
	
	plugin:SetSetting("SelectionMode", NextMode)
end))

-- // Instance Init & Cleanup

MainGui.Enabled = false
MainGui.Parent = plugin:GetSetting("Enabled") and CoreGui or script

SelectionModeButton.Text = `Selection Mode: {plugin:GetSetting("SelectionMode")}`

plugin.Unloading:Once(function()
	for _,v in Connections do
		v:Disconnect()
	end
	SelectedParticles = {}
	MainGui:Destroy()
end)
