sgs.ai_skill_playerchosen["nanmanxiangEffect"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	local to = {}
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) then
			table.insert(to,p)
		end
	end
	return to
end
sgs.ai_skill_invoke.shengguang = function(self, data)
	--[[local room = self.player:getRoom()
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:getMark("jiluMark") > 0 then
			if self:isEnemy(p) then
				return true
			end
		end
	end
	if self:isWeak(self.player) then return true end
    return false]]--
	return true
end