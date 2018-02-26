-----测试用-----
sgs.ai_chat = {}

function speak(to, type)
	if not sgs.GetConfig("AIChat", false) then return end
	if to:getState() ~= "robot" then return end
	if sgs.GetConfig("OriginAIDelay", 0) == 0 then return end

	if table.contains(sgs.ai_chat, type) then
		local i = math.random(1, #sgs.ai_chat[type])
		to:speak(sgs.ai_chat[type][i])
	end
end

local shop_skill = {}
shop_skill.name = "shop"
table.insert(sgs.ai_skills, shop_skill)
shop_skill.getTurnUseCard = function(self)
	if self.player:getTag("do_not"):toBool() then return end
	if self.player:getMark("buyNum") >= 2 then return end
	--if self.player:usedTimes("#shopCard") >= 2 then return end
	return sgs.Card_Parse("#shopCard:.:&shop")
end
sgs.ai_skill_use_func["#shopCard"] = function(card, use, self)
	use.card = card
end

sgs.ai_skill_choice["shop"] = function(self, choices, data)
    local source = self.player
	local room = source:getRoom()
	local products = source:getTag("products1"):toString():split("+") or {}
	if table.contains(products,"extraProduct") then
		if source:getMark("@coin") > 1 then
			return "extraProduct"
		end
	end
	if table.contains(products,"getYitianjian") then
		if source:getMark("@coin") > 7 then
			if not source:getWeapon() then
				return "getYitianjian"
			end
		end
	end
	if table.contains(products,"getShengguangbaiyi") then
		if source:getMark("@coin") > 7 then
			if not source:getEquip(1) then
				return "getShengguangbaiyi"
			end
		end
	end
	if table.contains(products,"getJuechen") then
		if source:getMark("@coin") > 7 then
			if not source:getEquip(2) then
				return "getJuechen"
			end
		end
	end
	if table.contains(products,"getNanmanxiang") then
		if source:getMark("@coin") > 6 then
			if not source:getEquip(3) then
				return "getNanmanxiang"
			end
		end
	end
	if table.contains(products,"upgradeSoldier") then
		if source:getMark("@coin") > 11 then
			return "upgradeSoldier"
		end
	end
	if table.contains(products,"no_careerist") then
		if source:getMark("@coin") > 11 then
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if p:getKingdom() == source:getKingdom() then
					return "no_careerist"
				end
			end
		end
	end
	if table.contains(products,"peachUse") then
		if source:isWounded() and source:getMark("@coin") > 4 then
			return "peachUse"
		end
	end
	if table.contains(products,"_discard") then
		if source:getMark("@coin") > 1 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"_discard") then
			local need_help = false
			local SilverLion = false
			local equip_need_discard = false
			for _, p in pairs(self.friends) do
				if p:getJudgingArea():length() > 0 then
					for _, c in sgs.qlist(p:getJudgingArea()) do
						if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then 
							need_help = true
						elseif c:isKindOf("Lightning") then
							if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
								need_help = true
							end
						end
					end
				end
				if p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") and self:isWeak(p) then
					SilverLion = true
				end
			end
			for _, p in pairs(self.enemies) do
				if p:getEquip(1) and not p:getEquip(1):isKindOf("Vine") then
					equip_need_discard = true
				end
				if p:getJudgingArea():length() > 0 then
					for _, c in sgs.qlist(p:getJudgingArea()) do
						if c:isKindOf("Lightning") then
							if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
								return "_discard"
							end
						end
					end
				end
			end
			if need_help or SilverLion or equip_need_discard then
				return "_discard"
			end
		end
	end
	if table.contains(products,"super_discard") then
		if source:getMark("@coin") > 3 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"super_discard") then
			for _, p in pairs(self.friends) do
				local need_help = 0
				if p:getJudgingArea():length() > 0 then
					for _, c in sgs.qlist(p:getJudgingArea()) do
						if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then 
							need_help = need_help + 1
						elseif c:isKindOf("Lightning") then
							if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
								need_help = need_help + 1
							end
						end
					end
				end
				if p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") and self:isWeak(p) then
					need_help = need_help + 1
				end
				if need_help > 1 then return "super_discard" end
			end
			for _, p in pairs(self.enemies) do
				if p:getEquip(1) and not p:getEquip(1):isKindOf("Vine") and p:getCards("he"):length() > 1 then
					return "super_discard"
				end
				if p:getJudgingArea():length() > 0 then
					for _, c in sgs.qlist(p:getJudgingArea()) do
						if c:isKindOf("Lightning") then
							if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
								return "super_discard"
							end
						end
					end
				end
			end
		end
	end
	if table.contains(products,"box") then
		if source:getMark("@coin") > 5 then
			if room:getAlivePlayers():length() >= 4 then
				return "box"
			end
		end
	end
	if table.contains(products,"coffer") then
		if source:getMark("@coin") > 6 then
			return "coffer"
		end
	end
	if table.contains(products,"treasure1") then
		if source:getMark("@coin") > 5 then
			if self:isWeak(source) then
				return "treasure1"
			end
		end
	end
	if table.contains(products,"fireGun") then
		if source:getMark("@coin") > 4 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"fireGun") then
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if source:inMyAttackRange(p) and self:isEnemy(p) and p:getEquip(1) and p:getEquip(1):isKindOf("Vine") then
					return "fireGun"
				end
			end
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if source:inMyAttackRange(p) and self:isEnemy(p) and self:isWeak(p) then
					return "fireGun"
				end
			end
		end
	end
	if table.contains(products,"thunder") then
		if source:getMark("@coin") > 3 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"thunder") then
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if source:inMyAttackRange(p) and self:isEnemy(p) and self:isWeak(p) then
					return "thunder"
				end
			end
		end
	end
	if table.contains(products,"bet") then
		if not self:isWeak(source) and source:getMark("@coin") > 1 then
			return "bet"
		end
	end
	if table.contains(products,"getJink") then
		if not table.contains(source:getTag("do_not_choose"):toString():split("+"),"getJink") then
			if self:isWeak() and self:getCardsNum("Jink") == 0 and source:getHp() > 0 and source:getMark("@coin") > 2 then
				return "getJink"
			end
		end
	end
	if table.contains(products,"getAnaleptic") then
		if not table.contains(source:getTag("do_not_choose"):toString():split("+"),"getAnaleptic") then
			local enemy_isWeak = false
			for _, p in pairs(self.enemies) do
				if (self:isWeak(p) or p:isKongcheng()) and source:inMyAttackRange(p) then
					enemy_isWeak = true
					break
				end
			end
			if source:getMark("@coin") > 2 and self:getCardsNum("Analeptic") == 0 and ((self:isWeak() and source:getHp() > 0 and self:getCardsNum("Jink") < source:getHp())) then
				return "getAnaleptic"
			end
		end
	end
	if table.contains(products,"getAwaitExhausted") then
		if source:getMark("@coin") > 3 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"getAwaitExhausted") then
			local invoke = false
			for _, p in pairs(self.friends) do
				if p:hasShownSkill("xiaoji") or p:hasShownSkill("mingzhe") or p:hasShownSkill("hongde") or p:hasShownSkill("lirang") then
					invoke = true
					break
				end
			end
			if source:getEquip(1) and source:getEquip(1):isKindOf("SilverLion") and source:isWounded() then
				invoke = true
			end
			if #self.friends > 2 or invoke then
				return "getAwaitExhausted"
			end
		end
	end
	if table.contains(products,"getFireAttack") then
		if source:getMark("@coin") > 2 and not table.contains(source:getTag("do_not_choose"):toString():split("+"),"getFireAttack") then
			local has_vine = false
			local isWeak = false
			for _, p in pairs(self.enemies) do
				if p:getEquip(1) and p:getEquip(1):isKindOf("Vine") then
					has_vine = true
				end
				if self:isWeak(p) then
					isWeak = true
				end
			end
			if isWeak or has_vine then
				if source:getHandcardNum() > 2 then
					return "getFireAttack"
				end
			end
		end
	end
	if table.contains(products,"slashUse") then
		if not table.contains(source:getTag("do_not_choose"):toString():split("+"),"slashUse") then
			local enemy_isWeak = false
			for _, p in pairs(self.enemies) do
				if p:isKongcheng() and p:hasShownSkill("kongcheng") then continue end
				if (self:isWeak(p) or p:isKongcheng()) and source:inMyAttackRange(p) then
					enemy_isWeak = true
					break
				end
			end
			if source:getMark("@coin") > 2 and enemy_isWeak then
				return "slashUse"
			end
		end
	end
	return "cancel"
end
sgs.ai_skill_playerchosen["shopSlash"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	local enemy_isWeak = false
	for _, p in sgs.qlist(targets) do
		if self:isFriend(p) then continue end
		if p:isKongcheng() and p:hasShownSkill("kongcheng") then continue end
		if (self:isWeak(p) or p:isKongcheng()) then
			return p
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["shopDiscard"] = function(self, targets) 
	local source = self.player
	local room = source:getRoom()
	
	source:speak("discard")
    for _, p in pairs(self.friends) do
		if p:getJudgingArea():length() > 0 then
			for _, c in sgs.qlist(p:getJudgingArea()) do
				if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then 
					return p
				elseif c:isKindOf("Lightning") then
					if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
						return p
					end
				end
			end
		end
		if p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") and self:isWeak(p) then
			return p
		end
	end
	for _, p in pairs(self.enemies) do
		if p:getJudgingArea():length() > 0 then
			for _, c in sgs.qlist(p:getJudgingArea()) do
				if c:isKindOf("Lightning") then
					if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
						return p
					end
				end
			end
		end
		if p:getEquip(1) and not p:getEquip(1):isKindOf("Vine") then
			return p
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["shopSuperDiscard"] = function(self, targets) 
	local source = self.player
	local room = source:getRoom()
	source:speak("discard")
	for _, p in pairs(self.friends) do
		local need_help = 0
		if p:getJudgingArea():length() > 0 then
			for _, c in sgs.qlist(p:getJudgingArea()) do
				if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then 
					need_help = need_help + 1
				elseif c:isKindOf("Lightning") then
					if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
						need_help = need_help + 1
					end
				end
			end
		end
		if p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") and self:isWeak(p) then
			need_help = need_help + 1
		end
		if need_help > 1 then return p end
	end
	for _, p in pairs(self.enemies) do
		if p:getEquip(1) and not p:getEquip(1):isKindOf("Vine") and p:getCards("he"):length() > 1 then
			return p
		end
		if p:getJudgingArea():length() > 0 then
			for _, c in sgs.qlist(p:getJudgingArea()) do
				if c:isKindOf("Lightning") then
					if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
						return p
					end
				end
			end
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["shopThunder"] = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	source:speak("thunder")
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) and self:isWeak(p) then
			return p
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["shopFireGun"] = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	source:speak("fire")
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) and p:getEquip(1) and p:getEquip(1):isKindOf("Vine") then
			return p
		end
	end
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) and self:isWeak(p) then
			return p
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["shopBox"] = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(targets) do
		if self:isFriend(p) then 
			return p
		end
	end
	return "."
end
sgs.ai_skill_playerchosen["texun"] = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) and not p:isKongcheng() then 
			return p
		end
	end
	return "."
end
sgs.ai_skill_askforag["shopTrigger"] = function(self, card_ids)
	local source = self.player
	local room = source:getRoom()
	local suit_table = {}
	for i = 1,4,1 do
		table.insert(suit_table,0)
	end
	for _, d in sgs.qlist(card_ids) do
		local card1 = sgs.Sanguosha:getCard(d)
		if card1:getSuit() == sgs.Card_Spade then
			suit_table[1] =  suit_table[1] + 1
		elseif card1:getSuit() == sgs.Card_Heart then
			suit_table[2] =  suit_table[2] + 1
		elseif card1:getSuit() == sgs.Card_Club then
			suit_table[3] =  suit_table[3] + 1
		elseif card1:getSuit() == sgs.Card_Diamond then
			suit_table[4] =  suit_table[4] + 1
		end
	end
	local max = 0
	local index = -1
	for i = 1,4,1 do
		if suit_table[i] > max then
			max = suit_table[i]
			index = i 
		end
	end
	local suit = nil 
	if i == 1 then suit = sgs.Card_Spade 
	elseif i == 2 then suit = sgs.Card_Heart
	elseif i == 3 then suit = sgs.Card_Club
	elseif i == 4 then suit = sgs.Card_Diamond
	end
	for _, d in sgs.qlist(card_ids) do
		local card1 = sgs.Sanguosha:getCard(d)
		if card1:getSuit() == suit then
			return d
		end
	end
end
sgs.ai_skill_cardask["@jingbing"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in ipairs(cards) do
		if not card:isKindOf("Peach") and not card:isKindOf("Analeptic") then
			return card:toString()
		end
	end
	for _,card in ipairs(cards) do
		return card:toString()
	end
	return cards:first():toString()
end
sgs.ai_skill_invoke.jingbing = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(300)
	if self:isEnemy(room:getCurrent()) then
		return true
	end
    return false
end
sgs.ai_skill_invoke["#mouceTrigger"] = function(self, data)
    return true
end
sgs.ai_skill_invoke["#yongmengTrigger"] = function(self, data)
    return true
end
local yongmeng_skill={}
yongmeng_skill.name="yongmeng"
table.insert(sgs.ai_skills,yongmeng_skill)
yongmeng_skill.getTurnUseCard=function(self)
	local cards = self.player:getCards("he")
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local use_card
	for _,card in ipairs(cards)  do
		if self.player:getMark("@qspade") > 0 and card:getSuit() == sgs.Card_Spade then
			use_card = card
			break
		end
		if self.player:getMark("@qheart") > 0 and card:getSuit() == sgs.Card_Heart then
			use_card = card
			break
		end
		if self.player:getMark("@qclub") > 0 and card:getSuit() == sgs.Card_Club then
			use_card = card
			break
		end
		if self.player:getMark("@qdiamond") > 0 and card:getSuit() == sgs.Card_Diamond then
			use_card = card
			break
		end
	end
	if not use_card then return nil end
	if self.player:getMark("phaseMark") == 1 then
		local suit = use_card:getSuitString()
		local number = use_card:getNumber()
		local card_id = use_card:getEffectiveId()
		local card_str = string.format("slash:yongmeng[%s:%d]=%d&yongmeng",suit, number, card_id)
		local slash = sgs.Card_Parse(card_str)
		assert(slash)
		return slash
	elseif self.player:getMark("phaseMark") == 2 then
		local suit = use_card:getSuitString()
		local number = use_card:getNumber()
		local card_id = use_card:getEffectiveId()
		local card_str = string.format("jink:yongmeng[%s:%d]=%d&yongmeng",suit, number, card_id)
		local jink = sgs.Card_Parse(card_str)
		assert(jink)
		return jink
	end
end
sgs.ai_view_as.yongmeng = function(card, player, card_place)
	local can_use = false
	if player:getMark("@qspade") > 0 and card:getSuit() == sgs.Card_Spade then
		can_use = true
	end
	if player:getMark("@qheart") > 0 and card:getSuit() == sgs.Card_Heart then
		can_use = true
	end
	if player:getMark("@qclub") > 0 and card:getSuit() == sgs.Card_Club then
		can_use = true
	end
	if player:getMark("@qdiamond") > 0 and card:getSuit() == sgs.Card_Diamond then
		can_use = true
	end
	local suit = card:getSuitString()
	local number = card:getNumber()
	local card_id = card:getEffectiveId()
	if player:getMark("phaseMark") == 2 and can_use then
		return string.format("jink:yongmeng[%s:%d]=%d&yongmeng",suit, number, card_id)
	end
end
local mouce_skill={}
mouce_skill.name="mouce"
table.insert(sgs.ai_skills,mouce_skill)
mouce_skill.getTurnUseCard=function(self)
	local cards = self.player:getCards("h")
	cards=sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local use_card
	for _,card in ipairs(cards)  do
		if card:hasFlag("mouceFlag") then
			use_card = card
			break
		end
	end
	if not use_card then return nil end
	local suit = use_card:getSuitString()
	local number = use_card:getNumber()
	local card_id = use_card:getEffectiveId()
	if use_card:getSuit() == sgs.Card_Spade then
		local card_str = string.format("duel:mouce[%s:%d]=%d&mouce",suit, number, card_id)
		local duel = sgs.Card_Parse(card_str)
		assert(duel)
		return duel
	elseif use_card:getSuit() == sgs.Card_Heart then
		local card_str = string.format("peach:mouce[%s:%d]=%d&mouce",suit, number, card_id)
		local peach = sgs.Card_Parse(card_str)
		assert(peach)
		return peach
	end
end
sgs.ai_view_as.mouce = function(card, player, card_place)
	if card:hasFlag("mouceFlag") then
		local suit = card:getSuitString()
		local number = card:getNumber()
		local card_id = card:getEffectiveId()
		if card:getSuit() == sgs.Card_Club then
			return string.format("nullification:mouce[%s:%d]=%d&mouce",suit, number, card_id)
		elseif card:getSuit() == sgs.Card_Heart then
			return string.format("peach:mouce[%s:%d]=%d&mouce",suit, number, card_id)
		elseif card:getSuit() == sgs.Card_Diamond then
			return string.format("jink:mouce[%s:%d]=%d&mouce",suit, number, card_id)
		end
	end
end