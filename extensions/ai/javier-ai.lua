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

sgs.ai_skill_invoke.zhenhan = function(self, data)
    return true
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

sgs.ai_skill_cardask["@fuli"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if card:isRed() then
			return card:toString()
		end
	end
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
	room:getThread():delay(450)
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

sgs.ai_skill_exchange.shaluTuifeng = function(self, pattern, max_num, min_num, expand_pile)
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
sgs.ai_need_damaged.shaluTuifeng = function(self, attacker, player)
	if not player:hasSkill("shaluTuifeng") then return false end
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
function sgs.ai_cardneed.shaluTuifeng(to, card)
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
sgs.ai_skill_invoke.huanshi = function(self, data)
    return true
end
sgs.ai_skill_use["@@huanshi"] = function(self, prompt)
	self:updatePlayers()
	local data = self.player:property("huanshiDataProp")
	local ids = self.player:property("huanshiProp"):toString():split("+")
	local judge = data:toJudge()
	if judge:isGood() then return "." end
	
	for _, id in pairs(ids) do
		local card = sgs.Sanguosha:getCard(id)
		--[[if self:isEnemy(judge.who) and judge.good() then
			if not judge.isGood(card) then
				----
			end
		end]]-- --与自己势力相同，不会是敌人
		if judge:isGood(card) then
			local card_str = "#huanshiCard:".. id ..":&huanshi"
			return card_str
		end
	end
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
		if p:hasShownSkill("Eduoshi") and self:isEnemy(p) then luxun = p end
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

sgs.ai_skill_invoke.shaluKuanggu = function(self, data)
    return true
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
	self:log("ddd")
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
	if not use.card then return "." end
	local num = use.card:getNumber()
	local invoke = false
	local jink_need = 1
	if use.from:hasShownSkill("wushuang") then jink_need = 2 end
	if use.from:getMark("drank") > 0 then invoke = true end
	if self.player:getEquip(1) and self.player:getEquip(1):isKindOf("EightDiagram") and self:getCardsNum("Jink") >= jink_need then invoke = false end
	if self.player:hasSkill("longdan") and self.player:hasSkill("longhun") and self:getCardsNum("Jink") + self:getCardsNum("Slash") >= 1 then invoke = false end
	if use.from:getEquip(0) and use.from:getEquip(0):isKindOf("Axe") and use.from:getCards("he"):length() > 2 then invoke = true end
	if invoke == false then return "." end
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

-----薛综-----

sgs.ai_skill_invoke["funan"] = function(self, data)
	local to
	local objectName = self.player:property("funanToProp"):toString()
	for _, p in sgs.qlist(self.room:getAlivePlayers()) do 
		if p:objectName() == objectName then
			to = p 
			break
		end
	end
	local card_id = self.player:property("funanCardProp"):toInt()
	local card = sgs.Sanguosha:getCard(card_id)
	if self:isFriend(to) then
		return true
	else
		if self:getCardsNum("Jink") < self.player:getMaxCards() and self:isWeak(self.player) and card:isKindOf("Jink") then
			return true
		end
	end
	if self.player:getMark("funanMark") > 0 then return true end
	return false
end
sgs.ai_skill_playerchosen["jiexun"] = function(self, targets) 
	local source = self.player
	local room = self.room
	local num = source:getMark("@xun")
	local diamonds_num = 0
	local to_friend = false
	local to_enemy = false
	local discard_num = num - diamonds_num
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		for _, c in sgs.qlist(p:getJudgingArea()) do
			if c:getSuit() == sgs.Card_Diamond then
				diamonds_num = diamonds_num + 1
			end
		end
		for _, c in sgs.qlist(p:getEquips()) do
			if c:getSuit() == sgs.Card_Diamond then
				diamonds_num = diamonds_num + 1
			end
		end
	end
	if diamonds_num >= num then
		to_friend = true
	elseif diamonds_num < num and diamonds_num < 2 then
		to_enemy = true
	elseif diamonds_num < num and diamonds_num >= 2 and num - diamonds_num < 2 then
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if self:isFriend(p) and p:isWounded() then
				for _, c in sgs.qlist(p:getEquips()) do
					if c:isKindOf("SilverLion") then
						return p
					end
				end
			end
		end
	end
	if num / diamonds_num >= 2 then
		to_enemy = true
	end
	local to 
	if to_enemy then
		for _, p in sgs.qlist(targets) do
			if self:isEnemy(p) then
				if p:getHandcardNum() + p:getEquips():length() > discard_num then
					if to and to:getHandcardNum() + to:getEquips():length() > p:getHandcardNum() + p:getEquips():length() then
						to = p
					elseif not to then
						to = p
					end
				end
			end
		end
	elseif to_friend then
		for _, p in sgs.qlist(targets) do
			if self:isFriend(p) then
				if p:getHandcardNum() + p:getEquips():length() > discard_num then
					if to and to:getHandcardNum() + to:getEquips():length() > p:getHandcardNum() + p:getEquips():length() then
						to = p
					elseif not to then
						to = p
					end
				end
				if p:hasShownSkill("xiaoji") and p:getEquips():length() > 0 then
					to = p 
					break
				end
			end
		end
	end
	if not to then
		if diamonds_num == num and diamonds_num == 0 then
			return targets:first()
		elseif num > 3 and num - discard_num <= 2 then
			for _, p in sgs.qlist(targets) do
				if self:isEnemy(p) then
					if p:getHandcardNum() + p:getEquips():length() <= discard_num then
						if to and to:getHandcardNum() + to:getEquips():length() < p:getHandcardNum() + p:getEquips():length() then
							to = p
						elseif not to then
							to = p
						end
					end
				end
			end
		end
	end
	if to then
		return to
	end
	return nil
end

-----马良-----

sgs.ai_skill_playerchosen.yingyuan = function(self, targets)
	local source = self.player
	local room = self.room
	local ids = source:getTag("yingyuanCard"):toString():split("+")
	if #ids == 0 or ids[1] == "" then return nil end
	local yueyin = nil
	local weak_friend = nil
	local min_card_friend = nil
	for _,p in sgs.qlist(targets) do 
		if self:isFriend(p) and p:hasShownSkill("jizhi") then
			yueyin = p 
		end
		if self:isFriend(p) and self:isWeak(p) then
			if weak_friend then
				if weak_friend:getHp() > p:getHp() and p:getHandcardNum() + p:getEquips():length() <= weak_friend:getHandcardNum() + weak_friend:getEquips():length() + 1 then
					weak_friend = p
				end
			else
				weak_friend = p 
			end
		end
		if self:isFriend(p) then
			if min_card_friend then
				if min_card_friend:getHandcardNum() + min_card_friend:getEquips():length() > p:getHandcardNum() + p:getEquips():length() then
					min_card_friend = p
				end
			else
				min_card_friend =  p
			end
		end
	end
	for _, c in pairs(ids) do 
		local card = sgs.Sanguosha:getCard(tonumber(c))
		if card:isKindOf("Jink") or card:isKindOf("Peach") or card:isKindOf("Analeptic") then
			if weak_friend then
				return weak_friend
			end
		end
		if card:isNDTrick() then
			if yueyin then
				return yueyin
			end
		end
		if min_card_friend then
			return min_card_friend
		end
	end
	if min_card_friend then
		return min_card_friend
	end
end
sgs.ai_skill_invoke.zishu = function(self, data)
	local room = self.room
	room:getThread():delay(200)
    return true
end
sgs.ai_skill_movecards.zishu1 = function(self, upcards, downcards, min_num, max_num)
	local zishu_cards = sgs.IntList()
	local upcards_copy = table.copyFrom(upcards)
	local number = #upcards_copy
	--self:sortByUseValue(upcards, true)
	for _, c in pairs(upcards_copy) do
		zishu_cards:append(c)
	end
	local down = {}
	local handcard_list = {}
	local useValueSelect = true
	local keepValueSelect = true
	for _, c in sgs.qlist(zishu_cards) do
		for _, h in sgs.qlist(self.player:getHandcards()) do 
			if self:isWeak(self.player) and self:getCardsNum("Jink") + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 2 then
				local pile_card = sgs.Sanguosha:getCard(c)
				if keepValueSelect and pile_card:isKindOf("Peach") or pile_card:isKindOf("Jink") or pile_card:isKindOf("Analeptic") and not table.contains(handcard_list, h) then
					table.insert(down, c)
					table.removeOne(upcards_copy, c)
					table.insert(handcard_list, h)
					keepValueSelect = false
					break
				end
				if self:getKeepValue(pile_card) > self:getKeepValue(h) and not table.contains(handcard_list, h) then
					table.insert(down, c)
					table.removeOne(upcards_copy, c)
					table.insert(handcard_list, h)
					break
				end
			else 
				local pile_card = sgs.Sanguosha:getCard(c)
				if useValueSelect and self:getUseValue(pile_card) > self:getUseValue(h) and not table.contains(handcard_list, h) then
					table.insert(down, c)
					table.removeOne(upcards_copy, c)
					table.insert(handcard_list, h)
					useValueSelect = false
					break
				elseif self:getKeepValue(pile_card) > self:getKeepValue(h) and not table.contains(handcard_list, h) then
					table.insert(down, c)
					table.removeOne(upcards_copy, c)
					table.insert(handcard_list, h)
					break
				end
			end
		end
		if #down >= max_num then
			break
		end
	end
	return upcards_copy, down
	--return up_card_tonumber, down
end
sgs.ai_skill_exchange.zishu = function(self, pattern, max_num, min_num, expand_pile)
	local to_exchange = {}
	local prohibit_list = self.player:property("zishuExchangeProp"):toString():split("+")
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards, false)
	for _,c in ipairs(cards) do
		if not (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then
			local not_in_prohibit = true
			for _, i in pairs(prohibit_list) do 
				if c:getEffectiveId() == tonumber(i) then
					not_in_prohibit = false
				end
			end
			if not_in_prohibit then
				table.insert(to_exchange, c:getEffectiveId())
			end
		end
		if #to_exchange >= min_num then
			break
		end
	end
	if #to_exchange < min_num then
		for _,c in ipairs(cards) do
			local not_in_prohibit = true
			for _, i in pairs(prohibit_list) do 
				if c:getEffectiveId() == i then
					not_in_prohibit = false
				end
			end
			if not_in_prohibit then
				table.insert(to_exchange, c:getEffectiveId())
			end
			if #to_exchange >= min_num then
				break
			end
		end
	end
	return to_exchange
end
sgs.ai_skill_movecards.zishu2 = function(self, upcards, downcards, min_num, max_num)  --todo：借鉴灭计/涯角/【攻心】（应该简单点）
	--local Variant = self.player:getTag("AI_shenduanDrawPileCards"):toList()
	--self.player:removeTag("AI_shenduanDrawPileCards")
	local zishu_cards = sgs.IntList()
	for _, c in pairs(upcards) do
		zishu_cards:append(c)
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
		if zishu_cards:length() >= num then
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
			for i = num - 1  , num - zishu_cards:length() , -1 do
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
				for _,id_str in sgs.qlist(zishu_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Spade or (sgs.Sanguosha:getCard(id_str):getNumber() < 2 and sgs.Sanguosha:getCard(id_str):getNumber() > 9) then
						table.insert(lightning_not_effect, tonumber(id_str))
					end
				end
			end
			if indulgence_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if lightning_index ~= -1 and table.contains(lightning_not_effect,tonumber(id_str)) and #lightning_not_effect == 1 then continue end
					if (sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Heart) or (nextAlive:hasShownSkill("hongyan") and sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Spade) then
						down[indulgence_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
			end
			if supplyShortage_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if lightning_index ~= -1 and table.contains(lightning_not_effect,tonumber(id_str)) and #lightning_not_effect == 1 then continue end
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Club then
						down[supplyShortage_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
			end
			if lightning_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Spade or (sgs.Sanguosha:getCard(id_str):getNumber() < 2 and sgs.Sanguosha:getCard(id_str):getNumber() > 9) then
						down[lightning_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
			end
			if indulgence_index ~= -1 and down[indulgence_index] == -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					down[indulgence_index] = tonumber(id_str)
					zishu_cards:removeOne(id_str)
					break
				end
			end
			if supplyShortage_index ~= -1 and down[supplyShortage_index] == -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					down[supplyShortage_index] = tonumber(id_str)
					zishu_cards:removeOne(id_str)
					break
				end
			end
		elseif self:isEnemy(nextAlive) then
			if lightning_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Spade and sgs.Sanguosha:getCard(id_str):getNumber() >= 2 and sgs.Sanguosha:getCard(id_str):getNumber() <= 9 then
						down[lightning_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
			end
			if indulgence_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Club then 
						down[indulgence_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
				if down[indulgence_index] == -1 then
					for _,id_str in sgs.qlist(zishu_cards) do
						if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Heart  then
							down[indulgence_index] = tonumber(id_str)
							zishu_cards:removeOne(id_str)
							break
						end
					end
				end
			end
			if supplyShortage_index ~= -1 then
				for _,id_str in sgs.qlist(zishu_cards) do
					if sgs.Sanguosha:getCard(id_str):getSuit() == sgs.Card_Heart then 
						down[supplyShortage_index] = tonumber(id_str)
						zishu_cards:removeOne(id_str)
						break
					end
				end
				if down[supplyShortage_index] == -1 then
					for _,id_str in sgs.qlist(zishu_cards) do
						if sgs.Sanguosha:getCard(id_str):getSuit() ~= sgs.Card_Club  then
							down[supplyShortage_index] = tonumber(id_str)
							zishu_cards:removeOne(id_str)
							break
						end
					end
				end
			end
		end
	end
	if zishu_cards:length() > 0 then
		for j = 1 , #upcards, 1 do
			if down[j] == -1 then
				down[j] = tonumber(zishu_cards:first())
				zishu_cards:removeOne(zishu_cards:first())
			end
		end
	end
	return {}, down
end
	
-----王基-----

sgs.ai_skill_playerchosen.qizhi = function(self, targets)
	local source = self.player
	local room = self.room
	local dengai
	local weixie
	local fangyu
	local wangji
	for _, p in sgs.qlist(targets) do
		if self:isFriend(p) and p:hasShownSkill("tuntian") then
			dengai = p 
		end
		if self:isEnemy(p) then
			if p:getEquip(1) then
				fangyu = p
			end
			if not self:isFriend(p:getNextAlive(1)) and not self:isFriend(p:getNextAlive(-1)) then
				if p:getEquip(0) or p:getEquip(3) then
					weixie = p
				end
			end
		end
		if p:objectName() == source:objectName() then
			wangji = p 
		end
		if weixie then return weixie end
		if dengai then return dengai end
		if fangyu then return fangyu end
		if wangji then return wangji end
	end
	return targets:first()
end
sgs.ai_skill_invoke.jinqu = function(self, data)
--jinqu_damaged
	if data:toString() == "1" then return true end
	local x = self.player:getMark("@qizhi")
	local handcardNum = self.player:getHandcardNum()
	if x == 0 then return false end
	if handcardNum <= x then
		return true
	elseif (handcardNum > 0 and handcardNum < 3 and handcardNum - x <= 1) or (handcardNum >=3 and handcardNum < 6 and handcardNum - x <= 2) or (handcardNum >=6 and handcardNum < 10 and handcardNum - x <= 3) then
		local junk_cards_num = 0
		local slash_num = 0
		local fangyu_num = 0
		for _, c in sgs.qlist(self.player:getHandcards()) do 
			if c:isKindOf("TrickCard") and not c:isKindOf("Nullification") then
				junk_cards_num = junk_cards_num + 1
			elseif c:isKindOf("EquipCard") then 
				junk_cards_num = junk_cards_num + 1 
			elseif c:isKindOf("Slash") then
				slash_num = slash_num + 1 
			elseif c:isKindOf("Peach") or c:isKindOf("Jink") or (c:isBlack() and self.player:hasSkill("qingguo")) then
				fangyu_num = fangyu_num + 1 
			end
			if junk_cards_num >= handcardNum - x then return true end
			if fangyu_num < slash_num then return true end
		end
	end
end 

-----徐氏-----
sgs.ai_use_value.fuzhuCard = 2
sgs.ai_use_priority.fuzhuCard = 3
local fuzhu_skill = {}
fuzhu_skill.name = "fuzhu"
table.insert(sgs.ai_skills, fuzhu_skill)
fuzhu_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	if self.player:getHp() == 0 then return nil end
	return sgs.Card_Parse("#fuzhuCard:.:&fuzhu")
end
sgs.ai_skill_use_func["#fuzhuCard"] = function(card, use, self)
	local source = self.player
	local room = self.room
	local to 
	local big_kingdoms = source:getBigKingdoms("fuzhu")
	for _, p in sgs.qlist(room:getOtherPlayers(source)) do 
		if self:isEnemy(p) and p:isMale() and source:inMyAttackRange(p) then
			if table.contains(big_kingdoms,p:getKingdom()) then 
				to = p 
				break
			end
		end
	end
	if not to then
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do 
			if self:isEnemy(p) and p:isMale() and source:inMyAttackRange(p) then
				to = p 
				break
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
sgs.ai_skill_invoke.wengua = function(self, data)
	local room = self.room
    return true
end
sgs.ai_skill_exchange.wengua = function(self, pattern, max_num, min_num, expand_pile)
	local source = self.player
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local room = self.room
	local to = room:getCurrent()
	local judge_card = 0      --0代表无，1代表乐不思蜀，2代表兵粮寸断，3代表闪电
	local to_put = {}
	for _, c in sgs.qlist(to:getNextAlive():getJudgingArea()) do 
		if c:isKindOf("Indulgence") then
			judge_card = 1
		elseif c:isKindOf("SupplyShortage") then
			judge_card = 2
		elseif c:isKindOf("Lightning") then
			judge_card = 3
		end
	end
	if (judge_card == 1 or judge_card == 2) then
		if self:isFriend(to:getNextAlive()) then
			for _,c in ipairs(cards) do
				if (judge_card == 1 and c:getSuit() == sgs.Card_Heart) or (judge_card == 2 and c:getSuit() == sgs.Card_Club) then
					source:setTag("wenguaPushTag", sgs.QVariant(true))
					table.insert(to_put, c:getEffectiveId())
					return to_put
				elseif judge_card == 3 and (c:getSuit() ~= sgs.Card_Spade or (c:getSuit() == sgs.Card_Spade and (c:getNumber() < 2 or c:getNumber() > 9))) then
					source:setTag("wenguaPushTag", sgs.QVariant(true))
					table.insert(to_put, c:getEffectiveId())
					return to_put
				end
			end
		elseif self:isEnemy(to:getNextAlive()) then
			for _,c in ipairs(cards) do
				if (judge_card == 1 and c:getSuit() ~= sgs.Card_Heart) or (judge_card == 2 and c:getSuit() ~= sgs.Card_Club) then
					source:setTag("wenguaPushTag", sgs.QVariant(true))
					table.insert(to_put, c:getEffectiveId())
					return to_put
				elseif judge_card == 3 and (c:getSuit() == sgs.Card_Spade and (c:getNumber() >= 2 and c:getNumber() <= 9)) then
					source:setTag("wenguaPushTag", sgs.QVariant(true))
					table.insert(to_put, c:getEffectiveId())
					return to_put
				end
			end
		end
	end
	for _,c in ipairs(cards) do
		if (c:isBlack() and c:isKindOf("TrickCard") and not c:isKindOf("Collateral") and 
				not c:isKindOf("Nullification") and not c:isKindOf("FightTogether") and not c:isKindOf("ImperialOrder") and
				not c:isKindOf("ThreatenEmperor") and not c:isKindOf("Lightning") and not c:isKindOf("BurningCamps")) or 
				c:isKindOf("Slash") then
			source:setTag("wenguaPushTag", sgs.QVariant(false))
			table.insert(to_put, c:getEffectiveId())
			return to_put
		end
	end
	for _,c in ipairs(cards) do
		table.insert(to_put, c:getEffectiveId())
		return to_put
	end
	return {}
end
sgs.ai_skill_choice["wengua"] = function(self, choices, data)
    local source = self.player
    local room = source:getRoom()
	local choice = source:getTag("wenguaPushTag"):toBool()
	if choice then
		return pile_top
	else
		return pile_bottom
	end
	return false
end

------陈宫-----

mingce_skill = {}
mingce_skill.name = "mingce"
table.insert(sgs.ai_skills, mingce_skill)
mingce_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#mingceCard") then return end
	if not self:willShowForAttack() then return end

	local card
	if self:needToThrowArmor() then
		card = self.player:getArmor()
	end
	if not card then
		local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)

		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
				if self:getCardsNum("Slash") > 1 then
					card = hcard
					break
				else
					local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
					self:useBasicCard(hcard, dummy_use)
					if dummy_use and dummy_use.to and (dummy_use.to:length() == 0
							or (dummy_use.to:length() == 1 and not self:hasHeavySlashDamage(self.player, hcard, dummy_use.to:first()))) then
						card = hcard
						break
					end
				end
			elseif hcard:isKindOf("EquipCard") then
				card = hcard
				break
			end
		end
	end
	if not card then
		local ecards = self.player:getCards("e")
		ecards = sgs.QList2Table(ecards)

		for _, ecard in ipairs(ecards) do
			if ecard:isKindOf("Weapon") or ecard:isKindOf("OffensiveHorse") then
				card = ecard
				break
			end
		end
	end
	if card then
		card = sgs.Card_Parse("#mingceCard:" .. card:getEffectiveId() .. ":&mingce")
		return card
	end

	return nil
end
sgs.ai_skill_use_func["#mingceCard"] = function(card, use, self)
	local target
	local friends = self.friends_noself
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	local slash_target

	local canmingceTo = function(player)
		local canGive = not self:needKongcheng(player, true)
		return canGive or (not canGive and self:getEnemyNumBySeat(self.player, player) == 0)
	end

	local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
	self:sort(self.enemies, "defense")
	local _, friend = self:getCardNeedPlayer({real_card}, friends, "mingce")
	if friend and self:isFriend(friend) and canmingceTo(friend) then
		for _, enemy in ipairs(self.enemies) do
			if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
					and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
					and enemy:objectName() ~= self.player:objectName() then
				target = friend
				slash_target = enemy
				break
			end
		end
	end
	
	if not target then
		for _, friend in ipairs(friends) do
			if canmingceTo(friend) then
				for _, enemy in ipairs(self.enemies) do
					if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
							and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
							and enemy:objectName() ~= self.player:objectName() then
						target = friend
						slash_target = enemy
						break
					end
				end
			end
			if target then break end
		end
	end

	if not target then
		self:sort(friends, "defense")
		local _, friend = self:getCardNeedPlayer({real_card}, friends, "mingce")
		if friend and self:isFriend(friend) and canmingceTo(friend) then  --getCardNeedPlayer可能破空城
			target = friend
		end
	end

	if not target then
		self:sort(friends, "defense")
		for _, friend in ipairs(friends) do
			if canmingceTo(friend) then
				target = friend
				break
			end
		end
	end

	if target then
		use.card = card
		if use.to then
			use.to:append(target)
			if not slash_target then
				local slash_targets = sgs.SPlayerList()
				if self:slashIsAvailable(target) then
					for _, p in sgs.qlist(self.room:getOtherPlayers(target)) do
						if target:canSlash(p) then
							slash_targets:append(p)
						end
					end
				end
				if not slash_targets:isEmpty() then
					slash_target = sgs.ai_skill_playerchosen.zero_card_as_slash(self, slash_targets)
				end
			end
			if slash_target then
				use.to:append(slash_target)
			end
		end
	end
end
sgs.ai_skill_choice.mingce = function(self, choices)
	--local chengong = self.room:getCurrent()
	local chengong = sgs.findPlayerByShownSkillName("mingce")  --防明鉴
	if chengong and not self:isFriend(chengong) then return "draw" end
	if not string.find(choices, "use") then return "draw" end  --防特殊情况（比如未通过二次合法性检测）
	local target = self.player:getTag("mingceTarget"):toPlayer()
	if not target then return "draw" end
	if not self:isFriend(target) then
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not self:slashProhibit(slash, target) then return "use" end
	end
	return "draw"
end
sgs.ai_use_value.mingceCard = 5.9
sgs.ai_use_priority.mingceCard = 4
sgs.ai_card_intention.mingceCard = function(self, card, from, tos)
	sgs.updateIntention(from, tos[1], -70)
end
sgs.ai_cardneed.mingce = sgs.ai_cardneed.equip
sgs.ai_skill_invoke.zhichi = function(self, data)
	local current = self.room:getCurrent()
	if not current or current:isDead() then return false end
	
	--来自潜心
	local threat = getCardsNum("SavageAssault", current, self.player) + getCardsNum("ArcheryAttack", current, self.player)
	if not self:isFriend(current) then
		threat = threat + getCardsNum("Duel", current, self.player)
		if self:slashIsAvailable(current) and current:canSlash(self.player) and getCardsNum("Slash", current, self.player) > 0 then
			threat = threat + (self:hasCrossbowEffect(current) and getCardsNum("Slash", current, self.player) or 1)
		end
		if not self.player:isNude() then
			threat = threat + getCardsNum("Dismantlement", current, self.player)
			if current:distanceTo(self.player) == 1 or current:hasShownSkill("qicai") then
				threat = threat + getCardsNum("Snatch", current, self.player)
			end
		end
		if not self.player:getEquips():isEmpty() and not self:needToThrowArmor() then
			threat = threat + getCardsNum("Drowning", current, self.player)
		end
		if current:getNextAlive() and self.player:inFormationRalation(current:getNextAlive()) then  --Ralation醉了
			threat = threat + getCardsNum("BurningCamps", current, self.player)
		end
	end
	if threat >= 1 --[[and not self.player:hasSkill("Shibei")]] then return true end
	
	local benefit = getCardsNum("AmazingGrace", current, self.player)
	if self.player:isWounded() then
		benefit = benefit + getCardsNum("GodSalvation", current, self.player)
	end
	if self:isFriend(current) then
		if (self.player:containsTrick("indulgence") or self.player:containsTrick("supply_shortage")) then
			benefit = benefit + getCardsNum("Dismantlement", current, self.player)
			if current:distanceTo(self.player) == 1 or current:hasShownSkill("qicai") then
				benefit = benefit + getCardsNum("Snatch", current, self.player)
			end
		end
		local slash = sgs.cloneCard("slash")  --防止isPriorFriendOfSlash报错
		if self:isPriorFriendOfSlash(self.player, slash, current) and current:canSlash(self.player) and self:slashIsAvailable(current) and getCardsNum("Slash", current, self.player) > 0 then
			benefit = benefit + (self:hasCrossbowEffect(current) and getCardsNum("Slash", current, self.player) or 1)
		end
	end
	
	return self:willShowForDefence() and benefit < 1
end

-----曹节-----
sgs.ai_skill_invoke.shouxi = function(self, data)
	local room = self.room
    return true
end
sgs.ai_skill_invoke.huimin = function(self, data)
	local room = self.room
	local friend_num = 0 
	local enemy_num = 0
	for _, p in sgs.qlist(room:getAlivePlayers()) do 
		if p:getHandcardNum() < p:getHp() then
			if self:isFriend(p) then friend_num = friend_num + 1 
			elseif self:isEnemy(p) then enemy_num = enemy_num + 1
			end
		end
	end
	if friend_num == 0 then return false end
	if (friend_num <= 2 and friend_num + 2 >= enemy_num) or (friend_num > 2 and friend_num + 3 >= enemy_num) then
		return true
	end
	return false
end
sgs.ai_skill_exchange.huimin = function(self, pattern, max_num, min_num, expand_pile)
	local to_show = {}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,c in ipairs(cards) do
		if not (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then
			table.insert(to_show, c:getEffectiveId())
		end
		if #to_show >= min_num then break end
	end
	if #to_show < min_num then
		for _,c in ipairs(cards) do
			if not table.contains(to_show, c:getEffectiveId()) then
				table.insert(to_show, c:getEffectiveId())
			end
			if #to_show >= min_num then break end
		end
	end
	return to_show
end
sgs.ai_skill_playerchosen.huimin = function(self, targets)
	local source = self.player
	local room = self.room
	local num = targets:length()
	local target_list = {}
	local target_sort_list = {}
	for _, p in sgs.qlist(targets) do 
		table.insert(target_list, p:objectName())
	end
	local current_player = source
	local i = 1
	while true do
		if table.contains(target_list, current_player:objectName()) then
			target_sort_list[i] = current_player
			i = i + 1 
		end
		current_player = current_player:getNextAlive()
		if #target_sort_list == #target_list then break end
	end	
	local friend_judge_list = {}
	i = 1
	for _, p in pairs(target_sort_list) do 
		if self:isFriend(p) then
			friend_judge_list[i] = 1 
		else
			friend_judge_list[i] = 0
		end
		i = i + 1
	end
	local max_num = 0
	local max_value_player = -1
	for j = 1, num, 1 do 
		local value = 0
		for k = 1, num, 1 do 
			local index = k + j - 1
			if index > num then index = index - num end
			value = value + math.pow(2, num - k) * friend_judge_list[index]
		end
		if value > max_num then
			max_num = value
			max_value_player = j
		end
	end
	if max_value_player ~= -1 then
		return target_sort_list[max_value_player]
	end
	return targets:first()
end

-----曹冲-----

sgs.ai_skill_invoke.chengxiang = function(self)
	return not self:needKongcheng(self.player, true)
end
function chengxiangDFS(cards, current, i)
	if i > #cards then return {} end
	local result = {}
	local temp = (current ~= "") and current:split("+") or {}
	table.insertTable(result, chengxiangDFS(cards, current, i + 1))
	
	local temp_int = {}
	for _,id_str in ipairs(temp) do
		table.insert(temp_int, tonumber(id_str))
	end
	if chengxiangAsMovePattern(temp_int, cards[i]) then
		table.insert(temp, cards[i])
		table.insert(result, table.concat(temp, "+"))
		table.insertTable(result, chengxiangDFS(cards, table.concat(temp, "+"), i + 1))
	end
	return result
end
function evaluatechengxiangCards(self, card_str)
	if card_str == "" then return 0 end
	local cards = card_str:split("+")
	local sum = 0
	for _,id in ipairs(cards) do
		sum = sum + self:cardNeed(sgs.Sanguosha:getCard(tonumber(id)))
	end
	return sum
end
function sortchengxiangChoicesByCardNeed(self, choices, inverse)
	local values = {}
	for _, choice in ipairs(choices) do
		values[choice] = evaluatechengxiangCards(self, choice)
	end

	local compare_func = function(a,b)
		local value1 = values[a]
		local value2 = values[b]

		if value1 ~= value2 then
			if inverse then return value1 > value2 end
			return value1 < value2
		else  --牌数
			local a_tab = a:split("+")
			local b_tab = b:split("+")
			if inverse then return #a_tab > #b_tab end
			return #a_tab < #b_tab
		end
	end

	table.sort(choices, compare_func)
	
	--已知bug：排序时是按未拿到手时单独地判断每张牌，如果第二张牌的need会随第一张牌的到手而减少则不会识别出来
	--例如有时会拿2闪而不是1闪1酒，即使拿了1闪以后闪的need比酒低
end
sgs.ai_skill_movecards.chengxiang = function(self, upcards, downcards, min_num, max_num)
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	
	local choices = chengxiangDFS(upcards, "", 1)
	sortchengxiangChoicesByCardNeed(self, choices)
	for _,id_str in ipairs(choices[#choices]:split("+")) do
		table.insert(down, tonumber(id_str))
		table.removeAll(upcards_copy, tonumber(id_str))
	end
	
	return upcards_copy, down
end
sgs.ai_skill_cardask["@renxin-card"] = function(self, data, pattern)
	local dmg = data:toDamage()
	if not self:willShowForDefence() and not self.player:willBeFriendWith(dmg.to) then return "." end  --同势力的就不管亮没亮将了，先救了再说
	local invoke
	if self:isFriend(dmg.to) then
		if self:damageIsEffective_(dmg) and not self:getDamagedEffects(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash"))
			and not self:needToLoseHp(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash")) then
			invoke = true
		elseif not self:toTurnOver(self.player) then
			invoke = true
		end
	elseif self:objectiveLevel(dmg.to) == 0 and not self:toTurnOver(self.player) then
		invoke = true
	end
	if invoke then
		local equipCards = {}
		for _, c in sgs.qlist(self.player:getCards("he")) do
			if c:isKindOf("EquipCard") and self.player:canDiscard(self.player, c:getEffectiveId()) then
				table.insert(equipCards, c)
			end
		end
		if #equipCards > 0 then
			self:sortByKeepValue(equipCards)
			return equipCards[1]:getEffectiveId()
		end
	end
	return "."
end
sgs.ai_cardneed.renxin = function(to, card, self)
	for _,friend in ipairs(self.friends_noself) do
		if self:isWeak(friend) then
			return sgs.ai_cardneed.shensu(to, card, self)
		end
	end
end
function SmartAI:hasrenxinEffect(to, from, needFaceDown, damageNum, isSlash, slash, nature, simulateDamage)  --检测是否会导致无意义的酒杀之类
	if isSlash and (not slash or not slash:isKindOf("Slash")) then
		slash = self.player:objectName() == from:objectName() and self:getCard("Slash") or sgs.cloneCard("slash")
	end
	local damageStruct = {}
	damageStruct.to = to or self.player
	damageStruct.from = from or self.room:getCurrent()
	damageStruct.nature = nature or sgs.DamageStruct_Normal
	damageStruct.damage = damageNum or 1
	damageStruct.card = slash
	if slash and not nature then
		if slash:isKindOf("FireSlash") then
			damageStruct.nature = sgs.DamageStruct_Fire
		elseif slash:isKindOf("ThunderSlash") then
			damageStruct.nature = sgs.DamageStruct_Thunder
		end
	end
	return self:hasrenxinEffect_(damageStruct, needFaceDown, simulateDamage)  --needFaceDown表示只考虑叠置的曹冲翻回来的情况（因为cost比较伤），但是实际上用到的地方全是false。。
end
function SmartAI:hasrenxinEffect_(damageStruct, needFaceDown, simulateDamage)
	if type(damageStruct) ~= "table" and type(damageStruct) ~= "DamageStruct" and type(damageStruct) ~= "userdata" then self.room:writeToConsole(debug.traceback()) return end
	if not damageStruct.to then self.room:writeToConsole(debug.traceback()) return end
	local to = damageStruct.to
	if to:hasFlag("AI_renxinTesting") then return false end
	if to:getHp() ~= 1 then return false end
	local nature = damageStruct.nature or sgs.DamageStruct_Normal
	local damage = damageStruct.damage or 1
	local from = damageStruct.from
	local card = damageStruct.card
	--if from:hasShownSkill("Jueqing") then return false end
	
	local caochong = sgs.findPlayerByShownSkillName("renxin")
	if not caochong or (caochong:objectName() == to:objectName()) or not self:isFriend(caochong, to) then return false end
	if getKnownCard(caochong, self.player, "EquipCard", false, "h") + caochong:getEquips():length() < 1 then return false end  --cardIsVisible判断有问题
	local equips = getKnownCard(caochong, self.player, "EquipCard", false, "he", true)
	if next(equips) and caochong:isJilei(equips[1]) then return false end
	
	if not self:toTurnOver(caochong) then return true end
	if needFaceDown then return false end
	
	if simulateDamage then  --抄hasHeavySlashDamage、damageIsEffective_
		if card and card:isKindOf("Slash") then
			if (card and card:hasFlag("drank")) then
				damage = damage + 1
			elseif from:getMark("drank") > 0 then
				damage = damage + from:getMark("drank")
			end
		end
		--if from:hasShownSkill("Jueqing") then return false end
		
		if to:getMark("@gale") > 0 and nature == sgs.DamageStruct_Fire then damage = damage + 1 end
		if to:getMark("@gale_ShenZhuGeLiang") > 0 and nature == sgs.DamageStruct_Fire then damage = damage + 1 end
	
		if card and card:isKindOf("Slash") then
			if from:hasFlag("luoyi") then damage = damage + 1 end
			if from:getMark("@LuoyiLB") > 0 then damage = damage + from:getMark("@LuoyiLB") end
			if from:hasShownSkill("anjian") and not to:inMyAttackRange(from) then damage = damage + 1 end
			if from:hasWeapon("GudingBlade") and slash and to:isKongcheng() then damage = damage + 1 end
		elseif card and card:isKindOf("Duel") then
			if from:hasFlag("luoyi") then damage = damage + 1 end
			if from:getMark("@LuoyiLB") > 0 then damage = damage + from:getMark("@LuoyiLB") end
		end
		
		if to:hasShownSkill("mingshi") and from and not from:hasShownAllGenerals() then
			damage = damage - 1
		end
		if to:hasShownSkills("jgyuhuo_pangtong|jgyuhuo_zhuque") and nature == sgs.DamageStruct_Fire then return false end
		local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
		if jiaren_zidan and jiaren_zidan:isFriendWith(to) then
			damage = 1
		end
	end
	
	if to:hasArmorEffect("PeaceSpell") and not IgnoreArmor(from, to) and not (from:hasWeapon("IceSword") and card and card:isKindOf("Slash")) and not from:hasShownSkills("zhiman|zhiman_GuanSuo") and nature ~= sgs.DamageStruct_Normal then return false end
	if to:hasArmorEffect("Breastplate") and not IgnoreArmor(from, to) then return false end  --此时体力值为1，因此必能发动护心镜
	if to:hasArmorEffect("Vine") and not IgnoreArmor(from, to) and nature == sgs.DamageStruct_Fire then
		damage = damage + 1
	end
	if to:hasArmorEffect("SilverLion") and not IgnoreArmor(from, to) then
		damage = 1
	end
	if damage > 1 then return true end  --伤害大于1点则曹冲必须仁心
	if damage < 1 then return false end
	
	--if self:needToThrowArmor(caochong) or (caochong:hasShownSkills(sgs.lose_equip_skill) and caochong:canDiscard(caochong, "e")) then return true end
	return false  --此函数目的仅仅是检测酒杀之类，因此不用考虑曹冲翻面是否值得等情况
end
sgs.renxin_keep_value = sgs.xiaoji_keep_value

-----杀戮模式*曹冲-----

sgs.ai_cardneed.shaluRenxin = function(to, card, self)
	for _,friend in ipairs(self.friends_noself) do
		if self:isWeak(friend) then
			return sgs.ai_cardneed.shensu(to, card, self)
		end
	end
end

-----夏侯氏-----
sgs.ai_skill_invoke.qiaoshi = function(self, data)
	local room = self.room
	local source = self.player
	local to = room:getCurrent()
	if self:isFriend(to) then
		return true
	end
	if self:isWeak() then
		if self:getCardsNum("Jink") + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 3 then
			return true
		end
	end
    return false
end
sgs.ai_skill_movecards.yanyu = function(self, upcards, downcards, min_num, max_num)
	local yanyu_cards = sgs.IntList()
	local upcards_copy = table.copyFrom(upcards)
	for _, c in pairs(upcards_copy) do
		yanyu_cards:append(c)
	end
	local down = {}
	local spade_num, spade_value, heart_num, heart_value, club_num, club_value, diamond_num, diamond_value = 0,0,0,0,0,0,0,0
	for _, c in sgs.qlist(yanyu_cards) do
		local card = sgs.Sanguosha:getCard(c)
		local value = 0
		if card:isKindOf("Jink") then
			if self:getCardsNum("Jink") == 0 then
				value = 5.2
			elseif self:getCardsNum("Jink") > 2 then
				value = 3.1
			else
				value = 4.1
			end
		elseif card:isKindOf("Peach") then value = 7
		elseif card:isKindOf("Slash") then 
			if self:getCardsNum("Slash") == 0 and self.player:usedTimes("#yanyuCard") < 2 then
				value = 6.2
			else
				value = 4
			end
		elseif card:isKindOf("Analeptic") then
			if self:getCardsNum("Analeptic") == 0 then
				value = 4.5
			else
				value = 3
			end
		elseif card:isKindOf("ExNihilo") or card:isKindOf("BefriendAttacking") then value = 5.5
		elseif card:isKindOf("EightDiagram") or card:isKindOf("Indulgence") then value = 5.7
		elseif card:isKindOf("Nullification") or card:isKindOf("JadeSeal") then value = 4.3
		elseif card:isKindOf("ImperialOrder") or card:isKindOf("FightTogether") then value = 2
		elseif card:isKindOf("EquipCard") or card:isKindOf("Snatch") then value = 3.7
		else value = 3
		end
		if card:getSuit() == sgs.Card_Spade then 
			spade_num = spade_num + 1 
			spade_value = spade_value + value
		elseif card:getSuit() == sgs.Card_Heart then 
			heart_num = heart_num + 1
			heart_value = heart_value + value
		elseif card:getSuit() == sgs.Card_Club 
			then club_num = club_num + 1
			club_value = club_value + value
		elseif card:getSuit() == sgs.Card_Diamond then 
			diamond_num = diamond_num + 1
			diamond_value = diamond_value + value
		end
	end
	if self.player:hasSkill("jizhi") and card:isNDTrick() then value = value + 1.3 end
	local max_value = spade_value
	local max_suit = sgs.Card_Spade
	if heart_value > max_value then 
		max_value = heart_value
		max_suit = sgs.Card_Heart
	end
	if club_value > max_value then 
		max_value = club_value
		max_suit = sgs.Card_Club
	end
	if diamond_value > max_value then 
		max_value = diamond_value
		max_suit = sgs.Card_Diamond
	end
	for _, c in sgs.qlist(yanyu_cards) do
		local card = sgs.Sanguosha:getCard(c)
		if card:getSuit() == max_suit then
			table.insert(down, c)
			table.removeOne(upcards_copy, c)
		end
	end
	return upcards_copy, down
end
sgs.ai_use_value.yanyuCard = 17
sgs.ai_use_priority.yanyuCard = 16.62
local yanyu_skill = {}
yanyu_skill.name = "yanyu"
table.insert(sgs.ai_skills, yanyu_skill)
yanyu_skill.getTurnUseCard = function(self)
	if self.player:usedTimes("#yanyuCard") < 2 then
		return sgs.Card_Parse("#yanyuCard:.:&yanyu")
	end
end
sgs.ai_skill_use_func["#yanyuCard"] = function(card, use, self)
	local source = self.player
	local putcard ={}
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	for _, card in ipairs(cards) do
		if card:isKindOf("Slash") then
			table.insert(putcard,card:getEffectiveId())
			break
		end
	end
	if #putcard > 0 then
		use.card = sgs.Card_Parse("#yanyuCard:" .. table.concat(putcard, "+") .. ":&yanyu")
	end
end
sgs.ai_skill_playerchosen.yanyu = function(self, targets)
	local source = self.player
	local room = self.room
	local weak_friend
	for _, p in sgs.qlist(targets) do 
		if self:isFriend(p) then
			if p:isKongcheng() and p:hasShownSkill("kongcheng") and self.player:getNextAlive():objectName() ~= p:objectName() then continue end
			if weak_friend then
				if 2 * weak_friend:getHp() + weak_friend:getHandcardNum() + weak_friend:getEquips():length() > 2 * p:getHp() + p:getHandcardNum() + p:getEquips():length() then
					weak_friend = p
				end
			else
				weak_friend = p
			end
		end
	end
	return weak_friend
end

-----陆逊-----

local Eduoshi_skill = {}
Eduoshi_skill.name = "Eduoshi"
table.insert(sgs.ai_skills, Eduoshi_skill)
Eduoshi_skill.getTurnUseCard = function(self, inclusive)
	local DuoTime = 3
	if self.player:hasSkills("fenming|zhiheng|fenxun|keji") then
		DuoTime = 3
	end
	if self.player:hasSkills("hongyan|yingzi_zhouyu|yingzi_sunce") then
		DuoTime = 3
	end
	if self.player:hasSkills("xiaoji|haoshi") then
		DuoTime = 4
	end
	for _, player in ipairs(self.friends) do
		if player:hasShownSkills("xiaoji|haoshi") then
			DuoTime = 4
			break
		end
	end

	if self.player:getMark("@duoshiMark") >= DuoTime and self:getOverflow() <= 0 then return end

	if sgs.turncount <= 1 and #self.friends_noself == 0 and not self:isWeak() and self:getOverflow() <= 0 then return end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)

	if (self:hasCrossbowEffect() or self:getCardsNum("Crossbow") > 0) and self:getCardsNum("Slash") > 0 then
		self:sort(self.enemies, "defense")
		for _, enemy in ipairs(self.enemies) do
			local inAttackRange = self.player:distanceTo(enemy) == 1 or self.player:distanceTo(enemy) == 2
									and self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse()
			if inAttackRange  and sgs.isGoodTarget(enemy, self.enemies, self) then
				local slashes = self:getCards("Slash")
				local slash_count = 0
				for _, slash in ipairs(slashes) do
					if not self:slashProhibit(slash, enemy) and self:slashIsEffective(slash, enemy) then
						slash_count = slash_count + 1
					end
				end
				if slash_count >= enemy:getHp() then return end
			end
		end
	end

	local need_card
	if self.player:getHandcardNum() <= 2 then return end
	self:sortByUseValue(cards, true)
	local suit_used = self.player:property("duoshiProp"):toString():split("+")
	for _, card in ipairs(cards) do
	
		if not table.contains(suit_used, card:getSuitString()) then
			local shouldUse = true
			if card:isKindOf("Slash") then
				local dummy_use = { isDummy = true }
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			end

			if self:getUseValue(card) > sgs.ai_use_value.AwaitExhausted and card:isKindOf("TrickCard") then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end

			local sunshangxiang = false
			if self.player:hasSkills("xiaoji") and self.player:getCards("e"):length() > 0 then
				sunshangxiang = true
			end
			for _, player in ipairs(self.friends) do
				if player:hasShownSkill("xiaoji") and player:getCards("e"):length() > 0 then
					sunshangxiang = true
					break
				end
			end

			if not self:willShowForDefence() and not sunshangxiang then
				shouldUse = false
			end

			if shouldUse and not card:isKindOf("Peach") then
				need_card = card
				break
			end

		end
	end

	local EduoshiArg = DuoTime/ 1.3 - 042 * self:getOverflow() 
	if need_card then
		--if self:getUseValue(need_card) > self:getUseValue(sgs.Sanguosha:cloneCard("await_exhausted")) + EduoshiArg then return end
		local card_id = need_card:getEffectiveId()
		local card_str = string.format("await_exhausted:Eduoshi[%s:%d]=%d&Eduoshi",need_card:getSuitString(), need_card:getNumber(), need_card:getEffectiveId())
		local await = sgs.Card_Parse(card_str)
		assert(await)
		return await
	end
end
sgs.ai_skill_invoke.duoshi = function(self, data)
	return true
end

-----司马朗-----

sgs.ai_skill_invoke.junbing = function(self, data)
	local room = self.room
	local source = self.player
	local to = source:getTag("junbingTag"):toPlayer()
	if self:isFriend(to) then
		return true
	end
	if self:isEnemy(to) then
		if to:hasShownSkill("tuntian") then
			if to:hasShownSkill("jixi") then
				return false
			else
				if to:isKongcheng() then
					return true
				end
			end
		else
			if to:getHandcardNum() == 0 then
				return true
			elseif to:getHandcardNum() == 1 and (self:getCardsNum("Peach") == 0 or self:getCardsNum("Analeptic") == 0) then
				return true
			end
		end
	end
    return false
end
sgs.ai_skill_use["@@quji"] = function(self, prompt)
	self:sort(self.friends, "hp")
	local num = self.player:getHp()
	local target = nil
	local has_xizhicai
	for _, p in pairs(self.friends_noself) do
		if p:isWounded() and p:hasShownSkill("xianfu") then
			has_xizhicai = true
		end
	end
	if has_xizhicai then
		for _, p in pairs(self.friends_noself) do
			if p:isWounded() and p:getMark("@fu") > 0 then
				target = p
				break
			end
		end
	end
	if not target then
		for _, p in pairs(self.friends_noself) do
			if p:objectName() ~= self.player:objectName() and p:isWounded() then
				target = p
				break
			end
		end
	end
	local suit
	if self.player:getMark("qujispade") > 0 then
		suit = sgs.Card_Spade
	elseif self.player:getMark("qujiheart") > 0 then
		suit = sgs.Card_Heart
	elseif self.player:getMark("qujiclub") > 0 then
		suit = sgs.Card_Club
	elseif self.player:getMark("qujidiamond") > 0 then
		suit = sgs.Card_Diamond
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards)
	local need_card = {}
	for _, c in pairs(cards) do
		if not c:isKindOf("Peach") and c:getSuit() == suit then
			table.insert(need_card, c:getEffectiveId())
		end
		if #need_card >= num then
			break
		end
	end
	if target and #need_card == num then
	    local card_str = "#qujiCard:"..table.concat(need_card, "+")..":&quji->" .. target:objectName()
		return card_str	
	end
	return "."
end

-----潘璋马忠-----

sgs.ai_skill_cardask["@duodao-get"] = function(self, data)
	if not self:willShowForAttack() and not self:willShowForDefence() then return "." end
	local function getLeastValueCard(from)
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		for _, c in ipairs(cards) do
			if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
		end
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
		if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < self:evaluateWeapon(from:getWeapon()) then
			return "$" .. self.player:getWeapon():getEffectiveId()
		end
	end
	local damage = data:toDamage()
	if not damage.from or not damage.from:getWeapon() then
		if self:needToThrowArmor() then
			return "$" .. self.player:getArmor():getEffectiveId()
		elseif self.player:getHandcardNum() == 1 and self:needKongcheng() --[[(self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0))]] then
			return "$" .. self.player:handCards():first()
		end
	else
		if self:isFriend(damage.from) then
			if damage.from:hasSkills("xiaoji") and self:isWeak(damage.from) then
				local str = getLeastValueCard(damage.from)
				if str then return str end
			else
				if self:getCardsNum("Slash") == 0 or self:willSkipPlayPhase() then return "." end
				local invoke = false
				local range = sgs.weapon_range[damage.from:getWeapon():getClassName()] or 0
				if self.player:hasSkill("anjian") then
					for _, enemy in ipairs(self.enemies) do
						if not enemy:inMyAttackRange(self.player) and not self.player:inMyAttackRange(enemy) and self.player:distanceTo(enemy) <= range then
							invoke = true
							break
						end
					end
				end
				if not invoke and self:evaluateWeapon(damage.from:getWeapon()) > 8 then invoke = true end
				if invoke then
					local str = getLeastValueCard(damage.from)
					if str then return str end
				end
			end
		else
			--[[if damage.from:hasSkill("nosxuanfeng") then
				for _, friend in ipairs(self.friends) do
					if self:isWeak(friend) then return "." end
				end
			else]]
				--[[if hasManjuanEffect(self.player) then
					if self:needToThrowArmor() and not self.player:isJilei(self.player:getArmor()) then
						return "$" .. self.player:getArmor():getEffectiveId()
					elseif self.player:getHandcardNum() == 1
							and (self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0))
							and not self.player:isJilei(self.player:getHandcards():first()) then
						return "$" .. self.player:handCards():first()
					end
				else]]
					local str = getLeastValueCard(damage.from)
					if str then return str end
				--end
			--end
		end
	end
	return "."
end
sgs.ai_skill_invoke.anjian = function(self, data)
	if not self:willShowForAttack() then return false end
	local enemy = data:toPlayer()
	if self:isFriend(enemy) then return false end
	local damage = self.player:getTag("anjianDamage"):toDamage()
	local damage_copy = damage
	damage_copy.damage = damage_copy.damage + 1
	if self:objectiveLevel(enemy) > 3 and self:damageIsEffective_(damage_copy)
		and (not enemy:hasArmorEffect("SilverLion") or self.player:hasWeapon("QinggangSword")) then
		return true
	end
	return false
end
function sgs.ai_cardneed.anjian(to, card, self)  --抄裸衣
	local slash_num = 0
	local target
	local slash = sgs.cloneCard("slash")

	local cards = to:getHandcards()
	local need_slash = true
	for _, c in sgs.qlist(cards) do
		if sgs.cardIsVisible(c, to, self.player) then
			if isCard("Slash", c, to) then
				need_slash = false
				break
			end
		end
	end

	self:sort(self.enemies, "defenseSlash")
	for _, enemy in ipairs(self.enemies) do
		if to:canSlash(enemy) and not self:slashProhibit(slash ,enemy) and self:slashIsEffective(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2 then
			target = enemy
			break
		end
	end

	if need_slash and target and isCard("Slash", card, to) then return true end
end
sgs.anjian_keep_value = {
	DefensiveHorse  = 6,
	FireSlash       = 5.6,
	Slash           = 5.4,
	ThunderSlash    = 5.5,
	Axe             = 5,
	Triblade        = 4.9,
	Blade           = 4.9,
	Spear           = 4.9,
	Fan             = 4.8,
	KylinBow        = 4.7,
	Halberd         = 4.6,
	MoonSpear       = 4.5,
	SPMoonSpear     = 4.5,
	OffensiveHorse  = 4
}

-----刘琦-----

sgs.ai_skill_invoke.tunjiang = function(self, data)
	if self:needKongcheng() then
		return false
	end
    return true
end
sgs.ai_skill_invoke.benzhi = function(self, data)
    return true
end
sgs.ai_skill_invoke.wenji = function(self, data)
	local room = self.room
	local to = room:getCurrent()
	if to:getHandcardNum() <= 2 and self:isWeak(to) then
		return false
	end
    return true
end
sgs.ai_skill_cardask["@wenji-card"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local to = self.player:getTag("wenjiAskTag"):toPlayer()
	local need_jink = false
	local need_peach = false
	local need_equip = false
	local need_card = true
	local need_trick = false
	if self:isWeak(to) then
		if to:getHandcardNum() <= 2 then 
			need_jink = true
			need_peach = true
		end
	end
	if to:hasShownSkill("jizhi") or to:hasShownSkill("yingyuan") then
		need_trick = true
	end
	if self.player:getEquips():length() > 1 and to:getEquips():length() <= 1 then
		need_equip = true
	end
	if self:isWeak(self.player) and self.player:getHandcardNum() <= 2 then 
		need_card = false
	end
	if self.player:getNextAlive():objectName() == to:objectName() then
		need_equip = true
		need_trick = true
		need_card = true
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	if need_peach then
		for _,card in pairs(cards) do
			if card:isKindOf("Peach") then
				return card:toString()
			end
		end
	end
	if need_jink then
		for _,card in pairs(cards) do
			if card:isKindOf("Jink") then
				return card:toString()
			end
		end
	end
	if need_equip then
		for _,card in pairs(cards) do
			if card:isNDTrick() then
				return card:toString()
			end
		end
	end
	if need_equip then
		for _,card in pairs(cards) do
			for i = 0, 4, 1 do 
				if not to:getEquip(i) then
					if (i == 0 and card:isKindOf("Weapon")) or (i == 1 and card:isKindOf("Armor"))
							or (i == 2 and card:isKindOf("DefensiveHorse")) or (i == 3 and card:isKindOf("OffensiveHorse"))
							or (i == 4 and card:isKindOf("Treasure")) then
						return card:toString()
					end
				end
			end
		end
	end
	if need_card then
		for _,card in pairs(cards) do
			if not card:isKindOf("Jink") then
				return card:toString()
			end
		end
		for _,card in pairs(cards) do
			return card:toString()
		end
	end
	return "."
end

-----苏飞-----

sgs.ai_skill_invoke.lianpian = function(self, data)
	return true
end

-----黄权-----

sgs.ai_skill_playerchosen["dianhu"] = function(self, targets) 
    local source = self.player
	local room = source:getRoom()
	for _, p in sgs.qlist(targets) do 
		if p:hasShownOneGeneral() and (p:getKingdom() ~= source:getKingdom() or p:getRole() == "careerist") then
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
sgs.ai_skill_invoke.jianji = function(self, data)
	local data_str = data:toString()
	local value = data_str:split(":")
	local id = value[2]
	if (sgs.Sanguosha:getCard(id):isKindOf("Weapon") and not self.player:getWeapon()) or
	   (sgs.Sanguosha:getCard(id):isKindOf("Armor") and not self.player:getArmor()) or
	   (sgs.Sanguosha:getCard(id):isKindOf("DefensiveHorse") and not self.player:getDefensiveHorse()) or
	   (sgs.Sanguosha:getCard(id):isKindOf("OffensiveHorse") and not self.player:getOffensiveHorse()) or
	   (sgs.Sanguosha:getCard(id):isKindOf("Treasure") and not self.player:getTreasure()) then
	    return true
	end
    return false
end
sgs.ai_skill_use_func["#jianjiCard"] = function(card, use, self)
	local room = self.room
	local source = self.player
	local use_or_not = false
	for _, p in sgs.qlist(room:getOtherPlayers(player)) do 
		if p:hasShownOneGeneral() and (p:getKingdom() ~= source:getKingdom() or p:getRole() == "careerist") then
			use_or_not = true
			break
		end
	end
	if not use_or_not and not source:hasShownSkill("dianhu") then return false end
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
	if targets:length() == 1 then
		use.card = card
		if use.to then use.to = targets end
	end
end
sgs.ai_skill_use["@@jianji"]=function(self,prompt)
    self:updatePlayers()
	local card = prompt:split(":")
	if (sgs.Sanguosha:getCard(card[5]):isKindOf("Weapon") and not self.player:getWeapon()) or
	   (sgs.Sanguosha:getCard(card[5]):isKindOf("Armor") and not self.player:getArmor()) or
	   (sgs.Sanguosha:getCard(card[5]):isKindOf("DefensiveHorse") and not self.player:getDefensiveHorse()) or
	   (sgs.Sanguosha:getCard(card[5]):isKindOf("OffensiveHorse") and not self.player:getOffensiveHorse()) or
	   (sgs.Sanguosha:getCard(card[5]):isKindOf("Treasure") and not self.player:getTreasure()) then
	    return "" .. card[5]
	    --return ("%s:%s[%s:%s]=%d&jianji"):format(card[2],card[2], suit, number, card[5])
	end
	if card[2] == "slash" or card[2] == "fire_slash" or card[2] == "thunder_slash" then
	    self:sort(self.enemies, "defense")
		local targets = {}
		for _,enemy in ipairs(self.enemies) do
		    if (not self:slashProhibit(sgs.Sanguosha:getCard(card[5]), enemy)) and self.player:canSlash(enemy, sgs.Sanguosha:getCard(card[5])) then
				if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "peach" or card[2] == "threaten_emperor" or card[2] == "await_exhausted" or card[2] == "ex_nihilo" or card[2] == "amazing_grace" then
	    return "" .. card[5]
		--return ("%s:%s[%s:%s]=%d&jianji"):format(card[2],card[2], suit, number, card[5])
	end
	if card[2] == "savage_assault" or card[2] == "archery_attack"  then
		local is_weak = false
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do 
			if self:isFriend(p) then 
				if p:getHp() == 1 and self:getCardsNum("Peach") == 0 then 
					is_weak = true
				end
			end
		end
		if not is_weak then
			return "" .. card[5]
			--return ("%s:%s[%s:%s]=%d&jianji"):format(card[2],card[2], suit, number, card[5])
		end
	end
	if card[2] == "god_salvation" then
		local need_recover = false
		local friend_wounded = 0
		local enemy_wounded = 0
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do 
			if self:isFriend(p) then friend_wounded = friend_wounded + 1
			elseif self:isEnemy(p) and p:hasShownOneGeneral() then enemy_wounded = enemy_wounded + 1
			end
		end
		local base = 1 
		if self.player:getKingdom() == "wei" and self.player:getRole() ~= "careerist" then base = 2 end
		if friend_wounded >= enemy_wounded - 1 then
			need_recover = true
		end
		if need_recover then
			return "" .. card[5]
			--return ("%s:%s[%s:%s]=%d&jianji"):format(card[2],card[2], suit, number, card[5])
		end
	end
	if card[2] == "iron_chain" then
	    local situation_is_friend = false
	    for _, friend in ipairs(self.friends) do
		    if friend:isChained() and (not friend:isProhibited(friend, sgs.Sanguosha:getCard(card[5]))) then
			    situation_is_friend = true
		    end
		end
		if situation_is_friend then
		    local targets = {}
			for _, friend in ipairs(self.friends) do
			    if friend:isChained() and (not friend:isProhibited(friend, sgs.Sanguosha:getCard(card[5]))) then
			        if #targets >= 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
					table.insert(targets,friend:objectName())
		        end
			end
			if #targets > 0 then
				return card[5] .. "->" .. table.concat(targets,"+")
				--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
			else
			    return "."
			end
		else
		    local chained_enemy = 0
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
			    if enemy:isChained() then
				    chained_enemy = chained_enemy + 1
				end
				if (not enemy:isChained()) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
					if #targets >= 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if (#targets + chained_enemy) > 1 then
				return card[5] .. "->" .. table.concat(targets,"+")
				--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
			else
			    return "."
			end
	    end
	end
	if card[2] == "burning_camps" then
		if self:isEnemy(self.player:getNextAlive()) then
			return "" .. card[5]
			--return ("%s:%s[%s:%s]=%d&jianji"):format(card[2],card[2], suit, number, card[5])
		end
	end
	if card[2] == "befriend_attacking" then
	    self:sort(self.friends, "hp")
	    self:sort(self.enemies, "hp")
		local targets = {}
		for _, friend in ipairs(self.friends_noself) do
		    if (friend:getKingdom() ~= self.player:getKingdom()) and (not friend:isProhibited(friend, sgs.Sanguosha:getCard(card[5]))) then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,friend:objectName())
			end
		end
		if #targets == 0 then
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:isKongcheng()) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
					table.insert(targets,enemy:objectName())
				end
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "fire_attack" then
	    self:sort(self.enemies, "hp")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:isKongcheng()) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "dismantlement" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:isAllNude()) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "drowning" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if enemy:getEquips():length() > 0 then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "snatch" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:isAllNude()) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) and
			self.player:distanceTo(enemy) <= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, sgs.Sanguosha:getCard(card[5])) then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "collateral" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if enemy:getWeapon() and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
			    for _, tos in ipairs(self.enemies) do
				    if enemy:objectName() ~= tos:objectName() and
					enemy:canSlash(tos, sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)) and
					(not tos:isProhibited(tos, sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0))) then
				        table.insert(targets,enemy:objectName())
						table.insert(targets,tos:objectName())
						break
					end
				end
			end
		end
		if #targets > 1 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "duel" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
			    if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, sgs.Sanguosha:getCard(card[5])) then break end
				table.insert(targets,enemy:objectName())
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "supply_shortage" then
	    self:sort(self.enemies, "handcard")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:containsTrick("supply_shortage")) and
			(not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) and
			self.player:distanceTo(enemy) <= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, sgs.Sanguosha:getCard(card[5])) then
			    table.insert(targets,enemy:objectName())
				break
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	if card[2] == "indulgence" then
	    self:sort(self.enemies, "hp")
		local targets = {}
		for _, enemy in ipairs(self.enemies) do
		    if (not enemy:containsTrick("indulgence")) and (not enemy:isProhibited(enemy, sgs.Sanguosha:getCard(card[5]))) then
			    table.insert(targets,enemy:objectName())
				break
			end
		end
		if #targets > 0 then
			return card[5] .. "->" .. table.concat(targets,"+")
			--return ("%s:%s[%s:%s]=%d&jianji->%s"):format(card[2],card[2], suit, number, card[5], table.concat(targets,"+"))
		else
		    return "."
		end
	end
	return "."
end

-----群*马超-----

sgs.ai_skill_playerchosen["shichou"] = function(self, targets) 
    self:sort(self.enemies, "defense")
	local targets_list = {}
	local lost_hp = self.player:getMaxHp() - self.player:getHp()
	local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	for _,enemy in ipairs(self.enemies) do
		if (not self:slashProhibit(card, enemy)) and self.player:canSlash(enemy, card) and targets:contains(enemy) then
	self:log("?")
			table.insert(targets_list,enemy)
		end
		if #targets_list >= lost_hp then break end
	end
	self:log("!!!!!!"..#targets_list)
	if #targets_list > 0 then
	self:log("!!!!!!")
		return targets_list
	end
end

-----杀戮模式*郭嘉-----

sgs.ai_skill_invoke.shaluTiandu = function(self, data)
	return true
end
sgs.ai_skill_invoke.zhinang = function(self, data)
	return true
end
sgs.ai_skill_use["@@zhinang"]=function(self,prompt)
    self:updatePlayers()
	local cards = {}
	local ids = self.player:property("zhinangProp"):toString():split("+")
	for _, id in pairs(ids) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	self:sortByUseValue(cards, true)
	for _, card in pairs(cards) do 
		self:log("cardSuit:" .. card:getSuit())
		if (card:isKindOf("Weapon") and not self.player:getWeapon()) or
		   (card:isKindOf("Armor") and not self.player:getArmor()) or
		   (card:isKindOf("DefensiveHorse") and not self.player:getDefensiveHorse()) or
		   (card:isKindOf("OffensiveHorse") and not self.player:getOffensiveHorse()) or
		   (card:isKindOf("Treasure") and not self.player:getTreasure()) then
			return ("%s:%s[%s:%s]=%d&zhinang"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId())
		end
		if card:isKindOf("Slash") or card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") then
			self:sort(self.enemies, "defense")
			local targets = {}
			for _,enemy in ipairs(self.enemies) do
				if (not self:slashProhibit(card, enemy)) and self.player:canSlash(enemy, card) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Peach") or card:isKindOf("ThreatenEmperor") or card:isKindOf("AwaitExhausted") or card:isKindOf("ExNihilo") or card:isKindOf("AmazingGrace") then
			return ("%s:%s[%s:%s]=%d&zhinang"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId())
		end
		if card:isKindOf("SavageAssault") or card:isKindOf("ArcheryAttack")  then
			local is_weak = false
			for _, p in sgs.qlist(self.room:getAlivePlayers()) do 
				if self:isFriend(p) then 
					if p:getHp() == 1 and self:getCardsNum("Peach") == 0 then 
						is_weak = true
					end
				end
			end
			if not is_weak then
				return ("%s:%s[%s:%s]=%d&zhinang"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId())
			end
		end
		if card:isKindOf("GodSalvation") then
			local need_recover = false
			local friend_wounded = 0
			local enemy_wounded = 0
			for _, p in sgs.qlist(self.room:getAlivePlayers()) do 
				if self:isFriend(p) then friend_wounded = friend_wounded + 1
				elseif self:isEnemy(p) and p:hasShownOneGeneral() then enemy_wounded = enemy_wounded + 1
				end
			end
			local base = 1 
			if self.player:getKingdom() == "wei" and self.player:getRole() ~= "careerist" then base = 2 end
			if friend_wounded >= enemy_wounded - 1 then
				need_recover = true
			end
			if need_recover then
				return ("%s:%s[%s:%s]=%d&zhinang"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId())
			end
		end
		if card:isKindOf("IronChain") then
			local situation_is_friend = false
			for _, friend in ipairs(self.friends) do
				if friend:isChained() and (not friend:isProhibited(friend, card)) then
					situation_is_friend = true
				end
			end
			if situation_is_friend then
				local targets = {}
				for _, friend in ipairs(self.friends) do
					if friend:isChained() and (not friend:isProhibited(friend, card)) then
						if #targets >= 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
						table.insert(targets,friend:objectName())
					end
				end
				if #targets > 0 then
					return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
				else
					return "."
				end
			else
				local chained_enemy = 0
				local targets = {}
				for _, enemy in ipairs(self.enemies) do
					if enemy:isChained() then
						chained_enemy = chained_enemy + 1
					end
					if (not enemy:isChained()) and (not enemy:isProhibited(enemy, card)) then
						if #targets >= 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
						table.insert(targets,enemy:objectName())
					end
				end
				if (#targets + chained_enemy) > 1 then
					return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
				else
					return "."
				end
			end
		end
		if card:isKindOf("BurningCamps") then
			if self:isEnemy(self.player:getNextAlive()) then
				return ("%s:%s[%s:%s]=%d&zhinang"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId())
			end
		end
		if card:isKindOf("BefriendAttacking") then
			self:sort(self.friends, "hp")
			self:sort(self.enemies, "hp")
			local targets = {}
			for _, friend in ipairs(self.friends_noself) do
				if (friend:getKingdom() ~= self.player:getKingdom()) and (not friend:isProhibited(friend, card)) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,friend:objectName())
				end
			end
			if #targets == 0 then
				for _, enemy in ipairs(self.enemies) do
					if (not enemy:isKongcheng()) and (not enemy:isProhibited(enemy, card)) then
						if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
						table.insert(targets,enemy:objectName())
					end
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("FireAttack") then
			self:sort(self.enemies, "hp")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:isKongcheng()) and (not enemy:isProhibited(enemy, card)) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Dismantlement") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:isAllNude()) and (not enemy:isProhibited(enemy, card)) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Drowning") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if enemy:getEquips():length() > 0 then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Snatch") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:isAllNude()) and (not enemy:isProhibited(enemy, card)) and
				self.player:distanceTo(enemy) <= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, card) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Collateral") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if enemy:getWeapon() and (not enemy:isProhibited(enemy, card)) then
					for _, tos in ipairs(self.enemies) do
						if enemy:objectName() ~= tos:objectName() and
						enemy:canSlash(tos, sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)) and
						(not tos:isProhibited(tos, sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0))) then
							table.insert(targets,enemy:objectName())
							table.insert(targets,tos:objectName())
							break
						end
					end
				end
			end
			if #targets > 1 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Duel") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:isProhibited(enemy, card)) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("SupplyShortage") then
			self:sort(self.enemies, "handcard")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:containsTrick("supply_shortage")) and
				(not enemy:isProhibited(enemy, card)) and
				self.player:distanceTo(enemy) <= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, card) then
					table.insert(targets,enemy:objectName())
					break
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
		if card:isKindOf("Indulgence") then
			self:sort(self.enemies, "hp")
			local targets = {}
			for _, enemy in ipairs(self.enemies) do
				if (not enemy:containsTrick("indulgence")) and (not enemy:isProhibited(enemy, card)) then
					table.insert(targets,enemy:objectName())
					break
				end
			end
			if #targets > 0 then
				return ("%s:%s[%s:%s]=%d&zhinang->%s"):format(card:objectName(),card:objectName(), card:getSuit(), card:getNumber(), card:getId(), table.concat(targets,"+"))
			else
				return "."
			end
		end
	end
	return "."
end

-----姜维*魏-----

sgs.ai_skill_invoke.zhanxing = function(self, data)
	return true
end
sgs.ai_skill_invoke.kunfen = function(self, data)
	return true
end
function SmartAI:isMtiaoxinTarget(enemy)
	if not enemy then self.room:writeToConsole(debug.traceback()) return end
	if getCardsNum("Slash", enemy, self.player) < 1 and self.player:getHp() > 1 and not self:canHit(self.player, enemy)
		and not (enemy:hasWeapon("DoubleSword") and self.player:getGender() ~= enemy:getGender())
		then return true end
	if sgs.card_lack[enemy:objectName()]["Slash"] == 1
		or self:needLeiji(self.player, enemy)
		or self:getDamagedEffects(self.player, enemy, true)
		or self:needToLoseHp(self.player, enemy, true, true)
		then return true end
	if self.player:hasSkill("xiangle") and (enemy:getHandcardNum() < 2 or getKnownCard(enemy, self.player, "BasicCard") < 2
												and enemy:getHandcardNum() - getKnownNum(enemy, self.player) < 2) then return true end
	return false
end
Mtiaoxin_skill = {}
Mtiaoxin_skill.name = "Mtiaoxin"
table.insert(sgs.ai_skills, Mtiaoxin_skill)
Mtiaoxin_skill.getTurnUseCard = function(self,inclusive)
	if not self.player:hasUsed("#MtiaoxinCard") then
		return sgs.Card_Parse("#MtiaoxinCard:.:&Mtiaoxin")
	end
end

--[[sgs.ai_skill_use_func["#MtiaoxinCard"] = function(card, use, self)
	local room = self.room
	local source = self.player
	local use_or_not = false
	local friends_hands = 999
	local target_friend
	self:log("11")
	for _, p in pairs(self.friends) do
		local x = p:getHandcardNum()
		if x < friends_hands then
			friends_hands = x
			target_friend = p
		end
	end
	local targets = sgs.SPlayerList()
	targets:append(target_friend)
	if targets:length() == 1 then
		use.card = card
		if use.to then self:log("2") use.to = targets end
	end
end--]]
sgs.ai_skill_use_func["#MtiaoxinCard"] = function(card, use, self)
	local distance = use.defHorse and 1 or 0
	local targets = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy:distanceTo(self.player, distance) <= enemy:getAttackRange() and not self:doNotDiscard(enemy) and self:isMtiaoxinTarget(enemy) then
			table.insert(targets, enemy)
		end
	end
	if #targets == 0 then return end

	sgs.ai_use_priority.MtiaoxinCard = 8
	
	if not self.player:getArmor() and not self.player:isKongcheng() then
		for _, card in sgs.qlist(self.player:getCards("h")) do
			if card:isKindOf("Armor") and self:evaluateArmor(card) > 3 then
				sgs.ai_use_priority.MtiaoxinCard = 5.9
				break
			end
		end
	end
	self:sort(targets, "defenseSlash")
	local targets_list = sgs.SPlayerList()
	targets_list:append(targets[1])
	if targets_list:length() == 1 then
		use.card = card
		if use.to then use.to = targets_list end
	end
end

sgs.ai_skill_cardask["@tiaoxin-slash"] = function(self, data, pattern, target)
	if target then
		local cards = self:getCards("Slash")
		self:sortByUseValue(cards)
		for _, slash in ipairs(cards) do
			if self:isFriend(target) and self:slashIsEffective(slash, target) then
				if self:needLeiji(target, self.player) then return slash:toString() end
				if self:getDamagedEffects(target, self.player) then return slash:toString() end
				if self:needToLoseHp(target, self.player, nil, true) then return slash:toString() end
			end
			if not self:isFriend(target) and self:slashIsEffective(slash, target)
				and not self:getDamagedEffects(target, self.player, true) and not self:needLeiji(target, self.player) then
					return slash:toString()
			end
		end
		for _, slash in ipairs(cards) do
			if not self:isFriend(target) then
				if not self:needLeiji(target, self.player) and not self:getDamagedEffects(target, self.player, true) then return slash:toString() end
				if not self:slashIsEffective(slash, target) then return slash:toString() end
			end
		end
	end
	return "."
end

sgs.ai_card_intention.MtiaoxinCard = 80
sgs.ai_use_priority.MtiaoxinCard = 4

-----孙尚香*蜀-----

sgs.ai_skill_invoke.shaluXiaoji = function(self, data)
	return true
end
sgs.ai_skill_invoke.liangzhu = function(self, data)
	return true
end
sgs.ai_skill_choice["liangzhu"] = function(self, choices, data)
    local source = self.player
    local room = source:getRoom()
	local to = room:getCurrent()
	local choice_list = choices:split("+")
	if self:isFriend(to) then
		return choice_list[2]
	end
	return choice_list[1]
end
fanxiang_skill = {}
fanxiang_skill.name = "fanxiang"
table.insert(sgs.ai_skills, fanxiang_skill)
fanxiang_skill.getTurnUseCard = function(self,inclusive)
	if self.player:getMark("@fanxiangMark") > 0 and self.player:isWounded() then
		return sgs.Card_Parse("#fanxiangCard:.:&fanxiang")
	end
end
sgs.ai_skill_use_func["#fanxiangCard"] = function(card, use, self)
	local source = self.player
	local room = self.room
	local max_kingdom_num
	local kingdom_num = 0
	local best_to_choice
	local to
	for _, p in sgs.qlist(room:getOtherPlayers(source)) do 
		if p:getKingdom() == source:getKingdom() and source:getRole() ~= "careerist" then
			kingdom_num = kingdom_num + 1
			if kingdom_num > max_kingdom_num then
				max_kingdom_num = kingdom_num
				best_to_choice = to 
			end
		else
			to = p 
			kingdom_num = 0
		end
	end
	local targets_list = sgs.SPlayerList()
	if not best_to_choice and self:isWeak(source) then
		best_to_choice = room:getOtherPlayers(source):first()
	end
	if best_to_choice then targets_list:append(best_to_choice) end
	if targets_list:length() == 1 then
		use.card = card
		if use.to then use.to = targets_list end
	end
end

-----周公瑾-----

sgs.ai_skill_playerchosen.sashuang = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	local target = nil
	for _, p in pairs(self.friends) do
		if not p:hasShownGeneral2() then continue end
		local skill_list = p:getGeneral2():getSkillList(true, false)
		if skill_list:length() == 0 then return p end
		if skill_list:length() == 1 then
			local skill = skill_list:first()
			if skill:objectName() == "qixi" and not p:hasShownSkill("xiaoji") then return p end
			if skill:objectName() == "yicheng" and not p:hasShownSkill("xiaoji") then return p end
			if skill:objectName() == "yinghun" then return p end
			if skill:objectName() == "tianyi" then return p end
			if skill:objectName() == "buqu" and p:getHp() > 1 then return p end
			if skill:objectName() == "yinbing" then return p end
			if skill:objectName() == "keji" and #self.enemies > 2 then return p end
		end
		if skill_list:length() == 2 then
			for _, skill in sgs.qlist(skill_list) do 
				if skill:objectName() == "chouhai" or skill:objectName() == "kurou" or
					skill:objectName() == "niaoxiang" or skill:objectName() == "duanbing" 
						or skill:objectName() == "fenmin" then
					return p 
				end
				if skill:objectName() == "mingzhe" and p:getHandcardNum() < 2 then return p end
			end
		end
	end
	return source
end
sgs.ai_skill_invoke.sashuang = function(self, data)
	local source = self.player
	local room = source:getRoom()
	local skill_list = source:getGeneral2():getSkillList(true, false)
	if skill_list:length() == 0 then return true end
	if skill_list:length() == 1 then
		local skill = skill_list:first()
		if skill:objectName() == "qixi" and not source:hasShownSkill("xiaoji") then return true end
		if skill:objectName() == "yicheng" and not source:hasShownSkill("xiaoji") then return true end
		if skill:objectName() == "yinghun" then return true end
		if skill:objectName() == "tianyi" then return true end
		if skill:objectName() == "buqu" and source:getHp() > 1 then return true end
		if skill:objectName() == "yinbing" then return true end
		if skill:objectName() == "keji" and #self.enemies > 2 then return true end
	end
	if skill_list:length() == 2 then
		for _, skill in sgs.qlist(skill_list) do 
			if skill:objectName() == "chouhai" or skill:objectName() == "kurou" or
				skill:objectName() == "niaoxiang" or skill:objectName() == "duanbing" 
					or skill:objectName() == "fenmin" then
				return true
			end
			if skill:objectName() == "mingzhe" and source:getHandcardNum() < 3 then return true end
			if skill:objectName() == "zhijian" and #self.friends < 2 then return true end
			if skill:objectName() == "zhuiyi" and #self.friends < 2 then return true end
		end
	end
	return false
end
local xinji_skill = {}
xinji_skill.name = "xinji"
table.insert(sgs.ai_skills, xinji_skill)
xinji_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#xinjiCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#xinjiCard:.:&xinji")
end
sgs.ai_skill_use_func["#xinjiCard"] = function(card, use, self)
	local room = self.room
	self:sort(self.enemies, "handcard")
	local to
	for _, p in pairs(self.enemies) do 
		if p:objectName() == self.player:objectName() or p:getHandcardNum() <= 1 then continue end
		if p:hasShownOneGeneral() then 
			to = p 
			break
		end
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local need_card = nil
	for _, c in pairs(cards) do
		if not c:isKindOf("Peach") then
			need_card = c:getEffectiveId()
			break
		end
	end
	if to then
		use.card = sgs.Card_Parse("#xinjiCard:"..need_card..":&xinji")
		local targets = sgs.SPlayerList()
		targets:append(to)
		if use.to then use.to = targets end
	end
end	

-----诸葛孔明-----

sgs.ai_skill_invoke.qixing = function(self, data)
	return true
end
sgs.ai_skill_use["@@kuangfeng"] = function(self, prompt)
	local friendly_fire
	for _, friend in ipairs(self.friends_noself) do
		if friend:getMark("@gale") == 0 and self:damageIsEffective(friend, sgs.DamageStruct_Fire) and friend:faceUp() and not self:willSkipPlayPhase(friend)
			and (friend:hasSkill("huoji") or friend:hasWeapon("fan") or (friend:hasSkill("yeyan") and friend:getMark("@flame") > 0)) then
			friendly_fire = true
			break
		end
	end

	local is_chained = 0
	local target = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy:getMark("@gale") == 0 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
			if enemy:isChained() then
				is_chained = is_chained + 1
				table.insert(target, enemy)
			elseif enemy:hasArmorEffect("vine") then
				table.insert(target, 1, enemy)
				break
			end
		end
	end
	local usecard=false
	if friendly_fire and is_chained > 1 then usecard=true end
	self:sort(self.friends, "hp")
	if target[1] and not self:isWeak(self.friends[1]) then
		if target[1]:hasArmorEffect("vine") and friendly_fire then usecard = true end
	end
	if usecard then
		card_ids = self.player:getPile("stars")
		if cards:length() == 0 then return "." end
		local cards = idToCard(card_ids)
		self:sortByUseValue(cards, true)
		if not target[1] then table.insert(target,self.enemies[1]) end
		if target[1] then return "#kuangfengCard:" .. cards[1]:getId() .. ":&kuangfeng->" .. target[1]:objectName() else return "." end
	else
		return "."
	end
end
sgs.ai_card_intention.kuangfengCard = 80

sgs.ai_skill_use["@@dawu"] = function(self, prompt)
	self:sort(self.friends_noself, "hp")
	local targets = {}
	self:sort(self.friends_noself,"defense")
	for _, friend in ipairs(self.friends_noself) do
		if friend:getMark("@fog") == 0 and self:isWeak(friend) and not friend:hasSkill("buqu")
			and not (friend:hasSkill("hunzi") and friend:getMark("hunzi") == 0 and friend:getHp() > 1) then
				table.insert(targets, friend:objectName())
				break
		end
	end
	if self.player:getPile("stars"):length() > #targets and self:isWeak() then table.insert(targets, self.player:objectName()) end
	if #targets > 0 then
		local card_ids = sgs.QList2Table(self.player:getPile("stars"))
		local cards = idToCard(card_ids)
		self:sortByUseValue(cards, true)
		local length = #targets
		local card_needs = {}
		for _, card in pairs(cards) do
			if #card_needs >= length then break end
			table.insert(card_needs, card:getId())
		end
		return "#dawuCard:" .. table.concat(card_needs, "+") .. ":&dawu->" .. table.concat(targets, "+")
	end
	return "."
end

sgs.ai_card_intention.dawuCard = -70

sgs.ai_skill_use["@@xuming"] = function(self, prompt)
	local lost_hp = self.player:getMaxHp() - self.player:getHp()
	local length = self.player:getPile("stars"):length()
	if self:getCardsNum("Peach") > 0 then return "." end
	if length > 0 then
		local need_num = length < lost_hp and length or lost_hp
		local peach_num_to_escape_dying = 1 - self.player:getHp()
		if peach_num_to_escape_dying <= 0 then return "." end
		if need_num > peach_num_to_escape_dying + 1 then
			need_num = need_num - 1
		end
		if need_num > peach_num_to_escape_dying + 2 then
			need_num = need_num - 1
		end
		local card_ids = sgs.QList2Table(self.player:getPile("stars"))
		local cards = idToCard(card_ids)
		self:sortByUseValue(cards, true)
		local card_needs = {}
		for _, card in pairs(cards) do
			if #card_needs >= need_num then break end
			table.insert(card_needs, card:getId())
		end
		return "#xumingCard:" .. table.concat(card_needs, "+") .. ":&xuming"
	end
	return "."
end
sgs.ai_skill_movecards.qixing = function(self, upcards, downcards, min_num, max_num)
	local qixing_cards, hand_cards = sgs.IntList(), sgs.IntList()
	local upcards_copy = table.copyFrom(upcards)
	local downcards_copy = table.copyFrom(downcards)
	local number = #upcards_copy
	--self:sortByUseValue(upcards, true)
	for _, c in pairs(upcards_copy) do
		qixing_cards:append(c)
	end
	for _, c in pairs(downcards_copy) do
		hand_cards:append(c)
	end
	local up = {}
	local down = {}
	local handcard_list = {}
	local useValueSelect = true
	local keepValueSelect = true
	for _, c in sgs.qlist(qixing_cards) do
		for _, h in sgs.qlist(hand_cards) do
			if self.player:hasSkill("jizhi") then
				local pile_card = sgs.Sanguosha:getCard(c)
				if pile_card:isNDTrick() and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					keepValueSelect = false
					break
				end
			end
			if self.player:hasSkill("xiaoji") then
				local pile_card = sgs.Sanguosha:getCard(c)
				if pile_card:isKindOf("EquipCard") and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					keepValueSelect = false
					break
				end
			end
			if self:isWeak(self.player) and self:getCardsNum("Jink") + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 2 then
				local pile_card = sgs.Sanguosha:getCard(c)
				local h_card = sgs.Sanguosha:getCard(h)
				if keepValueSelect and (pile_card:isKindOf("Peach") or pile_card:isKindOf("Jink") or pile_card:isKindOf("Analeptic")) and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					keepValueSelect = false
					break
				end
				if self:getKeepValue(pile_card) > self:getKeepValue(h_card) and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					break
				end
			else 
				local pile_card = sgs.Sanguosha:getCard(c)
				local h_card = sgs.Sanguosha:getCard(h)
				if useValueSelect and self:getUseValue(pile_card) > self:getUseValue(h_card) and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					useValueSelect = false
					break
				elseif self:getKeepValue(pile_card) > self:getKeepValue(h_card) and table.contains(downcards_copy, h) then
					table.insert(downcards_copy, c)
					table.removeOne(upcards_copy, c)
					table.insert(upcards_copy, h)
					table.removeOne(downcards_copy, h)
					break
				end
			end
		end
	end
	self:log("upcards:" .. table.concat(upcards_copy, "+"))
	self:log("downcards:" .. table.concat(downcards_copy, "+"))
	if #downcards_copy ~= min_num then return upcards, downcards end
	return upcards_copy, downcards_copy
end

-----陆绩-----

sgs.ai_skill_invoke.huaijv = function(self, data)
	return true
end
sgs.ai_use_value.zhenglunCard = 15
sgs.ai_use_priority.zhenglunCard = 15
zhenglun_skill = {}
zhenglun_skill.name = "zhenglun"
table.insert(sgs.ai_skills, zhenglun_skill)
zhenglun_skill.getTurnUseCard = function(self,inclusive)
	if self.player:usedTimes("#zhenglunCard") < 2 then
		return sgs.Card_Parse("#zhenglunCard:.:&zhenglun")
	end
end
sgs.ai_skill_use_func["#zhenglunCard"] = function(card, use, self)
	local room = self.room
	local source = self.player
	self:sort(self.friends, "hp")
	local can_use = false
	if source:getHp() == 1 and source:getMark("@orange") > 0 then can_use = true end
	if source:getMaxHp() == 1 then return false end
	if not source:isWounded() and self:getCardsNum("Peach") >= source:getMaxHp() - 1 then can_use = true end
	if not source:isWounded() and #self.friends_noself > 0 and self.friends_noself[1]:isWounded() and source:hasSkill("jieyin") then can_use = true end
	if can_use then
		use.card = card
	end
end
sgs.ai_use_value.yiliCard = 15.2
sgs.ai_use_priority.yiliCard = 15.2
yili_skill = {}
yili_skill.name = "yili"
table.insert(sgs.ai_skills, yili_skill)
yili_skill.getTurnUseCard = function(self)
	if self.player:getMark("@orange") > 0 then
		return sgs.Card_Parse("#yiliCard:.:&yili")
	end
end
sgs.ai_skill_use_func["#yiliCard"] = function(card, use, self)
	local room = self.room
	local targets = sgs.SPlayerList()
	local source = self.player
	local num = source:getMark("@orange")
	if source:getHp() <= 2 then num = num - 1 end
	
	self:sort(self.friends_noself, "hp")
	
	for _, p in pairs(self.friends_noself) do
		if targets:length() >= num then break end
		if p:getMark("@orange") == 0 then
			targets:append(p)
		end
	end
	if targets:length() > 0 and targets:length() <= source:getMark("@orange") then
		use.card = card
		if use.to then use.to = targets end
	end
end

-----诸葛恪-----

sgs.ai_skill_invoke.aocai = function(self, data)
	return true
end
sgs.ai_skill_use["@@aocai"] = function(self, prompt)
	local source = self.player
	local patterns = source:property("aocaiPattern"):toString():split("+")
	if table.contains(patterns, "slash") then
		table.insert(patterns,"fire_slash")
		table.insert(patterns,"thunder_slash")
	end
	local card_need
	local aocaiCards = source:property("aocaiPileCard"):toString():split("+")
	for _, id in pairs(aocaiCards) do 
		local card = sgs.Sanguosha:getCard(id)
		if table.contains(patterns, sgs.Sanguosha:getCard(tonumber(id)):objectName()) then
			card_need = card:getEffectiveId()
			break
		end
	end
	if card_need then
	    local card_str = "#aocaiCard:"..card_need..":&aocai"
		return card_str	
	end
	return "."
end
sgs.ai_view_as.aocai = function(card, player, card_place)
	local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
	local names = pattern:split("+")
	if player:getPhase() ~= sgs.Player_NotActive then return nil end
	if table.contains(names, "slash") then
		table.insert(names,"fire_slash")
		table.insert(names,"thunder_slash")
	end
	local card_need
	local aocaiCards = player:property("aocaiPileCard"):toString():split("+")
	for _, id in pairs(aocaiCards) do 
		local card = sgs.Sanguosha:getCard(id)
		if table.contains(names, sgs.Sanguosha:getCard(tonumber(id)):objectName()) then
			card_need = card
			break
		end
	end
	if not card_need then
		local dying_player = player:getRoom():getCurrentDyingPlayer()
		if dying_player then
			local need_class = {}
			if dying_player:objectName() == player:objectName() then need_class = {"peach", "analeptic"}
			elseif dying_player:objectName() ~= player:objectName() then need_class = {"peach"} end
			for _, id in pairs(aocaiCards) do 
				local card = sgs.Sanguosha:getCard(id)
				if table.contains(need_class, sgs.Sanguosha:getCard(tonumber(id)):objectName()) then
					card_need = card
					break
				end
			end
		end
	end
	if card_need then
		local suit = card_need:getSuit()
		local number = card_need:getNumber()
		local card_id = card_need:getId()
		return ("%s:aocai[%s:%s]=%d&aocai"):format(card_need:objectName(), suit, number, card_id)
	end
end
local duwu_skill = {}
duwu_skill.name = "duwu"
table.insert(sgs.ai_skills, duwu_skill)
duwu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#duwuCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#duwuCard:.:&duwu")
end
sgs.ai_skill_use_func["#duwuCard"] = function(card, use, self)
	local room = self.room
	self:sort(self.enemies, "hp")
	local to
	local min_num = 999
	local handCardsNum = self.player:getHandcardNum() + self.player:getEquips():length()
	for _, p in pairs(self.enemies) do 
		if p:objectName() == self.player:objectName() or p:getHandcardNum() > 3 then continue end
		if not to and p:getHandcardNum() <= handCardsNum then 
			to = p
			min_num = p:getHandcardNum() + p:getHp()
		elseif to then
			if p:getHandcardNum() + p:getHp() < min_num then
				if p:getHandcardNum() == 0 or (p:getHandcardNum() > 0 and p:getHandcardNum() < handCardsNum - 2) then
					min_num = p:getHandcardNum() + p:getHp()
					to = p 
				end
			end
		end
	end
	local need_card = {}
	if to then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards,true)
		for _, c in pairs(cards) do
			if #need_card >= to:getHandcardNum() then break end
			if not c:isKindOf("Peach") then
				table.insert(need_card, c:getEffectiveId())
			end
		end
	end
	if to and #need_card == to:getHandcardNum() then
		local targets = sgs.SPlayerList()
		targets:append(to)
		if targets:length() == 1 then
			use.card = sgs.Card_Parse("#duwuCard:"..table.concat(need_card, "+")..":&duwu")
			if use.to then use.to = targets end
		end
	end
end	

-----严畯-----

sgs.ai_skill_invoke.guanchao = function(self, data)
	return true
end
sgs.ai_skill_use["@@xunxian"] = function(self, prompt)
	local source = self.player
	if #self.friends_noself == 0 then return "." end
	local card_ids = source:property("guanchaoProp"):toString():split("+")
	local card_id = source:property("xunxianProp"):toInt()
	local usecard = sgs.Sanguosha:getCard(card_id)
	local suit = usecard:getSuit()
	local cards = sgs.QList2Table(source:getCards("he"))
	self:sortByUseValue(cards,true)
	local will_be_discard = false
	local need_card = nil
	for _, card in pairs(cards) do
		if card:getSuit() == suit and card:getId() ~= card_id and table.contains(card_ids, tostring(card:getId())) then
			need_card = card:getEffectiveId()
			will_be_discard = true
			break
		end
	end
	if not need_card then
		for _, card in pairs(cards) do
			if card:getSuit() == suit and card:getId() ~= card_id then 
				if (not self:isWeak(source) and self.player:getHandcardNum() > self.player:getMaxCards()) or (self:isWeak(source) and (self:getCardsNum(usecard:objectName()) > 1 or (self:getCardsNum(usecard:objectName()) == 1 
					and self:getUseValue(usecard) < 5))) then
					need_card = card:getEffectiveId()
					break
				end
			end
		end
	end
	local target
	local candidate = self.friends_noself[1]
	self:sort(self.friends_noself, "hp")
	if will_be_discard then target = candidate
	else
		if not self:isWeak(source) or (self:isWeak(source) and (candidate:getHandcardNum() < source:getHandcardNum() or candidate:getHp() < source:getHp())) then
			target = candidate
		end
		if not target then
			if source:getHandcardNum() > source:getMaxCards() + 2 then
				target = candidate
			end
		end
	end
	if target and need_card then
	    local card_str = "#xunxianCard:"..need_card..":&xunxian->" .. target:objectName()
		return card_str	
	end
	return "."
end

-----夏侯渊-----

sgs.ai_skill_invoke.hubu = function(self, data)
	return true
end
sgs.ai_skill_use["@@hubu"] = function(self, prompt)
	self:updatePlayers()
	local ids = self.player:property("hubuProp"):toString():split("+")
	for _, id in pairs(ids) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Slash") then
			self:sort(self.enemies, "defense")
			local targets = {}
			for _,enemy in ipairs(self.enemies) do
				if (not self:slashProhibit(card, enemy)) and self.player:canSlash(enemy, card) then
					if #targets >= 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) then break end
					table.insert(targets,enemy:objectName())
				end
			end
			if #targets > 0 then
				return id .. "->" .. table.concat(targets,"+")
				--return ("%s:%s[%s:%s]=%d&hubu->%s"):format(card:objectName(), card:objectName(), card:getSuit(), card:getNumber(), id, table.concat(targets,"+"))
			else
				return "."
			end
		end
	end
end

-----徐盛-----

sgs.ai_skill_invoke.pojun = function(self, data)
	local to = data:toPlayer()
	if self:isEnemy(to) then return true 
	elseif self:isFriend(to) and to:hasShownSkill("xiaoji") then
		for _, card in sgs.qlist(to:getEquips()) do 
			if card:isRed() then 
				return true
			end
		end
	end
	return false
end
sgs.ai_skill_cardchosen["pojun"] = function(self, who, flags)
	local to = data:toPlayer()
	if to:getEquips():length() > 0 then
	    for _, card in sgs.qlist(to:getEquips()) do
		    if (self:isEnemy(to) and card:isBlack()) or (self:isFriend(to) and card:isRed()) then
			    return card:getEffectiveId()
			end
		end
	end
end

-----赵云-----

sgs.ai_skill_invoke.longhun = function(self, data)
	return true
end

-----张飞-----

sgs.ai_skill_invoke.tishen = function(self, data)
	return true
end

-----夏侯惇-----

function hasEquipInHand(player, equip)
	for _, card in sgs.qlist(player:getEquips()) do 
		if card:isKindOf(equip) then
			return true
		end
	end
	return false
end
sgs.ai_skill_use["@@qingjian"] = function(self, prompt)
	local source = self.player
	local room = self.room
	if #self.friends_noself == 0 then return "." end
	local card_ids = source:property("qingjianProp"):toString():split("+")
	local need_cards = {}
	if source:objectName() == room:getCurrent():objectName() and source:isSkipped(sgs.Player_Play) and not source:hasSkill("qiaobian") and source:getMaxCards() - source:getHandcardNum() >= #card_ids then need_cards = card_ids
	elseif source:getPhase() ~= sgs.Player_NotActive then
		local slash_num = 1
		local jink_num = 1
		local analeptic_num = 1
		for _, id in pairs(card_ids) do 
			local card = sgs.Sanguosha:getCard(id)
			local slash_condition = card:isKindOf("Slash") and self:getCardsNum("Slash") > slash_num
			local peach_condition = card:isKindOf("Peach") and not source:isWounded()
			local jink_condition = card:isKindOf("Jink") and self:getCardsNum("Jink") > jink_num
			local analeptic_condition = card:isKindOf("Analeptic") and self:getCardsNum("Analeptic") > analeptic_num
			local nullification_condition = card:isKindOf("Nullification")
			local snatch_and_supply_shortage_condition = (card:isKindOf("Snatch") or card:isKindOf("SupplyShortage"))
			local equip_condition = (card:isKindOf("Weapon") and (source:getEquip(0) or hasEquipInHand(source, "Weapon"))) 
				or (card:isKindOf("Armor") and (source:getEquip(1) or hasEquipInHand(source, "Armor")))
				or (card:isKindOf("DefensiveHorse") and (source:getEquip(2) or hasEquipInHand(source, "OffensiveHorse"))) 
				or (card:isKindOf("OffensiveHorse") and (source:getEquip(3) or hasEquipInHand(source, "OffensiveHorse"))) 
				or (card:isKindOf("Treasure") and (source:getEquip(4) or hasEquipInHand(source, "Treasure")))
			for _, p in pairs(self.enemies) do
				local has_target = false
				if source:distanceTo(p) == 1 then
					has_target = true
				end
				if has_target then
					snatch_and_supply_shortage_condition = false
				end
			end
			local need_help = false
			for _, p in pairs(self.friends_noself) do 
				if self:isWeak(p) and p:getHandcardNum() < 3 then
					need_help = true
				end
			end
			if not need_help then
				peach_condition = false
				jink_condition = jink_condition and self:getCardsNum("Jink") > 2
			end
			if source:getHp() <= 1 and not source:isSkipped(sgs.Player_Play) then peach_condition = false end
			if source:isSkipped(sgs.Player_Play) and source:getMaxCards() - source:getHandcardNum() >= #card_ids then
				jink_condition = false
				peach_condition = card:isKindOf("Peach")
			    snatch_and_supply_shortage_condition = (card:isKindOf("Snatch") or card:isKindOf("SupplyShortage"))
			    slash_condition = card:isKindOf("Slash")
			end
			if slash_condition or peach_condition or jink_condition or analeptic_condition or nullification_condition or snatch_and_supply_shortage_condition or equip_condition then
				table.insert(need_cards, id)
				if card:isKindOf("Slash") then slash_num = slash_num + 1
				elseif card:isKindOf("Jink") then jink_num = jink_num + 1
				elseif card:isKindOf("Analeptic") then analeptic_num = analeptic_num + 1
				end
			end
		end
	else
		local slash_num = 1
		local jink_num = 1
		local peach_num = 1
		local analeptic_num = 1
		for _, id in pairs(card_ids) do 
			local card = sgs.Sanguosha:getCard(id)
			local slash_condition = card:isKindOf("Slash") and self:getCardsNum("Slash") > slash_num
			local peach_condition = card:isKindOf("Peach") and source:getHp() > peach_num
			local jink_condition = card:isKindOf("Jink") and self:getCardsNum("Jink") > jink_num
			local analeptic_condition = card:isKindOf("Analeptic") and self:getCardsNum("Analeptic") > analeptic_num
			local equip_condition = (card:isKindOf("Weapon") and (source:getEquip(0) or hasEquipInHand(source, "Weapon"))) 
				or (card:isKindOf("Armor") and (source:getEquip(1) or hasEquipInHand(source, "Armor")))
				or (card:isKindOf("DefensiveHorse") and (source:getEquip(2) or hasEquipInHand(source, "OffensiveHorse"))) 
				or (card:isKindOf("OffensiveHorse") and (source:getEquip(3) or hasEquipInHand(source, "OffensiveHorse"))) 
				or (card:isKindOf("Treasure") and (source:getEquip(4) or hasEquipInHand(source, "Treasure")))
			local other_condition = not card:isKindOf("Slash") and not card:isKindOf("Peach") and not card:isKindOf("Jink") and not card:isKindOf("Analeptic") and not card:isKindOf("EquipCard")
			local need_help = false
			for _, p in pairs(self.friends_noself) do 
				if self:isWeak(p) and p:getHandcardNum() < 3 then
					need_help = true
				end
			end
			if not need_help then
				peach_condition = false
				jink_condition = jink_condition and self:getCardsNum("Jink") > 2
			end
			if need_help and source:getHp() > 1 then analeptic_condition = card:isKindOf("Analeptic") end
			if slash_condition or peach_condition or jink_condition or analeptic_condition or other_condition or equip_condition then
				table.insert(need_cards, id)
				if card:isKindOf("Slash") then slash_num = slash_num + 1
				elseif card:isKindOf("Jink") then jink_num = jink_num + 1
				elseif card:isKindOf("Peach") then peach_num = peach_num + 1
				elseif card:isKindOf("Analeptic") then analeptic_num = analeptic_num + 1
				end
			end
		end
	end
	local target
	local candidate = self.friends_noself[1]
	self:sort(self.friends_noself, "hp")
	if not self:isWeak(source) or (self:isWeak(source) and (candidate:getHandcardNum() <= source:getHandcardNum() or candidate:getHp() < source:getHp())) then
		target = candidate
	end
	if not target then
		if source:getHandcardNum() > source:getMaxCards() + 1 then
			target = candidate
		end
	end
	if target and #need_cards > 0 then
	    local card_str = "#qingjianCard:".. table.concat(need_cards, "+") ..":&qingjian->" .. target:objectName()
		return card_str	
	end
	return "."
end

-----刘备——----

sgs.ai_skill_invoke.renwangSlash = function(self, data)
	local to = self.room:getCurrent()
	if self:isFriend(to) then return false end
	local card = sgs.Sanguosha:getCard(self.player:getPile("renwang"):first())
	if self.player:getEquip(0) and self.player:getEquip(0):isKindOf("QinggangSword") then return true end
	if to:getEquip(1) and to:getEquip(1):isKindOf("RenwangShield") and card:isBlack() then return false end
	if to:getEquip(1) and to:getEquip(1):isKindOf("Vine") and not card:isKindOf("FireSlash") and not card:isKindOf("ThunderSlash") then return false end
	if to:getEquip(1) and to:getEquip(1):isKindOf("PeaceSpell") and card:isKindOf("FireSlash") then return false end
	if to:getEquip(1) and to:getEquip(1):isKindOf("IronArmor") and card:isKindOf("FireSlash") then return false end
	return true
end
sgs.ai_skill_invoke.renwangPeach = function(self, data)
	local to = self.player:property("renwangPeachProp"):toPlayer()
	return self:isFriend(to)
end
sgs.ai_skill_invoke.renwangAnaleptic = function(self, data)
	local to = self.player:property("renwangAnalepticProp"):toPlayer()
	return self:isEnemy(to)
end
sgs.ai_skill_invoke.renwangOther = function(self, data)
	local to = self.room:getCurrent()
	local has_Indulgence = false
	for _, card in sgs.qlist(to:getJudgingArea()) do 
		if card:isKindOf("Indulgence") then
			has_Indulgence = true
		end
	end
	return to:objectName() == self.player:objectName() or (self:isFriend(to) and not has_Indulgence)
end
sgs.ai_skill_cardask["@renwang_invoke"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		if card:isKindOf("Peach") then
			for _, p in pairs(self.friends) do 
				if p:getHp() <= 2 then
					return card:toString()
				end
			end
		end
	end
	for _,card in pairs(cards) do
		if card:isKindOf("Slash") or card:isKindOf("Jink") or (card:isKindOf("Analeptic") and self.player:getHp() > 1) then 
			return card:toString()
		end
	end
	for _,card in pairs(cards) do
		if not card:isKindOf("Peach") and not card:isKindOf("Analeptic") then
			return card:toString()
		end
	end
	return nil
end

-----全琮-----

sgs.ai_skill_playerchosen.yaoming = function(self, targets)
	self:sort(self.friends_noself, "hp")
	self:sort(self.enemies, "hp")
	local num = self.player:getMark("yaomingMark")
	local friend = self.friends_noself[1]
	local enemy = self.enemies[1]
	local toFriend = false
	if not friend then toFriend = false end
	if not enemy then toFriend = true end
	if friend and enemy then
		if enemy:getHandcardNum() + enemy:getEquips():length() < num + 2 then toFriend = true
		elseif enemy:getHandcardNum() < friend:getHandcardNum() and enemy:getHp() <= friend:getHp() then
			toFriend = false
		else
			toFriend = true
		end
	end
	if toFriend then
		return friend
	else
		return enemy
	end
end
sgs.ai_skill_choice["yaoming"] = function(self, choices, data)
    local to = self.player:property("yaomingProp"):toPlayer()
	if self:isFriend(to) then
		return "yaoming_draw"
	else
		return "yaoming_discard"
	end
end

-----王平-----

sgs.ai_skill_invoke.binglve = function(self, data)
	return true
end
sgs.ai_skill_exchange.binglve = function(self, pattern, max_num, min_num, expand_pile)
	local room = self.room
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,c in ipairs(cards) do
		if not (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then 
			if room:getCardPlace(c:getId()) == sgs.Player_PlaceEquip then
				if c:isKindOf("Vine") or (not c:isKindOf("Armor") and not c:isKindOf("DefensiveHorse")) then
					table.insert(to_discard, c:getEffectiveId())
				end
			else
				table.insert(to_discard, c:getEffectiveId())
			end
		end
		if #to_discard >= min_num then break end
	end
	return to_discard
end
sgs.ai_skill_playerchosen.feijun = function(self, targets)
	self:sort(self.friends_noself, "hp")
	self:sort(self.enemies, "hp")
	local friend 
	local enemy
	for _, p in pairs(self.friends_noself) do
		if targets:contains(p) then
			friend = p
		end
	end
	for _, p in pairs(self.enemies) do
		if targets:contains(p) then
			enemy = p
		end
	end
	local toFriend = false
	local data = self.player:property("feijunDataProp")
	local use = data:toCardUse()
	if use.card:isKindOf("Peach") or use.card:isKindOf("ExNihilo") or use.card:isKindOf("BefriendAttacking") or use.card:isKindOf("AwaitExhausted") or use.card:isKindOf("Analeptic") or use.card:isKindOf("AllianceFeast") then
		toFriend = true
	end
	if toFriend and friend then
		return friend
	elseif not toFriend and enemy then
		return enemy
	end
	return nil
end

-----张梁-----
function getPossibleCards(number, cards, bags, card_num, result_table, card_id)
	if number < 0 then
		return nil 
	elseif card_num <= 0 then
		return nil
	elseif number == 0 then
		table.insert(bags, card_id)
		result_table[1] = bags
	else
	--self:log("number:"..number..",card_num:"..card_num..",card_id:"..card_id)
		--不减去这个数
		getPossibleCards(number, cards, bags, card_num - 1, result_table, card_id)
		--减去这个数
		local last_card = cards[card_num]
		local last_num = sgs.Sanguosha:getCard(last_card):getNumber()
		local new_bags = table.copyFrom(bags)
		table.insert(new_bags, last_card)
		getPossibleCards(number - last_num, cards, new_bags, card_num - 1, result_table, card_id)
	end
end
function sortTable(data)
	for i = 1, #data, 1 do 
		local changed = false
		for j = i + 1, #data, 1 do 
			if sgs.Sanguosha:getCard(data[j - 1]):getNumber() > sgs.Sanguosha:getCard(data[j]):getNumber() then
				local card = data[j - 1]
				data[j - 1] = data[j]
				data[j] = card
				changed = true
			end
			if not changed then
				break
			end
		end
	end
end
sgs.ai_skill_invoke.jijun = function(self, data)
	return true
end
sgs.ai_skill_use["@@fangtong"] = function(self, prompt)
	self:sort(self.enemies, "hp")
	local enemy1 = self.enemies[1]
	local enemy2 = self.enemies[2]
	if not enemy1 then return "." end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local sortedPile = {}
	for _, id in sgs.qlist(self.player:getPile("jun")) do 
		table.insert(sortedPile, id)
	end
	sortTable(sortedPile)
	local number = 0
	local the_cards = {}
	local maxNum = 10   --最多只考虑十张牌
	for _, id in pairs(sortedPile) do
		maxNum = maxNum - 1
		table.insert(the_cards, id)
		if maxNum <= 0 then
			break
		end
	end
	local possible_cards = {}
	local bags = {}
	for _,c in ipairs(cards) do
		--table.insert(the_cards, c:getId())
		--sortTable(the_cards)
		getPossibleCards(36-c:getNumber(), the_cards, bags, #the_cards, possible_cards, c:getId())
		--table.removeOne(the_cards, c:getId())
	end
	
	if #possible_cards == 0 then
		for _,c in ipairs(cards) do
			--table.insert(the_cards, c:getId())
			--sortTable(the_cards)
			getPossibleCards(24-c:getNumber(), the_cards, bags, #the_cards, possible_cards, c:getId())
			--table.removeOne(the_cards, c:getId())
		end
	end
	
	if #possible_cards == 0 then return "." end
	local totoalNum = 0
	for _, id in pairs(possible_cards[1]) do 
		totoalNum = totoalNum + sgs.Sanguosha:getCard(id):getNumber()
	end
	self:log("totalNumberList:"..table.concat(possible_cards[1], "+"))
	self:log("totalNumber:"..totoalNum)
	if totoalNum ~= 24 and totoalNum ~= 36 then self:log("不等于，算法有误") return "." end
	
	local targets_list = {}
	if totoalNum == 24 then
		table.insert(targets_list, enemy1:objectName())
	elseif totoalNum == 36 then
		if enemy2 and enemy1:getHp() == 1 and enemy2:getHp() == 1 then
			table.insert(targets_list, enemy1:objectName())
			table.insert(targets_list, enemy2:objectName())
		else
			table.insert(targets_list, enemy1:objectName())
		end
	end
	self:log("zzzzzz")
	
	if #targets_list > 0 and #possible_cards > 0 then
	    local card_str = "#fangtongCard:"..table.concat(possible_cards[1], "+")..":&fangtong->"..table.concat(targets_list, "+")
		return card_str	
	end
	return "."
end

-----王粲-----
sgs.ai_skill_invoke.qiai = function(self, data)
	return true
end
sgs.ai_skill_invoke.denglou = function(self, data)
	return true
end

-----杜畿-----
sgs.ai_skill_invoke.andong = function(self, data)
	return true
end
sgs.ai_skill_choice["andong"] = function(self, choices, data)
	local damage = data:toDamage()
	if self:isEnemy(damage.to) then
		--[[if self:getCardsNum("Peach") > 0 and damage.to:getHp() > damage.damage then
			return "andongY"
		else--]]
			return "andongN"
		--end
	end
	return "andongY"
end
sgs.ai_skill_use["@@andong"] = function(self, prompt)
	self:updatePlayers()
	local ids = self.player:property("andongProp"):toString():split("+")
	if #ids == 0 then return nil end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Peach") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("ExNihilo") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Analeptic") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Jink") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("BefriendAttacking") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Snatch") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Indulgence") then return "#andongCard:"..id..":&andong" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Slash") then return "#andongCard:"..id..":&andong" end end
	return "#andongCard:"..ids[1]..":&andong"
end
sgs.ai_skill_use["@@yingshiGet"] = function(self, prompt)
	self:updatePlayers()
	local ids = self.player:property("yingshiGetProp"):toString():split("+")
	if #ids == 0 then return nil end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Peach") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("ExNihilo") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Analeptic") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Jink") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("BefriendAttacking") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Snatch") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Indulgence") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	for _, id in pairs(ids) do if sgs.Sanguosha:getCard(tonumber(id)):isKindOf("Slash") then return "#yingshiGetCard:"..id..":&yingshiGet" end end
	return "#yingshiGetCard:"..ids[1]..":&yingshiGet"
end
sgs.ai_skill_playerchosen.yingshi = function(self, targets)
	self:sort(self.enemies, "hp")
	local to = {}
	local num = math.random(1, 2)
	if #self.enemies == 0 then return nil
	elseif #self.enemies == 1 then num = 1 end
	for i = 1, num, 1 do 
		table.insert(to,self.enemies[i])
	end
	return to
end

-----满宠——----
local junxing_skill = {}
junxing_skill.name = "junxing"
table.insert(sgs.ai_skills, junxing_skill)
junxing_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:isKongcheng() or self.player:hasUsed("#junxingCard") then return nil end
	return sgs.Card_Parse("#junxingCard:.:&junxing")
end
sgs.ai_skill_use_func["#junxingCard"] = function(card, use, self)
	-- find enough cards
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())
	local use_slash_num = 0
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:isKindOf("Slash") then
			local will_use = false
			if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
				local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
					will_use = true
					use_slash_num = use_slash_num + 1
				end
			end
			if not will_use then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local num = self:getCardsNum("Jink") - 1
	if self.player:getArmor() then num = num + 1 end
	if num > 0 then
		for _, card in ipairs(cards) do
			if card:isKindOf("Jink") and num > 0 then
				table.insert(unpreferedCards, card:getId())
				num = num - 1
			end
		end
	end
	for _, card in ipairs(cards) do
		if card:isKindOf("EquipCard") then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	for _, card in ipairs(cards) do
		if card:isNDTrick() or card:isKindOf("Lightning") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end
	if #use_cards == 0 then return end

	-- to friends
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if not self:toTurnOver(friend, #use_cards, "junxing") then
			use.card = sgs.Card_Parse("#junxingCard:" .. table.concat(use_cards, "+") .. ":&junxing")
			if use.to then use.to:append(friend) end
			return
		end
	end
	if #use_cards > 3 then
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.notActive_cardneed_skill) and not friend:hasShownSkills(sgs.Active_cardneed_skill) and not friend:hasShownSkills(sgs.Active_priority_skill) and self:getOverflow(friend) <= 2 then
				use.card = sgs.Card_Parse("#junxingCard:" .. table.concat(use_cards, "+") .. ":&junxing")
				if use.to then use.to:append(friend) end
				return
			end
		end
	end

	-- to enemies
	local basic, trick, equip
	for _, id in ipairs(use_cards) do
		local typeid = sgs.Sanguosha:getEngineCard(id):getTypeId()
		if not basic and typeid == sgs.Card_TypeBasic then basic = id
		elseif not trick and typeid == sgs.Card_TypeTrick then trick = id
		elseif not equip and typeid == sgs.Card_TypeEquip then equip = id
		end
		if basic and trick and equip then break end
	end
	self:sort(self.enemies, "handcard")
	local other_enemy
	for _, enemy in ipairs(self.enemies) do
		local id = nil
		if self:toTurnOver(enemy, 1) then
			if getKnownCard(enemy, self.player, "BasicCard") == 0 then id = equip or trick end
			if not id and getKnownCard(enemy, self.player, "TrickCard") == 0 then id = equip or basic end
			if not id and getKnownCard(enemy, self.player, "EquipCard") == 0 then id = trick or basic end
			if id then
				use.card = sgs.Card_Parse("#junxingCard:" .. id .. ":&junxing")
				if use.to then use.to:append(enemy) end
				return
			elseif not other_enemy then
				other_enemy = enemy
			end
		end
	end
	if other_enemy then
		use.card = sgs.Card_Parse("#junxingCard:" .. use_cards[1] .. ":&junxing")
		if use.to then use.to:append(other_enemy) end
		return
	end
	
	for _, friend in ipairs(self.friends_noself) do
		if friend:hasShownSkill("Dawu") then
			local fog_count = 0
			for _,friend2 in ipairs(self.friends) do
				if friend2:getMark("@fog_ShenZhuGeLiang") > 0 then
					fog_count = fog_count + (friend2:isWeak() and 2 or 1)
				end
			end
			if fog_count >= 2 then
				use.card = sgs.Card_Parse("#junxingCard:" .. table.concat(use_cards, "+") .. ":&junxing")
				if use.to then use.to:append(friend) end
				return
			end
		end
	end
end
sgs.ai_use_priority.junxingCard = 1.2
sgs.ai_card_intention["#junxingCard"] = function(self, card, from, tos)
	local to = tos[1]
	if not to:faceUp() then
		sgs.updateIntention(from, to, -80)
	else
		if to:getHandcardNum() <= 1 and card:subcardsLength() >= 3 then
			sgs.updateIntention(from, to, -40)
		else
			sgs.updateIntention(from, to, 80)
		end
	end
end
sgs.ai_skill_cardask["@junxing-discard"] = function(self, data, pattern)
	local manchong = sgs.findPlayerByShownSkillName("junxing")
	if manchong and self:isFriend(manchong) then return "." end

	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end
sgs.ai_skill_cardask["@yuce-show"] = function(self, data)
	if not self:willShowForMasochism() then return false end
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if not damage.from or damage.from:isDead() then return "." end
	if self:isFriend(damage.from) then return "$" .. self.player:handCards():first() end
	local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), damage.from:objectName())
	local types = { sgs.Card_TypeBasic, sgs.Card_TypeEquip, sgs.Card_TypeTrick }
	for _, card in sgs.qlist(damage.from:getHandcards()) do
		if card:hasFlag("visible") or card:hasFlag(flag) then
			table.removeOne(types, card:getTypeId())
		end
		if #types == 0 then break end
	end
	if #types == 0 then types = { sgs.Card_TypeBasic } end
	for _, card in sgs.qlist(self.player:getHandcards()) do
		for _, cardtype in ipairs(types) do
			if card:getTypeId() == cardtype then return "$" .. card:getEffectiveId() end
		end
	end
	return "$" .. self.player:handCards():first()
end
sgs.ai_skill_cardask["@yuce-discard"] = function(self, data, pattern, target)
	if target and self:isFriend(target) then return "." end
	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end
sgs.ai_damage_effect.yuce = function(self, damage)
	local to = damage.to
	local from = damage.from
	local damagecount = damage.damage or 1
	if to:hasShownSkill("yuce") and not to:isKongcheng() and to:getHp() > 1 then
		if not from then return true
        elseif self:isFriend(to, from) then return false
        else
            if from:objectName() ~= self.player:objectName() then
                if from:getHandcardNum() <= 2 then return (damagecount > 1) end
            else
                if ((getKnownCard(to, self.player, "TrickCard", false, "h") + getKnownCard(to, self.player, "EquipCard", false, "h") < to:getHandcardNum())
                    and (getCardsNum("TrickCard", from, self.player) + getCardsNum("EquipCard", from, self.player) < 1))
                    or getCardsNum("BasicCard", from, self.player) < 2 then  --注意国战getCardsNum不包括装备
                    return (damagecount > 1)  --原来是return false
                end
            end
        end
    end
	return true
end
function sgs.ai_cardneed.yuce(to, card)
	return to:getCards("h"):length() == 0
end

-----张嶷
function SmartAI:findPlayerToDamage(damage, source, nature, targets, include_self, base_value, return_table)  --仅出现于怃戎，暂且先放到这里（日后必有重谢）
    damage = damage or 1
    nature = nature or sgs.DamageStruct_Normal
    source = source or nil
    base_value = base_value or 0
    if include_self == nil then include_self = true    end
    
    local victims
    if targets then
        victims = targets
    else
        victims = include_self and self.room:getOtherPlayers(self.player) or self.room:getAlivePlayers()
    end
    if type(victims) ~= "table" then
        victims = sgs.QList2Table(victims)
    end
    if #victims == 0 then
        if return_table then
            return {}
        else
            return nil
        end
    end
    
    --[[local JinXuanDi = self.room:findPlayerBySkillName("wuling")
    local windEffect = ( JinXuanDi and JinXuanDi:getMark("@wind") > 0 )
    if windEffect and nature == sgs.DamageStruct_Fire then
        damage = damage + 1
    end
    local thunderEffect = ( JinXuanDi and JinXuanDi:getMark("@thunder") > 0 )
    if thunderEffect and nature == sgs.DamageStruct_Thunder then
        damage = damage + 1
    end]]
    
    local isSourceFriend = ( source and self:isFriend(source) )
    local isSourceEnemy = ( source and self:isEnemy(source) )
    
    local function getDamageValue(target, self_only)
        local value = 0
        local isFriend = self:isFriend(target)
        local isEnemy = self:isEnemy(target)
        --local careLord = ( self.role == "renegade" and target:isLord() and self.room:alivePlayerCount() > 2 )
		local willInvokeBreastplate = false
        local count = damage
        if self:damageIsEffective(target, nature, source) then
			--todo：绝情
            --[[if target:hasSkill("chouhai") and target:isKongcheng() then
                count = count + 1
            end]]
            if nature == sgs.DamageStruct_Fire then  --todo：雷电伤害（助祭）
                if target:getMark("@gale") > 0 then
                    count = count + 1
                end
                if target:getMark("@gale_ShenZhuGeLiang") > 0 then
                    count = count + 1
                end
                if target:hasShownSkill("Ranshang") then
                    count = count + 1
                end
			end
			local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
			if jiaren_zidan and jiaren_zidan:isFriendWith(target) then
				count = 1
			end
			if nature == sgs.DamageStruct_Fire then
                if target:hasArmorEffect("Vine") then
                    count = count + 1
                --[[elseif target:hasArmorEffect("bossmanjia") then
                    count = count + 1]]
                end
            end
            if count > 1 and target:hasArmorEffect("silver_lion") then
                count = 1
            end
        else
            count = 0
        end
        if count > 0 then
            value = value + count * 20 --设1牌价值为10，且1体力价值2牌，1回合价值2.5牌，下同
            local hp = target:getHp()
            local deathFlag = false
            if count >= hp then
                deathFlag = ( count >= hp + self:getAllPeachNum(target) )
            end
            if deathFlag then
                value = value + 500
            else
                --if hp >= getBestHp(target) + count then
				if hp >= target:getMaxHp() + count then
                    value = value - 2
                end
                if self:needToLoseHp(target, source) then
                    value = value - 5
                end
                if self:isWeak(target) then
                    value = value + 15
                else
                    value = value + 12 - sgs.getDefense(target)
                end
                if hp <= count then
                    if target:hasShownSkill("Jiushi") and target:faceUp() then
                        value = value + 25
                    end
                end
                if self:getDamagedEffects(target, source) then  --懒得考虑其他卖血流了，直接这样吧
                    if target:hasShownSkill("yiji") then
                        value = value - 20 * count
                    end
                    if target:hasShownSkill("YijiLB") then
                        value = value - 10 * count
                    end
                    if target:hasShownSkill("jieming") then
                        local chaofeng = self:getJiemingChaofeng(target)
                        if chaofeng > 0 then --chaofeng = 5 - draw * 2, draw < 2
                            value = value - ( 5 - chaofeng ) * 5
                        else --chaofeng = - draw * 2, draw >= 2
                            value = value + chaofeng * 5
                        end
                    end
                    if target:hasShownSkill("Guixin") then
                        value = value + 25
                        local others = self.room:getOtherPlayers(target)
                        local x = 0
                        for _,p in sgs.qlist(others) do
                            if not p:isAllNude() then
                                x = x + 1
                                if self:isFriend(p, target) then
                                    if not p:getJudgingArea():isEmpty() then
                                        value = value - 5
                                    end
                                elseif p:isNude() then
                                    value = value + 5
                                end
                            end
                        end
                        --if not hasManjuanEffect(target) then
                            value = value - x * 10
                        --end
                    end
                    if target:hasShownSkill("Chengxiang") then
                        value = value - 15
                    end
                    --[[if target:hasShownSkill("noschengxiang") then
                        value = value - 15
                    end]]
                end
            end
            if isFriend then
                value = - value
            elseif not isEnemy then
                value = value / 2
            end
            if self_only or nature == sgs.DamageStruct_Normal then
            elseif target:isChained() then
                local others = self.room:getOtherPlayers(target)
                for _,p in sgs.qlist(others) do
                    if p:isChained() then
                        local v = values[p:objectName()] or getDamageValue(p, true)
                        value = value + v
                    end
                end
            end
            if self:cantbeHurt(target, source, count) then
                value = value - 800
            end
            --[[if deathFlag and careLord then
                value = value - 1000
            end]]
        end
        return value
    end
    
    local values = {}
    for _,victim in ipairs(victims) do
        values[victim:objectName()] = getDamageValue(victim, false) or 0
    end
    
    local compare_func = function(a, b)
        local valueA = values[a:objectName()] or 0
        local valueB = values[b:objectName()] or 0
        --return valueA >= valueB  --等于时交换会导致不稳定排序，从而崩
		if valueA == valueB then
			return sgs.getDefense(a) < sgs.getDefense(b)
		else
			return valueA > valueB
		end
    end
    
    table.sort(victims, compare_func)
    
    if return_table then
        local result = {}
        for _,victim in ipairs(victims) do
            if values[victim:objectName()] > base_value then
                table.insert(result, victim)
            end
        end
        return result
    end
    
    local victim = victims[1]
    local value = values[victim:objectName()] or 0
    if value > base_value then
        return victim
    end
    
    return nil
end
function getKnownHandcards(player, target)
    local handcards = target:getHandcards()
    
    if player:objectName() == target:objectName() then
        return sgs.QList2Table(handcards), {}
    end
    
    --[[local dongchaee = global_room:getTag("Dongchaee"):toString() or ""
    if dongchaee == target:objectName() then
        local dongchaer = global_room:getTag("Dongchaer"):toString() or ""
        if dongchaer == player:objectName() then
            return sgs.QList2Table(handcards), {}
        end
    end]]
    
    local knowns, unknowns = {}, {}
    local flag = string.format("visible_%s_%s", player:objectName(), target:objectName())
    for _,card in sgs.qlist(handcards) do
        if card:hasFlag("visible") or card:hasFlag(flag) then
            table.insert(knowns, card)
        else
            table.insert(unknowns, card)
        end
    end
    return knowns, unknowns
end
local wurong_skill = {}
wurong_skill.name = "Wurong"
table.insert(sgs.ai_skills, wurong_skill)
wurong_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
    if self.player:hasUsed("#WurongCard") then
        return nil
    elseif self.player:isKongcheng() then
        return nil
    end
    return sgs.Card_Parse("#WurongCard:.:&Wurong")
end
sgs.ai_skill_use_func["#WurongCard"] = function(card, use, self)
    local handcards = self.player:getHandcards()
    local my_slashes, my_cards = {}, {}
    for _,c in sgs.qlist(handcards) do
        if c:isKindOf("Slash") or (self.player:hasSkill("Shizhi") and self.player:getHp() == 1 and self.player:getMark("CompanionEffect") == 0 and c:isKindOf("Jink")) then
            table.insert(my_slashes, c)
        else
            table.insert(my_cards, c)
        end
    end
    local no_slash = ( #my_slashes == 0 ) 
    local all_slash = ( #my_cards == 0 ) 
    local need_slash, target = nil, nil
	local target_slash, target_no_slash, target_no_limit = nil, nil, nil
	local prioritize_no_slash = false
	
	local all_jink, has_jink, no_jink = {}, {}, {}
	for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		local knowns, unknowns = getKnownHandcards(self.player, p)
		all_jink[p:objectName()] = (#unknowns == 0)
		has_jink[p:objectName()] = false
		no_jink[p:objectName()] = (#unknowns == 0)
		for _,jink in ipairs(knowns) do
			if jink:isKindOf("Jink") then
				no_jink[p:objectName()] = false
				has_jink[p:objectName()] = true
			else
				all_jink[p:objectName()] = false
			end
		end
	end
    
    --自己展示的一定不是【杀】，目标展示的必须是【闪】，方可获得目标一张牌
    if no_slash then
        local others = self.room:getOtherPlayers(self.player)
        local targets = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, others, true)  --旧版要改
        for _,p in ipairs(targets) do
            if not p:isKongcheng() and all_jink[p:objectName()] then
				if not target_no_slash then target_no_slash = p end
				break
            end
        end
		if not target_no_slash then			--放宽条件（毕竟all_jink很难达成，导致原版AI对有没有闪判断太僵硬）
			for _,p in ipairs(targets) do
				--if not p:isKongcheng() and getCardsNum("Jink", p, self.player) > p:getHandcardNum() - 1 then  
				if not p:isKongcheng() and getKnownCard(p, self.player, "Jink", false) > p:getHandcardNum() - 1 then  
					if not target_no_slash then target_no_slash = p end
					break
				end
			end
		end
		if not target_no_slash then
			for _,p in ipairs(targets) do
				if not p:isKongcheng() and not no_jink[p:objectName()] then  
					if not target_no_slash then target_no_slash = p end
					break
				end
			end
		end
    end
    
    --自己展示的一定是【杀】，目标展示的不是【闪】时，可对目标造成1点伤害
	if all_slash and not target_slash then
        local targets = self:findPlayerToDamage(1, self.player, nil, nil, false, 5, true)
        for _,p in ipairs(targets) do
            if not p:isKongcheng() then
                local knowns, unknowns = getKnownHandcards(self.player, p)
                if self:isFriend(p) and not all_jink[p:objectName()] then --队友会配合不展示【闪】的
					if not target_slash then target_slash = p end
                    break
                elseif (self:isEnemy(p) or #self.enemies == 0) and not has_jink[p:objectName()] then
					if not target_slash then target_slash = p end
                    break
                end
            end
        end
    end
    
    --自己展示的不一定是【杀】，可根据目标情况决定展示的牌
	if not target_slash or not target_no_slash or not target_no_limit then
        local friends, enemies, others = {}, {}, {}
        local other_players = self.room:getOtherPlayers(self.player)
        for _,p in sgs.qlist(other_players) do
            if not p:isKongcheng() then
                if self:isFriend(p) then
                    table.insert(friends, p)
                elseif self:isEnemy(p) then
                    table.insert(enemies, p)
                else
                    table.insert(others, p)
                end
            end
        end
        
		if not target_slash then  --New if
			local to_damage = self:findPlayerToDamage(1, self.player, nil, enemies, false, 5, true)
			for _,enemy in ipairs(to_damage) do
				if no_jink[enemy:objectName()] then
					if not target_slash then target_slash = enemy end
					break
				end
			end
			if not target_slash then
				for _,enemy in ipairs(to_damage) do
					--if getCardsNum("Jink", enemy, self.player) < 1 then
					if getKnownCard(enemy, self.player, "Jink", false) < 1 then
						if not target_slash then target_slash = enemy end
						break
					end
				end
			end
			if not target_slash then
				for _,enemy in ipairs(to_damage) do
					if not all_jink[enemy:objectName()] then
						if not target_slash then target_slash = enemy end
						break
					end
				end
			end
		end
        
        --if not target then
		if not target_no_slash then
            local other_players = self.room:getOtherPlayers(self.player)
            local to_obtain = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, other_players, true)
            for _,p in ipairs(to_obtain) do
                if not p:isKongcheng() then
                    if self:isFriend(p) and has_jink[p:objectName()] then
						if not target_no_slash then
							target_no_slash = p
							if self:needToThrowArmor(p) then prioritize_no_slash = true end
						end
						break
                    elseif (self:isEnemy(p) or #self.enemies == 0) and all_jink[p:objectName()] then
						if not target_no_slash then
							target_no_slash = p 
							if self:getDangerousCard(p) then prioritize_no_slash = true end
						end
						break
                    end
                end
            end
			if not target_no_slash then
				for _,p in ipairs(to_obtain) do
					if not p:isKongcheng() then
						--if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and ((getCardsNum("Jink", p, self.player) > p:getHandcardNum() - 1) or self:getDangerousCard(p)) then
						if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and ((getKnownCard(p, self.player, "Jink", false) > p:getHandcardNum() - 1) or self:getDangerousCard(p)) then
							if not target_no_slash then
								target_no_slash = p 
								if self:getDangerousCard(p) then prioritize_no_slash = true end
							end
							break
						end
					end
				end
			end
			if not target_no_slash then
				for _,p in ipairs(to_obtain) do
					if not p:isKongcheng() then
						if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and (not no_jink[p:objectName()] or self:getDangerousCard(p) or self:getValuableCard(p)) then
							if not target_no_slash then
								target_no_slash = p 
								if self:getDangerousCard(p) then prioritize_no_slash = true end
							end
							break
						end
					end
				end
			end
        end
        
		if not target_slash then
            to_damage = self:findPlayerToDamage(1, self.player, nil, friends, false, 25, true)
            for _,friend in ipairs(to_damage) do
                if not all_jink[p:objectName()] then
					if not target_slash then target_slash = friend end
                    break
                end
            end
        end
		
		if not target_slash then
            local victim = self:findPlayerToDamage(1, self.player, nil, others, false, 5)
            if victim and (self:objectiveLevel(victim) > 0 or #self.enemies == 0) then
				if not target_slash then target_slash = victim end
            end
        end
        
        --只是为了看牌……
		if not target_no_limit and #my_cards > 0 and self:getOverflow() > 0 then
            if #enemies > 0 then
                self:sort(enemies, "handcard")
				if not target_no_limit then target_no_limit = enemies[1] end
            elseif #others > 0 then
                --self:sort(others, "threat")  --threat是什么鬼
                self:sort(others, "handcard")
				if others[1] and (self:objectiveLevel(others[1]) > 0 or #self.enemies == 0) then
					if not target_no_limit then target_no_limit = others[1] end
				end
            end
        end
        
		if not target_no_limit and #enemies > 0 then
            self:sort(enemies, "defense")
			if not target_no_limit then target_no_limit = enemies[1] end
        end
    end
    
	if prioritize_no_slash and target_no_slash and not target_no_slash:isKongcheng() and not all_slash then
		target = target_no_slash
		need_slash = false
	elseif target_slash and not target_slash:isKongcheng() and not no_slash then
		target = target_slash
		need_slash = true
	elseif not willShowShizhi(self) then
	elseif target_no_slash and not target_no_slash:isKongcheng() and not all_slash then
		target = target_no_slash
		need_slash = false
	elseif target_no_limit and not target_no_limit:isKongcheng() then
		target = target_no_limit
		need_slash = (math.random(0, 1) == 0)
		if all_slash then need_slash = true
		elseif no_slash then need_slash = false end
	end
	
    if target and not target:isKongcheng() then
        local use_cards = need_slash and my_slashes or my_cards
        if #use_cards > 0 then
            self:sortByUseValue(use_cards, true)
            local card_str = "#WurongCard:"..use_cards[1]:getEffectiveId() .. ":&Wurong"
            local acard = sgs.Card_Parse(card_str)
            use.card = acard
            if use.to then
                use.to:append(target)
            end
        end
    end
end
sgs.ai_use_priority.WurongCard = 3.1
sgs.ai_use_value.WurongCard = 4.5
sgs.ai_skill_exchange.Wurong = function(self, pattern, max_num, min_num, expand_pile)
	local to_discard = {}
	local cards = self.player:getHandcards()
	local zhangni = sgs.findPlayerByShownSkillName("Wurong")
	cards = sgs.QList2Table(cards)
	
	local my_jinks, my_cards = {}, {}
    for _,c in ipairs(cards) do
        if c:isKindOf("Jink") then
            table.insert(my_jinks, c)
        else
            table.insert(my_cards, c)
        end
    end
	self:sortByKeepValue(my_jinks)
	self:sortByKeepValue(my_cards)
	
    local no_jink = (#my_jinks == 0) 
    local all_jink = (#my_cards == 0) 
	
	local knowns, unknowns = getKnownHandcards(self.player, zhangni)
	local zhangni_no_slash, zhangni_all_slash = (#unknowns == 0), (#unknowns == 0)
	for _,c in ipairs(knowns) do
        if c:isKindOf("Slash") then
            zhangni_no_slash = false
        else
            zhangni_all_slash = false
        end
    end
	
	local needDamage, needGetCard = false, false
	local preventDamage, preventGetCard = false, false
	
	if self:isFriend(zhangni) then
		if self:needToLoseHp(self.player, zhangni) or self:getDamagedEffects(self.player, zhangni) then
			needDamage = true
		elseif self:needToThrowArmor() or (self.player:hasSkills(sgs.lose_equip_skill) and not self.player:getEquips():isEmpty()) or self:needKongcheng() then
			needGetCard = true
		end
	else
		if not self:damageIsEffective(self.player, nil, zhangni) then needDamage = true
		elseif self:isWeak() then preventDamage = true
		elseif self.player:hasSkills(sgs.masochism_skill) or self:needToLoseHp(self.player, zhangni) or self:getDamagedEffects(self.player, zhangni) or self:cantbeHurt(self.player, zhangni) then
			needDamage = true
		end
		if self.player:getCards("he"):length() == 1 and self:needKongcheng()  then needGetCard = true
		elseif self:getDangerousCard(self.player) or self:getValuableCard(self.player) then preventGetCard = true
		end
	end
	
	local mustShowJink = needGetCard or (preventDamage and not zhangni_no_slash)
	local preventShowJink = needDamage or (preventGetCard and not zhangni_all_slash)
	
	if mustShowJink and not no_jink then
		return my_jinks[1]:getEffectiveId()
	elseif preventShowJink and not all_jink then
		return my_cards[1]:getEffectiveId()
	else  --杀吧主流是无脑展示闪，但是太那啥。。
		if math.random() < 0.7 and not no_jink then
			return my_jinks[1]:getEffectiveId()
		else
			self:sortByKeepValue(cards)
			return cards[1]:getEffectiveId()
		end
	end
end
sgs.ai_skill_invoke.Shizhi = false  --需要闪当杀的话用视为技
function willShowShizhi(self)
--本来打算也放到view_as里的，结果会导致嵌套
	if self.player:hasShownSkill("Shizhi") or not self.player:hasSkill("Shizhi") then return true end
	if (self.player:getHp() ~= 1 and not self:isWeak()) or self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then return true end
	local cards = sgs.QList2Table(self.player:getHandcards())
	local jinks = {}
	for _,card in ipairs(cards) do
		if card:isKindOf("Jink") then 
			table.insert(jinks, card)
			if self:isWeak() and self:getCardsNum("Jink") <= 1 and (self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 1) then
				return false
			end
		end
	end
	if #jinks == 0 then return not self:isWeak() end
	
	self:sortByUseValue(jinks)  --判断价值最高的一张牌是否依然低于杀
	local card = jinks[1]
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local slash = sgs.Card_Parse(("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id))
	assert(slash)
	local value = self:getUseValue(slash)
	if self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then  --二次转化大法好
		local jink = sgs.Card_Parse(("jink:longdan[%s:%s]=%d&longdan"):format(suit, number, card_id))
		assert(jink)
		value = math.max(value, self:getUseValue(jink))
	end
	return self:getUseValue(card) < value
end
sgs.ai_view_as.Shizhi = function(card, player, card_place)
	if player:getHp() == 1 and not player:hasShownSkill("Shizhi") then
		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		if card_place == sgs.Player_PlaceHand and card:isKindOf("Jink") and not card:hasFlag("using") then
			return ("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id)
		end
	end
end
local shizhi_skill = {}
shizhi_skill.name = "Shizhi"
table.insert(sgs.ai_skills, shizhi_skill)
shizhi_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasShownSkill("Shizhi") or self.player:getHp() ~= 1 then return end
	if not willShowShizhi(self) then return end
	if self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then return end
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end
	
	local handcards = self.player:getHandcards()
	local real_slashes = {}
	for _,slash in sgs.qlist(handcards) do
		if isCard("Slash", slash, self.player) then table.insert(real_slashes, slash) end
	end
	
	local cards = {}
	for _, card in sgs.qlist(handcards) do
		if card:isKindOf("Jink") and (not self:isWeak() or self:hasCrossbowEffect() or useAll) then  --条件非常苛刻，只有一击必杀才能矢志，因为实在太伤了
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				local hasEffectiveSlash = false
				if #real_slashes > 0 then  --尝试解决手里有真杀还亮矢志的问题
					local use = {to = sgs.SPlayerList(), isDummy = true}
					self:useBasicCard(slash, use)
					if use.card and use.card:isKindOf("Slash") and use.to and not use.to:isEmpty() then
						for _,realslash in ipairs(real_slashes) do
							local use2 = {to = sgs.SPlayerList(), isDummy = true}
							self:useBasicCard(realslash, use2)
							if use2.card and use2.card:isKindOf("Slash") and use2.to and not use2.to:isEmpty() then
								local same_targets = true
								for _,to in sgs.qlist(use.to) do
									if not use2.to:contains(to) then same_targets = false break end
								end
								if same_targets then hasEffectiveSlash = true break end
							end
						end
					end
				end
				if not hasEffectiveSlash then
					table.insert(cards, slash)
				end
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end

-----蔡夫人-----
sgs.ai_skill_invoke.Qieting = function(self, data)
	if not self:willShowForDefence() then return false end
	if self:needKongcheng(self.player, true) then
		local target = self.room:getCurrent()
	
		local disable_list = {}
		for i = 0, 4 do
			if target:getEquip(i) and self.player:getEquip(i) then
				table.insert(disable_list, target:getEquip(i):getEffectiveId())
			end
		end
		local id = self:askForCardChosen(target, "e", "dummyReason", sgs.Card_MethodNone, disable_list)  --dummy可确保并非强制
		if not id then
			return false
		end
	end
	return true
end
sgs.ai_skill_choice.Qieting = function(self, choices)
	local target = self.room:getCurrent()
	
	local disable_list = {}
	for i = 0, 4 do
		if target:getEquip(i) and self.player:getEquip(i) then
			table.insert(disable_list, target:getEquip(i):getEffectiveId())
		end
	end
	local id = self:askForCardChosen(target, "e", "dummyReason", sgs.Card_MethodNone, disable_list)  --dummy可确保并非强制
	if id and id ~= -1 then
		for i = 0, 4 do
			if target:getEquip(i) and target:getEquip(i):getEffectiveId() == id and string.find(choices, i) then
				return i
			end
		end
	end
	return "draw"
end
local xianzhou_skill = {}
xianzhou_skill.name = "Xianzhou"
table.insert(sgs.ai_skills, xianzhou_skill)
xianzhou_skill.getTurnUseCard = function(self)
	if not self:willShowForDefence() and not self:willShowForAttack() then return end
	if self.player:getMark("@handover") <= 0 then return end
	if self.player:getEquips():isEmpty() then return end
	
	--下面这些其实是从useEquipCard对枭姬的判断改来的……
	local armor = self.player:getArmor()
	if armor and armor:objectName() == "PeaceSpell" and self.player:getHp() == 1 and not (self.player:hasLordSkill("hongfa") and not self.player:getPile("heavenly_army"):isEmpty()) then
		local peach_num = self:getCardsNum("Analeptic") + (self.player:hasShownSkill("wansha") and self:getCardsNum("Peach") or self:getAllPeachNum())
		if peach_num == 0 then
			return
		end
	end
	if self.player:getWeapon() and self.player:getWeapon():objectName() == "Crossbow" and self:getCardsNum("Slash") > 2 then
		local d_use = {isDummy = true,to = sgs.SPlayerList()}
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		self:useCardSlash(slash,d_use)
		if d_use.card then
			return
		end
	end
	
	return sgs.Card_Parse("#XianzhouCard:.:&Xianzhou")
end
sgs.ai_skill_use_func["#XianzhouCard"] = function(card, use, self)
	local xianzhou_values = {}  --记录献州牌对每个队友的价值（伤害）
	local function cmp_Xianzhou_value(a, b)
		local ar_a = xianzhou_values[a:objectName()]
		local ar_b = xianzhou_values[b:objectName()]
		if ar_a == ar_b then
			if a:getAttackRange() == b:getAttackRange() then
				return sgs.getDefense(a) > sgs.getDefense(b)
			else
				return a:getAttackRange() > b:getAttackRange()
			end
		else
			return ar_a > ar_b
		end
	end
	
	local len = self.player:getEquips():length()
	local weapon, armor = self.player:getWeapon(), self.player:getArmor()
	local lostHp = self.player:getLostHp()
	if armor and armor:isKindOf("SilverLion") then lostHp = lostHp - 1 end
	if armor and armor:isKindOf("PeaceSpell") and not (self.player:hasLordSkill("hongfa") and not self.player:getPile("heavenly_army"):isEmpty()) then lostHp = lostHp + 1 end
	local willBeWounded = (lostHp > 0)
	
	for _,friend in ipairs(self.friends_noself) do  --Initialize Xianzhou value
		local value = 0
		if friend:hasShownSkills(sgs.need_equip_skill) then value = value + 2 end
		if friend:hasShownSkills(sgs.lose_equip_skill) then value = value + 2 end
		if friend:hasShownSkills(sgs.cardneed_skill) then value = value + 1 end
		
		if weapon then
			if not friend:getWeapon() then value = value + self:evaluateWeapon(weapon, friend) / 5
			else value = value + math.max(self:evaluateWeapon(weapon, friend) - self:evaluateWeapon(friend:getWeapon(), friend) - 1, 0) / 5 end
		end
		if armor then
			if not friend:getArmor() then value = value + self:evaluateArmor(armor, friend) / 5
			else value = value + math.max(self:evaluateArmor(armor, friend) - self:evaluateArmor(friend:getWeapon(), friend) - 1, 0) / 5 end
		end
		
		local all_friends = not willBeWounded  --若蔡夫人未受伤则必须选择伤害
		local avail_enemies = {}
		for _, target in sgs.qlist(self.room:getOtherPlayers(friend)) do
			if not friend:inMyAttackRange(target) then continue end
			if not self:isFriend(target) or not self:damageIsEffective(target, nil, friend) or self:getDamagedEffects(target, friend) then
				all_friends = false
			end
			if not self:isEnemy(target) and not (#self.enemies == 0 and self:objectiveLevel(target) > 3) then continue end
			if self:damageIsEffective(target, nil, friend) and not self:getDamagedEffects(target, friend) and not self:needToLoseHp(target, friend) then
				table.insert(avail_enemies, self:isWeak(target) and 1.5 or 1)
			end
		end
		table.sort(avail_enemies)  --升序
		if #avail_enemies > 0 then
			for i = math.max(#avail_enemies - len + 1, 1), #avail_enemies do
				value = value + avail_enemies[i]
			end
		end
		
		xianzhou_values[friend:objectName()] = all_friends and -99 or value
	end
	
	if self:isWeak() and willBeWounded then
		table.sort(self.friends_noself, cmp_Xianzhou_value)
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.need_equip_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.lose_equip_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.cardneed_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			--if not hasManjuanEffect(friend) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			--end
		end
		if sgs.turncount > 2 then  --防止全暗将时期献州（应该有更好的写法，未知）
			self:sort(self.friends)
			for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if self:objectiveLevel(target) > 0 and target:hasShownSkills(sgs.need_equip_skill) then continue end
				local canUse = true
				for _, friend in ipairs(self.friends) do
					if friend:objectName() ~= target:objectName() and target:inMyAttackRange(friend) and self:damageIsEffective(friend, nil, target)
						and not self:getDamagedEffects(friend, target) and not self:needToLoseHp(friend, target) then
						canUse = false
						break
					end
				end
				if canUse then
					use.card = card
					if use.to then use.to:append(target) end
					return
				end
			end
		end
	end
	if --[[not willBeWounded and]] #self.friends_noself > 0 then  --坑掉虚弱的敌人（注意此时必须选择造成伤害）（融合了源码的未受伤和原项目的体力为1）
		local consider_killers = {}
		self:sort(self.friends_noself)
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if not self:isEnemy(target) and not (#self.enemies == 0 and self:objectiveLevel(target) > 3) then continue end
			for _, friend in ipairs(self.friends_noself) do
				if friend:objectName() ~= target:objectName() and friend:inMyAttackRange(target) and self:damageIsEffective(target, nil, friend)
					and not self:getDamagedEffects(target, friend) and not self:needToLoseHp(target, friend)
					and ((self:isWeak(target) and not willBeWounded) or (target:getHp() <= 1 and not hasNiepanEffect(target) and not hasBuquEffect(target))) then
					if not table.contains(consider_killers, friend) then table.insert(consider_killers, friend) end
				end
			end
		end
		if #consider_killers > 0 then
			table.sort(consider_killers, cmp_Xianzhou_value)
			use.card = card
			if use.to then use.to:append(consider_killers[1]) end
			return
		end
	end

	if #self.friends_noself == 0 then return end
	if self.player:getEquips():length() > 2 or self.player:getEquips():length() > #self.enemies and sgs.turncount > 2 then
		table.sort(self.friends_noself, cmp_Xianzhou_value)
		if xianzhou_values[self.friends_noself[1]:objectName()] >= self.player:getEquips():length() then
			use.card = card
			if use.to then use.to:append(self.friends_noself[1]) end
			return
		end
	end
end
sgs.ai_use_priority.XianzhouCard = 4.9
sgs.ai_card_intention.XianzhouCard = function(self, card, from, tos)
	if not from:isWounded() then sgs.updateIntentions(from, tos, -10) end
end
sgs.ai_skill_playerchosen.Xianzhou = function(self, targets, max_num, min_num)
	local current = self.player:getTag("XianzhouSource"):toPlayer()
	if not current then return {} end
	if self:isWeak(current) and self:isFriend(current) and not (current:getLostHp() == 1 and max_num > 1) then return {} end
	
	local value = 0  --用于与回血选项比较
	local victims = {}
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if self.player:inMyAttackRange(enemy) and self:damageIsEffective(enemy, nil, self.player)
			and not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player)
			and not table.contains(victims, enemy) then
			table.insert(victims, enemy)
			value = value + (self:isWeak(enemy) and 1.5 or 1)
			if #victims == max_num then break end
		end
	end
	if #victims < max_num then  --masochism friends
		self:sort(self.friends_noself)
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self.player:inMyAttackRange(friend) and self:damageIsEffective(friend, nil, self.player)
				and (self:getDamagedEffects(friend, self.player) or self:needToLoseHp(friend, self.player) or friend:hasShownSkills(sgs.masochism_skill))
				and not table.contains(victims, friend) then
				table.insert(victims, friend)
				value = value + 0.7
				if #victims == max_num then break end
			end
		end
	end
	if #victims < max_num then
		for _, target in sgs.qlist(targets) do
			if not self:isFriend(target) and self:isWeak(target) and not table.contains(victims, target) then
				table.insert(victims, target)
				value = value + 0.3
				if #victims == max_num then break end
			end
		end
	end

	if value < math.min(current:getLostHp(), max_num) * 1.2 and self:isFriend(current) then  
		return {}
	end
	if #victims >= min_num then return victims end
	
	--min_num为1（必须选择伤害）
	for _, target in sgs.qlist(targets) do
		if not self:isFriend(target) and not table.contains(victims, target) then
			table.insert(victims, target)
			if #victims == min_num then break end
		end
	end
	if #victims < min_num then
		self:sort(self.friends_noself)
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self.player:inMyAttackRange(friend) and not self:damageIsEffective(friend, nil, self.player) and not table.contains(victims, friend) then
				table.insert(victims, friend)
				if #victims == min_num then break end
			end
		end
	end
	if #victims < min_num then
		for _, target in sgs.qlist(targets) do
			if not table.contains(victims, target) then
				table.insert(victims, target)
				if #victims == min_num then break end
			end
		end
	end
	
	return victims
end
sgs.ai_choicemade_filter.playerChosen.Xianzhou = function(self, from, promptlist)
	if from:objectName() == promptlist[3] then return end
	local reason = string.gsub(promptlist[2], "%-", "_")
	local tos = promptlist[3]:split("+")
	local to
	local caifuren = from:getTag("XianzhouSource"):toPlayer()
	if caifuren and not caifuren:isWounded() then return end
	
	for _, to_str in ipairs(tos) do
		to = findPlayerByObjectName(to_str)
		if not to then continue end
		if self:damageIsEffective(to, nil, from) and not self:getDamagedEffects(to, from) and not self:needToLoseHp(to, from) and not to:hasShownSkills(sgs.masochism_skill) then
			sgs.updateIntention(from, to, 10)
		end
	end
end
function sgs.ai_cardneed.Xianzhou(to, card, self)
	if to:getMark("@handover") <= 0 then return end
	if to:getEquips():isEmpty() and self:isWeak(to) --[[and not self:willSkipPlayPhase(to)]] then
		return card:isKindOf("EquipCard")  --需要装备牌献州回血
	end
end

-----蹋顿-----
sgs.ai_skill_invoke.luanzhan = function(self, data)
	if data:toString() == "Mark" then
		return self:willShowForAttack()  --懒得想
	else
		return false
	end
end
sgs.ai_skill_playerchosen.luanzhanTarget = function(self, targets, max_num, min_num)  --无中、挟天子
	local use = self.player:getTag("luanzhanCardUse"):toCardUse()
	if use.card:isKindOf("ExNihilo") then  --照抄findPlayerToDraw（原函数只能返回一人）
		local friends = {}
		for _, player in sgs.qlist(targets) do
			if self:isFriend(player) and not (player:hasShownSkill("kongcheng") and player:isKongcheng() and drawnum <= 2)
				and self:hasTrickEffective(use.card, player, self.player) and use.card:isAvailable(player) then
				table.insert(friends, player)
			end
		end
		if #friends == 0 then return {} end
		
		local target_table = {}
		self:sort(friends, "defense")
		for _, friend in ipairs(friends) do
			if friend:getHandcardNum() < 2 and not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end

		local AssistTarget = self:AssistTarget()
		if AssistTarget and (AssistTarget:getHandcardNum() < 10 or self.player:getHandcardNum() > AssistTarget:getHandcardNum()) then
			for _, friend in ipairs(friends) do
				if friend:objectName() == AssistTarget:objectName() and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
					table.insert(target_table, friend)
					if #target_table == max_num then return target_table end
				end
			end
		end

		for _, friend in ipairs(friends) do
			if friend:hasShownSkills(sgs.cardneed_skill) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end

		self:sort(friends, "handcard")
		for _, friend in ipairs(friends) do
			if not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end
		return target_table
	elseif use.card:isKindOf("ThreatenEmperor") then
		local friends = {}
		for _, friend in sgs.qlist(targets) do
			if self:isFriend(friend) and self:hasTrickEffective(use.card, friend, self.player) and use.card:isAvailable(friend) and friend:getCardCount(true) >= 1 and friend:canDiscard(friend, "he") then
				table.insert(friends, friend)
			end
		end
		if next(friends) then
			local target_table = {}
			self:sort(friends, "defense")
			for _, friend in ipairs(friends) do
				if self:needToThrowArmor(friend) and not table.contains(target_table, friend) then
					table.insert(target_table, friend)
					if #target_table == max_num then return target_table end
				end
			end
			local AssistTarget = self:AssistTarget()  --从这里开始基本抄放权
			if AssistTarget and table.contains(friends, AssistTarget) and not self:willSkipPlayPhase(AssistTarget) and not table.contains(target_table, AssistTarget) then
				table.insert(target_table, AssistTarget)
				if #target_table == max_num then return target_table end
			end
			self:sort(friends, "handcard")
			friends = sgs.reverse(friends)
			for _, target in ipairs(friends) do
				if target:hasShownSkills("zhiheng|" .. sgs.priority_skill .. "|shensu") and (not self:willSkipPlayPhase(target) or target:hasShownSkill("shensu")) and not table.contains(target_table, target) then
					table.insert(target_table, target)
					if #target_table == max_num then return target_table end
				end
			end
			return target_table
		end
	end
	return {}
end
sgs.ai_skill_use["@@luanzhan1"] = function(self, prompt)  --借刀
	--抄旧灭计
	local collateral = sgs.Card_Parse(self.player:property("extra_collateral"):toString())
	if not collateral then self.room:writeToConsole("luanzhan card parse error!!") end
	local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
	dummy_use.current_targets = self.player:property("extra_collateral_current_targets"):toString():split("+")
	self:useCardCollateral(collateral, dummy_use)
	if dummy_use.card and dummy_use.to:length() == 2 then
		local first = dummy_use.to:at(0):objectName()
		local second = dummy_use.to:at(1):objectName()
		return "#ExtraCollateralCard:.:&->" .. first .. "+" .. second
	end
end
sgs.ai_skill_use["@@luanzhan2"] = function(self, prompt)  --联军
	local card = sgs.Card_Parse(self.player:property("extra_af"):toString())
	if not card then self.room:writeToConsole("luanzhan card parse error!!") end
	local current_targets_names = self.player:property("extra_af_current_targets"):toString():split("+")
	local max_targets = self.player:getMark("luanzhanCount")
	
	--照抄useCardAllianceFeast（因为没法像借刀一样把current_targets耦合进去）
	if not card:isAvailable(self.player) then return end
	local hegnullcards = self.player:getCards("HegNullification")
	local effect_kingdoms = {}
	local current_target = findPlayerByObjectName(current_targets_names[#current_targets_names])  --因为肯定是同一国，直接找个代表
	if current_target then
		if current_target:getRole() == "careerist" then
			table.insert(effect_kingdoms, current_target:objectName())
		else
			table.insert(effect_kingdoms, current_target:getKingdom())
		end
	end

	for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self.player:isFriendWith(target) and target:hasShownOneGeneral() and self:hasTrickEffective(card, target, self.player)
			and not(target:getRole() ~= "careerist" and table.contains(effect_kingdoms, target:getKingdom())) then
			if target:getRole() == "careerist" then
				table.insert(effect_kingdoms, target:objectName())
			else
				table.insert(effect_kingdoms, target:getKingdom())
			end
		end
	end
	if #effect_kingdoms == 0 then return end

	--local max_v = 0
	--local winner
	local value_table = {}  --存储每个kingdom的value
	local count_table = {}  --存储每个kingdom的人数
	local rep_table = {}  --存储每个kingdom的一个代表角色
	for _, kingdom in ipairs(effect_kingdoms) do
		local value = 0
		if kingdom:startsWith("sgs") then
			count_table[kingdom] = 1
			--value = value + 1
			--if self.player:hasShownSkills(sgs.cardneed_skill) then value = value + 0.5 end
			local target = findPlayerByObjectName(kingdom)
			rep_table[kingdom] = target
			if self:isFriend(target) then
				value = value + 1
				if target:isWounded() then
					value = value + 1.8
					if target:hasShownSkills(sgs.masochism_skill) then value = value + 1 end
				else
					if target:hasShownSkills(sgs.cardneed_skill) then value = value + 1 end
					if target:isChained() then value = value + 1 end
				end
			elseif self:isEnemy(target) then
				value = value - 1
				if target:isWounded() then
					value = value - 1.8
					if target:hasShownSkills(sgs.masochism_skill) then value = value - 1 end
				else
					if target:hasShownSkills(sgs.cardneed_skill) then value = value - 1 end
					if target:isChained() then value = value - 1 end
				end
			end
		else
			local self_value = 0
			local enemy_value = 0
			count_table[kingdom] = 0
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasShownOneGeneral() and p:getRole() ~= "careerist" and p:getKingdom() == kingdom then
					count_table[kingdom] = count_table[kingdom] + 1
					rep_table[kingdom] = p
					--self_value = self_value + 1
					--if self.player:hasShownSkills(sgs.cardneed_skill) then self_value = self_value + 0.5 end
					if self:isFriend(p) and self:hasTrickEffective(card, p, self.player) then
						self_value = self_value + 1
						if p:isWounded() then
							self_value = self_value + 1.8
							if p:hasShownSkills(sgs.masochism_skill) then self_value = self_value + 1 end
						else
							if p:hasShownSkills(sgs.cardneed_skill) then self_value = self_value + 1 end
							if p:isChained() then self_value = self_value + 1 end
						end
					elseif self:isEnemy(p) and self:hasTrickEffective(card, p, self.player) then
						enemy_value = enemy_value + 1
						if p:isWounded() then
							enemy_value = enemy_value + 1.8
							if p:hasShownSkills(sgs.masochism_skill) then enemy_value = enemy_value + 1 end
						else
							if p:hasShownSkills(sgs.cardneed_skill) then enemy_value = enemy_value + 1 end
							if p:isChained() then enemy_value = enemy_value + 1 end
						end
					end
				end
			end
			if self_value >= 3 and enemy_value > 5 and hegnullcards then
				enemy_value = enemy_value / 2
			end
			value = self_value - enemy_value
		end
		--[[if value > max_v then
			winner = kingdom
			max_v = value
		end]]
		value_table[kingdom] = value
	end
	
	local targets = {}
	local target_count = 0
	local max_v = 0
	local winner
	while target_count < max_targets and next(effect_kingdoms) do
		max_v = 0
		winner = nil
		for kingdom, value in pairs(value_table) do
			if value > max_v and count_table[kingdom] + target_count <= max_targets and table.contains(effect_kingdoms, kingdom) then
				max_v = value
				winner = kingdom
			end
		end
		if not winner then break end
		table.removeAll(effect_kingdoms, winner)
		table.insert(targets, rep_table[winner]:objectName())
		target_count = target_count + count_table[winner]
	end
	if next(targets) then
		return "#ExtraAllianceFeastCard:.:&->" .. table.concat(targets, "+")
	end
end
function sgs.ai_cardneed.luanzhan(to, card, self)
	if to:getMark("luanzhanCount") <= 0 or (not card:isBlack() and not isCard("Slash", card, to)) then return end
	return isCard("ExNihilo", card, to) or isCard("BefriendAttacking", card, to) or isCard("Snatch", card, to) or isCard("Dismantlement", card, to) or isCard("Duel", card, to) or isCard("Drowning", card, to) or (isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0)
end
sgs.luanzhan_keep_value = {
	Dismantlement = 5.6,
	Duel        = 5.3,
	Drowning    = 5.2,
}
sgs.ai_suit_priority.luanzhan = "diamond|heart|club|spade"

-----刘封-----
sgs.ai_skill_playerchosen.xiansi = function(self)
	if not self:willShowForAttack() then return {} end
	local canSlash_enemies = false  --是否有敌人可以打到刘封
	local crossbow_effect
	
	local isHuashen = false
	if not isHuashen then
		for _, enemy in ipairs(self.enemies) do
			if enemy:inMyAttackRange(self.player) or (self:hasCrossbowEffect(enemy) or getKnownCard(enemy, self.player, "Crossbow") > 0) then  --防止敌人裸模武器然后突突突
				canSlash_enemies = true
			end
			if enemy:inMyAttackRange(self.player) and (self:hasCrossbowEffect(enemy) or getKnownCard(enemy, self.player, "Crossbow") > 0) then
				crossbow_effect = true
				break
			end
		end
	end
	local max_num = 999
	if canSlash_enemies then  --如果敌人都打不到刘封，可以放心发动
		if crossbow_effect then max_num = 3
		elseif self:getCardsNum("Jink") < 1 or self:isWeak() then max_num = 5 end
	end
	if self.player:getPile("counter"):length() >= max_num then return {} end
	local rest_num = math.min(2, max_num - self.player:getPile("counter"):length())
	local targets = {}

	local add_player = function(player, isfriend)
		if player:getHandcardNum() == 0 or player:objectName() == self.player:objectName() then return #targets end
		--if self:objectiveLevel(player) == 0 and player:isLord() and sgs.current_mode_players["rebel"] > 1 then return #targets end
		if #targets == 0 then
			table.insert(targets, player:objectName())
		elseif #targets == 1 then
			if player:objectName() ~= targets[1] then
				table.insert(targets, player:objectName())
			end
		end
		if isfriend and isfriend == 1 then
			self.player:setFlags("AI_xiansiToFriend_" .. player:objectName())
		end
		return #targets
	end
	
	local convertToSPlayer = function(targets)
		local result = {}
		for _,name in pairs(targets) do
			table.insert(result, findPlayerByObjectName(name))
		end
		return result
	end

	local player = self:findPlayerToDiscard("he", true, false)
	if player then
		if rest_num == 1 then return convertToSPlayer({player}) end
		add_player(player, self:isFriend(player) and 1 or nil)
		local another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(player))
		if another then
			add_player(another, self:isFriend(another) and 1 or nil)
			return convertToSPlayer(targets)
		end
	end
	
	local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
	local luxun = self.room:findPlayerBySkillName("Lianying")-- or self.room:findPlayerBySkillName("noslianying")
	local dengai = sgs.findPlayerByShownSkillName("tuntian")
	--local jiangwei = self.room:findPlayerBySkillName("zhiji")

	--[[if jiangwei and self:isFriend(jiangwei) and jiangwei:getMark("zhiji") == 0 and jiangwei:getHandcardNum()== 1
		and self:getEnemyNumBySeat(self.player, jiangwei) <= (jiangwei:getHp() >= 3 and 1 or 0) then
		if add_player(jiangwei, 1) == rest_num then return "@xiansiCard=.->" .. table.concat(targets, "+") end
	end]]
	--[[if dengai and dengai:hasSkill("zaoxian") and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0)
		and dengai:getMark("zaoxian") == 0 and dengai:getPile("field"):length() == 2 and add_player(dengai, 1) == rest_num then
		return targets
	end]]

	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, zhugeliang) > 0 then
		if zhugeliang:getHp() <= 2 then
			if add_player(zhugeliang, 1) == rest_num then return convertToSPlayer(targets) end
		else
			local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), zhugeliang:objectName())
			local cards = sgs.QList2Table(zhugeliang:getHandcards())
			if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
				if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
					if add_player(zhugeliang, 1) == rest_num then return convertToSPlayer(targets) end
				end
			end
		end
	end

	if luxun and self:isFriend(luxun) and luxun:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, luxun) > 0 then
		local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), luxun:objectName())
		local cards = sgs.QList2Table(luxun:getHandcards())
		if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
			if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
				if add_player(luxun, 1) == rest_num then return convertToSPlayer(targets) end
			end
		end
	end

	if luxun and add_player(luxun, (self:isFriend(luxun) and 1 or nil)) == rest_num then
		return convertToSPlayer(targets)
	end

	if dengai and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0) and add_player(dengai, 1) == rest_num then
		return convertToSPlayer(targets)
	end

	if #targets == 1 then
		local target = findPlayerByObjectName(self.room, targets[1])
		if target then
			local another
			if rest_num > 1 then another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(target)) end
			if another then
				add_player(another, self:isFriend(another) and 1 or nil)
				return convertToSPlayer(targets)
			else
				return convertToSPlayer(targets)
			end
		end
	end
	return {}
end
sgs.ai_card_intention.xiansiCard = function(self, card, from, tos)  --todo：重写（参见奋威）
	--[[local lord = self.room:getLord()
	if sgs.evaluatePlayerRole(from) == "neutral" and sgs.evaluatePlayerRole(tos[1]) == "neutral"
		and (not tos[2] or sgs.evaluatePlayerRole(tos[2]) == "neutral") and lord and not lord:isNude()
		and self:doNotDiscard(lord, "he", true) and from:aliveCount() >= 4 then
		sgs.updateIntention(from, lord, -35)
		return
	end]]
	if from:getState() == "online" then
		for _, to in ipairs(tos) do
			if (self.player:hasShownSkills("kongcheng", to) and to:getHandcardNum() == 1) --[[or to:hasShownSkills("tuntian+zaoxian")]] then
			else
				sgs.updateIntention(from, to, 80)
			end
		end
	else
		for _, to in ipairs(tos) do
			local intention = from:hasFlag("AI_xiansiToFriend_" .. to:objectName()) and -5 or 80
			sgs.updateIntention(from, to, intention)
		end
	end
end
local getxiansiCard = function(pile)
	if #pile > 1 then return pile[1], pile[2] end
	return nil
end
local xiansi_slash_skill = {}
xiansi_slash_skill.name = "xiansi_slash"
table.insert(sgs.ai_skills, xiansi_slash_skill)
--[[function sgs.ai_cardsview_value.xiansi_slash(self, class_name, player)  --Gave up halfway
	if class_name == "Slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
		if player:hasFlag("slashTargetFixToOne") then
			local target
			for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
				if p:hasFlag("SlashAssignee") then target = p break end
			end
			local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, slash) > 50 or self.player:hasFlag("slashNoDistanceLimit")
			local targets = {}
			local use = { to = sgs.SPlayerList() }
											self.room:sendCompulsoryTriggerLog(self.player, "02.75", false)
			if self.player:canSlash(target, slash, not no_distance) then use.to:append(target) else return "." end

											self.room:sendCompulsoryTriggerLog(self.player, "03", false)
			if target:hasShownSkill("xiansi") and target:getPile("counter"):length() > 1
				and not (self:needKongcheng() and self.player:isLastHandCard(slash, true)) then
											self.room:sendCompulsoryTriggerLog(self.player, "04", false)
				--return "#xiansiSlashCard:.:" .. target:objectName() .. "&->" .. target:objectName()
				--return "#xiansiSlashCard:.:" .. target:objectName() .. "&"
				local ints = sgs.QList2Table(target:getPile("counter"))
				local a, b = getxiansiCard(ints)
				if a and b then
					return "#xiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&->" .. target:objectName()
				end
			end
			return "@AocaiCard=.:slash"
		end
	end
end]]
xiansi_slash_skill.getTurnUseCard = function(self)
	if not self:slashIsAvailable() then return end
	local liufeng = sgs.findPlayerByShownSkillName("xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return end
	local ints = sgs.QList2Table(liufeng:getPile("counter"))
	local a, b = getxiansiCard(ints)
	if a and b then
		return sgs.Card_Parse("#xiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&")
	end
end
sgs.ai_skill_use_func["#xiansiSlashCard"] = function(card, use, self)
	local liufeng = sgs.findPlayerByShownSkillName("xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return "." end
	local slash = sgs.Sanguosha:cloneCard("slash")

	if self:slashIsAvailable() and self:isFriend(liufeng) and (not self:slashIsEffective(slash, liufeng, self.player) or liufeng:hasShownSkill("xiangle")) then
		sgs.ai_use_priority.xiansiSlashCard = 0.1
		use.card = card
		if use.to then use.to:append(liufeng) end
		return
	else
		sgs.ai_use_priority.xiansiSlashCard = 2.6
		local dummy_use = { to = sgs.SPlayerList() }
		self:useCardSlash(slash, dummy_use)
		if dummy_use.card then
			if (dummy_use.card:isKindOf("GodSalvation") or dummy_use.card:isKindOf("Analeptic") or dummy_use.card:isKindOf("Weapon"))
				and self:getCardsNum("Slash") > 0 then
				use.card = dummy_use.card
				--if use.to then use.to:append(liufeng) end  --会导致对刘封使用酒的bug（什么鬼）
				if dummy_use.to then use.to = dummy_use.to end
				return
			else
				if dummy_use.card:isKindOf("Slash") and dummy_use.to:length() > 0 then
					local lf
					for _, p in sgs.qlist(dummy_use.to) do
						if p:objectName() == liufeng:objectName() then
							lf = true
							break
						end
					end
					if lf and self.player:hasSkill("duanbing") and self:willShowForAttack() and not self.player:hasFlag("HalberdUse") then  --短兵必须选择刘封为额定目标，额外目标必须距离1
						local slash_targets = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, dummy_use.card)
						if dummy_use.to and dummy_use.to:length() > slash_targets then
							local hasDist1 = false
							for _, p in sgs.qlist(dummy_use.to) do
								if p:objectName() ~= liufeng:objectName() and self.player:distanceTo(p) == 1 then
									hasDist1 = true
									break
								end
							end
							if not hasDist1 then lf = nil end
						end
					end
					if lf then
						use.card = card
						if use.to then use.to:append(liufeng) end
						return
					end
				end
			end
		end
	end
	if not use.card then
		sgs.ai_use_priority.xiansiSlashCard = 2.0
		if self:slashIsAvailable() and self:isEnemy(liufeng)
			and not self:slashProhibit(slash, liufeng) and self:slashIsEffective(slash, liufeng) and sgs.isGoodTarget(liufeng, self.enemies, self) then
			use.card = card
			if use.to then use.to:append(liufeng) end
			return
		end
	end
end
sgs.ai_card_intention.xiansiSlashCard = function(self, card, from, tos)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if not self:slashIsEffective(slash, tos[1], from) then
		sgs.updateIntention(from, tos[1], -30)
	else
		return sgs.ai_card_intention.Slash(self, slash, from, tos)
	end
end

-----孙鲁班-----
sgs.ai_skill_invoke.jiaojin = function(self, data)
	return true
end

local zenhui_skill = {}
zenhui_skill.name = "zenhui"
table.insert(sgs.ai_skills, zenhui_skill)
zenhui_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#zenhuiCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#zenhuiCard:.:&zenhui")
end
sgs.ai_skill_use_func["#zenhuiCard"] = function(card, use, self)
	local room = self.room
	self:sort(self.enemies, "hp")
	local to
	local max_num = 0
	local hurt_friend = 0
	for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
		local num = 0
		local hurt = 0
		for _, q in sgs.qlist(room:getOtherPlayers(p)) do
			if self:isEnemy(q) and p:distanceTo(q) <= 1 then
				num = num + 1
			elseif self:isFriend(q) and p:distanceTo(q) <= 1 then
				hurt = hurt + 1
			end
		end
		if num > max_num then
			max_num = num
			to = p
			hurt_friend = hurt
		elseif num == max_num then
			if hurt < hurt_friend then
				max_num = num
				to = p
				hurt_friend = hurt
			end
		end
	end
	if not to then return false end
	if hurt_friend > max_num then return false end
	if self:isEnemy(to) and (hurt_friend > max_num - 1 or max_num < 1) then return false end
	local need_card = -1
	if to then
		local cards = self.player:getCards("h")
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards,true)
		for _, c in pairs(cards) do
			if c:isKindOf("Slash") then
				need_card = c:getEffectiveId()
			end
		end
	end
	if to and need_card ~= -1 then
		local targets = sgs.SPlayerList()
		targets:append(to)
		if targets:length() == 1 then
			use.card = sgs.Card_Parse("#zenhuiCard:"..need_card..":&zenhui")
			if use.to then use.to = targets end
		end
	end
end	

-----陆抗-----
sgs.ai_skill_invoke.qianjie = function(self, data)
	return true
end
sgs.ai_use_value.jueyanCard = 20
sgs.ai_use_priority.jueyanCard = 20
local jueyan_skill = {}
jueyan_skill.name = "jueyan"
table.insert(sgs.ai_skills, jueyan_skill)
jueyan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#jueyanCard") then return end
	return sgs.Card_Parse("#jueyanCard:.:&jueyan")
end
sgs.ai_skill_use_func["#jueyanCard"] = function(card, use, self)
	local list_str = self.player:property("jueyanProp"):toString()
	local room = self.player:getRoom()
	if list_str == "" or list_str == nil then
		list_str = "jueyan1+jueyan2+jueyan3+jueyan4+jueyan5+jueyanCancel"
	end
	local list = list_str:split("+")
	local invoke = false
	--如果锦囊多，则选第五个
	if table.contains(list, "jueyan5") then 
		local trick_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("ExNihilo") or card:isKindOf("BefriendAttacking") then trick_num = trick_num + 3
			elseif card:isKindOf("AwaitExhausted") then trick_num = trick_num + 2
			elseif card:isKindOf("ThreatenEmperor") or card:isKindOf("FightTogether") or card:isKindOf("ImperialOrder") then trick_num = trick_num + 0.5
			elseif card:isNDTrick() then trick_num = trick_num + 1
			end
		end
		if trick_num >= 3 then 
			invoke = true
		end
	end
	if table.contains(list, "jueyan4") and self:getCardsNum("Peach") == 0 then
		if self.player:getHp() == 1 and self.player:isWounded() then
			invoke = true
		end
	end
	if table.contains(list, "jueyan1") then 
		if self.player:getHandcardNum() < 2 then
			invoke = true
		end
	end
	if table.contains(list, "jueyan2") then 
		local slash_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("Slash") and card:getSuit() ~= sgs.Card_Diamond then slash_num = slash_num + 1 end
		end
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
			if self:isEnemy(p) and self.player:inMyAttackRange(p) then
				if slash_num > 2 then
					invoke = true
				elseif slash_num == 2 and p:getHp() == 1 then
					invoke = true
				end
			end
		end
	end
	if table.contains(list, "jueyan3") then
		local slash_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("Slash") and card:getSuit() ~= sgs.Card_Spade then slash_num = slash_num + 1 end
		end
		if slash_num > 0 then
			for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
				if self:isEnemy(p) and p:getHp() == 1 then
					if not self.player:inMyAttackRange(p) or (p:getEquip(1) and ((p:getEquip(1):isKindOf("RenwangShield") and self.player:getCardsNum("ThunderSlash") == 0) 
					or (p:getEquip(1):isKindOf("Vine") and self.player:getCardsNum("ThunderSlash") == 0 and self.player:getCardsNum("FireSlash") == 0)
					or p:getEquip(1):isKindOf("EightDiagram"))) then
						invoke = true
					end
				end
			end
		end
	end
	if table.contains(list, "jueyan4") and self.player:isWounded() and self.player:getHandcardNum() > self.player:getMaxCards() + 2 then
		invoke = true
	end
	if table.contains(list, "jueyan1") and self.player:isWounded() and self.player:getHandcardNum() > self.player:getMaxCards() + 2 then
		invoke = true
	end
	if invoke then
		use.card = card
	end
end
sgs.ai_skill_choice["jueyan"] = function(self, choices, data)
	local room = self.player:getRoom()
	local list_str = self.player:property("jueyanProp"):toString()
	if list_str == "" or list_str == nil then
		list_str = "jueyan1+jueyan2+jueyan3+jueyan4+jueyan5+jueyanCancel"
	end
	local list = list_str:split("+")
	if table.contains(list, "jueyan5") then 
		local trick_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("ExNihilo") or card:isKindOf("BefriendAttacking") then trick_num = trick_num + 3
			elseif card:isKindOf("AwaitExhausted") then trick_num = trick_num + 2
			elseif card:isKindOf("ThreatenEmperor") or card:isKindOf("FightTogether") or card:isKindOf("ImperialOrder") then trick_num = trick_num + 0.5
			elseif card:isNDTrick() then trick_num = trick_num + 1
			end
		end
		if trick_num >= 3 then 
			return "jueyan5"
		end
	end
	if table.contains(list, "jueyan4") and self:getCardsNum("Peach") == 0 then
		if self.player:getHp() == 1 and self.player:isWounded() then
			return "jueyan4"
		end
	end
	if table.contains(list, "jueyan1") then 
		if self.player:getHandcardNum() < 2 then
			return "jueyan1"
		end
	end
	if table.contains(list, "jueyan2") then 
		local slash_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("Slash") and card:getSuit() ~= sgs.Card_Diamond then slash_num = slash_num + 1 end
		end
		for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
			if self:isEnemy(p) and self.player:inMyAttackRange(p) then
				if slash_num > 2 then
					return "jueyan2"
				elseif slash_num == 2 and p:getHp() == 1 then
					return "jueyan2"
				end
			end
		end
	end
	if table.contains(list, "jueyan3") and self:getCardsNum("Slash") > 0 then
		local slash_num = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do 
			if card:isKindOf("Slash") and card:getSuit() ~= sgs.Card_Spade then slash_num = slash_num + 1 end
		end
		if slash_num > 0 then
			for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
				if self:isEnemy(p) and p:getHp() == 1 then
					if not self.player:inMyAttackRange(p) or (p:getEquip(1) and ((p:getEquip(1):isKindOf("RenwangShield") and self.player:getCardsNum("ThunderSlash") == 0) 
					or (p:getEquip(1):isKindOf("Vine") and self.player:getCardsNum("ThunderSlash") == 0 and self.player:getCardsNum("FireSlash") == 0)
					or p:getEquip(1):isKindOf("EightDiagram"))) then
						return "jueyan3"
					end
				end
			end
		end
	end
	if table.contains(list, "jueyan4") and self.player:isWounded() and self.player:getHandcardNum() > self.player:getMaxCards() + 2 then
		return "jueyan4"
	end
	if table.contains(list, "jueyan1") and self.player:isWounded() and self.player:getHandcardNum() > self.player:getMaxCards() + 2 then
		return "jueyan1"
	end
	return choices[1]
end
sgs.ai_skill_playerchosen.poshi = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	local maxNum = 0
	local to 
	for _, p in pairs(self.friends) do 
		local num = p:getMaxHp() - p:getHandcardNum()
		if num > maxNum then
			maxNum = num 
			to = p 
		elseif num == maxNum then
			if p:getHp() < to:getHp() then
				maxNum = num 
				to = p 
			end
		end
	end
	if to then
		return to
	end
	return nil
end
sgs.ai_use_value.huairouCard = 228
sgs.ai_use_priority.huairouCard = 228
local huairou_skill = {}
huairou_skill.name = "huairou"
table.insert(sgs.ai_skills, huairou_skill)
huairou_skill.getTurnUseCard = function(self)
	local equips = {}
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:getTypeId() == sgs.Card_TypeEquip then
			table.insert(equips, card)
		end
	end
	for _, card in sgs.qlist(self.player:getEquips()) do
		if card:getTypeId() == sgs.Card_TypeEquip then
			table.insert(equips, card)
		end
	end
	if #equips == 0 then return end
	if self.player:hasUsed("#huairouCard") then return end
	return sgs.Card_Parse("#huairouCard:.:&huairou")
end
sgs.ai_skill_use_func["#huairouCard"] = function(card, use, self)
	local equips = {}
	if not self.player:hasSkill("xiaoji") then
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if card:isKindOf("Armor") or card:isKindOf("Weapon") then
				if not self:getSameEquip(card) then
				elseif card:isKindOf("GudingBlade") and self:getCardsNum("Slash") > 0 then
					local HeavyDamage
					local slash = self:getCard("Slash")
					for _, enemy in ipairs(self.enemies) do
						if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(slash, enemy)
							and self:slashIsEffective(slash, enemy) and enemy:isKongcheng() then
								HeavyDamage = true
								break
						end
					end
					if not HeavyDamage then table.insert(equips, card) end
				else
					table.insert(equips, card)
				end
			elseif card:getTypeId() == sgs.Card_TypeEquip then
				table.insert(equips, card)
			end
		end
	end
	for _, card in sgs.qlist(self.player:getEquips()) do
		if card:isKindOf("Armor") or card:isKindOf("Weapon") then
			if not self:getSameEquip(card) then
			elseif card:isKindOf("GudingBlade") and self:getCardsNum("Slash") > 0 then
				local HeavyDamage
				local slash = self:getCard("Slash")
				for _, enemy in ipairs(self.enemies) do
					if self.player:canSlash(enemy, slash, true) and not self:slashProhibit(slash, enemy)
						and self:slashIsEffective(slash, enemy) and enemy:isKongcheng() then
							HeavyDamage = true
							break
					end
				end
				if not HeavyDamage then table.insert(equips, card) end
			else
				table.insert(equips, card)
			end
		elseif card:getTypeId() == sgs.Card_TypeEquip then
			table.insert(equips, card)
		end
	end
	if #equips == 0 then return end

	local select_equip, target
	for _, friend in ipairs(self.friends_noself) do
		for _, equip in ipairs(equips) do
			if not self:getSameEquip(equip, friend) and friend:hasShownSkills(sgs.need_equip_skill .. "|" .. sgs.lose_equip_skill) then
				target = friend
				select_equip = equip
				break
			end
		end
		if target then break end
		for _, equip in ipairs(equips) do
			if not self:getSameEquip(equip, friend) then
				target = friend
				select_equip = equip
				break
			end
		end
		if target then break end
	end
	if not target then 
		local list = {}
		if self:getCardsNum("OffensiveHorse") > 1 then
			if self.player:hasSkill("xiaoji") and self.player:getEquip(3) then 
				table.insert(list, self.player:getEquip(3))
			else
				for _, equip in ipairs(equips) do
					if equip:isKindOf("OffensiveHorse") then
						table.insert(list, equip)
						break
					end
				end
			end
		elseif self:getCardsNum("Weapon") > 1 then
			if self.player:hasSkill("xiaoji") and self.player:getEquip(0) then 
				table.insert(list, self.player:getEquip(0))
			else
				for _, equip in ipairs(equips) do
					if equip:isKindOf("Weapon") then
						table.insert(list, equip)
					end
				end
			end
		elseif self:getCardsNum("DefensiveHorse") > 1 then
			if self.player:hasSkill("xiaoji") and self.player:getEquip(2) then 
				table.insert(list, self.player:getEquip(2))
			else
				for _, equip in ipairs(equips) do
					if equip:isKindOf("DefensiveHorse") then
						table.insert(list, equip)
						break
					end
				end
			end
		elseif self:getCardsNum("Armor") > 1 then
			if self.player:hasSkill("xiaoji") and self.player:getEquip(1) then 
				table.insert(list, self.player:getEquip(1))
			else
				for _, equip in ipairs(equips) do
					if equip:isKindOf("Armor") then
						table.insert(list, equip)
					end
				end
			end
		end
		if #list == 0 then 
			if self.player:isWounded() and self.player:getEquip(1) and self.player:getEquip(1):isKindOf("SilverLion") then
				table.insert(list, self.player:getEquip(1))
			elseif self.player:getEquip(1) and self.player:getEquip(1):isKindOf("Vine") and not self.player:hasSkill("kongcheng") then
				table.insert(list, self.player:getEquip(1))
			elseif self.player:hasSkill("xiaoji") and self:isWeak(self.player) then
				table.insert(list, self.player:getEquips():first())
			end
		end
		if #list == 0 then return nil end
		self:sortByKeepValue(list,true)
		local select_equip = list[1]
		local huairou = sgs.Card_Parse("#huairouCard:" .. select_equip:getId() .. ":&huairou")
		use.card = huairou
	else
		if use.to then use.to:append(target) end
		local huairou = sgs.Card_Parse("#huairouCard:" .. select_equip:getId() .. ":&huairou")
		use.card = huairou
	end
end

-----严颜-----
sgs.ai_skill_invoke.juzhan = function(self, data)
	self.room:getThread():delay(1500)
	return true
end

-----嵇康-----
sgs.ai_skill_cardask["@qingxian"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local equips = self.player:getEquips()
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isKindOf("EquipCard") then
			equips:append(card)
		end
	end
	cards = sgs.QList2Table(equips)
	self:sortByUseValue(cards, true)
	for _,card in pairs(cards) do
		return card:toString()
	end
	return nil
end
sgs.ai_skill_playerchosen.qingxianDamageYang = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	for _, p in pairs(self.friends_noself) do 
		if targets:contains(p) then
			return p 
		end
	end
	return nil
end
sgs.ai_skill_playerchosen.qingxianDamageYin = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.enemies, "hp")
	for _, p in pairs(self.enemies) do 
		if targets:contains(p) then
			return p 
		end
	end
	return nil
end
sgs.ai_skill_playerchosen.qingxianRecoverYang = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	local need_target
	local value = 999
	for _, p in pairs(self.friends) do 
		if targets:contains(p) then
			local num = p:getHp() * 2 + p:getHandcardNum() + p:getEquips():length()
			if num < value then
				value = num 
				need_target = p 
			end
		end
	end
	if need_target then
		return need_target
	end
	if #self.enemies > 0 then
		return self.friends[1]
	end
	return nil
end
sgs.ai_skill_playerchosen.qingxianRecoverYin = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.enemies, "hp")
	local need_target
	local value = 999
	for _, p in pairs(self.enemies) do 
		if targets:contains(p) then
			local num = p:getHp() * 2 + p:getHandcardNum() + p:getEquips():length()
			if num < value and p:getHandcardNum() + p:getEquips():length() >= 2 then
				value = num 
				need_target = p 
			end
		end
	end
	if need_target then
		return need_target
	end
	if #self.enemies > 0 then
		return self.enemies[1]
	end
	return nil
end
sgs.ai_skill_playerchosen.hexian = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	local maxNum = 0
	local to 
	for _, p in pairs(self.friends_noself) do 
		if targets:contains(p) then
			return p 
		end
	end
	return nil
end
sgs.ai_skill_playerchosen.liexian = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.enemies, "hp")
	local need_target
	local value = 999
	for _, p in pairs(self.enemies) do 
		if targets:contains(p) then
			local num = p:getHp() * 2 + p:getHandcardNum() + p:getEquips():length()
			if num < value and p:getHandcardNum() + p:getEquips():length() >= 2 then
				value = num 
				need_target = p 
			end
		end
	end
	if need_target then
		return need_target
	end
	if #self.enemies > 0 then
		return self.enemies[1]
	end
	return nil
end
sgs.ai_skill_playerchosen.rouxian = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp")
	local need_target
	local value = 999
	for _, p in pairs(self.friends) do 
		if targets:contains(p) then
			local num = p:getHp() * 2 + p:getHandcardNum() + p:getEquips():length()
			if num < value then
				value = num 
				need_target = p 
			end
		end
	end
	if need_target then
		return need_target
	end
	if #self.friends > 0 then
		return self.friends[1]
	end
	return nil
end
sgs.ai_skill_invoke.jixian = function(self, data)
	local room = self.room
	local to 
	local toObjectName = data:toString():split(":::")[2]
	for _, p in sgs.qlist(room:getAlivePlayers()) do 
		if p:objectName() == toObjectName then
			to = p
		end
	end
	if self:isEnemy(to) then 
		return true
	end
	return false
end
sgs.ai_skill_playerchosen.juexiang = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends, "hp", false)
	local maxNum = 0
	local to 
	for _, p in pairs(self.friends_noself) do 
		if targets:contains(p) then
			return p 
		end
	end
	return nil
end

-----董白-----
sgs.ai_skill_invoke.xiahui = function(self, data)
	return true
end
sgs.ai_use_value.lianzhuCard = 6
sgs.ai_use_priority.lianzhuCard = 6
local lianzhu_skill = {}
lianzhu_skill.name = "lianzhu"
table.insert(sgs.ai_skills, lianzhu_skill)
lianzhu_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#lianzhuCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#lianzhuCard:.:&lianzhu")
end
sgs.ai_skill_use_func["#lianzhuCard"] = function(card, use, self)
	local room = self.room
	self:sort(self.enemies, "handcard", false)
	local to
	for _, p in pairs(self.enemies) do 
		if p:objectName() == self.player:objectName() then continue end
		if p:hasShownOneGeneral() then 
			to = p 
			break
		end
	end
	if not to then
		for _, p in pairs(self.enemies) do 
			if p:objectName() == self.player:objectName() then continue end
			to = p 
			break
		end
	end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards,true)
	local need_card = nil
	for _, c in pairs(cards) do
		if c:isBlack() then
			need_card = c:getEffectiveId()
			break
		end
	end
	if to and need_card then
		use.card = sgs.Card_Parse("#lianzhuCard:"..need_card..":&lianzhu")
		local targets = sgs.SPlayerList()
		targets:append(to)
		if use.to then use.to = targets end
	end
end	
sgs.ai_skill_discard["lianzhu"] = function(self, discard_num, min_num, optional, include_equip)
	local source = self.player
	local room = source:getRoom()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards,true)
	local need_card = {}
	for _, c in pairs(cards) do
		if #need_card >= discard_num then break end
		if not c:hasFlag("xiahuiCard") and not c:isKindOf("Peach") and (not c:isKindOf("Armor") or (c:isKindOf("Armor") and (c:isKindOf("Vine") or (c:isKindOf("SilverLion") and source:isWounded())))) then
			table.insert(need_card, c:getEffectiveId())
		end
	end
	if #need_card == discard_num then
		return need_card
	end
	return {}
end

-----严白虎-----
sgs.ai_use_value.zhidaoCard = 6
sgs.ai_use_priority.zhidaoCard = 6
local zhidao_skill = {}
zhidao_skill.name = "zhidao"
table.insert(sgs.ai_skills, zhidao_skill)
zhidao_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#zhidaoCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#zhidaoCard:.:&zhidao")
end
sgs.ai_skill_use_func["#zhidaoCard"] = function(card, use, self)
	local room = self.room
	if self.player:getHp() <= 2 then
		if self:getCardsNum("Jink") > 1 or 
			(self:getCardsNum("Jink") == 0 and self.player:getHp() == 2 and self.player:getEquip(1) and self.player:getEquip(1):isKindOf("EightDiagram")) or
			(self:getCardsNum("Jink") == 1 and self.player:getHp() == 1 and self.player:getEquip(1) and self.player:getEquip(1):isKindOf("EightDiagram")) or 
			(self.player:getEquip(1) and self.player:getEquip(1):isKindOf("Vine")) then 
		else
			return
		end
	end
	self:sort(self.enemies, "handcard")
	local to
	for _, p in pairs(self.enemies) do 
		if p:objectName() == self.player:objectName() then continue end
		if p:getHandcardNum() > 0 then 
			if self.player:getHp() <= 2 and p:getEquip(0) and p:getEquip(0):isKindOf("Axe") and p:getHandcardNum() + p:getEquips():length() >= 3 then continue end
			to = p 
			break
		end
	end
	if to then
		use.card = card
		local targets = sgs.SPlayerList()
		targets:append(to)
		if use.to then use.to = targets end
	end
end	
sgs.ai_skill_playerchosen.jili = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.enemies, "hp", false)
	local maxNum = 0
	for _, p in pairs(self.enemies) do 
		if targets:contains(p) then
			return p 
		end
	end
	return targets:first()
end

-----韩当-----
sgs.ai_skill_invoke.xiahui = function(self, data)
	local room = self.room
	if room:getAlivePlayers():length() <= 4 then return true end
	for _, p in sgs.qlist(room:getOtherPlayers(self.player)) do 
		if self:isEnemy(p) and p:hasShownOneGeneral() then 
			return true
		end
	end
	return false
end
sgs.ai_use_value.jiefanCard = 6
sgs.ai_use_priority.jiefanCard = 6
local jiefan_skill = {}
jiefan_skill.name = "jiefan"
table.insert(sgs.ai_skills, jiefan_skill)
jiefan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#jiefanCard") or self.player:isNude() then return end
	return sgs.Card_Parse("#jiefanCard:.:&jiefan")
end
sgs.ai_skill_use_func["#jiefanCard"] = function(card, use, self)
	local room = self.room
	self:sort(self.friends, "hp")
	local to
	for _, p in pairs(self.friends) do 
		if p:getHp() == 2 and p:getAttackRange() == 2 then 
			to = p 
		elseif p:getHp() == 1 and p:getAttackRange() <= 2 then 
			to = p 
		end
	end
	if not to then 
		for _, p in pairs(self.friends) do 
			if p:getAttackRange() >= 4 and p:getHandcardNum() <= 2 then 
				to = p 
			end
		end
	end
	if not to then 
		for _, p in pairs(self.friends) do 
			if p:getAttackRange() == 3 and p:getHandcardNum() <= 1 then 
				to = p
			end
		end
	end
	if to then
		use.card = card
		local targets = sgs.SPlayerList()
		targets:append(to)
		if use.to then use.to = targets end
	end
end	

-----程普-----
function sgs.ai_cardneed.lihuo(to, card, self)
	return card:isKindOf("FireSlash")
end
sgs.ai_skill_invoke.lihuo = function(self, data)
	if self.player:hasWeapon("fan") then return false end
	if not sgs.ai_skill_invoke.fan(self, data) then return false end
	local use = data:toCardUse()
	for _, player in sgs.qlist(use.to) do
		if self:isEnemy(player) and self:damageIsEffective(player, sgs.DamageStruct_Fire) and sgs.isGoodTarget(player, self.enemies, self) then
			if player:isChained() then return self:isGoodChainTarget(player) end
			if player:hasArmorEffect("vine") then return true end
		end
	end
	return false
end
sgs.ai_skill_playerchosen.lihuo = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	local use = data:toCardUse()
	for _, player in sgs.qlist(targets) do
		if self:isEnemy(player) and self:damageIsEffective(player, sgs.DamageStruct_Fire) and sgs.isGoodTarget(player, self.enemies, self) then
			if player:isChained() and self:isGoodChainTarget(player) then return player end
			if player:hasArmorEffect("vine") then return player end
		end
	end
	for _, player in sgs.qlist(targets) do
		if self:isEnemy(player) then
			return player
		end
	end
	return targets:first()
end
sgs.ai_skill_cardask["@chunlao_invoke"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,card in pairs(cards) do
		if not card:isKindOf("Peach") then
			return card:toString()
		end
	end
	return "."
end

-----吴懿-----
sgs.ai_skill_invoke.benxi = function(self, data)
	self.room:getThread():delay(700)
	return true
end
sgs.ai_skill_playerchosen.benxi = function(self, targets)
	local source = self.player
	local room = source:getRoom()
	self:sort(self.friends_noself, "hp")
	local id = source:property("benxiProp"):toInt()
	local card = sgs.Sanguosha:getCard(id)
	if card:isKindOf("Slash") then
		if card:isKindOf("FireSlash") then
			for _, player in sgs.qlist(targets) do
				if self:isEnemy(player) and self:damageIsEffective(player, sgs.DamageStruct_Fire) and sgs.isGoodTarget(player, self.enemies, self) then
					if player:isChained() and self:isGoodChainTarget(player) then return player end
					if player:hasArmorEffect("vine") then return player end
				end
			end
		end
		for _, player in sgs.qlist(targets) do
			if self:isEnemy(player) then
				return player
			end
		end
	elseif card:isKindOf("Peach") then
		for _, player in pairs(self.friends_noself) do
			if targets:contains(player) and player:isWounded() then
				return player
			end
		end
	elseif card:isKindOf("Analeptic") then
		for _, player in pairs(self.friends_noself) do
			if targets:contains(player) then
				return player
			end
		end
	end
	return nil
end
sgs.ai_skill_cardask["@benxi_invoke"] = function(self, data, pattern, target, target2)
    local room = self.player:getRoom()
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,card in pairs(cards) do
		if not card:isKindOf("Peach") then
			return card:toString()
		end
	end
	return cards[1]:toString()
end

-----诸葛诞-----
sgs.ai_skill_invoke.gongao = function(self, data)
	self.room:getThread():delay(300)
	return true
end

sgs.ai_skill_choice["jueyan"] = function(self, choices, data)
	local room = self.room 
	local source = self.player
	if room:getAlivePlayers():length() <= 3 then return "gongao_recover" end
	local player_num = room:getAlivePlayers():length()
	local num = math.random(0, 50)
	if player:getHandcardNum() < 3 and player_num <= 4 then 
		if num < 10 then return "gongao_draw"
		else return "gongao_recover"
		end
	elseif player:getHandcardNum() < 3 and player_num <= 5 then 
		if num < 20 then return "gongao_draw"
		else return "gongao_recover"
		end
	elseif player:getHandcardNum() < 4 and player_num <= 7 then 
		if num < 30 then return "gongao_draw"
		else return "gongao_recover"
		end
	elseif player:getHandcardNum() < 4 and player_num <= 10 then 
		if num < 40 then return "gongao_draw"
		else return "gongao_recover"
		end
	else
		return "gongao_recover"
	end
end

-----朱然-----
-- 胆守
local danshou_skill = {}
danshou_skill.name = "danshou"
table.insert(sgs.ai_skills, danshou_skill)
danshou_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	local times = self.player:getMark("danshou") + 1
	if times < self.player:getCardCount(true) then
		return sgs.Card_Parse("#danshouCard:.:&danshou")
	end
end
sgs.ai_skill_use_func["#danshouCard"] = function(card, use, self)
	local times = self.player:getMark("danshou") + 1
	local cards = self.player:getCards("he")
	local jink_num = self:getCardsNum("Jink")
	local to_discard = {}
	for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
		cards:append(sgs.Sanguosha:getCard(id))
	end
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local has_weapon = false
	local DisWeapon = false
	local DisOffensiveHorse = false
	for _, card in ipairs(cards) do
		if card:isKindOf("Weapon") and card:isBlack() then has_weapon = true end
	end
	for _, card in ipairs(cards) do
		if self.player:canDiscard(self.player, card:getEffectiveId()) and ((self:getUseValue(card) < sgs.ai_use_value.Dismantlement + 1) or self:getOverflow() > 0) then
			local shouldUse = true
			if card:isKindOf("Armor") then
				if not self.player:getArmor() then shouldUse = false
				elseif self.player:hasEquip(card) and not (card:isKindOf("SilverLion") and self.player:isWounded()) then shouldUse = false
				end
			end
			if card:isKindOf("Weapon") and self.player:getHandcardNum() > 2 then
				if not self.player:getWeapon() then shouldUse = false
				elseif self.player:hasEquip(card) and not has_weapon then shouldUse = false
				else DisWeapon = true
				end
			end
			if card:isKindOf("Weapon") and self.player:hasEquip(card) then  --源码漏掉的距离判断
				DisWeapon = true
			end
			if card:isKindOf("OffensiveHorse") and self.player:hasEquip(card) then
				DisOffensiveHorse = true
			end
			if card:isKindOf("Slash") then
				local dummy_use = { isDummy = true }
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			end
			if self:getUseValue(card) > sgs.ai_use_value.Dismantlement + 1 and card:isKindOf("TrickCard") then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end
			if isCard("Peach", card, self.player) then
				if times ~= 3 then shouldUse = false end
			end
			if isCard("Jink", card, self.player) then
				if jink_num <= 1 and times == 1 then shouldUse = false
				else jink_num = jink_num - 1 end
			end
			if shouldUse then
				table.insert(to_discard, card:getEffectiveId())
				if #to_discard == times then break end
			end
		end
	end

	local distance_fix = 0
	if DisWeapon then distance_fix = self.player:getWeapon():getRealCard():toWeapon():getRange() - self.player:getAttackRange(false) end
	if DisOffensiveHorse then distance_fix = distance_fix + 1 end
	local target
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if (self.player:distanceTo(p, distance_fix) <= self.player:getAttackRange()) and (self.player:distanceTo(p) ~= -1) or table.contains(self.player:property("in_my_attack_range"):toString():split("+"), p:objectName()) then  --基本来自lua中的inMyAttackRangeFromV2
			if times == 1 or times == 2 then
				if self.player:canDiscard(p, "he") and not p:isNude() then
					if self:isFriend(p) then
						if(self:hasSkills(sgs.lose_equip_skill, p) and not p:getEquips():isEmpty())
						or (self:needToThrowArmor(p) and p:getArmor()) or self:doNotDiscard(p) then
							target = p  break end
					elseif self:isEnemy(p) then
						if times == 2 and self:needToThrowArmor(p) then continue
						elseif (not self:doNotDiscard(p) or self:getDangerousCard(p) or self:getValuableCard(p)) then
							target = p  break end
					end
				end
			elseif times == 3 then
				if self:isEnemy(p) then
					if self:damageIsEffective(p, nil, self.player) and not self:getDamagedEffects(p, self.player)
					and not self:needToLoseHp(p, self.player) and ((self:isWeak(p) and p:getHp() < 3) or self:getOverflow() > 3)  then
						target = p  break end
				end
			elseif times == 4 then
				if self:isFriend(p) and p:isWounded() then
					target = p  break end
			end
		end
	end
	if target and #to_discard == times then
		use.card = sgs.Card_Parse("#danshouCard:" .. table.concat(to_discard, "+") .. ":&danshou")
		if use.to then use.to:append(target) end
		return
	end
end
sgs.ai_use_priority.danshouCard = sgs.ai_use_priority.Dismantlement + 2
sgs.ai_use_value.danshouCard = sgs.ai_use_value.Dismantlement + 1
sgs.ai_card_intention.danshouCard = function(self, card, from, tos)
	local num = card:subcardsLength()
	if num == 2 or num == 3 then
		sgs.updateIntentions(from, tos, 10)
	elseif num == 4 then
		sgs.updateIntentions(from, tos, -10)
	end
end
sgs.ai_choicemade_filter.cardChosen.danshou = sgs.ai_choicemade_filter.cardChosen.snatch
sgs.ai_skill_exchange.danshou = function(self, pattern, max_num, min_num, expand_pile)
	local to_discard = {}
	local cards = self.player:getHandcards()
	local zhuran = sgs.findPlayerByShownSkillName("danshou")
	cards = sgs.QList2Table(cards)
	if self:isFriend(zhuran) then  --抄恩怨
		for _, card in ipairs(cards) do
			if isCard("Peach", card, zhuran) and ((not self:isWeak() and self:getCardsNum("Peach") > 0) or self:getCardsNum("Peach") > 1) then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
			if isCard("Analeptic", card, zhuran) and self:getCardsNum("Analeptic") > 1 then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
			if isCard("Jink", card, zhuran) and self:getCardsNum("Jink") > 1 then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
		end
	end
	self.player:setFlags("Global_AIDiscardExchanging")  --v2中exchange就是用discard进行的
	local to_exchange = self:askForDiscard("danshou", 1, 1, false, true)
	self.player:setFlags("-Global_AIDiscardExchanging")
	return to_exchange
end

-----张星彩-----

sgs.ai_skill_invoke.shenxian = function(self, data)
	self.room:getThread():delay(300)
	return true
end
sgs.ai_use_value.qiangwuCard = 8
sgs.ai_use_priority.qiangwuCard = 8
local qiangwu_skill = {}
qiangwu_skill.name = "qiangwu"
table.insert(sgs.ai_skills, qiangwu_skill)
qiangwu_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if not self.player:hasUsed("#qiangwuCard") then
		return sgs.Card_Parse("#qiangwuCard:.:&qiangwu")
	end
end
sgs.ai_skill_use_func["#qiangwuCard"] = function(card, use, self)
	if self:getCardsNum("Slash") > 0 then 
		use.card = card
	end
end