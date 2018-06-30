-----苏飞-----

sgs.ai_skill_invoke.lianpian = function(self, data)
	return true
end

-----黄权-----

sgs.ai_skill_playerchosen["dianhu"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(targets) do 
		if p:getKingdom() ~= source:getKingdom() or p:getRole() == "careerist" then
			return p
		end
	end
	for _, p in sgs.qlist(targets) do 
		if self:isEnemy(p) then
			return p
		end
	end
	return targets:first()
end
sgs.ai_use_value.jianjiCard = 5
sgs.ai_use_priority.jianjiCard = 5
jianji_skill = {}
jianji_skill.name = "jianji"
table.insert(sgs.ai_skills, jianji_skill)
jianji_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#jianjiCard") then
		return sgs.Card_Parse("#jianjiCard:.:&jianji")
	end
end
sgs.ai_skill_use_func["#jianjiCard"] = function(card, use, self)
	self:log("faefwe")
	local room = self.room
	local source = self.player
	local friends_hands = 999
	local target_friend
	for _, p in pairs(self.friends) do
		local x = p:getHandcardNum()
		if x < friends_hands then
			friends_hands = x
			target_friend = p
		end
	end
	local targets = sgs.SPlayerList()
	targets:append(target_friend)
	if targets:length() == 2 then
		use.card = card
		if use.to then use.to = targets end
	end
end