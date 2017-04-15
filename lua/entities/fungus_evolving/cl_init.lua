include('shared.lua')

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
end