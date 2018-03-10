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

lord_sunquan = sgs.General(extension, "lord_sunquan$", "wu", 4, true, true)

--**********加强包**********-----

caocao = sgs.General(extension1, "caocao", "wei","4",true,false,false) 
weiyan = sgs.General(extension1, "weiyan", "shu","4",true,false,false)

--**********猛包**********-----

meng_zhaoyun = sgs.General(extension2, "meng_zhaoyun", "shu","3")
meng_luxun = sgs.General(extension2, "meng_luxun", "wu","3")

--===========================================函数区============================================--

local sendMsg = function(room,message)
	local msg = sgs.LogMessage()
	msg.type = "#message"
	msg.arg = message
	room:sendLog(msg)
end
local sendMsgFrom = function(room,player,message)
	local msg = sgs.LogMessage()
	msg.type = "#messagefrom"
	msg.from = player
	msg.arg = message
	room:sendLog(msg)
end
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

--===========================================技能区============================================--

--**********智包**********-----

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
		if death.who:objectName() == player:objectName() and player:hasSkill(self:objectName()) and death.damage.from then
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
	frequency = sgs.Skill_Frequent,
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
			if not p:isNude() then
				targets:append(p)
			end
		end
		if targets:length() == 0 then return false end
		local target_choose = room:askForPlayersChosen(player,targets,self:objectName(),0,player:getMaxHp()-player:getHp(),self:objectName().."-invoke",true)
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
		room:broadcastSkillInvoke(self:objectName())
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
		sendMsg(room,"fff")
		if player:getPhase() == sgs.Player_Discard and player:getHandcardNum() > player:getMaxCards() and player:isWounded() then
			sendMsg(room,"rrr")	
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
	events = {sgs.CardsMoveOneTime,sgs.GeneralShown} ,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard then
				return self:objectName()
			end
		elseif event == sgs.GeneralShown then
			if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
			if player:hasShownSkill("duoshi") and player:hasShownSkill(self:objectName()) then
				room:detachSkillFromPlayer(player,"duoshi")
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
	events = {sgs.Damage, sgs.PreDamageDone},
	can_trigger = function(self, event, room, player, data)	
		local damage = data:toDamage()
		if (event == sgs.PreDamageDone) and damage.from and damage.from:hasSkill(self:objectName()) and damage.from:isAlive() then
			local weiyan = damage.from
			weiyan:setTag("invokeLuaKuanggu", sgs.QVariant((weiyan:distanceTo(damage.to) <= 1)))
			return ""
		elseif (event == sgs.Damage) and player:hasSkill(self:objectName()) and player:isAlive() then
			local invoke = player:getTag("invokeLuaKuanggu"):toBool()
			player:setTag("invokeLuaKuanggu", sgs.QVariant(false))
			if invoke then
				return self:objectName()
			end	
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
			recover.recover = damage.damage
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
        return #selected <= sgs.Self:getHandcardNum() - sgs.Self:getHp()
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
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("lizhan") then
skillList:append(lizhan)
end
if not sgs.Sanguosha:getSkill("zhaxiang") then
skillList:append(zhaxiang)
end
if not sgs.Sanguosha:getSkill("lianying") then
skillList:append(lianying)
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
	if allNames[i] == "luxun" then
		general:addSkill("lianying")
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
		if event == sgs.EventPhaseStart then
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
		else
			if room:askForSkillInvoke(player,self:objectName(),data) then
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

--===========================================珠联璧合区============================================--

--**********智包**********-----

zhangxiu:addCompanion("jiaxu")
zhangxiu:addCompanion("zoushi")
huaxiong:addCompanion("panfeng")
bulianshi:addCompanion("sunquan")
zhangchunhua:addCompanion("simayi")
liru:addCompanion("dongzhuo")
liyan:addCompanion("zhugeliang")
zumao:addCompanion("sunjian")
zhoucang:addCompanion("guanyu")
caimao:addCompanion("liubiao")
hejin:addCompanion("hetaihou")

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
	["#zhangchunhua"] = "冷血皇后",
	["jueqing"] = "绝情",
	[":jueqing"] = "当你造成伤害时，你可以指定一名角色为伤害来源。",
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
	["liru"] = "李儒",
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
	["#xizhicai"] = "负俗的天才",
	["zaoshi"] = "早逝",
	[":zaoshi"] = "锁定技，你视为拥有技能“天妒”，若你已有技能“天妒”，你将技能改为如下效果：当你的判定牌生效后，你可以获得之，然后你可以将其交给一名其他角色。",
	["tiandu_xizhicai"] = "天妒",
	[":tiandu_xizhicai"] = "当你的判定牌生效后，你可以获得之，然后你可以将其交给一名其他角色。",
	["xianfu"] = "先辅",
	[":xianfu"] = "锁定技，你亮出武将牌时，你须选择一名其他角色，其成为“先辅”目标：当其受到伤害后，你受到等量的伤害；当其回复体力后，你回复等量的体力。",
	["chouce"] = "筹策",
	[":chouce"] = "当你受到1点伤害后，你可以判定，若结果为：红色，令一名角色摸X张牌（若其为“先辅”选择的角色，X为2，否则为1）；黑色，弃置一名角色区域里的一张牌。",
	["lord_sunquan"] = "孙权-君",
	["#lord_sunquan"] = "吴王光耀",
	["shenduan"] = "慎断",
	[":shenduan"] = "出牌阶段，你可以将至多x张牌（x为已亮吴势力角色数且至少为2）以任意顺序至于牌堆顶，然后从牌堆底摸等量的牌。<br /><font color=\"pink\">注：其他角色能看到你置于牌堆顶的牌。</font>",
	["zaoli"] = "早立",
	[":zaoli"] = "你明置武将牌后，你可以摸两张牌，回复一点体力并重置武将牌。",
	["shouguan"] = "授官",
	[":shouguan"] = "锁定技，你的回合结束后，或者“大都督”死亡后，若场上没有“大都督”且有其他存活的吴势力角色，你须指定一名其他吴势力角色成为“大都督”。“大都督”每有一点已损失体力值，视为吴势力角色数+1，“大都督”使用锦囊牌时，其可以令你摸一张牌。",
	["liyan"] = "李严",
	["#liyan"] = "矜风流务",
	["duliang"] = "督粮",
	[":duliang"] = "阵法技，与你处于同一队列的角色成为【兵粮寸断】或者【过河拆桥】的目标时，你可以取消该目标。你出牌阶段的出杀次数+x（x为与你处于同一队列的其他角色数）。<br /><font color=\"pink\">注：如果队列只有你一个人，该技能也对你也生效。</font>",
	["fulin"] = "腹鳞",
	[":fulin"] = "一名角色第一次濒死时，你可以摸两张牌；一名蜀势力的其他角色死亡时，你增加一点手牌上限。<br /><font color=\"pink\">注：蜀势力不包括野心家。</font>",
	["zhugejin"] = "诸葛瑾",
	["#zhugejin"] = "宛陵侯",
	["hongyuan"] = "弘援",
	[":hongyuan"] = "摸牌阶段，你可以少摸两张牌，然后选择一项：令所有与你势力相同的角色各摸一张牌，或者令所有与你势力不同的角色（包括暗将）各弃置一张牌。",
	["mingzhe"] = "明哲",
	[":mingzhe"] = "当你于回合外因使用、打出或弃置而失去红色牌时，你可以摸等量的牌。",
	["zhonghui"] = "钟会",
	["#zhonghui"] = "谋谟之勋",
	["zili"] = "自立",
	[":zili"] = "主将技，锁定技，限定技，你的回合结束后，你摸三张牌并回复一点体力，然后移除副将牌，将势力改为“野心家”并获得技能“劝降”。<br /><font color=\"pink\">劝降：当你的【杀】对一名其他角色造成伤害时，你令对方选择一项：交给你一张牌，或移除其副将牌并置于你的副将区。若你因此获得副将，你防止你造成的伤害，失去技能“大志”，并将此技能的第二个选项改为“失去一点体力”。</font>",
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
	["benyu"] = "贲育",
	[":benyu"] = "当你受到伤害后，若伤害来源存活且你的手牌数：小于X，你可以将手牌补至X（至多为5）张；大于X，你可以弃置至少X+1张手牌，对伤害来源造成1点伤害。（X为伤害来源的手牌数）",
	["@benyu-discard"] = "你可以发动“贲育”弃置至少 %arg 张手牌对 %dest 造成1点伤害",
	["~benyu"] = "选择足量的手牌→点击确定",
	["zumao"] = "祖茂",
	["#zumao"] = "碧血染赤帻",
	["yinbing"] = "引兵",
	[":yinbing"] = "弃牌阶段结束时，你可以指定至多x名角色（x为你已损失体力值），你分别弃置指定角色的一张牌。",
	["zhoucang"] = "周仓",
	["#zhoucang"] = "披肝沥胆",
	["zhongyong"] = "忠勇",
	[":zhongyong"] = "当你使用的【杀】结算结束后，你可以将此【杀】或目标角色使用的所有【闪】交给一名不为此【杀】目标的其他角色，以此法获得红色牌的角色可以对你攻击范围内的一名角色使用一张【杀】（无距离限制）。",
	["#zhongyong"] = "忠勇",
	["@zhongyong"] = "你可以发动“忠勇”",
	["~zhongyong"] = "选择【杀】或所有【闪】→选择一名其他角色→点击确定",
	["@zhongyong-slash"] = "你可以对 %src 攻击范围内的角色使用一张【杀】",
	["caimao"] = "蔡瑁",
	["#caimao"] = "荆州水师",
	["shuishi"] = "水师",
	[":shuishi"] = "阵法技，若你是被围攻角色，围攻角色对你使用【杀】或【水淹七军】时，你可以弃置一张手牌令此牌对你无效；若你是围攻角色，你对被围攻角色使用【杀】或【水淹七军】造成伤害时，你可以令此伤害+1。",
	["duozhu"] = "夺主",
	[":duozhu"] = "锁定技，当一名其他角色阵亡时，你将其装备区内所有你相应位置没有的装备置于你的装备区。<br /><font color=\"pink\">注：此技能优先级高于行殇。</font>",
	["hejin"] = "何进",
	["#hejin"] = "色厉内荏",
	["mouzhu"] = "谋诛",
	[":mouzhu"] = "锁定技，你杀死角色后的结算改为摸三张牌。",
	["yanhuo"] = "延祸",
	[":yanhuo"] = "你的回合结束后，可以指定一名角色，其摸x张牌并弃置x张牌（x为你已损失体力值）。",
	["miheng"] = "祢衡",
	["#miheng"] = "鸷鹗啄孤凤",
	["kuangcai"] = "狂才",
	[":kuangcai"] = "出牌阶段开始时，你可以令此回合获得如下效果：当你使用牌时，摸一张牌，然后若本回合你使用牌的次数大于x（x为你的体力上限），你结束出牌阶段。",
	["shejian"] = "舌剑",
	[":shejian"] = "出牌阶段限一次，你可以指定至多x名其他角色（x为当前大势力角色数），你与所有指定角色同时展示一张手牌，然后你弃置所有与你展示的牌颜色相同的牌。",
	["masu"] = "马谡",
	["#masu"] = "街亭之殇",
	["sanyao"] = "散谣",
	[":sanyao"] = "一名角色的弃牌阶段开始时，若其需要弃置手牌，你可以展示其一张牌，然后你选择一项：令其于此弃牌阶段内该牌不计入手牌数；或者令其于此弃牌阶段内不能弃置此牌。",
	["huilei"] = "挥泪",
	[":huilei"] = "锁定技，杀死你的角色获得技能“泪目”（锁定技，当你的体力值不小于3时，你不能弃置黑色手牌；当你的体力值为2时，你不能弃置黑桃手牌。）。",
	["leimu"] = "泪目",
	[":leimu"] = "锁定技，当你的体力值不小于3时，你不能弃置黑色手牌；当你的体力值为2时，你不能弃置黑桃手牌。",
	--加强包--
	["lizhan"] = "励战",
	[":lizhan"] = "副将技，此武将牌上单独的阴阳鱼个数-1，回合结束时，你可以令任意名已受伤的角色摸一张牌。",
	["lizhan-invoke"] = "你可以指定任意名已受伤的角色各摸一张牌",
	["zhaxiang"] = "诈降",
	[":zhaxiang"] = "弃牌阶段开始时，若你的手牌数大于你的体力值，你可以将x张手牌交给一名其他角色（x为你的手牌数减去你的体力值），然后若x不小于2，你对其造成一点伤害。",
	["@zhaxiang-card"] = "你可以发动诈降",
	["Ejianxiong"] = "奸雄",
	[":Ejianxiong"] = "每当你受到伤害后，你可以选择一项：获得对你造成伤害的牌，或摸一张牌。",
	["draw1"] = "摸一张牌",
	["obtain"] = "获得造成伤害的牌",
	["Ekuanggu"] = "狂骨",
	[":Ekuanggu"] = "每当你对距离1以内的一名角色造成1点伤害后，你可以回复1点体力，或者摸一张牌。",
	["lianying"] = "连营",
	[":lianying"] = "副将技，每当你失去最后的手牌后，你可以摸一张牌。你明置武将牌后，若你有技能“度势”，你失去技能“度势”。",
	["danqi"] = "单骑",
	[":danqi"] = "副将技，此武将牌上单独的阴阳鱼个数-1，当你的红色牌造成伤害时，你可以弃置对方的一张牌，然后若你弃置的牌与你使用的该牌花色相同，你摸一张牌。",
	--猛包--
	["meng_zhaoyun"] = "赵子龙",
	["#meng_zhaoyun"] = "虎威将军",
	["yajiao"] = "涯角",
	[":yajiao"] = "锁定技，你的回合结束后，你获得牌堆顶x张牌中的所有的【杀】（x为存活角色数），然后若你获得的【杀】个数大于x/2，你将武将牌叠置。",
	["chongzhen"] = "冲阵",
	[":chongzhen"] = "当你使用【杀】/成为【杀】的目标时，你可以弃置一张比此【杀】点数大的基本牌令此【杀】不可被闪避/对你无效。",
	["meng_luxun"] = "陆伯言",
	["#meng_luxun"] = "江陵侯",
	["shaoying"] = "烧营",
	[":shaoying"] = "你的回合开始时，你可以视为对一名角色使用一张【火攻】。锁定技，当你对一名角色造成火属性伤害后，你可以视为对其下家使用一张【火攻】（若其有手牌）。",
	["linggong"] = "领功",
	[":linggong"] = "你的回合结束后，你可以摸x张牌（x为你此回合造成火属性伤害的次数，且最多不超过3）。",
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
	--猛包--
	["@chongzhen1"] = "你可以弃置一张比该【杀】点数大的基本牌,令此【杀】不可被闪避",
	["@chongzhen2"] = "你可以弃置一张比该【杀】点数大的基本牌,令此【杀】对你无效",
	["shaoying-invoke"] = "你可以指定一名角色，视为对其使用一张【火攻】",
-----exchange-----
	["tuifengPush"] = "您可以将一张牌当作“锋”置于武将牌上",
-----choice-----
	["draw"] = "摸两张牌",
	["recover"] = "回复一点体力",
	["reset"] = "重置武将牌",
	["dingpan_discard"] = "弃置一张装备牌",
	["dingpan_damage"] = "获得所有装备牌，然后受到一点伤害",
	["zongxuan#up"] = "弃置",
	["zongxuan#down"] = "置于牌堆顶",
	["shenduan#up"] = "弃置",
	["shenduan#down"] = "置于牌堆顶",
	["friend_draw"] = "所有与你势力相同的角色摸一张牌",
	["enemy_discard"] = "所有与你势力不同的角色弃置一张牌",
	["sanyao_benefit"] = "令对方该手牌不计入手牌数",
	["sanyao_not_benefit"] = "令对方不能弃置此牌",
-----bug-----
	["qiaoshuiCard"] = "巧说",
	["shenduanCard"] = "慎断",
	["#tuifeng-throw"] = "推锋",
-----pile-----
	["lead"] = "锋",
	["power"] = "权",
	["fu"] = "伏",
-----mark-----
	["@lead"] = "锋",
	["@yaowu"] = "耀武",
	["@zili"] = "自立",
	
	
	
	["#message"] = "%arg",
	["#messagefrom"] = "%from %arg",
	
	
	
	
	
	
	
	
	
	
	
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------
---------------------------------------------------------------------------------华丽分割线-------------------------------------------------------------------------------------------	
	
	
	
	
	
	
	
	
}

return {extension,extension1,extension2}