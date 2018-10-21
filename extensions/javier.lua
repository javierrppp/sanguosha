extension = sgs.Package("javier", sgs.Package_GeneralPack)
extension1 = sgs.Package("strengthen", sgs.Package_GeneralPack)
extension2 = sgs.Package("meng", sgs.Package_GeneralPack)

--===========================================武将区============================================--

--**********智包**********-----

zhangchunhua = sgs.General(extension, "zhangchunhua", "wei","3",false) 
zhangxiu = sgs.General(extension, "zhangxiu", "qun","3") 
huaxiong = sgs.General(extension, "huaxiong", "qun","6") 
sunhao = sgs.General(extension, "sunhao", "wu","6")
niujin = sgs.General(extension, "niujin", "wei","6")
liaohua = sgs.General(extension, "liaohua", "shu","5")
liubiao = sgs.General(extension, "liubiao", "qun","4")
bulianshi = sgs.General(extension, "bulianshi", "wu","3",false)
jianyong = sgs.General(extension, "jianyong", "shu","3")
xushu = sgs.General(extension, "xushu", "shu","4")
chenqun = sgs.General(extension, "chenqun", "wei","3")
liuxie = sgs.General(extension, "liuxie", "qun","3")
mizhu = sgs.General(extension, "mizhu", "shu","3")
buzhi = sgs.General(extension, "buzhi", "wu","3")
litong = sgs.General(extension, "litong", "wei","4")
liru = sgs.General(extension, "liru", "qun","3")
yufan = sgs.General(extension, "yufan", "wu","3")
xizhicai = sgs.General(extension, "xizhicai", "wei","3")
liyan = sgs.General(extension, "liyan", "shu","3")
zhugejin = sgs.General(extension, "zhugejin", "wu","3")
zhonghui = sgs.General(extension, "zhonghui", "wei","4")
chengyu = sgs.General(extension, "chengyu", "wei","3")
zumao = sgs.General(extension, "zumao", "wu","4")
zhoucang = sgs.General(extension, "zhoucang", "shu","4")
caimao = sgs.General(extension, "caimao", "qun","4")
hejin  = sgs.General(extension, "hejin", "qun","4")
miheng  = sgs.General(extension, "miheng", "qun","3")
masu = sgs.General(extension, "masu", "shu","3")
xuezong = sgs.General(extension, "xuezong", "wu","3")
maliang = sgs.General(extension, "maliang", "shu","3")
xushi = sgs.General(extension, "xushi", "wu","3", false)
wangji = sgs.General(extension, "wangji", "wei","3")
caojie = sgs.General(extension, "caojie", "qun","3", false)
chengong = sgs.General(extension, "chengong", "qun","3")
caochong = sgs.General(extension, "caochong", "wei","3")
xiahoushi = sgs.General(extension, "xiahoushi", "shu","3", false)
simalang = sgs.General(extension, "simalang", "wei" ,"3")
panzhangmazhong = sgs.General(extension, "panzhangmazhong", "wu", "4")
zhugeke = sgs.General(extension, "zhugeke", "wu", "3")
luji = sgs.General(extension, "luji", "wu", "3")
zhugedan = sgs.General(extension, "zhugedan", "wei", "4")
yanjun = sgs.General(extension, "yanjun", "wu", "3")

lord_sunquan = sgs.General(extension, "lord_sunquan$", "wu", 4, true, true)
lord_caocao = sgs.General(extension, "lord_caocao$", "wei", 4, true, true)

--**********加强包**********-----

caocao = sgs.General(extension1, "caocao", "wei","4",true,false,true) 
weiyan = sgs.General(extension1, "weiyan", "shu","4",true,false,true)
luxun = sgs.General(extension1, "luxun", "wu","3",true,false,true)
zhaoyun = sgs.General(extension1, "zhaoyun", "shu","4",true,false,true)
zhangfei = sgs.General(extension1, "zhangfei", "shu","4",true,false,true)
xusheng = sgs.General(extension1, "xusheng", "wu","4",true,false,true)
xiahouyuan = sgs.General(extension1, "xiahouyuan", "wei","4",true,false,true)
xiahoudun = sgs.General(extension1, "xiahoudun", "wei","4",true,false,true)
liubei = sgs.General(extension1, "liubei", "shu","4",true,false,true)

--**********猛包**********-----

meng_zhaoyun = sgs.General(extension2, "meng_zhaoyun", "shu","3")
meng_luxun = sgs.General(extension2, "meng_luxun", "wu","3")
meng_dianwei = sgs.General(extension2, "meng_dianwei", "wei","4")
meng_dongzhuo = sgs.General(extension2, "meng_dongzhuo", "qun","4")
meng_zhouyu = sgs.General(extension2, "meng_zhouyu", "wu","3")
meng_zhugeliang = sgs.General(extension2, "meng_zhugeliang", "shu","3")

--**********测试专用**********-----

gaoda = sgs.General(extension2, "gaoda", "qun","100", true, true, false)

--===========================================函数区============================================--

local isLiangjiang = function(player) --判断该武将是不是五良将
	if player:getRole() == "careerist" then return false end
	local is = false
	if player:getGeneralName() == "yujin" or player:getGeneralName() == "yuejin" or player:getGeneralName() == "xuhuang" or player:getGeneralName() == "zhangliao" or player:getGeneralName() == "zhanghe"  then
		is = true
	end
	if not is and player:getGeneralName() ~= "shalu_guojia" and player:getGeneralName() ~= "guojia" and player:getGeneralName() ~= "xunyu" and player:getGeneralName() ~= "chengyu" and player:getGeneralName() ~= "jiaxu" and player:getGeneralName() ~= "xunyou" then
		if player:getGeneral2Name() == "yujin" or player:getGeneral2Name() == "yuejin" or player:getGeneral2Name() == "xuhuang" or player:getGeneral2Name() == "zhangliao" or player:getGeneral2Name() == "zhanghe"  then
			is = true
		end
	end 
	return is
end
local isMouchen = function(player) --判断该武将是不是五谋臣
	if player:getRole() == "careerist" then return false end
	local is = false
	if player:getGeneralName() == "shalu_guojia" or player:getGeneralName() == "guojia" or player:getGeneralName() == "xunyu" or player:getGeneralName() == "chengyu" or player:getGeneralName() == "jiaxu" or player:getGeneralName() == "xunyou"  then
		is = true
	end
	if not is and player:getGeneralName() ~= "yujin" and player:getGeneralName() ~= "yuejin" and player:getGeneralName() ~= "xuhuang" and player:getGeneralName() ~= "zhangliao" and player:getGeneralName() ~= "zhanghe" then
		if player:getGeneral2Name() == "shalu_guojia" or player:getGeneral2Name() == "guojia" or player:getGeneral2Name() == "xunyu" or player:getGeneral2Name() == "chengyu" or player:getGeneral2Name() == "jiaxu" or player:getGeneral2Name() == "xunyou"  then
			is = true
		end
	end
	return is
end
local getMouchenNum = function(room) --获得五谋臣的个数
	local num = 0
	for _, player in sgs.qlist(room:getAlivePlayers()) do
		if player:getRole() ~= "careerist" then
			if player:getGeneralName() == "shalu_guojia" or player:getGeneralName() == "guojia" or player:getGeneralName() == "xunyu" or player:getGeneralName() == "chengyu" or player:getGeneralName() == "jiaxu" or player:getGeneralName() == "xunyou" then
				num = num + 1
			elseif player:getGeneral2Name() == "shalu_guojia" or player:getGeneral2Name() == "guojia" or player:getGeneral2Name() == "xunyu" or player:getGeneral2Name() == "chengyu" or player:getGeneral2Name() == "jiaxu" or player:getGeneral2Name() == "xunyou" then
				num = num + 1
			end
		end
	end
	return num
end
local getLiangjiangNum = function(room) --获得五良将的个数
	local num = 0
	for _, player in sgs.qlist(room:getAlivePlayers()) do
		if player:getRole() ~= "careerist" then
			if player:getGeneralName() == "yujin" or player:getGeneralName() == "yuejin" or player:getGeneralName() == "xuhuang" or player:getGeneralName() == "zhangliao" or player:getGeneralName() == "zhanghe"  then
				num = num + 1
			elseif player:getGeneral2Name() == "yujin" or player:getGeneral2Name() == "yuejin" or player:getGeneral2Name() == "xuhuang" or player:getGeneral2Name() == "zhangliao" or player:getGeneral2Name() == "zhanghe"  then
				num = num + 1
			end
		end
	end
	return num
end

--===========================================技能区============================================--

--**********智包**********-----

-----严畯-----

guanchao = sgs.CreateTriggerSkill{
	name = "guanchao",
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self:objectName()) then	
			if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Play then
				return self:objectName()
			elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Play then
				local card_ids = player:property("guanchaoProp"):toString():split("+")
				room:setPlayerProperty(player, "guanchaoProp", sgs.QVariant(""))
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, card in sgs.qlist(player:getHandcards()) do 
					if table.contains(card_ids, tostring(card:getId())) then 
						dummy:addSubcard(card)
					end
				end
				if dummy:getSubcards():length() > 0 then
					room:broadcastSkillInvoke(self:objectName())
					room:throwCard(dummy, player)
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local sort_list = {}
		local card_list = {}
		for i = 0, 1000, 1 do 
			local judge = sgs.JudgeStruct()
			if #sort_list == 0 then
				judge.pattern = "."
			elseif #sort_list == 1 then
				local pattern = "~" .. sort_list[1] - 1 .. "," .. sort_list[1] + 1 .. "~"
				judge.pattern = ".|.|" .. pattern
				--sendMsg(room, "pattern:" .. judge.pattern)
				--judge.pattern = ".|.|^" .. sort_list[1]
			else 
				if sort_list[1] < sort_list[2] then
					judge.pattern = ".|.|" .. sort_list[#sort_list] + 1 .. "~"
				elseif sort_list[1] > sort_list[2] then
					judge.pattern = ".|.|~" .. sort_list[#sort_list] - 1
				else 
					sendMsg("judge error")
					break
				end
			end
			judge.good = true
			judge.reason = self:objectName()
			judge.who = player
			room:judge(judge)
			if judge:isGood() then
				table.insert(sort_list, judge.card:getNumber())
				table.insert(card_list, judge.card:getId())
			else
				break
			end
		end
		room:setPlayerProperty(player, "guanchaoProp", sgs.QVariant(table.concat(card_list, "+")))
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, id in pairs(card_list) do 
			dummy:addSubcard(sgs.Sanguosha:getCard(id))
		end
		player:obtainCard(dummy)
		return false
	end
}
xunxianCard = sgs.CreateSkillCard{
	name = "xunxianCard",
	skill_name = "xunxian",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
		effect.to:obtainCard(self)
	end
}
xunxianVS = sgs.CreateViewAsSkill{
	name = "xunxian",
	n = 1,
	view_filter = function(self, selected, to_select)
		local card_id = sgs.Self:property("xunxianProp"):toInt()
		local suit = sgs.Sanguosha:getCard(card_id):getSuit()
		return to_select:getSuit() == suit and to_select:getId() ~= card_id and (not sgs.Self:isJilei(to_select))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local xunxiancard = xunxianCard:clone()
			xunxiancard:addSubcard(cards[1])
			return xunxiancard 
		end  
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@xunxian"
	end,
	enabled_at_play = function(self, player)
		return false
	end
}
xunxian = sgs.CreateTriggerSkill{
	name = "xunxian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded},
	view_as_skill = xunxianVS,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local card 
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("EquipCard") or use.card:isKindOf("TrickCard") then 		--防止技能卡也进入判断
				card = use.card
			end
		elseif event == sgs.CardResponded then
			local response = data:toCardResponse()
			if response.m_isUse == false then return "" end
			card = response.m_card
		end
		if not card or card:getSuit() == sgs.Card_NoSuit then return "" end
		local can_invoke = false
		if player:isNude() then return "" end
		for _, c in sgs.qlist(player:getHandcards()) do 
			if card:getSuit() == c:getSuit() then
				can_invoke = true
			end
		end
		for _, c in sgs.qlist(player:getEquips()) do 
			if card:getSuit() == c:getSuit() then
				can_invoke = true
			end
		end
		if can_invoke then
			room:setPlayerProperty(player, "xunxianProp", sgs.QVariant(card:getId()))
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card_id = player:property("xunxianProp"):toInt()
		local suit = sgs.Sanguosha:getCard(card_id):getSuitString()
		if room:askForUseCard(player, "@@xunxian", "@xunxian-card:::" .. suit, -1, sgs.Card_MethodNone) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:notifySkillInvoked(player, self:objectName())
		return false
	end,
}
yanjun:addSkill(guanchao)
yanjun:addSkill(xunxian)

-----陆绩-----

huaijv = sgs.CreateTriggerSkill{
	name = "huaijv",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self:objectName()) then	
			if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Start then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:gainMark("@orange")
	end
}
huaijvDraw = sgs.CreateTriggerSkill{
	name = "#huaijv_draw",
	global = true,
	events = {sgs.DrawNCards},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive())then return "" end
		if player:getMark("@orange") > 0 and player:getHandcardNum() < player:getHp() then return self:objectName() end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("huaijv")
		local luji = room:findPlayerBySkillName("huaijv")
		room:doAnimate(1, luji:objectName(), player:objectName())
		local value = data:toInt()
		local new_value = value + 1
		data:setValue(new_value)
	end
}
huaijvDamageInflicted = sgs.CreateTriggerSkill{
	name = "#huaijv_damageInflicted",
	global = true,
	events = {sgs.DamageInflicted, sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if damage.to and damage.to:isAlive() then 
				if damage.to:getMark("@orange") > 0 then
					return self:objectName(), damage.to
				end
			end
		elseif event == sgs.Damaged and player:getMark("@orange") > 0 then
			player:loseMark("@orange")
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:broadcastSkillInvoke("huaijv")
		local luji = room:findPlayerBySkillName("huaijv")
		local damage = data:toDamage()
		if damage.damage > 1 then
			local msg = sgs.LogMessage()
			msg.type, msg.from, msg.arg = "#huaijv", luji, damage.damage
			room:sendLog(msg)
		end
		room:doAnimate(1, luji:objectName(), player:objectName())
		damage.damage = 1
		data:setValue(damage)
		return false
	end,
}
huaijvDying = sgs.CreateTriggerSkill{
	name = "#huaijv_dying",
	global = true,
	events = {sgs.Dying},
	can_trigger = function(self, event, room, player, data)
		local dying = data:toDying()
		if dying.who:getMark("@orange") > 0 then
			return self:objectName(), dying.who
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if ask_who:getHp() > 0 then return false end
		room:broadcastSkillInvoke("huaijv")
		local luji = room:findPlayerBySkillName("huaijv")
		room:doAnimate(1, luji:objectName(), player:objectName())
		local num = 1 - ask_who:getHp()
		ask_who:loseAllMarks("@orange")
		local recover = sgs.RecoverStruct()
		recover.who = ask_who
		recover.recover = num
		room:recover(ask_who, recover)
		return false
	end,
}
yiliCard = sgs.CreateSkillCard{
	name = "yiliCard",
	skill_name = "yili",
	mute = true,
	filter = function(self, selected, to_select)
		if #selected >= sgs.Self:getMark("@orange") then return false end
		return to_select:getMark("@orange") == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("yili")
		source:loseMark("@orange", #targets)
		for _, p in pairs(targets) do
			p:gainMark("@orange")
		end
	end,
}
yili = sgs.CreateZeroCardViewAsSkill{
	name = "yili",
	view_as = function(self) 
		local card = yiliCard:clone()
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@orange") > 0
	end
}
zhenglunCard = sgs.CreateSkillCard{
	name = "zhenglunCard",
	skill_name = "zhenglun",
	mute = true,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("zhenglun")
		room:loseHp(source, 1)
		source:gainMark("@orange")
		if source:getMark("@orange") <= source:getMaxHp() then
			source:drawCards(1)
		end
	end,
}
zhenglun = sgs.CreateZeroCardViewAsSkill{
	name = "zhenglun",
	view_as = function(self) 
		local card = zhenglunCard:clone()
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#zhenglunCard") < 2
	end
}
luji:addSkill(huaijv)
luji:addSkill(huaijvDraw)
luji:addSkill(huaijvDamageInflicted)
luji:addSkill(huaijvDying)
luji:addSkill(yili)
luji:addSkill(zhenglun)
sgs.insertRelatedSkills(extension, "huaijv", "#huaijv_draw")
sgs.insertRelatedSkills(extension, "huaijv", "#huaijv_damageInflicted")
sgs.insertRelatedSkills(extension, "huaijv", "#huaijv_dying")

-----诸葛诞-----

gongao = sgs.CreateTriggerSkill{
	name = "gongao",
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.EventLoseSkill},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)	
		if player and player:isAlive() and player:hasSkill(self:objectName()) then
			local phase = player:getPhase()
			if event == sgs.EventPhaseStart and phase == sgs.Player_Play then
				if player:getHandcardNum() > 1 then
					return self:objectName()
				end
			elseif event == sgs.EventPhaseEnd and phase == sgs.Player_Play then
				return self:objectName()
			end
			if event == sgs.EventPhaseEnd and phase == sgs.Player_Finish then 
				if player:getPile("gong"):length() > 0 then
					return self:objectName()
				end
			end
		end
		if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			player:clearOnePrivatePile("gong")
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		local num = math.floor(player:getHandcardNum() / 2)
		if event == sgs.EventPhaseStart then
			room:broadcastSkillInvoke(self:objectName())
			local exc_card = room:askForExchange(player, self:objectName(), num, num, "gongaoExchange:::"..num, "", ".|.|.|hand")
			if not exc_card then
				exc_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for p = 0, num-1, 1 do
					exc_card:addSubcard(player:getHandcards():at(p))
				end
			end
			player:addToPile("gong", exc_card:getSubcards(), false)
			exc_card:deleteLater()
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Play then
				if player:getHandcardNum() > 1 then
					room:broadcastSkillInvoke(self:objectName())
					local phases = sgs.PhaseList()
					phases:append(sgs.Player_Play)
					player:play(phases)
				else
					local phases = sgs.PhaseList()
					phases:append(sgs.Player_Discard)
					phases:append(sgs.Player_Finish)
					player:play(phases)
				end
			elseif player:getPhase() == sgs.Player_Finish then
				room:broadcastSkillInvoke(self:objectName())
				local to_draw = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, c in sgs.qlist(player:getPile("gong")) do
					local ccc = sgs.Sanguosha:getCard(c)
					to_draw:addSubcard(ccc)
				end
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName(), player:objectName(), self:objectName(),"")
				room:moveCardTo(to_draw, player, sgs.Player_PlaceHand, reason)
			end
		end
		return false
	end
}
weizhong = sgs.CreateTriggerSkill{
	name = "weizhong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)	
		if player and player:isAlive() and player:hasShownOneGeneral() then
			local zhugedan = room:findPlayersBySkillName(self:objectName())
			for _, p in sgs.qlist(zhugedan) do 
				if p:hasShownOneGeneral() then
					if player:objectName() == p:objectName() or (player:getKingdom() == p:getKingdom() and player:getRole() ~= "careerist" and p:getRole() ~= "careerist") then 
						if p:getHandcardNum() < p:getMaxHp() then
							return self:objectName(), p
						end
					end
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if not ask_who:hasShownSkill(self:objectName()) and room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		if ask_who:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(ask_who, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:broadcastSkillInvoke(self:objectName())
		ask_who:drawCards(1)
		return false
	end
}
zhugedan:addSkill(gongao)
zhugedan:addSkill(weizhong)

-----诸葛恪-----
aocaiMove = sgs.CreateTriggerSkill{
	name = "#aocai_move",
	global = true,
	events={sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		local zhugeke = room:findPlayerBySkillName("aocai")
		if not zhugeke then return "" end
		local old_ids_list = zhugeke:property("aocaiPileCard"):toString():split("+")
		if zhugeke:property("aocaiPileCard"):toString() ~= "" and zhugeke:property("aocaiPileCard") ~= nil then
			room:setPlayerProperty(zhugeke, "aocaiPileCard", sgs.QVariant(""))
			local old_ids = sgs.IntList()
			for _, c in pairs(old_ids_list) do 
				old_ids:append(tonumber(c))
			end
			room:notifyMoveToPile(player, old_ids, "aocai", sgs.Player_DrawPile, false, false)
		end
		
		local ids = sgs.IntList()
		ids:append(room:getDrawPile():at(0))
		ids:append(room:getDrawPile():at(1))
		local id_table = {}
		for _, id in sgs.qlist(ids) do 
			table.insert(id_table, id)
		end
		
		room:setPlayerProperty(zhugeke, "aocaiPileCard", sgs.QVariant(table.concat(id_table, "+")))
		room:notifyMoveToPile(player, ids, "aocai", sgs.Player_DrawPile, true, true)
		--[[local ids_table = {}
		table.insert(ids_table, room:getDrawPile():at(0))
		table.insert(ids_table, room:getDrawPile():at(1))
		sendMsg(room, "length:"..#ids_table)
		for _, id in pairs(ids_table) do 
			sendMsg(room, ".."..id)
		end
		room:setPlayerProperty(zhugeke, "aocaiPileCard", sgs.QVariant(table.concat(ids_table, "+")))--]]
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return false
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		return false
	end
}
aocaiCard = sgs.CreateSkillCard{
	name = "aocaiCard",
	skill_name = "aocai",
	will_throw = false,
	filter = function(self, targets, to_select)
		local pattern = sgs.Self:property("aocaiPattern"):toString()
		local usereason = sgs.Self:property("aocaiReason"):toString()
		if pattern == "jink" or (pattern == "slash" and usereason == "response") or pattern == "peach+analeptic" then
			return false
		else
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local c_card = sgs.Sanguosha:cloneCard(card:objectName())
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			return c_card and c_card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, c_card, plist)
		end
	end ,
	feasible = function(self, targets)
		local usereason = sgs.Self:property("aocaiReason"):toString()
		local pattern = sgs.Self:property("aocaiPattern"):toString()
		if pattern == "jink" or (pattern == "slash" and usereason == "response") or pattern == "peach+analeptic" then
			return #targets == 0
		else
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local c_card = sgs.Sanguosha:cloneCard(card:objectName())
			local plist = sgs.PlayerList()
			for i = 1, #targets do plist:append(targets[i]) end
			return c_card and c_card:targetsFeasible(plist, sgs.Self)
		end
	end,
	on_use = function(self, room, source, targets)
		local usereason = source:property("aocaiReason"):toString()
		local pattern = source:property("aocaiPattern"):toString()
		if pattern == "jink" or (pattern == "slash" and usereason == "response") then
			room:provide(self)
			return true
		else
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local c_card = sgs.Sanguosha:cloneCard(card:objectName())
			local plist = sgs.SPlayerList()
			c_card:addSubcard(card)
			for i = 1, #targets do plist:append(targets[i]) end
			room:useCard(sgs.CardUseStruct(c_card, source, plist), true) 
		end
	end
}
aocaiVS = sgs.CreateViewAsSkill{
	name = "aocai",
	expand_pile = "#aocai",
	view_filter = function(self, selected, to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		local card_ids = sgs.Self:property("aocaiPileCard"):toString():split("+")
		local names = pattern:split("+")
		if pattern == "@@aocai" then names = sgs.Self:property("aocaiPattern"):toString():split("+") end
		if table.contains(names, "slash") then
			table.insert(names,"fire_slash")
			table.insert(names,"thunder_slash")
		end
		return #selected == 0 and table.contains(card_ids, tostring(to_select:getId())) and table.contains(names, sgs.Sanguosha:getCard(to_select:getId()):objectName())
	end,
	view_as = function(self, cards)
		local card
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if #cards == 0 then return false end
		card = aocaiCard:clone()
		card:setShowSkill(self:objectName())
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		card:setUserString(pattern)
		return card
	end,
	enabled_at_response = function(self, player, pattern)
		if player:getPhase() ~= sgs.Player_NotActive then return end
		if pattern == "slash" then
			return sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		elseif (pattern == "peach") then
			return not player:hasFlag("Global_PreventPeach")
		elseif string.find(pattern, "analeptic") then
			return true
		elseif pattern == "@@aocai" then
			return true
		end
		return false
	end,
	enabled_at_play = function(self, player)
		return false
	end
}
aocai = sgs.CreateTriggerSkill{
	name = "aocai",
	view_as_skill = aocaiVS,
	events={sgs.CardAsked},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() ~= sgs.Player_NotActive then return end
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		if (pattern == "slash" or pattern == "jink") then
			return self:objectName()
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if room:askForSkillInvoke(player, self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true
		end
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		--[[local ids = sgs.IntList()
		ids:append(room:getDrawPile():at(0))
		ids:append(room:getDrawPile():at(1))
		local id_table = {}
		for _, id in sgs.qlist(ids) do 
			table.insert(id_table, id)
		end--]]
		local pattern = data:toStringList()[1]
		--room:setPlayerProperty(ask_who, "aocaiPileCard", sgs.QVariant(table.concat(id_table, "+")))
		room:setPlayerProperty(ask_who, "aocaiPattern", sgs.QVariant(pattern))
		room:setPlayerProperty(ask_who, "aocaiReason", sgs.QVariant("response"))
		--room:notifyMoveToPile(ask_who, ids, self:objectName(), sgs.Player_DrawPile, true, true)
		local invoked = room:askForUseCard(ask_who, "@@aocai", "@aocai", -1, sgs.Card_MethodNone)
		--room:notifyMoveToPile(ask_who, ids, self:objectName(), sgs.Player_DrawPile, false, false)
		room:setPlayerProperty(ask_who, "aocaiPattern", sgs.QVariant())
		--room:setPlayerProperty(ask_who, "aocaiPileCard", sgs.QVariant())
		room:setPlayerProperty(ask_who, "aocaiReason", sgs.QVariant())
		if invoked then return true end
		return false
	end
}
duwu = sgs.CreateViewAsSkill{
	name = "duwu",
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		local card = duwuCard:clone()
		if #cards == 0 then return false end
		card:setShowSkill(self:objectName())
		card:setSkillName(self:objectName())
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#duwuCard")
	end
}
duwuCard = sgs.CreateSkillCard{
	name = "duwuCard",
	skill_name = "duwu",
	will_throw = true,
	mute = true,
	filter = function(self, targets, to_select, player)
		local attackRange = false
		if player:getWeapon() and self:getSubcards():contains(player:getWeapon():getId()) then
			local weapon = player:getWeapon():getRealCard():toWeapon()
			local distance_fix = weapon:getRange() - player:getAttackRange(false)
			if player:getOffensiveHorse() and self:getSubcards():contains(player:getOffensiveHorse():getId()) then
				distance_fix = distance_fix + 1
			end
			attackRange = inMyAttackRangeFromV2(player, to_select, distance_fix)
		elseif player:getOffensiveHorse() and self:getSubcards():contains(player:getOffensiveHorse():getId()) then
			attackRange = inMyAttackRangeFromV2(player, to_select, 1)
		else
			attackRange = player:inMyAttackRange(to_select)
		end
		return to_select:getHandcardNum() == self:getSubcards():length() and attackRange and to_select:objectName() ~= player:objectName()
	end ,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		local to = targets[1]
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = to
		damage.damage = 1
		room:damage(damage)
	end
}
zhugeke:addSkill(aocai)
zhugeke:addSkill(aocaiMove)
zhugeke:addSkill(duwu)
sgs.insertRelatedSkills(extension, "aocai", "#aocai_move")

-----潘璋马忠-----

duodao = sgs.CreateTriggerSkill{
	name = "duodao",
	can_preshow = true,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)	
		local damage = data:toDamage()
		if player and player:isAlive() and player:hasSkill(self:objectName()) and player:canDiscard(player, "he") then
			if damage.card and damage.card:isKindOf("Slash") then
				return self:objectName() .. "->" .. damage.from:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if room:askForCard(ask_who, "..", "@duodao-get", data, self:objectName()) then
			room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true
		end
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if ask_who:isAlive() and player:isAlive() and player:getWeapon() then
			room:obtainCard(ask_who, player:getWeapon(), sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, ask_who:objectName(), player:objectName(), self:objectName(), ""))
		end
		return false
	end
}
anjian = sgs.CreateTriggerSkill{
	name = "anjian",
	events = {sgs.DamageCaused},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self) then
			local damage = data:toDamage()
			if damage.to and damage.to:isAlive() and not (damage.to:inMyAttackRange(damage.from) or damage.to:objectName() == damage.from:objectName()) then 
				if damage.card and damage.card:isKindOf("Slash") and not (damage.chain or damage.transfer or not damage.by_user) then
					return self:objectName() .. "->" .. damage.to:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		local d = sgs.QVariant()
		d:setValue(player)
		ask_who:setTag("anjianDamage", data)  --for AI
		local invoked = ask_who:hasShownSkill(self:objectName()) or room:askForSkillInvoke(ask_who, self:objectName(), d)
		ask_who:removeTag("anjianDamage")
		if invoked then
			room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true
		end
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:notifySkillInvoked(ask_who, self:objectName())
		local damage = data:toDamage()
		local log = sgs.LogMessage()
		log.type = "#anjianBuff"
		log.from = ask_who
		log.to:append(player)
		log.arg = damage.damage
		log.arg2 = damage.damage + 1
		room:sendLog(log)
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end,
}
panzhangmazhong:addSkill(duodao)
panzhangmazhong:addSkill(anjian)

-----司马朗-----

junbing = sgs.CreateTriggerSkill{
	name = "junbing",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = sgs.EventPhaseStart,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local simalang = room:findPlayersBySkillName(self:objectName())
		if player:getPhase() ~= sgs.Player_Finish then return "" end
		for _, p in sgs.qlist(simalang) do 
			if p:objectName() == player:objectName() or (p:objectName() ~= player:objectName() and p:hasShownSkill(self:objectName())) then
				if player:getHandcardNum() < 2 then 
					local d = sgs.QVariant()
					d:setValue(p)
					player:setTag("junbingTag", d)
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		local to = ask_who:getTag("junbingTag"):toPlayer()
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			room:notifySkillInvoked(to, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		ask_who:removeTag("junbingTag")
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		ask_who:drawCards(1)
		room:getThread():delay(300)
		local to = ask_who:getTag("junbingTag"):toPlayer()
		ask_who:removeTag("junbingTag")
		if ask_who:objectName() == to:objectName() then return false end
		local num = ask_who:getHandcardNum()
		local dummy = sgs.DummyCard()
		dummy:addSubcards(ask_who:getHandcards())
		room:obtainCard(to, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, ask_who:objectName(), to:objectName(), self:objectName(), ""), false)
		dummy:deleteLater() 
		local exc_card = room:askForExchange(to, self:objectName(), num, num, "junbingExchange::"..ask_who:objectName()..":"..num, "", ".|.|.|hand")
		if not exc_card then
			exc_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for p = 0, num-1, 1 do
				exc_card:addSubcard(to:getHandcards():at(p))
			end
		end
		room:obtainCard(ask_who, exc_card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, to:objectName(), ask_who:objectName(), self:objectName(), ""), false)
		return false
	end
}
qujiCard = sgs.CreateSkillCard{
	name = "qujiCard",
	skill_name = "quji",
    will_throw = true,
	mute = true,
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then
			return false
		elseif #targets == 0 then
			return to_select:isWounded()
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		local to = targets[1]
		local recover = sgs.RecoverStruct()
		recover.who = source
		room:recover(to, recover)
	end
}
qujiVS = sgs.CreateViewAsSkill{
	name = "quji",
	response_pattern = "@@quji",
	view_filter = function(self, selected, to_select)
		if sgs.Self:isJilei(to_select) then return false end
		local num = sgs.Self:getHp()
		local suit
		if sgs.Self:getMark("qujispade") > 0 then
			suit = sgs.Card_Spade
		elseif sgs.Self:getMark("qujiheart") > 0 then
			suit = sgs.Card_Heart
		elseif sgs.Self:getMark("qujiclub") > 0 then
			suit = sgs.Card_Club
		elseif sgs.Self:getMark("qujidiamond") > 0 then
			suit = sgs.Card_Diamond
		end
		if #selected < num then 
			return to_select:getSuit() == suit
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards ~= sgs.Self:getHp() then return nil end
		local card = qujiCard:clone()
		card:setShowSkill(self:objectName())
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
}
quji = sgs.CreateTriggerSkill{
	name = "quji",
	can_preshow = true,
	view_as_skill = qujiVS ,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged, sgs.DamageComplete},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.DamageComplete then
			room:setPlayerMark(player, "qujispade", 0)
			room:setPlayerMark(player, "qujiheart", 0)
			room:setPlayerMark(player, "qujiclub", 0)
			room:setPlayerMark(player, "qujidiamond", 0)
			return ""
		elseif event == sgs.Damaged then
			if player:getHandcardNum() + player:getEquips():length() < player:getHp() then return "" end
			local damage = data:toDamage()
			if not damage.card then return "" end
			if damage.card:getSuit() == sgs.Card_NoSuit then return "" end
			local can_invoke = false
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do 
				if p:isWounded() then
					can_invoke = true
				end
			end
			if can_invoke then	
				room:addPlayerMark(player, "quji"..damage.card:getSuitString())
				return self:objectName()
			end
			return ""
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		local suit
		if player:getMark("qujispade") > 0 then
			suit = "黑桃"
		elseif player:getMark("qujiheart") > 0 then
			suit = "红桃"
		elseif player:getMark("qujiclub") > 0 then
			suit = "梅花"
		elseif player:getMark("qujidiamond") > 0 then
			suit = "方片"
		end
		if room:askForUseCard(player, "@@quji", "@qujiCard:::"..player:getHp()..":"..suit, -1, sgs.Card_MethodDiscard) then
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		return false
	end
}
simalang:addSkill(junbing)
simalang:addSkill(quji)

-----夏侯氏-----

function yanyuAsMovePattern(selected, to_select)
	local can_move = true
	local to_select_card = sgs.Sanguosha:getCard(to_select)
	for _,id in ipairs(selected) do
		local card = sgs.Sanguosha:getCard(id)
		if card:getSuit() ~= to_select_card:getSuit() then
			can_move = false
		end
	end
	return can_move
end
yanyuCard = sgs.CreateSkillCard{
	name = "yanyuCard",
	skill_name = "yanyu",
	will_throw = true,
	target_fixed=true,
	on_use = function(self, room, source, targets)
		if not source:isAlive() then return false end
		local num = source:getMaxHp()
		if num > 5 then num = 5 end
		local card_ids = room:getNCards(num, true)
		local result = room:askForMoveCards(source, card_ids, sgs.IntList(), true, "yanyu", "yanyuAsMovePattern", self:objectName(), 1, num, false, true)
		local dummy = sgs.DummyCard()
		if not result.bottom:isEmpty() then
			dummy:addSubcards(result.bottom)
			source:obtainCard(dummy)
		end
		if not result.top:isEmpty() then
			dummy:clearSubcards()
			dummy:addSubcards(result.top)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, source:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		end
		dummy:deleteLater()
		return false
	end
}
yanyu = sgs.CreateOneCardViewAsSkill{
	name = "yanyu",
	view_filter = function(self, card)
		return card:isKindOf("Slash")
	end,
	view_as = function(self, originalCard)
		local card = yanyuCard:clone()
		card:addSubcard(originalCard)
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#yanyuCard") < 2
	end
}
yanyu_give = sgs.CreateTriggerSkill{
	name = "#yanyu_give",
	global = true,
	events = {sgs.EventPhaseEnd},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill("yanyu") then return "" end
		if player:getPhase() == sgs.Player_Play then
			if player:usedTimes("#yanyuCard") == 2 then
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					if p:isMale() then
						return self:objectName()
					end
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do 
			if p:isMale() then
				targets:append(p)
			end
		end
		local to = room:askForPlayerChosen(player, targets, "yanyu", "yanyu-choose", true, true)
		if to then
			room:broadcastSkillInvoke("yanyu")
			local d = sgs.QVariant()
			d:setValue(to)
			player:setTag("yanyueffect", d)
			player:showGeneral(player:inHeadSkills(self:objectName()))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local to = player:getTag("yanyueffect"):toPlayer()
		to:drawCards(2)
		player:removeTag("yanyueffect")
		return false
	end
}
qiaoshi = sgs.CreateTriggerSkill{
	name = "qiaoshi",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = sgs.EventPhaseStart,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local xiahoushi = room:findPlayersBySkillName(self:objectName())
		if player:getPhase() ~= sgs.Player_Finish then return "" end
		for _, p in sgs.qlist(xiahoushi) do 
			if player:objectName() ~= p:objectName() and player:getHandcardNum() == p:getHandcardNum() then 
				return self:objectName(), p
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		ask_who:drawCards(1)
		player:drawCards(1)
		return false
	end
}
xiahoushi:addSkill(qiaoshi)
xiahoushi:addSkill(yanyu)
xiahoushi:addSkill(yanyu_give)
sgs.insertRelatedSkills(extension, "yanyu", "#yanyu_give")

-----曹冲-----

function chengxiangAsMovePattern(selected, to_select)
	local sum = 0
	for _,id in ipairs(selected) do
		sum = sum + sgs.Sanguosha:getCard(id):getNumber()
	end
	if to_select ~= -1 then
		sum = sum + sgs.Sanguosha:getCard(to_select):getNumber()
	end
	return sum <= 13
end
chengxiang = sgs.CreateTriggerSkill{
	name = "chengxiang",
	can_preshow = true,
	frequency = sgs.Skill_Frequent,
	events = sgs.Damaged,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		local card_ids = room:getNCards(4, false)
		local numbers = {}
		for _,id in sgs.qlist(card_ids) do
			table.insert(numbers, sgs.Sanguosha:getCard(id):getNumber())
		end
		table.sort(numbers)
		local max_cards, min_sum = 0, 0
		for _,num in ipairs(numbers) do
			min_sum = min_sum + num
			if min_sum <= 13 then max_cards = max_cards + 1 end
		end
		
		local result = room:askForMoveCards(player, card_ids, sgs.IntList(), true, self:objectName(), "chengxiangAsMovePattern", self:objectName(), 1, max_cards, false, true)
		local dummy = sgs.DummyCard()
		if not result.bottom:isEmpty() then
			dummy:addSubcards(result.bottom)
			player:obtainCard(dummy)
		end
		if not result.top:isEmpty() then
			dummy:clearSubcards()
			dummy:addSubcards(result.top)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		end
		dummy:deleteLater()
		return false
	end,
}
renxin = sgs.CreateTriggerSkill{
	name = "renxin",
	can_preshow = true,
	events = {sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.to and damage.to:isAlive() then 
			if damage.to:getHp() == 1 then
				local skill_list, player_list = {}, {}
				for _,p in sgs.qlist(room:getOtherPlayers(damage.to)) do
					if p:hasSkill(self:objectName()) and p:canDiscard(p, "he") then
						table.insert(skill_list, self:objectName())
						table.insert(player_list, p:objectName())
					end
				end
				return table.concat(skill_list, "|"), table.concat(player_list, "|")
			end
		end
		return ""
		--[[elseif (event == sgs.ChoiceMade) and player:hasSkill(self:objectName()) then  --根据规则翻面已改为效果而非消耗
			local data_list = data:toString():split(":")
			if (#data_list > 3) and (data_list[3] == "@renxin-card") and (data_list[#data_list] ~= "_nil_") then
				player:turnOver()
			end
		end]]
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if room:askForCard(ask_who, ".Equip", "@renxin-card:" .. player:objectName(), data, self:objectName()) then
			room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		ask_who:turnOver()
		local msg = sgs.LogMessage()
		msg.type, msg.from, msg.arg = "#renxin", player, self:objectName()
		room:sendLog(msg)
		return true
	end,
}
caochong:addSkill(chengxiang)
caochong:addSkill(renxin)

-----曹节-----

shouxi = sgs.CreateTriggerSkill{
	name = "shouxi",
	can_preshow = true,
	events = {sgs.TargetConfirming, sgs.EventLoseSkill},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self) then return "" end
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return "" end
		if use.to:contains(player) then 
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data)
		local id = room:getNCards(1):first()
		local move = sgs.CardsMoveStruct(id, nil, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "shouxi", ""))
		room:moveCardsAtomic(move, true)
		room:getThread():delay(1000)
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("EquipCard") then return false end
		local has = false
		for _, c in sgs.qlist(player:getPile("shouxiPile")) do 
			local c_card = sgs.Sanguosha:getCard(c)
			if card:objectName() == c_card:objectName() then
				has = true
			end
		end
		if has == true then 
			room:throwCard(id, player)
			return false 
		end
		player:addToPile("shouxiPile", id) 
		local use = data:toCardUse()
		local nullified_list = use.nullified_list
		room:setEmotion(player, "cancel")
		table.insert(nullified_list, player:objectName())
		use.nullified_list = nullified_list
		data:setValue(use)
		return false
	end
}
huimin = sgs.CreateTriggerSkill{
	name = "huimin",
	can_preshow = true,
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self) then return "" end
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			for _, p in sgs.qlist(room:getAlivePlayers()) do 
				if p:getHandcardNum() < p:getHp() then
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data)
		local num = 0 
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do 
			if p:getHandcardNum() < p:getHp() then
				num = num + 1
				targets:append(p)
				room:doAnimate(1, player:objectName(), p:objectName())
			end
		end
		player:drawCards(num)
		local exc_card = room:askForExchange(player, self:objectName(), num, num, "huiminExchange:::"..num, "", ".|.|.|hand")
		if not exc_card then
			exc_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for p = 0, num-1, 1 do
				exc_card:addSubcard(player:getHandcards():at(p))
			end
		end
		local huimin_cards = exc_card:getSubcards()
		local to = room:askForPlayerChosen(player, targets, self:objectName(), "huimin-choose", true, true)
		if not to then to = targets:first() end
		local move = sgs.CardsMoveStruct(exc_card:getSubcards(), nil, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "huimin", ""))
		room:moveCardsAtomic(move, true)
		local target_list = {}
		--[[for _, p in sgs.qlist(targets) do 
			table.insert(target_list, p)
		end--]]
		local begin = false
		for _, p in sgs.qlist(targets) do 
			if p:objectName() == to:objectName() then
				begin = true
			end
			if begin then
				table.insert(target_list, p)
			end
		end
		for _, p in sgs.qlist(targets) do 
			if p:objectName() == to:objectName() then break end
			table.insert(target_list, p)
		end
		local current_player = to
		room:fillAG(huimin_cards)
		local t = sgs.SPlayerList()
		for _, p in pairs(target_list) do 
			local id = room:askForAG(p, huimin_cards, false, self:objectName())
			room:takeAG(p, id, true)
			table.removeOne(target_list, p:objectName())
			huimin_cards:removeOne(id)
			if huimin_cards:length() == 0 then break end
		end
		--[[while true do
			if table.contains(target_list, current_player:objectName()) then
				local id = room:askForAG(current_player, huimin_cards, false, self:objectName())
				room:takeAG(current_player, id, true)
				table.removeOne(target_list, current_player:objectName())
				huimin_cards:removeOne(id)
			end
			current_player = current_player:getNextAlive()
			if t:contains(current_player) then break else t:append(current_player) end
			if huimin_cards:length() == 0 then break end
		end--]]
		room:clearAG()
		return false
	end
}
caojie:addSkill(shouxi)
caojie:addSkill(huimin)
-----陈宫-----

function findmingceTarget(source)
	local slash_targets = sgs.PlayerList()
	if sgs.Slash_IsAvailable(source) then
		for _, p in sgs.qlist(source:getAliveSiblings()) do
			if source:canSlash(p) then  --严格来说，进行杀的合法性检测时，应该假设明策牌已经给出去了。但是这无法实现
				slash_targets:append(p)
			end
		end
	end
	return slash_targets
end
mingceCard = sgs.CreateSkillCard{
	name = "mingceCard",
	skill_name = "mingce",
    will_throw = false,
    handling_method = sgs.Card_MethodNone,
	filter = function(self, selected, to_select)
		if #selected == 0 then 
			return to_select:objectName() ~= sgs.Self:objectName()
		elseif #selected == 1 then
			return findmingceTarget(selected[1]):contains(to_select)
		end
		return false
	end,
	feasible = function(self, selected)
		if #selected == 1 then
			return findmingceTarget(selected[1]):isEmpty()
		elseif #selected == 2 then
			return true
		end
		return false
	end,
	about_to_use = function(self, room, card_use)  --翻译Card::onUse
		local player = card_use.from
		local target = card_use.to:first()
		--源码处理SkillPosition的那段未提供lua接口
		
		local msg = sgs.LogMessage()
		msg.from = player
		msg.to:append(target)
		msg.type = "#UseCard"
		msg.card_str = card_use.card:toString(true)
		room:sendLog(msg)
		
		if card_use.to:length() == 2 then
			local dat = sgs.QVariant()
			dat:setValue(card_use.to:last())
			target:setTag("mingceTarget", dat)
			local msg = sgs.LogMessage()
			msg.type = "#CollateralSlash"
			msg.from = player
			msg.to:append(card_use.to:last())
			room:sendLog(msg)
			room:doAnimate(1, target:objectName(), card_use.to:last():objectName())  --S_ANIMATE_INDICATE
			card_use.to:removeAt(1)
		end
		
		local data = sgs.QVariant()
		data:setValue(card_use)
		local thread = room:getThread()
		assert(thread)
		thread:trigger(sgs.PreCardUsed, room, player, data)
		card_use = data:toCardUse()
		
		--self:extraCost(room, card_use)  --无法将self转化为SkillCard
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), target:objectName(), "mingce", "")
		room:obtainCard(target, self, reason)
		if player:ownSkill(card_use.card:showSkill()) and not player:hasShownSkill(card_use.card:showSkill()) then
			player:showGeneral(player:inHeadSkills(card_use.card:showSkill()))
		end
		
		thread:trigger(sgs.CardUsed, room, player, data)
		thread:trigger(sgs.CardFinished, room, player, data)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local source = effect.from
		local target = effect.to
		if target:isDead() then return false end
		local choicelist = {"draw"}
		local slash_target = target:getTag("mingceTarget"):toPlayer()
		target:removeTag("mingceTarget")
		if slash_target and target:canSlash(slash_target, nil, false) then
			table.insert(choicelist, "use")
		end
		local choice = room:askForChoice(target, "mingce", table.concat(choicelist, "+"))
		
		if choice == "use" and slash_target then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("_mingce")
			room:useCard(sgs.CardUseStruct(slash, target, slash_target), false)
		elseif choice == "draw" then
			target:drawCards(1, "mingce")
		end
	end,
	on_turn_broken = function(self, function_name, room, data)
		local target
		if function_name == "about_to_use" or function_name == "extra_cost" then
			target = data:toCardUse().to:first()
		elseif function_name == "on_effect" then
			target = data:toCardEffect().to
		end
		target:removeTag("mingceTarget")
	end,
}
mingce = sgs.CreateOneCardViewAsSkill{
	name = "mingce",
	filter_pattern = "EquipCard,Slash",
	view_as = function(self, card)
        local mingce_card = mingceCard:clone()
		mingce_card:addSubcard(card)
        mingce_card:setShowSkill(self:objectName())
        return mingce_card
	end,
	enabled_at_play = function(self, player)
        return not player:hasUsed("#mingceCard")
	end,
}
zhichi = sgs.CreateTriggerSkill{
	name = "zhichi",
	can_preshow = true,
	events = {sgs.Damaged},
	frequency = sgs.Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local current = room:getCurrent()
		return (current and (current:objectName() ~= player:objectName())) and self:objectName() or ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:hasShownSkill(self:objectName()) or player:askForSkillInvoke(self:objectName()) then
			room:broadcastSkillInvoke(self:objectName(), 1, player)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data)
		if player:getMark("@late") == 0 then
			room:addPlayerMark(player, "@late")
		end
		local msg = sgs.LogMessage()
		msg.type, msg.from = "#zhichiDamaged", player
		room:sendLog(msg)
	end,
}
zhichiProtect = sgs.CreateTriggerSkill{
	name = "#zhichi-protect",
	can_preshow = false,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected, sgs.SlashEffected},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if event == sgs.CardEffected then
			local effect = data:toCardEffect()
			if effect.card:isNDTrick() then
				return (effect.to:getMark("@late") > 0) and self:objectName(), effect.to or ""
			end
		elseif event == sgs.SlashEffected then
			local effect = data:toSlashEffect()
			return (effect.to:getMark("@late") > 0) and self:objectName(), effect.to or ""
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		room:broadcastSkillInvoke("zhichi", 2, ask_who)
		room:notifySkillInvoked(ask_who, "zhichi")
		return true
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		local msg = sgs.LogMessage()
		msg.type, msg.from, msg.arg = "#zhichiAvoid", ask_who, "zhichi"
		room:sendLog(msg)
		return true
	end,
}
zhichiClear = sgs.CreateTriggerSkill{
	name = "#zhichi-clear",
	events = {sgs.EventPhaseStart},
	priority = 8,
	global = true,
	on_record = function(self, event, room, player, data)
		if player:getPhase() ~= sgs.Player_NotActive then return end
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("@late") > 0 then
				room:setPlayerMark(p, "@late", 0)
			end
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end
}
chengong:addSkill(mingce)
chengong:addSkill(zhichi)
chengong:addSkill(zhichiProtect)
chengong:addSkill(zhichiClear)
sgs.insertRelatedSkills(extension, "zhichi", "#zhichi-protect", "#zhichi-clear")

-----王基-----

qizhi = sgs.CreateTriggerSkill{
	name = "qizhi",
	can_preshow = true,
	events = {sgs.TargetChosen},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self) then return "" end
		if player:getPhase() == sgs.Player_NotActive then return false end
		local use = data:toCardUse()
		if not use.card or not use.from or player:objectName() ~= use.from:objectName() then return "" end
		if use.card:isKindOf("TrickCard") or use.card:isKindOf("BasicCard") then
			for _ , p in sgs.qlist(room:getAlivePlayers()) do
				if not use.to:contains(p) and player:canDiscard(p, "he") then
					return self:objectName()
				end
			end
		end
	end,	
	on_cost = function(self, event, room, player, data)
		local use = data:toCardUse()
		local targets = sgs.SPlayerList()
		for _ , p in sgs.qlist(room:getAlivePlayers()) do
			if not use.to:contains(p) and player:canDiscard(p, "he") then
				targets:append(p)
			end
		end
		local target = room:askForPlayerChosen(player, targets, self:objectName(), "qizhi-choice:::" .. use.card:objectName(), true, true)
		if target then
			room:broadcastSkillInvoke(self:objectName(), player)
			local d = sgs.QVariant()
			d:setValue(target)
			player:setTag("qizhieffect", d)
			return true
		end
	end,	
	on_effect = function(self, event, room, player, data)
		local target = player:getTag("qizhieffect"):toPlayer()
		--[[local jsonValue = {
			10,
			player:objectName(),
			"zhoutai",
			"buqu",
		}
		room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))--]]
		if target:hasSkill("leimu") and target:getHp() > 1 then
			local can = false
			if target:getHp() == 2 then
				for _, c in sgs.qlist(target:getHandcards()) do 
					if c:getSuit() ~= sgs.Card_Spade then
						can_ = true
						break
					end
				end
				for _, c in sgs.qlist(target:getEquips()) do 
					if c:getSuit() ~= sgs.Card_Spade then
						can = true
						break
					end
				end
			elseif target:getHp() > 2 then
				for _, c in sgs.qlist(target:getHandcards()) do 
					if c:isRed() then
						can = true
						break
					end
				end
				for _, c in sgs.qlist(target:getEquips()) do 
					if c:isRed() then
						can = true
						break
					end
				end
			end
			sendMsg(room, "没有可以弃置的牌")
			if can == false then return false end
		end
		room:addPlayerMark(player, "@qizhi")
		player:removeTag("qizhieffect")
		local to_throw = room:askForCardChosen(player, target, "he", self:objectName(), false, sgs.Card_MethodDiscard)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), target:objectName(), self:objectName(), nil)
		room:throwCard(sgs.Sanguosha:getCard(to_throw), reason, target, player)
		target:drawCards(1, self:objectName())
	end,
	on_turn_broken = function(self, function_name, event, room, player, data, ask_who)
		player:removeTag("qizhieffect")
	end
}
qizhiClear = sgs.CreateTriggerSkill{
	name = "#qizhi-clear",
	events = {sgs.EventPhaseStart},
	priority = 8,
	global = true,
	on_record = function(self, event, room, player, data)
		if player:getPhase() == sgs.Player_NotActive then
			room:setPlayerMark(player, "@qizhi", 0)
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
jinqu = sgs.CreatePhaseChangeSkill{
	name = "jinqu",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if player and player:isAlive() and player:hasSkill(self) then
			if player:getPhase() == sgs.Player_Finish then 
				return self:objectName()
			end	
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local x = player:getMark("@qizhi")
		if room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("HandNumMax:::" .. player:getMark("@qizhi"))) then
			return true 
		end
		return false 
	end,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		player:drawCards(2, self:objectName())
		local x = player:getMark("@qizhi")
		local y = player:getHandcardNum()
		if y > x then
			room:broadcastSkillInvoke(self:objectName(), 1, player)
			room:askForDiscard(player, self:objectName(), y - x, y - x)
		elseif y <= x then
			room:broadcastSkillInvoke(self:objectName(), 2, player)
		end
		return false 
	end,
}
jinqu_damaged = sgs.CreateTriggerSkill{
	name = "#jinqu_damaged",
	global = true,
	events = {sgs.Damaged},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill("jinqu") then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data)
		if room:askForSkillInvoke(player,"jinqu",sgs.QVariant("1")) then
			player:showGeneral(player:inHeadSkills("jinqu"))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("jinqu")
		room:notifySkillInvoked(player, "jinqu")
		if player:getRole() == "careerist" then
			player:drawCards(1)
			room:askForDiscard(player, self:objectName(), 1, 1)
		else
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getKingdom() == player:getKingdom() and p:getRole() ~= "careerist" and p:hasShownOneGeneral() then
					p:drawCards(1)
					room:askForDiscard(p, self:objectName(), 1, 1, false, true)
				end
			end
		end
	end
}
wangji:addSkill(jinqu)
wangji:addSkill(jinqu_damaged)
wangji:addSkill(qizhi)
wangji:addSkill(qizhiClear)
sgs.insertRelatedSkills(extension, "qizhi", "#qizhi-clear")
sgs.insertRelatedSkills(extension, "jinqu", "#jinqu_damaged")

-----徐氏-----

wengua = sgs.CreateTriggerSkill{
	name = "wengua",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if player:isWounded() and player:getPhase() == sgs.Player_Finish then
			local xushi = room:findPlayerBySkillName(self:objectName())
			if xushi then
				return self:objectName(), xushi
			end
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(ask_who, self:objectName())
		ask_who:drawCards(1)
		local exc_card = room:askForExchange(ask_who, self:objectName(), 1, 1, "wenguaPush", "", ".")
		if not exc_card then
			exc_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			exc_card:addSubcard(ask_who:getHandcards():first())
		end
		--[[local putcards = sgs.IntList()
		for _, c in sgs.qlist(exc_card:getSubcards()) do
			putcards:append(c)
		end--]]
		local choice = room:askForChoice(ask_who, self:objectName(), "pile_top+pile_bottom")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, ask_who:objectName(), self:objectName(), "")
		if choice == "pile_top" then
			room:moveCardTo(exc_card, ask_who, sgs.Player_DrawPile)
			--move = sgs.CardsMoveStruct(putcards, ask_who, nil, sgs.Player_PlaceHand, sgs.Player_DrawPile, reason)
		elseif choice == "pile_bottom" then
			room:moveCardTo(exc_card, ask_who, sgs.Player_DrawPileBottom)
			--move = sgs.CardsMoveStruct(putcards, ask_who, nil, sgs.Player_PlaceHand, sgs.Player_DrawPileBottom , reason)
		end
		--moves:append(move)
		--room:moveCardsAtomic(moves, true)
		return false
	end
}
fuzhuCard = sgs.CreateSkillCard{
	name = "fuzhuCard",
	skill_name = "fuzhu",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then
			return false
		elseif not to_select:isMale() then
			return false
		elseif not sgs.Self:inMyAttackRange(to_select) then
			return false
		elseif #targets == 0 then
			return true
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("fuzhu")
		local to = targets[1]
		local x = 0
		for _, q in sgs.qlist(room:getAlivePlayers()) do 
			if q:isWounded() then
				x = x + 1
			end
			if x >= source:getMaxHp() then
				break
			end
		end
		for i = 1, x, 1  do
			if not to:isAlive() or room:getDrawPile():isEmpty() then return false end
			local id = room:getDrawPile():at(room:getDrawPile():length()-1)
			local move = sgs.CardsMoveStruct(id, nil, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, source:objectName(), "fuzhu", ""))
			room:moveCardsAtomic(move, true)
			room:getThread():delay(500)
			local card = sgs.Sanguosha:getCard(id)
			if (card:isBlack() and card:isKindOf("TrickCard") and not card:isKindOf("Collateral") and 
				not card:isKindOf("Nullification") and not card:isKindOf("FightTogether") and not card:isKindOf("ImperialOrder") and
				not card:isKindOf("ThreatenEmperor") and not card:isKindOf("Lightning") and not card:isKindOf("BurningCamps")) or 
				card:isKindOf("Slash") then
				if not source:isProhibited(to, card) then 
					local targets = sgs.SPlayerList()
					targets:append(to)
					local use_card = sgs.Sanguosha:cloneCard(card:objectName(), card:getSuit(), card:getNumber())
					use_card:addSubcard(card)
					use_card:setSkillName("fuzhu")
					local card_use = sgs.CardUseStruct()
					card_use.from = source
					card_use.to = targets
					card_use.card = use_card
					room:useCard(card_use, false)
				end
			else
				room:throwCard(id, source)
			end
		end
		source:setPhase(sgs.Player_Discard)
	end
}
fuzhu = sgs.CreateZeroCardViewAsSkill{   
	name = "fuzhu",
	view_as = function(self)
		local skillcard = fuzhuCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#fuzhuCard")
	end
}
xushi:addSkill(wengua)
xushi:addSkill(fuzhu)

-----薛综-----

funan = sgs.CreateTriggerSkill{
	name = "funan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove, sgs.CardResponded, sgs.CardUsed, sgs.CardFinished, sgs.GameStart, sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if event == sgs.CardFinished or event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				player:setTag("funanInvoke", sgs.QVariant(false))
				player:setTag("funanCard", sgs.QVariant(""))
			end
		end
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Finish then return "" end
			local xuezong = room:findPlayerBySkillName(self:objectName())
			if not xuezong then return "" end
			xuezong:setTag("funanInvoke", sgs.QVariant(false))
			xuezong:setTag("funanCard", sgs.QVariant(""))
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			local to_player
			local xuezong = room:findPlayerBySkillName(self:objectName())
			if not xuezong then return "" end
			if event == sgs.CardResponded then
				local response = data:toCardResponse()
				if response.m_who:objectName() ~= xuezong:objectName() then return "" end
				if player:objectName() == xuezong:objectName() then return "" end
				if response.m_isHandcard == false then 
					return "" 
				end
				to_player = player
			elseif event == sgs.CardUsed then
				local use = data:toCardUse()
				if not player or player:isDead() then return "" end
				if use.from:objectName() == xuezong:objectName() then 
					return "" 
				end
				to_player = use.from
			end
			local card
			if event == sgs.CardResponded then
				local response = data:toCardResponse()
				card = response.m_card
			elseif event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
				if not use.card:isKindOf("Nullification") then return "" end
			end
			if event == sgs.CardResponded or (event == sgs.CardUsed and card:isKindOf("Nullification")) then
				local status = xuezong:getTag("funanInvoke"):toBool()
				local ids = xuezong:getTag("funanCard"):toString():split("+")
				if xuezong:getMark("funanMark") == 0 and (#ids == 0 or ids[1] == "") then return "" end
				if status == true then
					return self:objectName(), xuezong
				end
			end
		elseif event == sgs.BeforeCardsMove then
			if not player or player:isDead() then return "" end
			local move = data:toMoveOneTime()
			if not move.from or player:objectName() ~= move.from:objectName() then return "" end
			if move.from_places:contains(sgs.Player_PlaceHand) and (move.to_place == sgs.Player_PlaceTable)
					and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
				if player:hasSkill(self:objectName()) then
					player:setTag("funanCard", sgs.QVariant(""))
					local ids = {}
					for _,id in sgs.qlist(move.card_ids) do
						card = sgs.Sanguosha:getCard(id)
						table.insert(ids, id)
					end
					if #ids > 0 then
						player:setTag("funanInvoke", sgs.QVariant(true))
						player:setTag("funanCard", sgs.QVariant(table.concat(ids,"+")))
					end
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		room:setPlayerProperty(ask_who, "funanToProp", sgs.QVariant())
		room:setPlayerProperty(ask_who, "funanCardProp", sgs.QVariant())
		local to = player
		local card_id
		if event == sgs.CardResponded then
			local respond = data:toCardResponse()
			card_id = respond.m_card:getId()
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			card_id = use.card:getId()
		end
		room:setPlayerProperty(ask_who, "funanToProp", sgs.QVariant(to:objectName()))
		room:setPlayerProperty(ask_who, "funanCardProp", sgs.QVariant(card_id))
		if room:askForSkillInvoke(ask_who,"funan",data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(ask_who, self:objectName())
		if event == sgs.CardUsed or event == sgs.CardResponded then
			local card
			local to
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
				to = use.from
				if not use.card:isKindOf("Nullification") then return "" end
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				card = response.m_card
				to = player
			end
			if ask_who:getMark("funanMark") == 0 then  --没有失去诫训
				local ids = ask_who:getTag("funanCard"):toString():split("+")
				ask_who:setTag("funanCard", sgs.QVariant(""))
				if #ids == 0 or ids[1] == "" then return false end
				room:obtainCard(ask_who, card) 
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, c in pairs(ids) do
					local ccc = sgs.Sanguosha:getCard(tonumber(c))
					dummy:addSubcard(ccc)
				end
				if dummy:getSubcards():length() > 0 then
					room:obtainCard(to, dummy)
				end
			else									--失去了诫训
				room:obtainCard(ask_who, card)
			end
		end
		return false
	end
}
--[[funan = sgs.CreateTriggerSkill{
	name = "funan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded, sgs.CardFinished, sgs.GameStart, sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if player:hasSkill(self:objectName()) then
				local card = use.card
				if use.card:isKindOf("EquipCard") then return "" end
				local ids = {}
				if use.card:getSubcards():length() > 0 then
					for _, c in sgs.qlist(use.card:getSubcards()) do 
						table.insert(ids, c)
					end
					--room:setPlayerProperty(player, "funanToProp", sgs.QVariant(use.to))
					room:setPlayerProperty(player, "funanProp", sgs.QVariant(table.concat(ids,"+")))
					room:setPlayerProperty(player, "funanInvokeProp", sgs.QVariant(true))
				end
			else
				if not use.card:isKindOf("Nullification") then return "" end
				local card = use.card
				if card:getSubcards():length() > 0 then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if p:property("funanInvokeProp"):toBool() == true then
							return self:objectName(), p
						end
					end
				end
			end
		end
		if event == sgs.CardResponded then
			local response = data:toCardResponse()
			card = response.m_card
			if card:getSubcards():length() > 0 then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:property("funanInvokeProp"):toBool() == true then
						return self:objectName(), p
					end
				end
			end
		end
		if event == sgs.CardFinished or event == sgs.GameStart then
			if player:hasSkill(self:objectName()) then
				room:setPlayerProperty(player, "funanInvokeProp", sgs.QVariant(false))
			end
		end
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Finish then return "" end
			local xuezong
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:property("funanProp") and p:property("funanProp"):toString() ~= "" then
					xuezong = p
					break
				end
			end
			if not xuezong then return "" end
			room:setPlayerProperty(xuezong, "funanProp", sgs.QVariant(""))
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		room:setPlayerProperty(ask_who, "funanToProp", sgs.QVariant())
		room:setPlayerProperty(ask_who, "funanCardProp", sgs.QVariant())
		local to = player
		local card_id
		if event == sgs.CardResponded then
			local respond = data:toCardResponse()
			card_id = respond.m_card:getId()
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			card_id = use.card:getId()
		end
		room:setPlayerProperty(ask_who, "funanToProp", sgs.QVariant(to:objectName()))
		room:setPlayerProperty(ask_who, "funanCardProp", sgs.QVariant(card_id))
		if room:askForSkillInvoke(ask_who,"funan",data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(ask_who, self:objectName())
		local card
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		end
		if event == sgs.CardResponded then
			local response = data:toCardResponse()
			card = response.m_card
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, c in sgs.qlist(card:getSubcards()) do
			local ccc = sgs.Sanguosha:getCard(c)
			dummy:addSubcard(ccc)
		end
		if dummy:getSubcards():length() > 0 then
			room:obtainCard(ask_who, dummy)
		end
		room:obtainCard(ask_who, card)
		if ask_who:getMark("funanMark") == 0 then
			local ids = ask_who:property("funanProp"):toString():split("+")
			local dummy1 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, c in pairs(ids) do
				local ccc = sgs.Sanguosha:getCard(c)
				dummy1:addSubcard(ccc)
			end
			if dummy1:getSubcards():length() > 0 then
				room:obtainCard(player, dummy1)
			end
			room:setPlayerProperty(ask_who, "funanInvokeProp", sgs.QVariant(false))
			--player:setCardLimitation("use,response", sgs.Sanguosha:getCard(id):toString(), false)
			--room:setPlayerCardLimitation(player, "use, response", sgs.Sanguosha:getCard(id):toString(), false)
		end
	end
}--]]
jiexun = sgs.CreateTriggerSkill{
	name = "jiexun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "jiexun-invoke", true, true)
		if to then
			room:setPlayerProperty(player, "jiexunProp", sgs.QVariant(to:objectName()))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local to
		objectName = player:property("jiexunProp"):toString()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == objectName then
				to = p 
				break
			end
		end
		room:setPlayerProperty(player, "jiexunProp", sgs.QVariant())
		local num = player:getMark("@xun")
		local diamonds_num = 0
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
		to:drawCards(diamonds_num)
		local to_card_num = to:getHandcardNum() + to:getEquips():length()
		if num > 0 then
			room:askForDiscard(to, self:objectName(), num, num, false, true)
			player:gainMark("@xun")
			if num >= to_card_num then
				room:detachSkillFromPlayer(player,"jiexun")
				room:setPlayerMark(player, "@xun", 0)
				room:addPlayerMark(player, "funanMark")
			end
		else
			player:gainMark("@xun")
		end
	end
}
xuezong:addSkill(funan)
xuezong:addSkill(jiexun)

-----马良-----

zishu = sgs.CreateTriggerSkill{
	name = "zishu",
	frequency = sgs.Skill_NotFrequent, 
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if player:getPhase() == sgs.Player_Finish and not player:isKongcheng() then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local x = player:getHandcardNum()
		if x > 3 then x = 3 end
		local ids = room:getNCards(x, true)
		local handcards = sgs.IntList()
		for _, c in sgs.qlist(player:getHandcards()) do
			handcards:append(c:getId())
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
		local notify_visible_list = sgs.IntList()
		notify_visible_list:append(-1)
		local AsMove = room:askForMoveCards(player, ids, sgs.IntList(), true, "zishu1", "", self:objectName(), 0, x, false, false, notify_visible_list)
		local ids_sorts = {}
		for _, c in sgs.qlist(ids) do
			table.insert(ids_sorts, c)
		end
		local to_top = sgs.IntList(), sgs.IntList()
		local size = AsMove.bottom:length()
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local prohibit = ""
		local prohibit_list = {}
		for _, c in sgs.qlist(AsMove.bottom) do
			if prohibit ~= "" then
				prohibit = prohibit.."+"
			end
			local ccc = sgs.Sanguosha:getCard(c)
			dummy:addSubcard(ccc)
			prohibit = prohibit.."^"..sgs.Sanguosha:getCard(c):toString()
			ids:removeOne(c)
			table.insert(prohibit_list, c)
		end
		local to_top_ids = sgs.IntList()
		for _, c in pairs(ids_sorts) do
			for _, d in sgs.qlist(ids) do 
				if c == d then
					to_top_ids:prepend(c)
				end
			end
		end
		local card_top_to_pile = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, c in sgs.qlist(to_top_ids) do 
			card_top_to_pile:addSubcard(c)
		end
		local moves = sgs.CardsMoveList()
		room:moveCardTo(card_top_to_pile, player, sgs.Player_DrawPile)
		if dummy:getSubcards():length() > 0 then
			room:obtainCard(player, dummy, false)
			room:setPlayerProperty(player, "zishuExchangeProp", sgs.QVariant(table.concat(prohibit_list, "+")))
			local exc_card = room:askForExchange(player, self:objectName(), size, size, "zishuPush", "", prohibit.."|.|.|hand")
			room:setPlayerProperty(player, "zishuExchangeProp", sgs.QVariant())
			if not exc_card then
				exc_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for p = 0, size-1, 1 do
					exc_card:addSubcard(player:getHandcards():at(p))
				end
			end
			local putcards = sgs.IntList()
			for _, c in sgs.qlist(exc_card:getSubcards()) do
				putcards:append(c)
			end
			if putcards:length() == 1 then
				to_top:prepend(putcards:first())
			else
				local AsMove = room:askForMoveCards(player, putcards, sgs.IntList(), true, "zishu2", "", self:objectName(), size, size, false, false, notify_visible_list)
				for _, id in sgs.qlist(AsMove.bottom) do
					to_top:prepend(id)
				end
			end
			local card_to_pile = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, c in sgs.qlist(to_top) do 
				card_to_pile:addSubcard(c)
			end
			room:moveCardTo(card_to_pile, player, sgs.Player_DrawPile)
		end
	end
	--priority = -11
}
--[[yingyuan = sgs.CreateTriggerSkill{
	name = "yingyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove,sgs.CardUsed, sgs.EventPhaseStart, sgs.CardFinished, sgs.JinkEffect},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
				local maliang = room:findPlayersBySkillName(self:objectName())
				for _, p in sgs.qlist(maliang) do
					p:setTag("yingyuanTag", sgs.QVariant(""))
					player:removeTag("yingyuanCard")
					player:removeTag("yingyuanCardName")
					p:setTag("yingyuanInvoke", sgs.QVariant(false))
				end
			end
		elseif event == sgs.CardUsed or event == sgs.JinkEffect then
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
			local card
		sendMsg(room,"1")
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
			elseif event == sgs.JinkEffect then
				card = data:toCard()
				if card:getSubcards():length() == 0 then return "" end
			end
		sendMsg(room,"2")
			if card:isKindOf("EquipCard") or card:isKindOf("Lightning") or card:isKindOf("SupplyShortage") or card:isKindOf("Indulgence") then return "" end
			local use_history = player:getTag("yingyuanTag"):toString():split("+")
			local use_history_num
			if use_history == "" then use_history_num = 0 else use_history_num = #use_history end
			if use_history_num > getKingdoms(room) then return "" end
			if #use_history > 0 then
				for _, c in pairs(use_history) do
					if card:objectName() == c then
						return ""
					end
				end
			end
		sendMsg(room,"3")
			player:setTag("yingyuanCardName", sgs.QVariant(card:objectName()))
			local ids = {}
		sendMsg(room,"31:"..card:subcardsLength())
			for _, c in sgs.qlist(card:getSubcards()) do 
				sendMsg(room,"31:"..c)
				table.insert(ids, c)
			end
			if #ids > 0 then
				player:setTag("yingyuanInvoke", sgs.QVariant(true))
				player:setTag("yingyuanCard", sgs.QVariant(table.concat(ids,"+")))
			end
		sendMsg(room,"32")
			if event == sgs.JinkEffect then
				if player:getTag("yingyuanInvoke"):toBool() == true then
					return self:objectName()
				end
			end
		sendMsg(room,"4")
		elseif event == sgs.CardFinished then
		sendMsg(room,"5"..player:getTag("yingyuanInvoke"):toString())
			if player:getTag("yingyuanInvoke"):toBool() == true then
				return self:objectName()
			end
		end
		elseif event == sgs.BeforeCardsMove then
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
			local move = data:toMoveOneTime()
			if move.from_places:contains(sgs.Player_PlaceTable) and (move.to_place == sgs.Player_DiscardPile)
					and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
				local have = false
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if card:hasFlag("can_obtain") then
						have = true
					end
				end
				if have and move.from and (player:objectName() == move.from:objectName()) then
					return self:objectName()
				end
			end
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		player:setTag("yingyuanInvoke", sgs.QVariant(false))
		local targets = sgs.SPlayerList()
		sendMsg(room,"ddd")
		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "yingyuan-invoke", true, true)
		if to then
			room:setPlayerProperty(player, "yingyuanProp", sgs.QVariant(to:objectName()))
			local use_history = player:getTag("yingyuanTag"):toString():split("+")
			local cardName = player:getTag("yingyuanCardName"):toString()
			table.insert(use_history, cardName)
			player:setTag("yingyuanTag", sgs.QVariant(table.concat(use_history,"+")))
			player:removeTag("yingyuanCardName")
			return true
		end
		player:removeTag("yingyuanCardName")
		player:removeTag("yingyuanCard")
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		if not event == sgs.BeforeCardsMove then return false end
		local to
		objectName = player:property("yingyuanProp"):toString()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == objectName then
				to = p 
				break
			end 
		end
		room:setPlayerProperty(player, "yingyuanProp", sgs.QVariant())
		local ids = player:getTag("yingyuanCard"):toString():split("+")
		player:removeTag("yingyuanCard")
		if #ids > 0 then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, c in pairs(ids) do
				local ccc = sgs.Sanguosha:getCard(c)
				dummy:addSubcard(ccc)
			end
			if dummy:getSubcards():length() > 0 then
				room:obtainCard(to, dummy)
			end
		end
		local move = data:toMoveOneTime()
		if move.from_places:contains(sgs.Player_PlaceTable) and (move.to_place == sgs.Player_DiscardPile)
				and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
			--local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			local have = false
			local move_card_ids_copy = move.card_ids
			for _, id in sgs.qlist(move_card_ids_copy) do
				local card = sgs.Sanguosha:getCard(id)
				if card:hasFlag("can_obtain") then
					--dummy:addSubcard(id)
					--move.card_ids:removeOne(id)
					have = true
				end
			end
			if have and move.from and (player:objectName() == move.from:objectName()) then
				--room:obtainCard(to, dummy, true)
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), self:objectName(), "")
				local move1 = sgs.CardsMoveStruct(move_card_ids_copy, player, to, sgs.Player_PlaceTable, sgs.Player_PlaceHand, reason)
				room:moveCardsAtomic(move1)
				data:setValue(move)
			end 
		end
		return false
	end
}--]]
yingyuan = sgs.CreateTriggerSkill{
	name = "yingyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove,sgs.CardUsed, sgs.EventPhaseStart,sgs.CardFinished, sgs.CardResponded, sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
				local maliang = room:findPlayersBySkillName(self:objectName())
				for _, p in sgs.qlist(maliang) do
					p:setTag("yingyuanTag", sgs.QVariant(""))
					player:removeTag("yingyuanCardName")
					p:setTag("yingyuanInvoke", sgs.QVariant(false))
					p:setTag("yingyuanCard", sgs.QVariant(""))
				end
			end
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
			local maliang
			local card
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				if use.from:objectName() ~= player:objectName() then return "" end
				maliang = player
				card = use.card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				if response.m_isUse == false then return "" end
				if response.m_isHandcard == false then return "" end
				maliang = player
				card = response.m_card
			end
			if not card:isKindOf("BasicCard") and not card:isNDTrick() then return "" end
			local use_history = maliang:getTag("yingyuanTag"):toString():split("+")
			local use_history_num
			if use_history == "" then use_history_num = 0 else use_history_num = #use_history end
			if use_history_num > getKingdoms(room) then return "" end
			if #use_history > 0 then
				for _, c in pairs(use_history) do
					if card:objectName() == c then
						return ""
					end
				end
			end
			maliang:setTag("yingyuanCardName", sgs.QVariant(card:objectName()))
			maliang:setTag("yingyuanInvoke", sgs.QVariant(true))
			if event == sgs.CardResponded or (event == sgs.CardUsed and card:isKindOf("Nullification")) then
				local ids = maliang:getTag("yingyuanCard"):toString():split("+")
				if #ids > 0 and ids[1] ~= "" then
					return self:objectName(), maliang
				end
			end
		elseif event == sgs.CardFinished then
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
			player:setTag("yingyuanInvoke", sgs.QVariant(false))
		elseif event == sgs.BeforeCardsMove then
			if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
			local move = data:toMoveOneTime()
			if not move.from or player:objectName() ~= move.from:objectName() then return "" end
			local ids = {}
			for _,id in sgs.qlist(move.card_ids) do
				card = sgs.Sanguosha:getCard(id)
				table.insert(ids, id)
			end
			if #ids > 0 then
				player:setTag("yingyuanCard", sgs.QVariant(table.concat(ids,"+")))   --万恶的闪和无懈可击
			end
			if player:getTag("yingyuanInvoke"):toBool() == false then return "" end
			
			--董仲颖技能  自己弃牌也能发动？ 检查输出reason
			if move.from_places:contains(sgs.Player_PlaceTable) and (move.to_place == sgs.Player_DiscardPile)
					and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
				return self:objectName()
			end
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		ask_who:setTag("yingyuanInvoke", sgs.QVariant(false))
		local ids = ask_who:getTag("yingyuanCard"):toString():split("+")
		local objectNames = {}
		if #ids > 0 and ids[1] ~= "" then
			for _, c in pairs(ids) do
				local ccc = sgs.Sanguosha:getCard(tonumber(c))
				table.insert(objectNames, ccc:objectName())
			end
		end
		local objectNames_str = table.concat(objectNames, ",")
		local targets = sgs.SPlayerList()
		local to = room:askForPlayerChosen(ask_who, room:getOtherPlayers(ask_who), self:objectName(), "yingyuan-invoke:::"..objectNames_str, true, true)
		if to then
			room:setPlayerProperty(ask_who, "yingyuanProp", sgs.QVariant(to:objectName()))
			local use_history = ask_who:getTag("yingyuanTag"):toString():split("+")
			local cardName = ask_who:getTag("yingyuanCardName"):toString()
			table.insert(use_history, cardName)
			ask_who:setTag("yingyuanTag", sgs.QVariant(table.concat(use_history,"+")))
			ask_who:removeTag("yingyuanCardName")
			return true
		end
		ask_who:removeTag("yingyuanCardName")
		ask_who:setTag("yingyuanCard", sgs.QVariant(""))
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(ask_who, self:objectName())
		local to
		objectName = ask_who:property("yingyuanProp"):toString()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == objectName then
				to = p 
				break
			end 
		end
		room:setPlayerProperty(ask_who, "yingyuanProp", sgs.QVariant())
		if event == sgs.BeforeCardsMove then
			local move = data:toMoveOneTime()
			if (move.from_places:contains(sgs.Player_PlaceTable) or move.from_places:contains(sgs.Player_PlaceHand)) and (move.to_place == sgs.Player_DiscardPile)
					and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
				local move_card_ids_copy = move.card_ids
				if move.from and (ask_who:objectName() == move.from:objectName()) then
					move.to = to
					move.to_place = sgs.Player_PlaceHand
					data:setValue(move)
				end
			end
			ask_who:setTag("yingyuanCard", sgs.QVariant(""))
		elseif event == sgs.CardResponded or event == sgs.CardUsed then
			local ids = ask_who:getTag("yingyuanCard"):toString():split("+")
			ask_who:setTag("yingyuanCard", sgs.QVariant(""))
			if #ids > 0 and ids[1] ~= "" then
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, c in pairs(ids) do
					local ccc = sgs.Sanguosha:getCard(tonumber(c))
					dummy:addSubcard(ccc)
				end
				if dummy:getSubcards():length() > 0 then
					room:obtainCard(to, dummy)
				end
			end
		end
		return false
	end
}
maliang:addSkill(zishu)
maliang:addSkill(yingyuan)

-----君主·曹操-----

mouduan = sgs.CreateTriggerSkill{
	name = "mouduan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local damage = data:toDamage()
		if not damage.from then return "" end
		local can_invoke = false
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getKingdom() == "wei" and (isMouchen(p) or isLiangjiang(p)) then
				can_invoke = true
			end
		end
		if can_invoke then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getKingdom() == "wei" and (isMouchen(p) or isLiangjiang(p)) then
				targets:append(p)
			end
		end
		room:setPlayerProperty(player, "mouduanSelectProp", data)
		local to = room:askForPlayerChosen(player, targets, self:objectName(), "mouduan-invoke", true, true)
		room:setPlayerProperty(player, "mouduanSelectProp", sgs.QVariant())
		if to then
			room:setPlayerProperty(player, "mouduanProp", sgs.QVariant(to:objectName()))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local to
		objectName = player:property("mouduanProp"):toString()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == objectName then
				to = p 
				break
			end
		end
		room:setPlayerProperty(player, "mouduanProp", sgs.QVariant())
		if isLiangjiang(to) then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName(self:objectName())
			local card_use = sgs.CardUseStruct()
			card_use.from = to
			card_use.to:append(data:toDamage().from)
			card_use.card = slash
			room:useCard(card_use, false)
		elseif isMouchen(to) then
			local phases = sgs.PhaseList()
			phases:append(sgs.Player_Play)
			to:play(phases)
		end
		return false
	end
}
xietian = sgs.CreateViewAsSkill{
	name = "xietian" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if #selected > 0 then return false end
		local card = to_select
		return card:getSuit() == sgs.Card_Heart and card:getNumber() == 2
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local originalCard = cards[1]
		local threaten_emperor = sgs.Sanguosha:cloneCard("threaten_emperor", originalCard:getSuit(), originalCard:getNumber())
		threaten_emperor:addSubcard(originalCard)
		threaten_emperor:setSkillName(self:objectName())
		return threaten_emperor
	end 
}
yitian1 = sgs.CreateTriggerSkill{
	name = "yitian1",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Start then
			if player:getEquip(0) and player:getEquip(0):isKindOf("Yitianjian") then return "" end
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		for i = 0, 10000 do
			local card = sgs.Sanguosha:getEngineCard(i)
			if card == nil then break end
			if card:isKindOf("Yitianjian") then
				player:gainMark("yitianjianMark")
				local use = sgs.CardUseStruct()
				use.card = card
				use.from = player
				use.to:append(player)
				room:useCard(use)
				player:loseMark("yitianjianMark")
			end
		end
		return false
	end
}
dashi = sgs.CreateTriggerSkill{
	name = "dashi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.Death},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Discard then
				room:setPlayerMark(player,"dashiMouchenMark",getMouchenNum(room))
			elseif player:getPhase() == sgs.Player_Start then
				room:setPlayerMark(player,"dashiLiangjiangMark",getLiangjiangNum(room))
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard then
				room:setPlayerMark(player,"dashiMouchenMark",0)
			end
		elseif event == sgs.Death then
			room:setPlayerMark(player,"dashiLiangjiangMark",getLiangjiangNum(room))
			--[[ocal hasLiangjiangOrMouchen = false
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if isLiangjiang(p) or isMouchen(p) then
					hasLiangjiangOrMouchen = true
					break
				end
			end
			if not hasLiangjiangOrMouchen then
				room:detachSkillFromPlayer(player,"mouduan")
				room:acquireSkill(player,"Ejianxiong",true,player:inHeadSkills(self:objectName()))
			end--]]
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
dashi_maxCard = sgs.CreateMaxCardsSkill{
    name = "#dashi_maxCard" ,
	global = true,
    extra_func = function(self, target)
        if target:hasShownSkill("dashi") and target:getMark("dashiMouchenMark") > 0 then
		    return target:getMark("dashiMouchenMark")
		else
            return 0
        end
    end
}
dashi_extraSlash = sgs.CreateTargetModSkill{
	name = "#dashi_extraSlash",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill("dashi") and player:getMark("dashiLiangjiangMark") > 0 then
			return player:getMark("dashiLiangjiangMark")
		else
			return 0
		end
	end
}	
lord_caocao:addSkill(mouduan)
lord_caocao:addSkill(dashi)
lord_caocao:addSkill(dashi_extraSlash)
lord_caocao:addSkill(dashi_maxCard)
lord_caocao:addSkill(xietian)
lord_caocao:addSkill(yitian1)
extension:insertRelatedSkills("dashi","#dashi_extraSlash")
extension:insertRelatedSkills("dashi","#dashi_maxCard")

-----马谡-----
sanyao_maxcard = sgs.CreateMaxCardsSkill{
    name = "#sanyao_maxcard" ,
	global = true,
    extra_func = function(self, target)
        if target:getMark("sanyaoMark") > 0 then
		    return 1
		else
            return 0
        end
    end
}
sanyao = sgs.CreateTriggerSkill{
	name = "sanyao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.EventPhaseStart then
			local masu = room:findPlayerBySkillName(self:objectName())
			if not (masu and masu:isAlive() and masu:hasSkill(self:objectName())) then return "" end
			if player:getPhase() == sgs.Player_Discard and player:getHandcardNum() > player:getMaxCards() then
				return self:objectName(), masu
			end
		elseif event == sgs.EventPhaseEnd then   --清理标记
			if player:getPhase() ~= sgs.Player_Discard then return "" end
			local cardString = player:getTag("sanyaoTag"):toString()
			room:setPlayerMark(player, "sanyaoMark", 0)
			room:removePlayerCardLimitation(player, "discard", cardString)
			player:removeTag("sanyaoTag")
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local id = room:askForCardChosen(ask_who, player, "h", self:objectName(), false)
		room:showCard(player, id)
		local choice = room:askForChoice(ask_who, self:objectName(), "sanyao_benefit+sanyao_not_benefit")
		player:setTag("sanyaoTag", sgs.QVariant(sgs.Sanguosha:getCard(id):toString()))
		room:setPlayerCardLimitation(player, "discard", sgs.Sanguosha:getCard(id):toString(), false)
		if choice == "sanyao_benefit" then
			sendMsgFrom(room, ask_who, "选择了令该牌不计入其手牌数")
			room:addPlayerMark(player,"sanyaoMark")
		else
			sendMsgFrom(room, ask_who, "选择了令其不能弃置该牌")
		end
		return false
	end,
	priority = 1000
}
huilei = sgs.CreateTriggerSkill{
	name = "huilei",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	can_trigger = function(self, event, room, player, data)
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and death.damage and death.damage.from then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local death = data:toDeath()
		room:acquireSkill(death.damage.from,"leimu")
		return false
	end,
}
leimu = sgs.CreateTriggerSkill{
	name = "leimu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.HpChanged, sgs.EventAcquireSkill},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getHp() >= 3 then
			room:removePlayerCardLimitation(player, "discard", ".|spade")
			room:setPlayerCardLimitation(player, "discard", ".|black", false)
		elseif player:getHp() == 2 then
			room:removePlayerCardLimitation(player, "discard", ".|black")
			room:setPlayerCardLimitation(player, "discard", ".|spade", false)
		else
			room:removePlayerCardLimitation(player, "discard", ".|black")
			room:removePlayerCardLimitation(player, "discard", ".|spade")
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	end,
	on_effect = function(self, event, room, player, data,ask_who)
	end
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("leimu") then skills:append(leimu) end
sgs.Sanguosha:addSkills(skills)
masu:addSkill(sanyao)
masu:addSkill(sanyao_maxcard)
masu:addSkill(huilei)

-----祢衡-----

kuangcai = sgs.CreateTriggerSkill{
	name = "kuangcai",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Play then
			return self:objectName()
		elseif player:getPhase() == sgs.Player_Finish then
			player:loseMark("@kuang")
			player:removeTag("kuangcaiCardUsedNum")
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		player:gainMark("@kuang")
		player:setTag("kuangcaiCardUsedNum",sgs.QVariant(0))
		return false
	end,
}
kuangcaiUserCard = sgs.CreateTriggerSkill{
	name = "#kuangcai_usecard",
	global = true,
	events = {sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if room:getCurrent():objectName() ~= player:objectName() then return "" end
		if player:getMark("@kuang") > 0 then
			local use = data:toCardUse()
			local card = use.card 
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard") or use.card:isKindOf("EquipCard") then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		player:drawCards(1)
		local usenum = player:getTag("kuangcaiCardUsedNum"):toInt()
		if usenum >= player:getMaxHp() then
			player:setPhase(sgs.Player_Discard)
		else
			player:setTag("kuangcaiCardUsedNum",sgs.QVariant(usenum + 1))
		end
		return false
	end,
}
shejianCard = sgs.CreateSkillCard{
	name = "shejianCard",
	skill_name = "shejian",
	mute = true,
	filter = function(self, selected, to_select)
		local big_kingdoms = sgs.Self:getBigKingdoms("shejian")
		local big_kingdom_count = 0
		local players = sgs.Self:getAliveSiblings()
		players:append(sgs.Self)
		for _,p in sgs.qlist(players) do
			if table.contains(big_kingdoms, p:objectName()) or (table.contains(big_kingdoms, p:getKingdom()) and (p:getRole() ~= "careerist")) then  --野心家的同势力角色数永远不可能大于1，因此不可能出现在big_kingdoms中
				big_kingdom_count = big_kingdom_count + 1
			end
		end
		return #selected <= big_kingdom_count and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local room = source:getRoom()
		local card = room:askForCard(source, ".|.|.|hand!", "@shejian", sgs.QVariant(), sgs.Card_MethodNone, source)
		local players = {}
		local cards = {}
		table.insert(players,source)
		table.insert(cards,card:getEffectiveId())
		for _, p in pairs(targets) do
			local c = room:askForCard(p, ".|.|.|hand!", "@shejian", sgs.QVariant(), sgs.Card_MethodNone, source)
			table.insert(players,p)
			table.insert(cards,c:getEffectiveId())
		end
		for i = 1, #players, 1 do
			room:showCard(players[i], cards[i])
		end
		room:getThread():delay(1000)
		for i = 1, #players, 1 do
			if (sgs.Sanguosha:getCard(cards[i]):isRed() and card:isRed()) or (sgs.Sanguosha:getCard(cards[i]):isBlack() and card:isBlack()) then
				room:throwCard(cards[i], players[i], source)
			end
		end
	end,
}
shejian = sgs.CreateZeroCardViewAsSkill{
	name = "shejian",
	view_as = function(self) 
		local card = shejianCard:clone()
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#shejianCard") and not player:isKongcheng()
	end
}
miheng:addSkill(kuangcai)
miheng:addSkill(kuangcaiUserCard)
miheng:addSkill(shejian)
extension:insertRelatedSkills("kuangcai","#kuangcai_usecard")

-----何进-----

mouzhu = sgs.CreateTriggerSkill{
	name = "mouzhu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BuryVictim},
	can_trigger = function(self, event, room, player, data)
		local death = data:toDeath()
		local reason = death.damage
		if reason then
			local killer = reason.from
			if not (killer and killer:isAlive() and killer:hasSkill(self:objectName())) then return "" end
			return self:objectName(),killer
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not ask_who:hasShownSkill(self:objectName()) and room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		if ask_who:hasShownSkill(self:objectName()) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:setTag("SkipNormalDeathProcess", sgs.QVariant(true))
		player:bury()
		ask_who:drawCards(3)
		return false
	end
}
mouzhuClear = sgs.CreateTriggerSkill{
	name = "#mouzhu-clear",
	events = {sgs.BuryVictim},
	priority = -1,
	global = true,
	on_record = function(self, event, room, player, data)
		local death = data:toDeath()
		local reason = death.damage
		if reason then
			local killer = reason.from
			if not (killer and killer:isAlive() and killer:hasSkill(self:objectName())) then return "" end
		end
		room:setTag("SkipNormalDeathProcess", sgs.QVariant(false))
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
yanhuo = sgs.CreateTriggerSkill{
	name = "yanhuo",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:isWounded() then return "" end
		if player:getPhase() == sgs.Player_Finish then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), self:objectName().."-invoke", true, true)
		if to then
			player:showGeneral(player:inHeadSkills(self:objectName()))
			room:broadcastSkillInvoke(self:objectName())
			local losthp = player:getMaxHp() - player:getHp()
			to:drawCards(losthp)
			room:askForDiscard(to, self:objectName(), losthp, losthp, false, true)
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return true
	end,
}
hejin:addSkill(mouzhu)
hejin:addSkill(mouzhuClear)
hejin:addSkill(yanhuo)
extension:insertRelatedSkills("mouzhu","#mouzhu-clear")

-----蔡瑁-----

shuishiCard = sgs.CreateSkillCard{
	name = "shuishiCard",
	target_fixed = true,
	skill_name = "shuishi",
	on_use = function(self, room, source, targets)
	end,
}
shuishiVS = sgs.CreateZeroCardViewAsSkill{
	name = "shuishi",
	view_as = function(self, cards)
		local shuishicard = shuishiCard:clone()
		return shuishicard
	end,
	enabled_at_play = function(self, player)
		return player:hasUsed("#shuishiCard")
	end
}
shuishi = sgs.CreateTriggerSkill{
	name = "shuishi",
	frequency = sgs.Skill_Frequent,
	is_battle_array = true,
	battle_array_type = sgs.Siege,
	view_as_skill = shuishiVS,
	events = {sgs.TargetConfirmed,sgs.Predamage},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) or room:getAlivePlayers():length() == 2 then return "" end
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.to:contains(player) then return "" end
			if (use.card:isKindOf("Slash") or use.card:isKindOf("Drowning")) and use.from:inSiegeRelation(use.from,player)then
				return self:objectName()
			end
		elseif event == sgs.Predamage then
			local damage = data:toDamage()
			if damage.from:objectName() ~= player:objectName() then return "" end
			if damage.card and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Drowning")) and player:inSiegeRelation(player,damage.to) then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if event == sgs.TargetConfirmed then
			if room:askForCard(player, ".|.|.|hand", "@shuishi", data, sgs.CardDiscarded) then
				room:notifySkillInvoked(ask_who, self:objectName())
				return true
			end
		elseif event == sgs.Predamage then
			if room:askForSkillInvoke(player,self:objectName(),data) then
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			room:setEmotion(player, "cancel")
			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		elseif event == sgs.Predamage then
			local damage = data:toDamage()
			damage.damage = damage.damage + 1 
			data:setValue(damage)
		end
		return false
	end
}
duozhu = sgs.CreateTriggerSkill{
	name = "duozhu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameOverJudge},
	can_trigger = function(self, event, room, player, data)
		local caimao = room:findPlayerBySkillName(self:objectName())
		if not (caimao and caimao:isAlive()) then return "" end
		local death = data:toDeath()
		if player:objectName() ~= death.who:objectName() then return "" end
		if player:getEquips():length() == 0 then return "" end
		return self:objectName(),caimao:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not ask_who:hasShownSkill(self:objectName()) and room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		if ask_who:hasShownSkill(self:objectName()) then
			room:getThread():delay(500)
			room:notifySkillInvoked(ask_who, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		if player:getEquip(0) and not ask_who:getEquip(0) then room:moveCardTo(player:getEquip(0), ask_who, sgs.Player_PlaceEquip) end
		if player:getEquip(1) and not ask_who:getEquip(1) then room:moveCardTo(player:getEquip(1), ask_who, sgs.Player_PlaceEquip) end
		if player:getEquip(2) and not ask_who:getEquip(2) then room:moveCardTo(player:getEquip(2), ask_who, sgs.Player_PlaceEquip) end
		if player:getEquip(3) and not ask_who:getEquip(3) then room:moveCardTo(player:getEquip(3), ask_who, sgs.Player_PlaceEquip) end
		if player:getEquip(4) and not ask_who:getEquip(4) then room:moveCardTo(player:getEquip(4), ask_who, sgs.Player_PlaceEquip) end
		return false
	end,
	priority = 10000   --优先级高于行殇
}
caimao:addSkill(shuishi)
caimao:addSkill(duozhu)

-----周仓-----

zhongyongRecord1 = sgs.CreateTriggerSkill{
	name = "#zhongyong-record1",
	events = {sgs.SlashProceed},
	--[[由于技能要求仅记录所有响应此杀使用的闪，思路如下：
	1. 在SlashProceed记录目标需要使用的闪的数量，且设置Mark（同时记录此杀）；（入栈）
	2. 然后目标选择是否使用闪，如果使用，则在JinkEffect会收到此闪，此时判断是否有Mark，有的话就是响应此杀使用的闪了，记下来；
	3. 最后在SlashProceed的Gamerule执行完以后出栈（保证不会入了栈却不出）。
	]]
	priority = 1,
	global = true,
    on_record = function(self, event, room, player, data)
		local effect = data:toSlashEffect()
		local slashes = effect.to:getTag("zhongyongSlashStack"):toString():split("|")
		table.removeAll(slashes, "")
		local jink_nums = effect.to:getTag("zhongyongJinkNumStack"):toString():split("|")
		table.removeAll(jink_nums, "")
		local jinks = effect.to:getTag("zhongyongJinkRespondedStack"):toString():split("|") 
		table.removeAll(jinks, "")
		table.insert(slashes, effect.slash:toString())
		table.insert(jink_nums, effect.jink_num)
		table.insert(jinks, "-1")  --占位
		effect.to:setTag("zhongyongSlashStack", sgs.QVariant(table.concat(slashes, "|")))
		effect.to:setTag("zhongyongJinkNumStack", sgs.QVariant(table.concat(jink_nums, "|")))
		effect.to:setTag("zhongyongJinkRespondedStack", sgs.QVariant(table.concat(jinks, "|")))
	end,
    can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
zhongyongRecord2 = sgs.CreateTriggerSkill{
	name = "#zhongyong-record2",
	events = {sgs.JinkEffect},
	priority = 8,
	global = true,
    on_record = function(self, event, room, player, data)
		local jink_nums = player:getTag("zhongyongJinkNumStack"):toString():split("|")
		table.removeAll(jink_nums, "")
		local jinks = player:getTag("zhongyongJinkRespondedStack"):toString():split("|")
		table.removeAll(jinks, "")
		if #jink_nums == 0 or tonumber(jink_nums[#jink_nums]) == 0 --[[or #sources == 0]] then return end  --已经响应完闪，说明有bug或奇葩插入结算
		
		local jink = data:toCard()
		local id_tab = {}
		if jink:isVirtualCard() then
			id_tab = sgs.QList2Table(jink:getSubcards())
		else
			table.insert(id_tab, jink:getEffectiveId())
		end
		local jinksOneTime = jinks[#jinks]:split("+")
		table.removeAll(jinksOneTime, "")
		table.insert(jinksOneTime, table.concat(id_tab, "~"))  --jinks栈的每个元素记录方式：-1+闪1子卡1~闪1子卡2+闪2子卡+闪3子卡+……（因为子卡必须全在弃牌堆）
		jink_nums[#jink_nums] = tostring(tonumber(jink_nums[#jink_nums]) - 1)  --注意不要删除！到出栈时再删除
		jinks[#jinks] = table.concat(jinksOneTime, "+")
		player:setTag("zhongyongJinkNumStack", sgs.QVariant(table.concat(jink_nums, "|")))
		player:setTag("zhongyongJinkRespondedStack", sgs.QVariant(table.concat(jinks, "|")))
	end,
    can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
zhongyongRecord3 = sgs.CreateTriggerSkill{
	name = "#zhongyong-record3",
	events = {sgs.SlashProceed},
	priority = -1,
	global = true,
    on_record = function(self, event, room, player, data)
		local effect = data:toSlashEffect()
		local slashes = effect.to:getTag("zhongyongSlashStack"):toString():split("|")
		table.removeAll(slashes, "")
		local jink_nums = effect.to:getTag("zhongyongJinkNumStack"):toString():split("|")
		table.removeAll(jink_nums, "")
		local jinks = effect.to:getTag("zhongyongJinkRespondedStack"):toString():split("|") 
		table.removeAll(jinks, "")
		if not next(slashes) or not slashes[#slashes] or (slashes[#slashes] ~= effect.slash:toString()) then
			room:writeToConsole("Error with zhongyong Stack pop")
			return
		end
		
		local jinksOneTime = jinks[#jinks]:split("+")
		table.removeAll(jinksOneTime, "")
		table.removeAll(jinksOneTime, "-1")
		if next(jinksOneTime) then  --注：根据OL结算，多目标的杀结算后只能选择要么给杀，要么给所有闪，因此直接将所有闪记录在一起
			local jinksReceived = effect.from:getTag("zhongyongJinksReceived_" .. effect.slash:toString()):toString():split("+")  --记录所有目标响应此杀使用的所有闪
			table.removeAll(jinksReceived, "")
			table.insertTable(jinksReceived, jinksOneTime)
			effect.from:setTag("zhongyongJinksReceived_" .. effect.slash:toString(), sgs.QVariant(table.concat(jinksReceived, "+")))
		end
		
		table.remove(slashes, #slashes)
		if next(slashes) then effect.to:setTag("zhongyongSlashStack", sgs.QVariant(table.concat(slashes, "|"))) else effect.to:removeTag("zhongyongSlashStack") end
		table.remove(jink_nums, #jink_nums)
		if next(jink_nums) then effect.to:setTag("zhongyongJinkNumStack", sgs.QVariant(table.concat(jink_nums, "|"))) else effect.to:removeTag("zhongyongJinkNumStack") end
		table.remove(jinks, #jinks)
		if next(jinks) then effect.to:setTag("zhongyongJinkRespondedStack", sgs.QVariant(table.concat(jinks, "|"))) else effect.to:removeTag("zhongyongJinkRespondedStack") end
	end,
    can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
zhongyongCard = sgs.CreateSkillCard{
	name = "zhongyongCard",
	skill_name = "zhongyong",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:hasFlag("zhongyongAvailable")
	end,
	about_to_use = function(self, room, cardUse)
		local source, target = cardUse.from, cardUse.to:at(0)
		room:doAnimate(1, source:objectName(), target:objectName())
		local data = sgs.QVariant()
		data:setValue(target)
		source:setTag("zhongyongTarget", data)
		local data2 = sgs.QVariant()
		data2:setValue(self)
		source:setTag("zhongyongToGive", data2)
	end,
}
zhongyongVS = sgs.CreateViewAsSkill{
	name = "zhongyong",
	response_pattern = "@@zhongyong",
	expand_pile = "#zhongyong",
	view_filter = function(self, selected, to_select)
		local toGet = sgs.Self:property("zhongyongCards"):toString():split("|")
		for _,toGetOneTime_str in pairs(toGet) do
			local toGetOneTime = toGetOneTime_str:split("+")
			if #selected == 0 and table.contains(toGetOneTime, tostring(to_select:getId())) then return true
			elseif #selected > 0 and table.contains(toGetOneTime, tostring(selected[1]:getId())) and table.contains(toGetOneTime, tostring(to_select:getId())) then return true end
		end
		return false
	end, 
	view_as = function(self, originalCards) 
		local containsAll = false
		local toGet = sgs.Self:property("zhongyongCards"):toString():split("|")
		for _,toGetOneTime_str in pairs(toGet) do
			local toGetOneTime = toGetOneTime_str:split("+")
			containsAll = true
			if #toGetOneTime ~= #originalCards then containsAll = false continue end
			for _,card in pairs(originalCards) do
				if not table.contains(toGetOneTime, tostring(card:getId())) then containsAll = false continue end
			end
			if containsAll then break end
		end
		if containsAll then
			local skillcard = zhongyongCard:clone()
			for _, card in ipairs(originalCards) do
				skillcard:addSubcard(card)
			end
			skillcard:setSkillName(self:objectName())
			return skillcard
		end
	end,
}
zhongyong = sgs.CreateTriggerSkill{
	name = "zhongyong",
	can_preshow = true,
	events = {sgs.CardFinished},
	view_as_skill = zhongyongVS,
    can_trigger = function(self, event, room, player, data)
		local use = data:toCardUse()
		if use.from and use.from:isAlive() and use.from:hasSkill(self) and use.card and use.card:isKindOf("Slash") then
			--一定不要用player代替use.from！为了获得真正的使用者（谮毁），因为CardUsed到CardFinished之间不会检测使用者的变化从而改变player
			local toGet, toGetOneTime, toGetOneTime_Temp = {}, {}, {}
			
			if use.card:isVirtualCard() then
				toGetOneTime_Temp = sgs.QList2Table(use.card:getSubcards())
			else
				table.insert(toGetOneTime_Temp, use.card:getEffectiveId())
			end
			local all_discard_pile = true
			for _,id in ipairs(toGetOneTime_Temp) do
				if room:getCardPlace(id) ~= sgs.Player_DiscardPile then all_discard_pile = false break end
			end
			if all_discard_pile then table.insert(toGet, table.concat(toGetOneTime_Temp, "+")) end
			
			local jinksReceived = use.from:getTag("zhongyongJinksReceived_" .. use.card:toString()):toString()
			if jinksReceived ~= "" then  --jinksReceived记录方式：-1+闪1子卡1~闪1子卡2+闪2子卡+闪3子卡+……（因为子卡必须全在弃牌堆）
				toGetOneTime_Temp = jinksReceived:split("+")
				toGetOneTime = {}
				for _,jinkIds in ipairs(toGetOneTime_Temp) do
					local all_discard_pile = true  --判断每张不同的闪的所有子卡是否均在弃牌堆
					for _,id in ipairs(jinkIds:split("~")) do
						if room:getCardPlace(tonumber(id)) ~= sgs.Player_DiscardPile then all_discard_pile = false break end
					end
					if all_discard_pile then
						for _,id in ipairs(jinkIds:split("~")) do
							table.insert(toGetOneTime, tonumber(id))
						end
					end
				end
				if next(toGetOneTime) then table.insert(toGet, table.concat(toGetOneTime, "+")) end
			end
			if not next(toGet) then return "" end
			
			for _,p in sgs.qlist(room:getOtherPlayers(use.from)) do
				if not use.to:contains(p) then
					return self:objectName(), use.from
				end
			end
		end
		return ""
	end,
    on_cost = function(self, event, room, player, data, ask_who)
		local use = data:toCardUse()
		local toGet, toGetOneTime, toGetOneTime_Temp = {}, {}, {}
		local ids = sgs.IntList()
			
		if use.card:isVirtualCard() then
			toGetOneTime_Temp = sgs.QList2Table(use.card:getSubcards())
		else
			table.insert(toGetOneTime_Temp, use.card:getEffectiveId())
		end
		local all_discard_pile = true
		for _,id in ipairs(toGetOneTime_Temp) do
			if room:getCardPlace(id) ~= sgs.Player_DiscardPile then all_discard_pile = false break end
		end
		if all_discard_pile then table.insert(toGet, table.concat(toGetOneTime_Temp, "+")) end
		
		local jinksReceived = use.from:getTag("zhongyongJinksReceived_" .. use.card:toString()):toString()
		if jinksReceived ~= "" then  --jinksReceived记录方式：-1+闪1子卡1~闪1子卡2+闪2子卡+闪3子卡+……（因为子卡必须全在弃牌堆）
			toGetOneTime_Temp = jinksReceived:split("+")
			toGetOneTime = {}
			for _,jinkIds in ipairs(toGetOneTime_Temp) do
				local all_discard_pile = true  --判断每张不同的闪的所有子卡是否均在弃牌堆
				for _,id in ipairs(jinkIds:split("~")) do
					if room:getCardPlace(tonumber(id)) ~= sgs.Player_DiscardPile then all_discard_pile = false break end
				end
				if all_discard_pile then
					for _,id in ipairs(jinkIds:split("~")) do
						table.insert(toGetOneTime, tonumber(id))
					end
				end
			end
			if next(toGetOneTime) then table.insert(toGet, table.concat(toGetOneTime, "+")) end
		end
		if not next(toGet) then return "" end
		
		local list = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(use.from)) do
			if not use.to:contains(p) then
				list:append(p)
				room:setPlayerFlag(p, "zhongyongAvailable")
			end
		end
		if list:isEmpty() then return false end
		
		room:setPlayerProperty(ask_who, "zhongyongCards", sgs.QVariant(table.concat(toGet, "|")))  --格式：slash1+slash2|jink1+jink2+...
		ask_who:removeTag("zhongyongTarget")
		ask_who:removeTag("zhongyongToGive")
		for _,cardids in ipairs(toGet) do
			if cardids == "" then continue end
			for _,id in ipairs(cardids:split("+")) do 
				ids:append(tonumber(id))
			end
		end
		if ids:length() == 0 then return false end
		room:notifyMoveToPile(ask_who, ids, self:objectName(), sgs.Player_DiscardPile, true, true)
		local invoked = room:askForUseCard(ask_who, "@@zhongyong", "@zhongyong", -1, sgs.Card_MethodNone)
		
		room:notifyMoveToPile(ask_who, ids, self:objectName(), sgs.Player_DiscardPile, false, false)
		room:setPlayerProperty(ask_who, "zhongyongCards", sgs.QVariant())
		for _,p in sgs.qlist(list) do
			room:setPlayerFlag(p, "-zhongyongAvailable")
		end
		if invoked then
			room:broadcastSkillInvoke(self:objectName(), ask_who:inDeputySkills(self) and 2 or 1, ask_who)
			local msg = sgs.LogMessage()
			msg.type, msg.from, msg.arg = "#InvokeSkill", ask_who, self:objectName()
			room:sendLog(msg)
			return true
		end
		return false
	end,
    on_effect = function(self, event, room, player, data, ask_who)
		local target = ask_who:getTag("zhongyongTarget"):toPlayer()
		ask_who:removeTag("zhongyongTarget")
		local skillCard = ask_who:getTag("zhongyongToGive"):toCard()
		ask_who:removeTag("zhongyongToGive")
		if not target or target:isDead() or not skillCard then return end
		
		local red = false
		for _,id in sgs.qlist(skillCard:getSubcards()) do
			if sgs.Sanguosha:getCard(id):isRed() then red = true break end
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, ask_who:objectName(), self:objectName(), "")
		room:obtainCard(target, skillCard, reason)
		
		if red and target and target:isAlive() and target:objectName()~= ask_who:objectName() then
			local slashlist = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getOtherPlayers(ask_who)) do
				if ask_who:inMyAttackRange(p) and target:canSlash(p, false) then
					slashlist:append(p)
				end
			end
			if slashlist:isEmpty() then return false end
			room:askForUseSlashTo(target, slashlist, "@zhongyong-slash:" .. ask_who:objectName(), false)
		end
	end,
}
zhongyongClear = sgs.CreateTriggerSkill{
	name = "#zhongyong-clear",
	events = {sgs.CardFinished},
	global = true,
	priority = 1,
    on_record = function(self, event, room, player, data)
		local use = data:toCardUse()
		if use.card and use.card:isKindOf("Slash") then
			--use.card:removeTag("zhongyongJinksReceived")
			use.from:removeTag("zhongyongJinksReceived_" .. use.card:toString())
		end
	end,
    can_trigger = function(self, event, room, player, data, ask_who)
		return ""
	end,
}
zhoucang:addSkill(zhongyong)
zhoucang:addSkill(zhongyongRecord1)
zhoucang:addSkill(zhongyongRecord2)
zhoucang:addSkill(zhongyongRecord3)
zhoucang:addSkill(zhongyongClear)
extension:insertRelatedSkills("zhongyong","#zhongyong-record1")
extension:insertRelatedSkills("zhongyong","#zhongyong-record2")
extension:insertRelatedSkills("zhongyong","#zhongyong-record3")
extension:insertRelatedSkills("zhongyong","#zhongyong-clear")

-----祖茂-----

yinbing = sgs.CreateTriggerSkill{
	name = "yinbing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Discard then
			if player:isWounded() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if not p:isNude() then
				targets:append(p)
			end 
		end
		if targets:length() == 0 then return false end
		local target_choose = room:askForPlayersChosen(player,targets,self:objectName(),0,player:getMaxHp()-player:getHp(),self:objectName().."-invoke:::"..player:getMaxHp()-player:getHp(),true)
		if target_choose:length() > 0 then
			player:showGeneral(player:inHeadSkills("yinbing"))
			room:broadcastSkillInvoke(self:objectName())
			for _, p in sgs.qlist(target_choose) do
				local id = room:askForCardChosen(player, p, "he", self:objectName(), false, sgs.Card_MethodDiscard)
				room:throwCard(id, p, player)
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
zumao:addSkill(yinbing)

-----程昱-----

shefuCard = sgs.CreateSkillCard{
	name = "shefuCard",
	skill_name = "shefu",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:objectName() ~= player:objectName()
	end,
	on_effect = function(self, effect)
		effect.to:addToPile("fu", self, false)
		local banList = effect.from:property("shefuProp"):toString():split("+")
		table.insert(banList,sgs.Sanguosha:getCard(self:getSubcards():first()):objectName())
		effect.from:getRoom():setPlayerProperty(effect.from, "shefuProp", sgs.QVariant(table.concat(banList,"+")))
	end,
}
shefu = sgs.CreateOneCardViewAsSkill{
	name = "shefu",
	view_filter = function(self, card)
		return not table.contains(sgs.Self:property("shefuProp"):toString():split("+"),card:objectName()) and not card:isKindOf("EquipCard")
	end,
	view_as = function(self, originalCard)
		local card = shefuCard:clone()
		card:addSubcard(originalCard)
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		local num = player:getMaxHp() - player:getHp()
		if num == 0 then num = 1 end
		return player:usedTimes("#shefuCard") < num
	end
}

shefuDamage = sgs.CreateTriggerSkill{
	name = "#shefuDamage",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponded,sgs.Damaged,sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.Damaged then
			if not player:isAlive() or not player:hasShownSkill("shefu") then return "" end
			local damage = data:toDamage()
			if damage.card then
				local shefuList = player:property("shefuProp"):toString():split("+")
				for i = 1 , #shefuList, 1 do if shefuList[i] == damage.card:objectName() then table.remove(shefuList,i) break end end
				room:setPlayerProperty(player,"shefuProp",sgs.QVariant(table.concat(shefuList,"+")))
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_Start then return "" end
			if not player:isAlive() or not player:hasShownSkill("shefu") then return "" end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				for _, c in sgs.qlist(p:getPile("fu")) do
					local ccc = sgs.Sanguosha:getCard(c)
					dummy:addSubcard(ccc)
				end
			end
			if dummy:getSubcards():length() > 0 then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), "shefu", "")
				room:obtainCard(player, dummy, reason, false)
			end
		end
		local card
		if event == sgs.CardUsed then  
			card = data:toCardUse().card
		elseif event == sgs.CardResponded then
			local response = data:toCardResponse()
			card = response.m_card
		end
		for _, c in sgs.qlist(player:getPile("fu")) do
			local ccc = sgs.Sanguosha:getCard(c)
			if ccc:objectName() == card:objectName() then
				room:getThread():delay(500)
				room:broadcastSkillInvoke("shefu")
				local damage = sgs.DamageStruct()
				damage.from = room:findPlayerBySkillName("shefu")
				damage.to = player
				damage.damage = 1
				room:damage(damage)
				room:throwCard(ccc,player)
				if card:isNDTrick() and not card:isKindOf("Nullification") and not card:isKindOf("HegNullification") then
					local use = data:toCardUse()
					local nullified_list = use.nullified_list
					for _, p in sgs.qlist(use.to) do
						room:setEmotion(p, "cancel")
						table.insert(nullified_list, p:objectName())
					end
					use.nullified_list = nullified_list
					data:setValue(use)
				end
				break
			end
		end
		return ""
	end
}
benyu = sgs.CreateMasochismSkill{
	name = "benyu",
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local damage = data:toDamage()
		if damage.from and damage.from:isAlive() then
			return (damage.from:getHandcardNum() ~= player:getHandcardNum()) and self:objectName() or ""
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.from:getHandcardNum() > player:getHandcardNum() then
			if player:askForSkillInvoke(self:objectName(), data) then
				room:broadcastSkillInvoke(self:objectName(), 1, player)
				player:setTag("benyuType", sgs.QVariant(damage.from:getHandcardNum()))
				return true 
			end
		elseif damage.from:getHandcardNum() < player:getHandcardNum() then
			room:setPlayerProperty(player,"benyuProp",data)
			if room:askForDiscard(player, self:objectName(), 999, damage.from:getHandcardNum() + 1, true, false, "@Benyu-discard::" .. damage.from:objectName() .. ":" .. damage.from:getHandcardNum() + 1, true) then
				room:broadcastSkillInvoke(self:objectName(), 2, player)
				player:setTag("benyuType", sgs.QVariant(-1))
				return true 
			end
		end
		return false
	end,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local x = player:getTag("benyuType"):toInt()
		player:removeTag("benyuType")
		if x > 0 then
			room:drawCards(player, math.max(math.min(x, 5) - player:getHandcardNum(), 0), self:objectName())
		elseif x == -1 then
			if damage.from and damage.from:isAlive() then
				room:damage(sgs.DamageStruct(self:objectName(), player, damage.from))
			end
		end
	end,
	on_turn_broken = function(self, function_name, event, room, player, data, ask_who)
		player:removeTag("benyuType")
	end
}
chengyu:addSkill(shefu)
chengyu:addSkill(shefuDamage)
chengyu:addSkill(benyu)
extension:insertRelatedSkills("shefu","#shefuDamage")

-----钟会-----

zili = sgs.CreateTriggerSkill{
	name = "zili",
	frequency = sgs.Skill_Limited,
	limit_mark = "@zili", 
	relate_to_place = "head",
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getMark("@zili") == 0 then return "" end
		if player:getPhase() == sgs.Player_Finish then
			return self:objectName()
		end	
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("zhonghui", self:objectName())
		player:loseMark("@zili")
		player:drawCards(3)
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
		player:removeGeneral(false)
		room:setPlayerProperty(player, "role", sgs.QVariant("careerist"))
		room:acquireSkill(player,"quanxiang")
	end 
}
quanxiang = sgs.CreateTriggerSkill{
	name = "quanxiang",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageCaused},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.from:objectName() == player:objectName() and damage.to:hasShownGeneral2() then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local damage = data:toDamage()
		local card = room:askForCard(damage.to, "EquipCard", "@quanxiang", data, sgs.Card_MethodNone, player)
		if card then
			player:obtainCard(card)
		else
			if player:getMark("quanxiangMark") == 0 then
				room:doSuperLightbox("zhonghui", self:objectName())
				for _,skill in sgs.qlist(player:getGeneral2():getVisibleSkillList(true,false)) do
					room:detachSkillFromPlayer(player,skill:objectName())
				end 
				room:addPlayerMark(player,"quanxiangMark",1)
				local skill_list = {}
				for _,skill in sgs.qlist(damage.to:getGeneral2():getVisibleSkillList(true,false)) do
					if not table.contains(skill_list, skill:objectName()) and not player:hasSkill(skill) then
						table.insert(skill_list, skill:objectName())
					end
				end 
				local general2Name = damage.to:getGeneral2Name()
				damage.to:removeGeneral(false)  --士兵没有General的bug
				room:changePlayerGeneral2(player, general2Name)
				room:detachSkillFromPlayer(player,"dazhi")
				if #skill_list ~=0 then
					for _, skill in ipairs(skill_list) do
						room:acquireSkill(player, skill,true,false)
					end
				end
				return true
			else
				room:notifySkillInvoked(player, self:objectName())
				room:loseHp(damage.to, 1)
			end
		end
		return false
	end
}
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("quanxiang") then skills:append(quanxiang) end
sgs.Sanguosha:addSkills(skills)
dazhi = sgs.CreateTriggerSkill{
	name = "dazhi",
	relate_to_place = "head",
	events = {sgs.EventPhaseStart,sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Discard then
				room:setPlayerMark(player,"dazhiMark",room:getAlivePlayers():length())
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Discard then
				room:setPlayerMark(player,"dazhiMark",0)
			end
		end
		return ""
	end
}
dazhi1 = sgs.CreateMaxCardsSkill{
	name = "#dazhi1" ,
	global = true,
	extra_func = function(self, player)
		if (player:hasShownSkill("dazhi")) then
			return player:getMark("dazhiMark") - player:getHp()
		end
		return 0
	end,
	priority = -5
}
dazhi2 = sgs.CreateTriggerSkill{
	name = "#dazhi2",
	events = {sgs.DrawNCards},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill("dazhi")) then return "" end
		if not player:hasShownSkill("dazhi") then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local value = data:toInt()
		local new_value = value + player:getMaxHp() - player:getHp()
		data:setValue(new_value)
	end
}
quanji = sgs.CreateTriggerSkill{
	name = "quanji",
	relate_to_place = "deputy",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local damage = data:toDamage()
		local trigger_list = {}
		for i = 1, damage.damage, 1 do
			table.insert(trigger_list, self:objectName())
		end
		return table.concat(trigger_list,",")
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:drawCards(player, 1, self:objectName())
		if player:isAlive() and not player:isKongcheng() then
			local card_id
			if player:getHandcardNum() == 1 then
				card_id = player:handCards():first()
				room:getThread():delay()
			else
				local exc_card = room:askForExchange(player, self:objectName(), 1, 1, "quanjiPush", "", ".|.|.|hand")
				if exc_card then
					card_id = exc_card:getEffectiveId()
				else
					card_id = player:getHandcards():at(math.random(0, player:getHandcards():length() - 1))
				end
			end
			player:addToPile("power", card_id)
		end
	end,
}
quanjiKeep = sgs.CreateMaxCardsSkill{
	name = "#quanji-keep",
	extra_func = function(self, target)
		if target:hasShownSkill("quanji") then
			return target:getPile("power"):length()
		else
			return 0
		end
	end
}
quanjiClear = sgs.CreateTriggerSkill{
	name = "#quanji-clear",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventLoseSkill},
	on_record = function(self, event, room, player, data)
		if data:toString() == "quanji" then
			player:clearOnePrivatePile("power")
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
paiyiCard = sgs.CreateSkillCard{
	name = "paiyiCard",
	skill_name = "paiyi",
    will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, selected, to_select)
		return #selected == 0
	end,
	extra_cost = function(self, room, use)
		local powers = use.from:getPile("power")
		if powers:isEmpty() then return false end
		local card_id = self:getSubcards():first()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", use.to:first():objectName(), "paiyi", "")
		room:throwCard(sgs.Sanguosha:getCard(card_id), reason, nil)
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		room:broadcastSkillInvoke("paiyi", (effect.from:objectName() == effect.to:objectName()) and 1 or 2)
		room:drawCards(effect.to, 2, self:objectName())
		if effect.to:isAlive() and effect.to:getHandcardNum() > effect.from:getHandcardNum() then
			room:damage(sgs.DamageStruct("paiyi", effect.from, effect.to))
		end
	end,
}
paiyi = sgs.CreateOneCardViewAsSkill{
	name = "paiyi",
	relate_to_place = "deputy",
	expand_pile = "power",
	filter_pattern = ".|.|.|power",
	view_as = function(self, card)
        local paiyi_card = paiyiCard:clone()
		paiyi_card:addSubcard(card)
        paiyi_card:setShowSkill(self:objectName())
        return paiyi_card
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#paiyiCard") and not player:getPile("power"):isEmpty()
	end
}
zhonghui:addSkill(zili)
zhonghui:addSkill(dazhi)
zhonghui:addSkill(dazhi1)
zhonghui:addSkill(dazhi2)
zhonghui:addSkill(quanji)
zhonghui:addSkill(quanjiKeep)
zhonghui:addSkill(quanjiClear)
zhonghui:addSkill(paiyi)
extension:insertRelatedSkills("dazhi","#dazhi1")
extension:insertRelatedSkills("dazhi","#dazhi2")
extension:insertRelatedSkills("quanji","#quanji-keep")
extension:insertRelatedSkills("quanji","#quanji-clear")
zhonghui:setDeputyMaxHpAdjustedValue(-1)

-----诸葛瑾-----

hongyuan = sgs.CreateTriggerSkill{
	name = "hongyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards,sgs.AfterDrawNCards},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.DrawNCards then
			return self:objectName()
		else
			if player:getMark("hongyuanMark") > 0 then
				room:setPlayerMark(player,"hongyuanMark",0)
				local choice = room:askForChoice(player, self:objectName(), "friend_draw+enemy_discard")
				if choice == "friend_draw" then
					if player:getRole() == "careerist" then player:drawCards(1) return "" end
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if p:hasShownOneGeneral() and p:getKingdom() == player:getKingdom() and p:getRole() ~= "careerist" then
							p:drawCards(1)
						end
					end
				elseif choice == "enemy_discard" then
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						if player:getRole() == "careerist" then
							room:askForDiscard(p, self:objectName(), 1, 1, false, true)
						elseif player:getKingdom() ~= p:getKingdom() or p:getRole() == "careerist" or not p:hasShownOneGeneral() then
							room:askForDiscard(p, self:objectName(), 1, 1, false, true)
						end
					end
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		if event == sgs.DrawNCards then
			data:setValue(0)
			room:setPlayerMark(player,"hongyuanMark",1)
		end
	end
}
mingzhe = sgs.CreateTriggerSkill{
	name = "mingzhe",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if (player:getPhase() ~= sgs.Player_NotActive) then return "" end
		local move = data:toMoveOneTime()
		if not move.from then return "" end
		if move.from and move.from:objectName() ~= player:objectName() then return "" end
		if event == sgs.BeforeCardsMove then
			room:setPlayerMark(player,"mingzheMark",0)
			local reason = move.reason.m_reason
			local reasonx = bit32.band(reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
			local Yes = reasonx == sgs.CardMoveReason_S_REASON_DISCARD or reasonx == sgs.CardMoveReason_S_REASON_USE or reasonx == sgs.CardMoveReason_S_REASON_RESPONSE
			if Yes then
				local card
				local i = 0
				for _,id in sgs.qlist(move.card_ids) do
					card = sgs.Sanguosha:getCard(id)
					if move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip then
						if card and card:isRed() and room:getCardOwner(id):getSeat() == player:getSeat() then
							i = i + 1
						end
					end
				end
				player:gainMark("mingzheMark",i)
				--room:setPlayerMark(player,"mingzheMark",i)
				return ""
			end
		else
			if player:getMark("mingzheMark") > 0 then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:drawCards(player:getMark("mingzheMark"))
		return false
	end
}
zhugejin:addSkill(hongyuan)
zhugejin:addSkill(mingzhe)

-----李严-----

duliangCard = sgs.CreateSkillCard{
	name = "duliangCard",
	target_fixed = true,
	skill_name = "duliang",
	on_use = function(self, room, source, targets)
	end,
}
duliangVS = sgs.CreateZeroCardViewAsSkill{
	name = "duliang",
	view_as = function(self, cards)
		local duliangcard = duliangCard:clone()
		return duliangcard
	end,
	enabled_at_play = function(self, player)
		return player:hasUsed("#duliangCard")
	end
}
duliang = sgs.CreateTriggerSkill{
	name = "duliang",
	frequency = sgs.Skill_Frequent,
	is_battle_array = true,
	battle_array_type = sgs.Formation,
	view_as_skill = duliangVS,
	events = {sgs.TargetConfirmed},
	can_trigger = function(self, event, room, player, data)
		local liyan = room:findPlayerBySkillName(self:objectName())
		if not (liyan and liyan:isAlive()) then return "" end
		if not (player and player:isAlive()) then return "" end
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.to:contains(player) then return "" end
			if (use.card:isKindOf("SupplyShortage") or use.card:isKindOf("Dismantlement")) then
				if liyan:inFormationRalation(player) then --or liyan:objectName() == player:objectName() then
				--[[local targets = {}
				for _, p in sgs.qlist(use.to) do
					if liyan:inFormationRalation(p) or liyan:objectName() == p:objectName() then
						table.insert(targets, p:objectName())
					end
				end]]--
					return self:objectName(),liyan:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.card:isKindOf("SupplyShortage") then
				local _ids = sgs.IntList()
				_ids:append(use.card:getId())
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, use.to:first():objectName(), self:objectName(), "")
				local moves = sgs.CardsMoveList()
				local move = sgs.CardsMoveStruct(_ids, use.to:first(), nil, sgs.Player_PlaceJudge, sgs.Player_DiscardPile, reason)
				moves:append(move)
				room:moveCardsAtomic(moves, true)
				room:setEmotion(player, "cancel")
			else
				room:setEmotion(player, "cancel")
				local nullified_list = use.nullified_list
			    table.insert(nullified_list, player:objectName())
			    use.nullified_list = nullified_list
			    data:setValue(use)
			end
		end
	end
}
duliangTargetMod = sgs.CreateTargetModSkill{
	name = "#duliangTargetMod",
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasShownSkill("duliang") then
			return player:getFormation():length() - 1
		else
			return 0
		end
	end
}	
fulin = sgs.CreateTriggerSkill{
	name = "fulin",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Death,sgs.Dying},
	can_trigger = function(self, event, room, player, data)
		local liyan = room:findPlayerBySkillName(self:objectName())
		if not (liyan and liyan:isAlive()) then return "" end
		if event == sgs.Dying then
			local dying = data:toDying()
			if player:objectName() ~= dying.who:objectName() then return "" end
			if player:getMark("fulinMark") == 0 then
				room:setPlayerMark(player,"fulinMark",1)
				return self:objectName(),liyan:objectName()
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if player:objectName() ~= death.who:objectName() then return "" end
			if player:getKingdom() == "shu" and player:getRole() ~= "careerist" then
				return self:objectName(),liyan:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if ask_who:hasShownSkill(self:objectName()) and event == sgs.Death then
			room:notifySkillInvoked(ask_who, self:objectName())
			return true
		end
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.Dying then
			ask_who:drawCards(2)
			room:broadcastSkillInvoke(self:objectName())
		elseif event == sgs.Death then
			ask_who:gainMark("@fulin")
			room:broadcastSkillInvoke(self:objectName())
		end
	end
}
fulin_limit = sgs.CreateMaxCardsSkill{
	name = "#fulin_limit" ,
	extra_func = function(self, player)
		if (player:hasShownSkill("fulin")) then
			return player:getMark("@fulin")
		end
		return 0
	end
}
liyan:addSkill(duliang)
liyan:addSkill(duliangTargetMod)
liyan:addSkill(fulin)
liyan:addSkill(fulin_limit)
extension:insertRelatedSkills("fulin","#fulin_limit")
extension:insertRelatedSkills("duliang","#duliangTargetMod")

-----君主·孙权-----

shouguan = sgs.CreateTriggerSkill{
	name = "shouguan",
	frequency = sgs.Skill_Compulsory, 
	events = {sgs.EventPhaseStart,sgs.Death,sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		local sunquan = room:findPlayerBySkillName(self:objectName())
		if not (sunquan and sunquan:isAlive()) then return "" end
		if event == sgs.EventPhaseStart then
			if sunquan:getPhase() ~= sgs.Player_Finish then return ""  end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:getMark("@dadudu") == 0 then
				return ""
			end
		end
		if event == sgs.CardUsed then
			if player:getMark("@dadudu") > 0 then
				local use = data:toCardUse()
				if use.card:isKindOf("TrickCard") then
					if room:askForSkillInvoke(player,self:objectName(),data) then
						sunquan:drawCards(1)
						room:broadcastSkillInvoke(self:objectName(),1)
						return ""
					end
				end
			end
			return ""
		end
		local can_invoke = false
		for _, p in sgs.qlist(room:getOtherPlayers(sunquan)) do
			if p:getMark("@dadudu") > 0 then
				return ""
			end
			if p:hasShownOneGeneral() and p:getKingdom() == sunquan:getKingdom() then
				can_invoke = true
			end
		end
		if can_invoke then
			return self:objectName(),sunquan:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(ask_who)) do
			if p:hasShownOneGeneral() and p:getKingdom() == ask_who:getKingdom() then
				targets:append(p)
			end
		end
		if targets:length() == 0 then return false end
		local to = room:askForPlayerChosen(ask_who, targets, self:objectName(), self:objectName().."-invoke", false, true)
		if to then
			room:broadcastSkillInvoke(self:objectName(),2)
			to:gainMark("@dadudu")
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
	--priority = -11
}
shenduanCard = sgs.CreateSkillCard{
	name = "shenduanCard",
	target_fixed = true,
	will_throw = false,
	mute = true,
	on_use = function(self, room, source, targets)
		if source:isAlive() then
			room:broadcastSkillInvoke("shenduan")
			local card_ids,to_top,cards = sgs.IntList(),sgs.IntList(),sgs.VariantList()
			for _, idstring in sgs.qlist(self:getSubcards()) do 
				card_ids:append(tonumber(idstring))
				cards:append(sgs.QVariant(idstring))
			end
			if self:getSubcards():length() > 0 then
				source:setTag("AI_shenduanDrawPileCards", sgs.QVariant(cards))
				local move = sgs.CardsMoveStruct()
				move.card_ids = card_ids
				move.to_place = sgs.Player_PlaceTable
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_UNKNOWN, source:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
				local AsMove = room:askForMoveCards(source, card_ids, sgs.IntList(), true, "shenduan", "", self:objectName(), card_ids:length(), card_ids:length(), false, false)
				for _, id in sgs.qlist(AsMove.bottom) do
					to_top:prepend(id) 
				end
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), self:objectName(), "")
				local move = sgs.CardsMoveStruct(to_top, source, nil, sgs.Player_DiscardPile, sgs.Player_DrawPile, reason)
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:setTag("shenduanMoving", sgs.QVariant(true))  --for AI (filterEvent)
				room:moveCardsAtomic(moves, false)
				room:removeTag("shenduanMoving")
			end
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for i = 1, self:getSubcards():length(), 1  do
				dummy:addSubcard(sgs.Sanguosha:getCard(room:getDrawPile():at(room:getDrawPile():length()-i)))
			end
			room:obtainCard(source, dummy, false)
		end
	end
}
shenduan = sgs.CreateViewAsSkill{
	name = "shenduan",
	n = 999,
	view_filter = function(self, selected, to_select)
		return #selected < sgs.Self:getMark("shenduanMark")
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local shenduan_card = shenduanCard:clone()
		for _,card in pairs(cards) do
			shenduan_card:addSubcard(card)
		end
		shenduan_card:setSkillName(self:objectName())
		return shenduan_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#shenduanCard") and player:canDiscard(player, "he")
	end,
	enabled_at_response = function(self, target, pattern)
		return pattern == "@shenduan"
	end
}
shenduan1 = sgs.CreateTriggerSkill{
	name = "#shenduan1",
	events = {sgs.EventPhaseStart,sgs.GeneralShown,sgs.EventAcquireSkill},
	global = true,
	can_trigger = function(self, event, room, player, data)
		if event == sgs.EventPhaseStart then
			if not (player and player:isAlive() and player:hasSkill("shenduan")) then return "" end
			if not player:getPhase() == sgs.Player_Play then return "" end
		end
		local num = 1
		if player:getRole() == "careerist" then num = 1 end
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasShownOneGeneral() then
				if p:getKingdom() == player:getKingdom() and not p:getRole() ~= "careerist" then
					num = num + 1 
					if p:isWounded() and p:getMark("@dadudu") > 0 then
						num = num + p:getMaxHp() - p:getHp()
					end
				end
			end
		end
		if num < 2 then
			num = 2
		end
		room:setPlayerMark(player,"shenduanMark",num)
		return ""
	end
}
zaoli = sgs.CreateTriggerSkill{
	name = "zaoli",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GeneralShown},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:drawCards(2)
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(player, recover)
		if player:isChained() then
			room:setPlayerProperty(player, "chained", sgs.QVariant(false))
		end
		if not player:faceUp() then
			player:turnOver()
		end
	end
}
lord_sunquan:addSkill(shenduan)
lord_sunquan:addSkill(shenduan1)
extension:insertRelatedSkills("shenduan","#shenduan1")
lord_sunquan:addSkill(zaoli)
lord_sunquan:addSkill(shouguan)

-----戏志才-----

zaoshi = sgs.CreateTriggerSkill{
	name = "zaoshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.FinishJudge,sgs.StartJudge,sgs.GeneralShown, sgs.EventAcquireSkill},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.StartJudge or event == sgs.GeneralShown or event == sgs.EventAcquireSkill then
			if player:hasShownSkill("tiandu") and player:hasShownSkill(self:objectName()) then
				room:detachSkillFromPlayer(player,"tiandu")
				if not player:hasSkill("tiandu_xizhicai") then
					room:acquireSkill(player,"tiandu_xizhicai",true,not player:inHeadSkills(self:objectName()))
				end
				room:setPlayerMark(player,"tianduMark",1)
			end
			return ""
		end
		if not player:hasSkill("tiandu_xizhicai") then
			return "tiandu_xizhicai"
		end
		return ""
	end
}
tiandu_xizhicai = sgs.CreateTriggerSkill{
	name = "tiandu_xizhicai",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.FinishJudge},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			player:showGeneral(player:inHeadSkills("zaoshi"))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("zaoshi")
		local room = player:getRoom()
		local judge = data:toJudge()
		local card = judge.card
		local card_data = sgs.QVariant()
		card_data:setValue(card)
		if room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceJudge then
			player:obtainCard(card)
		end
		if player:getMark("tianduMark") > 0 then
			local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), self:objectName().."-invoke", true, true)
			if to then
				to:obtainCard(card)
			end
		end
		return true
	end,
	priority = 100,
}
xianfu = sgs.CreateTriggerSkill{
	name = "xianfu" ,
	events = {sgs.GeneralShown, sgs.HpRecover, sgs.Damaged},
	--global = true,
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local xizhicai = room:findPlayerBySkillName(self:objectName())
		if event == sgs.GeneralShown then
			if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
			if player:hasSkill(self:objectName()) then
				return self:objectName()
			end
		elseif event == sgs.HpRecover or event == sgs.Damaged then
			if xizhicai and player:getMark("@fu") > 0 then
				return self:objectName(),xizhicai:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GeneralShown then
			local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "xianfu-invoke", false, true)
			if to then
				room:addPlayerMark(to, "@fu")
				room:broadcastSkillInvoke(self:objectName(), math.random(1, 2))
			end
		else
			for _, p in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if player:getMark("@fu") > 0 and player:isAlive() then
					if event == sgs.Damaged then
						room:broadcastSkillInvoke(self:objectName(), math.random(3, 4))
						room:damage(sgs.DamageStruct(self:objectName(), nil, p, data:toDamage().damage))
					else
						room:broadcastSkillInvoke(self:objectName(), math.random(5, 6))
						local recover = sgs.RecoverStruct()
						recover.who = p
						room:recover(p, recover)
					end
				end
			end
		end
		return false
	end
}
chouce = sgs.CreateTriggerSkill{
	name = "chouce",
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local damage = data:toDamage()
		local trigger_list = {}
		for i = 1, damage.damage, 1 do
			table.insert(trigger_list, self:objectName())
		end
		return table.concat(trigger_list,",")
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player, self:objectName(), data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName(), 1)
		local judge = sgs.JudgeStruct()
		judge.pattern = "."
		judge.reason = self:objectName()
		judge.who = player
		room:judge(judge)
		if judge.card:isRed() then
			room:setPlayerProperty(player,"chouceProp",sgs.QVariant("red"))
			local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "chouce1-invoke", true, true)
			room:setPlayerProperty(player,"chouceProp",sgs.QVariant())
			if to then
				local x = 1
				if to:getMark("@fu") > 0 then
					x = 2
					room:broadcastSkillInvoke(self:objectName(), 2)
				end
				to:drawCards(x, self:objectName())
			end
		elseif judge.card:isBlack() then
			local targets = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if player:canDiscard(p, "hej") then
					targets:append(p)
				end
			end
			if not targets:isEmpty() then
				room:setPlayerProperty(player,"chouceProp",sgs.QVariant("black"))
				local to = room:askForPlayerChosen(player, targets, self:objectName(), "chouce2-invoke", true, true)
				room:setPlayerProperty(player,"chouceProp",sgs.QVariant("red"))
				if to then
					if to:getMark("@fu") > 0 then
						room:broadcastSkillInvoke(self:objectName(), 2)
					end
					local id = room:askForCardChosen(player, to, "hej", self:objectName(), false, sgs.Card_MethodDiscard)
					room:throwCard(id, to, player)
				end
			end
		end
	return false
	end
}
xizhicai:addSkill(zaoshi)
xizhicai:addSkill(xianfu)
xizhicai:addSkill(chouce)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("tiandu_xizhicai") then skills:append(tiandu_xizhicai) end
sgs.Sanguosha:addSkills(skills)

-----虞翻-----

zongxuan = sgs.CreateTriggerSkill{
	name = "zongxuan",
	can_preshow = true,
	events = {sgs.CardsMoveOneTime},
	frequency = sgs.Skill_NotFrequent,
 	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return end
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName()
			and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)) == sgs.CardMoveReason_S_REASON_DISCARD then
			
			if move.from_places:contains(sgs.Player_PlaceTable) and move.to_place == sgs.Player_DiscardPile then  --条件B
				local zongxuanStack_str = player:getTag("zongxuanStack"):toString()
				if zongxuanStack_str == "" then return end
				local zongxuanStack = zongxuanStack_str:split("|")
				
				if player:hasSkill(self) and player:getTag("zongxuanPopIndex"):toInt() ~= #zongxuanStack then
					local zongxuanOneTime_str = zongxuanStack[#zongxuanStack]
					local zongxuanOneTime = zongxuanOneTime_str:split("+")
					table.removeAll(zongxuanOneTime, "-1")
					local zongxuanRemains = {}
					for i, id in sgs.qlist(move.card_ids) do
						if table.contains(zongxuanOneTime, tostring(id)) and room:getCardPlace(id) == sgs.Player_DiscardPile then
							table.insert(zongxuanRemains, id)
						end
					end
					if next(zongxuanRemains) then
						room:setPlayerProperty(player, "zongxuanToGet", sgs.QVariant(table.concat(zongxuanRemains, "+")))
						return self:objectName()
					end
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local zongxuanStack_str = player:getTag("zongxuanStack"):toString()
		local zongxuanStack = zongxuanStack_str:split("|")
		player:setTag("zongxuanPopIndex", sgs.QVariant(#zongxuanStack))
		
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		local zongxuanToGet = player:property("zongxuanToGet"):toString():split("+")
		room:setPlayerProperty(player, "zongxuanToGet", sgs.QVariant())
		local card_ids, to_top = sgs.IntList(), sgs.IntList()
		for _, idstring in ipairs(zongxuanToGet) do 
			card_ids:append(tonumber(idstring))
		end

		local AsMove = room:askForMoveCards(player, card_ids, sgs.IntList(), true, self:objectName(), "", self:objectName(), 1, card_ids:length(), false, false)
		if AsMove.bottom:isEmpty() then 
			return false 
		end
		
		for _, id in sgs.qlist(AsMove.bottom) do
			to_top:prepend(id)
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
		local move = sgs.CardsMoveStruct(to_top, player, nil, sgs.Player_DiscardPile, sgs.Player_DrawPile, reason)
		local moves = sgs.CardsMoveList()
		moves:append(move)
		room:setTag("zongxuanMoving", sgs.QVariant(true))  --for AI (filterEvent)
		room:moveCardsAtomic(moves, true)
		room:removeTag("zongxuanMoving")
		 
		local tab = {}
		for _, id in sgs.qlist(AsMove.bottom) do
			table.insert(tab, id)
		end
		local msg = sgs.LogMessage()
		msg.type = "$GuanxingTop"
		msg.card_str = table.concat(tab, "+")
		room:sendLog(msg)
		return false
	end,
}
zongxuanRecord = sgs.CreateTriggerSkill{
	name = "#zongxuan-record",
	events = {sgs.CardsMoveOneTime},
	priority = 1,
	global = true,
 	on_record = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return end
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName()
			and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)) == sgs.CardMoveReason_S_REASON_DISCARD then
			
			if (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
				and move.to_place == sgs.Player_PlaceTable then  --条件A
				local card_ids = {-1}
				for i, id in sgs.qlist(move.card_ids) do
					if (move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip) and room:getCardPlace(id) == sgs.Player_PlaceTable then
						table.insert(card_ids, id)
					end
				end
				
				local zongxuanStack_str = player:getTag("zongxuanStack"):toString()
				local zongxuanStack = zongxuanStack_str:split("|")
				table.removeAll(zongxuanStack, "")
				table.insert(zongxuanStack, table.concat(card_ids, "+"))
				player:setTag("zongxuanStack", sgs.QVariant(table.concat(zongxuanStack, "|")))
			elseif move.from_places:contains(sgs.Player_PlaceTable) and move.to_place == sgs.Player_DiscardPile then  --条件B
				local zongxuanStack_str = player:getTag("zongxuanStack"):toString()
				if zongxuanStack_str == "" then return end
				local zongxuanStack = zongxuanStack_str:split("|")
				
				table.remove(zongxuanStack, #zongxuanStack)
				if next(zongxuanStack) then player:setTag("zongxuanStack", sgs.QVariant(table.concat(zongxuanStack, "|")))
				else player:removeTag("zongxuanStack") end
				player:removeTag("zongxuanPopIndex")
			end
		end
	end,
 	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
zhiyan = sgs.CreateTriggerSkill{
	name = "zhiyan",
	can_preshow = true,
	frequency = sgs.Skill_Frequent,
	events = sgs.EventPhaseStart,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Finish) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data)
		local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), self:objectName().."-invoke", true, true)
		if to then
			room:broadcastSkillInvoke(self:objectName(), player)
			local to_data = sgs.QVariant()
			to_data:setValue(to)
			player:setTag(self:objectName(), to_data)
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		local to = player:getTag(self:objectName()):toPlayer()
		player:removeTag(self:objectName())
		local ids = room:getNCards(1, false)
		local card = sgs.Sanguosha:getCard(ids:first())
		room:obtainCard(to, card, false)
		if to:isAlive() then
			room:showCard(to, ids:first())
			if not card:isKindOf("EquipCard") then return false end
			if to:isAlive() and (room:getCardOwner(ids:first()):objectName() == to:objectName()) and not to:isLocked(card) then
				room:useCard(sgs.CardUseStruct(card, to, to))
				local recover = sgs.RecoverStruct()
				recover.who = player 
				room:recover(to, recover)
			end
		end
		return false 
	end,
	on_turn_broken = function(self, function_name, event, room, player, data, ask_who)
		player:removeTag(self:objectName())
	end
}
yufan:addSkill(zongxuan)
yufan:addSkill(zongxuanRecord)
yufan:addSkill(zhiyan)
extension:insertRelatedSkills("zongxuan","#zongxuan-record")

-----李儒-----

juece = sgs.CreatePhaseChangeSkill{
	name = "juece",
	frequency = sgs.Skill_NotFrequent,
	can_preshow = true,
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) or (player:getPhase() ~= sgs.Player_Finish) then return "" end
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:isKongcheng() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self,event,room,player,data)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:isKongcheng() then
				targets:append(p)
			end
		end
		local target = room:askForPlayerChosen(player, targets, self:objectName(), "@juece", true, true)
		if target then
			room:broadcastSkillInvoke(self:objectName(), player)
			local d = sgs.QVariant()
			d:setValue(target)
			player:setTag("juece_tar", d)
			return true
		end
	end,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		local target = player:getTag("juece_tar"):toPlayer()
		player:removeTag("juece_tar")
		local damage = sgs.DamageStruct()
		damage.from = player
		damage.reason = self:objectName()
		damage.to = target
		room:damage(damage)
	end,
}
miejiCard = sgs.CreateSkillCard{
	name = "miejiCard",
	skill_name = "mieji",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and not to_select:isKongcheng() and to_select:objectName() ~= player:objectName()
	end,
	extra_cost = function(self, room, card_use)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, card_use.from:objectName(), "mieji", "")
		room:moveCardTo(self, card_use.from, nil, sgs.Player_DrawPile, reason, true)		
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local cards = effect.to:getCards("he")
		local done = false
		while not done do
			done = true
			for _, c in sgs.qlist(cards) do
				if effect.to:isJilei(c) then
					cards:removeOne(c)
					done = false
					break
				end
			end
		end
		if cards:length() == 0 then return end
		local instanceDiscard = false
		local instanceDiscardId = -1
		if cards:length() == 1 then
			instanceDiscard = true
		elseif cards:length() == 2 then
			local bothTrick = true
			local trickId = -1
			for _,c in sgs.qlist(cards) do
				if c:getTypeId() ~= sgs.Card_TypeTrick then
					bothTrick = false
				else
					trickId = c:getId()
				end
			end
			instanceDiscard = not bothTrick
			instanceDiscardId = trickId
		end
		if instanceDiscard then
			local dummy = sgs.DummyCard()
			if instanceDiscardId == -1 then
				dummy:addSubcards(cards)
			else
				dummy:addSubcard(instanceDiscardId)
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, effect.to:objectName(), "mieji", nil)
			room:throwCard(dummy, reason, effect.to)
			dummy:deleteLater()
		elseif not room:askForCard(effect.to, "@@miejiDiscard!", "@mieji-discard") then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			local tricks = sgs.CardList()
			local non_tricks = sgs.CardList()
			for _,c in sgs.qlist(cards) do
				if c:getTypeId() == sgs.Card_TypeTrick then
					tricks:append(c)
				else
					non_tricks:append(c)
				end
			end
			if not tricks:isEmpty() then
				dummy:addSubcard(tricks:at(math.random(0, tricks:length() - 1)))
			else
				local random1 = math.random(0, non_tricks:length() - 1)
				dummy:addSubcard(non_tricks:at(random1))
				non_tricks:removeAt(random1)
				dummy:addSubcard(non_tricks:at(math.random(0, non_tricks:length() - 1)))
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, effect.to:objectName(), "mieji", nil)
			room:throwCard(dummy, effect.to)
			dummy:deleteLater()
		end
	end,
}
mieji = sgs.CreateOneCardViewAsSkill{
	name = "mieji",
	filter_pattern = "TrickCard|black",
	view_as = function(self, originalCard)
		local card = miejiCard:clone()
		card:addSubcard(originalCard)
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#miejiCard")
	end
}
miejiDiscard = sgs.CreateViewAsSkill{
	name = "miejiDiscard",
	view_filter = function(self, selected, to_select)
		if sgs.Self:isJilei(to_select) then return false end
		if #selected == 0 then return true
		elseif #selected == 1 then
			return to_select:getTypeId() ~= sgs.Card_TypeTrick and selected[1]:getTypeId() ~= sgs.Card_TypeTrick
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local ok = false
		if #cards == 1 then
			ok = cards[1]:getTypeId() == sgs.Card_TypeTrick
		elseif #cards == 2 then
			ok = true
			for _, c in ipairs(cards) do
				if c:getTypeId() == sgs.Card_TypeTrick then
					ok = false
					break
				end
			end
		end
		if ok then
			local dummy = sgs.DummyCard()
			for _, c in ipairs(cards) do
				dummy:addSubcard(c)
			end
			return dummy
		end
	end,
 	enabled_at_play = function(self, player)
		return false
	end,
 	enabled_at_response = function(self, player, pattern)
		return pattern == "@@miejiDiscard!"
	end,
}
fenchengCard = sgs.CreateSkillCard{
	name = "fenchengCard",
	skill_name = "fencheng",
	target_fixed = true,
	mute = true,
	about_to_use = function(self, room, cardUse)
		room:removePlayerMark(cardUse.from, "@burn")
		room:broadcastSkillInvoke("fencheng", cardUse.from)
		room:doSuperLightbox("liru", "fencheng")
		self:cardOnUse(room, cardUse)
	end,
	on_use = function(self, room, source, targets)
		room:setTag("fenchengDiscard", sgs.QVariant(0))
		source:setFlags("fenchengUsing")
		for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			if p:isAlive() then
				room:cardEffect(self, source, p)
				room:getThread():delay()
			end
		end
		source:setFlags("-fenchengUsing")
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local length = room:getTag("fenchengDiscard"):toInt() + 1
		if not effect.to:canDiscard(effect.to, "he") or (effect.to:getCardCount(true) < length)
			or not room:askForDiscard(effect.to, "fencheng", 1000, length, true, true, "@fencheng:::" .. length) then
			room:setTag("fenchengDiscard", sgs.QVariant(0))
			
			local damage = sgs.DamageStruct()
			damage.from =  effect.from
			damage.reason = "fencheng"
			damage.to = effect.to
			damage.damage = 2
			damage.nature = sgs.DamageStruct_Fire
			room:damage(damage)
		end
	end,
	on_turn_broken = function(self, function_name, room, data)
		if function_name == "on_use" then
			data:toCardUse().from:setFlags("-fenchengUsing")
		elseif function_name == "on_effect" then
			data:toCardEffect().from:setFlags("-fenchengUsing")
		end
	end
}
fenchengVS = sgs.CreateZeroCardViewAsSkill{
	name = "fencheng",
	view_as = function(self)
		local card = fenchengCard:clone()
		card:setShowSkill(self:objectName())
		card:setSkillName(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@burn") > 0
	end,
}
fencheng = sgs.CreateTriggerSkill{
	name = "fencheng",
	can_preshow = false,
	events = {sgs.ChoiceMade},
	frequency = sgs.Skill_Limited,
	limit_mark = "@burn", 
	view_as_skill = fenchengVS,
	on_record = function(self, event, room, player, data)
		local data_str = data:toString():split(":")
		if (#data_str ~= 3) or (data_str[1] ~= "cardDiscard") or (data_str[2] ~= "fencheng") then
			return
		end
		local num = data_str[3]:split("+")
		room:setTag("fenchengDiscard", sgs.QVariant(#num))
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
liru:addSkill(juece)
liru:addSkill(mieji)
liru:addSkill(fencheng)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("miejiDiscard") then skills:append(miejiDiscard) end
sgs.Sanguosha:addSkills(skills)

-----李通-----

tuifeng = sgs.CreateMasochismSkill{
	name = "tuifeng",
	can_preshow = true, 
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if player:isNude() then return "" end
		local damage = data:toDamage()
		local trigger_list = {}
		for i = 1, damage.damage, 1 do
			table.insert(trigger_list, self:objectName())
		end
		return table.concat(trigger_list, ",")
	end, 
	on_cost = function(self, event, room, player, data)
		local exc_card = room:askForExchange(player, self:objectName(), 1, 0, "tuifengPush", "", ".")
		if exc_card then
			player:setTag("tuifengCardId", sgs.QVariant(exc_card:getSubcards():first()))
			local msg = sgs.LogMessage()
			msg.type, msg.from, msg.arg = "#InvokeSkill", player, self:objectName()
			room:sendLog(msg)
			room:broadcastSkillInvoke(self:objectName(), 2, player)
			return true
		end
		player:removeTag("tuifengCardId")
		return false 
	end,
	on_damaged = function(self, player, damage)
		local id = player:getTag("tuifengCardId"):toInt()
		player:removeTag("tuifengCardId")
		if id then
			player:addToPile("lead", id)
		end
	end,
	on_turn_broken = function(self, function_name, event, room, player, data, ask_who)
		player:removeTag("tuifengCardId")
	end
}
tuifengThrow = sgs.CreateTriggerSkill{
	name = "#tuifeng-throw",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() ~= sgs.Player_Start then return "" end
		return (player:getPile("lead"):length() > 0) and self:objectName() or ""
	end,
	on_cost = function(self, event, room, player, data)
		room:broadcastSkillInvoke("tuifeng", 1, player)
		if player:ownSkill("tuifeng") and not player:hasShownSkill("tuifeng") then
			player:showGeneral(player:inHeadSkills("tuifeng"))
		end
		return true
	end,
	on_effect = function(self, event, room, player, data)
		local x = player:getPile("lead"):length()
		if x > 0 then
			room:sendCompulsoryTriggerLog(player, "tuifeng", true)
			local dummy = sgs.DummyCard(player:getPile("lead"))
			dummy:deleteLater()
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "tuifeng", "")
			room:throwCard(dummy, reason, nil)
			player:drawCards(2*x)
			room:setPlayerMark(player, "@lead", x)
		end
	end,
}
tuifengClear = sgs.CreateTriggerSkill{
	name = "#tuifeng-clear",
	events = {sgs.EventPhaseStart, sgs.EventLoseSkill},
	priority = 8,
	global = true,
	on_record = function(self, event, room, player, data)
		if event == sgs.EventPhaseStart then
			if player:getPhase() ~= sgs.Player_NotActive then return end
			for _,p in sgs.qlist(room:getAllPlayers()) do
				if p:getMark("@lead") > 0 then
					room:setPlayerMark(p, "@lead", 0)
				end
			end
		elseif (event == sgs.EventLoseSkill) and data:toString() == "tuifeng" then
			player:clearOnePrivatePile("lead")
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
tuifengTargetMod = sgs.CreateTargetModSkill{
	name = "#tuifeng-targetmod",
	pattern = "Slash",
	residue_func = function(self, from, card)
		return from:getMark("@lead")
	end,
}
litong:addSkill(tuifeng)
litong:addSkill(tuifengThrow)
litong:addSkill(tuifengClear)
litong:addSkill(tuifengTargetMod)
extension:insertRelatedSkills("tuifeng","#tuifeng-throw")
extension:insertRelatedSkills("tuifeng","#tuifeng-clear")
extension:insertRelatedSkills("hontuifenggde","#tuifeng-targetmod")

-----步骘-----

hongde = sgs.CreateTriggerSkill{
	name = "hongde",
	can_preshow = true,
	events = {sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if room:getCurrent() and room:getCurrent():getMark(self:objectName()) >= 4 then return "" end
		local move = data:toMoveOneTime()
		if not room:getTag("FirstRound"):toBool() and move.card_ids:length() >= 2 then
			local isGet = (move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand --[[and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_PREVIEWGIVE]])
			local isLose = false
			local lostCount = 0
			if move.from and move.from:objectName() == player:objectName() and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) and not (move.to and move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip)) then
				for i = 0, move.from_places:length() - 1 do
					if (move.from_places:at(i) == sgs.Player_PlaceHand) or (move.from_places:at(i) == sgs.Player_PlaceEquip) then
						lostCount = lostCount + 1
						if lostCount >= 2 then isLose = true break end
					end
				end
			end
			if isGet or isLose then return self:objectName() end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), self:objectName().."-invoke", true, true)
		if to then
			room:broadcastSkillInvoke(self:objectName(), player)
			room:drawCards(to, 1, self:objectName())
			room:getCurrent():addMark(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		return false
	end,
	on_turn_broken = function(self, function_name, event, room, player, data, ask_who)
		player:removeTag(self:objectName())
	end
}
hongdeClear = sgs.CreateTriggerSkill{
	name = "#hongde-clear",
	events = {sgs.EventPhaseStart},
	priority = 8,
	global = true,
 	on_record = function(self, event, room, player, data)
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_NotActive) then
			if player:getMark("hongde") > 0 then
				player:setMark("hongde", 0)
			end
		end
	end,
 	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
dingpanCard = sgs.CreateSkillCard{
	name = "dingpanCard",
	skill_name = "dingpan",
	mute = true,
	filter = function(self, selected, to_select)
		return #selected == 0 and not to_select:getEquips():isEmpty()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		target:drawCards(1, self:objectName())
		local choices = {}
		if source:isAlive() and source:canDiscard(target, "e") then
			table.insert(choices, "dingpan_discard")
		end
		table.insert(choices, "dingpan_damage")
		local choice = room:askForChoice(target, "dingpan", table.concat(choices, "+"))
		if choice == "dingpan_discard" and source:canDiscard(target, "e") then
			room:broadcastSkillInvoke("dingpan", 1, source)
			local id = room:askForCardChosen(source, target, "e", "dingpan", false, sgs.Card_MethodDiscard)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, source:objectName(), target:objectName(), "dingpan", nil)
			room:throwCard(sgs.Sanguosha:getCard(id), reason, target, source)
		elseif choice == "dingpan_damage" then
			room:broadcastSkillInvoke("dingpan", 2, source)
			local dummy = sgs.DummyCard()
			for _, equip in sgs.qlist(target:getEquips()) do
			    dummy:addSubcard(equip:getEffectiveId())
		    end
			dummy:deleteLater()
			room:obtainCard(target, dummy, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName(), target:objectName(), "dingpan", ""))
			room:damage(sgs.DamageStruct("dingpan", source, target))
		end
	end
}
dingpan = sgs.CreateZeroCardViewAsSkill{
	name = "dingpan",
	view_as = function(self) 
		local card = dingpanCard:clone()
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)  --待定，可能需要重写getBigKingdoms，因为暗置发动技能时是否属于吴势力的问题
		local big_kingdoms = player:getBigKingdoms("dingpan")
		local big_kingdom_count = 0
		local players = player:getAliveSiblings()
		players:append(player)
		for _,p in sgs.qlist(players) do
			if table.contains(big_kingdoms, p:objectName()) or (table.contains(big_kingdoms, p:getKingdom()) and (p:getRole() ~= "careerist")) then  --野心家的同势力角色数永远不可能大于1，因此不可能出现在big_kingdoms中
				big_kingdom_count = big_kingdom_count + 1
			end
		end
		return player:usedTimes("#dingpanCard") < math.max(1, big_kingdom_count)
	end
}
buzhi:addSkill(hongde)
buzhi:addSkill(hongdeClear)
extension:insertRelatedSkills("hongde","#hongde-clear")
buzhi:addSkill(dingpan)

-----糜竺-----

ziyuanCard = sgs.CreateSkillCard{
	name = "ziyuanCard",
	skill_name = "ziyuan",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		if #targets == 0 then
			return to_select:getHp() == 1 or to_select:getHandcardNum() <= 1
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		local target = effect.to
		room:broadcastSkillInvoke("ziyuan")
		room:notifySkillInvoked(effect.from, self:objectName())
		if target:getHandcardNum() <= 1 then target:drawCards(1) end
		if target:getHp() == 1 then
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(target, recover)
		end
	end,
}
ziyuan = sgs.CreateZeroCardViewAsSkill{   
	name = "ziyuan",
	view_as = function(self)
		local skillcard = ziyuanCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#ziyuanCard")
	end,
}
jugu = sgs.CreateTriggerSkill{
	name = "jugu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Start then
			return self:objectName()
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:drawCards(1)
		local card = room:askForCard(player, "..", "@jugu", data, sgs.Card_MethodNone, player)
		if card then
			room:moveCardTo(card, player, sgs.Player_DrawPile)
		end
		return false
	end
}
mizhu:addSkill(jugu)
mizhu:addSkill(ziyuan)

-----陈群-----

dingpin = sgs.CreateTriggerSkill{
	name = "dingpin",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local dest = room:askForPlayerChosen(player, room:getAlivePlayers(), "dingpin","dingpin-invoke",true,true)
		if dest then
			room:doAnimate(1, player:objectName(), dest:objectName())
			local d = sgs.QVariant()
			d:setValue(dest)
			player:setTag("dingpin_tg", d)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local dest = player:getTag("dingpin_tg"):toPlayer()
		local judge = sgs.JudgeStruct()
		judge.pattern = ".|black"
		judge.good = true
		judge.who = dest
		judge.play_animation = true
		room:judge(judge)
		if judge:isGood() then
			dest:drawCards(dest:getMaxHp() - dest:getHp())
		else
			player:turnOver()
		end
		return false
	end
}
faen = sgs.CreateTriggerSkill{ 
	name = "faen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.ChainStateChanged,sgs.TurnedOver},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local chenqun = room:findPlayerBySkillName(self:objectName())
		if chenqun then
			if event == sgs.ChainStateChanged then
				if player:isChained() then
					return self:objectName() , chenqun:objectName()
				end
			elseif event == sgs.TurnedOver then
				return self:objectName() , chenqun:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local _data = sgs.QVariant()
		_data:setValue(player)
		if room:askForSkillInvoke(ask_who,self:objectName(),_data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		if player:objectName() == ask_who:objectName() then
			player:drawCards(1) 
			local dest = room:askForPlayerChosen(player, room:getOtherPlayers(player), "faen","faen-invoke",true)
			if dest then
				room:doAnimate(1, player:objectName(), dest:objectName())
				dest:drawCards(1)
			end
		else 
			player:drawCards(1)
		end
		return false
	end
}
chenqun:addSkill(dingpin)
chenqun:addSkill(faen)

-----刘协-----

mizhaoCard = sgs.CreateSkillCard{
	name = "mizhaoCard",
	skill_name = "mizhao",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	extra_cost = function(self, room, use)
		local target = use.to:first()
		local source = use.from
		room:broadcastSkillInvoke("mizhao")
		target:obtainCard(use.card, false)
		local targets = sgs.SPlayerList()
		local others = room:getOtherPlayers(target)
		for _,p in sgs.qlist(others) do
			if not p:isKongcheng() then
				targets:append(p)
			end
		end
		if not target:isKongcheng() then
			if not targets:isEmpty() then
				local dest = room:askForPlayerChosen(source, targets, "mizhao")
				room:doAnimate(1, source:objectName(), dest:objectName())
				--if not dest then dest = targets:first() end
				local pd = sgs.PindianStruct()
				pd = target:pindianSelect(dest, "mizhao")
				local d = sgs.QVariant()
				d:setValue(pd)
				source:setTag("mizhao_pd", d)
			end
		end
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		local target = effect.to
		local pd = source:getTag("mizhao_pd"):toPindian()
		source:removeTag("mizhao_pd")
		if pd and pd.reason == "mizhao" then
		    local success = source:pindian(pd)
			local fromNumber = pd.from_card:getNumber()
			local toNumber = pd.to_card:getNumber()
			if fromNumber ~= toNumber then
				local winner
				local loser
				if fromNumber > toNumber then
					winner = pd.from
					loser = pd.to
				else
					winner = pd.to
					loser = pd.from
				end
				if winner:canSlash(loser, nil, false) then
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName("mizhao")
					local card_use = sgs.CardUseStruct()
					card_use.from = winner
					card_use.to:append(loser)
					card_use.card = slash
					room:useCard(card_use, false)
				end
			end
		end
	end
}
mizhao = sgs.CreateZeroCardViewAsSkill{
	name = "mizhao",
	view_as = function(self)
		local handCards = sgs.Self:getHandcards()
		local card = mizhaoCard:clone()
		for _,cd in sgs.qlist(handCards) do
			card:addSubcard(cd)
		end
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		if not player:isKongcheng() then
			return not player:hasUsed("#mizhaoCard")
		end
		return false
	end
}
tianming = sgs.CreateTriggerSkill{
	name = "tianming",
	events = {sgs.TargetConfirming},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:askForDiscard(player, self:objectName(), 2, 2, false, true)
		player:drawCards(2, self:objectName())
		local max = -1000
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:getHp() > max then
				max = p:getHp()
			end
		end
		if player:getHp() == max then return false end
		local maxs = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if p:getHp() == max then
				maxs:append(p)
			end
			if maxs:length() > 1 then return false end
		end
		local mosthp = maxs:first()
		if room:askForSkillInvoke(mosthp, self:objectName()) then
			room:doAnimate(1, player:objectName(), mosthp:objectName())
			if room:askForDiscard(mosthp, self:objectName(), 2, 2, false, true) then
				mosthp:drawCards(2)
			end
		end
		return false
	end
}
liuxie:addSkill(mizhao)
liuxie:addSkill(tianming)

-----刘表-----

gushou = sgs.CreateDistanceSkill{
	name = "gushou",
	correct_func = function(self, from, to)
		if to:hasShownSkill(self:objectName()) then
			return to:getMaxHp() - to:getHp()
		end
		return 0
	end
}
gushou_limit = sgs.CreateMaxCardsSkill{
	name = "#gushou_limit" ,
	extra_func = function(self, player)
		if (player:hasShownSkill("gushou")) then
			return player:getMaxHp() - player:getHp()
		end
		return 0
	end,
	priority = -10
}
gushou_trigger = sgs.CreateTriggerSkill{
	name = "#gushou_trigger",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill("gushou")) then return "" end
		if player:getPhase() == sgs.Player_Discard and player:getHandcardNum() > player:getMaxCards() and player:isWounded() then
			if not player:hasShownSkill("gushou") and room:askForSkillInvoke(player, "gushou", data) then
				player:showGeneral(player:inHeadSkills("gushou"))
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	end,
	on_effect = function(self, event, room, player, data,ask_who)
	end
}
liubiao:addSkill(gushou)
liubiao:addSkill(gushou_limit)
liubiao:addSkill(gushou_trigger)
extension:insertRelatedSkills("gushou","#gushou_limit")
extension:insertRelatedSkills("gushou","#gushou_trigger")

-----简雍-----

qiaoshuiCard = sgs.CreateSkillCard{
	name = "qiaoshuiCard",
	skill_name = "qiaoshui",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and (not to_select:isKongcheng()) and to_select:objectName() ~= sgs.Self:objectName()
	end,
	extra_cost = function(self, room, use)
		local pd = sgs.PindianStruct()
		pd = use.from:pindianSelect(use.to:first(), "qiaoshui")
		local d = sgs.QVariant()
		d:setValue(pd)
		use.from:setTag("qiaoshui_pd", d)
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:broadcastSkillInvoke("qiaoshui")
		local source = effect.from
		local target = effect.to
		local pd = source:getTag("qiaoshui_pd"):toPindian()
		source:removeTag("qiaoshui_pd")
		if pd then
			local success = source:pindian(pd)
			pd = nil
			if success and not target:isAllNude() then
				local snatch = sgs.Sanguosha:cloneCard("Snatch", sgs.Card_NoSuit, 0)
				snatch:setSkillName(self:objectName())
				local card_use = sgs.CardUseStruct()
				card_use.from = source
				card_use.to:append(target)
				card_use.card = snatch
				room:useCard(card_use, false)
			end
		end
	end,
}
qiaoshui = sgs.CreateZeroCardViewAsSkill{   
	name = "qiaoshui",
	view_as = function(self)
		local skillcard = qiaoshuiCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#qiaoshuiCard")
	end,
}
zongshi = sgs.CreateTriggerSkill{
	name = "zongshi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Pindian},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local jianyong = room:findPlayerBySkillName(self:objectName())
		if not (jianyong and jianyong:isAlive()) then return "" end
		local pindian = data:toPindian()
		if pindian.from_card:getSuit() == sgs.Card_Spade or pindian.to_card:getSuit() == sgs.Card_Spade then return self:objectName() ,jianyong:objectName() end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local pindian = data:toPindian()
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if pindian.from_card:getSuit() == sgs.Card_Spade then 
			if room:getCardPlace(pindian.from_card:getId()) ~= sgs.Player_PlaceHand then
				dummy:addSubcard(pindian.from_card:getId()) 
			end
		end
		if pindian.to_card:getSuit() == sgs.Card_Spade then 
			if room:getCardPlace(pindian.to_card:getId()) ~= sgs.Player_PlaceHand then
				dummy:addSubcard(pindian.to_card:getId())
			end
		end
		ask_who:obtainCard(dummy)
		return false
	end
}
jianyong:addSkill(qiaoshui)
jianyong:addSkill(zongshi)

-----徐庶-----

zhuhai = sgs.CreateTriggerSkill{
	name = "zhuhai",
	relate_to_place = "head",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart,sgs.DamageCaused,sgs.SlashMissed,sgs.PreCardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if event == sgs.DamageCaused then
			if player:objectName() == room:getCurrent():objectName() then
				room:setPlayerMark(player,"zhuhaiMark",1)
			end
			return ""
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				if player:getMark("zhuhaiMark") > 0 then
					room:setPlayerMark(player,"zhuhaiMark",0)
					local xushus = room:findPlayersBySkillName(self:objectName())
					xushus:removeOne(player)
					local skill_list,player_list = {},{}
					if xushus:length() > 0 then
						for _, xushu in sgs.qlist(xushus) do
							if not xushu:isNude() then
								table.insert(skill_list, self:objectName())
								table.insert(player_list, xushu:objectName())
							end
						end
					end
					return table.concat(skill_list,"|"), table.concat(player_list,"|")
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			if effect.from:getMark("zhuhai_Mark") > 0 then
				room:broadcastSkillInvoke(self:objectName(),2)
				effect.from:drawCards(1)
			end
			return ""
		elseif event == sgs.PreCardUsed then
			if player:getMark("zhuhai_Mark") > 0 then
				room:broadcastSkillInvoke(self:objectName(),1)
				room:notifySkillInvoked(player, self:objectName())
			return ""
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if ask_who:isAlive() and not ask_who:isNude() and player:isAlive() then
			if event == sgs.EventPhaseStart then
				room:setPlayerMark(ask_who,"zhuhai_Mark",1)
				local card = room:askForUseSlashTo(ask_who,player,"@zhuhai",false)
				room:setPlayerMark(ask_who,"zhuhai_Mark",0)
				if card then
					return true
				end
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
wuyan = sgs.CreateTriggerSkill{
	name = "wuyan",
	relate_to_place = "deputy",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local damage = data:toDamage()
		if damage.card and (damage.card:getTypeId() == sgs.Card_TypeTrick) then
			if (event == sgs.DamageInflicted) and player:hasSkill(self:objectName()) then
				return self:objectName()
			elseif (event == sgs.DamageCaused) and (damage.from and damage.from:isAlive() and damage.from:hasSkill(self:objectName())) then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		return true
	end
}
jujianCard = sgs.CreateSkillCard{
	name = "jujianCard",
	skill_name = "jujian",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()	
		local choiceList = {"draw"}
		if effect.to:isWounded() then
			table.insert(choiceList, "recover")
		end
		if (not effect.to:faceUp()) or effect.to:isChained() then
			table.insert(choiceList, "reset")
		end
		local choice = room:askForChoice(effect.to, "jujian", table.concat(choiceList, "+"))
		if choice == "draw" then
			effect.to:drawCards(2)
		elseif choice == "recover" then
			local recover = sgs.RecoverStruct()
			recover.who = effect.from
			room:recover(effect.to, recover)
		elseif choice == "reset" then
			if effect.to:isChained() then
				room:setPlayerProperty(effect.to, "chained", sgs.QVariant(false))
			end
			if not effect.to:faceUp() then
				effect.to:turnOver()
			end
		end
	end
}
jujianVS = sgs.CreateViewAsSkill{
	name = "jujian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (not to_select:isKindOf("BasicCard")) and (not sgs.Self:isJilei(to_select))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local jujiancard = jujianCard:clone()
			jujiancard:addSubcard(cards[1])
			return jujiancard 
		end  
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@jujian"
	end
}
jujian = sgs.CreateTriggerSkill{
	name = "jujian",
	relate_to_place = "deputy",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = jujianVS,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:isNude() then return "" end
		if (player:getPhase() == sgs.Player_Finish) and player:canDiscard(player, "he") then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForUseCard(player, "@@jujian", "@jujian-card", -1, sgs.Card_MethodNone) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:notifySkillInvoked(player, self:objectName())
		return true
	end,
}
xushu:addSkill(zhuhai)
xushu:addSkill(wuyan)
xushu:addSkill(jujian)
xushu:setDeputyMaxHpAdjustedValue(-1)

-----步练师-----

anxuCard = sgs.CreateSkillCard{
	name = "anxuCard",
	skill_name = "anxu",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then
			return false
		elseif #targets == 0 then
			return true
		elseif #targets == 1 then 
			return to_select:objectName() ~= targets[1]:objectName() and to_select:getHandcardNum() ~= targets[1]:getHandcardNum()
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		if targets[1]:getHandcardNum() == targets[2]:getHandcardNum() then return end
		local from = targets[1]:getHandcardNum() < targets[2]:getHandcardNum() and targets[1] or targets[2]
		local to = from:objectName() == targets[1]:objectName() and targets[2] or targets[1]
		
		local skin_id = source:property((source:inHeadSkills("anxu") and "head" or "deputy") .. "_skin_id"):toInt()
		if skin_id == 1 then
			room:broadcastSkillInvoke("anxu", matchPlayerName(from, "sunquan") and 2 or 1, source)
		else
			room:broadcastSkillInvoke("anxu", source)
		end
		if not to:isKongcheng() then
			local id = room:askForCardChosen(from, to, "h", self:getSkillName(), false)
			local card = sgs.Sanguosha:getCard(id)
			room:obtainCard(from, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName(), "anxu", ""))
			if from:isDead() then return end
			room:showCard(from, id)
			if card:getSuit() ~= sgs.Card_Spade and source:isAlive() then
				room:drawCards(source, 1, "anxu")
			end
		end
	end,
}
anxu = sgs.CreateZeroCardViewAsSkill{   
	name = "anxu",
	view_as = function(self)
		local skillcard = anxuCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#anxuCard")
	end,
}
zhuiyi = sgs.CreateTriggerSkill{
	name = "zhuiyi",
	events = {sgs.Death},
	can_preshow = false,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:hasSkill(self)) then return "" end
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if not (death.damage and death.damage.from and (p:objectName() == death.damage.from:objectName())) then
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		local can_invoke = room:getAlivePlayers()
		local death = data:toDeath()
		if death.damage and death.damage.from then
			room:setPlayerProperty(player,"zhuiyiProp",sgs.QVariant(death.damage.from:objectName()))
			can_invoke:removeOne(death.damage.from)
		end
		if not can_invoke:isEmpty() then
			local target
			target = room:askForPlayerChosen(player, can_invoke, self:objectName(), "zhuiyi-invoke:", true, true)
			room:setPlayerProperty(player,"zhuiyiProp",sgs.QVariant())
			if target then
				room:broadcastSkillInvoke(self:objectName(), player)
				local _data = sgs.QVariant()
				_data:setValue(target)
				player:setTag("zhuiyiTag", _data)
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data)
		local target = player:getTag("zhuiyiTag"):toPlayer()
		player:removeTag("zhuiyiTag")
		if target then
			target:drawCards(3)
			if target:isAlive() and target:isWounded() then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(target, recover, true)
			end
		end
		return false
	end
}
bulianshi:addSkill(anxu)
bulianshi:addSkill(zhuiyi)

-----华雄-----

shiyong = sgs.CreateTriggerSkill{
	name = "shiyong",
	events = {sgs.Damaged},
	frequency = sgs.Skill_Compulsory,
	can_preshow = false,
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.from and damage.from:isKongcheng() or player:isKongcheng() then return "" end
		if damage.from and damage.from:objectName() == damage.to:objectName() then return "" end
		if not player:hasShownSkill(self:objectName()) then return "" end
		if damage.card and not damage.card:isKindOf("Slash") then return "" end
		if not damage.card then return "" end
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local damage = data:toDamage()
		if not player:hasShownSkill(self:objectName()) then
			return false
		end
		local _data = sgs.QVariant()		
		_data:setValue(player)
		if room:askForSkillInvoke(damage.from,self:objectName(),_data) then
			room:broadcastSkillInvoke(self:objectName())
			room:notifySkillInvoked(player, self:objectName())
			local damage = data:toDamage()
			local pd = sgs.PindianStruct()
			pd = damage.from:pindianSelect(player, "shiyong")
			local d = sgs.QVariant()
			d:setValue(pd)
			player:setTag("shiyong_pd", d)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local pd = ask_who:getTag("shiyong_pd"):toPindian()
		ask_who:removeTag("shiyong_pd")
		if pd and pd.reason == "shiyong" then
			room:broadcastSkillInvoke(self:objectName())
			local pd_to = true  --pd用于纵适
			local pd_from = true
			if pd.from_card:getNumber() < pd.to_card:getNumber() then
				pd.to:obtainCard(pd.from_card)
			elseif pd.from_card:getNumber() > pd.to_card:getNumber() then
				pd.from:obtainCard(pd.to_card)
			end
			local success = ask_who:pindian(pd)
		end
		return false
	end
}
yaowu = sgs.CreateTriggerSkill{
	name = "yaowu",
	events = {sgs.DamageInflicted},
	limit_mark = "@yaowu",
	frequency = sgs.Skill_Limited,
	can_trigger = function(self, event, room, player, data)
		local huaxiong = room:findPlayerBySkillName(self:objectName())
		if huaxiong and huaxiong:getMark("@yaowu") == 0 then return "" end
		local damage = data:toDamage()
		if not (huaxiong and huaxiong:isAlive()) then return "" end
		if player:getHp() == 1 and damage.damage > 0 then
			return self:objectName(),huaxiong:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local damage = data:toDamage()
		local _data = sgs.QVariant()		
		_data:setValue(damage.to)
		if room:askForSkillInvoke(ask_who,self:objectName(),_data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:doSuperLightbox("huaxiong", self:objectName())
		room:removePlayerMark(ask_who, "@yaowu")
		room:notifySkillInvoked(ask_who, self:objectName())
		return true
	end
}
huaxiong:addSkill(shiyong)
huaxiong:addSkill(yaowu)

-----廖化-----

fuli = sgs.CreateTriggerSkill{
	name = "fuli",
	events = {sgs.DamageInflicted},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if not damage.from then return false end
		--if damage.from and not isLargeKingdom(damage.from) then return "" end
		local big_kingdoms = damage.from:getBigKingdoms("fuli")
		if not table.contains(big_kingdoms,damage.from:getKingdom()) then return "" end
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
	    if room:askForCard(player, ".|red", "@fuli", data, self:objectName()) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local damage = data:toDamage()
		damage.damage = damage.damage - 1
		if damage.damage == 0 then
			return true
		end
		data:setValue(damage)
		return false
	end
}
liaohua:addSkill(fuli)

-----孙皓-----

canshi = sgs.CreateTriggerSkill{
	name = "canshi",
	events = {sgs.DrawNCards,sgs.CardUsed,sgs.EventPhaseEnd},
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.DrawNCards then
			local num = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:isWounded() then
					num = num + 1
				end
			end
			if num == 0 then return "" end
		end
		if event == sgs.CardUsed or event == sgs.EventPhaseEnd then
			if player:getMark("canshiMark") == 0 then
				return ""
			end
		end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if event == sgs.DrawNCards then
			if room:askForSkillInvoke(player,self:objectName(),data) then
				return true
			end
		end
		if event == sgs.CardUsed or event == sgs.EventPhaseEnd then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.DrawNCards then
			room:broadcastSkillInvoke(self:objectName())
			room:setPlayerMark(player,"canshiMark",1)
			local num = 0
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:isWounded() then
					num = num + 1
				end
			end
			local value = data:toInt()
			value = num
			data:setValue(value)
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard") then
				room:askForDiscard(player, self:objectName(), 1, 1, false, true)
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish then
				room:setPlayerMark(player,"canshiMark",0)
			end
		end
		return false
	end
}
chouhai = sgs.CreateTriggerSkill{
	name = "chouhai",
	events = {sgs.DamageInflicted},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:isKongcheng() then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local damage = data:toDamage()
		damage.damage = damage.damage + 1
		data:setValue(damage)
		return false
	end
}
sunhao:addSkill(canshi)
sunhao:addSkill(chouhai)

-----牛金-----

cuorui = sgs.CreateTriggerSkill{
	name = "cuorui",
	events = {sgs.Damaged},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:isNude() then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local card = room:askForCard(player, "..!", "@cuorui", data, sgs.Card_MethodNone, player)
		room:moveCardTo(card, player, sgs.Player_DrawPile)
		return false
	end 
}
liewei = sgs.CreateTriggerSkill{
	name = "liewei",
	events = {sgs.GeneralShown},
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_NotActive and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:drawCards(3)
		local phases = sgs.PhaseList()
		phases:append(sgs.Player_Play)
		player:play(phases)
		return false
	end
}
niujin:addSkill(cuorui)
niujin:addSkill(liewei)

-----张春华-----

shangshi = sgs.CreateTriggerSkill{
	name = "shangshi",
	events = {sgs.EventPhaseChanging, sgs.CardsMoveOneTime, sgs.MaxHpChanged, sgs.HpChanged},
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local losthp = player:getMaxHp() - player:getHp()
		if player:getHandcardNum() >= losthp then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, zhangchunhua, data,ask_who)
		local room = zhangchunhua:getRoom()
		local losthp = zhangchunhua:getLostHp()
		if (triggerEvent == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if zhangchunhua:getPhase() == sgs.Player_Discard then
				local changed = false
				if move.from and move.from:objectName() == zhangchunhua:objectName() and move.from_places:contains(sgs.Player_PlaceHand) then
					changed = true
				end
				if move.to and move.to:objectName() == zhangchunhua:objectName() and move.to_place == sgs.Player_PlaceHand then
					changed = true
				end
				if changed then
					zhangchunhua:addMark("shangshi")
				end
				return false
			else
				local can_invoke = false
				if move.from and move.from:objectName() == zhangchunhua:objectName() and move.from_places:contains(sgs.Player_PlaceHand) then
					can_invoke = true
				end
				if move.to and move.to:objectName() == zhangchunhua:objectName() and move.to_place == sgs.Player_PlaceHand then
					can_invoke = true
				end
				if not can_invoke then
					return false
				end
			end
		elseif triggerEvent == sgs.HpChanged or triggerEvent == sgs.MaxHpChanged then
			if zhangchunhua:getPhase() == sgs.Player_Discard then
				zhangchunhua:addMark("shangshi")
				return false
			end
		elseif triggerEvent == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.from ~= sgs.Player_Discard then
				return false
			end
			if zhangchunhua:getMark("shangshi") <= 0 then
				return false
			end
			zhangchunhua:setMark("shangshi", 0)
		end
		if (zhangchunhua:getHandcardNum() < losthp and zhangchunhua:getPhase() ~= sgs.Player_Discard and zhangchunhua:askForSkillInvoke(self:objectName())) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false 
	end ,
	on_effect = function(self, event, room, zhangchunhua, data,ask_who)
		zhangchunhua:drawCards(zhangchunhua:getLostHp() - zhangchunhua:getHandcardNum())
		return false
	end
}
jueqing = sgs.CreateTriggerSkill{
	name = "jueqing",
	events = {sgs.DamageCaused},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, zhangchunhua, data,ask_who)
		local damage = data:toDamage()
		local targets = room:getOtherPlayers(zhangchunhua)
		targets:removeOne(damage.to)
		zhangchunhua:setTag("jueqingTag",data)
		local to = room:askForPlayerChosen(zhangchunhua, targets, self:objectName(), self:objectName().."-invoke", true, true)
		zhangchunhua:removeTag("jueqingTag")
		if to then
			damage.from = to
			data:setValue(damage)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, zhangchunhua, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		return false
	end
}
zhangchunhua:addSkill(shangshi)
zhangchunhua:addSkill(jueqing)

-----张绣-----

tusha = sgs.CreateTriggerSkill{
	name = "tusha",
	events = {sgs.Predamage},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local damage = data:toDamage()
		if damage.to:getMaxHp() ~= damage.to:getHp() then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local damage = data:toDamage()
		if damage.chain or damage.transfer  then return false end
		local _data = sgs.QVariant()		
		_data:setValue(damage.to)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),_data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local damage = data:toDamage()
		damage.damage = damage.damage + 1
		data:setValue(damage)
		return false
	end
}
jiaoxie = sgs.CreateTriggerSkill{
	name = "jiaoxie",
	events = {sgs.TargetConfirmed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local use = data:toCardUse()
		if use.from ~= player or use.to:length() ~= 1 then return "" end
		if not use.card:isKindOf("Slash") then return "" end
		if use.to:first():getEquips():length() == 0 then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local use = data:toCardUse()
		local _data = sgs.QVariant()		
		_data:setValue(use.to:first())
		if room:askForSkillInvoke(player,self:objectName(), _data) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local use = data:toCardUse()
		local id = room:askForCardChosen(player, use.to:first(), "e", self:objectName())
		room:obtainCard(player,id)
	end
}
zhangxiu:addSkill(tusha)
zhangxiu:addSkill(jiaoxie)

--**********加强包**********-----

-----连营-----

lianying = sgs.CreateTriggerSkill{
	name = "lianying" ,
	frequency = sgs.Skill_Frequent ,
	relate_to_place = "deputy",
	events = {sgs.CardsMoveOneTime} ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		player:drawCards(1, self:objectName())
		return false
	end
}
Eduoshi = sgs.CreateOneCardViewAsSkill{
	name = "Eduoshi",
	response_or_use = true,	
	relate_to_place = "head",
	view_filter = function(self, card)
		local suit_used = sgs.Self:property("duoshiProp"):toString():split("+")
		return not table.contains(suit_used, card:getSuitString()) and not sgs.Self:isJilei(card)
	end,
	view_as = function(self, card)
		local await_exhausted = sgs.Sanguosha:cloneCard("await_exhausted",card:getSuit(),card:getNumber())
		await_exhausted:setSkillName("Eduoshi")
		await_exhausted:addSubcard(card)
		return await_exhausted
	end
}
duoshi_trigger = sgs.CreateTriggerSkill{
	name = "#duoshi_trigger" ,
	frequency = sgs.Skill_Compulsory ,
	relate_to_place = "head",
	global = true,
	events = {sgs.CardUsed, sgs.EventPhaseEnd} ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill("Eduoshi") then return "" end
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("AwaitExhausted") then
				if use.card:getSkillName() == "Eduoshi" then
					local suit_used = player:property("duoshiProp"):toString():split("+")
					table.insert(suit_used, use.card:getSuitString())
					room:setPlayerProperty(player, "duoshiProp", sgs.QVariant(table.concat(suit_used, "+")))
				end
				player:gainMark("@duoshiMark")
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish then
				room:setPlayerProperty(player, "duoshiProp", sgs.QVariant(""))
				local can_invoke = false
				if player:getMark("@duoshiMark") >= 3 then
					local hp = player:getMaxHp()
					if hp > 5 then hp = 5 end
					local n = hp - player:getHandcardNum()
					if n > 0 then
						can_invoke = true
					end
				end
				player:loseAllMarks("@duoshiMark")
				if can_invoke then
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke("duoshi", data) then
			room:broadcastSkillInvoke("duoshi")
			room:notifySkillInvoked(player, "duoshi")
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local hp = player:getMaxHp()
		if hp > 5 then hp = 5 end
		local n = hp - player:getHandcardNum()
		if n > 0 then
			player:drawCards(n)
		end
		return false
	end,
	priority = -10
}
luxun:addSkill("qianxun")
luxun:addSkill(lianying)
luxun:addSkill(Eduoshi)
luxun:addSkill(duoshi_trigger)
sgs.insertRelatedSkills(extension, "Eduoshi", "#duoshi_trigger")

-----单骑-----

danqi = sgs.CreateTriggerSkill{
	name = "danqi" ,
	frequency = sgs.Skill_Frequent ,
	relate_to_place = "deputy",
	events = {sgs.Damage} ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local damage = data:toDamage()
		if damage.card:isRed() and damage.to and not damage.to:isNude() then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local damage = data:toDamage()
		room:broadcastSkillInvoke(self:objectName(),1)
		player:setTag("damageCardSuit", sgs.QVariant(damage.card:getSuitString()))
		local id = room:askForCardChosen(player, damage.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
		player:removeTag("damageCardSuit")
		local card = sgs.Sanguosha:getCard(id)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, player:objectName(), damage.to:objectName(), self:objectName(), nil)
		room:throwCard(sgs.Sanguosha:getCard(id), reason, damage.to, player)
		if card:getSuit() == damage.card:getSuit() then
			player:drawCards(1)
			room:broadcastSkillInvoke(self:objectName(),2)
		end
	return false
	end
} 

-----狂骨-----

Ekuanggu = sgs.CreateTriggerSkill{
	name = "Ekuanggu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.PreDamageDone, sgs.DamageDone},
	can_trigger = function(self, event, room, player, data)	
		local damage = data:toDamage()
		if (event == sgs.PreDamageDone) and damage.from and damage.from:hasSkill(self:objectName()) and damage.from:isAlive() then
			local weiyan = damage.from
			weiyan:setTag("invokeLuaKuanggu", sgs.QVariant((weiyan:distanceTo(damage.to) <= 1)))
			return ""
		elseif (event == sgs.Damage) and player:hasSkill(self:objectName()) and player:isAlive() then
			local invoke = player:getTag("invokeLuaKuanggu"):toBool()
			if invoke then
				local trigger_list = {}
				for i = 1, damage.damage, 1 do
					sendMsg(room,"kuanggu")
					table.insert(trigger_list, self:objectName())
				end
				return table.concat(trigger_list, ",")
			end
		elseif event == sgs.DamageDone then
			player:setTag("invokeLuaKuanggu", sgs.QVariant(false))
		end
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local choices = {"draw1"}
		if player:isWounded() then
			table.insert(choices, "recover")
		end
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), data)
		if choice == "recover" then
			local damage = data:toDamage()
			local recover = sgs.RecoverStruct()
			recover.who = player
			room:recover(player, recover)
		else
			player:drawCards(1, self:objectName())
		end
		return false
	end
}
weiyan:addSkill(Ekuanggu)

-----奸雄-----

Ejianxiong = sgs.CreateMasochismSkill{
	name = "Ejianxiong" ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		local data = sgs.QVariant()
		data:setValue(damage)
		local choices = {"draw1"}
		local card = damage.card
		if card then
			local ids = sgs.IntList()
			if card:isVirtualCard() then
				ids = card:getSubcards()
			else
				ids:append(card:getEffectiveId())
			end
			if ids:length() > 0 then
				local all_place_table = true
				for _, id in sgs.qlist(ids) do
					if room:getCardPlace(id) ~= sgs.Player_PlaceTable then
						all_place_table = false
						break
					end
				end
				if all_place_table then
					table.insert(choices, "obtain")
				end
			end
		end
		local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"), data)
		if choice ~= "cancel" then
			room:notifySkillInvoked(player, self:objectName())
			if choice == "obtain" then
				player:obtainCard(card)
			else
				player:drawCards(1, self:objectName())
			end
		end
		return false
	end
}
caocao:addSkill(Ejianxiong)
caocao:addCompanion("dianwei")
caocao:addCompanion("xuchu")

-----励战-----

lizhan = sgs.CreateTriggerSkill{
	name = "lizhan",
	relate_to_place = "deputy",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Finish then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:isWounded() then
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:isWounded() then
				targets:append(p)
			end
		end
		if targets:length() == 0 then return false end
		local target_choose = room:askForPlayersChosen(player,targets,self:objectName(),0,targets:length(),self:objectName().."-invoke",true)
		if target_choose:length() > 0 then
			room:broadcastSkillInvoke(self:objectName())
			player:showGeneral(player:inHeadSkills(self:objectName()))
			room:drawCards(target_choose,1)
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}

-----诈降-----

zhaxiangCard = sgs.CreateSkillCard{
	name = "zhaxiangCard",
	skill_name = "zhaxiang",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then
			return false
		elseif #targets == 0 then
			return true
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		local target = effect.to
		room:broadcastSkillInvoke("zhaxiang")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), target:objectName(), "zhaxiang","")
		room:moveCardTo(self,target,sgs.Player_PlaceHand,reason)
		room:notifySkillInvoked(effect.from, self:objectName())
		if self:getSubcards():length() > 1 then
			local damage = sgs.DamageStruct()
			damage.from = source
			damage.to = target
			damage.damage = 1
			room:damage(damage)
		end
	end,
}
zhaxiangVS = sgs.CreateViewAsSkill{
    name = "zhaxiang",
    n = 999, 
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then
            return false
        end
        return #selected < sgs.Self:getHandcardNum() - sgs.Self:getHp()
    end,
    view_as = function(self, cards) 
		if #cards < sgs.Self:getHandcardNum() - sgs.Self:getHp() then return nil end
        local card = zhaxiangCard:clone()
        for _,c in ipairs(cards) do
            card:addSubcard(c)
        end
        return card
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zhaxiang"
	end
}
zhaxiang = sgs.CreateTriggerSkill{
	name = "zhaxiang",
	view_as_skill = zhaxiangVS,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Discard then
			if player:getHandcardNum() > player:getHp() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForUseCard(player, "@@zhaxiang", "@zhaxiang-card", -1, sgs.Card_MethodNone) then
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end,
}

-----张飞-----

tishen = sgs.CreateTriggerSkill{
	name = "tishen",
	frequency = sgs.Skill_NotFrequent,
	relate_to_place = "deputy",
	events = {sgs.TargetConfirmed, sgs.CardFinished, sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if event == sgs.TargetConfirmed then
			if not player:hasSkill(self:objectName()) then return "" end
			local use = data:toCardUse()
			if use.to:contains(player) and use.card:isKindOf("Slash") and use.from:objectName() ~= player:objectName() then
				room:addPlayerMark(player, "tishenMark")
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			for _, p in sgs.qlist(use.to) do
				if p:getMark("tishenMark") > 0 then
					room:removePlayerMark(p, "tishenMark")
					return self:objectName(), p
				end
			end
		elseif event == sgs.Damaged then
			if not player:hasSkill(self:objectName()) then return "" end
			if player:getMark("tishenMark") > 0 then
				room:removePlayerMark(player, "tishenMark")
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		if event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and room:getCardPlace(use.card:getId()) == sgs.Player_DiscardPile then
				ask_who:obtainCard(use.card)
			end
		end
		return false
	end
}
zhangfei:addSkill("paoxiao")
zhangfei:addSkill(tishen)
zhangfei:setDeputyMaxHpAdjustedValue(-1)

-----赵云-----

longhun = sgs.CreateTriggerSkill{
	name = "longhun",
	frequency = sgs.Skill_NotFrequent,
	relate_to_place = "head",
	events = {sgs.CardResponded, sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if player:getPhase() ~= sgs.Player_NotActive then return end
		if event == sgs.CardResponded then
			local response = data:toCardResponse()
			if response.m_isHandcard == false then return "" end
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() ~= player:objectName() then return "" end
		end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local card
		if event == sgs.CardResponded then
			local response = data:toCardResponse()
			if response.m_isHandcard == false then return "" end
			card = response.m_card
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() ~= player:objectName() then return "" end
			card = use.card
		end
		
		local id = room:getNCards(1):first()
		local move = sgs.CardsMoveStruct(id, nil, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "longhun", ""))
		room:moveCardsAtomic(move, true)
		room:getThread():delay(1000)
		local show_card = sgs.Sanguosha:getCard(id)
		if show_card:getColor() == card:getColor() then
			room:obtainCard(player, id)
		else
			room:throwCard(id, player)
		end
		return false
	end
}
zhaoyun:addSkill("longdan")
zhaoyun:addSkill(longhun)
zhaoyun:addCompanion("liushan")
zhaoyun:setHeadMaxHpAdjustedValue(-1)

-----徐盛-----

pojun = sgs.CreateTriggerSkill{
	name = "pojun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	can_trigger = function(self, event, room, player, data)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return "" end
		if player and not player:isDead() and use.from:hasSkill(self:objectName()) and use.to:contains(player) and not player:isNude() then
			return self:objectName(), use.from:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local to_data = sgs.QVariant()
		to_data:setValue(player)
		if room:askForSkillInvoke(ask_who,self:objectName(),to_data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local to_throw = room:askForCardChosen(ask_who, player, "he", self:objectName(), false, sgs.Card_MethodDiscard)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, ask_who:objectName(), player:objectName(), self:objectName(), nil)
		room:throwCard(sgs.Sanguosha:getCard(to_throw), reason, player, ask_who)
		if sgs.Sanguosha:getCard(to_throw):isRed() then
			player:drawCards(1)
		end
		return false
	end
}
xusheng:addSkill("yicheng")
xusheng:addSkill(pojun)
xusheng:addCompanion("dingfeng")

-----夏侯渊-----

hubuVS = sgs.CreateViewAsSkill{
	name = "hubu",
	expand_pile = "#hubu",
	n = 1,
	view_filter = function(self, selected, to_select)
		local Slashs = sgs.Self:property("hubuProp"):toString():split("+")
		return #selected == 0 and table.contains(Slashs, tostring(to_select:getId()))
	end,
	view_as = function(self, cards)
		return cards[1]
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@hubu"
	end,
	enabled_at_play = function(self, player)
		return false
	end
}
hubu = sgs.CreateTriggerSkill{
	name = "hubu",
	view_as_skill = hubuVS,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_preshow = true,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:isWounded() then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local lost_hp = player:getMaxHp() - player:getHp()
		if lost_hp <= 0 then return false end
		local ids = room:getNCards(lost_hp)
		local move = sgs.CardsMoveStruct(ids, nil, sgs.Player_PlaceTable, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "hubu", ""))
		room:moveCardsAtomic(move, true)
		room:getThread():delay(500)
		local slash_qlist = sgs.IntList()
		local slash_list = {}
		local discard_dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for i=0, lost_hp-1, 1 do
			local id = ids:at(i)
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("Slash") or card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") then
				slash_qlist:append(id)
				table.insert(slash_list, id)
			else
				discard_dummy:addSubcard(id)
			end
		end
		local used_cards = sgs.IntList()
		for i=0, slash_qlist:length() - 1, 1 do
			room:setPlayerProperty(player, "hubuProp", sgs.QVariant(table.concat(slash_list, "+")))
			room:notifyMoveToPile(player, slash_qlist, "hubu", sgs.Player_DrawPile, true, true)
			local card = room:askForUseCard(player, "@@hubu", "@hubu-card")
			room:notifyMoveToPile(player, slash_qlist, "hubu", sgs.Player_DrawPile, false, false)
			if card then
				for _, id in sgs.qlist(slash_qlist) do 
					if card:getId() == id then
						table.removeOne(slash_list, id)
						room:setPlayerProperty(player, "hubuProp", sgs.QVariant(table.concat(slash_list, "+")))
						used_cards:append(id)
						break
					end
				end
			else
				room:setPlayerProperty(player, "hubuProp", sgs.QVariant(""))
				break
			end
		end
		for _, id in sgs.qlist(slash_qlist) do 
			if not used_cards:contains(id) then
				discard_dummy:addSubcard(id)
			end
		end
		room:throwCard(discard_dummy, player)
		return false
	end,
}
xiahouyuan:addSkill("shensu")
xiahouyuan:addSkill(hubu)

-----夏侯惇-----

qingjianCard = sgs.CreateSkillCard{
	name = "qingjianCard",
	skill_name = "qingjian",
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select, player)
		return to_select:objectName() ~= player:objectName()
	end ,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		targets[1]:obtainCard(self, false)
	end
}
qingjianVS = sgs.CreateViewAsSkill{
	name = "qingjian",
	n = 999,
	response_pattern = "@@qingjian",
	view_filter = function(self, selected, to_select)
		local ids = sgs.Self:property("qingjianProp"):toString():split("+")
		return table.contains(ids, tostring(to_select:getId()))
	end, 
	view_as = function(self, originalCards) 
		if #originalCards == 0 then return false end
		local skillcard = qingjianCard:clone()
		for _, card in ipairs(originalCards) do
			skillcard:addSubcard(card)
		end
		skillcard:setSkillName("qingjian")
        skillcard:setShowSkill("qingjian")
		return skillcard
	end,
}
qingjian = sgs.CreateTriggerSkill{
	name = "qingjian",
	view_as_skill = qingjianVS,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	can_preshow = true,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:hasFlag("qingjian_used") then return "" end
		local move = data:toMoveOneTime()
		local isGet = (move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceHand --[[and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_PREVIEWGIVE]])
		if isGet then
			local list = {}
			for _, id in sgs.qlist(move.card_ids) do
				table.insert(list, id)
			end
			room:setPlayerProperty(player, "qingjianProp", sgs.QVariant(table.concat(list, "+")))
			return self:objectName() 
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForUseCard(player, "@@qingjian", "@qingjian_card", -1, sgs.Card_MethodNone) then
			room:setPlayerProperty(player, "qingjianProp", sgs.QVariant(""))
			return true
		end
		room:setPlayerProperty(player, "qingjianProp", sgs.QVariant(""))
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:setPlayerFlag(player, "qingjian_used")
		room:broadcastSkillInvoke(self:objectName())
		return false
	end
}	
xiahoudun:addSkill("ganglie")
xiahoudun:addCompanion("xiahouyuan")
xiahoudun:addSkill(qingjian)

-----刘备-----

renwang = sgs.CreateTriggerSkill{
	name = "renwang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_preshow = true,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPile("renwang"):length() == 0 and player:getPhase() == sgs.Player_Finish then
			if not player:isKongcheng() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card = room:askForCard(ask_who, ".|.|.|hand", "@renwang_invoke", data, sgs.Card_MethodNone, ask_who)
		if card then
			local _data = sgs.QVariant()
			_data:setValue(card)
			player:setTag("renwangTag", _data)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local card = player:getTag("renwangTag"):toCard()
		player:setTag("renwangTag", sgs.QVariant())
		player:addToPile("renwang", card, false)
		return false
	end
}	
renwangSlash = sgs.CreateTriggerSkill{
	name = "#renwang_slash",
	global = true,
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local skill_list, player_list = {}, {}
		local liubeis = room:findPlayersBySkillName("renwang")
		if player:isKongcheng() and player:getPhase() == sgs.Player_Finish then
			for _, liubei in sgs.qlist(liubeis) do 
				if liubei:getPile("renwang"):length() > 0 and sgs.Sanguosha:getCard(liubei:getPile("renwang"):first()):isKindOf("Slash") then
					table.insert(skill_list, self:objectName())
					table.insert(player_list, liubei:objectName())
				end
			end
		end
		return table.concat(skill_list, "|"), table.concat(player_list, "|")
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card = sgs.Sanguosha:getCard(ask_who:getPile("renwang"):first())
		local _data = sgs.QVariant()
		_data:setValue(player)
		room:setPlayerProperty(ask_who, "renwangAnalepticProp", _data)
		if room:askForSkillInvoke(ask_who,"renwangSlash", sgs.QVariant("renwangSlash:" .. player:objectName() .. "::" .. card:objectName())) then
			room:setPlayerProperty(ask_who, "renwangAnalepticProp", sgs.QVariant())
			return true
		end
		room:setPlayerProperty(ask_who, "renwangAnalepticProp", sgs.QVariant())
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("renwang")
		local card = sgs.Sanguosha:getCard(ask_who:getPile("renwang"):first())
		if not card:isKindOf("Slash") then return false end
		--local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		--slash:setSkillName("renwang")
		local card_use = sgs.CardUseStruct()
		card_use.from = ask_who
		card_use.to:append(player)
		card_use.card = card
		room:useCard(card_use, false)
		return false
	end
}	
renwangJink = sgs.CreateTriggerSkill{
	name = "#renwang_jink",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed},
	can_trigger = function(self, event, room, player, data)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return "" end
		if player and player:hasSkill("renwang") and not player:isDead() and use.to:contains(player) then
			if player:getPile("renwang"):length() > 0 and sgs.Sanguosha:getCard(player:getPile("renwang"):first()):isKindOf("Jink") then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("renwang")
		local use = data:toCardUse()
		local dummy = sgs.DummyCard(player:getPile("renwang"))
		dummy:deleteLater()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "renwang", "")
		room:throwCard(dummy, reason, nil)
		if use.to:contains(player) then
			local use = data:toCardUse()
			room:setEmotion(player, "cancel")
			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		end
	end
}	
renwangPeach = sgs.CreateTriggerSkill{
	name = "#renwang_peach",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Dying},
	can_trigger = function(self, event, room, player, data)
		local dying = data:toDying()
		if not (player and player:isAlive()) then return "" end
		local skill_list, player_list = {}, {}
		if player:objectName() == dying.who:objectName() then
			local liubeis = room:findPlayersBySkillName("renwang")
			for _, liubei in sgs.qlist(liubeis) do 
				if liubei:getPile("renwang"):length() > 0 and sgs.Sanguosha:getCard(liubei:getPile("renwang"):first()):isKindOf("Peach") then
					table.insert(skill_list, self:objectName())
					table.insert(player_list, liubei:objectName())
				end
			end
		end
		return table.concat(skill_list, "|"), table.concat(player_list, "|")
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card = sgs.Sanguosha:getCard(ask_who:getPile("renwang"):first())
		local _data = sgs.QVariant()
		_data:setValue(player)
		room:setPlayerProperty(ask_who, "renwangPeachProp", _data)
		if room:askForSkillInvoke(ask_who,"renwangPeach", sgs.QVariant("renwangPeach:" .. player:objectName() .. "::" .. card:objectName())) then
			room:setPlayerProperty(ask_who, "renwangPeachProp", sgs.QVariant())
			return true
		end
		room:setPlayerProperty(ask_who, "renwangPeachProp", sgs.QVariant())
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("renwang")
		local dummy = sgs.DummyCard(ask_who:getPile("renwang"))
		dummy:deleteLater()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "renwang", "")
		room:throwCard(dummy, reason, nil)
		room:doAnimate(1, ask_who:objectName(), player:objectName())
		local recover = sgs.RecoverStruct()
		recover.who = ask_who
		recover.recover = 2
		room:recover(player, recover)
	end
}
renwangAnaleptic = sgs.CreateTriggerSkill{
	name = "#renwang_analeptic",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if not (player and player:isAlive() and damage.from) then return "" end
		local skill_list, player_list = {}, {}
		if damage.card and damage.card:isKindOf("Slash") then
			local liubeis = room:findPlayersBySkillName("renwang")
			for _, liubei in sgs.qlist(liubeis) do 
				if liubei:getPile("renwang"):length() > 0 and sgs.Sanguosha:getCard(liubei:getPile("renwang"):first()):isKindOf("Analeptic") then
					table.insert(skill_list, self:objectName())
					table.insert(player_list, liubei:objectName())
				end
			end
		end
		return table.concat(skill_list, "|"), table.concat(player_list, "|")
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card = sgs.Sanguosha:getCard(ask_who:getPile("renwang"):first())
		local _data = sgs.QVariant()
		_data:setValue(player)
		room:setPlayerProperty(ask_who, "renwangAnalepticProp", _data)
		if room:askForSkillInvoke(ask_who, "renwangAnaleptic", sgs.QVariant("renwangAnaleptic:" .. player:objectName() .. "::" .. card:objectName())) then
			room:setPlayerProperty(ask_who, "renwangAnalepticProp", sgs.QVariant())
			return true
		end
		room:setPlayerProperty(ask_who, "renwangAnalepticProp", sgs.QVariant())
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("renwang")
		local dummy = sgs.DummyCard(ask_who:getPile("renwang"))
		dummy:deleteLater()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "renwang", "")
		room:throwCard(dummy, reason, nil)
		local damage = data:toDamage()
		room:doAnimate(1, ask_who:objectName(), damage.to:objectName())
		damage.damage = damage.damage + 1
		data:setValue(damage)
	end
}
renwangOther = sgs.CreateTriggerSkill{
	name = "#renwang_other",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if event == sgs.EventPhaseStart then
			if not (player and player:isAlive()) then return "" end
			local skill_list, player_list = {}, {}
			local liubeis = room:findPlayersBySkillName("renwang")
			if player:getPhase() == sgs.Player_Start then
				--先清除标记
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					p:setTag("renwang_get_tag", sgs.QVariant())
				end
				for _, liubei in sgs.qlist(liubeis) do 
					if liubei:getPile("renwang"):length() > 0 then
						local card = sgs.Sanguosha:getCard(liubei:getPile("renwang"):first())
						if not card:isKindOf("Slash") and not card:isKindOf("Jink") and not card:isKindOf("Analeptic") and not card:isKindOf("Peach") then
							table.insert(skill_list, self:objectName())
							table.insert(player_list, liubei:objectName())
						end
					end
				end
			elseif player:getPhase() == sgs.Player_Finish then
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					p:setTag("renwang_get_tag", sgs.QVariant())
				end
			end
			return table.concat(skill_list, "|"), table.concat(player_list, "|")
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if not use.card then return "" end
			local id = use.card:getId()
			for _, p in sgs.qlist(room:getAlivePlayers()) do 
				sendMsg(room, "id2:" .. p:property("renwang_get_prop"):toInt())
				if p:property("renwang_get_prop"):toInt() == id then
					room:broadcastSkillInvoke("renwang")
					room:doAnimate(1, p:objectName(), player:objectName())
					p:drawCards(1)
					room:setPlayerProperty(p, "renwang_get_prop", sgs.QVariant())
				end
			end
		end
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local card = sgs.Sanguosha:getCard(ask_who:getPile("renwang"):first())
		if event == sgs.EventPhaseStart and room:askForSkillInvoke(ask_who,"renwangOther",sgs.QVariant("renwangOther:" .. player:objectName() .. "::" .. card:objectName())) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke("renwang")
		if event == sgs.EventPhaseStart then
			local dummy = sgs.DummyCard(ask_who:getPile("renwang"))
			local id = ask_who:getPile("renwang"):first()
			if dummy:getSubcards():length() > 0 then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), "renwang", "")
				room:obtainCard(player, dummy, reason, false)
				room:setPlayerProperty(ask_who, "renwang_get_prop", sgs.QVariant(id))
			end
		end
	end
}
liubei:addSkill("rende")
liubei:addSkill(renwang)
liubei:addSkill(renwangSlash)
liubei:addSkill(renwangJink)
liubei:addSkill(renwangPeach)
liubei:addSkill(renwangAnaleptic)
liubei:addSkill(renwangOther)
extension2:insertRelatedSkills("renwang","#renwang_slash")
extension2:insertRelatedSkills("renwang","#renwang_jink")
extension2:insertRelatedSkills("renwang","#renwang_peach")
extension2:insertRelatedSkills("renwang","#renwang_analeptic")
extension2:insertRelatedSkills("renwang","#renwang_other")

local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("lizhan") then
skillList:append(lizhan)
end
if not sgs.Sanguosha:getSkill("zhaxiang") then
skillList:append(zhaxiang)
end
if not sgs.Sanguosha:getSkill("danqi") then
skillList:append(danqi)
end
sgs.Sanguosha:addSkills(skillList)	
local allNames = sgs.Sanguosha:getLimitedGeneralNames()
for i = #allNames, 1, -1 do  
	local general = sgs.Sanguosha:getGeneral(allNames[i])
	if allNames[i] == "caoren" then
		general:addSkill("lizhan")
		general:setDeputyMaxHpAdjustedValue(-1)
	end
	if allNames[i] == "huanggai" then
		general:addSkill("zhaxiang")
	end
	if allNames[i] == "guanyu" then
		general:addSkill("danqi")
		general:setDeputyMaxHpAdjustedValue(-1)
	end
end  

--**********猛包**********-----

-----赵子龙-----
yajiao = sgs.CreateTriggerSkill{
	name = "yajiao" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.EventPhaseStart} ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if player:getPhase() == sgs.Player_Finish then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:notifySkillInvoked(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		local x = room:getAlivePlayers():length()
		local ids = room:getNCards(x, false)
		local card_to_obtain = {}
		for i=0, x-1, 1 do
			local id = ids:at(i)
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("Slash") or card:isKindOf("FireSlash") or card:isKindOf("ThunderSlash") then
				table.insert(card_to_obtain, id)
			end
		end
		if #card_to_obtain > 0 then
			local dummy2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, id in ipairs(card_to_obtain) do
				dummy2:addSubcard(id)
			end
			room:obtainCard(player, dummy2,true)
		end
		if #card_to_obtain > x/2 then
			player:turnOver()
		end
	end
}
chongzhen = sgs.CreateTriggerSkill{
	name = "chongzhen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.SlashProceed},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") then return "" end
			if player and player:hasSkill(self:objectName()) and not player:isDead() and use.to:contains(player) then
				return self:objectName()
			end
		elseif event == sgs.SlashProceed then
			local use = data:toSlashEffect()
			if player and player:hasSkill(self:objectName()) and not player:isDead() and use.from:objectName() == player:objectName() then
				return self:objectName()	
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local use
		local num 
		if event == sgs.TargetConfirmed then
			use = data:toCardUse()
			num = use.card:getNumber() + 1
			if use.to:contains(player) and room:askForCard(player, "BasicCard|.|"..num.."~13", "@chongzhen2", data, sgs.CardDiscarded) then
				return true
			end
		elseif event == sgs.SlashProceed then
			use = data:toSlashEffect()
			num = use.slash:getNumber() + 1
			if use.from:objectName() == player:objectName() and room:askForCard(player, "BasicCard|.|"..num.."~13", "@chongzhen1", data, sgs.CardDiscarded) then
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.to:contains(player) then
				local use = data:toCardUse()
				room:setEmotion(player, "cancel")
				local nullified_list = use.nullified_list
				table.insert(nullified_list, player:objectName())
				use.nullified_list = nullified_list
				data:setValue(use)
			end
		elseif event == sgs.SlashProceed then
			local use = data:toSlashEffect()
			if use.from:objectName() == player:objectName() then
				local effect = data:toSlashEffect()
				room:slashResult(effect,nil)
				return true
			end
		end
		return false
	end
}
meng_zhaoyun:addSkill(yajiao)
meng_zhaoyun:addSkill(chongzhen)

-----陆伯言-----

shaoying = sgs.CreateTriggerSkill{
	name = "shaoying",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.Damage},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				return self:objectName()
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Fire and not damage.to:getNextAlive(1):isKongcheng() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if event == sgs.Damage then
			if room:askForSkillInvoke(player,self:objectName(),data) then
				return true
			end
		elseif event == sgs.EventPhaseStart then
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if not p:isKongcheng() then
					targets:append(p)
				end
			end
			local to = room:askForPlayerChosen(player, targets, self:objectName(), "shaoying-invoke", true, true)
			if to then
				room:setPlayerProperty(player, "shaoyingProp", sgs.QVariant(to:objectName()))
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local to
		if event == sgs.EventPhaseStart then
			objectName = player:property("shaoyingProp"):toString()
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:objectName() == objectName then
					to = p 
					break
				end
			end
			room:setPlayerProperty(player, "shaoyingProp", sgs.QVariant())
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			to = damage.to:getNextAlive(1)
		end
		local fire_attack = sgs.Sanguosha:cloneCard("fire_attack", sgs.Card_NoSuit, 0)
		fire_attack:setSkillName("shaoying")
		local card_use = sgs.CardUseStruct()
		card_use.from = player
		card_use.to:append(to)
		card_use.card = fire_attack
		room:useCard(card_use, false)
		return false
	end
}
linggong = sgs.CreateTriggerSkill{
	name = "linggong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.Damage},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				room:setPlayerProperty(player, "linggongProp", sgs.QVariant(0))
			elseif player:getPhase() == sgs.Player_Finish then
				local num = player:property("linggongProp"):toInt()
				if num > 0 then
					return self:objectName()
				end
			end
		elseif event == sgs.Damage then
			local damage = data:toDamage()
			if damage.nature == sgs.DamageStruct_Fire then
				local num = player:property("linggongProp"):toInt()
				room:setPlayerProperty(player, "linggongProp", sgs.QVariant(num + 1))
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		room:setPlayerProperty(player, "linggongProp", sgs.QVariant(0))
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local num = player:property("linggongProp"):toInt()
		if num > 3 then num = 3 end
		player:drawCards(num)
		room:setPlayerProperty(player, "linggongProp", sgs.QVariant(0))
		return false
	end,
	priority = 100
}
meng_luxun:addSkill(shaoying)
meng_luxun:addSkill(linggong)

-----古之恶来-----
hengsao = sgs.CreateTargetModSkill{
	name = "hengsao",
	pattern = "Slash",
	extra_target_func = function(self, player)
		if player:hasShownSkill(self:objectName()) and player:getEquip(0) then
			return player:getAttackRange() - 1
		else
			return 0
		end
	end
}
tiequCard = sgs.CreateSkillCard{
	name = "tiequCard",
	target_fixed=true,
	skill_name = "tiequ",
	on_use = function(self, room, source, targets)
		if not source:isAlive() then return false end
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.to = source
		damage.damage = 1
		room:damage(damage)
		local cardList = {}
		local DiscardPile = room:getDiscardPile()
		for _,cid in sgs.qlist(DiscardPile) do
			local cd = sgs.Sanguosha:getCard(cid)
			if cd:isKindOf("Yitian") or cd:isKindOf("Shengguangbaiyi") or cd:isKindOf("juechen") or cd:isKindOf("nanmanxiang") then
				continue
			end
			if cd:isKindOf("Weapon") and not source:getEquip(0) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("Armor") and not source:getEquip(1) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("DefensiveHorse") and not source:getEquip(2) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("OffensiveHorse") and not source:getEquip(3) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("Treasure") and not source:getEquip(4) then
				table.insert(cardList, cid)
			end
		end
		local DrawPile = room:getDrawPile()
		for _,cid in sgs.qlist(DrawPile) do
			local cd = sgs.Sanguosha:getCard(cid)
			if cd:isKindOf("Yitian") or cd:isKindOf("Shengguangbaiyi") or cd:isKindOf("juechen") or cd:isKindOf("nanmanxiang") then
				continue
			end
			if cd:isKindOf("Weapon") and not source:getEquip(0) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("Armor") and not source:getEquip(1) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("DefensiveHorse") and not source:getEquip(2) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("OffensiveHorse") and not source:getEquip(3) then
				table.insert(cardList, cid)
			elseif cd:isKindOf("Treasure") and not source:getEquip(4) then
				table.insert(cardList, cid)
			end
		end
		for i = 0, 10000 do
			local card = sgs.Sanguosha:getEngineCard(i)
			if card == nil then break end
			if card:isKindOf("Yitianjian") then
				local hasYitian = false
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getEquip(0) and p:getEquip(0):isKindOf("Yitianjian") then
						hasYitian = true
					end
				end
				if not hasYitian then table.insert(cardList, i) end
			end
			if card:isKindOf("Shengguangbaiyi") then
				local hasShengguangbaiyi = false
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getEquip(1) and p:getEquip(1):isKindOf("Shengguangbaiyi") then
						hasShengguangbaiyi = true
					end
				end
				if not hasShengguangbaiyi then table.insert(cardList, i) end
			end
			if card:isKindOf("Juechen") then
				local hasJuechen = false
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getEquip(2) and p:getEquip(2):isKindOf("Juechen") then
						hasJuechen = true
					end
				end
				if not hasJuechen then table.insert(cardList, i) end
			end
			if card:isKindOf("Nanmanxiang") then
				local hasNanmanxiang = false
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getEquip(3) and p:getEquip(3):isKindOf("Nanmanxiang") then
						hasNanmanxiang = true
					end
				end
				if not hasNanmanxiang then table.insert(cardList, i) end
			end
		end
		local randomNum = math.random(1,#cardList)
		local card = sgs.Sanguosha:getCard(cardList[randomNum])
		local use = sgs.CardUseStruct()
		use.card = card
		use.from = source
		use.to:append(source)
		room:useCard(use)
		return false
	end,
}
tiequ = sgs.CreateZeroCardViewAsSkill{
	name = "tiequ",
	view_as = function(self) 
		local card = tiequCard:clone()
		card:setShowSkill(self:objectName())
		return card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#tiequCard")
	end
}
meng_dianwei:addSkill(hengsao)
meng_dianwei:addSkill(tiequ)

-----董仲颖-----

huangyinCard = sgs.CreateSkillCard{
	name = "huangyinCard",
	skill_name = "huangyin",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then
			return false
		elseif not to_select:isFemale() then
			return false
		elseif #targets == 0 then
			return true
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("huangyin")
		local to = targets[1]
		room:askForDiscard(to, self:objectName(), 1, 1, false, true)
		if to:getHandcardNum() > source:getHandcardNum() then
			local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(source, recover)
		end
	end
}
huangyin = sgs.CreateZeroCardViewAsSkill{   
	name = "huangyin",
	view_as = function(self)
		local skillcard = huangyinCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#huangyinCard")
	end,
}

weishe = sgs.CreateTriggerSkill{
	name = "weishe",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if not (use.card:isKindOf("Slash") or (use.card:isNDTrick() and use.card:isBlack())) then return "" end
			if player and player:hasSkill(self:objectName()) and not player:isDead() and use.from:objectName() == player:objectName() and use.to:length() > 0 then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local use = data:toCardUse()
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(use.to) do
			if not p:isNude() then
				targets:append(p)
			end
		end
		if targets:length() > 0 then
			local to = room:askForPlayerChosen(player, targets, self:objectName(), "weishe-invoke", true, true)
			if to then
				room:setPlayerProperty(player, "weisheProp", sgs.QVariant(to:objectName()))
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local to
		objectName = player:property("weisheProp"):toString()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() == objectName then
				to = p 
				break
			end
		end
		room:setPlayerProperty(player, "weisheProp", sgs.QVariant())
		if to then
			room:askForDiscard(to, self:objectName(), 1, 1, false, true)
		end
		return false
	end
} 
meng_dongzhuo:addSkill(huangyin)
meng_dongzhuo:addSkill(weishe)

-----周公瑾-----

sashuang = sgs.CreateTriggerSkill{
	name = "sashuang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() == sgs.Player_Start then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		targets:append(player)
		if player:getRole() ~= "careerist" then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasShownOneGeneral() and p:getKingdom() == player:getKingdom() and p:getRole() ~= "careerist" then
					targets:append(p)
				end
			end
		end
		if targets:length() > 0 then
			local to = room:askForPlayerChosen(player, targets, self:objectName(), "sashuang-invoke", true, true)
			if to then
				local to_data = sgs.QVariant()
				to_data:setValue(to)
				player:setTag("sashuangTag", to_data)
				return true
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local to = player:getTag("sashuangTag"):toPlayer()
		to:drawCards(1)
		if room:askForSkillInvoke(to, self:objectName(), sgs.QVariant("changeHero:::" .. to:getKingdom())) then
			local generalList = room:getTag("generalListTag"):toString():split("+")
			if #generalList <= 1 then
				generalList = initGenerals()
			end
			local selected_general = {}
			for _, p in sgs.qlist(room:getAlivePlayers()) do 
				if not table.contains(selected_general, p:getGeneralName()) then
					table.insert(selected_general, p:getGeneralName())
				end
				if not table.contains(selected_general, p:getGeneral2Name()) then
					table.insert(selected_general, p:getGeneral2Name())
				end
			end
			local general, new_general_list = getGenerals(generalList, to:getKingdom(), selected_general)
			table.removeOne(new_general_list, to:getGeneral2Name())
			table.insert(new_general_list, to:getGeneral2Name())
			--sendMsg(room, table.concat(new_general_list, "+"))
			room:setTag("generalListTag", sgs.QVariant(table.concat(new_general_list, "+")))
			--to:removeGeneral(false)  --士兵没有General的bug
			to:showGeneral(false)
			local skill_list = to:getGeneral2():getSkillList(true, false)
			if skill_list:length() > 0 then
				for _, skill in sgs.qlist(skill_list) do
					room:detachSkillFromPlayer(to,skill:objectName())
				end
			end
			room:changePlayerGeneral2(to, general)
			skill_list = sgs.Sanguosha:getGeneral(general):getSkillList(true, false)
			if skill_list:length() > 0 then
				for _, skill in sgs.qlist(skill_list) do
					room:acquireSkill(to, skill,true,false)
				end
			end
		end
	end,
	priority = -1,
}
xinjiCard = sgs.CreateSkillCard{
    name = "xinjiCard", 
	skill_name = "xinji",
	filter = function(self, targets, to_select) 
		if #targets ~= 0 then return false end
		return not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect)
        local room = effect.from:getRoom()
		room:showAllCards(effect.to)
		room:broadcastSkillInvoke(self:objectName())
		room:getThread():delay(2000)
		local suit = sgs.Sanguosha:getCard(self:getSubcards():first()):getSuit()
		local has = 0
		local dummy = sgs.DummyCard()
		for _, c in sgs.qlist(effect.to:getHandcards()) do
			if c:getSuit() == suit then
				has = 1
				dummy:addSubcard(c)
			end
		end
		if has > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, effect.from:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		else
			room:addPlayerMark(effect.to,"xinjidistant")
			local msg = sgs.LogMessage()
			msg.type = "#xinjimsg"
			msg.from = effect.from
			msg.to:append(effect.to)
			room:sendLog(msg)
        end
	end
}
xinji = sgs.CreateViewAsSkill{
	name = "xinji", 
	n = 1, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#xinjiCard")
	end,
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end, 
	view_as = function(self, cards)
	if #cards == 0 then return nil end
		local card = xinjiCard:clone()
		card:addSubcard(cards[1])
		return card
	end
}
xinji1 = sgs.CreateTriggerSkill{
	name = "#xinji1" ,
	global = true,
	events = {sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if player:getPhase() == sgs.Player_Play then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("xinjidistant") > 0 then
					room:setPlayerMark(p,"xinjidistant",0)
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
	end
}
xinji2 = sgs.CreateDistanceSkill{
	name = "#xinji2",
	global = true,
	correct_func = function(self, from, to)
		if from:hasSkill("xinji") and to:getMark("xinjidistant") > 0 then
		    return - 999
		else
			return 0
		end
	end
}
meng_zhouyu:addSkill(sashuang)
meng_zhouyu:addSkill(xinji)
meng_zhouyu:addSkill(xinji1)
meng_zhouyu:addSkill(xinji2)
extension2:insertRelatedSkills("xinji","#xinji1")
extension2:insertRelatedSkills("xinji","#xinji2")

-----诸葛孔明-----

qixing = sgs.CreateTriggerSkill{
	name = "qixing",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GeneralShown, sgs.EventPhaseEnd, sgs.EventPhaseStart, sgs.EventLoseSkill},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.GeneralShown then
			if not player:hasSkill(self:objectName()) then return "" end
			if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
			return self:objectName()
		elseif event == sgs.EventPhaseEnd then
			if player:getPile("stars"):length() == 0 then return "" end
			if player:getPhase() == sgs.Player_Draw then
				return self:objectName()
			end
		elseif event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			player:clearOnePrivatePile("stars")
		elseif event == sgs.EventPhaseStart then
			if not player:hasShownSkill(self:objectName()) and player:getPhase() == sgs.Player_Start then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if event == sgs.EventPhaseEnd then
			if room:askForSkillInvoke(player,self:objectName(),data) then
				room:notifySkillInvoked(player, self:objectName())
				room:broadcastSkillInvoke(self:objectName())
				return true
			end
		elseif event == sgs.EventPhaseStart then
			if room:askForSkillInvoke(player,self:objectName(),sgs.QVariant("qixingShow")) then
				return true
			end
		elseif event == sgs.GeneralShown then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if event == sgs.GeneralShown then
			player:drawCards(7)
			local exchange_card = room:askForExchange(player, self:objectName(), 7, 7)
			if not exchange_card then
				exchange_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for p = 0, 7-1, 1 do
					exchange_card:addSubcard(player:getHandcards():at(p))
				end
			end
			player:addToPile("stars", exchange_card:getSubcards(), false)
			exchange_card:deleteLater()
		elseif event == sgs.EventPhaseStart then
			player:showGeneral(player:inHeadSkills(self:objectName()))
		elseif event == sgs.EventPhaseEnd then
			local handcards = sgs.IntList()
			local cards = player:getHandcards()
			for _, c in sgs.qlist(cards) do
				handcards:append(c:getId())
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
			local notify_visible_list = sgs.IntList()
			notify_visible_list:append(-1)
			local AsMove = room:askForMoveCards(player, player:getPile("stars"), handcards, true, self:objectName(), "", self:objectName(), player:getHandcardNum(), player:getHandcardNum(), false, false, notify_visible_list)
			local to_draw = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			local to_pile = sgs.IntList()
			for _, c in sgs.qlist(AsMove.bottom) do
				local ccc = sgs.Sanguosha:getCard(c)
				if not cards:contains(ccc) then
					to_draw:addSubcard(ccc)
				end
			end
			for _, c in sgs.qlist(AsMove.top) do
				local ccc = sgs.Sanguosha:getCard(c)
				if cards:contains(ccc) then
					to_pile:append(c)
				end
			end
			player:addToPile("stars", to_pile, false)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName(), player:objectName(), self:objectName(),"")
			room:moveCardTo(to_draw, player, sgs.Player_PlaceHand, reason)
		end
		return false
	end
}
dawuCard = sgs.CreateSkillCard{
	name = "dawuCard",
	skill_name = "dawu",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets < self:getSubcards():length() and to_select:getMark("@fog") == 0
	end,
	feasible = function(self, targets)
		return #targets == self:getSubcards():length()
	end,
	about_to_use = function(self, room, cardUse)
		local stars = cardUse.from:getPile("stars")
		if stars:isEmpty() then return false end
		local cards = self:getSubcards()
		local dummy = sgs.DummyCard()
		dummy:addSubcards(cards)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", cardUse.to:first():objectName(), "dawu", "")
		room:throwCard(dummy, reason, nil)
		local source, targets = cardUse.from, cardUse.to
		room:broadcastSkillInvoke("dawu")
		for _, p in sgs.qlist(targets) do 
			room:doAnimate(1, source:objectName(), p:objectName())
			p:gainMark("@fog")
		end
	end,
}
dawuVS = sgs.CreateViewAsSkill{
	name = "dawu",
	response_pattern = "@@dawu",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("stars"):contains(to_select:getId())
	end, 
	view_as = function(self, originalCards) 
		if #originalCards == 0 then return false end
		local skillcard = dawuCard:clone()
		for _, card in ipairs(originalCards) do
			skillcard:addSubcard(card)
		end
		skillcard:setSkillName(self:objectName())
        skillcard:setShowSkill("dawu")
		return skillcard
	end,
}
dawu = sgs.CreateTriggerSkill{
	name = "dawu",
	can_preshow = true,
	events = {sgs.EventPhaseStart, sgs.Death, sgs.EventLoseSkill},
	view_as_skill = dawuVS,
    can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.Death then
			for _,p in sgs.qlist(room:getAllPlayers()) do
				p:loseAllMarks("@fog")
			end
		end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _,p in sgs.qlist(room:getAllPlayers()) do
					p:loseAllMarks("@fog")
				end
			end
			if player:getPhase() == sgs.Player_Finish and player:getPile("stars"):length() > 0 then
				return self:objectName()
			end
		end
		--[[if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			for _,p in sgs.qlist(room:getAllPlayers()) do
				p:loseAllMarks("@fog")
			end
		end--]]
		return ""
	end,
    on_cost = function(self, event, room, player, data, ask_who)
		local invoked = room:askForUseCard(player, "@@dawu", "@dawu", -1, sgs.Card_MethodNone)
		if invoked then
			return true
		end
		return false
	end,
    on_effect = function(self, event, room, player, data, ask_who)
	end,
}
dawu_effect = sgs.CreateTriggerSkill{
	name = "#dawu_effect",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Thunder and player:getMark("@fog") > 0 then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		sendMsgByFrom(room, "受到了大雾的效果，伤害被取消", player)
		return true
	end
}
kuangfengCard = sgs.CreateSkillCard{
	name = "kuangfengCard",
	skill_name = "kuangfeng",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		return #targets == 0 and to_select:getMark("@gale") == 0
	end,
	about_to_use = function(self, room, cardUse)
		local stars = cardUse.from:getPile("stars")
		if stars:isEmpty() then return false end
		local card_id = self:getSubcards():first()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", cardUse.to:first():objectName(), "kuangfeng", "")
		room:throwCard(sgs.Sanguosha:getCard(card_id), reason, nil)
		local source, target = cardUse.from, cardUse.to:at(0)
		room:doAnimate(1, source:objectName(), target:objectName())
		room:broadcastSkillInvoke("kuangfeng")
		target:gainMark("@gale")
	end,
}
kuangfengVS = sgs.CreateViewAsSkill{
	name = "kuangfeng",
	response_pattern = "@@kuangfeng",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		return #selected == 0 and sgs.Self:getPile("stars"):contains(to_select:getId())
	end, 
	view_as = function(self, originalCards) 
		if #originalCards ~= 1 then return false end
		local skillcard = kuangfengCard:clone()
		for _, card in ipairs(originalCards) do
			skillcard:addSubcard(card)
		end
		skillcard:setSkillName(self:objectName())
        skillcard:setShowSkill("kuangfeng")
		return skillcard
	end,
}
kuangfeng = sgs.CreateTriggerSkill{
	name = "kuangfeng",
	can_preshow = true,
	events = {sgs.EventPhaseStart, sgs.Death, sgs.EventLoseSkill},
	view_as_skill = kuangfengVS,
    can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.Death then
			for _,p in sgs.qlist(room:getAllPlayers()) do
				p:loseAllMarks("@gale")
			end
		end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_RoundStart then
				for _,p in sgs.qlist(room:getAllPlayers()) do
					p:loseAllMarks("@gale")
				end
			end
			if player:getPhase() == sgs.Player_Finish and player:getPile("stars"):length() > 0 then
				return self:objectName()
			end
		end
		--[[if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			sendMsg(room, "eee")
			for _,p in sgs.qlist(room:getAllPlayers()) do
				p:loseAllMarks("@fog")
			end
		end--]]
		return ""
	end,
    on_cost = function(self, event, room, player, data, ask_who)
		local invoked = room:askForUseCard(player, "@@kuangfeng", "@kuangfeng", -1, sgs.Card_MethodNone)
		if invoked then
			return true
		end
		return false
	end,
    on_effect = function(self, event, room, player, data, ask_who)
	end,
}
kuangfeng_effect = sgs.CreateTriggerSkill{
	name = "#kuangfeng_effect",
	global = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire and player:getMark("@gale") > 0 then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		return true
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		local damage = data:toDamage()
		damage.damage = damage.damage + 1
		data:setValue(damage)
		sendMsgByFrom(room, "受到了狂风的效果，伤害+1", player)
		return false
	end
}
xumingCard = sgs.CreateSkillCard{
	name = "xumingCard",
	skill_name = "xuming",
	target_fixed = true,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	about_to_use = function(self, room, cardUse)
		local source = cardUse.from
		local stars = cardUse.from:getPile("stars")
		if stars:isEmpty() then return false end
		local cards = self:getSubcards()
		local dummy = sgs.DummyCard()
		dummy:addSubcards(cards)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", cardUse.from:objectName(), "xuming", "")
		room:throwCard(dummy, reason, nil)
		source:loseMark("@xumingMark")
		room:doSuperLightbox("meng_zhugeliang", "xuming")
		local num = self:getSubcards():length()
		local recover = sgs.RecoverStruct()
		recover.who = source
		recover.recover = num
		room:recover(source, recover)
		room:broadcastSkillInvoke("xuming")
		room:detachSkillFromPlayer(source,"kuangfeng")
		room:detachSkillFromPlayer(source,"dawu")
		for _,p in sgs.qlist(room:getAllPlayers()) do
			p:loseAllMarks("@fog")
			p:loseAllMarks("@gale")
		end
		sendMsgByFrom(room, "发动了技能“续命”", source)
	end,
}
xumingVS = sgs.CreateViewAsSkill{
	name = "xuming",
	response_pattern = "@@xuming",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		local num = sgs.Self:getMaxHp() - sgs.Self:getHp()
		return #selected < num and sgs.Self:getPile("stars"):contains(to_select:getId())
	end, 
	view_as = function(self, originalCards) 
		if #originalCards == 0 then return false end
		local skillcard = xumingCard:clone()
		for _, card in ipairs(originalCards) do
			skillcard:addSubcard(card)
		end
		skillcard:setSkillName(self:objectName())
        skillcard:setShowSkill("xuming")
		return skillcard
	end,
}
xuming = sgs.CreateTriggerSkill{
	name = "xuming",
	can_preshow = true,
	events = {sgs.Dying},
	frequency = sgs.Skill_Limited,
	view_as_skill = xumingVS,
	limit_mark = "@xumingMark", 
    can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getMark("@xumingMark") > 0 and player:getPile("stars"):length() > 0 then
			return self:objectName()
		end
		return ""
	end,
    on_cost = function(self, event, room, player, data, ask_who)
		local invoked = room:askForUseCard(player, "@@xuming", "@xuming", -1, sgs.Card_MethodNone)
		if invoked then
			return true
		end
		return false
	end,
    on_effect = function(self, event, room, player, data, ask_who)
	end,
}
meng_zhugeliang:addSkill(qixing)
meng_zhugeliang:addSkill(dawu)
meng_zhugeliang:addSkill(dawu_effect)
meng_zhugeliang:addSkill(kuangfeng)
meng_zhugeliang:addSkill(kuangfeng_effect)
meng_zhugeliang:addSkill(xuming)
extension2:insertRelatedSkills("dawu","#dawu_effect")
extension2:insertRelatedSkills("kuangfeng","#kuangfeng_effect")
meng_zhugeliang:addCompanion("huangyueying")

--**********测试专用**********-----

zhenhan = sgs.CreateTriggerSkill{
	name = "zhenhan",
	can_preshow = false,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			player:showGeneral(player:inHeadSkills(self:objectName()))
			local phases = sgs.PhaseList()
			phases:append(sgs.Player_Play)
			player:play(phases)
		end
		return false
	end
}
gaoda:addSkill(zhenhan)
gaoda:addSkill("guidao")
gaoda:addSkill("tiandu")
gaoda:addSkill("yiji")
gaoda:addSkill("beige")

--===========================================珠联璧合区============================================--

--**********智包**********-----

zhangxiu:addCompanion("jiaxu")
zhangxiu:addCompanion("zoushi")
huaxiong:addCompanion("panfeng")
bulianshi:addCompanion("sunquan")
zhangchunhua:addCompanion("simayi")
liru:addCompanion("dongzhuo")
liru:addCompanion("meng_dongzhuo")
liyan:addCompanion("zhugeliang")
zumao:addCompanion("sunjian")
zhoucang:addCompanion("guanyu")
caimao:addCompanion("liubiao")
hejin:addCompanion("hetaihou")
maliang:addCompanion("masu")
chengong:addCompanion("lvbu")
caojie:addCompanion("liuxie")
xiahoushi:addCompanion("zhangfei")
zhugeke:addCompanion("zhugejin")
meng_zhouyu:addCompanion("sunce")
meng_zhaoyun:addCompanion("liushan")

--**********猛包**********-----

meng_zhaoyun:addCompanion("liushan")


--[[
local allNames = sgs.Sanguosha:getLimitedGeneralNames()
for i = #allNames, 1, -1 do  
	local general = sgs.Sanguosha:getGeneral(allNames[i])
	if general:getPackage() ~= "javier" then
		general:addSkill("shop")
	end
end  
]]--

--===========================================翻译区============================================--

sgs.LoadTranslationTable{
	["javier"] = "智包" ,
	["strengthen"] = "加强包",
	["meng"] = "猛包",
	--智包--
	["zhangchunhua"] = "张春华",
	["~zhangchunhua"] = "怎能如此对我。",
	["#zhangchunhua"] = "冷血皇后",
	["jueqing"] = "绝情",
	[":jueqing"] = "当你造成伤害时，你可以指定一名角色为伤害来源。",
	["$jueqing1"] = "无来无去，不悔不怨",
	["$jueqing2"] = "你的死活，与我何干。",
	["shangshi"] = "伤势",
	[":shangshi"] = "弃牌阶段外，当你的手牌数小于X时，你可以将手牌补至X张（X为你已损失的体力值）。",
	["$shangshi1"] = "自损八百，可伤敌一千。",
	["$shangshi2"] = "无情者伤人，有情者自伤",
	["zhangxiu"] = "张绣",
	["#zhangxiu"] = "破羌将军",
	["tusha"] = "突杀",
	[":tusha"] = "锁定技，你对满体力的角色造成的伤害+1。",
	["jiaoxie"] = "缴械",
	[":jiaoxie"] = "你使用【杀】指定目标时，可以获得其一张装备牌。",
	["$tusha1"] = "给我上！",
	["$tusha2"] = "杀你个措手不及！",
	["$jiaoxie1"] = "纵使你有三头六臂，没有兵器，也只是个任人宰割的羊",
	["$jiaoxie2"] = "看你还怎么反抗",
	["huaxiong"] = "华雄",
	["~huaxiong"] = "皮厚不挡刀哇……",
	["#huaxiong"] = "魔将",
	["shiyong"] = "恃勇",
	[":shiyong"] = "一名角色使用【杀】对你造成伤害后，若你明置了武将牌，其可以与你拼点，若你赢，你获得其的拼点牌；若你输，其获得你的拼点牌。",
	["$shiyong1"] = "好大一股杀气啊！",
	["$shiyong2"] = "好大一股酒气啊！",
	["yaowu"] = "耀武",
	[":yaowu"] = "限定技，一名角色将要受到伤害时，若其的体力值为1，你可以令其防止此伤害。",
	["$yaowu1"] = "哼！先让你尝点甜头。",
	["$yaowu2"] = "大人有大量，不和你计较。",
	["sunhao"] = "孙皓",
	["~sunhao"] = "命啊！命！……",
	["#sunhao"] = "时日曷丧",
	["canshi"] = "残蚀",
	[":canshi"] = "摸牌阶段，你可改为摸X张牌（X为已受伤的角色数），然后当你本回合使用基本牌或锦囊牌时，你弃置一张牌。<br /><font color=\"pink\">注：当没有人受伤时，不能发动此技能。</font>",
	["$canshi1"] = "众人与蝼蚁何异？哈哈哈……",
	["$canshi2"] = "难道一切不在朕手中？",
	["chouhai"] = "仇海",
	[":chouhai"] = "锁定技，当你受到伤害时，若你没有手牌，此伤害+1。",
	["$chouhai1"] = "哼，树敌三千又如何？",
	["$chouhai2"] = "不发狂，就灭亡！",
	["niujin"] = "牛金",
	["~niujin"] = "这~包围圈太厚，老牛，尽力了……",
	["#niujin"] = "独进的兵胆",
	["cuorui"] = "挫锐",
	[":cuorui"] = "锁定技，当你受到伤害后，你须将一张手牌置于牌堆顶。",
	["$cuorui1"] = "区区乌合之众，如何困得住我！",
	["$cuorui2"] = "今日就让你见识见识~老牛的厉害！",
	["liewei"] = "裂围",
	[":liewei"] = "你的回合外明置此武将牌时，你可以摸三张牌然后执行一个额外的出牌阶段。",
	["$liewei1"] = "敌阵已乱，速速突围！",
	["$liewei2"] = "杀你，如同碾死一只蚂蚁。",
	["liaohua"] = "廖化",
	["~liaohua"] = "今后就靠你们了。",
	["#liaohua"] = "历尽沧桑",
	["fuli"] = "伏枥",
	[":fuli"] = "大势力角色对你造成伤害时，你可以弃置一张红色牌令此伤害-1。",
	["$fuli1"] = "有老夫在，蜀汉就不会倒下。",
	["$fuli2"] = "今天是个拼命的好日子，哈哈哈哈。",
	["liubiao"] = "刘表",
	["~liubiao"] = "优柔寡断，要不得啊！……",
	["#liubiao"] = "跨蹈汉南",
	["gushou"] = "固守",
	[":gushou"] = "锁定技，其他角色计算与你的距离时，始终+x，x为你已损失体力值。你的手牌上限等于你的体力上限。",
	["$gushou1"] = "江河霸主，何惧之有？",
	["$gushou2"] = "荆襄之地，固若金汤！",
	["bulianshi"] = "步练师",
	["~bulianshi"] = "江之永矣，不可方思。",
	["#bulianshi"] = "无冕之后",
	["anxu"] = "安恤",
	[":anxu"] = "出牌阶段限一次，你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为♠，你摸一张牌。 ",
	["$anxu1"] = "君子乐胥，万邦之屏。",
	["$anxu2"] = "和鸾雝雝，万福攸同。",
	["zhuiyi"] = "追忆",
	[":zhuiyi"] = "你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。 ",
	["$zhuiyi1"] = " 妾心所系，如月之恒。",
	["$zhuiyi2"] = "终其永怀，恋心殷殷。",
	["jianyong"] = "简雍",
	["~jianyong"] = "两国交战，不斩...唔唔唔",
	["#jianyong"] = "优游风议",
	["qiaoshui"] = "巧说",
	[":qiaoshui"] = "出牌阶段限一次，你可以与一名其他角色拼点，若你赢，视为你对其使用了一张无距离限制的【顺手牵羊】。",
	["$qiaoshui1"] = " 合则两利，斗则两伤。",
	["$qiaoshui2"] = "君且安坐，听我一言。",
	["zongshi"] = "纵适",
	[":zongshi"] = "当有拼点结束后，你可以获得其中的黑桃牌。<br /><font color=\"pink\">注：如果是“恃勇”发起的拼点，则“恃勇”的结算先于该技能。</font>",
	["$zongshi1"] = "买卖不成，情义还在。",
	["$zongshi2"] = "此等小事，何须挂耳？",
	["xushu"] = "徐庶",
	["~xushu"] = "母亲，孩儿尽孝来了……",
	["#xushu"] = "化剑为犁",
	["zhuhai"] = "诛害",
	[":zhuhai"] = "主将技，一名其他角色的结束阶段开始时，若该角色本回合造成过伤害，你可以对其使用一张无距离限制的【杀】。然后若此杀被闪避，你摸一张牌。 ",
	["$zhuhai1"] = "善恶有报，天道轮回！",
	["$zhuhai2"] = "早知今日，何必当初！",
	["wuyan"] = "无言",
	[":wuyan"] = "副将技，此武将牌上单独的阴阳鱼个数-1，锁定技，每当你造成或受到伤害时，防止锦囊牌的伤害。 ",
	["$wuyan1"] = "汝有良策，何必问我！",
	["$wuyan2"] = "吾，誓不为汉贼献一策！",
	["jujian"] = "举荐",
	[":jujian"] = "副将技，结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。 ",
	["$jujian1"] = "卧龙之才，远胜于我。",
	["$jujian2"] = "天下大任，望君莫辞！",
	["chenqun"] = "陈群",
	["~chenqun"] = "吾身虽陨，典律昭昭",
	["#chenqun"] = "万世臣表",
	["dingpin"] = "定品",
	[":dingpin"] = "当你受到伤害后，你可以令一名角色判定，若为黑，其摸等同于其已损失体力值张数的牌；若为红，你将武将牌叠置。",
	["$dingpin1"] = "取才赋职，论能行赏。",
	["$dingpin2"] = "定品寻良骥，中正探人杰。",
	["faen"] = "法恩",
	[":faen"] = "每当一名角色的武将牌叠置或横置时，你可以令其摸一张牌。然后若叠置或横置的角色是你，你可以令一名其他角色摸一张牌。 ",
	["$faen1"] = "礼法容情，皇恩浩荡。",
	["$faen2"] = "法理有度，恩威并施。",
	["mizhu"] = "糜竺",
	["~mizhu"] = "劣抵备主，我之罪也~",
	["#mizhu"] = "挥金追义",
	["jugu"] = "巨贾",
	[":jugu"] = "你的回合开始时，你可以摸一张牌，然后你可以将一张牌置于牌堆顶。",
	["$jugu1"] = "钱~要多少有多少！",
	["$jugu2"] = "君子爱财，取之有道~",
	["ziyuan"] = "资援",
	[":ziyuan"] = "出牌阶段限一次，你可以令一名体力值为1的角色回复一点体力，或者令一名手牌数不大于1的角色摸一张牌。<br /><font color=\"pink\">注：如果你指定的角色两个条件都符合，那么即回复一点体力也摸一张牌。</font>",
	["$ziyuan1"] = "区区薄礼，万望使君笑纳~",
	["$ziyuan2"] = "雪中送炭，以解君愁。",
	["liuxie"] = "刘协",
	["#liuxie"] = "受困天子",
	["~liuxie"] = "为什么不把复兴汉室的权力交给我？",
	["mizhao"] = "密诏",
	[":mizhao"] = "出牌阶段限一次，你可以将所有手牌（至少一张）交给一名其他角色：若如此做，你令该角色与另一名由你指定的有手牌的角色拼点：若一名角色赢，视为该角色对没赢的角色使用一张【杀】。",
	["$mizhao1"] = "此诏事关重大，切记小心行事。",
	["$mizhao2"] = "爱卿世受皇恩，堪此重任。",
	["tianming"] = "天命",
	[":tianming"] = "每当你被指定为【杀】的目标时，你可以弃置两张牌，然后摸两张牌。若全场唯一的体力值最多的角色不是你，该角色也可以弃置两张牌，然后摸两张牌。",
	["$tianming1"] = "皇汉国祚，千年不息。",
	["$tianming2"] = "朕乃大汉皇帝，天命之子。",
	["buzhi"] = "步骘",
	["~buzhi"] = "交州已定，主公尽可放心。",
	["#buzhi"] = "积跬靖边",
	["hongde"] = "弘德",
	[":hongde"] = "当你获得或失去至少两张牌后，你可以令一名其他角色摸一张牌。每名角色的回合限四次。",
	["$hongde1"] = "德无单行，福必双至",
	["$hongde2"] = "江南重义，东吴尚德。",
	["dingpan"] = "定判",
	[":dingpan"] = "出牌阶段限X次（X为大势力角色数且至少为1），你可以令一名装备区里有牌的角色摸一张牌，然后其选择一项：1.令你弃置其装备区里的一张牌；2.获得其装备区里的所有牌，若如此做，你对其造成1点伤害。",
	["$dingpan1"] = "从孙者生，从刘者死！",
	["$dingpan2"] = "多行不义必自",
	["litong"] = "李通",
	["~litong"] = "战死沙场，快哉",
	["#litong"] = "万亿吾独往",
	["tuifeng"] = "推锋",
	[":tuifeng"] = "当你受到1点伤害后，你可以将一张牌置于武将牌上，称为“锋”；准备阶段开始时，若你的武将牌上有“锋”，你移去所有“锋”，摸2X张牌，若如此做，你于此回合的出牌阶段内可以多使用X张【杀】（X为你此次移去的“锋”数）。",
	["$tuifeng1"] = "摧锋陷阵，以杀贼首。",
	["$tuifeng2"] = "敌锋之锐，我已尽知。",
	["liru"] = "李儒",
	["~liru"] = "如遇明主，大业必成！",
	["#liru"] = "魔仕",
	["juece"] = "绝策",
	[":juece"] = "结束阶段开始时，你可以对一名没有手牌的角色造成1点伤害。",
	["@juece"] = "你可以发动“绝策”<br/> <b>操作提示</b>: 选择一名没有手牌的角色→点击确定<br/>",
	["$juece1"] = "哼，你走投无路了。",
	["$juece2"] = "无用之人，死！",
	["mieji"] = "灭计",
	[":mieji"] = "出牌阶段限一次，你可以将一张黑色锦囊牌置于牌堆顶并选择一名有手牌的其他角色，该角色弃置一张锦囊牌，否则弃置两张非锦囊牌。",
	["$mieji1"] = "宁错杀，毋放过！",
	["$mieji2"] = "你能逃得出我的手掌心吗？",
	["fencheng"] = "焚城",
	[":fencheng"] = "限定技，出牌阶段，你可以令所有其他角色选择一项：1. 弃置至少X张牌（X为上一名进行选择的角色以此法弃置的牌数+1）；2. 受到你造成的2点火焰伤害。",
	["$fencheng1"] = "我得不到的，你们也别想得到！",
	["$fencheng2"] = "让这一切都灰飞烟灭吧！哼哼哼……",
	["yufan"] = "虞翻",
	["#yufan"] = "狂直之士",
	["~yufan"] = "我枉称东方朔再世……",
	["zongxuan"] = "纵玄",
	[":zongxuan"] = "当你的牌因弃置而置入弃牌堆后，你可以将其中至少一张牌置于牌堆顶。",
	["$zongxuan1"] = "依易设象，以占吉凶。",
	["$zongxuan2"] = "世间万物皆有定数。",
	["zhiyan"] = "直言",
	[":zhiyan"] = "结束阶段开始时，你可以令一名角色摸一张牌并展示之，若此牌为装备牌，该角色使用之，然后其回复1点体力。",
	["$zhiyan1"] = "志节分明，折而不屈。",
	["$zhiyan2"] = "直言劝谏，不惧祸否。",
	["xizhicai"] = "戏志才",
	["~xizhicai"] = "为何…不再给我…一点点时间…",
	["#xizhicai"] = "负俗的天才",
	["zaoshi"] = "早逝",
	[":zaoshi"] = "锁定技，你视为拥有技能“天妒”，若你已有技能“天妒”，你将技能改为如下效果：当你的判定牌生效后，你可以获得之，然后你可以将其交给一名其他角色。",
	["$zaoshi1"] = "天意，不可逆。",
	["$zaoshi2"] = "既是如此。。。",
	["tiandu_xizhicai"] = "天妒",
	[":tiandu_xizhicai"] = "当你的判定牌生效后，你可以获得之，然后你可以将其交给一名其他角色。",
	["xianfu"] = "先辅",
	[":xianfu"] = "锁定技，你亮出该武将牌时，你须选择一名其他角色，其成为“先辅”目标：当其受到伤害后，你受到等量的伤害；当其回复体力后，你回复等量的体力。",
	["$xianfu1"] = "辅佐明君，从一而终！",
	["$xianfu2"] = "吾于此生，竭尽所能。",
	["$xianfu3"] = "春蚕至死，蜡炬成灰！",
	["$xianfu4"] = "愿为主公，尽我所能。",
	["$xianfu5"] = "赠人玫瑰，手有余香。",
	["$xianfu6"] = "主公之幸，我之幸也。",
	["chouce"] = "筹策",
	[":chouce"] = "当你受到1点伤害后，你可以判定，若结果为：红色，令一名角色摸X张牌（若其为“先辅”选择的角色，X为2，否则为1）；黑色，弃置一名角色区域里的一张牌。",
	["$chouce1"] = "一筹一划，一策一略。",
	["$chouce2"] = "主公之忧，吾之所思也。",
	["lord_sunquan"] = "孙权-君",
	["~lord_sunquan"] = "父兄大绩，权实憾矣！",
	["#lord_sunquan"] = "吴王光耀",
	["shenduan"] = "慎断",
	[":shenduan"] = "出牌阶段，你可以将至多x张牌（x为已亮吴势力角色数且至少为2）以任意顺序至于牌堆顶，然后从牌堆底摸等量的牌。<br /><font color=\"pink\">注：其他角色能看到你置于牌堆顶的牌。</font>",
	["$shenduan1"] = "不急，吾等必一击制敌",
	["$shenduan2"] = "纵横捭阖，自有制衡之道",
	["zaoli"] = "早立",
	[":zaoli"] = "你明置武将牌后，你可以摸两张牌，回复一点体力并重置武将牌。",
	["$zaoli1"] = "淡定，淡定。",
	["$zaoli2"] = "带他出动，再做契议。",
	["shouguan"] = "授官",
	[":shouguan"] = "锁定技，你的回合结束后，或者“大都督”死亡后，若场上没有“大都督”且有其他存活的吴势力角色，你须指定一名其他吴势力角色成为“大都督”。“大都督”每有一点已损失体力值，视为吴势力角色数+1，“大都督”使用锦囊牌时，其可以令你摸一张牌。",
	["$shouguan1"] = "不愧是朕的左臂右膀",
	["$shouguan2"] = "得此良将，甚慰朕心",
	["liyan"] = "李严",
	["~liyan"] = "孔明这一走，我算是没指望了......",
	["#liyan"] = "矜风流务",
	["duliang"] = "督粮",
	[":duliang"] = "阵法技，与你处于同一队列的角色成为【兵粮寸断】或者【过河拆桥】的目标时，你可以取消该目标。你出牌阶段的出杀次数+x（x为与你处于同一队列的其他角色数）。<br /><font color=\"pink\">注：如果队列只有你一个人，该技能也对你也生效。</font>",
	["$duliang1"] = "粮草已到，请将军验看。",
	["$duliang2"] = "告诉丞相，山路难走！请宽限几天。",
	["fulin"] = "腹鳞",
	[":fulin"] = "一名角色第一次濒死时，你可以摸两张牌；一名蜀势力的其他角色死亡时，你增加一点手牌上限。<br /><font color=\"pink\">注：蜀势力不包括野心家。</font>",
	["$fulin1"] = "丞相丞相！你没看见我吗？",
	["$fulin2"] = "我乃托孤重臣，却在这搞什么粮草！",
	["zhugejin"] = "诸葛瑾",
	["~zhugejin"] = "君臣不相负，来世复君臣",
	["#zhugejin"] = "宛陵侯",
	["hongyuan"] = "弘援",
	[":hongyuan"] = "摸牌阶段，你可以少摸两张牌，然后选择一项：令所有与你势力相同的角色各摸一张牌，或者令所有与你势力不同的角色（包括暗将）各弃置一张牌。",
	["$hongyuan1"] = "自舍其身，施于天下。",
	["$hongyuan2"] = "诸将莫慌，粮草已到。",
	["mingzhe"] = "明哲",
	[":mingzhe"] = "当你于回合外因使用、打出或弃置而失去红色牌时，你可以摸等量的牌。",
	["$mingzhe1"] = "塞翁失马，焉知非福",
	["$mingzhe2"] = "明以洞察，哲以保身。",
	["huanshi"] = "缓释",
	[":huanshi"] = "当一名与你势力相同的角色的判定牌生效前，你可以观看牌堆顶的两张牌，你可以打出其中一张牌代替该判定牌。",
	["$huanshi1"] = "缓乐之危急，释兵之困顿。",
	["$huanshi2"] = "尽死生之力，保友邦之安。",
	["zhonghui"] = "钟会",
	["~zhonghui"] = "伯约，让你失望了。",
	["#zhonghui"] = "谋谟之勋",
	["zili"] = "自立",
	[":zili"] = "主将技，锁定技，限定技，你的回合结束后，你摸三张牌并回复一点体力，然后移除副将牌，将势力改为“野心家”并获得技能“劝降”。<br /><font color=\"pink\">劝降：当你的【杀】对一名其他角色造成伤害时，你令对方选择一项：交给你一张牌，或移除其副将牌并置于你的副将区。若你因此获得副将，你防止你造成的伤害，失去技能“大志”，并将此技能的第二个选项改为“失去一点体力”。</font>",
	["$zili1"] = "欲取天下，当在此时！",
	["$zili2"] = "时机已到，今日起兵！",
	["quanxiang"] = "劝降",
	[":quanxiang"] = "当你的【杀】对一名其他角色造成伤害时，若其已明置副将，你可以令对方选择一项：交给你一张装备牌，或移除其副将牌并置于你的副将区。若你因此获得副将，你防止你造成的伤害，失去技能“大志”，并将此技能的第二个选项改为“失去一点体力”。",
	["dazhi"] = "大志",
	[":dazhi"] = "主将技，锁定技，若你的武将处于明置状态，你的手牌上限为场上存活角色数，你摸牌阶段摸牌数+x,x为你已损失体力值。",
	["quanji"] = "权计",
	[":quanji"] = "副将技，此武将牌上单独的阴阳鱼个数-1，当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”；你的手牌上限+X（X为“权”数）。",
	["paiyi"] = "排异",
	[":paiyi"] = "副将技，此武将牌上单独的阴阳鱼个数-1；出牌阶段限一次，你可以移去一张“权”并选择一名角色，令其摸两张牌，然后若其手牌多于你，你对其造成1点伤害。",
	["$quanji1"] = "这仇，我记下了。",
	["$quanji2"] = "先让你得意几天。",
	["$paiyi1"] = "此地，容不下你！",
	["$paiyi2"] = "妨碍我的人，都得死！",
	["chengyu"] = "程昱",
	["#chengyu"] = "泰山捧日",
	["~chengyu"] = "此诚报效国家之时，吾却休矣……" ,
	["shefu"] = "设伏",
	[":shefu"] = "出牌阶段限x次（x为你的已损失体力值且最少为1），你可以将一张手牌背面朝上置于一名其他角色的武将牌上（每种名称的牌只限一次，且不得是装备牌），称为“伏”。当一名角色使用或打出牌时，若其的“伏”里有相同的牌名，你弃置此“伏”并对其造成一点伤害，然后若该牌为非延时锦囊牌（无懈可击除外），该牌无效。你的回合开始时，若场上有“伏”在，你收回所有的“伏”。当你受到伤害后，若有造成伤害的牌，你重置该牌名称的限制次数。",
	["$shefu1"] = "圈套已设，埋伏已完，只等敌军进来。",
	["$shefu2"] = "如此天网，量你插翅也难逃",
	["benyu"] = "贲育",
	[":benyu"] = "当你受到伤害后，若伤害来源存活且你的手牌数：小于X，你可以将手牌补至X（至多为5）张；大于X，你可以弃置至少X+1张手牌，对伤害来源造成1点伤害。（X为伤害来源的手牌数）",
	["$benyu1"] = "天下大乱，群雄并起，必有命事。",
	["$benyu2"] = "曹公智略乃上天所授",
	["zumao"] = "祖茂",
	["~zumao"] = "孙将军，已经安全了吧。" ,
	["#zumao"] = "碧血染赤帻",
	["yinbing"] = "引兵",
	[":yinbing"] = "弃牌阶段结束时，你可以指定至多x名角色（x为你已损失体力值），你分别弃置指定角色的一张牌。",
	["$yinbing1"] = "将军走此小道，追兵交我应付！",
	["$yinbing2"] = "追兵凶猛，末将断后！",
	["zhoucang"] = "周仓",
	["~zhoucang"] = "为将军操刀牵马，此生无憾",
	["#zhoucang"] = "披肝沥胆",
	["zhongyong"] = "忠勇",
	[":zhongyong"] = "当你使用的【杀】结算结束后，你可以将此【杀】或目标角色使用的所有【闪】交给一名不为此【杀】目标的其他角色，以此法获得红色牌的角色可以对你攻击范围内的一名角色使用一张【杀】（无距离限制）。",
	["#zhongyong"] = "忠勇",
	["$zhongyong1"] = "驱刀飞血，直取寇首",
	["$zhongyong2"] = "为将军提刀携马，万死不辞",
	["caimao"] = "蔡瑁",
	["#caimao"] = "荆州水师",
	["shuishi"] = "水师",
	[":shuishi"] = "阵法技，若你是被围攻角色，围攻角色对你使用【杀】或【水淹七军】时，你可以弃置一张手牌令此牌对你无效；若你是围攻角色，你对被围攻角色使用【杀】或【水淹七军】造成伤害时，你可以令此伤害+1。",
	["duozhu"] = "夺主",
	[":duozhu"] = "锁定技，当一名其他角色阵亡时，你将其装备区内所有你相应位置没有的装备置于你的装备区。<br /><font color=\"pink\">注：此技能优先级高于行殇。</font>",
	["$duozhu1"] = "缺失",
	["hejin"] = "何进",
	["~hejin"] = "不能遗祸世间",
	["#hejin"] = "色厉内荏",
	["mouzhu"] = "谋诛",
	[":mouzhu"] = "锁定技，你杀死角色后的结算改为摸三张牌。",
	["$mouzhu1"] = "汝等罪大恶极，快快伏法",
	["$mouzhu2"] = "宦官专权，今必诛之",
	["yanhuo"] = "延祸",
	[":yanhuo"] = "你的回合结束后，可以指定一名角色，其摸x张牌并弃置x张牌（x为你已损失体力值）。",
	["$yanhuo1"] = "你很快就笑不出来了",
	["$yanhuo2"] = "乱世，才刚刚开始",
	["miheng"] = "祢衡",
	["#miheng"] = "鸷鹗啄孤凤",
	["kuangcai"] = "狂才",
	[":kuangcai"] = "出牌阶段开始时，你可以令此回合获得如下效果：当你使用牌时，摸一张牌，然后若本回合你使用牌的次数大于x（x为你的体力上限），你结束出牌阶段。",
	["shejian"] = "舌剑",
	[":shejian"] = "出牌阶段限一次，你可以指定至多x名其他角色（x为当前大势力角色数），你与所有指定角色同时展示一张手牌，然后你弃置所有与你展示的牌颜色相同的牌。",
	["masu"] = "马谡",
	["~masu"] = "败军之罪，万死难赎。",
	["#masu"] = "街亭之殇",
	["sanyao"] = "散谣",
	[":sanyao"] = "一名角色的弃牌阶段开始时，若其需要弃置手牌，你可以展示其一张牌，然后你选择一项：令其于此弃牌阶段内该牌不计入手牌数；或者令其于此弃牌阶段内不能弃置此牌。",
	["$sanyao1"] = "散谣惑敌不攻自破。",
	["$sanyao2"] = "三人成虎事多有",
	["huilei"] = "挥泪",
	[":huilei"] = "锁定技，杀死你的角色获得技能“泪目”（锁定技，当你的体力值不小于3时，你不能弃置黑色手牌；当你的体力值为2时，你不能弃置黑桃手牌。）。",
	["$huilei1"] = "谡，愿以死安大局！",
	["$huilei2"] = "丞相视某如子，某以丞相为父。",
	["leimu"] = "泪目",
	[":leimu"] = "锁定技，当你的体力值不小于3时，你不能弃置黑色手牌；当你的体力值为2时，你不能弃置黑桃手牌。",
	["lord_caocao"] = "曹操-君",
	["~lord_caocao"] = "华佗何在？？？",
	["#lord_caocao"] = "魏武东临",
	["mouduan"] = "谋断",
	[":mouduan"] = "当你受到伤害后，你可以令一名五良将视为对伤害来源使用一张【杀】，或令一名五谋臣执行一个额外的出牌阶段（若重叠则只看主将）。",
	["dashi"] = "大势",
	[":dashi"] = "锁定技，每有一个五良将存在，你的出牌阶段出【杀】次数+1，每有一个五谋臣存在，你的手牌上限+1。",
	["xietian"] = "挟天",
	[":xietian"] = "你可以将红桃2的牌当作【挟天子以令诸侯】使用。",
	["yitian1"] = "倚天",
	[":yitian1"] = "锁定技，你的回合开始时，你装备【倚天剑】（替换原有装备）。",
	["maliang"] = "马良",
	["~maliang"] = "皇叔为何不听我之言！",
	["#maliang"] = "白眉智士",
	["yingyuan"] = "应援",
	[":yingyuan"] = "每回合限x次（x为场上势力数），当你使用基本牌或非延时锦囊牌结算完毕后，你可以将之交给一名其他角色（相同牌名的牌每回合限一次）。",
	["$yingyuan1"] = "慢着，让我来！",
	["$yingyuan2"] = "弃暗投明，光耀门楣！",
	["zishu"] = "自书",
	[":zishu"] = "你的回合结束后，你可以观看牌堆顶的x张牌（x为你的手牌数且不得超过3），然后你可以选择获得其中任意张牌，并将等量的其他手牌置于牌堆顶。",
	["zishu1"] = "自书",
	["zishu2"] = "自书",
	["$zishu1"] = "暴戾之气，伤人害己。",
	["$zishu2"] = "休要再提战事。",
	["xuezong"] = "薛综",
	["~xuezong"] = "尔等，竟做如此有辱斯文之事。。",
	["#xuezong"] = "东宫弦诵",
	["funan"] = "复难",
	[":funan"] = "其他角色使用或打出牌响应你使用的牌时，你可令其获得你使用的牌（其本回合不能使用或打出这张牌），然后你获得其使用或打出的牌。",
	["$funan1"] = "礼尚往来，乃君子风范。",
	["$funan2"] = "以子之矛，攻子之盾。",
	["jiexun"] = "诫训",
	[":jiexun"] = "结束阶段，你可令一名其他角色摸等同于场上方块牌数的牌，然后弃置X张牌（X为此前该技能发动过的次数）。若其因此法弃置了所有牌，则你失去“诫训”，然后你发动“复难”时，无须令其获得你使用的牌。",
	["$jiexun1"] = "帝王应以社稷为重，以大官为主。",
	["$jiexun2"] = "吾冒昧进谏，只求陛下思虑。",
	["xushi"] = "徐氏",
	["~xushi"] = "莫问前程凶吉，但求落幕无悔。",
	["#xushi"] = "节义双全",
	["wengua"] = "问卦",
	["$wengua1"] = "卦不能佳，可须异日。",
	["$wengua2"] = "阴阳相生相克，万事周而复始。",
	[":wengua"] = "一名角色的回合结束后，若其已受伤，你可以摸一张牌，然后将一张牌置于牌堆顶或排队底。",
	["fuzhu"] = "伏诛",
	[":fuzhu"] = "出牌阶段，你可以指定一名攻击范围内的男性角色并依次展示牌堆底的x张牌（x为场上已受伤的角色数且最多不能超过你的体力上限），若展示的牌为【杀】或黑色锦囊牌（必须为有明确的指定目标且目标为非自己的锦囊牌），你视为对其使用。执行完毕后，你结束出牌阶段。<hr /><font color=\"pink\">以下几个锦囊牌无效：<br />【借刀杀人】、【敕令】、【挟天子以令诸侯】、【火烧连营】、【勠力同心】、【闪电】</font>",
	["$fuzhu1"] = "我连做梦都在等这一天呢。",
	["$fuzhu2"] = "既然来了，就别想走了。",
	["#wangji"] = "经行合一",
	["wangji"] = "王基",
	["~wangji"] = "天下之事，必归大魏，可恨未能得见啊……",
	["qizhi"] = "奇制",
	[":qizhi"] = "当你于回合内使用基本牌或锦囊牌指定目标后，你可以选择一名不是此牌目标的角色，弃置其一张牌，然后其摸一张牌。",
	["$qizhi1"] = "声东击西，敌寇，一网成擒！",
	["$qizhi2"] = "吴懿不在此地，已遣别部出发。",
	["jinqu"] = "进趋",
	["#jinqu_damaged"] = "进趋",
	[":jinqu"] = "结束阶段开始时，你可以摸两张牌，然后将手牌弃置至X张（X为此回合内你发动“奇制”的次数）。当你受到伤害后，你可以令所有与你势力相同的角色依次摸一张牌并弃置一张牌。",
	["$jinqu1"] = "建上昶水城，以逼夏口！",
	["$jinqu2"] = "通川聚粮，伐吴之业，当步步为营。",
	["caojie"] = "曹节",
	["#caojie"] = "献穆皇后",
	["~caojie"] = "黄天，定不祚尔。。。",
	["shouxi"] = "守玺",
	[":shouxi"] = "当你成为【杀】的目标时，你可以翻开牌堆顶的一张牌，若此牌不为装备牌且你的武将牌上没有与此牌同名的牌，你将此牌置于武将牌上且该【杀】对你无效。",
	["$shouxi1"] = "天子之位，乃归刘汉！",
	["$shouxi2"] = "吾父功盖寰区，然且不敢篡窃神器。",
	["huimin"] = "惠民",
	[":huimin"] = "结束阶段，你可以摸X张牌（X为手牌数小于其体力值的角色数），然后展示等量的手牌，从你选择的一名角色开始依次获得其中一张。",
	["$huimin1"] = "悬壶济世，施医救民。",
	["$huimin2"] = "心系百姓，惠布山阳。",
	["#chengong"] = "刚直壮烈",
	["chengong"] = "陈宫",
	["~chengong"] = "请出就戮！",
	["mingce"] = "明策",
	[":mingce"] = "出牌阶段限一次，你可以将一张装备牌或【杀】交给一名其他角色，若如此做，该角色可以视为对其攻击范围内你选择的一名角色使用【杀】，否则其摸一张牌。",
	["$mingce1"] = "如此，霸业可图也！",
	["$mingce2"] = "如此，一击可擒也！",
	["zhichi"] = "智迟",
	[":zhichi"] = "锁定技，当你于回合外受到伤害后，【杀】和普通锦囊牌对你无效，直到回合结束。",
	["$zhichi1"] = "如今之计，唯有退守，再做决断！",
	["$zhichi2"] = "若吾早知如此。",
	["#caochong"] = "仁爱的神童",
	["caochong"] = "曹冲",
	["~caochong"] = "子桓哥哥……",
	["chengxiang"] = "称象",
	[":chengxiang"] = "当你受到伤害后，你可以亮出牌堆顶的四张牌，然后获得其中至少一张点数之和不大于13的牌，并将其余的牌置入弃牌堆。",
	["$chengxiang1"] = "依我看，小事一桩。",
	["$chengxiang2"] = "孰重孰轻，一称便知。",
	["renxin"] = "仁心",
	[":renxin"] = "当其他角色受到伤害时，若其体力值为1，你可以弃置一张装备牌，叠置，然后防止此伤害。",
	["$renxin1"] = "仁者爱人，人恒爱之。",
	["$renxin2"] = "有我在，别怕。",
	["xiahoushi"] = "夏侯氏",
	["~xiahoushi"] = "原有来生，不负亲人。。。",
	["#xiahoushi"] = "采缘撷睦",
	["qiaoshi"] = "樵拾",
	[":qiaoshi"] = "其他角色的结束阶段开始时，若你的手牌数与其相等，你可以与其各摸一张牌。",
	["$qiaoshi1"] = "樵前情窦开，君后寻迹来。",
	["$qiaoshi1"] = "樵心遇郎君，妾心连衣身。",
	["yanyu"] = "燕语",
	["yanyuCard"] = "燕语",
	[":yanyu"] = "出牌阶段，你可以弃置一张【杀】并展示牌堆顶的x张牌（x为你的体力上限），然后你选择获得其中一种花色的任意张牌。出牌阶段结束时，若你于此阶段内发动过两次该技能，你可以选择一名男性角色，其摸两张牌。",
	["$yanyu1"] = "伴君一生，不寂寞。",
	["$yanyu2"] = "感君一回顾，思君朝与暮。",
	["simalang"] = "司马朗",
	["~simalang"] = "微功未效，有辱国恩...",
	["#simalang"] = "再世神农",
	["junbing"] = "郡兵",
	[":junbing"] = "一名角色的结束阶段开始时，若其手牌数不大于1，你令其选择是否摸一张牌，若其选择是，其将所有手牌交给你，若如此做，你将等量的牌交给该角色。",
	["$junbing1"] = "郡国当有搜狩习战之备。",
	["$junbing2"] = "男儿慷慨，军中豪迈。",
	["quji"] = "去疾",
	[":quji"] = "当你受到伤害后，你可以弃置x张与造成伤害的牌花色相同的牌并指定一名已受伤的其他角色（x为你的体力值），其恢复一点体力。",
	["$quji1"] = "愿为将士，略尽绵薄。",
	["$quji2"] = "若不去兵之疾，则将何以守国？",
	["panzhangmazhong"] = "潘璋＆马忠",
	["#panzhangmazhong"] = "擒龙伏虎",
	["~panzhangmazhong"] = "怎么可能，我明明亲手将你……",
	["&panzhangmazhong"] = "潘璋马忠",
	["duodao"] = "夺刀",
	[":duodao"] = "当你受到【杀】造成的伤害后，你可以弃置一张牌，获得伤害来源装备区里的武器牌。",
	["@duodao-get"] = "你可以弃置一张牌发动“夺刀”",
	["$duodao1"] = "夺敌兵刃，如断其臂！",
	["$duodao2"] = "这刀岂是你配用的？",
	["anjian"] = "暗箭",
	[":anjian"] = "锁定技，当你使用【杀】对目标角色造成伤害时，若你不在其攻击范围内，你令此伤害+1。",
	["#anjianBuff"] = "%from 的“<font color=\"yellow\"><b>暗箭</b></font>”效果被触发，伤害从 %arg 点增加至 %arg2 点",
	["$anjian1"] = "哼，你满身都是破绽！",
	["$anjian2"] = "击其懈怠，攻其不备！",
	["zhugeke"] = "诸葛恪",
	["#zhugeke"] = "雄才大略",
	["~zhugeke"] = "",
	["aocai"] = "傲才",
	[":aocai"] = "当你于回合外需要使用／打出基本牌时，你可以观看牌堆顶的两张牌，若如此做，你可以使用／打出其中的一张牌。",
	["$aocai1"] = "",
	["$aocai2"] = "",
	["duwu"] = "黩武",
	[":duwu"] = " 出牌阶段限一次，你可以选择你攻击范围内的一名其他角色并弃置X张牌（X为该角色的手牌数），然后对其造成1点伤害。",
	["$duwu1"] = "",
	["$duwu2"] = "",
	["luji"] = "陆绩",
	["#luji"] = "怀橘遗亲",
	["~luji"] = "恨不能见，车同轨，书同文……",
	["huaijv"] = "怀橘",
	[":huaijv"] = "锁定技，你的回合开始时，若你的“橘”标记个数不超过你的体力上限，你获得一个“橘”标记。（有“橘”标记的角色获得以下效果：受到伤害时，伤害数最多为1点；受到伤害后，移去一枚“橘”标记；摸牌阶段开始时，若手牌数小于体力值，摸牌数+1；濒死时，失去所有“橘”标记并将体力值回复至一点。）",
	["$huaijv1"] = "情深舐犊，怀擢藏橘。",
	["$huaijv2"] = "袖中怀绿桔，遗母报乳哺。",
	["yili"] = "遗礼",
	[":yili"] = "出牌阶段，你可以将你任意枚“橘”标记分配给等量其他没有“橘”标记的角色。",
	["$yili1"] = "行遗礼之举，于不敬王者",
	["$yili2"] = "遗失礼仪，则俱非议。",
	["zhenglun"] = "整论",
	[":zhenglun"] = "出牌阶段限两次，你可以失去一点体力并获得一个“橘”标记。若此时你的“橘”标记个数不超过你的体力上限，你摸一张牌。",
	["$zhenglun1"] = "整论四海未泰，修文德以平。",
	["$zhenglun2"] = "今论者不务道德怀取之术，而惟尚武，窃所未安。",
	["zhugedan"] = "诸葛诞",
	["#zhugedan"] = "严毅威重",
	["~zhugedan"] = "诸葛一氏定会为我复仇！",
	["gongao"] = "功獒",
	[":gongao"] = "锁定技，你的出牌阶段开始时，你需要将一半的手牌（向下取整）置于武将牌上，称为“功”。出牌阶段结束后，若你的手牌数大于1，你执行一个额外的出牌阶段。你的回合结束后，你获得武将牌上所有的“功”。",
	["$gongao1"] = "恪尽职守，忠心事主。",
	["$gongao2"] = "攻城拔寨，建功立业。",
	["weizhong"] = "威重",
	[":weizhong"] = "锁定技，一名角色受到伤害后，若该角色是你或者与你势力相同，且你的手牌数小于你的体力上限，你摸一张牌。",
	["$weizhong"] = "定当夷司马氏三族！",
	["yanjun"] = "严畯",
	["#yanjun"] = "贤逊曼才",
	["~yanjun"] = "",
	["guanchao"] = "观潮",
	[":guanchao"] = "出牌阶段开始时，你可以进行判定，若本回合你以此法判定的所有判定牌点数呈严格递增或严格递减，你重复此流程，否则你弃置该判定牌并获得所有其他因此法判定的判定牌。你于出牌阶段结束后弃置所有因此法获得的牌。",
	["xunxian"] = "逊贤",
	[":xunxian"] = "当你使用牌时，你可以将一张相同花色的牌交给一名其他角色。",
	--加强包--
	["lizhan"] = "励战",
	[":lizhan"] = "副将技，此武将牌上单独的阴阳鱼个数-1，回合结束时，你可以令任意名已受伤的角色摸一张牌。",
	["$lizhan1"] = "行伍严整，百战不殆。",
	["$lizhan2"] = "任你强横霸道，我自岿然不动。",
	["lizhan-invoke"] = "你可以指定任意名已受伤的角色各摸一张牌",
	["zhaxiang"] = "诈降",
	[":zhaxiang"] = "弃牌阶段开始时，若你的手牌数大于你的体力值，你可以将x张手牌交给一名其他角色（x为你的手牌数减去你的体力值），然后若x不小于2，你对其造成一点伤害。",
	["@zhaxiang-card"] = "你可以发动诈降",
	["Ejianxiong"] = "奸雄",
	[":Ejianxiong"] = "每当你受到伤害后，你可以选择一项：获得对你造成伤害的牌，或摸一张牌。",
	["$Ejianxiong1"] = "燕雀安知鸿鹄之志。",
	["$Ejianxiong2"] = "夫英雄者，胸怀大志，腹有良谋。",
	["draw1"] = "摸一张牌",
	["obtain"] = "获得造成伤害的牌",
	["Ekuanggu"] = "狂骨",
	[":Ekuanggu"] = "每当你对距离1以内的一名角色造成1点伤害后，你可以回复1点体力，或者摸一张牌。",
	["$Ekuanggu1"] = "哼！也不看看我是何人。",
	["$Ekuanggu2"] = "嗯哈哈哈哈哈哈，赢你，还不容易！",
	["Eduoshi"] = "度势",
	["duoshi_trigger"] = "度势",
	[":Eduoshi"] = "主将技，你可以将一张牌当做【以逸待劳】使用（出牌阶段每种花色限一次）。你的回合结束后，若你于此回合使用【以逸待劳】的次数不小于3，你将手牌补至体力上限（最多5张）。",
	["lianying"] = "连营",
	[":lianying"] = "副将技，每当你失去最后的手牌后，你可以摸一张牌。",
	["$lianying1"] = "旧的不去，新的不来",
	["$lianying2"] = "牌不是万能的，但是没牌是万万不能的。",
	["danqi"] = "单骑",
	[":danqi"] = "副将技，此武将牌上单独的阴阳鱼个数-1，当你的红色牌造成伤害时，你可以弃置对方的一张牌，然后若你弃置的牌与你使用的该牌花色相同，你摸一张牌。",
	["$danqi1"] = "单骑护嫂千里，只为桃园之义。",
	["$danqi2"] = "独身远涉，赤心归国。",
	["longhun"] = "龙魂",
	[":longhun"] = "主将技，此武将牌上单独的阴阳鱼个数-1，你于回合外使用或打出手牌时，你可以展示牌堆顶的一张牌，若与你使用或打出的牌颜色相同，你获得之。",
	["$longhun1"] = "常山赵子龙在此！",
	["$longhun2"] = "能屈能伸，才是大丈夫。",
	["tishen"] = "替身",
	[":tishen"] = "副将技，此武将牌上单独的阴阳鱼个数-1，一名角色对你使用【杀】结算完毕后，若该【杀】未造成伤害，你获得该【杀】。",
	["$tishen1"] = "谁还敢过来一战！",
	["$tishen2"] = "欺我无谋？定要尔等血偿！",
	["pojun"] = "破军",
	[":pojun"] = "当你使用【杀】时，你可以弃置目标角色的一张牌，若该牌为红色，其摸一张牌。",
	["$pojun1"] = "大军在此，尔等休想前进一步！",
	["$pojun2"] = "敬请养精蓄锐。",
	["hubu"] = "虎步",
	[":hubu"] = "当你受到伤害后，你可以展示牌堆顶的x张牌，然后你可以使用其中任意张【杀】,并将其余牌弃置。（x为你已损失体力值）",
	["$hubu1"] = "神速进击，攻敌不备！",
	["$hubu2"] = "你已经死啦！",
	["qingjian"] = "清俭",
	[":qingjian"] = "每回合限一次，当你获得牌时，你可以将其中任意张牌交给其他角色。",
	["$qingjian1"] = "钱财，乃身外之物！",
	["$qingjian2"] = "福生于清俭，德生于卑退。",
	["renwang"] = "仁望",
	[":renwang"] = "你的回合结束后，若你没有“仁望”牌，你可以将一张手牌背面朝上置于武将牌上，称为“仁望”。根据武将牌上的“仁望”牌获得如下效果:【闪】，你成为【杀】的目标时，你弃置该牌且该【杀】无效且你摸一张牌；【杀】，一名角色回合结束后，若其没有手牌，你可以对其使用该牌；【桃】，一名角色濒死时，你可以弃置该牌并令其回复两点体力；【酒】，一名角色使用【杀】造成伤害时，你可以弃置此牌令伤害+1；其他牌，一名角色的回合开始时，你可以将该牌正面朝上交给其，其该回合内使用该牌时你摸一张牌。",
	--猛包--
	["meng_zhaoyun"] = "赵子龙",
	["~meng_zhaoyun"] = "你们谁，还敢在上！",
	["#meng_zhaoyun"] = "虎威将军",
	["yajiao"] = "涯角",
	[":yajiao"] = "锁定技，你的回合结束后，你获得牌堆顶x张牌中的所有的【杀】（x为存活角色数），然后若你获得的【杀】个数大于x/2，你将武将牌叠置。",
	["$yajiao1"] = "策马驱前，斩敌当先。", 
	["$yajiao2"] = "遍寻天下，但求一败。", 
	["chongzhen"] = "冲阵",
	[":chongzhen"] = "当你使用【杀】/成为【杀】的目标时，你可以弃置一张比此【杀】点数大的基本牌令此【杀】不可被闪避/对你无效。",
	["$chongzhen1"] = "进退自如，游刃有余。", 
	["$chongzhen2"] = "龙威虎胆，斩敌破阵。", 
	["meng_luxun"] = "陆伯言",
	["~meng_luxun"] = "我的未竟之业！",
	["#meng_luxun"] = "江陵侯",
	["shaoying"] = "烧营",
	[":shaoying"] = "你的回合开始时，你可以视为对一名角色使用一张【火攻】。锁定技，当你对一名角色造成火属性伤害后，你可以视为对其下家使用一张【火攻】（若其有手牌）。",
	["$shaoying1"] = "烈火声", 
	["$shaoying2"] = "烈火声", 
	["linggong"] = "领功",
	[":linggong"] = "你的回合结束后，你可以摸x张牌（x为你此回合造成火属性伤害的次数，且最多不超过3）。",
	["$linggong1"] = "谦谦君子，温润如玉。", 
	["$linggong2"] = "满招损，谦受益。", 
	["meng_dianwei"] = "古之恶来",
	[":meng_dianwei"] = "忠勇死士",
	["hengsao"] = "横扫",
	[":hengsao"] = "锁定技，若你装备了武器，你使用【杀】指定的角色数至多为x（x为你武器的攻击范围）。",
	["tiequ"] = "铁躯",
	[":tiequ"] = "出牌阶段限一次，你可以自减一点体力，然后随机装备一张牌堆中你对应装备区没有的装备。",
	["meng_dongzhuo"] = "董仲颖",
	["~meng_dongzhuo"] = "庶子！竟敢反我。。。",
	["#meng_dongzhuo"] = "西凉鬼豪",
	["huangyin"] = "荒淫",
	[":huangyin"] = "出牌阶段限一次，你可以指定一名女性角色，其需弃置一张牌，然后若此时其手牌数大于你，你回复一点体力。",
	["$huangyin1"] = "美女，美酒，美食，尽我享用。", 
	["$huangyin2"] = "嗯。。。尽享天下美味，呵呵呵呵呵呵呵。。。", 
	["weishe"] = "威慑",
	[":weishe"] = "你使用【杀】或黑色锦囊牌指定目标后，可以令其中一名角色弃置一张牌。",
	["$weishe1"] = "什么礼治纲常，我说的，就是纲常", 
	["$weishe2"] = "不施严法怎治乱民？休得啰嗦！", 
	["meng_zhouyu"] = "周公瑾",
	["#meng_zhouyu"] = "平虏伯",
	["~meng_zhouyu"] = "既生瑜，何生亮...既生瑜，何生亮！",
	["sashuang"] = "飒爽",
	[":sashuang"] = "你的回合开始时，你可以令一名与你势力相同的角色摸一张牌，然后该角色可以变更副将。",
	["$sashuang1"] = "哈哈哈哈哈...",
	["$sashuang2"] = "伯符，且看我这一手！",
	["xinji"] = "心计",
	[":xinji"] =  "出牌阶段限一次，你可以弃置一张牌并指定一名其他角色，其展示所有手牌并弃置所有等同于你弃置的牌花色相同的手牌。然后若其手牌数没有减少，此回合你与其的距离视为1。",
	["$xinji1"] = "与我为敌，就当这般生不如死！",
	["$xinji2"] = "抉择吧！在苦与痛的地狱中！",
	["meng_zhugeliang"] = "诸葛孔明",
	["#meng_zhugeliang"] = "赤壁妖术师",
	["~meng_zhugeliang"] = "今当远离，临表涕零……不知所言……",
	["qixing"] = "七星",
	[":qixing"] = "准备阶段，你可以明置此武将牌。当你明置此武将牌时，你摸七张牌并将七张手牌扣置于你的武将牌上，称为“星”。摸牌阶段结束时，你可以用任意张手牌替换等量的“星”。",
	["$qixing1"] = "祈星辰之力，佑我蜀汉！",
	["$qixing2"] = "伏望天恩，誓讨汉贼！",
	["kuangfeng"] = "狂风",
	[":kuangfeng"] = "结束阶段，你可以移去一张“星”并选择一名角色，然后直到你的下回合开始之前，当该角色受到火焰伤害时，此伤害+1。",
	["$kuangfeng1"] = "风——起——！",
	["$kuangfeng2"] = "万事俱备，只欠业火",
	["dawu"] = "大雾",
	[":dawu"] = "结束阶段，你可以移去任意张“星”并选择等量的角色，然后直到你的下回合开始之前，当这些角色受到非雷电伤害时，防止此伤害+1。",
	["$dawu1"] = "此非万全之策，唯惧天雷",
	["$dawu1"] = "此计可保你一时平安",
	["xuming"] = "续命",
	[":xuming"] = "限定技，当你濒死时，你可以弃置不超过你已损失体力值张数的“星”，若如此做，你回复等量的体力，然后失去技能“大雾”和“狂风”。",
	--测试专用--
	["gaoda"] = "高达",
	["#gaoda"] = "做测试啦",
	["zhenhan"] = "震撼",
	[":zhenhan"] = "当你受到伤害后，你可以执行一个额外的出牌阶段。",
-----msg-----
	["#yaowu"] = "%from 发动技能“耀武”，此次伤害无效。",
-----invoke-----
	--智包--
	["@cuorui"] = "请将一张牌置于牌堆顶。",
	["@zhuhai"] = "你可以对当前回合角色使用一张【杀】。",
	["@mieji-discard"] = "请弃置一张锦囊牌或两张非锦囊牌",
	["@fencheng"] = "请弃置至少 %arg 张牌，包括装备区的牌",
	["~miejiDiscard"] = "选择一张锦囊牌或两张非锦囊牌→点击确定",
	["@zongxuan"] = "请选择至少一张牌置于牌堆顶", 
	["@shenduan"] = "请将牌以任意顺序置于牌堆顶", 
	["@fuli"] = "你可以弃置一张红色牌，令此伤害-1", 
	["zhuiyi-invokex"] = "请指定一名角色(不能是杀死你的角色)，对其发动“追忆”",
	["zhuiyi-invoke"] = "请指定一名角色，对其发动“追忆”",
	["@jujian-card"] = "请指定一名角色，对其发动“举荐”",
	["dingpin-invoke"] = "请指定一名角色，对其发动“定品”",
	["faen-invoke"] = "您可以指定一名其他角色，令其摸一张牌",
	["@jugu"] = "您可以将一张牌置于牌堆顶",
	["hongde-invoke"] = "您可以指定一名觉色，令其摸一张牌",
	["zhiyan-invoke"] = "你可以发动“直言”<br/> <b>操作提示</b>: 选择一名角色→点击确定<br/>",
	["tiandu_xizhicai-invoke"] = "你可以将该牌交给一名其他角色",
	["chouce1-invoke"] = "你可以令一名角色摸一张牌（若为先辅角色，则其摸两张）",
	["chouce2-invoke"] = "你可以弃置一名其他角色区域的一张牌",
	["xianfu-invoke"] = "指定一名角色为“先辅”的目标",
	["shouguan-invoke"] = "选择一名吴势力角色令其成为大都督",
	["jueqing-invoke"] = "你可以指定一名觉色为伤害来源",
	["yanhuo-invoke"] = "你可以指定一名觉色发动“延祸”",
	["quanjiPush"] = "请将一张手牌置于武将牌上",
	["@quanxiang"] = "将一张牌交给对方，否则将副将牌移除置于对方的副将区",
	["@shuishi"] = "你可以弃置一张手牌，令此牌无效",
	["@shejian"] = "请展示一张手牌",
	["@benyu-discard"] = "你可以弃置手牌对伤害来源造成一点伤害",
	["mouduan-invoke"] = "你可以指定一名五良将或五谋臣",
	["weishe-invoke"] = "你可以指定一名目标角色，对其发动“威慑”",
	["jiexun-invoke"] = "你可以指定一名其他角色，对其发动“诫训”",
	["yingyuan-invoke"] = "你可以发动“应援”<br/> <b>操作提示</b>: 选择一名其他角色获得以下牌：<br/>%arg<br/>",
	["zishuPush"] = "请将其他手牌置于牌堆顶",
	["qizhi-choice"] = "你可以发动“奇制”<br/> <b>操作提示</b>: 选择一名不是此【%arg】目标的角色→点击确定<br/>",
	["jinqu:HandNumMax"] = "你可以发动“进趋”摸两张牌，然后将手牌弃置至 %arg 张",
	["wenguaPush"] = "请选择一张牌，将其置于牌堆顶或牌堆底",
	["#zhichi-protect"] = "智迟（令【杀】和普通锦囊牌无效）",
	["#zhichiDamaged"] = "%from 受到了伤害，本回合内【<font color=\"yellow\"><b>杀</b></font>】和普通锦囊牌都将对其无效",
	["#zhichiAvoid"] = "%from 的“%arg”被触发，【<font color=\"yellow\"><b>杀</b></font>】和普通锦囊牌对其无效",
	["huiminExchange"] = "请展示%arg张手牌",
	["huimin-choose"] = "请选择“惠民”的起始角色",
	["@chengxiang"] = "请选择至少一张点数之和<=13的牌",
	["@renxin-card"] = "你可以弃置一张装备牌发动“仁心”防止 %src 受到的伤害",
	["#renxin"] = "%from 受到的伤害由于“%arg”效果被防止",
	["@zhongyong"] = "你可以发动“忠勇”",
	["~zhongyong"] = "选择【杀】或所有【闪】→选择一名其他角色→点击确定",
	["@zhongyong-slash"] = "你可以对 %src 攻击范围内的角色使用一张【杀】",
	["@Benyu-discard"] = "你可以发动“贲育”弃置至少 %arg 张手牌对 %dest 造成1点伤害",
	["~benyu"] = "选择足量的手牌→点击确定",
	["yanyu-choose"] = "你可以选择一名男性角色，令其摸两张牌",
	["@yanyu"] = "你可以获得其中一种花色的任意张牌",
	["@zishu1"] = "你可以选择获得任意张牌",
	["@zishu1"] = "请将牌以任意顺序置于牌堆顶",
	["junbingExchange"] = "请将%arg张手牌交给%dest",
	["@@quji"] = "去疾",
	["@qujiCard"] = "你可以弃置%arg张%arg2手牌并指定一名已受伤的其他角色，对其发动“去疾”",
	["~quji"] = "指定一名已受伤的其他角色",
	["@wenji-card"] = "你可以将一张牌交给%src",
	["yinbing-invoke"] = "你可以指定至多%arg名角色，分别弃置指定角色的一张牌",
	["sashuang:changeHero"] = "你可以更换你的副将<br />从武将牌堆顶中依次翻开武将，直到遇到与你势力相同的武将，更换你的副将，将翻开的武将置于武将牌堆底",
	["sashuang-invoke"] = "你可以指定一名与你势力相同的角色，令其摸一张牌，然后其可以更换副将",
	["@@kuangfeng"] = "狂风",
	["@kuangfeng"] = "你可以弃置一张“星”并选择一名角色发动“狂风”",
	["~kuangfeng"] = "选中一张星—>选中一名角色—>点击确定",
	["@@dawu"] = "大雾",
	["@dawu"] = "你可以弃置任意张“星”并选择等量角色发动“大雾”",
	["~dawu"] = "选中任意张星—>选中等量角色—>点击确定",
	["@qixing"] = "你可以将任意手牌与等量的“星”交换",
	["qixing:qixingShow"] = "你可以明置诸葛孔明，发动“七星”。",
	["@@xuming"] = "续命",
	["@xuming"] = "你可以弃置任意张“星”（不超过你已损失体力值），然后回复等量的体力值",
	["~xuming"] = "选中任意张星—>点击确定",
	["@@aocai"] = "傲才",
	["@aocai"] = "你可以使用/打出牌堆顶的一张牌。",
	["#aocai"] = "傲才",
	["gongaoExchange"] = "你需将 %arg 张手牌置于武将牌上",
	["@xunxian-card"] = "你可以将一张 %arg 花色的手牌交给一名其他角色",
	--猛包--
	["@chongzhen1"] = "你可以弃置一张比该【杀】点数大的基本牌,令此【杀】不可被闪避",
	["@chongzhen2"] = "你可以弃置一张比该【杀】点数大的基本牌,令此【杀】对你无效",
	["shaoying-invoke"] = "你可以指定一名角色，视为对其使用一张【火攻】",
	--加强包--
	["@hubu-card"] = "你可以使用其中任意张【杀】",
	["#hubu"] = "虎步",
	["@qingjian_card"] = "你可以将获得的任意张牌交给其他角色",
	["@renwang_invoke"] = "你可以发动“仁望”，将一张牌置于武将牌上",
	["#renwang_slash"] = "仁望",
	["#renwang_jink"] = "仁望",
	["#renwang_analeptic"] = "仁望",
	["#renwang_peach"] = "仁望",
	["#renwang_other"] = "仁望",
	["renwangSlash:renwangSlash"] = "你可以对 %src 使用仁望牌【%arg】",
	["renwangPeach:renwangPeach"] = "你可以弃置仁望牌【%arg】令 %src 回复两点体力",
	["renwangAnaleptic:renwangAnaleptic"] = "你可以弃置仁望牌【%arg】令该【杀】对 %src 造成的伤害加一",
	["renwangOther:renwangOther"] = "你可以将仁望牌【%arg】交给 %src ",
-----exchange-----
	["tuifengPush"] = "您可以将一张牌当作“锋”置于武将牌上",
-----choice-----
	["draw"] = "摸两张牌",
	["recover"] = "回复一点体力",
	["reset"] = "重置武将牌",
	["dingpan_discard"] = "弃置一张装备牌",
	["dingpan_damage"] = "获得所有装备牌，然后受到一点伤害",
	["friend_draw"] = "所有与你势力相同的角色摸一张牌",
	["enemy_discard"] = "所有与你势力不同的角色弃置一张牌",
	["sanyao_benefit"] = "令对方该手牌不计入手牌数",
	["sanyao_not_benefit"] = "令对方不能弃置此牌",
	["pile_top"] = "置于牌堆顶",
	["pile_bottom"] = "置于牌堆底",
	["mingce:use"] = "对攻击范围内的一名角色使用一张【杀】",
	["mingce:draw"] = "摸一张牌",
	["chengxiang#up"] = "置入弃牌堆",
	["chengxiang#down"] = "获得",
	["yanyu#up"] = "弃置",
	["yanyu#down"] = "获得",
	["qixing#up"] = "星",
	["qixing#down"] = "手牌",
-----move-----
	["zongxuan#up"] = "弃置",
	["zongxuan#down"] = "置于牌堆顶",
	["shenduan#up"] = "弃置",
	["shenduan#down"] = "置于牌堆顶",
	["zishu1#up"] = "牌堆顶",
	["zishu1#down"] = "获取",
	["zishu2#up"] = "手牌",
	["zishu2#down"] = "置于牌堆顶",
-----bug-----
	["qiaoshuiCard"] = "巧说",
	["shenduanCard"] = "慎断",
	["#tuifeng-throw"] = "推锋",
	["xinjiCard"] = "心计",
-----pile-----
	["lead"] = "锋",
	["power"] = "权",
	["fu"] = "伏",
	["shouxiPile"] = "玺",
	["stars"] = "星",
	["gong"] = "功",
-----mark-----
	["@lead"] = "锋",
	["@yaowu"] = "耀武",
	["@zili"] = "自立",
	["@xun"] = "训",
	["@fulin"] = "腹麟",
	["@duoshiMark"] = "度势",
	["@orange"] = "橘",
	
	
	
	["#message"] = "%arg",
	["#messagefrom"] = "%from %arg",
	["#xinjimsg"] = "%from 于当前出牌阶段与%to 的距离视为1",
	["#huaijv"] = "因“橘”标记的效果，伤害由 %arg 点降至1点",
	
	
	
	
	
	
	
	
	
	
	
	
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------	
	
	
	
	
	
	
	
	
}

return {extension,extension1,extension2}