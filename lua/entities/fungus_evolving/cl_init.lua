include('shared.lua')

function ENT:Initialize()
	self:SetRenderMode(RENDERMODE_TRANSALPHA)
	self.RenderGroup = RENDERGROUP_TRANSLUCENT
end

function ENT:Draw()
	self:DrawModel()
	local angle = Angle(0, 0, 90)
	cam.Start3D2D( self:GetPos(), angle, 1 )
		draw.DrawText(self:GetNWString("m"), "ChatFont", 0, -32, Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()
	cam.Start3D2D( self:GetPos(), angle, 0.4 )
		draw.DrawText(self:GetNWString("dna"), "ChatFont", 0, -16, Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), TEXT_ALIGN_CENTER )
	cam.End3D2D()
	render.DrawLine(self:GetPos(), self:GetNWVector("parentpos"), Color( self:GetNWFloat("r"), self:GetNWFloat("g"), self:GetNWFloat("b"), 255 ), true)
end