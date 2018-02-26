-----廖化-----
sgs.ai_skill_invoke.fuli = function(self, data)
    return true
end
-----华雄-----
sgs.ai_skill_invoke.yaowu = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		return true
	end
	return false
end
sgs.ai_skill_invoke.shiyong = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(500)
	local target = data:toPlayer()
	if self:isEnemy(target) then
		local max_num = 0
		for _, c in sgs.qlist(self.player:getHandcards()) do
			if c:getNumber() > max_num then
				max_num = c:getNumber()
			end
		end
		if target:getHandcardNum() >3 then
			if max_num >= 11 then return true end
		elseif target:getHandcardNum() == 3 then
			if max_num >= 10 then return true end
		elseif target:getHandcardNum() == 2 then
			if max_num >= 9 then return true end
		else
			if max_num >= 8 then return true end
		end
	end
	return false
end
-----孙皓-----
sgs.ai_skill_invoke.canshi = function(self, data)
	local room = self.player:getRoom()
	local num = 0
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:isWounded() then
			num = num + 1
		end
	end
	if num >= 4 then return true end
	if num > 2 and self.player:isSkipped(sgs.Player_Play) then return true end
	return false
end
-----牛金-----
sgs.ai_skill_invoke.cuorui = function(self, data)
	if self.player:getHp() == 1 then return true end
	for _, enemy in pairs(self.enemies) do
	    if enemy:getHp() == 1 then
		    return true
		end
	end
	return false
end
-----张春华-----
sgs.ai_skill_invoke.jueqing = function(self, data)
	local damage = data:toDamage()
	if damage.to and damage.to:getHp() - damage.damage <= 0 then
		if self.player:hasShownOneGeneral() then
			if damage.to:getKingdom() ~= self.player:getKingdom() then return false end
		else
			if damage.to:getKingdom() == self.player:getKingdom() then return false end
		end
	end
	return self:isFriend(data:toPlayer())
end
sgs.ai_skill_invoke.shangshi = function(self, data)
    return true
end
sgs.ai_skill_cardask["@cuorui"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if not card:isKindOf("Peach") and not card:isKindOf("Analeptic") and not card:isKindOf("ExNihilo") then
			return card:toString()
		end
	end
	for _,card in pairs(cards) do
		return card:toString()
	end
	local cards1 = self.player:getCards("he")
	return cards1:first():toString()
end
-----张绣-----
sgs.ai_skill_invoke.tusha = function(self, data)
	return self:isEnemy(data:toPlayer())
end
sgs.ai_skill_invoke.jiaoxie = function(self, data)
	local target = data:toPlayer()
	if self:isFriend(target) then
		if target:getEquip(1) and target:getEquip(1):isKingOf("SilverLion") and target:isWounded() then return true end
	end
	return self:isEnemy(data:toPlayer())
end
-----步练师-----
sgs.ai_use_value.anxuCard = 118
sgs.ai_use_priority.anxuCard = 119
anxu_skill = {}
anxu_skill.name = "anxu"
table.insert(sgs.ai_skills, anxu_skill)
anxu_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#anxuCard") then
		return sgs.Card_Parse("#anxuCard:.:&anxu")
	end
end
sgs.ai_skill_use_func["#anxuCard"] = function(card, use, self)
	local room = self.room
	local enemies_hands = 999
	local friends_hands = 999
	local target_enemy = nil
	local target_friend = nil
	local hide_general = nil
	local targets = sgs.SPlayerList()
    for _, p in pairs(self.friends) do
		if p:objectName() ~= self.player:objectName() then 
			local x = p:getHandcardNum()
			if x < friends_hands then
				friends_hands = x
				target_friend = p
			end
		end
	end
	for _, p in pairs(self.enemies) do
		if p:objectName() ~= self.player:objectName() then 
			local x = p:getHandcardNum()
			if x < enemies_hands and x > friends_hands then
				enemies_hands = x
				target_enemy = p
			end
		end
	end
	if target_friend and target_enemy then
		targets:append(target_enemy)
		targets:append(target_friend)
	elseif target_friend and hide_general then
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if p:objectName() ~= target_friend:objectName() and p:getHandcardNum() > target_friend:getHandcardNum() then
				if not self:isFriend(p) or not p:hasShownOneGeneral() then
					hide_general = p
					break
				end
			end
		end
		targets:append(target_enemy)
		targets:append(hide_general)
	else
		for _, p in sgs.qlist(room:getOtherPlayers(self.player))do
			if targets:length() == 0 then targets:append(p) end
			for _, q in sgs.qlist(room:getOtherPlayers(self.player)) do
				if q:objectName() ~= p:objectName() then
					if targets:first():getHandcardNum() > q:getHandcardNum() then
						if not self:isFriend(targets:first()) then
							targets:append(q)
						end
					elseif targets:first():getHandcardNum() < q:getHandcardNum() then
						if not self:isFriend(q) then
							targets:append(q)
							break
						end
					end
				end
			end
			if targets:length() == 2 then break end
			targets:removeOne(p)
		end
	end
	if targets:length() == 2 then
		use.card = card
		if use.to then use.to = targets end
	end
end
sgs.ai_skill_playerchosen["zhuiyi"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	local players = room:getOtherPlayers(source)
	local killer = source:property("zhuiyiprop"):toString()
	for _, p in sgs.qlist(room:getOtherPlayers(source)) do
		if p:objectName() == killer then
			players:removeOne(p)
			break
		end
	end
	local min_hp = 999
	local zhuiyi_target
	for _, p in sgs.qlist(players) do
		if self:isFriend(p) then
			if p:getHp() < min_hp then
				min_hp = p:getHp()
				zhuiyi_target = p 
			end
		end
	end
	if zhuiyi_target then return zhuiyi_target end
	return nil
end
-----徐庶-----
sgs.ai_skill_invoke.wuyan = function(self, data)
	local damage = data:toDamage()
	if damage.to:objectName() == self.player:objectName() then
		return true
	end
	return false
end
sgs.ai_skill_use["@@jujian"] = function(self, prompt)
	self:sort(self.friends, "hp")
	local target = nil
	for _, p in pairs(self.friends) do
		if p:objectName() ~= self.player:objectName() then
			if not p:faceUp() then
				target = p
				break
			end
		end
	end
	if not target then
		for _, p in pairs(self.friends) do
			if p:objectName() ~= self.player:objectName() then
				target = p
				break
			end
		end
	end
	local hesitate = false
	if self:isWeak(self.player) then
		hesitate = true
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local need_card = nil
	for _, c in pairs(cards) do
		if not c:isKindOf("BasicCard") then
			if c:isKindOf("JadeSeal") or c:isKindOf("PeaceSpell") or c:isKindOf("RenwangShield") or c:isKindOf("EightDiagram") then
				if not hesitate then
					need_card = c:getEffectiveId()
					break
				end
			else
				need_card = c:getEffectiveId()
				break
			end
		end
	end
	if target and need_card then
	    local card_str = "#jujianCard:"..need_card..":&jujian->" .. target:objectName()
		return card_str	
	end
	return "."
end
sgs.ai_skill_choice["jujian"] = function(self, choices, data)
    local source = self.player
    local room = source:getRoom()
	if not source:faceUp() then
		if not source:isWeak() then
			return "reset"
		else
			if source:getHp() == 1 then return "recover"
			else return "draw" end
		end
	end
	if source:getHp() == 1 then return "recover"
	else return "draw"
	end
end
-----简雍-----
sgs.ai_skill_invoke.zongshi = function(self, data)
	local room = self.room
	room:getThread():delay(500)
    return true
end
sgs.ai_use_priority.qiaoshuiCard = 7
qiaoshui_skill = {}
qiaoshui_skill.name = "qiaoshui"
table.insert(sgs.ai_skills, qiaoshui_skill)
qiaoshui_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#qiaoshuiCard") then
		return sgs.Card_Parse("#qiaoshuiCard:.:&qiaoshui")
	end
end
sgs.ai_skill_use_func["#qiaoshuiCard"] = function(card, use, self)
	local room = self.room
	if self.player:isKongcheng() then return false end
	local targets = sgs.SPlayerList()
	for _, p in pairs(self.friends) do
		if p:getJudgingArea():length() > 0 and not p:isKongcheng() then
			for _, c in sgs.qlist(p:getJudgingArea()) do
				if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then
					if p:getHandcardNum() >= 2 then
						targets:append(p)
					end
				elseif c:isKindOf("Lightning") then
					if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
						targets:append(p)
					end
				end
			end
		end
	end
	if targets:length() == 0 then
		local max_number = 0
		for _, c in sgs.qlist(self.player:getHandcards()) do
			if c:getNumber() > max_number then
				max_number = c:getNumber()
			end
		end
		local has_Spade = false
		for _, c in sgs.qlist(self.player:getHandcards()) do
			if c:getSuit() == sgs.Card_Spade then
				has_Spade = true
			end
		end
		if self.player:getHandcardNum() < self.player:getHp() and not has_Spade then 
			if max_number < 10 then 
				return false
			end
		end
	end
	if targets:length() == 0 then
		for _, p in pairs(self.enemies) do
			if p:getCards("he"):length() > 1 and not p:isKongcheng() then
				targets:append(p) 
			end
		end
	end
	if targets:length() == 1 then
		use.card = card
		if use.to then use.to = targets end
	end
end
-----陈群-----
sgs.ai_skill_invoke.faen = function(self, data)
    return self:isFriend(data:toPlayer())
end
sgs.ai_skill_playerchosen["dingpin"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	room:getThread():delay(1000)
	local guojia = nil
	local max_losthp = 0
	local max_losthp_player = nil
	for _, p in ipairs(self.friends) do
		if p:hasShownSkill("tiandu") then
			guojia = p
		end
		if p:getMaxHp() - p:getHp() > max_losthp then
			max_losthp = p:getMaxHp() - p:getHp()
			max_losthp_player = p 
		end
	end
	if guojia and max_losthp_player and guojia:objectName() == max_losthp_player:objectName() then return guojia
	elseif guojia and guojia:getMaxHp() - guojia:getHp() >= max_losthp - 1 then return guojia
	elseif max_losthp_player then return max_losthp_player
	elseif guojia then return guojia end
	return nil
end
sgs.ai_skill_playerchosen["faen"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	room:getThread():delay(1000)
	local min_hp =999
	local min_card = 999
	local min_hp_player = nil
	local min_card_player = nil
	for _, p in ipairs(self.friends) do
		if p:objectName() ~= source:objectName() then
			if p:getHp() < min_hp then
				min_hp = p:getHp()
				min_hp_player = p 
			elseif p:getHp() == min_hp then
				if p:getHandcardNum() + p:getEquips():length() < min_hp_player:getHandcardNum() + min_card_player:getEquips():length() then
					min_hp_player = p 
				end
			end
			if p:getHandcardNum() + p:getEquips():length() < min_card then
				min_card = p:getHandcardNum() + p:getEquips():length()
				min_card_player = p 
			elseif p:getHandcardNum() + p:getEquips():length() == min_card then
				if p:getHp() < min_card_player:getHp() then
					min_card_player = p 
				end
			end
		end
	end
	if min_hp_player and min_card_player then
		if min_hp_player:getHandcardNum() + min_hp_player:getEquips():length() < min_card + 3 then return min_hp_player
		else return min_card_player end
	elseif min_hp_player then return min_hp_player
	elseif min_card_player then return min_card_player end
	return nil
end
-----糜竺-----
sgs.ai_use_value.ziyuanCard = 118
sgs.ai_use_priority.ziyuanCard = 119
ziyuan_skill = {}
ziyuan_skill.name = "ziyuan"
table.insert(sgs.ai_skills, ziyuan_skill)
ziyuan_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#ziyuanCard") then
		return sgs.Card_Parse("#ziyuanCard:.:&ziyuan")
	end
end
sgs.ai_skill_use_func["#ziyuanCard"] = function(card, use, self)
	local room = self.room
	local targets = sgs.SPlayerList()
	for _, p in pairs(self.friends) do
		if p:getHp() == 1 and p:getHandcardNum() <= 1 then
			targets:append(p)
		end
	end
	if targets:length() == 0 then
		for _, p in pairs(self.friends) do
			if p:getHp() == 1 then
				targets:append(p)
			end
		end
	end
	if targets:length() == 0 then
		for _, p in pairs(self.friends) do
			if p:getHandcardNum() <= 1 then
				targets:append(p)
			end
		end
	end
	if targets:length() == 1 then
		use.card = card
		if use.to then use.to = targets end
	end
end
sgs.ai_skill_invoke.jugu = function(self, data)
    return true
end
sgs.ai_skill_cardask["@jugu"] = function(self, data, pattern, target, target2)
	local source = self.player
    local room = self.player:getRoom()
	local cards = source:getCards("he")
	room:getThread():delay(1000)
	local num = source:getJudgingArea():length() --经检测发现，for循环判定区中的最后一个被访问的牌是第一个被判定的牌
	local x = 1
	for _, card in sgs.qlist(source:getJudgingArea()) do
		if x ~= num then
			x = x + 1
		else
			if card:isKindOf("Indulgence") then
				local usecard = nil
				for _, d in sgs.qlist(cards) do
					if d:getSuit() == sgs.Card_Heart then
						if usecard and self:getUseValue(usecard) > self:getUseValue(d) then
							usecard = d  
						elseif usecard == nil then
							usecard = d
						end
					end
				end
				if usecard then return usecard:toString() end
			elseif card:isKindOf("SupplyShortage") then
				local usecard = nil
				for _, d in sgs.qlist(cards) do
					if d:getSuit() == sgs.Card_Club then
						if usecard and self:getUseValue(usecard) > self:getUseValue(d) then
							usecard = d  
						elseif usecard == nil then
							usecard = d
						end
					end
				end
				if usecard then return usecard:toString() end
			elseif card:isKindOf("Lightning") then
				local usecard = nil
				for _, d in sgs.qlist(cards) do
					if not (d:getSuit() == sgs.Card_Spade and d:getNumber() >= 2 and d:getNumber() <= 9) then
						if usecard and self:getUseValue(usecard) > self:getUseValue(d) then
							usecard = d  
						elseif usecard == nil then
							usecard = d
						end
					end
				end
				if usecard then return usecard:toString() end
			end
		end
	end
	return "."
end
-----刘协-----
sgs.ai_use_value.mizhaoCard = 23
sgs.ai_use_priority.mizhaoCard = 13
mizhao_skill = {}
mizhao_skill.name = "mizhao"
table.insert(sgs.ai_skills, mizhao_skill)
mizhao_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#mizhaoCard") then
		return sgs.Card_Parse("#mizhaoCard:.:&mizhao")
	end
end
sgs.ai_skill_use_func["#mizhaoCard"] = function(card, use, self)
	local room = self.room
	local source = self.player
	local targets = sgs.SPlayerList()
	local num = source:getHandcardNum()
	if room:getAlivePlayers():length() <= 2 then return false end
	if num == 0 then return false end
	if num == 1 then
		if source:getHandcards():first():getNumber() < 7 then
			local min_hp = 999
			local min_hp_player = nil
			for _, p in pairs(self.enemies) do
				if p:isKongcheng() and p:getHp() < min_hp then
					min_hp = p:getHp()
					min_hp_player = p 
				end
			end
			if min_hp_player == nil then
				if self:getUseValue(source:getHandcards():first()) >= 7 then return false end
				for _, p in pairs(self.enemies) do
					if p:getHandcardNum() == 1 and p:getHp() < min_hp then
						min_hp = p:getHp()
						min_hp_player = p 
					end
				end
			end
			if min_hp_player == nil then
				for _, p in pairs(self.enemies) do
					if p:getHp() < min_hp then
						min_hp = p:getHp()
						min_hp_player = p 
					end
				end
			end
			if min_hp_player then targets:append(min_hp_player) end
		else
			local min_card = 999
			local min_card_player = nil
			for _, p in sgs.qlist(self.enemies) do
				if p:getHandcardNum() < min_card then
					min_card = p:getHandcardNum()
					min_card_player = p 
				elseif p:getHandcardNum() == min_card then
					if p:getHp() < min_card_player:getHp()then
						min_card_player = p 
					end
				end
			end
			if min_card_player then targets:append(min_card_player) end
		end
	else
		local max_cardNum = 0
		for _, c in sgs.qlist(source:getHandcards()) do
			if c:getNumber() > max_cardNum then
				max_cardNum = c:getNumber()
			end
		end
		if max_cardNum > 7 then
			local max_hp = 0
			local max_hp_player = nil
			for _, p in pairs(self.friends) do
				if p:objectName() ~= source:objectName() then
					if p:getHp() > max_hp then
						max_hp = p:getHp()
						max_hp_player = p
					elseif p:getHp() == max_hp then
						if p:getHandcardNum() > max_hp_player:getHandcardNum() then
							max_hp_player = p 
						end
					end
				end
			end
			if max_hp_player then targets:append(max_hp_player) end
		else
			for _, p in pairs(self.friends) do
				if p:objectName() ~= source:objectName() then
					if p:getHandcardNum() + source:getHandcardNum() > 3 and p:getHp() >= 2 then
						targets:append(p)
						break
					end
				end
			end
		end
	end
	local ids={}
	for _,card in sgs.qlist(source:getHandcards()) do
	    table.insert(ids, card:getEffectiveId())
	end
    local card_str = sgs.Card_Parse("#mizhaoCard:"..(table.concat(ids,"+"))..":&mizhao")	
    assert(card_str)
	if targets:length() == 1 then
		use.card = card_str
		if use.to then use.to = targets end
	end
end
sgs.ai_skill_playerchosen["mizhao"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	room:getThread():delay(1000)
	local min_hp = 999
	local min_hp_player = nil
	for _, p in pairs(self.enemies) do
		if not (p:getEquip(1) and p:getEquip(1):isKindOf("Vine")) and not p:isKongcheng() then
			if p:getHp() < min_hp then
				min_hp = p:getHp()
				min_hp_player = p 
			elseif p:getHp() == min_hp then
				if p:getHandcardNum() < min_hp_player:getHandcardNum() then
					min_hp_player = p 
				end
			end
		end
	end
	local min_card = 999
	local min_card_player = nil
	for _, p in pairs(self.enemies) do
		if not (p:getEquip(1) and p:getEquip(1):isKindOf("Vine")) and not p:isKongcheng() then
			if p:getHp() < min_card then
				min_card = p:getHp()
				min_card_player = p 
			elseif p:getHp() == min_card then
				if p:getHp() < min_card_player:getHp() then
					min_card_player = p 
				end
			end
		end
	end
	if min_card_player and min_hp_player and min_card_player:objectName() == min_hp_player:objectName() then
		return min_card_player
	elseif min_hp_player and min_hp_player:getHandcardNum() > min_card - 1 then
		return min_hp_player
	elseif min_hp_player then
		return min_hp_player
	end
	return targets:first()
end
sgs.ai_skill_invoke.tianming = function(self, data)
	local source = self.player
	local room = source:getRoom()
	local use = data:toCardUse()
	if use.card:isBlack() and source:getEquip(1) and source:getEquip(1):isKindOf("RenwangShield") then return false end
	if self:getCardsNum("Jink") > 0 then return false end
	if use.card:isKindOf("FireSlash") and source:getEquip(1) and source:getEquip(1):isKindOf("Vine") then return true end
	if source:getEquip(1) and source:getEquip(1):isKindOf("EightDiagram") then return false end
	local num = 0
	for _, c in sgs.qlist(source:getCards("he")) do
		if not c:isKindOf("Peach") then num = num + 1 end
		if num >= 2 then break end
	end
	if num >= 2 then return true end
	if source:getCards("he"):length() <= 1 then return true end
    return false
end
-----步骘-----
sgs.ai_skill_playerchosen.hongde = function(self, targets)
	if not self:willShowForAttack() and not self:willShowForDefence() then return nil end
	
	local function findhongdeFriend(except)
		local friend = self:findPlayerToDraw(false)
		if friend and (not except or friend:objectName() ~= except:objectName()) then return friend end
		
		local other_friends = self.friends_noself
		if except then table.removeOne(other_friends, except) end
		self:sort(other_friends)
		for _, friend in ipairs(other_friends) do
			if --[[not hasManjuanEffect(friend) and]] not self:needKongcheng(friend, true) then	
				return friend
			end
		end
		return nil
	end
	
	if self.player:getPhase() == sgs.Player_Draw and self.haoshi_target then
		local target = self.haoshi_target
		local otherPlayers = sgs.QList2Table(self.room:getOtherPlayers(self.player))
		self:sort(otherPlayers, "handcard")
		local least_handcard_player = otherPlayers[1]
		
		local friend = findhongdeFriend()
		if not friend then return nil end
		if friend:objectName() ~= target:objectName() then return friend end
		if #otherPlayers > 1 and friend:getHandcardNum() < otherPlayers[2]:getHandcardNum() then return friend end
		
		return findhongdeFriend(friend)
	end
	
	local friend = findhongdeFriend()
	if friend and friend:hasFlag("DimengTarget") and not self.player:hasFlag("DimengTarget") then
		local other_dimeng_target
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if p:hasFlag("DimengTarget") and p:objectName() ~= friend:objectName() then
				other_dimeng_target = p
			end
		end
		if other_dimeng_target then return other_dimeng_target end
		
		return findhongdeFriend(friend)
	else
		return friend
	end
end
sgs.ai_playerchosen_intention.hongde = function(self, from, to)
	if not to:hasFlag("DimengTarget") then
		sgs.updateIntention(from, to, -80)
	end
end
local dingpan_skill = {}
dingpan_skill.name = "dingpan"
table.insert(sgs.ai_skills, dingpan_skill)
dingpan_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	local big_kingdoms = self.player:getBigKingdoms("AI")
	local big_kingdom_count = 0
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if not p:hasShownOneGeneral() then continue end
		if table.contains(big_kingdoms, p:objectName()) or (table.contains(big_kingdoms, p:getKingdom()) and (p:getRole() ~= "careerist")) then
			big_kingdom_count = big_kingdom_count + 1
		end
	end
	if self.player:usedTimes("#dingpanCard") >= math.max(1, big_kingdom_count) then return nil end

	local can_invoke = false
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getEquips():length() > 0 then
			can_invoke = true
		end
	end
	if not can_invoke then return nil end
	return sgs.Card_Parse("#dingpanCard:.:&dingpan") 
end
sgs.ai_skill_use_func["#dingpanCard"] = function(card, use, self)
	local target
	if self.player:getEquips():length() > 0 and (self.player:hasSkills(sgs.lose_equip_skill .. "|tuntian|lirang") or self:needToThrowArmor()
		or (self.player:hasSkills(sgs.masochism_skill) and not self:isWeak()) or self:needToLoseHp(self.player, self.player)
		or (self.player:getEquips():length() >= 2 and not self:isWeak() and self.player:hasSkill("hongde") and self.player:getMark("hongde") < 4 and self:findFriendsByType(sgs.Friend_Draw))
		or not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, self.player) or self:getDamagedEffects(self.player, self.player, false)) then
		target = self.player
	end
	if not target then
		self:sort(self.friends_noself, "defense")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _,p in ipairs(self.friends_noself) do
			if p:getEquips():length() > 0 and (p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") or self:needToThrowArmor(p)
				or (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) or self:needToLoseHp(p, self.player)
				or not self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) or self:getDamagedEffects(p, self.player, false))
				and not self:willSkipPlayPhase(p) and not self:needKongcheng(p, true) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and p:hasShownSkills(sgs.need_equip_skill)
				and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and not p:hasShownSkills(sgs.cardneed_skill)
				and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
			if use.to:length() >= 1 then return end
		end
	end		
end
sgs.ai_use_value.dingpanCard = 5
sgs.ai_use_priority.dingpanCard = 2.62
sgs.ai_skill_choice.dingpan = function(self, choices, data)
	local buzhi = self.room:findPlayerBySkillName("dingpan")
	if (self.player:hasSkills(sgs.lose_equip_skill) and (self.player:getHp() > 2 or hasBuquEffect(self.player)))
		or (self.player:hasArmorEffect("SilverLion") and self.player:isWounded() and (self.player:getHp() >= 2 or hasBuquEffect(self.player)))
		or (self.player:hasSkills(sgs.masochism_skill) and not self:isWeak()) or self:needToLoseHp(self.player, buzhi)
		or (self.player:getEquips():length() >= 2 and not self:isWeak() and self.player:hasSkill("hongde") and self.player:getMark("hongde") < 4 and self:findFriendsByType(sgs.Friend_Draw))
		or not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, buzhi) or self:getDamagedEffects(self.player, buzhi, false) or self:cantbeHurt(self.player, buzhi)
		or (self:getCardsNum("Peach") > 0 and not self.player:isWounded() and not self:willSkipPlayPhase()) then
		return "damage"
	end
	return "discard"
end
-----李通-----
sgs.ai_skill_exchange.tuifeng = function(self, pattern, max_num, min_num, expand_pile)
	if not self:willShowForMasochism() then return {} end
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,c in ipairs(cards) do
		if not (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then
			table.insert(to_discard, c:getEffectiveId())
			return to_discard
		end
	end
	return {}
end
sgs.ai_need_damaged.tuifeng = function(self, attacker, player)
	if not player:hasSkill("tuifeng") then return false end
	local invoke = false
	local hp_limit = 4
	local enemies = self:getEnemies(player)
	if not next(enemies) then return false end
	self:sort(enemies, "hp")
	for _,p in ipairs(enemies) do
		if player:inMyAttackRange(p) and player:canSlash(p) then
			invoke = true
			if self:isWeak(p) then hp_limit = 3 end
			break
		end
	end
	if invoke and player:getCards("he"):length() > 3 and ( player:getHp() >= hp_limit or self:getCardsNum("Peach") > 1) and not self:willSkipPlayPhase(player) then return true end
	return false 
end
function sgs.ai_cardneed.tuifeng(to, card)
	return to:isNude()
end