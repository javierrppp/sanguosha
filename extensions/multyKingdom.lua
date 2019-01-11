extension_multy = sgs.Package("extension_multy", sgs.Package_GeneralPack)

liuqi_qun = sgs.General(extension_multy, "liuqi_qun", "qun", 3, true, true, false)
liuqi_shu = sgs.General(extension_multy, "liuqi_shu", "shu", 3, true, true, false)
huangquan_shu = sgs.General(extension_multy, "huangquan_shu", "shu", 3, true, true, false)
huangquan_wei = sgs.General(extension_multy, "huangquan_wei", "wei", 3, true, true, false)
sufei_qun = sgs.General(extension_multy, "sufei_qun", "qun", 4, true, true, false)
sufei_wu = sgs.General(extension_multy, "sufei_wu", "wu", 4, true, true, false)
tangzi_wei = sgs.General(extension_multy, "tangzi_wei", "wei", 4, true, true, false)
tangzi_wu = sgs.General(extension_multy, "tangzi_wu", "wu", 4, true, true, false)
machao_qun = sgs.General(extension_multy, "machao_qun", "qun", 4, true, true, false)
jiangwei_wei = sgs.General(extension_multy, "jiangwei_wei", "wei", 3, true, true, false)
sunshangxiang_shu = sgs.General(extension_multy, "sunshangxiang_shu", "shu", 4, false, true, false)


-----刘琦-----

wenjiVS = sgs.CreateOneCardViewAsSkill{
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
	
wenji = sgs.CreateTriggerSkill{
	name = "wenji",
	can_preshow = true,
	--global = true,
	view_as_skill = wenjiVS,
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
--liuqi_qun:addSkill(wenji_ask_card)
liuqi_qun:addSkill(benzhi)
liuqi_qun:addSkill(benzhi_distance)
liuqi_shu:addSkill(wenji)
--liuqi_shu:addSkill(wenji_ask_card)
liuqi_shu:addSkill(tunjiang)
--sgs.insertRelatedSkills(extension, "wenji", "#wenji_ask_card")
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
				if player:getTag("lianpianTag"):toString() == "" or player:getTag("lianpianTag") == nil then can_invoke = false end
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
			room:detachSkillFromPlayer(player,self:objectName())
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
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local card = jianjiCard:clone()
			card:setShowSkill(self:objectName())
			return card
		else
			return cards[1]
			--[[local id = sgs.Self:property("jianjiProp"):toInt()
			local card = sgs.Sanguosha:getCard(id)
			local acard = sgs.Sanguosha:cloneCard(card:objectName(), card:getSuit(), card:getNumber())
			acard:setSkillName("jianji")
			acard:addSubcard(card)
			return acard--]]
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
		--[[if card:isKindOf("EquipCard") then 
			if room:askForSkillInvoke(to, "jianji", sgs.QVariant("jianjiUse:" .. id .. "::" .. card:objectName())) then
				room:useCard(sgs.CardUseStruct(card, to, to))
			end
		else--]]
			if can_use then
				room:setPlayerProperty(to, "jianjiProp", sgs.QVariant(id))
				room:askForUseCard(to, "@@jianji", ("#jianji:%s:%s:%s:%s"):format(card:objectName(),card:getSuitString(),card:getNumber(),card:getEffectiveId()))
				room:setPlayerProperty(to, "jianjiProp", sgs.QVariant(-1))
			end
		--end
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

-----马超-----

shichou = sgs.CreateTriggerSkill{
	name = "shichou",
	can_preshow = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return "" end
		if use.from:hasSkill(self:objectName()) and player:objectName() == use.from:objectName() then
			if player:isWounded() then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		local targets = sgs.SPlayerList()
		local use = data:toCardUse()
		local card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do 
			if not use.to:contains(p) then
				if not player:isProhibited(p, card) and player:inMyAttackRange(p) then
					targets:append(p)
				end
			end
		end
		local lost_hp = player:getMaxHp() - player:getHp()
		local target_choose = room:askForPlayersChosen(player,targets,self:objectName(),0,lost_hp,self:objectName().."-invoke:::"..lost_hp,true)
		if target_choose:length() > 0 then
			room:broadcastSkillInvoke(self:objectName())
			local targets_list = {}
			for _, p in sgs.qlist(target_choose) do
				table.insert(targets_list, p:objectName())
			end
			player:setTag("shichouTag", sgs.QVariant(table.concat(targets_list, "+")))
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		local targets_list = player:getTag("shichouTag"):toString():split("+")
		player:setTag("shichouTag", sgs.QVariant(""))
		local use = data:toCardUse()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do 
			if table.contains(targets_list, p:objectName()) then
				use.to:append(p)
			end
		end
		data:setValue(use)
	end
}
		
		
machao_qun:addSkill(shichou)
machao_qun:addSkill("mashu_machao")
machao_qun:addCompanion("mateng")

-----姜维*魏-----

function zhanxingPattern(selected, to_select)
	return true --to_select:hasFlag("zhanxing_flag")
end
zhanxing = sgs.CreateTriggerSkill{
	name = "zhanxing",
	frequency = sgs.Skill_Compulsory,
	relate_to_place = "head",
	events = {sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		local move = data:toMoveOneTime()
		if not move.to or player:objectName() ~= move.to:objectName() then return "" end
		--if not move.from_places:contains(sgs.Player_PlaceHand) and not move.from_places:contains(sgs.Player_PlaceEquip) and (move.to_place == sgs.Player_PlaceHand) then
		if move.to_place == sgs.Player_PlaceHand then
			if not sgs.Sanguosha:getCard(move.card_ids:first()):hasFlag("zhanxing_flag") then 
				return self:objectName()
			end
		end
		for _, c in sgs.qlist(move.card_ids) do 
			local ccc = sgs.Sanguosha:getCard(c)
			room:setCardFlag(ccc, "-zhanxing_flag", player)
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if not player:hasShownSkill(self:objectName()) and room:askForSkillInvoke(player,self:objectName(),data) then
			return true
		end
		if player:hasShownSkill(self:objectName()) then
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		--[[room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local move = data:toMoveOneTime()
		local notify_visible_list = sgs.IntList()
		notify_visible_list:append(-1)
		local num = move.card_ids:length()
		local card_ids = room:getNCards(num, true)
		for _,id in sgs.qlist(move.card_ids) do
			card_ids:append(id)
		end
		local result = room:askForMoveCards(player, card_ids, sgs.IntList(), true, "zhanxing", "", self:objectName(), num, num, false, false, notify_visible_list)
		local move_card_ids = sgs.IntList()
		for _, id in sgs.qlist(result.bottom) do
			move_card_ids:prepend(id) 
		end
		if move_card_ids:length() > 0 then
			move.card_ids = move_card_ids
			data:setValue(move)
		end
		local dummy = sgs.DummyCard()
		if not result.top:isEmpty() then
			dummy:addSubcards(result.top)
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		end
		dummy:deleteLater()--]]
		
		--[[room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local move = data:toMoveOneTime()
		local notify_visible_list = sgs.IntList()
		notify_visible_list:append(-1)
		local num = move.card_ids:length()
		local get_card_ids = move.card_ids
		local card_ids = room:getNCards(num, true)
		local result = room:askForMoveCards(player, card_ids, get_card_ids, true, "zhanxing", "", self:objectName(), num, num, false, false, notify_visible_list)
		local to_draw = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local to_discard = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, c in sgs.qlist(result.bottom) do
			if not get_card_ids:contains(c) then
				to_draw:addSubcard(c)
			end
			local ccc = sgs.Sanguosha:getCard(c)
			room:setCardFlag(ccc, "zhanxing_flag", player)
		end
		for _, c in sgs.qlist(result.top) do
			--if get_card_ids:contains(c) then
				to_discard:addSubcard(c)
			--end
		end
		if to_draw:getSubcards():length() > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName(), player:objectName(), self:objectName(),"")
			room:moveCardTo(to_draw, player, sgs.Player_PlaceHand, reason)
		end
		if to_discard:getSubcards():length() > 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), player:objectName(), self:objectName(),"")
			room:moveCardTo(to_discard, player, sgs.Player_Discard, reason)
			--room:throwCard(to_discard, player)
		end--]]
		
		room:broadcastSkillInvoke(self:objectName())
		room:notifySkillInvoked(player, self:objectName())
		local move = data:toMoveOneTime()
		local num = move.card_ids:length()
		local card_ids = room:getNCards(num, true)
		local to_draw = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _,id in sgs.qlist(card_ids) do
			to_draw:addSubcard(id)
			room:setCardFlag(sgs.Sanguosha:getCard(id), "zhanxing_flag", player)
		end
		for _,id in sgs.qlist(move.card_ids) do
			room:setCardFlag(sgs.Sanguosha:getCard(id), "zhanxing_flag", player)
		end
		local prohibit = ""
		local prohibit_list = {}
		for _, card in sgs.qlist(player:getHandcards()) do 
			if not move.card_ids:contains(card:getId()) and not card_ids:contains(card:getId()) then
				if prohibit ~= "" then
					prohibit = prohibit.."+"
				end
				prohibit = prohibit.."^"..card:toString()
				table.insert(prohibit_list, card:getId())
			end
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName(), player:objectName(), self:objectName(),"")
		room:moveCardTo(to_draw, player, sgs.Player_PlaceHand, reason)
		local discard_card = room:askForExchange(player, self:objectName(), num, num, "zhanxing-discard:::"..num, "", prohibit)
		if not discard_card then
			discard_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, c in sgs.qlist(player:getHandcards()) do 
				if c:hasFlag("zhanxing_flag") then
					discard_card:addSubcard(c)
				end
			end
		end
		room:throwCard(discard_card, player)
	end
}
kunfen = sgs.CreateTriggerSkill{
	name = "kunfen",
	frequency = sgs.Skill_Frequent,
	relate_to_place = "deputy",
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:objectName() ~= room:getCurrent():objectName() then return "" end
		local move = data:toMoveOneTime()
		if not move.from then return "" end
		if move.from and move.from:objectName() ~= player:objectName() then return "" end
		if event == sgs.BeforeCardsMove then
			room:setPlayerMark(player,"kunfenMark",0)
			local reason = move.reason.m_reason
			local reasonx = bit32.band(reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
			local Yes = reasonx == sgs.CardMoveReason_S_REASON_DISCARD
			if Yes then
				local card
				local i = 0
				for _,id in sgs.qlist(move.card_ids) do
					card = sgs.Sanguosha:getCard(id)
					if move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip then
						if card and room:getCardOwner(id):getSeat() == player:getSeat() then
							i = i + 1
						end
					end
				end
				room:setPlayerMark(player,"kunfenMark",i)
				return ""
			end
		else
			if player:getMark("kunfenMark") > 0 then
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
		local num = player:getMark("kunfenMark")
		if num > 3 then num = 3 end
		player:drawCards(num)
		return false
	end
}
MtiaoxinCard = sgs.CreateSkillCard{
	name = "MtiaoxinCard" ,
	skill_name = "Mtiaoxin",
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:inMyAttackRange(sgs.Self) and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	feasible = function(self, targets)
		return #targets == 1
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:broadcastSkillInvoke("Mtiaoxin")
		local use_slash = false
		if effect.to:canSlash(effect.from, nil, false) then
			use_slash = room:askForUseSlashTo(effect.to,effect.from, "@tiaoxin-slash:" .. effect.from:objectName())
		end
		if (not use_slash) and effect.from:canDiscard(effect.to, "he") then
			room:throwCard(room:askForCardChosen(effect.from,effect.to, "he", "Mtiaoxin", false, sgs.Card_MethodDiscard), effect.to, effect.from)
		end
	end
}
Mtiaoxin = sgs.CreateZeroCardViewAsSkill{
	name = "Mtiaoxin",
	n = 0 ,
	view_as = function()
		return MtiaoxinCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#MtiaoxinCard")
	end
}
jiangwei_wei:addSkill(kunfen)
jiangwei_wei:addSkill(zhanxing)
jiangwei_wei:addSkill(Mtiaoxin)
jiangwei_wei:addCompanion("zhonghui")

-----孙尚香*蜀-----

shaluXiaoji = sgs.CreateTriggerSkill{
	name = "shaluXiaoji" ,
	frequency = sgs.Skill_Frequent ,
	relate_to_place = "head",
	events = {sgs.CardsMoveOneTime} ,
	can_trigger = function(self, event, room, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:hasSkill(self:objectName()) and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			for i = 0, move.card_ids:length() - 1, 1 do
				if not player:isAlive() then return false end
				if move.from_places:at(i) == sgs.Player_PlaceEquip then
					return self:objectName()
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
		player:drawCards(2)
		return false
	end
}
liangzhu = sgs.CreateTriggerSkill{
	name = "liangzhu" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.HpRecover} ,
	relate_to_place = "deputy",
	can_trigger = function(self, event, room, player, data)
		local room = player:getRoom()
		local recover = data:toRecover()
		if not (player and player:isAlive()) then return "" end
		local skill_list,player_list = {},{}
		if player:getPhase() == sgs.Player_Play then
			local sunshangxiangs = room:findPlayersBySkillName(self:objectName())
			if sunshangxiangs:length() > 0 then
				for _, sunshangxiang in sgs.qlist(sunshangxiangs) do
					table.insert(skill_list, self:objectName())
					table.insert(player_list, sunshangxiang:objectName())
				end
			end
		end
		if #skill_list > 0 then
			return table.concat(skill_list,"|"), table.concat(player_list,"|")
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
		local recover = data:toRecover()
		local choices = {"me_draw"}
		local drawNum = 1
		if ask_who:getMark("@fanxiangMark") == 0 then
			drawNum = 2
		end
		table.insert(choices, "not_me_draw" .. drawNum)
		local choice = room:askForChoice(ask_who, "liangzhu", table.concat(choices, "+"))
		if choice == "me_draw" then
			ask_who:drawCards(1)
		else
			player:drawCards(drawNum)
		end
		return false
	end
}
fanxiangCard = sgs.CreateSkillCard{
	name = "fanxiangCard",
	skill_name = "fanxiang",
	target_fixed = false,
	will_throw = false,
	mute = true,
	filter = function(self, targets, to_select, player) 
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return #targets == 1
	end,
	about_to_use = function(self, room, cardUse)
		room:removePlayerMark(cardUse.from, "@fanxiangMark")
		room:broadcastSkillInvoke("fanxiang", cardUse.from)
		room:doSuperLightbox("sunshangxiang_shu", "fanxiang")
		self:cardOnUse(room, cardUse)
	end,
	on_use = function(self, room, source, targets)
		local to = targets[1]
		room:swapSeat(source, to)
		local recover = sgs.RecoverStruct()
		recover.who = source
		room:recover(source, recover)
	end,
}
fanxiangVS = sgs.CreateZeroCardViewAsSkill{   
	name = "fanxiang",
	view_as = function(self)
		local skillcard = fanxiangCard:clone()
		skillcard:setSkillName(self:objectName())
		skillcard:setShowSkill(self:objectName())
		return skillcard
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@fanxiangMark") > 0 and player:isWounded()
	end,
}
fanxiang = sgs.CreateTriggerSkill{
	name = "fanxiang",
	can_preshow = false,
	relate_to_place = "deputy",
	events = {sgs.ChoiceMade},
	frequency = sgs.Skill_Limited,
	limit_mark = "@fanxiangMark", 
	view_as_skill = fanxiangVS,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
sunshangxiang_shu:addSkill(shaluXiaoji)
sunshangxiang_shu:addSkill(liangzhu)
sunshangxiang_shu:addSkill(fanxiang)
sunshangxiang_shu:addCompanion("liubei")
sunshangxiang_shu:setDeputyMaxHpAdjustedValue(-1)

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
	["#wenji_ask_card"] = "问计",
	["@wenji-card"] = "你可以将一张牌交给%src",
	
	["huangquan_shu"] = "黄权",
	["huangquan_wei"] = "黄权",
	["#huangquan_shu"] = "车骑将军",
	["#huangquan_wei"] = "车骑将军",
	["~huangquan_shu"] = "魏王厚待与我，降魏又有何错？",
	["~huangquan_wei"] = "魏王厚待与我，降魏又有何错？",
	["dianhu"] = "点虎",
	[":dianhu"] = "锁定技，你亮出该武将牌时，或者你的回合开始且场上没有带“虎”标记的角色且你已亮出此武将牌时，你指定一名其他角色，其获得“虎”标记。当你对有“虎”标记的角色造成1点伤害后，若你于此回合以此法摸牌的数量少于场上存活势力数，你摸一张牌；当你杀死带有“虎”标记的角色后，你增加一点体力上限,然后失去此技能。",
	["$dianhu1"] = "预则立，不预则废",
	["$dianhu2"] = "就用你，给我军祭旗",
	["jianji"] = "谏计",
	[":jianji"] = "出牌阶段限一次，你可以令一名与你势力相同的角色摸一张牌，然后其可以使用该牌。",
	["$jianji1"] = "锦上添花，不如雪中送炭",
	["$jianji2"] = "秘计交于将军，可解燃眉之困",
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
	
	["machao_qun"] = "马超",
	["#machao_qun"] = "威震西凉",
	["~machao_qun"] = "西凉，回不去啦。",
	["shichou"] = "誓仇",
	[":shichou"] = "你使用【杀】可以多选择至多X名角色为目标（X为你已经损失的体力值）。",
	["$shichou1"] = "灭族之恨，不共戴天！",
	["$shichou2"] = "休想跑！",
	["shichou-invoke"] = "你可以额外选择%arg名角色",
	
	["jiangwei_wei"] = "姜维",
	["#jiangwei_wei"] = "幼麟",
	["~jiangwei_wei"] = "伯约已尽力而为，奈何大汉国运衰微。",
	["Mtiaoxin"] = "挑衅",
	[":Mtiaoxin"] = "出牌阶段限一次，你可以令攻击范围内含有你的一名角色选择是否对你使用【杀】，若其选择否，你弃置其一张牌。",
	["$Mtiaoxin1"] = "今日天公作美，怎能不战而退？",
	["$Mtiaoxin2"] = "贼将无胆，何不早降？",
	["kunfen"] = "困奋",
	[":kunfen"] = "副将技，你的回合内，当你的牌因弃置而进入弃牌堆时，你可以摸等量的牌（最多3张）。",
	["$kunfen1"] = "纵使困顿难行，亦当砥砺奋进！",
	["$kunfen2"] = "心数虚实，众将切勿惫怠！",
	["zhanxing"] = "占星",
	[":zhanxing"] = "主将技，锁定技，当你获得牌时，你摸x张牌，然后你从这些牌中弃置x张牌（x为你获得的牌数）。",
	["$zhanxing1"] = "得遇丞相，再生之德！",
	["$zhanxing2"] = "丞相大义，维岂有不从之理！",
	["tiaoxin-slash"] = "请对 %src 使用一张【杀】，否则其弃置你一张牌",
	["@zhanxing"] = "替换其中的牌",
	["zhanxing#up"] = "弃置",
	["zhanxing#down"] = "获取",
	["zhanxing-discard"] = "请弃置 %arg 张牌",
	
	["sunshangxiang_shu"] = "孙尚香",
	["#sunshangxiang_shu"] = "乱世巾帼",
	["shaluXiaoji"] = "枭姬",
	[":shaluXiaoji"] = "主将技，每当你失去装备区里的装备牌后，你可以摸两张牌。",
	["$shaluXiaoji1"] = "双剑夸巧，不让须眉！",
	["$shaluXiaoji2"] = "弓马何须忌红妆？",
	["liangzhu"] = "良助",
	[":liangzhu"] = "副将技，此武将牌上单独的阴阳鱼个数-1，当一名角色于其出牌阶段内回复体力后，你可以选择一项：1.摸一张牌；2.令其摸一张牌（若你已发动限定技，则这一项更改为2）。",
	["$liangzhu1"] = "吾愿携弩，征战沙场，助君一战！",
	["$liangzhu2"] = "两国结盟，你我都是一家人！",
	["fanxiang"] = "返乡",
	[":fanxiang"] = "副将技，限定技，出牌阶段，若你已受伤，你可以指定一名其他角色，你与其交换位置，然后你回复一点体力。",
	["$fanxiang1"] = "兄命难违，从此两别…",
	["$fanxiang2"] = "今夕一别，不知何日再见…",
	["me_draw"] = "摸1张牌",
	["not_me_draw1"] = "其摸1张牌",
	["not_me_draw2"] = "其摸2张牌",
}
return {extension_multy}