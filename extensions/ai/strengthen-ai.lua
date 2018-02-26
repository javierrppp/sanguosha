sgs.ai_skill_invoke.danqi = function(self, data)
	local damage = data:toDamage()
	if self:isFriend(damage.to) then
		if damage.to:getEquip(1) and damage.to:getEquip(1):isKindOf("SilverLion") then
			return true
		end
	elseif self:isEnemy(damage.to) then
		return true
	end
    return false
end
sgs.ai_skill_cardchosen["danqi"] = function(self, who, flags)
    local source = self.player
    local room = source:getRoom()
	local suit = source:getTag("damageCardSuit"):toString()
	if who:getEquips():length() > 0 then
	    for _, c in sgs.qlist(who:getEquips()) do
		    if c:getSuitString() == suit then
			    return c:getEffectiveId()
			end
		end
	end
end
sgs.ai_skill_playerchosen["lizhan"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	local to = {}
	for _, p in sgs.qlist(targets) do
		if self:isFriend(p) then
			table.insert(to,p)
		end
	end
	return to
end
sgs.ai_skill_use["@@zhaxiang"] = function(self, prompt)
	local target = nil
	local tianxiang = false
	to_friend = false
	local num = self.player:getHandcardNum() - self.player:getHp()
	if num == 1 then
		for _, p in pairs(self.friends_noself) do
			target = p
			to_friend = true
			break
		end
	elseif num > 1 and num <= 3 then
		for _, p in pairs(self.enemies) do
			if p:getHp() == 1 then
				target = p 
			end
		end
		if not target and num == 3 then
			for _, p in pairs(self.friends_noself) do
				if p:getHp() > 2 then
					target = p
					to_friend = true
				end
				if p:hasShownSkill("tianxiang") then
					target = p
					tianxiang = true
					to_friend = true
					break
				end
			end
		end
		if not target then
			for _, p in pairs(self.enemies) do
				target = p 
				break
			end
		end
	else 
		for _, p in pairs(self.friends_noself) do
			if p:hasShownSkill("guzheng") then
				return false
			end
		end
		for _, p in pairs(self.friends_noself) do
			if p:getHp() > 2 then
				target = p
				to_friend = true
			end
			if p:hasShownSkill("tianxiang") then
				target = p
				tianxiang = true
				to_friend = true
				break
			end
		end
	end
	if not target then return false end
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)
	local need_cards = {}
	if tianxiang then
		for _, c in pairs(cards) do
			if c:getSuit() == sgs.Card_Spade or c:getSuit() == sgs.Card_Heart then
				table.insert(need_cards, c:getId())
				break
			end
		end
	end
	if #need_cards < num then
		for _, c in pairs(cards) do
			if to_friend then
				table.insert(need_cards, c:getId())
			else
				if not c:isKindOf("Peach") and not c:isKindOf("Analeptic") then
					table.insert(need_cards, c:getId())
				end
			end
			if #need_cards >= num then break end
		end
	end
	if target and #need_cards == num then
	    local card_str = "#zhaxiangCard:"..table.concat(need_cards, "+")..":&zhaxiang->" .. target:objectName()
		return card_str	
	end
	return "."
end
sgs.ai_skill_invoke.Ekuanggu = function(self, data)
    return true
end
sgs.ai_skill_choice["Ekuanggu"] = function(self, choices, data)
	if self:isWeak(self.player) or self.player:getHandcardNum() > self.player:getHp() then
		return "recover"
	end
end
sgs.ai_skill_invoke.Ejianxiong = function(self, data)
    return true
end
sgs.ai_skill_choice["Ejianxiong"] = function(self, choices, data)
	local damage = data:toDamage()
	if damage.card:isKindOf("Slash") and self:getCardsNum("Slash") > 0 then
		return "draw1"
	end
	if damage.card:isKindOf("ArcheryAttack") or damage.card:isKindOf("SavageAssault") then
		return "obtain"
	end
	if damage.card:getSubcards():length() > 1 then
		return "obtain"
	else
		if self:getUseValue(damage.card:getSubcards():first()) > 6 then
			return "obtain"
		end
	end
	return "draw1"
end