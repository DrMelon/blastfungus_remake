include('shared.lua')

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
	self.DebugDraw = false
end

function ENT:Draw()
	self.DebugDraw = (GetConVar("fungus_evolve_debug_draw"):GetInt() == 1)
	self:DrawModel()
	local angle = Angle(0, 0, 90)
	if(self.DebugDraw == true) then
		cam.Start3D2D( self:GetPos(), angle, 1 )
			draw.DrawText(self:GetNWString("m"), "ChatFont", 0, -32, Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	
		cam.Start3D2D( self:GetPos(), angle, 0.4 )
			draw.DrawText(self:GetNWString("dna"), "ChatFont", 0, -16, Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), TEXT_ALIGN_CENTER )
		cam.End3D2D()
	end
	render.DrawLine(self:GetPos(), self:GetNWVector("parentpos"), Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), true)
end