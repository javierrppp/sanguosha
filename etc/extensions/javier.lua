
extension = sgs.Package("javier", sgs.Package_GeneralPack)

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

local getKingdoms=function(room) --可以在函数中定义函数，本函数返回存活势力的数目
	local kingdoms={}
	local kingdom_number=0
	local players=room:getAlivePlayers()
	for _,aplayer in sgs.qlist(players) do
		if aplayer:hasShownOneGeneral() then
			if (not kingdoms[aplayer:getKingdom()]) and (aplayer:getRole() ~= "careerist") then
				kingdoms[aplayer:getKingdom()]=true
				kingdom_number=kingdom_number+1
			elseif aplayer:getRole() == "careerist" then
				kingdom_number=kingdom_number+1
			end
		end
	end
	return kingdom_number
end
local isLargeKingdom=function(player)
	local room = player:getRoom()
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:getEquip(4) and p:getEquip(4):isKindOf("JadeSeal") then
			if p:objectName() == player:objectName() then return true end
			if p:hasShownOneGeneral() then
				if p:getKingdom() == player:getKingdom() and p:getRole() ~= "careerist" then
					return true
				else
					return false
				end
			else
				return false
			end
		end
	end
	if player:getRole() == "careerist" then return false end
	local shu = 0
	local wei = 0
	local wu = 0
	local qun = 0
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		if p:hasShownOneGeneral() and p:getRole() ~= "careerist" then
			if p:getKingdom() == "shu" then shu = shu + 1
			elseif p:getKingdom() == "wei" then wei = wei + 1
			elseif p:getKingdom() == "wu" then wu = wu + 1
			elseif p:getKingdom() == "qun" then qun = qun + 1
			end
		end
	end
	if player:getKingdom() == "shu" then
		if shu < 2 then return false end
		if shu >= wei and shu >= wu and shu >= qun then return true end
	elseif player:getKingdom() == "wei" then
		if wei < 2 then return false end
		if wei >= shu and wei >= wu and wei >= qun then return true end
	elseif player:getKingdom() == "wu" then
		if wu < 2 then return false end
		if wu >= wei and wu >= shu and wu >= qun then return true end
	elseif player:getKingdom() == "qun" then
		if qun < 2 then return false end
		if qun >= wei and qun >= wu and qun >= shu then return true end
	end
	return false
end
local msgSend = function(from,to,name)
	local room = from:getRoom()
	local msg = sgs.LogMessage()
	msg.type = name
	if from then
		msg.from = from
	end
	if to then
		msg.to = to
	end
	room:sendLog(msg)
end
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
		room:drawCards(to, 1, self:objectName())
		room:getCurrent():addMark(self:objectName())
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
			table.insert(choices, "discard")
		end
		table.insert(choices, "damage")
		local choice = room:askForChoice(target, "dingpan", table.concat(choices, "+"))
		if choice == "discard" and source:canDiscard(target, "e") then
			room:broadcastSkillInvoke("dingpan", 1, source)
			local id = room:askForCardChosen(source, target, "e", "dingpan", false, sgs.Card_MethodDiscard)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, source:objectName(), target:objectName(), "dingpan", nil)
			room:throwCard(sgs.Sanguosha:getCard(id), reason, target, source)
		elseif choice == "damage" then
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
		local dest = room:askForPlayerChosen(player, room:getAlivePlayers(), "dingpin","dingpin-invoke",true)
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
			--感觉纵适这个技能有猫饼，所以写在这里，恃勇同
			local  jianyong = room:findPlayerBySkillName("zongshi")
			if jianyong and (pd.from_card:getSuit() == sgs.Card_Spade or pd.to_card:getSuit() == sgs.Card_Spade) then
				if room:askForSkillInvoke(jianyong,"zongshi") then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if pd.from_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pd.from_card:getId()) end
					if pd.to_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pd.to_card:getId()) end
					jianyong:obtainCard(dummy)
				end
			end
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
			room:doAnimate(sgs.QSanProtocol_S_ANIMATE_INDICATE, player:objectName(), mosthp:objectName())
			if room:askForDiscard(mosthp, self:objectName(), 2, 2, false, true) then
				mosthp:drawCards(2)
			end
		end
		return true
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
		if (player:hasShownSkill(self:objectName())) then
			return player:getMaxHp() - player:getHp()
		end
		return 0
	end,
	priority = -10
}
liubiao:addSkill(gushou)
liubiao:addSkill(gushou_limit)
extension:insertRelatedSkills("gushou","#gushou_limit")
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
		if pindian.from_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pindian.from_card:getId()) end
		if pindian.to_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pindian.to_card:getId()) end
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
				effect.from:drawCards(1)
			end
			return ""
		elseif event == sgs.PreCardUsed then
			if player:getMark("zhuhai_Mark") > 0 then
				room:broadcastSkillInvoke(self:objectName())
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
		if damage.from:objectName() == damage.to:objectName() then return "" end
		if not player:hasShownSkill(self:objectName()) then return "" end
		if damage.card and not damage.card:isKindOf("Slash") then return "" end
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
				pd_to = false
			elseif pd.from_card:getNumber() > pd.to_card:getNumber() then
				pd.from:obtainCard(pd.to_card)
				pd_from = false
			end
			local  jianyong = room:findPlayerBySkillName("zongshi")
			if jianyong and (pd.from_card:getSuit() == sgs.Card_Spade or pd.to_card:getSuit() == sgs.Card_Spade) then
				if room:askForSkillInvoke(jianyong,"zongshi") then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if pd_to and pd.from_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pd.from_card:getId()) end
					if pd_from and pd.to_card:getSuit() == sgs.Card_Spade then dummy:addSubcard(pd.to_card:getId()) end
					jianyong:obtainCard(dummy)
				end
			end
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
		msgSend(ask_who,nil,"#yaowu")
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
		--if damage.from and not isLargeKingdom(damage.from) then return "" end
		local big_kingdoms = damage.from:getBigKingdoms("fuli")
		if not table.contains(big_kingdoms,damage.from:getKingdom()) then return "" end
		if damage.from and not isLargeKingdom(damage.from) then return "" end
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
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
	events = {sgs.Predamage},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, zhangchunhua, data,ask_who)
		local damage = data:toDamage()
		local _data = sgs.QVariant()		
		_data:setValue(damage.to)
		if not zhangchunhua:hasShownSkill(self:objectName()) and room:askForSkillInvoke(zhangchunhua,self:objectName(),_data) then
			return true
		end
		if zhangchunhua:hasShownSkill(self:objectName()) then
			room:notifySkillInvoked(player, self:objectName())
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, zhangchunhua, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local damage = data:toDamage()
		damage.from = damage.to
		data:setValue(damage)
		if damage.to:getKingdom() == zhangchunhua:getKingdom() then
			damage.to:drawCards(1)
		end
		return false
	end
}
zhangchunhua:addSkill(shangshi)
zhangchunhua:addSkill(jueqing)
zhangchunhua:addCompanion("simayi")
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
zhangxiu:addCompanion("jiaxu")
zhangxiu:addCompanion("zoushi")
huaxiong:addCompanion("panfeng")
bulianshi:addCompanion("sunquan")
sgs.LoadTranslationTable{
	["javier"] = "智包" ,
	
	["zhangchunhua"] = "张春华",
	["#zhangchunhua"] = "冷血皇后",
	["jueqing"] = "绝情",
	[":jueqing"] = "锁定技，当你造成伤害时，其视为伤害来源，然后若其与你是同一势力，其摸一张牌。",
	["shangshi"] = "伤势",
	[":shangshi"] = "弃牌阶段外，当你的手牌数小于X时，你可以将手牌补至X张（X为你已损失的体力值）。",
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
	["#huaxiong"] = "魔将",
	["shiyong"] = "恃勇",
	[":shiyong"] = "一名角色使用【杀】对你造成伤害后，若你明置了武将牌，其可以与你拼点，若你赢，你获得其的拼点牌；若你输，其获得你的拼点牌。",
	["yaowu"] = "耀武",
	[":yaowu"] = "限定技，一名角色将要受到伤害时，若其的体力值为1，你可以令其防止此伤害。",
	["sunhao"] = "孙皓",
	["#sunhao"] = "时日曷丧",
	["canshi"] = "残蚀",
	[":canshi"] = "摸牌阶段，你可改为摸X张牌（X为已受伤的角色数），然后当你本回合使用基本牌或锦囊牌时，你弃置一张牌。<br /><font color=\"pink\">注：当没有人受伤时，不能发动此技能。</font>",
	["chouhai"] = "仇海",
	[":chouhai"] = "锁定技，当你受到伤害时，若你没有手牌，此伤害+1。",
	["niujin"] = "牛金",
	["cuorui"] = "挫锐",
	[":cuorui"] = "锁定技，当你受到伤害后，你须将一张手牌置于牌堆顶。",
	["liewei"] = "裂围",
	[":liewei"] = "你的回合外明置此武将牌时，你可以摸三张牌然后执行一个额外的出牌阶段。",
	["#niujin"] = "独进的兵胆",
	["liaohua"] = "廖化",
	["fuli"] = "伏枥",
	[":fuli"] = "锁定技，大势力角色对你造成的伤害-1。",
	["#liaohua"] = "历尽沧桑",
	["liubiao"] = "刘表",
	["#liubiao"] = "跨蹈汉南",
	["gushou"] = "固守",
	[":gushou"] = "锁定技，其他角色计算与你的距离时，始终+x，x为你已损失体力值。你的手牌上限等于你的体力上限。",
	["bulianshi"] = "步练师",
	["#bulianshi"] = "无冕之后",
	["anxu"] = "安恤",
	[":anxu"] = "出牌阶段限一次，你可以选择手牌数不等的两名其他角色：若如此做，手牌较少的角色正面朝上获得另一名角色的一张手牌。若此牌不为♠，你摸一张牌。 ",
	["zhuiyi"] = "追忆",
	[":zhuiyi"] = "你死亡时，你可以令一名其他角色（除杀死你的角色）摸三张牌并回复1点体力。 ",
	["jianyong"] = "简雍",
	["#jianyong"] = "优游风议",
	["qiaoshui"] = "巧说",
	[":qiaoshui"] = "出牌阶段限一次，你可以与一名其他角色拼点，若你赢，视为你对其使用了一张无距离限制的【顺手牵羊】。",
	["zongshi"] = "纵适",
	[":zongshi"] = "当有拼点结束后，你可以获得其中的黑桃牌。<br /><font color=\"pink\">注：如果是“恃勇”发起的拼点，则“恃勇”的结算先于该技能。</font>",
	["xushu"] = "徐庶",
	["#xushu"] = "化剑为犁",
	["zhuhai"] = "诛害",
	[":zhuhai"] = "主将技，一名其他角色的结束阶段开始时，若该角色本回合造成过伤害，你可以对其使用一张无距离限制的【杀】。然后若此杀被闪避，你摸一张牌。 ",
	["wuyan"] = "无言",
	[":wuyan"] = "副将技，此武将牌上单独的阴阳鱼个数-1，锁定技，每当你造成或受到伤害时，防止锦囊牌的伤害。 ",
	["jujian"] = "举荐",
	[":jujian"] = "副将技，结束阶段开始时，你可以弃置一张非基本牌并选择一名其他角色：若如此做，该角色选择一项：摸两张牌，或回复1点体力，或重置武将牌并将其翻至正面朝上。 ",
	["chenqun"] = "陈群",
	["#chenqun"] = "万世臣表",
	["dingpin"] = "定品",
	[":dingpin"] = "当你受到伤害后，你可以令一名角色判定，若为黑，其摸等同于其已损失体力值张数的牌；若为红，你将武将牌叠置。",
	["faen"] = "法恩",
	[":faen"] = "每当一名角色的武将牌叠置或横置时，你可以令其摸一张牌。然后若叠置或横置的角色是你，你可以令一名其他角色摸一张牌。 ",
	["mizhu"] = "糜竺",
	["#mizhu"] = "挥金追义",
	["jugu"] = "巨贾",
	[":jugu"] = "你的回合开始时，你可以摸一张牌，然后你可以将一张牌置于牌堆顶。",
	["ziyuan"] = "资援",
	[":ziyuan"] = "出牌阶段限一次，你可以令一名体力值为1的角色回复一点体力，或者令一名手牌数不大于1的角色摸一张牌。<br /><font color=\"pink\">注：如果你指定的角色两个条件都符合，那么即回复一点体力也摸一张牌。</font>",
	["liuxie"] = "刘协",
	["#liuxie"] = "受困天子",
	["mizhao"] = "密诏",
	[":mizhao"] = "出牌阶段限一次，你可以将所有手牌（至少一张）交给一名其他角色：若如此做，你令该角色与另一名由你指定的有手牌的角色拼点：若一名角色赢，视为该角色对没赢的角色使用一张【杀】。",
	["tianming"] = "天命",
	[":tianming"] = "每当你被指定为【杀】的目标时，你可以弃置两张牌，然后摸两张牌。若全场唯一的体力值最多的角色不是你，该角色也可以弃置两张牌，然后摸两张牌。",
	["buzhi"] = "步骘",
	["#buzhi"] = "积跬靖边",
	["hongde"] = "弘德",
	[":hongde"] = "当你获得或失去至少两张牌后，你可以令一名其他角色摸一张牌。每名角色的回合限四次。",
	["dingpan"] = "定判",
	[":dingpan"] = "出牌阶段限X次（X为大势力角色数且至少为1），你可以令一名装备区里有牌的角色摸一张牌，然后其选择一项：1.令你弃置其装备区里的一张牌；2.获得其装备区里的所有牌，若如此做，你对其造成1点伤害。",
	["litong"] = "李通",
	["#litong"] = "万亿吾独往",
	["tuifeng"] = "推锋",
	[":tuifeng"] = "当你受到1点伤害后，你可以将一张牌置于武将牌上，称为“锋”；准备阶段开始时，若你的武将牌上有“锋”，你移去所有“锋”，摸2X张牌，若如此做，你于此回合的出牌阶段内可以多使用X张【杀】（X为你此次移去的“锋”数）。",
	-----
	["@cuorui"] = "请将一张牌置于牌堆顶。",
	["@zhuhai"] = "你可以对当前回合角色使用一张【杀】。",
-----msg-----
	["#yaowu"] = "%from 发动技能“耀武”，此次伤害无效。",
-----invoke-----
	["zhuiyi-invokex"] = "请指定一名角色(不能是杀死你的角色)，对其发动“追忆”",
	["zhuiyi-invoke"] = "请指定一名角色，对其发动“追忆”",
	["@jujian-card"] = "请指定一名角色，对其发动“举荐”",
	["dingpin-invoke"] = "请指定一名角色，对其发动“定品”",
	["faen-invoke"] = "您可以指定一名其他角色，令其摸一张牌",
	["@jugu"] = "您可以将一张牌置于牌堆顶",
	["hongde-invoke"] = "您可以指定一名觉色，令其摸一张牌",
-----exchange-----
	["tuifengPush"] = "您可以将一张牌当作“锋”置于武将牌上",
-----choice-----
	["draw"] = "摸两张牌",
	["recover"] = "回复一点体力",
	["reset"] = "重置武将牌",
-----bug-----
	["qiaoshuiCard"] = "巧说",
-----pile-----
	["lead"] = "锋",
-----mark-----
	["@lead"] = "锋",
	["@yaowu"] = "耀武",
}
return {extension}