extension_multy = sgs.Package("extension_multy", sgs.Package_GeneralPack)

liuqi_qun = sgs.General(extension_multy, "liuqi_qun", "qun", 3)
liuqi_shu = sgs.General(extension_multy, "liuqi_shu", "shu", 3)
huangquan_shu = sgs.General(extension_multy, "huangquan_shu", "shu", 3)
huangquan_wei = sgs.General(extension_multy, "huangquan_wei", "wei", 3)
sufei_qun = sgs.General(extension_multy, "sufei_qun", "qun", 4)
sufei_wu = sgs.General(extension_multy, "sufei_wu", "wu", 4)
tangzi_wei = sgs.General(extension_multy, "tangzi_wei", "wei", 4)
tangzi_wu = sgs.General(extension_multy, "tangzi_wu", "wu", 4)

-----刘琦-----

wenji = sgs.CreateOneCardViewAsSkill{
	name = "wenji",
	view_filter = function(self, card)
		local wenji_card_player_list = sgs.Self:property("wenjiProp"):toString():split("+")
		for _,card_player_list in pairs(wenji_card_player_list) do
			local card_player = card_player_list:split(",")
			if card_player[1] == tostring(card:getId()) then return true end
		end
		return false
	end,
	view_as = function(self, originalCard)
		local card = wenjiCard:clone()
		card:addSubcard(originalCard)
		card:setSkillName(self:objectName())
		card:setShowSkill(self:objectName())
		return card
	end
}
wenjiCard = sgs.CreateSkillCard{
	name = "wenjiCard",
	skill_name = "wenji",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	mute = true,
	filter = function(self, targets, to_select, player)
		local wenji_card_player_list = sgs.Self:property("wenjiProp"):toString():split("+")
		local card_id = self:getSubcards():first()
		for _,card_player_list in pairs(wenji_card_player_list) do
			local card_player = card_player_list:split(",")
			if card_player[1] == tostring(card_id) then
				if card_player[2] == to_select:objectName() then
					return true
				end
			end
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 3
	end,
	on_use = function(self, room, source, targets)
	end
}
	
wenji_ask_card = sgs.CreateTriggerSkill{
	name = "#wenji_ask_card",
	can_preshow = true,
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd, sgs.CardUsed, sgs.CardResponded},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if event == sgs.EventPhaseStart then
			local liuqi = room:findPlayersBySkillName("wenji")
			if player:getPhase() ~= sgs.Player_Play then return "" end
			if player:getRole() == "careerist" then return "" end
			if not player:hasShownOneGeneral() then return "" end
			for _, p in sgs.qlist(liuqi) do 
				if p:objectName() ~= player:objectName() and p:getKingdom() == player:getKingdom() and p:getRole() ~= "careerist" then
					if player:getHandcardNum() + player:getEquips():length() > 0 then 
						return self:objectName(), p
					end
				end
			end
			return ""
		elseif event == sgs.EventPhaseEnd then
			if not player:hasSkill(self:objectName()) then return "" end
			if player:getPhase() == sgs.Player_Finish then
				--player:setTag("wenjiTag", sgs.QVariant(""))
				room:setPlayerProperty(player, "wenjiProp", sgs.QVariant(""))
				room:setPlayerMark(player, "tunjiangMark", 0)  --屯江
			end
			return ""
		elseif event == sgs.CardUsed or event == sgs.CardResponded then
			if not player:hasSkill(self:objectName()) then return "" end
			--local wenji_card = player:getTag("wenjiTag"):toString():split("+")
			local wenji_card = player:property("wenjiProp"):toString():split("+")
			local card 
			if event == sgs.CardUsed then
				local use = data:toCardUse()
				card = use.card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				if response.m_isUse == false then return "" end
				card = response.m_card
			end
			local id = card:getId()
			local toObjectName, to
			for i = 1, #wenji_card, 1 do 
				local str = wenji_card[i]:split(",")
				if id == tonumber(str[1]) then
					toObjectName = str[2]
					table.removeOne(wenji_card, wenji_card[i])
					break
				end
			end
			if toObjectName then
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					if p:objectName() == toObjectName then
						to = p 
					end
				end
				if not to then return false end
				to:drawCards(2)
				room:notifySkillInvoked(player, "wenji")
				room:broadcastSkillInvoke("wenji", 2)
				room:addPlayerMark(player, "tunjiangMark")   --屯江
				--player:setTag("wenjiTag", sgs.QVariant(table.concat(wenji_card, "+")))
				room:setPlayerProperty(player, "wenjiProp", sgs.QVariant(table.concat(wenji_card, "+")))
			end
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if ask_who:askForSkillInvoke("wenji", data) then
			ask_who:showGeneral(ask_who:inHeadSkills("wenji"))
			room:notifySkillInvoked(ask_who, "wenji")
			room:broadcastSkillInvoke("wenji", 1)
			room:doAnimate(1, ask_who:objectName(), player:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		local d = sgs.QVariant()
		d:setValue(ask_who)
		player:setTag("wenjiAskTag", d)
		local card = room:askForCard(player, "..", "@wenji-card:" .. ask_who:objectName(), sgs.QVariant(), sgs.Card_MethodNone)
		player:removeTag("wenjiAskTag")
		if card then
			room:obtainCard(ask_who, card, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), ask_who:objectName(), "wenji", ""), true)
			local str = card:getId() .. "," .. player:objectName()
			--local wenji_card_str = ask_who:getTag("wenjiTag"):toString()
			local wenji_card_str = ask_who:property("wenjiProp"):toString()
			if wenji_card_str == "" then
				--ask_who:setTag("wenjiTag", sgs.QVariant(str))
				room:setPlayerProperty(ask_who, "wenjiProp", sgs.QVariant(str))
			else
				local wenji_card = wenji_card_str:split("+")
				table.insert(wenji_card, str)
				--ask_who:setTag("wenjiTag", sgs.QVariant(table.concat(wenji_card, "+")))
				room:setPlayerProperty(ask_who, "wenjiProp", sgs.QVariant(table.concat(wenji_card, "+")))
			end
		end
	end
}
tunjiang = sgs.CreateTriggerSkill{
	name = "tunjiang",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				if player:getMark("tunjiangMark") > 0 and player:getMark("tunjiangCardUsedMark") >= player:getHp() then return "" end  --如果触发了问计且使用牌的次数大于等于体力值不能发动屯江
				room:setPlayerMark(player, "tunjiangMark", 0)
				room:setPlayerMark(player, "tunjiangCardUsedMark", 0)
				return self:objectName()
			end
			return ""
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard") or use.card:isKindOf("EquipCard") then
				room:addPlayerMark(player, "tunjiangCardUsedMark")
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			room:notifySkillInvoked(ask_who, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		ask_who:drawCards(2)
	end
}
benzhi = sgs.CreateTriggerSkill{
	name = "benzhi",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				if player:getMark("tunjiangMark") == 0 and player:getMark("tunjiangCardUsedMark") <= player:getHp() then return "" end  --如果没有触发问计且使用牌的次数小于体力值则不能发动屯江
				room:setPlayerMark(player, "tunjiangMark", 0)
				room:setPlayerMark(player, "tunjiangCardUsedMark", 0)
				return self:objectName()
			elseif player:getPhase() == sgs.Player_Start then
				player:loseMark("@benzhi")
			end
			return ""
		elseif event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard") or use.card:isKindOf("EquipCard") then
				room:addPlayerMark(player, "tunjiangCardUsedMark")
			end
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			room:notifySkillInvoked(ask_who, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		ask_who:gainMark("@benzhi")
	end
}
benzhi_distance = sgs.CreateDistanceSkill{
	name = "#benzhi_distance",
	correct_func = function(self, from, to)
		if to:hasShownSkill("benzhi") and to:getMark("@benzhi") > 0 then
			return 1
		end
		return 0
	end
}
liuqi_qun:addSkill(wenji)
liuqi_qun:addSkill(wenji_ask_card)
liuqi_qun:addSkill(benzhi)
liuqi_qun:addSkill(benzhi_distance)
liuqi_shu:addSkill(wenji)
liuqi_shu:addSkill(wenji_ask_card)
liuqi_shu:addSkill(tunjiang)
sgs.insertRelatedSkills(extension, "wenji", "#wenji_ask_card")
sgs.insertRelatedSkills(extension, "benzhi", "#benzhi_distance")

liuqi_qun:addCompanion("liubiao")

-----苏飞-----

lianpian = sgs.CreateTriggerSkill{
	name = "lianpian",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.CardUsed then
			if player:getPhase() ~= sgs.Player_Play then return "" end
			if player:getMark("lianpianMark") >= getKingdoms(room) then return "" end
			local use = data:toCardUse()
			if use.card:isKindOf("BasicCard") or use.card:isKindOf("TrickCard") or use.card:isKindOf("EquipCard") then
				local toObjectName = player:getTag("lianpianTag"):toString():split("+")
				local can_invoke = false
				local toObjectName_str = ""
				for _, p in sgs.qlist(use.to) do 
					if table.contains(toObjectName, p:objectName()) then
						can_invoke = true
					end
					if toObjectName_str == "" then
						toObjectName_str = p:objectName()
					else 
						toObjectName_str = toObjectName_str .. "+" .. p:objectName()
					end
				end
				player:setTag("lianpianTag", sgs.QVariant(toObjectName_str))
				if can_invoke then
					return self:objectName()
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish then
				room:setPlayerMark(player, "lianpianMark", 0)
				player:setTag("lianpianTag", sgs.QVariant(""))
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName())
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		player:drawCards(1)
		room:addPlayerMark(player, "lianpianMark")
		return false
	end
}

sufei_wu:addSkill(lianpian)
sufei_qun:addSkill(lianpian)
sufei_wu:addCompanion("ganning")

-----黄权-----

dianhu = sgs.CreateTriggerSkill{
	name = "dianhu",
	can_preshow = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GeneralShown, sgs.Damage, sgs.EventPhaseEnd, sgs.EventPhaseStart, sgs.Death},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		if event == sgs.GeneralShown then
			if not player:hasSkill(self:objectName()) then return "" end
			if data:toBool() ~= player:inHeadSkills(self:objectName()) then return "" end
			return self:objectName()
		elseif event == sgs.EventPhaseStart then
			if not player:hasSkill(self:objectName()) then return "" end
			if not player:hasShownSkill(self:objectName()) then return "" end
			if player:getPhase() == sgs.Player_Start then
				local has_hu = false
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do 
					if p:getMark("@hu") > 0 then
						has_hu = true
					end
				end
				if not has_hu then
					return self:objectName()
				end
			end
		elseif event == sgs.Damage then
			if not player:hasSkill(self:objectName()) then return "" end
			if player:getMark("dianhuLimit") >= getKingdoms(room) then return "" end
			local damage = data:toDamage()
			if damage.to and damage.to:getMark("@hu") > 0 then 
				local trigger_list = {}
				for i = 1, damage.damage, 1 do
					table.insert(trigger_list, self:objectName())
				end
				return table.concat(trigger_list, ",")
			end
		elseif event == sgs.Death then
			if not player:hasSkill(self:objectName()) then return "" end
			local death = data:toDeath()
			if death.who:getMark("@hu") > 0 and death.damage and death.damage.from:objectName() == player:objectName() then
				return self:objectName()
			end
		elseif event == sgs.EventPhaseEnd then
			if player:getPhase() == sgs.Player_Finish then
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					room:setPlayerMark(p, "dianhuLimit", 0)
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if event == sgs.Damage or event == sgs.Death then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 2)
			return true
		elseif event == sgs.GeneralShown or event == sgs.EventPhaseStart then
			room:notifySkillInvoked(player, self:objectName())
			room:broadcastSkillInvoke(self:objectName(), 1)
			local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), self:objectName().."-invoke", false, true)
			if not to then
				to = room:getOtherPlayers(player):first()
			end
			local _data = sgs.QVariant()
			_data:setValue(to)
			player:setTag("dianhuTarget", _data)
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if event == sgs.Damage then
			local damage = data:toDamage()
			player:drawCards(1)
			room:addPlayerMark(player, "dianhuLimit")
		elseif event == sgs.Death then
			local count = player:getMaxHp()
			local mhp = sgs.QVariant()
			mhp:setValue(count + 1)
			room:setPlayerProperty(player, "maxhp", mhp)
		elseif event == sgs.GeneralShown or event == sgs.EventPhaseStart then
			local to = player:getTag("dianhuTarget"):toPlayer()
			player:removeTag("dianhuTarget")
			to:gainMark("@hu")
		end
		return false
	end,
}

jianji = sgs.CreateViewAsSkill{
	name = "jianji",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then return false
		else
			local id = sgs.Self:property("jianjiProp"):toInt()
			return id == to_select:getId()
		end
	end,
	view_as = function(self) 
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local card = jianjiCard:clone()
			card:setShowSkill(self:objectName())
			return card
		else
			local id = sgs.Self:property("jianjiProp"):toInt()
			local card = sgs.Sanguosha:getCard(id)
			local acard = sgs.Sanguosha:cloneCard(card:objectName(), card:getSuit(), card:getNumber())
			acard:setSkillName("jianji")
			acard:addSubcard(card)
			return acard
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#jianjiCard")
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@jianji"
	end
}
jianjiCard = sgs.CreateSkillCard{
	name = "jianjiCard",
	skill_name = "jianji",
	target_fixed = false,
	mute = true,
	filter = function(self, targets, to_select, player)
		return sgs.Self:getKingdom() == to_select:getKingdom() and to_select:getRole() ~= "careerist"
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_use = function(self, room, source, targets)
		room:broadcastSkillInvoke("jianji")
		local to = targets[1]
		local card_ids = room:getNCards(1, true)
		local id = card_ids:first()
		local card = sgs.Sanguosha:getCard(id)
		room:obtainCard(to, id)
		local can_use = true
		if card:isKindOf("Jink") or card:isKindOf("Nullification") then
			can_use = false
		end
		if card:isKindOf("Peach") and not to:isWounded() then
			can_use = false
		end
		if card:isKindOf("EquipCard") then 
			if room:askForSkillInvoke(to, "jianji", sgs.QVariant("jianjiUse:" .. id .. "::" .. card:objectName())) then
				room:useCard(sgs.CardUseStruct(card, to, to))
			end
		else
			if can_use then
				room:setPlayerProperty(to, "jianjiProp", sgs.QVariant(id))
				room:askForUseCard(to, "@@jianji", ("#jianji:%s:%s:%s:%s"):format(card:objectName(),card:getSuitString(),card:getNumber(),card:getEffectiveId()))
				room:setPlayerProperty(to, "jianjiProp", sgs.QVariant(-1))
			end
		end
	end
}
huangquan_shu:addSkill(dianhu)
huangquan_wei:addSkill(dianhu)
huangquan_shu:addSkill(jianji)
huangquan_wei:addSkill(jianji)

-----唐咨-----

xingzhao = sgs.CreateTriggerSkill{
	name = "xingzhao",
	can_preshow = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardUsed, sgs.EventPhaseStart, sgs.DrawNCards},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.DrawNCards then
			if player:getEquips():length() > 0 then
				return "xunxun_tangzi", player
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Discard then
				if player:getEquips():length() > 2 then
					return self:objectName()
				end
			end
		elseif event == sgs.CardUsed then
			if player:getEquips():length() > 1 then
				local use = data:toCardUse()
				if use.card:isKindOf("EquipCard") then
					return self:objectName()
				end
			end
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		room:notifySkillInvoked(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		return true
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if event == sgs.EventPhaseStart then
			player:gainMark("@shangxianjiayi", 2)
		elseif event == sgs.CardUsed then
			player:drawCards(1)
		end
	end
}
xunxun_tangzi = sgs.CreateTriggerSkill{
	name = "xunxun_tangzi",
	can_preshow = true,
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawNCards},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill("xingzhao")) then return "" end
		if event == sgs.DrawNCards then
			return self:objectName()
		end
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if event == sgs.DrawNCards then
			if player:askForSkillInvoke("xunxun", data) then
				player:showGeneral(player:inHeadSkills("xingzhao"))
				room:notifySkillInvoked(player, "xunxun")
				room:broadcastSkillInvoke("xunxun_tangzi")
				return true 
			end
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		if event == sgs.DrawNCards then
			data:setValue(0)
			room:setPlayerMark(player,"xunxunTangziMark",0)
			local card_ids = room:getNCards(4, true)
			
			local notify_visible_list = sgs.IntList()
			notify_visible_list:append(-1)
			local result = room:askForMoveCards(player, card_ids, sgs.IntList(), true, "xunxun", "", "xunxun", 2, 2, false, false, notify_visible_list)
			local dummy = sgs.DummyCard()
			if not result.bottom:isEmpty() then
				dummy:addSubcards(result.bottom)
				player:obtainCard(dummy, false)
			end
			if not result.top:isEmpty() then
				dummy:clearSubcards()
				dummy:addSubcards(result.top)
				room:moveCardTo(dummy, player, sgs.Player_DrawPileBottom)
			end
			dummy:deleteLater()
		end
		return false
	end
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("xunxun_tangzi") then
skillList:append(xunxun_tangzi)
end
sgs.Sanguosha:addSkills(skillList)	
	
tangzi_wei:addSkill(xingzhao)
tangzi_wu:addSkill(xingzhao)

sgs.LoadTranslationTable{
	["extension_multy"] = "多势力武将包",
	["liuqi_shu"] = "刘琦",
	["liuqi_qun"] = "刘琦",
	["#liuqi_shu"] = "抽梯问计",
	["#liuqi_qun"] = "抽梯问计",
	["~liuqi_shu"] = "父亲，孩儿来见你啦。",
	["~liuqi_qun"] = "父亲，孩儿来见你啦。",
	["wenji"] = "问计",
	[":wenji"] = "一名与你势力相同的其他角色出牌阶段开始时，你可以令其选择是否交给你一张牌。若其选择是，直到你的下个回合结束后，当你使用该牌时（非转化），其摸两张牌。",
	["$wenji1"] = "还望先生救我。",
	["$wenji2"] = "言出子口，入于吾耳，可以言未？",
	["tunjiang"] = "屯江",
	[":tunjiang"] = "结束阶段开始时，若你本回合使用的牌数少于你的体力值或者没有触发问计令其他角色摸牌，你可以摸两张牌。",
	["benzhi"] = "奔职",
	[":benzhi"] = "结束阶段开始时，若你本回合使用的牌数不少于你的体力值或者触发过问计令其他角色摸牌，你可以令其他角色计算与你的距离+1直到你的下个回合开始时。",
	["$tunjiang1"] = "江夏冲要之地，孩儿愿往守之。",
	["$tunjiang2"] = "皇叔勿惊，吾与关将军已到。",
	["$benzhi1"] = "江夏冲要之地，孩儿愿往守之。",
	["$benzhi2"] = "皇叔勿惊，吾与关将军已到。",
	
	["huangquan_shu"] = "黄权",
	["huangquan_wei"] = "黄权",
	["#huangquan_shu"] = "车骑将军",
	["#huangquan_wei"] = "车骑将军",
	["~huangquan_shu"] = "魏王厚待与我，降魏又有何错？",
	["~huangquan_wei"] = "魏王厚待与我，降魏又有何错？",
	["dianhu"] = "点虎",
	[":dianhu"] = "锁定技，你亮出该武将牌时，或者你的回合开始时且场上没有带“虎”标记的角色且你已亮出此武将牌时，你指定一名其他角色，其获得“虎”标记。当你对有“虎”标记的角色造成1点伤害后，若你于此回合以此法摸牌的数量少于场上存活势力数，你摸一张牌；当你杀死带有“虎”标记的角色后，你增加一点体力上限,然后失去此技能。",
	["$dianhu1"] = "预则立，不预则废",
	["$dianhu2"] = "就用你，给我军祭旗",
	["jianji"] = "谏计",
	[":jianji"] = "出牌阶段限一次，你可以令一名与你势力相同的角色摸一张牌，然后其可以使用该牌。",
	["$jianji1"] = "锦上添花，不如雪中送炭",
	["$jianji2"] = "密计交于将军，可解燃眉之困",
	["dianhu-invoke"] = "请指定一名被点虎角色",
	["#jianji"] = "你可以使用该牌： 【%src】",
	["jianjiCard:jianjiUse"] = "你可以使用该牌： 【%arg】",
	["@hu"] = "虎",
	
	["sufei_qun"] = "苏飞",
	["sufei_wu"] = "苏飞",
	["#sufei_qun"] = "江夏都督",
	["#sufei_wu"] = "军都督",
	["~sufei_qun"] = "空不能再与兴霸兄并肩奋战了。。。",
	["~sufei_wu"] = "空不能再与兴霸兄并肩奋战了。。。",
	["lianpian"] = "联翩",
	[":lianpian"] = "出牌阶段限x次（x为场上的势力数），你于出牌阶段使用牌连续指定同一名角色为目标后，你可以摸一张牌。",
	["$lianpian1"] = "心无旁骛，断而敢行。",
	["$lianpian2"] = "需持续投入，方有回报。",
	
	["tangzi_wei"] = "唐咨",
	["tangzi_wu"] = "唐咨",
	["#tangzi_wei"] = "安远将军",
	["#tangzi_wu"] = "安远将军",
	["~tangzi_wei"] = "偷工减料，要不得呀！",
	["~tangzi_wu"] = "偷工减料，要不得呀！",
	["xingzhao"] = "兴棹",
	[":xingzhao"] = "锁定技，当你装备区的装备数量为：1个或以上，你视为拥有技能恂恂；2个或以上，你使用装备牌时摸一张牌；3个或以上，你的手牌上限+2；4个或以上，你所属的势力成为唯一的大势力。",
	["$xingzhao1"] = "拿些上好的木料来。",
	["$xingzhao2"] = "精挑细选，方能成百年之计。",
	["$xunxun_tangzi1"] = "船也不是一天就能造出来的。",
	["$xunxun_tangzi2"] = "让我先探他一探。",
	["xunxun_tangzi"] = "恂恂",
	
}
return {extension_multy}