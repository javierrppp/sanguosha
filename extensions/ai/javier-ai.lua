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

--**********智包**********-----

-----曹操·君-----

local isLiangjiang = function(player) --判断该武将是不是五良将
	if player:getRole() == "careerist" then return false end
	local is = false
	if player:getGeneralName() == "yujin" or player:getGeneralName() == "yuejin" or player:getGeneralName() == "xuhuang" or player:getGeneralName() == "zhangliao" or player:getGeneralName() == "zhanghe"  then
		is = true
	end
	if not is and player:getGeneralName() ~= "guojia" and player:getGeneralName() ~= "xunyu" and player:getGeneralName() ~= "chengyu" and player:getGeneralName() ~= "jiaxu" and player:getGeneralName() ~= "xunyou" then
		if player:getGeneral2Name() == "yujin" or player:getGeneral2Name() == "yuejin" or player:getGeneral2Name() == "xuhuang" or player:getGeneral2Name() == "zhangliao" or player:getGeneral2Name() == "zhanghe"  then
			is = true
		end
	end
	return is
end
local isMouchen = function(player) --判断该武将是不是五谋臣
	if player:getRole() == "careerist" then return false end
	local is = false
	if player:getGeneralName() == "guojia" or player:getGeneralName() == "xunyu" or player:getGeneralName() == "chengyu" or player:getGeneralName() == "jiaxu" or player:getGeneralName() == "xunyou"  then
		is = true
	end
	if not is and player:getGeneralName() ~= "yujin" and player:getGeneralName() ~= "yuejin" and player:getGeneralName() ~= "xuhuang" and player:getGeneralName() ~= "zhangliao" and player:getGeneralName() ~= "zhanghe" then
		if player:getGeneral2Name() == "guojia" or player:getGeneral2Name() == "xunyu" or player:getGeneral2Name() == "chengyu" or player:getGeneral2Name() == "jiaxu" or player:getGeneral2Name() == "xunyou"  then
			is = true
		end
	end
	return is
end
sgs.ai_skill_playerchosen.mouduan = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	local candidate
	local data = source:property("mouduanSelectProp")
	local damage = data:toDamage()
	if self:isEnemy(damage.from) then
		if damage.from:getEquip(1) and damage.from:getEquip(1):isKindOf("Vine") then   --利用火杀
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getRole() ~= "careerist" and p:getKingdom() == "wei" and isLiangjiang(p) then
					if p:getEquip(0) and p:getEquip(0):isKindOf("Fan") then
						candidate = p
						break
					end
				end
			end
		end
		if source:getRole() ~= "careerist" and damage.from:getHp() == 1 and not damage.from:hasShownSkill("buqu") and (not damage.from:getEquip(1) or (damage.from:getEquip(1) and not damage.from:getEquip(1):isKindOf("Vine"))) then
			local shu = 0 local wei = 0 local wu = 0 local qun = 0     --利用飞龙夺凤收拾残血角色
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getKingdom() == "shu" and p:getRole() ~= "careerist" then shu = shu + 1
				elseif p:getKingdom() == "wei" and p:getRole() ~= "careerist" then wei = wei + 1
				elseif p:getKingdom() == "wu" and p:getRole() ~= "careerist" then wu = wu + 1
				elseif p:getKingdom() == "qun" and p:getRole() ~= "careerist" then qun = qun + 1
				end
			end
			if wei < shu and wei < wu and wei < qun then
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getRole() ~= "careerist" and p:getKingdom() == "wei" and isLiangjiang(p) then
						if p:getEquip(0) and p:getEquip(0):isKindOf("DragonPhoenix") then
							return p
						end
					end
				end
			end
		end
	end
	local max_cardNum = 0
	local friend_candidate
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:getRole() ~= "careerist" and p:getKingdom() == "wei" and isMouchen(p) and room:getCurrent():objectName() ~= p:objectName() then
			if p:getHandcardNum() > max_cardNum then
				friend_candidate = p
				max_cardNum = p:getHandcardNum()
			end
		end
	end
	if max_cardNum <= 3 and candidate then return candidate
	elseif friend_candidate then return friend_candidate
	end
	return nil
end
local xietian_skill = {}
xietian_skill.name = "xietian"
table.insert(sgs.ai_skills, xietian_skill)
xietian_skill.getTurnUseCard = function(self, inclusive)
	local cards = {}
	cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards, true)
	local need_card
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Heart and card:getNumber() == 2 then 
			need_card = card
		end
	end
	if need_card then
		local suit = need_card:getSuitString()
		local number = need_card:getNumberString()
		local card_id = need_card:getEffectiveId()
		local card_str = ("threaten_emperor:xietian[%s:%s]=%d%s"):format(suit, number, card_id, "&xietian")
		local threaten_emperor = sgs.Card_Parse(card_str)
		assert(threaten_emperor)
		return threaten_emperor
	end
end
function sgs.ai_cardneed.xietian(to, card)
	return card:getSuit() == sgs.Card_Heart and card:getNumber() == 2
end

-----刘表-----

sgs.ai_skill_invoke.gushou = function(self, data)
    return true
end

-----马谡-----

sgs.ai_skill_invoke.sanyao = function(self, data)
	local source = self.player
	local room = source:getRoom()
	if self:isEnemy(room:getCurrent()) and room:getCurrent():hasShownSkill("buqu") and room:getCurrent():getHp() == 0 then
		return false
	end
    return true
end
sgs.ai_skill_choice["sanyao"] = function(self, choices, data)
    local source = self.player
    local room = source:getRoom()
	if self:isFriend(room:getCurrent()) then
		return "sanyao_benefit"
	else
		return "sanyao_not_benefit"
	end
end

-----祢衡-----

sgs.ai_skill_invoke.kuangcai = function(self, data)
	if self.player:getHandcardNum() - self.player:getHp() > 3 then return false end
    return true
end
sgs.ai_use_value.shejianCard = 17
sgs.ai_use_priority.shejianCard = 16.62
local shejian_skill = {}
shejian_skill.name = "shejian"
table.insert(sgs.ai_skills, shejian_skill)
shejian_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	if self.player:isKongcheng() then return nil end
	if not self.player:hasUsed("#shejianCard") then
		return sgs.Card_Parse("#shejianCard:.:&shejian")
	end
end
sgs.ai_skill_use_func["#shejianCard"] = function(card, use, self)
	local big_kingdoms = self.player:getBigKingdoms("AI")
	local big_kingdom_count = 0
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if not p:hasShownOneGeneral() then continue end
		if table.contains(big_kingdoms, p:objectName()) or (table.contains(big_kingdoms, p:getKingdom()) and (p:getRole() ~= "careerist")) then
			big_kingdom_count = big_kingdom_count + 1
		end
	end
	local usenum = self.player:getTag("kuangcaiCardUsedNum"):toInt()
	if usenum < big_kingdom_count and self.player:getHandcardNum() < self.player:getHp() then
		return false
	end
	local targets = sgs.SPlayerList()
	for _, p in pairs(self.enemies) do
		if not p:isKongcheng() then
			targets:append(p)
		end
		if targets:length() >= big_kingdom_count then
			break
		end
	end
	if targets:length() > 0 then
		use.card = card
		if use.to then use.to = targets end
	end
end

-----何进-----

sgs.ai_skill_invoke.mouzhu = function(self, data)
	local death = data:toDeath()
	local kindom = death.who:getKingdom()
	local friend_num = 0	
	if death.who:getRole() == "careerist" or self.player:getRole() == "careerist" then
		return true
	end
	if death.who:getKingdom() == self.player:getKingdom() then return true end
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:getKingdom() == kindom and p:objectName() ~= self.player:objectName() then
			friend_num = friend_num + 1
		end
	end
	if friend_num > 3 then return true end
    return false
end
sgs.ai_skill_playerchosen.yanhuo = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	for _, p in pairs(self.friends) do
		if p:hasShownSkill("lirang") then
			return p 
		end 
	end
	local maxcard = 0
	local target
	for _, p in pairs(self.friends) do
		if (p:getHandcardNum() + p:getEquips():length()) > maxcard then
			maxcard = p:getHandcardNum() + p:getEquips():length()
			target = p
		end
	end
	if target then
		return target
	else
		return source
	end
end
sgs.ai_skill_cardask["@shejian"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		return card:toString()
	end
end

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

sgs.ai_skill_playerchosen["jueqing"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	room:getThread():delay(750)
	local damage = source:getTag("jueqingTag"):toDamage()
	local to = damage.to
	local target = nil
	if (to:getHp() <= damage.damage and (self:getCardsNum("Peach") > 0 or to:getRole() == "careerist")) or to:getHp() > damage.damage then 
		if to:hasShownSkill("ganglie") then
			for _, p in sgs.qlist(targets) do
				if self:isEnemy(p) then
					if target then
						if target:getHp() > p:getHp() then
							target = p
						end
					else
						target = p
					end
				end
			end
		end
	end
	if target then return target end
	if not to:isWounded() then
		if self:isEnemy(to) then
			for _, p in sgs.qlist(targets) do
				if p:hasShownSkill("tusha") then
					return p
				end
			end
		end
	end
	if to:hasShownSkill("fuli") and self:isEnemy(to) then
		local big_kingdoms = source:getBigKingdoms("jueqing")
		if table.contains(big_kingdoms,source:getKingdom()) then 
			for _, p in sgs.qlist(targets) do
				if not table.contains(big_kingdoms,p:getKingdom()) then 
					return p 
				end
			end
		end
	end
	if to:hasShownSkill("duanchang")  then
		for _, p in sgs.qlist(targets) do
			if self:isEnemy(p) then
				return p
			end
		end
	end
	if to:hasShownSkill("fankui")  then
		for _, p in sgs.qlist(targets) do
			if self:isEnemy(p) and not p:isNude() then
				return p
			end
		end
	end
	if damage.to:getHp() <= damage.damage then
		if self:isFriend(to) then
			if source:getEquips():length() >= 2 then
				for _, p in sgs.qlist(targets) do
					if self:isFriend(p) then
						if target then
							if target:getCards("he"):length() > p:getCards("he"):length() then
								target = p
							end
						else
							target = p
						end
					end
				end
			end
		else
			for _, p in sgs.qlist(targets) do
				if p:getKingdom() == to:getKingdom() and p:getRole() ~= "careerist" and to:getRole() ~= "careerist" then
					if target then
						if target:getCards("he"):length() < p:getCards("he"):length() then
							target = p
						end
					else
						target = p
					end
				end
			end
			if not target then
				for _, p in sgs.qlist(targets) do
					if self:isFriend(p) and self:isWeak(p) then
						target = p 
						break
					end
				end
			end
		end
	end
	if to:hasShownSkill("mingshi") and self:isEnemy(to) then
		if target then
			if not target:hasShownAllGenerals() then
				for _, p in sgs.qlist(targets) do
					if p:hasShownAllGenerals() then
						target = p
					end
				end
			end
		else
			if not source:hasShownAllGenerals() then
				for _, p in sgs.qlist(targets) do
					if p:hasShownAllGenerals() then
						target = p
					end
				end
			end
		end
	end
	if target then return target end
	return "."
end
sgs.ai_skill_invoke.shangshi = function(self, data)
    return true
end

-----牛金-----

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
		if target:getEquip(1) and target:getEquip(1):isKindOf("SilverLion") and target:isWounded() then return true end
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
	elseif target_friend then
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if p:objectName() ~= target_friend:objectName() and p:getHandcardNum() > target_friend:getHandcardNum() then
				if not self:isFriend(p) or not p:hasShownOneGeneral() then
					hide_general = p
					break
				end
			end
		end
		if target_friend and hide_general then
			targets:append(target_friend)
			targets:append(hide_general)
		end
	else
		for _, p in sgs.qlist(room:getOtherPlayers(self.player))do
			if targets:length() == 0 then targets:append(p) end
			for _, q in sgs.qlist(room:getOtherPlayers(self.player)) do
				if q:objectName() ~= targets:first():objectName() then
					if targets:first():getHandcardNum() > q:getHandcardNum() then
						if not self:isFriend(targets:first()) then
							targets:append(q)
							break
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
		if not self:isWeak(source) then
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
	for _, p in pairs(self.friends_noself) do
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
	if #self.enemies == 1 and targets:length() == 0 then
		if not self.enemies[1]:isKongcheng() then
			targets:append(self.enemies[1])
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
		if p:hasShownSkill("tiandu") or p:hasShownSkill("tiandu_xizhicai") then
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

sgs.ai_use_value.mizhaoCard = 5
sgs.ai_use_priority.mizhaoCard = 5
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
	if use.card and use.card:isBlack() and source:getEquip(1) and source:getEquip(1):isKindOf("RenwangShield") then return false end
	if self:getCardsNum("Jink") > 0 then return false end
	if use.card and use.card:isKindOf("FireSlash") and source:getEquip(1) and source:getEquip(1):isKindOf("Vine") then return true end
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
		return "dingpan_damage"
	end
	return "dingpan_discard"
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

-----李儒-----

sgs.ai_skill_playerchosen.juece = function(self, targetlist)
	if not self:willShowForAttack() then return end
	local targets = sgs.QList2Table(targetlist)
	self:sort(targets)
	local friends, enemies = {}, {}
	for _, target in ipairs(targets) do
		if self:cantbeHurt(target, self.player) or not self:damageIsEffective(target, nil, self.player) then continue end
		if self:isEnemy(target) then table.insert(enemies, target)
		elseif self:isFriend(target) then table.insert(friends, target) end
	end
	for _, enemy in ipairs(enemies) do
		if not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player) then return enemy end
	end
	for _, friend in ipairs(friends) do
		if self:getDamagedEffects(friend, self.player) and self:needToLoseHp(friend, self.player) then return friend end
	end
	return nil
end
sgs.ai_playerchosen_intention.juece = function(self, from, to)
	if self:damageIsEffective(to, nil, from) and not self:getDamagedEffects(friend, self.player) and not self:needToLoseHp(friend, self.player) then
		sgs.updateIntention(from, to, 10)
	end
end
local mieji_skill = {}
mieji_skill.name = "mieji"
table.insert(sgs.ai_skills, mieji_skill)
mieji_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	for _, enemy in ipairs(self.enemies) do				--为绝策加入的防止给牌
		if enemy:isKongcheng() then enemy:setFlags("preventgivecard") end
	end
	if self.player:hasUsed("#miejiCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#miejiCard:.:&mieji")
end
sgs.ai_skill_use_func["#miejiCard"] = function(card, use, self)
	local nextAlive = self.player:getNextAlive()
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") and not nextAlive:hasSkill("qianxi") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	local big_kingdoms = self.player:getBigKingdoms("AI")
	local kindom = nextAlive:getKingdom()
	local fobitThreatenEmperor = false
	for _, k in ipairs(big_kingdoms) do		--检查下家是否大势力
		if k:match(kindom) and self:isEnemy(nextAlive) and not (hasLightning or hasIndulgence or hasSupplyShortage or nextAlive:hasSkill("qianxi")) then fobitThreatenEmperor = true end
	end
	
	local putcard, TEcard
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isBlack() and card:isKindOf("TrickCard") then
			if hasLightning and card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				if self:isEnemy(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if hasSupplyShortage and card:getSuit() == sgs.Card_Club then
				if self:isFriend(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if not putcard then
				if not card:isKindOf("ThreatenEmperor") or not fobitThreatenEmperor then  --防止把挟天子给大势力敌人
					putcard = card break
				end
			end
		end
	end

	local target
	for _, enemy in ipairs(self.enemies) do
		--if self:needKongcheng(enemy) and enemy:getHandcardNum() <= 2 then continue end
		--if self:doNotDiscard(enemy, "he", true, 2, true) then continue end
		if not enemy:isNude()  then
			target = enemy break
		end
	end
	if not target then
		for _, friend in ipairs(self.friends_noself) do
			if self:needKongcheng(friend) and friend:getHandcardNum() < 2 and not friend:isKongcheng() then
				target = friend break
			end
		end
	end
	if putcard and target then
		use.card = sgs.Card_Parse("#miejiCard:"..putcard:getEffectiveId() .. ":&mieji")
		if use.to then use.to:append(target) end
		return
	end
end
sgs.ai_use_priority.miejiCard = sgs.ai_use_priority.Dismantlement + 1
sgs.dynamic_value.control_card.miejiCard = true
sgs.ai_card_intention["#miejiCard"] = function(self, card, from, tos)
	for _, to in ipairs(tos) do
		if self:needKongcheng(to) and to:getHandcardNum() <= 2 then continue end
		sgs.updateIntention(from, to, 10)
	end
end
sgs.ai_skill_cardask["@@miejiDiscard!"] = function(self, prompt)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local trick = {}
	local nontrick = {}
	local discard = {}
	for _,card in ipairs(cards) do
		if self.player:isJilei(card) then continue end  --源码忘加了。。
		if card:isKindOf("TrickCard") then
			table.insert(trick, card)
		else
			table.insert(nontrick, card)
		end
	end
	if #cards <= 2 then return "." end
	if self:needToThrowArmor() and #nontrick >= 2 then
		table.insert(discard, self.player:getArmor())
		if nontrick[1] ~= discard[1] then
			table.insert(discard, nontrick[1])
		else
			table.insert(discard, nontrick[2])
		end
	end
	if self.player:hasSkills(sgs.lose_equip_skill) and self.player:getEquips():length() > 0 and #nontrick >= 2 then
		local ecards = sgs.QList2Table(self.player:getEquips())
		self:sortByKeepValue(ecards)
		table.insert(discard, ecards[1])
		if nontrick[1] ~= discard[1] then
			table.insert(discard, nontrick[1])
		else
			table.insert(discard, nontrick[2])
		end
	end
	if #trick == 0 then
		for _,card in ipairs(nontrick) do
			table.insert(discard, card)
			if #discard == 2 or #discard == #nontrick then
				break
			end
		end
	end
	if #nontrick == 0 and #trick >= 1 then
		table.insert(discard, trick[1])
	end
	if #discard > 0 then
		return "$"..table.concat(discard:getEffectiveId(), "+")
	end
return "."
end
sgs.ai_cardneed.mieji = function(to, card, self)
	return card:isBlack() and (card:getTypeId() == sgs.Card_TypeTrick)
end
sgs.ai_suit_priority.mieji = "diamond|heart|club|spade"
local fencheng_skill = {}
fencheng_skill.name = "fencheng"
table.insert(sgs.ai_skills, fencheng_skill)
fencheng_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:getMark("@burn") == 0 then return false end
	return sgs.Card_Parse("#fenchengCard:.:&fencheng")
end
sgs.ai_skill_use_func["#fenchengCard"] = function(card, use, self)
	local value = 0
	if self.player:hasShownSkill("baoling") then value = value + 3 end
	local neutral = 0
	local damage = { from = self.player, damage = 2, nature = sgs.DamageStruct_Fire }
	local lastPlayer = self.player
	for i, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		damage.to = p
		if self:damageIsEffective_(damage) then
			--if sgs.evaluatePlayerRole(p, self.player) == "neutral" then neutral = neutral + 1 end
			if not self:isFriend(p) and not self:isEnemy(p) then neutral = neutral + 1 end
			local v = 4
			if (self:getDamagedEffects(p, self.player) or self:needToLoseHp(p, self.player)) and getCardsNum("Peach", p, self.player) + p:getHp() > 2 then
				v = v - 6
			elseif lastPlayer:objectName() ~= self.player:objectName() and lastPlayer:getCardCount(true) < p:getCardCount(true) then
				v = v - 4
			elseif lastPlayer:objectName() == self.player:objectName() and not p:isNude() then
				v = v - 4
			end
			if self:isFriend(p) then
				value = value - v - p:getHp() + 2
			elseif self:isEnemy(p) then
				value = value + v + p:getLostHp() - 1
			end
			if p:isLord() and p:getHp() <= 2
				and (self:isEnemy(p, lastPlayer) and p:getCardCount(true) <= lastPlayer:getCardCount(true)
					or lastPlayer:objectName() == self.player:objectName() and (not p:canDiscard(p, "he") or p:isNude())) then
				if not self:isEnemy(p) then
					if self:getCardsNum("Peach") + getCardsNum("Peach", p, self.player) + p:getHp() <= 2 then return end
				else
					use.card = card
					return
				end
			end
		end
	end

	if neutral > self.player:aliveCount() / 2 then return end
	if value > 0 then
		use.card = card
	end
end
sgs.ai_use_priority.fenchengCard = 9.1
sgs.ai_skill_discard.fencheng = function(self, discard_num, min_num, optional, include_equip)  --原项目
	local cards = {}
	local thenext = self.player:getNextAlive()
	local thenextnext = thenext:getNextAlive()
	local selfnum = self.player:getCardCount(true)
	local nextnum = thenext:getCardCount(true)
	local hecards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(hecards)
	local chainedprevent		--被铁索则千万要避免
	if self.player:isChained() then
		for _, p in ipairs(self.friends_noself) do
			if self:isFriendWith(p) and not self:isGoodChainTarget(self.player, p, sgs.DamageStruct_Fire, 2) then
				chainedprevent = true
				break
			end
		end
	end
	if chainedprevent and self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then
		for i = 1, min_num do
			table.insert(cards, hecards[i]:getEffectiveId())
		end
		return cards
	end
	if thenext:hasFlag("fenchengUsing") then
		for i = 1, min_num do
			table.insert(cards, hecards[i]:getEffectiveId())
		end
		return cards
	end
	if self:isWeak() and self.player:hasArmorEffect("Breastplate") then		--危险但是有护心境就不弃牌
		return {}
	end
	if self:isFriend(thenext) and not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}	end	--下家是朋友，且自身不受伤
	if self:isFriendWith(thenext) then								--下家是同势力
		if nextnum >= min_num + 1 or not self:damageIsEffective(thenext, sgs.DamageStruct_Fire) then	--下家够弃牌，自己弃最小量
			for i = 1, min_num do
				table.insert(cards, hecards[i]:getEffectiveId())
			end
			return cards
		end
		if self:isWeak(thenext) and nextnum ~= 0 and not self:isWeak() then		--下家会没命，自己替下家挡
			return {}
		end
	end
	if self:isEnemy(thenext) then													--下家是敌人的场合
		if (not self:damageIsEffective(thenext, sgs.DamageStruct_Fire)) or (thenext:hasArmorEffect("SilverLion") and thenext:getHp() >= 2) then			--如果敌人不会受伤
			if not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}
			else
				for i = 1, min_num do												--自己弃最小量
					table.insert(cards, hecards[i]:getEffectiveId())
				end
				return cards
			end
		else
			if self:isFriendWith(thenextnext) or thenextnext:hasFlag("fenchengUsing") then	--如果下家的下家是同势力，或者下家是最后一名响应者
				if selfnum >= nextnum and nextnum >= min_num + 1 then				--手牌够先坑掉下家
					for i = 1, nextnum do
						table.insert(cards, hecards[i]:getEffectiveId())
					end
					return cards
				end
				if not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}	--如果自己不受伤，都放过
				else
					for i = 1, min_num do											--自己会受伤就弃最小量
						table.insert(cards, hecards[i]:getEffectiveId())
					end
					return cards
				end
			end
		end
	end
	for i = 1, min_num,1 do
		table.insert(cards, hecards[i]:getEffectiveId())
	end
	return cards
end

-----虞翻-----

local function getBackToId(self, cards)
	local cards_id = {}
	for _, card in ipairs(cards) do
		table.insert(cards_id, card:getEffectiveId())
	end
	return cards_id
end
sgs.ai_skill_invoke.zongxuan = function(self, data)  --试着完全搬运观星，结果搬运到一半弃疗了，因为实在太复杂而且看不懂有木有啊！！！！！:( 所以现在乱七八糟
	--if not self:willShowForDefence() then return false end
	if self.top_draw_pile_id then return false end
	--if self.player:getPhase() >= sgs.Player_Finish then return false end  --todo：处理回合外的情况
	
	local list = self.player:property("zongxuanToGet"):toString():split("+")
	--local bottom = getIdToCard(self, cards)
	local bottom = {}
	for _, card_id_str in ipairs(list) do
		local card = sgs.Sanguosha:getCard(tonumber(card_id_str))
		table.insert(bottom, card)
	end
	self:sortByUseValue(bottom, true)  --这是按自己的useValue排，而我还不会按别人的。。
	local up = {}
	
	local canzhiyan = (self.player:hasSkills("zhiyan") and (self.player:getPhase() >= sgs.Player_Play) and (self.player:getPhase() <= sgs.Player_Discard) and not self.player:isSkipped(sgs.Player_Finish))
	local current = global_room:getCurrent()
	if not current then
		current = global_room:getAlivePlayers():first()
	end
	local next_player  --来自观星（目前无法处理放权连破挟天子等情况）
	if current:getPhase() ~= sgs.Player_NotActive then
		for _, p in sgs.qlist(global_room:getOtherPlayers(current)) do
			if p:faceUp() then next_player = p break end
		end
		next_player = next_player or current:faceUp() and current or current:getNextAlive()
	else
		if current:faceUp() then 
			next_player = current
		else
			for _, p in sgs.qlist(global_room:getOtherPlayers(current)) do
				if p:faceUp() then next_player = p break end
			end
			next_player = next_player or current:faceUp() and current or current:getNextAlive()
		end
	end
	
	--乱七八糟的一段，写出来自己都不知道啥意思或者干啥用。。。弃疗了
	local current_will_judge = ((current:getPhase() < sgs.Player_Judge) and not current:getJudgingArea():isEmpty() and not current:hasShownSkills("qiaobian|shensu") and not current:isSkipped(sgs.Player_Judge)) 
								or (current:getPhase() == sgs.Player_NotActive)
	if current_will_judge and (current:getPhase() < sgs.Player_Start) then
		current_will_judge = current_will_judge and not next_player:hasShownSkills("luoshen|guanxing|yizhi|qianxi|yinghun_sunjian|yinghun_sunce")
								and not (next_player:hasShownSkills("shenzhi") and next_player:isWounded())
	end
	local current_will_draw = ((current:getPhase() < sgs.Player_Draw) and not current_will_judge and not current:hasShownSkills("tuxi|qiaobian|xunxun") and not current:isSkipped(sgs.Player_Draw))
								or (current:getPhase() == sgs.Player_NotActive)
	local next_will_judge = next_player and (not next_player:hasShownSkills("qiaobian|shensu") and not current_will_judge and not current_will_draw)
								and not current:hasShownSkills("Jujian|Miji|Jingce|shengxi")
								and not next_player:hasShownSkills("luoshen|guanxing|yizhi|qianxi|yinghun_sunjian|yinghun_sunce")
								and not (next_player:hasShownSkills("shenzhi") and next_player:isWounded())
	local next_judging_player = current_will_judge and current or (next_will_judge and next_player or nil)
	
	if next_judging_player then
		local judge = sgs.QList2Table(next_judging_player:getJudgingArea())
		judge = sgs.reverse(judge)
	else
		local judge = {}
	end
	
	local has_lightning, self_has_judged
	local judged_list = {}
	local willSkipDrawPhase, willSkipPlayPhase
	local is_friend_judging = next_judging_player and self:isFriend(next_judging_player) or false
	if judge and next(judge) then
		local lightning_index
		for judge_count, need_judge in ipairs(judge) do
			judged_list[judge_count] = 0
			if need_judge:isKindOf("Lightning") then
				lightning_index = judge_count
				has_lightning = need_judge
				continue
			elseif need_judge:isKindOf("Indulgence") then
				willSkipPlayPhase = true
				if next_judging_player:isSkipped(sgs.Player_Play) then continue end
			elseif need_judge:isKindOf("SupplyShortage") then
				willSkipDrawPhase = true
				if next_judging_player:isSkipped(sgs.Player_Draw) then continue end
			end
			local judge_str = sgs.ai_judgestring[need_judge:objectName()]
			if not judge_str then
				self.room:writeToConsole(debug.traceback())
				judge_str = sgs.ai_judgestring[need_judge:getSuitString()]
			end
			for index, for_judge in ipairs(bottom) do
				local suit = for_judge:getSuitString()
				if next_judging_player:hasShownSkill("hongyan") and suit == "spade" then suit = "heart" end
				if (is_friend_judging and (judge_str == suit)) or (not is_friend_judging and (judge_str ~= suit)) then
					table.insert(up, for_judge)
					table.remove(bottom, index)
					judged_list[judge_count] = 1
					self_has_judged = true
					if need_judge:isKindOf("SupplyShortage") then willSkipDrawPhase = false
					elseif need_judge:isKindOf("Indulgence") then willSkipPlayPhase = false
					end
					break
				end
			end
		end

		if lightning_index then
			for index, for_judge in ipairs(bottom) do
				local cardNumber = for_judge:getNumber()
				local cardSuit = for_judge:getSuitString()
				if self.player:hasSkill("hongyan") and cardSuit == "spade" then cardSuit = "heart" end
				if (is_friend_judging and not (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade")) or (not is_friend_judging and (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade")) then
					local i = lightning_index > #up and 1 or lightning_index
					table.insert(up, i , for_judge)
					table.remove(bottom, index)
					judged_list[lightning_index] = 1
					self_has_judged = true
					break
				end
			end
			if judged_list[lightning_index] == 0 then
				if #up >= lightning_index then
					for i = 1, #up - lightning_index + 1 do
						table.insert(bottom, table.remove(up))
					end
				end
				up = getBackToId(self, up)
				bottom = getBackToId(self, bottom)
				self.player:setTag("AI_zongxuanDrawPileCards", sgs.QVariant(table.concat(up, "+")))
				if canzhiyan then self.player:setFlags("AI_DoNotInvokezhiyan") end
				return true
			end
		end

		if not self_has_judged and #judge > 0 then
			--return {}, cards
			if canzhiyan then self.player:setFlags("AI_DoNotInvokezhiyan") end
			return false
		end

		--完全不懂
		--[[local index
		if willSkipDrawPhase then
			for i = #judged_list, 1, -1 do
				if judged_list[i] == 0 then index = i
				else break
				end
			end
		end]]

		for i = 1, #judged_list do
			if judged_list[i] == 0 then
				--[[if i == index then
					up = getBackToId(self, up)
					bottom = getBackToId(self, bottom)
					return up, bottom
				end]]
				table.insert(up, i, table.remove(bottom, 1))
			end
		end

	end
	
	--本来想在这里继续插入观星的内容，最后放弃了
	
	if (#up == 0) and not self:willShowForDefence() then return false end
	local willzhiyan = false
	local zhiyan_card
	if canzhiyan and not self.player:hasFlag("AI_DoNotInvokezhiyan") then  --最后处理
		local valuable
		for _, card in ipairs(bottom) do
			if card:isKindOf("EquipCard") then
				for _, friend in ipairs(self.friends) do
					if not (card:isKindOf("Armor") and not friend:getArmor() and friend:hasShownSkills(sgs.viewhas_armor_skill))
						and (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse")
							or (card:isKindOf("Weapon") and self:evaluateWeapon(card) > self:evaluateWeapon(friend:getWeapon()) - 1) or friend:hasShownSkills(sgs.lose_equip_skill)) then
						--self.top_draw_pile_id = card_id
						--self.player:setTag("AI_zongxuanDrawPileCards", sgs.QVariant(tostring(card_id)))
						zhiyan_card = card
						willzhiyan = true
						--return true
						--return "@zongxuanCard=" .. card_id
					end
				end
			elseif self:isValuableCard(card) and not valuable then
				valuable = card
				willzhiyan = true
			end
		end
		if valuable and not zhiyan_card then
			zhiyan_card = valuable
			willzhiyan = true
		end
	end
	local result = {}
	if willzhiyan then
		--[[self.top_draw_pile_id = valuable
		self.player:setTag("AI_zongxuanDrawPileCards", sgs.QVariant(tostring(valuable)))
		return true]]
		table.insert(result, zhiyan_card:getId())
	elseif canzhiyan and (next(up) ~= nil) and not self.player:hasFlag("AI_DoNotInvokezhiyan") then
		self.player:setFlags("AI_DoNotInvokezhiyan")
	end
	for _,card in ipairs(up) do
		table.insert(result, card:getId())
	end
	if #result > 0 then
		self.top_draw_pile_id = result[1]
		self.player:setTag("AI_zongxuanDrawPileCards", sgs.QVariant(table.concat(result, "+")))
		return true
	end
	return false
end
sgs.ai_skill_movecards.zongxuan = function(self, upcards, downcards, min_num, max_num)  --todo：借鉴灭计/涯角/【攻心】（应该简单点）
	local zongxuan_cards = self.player:getTag("AI_zongxuanDrawPileCards"):toString():split(":")
	self.player:removeTag("AI_zongxuanDrawPileCards")
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	for _,id_str in ipairs(zongxuan_cards) do
		table.insert(down, tonumber(id_str))
		table.removeAll(upcards_copy, tonumber(id_str))
	end
	return upcards_copy, down
end
sgs.ai_skill_playerchosen.zhiyan = function(self, targets)
	if self.player:hasFlag("AI_DoNotInvokezhiyan") then
		self.player:setFlags("-AI_DoNotInvokezhiyan")
		return nil
	end
	if self.top_draw_pile_id then
		local card = sgs.Sanguosha:getCard(self.top_draw_pile_id)
		if card:isKindOf("EquipCard") then
			self:sort(self.friends, "hp")
			for _, friend in ipairs(self.friends) do
				if (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse") or friend:hasShownSkills(sgs.lose_equip_skill) or (card:isKindOf("Armor") and self:needToThrowArmor(friend)))
					and not (card:isKindOf("Armor") and (friend:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, friend) < 0) and not self:needToThrowArmor(friend)) then  --evaluateArmor和needToThrowArmor这里可能有点问题
					return friend
				end
			end
			if not (card:isKindOf("Armor") and (self.player:hasSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card) < 0))
				and not (card:isKindOf("Weapon") and self.player:getWeapon() and self:evaluateWeapon(card) < self:evaluateWeapon(self.player:getWeapon()) - 1) then
				return self.player
			end
			--找了一圈都没找到，只能替换装备了
			for _, friend in ipairs(self.friends) do
				if self:isWeak(friend) or (friend:isWounded() and (card:isKindOf("Weapon") and self:evaluateWeapon(card) > self:evaluateWeapon(friend:getWeapon()) - 1))
					and not (card:isKindOf("Armor") and (friend:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, friend) < 0) and not self:needToThrowArmor(friend))
					and not (card:isKindOf("Treasure") and friend:getTreasure() and friend:getPile("wooden_ox"):length() > 1) then
					return friend
				end
			end
			if self.player:isWounded() and not (card:isKindOf("Armor") and (self.player:hasSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card) < 0)) then
				return self.player
			end
			--坑一波敌人
			for _, enemy in ipairs(self.enemy) do
				if (card:isKindOf("Armor") and (enemy:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, enemy) < 0) and not self:needToThrowArmor(enemy))
					or (card:isKindOf("Treasure") and enemy:getTreasure() and enemy:getPile("wooden_ox"):length() > 2) then
					return enemy
				end
			end
		else
			local cards = { card }
			local card, player = self:getCardNeedPlayer(cards)
			if player then
				return player
			else
				self:sort(self.friends)
				for _, friend in ipairs(self.friends) do
					if not self:needKongcheng(friend, true) --[[and not hasManjuanEffect(friend)]] then return friend end
				end
			end
		end
	else
		if not self:willShowForDefence() then return nil end
		self:sort(self.friends)
		for _, friend in ipairs(self.friends) do
			if not self:needKongcheng(friend, true) --[[and not hasManjuanEffect(friend)]] then return friend end
		end
	end
	return nil
end
--sgs.ai_playerchosen_intention.zhiyan = -60
sgs.ai_playerchosen_intention.zhiyan = function(self, from, to)
	if self.top_draw_pile_id then
		local card = sgs.Sanguosha:getCard(self.top_draw_pile_id)
	end
	if not card then
		sgs.updateIntention(from, to, -60)
	elseif not (card:isKindOf("Armor") and (to:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, to) < 0) and not self:needToThrowArmor(to))
		and not (card:isKindOf("Treasure") and to:getTreasure() and to:getPile("wooden_ox"):length() > 2) then
		sgs.updateIntention(from, to, -60)
	end
end

-----戏志才-----

sgs.ai_skill_invoke.tiandu_xizhicai = function(self, data)
	local judge = data:toJudge()
	if judge.reason == "tuntian" and judge.card:getSuit() ~= sgs.Card_Heart then
		return false
	end
    return true
end
sgs.ai_skill_invoke.chouce = function(self, data)
    return true
end
sgs.ai_skill_playerchosen.xianfu = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(room:getOtherPlayers(player)) do
		if p:hasShownSkill("qingnan") or p:hasShownSkill("jieyin") then
			return p
		end
	end
	for _, p in sgs.qlist(room:getOtherPlayers(player)) do
		if p:hasShownSkill("ziyuan") or p:hasShownSkill("shenzhi") then
			return p
		end
	end
	self:sort(self.enemies, "hp",false)
	for _, p in pairs(self.friends_noself) do
		return p
	end
	return targets:first()
end
sgs.ai_skill_playerchosen.tiandu_xizhicai = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	if self:isWeak(source) then return nil end
	self:sort(self.friends_noself, "defense")
	for _, p in pairs(self.friends_noself) do
		return p
	end
end
sgs.ai_skill_playerchosen.chouce = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends_noself, "defense")
	if source:property("chouceProp"):toString() == "red" then
		if self:isWeak(source) and source:getHandcardNum() <= 3 then return source end
		if room:getCurrent():objectName() == source:objectName() and source:getHandcardNum() <= source:getHp() then return source end
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if self:isFriend(p) and p:getMark("@fu") > 0 then
				if (self.friends_noself[1]:getHp() < p:getHp() - 1 and self.friends_noself[1]:getCards("he"):length() < p:getCards("he"):length()-2) then
					return self.friends_noself[1]
				else
					return p 
				end
			end
		end
		for _, p in ipairs(self.friends) do
			if self:isWeak(p) then
				return p 
			end
		end
		return source
	else
		for _, p in pairs(self.friends) do
			local tricks = p:getJudgingArea()
			if not tricks:isEmpty() then
				for _, c in sgs.qlist(tricks) do
					if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then
						return p
					elseif c:isKindOf("Lightning") then
						if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
							return p
						end
					end
				end
			end
		end
		self:sort(self.enemies, "defense",false)
		for _, p in pairs(self.enemies) do
			if not p:isAllNude() then
				return p 
			end
		end
	end
	return nil
end

-----君·孙权-----

sgs.ai_skill_invoke.shouguan = function(self, data)
    return true
end
sgs.ai_skill_invoke.zaoli = function(self, data)
    return true
end
sgs.ai_skill_playerchosen.shouguan = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(targets) do
		if p:hasShownSkill("xietian") then
			return p 
		end
	end
	return targets:first()
end
local shenduan_skill = {}
shenduan_skill.name = "shenduan"
table.insert(sgs.ai_skills, shenduan_skill)
shenduan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#shenduanCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#shenduanCard:.:&shenduan")
end
sgs.ai_skill_use_func["#shenduanCard"] = function(card, use, self)
	local nextAlive = self.player:getNextAlive()
	local hasLightning, hasIndulgence, hasSupplyShortage =false,false ,false
	local tricks = nextAlive:getJudgingArea()
	local num = tricks:length()
	if self.player:getMark("shenduanMark") >= num then
		for i = num - 1 , 0 , -1 do
			local trick = tricks:at(i)
			if self:hasTrickEffective(trick, nextAlive) then
				if trick:isKindOf("Lightning") then hasLightning = true 
				elseif trick:isKindOf("Indulgence") then hasIndulgence = true 
				elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true 
				end
			end
		end
	else
		for i = num - 1 , num - self.player:getMark("shenduanMark") , -1 do
			local trick = tricks:at(i)
			if self:hasTrickEffective(trick, nextAlive) then
				if trick:isKindOf("Lightning") then hasLightning = true 
				elseif trick:isKindOf("Indulgence") then hasIndulgence = true 
				elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true 
				end
			end
		end
	end
	local putcard ={}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	if self:isFriend(nextAlive) then
		for _, card in ipairs(cards) do
			if hasLightning and card:getSuit() == sgs.Card_Spade and card:getNumber() < 2 and card:getNumber() > 9 then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasLightning = false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
			if hasIndulgence and card:getSuit() == sgs.Card_Heart then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasIndulgence =false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
			if hasSupplyShortage and card:getSuit() == sgs.Card_Club then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasSupplyShortage = false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
		end
	elseif self:isEnemy(nextAlive) then
		for _, card in ipairs(cards) do
			if hasLightning and card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasLightning = false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
			if hasIndulgence and card:getSuit() ~= sgs.Card_Heart then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasIndulgence =false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
			if hasSupplyShortage and card:getSuit() ~= sgs.Card_Club then
				if not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					hasSupplyShortage = false
				end
			end
			if #putcard >= self.player:getMark("shenduanMark") then break end
		end
	end
	if #putcard < self.player:getMark("shenduanMark") then
		if self.player:hasSkill("xiaoji") then
			for _, card in sgs.qlist(self.player:getCards("e")) do
				if card:isKindOf("EquipCard") and table.contains(cards,card) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
					break
				end
			end
		end
		if #putcard < self.player:getMark("shenduanMark") then
			for _, card in ipairs(cards) do
				if self:isEnemy(nextAlive) and self:getUseValue(card) < 5 or self:getKeepValue(card) < 6 and not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
				elseif self:isFriend(nextAlive) and self:getUseValue(card) < 7 or self:getKeepValue(card) < 8 and not table.contains(putcard,card:getEffectiveId()) then
					table.insert(putcard,card:getEffectiveId())
					table.removeAll(cards,card)
				end
				if #putcard >= self.player:getMark("shenduanMark") then break end
			end
		end
	end
	if #putcard > 0 then
		use.card = sgs.Card_Parse("#shenduanCard:" .. table.concat(putcard, "+") .. ":&shenduan")
	end
end
sgs.ai_skill_movecards.shenduan = function(self, upcards, downcards, min_num, max_num)  --todo：借鉴灭计/涯角/【攻心】（应该简单点）
	--local Variant = self.player:getTag("AI_shenduanDrawPileCards"):toList()
	--self.player:removeTag("AI_shenduanDrawPileCards")
	local shenduan_cards = sgs.IntList()
	for _, c in pairs(upcards) do
		shenduan_cards:append(c)
	end
	local down = {}
	for q = 1 , #upcards, 1 do
		down[q] = -1 
	end
	local nextAlive = self.player:getNextAlive()
	local tricks = nextAlive:getJudgingArea()
	local num = tricks:length()
	local lightning_index = -1
	local indulgence_index = -1
	local supplyShortage_index = -1
	if num > 0 then
		if shenduan_cards:length() >= num then
			for i = num - 1  , 0 , -1 do
				local trick = tricks:at(i)
				if trick:isKindOf("Lightning") then
					lightning_index = num - i 
				elseif trick:isKindOf("Indulgence") then
					indulgence_index = num - i 
				elseif trick:isKindOf("SupplyShortage") then
					supplyShortage_index = num - i
				end
			end
		else
			for i = num - 1  , num - shenduan_cards:length() , -1 do
				local trick = tricks:at(i)
				if trick:isKindOf("Lightning") then
					lightning_index = num - i 
				elseif trick:isKindOf("Indulgence") then
					indulgence_index = num - i 
				elseif trick:isKindOf("SupplyShortage") then
					supplyShortage_index = num - i
				end
			end
		end
		if self:isFriend(nextAlive) then
			local lightning_not_effect = {}
			if lightning_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Spade or (sgs.Sanguosha:getCard(id_str):getNumber() < 2 and sgs.Sanguosha:getCard(id_str):getNumber() > 9) then
						table.insert(lightning_not_effect, tonumber(id_str))
					end
				end
			end
			if indulgence_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if lightning_index ~= -1 and table.contains(lightning_not_effect,tonumber(id_str)) and #lightning_not_effect == 1 then continue end
					if (sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Heart) or (nextAlive:hasShownSkill("hongyan") and sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Spade) then
						down[indulgence_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
			end
			if supplyShortage_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if lightning_index ~= -1 and table.contains(lightning_not_effect,tonumber(id_str)) and #lightning_not_effect == 1 then continue end
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Club then
						down[supplyShortage_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
			end
			if lightning_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Spade or (sgs.Sanguosha:getCard(id_str):getNumber() < 2 and sgs.Sanguosha:getCard(id_str):getNumber() > 9) then
						down[lightning_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
			end
			if indulgence_index ~= -1 and down[indulgence_index] == -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					down[indulgence_index] = tonumber(id_str)
					shenduan_cards:removeOne(id_str)
					break
				end
			end
			if supplyShortage_index ~= -1 and down[supplyShortage_index] == -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					down[supplyShortage_index] = tonumber(id_str)
					shenduan_cards:removeOne(id_str)
					break
				end
			end
		elseif self:isEnemy(nextAlive) then
			if lightning_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Spade and sgs.Sanguosha:getCard(id_str):getNumber() >= 2 and sgs.Sanguosha:getCard(id_str):getNumber() <= 9 then
						down[lightning_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
			end
			if indulgence_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Club then 
						down[indulgence_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
				if down[indulgence_index] == -1 then
					for _,id_str in sgs.qlist(shenduan_cards) do
						if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Heart  then
							down[indulgence_index] = tonumber(id_str)
							shenduan_cards:removeOne(id_str)
							break
						end
					end
				end
			end
			if supplyShortage_index ~= -1 then
				for _,id_str in sgs.qlist(shenduan_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Heart then 
						down[supplyShortage_index] = tonumber(id_str)
						shenduan_cards:removeOne(id_str)
						break
					end
				end
				if down[supplyShortage_index] == -1 then
					for _,id_str in sgs.qlist(shenduan_cards) do
						if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Club  then
							down[supplyShortage_index] = tonumber(id_str)
							shenduan_cards:removeOne(id_str)
							break
						end
					end
				end
			end
		end
	end
	if shenduan_cards:length() > 0 then
		for j = 1 , #upcards, 1 do
			if down[j] == -1 then
				down[j] = tonumber(shenduan_cards:first())
				shenduan_cards:removeOne(shenduan_cards:first())
			end
		end
	end
	return {}, down
end

-----李严-----

sgs.ai_skill_invoke.fulin = function(self, data)
    return true
end
sgs.ai_skill_invoke.duliang = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(500)
    local use = data:toCardUse()
	if self:isEnemy(use.from) then return true end
	if use.card:isKindOf("SupplyShortage") then
		return true
	elseif use.card:isKindOf("Dismantlement") then
		for _, c in sgs.qlist(use.to:first():getJudgingArea()) do
			if c:isKindOf("Indulgence") or c:isKindOf("SupplyShortage") then
				return false
			elseif c:isKindOf("Lightning") then
				if self:hasWizard(self.enemies) or #self.friends > room:getAlivePlayers():length() - #self.friends then
					return false
				else
					return true
				end
			end
		end
	end
	return true
end

-----诸葛瑾-----

sgs.ai_skill_invoke.hongyuan = function(self, data)
    local room = self.player:getRoom()
	if #self.enemies > 3 and not self:isWeak(self.player) then return true end
	local num = 0
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:hasShownOneGeneral() and p:getKingdom() == self.player:getKingdom() and p:getRole() ~= "careerist" then
			num = num + 1
		end
	end
	if num > 2 and not self:isWeak(self.player) then return true end
	if num > 3 then return true end
    return false
end
sgs.ai_skill_choice["hongyuan"] = function(self, choices, data)
    local source = self.player
    local room = source:getRoom()
	if source:getRole() == "careerist" then return "enemy_discard" end
	local num = 1
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:hasShownOneGeneral() and p:getKingdom() == source:getKingdom() and p:getRole() ~= "careerist" then
			num = num + 1
		end
	end
	if num > 2 and not self:isWeak(self.player) then return "friend_draw" end
	if num > 3 then return "friend_draw" end
	if #self.enemies > 3 then return "enemy_discard" end
	if num == 2 then return "friend_draw" end
	return "enemy_discard"
end

-----钟会-----

sgs.ai_skill_invoke.zili = function(self, data)
    return true
end
sgs.ai_skill_invoke.quanxiang = function(self, data)
	local room = self.player:getRoom()
	local damage = data:toDamage()
	if self.player:getMark("quanxiangMark") == 0 then
		if self:isEnemy(damage.to) then
			if damage.to:getGeneral2Name() == "huaxiong" or damage.to:getGeneral2Name() == "niujin" then
				return false
			end
		end
		if room:getAlivePlayers():length() == 2 then return true end
		if self:isEnemy(damage.to) then
			if damage.to:getGeneral2Name() == "liubei" or damage.to:getGeneral2Name() == "kongrong" then
				return false
			else
				return true
			end
		end
	else
		if self:isEnemy(damage.to) then return true end
	end
    return false
end
sgs.ai_skill_cardask["@quanxiang"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local damage = data:toDamage()
	if damage.from:getMark("quanxiangMark") == 0 then
		if self.player:getGeneral2Name() == "huaxiong" or self.player:getGeneral2Name() == "niujin" then return "." end
		if #self.friends_noself == 0 and self.player:getHp() == 1 then return "." end
	else
		if self.player:getHp() >= 4 and damage.damage == 1 then return "." end
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if card:isKindOf("EquipCard") then
			return card:toString()
		end
	end
	return "."
end
sgs.ai_skill_invoke.zili = function(self, data)
    return true
end
sgs.ai_skill_invoke.quanji = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(500)
    return true
end
sgs.ai_skill_exchange.quanji = function(self, pattern, max_num, min_num, expand_pile)
	local room = self.player:getRoom()
	room:getThread():delay(500)
	local to_discard = {}
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	table.insert(to_discard, cards[1]:getEffectiveId())
	return to_discard
end
local paiyi_skill = {}
paiyi_skill.name = "paiyi"
table.insert(sgs.ai_skills, paiyi_skill)
paiyi_skill.getTurnUseCard = function(self)
	if not (self.player:getPile("power"):isEmpty()
		or self.player:hasUsed("#paiyiCard")) then
		return sgs.Card_Parse("#paiyiCard:.:&paiyi")
	end
	return nil
end
sgs.ai_skill_use_func["#paiyiCard"] = function(card, use, self)
	local target
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if friend:getHandcardNum() < 2 and friend:getHandcardNum() + 1 < self.player:getHandcardNum()
		  and not self:needKongcheng(friend, true) and not friend:hasSkill("manjuan") then
			target = friend
		end
		if target then break end
	end
	if not target then
		if self.player:getHandcardNum() < self.player:getHp() + self.player:getPile("power"):length() - 1 then
			target = self.player
		end
	end
	self:sort(self.friends_noself, "hp")
	self.friends_noself = sgs.reverse(self.friends_noself)
	if not target then
		for _, friend in ipairs(self.friends_noself) do
			if friend:getHandcardNum() + 2 > self.player:getHandcardNum()
			  and (self:getDamagedEffects(friend, self.player) or self:needToLoseHp(friend, self.player, nil, true))
			  and not friend:hasSkill("manjuan") then
				target = friend
			end
			if target then break end
		end
	end
	self:sort(self.enemies, "defense")
	if not target then
		for _, enemy in ipairs(self.enemies) do
			if enemy:hasSkill("manjuan")
				and not (self:hasSkills(sgs.masochism_skill, enemy) and not self.player:hasSkill("jueqing"))
				and self:damageIsEffective(enemy, sgs.DamageStruct_Normal, self.player)
				and not (self:getDamagedEffects(enemy, self.player) or self:needToLoseHp(enemy))
				and enemy:getHandcardNum() > self.player:getHandcardNum() then
				target = enemy
			end
			if target then break end
		end
		if not target then
			for _, enemy in ipairs(self.enemies) do
				if not (self:hasSkills(sgs.masochism_skill, enemy) and not self.player:hasSkill("jueqing"))
					and not enemy:hasSkills(sgs.cardneed_skill .. "|jijiu|tianxiang|buyi")
					and self:damageIsEffective(enemy, sgs.DamageStruct_Normal, self.player) and not self:cantbeHurt(enemy)
					and not (self:getDamagedEffects(enemy, self.player) or self:needToLoseHp(enemy))
					and enemy:getHandcardNum() + 2 > self.player:getHandcardNum()
					and not enemy:hasSkill("manjuan") then
					target = enemy
				end
				if target then break end
			end
		end
	end
	local card_need ={}
	table.insert(card_need,self.player:getPile("power"):at(math.random(0,self.player:getPile("power"):length() - 1)))
	
	if target then
		use.card = sgs.Card_Parse("#paiyiCard:" .. table.concat(card_need, "+") .. ":&paiyi")
		if use.to then
			use.to:append(target)
		end
	end
end

-----祖茂-----

sgs.ai_skill_playerchosen["yinbing"] = function(self, targets) 
    local source = self.player
	local num = source:getMaxHp() - source:getHp()
	local room = source:getRoom()
	local to = {}
	for _, p in sgs.qlist(targets) do
		if #to >= num then break end
		if self:isFriend(p) and p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") then
			table.insert(to,p)
		end
		if #to >= num then break end
		if self:isEnemy(p) then
			table.insert(to,p)
		end
	end
	return to
end

-----程昱-----

sgs.ai_skill_invoke.benyu = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(500)
    return true
end
sgs.ai_skill_discard["benyu"] = function(self, discard_num, min_num, optional, include_equip)
	local source = self.player
	local room = source:getRoom()
	room:getThread():delay(1000)
	local damage = source:property("benyuProp"):toDamage()
	if min_num > 3 and source:getHandcardNum() - min_num < 3 and damage.to:getHp() > 1 then return {} end
	if self:isFriend(damage.from) then
		return {}
	end
	local no_usefulNum = 0
	for _, c in sgs.qlist(source:getHandcards()) do
		if not c:isKindOf("Peach") and not c:isKindOf("Analeptic") and not c:isKindOf("ExNihilo") then
			no_usefulNum = no_usefulNum + 1
		end
	end
	if no_usefulNum < min_num then return {} end
	local cardList = {}
	local cards = sgs.QList2Table(source:getCards("h"))
	self:sortByUseValue(cards)
	for _, c in pairs(cards) do
		if not c:isKindOf("Peach") and not c:isKindOf("Analeptic") and not c:isKindOf("ExNihilo") then
		table.insert(cardList,c:getId())
		if #cardList >= min_num then break end
		end
	end
	if #cardList == min_num then
		return cardList
	end
	return {}
end
local shefu_skill = {}
shefu_skill.name = "shefu"
table.insert(sgs.ai_skills, shefu_skill)
shefu_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	local num = self.player:getMaxHp() - self.player:getHp()
	if num == 0 then num = 1 end
	if self.player:usedTimes("#shefuCard") >= num or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#shefuCard:.:&shefu")
end
sgs.ai_skill_use_func["#shefuCard"] = function(card, use, self)
	local source = self.player
	local room = source:getRoom()
	local putcard,target
	local cards = {}
	for _, c in sgs.qlist(source:getHandcards()) do
		if not table.contains(source:property("shefuProp"):toString():split("+"),c:objectName()) and not c:isKindOf("EquipCard") then
			table.insert(cards,c)
		end
	end
	self:sortByUseValue(cards, true)
	local daqiao,ganning,xuhuang,guanyu,zhenji,wolong,fengchu,shuangtou,yuanshao,luxun,yuxi = nil,nil,nil,nil,nil,nil,nil,nil,nil,nil,nil
	for _, p in sgs.qlist(room:getOtherPlayers(source)) do
		if p:hasShownSkill("guose") and self:isEnemy(p) then daqiao = p end
		if p:hasShownSkill("xietian") and self:isEnemy(p) then ganning = p end
		if p:hasShownSkill("duanliang") and self:isEnemy(p) then xuhuang = p end
		if p:hasShownSkill("qingguo") and self:isEnemy(p) then zhenji = p end
		if p:hasShownSkill("wusheng") and self:isEnemy(p) then guanyu = p end
		if (p:hasShownSkill("huoji") or p:hasShownSkill("kanpo")) and self:isEnemy(p) then wolong = p end
		if p:hasShownSkill("lianhuan") and self:isEnemy(p) then fengchu = p end
		if p:hasShownSkill("shuangxiong") and self:isEnemy(p) then shuangtou = p end
		if p:hasShownSkill("luanji") and self:isEnemy(p) then yuanshao = p end
		if p:hasShownSkill("duoshi") and self:isEnemy(p) then luxun = p end
		if p:getEquip(4) and p:getEquip(4):isKindOf("JadeSeal") and self:isEnemy(p) then yuxi = p end
	end
	for _, card in ipairs(cards) do
		if card:isKindOf("Indulgence") and daqiao then
			putcard = card
			target = daqiao
		elseif card:isKindOf("Dismantlement") and ganning then
			putcard = card
			target = ganning
		elseif card:isKindOf("SupplyShortage") and xuhuang then
			putcard = card
			target = xuhuang
		elseif card:isKindOf("Jink") and zhenji then
			putcard = card
			target = zhenji
		elseif card:isKindOf("Slash") and guanyu then
			putcard = card
			target = guanyu
		elseif (card:isKindOf("FireAttack") or card:isKindOf("Nullification")) and wolong then
			putcard = card
			target = wolong
		elseif card:isKindOf("IronChain") and fengchu then
			putcard = card
			target = fengchu
		elseif card:isKindOf("Duel") and shuangtou then
			putcard = card
			target = shuangtou
		elseif card:isKindOf("ArcheryAttack") and yuanshao then
			putcard = card
			target = yuanshao
		elseif card:isKindOf("AwaitExhausted") and luxun then
			putcard = card
			target = luxun
		elseif card:isKindOf("KnownBoth") and yuxi then
			putcard = card
			target = yuxi
		end
		if putcard and target then break end
	end
	if not putcard or not target then
		for _, enemy in ipairs(self.enemies) do
			if enemy:getHp() == 1 then
				for _, card in ipairs(cards) do
					if card:isKindOf("Peach") then
						target = enemy
						putcard = card
						break
					end
				end
			end
			if enemy:getHandcardNum() > 2 then
				for _, card in ipairs(cards) do
					if card:isKindOf("Slash") then
						target = enemy
						putcard = card
						break
					elseif card:isKindOf("Jink") and self:getCardsNum("Jink") > 1 then
						target = enemy
						putcard = card
						break
					end
				end
			end
		end
	end
	if not putcard or not target then
		if source:getHandcardNum() > source:getHp() then
			for _, enemy in ipairs(self.enemies) do
				for _, card in ipairs(cards) do
					if enemy:getPile("fu"):length() == 0 then
						target = enemy
						putcard = card
						break
					end
				end
			end
		end
	end
	if not putcard or not target then
		if source:getHandcardNum() > source:getHp() then
			for _, enemy in ipairs(self.enemies) do
				for _, card in ipairs(cards) do
					target = enemy
					putcard = card
					break
				end
			end
		end
	end
	if putcard and target then
		use.card = sgs.Card_Parse("#shefuCard:"..putcard:getEffectiveId() .. ":&shefu")
		if use.to then use.to:append(target) end
		return
	end
end

-----蔡瑁-----

sgs.ai_skill_invoke.duozhu = function(self, data)
	local room = self.player:getRoom()
	room:getThread():delay(500)
    return true
end
sgs.ai_skill_invoke.shuishi = function(self, data)
	local damage = data:toDamage()
	if self:isEnemy(damage.to) then
		return true
	end
    return false
end
sgs.ai_skill_cardask["@shuishi"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if not card:isKindOf("Peach") then
			return card:toString()
		end
	end
	return "."
end

-----周仓-----

sgs.ai_skill_use["@@zhongyong"] = function(self, prompt)
	local target = nil
	local ids = sgs.IntList()
	local source = self.player
	local zhongyonCards = source:property("zhongyongCards"):toString():split("|")
	for _,cardids in ipairs(zhongyonCards) do
		for _,id in ipairs(cardids:split("+")) do
			ids:append(tonumber(id))
		end
	end
	local canxie = nil
	for _, p in pairs(self.enemies) do
		if p:getHp() == 1 and source:inMyAttackRange(p) then
			if canxie == nil then
				canxie = p
			else
				if p:getHandcardNum() < canxie:getHandcardNum() then
					canxie = p 
				end
			end
		end
	end
	local card_need = nil
	local card_peach = nil
	if canxie then
		for _, c in sgs.qlist(ids) do
			local card = sgs.Sanguosha:getCard(c)
			if card:isRed() then
				if card_need == nil then
					card_need = card:getEffectiveId()
				else
					if card:isKindOf("Slash") then
						card_need = card:getEffectiveId()
					end
				end
				if card:isKindOf("Peach") then
					card_peach = card:getEffectiveId()
				end
			end
		end
		if card_need then
			for _, p in pairs(self.friends_noself) do
				if p:hasShownSkill("wusheng") and p:hasFlag("zhongyongAvailable") then
					target = p 
					card_need = card_peach
				end
			end
			if not target then
				for _, p in pairs(self.friends_noself) do
					if p:hasShownSkill("longdan") and p:hasFlag("zhongyongAvailable") then
						target = p 
						card_need = card_peach
					end
				end
			end
			if not target then
				for _, p in pairs(self.friends_noself) do
					if p:getHandcardNum() > 3 and p:hasFlag("zhongyongAvailable") then
						target = p 
						card_need = card_peach
					end
				end
			end
			if not target then
				for _, p in pairs(self.friends_noself) do
					if p:getHandcardNum() > 2 and p:hasFlag("zhongyongAvailable") then
						target = p 
						card_need = card_peach
					end
				end
			end
			if not target then
				for _, p in pairs(self.friends_noself) do
					if p:hasFlag("zhongyongAvailable") then
						target = p 
					end
				end
			end
		end
	end
	if not target then
		local maxusevalue = nil
		for _, c in sgs.qlist(ids) do
			local card = sgs.Sanguosha:getCard(c)
			if maxusevalue == nil then
				maxusevalue = card
			else
				if self:getUseValue(card) > self:getUseValue(maxusevalue) then
					maxusevalue = card
				end
			end
		end
		if maxusevalue then card_need = maxusevalue:getEffectiveId() end
		local minhp = 999
		local minhp_player = nil
		for _, p in pairs(self.friends_noself) do
			if p:getHp() < minhp and p:hasFlag("zhongyongAvailable") then
				minhp = p:getHp()
				minhp_player = p 
			elseif p:getHp() == minhp and p:hasFlag("zhongyongAvailable") then
				if minhp_player:getHandcardNum() > p:getHandcardNum() then
					minhp_player = p 
				end
			end
		end
		if minhp_player then target = minhp_player end
	end
	if target and card_need then
	    local card_str = "#zhongyongCard:"..card_need..":&zhongyong->" .. target:objectName()
		return card_str	
	end
	return "."
end

--**********加强包**********-----

-----单骑-----

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

-----励战-----

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

-----诈降-----

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

-----狂骨-----

sgs.ai_skill_invoke.Ekuanggu = function(self, data)
    return true
end
sgs.ai_skill_choice["Ekuanggu"] = function(self, choices, data)
	if self:isWeak(self.player) or self.player:getHandcardNum() > self.player:getHp() then
		return "recover"
	end
end

-----奸雄-----

sgs.ai_skill_invoke.Ejianxiong = function(self, data)
    return true
end
sgs.ai_skill_choice["Ejianxiong"] = function(self, choices, data)
	local damage = data:toDamage()
	if not damage.card then return "draw1" end
	if damage.card and damage.card:isKindOf("Slash") and self:getCardsNum("Slash") > 0 then
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

--**********加强包**********-----

-----赵子龙-----
sgs.ai_skill_invoke.yajiao = function(self, data)
    return true
end
sgs.ai_skill_cardask["@chongzhen1"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local use = data:toSlashEffect()
	local num = use.slash:getNumber()
	local invoke = true
	if use.to:getHandcardNum() == 0 and (not use.to:getEquip(1) or (use.to:getEquip(1) and (not use.to:getEquip(1):isKindOf("EightDiagram") or (use.to:getEquip(1):isKindOf("EightDiagram") and self.player:getEquip(0) and self.player:getEquip(0):isKindOf("QinggangSword"))))) then
		invoke = false
	end
	if getCardsNum("Jink", use.to, self.player) == 0 and (not use.to:getEquip(1) or (use.to:getEquip(1) and not use.to:getEquip(1):isKindOf("EightDiagram"))) then invoke = false end
	if use.to:getHandcardNum() == 1 and use.to:getHp() > 2 then
		if use.drank == 0 then
			invoke = false
		end
	end
	if invoke == false then return nil end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if card:isKindOf("Slash") and card:getNumber() > num then
			return card:toString()
		end
	end
	for _,card in pairs(cards) do
		if card:isKindOf("BasicCard") and card:getNumber() > num then
			return card:toString()
		end
	end
end
sgs.ai_skill_cardask["@chongzhen2"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local use = data:toCardUse()
	if not use.slash then return nil end
	local num = use.slash:getNumber()
	local invoke = false
	local jink_need = 1
	if use.from:hasShownSkill("wushuang") then jink_need = 2 end
	if use.from:getMark("drank") > 0 then invoke = true end
	if self.player:getEquip(1) and self.player:getEquip(1):isKindOf("EightDiagram") and self:getCardsNum("Jink") >= jink_need then invoke = false end
	if use.from:getEquip(0) and use.from:getEquip(0):isKindOf("Axe") and use.from:getCards("he"):length() > 2 then invoke = true end
	if invoke == false then return nil end
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if card:isKindOf("Slash") and card:getNumber() > num then
			return card:toString()
		end
	end
	for _,card in pairs(cards) do
		if card:isKindOf("BasicCard") and card:getNumber() > num then
			return card:toString()
		end
	end
end

-----陆伯言-----

sgs.ai_skill_invoke.linggong = function(self, data)
    return true
end
sgs.ai_skill_invoke.shaoying = function(self, data)
    local room = self.player:getRoom()
	local damage = data:toDamage()
	if self:isEnemy(damage.to:getNextAlive(1)) then
		return true
	end
	return false
end
sgs.ai_skill_playerchosen["shaoying"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	local to = {}
	local candidate
	for _, p in sgs.qlist(targets) do
		if not p:isKongcheng() then
			if self:isEnemy(p) and p:getEquip(1) and p:getEquip(1):isKindOf("Vine") then
				if candidate then
					if candidate:getHp() > p:getHp() then
						candidate = p
					end
				else
					candidate = p
				end
			end
		end
	end
	if not candidate then
		for _, p in sgs.qlist(targets) do
			if not p:isKongcheng() then
				if self:isEnemy(p) and (self:isEnemy(p:getNextAlive(1)) and not p:getNextAlive(1):isKongcheng()) and (self:isEnemy(p:getNextAlive(2)) and not p:getNextAlive(2):isKongcheng()) then
					candidate = p 
					break
				end
			end
		end
	end
	if not candidate then
		for _, p in sgs.qlist(targets) do
			if not p:isKongcheng() then
				if self:isEnemy(p) and (self:isEnemy(p:getNextAlive(1)) and not p:getNextAlive(1):isKongcheng()) then
					candidate = p 
					break
				end
			end
		end
	end
	if not candidate then
		for _, p in sgs.qlist(targets) do
			if not p:isKongcheng() then
				if self:isEnemy(p) then
					candidate = p 
					break
				end
			end
		end
	end
	table.insert(to,candidate)
	return to
end

-----古之恶来-----

sgs.ai_use_value.tiequCard = 17
sgs.ai_use_priority.tiequCard = 16.62
local tiequ_skill = {}
tiequ_skill.name = "tiequ"
table.insert(sgs.ai_skills, tiequ_skill)
tiequ_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	if self.player:getHp() == 0 then return nil end
	if not self.player:hasUsed("#tiequCard") then
		return sgs.Card_Parse("#tiequCard:.:&tiequ")
	end
end
sgs.ai_skill_use_func["#tiequCard"] = function(card, use, self)
	local source = self.player
	if source:getHp() == 1 then return false end
	if source:getHp() == 2 and source:getEquip(1) then
		local need_help = false
		if source:hasSkill("fangzhu") then
			for _, p in pairs(self.friends) do
				if not p:faceUp() then
					need_help = true
				end
			end
		end
		if not need_help then return false end
	end
	if source:getHp() == 3 and source:getEquip(0) and source:getEquip(1) then
		if not source:hasSkill("fangzhu") and not source:hasSkill("yiji") and not source:hasSkill("jieming") then
			return false
		end
	end
	if source:getEquip(0) and source:getEquip(1) and source:getEquip(2) and source:getEquip(3) and source:getEquip(4) then return false end
	use.card = card
end

-----董仲颖-----
sgs.ai_use_value.huangyinCard = 17
sgs.ai_use_priority.huangyinCard = 16.62
local huangyin_skill = {}
huangyin_skill.name = "huangyin"
table.insert(sgs.ai_skills, huangyin_skill)
huangyin_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	if self.player:getHp() == 0 then return nil end
	if not self.player:hasUsed("#huangyinCard") then
		return sgs.Card_Parse("#huangyinCard:.:&huangyin")
	end
end
sgs.ai_skill_use_func["#huangyinCard"] = function(card, use, self)
	local source = self.player
	local room = self.room
	local to 
	if self.player:hasSkill("juece") and not self:isWeak() then
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if p:isFemale() and self:isEnemy(p) then
				if not to then
					to = p 
				else
					if not p:isKongcheng() and  p:getHandcardNum() < to:getHandcardNum() then
						to = p 
					end
				end
			end
		end
		if not to then
			for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
				if p:isFemale() and self:isEnemy(p) then
					if not to then
						to = p 
					else
						if p:getHandcardNum() > to:getHandcardNum() then
							to = p 
						end
					end
				end
			end
		end
	else
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if p:isFemale() and self:isEnemy(p) then
				if not to then
					to = p 
				else
					if p:getHandcardNum() > to:getHandcardNum() then
						to = p 
					end
				end
			end
		end
	end
	local targets = sgs.SPlayerList()
	if to then
		targets:append(to)
	end
	if targets:length() == 1 then
		use.card = card
		if use.to then use.to = targets end
	end
end

--[[sgs.ai_use_value.huangyinCard = 10
sgs.ai_use_priority.huangyinCard = 10
huangyin_skill = {}
huangyin_skill.name = "huangyin"
table.insert(sgs.ai_skills, huangyin_skill)
huangyin_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#huangyinCard") then
		return sgs.Card_Parse("#huangyinCard:.:&huangyin")
	end
end
sgs.ai_skill_use_func["#huangyinCard"] = function(card, use, self)
	local source = self.player
	local room = source:getRoom()
	local to 
	if self.player:hasSkill("juece") and not self:isWeak() then
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if self.isEnemy(p) then
				if not to then
					to = p 
				else
					if p:getHandcardNum() < to:getHandcardNum() then
						to = p 
					end
				end
			end
		end
	else
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do
			if self.isEnemy(p) then
				if not to then
					to = p 
				else
					if p:getHandcardNum() > to:getHandcardNum() then
						to = p 
					end
				end
			end
		end
	end
	local targets = sgs.SPlayerList()
	if to then
		targets:append(to)
	end
	if targets:length() == 1 then
		use.card = card
		if use.to then use.to = targets end
	end
end]]--
sgs.ai_skill_playerchosen["weishe"] = function(self, targets) 
    local source = self.player
	local to
	for _, p in sgs.qlist(targets) do
		if self:isEnemy(p) and (not p:getEquip(1) or (p:getEquip(1) and (not p:getEquip(1):isKindOf("SilverLion") or (p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") and not p:isWounded())))) then
			if not to then
				to = p
			else
				if p:getHandcardNum() < to:getHandcardNum() then
					to = p 
				end
			end
		end
	end
	if to then
		return to
	else
		for _, p in sgs.qlist(targets) do
		if self:isFriend(p) and p:isWounded() and p:getEquip(1) and p:getEquip(1):isKindOf("SilverLion") then
			return p
		end
	end
	end
	return nil
end
