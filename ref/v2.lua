--[[
	技能代码速查手册
	适用版本：新1005版
	简介：本手册分为A~Z共26个章节，分别以技能名第一个字的拼音首字母归类，其中ChapterV用于存放一些待完善的技能。
]]--
-----------
--[[A区]]--
-----------
--[[技能名：安娴
	相关武将：☆SP·大乔
	描述：每当你使用【杀】对目标角色造成伤害时，你可以防止此伤害：若如此做，该角色弃置一张手牌，然后你摸一张牌。每当你成为【杀】的目标时，你可以弃置一张手牌：若如此做，此【杀】的使用者摸一张牌，此【杀】对你无效。
	引用：LuaAnxian
	状态：0405验证通过
]]--
LuaAnxian = sgs.CreateTriggerSkill{
	name = "LuaAnxian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused, sgs.TargetConfirming},
	on_trigger = function(self, event, daqiao, data)
		local room = daqiao:getRoom()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash")
				and damage.by_user and not damage.chain and not damage.transfer
				and daqiao:askForSkillInvoke(self:objectName(), data) then
				local log = sgs.LogMessage()
				log.type = "#Anxian"
				log.from = daqiao
				log.arg = self:objectName()
				room:sendLog(log)
				if damage.to:canDiscard(damage.to, "h") then
					room:askForDiscard(damage.to, "LuaAnxian", 1, 1)
				end
				daqiao:drawCards(1, self:objectName())
				return true
			end
		elseif event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if not use.to:contains(daqiao) or not daqiao:canDiscard(daqiao, "h") then
				return false 
			end
			if use.card:isKindOf("Slash") then
				daqiao:setFlags("-AnxianTarget")
				if room:askForCard(daqiao, ".", "@anxian-discard", data, self:objectName()) then
					daqiao:setFlags("AnxianTarget")
					use.from:drawCards(1, self:objectName())
					if daqiao:isAlive() and daqiao:hasFlag("AnxianTarget") then
						daqiao:setFlags("-AnxianTarget")
						local nullified_list = use.nullified_list
						table.insert(nullified_list, daqiao:objectName())
						use.nullified_list = nullified_list
						data:setValue(use)
					end
				end
			end
		end
	end
}
--[[技能名：安恤
	相关武将：二将成名·步练师
	描述：出牌阶段，你可以选择两名手牌数不相等的其他角色，令其中手牌少的角色获得手牌多的角色的一张手牌并展示之，若此牌不为黑桃，你摸一张牌。每阶段限一次。
]]--
LuaAnxuCard = sgs.CreateSkillCard{
	name = "LuaAnxuCard",
	filter = function(self, targets, to_select, player)
		if to_select:objectName() == player:objectName() then return false end
		if #targets == 0 then
			return true
		elseif #targets == 1 then
			return to_select:getHandcardNum() ~= targets[1]:getHandcardNum()
		else
			return false
		end
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		local from, to
		if targets[1]:getHandcardNum() < targets[2]:getHandcardNum() then
			from = targets[1]
			to = targets[2]
		else
			from = targets[2]
			to = targets[1]
		end
		local id = room:askForCardChosen(from, to, "h", "LuaAnxu")
		local cd = sgs.Sanguosha:getCard(id)
		from:obtainCard(cd)
		room:showCard(from, id)
		if cd:getSuit() ~= sgs.Card_Spade then
			source:drawCards(1, "LuaAnxu")
		end
	end
}
LuaAnxu = sgs.CreateZeroCardViewAsSkill{
	name = "LuaAnxu",
	view_as = function() 
		return LuaAnxuCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaAnxuCard")
	end,
}
--[[技能名：暗箭（锁定技）
	相关武将：一将成名2013·潘璋&马忠
	描述：锁定技。每当你使用【杀】对目标角色造成伤害时，若你不在其攻击范围内，此伤害+1。
	引用：LuaAnjian
	状态：0405验证通过
]]--
LuaAnjian = sgs.CreateTriggerSkill{
	name = "LuaAnjian",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.chain or damage.transfer or not damage.by_user then return false end
		if damage.from and not damage.to:inMyAttackRange(damage.from)
			and damage.card and damage.card:isKindOf("Slash") then
			room:notifySkillInvoked(damage.from, self:objectName())
			damage.damage = damage.damage + 1
			data:setValue(damage)
        	end
        	return false
	end
}
--[[技能名：傲才
	相关武将：SP·诸葛恪
	描述：你的回合外，每当你需要使用或打出一张基本牌时，你可以观看牌堆顶的两张牌，然后使用或打出其中一张该类别的基本牌。
	状态：0405验证通过[与源码略有区别]
	引用：LuaAocai
]]--
local json = require("json")
function view(room, player, ids, enabled, disabled)
	local result = -1;
	local jsonLog = {
		"$ViewDrawPile",
		player:objectName(),
		"",
		table.concat(sgs.QList2Table(ids),"+"),
		"",
		""
	}
	room:doNotify(player, sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
	room:notifySkillInvoked(player, "LuaAocai")
	if enabled:isEmpty() then
		local jsonValue = {
			".",
			false,
			sgs.QList2Table(ids)
		}
		room:doNotify(player,sgs.CommandType.S_COMMAND_SHOW_ALL_CARDS, json.encode(jsonValue))
	else
		room:fillAG(ids, player, disabled)
		local id = room:askForAG(player, enabled, true, "LuaAocai");
		if id ~= -1 then
			ids:removeOne(id)
			result = id
		end
		room:clearAG(player)
	end
	room:returnToTopDrawPile(ids)--用这个函数将牌放回牌堆顶
	if result == -1 then
		room:setPlayerFlag(player, "Global_LuaAocaiFailed")
	end
	return result
end
LuaAocaiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaAocai",
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		if player:getPhase() ~= sgs.Player_NotActive or player:hasFlag("Global_LuaAocaiFailed") then return end
		if pattern == "slash" then
			return sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
		elseif pattern == "peach" then
			return not player:hasFlag("Global_PreventPeach")
		elseif string.find(pattern, "analeptic") then
			return true
		end
		return false
	end,
	view_as = function(self)
		local acard = LuaAocaiCard:clone()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "peach+analeptic" and sgs.Self:hasFlag("Global_PreventPeach") then
			pattern = "analeptic"
		end
		acard:setUserString(pattern)
		return acard
	end
}
LuaAocai = sgs.CreateTriggerSkill{
	name = "LuaAocai",
	view_as_skill = LuaAocaiVS,
	events = {sgs.CardAsked},
	on_trigger = function(self,event,player,data)
		if player:getPhase() ~= sgs.Player_NotActive then return end
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		if pattern == "slash" or pattern == "jink"
			and room:askForSkillInvoke(player, self:objectName(), data) then
			local ids = room:getNCards(2, false)
			local enabled, disabled = sgs.IntList(), sgs.IntList()
			for _,id in sgs.qlist(ids) do
				if string.find(sgs.Sanguosha:getCard(id):objectName(), pattern) then
					enabled:append(id)
				else
					disabled:append(id)
				end
			end
			local id = view(room, player, ids, enabled, disabled)
			if id ~= -1 then
				local card = sgs.Sanguosha:getCard(id)
				room:provide(card)
				return true
			end
		end
	end,
}
LuaAocaiCard = sgs.CreateSkillCard{
	name = "LuaAocaiCard",
	will_throw = false ,
	filter = function(self, targets, to_select)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name)
		end
		return card and card:targetFilter(plist, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, plist)
	end ,
	feasible = function(self, targets)
		local name = ""
		local card
		local plist = sgs.PlayerList()
		for i = 1, #targets do plist:append(targets[i]) end
		local aocaistring = self:getUserString()
		if aocaistring ~= "" then
			local uses = aocaistring:split("+")
			name = uses[1]
			card = sgs.Sanguosha:cloneCard(name)
		end
		return card and card:targetsFeasible(plist, sgs.Self)
	end,
	on_validate_in_response = function(self, user)
		local room = user:getRoom()
		local ids = room:getNCards(2, false)
		local aocaistring = self:getUserString()
		local names = aocaistring:split("+")
		if table.contains(names, "slash") then
			table.insert(names,"fire_slash")
			table.insert(names,"thunder_slash")
		end
		local enabled, disabled = sgs.IntList(), sgs.IntList()
		for _,id in sgs.qlist(ids) do
			if table.contains(names, sgs.Sanguosha:getCard(id):objectName()) then
				enabled:append(id)
			else
				disabled:append(id)
			end
		end
		local id = view(room, user, ids, enabled, disabled)
		return sgs.Sanguosha:getCard(id)
	end,
	on_validate = function(self, cardUse)
		cardUse.m_isOwnerUse = false
		local user = cardUse.from
		local room = user:getRoom()
		local ids = room:getNCards(2, false)
		local aocaistring = self:getUserString()
		local names = aocaistring:split("+")
		if table.contains(names, "slash") then
			table.insert(names, "fire_slash")
			table.insert(names, "thunder_slash")
		end
		local enabled, disabled = sgs.IntList(), sgs.IntList()
		for _,id in sgs.qlist(ids) do
			if table.contains(names, sgs.Sanguosha:getCard(id):objectName()) then
				enabled:append(id)
			else
				disabled:append(id)
			end
		end
		local id = view(room, user, ids, enabled, disabled)
		return sgs.Sanguosha:getCard(id)
	end
}
-----------
--[[B区]]--
-----------
 --[[技能名：悲鸣（锁定技）
	相关武将：闯关模式·魅
	描述：你死亡时，杀死你的其他角色弃置其所有手牌。
	引用：LuaBossBeiming
	状态：0405验证通过
]]--
LuaBossBeiming = sgs.CreateTriggerSkill{
	name = "LuaBossBeiming" ,
	events = {sgs.Death} ,
	frequency = sgs.Skill_Compulsory ,
	can_trigger = function(self, player)
		return target and target:hasSkill(self:objectName())
	end ,
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		local killer = death.damage and death.damage.from
		if killer and killer:objectName() ~= player:objectName() then
            	local log = sgs.LogMessage()
            	log.type = "#BeimingThrow"
            	log.from = player
            	log.to:append(killer)
            	log.arg = self:objectName()
            	room:sendLog(log);
            	room:notifySkillInvoked(player, self:objectName())
		room:broadcastSkillInvoke(self:objectName())
		killer:throwAllHandCards()
		return false
        end
    end
}
--[[技能名：北伐（锁定技）
	相关武将：智·姜维
	描述：锁定技。当你失去最后的手牌时，视为你对一名其他角色使用了一张【杀】，若不能如此做，则视为你对自己使用了一张【杀】
	引用：LuaBeifa
	状态：0405验证通过
]]--
LuaBeifa = sgs.CreateTriggerSkill{
	name = "LuaBeifa" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, jiangwei, data)
		local room = jiangwei:getRoom()
		local move = data:toMoveOneTime()
		if move.from and (move.from:objectName() == jiangwei:objectName()) and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard then
			local players = sgs.SPlayerList()
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName(self:objectName())
			for _, player in sgs.qlist(room:getOtherPlayers(jiangwei)) do
				if jiangwei:canSlash(player, slash, false) then
					players:append(player)
				end
			end
			local target = nil
			if not players:isEmpty() then
				target = room:askForPlayerChosen(jiangwei, players, self:objectName())--没有处理TargetMod
			end
			if (not target) and (not jiangwei:isProhibited(jiangwei, slash)) then
				target = jiangwei
			end
			if not target then return false end
			local use = sgs.CardUseStruct()
			use.card = slash
			use.from = jiangwei
			use.to:append(target)
			room:useCard(use)
		end
		return false
	end
}
--[[技能名：贲育
	相关武将：SP·程昱
	描述：每当你受到有来源的伤害后，若伤害来源存活，若你的手牌数：小于X，你可以将手牌补至X（至多为5）张；大于X，你可以弃置至少X+1张手牌，然后对伤害来源造成1点伤害。（X为伤害来源的手牌数）
	引用：LuaBeiyu
	状态：0405验证通过
]]--
LuaBenyuCard = sgs.CreateSkillCard{
	name = "LuaBenyuCard",
	will_throw = true,
	target_fixed = true
}
LuaBenyuVs = sgs.CreateViewAsSkill{
	name = "LuaBenyu",
	n = 998,
	response_pattern = "@@LuaBenyu",
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards < sgs.Self:getMark("LuaBenyu") then
			return nil
		end
		local vscard = LuaBenyuCard:clone()
		for _, i in ipairs(cards) do
			vscard:addSubcard(i)
		end
		return vscard
	end
}
LuaBenyu = sgs.CreateMasochismSkill{
	name = "LuaBenyu",
	view_as_skill = LuaBenyuVs,
	on_damaged = function(self, target, damage)
		if (not damage.from) or damage.from:isDead() then
			return false
		end
		local room = target:getRoom()
		local from_handcard_num, handcard_num = damage.from:getHandcardNum(), target:getHandcardNum()
		local data = sgs.QVariant()
		data:setValue(damage)
		if handcard_num == from_handcard_num then
			return false
		elseif handcard_num < from_handcard_num and handcard_num < 5 and room:askForSkillInvoke(target, self:objectName(), data) then
			room:drawCards(target, math.min(5, from_handcard_num) - handcard_num, self:objectName())
		elseif handcard_num > from_handcard_num then
			room:setPlayerMark(target, "LuaBenyu", from_handcard_num + 1)
			if room:askForUseCard(target, "@@LuaBenyu", "@benyu-discard::"..damage.from:objectName()..":"..tostring(from_handcard_num+1), -1, sgs.Card_MethodDiscard) then
				room:damage(sgs.DamageStruct(self:objectName(), target, damage.from))
			end
		end
		return false
	end
}
--[[技能名：暴凌（觉醒技）
	相关武将：势·董卓
	描述：出牌阶段结束时，若你本局游戏发动过“横征”，你增加3点体力上限，回复3点体力，然后获得“崩坏”。
	引用：LuaBaoling
	状态：0405验证通过
]]--
LuaBaoling = sgs.CreateTriggerSkill{
	name = "LuaBaoling",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:notifySkillInvoked(player, self:objectName())
		local log = sgs.LogMessage()
		log.type = "#BaolingWake"
		log.from = player
		log.arg = self:objectName()
		log.arg2 = "hengzheng"
		room:sendLog(log)
		room:setPlayerMark(player, "baoling", 1)
		if room:changeMaxHpForAwakenSkill(player, 3) then
			room:recover(player, sgs.RecoverStruct(player, nil, 3))
			if player:getMark("baoling") == 1 then
				room:acquireSkill(player, "benghuai")
			end
		end
	end,
	can_trigger = function(self, target)
		return target:getPhase() == sgs.Player_Play and target:getMark("baoling") == 0
			and target:getMark("HengzhengUsed") >= 1
	end
}
--[[技能名：霸刀
	相关武将：智·华雄
	描述：当你成为黑色的【杀】目标后，你可以使用一张【杀】
	引用：LuaBadao
	状态：0405验证通过
]]--
LuaBadao = sgs.CreateTriggerSkill{
	name = "LuaBadao" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.card:isBlack() and use.to:contains(player) then
			room:askForUseCard(player, "slash", "@askforslash")
		end
		return false
	end
}
--[[技能名：豹变（锁定技）
	相关武将：SP·夏侯霸
	描述：锁定技。若你的体力值为：3或更低，你拥有“挑衅”；2或更低，你拥有“咆哮”；1或更低，你拥有“神速”。
	引用：LuaBaobian
	状态：0405验证通过
]]--
function BaobianChange(room, player, hp, skill_name)
	local baobian_skills = player:getTag("BaobianSkills"):toString():split("+")	
	if player:getHp() <= hp then		
		if not table.contains(baobian_skills, skill_name) then			
			room:notifySkillInvoked(player, "LuaBaobian")
			if player:getHp() == hp then				
				room:broadcastSkillInvoke("baobian", 4 - hp)
			end			
			room:handleAcquireDetachSkills(player, skill_name)
			table.insert(baobian_skills, skill_name)
		end
	else
		if table.contains(baobian_skills, skill_name) then			
			room:handleAcquireDetachSkills(player, "-"..skill_name)
			table.removeOne(baobian_skills, skill_name)
		end
	end
	player:setTag("BaobianSkills", sgs.QVariant(table.concat(baobian_skills, "+")))	
end
LuaBaobian = sgs.CreateTriggerSkill{
	name = "LuaBaobian" ,
	events = {sgs.TurnStart, sgs.HpChanged, sgs.MaxHpChanged, sgs.EventAcquireSkill, sgs.EventLoseSkill} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)		
		local room = player:getRoom()
		if event == sgs.TurnStart then			
			local xiahouba = room:findPlayerBySkillName(self:objectName())
			if not xiahouba or not xiahouba:isAlive() then return false end
				BaobianChange(room, xiahouba, 1, "shensu")
				BaobianChange(room, xiahouba, 2, "paoxiao")
				BaobianChange(room, xiahouba, 3, "tiaoxin")
			end
		if event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				local baobian_skills = player:getTag("BaobianSkills"):toString():split("+")
				local detachList = {}
				for _, skill_name in ipairs(baobian_skills) do
					table.insert(detachList,"-"..skill_name)
				end
				room:handleAcquireDetachSkills(player, table.concat(detachList,"|"))
				player:setTag("BaobianSkills", sgs.QVariant())
			end
			return false
		elseif event == sgs.EventAcquireSkill then
			if data:toString() ~= self:objectName() then return false end
		end
		if not player:isAlive() or not player:hasSkill(self:objectName(), true) then return false end		
			BaobianChange(room, player, 1, "shensu")
			BaobianChange(room, player, 2, "paoxiao")
			BaobianChange(room, player, 3, "tiaoxin")		
		return false
	end ,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[技能名：豹变
	相关武将：TW一将成名·夏侯霸
	描述：当你使用【杀】或【决斗】对目标角色造成伤害时，若其势力与你：相同，你可以防止此伤害，令其将手牌补至X张（X为其体力上限）；不同且其手牌数大于其体力值，你可以弃置其Y张手牌（Y为其手牌数与体力值的差）。 
	引用：LuaTWBaobian
	状态：0405验证通过
]]--
LuaTWBaobian = sgs.CreateTriggerSkill{
	name = "LuaTWBaobian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and (damage.card:isKindOf("Slash") or damage.card:isKindOf("Duel"))
			and (not damage.chain) and (not damage.transfer) and damage.by_user then
			if damage.to:getKingdom() == player:getKingdom() then
				if player:askForSkillInvoke(self:objectName(), data) then
					if damage.to:getHandcardNum() < damage.to:getMaxHp() then
						local n = damage.to:getMaxHp() - damage.to:getHandcardNum()
						room:drawCards(damage.to, n, self:objectName())
					end
					return true
				end
			elseif damage.to:getHandcardNum() > math.max(damage.to:getHp(), 0) and player:canDiscard(damage.to, "h") then
				if player:askForSkillInvoke(self:objectName(), data) then
					local hc = damage.to:handCards()
					local n = damage.to:getHandcardNum() - math.max(damage.to:getHp(), 0)
					local dummy = sgs.Sanguosha:cloneCard("slash")
					math.randomseed(os.time())
					while n > 0 do
						local id = hc:at(math.random(0, hc:length() - 1))--取随机手牌代替askForCardChosen
						hc:removeOne(id)
						dummy:addSubcard(id)
						n = n - 1
					end
					room:throwCard(dummy, damage.to, player)
				end
			end
		end
	end
}
--[[技能名：暴敛（锁定技）
	相关武将：闯关模式·牛头，闯关模式·白无常
	描述：结束阶段开始时，你摸两张牌。 
	引用：LuaBossBaolian
	状态：0405验证通过
]]--
LuaBossBaolian = sgs.CreatePhaseChangeSkill{
	name = "LuaBossBaolian",
	frequency = sgs.Skill_Compulsory,
	priority = 4,
	on_phasechange = function(self, target)
		if target:getPhase() ~= sgs.Player_Finish then return false end
		local room = target:getRoom()
		room:broadcastSkillInvoke(self:objectName())
		room:sendCompulsoryTriggerLog(target, self:objectName())
		target:drawCards(2, self:objectName())
		return false
	end
}
--[[技能名：霸王
	相关武将：智·孙策
	描述：每当你使用的【杀】被【闪】抵消时，你可以与目标角色拼点：若你赢，可以视为你对至多两名角色各使用了一张【杀】（此杀不计入每阶段的使用限制）。
	引用：LuaBawang
	状态：0405验证通过
]]--
LuaBawangCard = sgs.CreateSkillCard{
	name = "LuaBawangCard" ,
	filter = function(self, targets, to_select)
		if #targets >= 2 then return false end
		return sgs.Self:canSlash(to_select, false)
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local slash = sgs.Sanguosha:cloneCard("slash" sgs.Card_NoSuit, 0)
		slash:setSkillName("LuaBawang")
		room:useCard(sgs.CardUseStruct(slash, effect.from, effect.to), false)
	end
}
LuaBawangVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaBawang" ,
	response_pattern = "@@LuaBawang" ,
	view_as = function()
		return LuaBawangCard:clone()
	end
}
LuaBawang = sgs.CreateTriggerSkill{
	name = "LuaBawang" ,
	events = {sgs.SlashMissed} ,
	view_as_skill = LuaBawangVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toSlashEffect()
		if (not effect.to:isNude()) and (not player:isKongcheng()) and (not effect.to:isKongcheng()) then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local success = player:pindian(effect.to, self:objectName(), nil)
				if success then
					if player:hasFlag("drank") then
						room:setPlayerFlag(player, "-drank")
					end
					room:askForUseCard(player, "@@LuaBawang", "@bawang")
				end
			end
		end
		return false
	end
}
--[[技能名：秉壹
	相关武将：一将成名2014·顾雍
	描述：结束阶段开始时，若你有手牌，你可以展示所有手牌：若均为同一颜色，你可以令至多X名角色各摸一张牌。（X为你的手牌数）
	引用：LuaBingyi
	状态：0405验证通过
]]--
LuaBingyiCard = sgs.CreateSkillCard{
	name = "LuaBingyiCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, player)
		local handcard = player:getHandcards()
		for _, cd in sgs.qlist(handcard) do
			if handcard:first():sameColorWith(cd) then continue end
			return false
		end
		return #targets < player:getHandcardNum()
	end,
	feasible = function(self, targets, player)
		local handcard = player:getHandcards()
		for _, cd in sgs.qlist(handcard) do
			if handcard:first():sameColorWith(cd) then continue end
			return #targets == 0
		end
		return #targets <= player:getHandcardNum()
	end,
	on_use = function(self, room, source, targets)
		room:showAllCards(source)
		for _, p in ipairs(targets) do
			room:drawCards(p, 1, "LuaBingyi")
		end
	end
}
LuaBingyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaBingyi",
	response_pattern = "@@LuaBingyi",
	view_as = function()
		return LuaBingyiCard:clone()
	end
}
LuaBingyi = sgs.CreatePhaseChangeSkill{
	name = "LuaBingyi",
	view_as_skill = LuaBingyiVS,
	on_phasechange = function(self, target)
		if target:getPhase() ~= sgs.Player_Finish or target:isKongcheng() then return false end
		target:getRoom():askForUseCard(target, "@@LuaBingyi", "@bingyi-card")
		return false
	end
}
--[[技能名：八阵（锁定技）
	相关武将：火·诸葛亮
	描述：若你的装备区没有防具牌，视为你装备着【八卦阵】。
]]--
LuaBazhen = sgs.CreateTriggerSkill{
	name = "LuaBazhen",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardAsked},
	on_trigger = function(self, event, wolong, data)
		local room = wolong:getRoom()
		local pattern = data:toStringList()[1]
		if pattern ~= "jink" then return false end
		if wolong:askForSkillInvoke("eight_diagram") then
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|red"
			judge.good = true
			judge.reason = "eight_diagram"
			judge.who = wolong
			judge.play_animation = true
			room:judge(judge)
			if judge:isGood() then
				room:setEmotion(wolong, "armor/EightDiagram");
				local jink = sgs.Sanguosha:cloneCard("jink", sgs.Card_NoSuit, 0)
				jink:setSkillName(self:objectName())
				room:provide(jink)
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) 
		and not target:getArmor() and not target:hasArmorEffect("eight_diagram")
	end
}
--[[技能名：拜印（觉醒技）
	相关武将：神·司马懿
	描述：回合开始阶段开始时，若你拥有4枚或更多的“忍”标记，你须减1点体力上限，并获得技能“极略”。
]]--
LuaBaiyin = sgs.CreatePhaseChangeSkill{
	name = "LuaBaiyin" ,
	frequency = sgs.Skill_Wake ,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:setPlayerMark(player,"LuaBaiyin", 1)
		if room:changeMaxHpForAwakenSkill(player) then
			room:acquireSkill(player, "jilve")
		end
		return false
	end ,
	can_trigger = function(self,target)
		return (target and target:isAlive() and target:hasSkill(self:objectName()))
				and (target:getPhase() == sgs.Player_Start)
				and (target:getMark("LuaBaiyin") == 0)
				and (target:getMark("@bear") >= 4)
	end
}
--[[技能名：暴虐（主公技）
	相关武将：林·董卓
	描述：每当其他群雄角色造成一次伤害后，该角色可以进行一次判定，若判定结果为黑桃，你回复1点体力。
]]--
LuaBaonue = sgs.CreateTriggerSkill{
	name = "LuaBaonue$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damage, sgs.PreDamageDone},
	global = true,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.PreDamageDone and damage.from then
			damage.from:setTag("InvokeBaonue", sgs.QVariant(damage.from:getKingdom() == "qun"))
		elseif event == sgs.Damage and player:getTag("InvokeBaonue"):toBool() and player:isAlive() then
			local dongzhuos = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasLordSkill(self:objectName()) then
					dongzhuos:append(p)
				end
			end
			while (not dongzhuos:isEmpty()) do
				local dongzhuo = room:askForPlayerChosen(player, dongzhuos, self:objectName(), "@baonue-to", true)
				if dongzhuo then
					dongzhuos:removeOne(dongzhuo)
					local log = sgs.LogMessage()
					log.type = "#InvokeOthersSkill"
					log.from = player
					log.to:append(dongzhuo)
					log.arg = self:objectName()
					room:sendLog(log)
					room:notifySkillInvoked(dongzhuo, self:objectName())
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|spade"
					judge.good = true
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if judge:isGood() then
						room:recover(dongzhuo, sgs.RecoverStruct(player))
					end
				else
					break
				end
			end
		end
		return false
	end,
}
--[[技能名：悲歌
	相关武将：山·蔡文姬、SP·蔡文姬
	描述：每当一名角色受到【杀】造成的一次伤害后，你可以弃置一张牌，令其进行一次判定，判定结果为：红桃 该角色回复1点体力；方块 该角色摸两张牌；梅花 伤害来源弃置两张牌；黑桃 伤害来源将其武将牌翻面。
]]--
LuaBeige = sgs.CreateTriggerSkill{
	name = "LuaBeige",
	events = {sgs.Damaged, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if damage.card == nil or not damage.card:isKindOf("Slash") or damage.to:isDead() then
				return false
			end
			for _, caiwenji in sgs.qlist(room:getAllPlayers()) do
				if not caiwenji or caiwenji:isDead() or not caiwenji:hasSkill(self:objectName()) then continue end
				if caiwenji:canDiscard(caiwenji, "he") and room:askForCard(caiwenji, "..", "@LuaBeige", data, self:objectName()) then
					local judge = sgs.JudgeStruct()
					judge.pattern = "."
					judge.good = true
					judge.play_animation = false
					judge.who = player
					judge.reason = self:objectName()
					room:judge(judge)
					local suit = judge.card:getSuit()
					if suit == sgs.Card_Heart then
						room:recover(player, sgs.RecoverStruct(caiwenji))
					elseif suit == sgs.Card_Diamond then
						player:drawCards(2, self:objectName())
					elseif suit == sgs.Card_Club then
						if damage.from and damage.from:isAlive() then
							room:askForDiscard(damage.from, self:objectName(), 2, 2, false, true)
						end
					elseif suit == sgs.Card_Spade then
						if damage.from and damage.from:isAlive() then
							damage.from:turnOver()
						end
					end
				end
			end
		else
			local judge = data:toJudge()
			if judge.reason ~= self:objectName() then return false end
			judge.pattern = tostring(judge.card:getEffectiveId())
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[技能名：崩坏（锁定技）
	相关武将：林·董卓
	描述：回合结束阶段开始时，若你不是当前的体力值最少的角色之一，你须失去1点体力或减1点体力上限。 
]]--
LuaBenghuai = sgs.CreatePhaseChangeSkill{
	name = "LuaBenghuai",
	frequency = sgs.Skill_Compulsory,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			for _,p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getHp() > player:getHp() then
					cantrigger = true
					break
				end
			end
			if cantrigger then
				local result = room:askForChoice(player, self:objectName(), "hp+maxhp")
				if result == "hp" then
					room:loseHp(player)
				else
					room:loseMaxHp(player)
				end
			end
			return false
		end
	end
}
--[[技能名：闭月
	相关武将：标准·貂蝉、SP貂蝉
	描述：回合结束阶段开始时，你可以摸一张牌。
]]--
LuaBiyue = sgs.CreatePhaseChangeSkill{
	name = "LuaBiyue",
	frequency = sgs.Skill_Frequent,
	on_phasechange = function(self, player)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName()) then
				player:drawCards(1, self:objectName())
			end
		end
		return false
	end
}
--[[技能名：补益
	相关武将：一将成名·吴国太
	描述：当一名角色进入濒死状态时，你可以展示该角色的一张手牌，若此牌不为基本牌，该角色弃置之，然后回复1点体力。
]]--
LuaBuyi = sgs.CreateTriggerSkill{
	name = "LuaBuyi",
	events = {sgs.Dying},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		local _player = dying.who
		if _player:isKongcheng() then return false end
		if _player:getHp() < 1 and player:askForSkillInvoke(self:objectName(), data) then
			local card
			if player:objectName() == _player:objectName() then
				card = room:askForCardShow(_player, player, "LuaBuyi")
			else
				local id = room:askForCardChosen(player, _player, "h", self:objectName())
				card = sgs.Sanguosha:getCard(id)
			end
			room:showCard(_player, card:getEffectiveId())
			if card:getTypeId() ~= sgs.Card_TypeBasic then
				if not _player:isJilei(card) then
					room:throwCard(card, _player)
				end
				room:broadcastSkillInvoke(self:objectName())
				room:recover(_player, sgs.RecoverStruct(player))
			end
		end
		return false
	end,
}
--[[技能名：不屈
	相关武将：风·周泰
	描述：每当你扣减1点体力后，若你当前的体力值为0：你可以从牌堆顶亮出一张牌置于你的武将牌上，若此牌的点数与你武将牌上已有的任何一张牌都不同，你不会死亡；若出现相同点数的牌，你进入濒死状态。
]]--
LuaBuqu = sgs.CreateTriggerSkill{
	name = "LuaBuqu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.AskForPeaches},
	on_trigger = function(self, event, zhoutai, data)
		local room = zhoutai:getRoom()
		local dying = data:toDying()
		if dying.who:objectName() ~= zhoutai:objectName() then
			return false
		end
		if zhoutai:getHp() > 0 then return false end
		room:sendCompulsoryTriggerLog(zhoutai, self:objectName())
		local id = room:drawCard()
		local num = sgs.Sanguosha:getCard(id):getNumber()
		local duplicate = false
		for _, card_id in sgs.qlist(zhoutai:getPile("luabuqu")) do
			if sgs.Sanguosha:getCard(card_id):getNumber() == num then
				duplicate = true
				break
			end
		end
		zhoutai:addToPile("luabuqu", id)
		if duplicate then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", self:objectName(), "")
			room:throwCard(sgs.Sanguosha:getCard(id), reason, nil)
		else
			room:recover(zhoutai, sgs.RecoverStruct(zhoutai, nil, 1 - zhoutai:getHp()))
		end
		return false
	end
}
LuaBuquMaxCards = sgs.CreateMaxCardsSkill{
	name = "#LuaBuqu",
	fixed_func = function(self, target)
		local len = target:getPile("luabuqu"):length()
		if len > 0 then
			return len
		else
			return -1
		end
	end
}
--[[技能名：不屈
	相关武将：怀旧·周泰
	描述：每当你扣减1点体力后，若你的体力值为0，你可以将牌堆顶的一张牌置于武将牌上，称为“创”，若所有“创”的点数均不同，你不会进入濒死状态。
	引用：LuaNosBuqu、LuaNosBuquRemove
	状态：0405验证通过
]]--
function Remove(zhoutai)
	local room = zhoutai:getRoom()
	local nosbuqu = zhoutai:getPile("luanosbuqu")
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "LuaNosBuqu", "")
	local need = 1 - zhoutai:getHp()
	if need <= 0 then
		for _, card_id in sgs.qlist(nosbuqu) do
			local log = sgs.LogMessage()
			log.type = "$NosBuquRemove"
			log.from = zhoutai
			log.card_str = sgs.Sanguosha:getCard(card_id):toString()
			room:sendLog(log)
			room:throwCard(sgs.Sanguosha:getCard(card_id), reason, nil)
		end
	else
		local to_remove = nosbuqu:length() - need
		for i = 0, to_remove - 1, 1 do
			room:fillAG(nosbuqu)
			local card_id = room:askForAG(zhoutai, nosbuqu, false, "LuaNosBuqu")
			local log = sgs.LogMessage()
			log.type = "$NosBuquRemove"
			log.from = zhoutai
			log.card_str = sgs.Sanguosha:getCard(card_id):toString()
			room:sendLog(log)
			nosbuqu:removeOne(card_id)
			room:throwCard(sgs.Sanguosha:getCard(card_id), reason, nil)
			room:clearAG()
		end
	end
end
LuaNosBuqu = sgs.CreateTriggerSkill{
	name = "LuaNosBuqu",
	events = {sgs.HpChanged, sgs.AskForPeachesDone},
	priority = {1, 2},
	on_trigger = function(self, event, zhoutai, data)
		local room = zhoutai:getRoom()
		if event == sgs.HpChanged and ((data:toDamage() and data:toDamage().to) or data:toInt() > 0) and zhoutai:getHp() < 1 then
			if room:askForSkillInvoke(zhoutai, self:objectName(), data) then
				room:setTag("LuaNosBuqu", sgs.QVariant(zhoutai:objectName()))
				local nosbuqu = zhoutai:getPile("luanosbuqu")
				local need = 1 - zhoutai:getHp()
				local n = need - nosbuqu:length()
				if n > 0 then
					local card_ids = room:getNCards(n, false)
					zhoutai:addToPile("luanosbuqu", card_ids)
				end
				local nosbuqunew = zhoutai:getPile("luanosbuqu")
				local duplicate_numbers = sgs.IntList()
				local numbers = {}
				for _, card_id in sgs.qlist(nosbuqunew) do
					local card = sgs.Sanguosha:getCard(card_id)
					local number = card:getNumber()
					if table.contains(numbers, number) then
						duplicate_numbers:append(number)
					else
						table.insert(numbers, number)
					end
				end
				if duplicate_numbers:isEmpty() then
					room:setTag("LuaNosBuqu", sgs.QVariant())
					return true
				end
			end
		elseif event == sgs.AskForPeachesDone then
			local nosbuqu = zhoutai:getPile("luanosbuqu")
			if zhoutai:getHp() > 0 then
				return false
			end
			if room:getTag("LuaNosBuqu"):toString() ~= zhoutai:objectName() then
				return false
			end
			room:setTag("LuaNosBuqu", sgs.QVariant())
			local duplicate_numbers = sgs.IntList()
			local numbers = {}
			for _, card_id in sgs.qlist(nosbuqu) do
				local card = sgs.Sanguosha:getCard(card_id)
				local number = card:getNumber()
				if table.contains(numbers, number) then
					duplicate_numbers:append(number)
				else
					table.insert(numbers, number)
				end
			end
			if duplicate_numbers:isEmpty() then
				room:setPlayerFlag(zhoutai, "-Global_Dying")
				return true
			else
				local log = sgs.LogMessage()
				log.type = "#NosBuquDuplicate"
				log.from = zhoutai
				log.arg = duplicate_numbers:length()
				room:sendLog(log)
				for i = 0, duplicate_numbers:length() - 1, 1 do
					local number = duplicate_numbers:at(i)
					local log = sgs.LogMessage()
					log.type = "#NosBuquDuplicateGroup"
					log.from = zhoutai
					log.arg = i + 1
					if number == 10 then
						log.arg2 = 10
					else
						local number_string = "-A23456789-JQK"
						log.arg2 = number_string[number]
					end
					room:sendLog(log)
					for _, card_id in sgs.qlist(nosbuqu) do
						local card = sgs.Sanguosha:getCard(card_id)
						if card:getNumber() == number then
							local log = sgs.LogMessage()
							log.type = "$NosBuquDuplicateItem"
							log.from = zhoutai
							log.card_str = card_id
							room:sendLog(log)
						end
					end
				end
			end
		end
		return false
	end
}
LuaNosBuquRemove = sgs.CreateTriggerSkill{
	name = "#LuaNosBuquRemove",
	events = {sgs.HpRecover, sgs.EventLoseSkill},
	on_trigger = function(self, event, zhoutai, data)
		if event == sgs.HpRecover then
			if zhoutai:getPile("luanosbuqu"):length() > 0 then
				Remove(zhoutai)
			end
			return false
		else
			if data:toString() == "LuaNosBuqu" then
				zhoutai:removePileByName("luanosbuqu")
				if zhoutai:getHp() < 0 then
					zhoutai:getRoom():enterDying(zhoutai, nil)
				end
			end
			return false
		end
	end
}
--[[技能名：奔袭（锁定技）
	相关武将：一将成名2014·吴懿
	描述：锁定技。你的回合内，你与其他角色的距离-X。你的回合内，若你与所有其他角色距离均为1，其他角色的防具无效，你使用【杀】可以额外选择一个目标。（X为本回合你已使用结算完毕的牌数）
	引用：LuaBenxi、LuaBenxiTargetMod、LuaBenxiDistance
	状态：0405验证通过
]]--
function isAllAdjacent(from, card)
	local rangefix = 0
	if card then
		if card:isVirtualCard() and from:getOffensiveHorse()
			and card:getSubcards():contains(from:getOffensiveHorse():getEffectiveId()) then
			rangefix = 1
		end
	end
	for _, p in sgs.qlist(from:getAliveSiblings()) do
		if from:distanceTo(p, rangefix) ~= 1 then
			return false
		end
	end
	return true
end
LuaBenxi = sgs.CreateTriggerSkill{
	name = "LuaBenxi",
	frequency = sgs.Skill_Compulsory,
	global = true,
	events = {sgs.EventPhaseChanging, sgs.CardEffected, sgs.CardFinished, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				room:setPlayerMark(player, "@LuaBenxi", 0)
				room:setPlayerMark(player, "LuaBenxi", 0)
				if player:hasFlag("LuaBenxiArmor") then
					room:setPlayerFlag(player, "-LuaBenxiArmor")
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
		elseif event == sgs.CardEffected then
			local from = data:toCardEffect().from
			if from:isAlive() and data:toCardEffect().to:objectName() ~= from:objectName() and from:hasSkill("LuaBenxi") and from:getPhase() ~= sgs.Player_NotActive then
				if from:hasFlag("LuaBenxiArmor") and not isAllAdjacent(from, nil) then
					room:setPlayerFlag(from, "-LuaBenxiArmor")
					for _, p in sgs.qlist(room:getOtherPlayers(from)) do
						room:removePlayerMark(p, "Armor_Nullified")
					end
				elseif isAllAdjacent(from, nil) and not from:hasFlag("LuaBenxiArmor") then
					room:setPlayerFlag(from, "LuaBenxiArmor")
					for _, p in sgs.qlist(room:getOtherPlayers(from)) do
						room:addPlayerMark(p, "Armor_Nullified")
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:getTypeId() ~= sgs.Card_TypeSkill
				and player:isAlive() and player:getPhase() ~= sgs.Player_NotActive then
				room:addPlayerMark(player, "LuaBenxi")
				if player:hasSkill("LuaBenxi") then
					room:setPlayerMark(player, "@LuaBenxi", player:getMark("LuaBenxi"))
					if player:hasFlag("LuaBenxiArmor") and not isAllAdjacent(player, nil) then
						room:setPlayerFlag(player, "-LuaBenxiArmor")
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:removePlayerMark(p, "Armor_Nullified")
						end
					elseif isAllAdjacent(player, nil) and not player:hasFlag("LuaBenxiArmor") then
						room:setPlayerFlag(player, "LuaBenxiArmor")
						for _, p in sgs.qlist(room:getOtherPlayers(player)) do
							room:addPlayerMark(p, "Armor_Nullified")
						end
					end
				end
			end
		elseif event == sgs.EventAcquireSkill or event == sgs.EventLoseSkill then
			if data:toString() ~= "LuaBenxi" then return false end
			local num = 0
			if event == sgs.EventAcquireSkill then
				num = player:getMark("LuaBenxi")
				if isAllAdjacent(player, nil) and player:getPhase() ~= sgs.Player_NotActive then
					room:setPlayerFlag(player, "LuaBenxiArmor")
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:addPlayerMark(p, "Armor_Nullified")
					end
				end
			else
				if player:hasFlag("LuaBenxiArmor") then
					room:setPlayerFlag(player, "-LuaBenxiArmor")
					for _, p in sgs.qlist(room:getOtherPlayers(player)) do
						room:removePlayerMark(p, "Armor_Nullified")
					end
				end
			end
			room:setPlayerMark(player, "@LuaBenxi", num)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
LuaBenxiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaBenxiTargetMod",
	pattern = "Slash",
	extra_target_func = function(self, from, card)
		if from:hasSkill("LuaBenxi") and isAllAdjacent(from, card) then
			return 1
		else
			return 0
		end
	end,
}
LuaBenxiDistance = sgs.CreateDistanceSkill{
	name = "#LuaBenxiDistance",
	correct_func = function(self, from, to)
		if from:hasSkill("LuaBenxi") and from:getPhase() ~= sgs.Player_NotActive then
			return -from:getMark("LuaBenxi")
		end
		return 0
	end,
}
--[[技能名：笔伐
	相关武将：SP·陈琳
	描述：结束阶段开始时，你可以将一张手牌移出游戏并选择一名其他角色，该角色的回合开始时，观看该牌，然后选择一项：交给你一张与该牌类型相同的牌并获得该牌，或将该牌置入弃牌堆并失去1点体力。
	引用：LuaBifa
	状态：0405验证通过
]]--
LuaBifaCard = sgs.CreateSkillCard{
	name = "LuaBifa",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:getPile("bifa"):isEmpty() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local tag = sgs.QVariant()
		tag:setValue(source)
		target:setTag("BifaSource"..tostring(self:getEffectiveId()), tag)
		target:addToPile("bifa", self, false)
	end
}
LuaBifaVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaBifa",
	response_pattern = "@@LuaBifa" ,
	filter_pattern = ".|.|.|hand" ,
	view_as = function(self, cd)
		local card = LuaBifaCard:clone()
		card:addSubcard(cd)
		return card
	end
}
LuaBifa = sgs.CreatePhaseChangeSkill{
	name = "LuaBifa",
	view_as_skill = LuaBifaVS,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:isAlive() and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Finish and not player:isKongcheng() then
			room:askForUseCard(player, "@@LuaBifa", "@bifa-remove")
			return false
		elseif player:getPhase() == sgs.Player_RoundStart and player:getPile("bifa"):length() > 0 then
			local card_id = player:getPile("bifa"):first()
			local chenlin = player:getTag("BifaSource"..tostring(card_id)):toPlayer()
			local ids = sgs.IntList()
			ids:append(card_id)
			 local log = sgs.LogMessage()
			log.type = "$BifaView"
			log.from = player
			log.card_str = tostring(card_id)
			log.arg = self:objectName()
			room:sendLog(log, player)
			room:fillAG(ids, player)
			local cd = sgs.Sanguosha:getCard(card_id)
			local pattern
			if cd:isKindOf("BasicCard") then
				pattern = "BasicCard"
			elseif cd:isKindOf("TrickCard") then
				pattern = "TrickCard"
			elseif cd:isKindOf("EquipCard") then
				pattern = "EquipCard"
			end
			local data_for_ai = sgs.QVariant(pattern)
			pattern = pattern.."|.|.|hand"
			local to_give = nil
			if not player:isKongcheng() and chenlin and chenlin:isAlive() then
				to_give = room:askForCard(player, pattern, "@bifa-give", data_for_ai, sgs.Card_MethodNone, chenlin)
 			end
			if chenlin and to_give then
				room:broadcastSkillInvoke(self:objectName(), 2)
				local reasonG = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), chenlin:objectName(), self:objectName(), "")
				room:obtainCard(chenlin, to_give, reasonG, false)
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, player:objectName(), self:objectName(), "")
				room:obtainCard(player, cd, reason, false)					
			else
				room:broadcastSkillInvoke(self:objectName(), 3)
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", self:objectName(), "")
				room:throwCard(cd, reason, nil)
				room:loseHp(player)
			end
			room:clearAG(player)
			player:removeTag("BifaSource"..tostring(card_id))
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[代码速查手册（C区）
	技能索引：
		残蚀、藏机、藏匿、缠怨、超级观星、称象、称象、称象、持盈、持重、冲阵、仇海、筹粮、除疠、穿心、穿心、醇醪、聪慧、存嗣、挫锐
]]--
--[[技能名：残蚀
	相关武将：SP·孙皓
	描述：摸牌阶段开始时，你可以放弃摸牌，摸X张牌（X 为已受伤的角色数），若如此做，当你于此回合内使用基本牌或锦囊牌时，你弃置一张牌。 
	引用：LuaCanshi
	状态：0405验证通过	
]]--
LuaCanshi = sgs.CreateTriggerSkill{
	name = "LuaCanshi",
	events = {sgs.EventPhaseStart, sgs.CardUsed, sgs.CardResponded},
	can_trigger = function(self, target)
		return target ~= nil and target:isAlive()
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:isAlive() and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Draw then
				local n = 0
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:isWounded() or (player:hasLordSkill("LuaGuiming") and (not room:correctSkillValidity(player,"LuaGuiming")) and p:getKingdom() == "wu")then
						n = n + 1
					end
				end
				if n > 0 and player:askForSkillInvoke(self:objectName(), data) then
					player:setFlags(self:objectName())
					player:drawCards(n, self:objectName())
					return true
				end
			end
		else 
			if player:hasFlag(self:objectName()) then
				local card = nil
				if event == CardUsed then
					card = data:toCardUse().card
				else 
					local resp = data:toCardResponse()
					if resp.m_isUse then
						card = resp.m_card
					end
				end
				if (card ~= nil and card:isKindOf("BasicCard")) or (card:isKindOf("TrickCard")) then
					room:sendCompulsoryTriggerLog(player, self:objectName())
					if not room:askForDiscard(player, self:objectName(), 1, 1, false, true, "@canshi-discard") then
						local cards = player:getCards("he")
						local c = cards:at(math.random(0, cards:length() - 1))
						room:throwCard(c, player)
					end
				end
			end
		end
		return false
	end
}
--[[技能名：藏机
	相关武将：1v1·黄月英1v1
	描述：你死亡时，你可以将装备区的所有装备牌移出游戏：若如此做，你的下个武将登场时，将这些牌置于装备区。
	引用：LuaCangji、LuaCangjiInstall
	状态：0405验证通过(KOF2013模式)
]]--
LuaCangjiCard = sgs.CreateSkillCard{
	name = "LuaCangjiCard",
	will_throw = false,
	filter = function(self, targets, to_select, player)
		if #targets>0 or to_select:objectName() == player:objectName() then
			return false
		end
		local equip_loc = sgs.IntList()
		for _,id in sgs.qlist(self:getSubcards()) do
			local card = sgs.Sanguosha:getCard(id)
			local equip = card:getRealCard():toEquipCard()
			if equip then
				equip_loc:append(equip:location())
			end
		end
		for _,loc in sgs.qlist(equip_loc) do
			if to_select:getEquip(loc) then
				return false
			end
		end
		return true
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local move = sgs.CardsMoveStruct(self:getSubcards(), effect.from, effect.to, sgs.Player_PlaceUnknown, sgs.Player_PlaceEquip, sgs.CardMoveReason())
		room:moveCardsAtomic(move, true)
		if effect.from:getEquips():isEmpty() then
			return
		end
		local loop = false
		for i = 0,3,1 do
			if effect.from:getEquip(i) then
				for _,p in sgs.qlist(room:getOtherPlayers(effect.from)) do
					if not p:getEquip(i) then
						loop = true
						break
					end
				end
				if loop then break end
			end
		end
		if loop then
			room:askForUseCard(effect.from, "@@LuaCangji", "@cangji-install", -1, sgs.Card_MethodNone)
		end
	end
}
LuaCangjiVS = sgs.CreateViewAsSkill{
	name = "LuaCangji",
	n = 4,
	response_pattern = "@@LuaCangji"
	view_filter = function(self, selected, to_select)
		return to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local card = LuaCangjiCard:clone()
		for _,c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end
}
LuaCangji = sgs.CreateTriggerSkill {
	name = "LuaCangji",
	events = {sgs.Death},
	view_as_skill = LuaCangjiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() or (not player:hasSkill(self:objectName())) or player:getEquips():isEmpty() then
			return false
		end
		if room:getMode() == "02_1v1" then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local equip_list = {}
				local move = sgs.CardsMoveStruct()
				move.from = player
				move.to = nil
				move.to_place = sgs.Player_PlaceTable
				for _, equip in sgs.qlist(player:getEquips()) do
					table.insert(equip_list,equip:getEffectiveId())
					move.card_ids:append(equip:getEffectiveId())
				end				
				player:setTag(self:objectName(), sgs.QVariant(table.concat(equip_list, "+")))
				room:moveCardsAtomic(move,true)
			end
		else
			room:askForUseCard(player,"@@LuaCangji","@cangji-install",-1,sgs.Card_MethodNone)
		end
		return false
	end,
	can_trigger = function(self,target)
		return target ~= nil
	end   
}
LuaCangjiInstall = sgs.CreateTriggerSkill {
	name = "#LuaCangjiInstall",
	events = {sgs.Debut},
	priority = 5,
	can_trigger = function(self,target)
		return target:getTag("LuaCangji"):toString() ~= ""
	end,  
	on_trigger = function(self,event,player, data)
		local room = player:getRoom()
		local equip_list = sgs.IntList()
		for _, id in ipairs(player:getTag("LuaCangji"):toString():split("+")) do
			local card_id = tonumber(id)
			if sgs.Sanguosha:getCard(card_id):getTypeId() == sgs.Card_TypeEquip then
				equip_list:append(card_id)
			end
		end
		player:removeTag("LuaCangji")
		if equip_list:isEmpty() then return false end
		local log = sgs.LogMessage()
		log.from = player
		log.type = "$Install"
		log.card_str = table.concat(sgs.QList2Table(equip_list), "+")
		room:sendLog(log)
		room:moveCardsAtomic(sgs.CardsMoveStruct(equip_list, player, sgs.Player_PlaceEquip, sgs.CardMoveReason()), true)
		return false
	end
}
--[[技能名：藏匿
	相关武将：铜雀台·伏皇后
	描述：弃牌阶段开始时，你可以回复1点体力或摸两张牌，然后将你的武将牌翻面；其他角色的回合内，当你获得（每回合限一次）/失去一次牌时，若你的武将牌背面朝上，你可以令该角色摸/弃置一张牌。
	引用：LuaCangni
	状态：0405验证通过
]]--
LuaCangni = sgs.CreateTriggerSkill{
	name = "LuaCangni" ,
	events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Discard and player:askForSkillInvoke(self:objectName()) then
			local choices = {}
			table.insert(choices, "draw")
			if player:isWounded() then
				table.insert(choices, "recover")
			end
			local choice
			if #choices == 1 then
				choice = choices[1]
			else
				choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			end
			if choice == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			else
				player:drawCards(2)
			end
			player:turnOver()
			return false
		elseif event == sgs.CardsMoveOneTime and not player:faceUp() then
			if (player:getPhase() ~= sgs.Player_NotActive) then
				return false
			end
			local move = data:toMoveOneTime()
			local target = room:getCurrent()
			if target:isDead() then
				return false
			end
			if (move.from and move.from:objectName() == player:objectName()) and ((not move.to) or (move.to:objectName() ~= player:objectName())) then
				local invoke = false
				for i = 0, move.card_ids:length() - 1, 1 do
					if move.from_places:at(i) == sgs.Player_PlaceHand or move.from_places:at(i) == sgs.Player_PlaceEquip then
						invoke = true
						break
					end
				end
				room:setPlayerFlag(player, "LuaCangniLose")
				if invoke and (not target:isNude()) and player:askForSkillInvoke(self:objectName()) then
					room:doAnimate(1, player:objectName(), target:objectName())
					room:askForDiscard(target, self:objectName(), 1, 1, false, true)
				end
				room:setPlayerFlag(player, "-LuaCangniLose")
				return false
			end
			if (move.to and (move.to:objectName() == player:objectName())) and ((not move.from) or (move.from:objectName() ~= player:objectName())) then
				if (move.to_place == sgs.Player_PlaceHand) or (move.to_place == sgs.Player_PlaceEquip) then
					room:setPlayerFlag(player, "LuaCangniGet")
					if (not target:hasFlag("LuaCangni_Used")) then
						if player:askForSkillInvoke(self:objectName()) then
							room:doAnimate(1, player:objectName(), target:objectName())
							room:setPlayerFlag(target, "LuaCangni_Used")
							target:drawCards(1)
						end
					end
					room:setPlayerFlag(player, "-LuaCangniGet")
				end
			end
		end
		return false
	end
}
--[[技能名：缠怨（锁定技）
	相关武将：风·于吉
	描述：你不能质疑“蛊惑”。若你的体力值为1，你的其他武将技能无效。
	引用：LuaChanyuan
	状态：1217验证通过(需配合本手册的“蛊惑”一起使用)
]]--
LuaChanyuan = sgs.CreateTriggerSkill {
	name = "LuaChanyuan",
	events = {sgs.GameStart, sgs.HpChanged, sgs.MaxHpChanged, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	frequency = sgs.Skill_Compulsory,
	
	can_trigger = function(self, target)
		return target
	end,
	
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if triggerEvent == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				local LuaChanyuan_skills = player:getTag("LuaChanyuanSkills"):toString():split("+")
				for _, skill_name in ipairs(LuaChanyuan_skills) do
					room:removePlayerMark(player, "Qingcheng"..skill_name)
				end
				player:setTag("LuaChanyuanSkills", sgs.QVariant())
			end
			return false
		elseif triggerEvent == sgs.EventAcquireSkill then
			if data:toString() ~= self:objectName() then return false end
		end
		
		if not player:isAlive() or not player:hasSkill(self:objectName()) then return false end
		
		if player:getHp() == 1 then
			local LuaChanyuan_skills = player:getTag("LuaChanyuanSkills"):toString():split("+")
			local skills = player:getVisibleSkillList()
			for _, skill in sgs.qlist(skills) do
				if skill:objectName() ~= self:objectName() and skill:getLocation() == sgs.Skill_Right and not skill:inherits("SPConvertSkill") and not skill:isAttachedLordSkill() and not (Set(LuaChanyuan_skills))[skill:objectName()] then
					room:addPlayerMark(player, "Qingcheng"..skill:objectName())
					table.insert(LuaChanyuan_skills, skill:objectName())
				end
			end
			player:setTag("LuaChanyuanSkills", sgs.QVariant(table.concat(LuaChanyuan_skills, "+")))
		else
			local LuaChanyuan_skills = player:getTag("LuaChanyuanSkills"):toString():split("+")
			for _, skill_name in ipairs(LuaChanyuan_skills) do
				room:removePlayerMark(player, "Qingcheng"..skill_name)
			end
			player:setTag("LuaChanyuanSkills", sgs.QVariant())
		end
		return false
	end
}
--[[技能名：超级观星
	相关武将：测试·五星诸葛
	描述：回合开始阶段，你可以观看牌堆顶的5张牌，将其中任意数量的牌以任意顺序置于牌堆顶，其余则以任意顺序置于牌堆底
	引用：LuaXSuperGuanxing
	状态：0405验证通过
]]--
LuaXSuperGuanxing = sgs.CreateTriggerSkill{
	name = "LuaXSuperGuanxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			if player:askForSkillInvoke(self:objectName()) then
				local room = player:getRoom()
				local stars = room:getNCards(5,false)
				room:askForGuanxing(player, stars)
			end
		end
	end
}
--[[技能名：称象
	相关武将：怀旧一将成名2013·曹冲
	描述： 每当你受到一次伤害后，你可以展示牌堆顶的四张牌，然后获得其中任意数量点数之和小于13的牌，并将其余的牌置入弃牌堆。
	引用：LuaChengxiang
	状态：0405验证通过
]]--
LuaChengxiang = sgs.CreateTriggerSkill{
	name = "LuaChengxiang" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		local card_ids = room:getNCards(4)
		room:fillAG(card_ids)
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		while true do
			local sum = 0
			for _, id in sgs.qlist(to_get) do
				sum = sum + sgs.Sanguosha:getCard(id):getNumber()
			end
			if sum >= 12 then break end
			for _, id in sgs.qlist(card_ids) do
				if sum + sgs.Sanguosha:getCard(id):getNumber() >= 13 then
					room:takeAG(nil, id, false)
					to_throw:append(id)
				end
			end
			for _, id in sgs.qlist(card_ids) do
				if to_throw:contains(id) then
					card_ids:removeOne(id)
				end
			end
			if to_throw:length() + to_get:length() == 4 then break end
			local card_id = room:askForAG(player, card_ids, true, self:objectName())
			if card_id == -1 then break end
			card_ids:removeOne(card_id)
			to_get:append(card_id)
			room:takeAG(player, card_id, false)
			if card_ids:isEmpty() then break end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			for _, id in sgs.qlist(to_get) do
				dummy:addSubcard(id)
			end
			player:obtainCard(dummy)
		end
		dummy:clearSubcards()
		if (not to_throw:isEmpty()) or (not card_ids:isEmpty()) then
			for _, id in sgs.qlist(to_throw) do
				dummy:addSubcard(id)
			end
			for _, id in sgs.qlist(card_ids) do
				dummy:addSubcard(id)
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		end
		room:clearAG()
		return false
	end
}
--[[技能名：称象
	相关武将：倚天·曹冲
	描述：每当你受到一次伤害后，你可以弃置X张点数之和与造成伤害的牌的点数相等的牌，你可以选择至多X名角色，若其已受伤则回复1点体力，否则摸两张牌。
	引用：LuaYTChengxiang
	状态：0405验证通过
]]--
LuaYTChengxiangCard = sgs.CreateSkillCard{
	name = "LuaYTChengxiang" ,
	filter = function(self, targets, to_select)
		return #targets < self:subcardsLength()
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		if effect.to:isWounded() then
			local recover = sgs.RecoverStruct()
			recover.card = self
			recover.who = effect.from
			room:recover(effect.to, recover)
		else
			effect.to:drawCards(2)
		end
	end
}
LuaYTChengxiangVS = sgs.CreateViewAsSkill{
	name = "LuaYTChengxiang" ,
	n = 3 ,
	view_filter = function(self, selected, to_select)
		if #selected >= 3 then return false end
		local sum = 0
		for _, card in ipairs(selected) do
			sum = sum + card:getNumber()
		end
		sum = sum + to_select:getNumber()
		return sum <= sgs.Self:getMark("LuaYTChengxiang")
	end ,
	view_as = function(self, cards)
		local sum = 0
		for _, c in ipairs(cards) do
			sum = sum + c:getNumber()
		end
		if sum == sgs.Self:getMark("LuaYTChengxiang") then
			local card = LuaYTChengxiangCard:clone()
			for _, c in ipairs(cards) do
				card:addSubcard(c)
			end
			return card
		else
			return nil
		end
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaYTChengxiang"
	end
}
LuaYTChengxiang = sgs.CreateTriggerSkill{
	name = "LuaYTChengxiang" ,
	events = {sgs.Damaged} ,
	view_as_skill = LuaYTChengxiangVS ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local card = damage.card
		if card == nil then return false end
		local point = card:getNumber()
		if (point < 1) or (point > 13) then return false end
		if player:isNude() then return false end
		local room = player:getRoom()
		room:setPlayerMark(player, "LuaYTChengxiang", point)
		local prompt = "@chengxiang-card:::" .. tostring(point)
		room:askForUseCard(player, "@@LuaYTChengxiang", prompt)
		return false
	end
}
--[[技能名：称象
	相关武将：一将成名2013·曹冲
	描述： 每当你受到一次伤害后，你可以展示牌堆顶的四张牌，然后获得其中任意数量点数之和小于或等于13的牌，并将其余的牌置入弃牌堆。
	引用：LuaChengxiang
	状态：0405验证通过
]]--
LuaChengxiang = sgs.CreateTriggerSkill{
	name = "LuaChengxiang" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if not player:askForSkillInvoke(self:objectName(), data) then return false end
		local card_ids = room:getNCards(4)
		room:fillAG(card_ids)
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		while true do
			local sum = 0
			for _, id in sgs.qlist(to_get) do
				sum = sum + sgs.Sanguosha:getCard(id):getNumber()
			end
			if sum > 12 then break end
			for _, id in sgs.qlist(card_ids) do
				if sum + sgs.Sanguosha:getCard(id):getNumber() > 13 then
					room:takeAG(nil, id, false)
					to_throw:append(id)
				end
			end
			for _, id in sgs.qlist(card_ids) do
				if to_throw:contains(id) then
					card_ids:removeOne(id)
				end
			end
			if to_throw:length() + to_get:length() == 4 then break end
			local card_id = room:askForAG(player, card_ids, true, self:objectName())
			if card_id == -1 then break end
			card_ids:removeOne(card_id)
			to_get:append(card_id)
			room:takeAG(player, card_id, false)
			if card_ids:isEmpty() then break end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			for _, id in sgs.qlist(to_get) do
				dummy:addSubcard(id)
			end
			player:obtainCard(dummy)
		end
		dummy:clearSubcards()
		if (not to_throw:isEmpty()) or (not card_ids:isEmpty()) then
			for _, id in sgs.qlist(to_throw) do
				dummy:addSubcard(id)
			end
			for _, id in sgs.qlist(card_ids) do
				dummy:addSubcard(id)
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
			room:throwCard(dummy, reason, nil)
		end
		room:clearAG()
		return false
	end
}
--[[技能名：持重（锁定技）
	相关武将：铜雀台·伏完
	描述：你的手牌上限等于你的体力上限；其他角色死亡时，你加1点体力上限。
	引用：LuaChizhongKeep、LuaChizhong
	状态：0405验证通过
]]--
LuaChizhongKeep = sgs.CreateMaxCardsSkill{
	name = "LuaChizhong",
	fixed_func = function(self, target)
		if target:hasSkill(self:objectName()) then
            return target:getMaxHp()
        else
            return -1
		end
	end
}
LuaChizhong = sgs.CreateTriggerSkill{
	name = "#LuaChizhong" ,
	events = {sgs.Death} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local splayer = room:findPlayerBySkillName(self:objectName())
		if not splayer then return false end
		local death = data:toDeath()
		if death.who:objectName() == player:objectName() then return false end
		room:setPlayerProperty(splayer, "maxhp", sgs.QVariant(splayer:getMaxHp() + 1))
		return false
	end
}
--[[技能名：冲阵
	相关武将：☆SP·赵云
	描述：每当你发动“龙胆”使用或打出一张手牌时，你可以立即获得对方的一张手牌。
	引用：LuaChongzhen
	状态：0405验证通过
]]--
LuaChongzhen = sgs.CreateTriggerSkill{
	name = "LuaChongzhen" ,
	events = {sgs.CardResponded, sgs.TargetSpecified} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardResponded then
	        	local resp = data:toCardResponse()
	        	if resp.m_card:getSkillName() == "longdan" and resp.m_who and (not resp.m_who:isKongcheng()) then
		            	local _data = sgs.QVariant()
				_data:setValue(resp.m_who)
		                if player:askForSkillInvoke(self:objectName(), _data) then
		                	local card_id = room:askForCardChosen(player, resp.m_who, "h", self:objectName())
		                	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
		                	room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
		                end
	        	end
	        else
	            local use = data:toCardUse()
	            if use.card:getSkillName() == "longdan" then
	                for _, p in sgs.qlist(use.to) do
	                	if p:isKongcheng() then continue end
	                	local _data = sgs.QVariant()
				_data:setValue(p)
				p:setFlags("LuaChongzhenTarget")
	                	local invoke = player:askForSkillInvoke(self:objectName(), _data)
	                	p:setFlags("-LuaChongzhenTarget")
	                	if invoke then
	                        	local card_id = room:askForCardChosen(player, p, "h", self:objectName())
	                        	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
	                        	room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
	                    	end
	                end
	            end
	        end
	        return false
	end
}
--[[技能名：仇海（锁定技）
	相关武将：SP·孙皓
	描述：当你受到伤害时，若你没有手牌，你令此伤害+1。 
	引用：LuaChouhai
	状态：0405验证通过
]]--
LuaChouhai = sgs.CreateTriggerSkill{
	name = "LuaChouhai",
	events = {sgs.DamageInflicted},
	frequency = sgs.Skill_Compulsory, 
	can_trigger = function(self, target)
		return target ~= nil and target:isAlive()
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isKongcheng() then
			room:sendCompulsoryTriggerLog(player, self:objectName(), true)
			local damage = data:toDamage()
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
		return false
	end
}
--[[技能名：筹粮
	相关武将：智·蒋琬
	描述：回合结束阶段开始时，若你手牌少于三张，你可以从牌堆顶亮出4-X张牌（X为你的手牌数），你获得其中的基本牌，把其余的牌置入弃牌堆
	引用：LuaChouliang
	状态：0405验证通过
]]--
LuaChouliang = sgs.CreateTriggerSkill{
	name = "LuaChouliang",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
	        local handcardnum = player:getHandcardNum()
	        if player:getPhase() == sgs.Player_Finish and handcardnum < 3
			and room:askForSkillInvoke(player, self:objectName()) then
	        	local x = 4 - handcardnum
	        	local ids = room:getNCards(x, false)
	        	local move = sgs.CardsMoveStruct()
	        	move.card_ids = ids
	        	move.to = player
	        	move.to_place = sgs.Player_PlaceTable
	        	move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), "")
	        	room:moveCardsAtomic(move, true)
	        	room:getThread():delay()
	
	        	local card_to_throw = sgs.IntList()
	        	local card_to_gotback = sgs.IntList()
	        	for i = 0, x - 1, 1 do
		                if not sgs.Sanguosha:getCard(ids:at(i)):isKindOf("BasicCard") then
		                    card_to_throw:append(ids:at(i))
		                else
		                    card_to_gotback:append(ids:at(i))
				end
			end
	        	if not card_to_gotback:isEmpty() then
		        	local dummy2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in sgs.qlist(card_to_gotback) do
		                	dummy2:addSubcard(id)
				end
		                local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, player:objectName())
		                room:obtainCard(player, dummy2, reason)
		                dummy2:deleteLater()
	        	end
	        	if not card_to_throw:isEmpty() then
		                local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in sgs.qlist(card_to_throw) do
		                	dummy:addSubcard(id)
				end
		                local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), "")
		                room:throwCard(dummy, reason, nil)
		                dummy:deleteLater()
			end
		end
        return false
    end
}
--[[技能名：除疠
	相关武将：标准·华佗
	描述：阶段技。若你有牌，你可以选择至少一名势力各不相同的有牌的其他角色：若如此做，你弃置你与这些角色各一张牌，然后以此法弃置?牌的角色摸一张牌。 
	引用：LuaChuli
	状态：0405验证通过
]]--
LuaChuliCard = sgs.CreateSkillCard{
	name = "LuaChuliCard" ,
	filter = function(self, targets, to_select)
		if to_select:objectName() == sgs.Self:objectName() then return false end
		local kingdoms = {}
		for _,p in ipairs(targets) do
			table.insert(kingdoms, p:getKingdom())
		end
		return sgs.Self:canDiscard(to_select, "he") and not table.contains(kingdoms, to_select:getKingdom())
	end ,
	on_use = function(self, room, source, targets)
		local draw_card = sgs.SPlayerList()
		if sgs.Sanguosha:getCard(self:getEffectiveId()):getSuit() == sgs.Card_Spade then
			draw_card:append(source)
		end
		for _,target in ipairs(targets) do
			if not source:canDiscard(target, "he") then continue end
			local id = room:askForCardChosen(source, target, "he", "chuli", false, sgs.Card_MethodDiscard)
			room:throwCard(id, target, source)
			if sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Spade then
				draw_card:append(target)
			end
		end
		
		for _,p in sgs.qlist(draw_card) do
			room:drawCards(p, 1, "chuli")
		end
	end
}
LuaChuli = sgs.CreateOneCardViewAsSkill{
	name = "LuaChuli" ,
	filter_pattern = ".!",
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and not player:hasUsed("#LuaChuliCard")
	end ,
	view_as = function(self, originalCard)
		local chuli_card = LuaChuliCard:clone()
		chuli_card:addSubcard(originalCard:getId())
		return chuli_card
	end ,
}
--[[技能名：醇醪
	相关武将：二将成名·程普
	描述：结束阶段开始时，若你的武将牌上没有牌，你可以将任意数量的【杀】置于你的武将牌上，称为“醇”；当一名角色处于濒死状态时，你可以将一张“醇”置入弃牌堆，令该角色视为使用一张【酒】。
	引用：LuaChunlao
	状态：0405验证通过
]]--
LuaChunlaoCard = sgs.CreateSkillCard{
	name = "LuaChunlaoCard" ,
	will_throw = false ,
	target_fixed = true ,
	handling_method = sgs.Card_MethodNone,
	on_use = function(self, room, source, targets)
		source:addToPile("wine", self)
	end
}
LuaChunlaoWineCard = sgs.CreateSkillCard{
	name = "LuaChunlaoWine" ,
	mute = true ,
	target_fixed = true ,
	will_throw = false ,
	on_use = function(self, room, source, targets)
		local who = room:getCurrentDyingPlayer()
		if not who then return end
		if self:getSubcards():length() ~= 0 then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, nil, "LuaChunlao", nil)
			room:throwCard(self, reason, nil)
			local analeptic = sgs.Sanguosha:cloneCard("Analeptic", sgs.Card_NoSuit, 0)
			analeptic:setSkillName("_LuaChunlao")
			room:useCard(sgs.CardUseStruct(analeptic, who, who, false))
		end
	end
}
LuaChunlaoVS = sgs.CreateViewAsSkill{
	name = "LuaChunlao" ,
	n = 999,
	expand_pile = "wine" ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "@@LuaChunlao") or (string.find(pattern, "peach") and (not player:getPile("wine"):isEmpty()))
	end ,
	view_filter = function(self, selected, to_select)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "@@LuaChunlao" then
			return to_select:isKindOf("Slash")
		else
			local pattern = ".|.|.|wine"
			if not sgs.Sanguosha:matchExpPattern(pattern, sgs.Self, to_select) then return false end
			return #selected == 0
		end
	end ,
	view_as = function(self, cards)
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if pattern == "@@LuaChunlao" then
			if #cards == 0 then return nil end
			local acard = LuaChunlaoCard:clone()
			for _, c in ipairs(cards) do
				acard:addSubcard(c)
			end
			acard:setSkillName(self:objectName())
			return acard
		else
			if #cards ~= 1 then return nil end
			local wine = LuaChunlaoWineCard:clone()
			for _, c in ipairs(cards) do
				wine:addSubcard(c)
			end
			wine:setSkillName(self:objectName())
			return wine
		end
	end ,
}
LuaChunlao = sgs.CreateTriggerSkill{
	name = "LuaChunlao" ,
	events = {sgs.EventPhaseStart} ,
	view_as_skill = LuaChunlaoVS ,
	on_trigger = function(self, event, player, data)
		if (event == sgs.EventPhaseStart)
				and (player:getPhase() == sgs.Player_Finish)
				and (not player:isKongcheng())
				and player:getPile("wine"):isEmpty() then
			player:getRoom():askForUseCard(player, "@@LuaChunlao", "@chunlao", -1, sgs.Card_MethodNone)
		end
		return false
	end
}
--[[技能名：聪慧（锁定技）
	相关武将：倚天·曹冲
	描述：你将永远跳过你的弃牌阶段
	引用：LuaConghui
	状态：0405验证通过
]]--
LuaConghui = sgs.CreateTriggerSkill{
	name = "LuaConghui" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.EventPhaseChanging} ,
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Discard then
			player:skip(change.to)
		end
		return false
	end
}
--[[技能名：存嗣
	相关武将：势·糜夫人
	描述：限定技，出牌阶段，你可以失去“闺秀”和“存嗣”，然后令一名角色获得“勇决”（若一名角色于出牌阶段内使用的第一张牌为【杀】，此【杀】结算完毕后置入弃牌堆时，你可以令其获得之。）：若该角色不是你，该角色摸两张牌。 
	引用：LuaCunsi、LuaCunsiStart
	状态：1217验证通过
	
	注：此技能与闺秀有联系，有联系的地方请使用本手册当中的闺秀，并非原版
]]--
LuaCunsiCard = sgs.CreateSkillCard{
	name = "LuaCunsiCard",

	filter = function(self, targets, to_select)
		return #targets == 0 
	end,
	
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		room:handleAcquireDetachSkills(effect.from,"-LuaGuixiu|-LuaCunsi")
		room:acquireSkill(effect.to,"yongjue")
		if effect.to:objectName() ~= effect.from:objectName() then
			effect.to:drawCards(2)
		end
	end
}
LuaCunsi = sgs.CreateZeroCardViewAsSkill{
	name = "LuaCunsi",
	frequency = sgs.Skill_Limited,

	view_as = function()
		return LuaCunsiCard:clone()
	end
}
LuaCunsiStart = sgs.CreateTriggerSkill{
	name = "#LuaCunsiStart",
	events = {sgs.GameStart,sgs.EventAcquireSkill},
	
	on_trigger = function(self, event, player, data)
		player:getRoom():getThread():addTriggerSkill(sgs.Sanguosha:getTriggerSkill("yongjue"))
	end,
}
--[[技能名：挫锐（锁定技）
	相关武将：1v1·牛金
	描述：你的起始手牌数为X+2（X为你备选区里武将牌的数量），你跳过登场后的第一个判定阶段。 
	引用：LuaCuorui
	状态：1217验证通过
]]--
LuaCuorui = sgs.CreateTriggerSkill {
	name = "LuaCuorui",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DrawInitialCards,sgs.EventPhaseChanging},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			local n = 3 
			if room:getMode() == "02_1v1" then
				local list = player:getTag("1v1Arrange"):toStringList()
				n = #list
				player:speak(n)
				if sgs.GetConfig("1v1/Rule","2013") == "2013" then
					n = n + 3
				end
				local origin
				if sgs.GetConfig("1v1/Rule","2013") =="Classical" then
					origin = 4
				else
					origin = player:getMaxHp()
				end
				n = n + 2 - origin
				player:speak(n)
			end
			data:setValue(data:toInt() + n)
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Judge and player:getMark("CuoruiSkipJudge") == 0 then
				player:skip(sgs.Player_Judge)
				player:addMark("CuoruiSkipJudge")
			end
		end
		return false
	end
}
-----------
--[[D区]]--
-----------
--[[技能名：大喝
	相关武将：☆SP·张飞
	描述：出牌阶段限一次，你可以与一名角色拼点：若你赢，你可以将该角色的拼点牌交给一名体力值不多于你的角色，本回合该角色使用的非?【闪】无效；若你没赢，你展示所有手牌，然后弃置一张手牌。
	引用：LuaDahe、LuaDahePindian
	状态：0504验证通过
]]--
LuaDaheCard = sgs.CreateSkillCard{
	name = "LuaDaheCard",
	mute = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_use = function(self, room, source, targets)
		source:pindian(targets[1], "LuaDahe", nil)
	end
}
LuaDaheVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaDahe",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaDaheCard") and not player:isKongcheng()
	end,
	view_as = function(self)
		return LuaDaheCard:clone()
	end,
}
LuaDahe = sgs.CreateTriggerSkill{
	name = "LuaDahe",
	events = {sgs.JinkEffect, sgs.EventPhaseChanging, sgs.Death},
	view_as_skill = LuaDaheVS,
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.JinkEffect then
			local jink = data:toCard()
			local bgm_zhangfei = room:findPlayerBySkillName(self:objectName())
			if bgm_zhangfei and bgm_zhangfei:isAlive() and player:hasFlag(self:objectName()) and jink:getSuit() ~= sgs.Card_Heart then
				local log = sgs.LogMessage()
				log.from = bgm_zhangfei
				log.to:append(player)
				log.type = "#DaheEffect"
				log.arg = jink:getSuitString()
				log.arg2 = "LuaDahe"
				room:sendLog(log)
				
				return true
			end
			return false
		end
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who ~= player then return false end
		end
		for _,other in sgs.qlist(room:getOtherPlayers(player)) do
			if other:hasFlag(self:objectName()) then
				room:setPlayerFlag(other, "-"..self:objectName())
			end
		end
		return false
	end
}
LuaDahePindian = sgs.CreateTriggerSkill{
	name = "#LuaDahe",
	events = {sgs.Pindian},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pindian = data:toPindian()
		if pindian.reason ~= "LuaDahe" or not pindian.from:hasSkill("LuaDahe") or room:getCardPlace(pindian.to_card:getEffectiveId()) ~= sgs.Player_PlaceTable then return false end
		if pindian.from_card:getNumber() > pindian.to_card:getNumber() then
			room:setPlayerFlag(pindian.to, "LuaDahe")
			local to_givelist = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:getHp() <= pindian.from:getHp() then
					to_givelist:append(p)
				end
			end
			if not to_givelist:isEmpty() then
				local to_give = room:askForPlayerChosen(pindian.from, to_givelist, "LuaDahe", "@LuaDahe-give", true)
				if not to_give then return false end
				to_give:obtainCard(pindian.to_card)
			end
		else
			if not pindian.from:isKongcheng() then
				room:showAllCards(pindian.from)
				room:askForDiscard(pindian.from, "LuaDahe", 1, 1, false, false)
			end
		end
		return false
	end
}
--[[技能名：大雾
	相关武将：神·诸葛亮
	描述：结束阶段开始时，你可以将X张“星”置入弃牌堆并选择X名角色，若如此做，你的下回合开始前，每当这些角色受到的非雷电伤害结算开始时，防止此伤害。
	引用：LuaDawu
	状态：0405验证通过(需与本手册的“七星”配合使用)
	备注：医治永恒&水饺wch哥：源码狂风和大雾的技能询问与标记的清除分别位于七星的QixingAsk和QixingClear中，此技能独立出来了。
]]--
LuaDawuCard = sgs.CreateSkillCard{
	name = "LuaDawuCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	filter = function(self, targets, to_select, player)
		return #targets < self:subcardsLength()
	end,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "LuaDawu", "")
		room:throwCard(self, reason, nil)
		source:setTag("LuaQixing_user", sgs.QVariant(true))
		for _,p in ipairs(targets) do
			p:gainMark("@fog")
		end
	end,
}
LuaDawuVS = sgs.CreateViewAsSkill{
	name = "LuaDawu", 
	n = 998,
	response_pattern = "@@LuaDawu",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		return sgs.Self:getPile("stars"):contains(to_select:getId())
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local dw = LuaDawuCard:clone()
			for _,card in pairs(cards) do
				dw:addSubcard(card)
			end
			return dw
		end
		return nil
	end,
}
LuaDawu = sgs.CreateTriggerSkill{
	name = "LuaDawu",
	events = {sgs.DamageForseen},
	view_as_skill = LuaDawuVS,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("@fog") > 0
	end,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature ~= sgs.DamageStruct_Thunder then
			return true
		else
			return false
		end
	end,
}
--[[技能名：单骑（觉醒技）
	相关武将：SP·关羽
	描述：准备阶段开始时，若你的手牌数大于体力值，且本局游戏主公为曹操，你减1点体力上限，然后获得技能“马术”。
	引用：LuaDanji
	状态：0405验证通过
]]--
LuaDanji = sgs.CreateTriggerSkill{
	name = "LuaDanji",
	frequency = sgs.Skill_Wake,
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, target)
		return target:isAlive() and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_Start
			and target:getMark("danji") == 0 and target:getHandcardNum() > target:getHp()
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local lord = room:getLord()
		if lord and (string.find(lord:getGeneralName(), "caocao") or string.find(lord:getGeneral2Name(), "caocao")) then
			room:setPlayerMark(player, "danji", 1)
			if room:changeMaxHpForAwakenSkill(player) and player:getMark("danji") == 1 then
				room:acquireSkill(player, "mashu")
			end
		end
	end,
}
--[[技能名：胆守
	相关武将：一将成名2013·朱然
	描述： 每当你造成伤害后，你可以摸一张牌，然后结束当前回合并结束一切结算。
	状态：Lua无法实现
]]--
luaNosDanshou = sgs.CreateTriggerSkill{
	name = "luaNosDanshou" ,
	events = {sgs.Damage},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if room:askForSkillInvoke(player, self:objectName(), data) then
			player:drawCards(1, self:objectName())
			room:throwEvent(sgs.TurnBroken)
		end
		return false
	end
}
--[[技能名：啖酪
	相关武将：SP·杨修
	描述：每当至少两名角色成为锦囊牌的目标后，若你为目标角色，你可以摸一张牌，然后该锦囊牌对你无效。   
	引用：LuaDanlao
	状态：0405验证通过
]]--
LuaDanalao = sgs.CreateTriggerSkill{
	name = "LuaDanlao" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.to:length() <= 1 or not use.to:contains(player) or not use.card:isKindOf("TrickCard") 
			or not room:askForSkillInvoke(player, self:objectName(), data) then
			return false
		end
		player:setFlags("-LuaDanlaoTarget")
		player:setFlags("LuaDanlaoTarget")
		player:drawCards(1, self:objectName())
		if player:isAlive() and player:hasFlag("LuaDanlaoTarget") then
			player:setFlags("-LuaDanlaoTarget")
			local nullified_list = use.nullified_list
			table.insert(nullified_list, player:objectName())
			use.nullified_list = nullified_list
			data:setValue(use)
		end
		return false
	end
}
--[[技能名：当先（锁定技）
	相关武将：二将成名·廖化
	描述：回合开始时，你执行一个额外的出牌阶段。
	引用：LuaDangxian
	状态：0405验证通过
]]--
LuaDangxian = sgs.CreateTriggerSkill{
	name = "LuaDangxian" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_RoundStart then
			local room = player:getRoom()
			player:setPhase(sgs.Player_Play)
			room:broadcastProperty(player, "phase")
			local thread = room:getThread()
			if not thread:trigger(sgs.EventPhaseStart, room, player) then
				thread:trigger(sgs.EventPhaseProceeding, room, player)
			end
			thread:trigger(sgs.EventPhaseEnd, room, player)
			player:setPhase(sgs.Player_RoundStart)
			room:broadcastProperty(player, "phase")
		end
		return false
	end
}
--[[技能名：缔盟
	相关武将：林·鲁肃
	描述：出牌阶段限一次，你可以弃置任意数量的牌并选择两名手牌数差等于该数量的其他角色：若如此做，这两名角色交换他们的手牌。 
	引用：LuaDimeng
	状态：0405验证通过
]]--
local json = require ("json")
LuaDimengCard = sgs.CreateSkillCard{
	name = "LuaDimengCard",
	filter = function(self, targets, to_select)
		if to_select:objectName() == sgs.Self:objectName() then return false end
		if #targets == 0 then return true end
		if #targets == 1 then
			return math.abs(to_select:getHandcardNum() - targets[1]:getHandcardNum()) == self:subcardsLength()
		end
		return false
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		local a = targets[1]
		local b = targets[2]
		a:setFlags("DimengTarget")
		b:setFlags("DimengTarget")
		local n1 = a:getHandcardNum()
		local n2 = b:getHandcardNum()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:objectName() ~= a:objectName() and p:objectName() ~= b:objectName() then
				room:doNotify(p, sgs.CommandType.S_COMMAND_EXCHANGE_KNOWN_CARDS, json.encode({a:objectName(), b:objectName()}))
			end
		end
		local exchangeMove = sgs.CardsMoveList()
		local move1 = sgs.CardsMoveStruct(a:handCards(), b, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, a:objectName(), b:objectName(), "dimeng", ""))
		local move2 = sgs.CardsMoveStruct(b:handCards(), a, sgs.Player_PlaceHand, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, b:objectName(), a:objectName(), "dimeng", ""))
		exchangeMove:append(move1)
		exchangeMove:append(move2)
        	room:moveCardsAtomic(exchangeMove, false);
	   	a:setFlags("-DimengTarget")
	   	b:setFlags("-DimengTarget")
	end
}
LuaDimeng = sgs.CreateViewAsSkill{
	name = "LuaDimeng",
	n = 999 ,
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end ,
	view_as = function(self, cards)
		local card = LuaDimengCard:clone()
		for _, c in ipairs(cards) do
	   		card:addSubcard(c)
		end
	   	return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaDimengCard")
	end
}
--[[技能名：定品
	相关武将：四将·陈群
	描述：出牌阶段，你可以弃置一张与你本回合已使用或弃置的牌类别均不同的手牌，然后令一名已受伤的角色进行判定：若结果为黑色，该角色摸X张牌，且你本阶段不能对该角色发动“定品”；红色，你将武将牌翻面。（X为该角色已损失的体力值）
	引用：LuaDingpin
	状态：0428验证通过
]]--
LuaDingpinCard = sgs.CreateSkillCard{
    name = "LuaDingpinCard" ,
    filter = function(self, targets, to_select, Self)
        return #targets == 0 and to_select:isWounded() and (not to_select:hasFlag("LuaDingpin"))
    end ,
    on_effect = function(self, effect) 
        local room = effect.from:getRoom()
        
        local judge = sgs.JudgeStruct()
        judge.who = effect.to
        judge.good = true
        judge.pattern = ".|black"
        judge.reason = "LuaDingpin"
        
        room:judge(judge)
        
        if (judge:isGood()) then
            room:setPlayerFlag(effect.to, "LuaDingpin")
            effect.to:drawCards(effect.to:getLostHp(), "LuaDingpin")
        else
            effect.from:turnOver()
        end
    end ,
}
LuaDingpinVS = sgs.CreateOneCardViewAsSkill{
    name = "LuaDingpin" ,
    enabled_at_play = function(self, player)
        if (not player:canDiscard(player, "h")) or (player:getMark("LuaDingpin") == 14) then return false end
        if (not player:hasFlag("LuaDingpin")) and player:isWounded() then return true end
        for _, p in sgs.qlist(player:getAliveSiblings()) do
            if (not p:hasFlag("LuaDingpin")) and p:isWounded() then return true end
        end
        
        return false
    end ,
    view_filter = function(self, card)
        return (not card:isEquipped()) and (bit32.band(sgs.Self:getMark("LuaDingpin"), bit32.lshift(1, card:getTypeId())) == 0)
    end ,
    view_as = function(self, card)
        local dp = LuaDingpinCard:clone()
        dp:addSubcard(card)
        return dp
    end ,
}
function recordLuaDingpinCardType(room, player, card)
    if player:getMark("LuaDingpin") == 14 then return end
    local typeid = bit32.lshift(1, card:getTypeId())
    local mark = player:getMark("LuaDingpin")
    if (bit32.band(mark, typeid) == 0) then
        room:setPlayerMark(player, "LuaDingpin", bit32.bor(mark, typeid))
    end
end
LuaDingpin = sgs.CreateTriggerSkill{
    name = "LuaDingpin" ,
    events = {sgs.EventPhaseChanging, sgs.PreCardUsed, sgs.CardResponded, sgs.BeforeCardsMove} ,
    view_as_skill = LuaDingpinVS ,
    global = true ,
    on_trigger = function(self, event, player, data) 
        local room = player:getRoom()
        if (event == sgs.EventPhaseChanging) then
            local change = data:toPhaseChange()
            if (change.to == sgs.Player_NotActive) then
                for _, p in sgs.qlist(room:getAllPlayers()) do
                    if p:hasFlag("LuaDingpin") then
                        room:setPlayerFlag(p, "-LuaDingpin")
                    end
                end
                if (player:getMark("LuaDingpin") > 0) then
                    room:setPlayerMark(player, "LuaDingpin", 0)
                end
            end
        else
            if (not player:isAlive()) or (player:getPhase() == sgs.Player_NotActive) then return false end
            if (event == sgs.PreCardUsed) or (event == sgs.CardResponded) then
                local card = nil
                if (event == sgs.PreCardUsed) then
                    card = data:toCardUse().card
                else
                    local resp = data:toCardResponse()
                    if (resp.m_isUse) then
                        card = resp.m_card
                    end
                end
                if (not card) or (card:getTypeId() == sgs.Card_TypeSkill) then return false end
                recordLuaDingpinCardType(room, player, card)
            elseif event == sgs.BeforeCardsMove then
                local move = data:toMoveOneTime()
                if (not move.from) or (player:objectName() ~= move.from:objectName()) or (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) ~= sgs.CardMoveReason_S_REASON_DISCARD) then
                    return false
                end
                for _, id in sgs.qlist(move.card_ids) do
                    local c = sgs.Sanguosha:getCard(id)
                    recordLuaDingpinCardType(room, player, c)
                end
            end
        end
        return false
    end ,
}
--[[技能名：洞察
	相关武将：倚天·贾文和
	描述：回合开始阶段开始时，你可以指定一名其他角色：该角色的所有手牌对你处于可见状态，直到你的本回合结束。其他角色都不知道你对谁发动了洞察技能，包括被洞察的角色本身
	引用：LuaDongcha
	状态：1217验证通过
]]--
function findServerPlayer(room,name)
	for _,p in sgs.qlist(room:getAlivePlayers()) do
		if p:objectName() == name then
			return p
		end
	end
	return nil
end
LuaDongcha = sgs.CreateTriggerSkill{
	name = "LuaDongcha",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,player,data)
		local phase = player:getPhase()
		local room = player:getRoom()
		if phase == sgs.Player_Start then
			local shou = room:askForPlayerChosen(player,room:getOtherPlayers(player),self:objectName(),"@LuaDongcha",true,false)
			if shou then
				room:setPlayerFlag(shou,"dongchaee")
				room:setTag("Dongchaee",sgs.QVariant(shou:objectName()))
				room:setTag("Dongchaer",sgs.QVariant(player:objectName()))
				room:showAllCards(shou,player)
			end
		elseif phase == sgs.Player_Finish then
			local shou_name = room:getTag("Dongchaee"):toString()
			if shou_name ~= "" then
				local shou = findServerPlayer(room,shou_name)
				if shou then
					room:setPlayerFlag(shou,"-dongchaee")
					room:setTag("Dongchaee",sgs.QVariant())
					room:setTag("Dongchaer",sgs.QVariant())
				end
			end
		end
		return false
	end
}
--[[技能名：毒士（锁定技）
	相关武将：倚天·贾文和
	描述：杀死你的角色获得崩坏技能直到游戏结束
	引用：LuaDushi
	状态：0405验证通过
]]--
LuaDushi = sgs.CreateTriggerSkill{
	name = "LuaDushi",
	events = {sgs.Death},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		local killer = nil
		if death.damage then killer = death.damage.from end
		if death.who:objectName() == player:objectName() and killer then
			if killer:objectName() ~= player:objectName() then
				killer:gainMark("@collapse")
				room:acquireSkill(killer, "benghuai")
			end
		end
		return false
	end,
}
--[[技能名：毒医
	相关武将：铜雀台·吉本
	描述：出牌阶段限一次，你可以亮出牌堆顶的一张牌并交给一名角色，若此牌为黑色，该角色不能使用或打出其手牌，直到回合结束。
	引用：LuaDuyi
	状态：0504验证通过
]]--
LuaDuyiCard = sgs.CreateSkillCard{
	name = "LuaDuyiCard" ,
	target_fixed = true ,
	mute = true ,
	on_use = function(self, room, source, targets)
		local card_ids = room:getNCards(1)
		local id = card_ids:first()
		room:fillAG(card_ids, nil)
		local target = room:askForPlayerChosen(source, room:getAlivePlayers(), "LuaDuyi")
		local card = sgs.Sanguosha:getCard(id)
		target:obtainCard(card)
		if card:isBlack() then
			room:setPlayerCardLimitation(target, "use,response", ".|.|.|hand", false)
			room:setPlayerMark(target, "LuaDuyi_target", 1)
		end
		room:clearAG()
	end
}
LuaDuyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaDuyi" ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaDuyiCard")
	end ,
	view_as = function()
		return LuaDuyiCard:clone()
	end ,
}
LuaDuyi = sgs.CreateTriggerSkill{
	name = "LuaDuyi" ,
	events = {sgs.EventPhaseChanging, sgs.Death} ,
	view_as_skill = LuaDuyiVS ,
	can_trigger = function(self, target)
		return target and target:hasInnateSkill(self:objectName())
	end ,
	on_trigger = function(self, event, player, data)
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
		else
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		end
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAlivePlayers()) do
			if p:getMark("LuaDuyi_target") > 0 then
				room:removePlayerCardLimitation(p, "use,response", ".|.|.|hand$0")
				room:setPlayerMark(p, "LuaDuyi_target", 0)
			end
		end
		return false
	end ,
}
--[[技能名：黩武
	相关武将：SP·诸葛恪
	描述：出牌阶段，你可以选择攻击范围内的一名其他角色并弃置X张牌：若如此做，你对该角色造成1点伤害。
		若你以此法令该角色进入濒死状态，濒死结算后你失去1点体力，且本阶段你不能再次发动“黩武”。（X为该角色当前的体力值）
	状态：0504验证通过
]]--
LuaDuwuCard = sgs.CreateSkillCard{
	name = "LuaDuwuCard" ,
	filter = function(self, targets, to_select)
		if (#targets ~= 0) or (math.max(0, to_select:getHp()) ~= self:subcardsLength()) then return false end
		if sgs.Self:getWeapon() and self:getSubcards():contains(sgs.Self:getWeapon():getId()) then
			local weapon = sgs.Self:getWeapon():getRealCard():toWeapon()
			local distance_fix = weapon:getRange() - sgs.Self:getAttackRange(false)
			if sgs.Self:getOffensiveHorse() and self:getSubcards():contains(sgs.Self:getOffensiveHorse():getId()) then
				distance_fix = distance_fix + 1
			end
			return sgs.Self:inMyAttackRange(to_select, distance_fix)
		elseif sgs.Self:getOffensiveHorse() and self:getSubcards():contains(sgs.Self:getOffensiveHorse():getId()) then
			return sgs.Self:inMyAttackRange(to_select, 1)
		else
			return sgs.Self:inMyAttackRange(to_select)
		end
	end ,
	on_effect = function(self, effect)
		effect.from:getRoom():damage(sgs.DamageStruct("LuaDuwu", effect.from, effect.to))
	end
}
LuaDuwuVS = sgs.CreateViewAsSkill{
	name = "LuaDuwu" ,
	n = 999 ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and (not player:hasFlag("LuaDuwuEnterDying"))
	end ,
	view_filter = function(self, selected, to_select)
		return not sgs.Self:isJilei(to_select)
	end ,
	view_as = function(self, cards)
		local duwu = LuaDuwuCard:clone()
		if #cards ~= 0 then
			for _, c in ipairs(cards) do
				duwu:addSubcard(c)
			end
		end
		return duwu
	end ,
}
LuaDuwu = sgs.CreateTriggerSkill{
	name = "LuaDuwu" ,
	events = {sgs.QuitDying} ,
	view_as_skill = LuaDuwuVS ,
	can_trigger = function(self, target)
		return target ~= nil
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if dying.damage and dying.damage:getReason() == "LuaDuwu" and not dying.damage.chain and not dying.damage.transfer then
			local from = dying.damage.from
			if from and from:isAlive() then
				room:setPlayerFlag(from, "LuaDuwuEnterDying")
				room:loseHp(from,1)
			end
		end
		return false
	end,
}
--[[技能名：短兵
	相关武将：国战·丁奉
	描述：你使用【杀】可以额外选择一名距离1的目标。
	引用：LuaXDuanbing
	状态：0504验证通过
	附注：原技能涉及修改源码。Lua的版本以此法可实现，但体验感略微欠佳。
]]--
LuaXDuanbing = sgs.CreateTriggerSkill{
	name = "LuaXDuanbing",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			local room = player:getRoom()
			local targets = sgs.SPlayerList()
			local others = room:getOtherPlayers(player)
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _,p in sgs.qlist(others) do
				if player:distanceTo(p) == 1 then
					if not use.to:contains(p) then
						if player:canSlash(p, use.card) then
							room:setPlayerFlag(p, "duanbingslash")
							targets:append(p)
						end
					end
				end
			end
			if not targets:isEmpty() then
				if player:askForSkillInvoke(self:objectName()) then
					local target = room:askForPlayerChosen(player, targets, self:objectName())
					for _,p in sgs.qlist(others) do
						if p:hasFlag("duanbingslash") then
							room:setPlayerFlag(p, "-duanbingslash")
						end
					end
					use.to:append(target)
					data:setValue(use)
				end
			end
		end
	end,
}
--[[技能名：断肠（锁定技）
	相关武将：山·蔡文姬、SP·蔡文姬
	描述：杀死你的角色失去所有武将技能。 
	引用：LuaDuanchang
	状态：0405验证通过
]]--
LuaDuanchang = sgs.CreateTriggerSkill{
	name = "LuaDuanchang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local room = player:getRoom()
		if death.who:objectName() ~= player:objectName() then
			return false
		end
		if death.damage and death.damage.from then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local skills = death.damage.from:getVisibleSkillList()
			local detachList = {}
			for _,skill in sgs.qlist(skills) do
				if not skill:inherits("SPConvertSkill") and not skill:isAttachedLordSkill() then
					table.insert(detachList,"-"..skill:objectName())
				end
			end
			room:handleAcquireDetachSkills(death.damage.from, table.concat(detachList,"|"))
			if death.damage.from:isAlive() then
				death.damage.from:gainMark("@duanchang")
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end
}
--[[技能名：断粮
	相关武将：林·徐晃
	描述：你可以将一张黑色的基本牌或黑色的装备牌当【兵粮寸断】使用。你使用【兵粮寸断】的距离限制为2。 
	引用：LuaDuanliangTargetMod，LuaDuanliang
	状态：0405验证通过
]]--
LuaDuanliang = sgs.CreateOneCardViewAsSkill{
	name = "LuaDuanliang",
	filter_pattern = "BasicCard,EquipCard|black",
	response_or_use = true,
	view_as = function(self, card)
		local shortage = sgs.Sanguosha:cloneCard("supply_shortage",card:getSuit(),card:getNumber())
		shortage:setSkillName(self:objectName())
		shortage:addSubcard(card)
		return shortage
	end
}
LuaDuanliangTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaDuanliang-target",
	pattern = "SupplyShortage",
	distance_limit_func = function(self, from)
		if from:hasSkill("LuaDuanliang") then
			return 1
		else
			return 0
		end
	end
}
--[[技能名：断指
	相关武将：铜雀台·吉本
	描述：当你成为其他角色使用的牌的目标后，你可以弃置其至多两张牌（也可以不弃置），然后失去1点体力。
	引用：LuaXDuanzhi、LuaXDuanzhiFakeMove
	状态：1217验证通过	
]]--
LuaXDuanzhi = sgs.CreateTriggerSkill{
	name = "LuaXDuanzhi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:getTypeId() == sgs.Card_TypeSkill or use.from:objectName() == player:objectName() or (not use.to:contains(player)) then
			return false
		end
		if player:askForSkillInvoke(self:objectName(), data) then
			room:setPlayerFlag(player, "LuaXDuanzhi_InTempMoving");
			local target = use.from
			local dummy = sgs.Sanguosha:cloneCard("slash") --没办法了，暂时用你代替DummyCard吧……
			local card_ids = sgs.IntList()
			local original_places = sgs.PlaceList()
			for i = 1,2,1 do
				if not player:canDiscard(target, "he") then break end
				if room:askForChoice(player, self:objectName(), "discard+cancel") == "cancel" then break end
				card_ids:append(room:askForCardChosen(player, target, "he", self:objectName()))
				original_places:append(room:getCardPlace(card_ids:at(i-1)))
				dummy:addSubcard(card_ids:at(i-1))
				target:addToPile("#duanzhi", card_ids:at(i-1), false)
			end
			if dummy:subcardsLength() > 0 then
				for i = 1,dummy:subcardsLength(),1 do
					room:moveCardTo(sgs.Sanguosha:getCard(card_ids:at(i-1)), target, original_places:at(i-1), false)
				end
			end
			room:setPlayerFlag(player, "-LuaXDuanzhi_InTempMoving")
			if dummy:subcardsLength() > 0 then
				room:throwCard(dummy, target, player)
			end
			room:loseHp(player);
		end
		return false
	end,
}
LuaXDuanzhiFakeMove = sgs.CreateTriggerSkill{
	name = "#LuaXDuanzhi-fake-move",
	events = {sgs.BeforeCardsMove,sgs.CardsMoveOneTime},
	priority = 10,
	on_trigger = function(self, event, player, data)
		if player:hasFlag("LuaXDuanzhi_InTempMoving") then
			return true
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[技能名：夺刀
	相关武将：一将成名2013·潘璋&马忠
	描述：每当你受到一次【杀】造成的伤害后，你可以弃置一张牌，获得伤害来源装备区的武器牌。
	引用：LuaDuodao
	状态：0405验证通过
]]--
LuaDuodao = sgs.CreateTriggerSkill{
	name = "LuaDuodao" ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if not damage.card or not damage.card:isKindOf("Slash") or not player:canDiscard(player, "he") then
			return
		end
		local _data = sgs.QVariant()
		_data:setValue(damage)
		local room = player:getRoom()
		if room:askForCard(player, "..", "@duodao-get", _data, self:objectName()) then
			if damage.from and damage.from:getWeapon() then
				player:obtainCard(damage.from:getWeapon())
			end
		end
	end
}
--[[技能名：度势
	相关武将：国战·陆逊
	描述：出牌阶段限四次，你可以弃置一张红色手牌并选择任意数量的其他角色，你与这些角色先各摸两张牌，然后各弃置两张牌。
	引用：LuaXDuoshi
	状态：1217验证通过	
]]--
LuaXDuoshiCard = sgs.CreateSkillCard{
	name = "LuaXDuoshiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return to_select:objectName() ~= sgs.Self:objectName()
	end,
	feasible = function(self, targets)
		return true
	end,
	on_use = function(self, room, source, targets)
		source:drawCards(2)
		for i=1, #targets, 1 do
			targets[i]:drawCards(2)
		end
		room:askForDiscard(source, "LuaXDuoshi", 2, 2, false, true, "#LuaXDuoshi-discard")
		for i=1, #targets, 1 do
			room:askForDiscard(targets[i], "LuaXDuoshi", 2, 2, false, true, "#LuaXDuoshi-discard")
		end
	end,
}
LuaXDuoshi = sgs.CreateViewAsSkill{
	name = "LuaXDuoshi",
	n = 1,
	view_filter = function(self, selected, to_select)
		if to_select:isRed() then
			if not to_select:isEquipped() then
				return not sgs.Self:isJilei(to_select)
			end
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local await = LuaXDuoshiCard:clone()
			await:addSubcard(cards[1])
			await:setSkillName(self:objectName())
			return await
		end
	end,
	enabled_at_play = function(self, player)
		return player:usedTimes("#LuaXDuoshiCard") < 4
	end
}
	技能名：断粮
	相关武将：林·徐晃
	描述：你可以将一张黑色牌当【兵粮寸断】使用，此牌必须为基本牌或装备牌；你可以对距离2以内的一名其他角色使用【兵粮寸断】。 
]]--
-----------
--[[E区]]--
-----------
--[[技能名：恩怨
	相关武将：一将成名·法正
	描述：你每次获得一名其他角色两张或更多的牌时，可以令其摸一张牌；每当你受到1点伤害后，你可以令伤害来源选择一项：交给你一张手牌，或失去1点体力。
	引用：LuaEnyuan
	状态：1217验证通过
]]--
LuaEnyuan = sgs.CreateTriggerSkill{
	name = "LuaEnyuan" ,
	events = {sgs.CardsMoveOneTime, sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.to and (move.to:objectName() == player:objectName()) and move.from and move.from:isAlive()
					and (move.from:objectName() ~= move.to:objectName())
					and (move.card_ids:length() >= 2)
					and (move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_PREVIEWGIVE) then
				local _movefrom
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if move.from:objectName() == p:objectName() then
						_movefrom = p
						break
					end
				end   --我去MoveOneTime的from居然是player不是splayer，还得枚举所有splayer获取下……
				_movefrom:setFlags("LuaEnyuanDrawTarget")
				local invoke = room:askForSkillInvoke(player, self:objectName(), data)
				_movefrom:setFlags("-LuaEnyuanDrawTarget")
				if invoke then
					room:drawCards(_movefrom, 1)
				end
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			local source = damage.from
			if (not source) or (source:objectName() == player:objectName()) then return false end
			local x = damage.damage
			for i = 0, x - 1, 1 do
				if source:isAlive() and player:isAlive() then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						local card
						if not source:isKongcheng() then
							card = room:askForExchange(source, self:objectName(), 1, false, "LuaEnyuanGive", true)
						end
						if card then
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(),
															  player:objectName(), self:objectName(), nil)
							reason.m_playerId = player:objectName()
							room:moveCardTo(card, source, player, sgs.Player_PlaceHand, reason)
						else
							room:loseHp(source)
						end
					else
						break
					end
				else
					break
				end
			end
		end
		return false
	end
}
--[[技能名：恩怨（锁定技）
	相关武将：怀旧·法正
	描述：其他角色每令你回复1点体力，该角色摸一张牌；其他角色每对你造成一次伤害后，需交给你一张红桃手牌，否则该角色失去1点体力。
	引用：LuaNosEnyuan
	状态：0405验证通过
]]--
LuaNosEnyuan = sgs.CreateTriggerSkill{
	name = "LuaNosEnyuan" ,
	events = {sgs.HpRecover, sgs.Damaged} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.HpRecover then
			local recover = data:toRecover()
			if recover.who and (recover.who:objectName() ~= player:objectName()) then
				recover.who:drawCards(recover.recover, self:objectName())
			end
		elseif event == sgs.Damaged then
			local damage = data:toDamage()
			local source = damage.from
			if source and (source:objectName() ~= player:objectName()) then
				local card = room:askForCard(source, ".|heart|.|hand", "@nosenyuan-heart", data, sgs.Card_MethodNone)
				if card then
					player:obtainCard(card)
				else
					room:loseHp(source)
				end
			end
		end
		return false
	end
}
-----------
--[[F区]]--
-----------
--[[技能名：反间
	相关武将：标准·周瑜
	描述：出牌阶段，你可以令一名其他角色说出一种花色，然后获得你的一张手牌并展示之，若此牌不为其所述之花色，你对该角色造成1点伤害。每阶段限一次。
	引用：LuaFanjian
	状态：1217验证通过
]]--
LuaFanjianCard = sgs.CreateSkillCard{
	name = "LuaFanjianCard",

	on_effect = function(self, effect)
		local zhouyu = effect.from
		local target = effect.to
		local room = zhouyu:getRoom()
		local card_id = zhouyu:getRandomHandCardId()
		local card = sgs.Sanguosha:getCard(card_id)
		local suit = room:askForSuit(target, "LuaFanjian")
		room:getThread():delay()
		target:obtainCard(card)
		room:showCard(target, card_id)
		if card:getSuit() ~= suit then
			room:damage(sgs.DamageStruct("LuaFanjian", zhouyu, target))
		end
	end
}
LuaFanjian = sgs.CreateZeroCardViewAsSkill{
	name = "LuaFanjian",
	
	view_as = function()
		return LuaFanjianCard:clone()
	end,

	enabled_at_play = function(self, player)
		return (not player:isKongcheng()) and (not player:hasUsed("#LuaFanjianCard"))
	end
}
--[[技能名：反间
	相关武将：翼·周瑜
	描述：出牌阶段，你可以选择一张手牌，令一名其他角色说出一种花色后展示并获得之，若猜错则其受到你对其造成的1点伤害。每阶段限一次。
	引用：LuaXNeoFanjian
	状态：1217验证通过
]]--
LuaXNeoFanjianCard = sgs.CreateSkillCard{
	name = "LuaXNeoFanjianCard",
	target_fixed = false,
	will_throw = false,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local subid = self:getSubcards():first()
		local card = sgs.Sanguosha:getCard(subid)
		local card_id = card:getEffectiveId()
		local suit = room:askForSuit(target, "LuaXNeoFanjian")
		room:getThread():delay()
		target:obtainCard(self)
		room:showCard(target, card_id)
		if card:getSuit() ~= suit then
			local damage = sgs.DamageStruct()
			damage.card = nil
			damage.from = source
			damage.to = target
			room:damage(damage)
		end
	end
}
LuaXNeoFanjian = sgs.CreateViewAsSkill{
	name = "LuaXNeoFanjian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = LuaXNeoFanjianCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if not player:isKongcheng() then
			return not player:hasUsed("#LuaXNeoFanjianCard")
		end
		return false
	end
}
--[[技能名：反馈
	相关武将：界限突破·司马懿
	描述：每当你受到1点伤害后，你可以获得伤害来源的一张牌。 
	引用：LuaFankui
	状态：0405验证通过
]]--
LuaFankui = sgs.CreateMasochismSkill{
	name = "LuaFankui",
	on_damaged = function(self, player, damage)
		local from = damage.from
		local room = player:getRoom()
		for i = 0, damage.damage - 1, 1 do
			local data = sgs.QVariant()
			data:setValue(from)
			if from and not from:isNude() and room:askForSkillInvoke(player, self:objectName(), data) then
				local card_id = room:askForCardChosen(player, from, "he", self:objectName())
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
				room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
			else
				break
			end
		end
	end
}
--[[技能名：反馈
	相关武将：标准·司马懿
	描述：每当你受到伤害后，你可以获得伤害来源的一张牌。   
	引用：LuaNosFankui
	状态：0405验证通过
]]--
LuaNosFankui = sgs.CreateMasochismSkill{
	name = "LuaNosFankui",
	on_damaged = function(self, player, damage)
		local from = damage.from
		local room = player:getRoom()
		local data = sgs.QVariant()
		data:setValue(from)
		if from and not from:isNude() and room:askForSkillInvoke(player, self:objectName(), data) then
			local card_id = room:askForCardChosen(player, from, "he", self:objectName())
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
			room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
		end
	end
}
--[[技能名：逢亮
	相关武将：界限突破SP·姜维
	描述：觉醒技，当你进入濒死状态时，你减1点体力上限并将体力值恢复至2点，然后获得技能“挑衅”，将技能“困奋”改为非锁定技。   
	引用：LuaFengliang
	状态：0504验证通过
	备注：zy：要和手册里的困奋配合使用、或者将获得的标记改为“fengliang”并将“LuaKunfen”改为“kunfen”
]]--
LuaFengliang = sgs.CreateTriggerSkill{
	name = "LuaFengliang" ,
	events = {sgs.EnterDying} ,
	frequency = sgs.Skill_Wake ,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName()) and target:isAlive() and target:getMark(self:objectName()) == 0
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
        room:addPlayerMark(player, self:objectName(), 1)
        if room:changeMaxHpForAwakenSkill(player) and player:getMark(self:objectName()) > 0 then
            local recover = 2 - player:getHp()
            room:recover(player, sgs.RecoverStruct(nil, nil, recover))
            room:handleAcquireDetachSkills(player, "tiaoxin")
            if player:hasSkill("LuaKunfen", true) then
				room:doNotify(player, 86, sgs.QVariant("LuaKunfen"))
			end
        end
		return false
	end
}
--[[技能名：放权
	相关武将：山·刘禅
	描述：你可以跳过你的出牌阶段，若如此做，你在回合结束时可以弃置一张手牌令一名其他角色进行一个额外的回合。
	引用：LuaFangquan、LuaFangquanGive
	状态：1217验证通过
]]--
LuaFangquan = sgs.CreateTriggerSkill{
	name = "LuaFangquan" ,
	events = {sgs.EventPhaseChanging} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Play then
			local invoked = false
			if player:isSkipped(sgs.Player_Play) then return false end
			invoked = player:askForSkillInvoke(self:objectName())
			if invoked then
				player:setFlags("LuaFangquan")
				player:skip(sgs.Player_Play)
			end
		elseif change.to == sgs.Player_NotActive then
			if player:hasFlag("LuaFangquan") then
				if not player:canDiscard(player, "h") then return false end
				if not room:askForDiscard(player, "LuaFangquan", 1, 1, true) then return false end
				local _player = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
				local p = _player
				local playerdata = sgs.QVariant()
				playerdata:setValue(p)
				room:setTag("LuaFangquanTarget", playerdata)
			end
		end
		return false
	end
}
LuaFangquanGive = sgs.CreateTriggerSkill{
	name = "#LuaFangquan-give" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:getTag("LuaFangquanTarget") then
			local target = room:getTag("LuaFangquanTarget"):toPlayer()
			room:removeTag("LuaFangquanTarget")
			if target and target:isAlive() then
				target:gainAnExtraTurn()
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (target:getPhase() == sgs.Player_NotActive)
	end ,
	priority = 1
}
--[[技能名：放逐
	相关武将：林·曹丕、铜雀台·曹丕、神·司马懿
	描述：每当你受到伤害后，你可以令一名其他角色摸X张牌，然后将其武将牌翻面。（X为你已损失的体力值）   
	引用：LuaFangzhu
	状态：0405验证通过
]]--
LuaFangzhu = sgs.CreateMasochismSkill{
	name = "LuaFangzhu",
	on_damaged = function(self, player)
		local room = player:getRoom()
		local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "fangzhu-invoke", player:getMark("JilveEvent") ~= 35, true)
		if to then
			to:drawCards(player:getLostHp(), self:objectName())
			to:turnOver()
		end
	end
}
--[[技能名：飞影（锁定技）
	相关武将：神·曹操、倚天·魏武帝
	描述：其他角色与你的距离+1 
	引用：LuaFeiying
	状态：0405验证通过
]]--
LuaFeiying = sgs.CreateDistanceSkill{
	name = "LuaFeiying",
	correct_func = function(self, from, to)
		if to:hasSkill("LuaFeiying") then
			return 1
		else
			return 0
		end
	end
}
--[[技能名：焚城（限定技）
	相关武将：一将成名2013·李儒
	描述：出牌阶段，你可以令所有其他角色选择一项：弃置X张牌，或受到你对其造成的1点火焰伤害。（X为该角色装备区牌的数量且至少为1）
	引用：LuaFencheng
	状态：1217验证通过
]]--
LuaFenchengCard = sgs.CreateSkillCard{
	name = "LuaFenchengCard" ,
	target_fixed = true ,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@burn")
		local players = room:getOtherPlayers(source)
		source:setFlags("LuaFenchengUsing")
		for _, player in sgs.qlist(players) do
			if player:isAlive() then
				room:cardEffect(self, source, player)
			end
		end
		source:setFlags("-LuaFenchengUsing")
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local length = math.max(1, effect.to:getEquips():length())
		if not effect.to:canDiscard(effect.to, "he") then
			room:damage(sgs.DamageStruct("LuaFencheng", effect.from, effect.to, 1, sgs.DamageStruct_Fire))
		elseif not room:askForDiscard(effect.to, "LuaFencheng", length, length, true, true) then
			room:damage(sgs.DamageStruct("LuaFencheng", effect.from, effect.to, 1, sgs.DamageStruct_Fire))
		end
	end
}
LuaFenchengVS = sgs.CreateViewAsSkill{
	name = "LuaFencheng" ,
	n = 0,
	view_as = function()
		return LuaFenchengCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return player:getMark("@burn") >= 1
	end
}
LuaFencheng = sgs.CreateTriggerSkill{
	name = "LuaFencheng" ,
	frequency = sgs.Skill_Limited,
	limit_mark = "@burn",
	events = {},
	view_as_skill = LuaFenchengVS,
	
	on_trigger = function()
	end
}
--[[技能名：焚心（限定技）
	相关武将：铜雀台·灵雎、SP·灵雎
	描述：当你杀死一名非主公角色时，在其翻开身份牌之前，你可以与该角色交换身份牌。（你的身份为主公时不能发动此技能。）
	引用：LuaXFenxin
	状态：1217验证通过
]]--
LuaXFenxin = sgs.CreateTriggerSkill{
	name = "LuaXFenxin",
	frequency = sgs.Skill_Limited,
	events = {sgs.AskForPeachesDone},
	limit_mark = "@burnheart",
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mode = room:getMode()
		if string.sub(mode, -1) == "p" or string.sub(mode, -2) == "pd" or string.sub(mode, -2) == "pz" then
			local dying = data:toDying()
			if dying.damage then
				local killer = dying.damage.from
				if killer and not killer:isLord() then
					if not player:isLord() and player:getHp() <= 0 then
						if killer:hasSkill(self:objectName()) then
							if killer:getMark("@burnheart") > 0 then
								room:setPlayerFlag(player, "FenxinTarget")
								local ai_data = sgs.QVariant()
								ai_data:setValue(player)
								if room:askForSkillInvoke(killer, self:objectName(), ai_data) then
									killer:loseMark("@burnheart")
									local role1 = killer:getRole()
									local role2 = player:getRole()
									killer:setRole(role2)
									room:setPlayerProperty(killer, "role", sgs.QVariant(role2))
									player:setRole(role1)
									room:setPlayerProperty(player, "role", sgs.QVariant(role1))
								end
								room:setPlayerFlag(player, "-FenxinTarget")
								return false
							end
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：奋激
	相关武将：风·周泰
	描述：每当一名角色的手牌因另一名角色的弃置或获得为手牌而失去后，你可以失去1点体力：若如此做，该角色摸两张牌。 
	引用：LuaFenji
	状态：0405验证通过
]]--
LuaFenji = sgs.CreateTriggerSkill{
	name = "LuaFenji",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if player:getHp() > 0 and move.from and move.from:isAlive() and move.from_places:contains(sgs.Player_PlaceHand)
			and ((move.reason.m_reason == sgs.CardMoveReason_S_REASON_DISMANTLE
			and move.reason.m_playerId ~= move.reason.m_targetId)
			or (move.to and move.to:objectName() ~= move.from:objectName() and move.to_place == sgs.Player_PlaceHand
				and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_GIVE
				and move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_SWAP)) then
			move.from:setFlags("LuaFenjiMoveFrom") --For AI
			local invoke = room:askForSkillInvoke(player, self:objectName(), data)
			move.from:setFlags("-LuaFenjiMoveFrom")
			if invoke then
				room:loseHp(player)
				if move.from:isAlive() then
					for _,p in sgs.qlist(room:getAllPlayers()) do
						if p:objectName() == move.from:objectName() then
							room:drawCards(p, 2, "LuaFenji")
							break
						end
					end
				end
			end
		end
	end
}
--[[技能名：奋迅
	相关武将：国战·丁奉
	描述：出牌阶段限一次，你可以弃置一张牌并选择一名其他角色，你获得以下锁定技：本回合你无视与该角色的距离。
	引用：LuaFenxun
	状态：1217验证通过
]]--
LuaFenxunCard = sgs.CreateSkillCard{
	name = "LuaFenxunCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local _data = sgs.QVariant()
		_data:setValue(effect.to)
		effect.from:setTag("LuaFenxunTarget", _data)
		room:setFixedDistance(effect.from, effect.to, 1)
	end
}
LuaFenxunVS = sgs.CreateViewAsSkill{
	name = "LuaFenxun" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and (not sgs.Self:isJilei(to_select))
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local first = LuaFenxunCard:clone()
		first:addSubcard(cards[1])
		first:setSkillName(self:objectName())
		return first
	end ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and (not player:hasUsed("#LuaFenxunCard"))
	end
}
LuaFenxun = sgs.CreateTriggerSkill{
	name = "LuaFenxun" ,
	events = {sgs.EventPhaseChanging, sgs.Death, sgs.EventLoseSkill} ,
	view_as_skill = LuaFenxunVS ,
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
		elseif event == sgs.EventLoseSkill then
			if data:toString() ~= self:objectName() then return false end
		end
		local target = player:getTag("LuaFenxunTarget"):toPlayer()
		if target then
			player:getRoom():setFixedDistance(player, target, -1)
			player:removeTag("LuaFenxunTarget")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:getTag("LuaFenxunTarget"):toPlayer()
	end
}
--[[技能名：愤勇
	相关武将：☆SP·夏侯惇
	描述：每当你受到一次伤害后，你可以竖置你的体力牌；当你的体力牌为竖置状态时，防止你受到的所有伤害。
	引用：LuaFenyong、LuaFenyongClear
	状态：1217验证通过
]]--
LuaFenyong = sgs.CreateTriggerSkill{
	name = "LuaFenyong" ,
	events = {sgs.Damaged, sgs.DamageInflicted} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged then
			if player:getMark("@fenyong") == 0 then
				if player:askForSkillInvoke(self:objectName()) then
					player:gainMark("@fenyong")
				end
			end
		elseif event == sgs.DamageInflicted then
			if player:getMark("@fenyong") > 0 then
				return true
			end
		end
		return false
	end
}
LuaFenyongClear = sgs.CreateTriggerSkill{
	name = "#LuaFenyong-clear" ,
	events = {sgs.EventLoseSkill} ,
	on_trigger = function(self, event, player, data)
		if data:toString() == "LuaFenyong" then
			player:loseAllMarks("@fenyong")
		end
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：奉印
	相关武将：铜雀台·伏完
	描述：其他角色的回合开始时，若其当前的体力值不比你少，你可以交给其一张【杀】，令其跳过其出牌阶段和弃牌阶段。
	引用：LuaFengyin
	状态：1217验证通过
]]--
LuaFengyinCard = sgs.CreateSkillCard{
	name = "LuaFengyinCard" ,
	target_fixed = true ,
	will_throw = false,
	handling_method = sgs.Card_MethodNone ,
	on_use = function(self, room, source, targets)
		local target = room:getCurrent()
		target:obtainCard(self)
		room:setPlayerFlag(target, "LuaFengyin_target")
	end
}
LuaFengyinVS = sgs.CreateViewAsSkill{
	name = "LuaFengyin" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and to_select:isKindOf("Slash")
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaFengyinCard:clone()
		card:addSubcard(cards[1])
		return card
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaFengyin"
	end
}
LuaFengyin = sgs.CreateTriggerSkill{
	name = "LuaFengyin" ,
	events = {sgs.EventPhaseChanging, sgs.EventPhaseStart} ,
	view_as_skill = LuaFengyinVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local splayer = room:findPlayerBySkillName(self:objectName())
		if not splayer or splayer:objectName() == player:objectName() then return false end
		if (event == sgs.EventPhaseChanging) and (data:toPhaseChange().to == sgs.Player_Start) then
			if player:getHp() >= splayer:getHp() then
				room:askForUseCard(splayer, "@@LuaFengyin", "@fengyin", -1, sgs.Card_MethodNone)
			end
		end
		if (event == sgs.EventPhaseStart) and player:hasFlag("LuaFengyin_target") then
			player:skip(sgs.Player_Play)
			player:skip(sgs.Player_Discard)
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end ,
}
--[[技能名：伏枥（限定技）
	相关武将：二将成名·廖化
	描述：当你处于濒死状态时，你可以将体力回复至X点（X为现存势力数），然后将你的武将牌翻面。
	引用：LuaFuli、LuaLaoji1
	状态：1217验证通过
]]--
getKingdomsFuli = function(yuanshu)
	local kingdoms = {}
	local room = yuanshu:getRoom()
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		local flag = true
		for _, k in ipairs(kingdoms) do
			if p:getKingdom() == k then
				flag = false
				break
			end
		end
		if flag then table.insert(kingdoms, p:getKingdom()) end
	end
	return #kingdoms
end
LuaFuli = sgs.CreateTriggerSkill{
	name = "LuaFuli" ,
	frequency = sgs.Skill_Limited ,
	events = {sgs.AskForPeaches} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying_data = data:toDying()
		if dying_data.who:objectName() ~= player:objectName() then return false end
		if player:askForSkillInvoke(self:objectName(), data) then
			room:removePlayerMark(player, "@laoji")
			local recover = sgs.RecoverStruct()
			recover.recover = math.min(getKingdomsFuli(player), player:getMaxHp()) - player:getHp()
			room:recover(player, recover)
			player:turnOver()
		end
		return false
	end ,
	can_trigger = function(self, target)
		return (target and target:isAlive() and target:hasSkill(self:objectName())) and (target:getMark("@laoji") > 0)
	end
}
LuaLaoji1 = sgs.CreateTriggerSkill{
	name = "#@laoji-Lua-1" ,
	events = {sgs.GameStart} ,
	on_trigger = function(self, event, player, data)
		player:gainMark("@laoji", 1)
	end
}
--[[技能名：扶乱
	相关武将：贴纸·王元姬
	描述：出牌阶段限一次，若你未于本阶段使用过【杀】，你可以弃置三张相同花色的牌，令你攻击范围内的一名其他角色将武将牌翻面，然后你不能使用【杀】直到回合结束。
	引用：LuaFuluan、LuaFuluanForbid
	状态：1217验证通过
]]--
LuaFuluanCard = sgs.CreateSkillCard{
	name = "LuaFuluanCard" ,
	filter = function(self, targets, to_select)
		if #targets ~= 0 then return false end
		if (not sgs.Self:inMyAttackRange(to_select)) or (sgs.Self:objectName() == to_select:objectName()) then return false end
		if sgs.Self:getWeapon() and self:getSubcards():contains(sgs.Self:getWeapon():getId()) then
			local weapon = sgs.Self:getWeapon():getRealCard():toWeapon()
			local distance_fix = weapon:getRange() - 1
			if sgs.Self:getOffensiveHorse() and self:getSubcards():contains(sgs.Self:getOffensiveHorse():getId()) then
				distance_fix = distance_fix + 1
			end
			return sgs.Self:distanceTo(to_select, distance_fix) <= sgs.Self:getAttackRange()
		elseif sgs.Self:getOffensiveHorse() and self:getSubcards():contains(sgs.Self:getOffensiveHorse():getId()) then
			return sgs.Self:distanceTo(to_select, 1) <= sgs.Self:getAttackRange()
		else
			return true
		end
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		effect.to:turnOver()
		room:setPlayerCardLimitation(effect.from, "use", "Slash", true)
	end ,
}
LuaFuluan = sgs.CreateViewAsSkill{
	name = "LuaFuluan" ,
	n = 3 ,
	view_filter = function(self, selected, to_select)
		if #selected >= 3 then return false end
		if sgs.Self:isJilei(to_select) then return false end
		if #selected ~= 0 then
			local suit = selected[1]:getSuit()
			return to_select:getSuit() == suit
		end
		return true
	end ,
	view_as = function(self, cards)
		if #cards ~= 3 then return nil end
		local card = LuaFuluanCard:clone()
		card:addSubcard(cards[1])
		card:addSubcard(cards[2])
		card:addSubcard(cards[3])
		return card
	end ,
	enabled_at_play = function(self, player)
		return (player:getCardCount(true) >= 3) and (not player:hasUsed("#LuaFuluanCard")) and (not player:hasFlag("ForbidLuaFuluan"))
	end
}
LuaFuluanForbid = sgs.CreateTriggerSkill{
	name = "#LuaFuluan-forbid" ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and (player:getPhase() == sgs.Player_Play) and (not player:hasFlag("ForbidLuaFuluan")) then
			player:getRoom():setPlayerFlag(player, "ForbidLuaFuluan")
		end
		return false
	end
}
--[[技能名：辅佐
	相关武将：智·张昭
	描述：当有角色拼点时，你可以打出一张点数小于8的手牌，让其中一名角色的拼点牌加上这张牌点数的二分之一（向下取整）
	引用：LuaFuzuo
	状态：1217验证通过
]]--
LuaFuzuoCard = sgs.CreateSkillCard{
	name = "LuaFuzuoCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and to_select:hasFlag("LuaFuzuo_target")
	end ,
	on_effect = function(self, effect)
		effect.to:getRoom():setPlayerMark(effect.to, "LuaFuzuo", self:getNumber())
	end
}
LuaFuzuoVS = sgs.CreateViewAsSkill{
	name = "LuaFuzuo" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and (not to_select:isEquipped()) and (to_select:getNumber() < 8)
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaFuzuoCard:clone()
		card:addSubcard(cards[1])
		return card
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaFuzuo"
	end
}
LuaFuzuo = sgs.CreateTriggerSkill{
	name = "LuaFuzuo" ,
	events = {sgs.PindianVerifying} ,
	view_as_skill = LuaFuzuoVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local zhangzhao = room:findPlayerBySkillName(self:objectName())
		if not zhangzhao then return false end
		local pindian = data:toPindian()
		room:setPlayerFlag(pindian.from, "LuaFuzuo_target")
		room:setPlayerFlag(pindian.to, "LuaFuzuo_target")
		room:setTag("LuaFuzuoPindianData", data)
		if room:askForUseCard(zhangzhao, "@@LuaFuzuo", "@fuzuo-pindian", -1, sgs.Card_MethodDiscard) then
			local isFrom = (pindian.from:getMark(self:objectName()) > 0)
			if isFrom then
				local to_add = pindian.from:getMark(self:objectName()) / 2
				room:setPlayerMark(pindian.from, self:objectName(), 0)
				pindian.from_number = pindian.from_number + to_add
			else
				local to_add = pindian.to:getMark(self:objectName()) / 2
				room:setPlayerMark(pindian.to, self:objectName(), 0)
				pindian.to_number = pindian.to_number + to_add
			end
			data:setValue(pindian)
		end
		room:setPlayerFlag(pindian.from, "-LuaFuzuo_target")
		room:setPlayerFlag(pindian.to, "-LuaFuzuo_target")
		room:removeTag("LuaFuzuoPindianData")
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：父魂
	相关武将：一将成名2012·关兴&张苞
	描述：你可以将两张手牌当普通【杀】使用或打出。每当你于出牌阶段内以此法使用【杀】造成伤害后，你获得技能“武圣”、“咆哮”，直到回合结束。
	引用：LuaFuhun
	状态：1217验证通过
]]--
LuaFuhunVS = sgs.CreateViewAsSkill{
	name = "LuaFuhun" ,
	n = 2,
	view_filter = function(self, selected, to_select)
		return (#selected < 2) and (not to_select:isEquipped())
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local slash = sgs.Sanguosha:cloneCard("Slash", sgs.Card_SuitToBeDecided, 0)
		slash:setSkillName(self:objectName())
		slash:addSubcard(cards[1])
		slash:addSubcard(cards[2])
		return slash
	end ,
	enabled_at_play = function(self, player)
		return (player:getHandcardNum() >= 2) and sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return (player:getHandcardNum() >= 2) and (pattern == "slash")
	end
}
LuaFuhun = sgs.CreateTriggerSkill{
	name = "LuaFuhun" ,
	events = {sgs.Damage, sgs.EventPhaseChanging} ,
	view_as_skill = LuaFuhunVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.Damage) and (player and player:isAlive() and player:hasSkill(self:objectName())) then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and (damage.card:getSkillName() == self:objectName())
					and (player:getPhase() == sgs.Player_Play) then
				room:handleAcquireDetachSkills(player, "wusheng|paoxiao")
				player:setFlags(self:objectName())
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if (change.to == sgs.Player_NotActive) and player:hasFlag(self:objectName()) then
				room:handleAcquireDetachSkills(player, "-wusheng|-paoxiao")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：父魂
	相关武将：怀旧-一将2·关&张-旧
	描述：摸牌阶段开始时，你可以放弃摸牌，改为从牌堆顶亮出两张牌并获得之，若亮出的牌颜色不同，你获得技能“武圣”、“咆哮”，直到回合结束。
	引用：LuaNosFuhun
	状态：1217验证通过
]]--
LuaNosFuhun = sgs.CreateTriggerSkill{
	name = "LuaNosFuhun",
	events = {sgs.EventPhaseStart, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if event == sgs.EventPhaseStart and phase == sgs.Player_Draw then
			if player:askForSkillInvoke(self:objectName()) then
				local id1 = room:drawCard()
				local id2 = room:drawCard()
				local card1 = sgs.Sanguosha:getCard(id1)
				local card2 = sgs.Sanguosha:getCard(id2)
				local diff = card1:isBlack() ~= card2:isBlack()
				local move = sgs.CardsMoveStruct()
				local move2 = sgs.CardsMoveStruct()
				move.card_ids:append(id1)
				move.card_ids:append(id2)
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(),self:objectName(), "")
				move.to_place = sgs.Player_PlaceTable
				room:moveCardsAtomic(move, true)
				room:getThread():delay()
				move2 = move
				move2.to_place = sgs.Player_PlaceHand
				move2.to = player
				room:moveCardsAtomic(move2, true)
				if diff then
					room:setEmotion(player, "good")
					room:acquireSkill(player, "wusheng")
					room:acquireSkill(player, "paoxiao")
					player:setFlags(self:objectName())
				else
					room:setEmotion(player, "bad")
				end
				return true
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive and player:hasFlag(self:objectName()) then
				room:detachSkillFromPlayer(player, "wusheng")
				room:detachSkillFromPlayer(player, "paoxiao")
			end
		end
	end
}
-----------
--[[G区]]--
-----------
--[[技能名：甘露
	相关武将：一将成名·吴国太
	描述：出牌阶段限一次，你可以令装备区的装备牌数量差不超过你已损失体力值的两名角色交换他们装备区的装备牌。。
	引用：LuaGanlu
	状态：1217验证通过
]]--
swapEquip = function(first, second)
	local room = first:getRoom()
	local equips1, equips2 = sgs.IntList(), sgs.IntList()
	for _, equip in sgs.qlist(first:getEquips()) do
		equips1:append(equip:getId())
	end
	for _, equip in sgs.qlist(second:getEquips()) do
		equips2:append(equip:getId())
	end
	local exchangeMove = sgs.CardsMoveList()
	local move1 = sgs.CardsMoveStruct(equips1, second, sgs.Player_PlaceEquip, 
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, first:objectName(), second:objectName(), "LuaGanlu", ""))
	local move2 = sgs.CardsMoveStruct(equips2, first, sgs.Player_PlaceEquip,
			sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_SWAP, first:objectName(), second:objectName(), "LuaGanlu", ""))
	exchangeMove:append(move2)
	exchangeMove:append(move1)
	room:moveCards(exchangeMove, false)
end
LuaGanluCard = sgs.CreateSkillCard{
	name = "LuaGanluCard" ,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return true
		elseif #targets == 1 then
			local n1 = targets[1]:getEquips():length()
			local n2 = to_select:getEquips():length()
			return math.abs(n1 - n2) <= sgs.Self:getLostHp()
		else
			return false
		end
	end ,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets)
		swapEquip(targets[1], targets[2])
	end
}
LuaGanlu = sgs.CreateViewAsSkill{
	name = "LuaGanlu" ,
	n = 0 ,
	view_as = function()
		return LuaGanluCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaGanluCard")
	end
}
--[[技能名：感染（锁定技）
	相关武将：僵尸·僵尸
	描述：你的装备牌都视为铁锁连环。
	引用：LuaXGanran
	状态：0405验证通过
]]--
LuaGanran = sgs.CreateFilterSkill{
	name = "LuaGanran",
	view_filter = function(self, to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return place == sgs.Player_PlaceHand and to_select:getTypeId() == sgs.Card_TypeEquip
	end,
	view_as = function(self, card)
		local ironchain = sgs.Sanguosha:cloneCard("iron_chain", card:getSuit(), card:getNumber())
		ironchain:setSkillName(self:objectName())
		local vs_card = sgs.Sanguosha:getWrappedCard(card:getEffectiveId())
		vs_card:takeOver(ironchain)
		return vs_card
	end,
}
--[[技能名：刚烈
	相关武将：界限突破·夏侯惇
	描述：每当你受到1点伤害后，你可以进行判定：若结果为红色，你对伤害来源造成1点伤害；黑色，你弃置伤害来源一张牌。 
	引用：LuaGanglie
	状态：0405验证通过
]]--
LuaGanglie = sgs.CreateTriggerSkill{
	name = "LuaGanglie",
	events = {sgs.Damaged, sgs.FinishJudge},
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Damaged and player:isAlive() and player:hasSkill(self:objectName()) then
			local damage = data:toDamage()
			local from = damage.from
			for i = 0, damage.damage - 1, 1 do
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local judge = sgs.JudgeStruct()
					judge.pattern = "."
					judge.play_animation = false
					judge.reason = self:objectName()
					judge.who = player
					room:judge(judge)
					if (not from) or from:isDead() then return end
					if judge.card:isRed() then
						room:damage(sgs.DamageStruct(self:objectName(), player, from))
					elseif judge.card:isBlack() then
						if player:canDiscard(from, "he") then
							local id = room:askForCardChosen(player, from, "he", self:objectName(), false, sgs.Card_MethodDiscard)
							room:throwCard(id, from, player)
						end
					end
				end
			end
		elseif event == sgs.FinishJudge then
			local judge = sgs.JudgeStruct()
			if judge.reason ~= self:objectName() then return false end
			judge.pattern = tostring(judge.card:getSuit())
		end
		return false
	end
}
--[[技能名：刚烈
	相关武将：标准·夏侯惇
	描述：每当你受到伤害后，你可以进行判定：若结果不为?，则伤害来源选择一项：弃置两张手牌，或受到1点伤害。 
	引用：LuaNosGanglie
	状态：0405验证通过
]]--
LuaNosGanglie = sgs.CreateMasochismSkill{
	name = "LuaNosGanglie" ,
	on_damaged = function(self, player, damage)
		local from = damage.from
		local room = player:getRoom()
		local data = sgs.QVariant()
		data:setValue(damage)
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|heart"
			judge.good = false
			judge.reason = self:objectName()
			judge.who = player
			room:judge(judge)
			if (not from) or from:isDead() then return end
			if judge:isGood() then
				if from:getHandcardNum() < 2 or not room:askForDiscard(from, self:objectName(), 2, 2, true) then
					room:damage(sgs.DamageStruct(self:objectName(), player, from))
				end
			end
		end
	end
}
--[[技能名：刚烈
	相关武将：2013-3v3·夏侯惇
	描述： 每当你受到伤害后，你可以选择一名对方角色并进行一次判定，若判定结果不为?，则该角色选择一项：弃置两张手牌，或受到你造成的1点伤害。
	引用：LuaVsGanglie
	状态：1217验证通过
]]--
LuaVsGanglie = sgs.CreateMasochismSkill{
	name = "LuaVsGanglie",
	on_damaged = function(self,player)
		local room = player:getRoom()
		local mode = room:getMode()
		local function isFriend (a,b)
			return string.sub(a:getRole(),1,1) == string.sub(b:getRole(),1,1)
		end
		if mode:startsWith("06_") then
			local enemies = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers())do
				if not isFriend(player,p) then
					enemies:append(p)
				end
			end
			local from = room:askForPlayerChosen(player,enemies,self:objectName(),"vsganglie-invoke", true, true)
			if from then
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|heart"
				judge.good = false
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isGood() then
					if from:getHandcardNum() < 2 then
						room:damage(sgs.DamageStruct(self:objectName(), player, from))
					else
						if not room:askForDiscard(from, self:objectName(), 2, 2, true) then
							room:damage(sgs.DamageStruct(self:objectName(), player, from))
						end
					end
				end
			end
		end
		return false
	end
}
--[[技能名：刚烈
	相关武将：翼·夏侯惇
	描述：每当你受到一次伤害后，你可以进行一次判定，若判定结果不为红桃，你选择一项：令伤害来源弃置两张手牌，或受到你对其造成的1点伤害。
	引用：LuaXNeoGanglie
	状态：1217验证通过
]]--
LuaXNeoGanglie = sgs.CreateTriggerSkill{
	name = "LuaXNeoGanglie",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local from = damage.from
		local ai_data = sgs.QVariant()
		ai_data:setValue(from)
		if from and from:isAlive() then
			if room:askForSkillInvoke(player, self:objectName(), ai_data) then
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|heart"
				judge.good = false
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isGood() then
					local choicelist = "damage"
					local flag = false
					if from:getHandcardNum() > 1 then
						choicelist = "damage+throw"
						flag = true
					end
					local choice
					if flag then
						choice = room:askForChoice(player, self:objectName(), choicelist)
					else
						choice = choicelist
					end
					if choice == "damage" then
						local damage = sgs.DamageStruct()
						damage.from = player
						damage.to = from
						room:setEmotion(player, "good")
						room:damage(damage)
					else
						room:askForDiscard(from, self:objectName(), 2, 2)
					end
				else
					room:setEmotion(player, "bad")
				end
			end
		end
	end
}
--[[技能名：弓骑
	相关武将：一将成名2012·韩当
	描述：出牌阶段限一次，你可以弃置一张牌，令你于此回合内攻击范围无限，若你以此法弃置的牌为装备牌，你可以弃置一名其他角色的一张牌。
	引用：LuaGongqi
	状态：1217验证通过
]]--
LuaGongqiCard = sgs.CreateSkillCard{
	name = "LuaGongqiCard" ,
	target_fixed = true ,
	on_use = function(self, room, source, targets)
		room:setPlayerFlag(source,"InfinityAttackRange")
		local cd = sgs.Sanguosha:getCard(self:getSubcards():first())
		if cd:isKindOf("EquipCard") then
			local _targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if source:canDiscard(p, "he") then _targets:append(p) end
			end
			if not _targets:isEmpty() then
				local to_discard = room:askForPlayerChosen(source, _targets, "LuaGongqi", "@gongqi-discard", true)
				if to_discard then
					room:throwCard(room:askForCardChosen(source, to_discard, "he", "LuaGongqi", false, sgs.Card_MethodDiscard), to_discard, source)
				end
			end
		end
	end
}
LuaGongqi = sgs.CreateViewAsSkill{
	name = "LuaGongqi" ,
	n = 1 ,
	view_filter = function(self, cards, to_select)
		return not sgs.Self:isJilei(to_select)
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaGongqiCard:clone()
		card:addSubcard(cards[1])
		card:setSkillName(self:objectName())
		return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaGongqiCard")
	end
}
--[[技能名：弓骑
	相关武将：怀旧·韩当
	描述：你可以将一张装备牌当【杀】使用或打出。你以此法使用的【杀】无距离限制。
	引用：LuaNosGongqi、LuaNosGongqiTargetMod
	状态：1217验证通过
]]--
LuaNosGongqi = sgs.CreateViewAsSkill{
	name = "LuaNosGongqi" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if to_select:getTypeId() ~= sgs.Card_TypeEquip then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(to_select:getEffectiveId())
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end ,
	view_as = function(self, cards)
		if #cards == 1 then
		local slash = sgs.Sanguosha:cloneCard("slash", cards[1]:getSuit(), cards[1]:getNumber())
		slash:addSubcard(cards[1])
		slash:setSkillName(self:objectName())
		return slash
		end
	end ,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end
}
LuaNosGongqiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaNosGongqi-target" ,

	distance_limit_func = function(self, player, card)
		if card:getSkillName() == "LuaNosGongqi" then
			return 1000
		else
			return 0
		end
	end
}
--[[技能名：攻心
	相关武将：神·吕蒙，界·吕蒙
	描述：出牌阶段限一次，你可以观看一名其他角色的手牌，然后选择其中一张?牌并选择一项：弃置之，或将之置于牌堆顶。
	引用：LuaGongxin
	状态：0405验证通过
]]--
LuaGongxinCard = sgs.CreateSkillCard{
	name = "LuaGongxinCard" ,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() --and not to_select:isKongcheng() 如果不想选择没有手牌的角色就加上这一句，源码是没有这句的
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then--如果加上了上面的那句，这句和对应的end可以删除
			local ids = sgs.IntList()
			for _, card in sgs.qlist(effect.to:getHandcards()) do
				if card:getSuit() == sgs.Card_Heart then
					ids:append(card:getEffectiveId())
				end
			end
			local card_id = room:doGongxin(effect.from, effect.to, ids)
			if (card_id == -1) then return end
			local result = room:askForChoice(effect.from, "LuaGongxin", "discard+put")
			effect.from:removeTag("LuaGongxin")
			if result == "discard" then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(), nil, "LuaGongxin", nil)
				room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
			else
				effect.from:setFlags("Global_GongxinOperator")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, effect.from:objectName(), nil, "LuaGongxin", nil)
				room:moveCardTo(sgs.Sanguosha:getCard(card_id), effect.to, nil, sgs.Player_DrawPile, reason, true)
				effect.from:setFlags("-Global_GongxinOperator")
			end
		end
	end
}	
LuaGongxin = sgs.CreateZeroCardViewAsSkill{
	name = "LuaGongxin" ,
	view_as = function()
		return LuaGongxinCard:clone()
	end ,
	enabled_at_play = function(self, target)
		return not target:hasUsed("#LuaGongxinCard")
	end
}
--[[技能名：共谋
	相关武将：倚天·钟士季
	描述：回合结束阶段开始时，你可指定一名其他角色：其在摸牌阶段摸牌后，须给你X张手牌（X为你手牌数与对方手牌数的较小值），然后你须选择X张手牌交给对方
	引用：LuaXGongmou、LuaXGongmouExchange
	状态：1217验证通过
]]--
LuaXGongmou = sgs.CreateTriggerSkill{
	name = "LuaXGongmou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		if phase == sgs.Player_Finish then
			if player:askForSkillInvoke(self:objectName()) then
				local players = room:getOtherPlayers(player)
				local target = room:askForPlayerChosen(player, players, self:objectName())
				target:gainMark("@conspiracy")
			end
		elseif phase == sgs.Player_Start then
			local players = room:getOtherPlayers(player)
			for _,p in sgs.qlist(players) do
				if p:getMark("@conspiracy") > 0 then
					p:loseMark("@conspiracy")
				end
			end
		end
		return false
	end
}
LuaXGongmouExchange = sgs.CreateTriggerSkill{
	name = "#LuaXGongmouExchange",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			player:loseMark("@conspiracy")
			local room = player:getRoom()
			local source = room:findPlayerBySkillName("LuaXGongmou")
			if source then
				local thisCount = player:getHandcardNum()
				local thatCount = source:getHandcardNum()
				local x = math.min(thatCount, thisCount)
				if x > 0 then
					local to_exchange = nil
					if thisCount == x then
						to_exchange = player:wholeHandCards()
					else
						to_exchange = room:askForExchange(player, "LuaXGongmou", x)
					end
					room:moveCardTo(to_exchange, source, sgs.Player_PlaceHand, false)
					to_exchange = room:askForExchange(source, "LuaXGongmou", x)
					room:moveCardTo(to_exchange, player, sgs.Player_PlaceHand, false)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			return target:getMark("@conspiracy") > 0
		end
		return false
	end,
	priority = -2
}
--[[技能名：蛊惑
	相关武将：风·于吉
	描述：你可以扣置一张手牌当做一张基本牌或非延时锦囊牌使用或打出，其他角色选择是否质疑：若无角色质疑，你展示该牌，取消不合法的目标并按你所述类型结算；若有角色质疑，中止质疑询问并展示该牌：若该牌为真，该角色获得“缠怨”（锁定技。你不能质疑“蛊惑”。若你的体力值为1，你的其他武将技能无效。），取消不合法的目标并按你所述类型结算；若该牌为假，你将其置入弃牌堆。每名角色的回合限一次。 
	引用：guhuo_new
	状态：0405验证通过(需配合本手册的缠怨一起使用)不知是否还有隐藏的问题
]]--
function guhuo(self, yuji)
	local room = yuji:getRoom()
	local players = room:getOtherPlayers(yuji)
	local used_cards = sgs.IntList()
	local moves = sgs.CardsMoveList()
	for _, card_id in sgs.qlist(self:getSubcards()) do
		used_cards:append(card_id)
	end
	--room:setTag("GuhuoType", self:getUserString())
	local questioned = nil
	for _, player in sgs.qlist(players) do
		if player:hasSkill("LuaChanyuan") then
			room:notifySkillInvoked(player, "LuaChanyuan")
			room:setEmotion(player, "no-question")
			continue
		end
		local choice = room:askForChoice(player, "LuaGuhuo", "noquestion+question")
		if choice == "question" then
			room:setEmotion(player, "question")
		else
			room:setEmotion(player, "no-question")
		end
		if choice == "question" then
			questioned = player
			break
		end
	end
	local success = false
	if not questioned then
		success = true
		for _, player in sgs.qlist(players) do
			room:setEmotion(player, ".")
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, yuji:objectName(), "", "LuaGuhuo")
		local move = sgs.CardsMoveStruct(used_cards, yuji, nil, sgs.Player_PlaceUnknown, sgs.Player_PlaceTable, reason)
		moves:append(move)
		room:moveCardsAtomic(moves, true)
	else
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		if self:getUserString() and self:getUserString() == "peach+analeptic" then
			success = card:objectName() == yuji:getTag("GuhuoSaveSelf"):toString()
		elseif self:getUserString() and self:getUserString() == "slash" then
			success = string.find(card:objectName(),"slash")
		elseif self:getUserString() and self:getUserString() == "normal_slash" then
			success = card:objectName() == "slash"
		else
			success = card:match(self:getUserString())
		end
		if success then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, yuji:objectName(), "", "LuaGuhuo")
			local move = sgs.CardsMoveStruct(used_cards, yuji, nil, sgs.Player_PlaceUnknown, sgs.Player_PlaceTable, reason)
			moves:append(move)
			room:moveCardsAtomic(moves, true)
		else
			room:moveCardTo(self, yuji, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, yuji:objectName(), "", "LuaGuhuo"), true)
		end
		for _, player in sgs.qlist(players) do
			room:setEmotion(player, ".")
			if success and questioned:objectName() == player:objectName() then
				room:acquireSkill(questioned, "LuaChanyuan")
			end
		end
	end
	yuji:removeTag("GuhuoSaveSelf")
	yuji:removeTag("GuhuoSlash")
	room:setPlayerFlag(yuji, "GuhuoUsed")
	return success
end
LuaGuhuoCard = sgs.CreateSkillCard {
	name = "LuaGuhuoCard",
    will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end
		local _card = sgs.Self:getTag("LuaGuhuo"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
	end ,
	feasible = function(self, targets)
		local players = sgs.PlayerList()
		for i = 1 , #targets do
			players:append(targets[i])
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = nil
			if self:getUserString() and self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				return card and card:targetsFeasible(players, sgs.Self)
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end
		local _card = sgs.Self:getTag("LuaGuhuo"):toCard()
		if _card == nil then
			return false
		end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetsFeasible(players, sgs.Self)
	end ,
	on_validate = function(self, card_use)
		local yuji = card_use.from
		local room = yuji:getRoom()
		local to_guhuo = self:getUserString()
		if to_guhuo == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local guhuo_list = {}
			table.insert(guhuo_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(guhuo_list, "normal_slash")
				table.insert(guhuo_list, "thunder_slash")
				table.insert(guhuo_list, "fire_slash")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_slash", table.concat(guhuo_list, "+"))
			yuji:setTag("GuhuoSlash", sgs.QVariant(to_guhuo))
		end
		if guhuo(self, yuji) then
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local user_str = ""
			if to_guhuo == "slash"  then
				if card:isKindOf("Slash") then
					user_str = card:objectName()
				else
					user_str = "slash"
				end
			elseif to_guhuo == "normal_slash" then
				user_str = "slash"
			else
				user_str = to_guhuo
			end
			--yuji:setTag("GuhuoSlash", sgs.QVariant(user_str))
			local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
			use_card:setSkillName("LuaGuhuo")
			use_card:addSubcard(self:getSubcards():first())
			use_card:deleteLater()
			local tos = card_use.to
			for _, to in sgs.qlist(tos) do
				local skill = room:isProhibited(yuji, to, use_card)
				if skill then
					card_use.to:removeOne(to)
				end
			end
			return use_card
		else
			return nil
		end
	end ,
	on_validate_in_response = function(self, yuji)
		local room = yuji:getRoom()
		local to_guhuo = ""
		if self:getUserString() == "peach+analeptic" then
			local guhuo_list = {}
			table.insert(guhuo_list, "peach")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(guhuo_list, "analeptic")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_saveself", table.concat(guhuo_list, "+"))
			yuji:setTag("GuhuoSaveSelf", sgs.QVariant(to_guhuo))
		elseif self:getUserString() == "slash" then
			local guhuo_list = {}
			table.insert(guhuo_list, "slash")
			local sts = sgs.GetConfig("BanPackages", "")
			if not string.find(sts, "maneuvering") then
				table.insert(guhuo_list, "normal_slash")
				table.insert(guhuo_list, "thunder_slash")
				table.insert(guhuo_list, "fire_slash")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_slash", table.concat(guhuo_list, "+"))
			yuji:setTag("GuhuoSlash", sgs.QVariant(to_guhuo))
		else
			to_guhuo = self:getUserString()
		end
		if guhuo(self, yuji) then
			local card = sgs.Sanguosha:getCard(self:getSubcards():first())
			local user_str = ""
			if to_guhuo == "slash" then
				if card:isKindOf("Slash") then
					user_str = card:objectName()
				else
					user_str = "slash"
				end
			elseif to_guhuo == "normal_slash" then
				user_str = "slash"
			else
				user_str = to_guhuo
			end
			local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
			use_card:setSkillName("LuaGuhuo")
			use_card:addSubcard(self)
			use_card:deleteLater()
			return use_card
		else
			return nil
		end
	end
}
LuaGuhuo = sgs.CreateOneCardViewAsSkill{
	name = "LuaGuhuo",
	filter_pattern = ".|.|.|hand",
	response_or_use = true,
	enabled_at_response = function(self, player, pattern)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		if player:isKongcheng() or player:hasFlag("GuhuoUsed") or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
            return false
		end
        if pattern == "peach" and player:getMark("Global_PreventPeach") > 0 then return false end
        if string.find(pattern, "[%u%d]") then return false end--这是个极其肮脏的黑客！！ 因此我们需要去阻止基本牌模式
		return true
	end,
	enabled_at_play = function(self, player)
		local current = false
		local players = player:getAliveSiblings()
		players:append(player)
		for _, p in sgs.qlist(players) do
			if p:getPhase() ~= sgs.Player_NotActive then
				current = true
				break
			end
		end
		if not current then return false end
		return not player:isKongcheng() and not player:hasFlag("GuhuoUsed")
	end,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local card = LuaGuhuoCard:clone()
			card:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
			card:addSubcard(cards)
			return card
		end
		local c = sgs.Self:getTag("LuaGuhuo"):toCard()
        if c then
            local card = LuaGuhuoCard:clone()
            if not string.find(c:objectName(), "slash") then
                card:setUserString(c:objectName())
            else
				card:setUserString(sgs.Self:getTag("GuhuoSlash"):toString())
				card:setTargetFixed(c:targetFixed() or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE)
			end
			card:addSubcard(cards)
			return card
        else
			return nil
		end
	end,
	enabled_at_nullification = function(self, player)
		local current = player:getRoom():getCurrent()
		if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then return false end
		return not player:isKongcheng() and not player:hasFlag("GuhuoUsed")
	end
}
LuaGuhuo:setGuhuoDialog("lr")
LuaGuhuoClear = sgs.CreateTriggerSkill{
	name = "#LuaGuhuo-clear" ,
	events = {sgs.EventPhaseChanging} ,
	can_trigger = function(self, target)
		return target
	end ,
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		local room = player:getRoom()
        if change.to == sgs.Player_NotActive then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
                if p:hasFlag("GuhuoUsed") then
                    room:setPlayerFlag(p, "-GuhuoUsed")
				end
            end
        end
		return false
	end
}
--[[技能名：蛊惑
	相关武将：怀旧·于吉
	描述：你可以说出一张基本牌或非延时类锦囊牌的名称，并背面朝上使用或打出一张手牌。若无其他角色质疑，则亮出此牌并按你所述之牌结算。若有其他角色质疑则亮出验明：若为真，质疑者各失去1点体力；若为假，质疑者各摸一张牌。除非被质疑的牌为红桃且为真，此牌仍然进行结算，否则无论真假，将此牌置入弃牌堆。
	引用：LuaNosguhuo
	状态：1217验证通过	
]]--
function Set(list)
	local set = {}
	for _, l in ipairs(list) do set[l] = true end
	return set
end
local patterns = {"slash", "jink", "peach", "analeptic", "nullification", "snatch", "dismantlement", "collateral", "ex_nihilo", "duel", "fire_attack", "amazing_grace", "savage_assault", "archery_attack", "god_salvation", "iron_chain"}
if not (Set(sgs.Sanguosha:getBanPackages()))["maneuvering"] then
	table.insert(patterns, 2, "thunder_slash")
	table.insert(patterns, 2, "fire_slash")
	table.insert(patterns, 2, "normal_slash")
end
local slash_patterns = {"slash", "normal_slash", "thunder_slash", "fire_slash"}
function getPos(table, value)
	for i, v in ipairs(table) do
		if v == value then
			return i
		end
	end
	return 0
end
local pos = 0
guhuo_select = sgs.CreateSkillCard {
	name = "guhuo_select",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		local type = {}
		local basic = {}
		local sttrick = {}
		local mttrick = {}
		for _, cd in ipairs(patterns) do
			local card = sgs.Sanguosha:cloneCard(cd, sgs.Card_NoSuit, 0)
			if card then
				card:deleteLater()
				if card:isAvailable(source) then
					if card:getTypeId() == sgs.Card_TypeBasic then
						table.insert(basic, cd)
					elseif card:isKindOf("SingleTargetTrick") then
						table.insert(sttrick, cd)
					else
						table.insert(mttrick, cd)
					end
					if cd == "slash" then
						table.insert(basic, "normal_slash")
					end
				end
			end
		end
		if #basic ~= 0 then table.insert(type, "basic") end
		if #sttrick ~= 0 then table.insert(type, "single_target_trick") end
		if #mttrick ~= 0 then table.insert(type, "multiple_target_trick") end
		local typechoice = ""
		if #type > 0 then
			typechoice = room:askForChoice(source, "LuaNosguhuo", table.concat(type, "+"))
		end
		local choices = {}
		if typechoice == "basic" then
			choices = table.copyFrom(basic)
		elseif typechoice == "single_target_trick" then
			choices = table.copyFrom(sttrick)
		elseif typechoice == "multiple_target_trick" then
			choices = table.copyFrom(mttrick)
		end
		local pattern = room:askForChoice(source, "guhuo-new", table.concat(choices, "+"))
		if pattern then
			if string.sub(pattern, -5, -1) == "slash" then
				pos = getPos(slash_patterns, pattern)
				room:setPlayerMark(source, "GuhuoSlashPos", pos)
			end
			pos = getPos(patterns, pattern)
			room:setPlayerMark(source, "GuhuoPos", pos)
			room:askForUseCard(source, "@LuaNosguhuo", "@@LuaNosguhuo")			
		end
	end,
}
function questionOrNot(player)
	local room = player:getRoom()
	local yuji = room:findPlayerBySkillName("LuaNosguhuo")
	local guhuoname = room:getTag("GuhuoType"):toString()
	if guhuoname == "peach+analeptic" then guhuoname = "peach" end
	if guhuoname == "normal_slash" then guhuoname = "slash" end
	local guhuocard = sgs.Sanguosha:cloneCard(guhuoname, sgs.Card_NoSuit, 0)
	local guhuotype = guhuocard:getClassName()
	if guhuotype and guhuotype == "AmazingGrace" then return "noquestion" end
	if guhuotype:match("Slash") then
		if yuji:getState() ~= "robot" and math.random(1, 4) == 1 and not sgs.questioner then return "question" end
	end
	if math.random(1, 6) == 1 and player:getHp() >= 3 and player:getHp() > player:getLostHp() then return "question" end
	local players = room:getOtherPlayers(player)
	players = sgs.QList2Table(players)
	local x = math.random(1, 5)
	if sgs.questioner then return "noquestion" end
	local questioner = room:getOtherPlayers(player):at(0)
	return player:objectName() == questioner:objectName() and x ~= 1 and "question" or "noquestion"
end
function guhuo(self, yuji)
		local room = yuji:getRoom()
		local players = room:getOtherPlayers(yuji)
	
		local used_cards = sgs.IntList()
		local moves = sgs.CardsMoveList()
		for _, card_id in sgs.qlist(self:getSubcards()) do
			used_cards:append(card_id)
		end		
		local questioned = sgs.SPlayerList()
		for _, p  in sgs.qlist(players) do
			if p:hasSkill("LuaChanyuan") then
				local log = sgs.LogMessage()
				log.type = "#LuaChanyuan"
				log.from = yuji
				log.to:append(p)
				log.arg = "LuaChanyuan"
				room:sendLog(log)				
				room:notifySkillInvoked(p, "LuaChanyuan")
				room:setEmotion(p, "no-question")
			else
				local choice = "noquestion"
				if p:getState() == "online" then
					choice = room:askForChoice(p, "guhuo", "noquestion+question")
				else
					room:getThread():delay(sgs.GetConfig("OriginAIDelay", ""))
					choice = questionOrNot(p)
				end
				if choice == "question" then
					sgs.questioner = p
					room:setEmotion(p, "question")
					questioned:append(p)					
				else
					room:setEmotion(p, "no-question")					
				end			
				local log = sgs.LogMessage()
				log.type = "#GuhuoQuery"
				log.from = p
				log.arg = choice
				room:sendLog(log)				
			end
		end
		room:removeTag("GuhuoType")
		local log = sgs.LogMessage()
		log.type = "$GuhuoResult"
		log.from = yuji
		local subcards = self:getSubcards()
		log.card_str = tostring(subcards:first())
		room:sendLog(log)
		local success = false
		local canuse = false
		if questioned:isEmpty() then
			canuse = true
			for _, p in sgs.qlist(players) do
				room:setEmotion(p, ".")
			end			
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, yuji:objectName(), "", "guhuo")
			local move = sgs.CardsMoveStruct()
			move.card_ids = used_cards
			move.from = yuji
			move.to = nil
			move.to_place = sgs.Player_PlaceTable
			move.reason = reason
			moves:append(move)
			room:moveCardsAtomic(moves, true)
		else
			local card = sgs.Sanguosha:getCard(subcards:first())
			local user_string = self:getUserString()						
			if user_string == "peach+analeptic" then
				success = card:objectName() == yuji:getTag("GuhuoSaveSelf"):toString()
			elseif user_string == "slash" then
				success = string.sub(card:objectName(), -5, -1) == "slash"
			elseif user_string == "normal_slash" then
				success = card:objectName() == "slash"
			else
				success = card:match(user_string)
			end
			if success then
				for _, p in sgs.qlist(questioned) do
					room:loseHp(p)
				end
			else
				for _, p in sgs.qlist(questioned) do
					if p:isAlive() then
						p:drawCards(1)
					end
				end
			end
			if success and card:getSuit() == sgs.Card_Heart	then canuse = true end	
			if canuse then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_USE, yuji:objectName(), "", "guhuo")
				local move = sgs.CardsMoveStruct()
				move.card_ids = used_cards
				move.from = yuji
				move.to = nil
				move.to_place = sgs.Player_PlaceTable
				move.reason = reason
				moves:append(move)
				room:moveCardsAtomic(moves, true)
			else
				room:moveCardTo(self, yuji, nil, sgs.Player_DiscardPile, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, yuji:objectName(), "", "guhuo"), true)
			end
			for _, p in sgs.qlist(players) do
				room:setEmotion(p, ".")
			end			
		end
		yuji:removeTag("GuhuoSaveSelf")		
		return canuse
	end
LuaNosguhuoCard = sgs.CreateSkillCard {
	name = "LuaNosguhuo",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	player = nil,
	on_use = function(self, room, source)
		player = source
	end,
	filter = function(self, targets, to_select, player)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and sgs.Sanguosha:getCurrentCardUsePattern() ~= "@LuaNosguhuo" then
			local card = nil
			if self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				card:setSkillName("guhuo")
			end
			if card and card:targetFixed() then
				return false
			end
			local qtargets = sgs.PlayerList()
			for _, p in ipairs(targets) do
				qtargets:append(p)
			end
			return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return false
		end		
		local pattern = patterns[player:getMark("GuhuoPos")]
		if pattern == "normal_slash" then pattern = "slash" end
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("guhuo")
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,	
	target_fixed = function(self)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and sgs.Sanguosha:getCurrentCardUsePattern() ~= "@LuaNosguhuo" then
			local card = nil
			if self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
			end
			return card and card:targetFixed()
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end		
		local pattern = patterns[player:getMark("GuhuoPos")]
		if pattern == "normal_slash" then pattern = "slash" end
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		return card and card:targetFixed()
	end,	
	feasible = function(self, targets)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and sgs.Sanguosha:getCurrentCardUsePattern() ~= "@LuaNosguhuo" then
			local card = nil
			if self:getUserString() ~= "" then
				card = sgs.Sanguosha:cloneCard(self:getUserString():split("+")[1])
				card:setSkillName("guhuo")
			end
			local qtargets = sgs.PlayerList()
			for _, p in ipairs(targets) do
				qtargets:append(p)
			end
			return card and card:targetsFeasible(qtargets, sgs.Self)
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE then
			return true
		end		
		local pattern = patterns[sgs.Self:getMark("GuhuoPos")]
		if pattern == "normal_slash" then pattern = "slash" end
		local card = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
		card:setSkillName("guhuo")
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,	
	on_validate = function(self, card_use)
		local yuji = card_use.from
		local room = yuji:getRoom()		
		local to_guhuo = self:getUserString()		
		if to_guhuo == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and sgs.Sanguosha:getCurrentCardUsePattern() ~= "@LuaNosguhuo" then
			local guhuo_list = {}
			table.insert(guhuo_list, "slash")
			if not (Set(sgs.Sanguosha:getBanPackages()))["maneuvering"] then
				table.insert(guhuo_list, "normal_slash")
				table.insert(guhuo_list, "thunder_slash")
				table.insert(guhuo_list, "fire_slash")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_slash", table.concat(guhuo_list, "+"))
			pos = getPos(slash_patterns, to_guhuo)
			room:setPlayerMark(yuji, "GuhuoSlashPos", pos)
		end
		room:broadcastSkillInvoke("guhuo")		
		local log = sgs.LogMessage()
		if card_use.to:isEmpty() then
			log.type = "#GuhuoNoTarget"
		else
			log.type = "#Guhuo"
		end
		log.from = yuji
		log.to = card_use.to
		log.arg = to_guhuo
		log.arg2 = "guhuo"		
		room:sendLog(log)		
		room:setTag("GuhuoType", sgs.QVariant(self:getUserString()))		
		if guhuo(self, yuji) then
			local subcards = self:getSubcards()
			local card = sgs.Sanguosha:getCard(subcards:first())
			local user_str
			if to_guhuo == "slash"  then
				if card:isKindOf("Slash") then
					user_str = card:objectName()
				else
					user_str = "slash"
				end
			elseif to_guhuo == "normal_slash" then
				user_str = "slash"
			else
				user_str = to_guhuo
			end
			local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
			use_card:setSkillName("guhuo")
			use_card:addSubcard(card)
			use_card:deleteLater()			
			return use_card
		else
			return nil
		end
	end,
	on_validate_in_response = function(self, yuji)
		local room = yuji:getRoom()
		room:broadcastSkillInvoke("guhuo")		
		local to_guhuo
		if self:getUserString() == "peach+analeptic" then
			local guhuo_list = {}
			table.insert(guhuo_list, "peach")
			if not (Set(sgs.Sanguosha:getBanPackages()))["maneuvering"] then
				table.insert(guhuo_list, "analeptic")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_saveself", table.concat(guhuo_list, "+"))
			yuji:setTag("GuhuoSaveSelf", sgs.QVariant(to_guhuo))
		elseif self:getUserString() == "slash" then
			local guhuo_list = {}
			table.insert(guhuo_list, "slash")
			if not (Set(sgs.Sanguosha:getBanPackages()))["maneuvering"] then
				table.insert(guhuo_list, "normal_slash")
				table.insert(guhuo_list, "thunder_slash")
				table.insert(guhuo_list, "fire_slash")
			end
			to_guhuo = room:askForChoice(yuji, "guhuo_slash", table.concat(guhuo_list, "+"))
			pos = getPos(slash_patterns, to_guhuo)
			room:setPlayerMark(yuji, "GuhuoSlashPos", pos)
		else
			to_guhuo = self:getUserString()
		end		
		local log = sgs.LogMessage()
		log.type = "#GuhuoNoTarget"
		log.from = yuji
		log.arg = to_guhuo
		log.arg2 = "guhuo"
		room:sendLog(log)		
		room:setTag("GuhuoType", sgs.QVariant(self:getUserString()))		
		if guhuo(self, yuji) then
			local subcards = self:getSubcards()
			local card = sgs.Sanguosha:getCard(subcards:first())
			local user_str
			if to_guhuo == "slash" then
				if card:isKindOf("Slash") then
					user_str = card:objectName()
				else
					user_str = "slash"
				end
			elseif to_guhuo == "normal_slash" then
				user_str = "slash"
			else
				user_str = to_guhuo
			end
			local use_card = sgs.Sanguosha:cloneCard(user_str, card:getSuit(), card:getNumber())
			use_card:setSkillName("guhuo")
			use_card:addSubcard(subcards:first())
			use_card:deleteLater()
			return use_card
		else
			return nil
		end
	end
}
LuaNosguhuo = sgs.CreateViewAsSkill {
	name = "LuaNosguhuo",	
	n = 1,	
	enabled_at_response = function(self, player, pattern)
		if pattern == "@LuaNosguhuo" then
			return not player:isKongcheng() 
		end		
		if player:isKongcheng() or string.sub(pattern, 1, 1) == "." or string.sub(pattern, 1, 1) == "@" then
			return false
		end
		if pattern == "peach" and player:hasFlag("Global_PreventPeach") then return false end
		return true
	end,	
	enabled_at_play = function(self, player)				
		return not player:isKongcheng()
	end,	
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			if sgs.Sanguosha:getCurrentCardUsePattern() == "@LuaNosguhuo" then
				local pattern = patterns[sgs.Self:getMark("GuhuoPos")]
				if pattern == "normal_slash" then pattern = "slash" end
				local c = sgs.Sanguosha:cloneCard(pattern, sgs.Card_SuitToBeDecided, -1)
				if c and #cards == 1 then
					c:deleteLater()
					local card = LuaNosguhuoCard:clone()
					if not string.find(c:objectName(), "slash") then
						card:setUserString(c:objectName())
					else
						card:setUserString(slash_patterns[sgs.Self:getMark("GuhuoSlashPos")])
					end
					card:addSubcard(cards[1])
					return card
				else
					return nil
				end
			elseif #cards == 1 then
				local card = LuaNosguhuoCard:clone()
				card:setUserString(sgs.Sanguosha:getCurrentCardUsePattern())
				card:addSubcard(cards[1])
				return card
			else
				return nil
			end
		elseif #cards == 0 then
			local cd = guhuo_select:clone()
			return cd
		end
	end,	
	enabled_at_nullification = function(self, player)				
		return not player:isKongcheng() 
	end
}
--[[技能名：固守
	相关武将：智·田丰
	描述：回合外，当你使用或打出一张基本牌时，可以摸一张牌
	引用：LuaXGushou
	状态：1217验证通过
]]--
LuaGushou = sgs.CreateTriggerSkill{
	name = "LuaGushou" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardUsed, sgs.CardResponded} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:getCurrent():objectName() == player:objectName() then return false end
		local card = nil
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		else
			card = data:toCardResponse().m_card
		end
		if card and card:isKindOf("BasicCard") then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				player:drawCards(1)
			end
		end
		return false
	end
}
--[[技能名：固政
	相关武将：山·张昭张纮
	描述：其他角色的弃牌阶段结束时，你可以将该角色于此阶段内弃置的一张牌从弃牌堆返回其手牌，若如此做，你可以获得弃牌堆里其余于此阶段内弃置的牌。
	引用：LuaGuzheng、LuaGuzhengGet
	状态：1217验证通过
	附注：以字符串形式保存卡牌id
]]--
function strcontain(a, b)
	if a == "" then return false end
	local c = a:split("+")
	local k = false
	for i=1, #c, 1 do
		if a[i] == b then
			k = true
			break
		end
	end
	return k
end
LuaGuzheng = sgs.CreateTriggerSkill{
	name = "LuaGuzheng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local erzhang = room:findPlayerBySkillName(self:objectName())
		local current = room:getCurrent()
		local move = data:toMoveOneTime()
		local source = move.from
		if source then
			if player:objectName() == source:objectName() then
				if erzhang and erzhang:objectName() ~= current:objectName() then
					if current:getPhase() == sgs.Player_Discard then
						local tag = room:getTag("GuzhengToGet")
						local guzhengToGet= tag:toString()
						tag = room:getTag("GuzhengOther")
						local guzhengOther = tag:toString()
						if guzhengToGet == nil then
							guzhengToGet = ""
						end
						if guzhengOther == nil then
							guzhengOther = ""
						end
						for _,card_id in sgs.qlist(move.card_ids) do
							local flag = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
							if flag == sgs.CardMoveReason_S_REASON_DISCARD then
								if source:objectName() == current:objectName() then
									if guzhengToGet == "" then
										guzhengToGet = tostring(card_id)
									else
										guzhengToGet = guzhengToGet.."+"..tostring(card_id)
									end
								elseif not strcontain(guzhengToGet, tostring(card_id)) then
									if guzhengOther == "" then
										guzhengOther = tostring(card_id)
									else
										guzhengOther = guzhengOther.."+"..tostring(card_id)
									end
								end
							end
						end
						if guzhengToGet then
							room:setTag("GuzhengToGet", sgs.QVariant(guzhengToGet))
						end
						if guzhengOther then
							room:setTag("GuzhengOther", sgs.QVariant(guzhengOther))
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
LuaGuzhengGet = sgs.CreateTriggerSkill{
	name = "#LuaGuzhengGet",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseEnd},
	on_trigger = function(self, event, player, data)
		if not player:isDead() then
			local room = player:getRoom()
			local erzhang = room:findPlayerBySkillName(self:objectName())
			if erzhang then
				local tag = room:getTag("GuzhengToGet")
				local guzheng_cardsToGet
				local guzheng_cardsOther
				if tag then
					guzheng_cardsToGet = tag:toString():split("+")
				else
					return false
				end
				tag = room:getTag("GuzhengOther")
				if tag then
					guzheng_cardsOther = tag:toString():split("+")
				end
				room:removeTag("GuzhengToGet")
				room:removeTag("GuzhengOther")
				local cardsToGet = sgs.IntList()
				local cards = sgs.IntList()
				for i=1,#guzheng_cardsToGet, 1 do
					local card_data = guzheng_cardsToGet[i]
					if card_data == nil then return false end
					if card_data ~= "" then --弃牌阶段没弃牌则字符串为""
						local card_id = tonumber(card_data)
						if room:getCardPlace(card_id) == sgs.Player_DiscardPile then
							cardsToGet:append(card_id)
							cards:append(card_id)
						end
					end
				end
				if guzheng_cardsOther then
					for i=1, #guzheng_cardsOther, 1 do
						local card_data = guzheng_cardsOther[i]
						if card_data == nil then return false end
						if card_data ~= "" then
							local card_id = tonumber(card_data)
							if room:getCardPlace(card_id) == sgs.Player_DiscardPile then
								cardsToGet:append(card_id)
								cards:append(card_id)
							end
						end
					end
				end
				if cardsToGet:length() > 0 then
					local ai_data = sgs.QVariant()
					ai_data:setValue(cards:length())
					if erzhang:askForSkillInvoke(self:objectName(), ai_data) then
						room:fillAG(cards, erzhang)
						local to_back = room:askForAG(erzhang, cardsToGet, false, self:objectName())
						local backcard = sgs.Sanguosha:getCard(to_back)
						player:obtainCard(backcard)
						cards:removeOne(to_back)
						erzhang:invoke("clearAG")
						local move = sgs.CardsMoveStruct()
						move.card_ids = cards
						move.to = erzhang
						move.to_place = sgs.Player_PlaceHand
						room:moveCardsAtomic(move, true)
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			return target:getPhase() == sgs.Player_Discard
		end
		return false
	end
}
--[[技能名：观星
	相关武将：标准·诸葛亮、山·姜维、SP·台版诸葛亮
	描述：准备阶段开始时，你可以观看牌堆顶的X张牌，然后将任意数量的牌以任意顺序置于牌堆顶，将其余的牌以任意顺序置于牌堆底。（X为存活角色数且至多为5）。
	引用：LuaGuanxing
	状态：1217验证通过（仅在原来基础修改askForGuanxing）
]]--
LuaGuanxing = sgs.CreateTriggerSkill{
	name = "LuaGuanxing",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName(), data) then
				local count = room:alivePlayerCount()
				if count > 5 then
					count = 5
				end
				local cards = room:getNCards(count)
				room:askForGuanxing(player,cards)
			end
		end
	end
}
--[[技能名：归命（主公技、锁定技）
	相关武将：SP·孙皓
	描述：其他吴势力角色于你的回合内视为已受伤的角色。 
	引用：LuaGuiming
	状态：Lua无法实现，可以考虑写在残蚀里
]]--
--[[技能名：归汉
	相关武将：倚天·蔡昭姬
	描述：出牌阶段，你可以主动弃置两张相同花色的红色手牌，和你指定的一名其他存活角色互换位置。每阶段限一次
	引用：LuaGuihan
	状态：1217验证通过
]]--
LuaGuihanCard = sgs.CreateSkillCard{
	name = "LuaGuihan" ,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_effect = function(self, effect)
		effect.from:getRoom():swapSeat(effect.from, effect.to)
	end
}
LuaGuihan = sgs.CreateViewAsSkill{
	name = "LuaGuihan" ,
	n = 2 ,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then return false end
		if #selected == 0 then
			return to_select:isRed()
		elseif (#selected == 1) then
			local suit = selected[1]:getSuit()
			return to_select:getSuit() == suit
		else
			return false
		end
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = LuaGuihanCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaGuihanCard")
	end
}
--[[技能名：归心
	相关武将：神·曹操
	描述：每当你受到1点伤害后，你可以依次获得所有其他角色区域内的一张牌，然后将武将牌翻面。 
	引用：LuaGuixin
	状态：0405验证通过
]]--
LuaGuixin = sgs.CreateMasochismSkill{
	name = "LuaGuixin" ,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local n = player:getMark("LuaGuixinTimes")--这个标记为了ai
		player:setMark("LuaGuixinTimes", 0)
		local data = sgs.QVariant()
		data:setValue(damage)
		local players = room:getOtherPlayers(player)
		for i = 0, damage.damage - 1, 1 do
			player:addMark("LuaGuixinTimes")
			if player:askForSkillInvoke(self:objectName(), data) then
				player:setFlags("LuaGuixinUsing")
				for _, p in sgs.qlist(players) do
					if p:isAlive() and (not p:isAllNude()) then
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
						local card_id = room:askForCardChosen(player, p, "hej", self:objectName())
						room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= sgs.Player_PlaceHand)
					end
				end
				player:turnOver()
				player:setFlags("-LuaGuixinUsing")
			else
				break
			end
		end
		player:setMark("LuaGuixinTimes", n)
	end
}
--[[技能名：归心
	相关武将：倚天·魏武帝
	描述：回合结束阶段，你可以做以下二选一：\
	  1. 永久改变一名其他角色的势力\
	  2. 永久获得一项未上场或已死亡角色的主公技。(获得后即使你不是主公仍然有效)"
	引用：LuaXWeiwudiGuixin
	状态：1217验证通过
]]--
LuaXWeiwudiGuixin = sgs.CreateTriggerSkill{
	name = "LuaXWeiwudiGuixin",
	events = {sgs.EventPhaseProceeding},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			if room:askForSkillInvoke(player, self:objectName()) then
				local choice = room:askForChoice(player, self:objectName(), "modify+obtain")
				local others = room:getOtherPlayers(player)
				if choice == "modify" then
					local to_modify = room:askForPlayerChosen(player, others, self:objectName())
					local ai_data = sgs.QVariant()
					ai_data:setValue(to_modify)
					room:setTag("Guixin2Modify", ai_data)
					local kingdom = room:askForChoice(player, self:objectName(), "wei+shu+wu+qun")
					room:removeTag("Guixin2Modify")
					local old_kingdom = to_modify:getKingdom()
					room:setPlayerProperty(to_modify, "kingdom", sgs.QVariant(kingdom))
				elseif choice == "obtain" then
					local lords = sgs.Sanguosha:getLords()
					for _, p in sgs.qlist(others) do
						table.removeOne(lords, p:getGeneralName())
					end
					local lord_skills = {}
					for _, lord in ipairs(lords) do
						local general = sgs.Sanguosha:getGeneral(lord)
						local skills = general:getSkillList()
						for _, skill in sgs.qlist(skills) do
							if skill:isLordSkill() then
								if not player:hasSkill(skill:objectName()) then
									table.insert(lord_skills, skill:objectName())
								end
							end
						end
					end
					if #lord_skills > 0 then
						local choices = table.concat(lord_skills, "+")
						local skill_name = room:askForChoice(player, self:objectName(), choices)
						local skill = sgs.Sanguosha:getSkill(skill_name)
						room:acquireSkill(player, skill)
						local jiemingEX = sgs.Sanguosha:getTriggerSkill(skill:objectName())
						jiemingEX:trigger(sgs.GameStart, room, player, sgs.QVariant())
					end
				end
			end
		end
	end,
}
--[[技能名：闺秀
	相关武将：势·糜夫人
	描述：每当你失去“闺秀”后，你可以回复1点体力。限定技，准备阶段开始时或出牌阶段，你可以摸两张牌。 
	引用：LuaGuixiu、LuaGuixiuDetach
	状态：1217验证通过
]]--
LuaGuixiuCard = sgs.CreateSkillCard{
	name = "LuaGuixiuCard",
	target_fixed = true,

	on_use = function(self, room, source, targets)
		room:removePlayerMark(source,"Luaguixiu")
		source:drawCards(2,"LuaGuixiu")
	end
}
LuaGuixiuVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaGuixiu" ,

	view_as = function()
		return LuaGuixiuCard:clone()
	end,
	
	enabled_at_play = function(self, player)
		return player:getMark("Luaguixiu") >= 1
	end
}
LuaGuixiu = sgs.CreateTriggerSkill{
	name = "LuaGuixiu" ,
	frequency = sgs.Skill_Limited,
	limit_mark = "Luaguixiu",
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaGuixiuVS ,

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("Luaguixiu") >= 1 and player:getPhase() == sgs.Player_Start and room:askForSkillInvoke(player, self:objectName()) then
			room:removePlayerMark(player,"Luaguixiu")
			player:drawCards(2,self:objectName())
		end
	end
}
LuaGuixiuDetach = sgs.CreateTriggerSkill{
	name = "#LuaGuixiuDetach" ,
	events = {sgs.EventLoseSkill},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if data:toString() == "LuaGuixiu" then
		if player:isWounded() and room:askForSkillInvoke(player,"guixiu_rec",sgs.QVariant("recover")) then
			room:notifySkillInvoked(player,"LuaGuixiu")
		local recover = sgs.RecoverStruct()
			recover.who = player
			room:recover(player,recover)
			end
		end
	end
}
--[[技能名：鬼才
	相关武将：界限突破·司马懿
	描述：每当一名角色的判定牌生效前，你可以打出一张牌代替之。 
	引用：LuaGuicai
	状态：0405验证通过
]]--
LuaGuicai = sgs.CreateTriggerSkill{
	name = "LuaGuicai" ,
	events = {sgs.AskForRetrial} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isKongcheng() then return false end
		local judge = data:toJudge()
		local prompt_list = {
			"@guicai-card" ,
			judge.who:objectName() ,
			self:objectName() ,
			judge.reason ,
			string.format("%d", judge.card:getEffectiveId())
		}
		local prompt = table.concat(prompt_list, ":")
		local forced = false
		if player:getMark("JilveEvent") == sgs.AskForRetrial then forced = true end
		local askforcardpattern = "."
		if forced then askforcardpattern = ".!" end
		local card = room:askForCard(player, askforcardpattern, prompt, data, sgs.Card_MethodResponse, judge.who, true)
		if forced and (card == nil) then
			card = player:getRandomHandCard()
		end
		if card then
			room:retrial(card, player, judge, self:objectName())
		end
		return false
	end
}
--[[技能名：鬼才
	相关武将：标准·司马懿
	描述：每当一名角色的判定牌生效前，你可以打出一张手牌代替之。
	引用：LuaNosGuicai
	状态：0405验证通过
]]--
LuaNosGuicai = sgs.CreateTriggerSkill{
	name = "LuaNosGuicai" ,
	events = {sgs.AskForRetrial} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isKongcheng() then return false end
		local judge = data:toJudge()
		local prompt_list = {
			"@nosguicai-card" ,
			judge.who:objectName() ,
			self:objectName() ,
			judge.reason ,
			tostring(judge.card:getEffectiveId())
		}
		local prompt = table.concat(prompt_list, ":")
        local card = room:askForCard(player, ".", prompt, data, sgs.Card_MethodResponse, judge.who, true)
		if card then
			room:retrial(card, player, judge, self:objectName())
		end
		return false
	end
}
--[[技能名：鬼道
	相关武将：风·张角、旧风·张角
	描述：每当一名角色的判定牌生效前，你可以打出一张黑色牌替换之。
	引用：LuaGuidao
	状态：0405验证通过
]]--
LuaGuidao = sgs.CreateTriggerSkill{
	name = "LuaGuidao" ,
	events = {sgs.AskForRetrial} ,
	can_trigger = function(self, target)
		if not (target and target:isAlive() and target:hasSkill(self:objectName())) then return false end
		if target:isKongcheng() then
			local has_black = false
			for i = 0, 3, 1 do
				local equip = target:getEquip(i)
				if equip and equip:isBlack() then
					has_black = true
					break
				end
			end
			return has_black
		else
			return true
		end
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		local prompt_list = {
			"@guidao-card" ,
			judge.who:objectName() ,
			self:objectName() ,
			judge.reason ,
			tostring(judge.card:getEffectiveId())
		}
		local prompt = table.concat(prompt_list, ":")
		local card = room:askForCard(player, ".|black", prompt, data, sgs.Card_MethodResponse, judge.who, true)
		if card then
			room:retrial(card, player, judge, self:objectName(), true)
		end
		return false
	end
}
--[[技能名：国色
	相关武将：标准·大乔、SP·台版大乔、SP·王战大乔
	描述：你可以将一张方块牌当【乐不思蜀】使用。
	引用：LuaGuose
	状态：1217验证通过
]]--
LuaGuose = sgs.CreateViewAsSkill{
	name = "LuaGuose",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:getSuit() == sgs.Card_Diamond
	end,
	view_as = function(self, cards)
		if #cards == 0 then
			return nil
		elseif #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local indulgence = sgs.Sanguosha:cloneCard("indulgence", suit, point)
			indulgence:addSubcard(id)
			indulgence:setSkillName(self:objectName())
			return indulgence
		end
	end
}
-----------
--[[H区]]--
-----------
--[[技能名：汉统
	相关武将：贴纸·刘协
	描述：弃牌阶段，你可以将你弃置的手牌置于武将牌上，称为“诏”。你可以将一张“诏”置入弃牌堆，然后你拥有并发动以下技能之一：“护驾”、“激将”、“救援”、“血裔”，直到当前回合结束。
	引用：LuaXHantong、LuaXHantongDetach
	状态：1217验证通过
]]--
function hasShuGenerals(player)
	for _,p in sgs.qlist(player:getAliveSiblings()) do
		if p:getKingdom() == "shu" then
			return true
		end
	end
	return false
end
LuaXHantongRemove = function(player)
	local room = player:getRoom()
	local card_ids = player:getPile("pile")
	room:fillAG(card_ids,player)
	local card_id = room:askForAG(player, card_ids, false, "LuaXHantong")
	room:clearAG(player)
	if card_id == -1 then return false end
	card_ids:removeOne(card_id)
	local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "LuaXHantong", "")
	local card = sgs.Sanguosha:getCard(card_id)
	room:throwCard(card, reason, nil)
	player:setTag("LuaXHantong",sgs.QVariant(true))
	return true
end
LuaXHantongCard = sgs.CreateSkillCard{
	name = "LuaXHantongCard",
	target_fixed = true,
	on_validate = function(self,card_use)
		local source = card_use.from
		local room = source:getRoom()
		card_use.m_isOwnerUse = false;
		if not LuaXHantongRemove(source) then return false end		
		room:acquireSkill(source, "jijiang");
		if not room:askForUseCard(source, "@jijiang", "@hantong-jijiang")then
			room:setPlayerFlag(source, "Global_JijiangFailed");
			return nil
		end
		return self
	end,
	on_use = function(self, room, source, targets)
	end,
}
LuaXHantongVS = sgs.CreateViewAsSkill{
	name = "LuaXHantong",
	n = 0,
	view_as = function(self, cards)
		return LuaXHantongCard:clone()
	end,
	enabled_at_play = function(self, player)
		if not player:getPile("pile"):isEmpty() then
			if not player:hasFlag("Global_JijiangFailed") then
				return sgs.Slash_IsAvailable(player) and not player:hasSkill("jijiang")
			end
		end
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		return player:getPile("pile"):length()>0 and hasShuGenerals(player) and pattern == "slash" and 
		sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and
		not player:hasFlag("Global_JijiangFailed") and not player:hasSkill("jijiang")
	end
}
LuaXHantong = sgs.CreateTriggerSkill{
	name = "LuaXHantong",
	events = {sgs.BeforeCardsMove,sgs.CardAsked, sgs.EventPhaseStart, sgs.TargetConfirmed},
	view_as_skill = LuaXHantongVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.BeforeCardsMove then
			if player:getPhase() ~= sgs.Player_Discard then return false end
			local move = data:toMoveOneTime()
			if 	move.from:objectName() ~= player:objectName() then return false end
			if move.to_place == sgs.Player_DiscardPile and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				if player:askForSkillInvoke(self:objectName()) then
					local ids = move.card_ids
					local dummy = {}
					local i = 0
					for _,card in sgs.qlist(ids) do
						local id = sgs.Sanguosha:getCard(card)
						table.insert(dummy, id)
					end
					local count = #dummy
					if count > 0 then
						for _,c in pairs(dummy) do
							local cid = c:getEffectiveId()
							player:addToPile("pile", cid)
							ids:removeOne(cid)
						end
					end
					data:setValue(move)
				end
			end
			return false
		end
		local hantongs = player:getPile("pile")
		if hantongs:length() > 0 then
			if event == sgs.CardAsked then
				local pattern = data:toStringList()[1]
				if pattern == "slash" and (not player:hasFlag("Global_JijiangFailed")) and not player:hasSkill("jijiang")then
					if (room:askForSkillInvoke(player,self:objectName())) then 
						if not LuaXHantongRemove(player) then return false end
						room:acquireSkill(player, "jijiang")
					end
				elseif pattern == "jink" and not player:hasSkill("hujia") then
					if (room:askForSkillInvoke(player,self:objectName()))then
						if not LuaXHantongRemove(player) then return false end
						room:acquireSkill(player, "hujia")
					end
				end
			elseif event == sgs.TargetConfirmed then
				local use = data:toCardUse()
				if (not use.card:isKindOf("Peach"))or(not use.from)or(use.from:getKingdom() ~= "wu")or(player:objectName() == use.from:objectName())or(not player:hasFlag("Global_Dying"))or(player:hasSkill("jiuyuan")) then return false end
				if room:askForSkillInvoke(player,self:objectName()) then
					if not LuaXHantongRemove(player) then return false end
					room:acquireSkill(player, "jiuyuan")
				end
			elseif event == sgs.EventPhaseStart then
				if player:getPhase() == sgs.Player_Discard then
					if player:getPhase() ~= sgs.Player_Discard or player:hasSkill("xueyi") then return false end
					if room:askForSkillInvoke(player,self:objectName()) then
						if not LuaXHantongRemove(player) then return false end
						room:acquireSkill(player, "xueyi")
					end
				end
			end				
		end
	end,
	priority = 3,
}
LuaXHantongDetach = sgs.CreateTriggerSkill{
	name = "#LuaXHantongDetach", 
	events = {sgs.EventPhaseChanging}, 
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		local room = player:getRoom()
		if change.to ~= sgs.Player_NotActive then return false end
		for _,p in sgs.qlist(room:getAllPlayers())do
			if p:getTag("LuaXHantong"):toBool() then
				room:handleAcquireDetachSkills(p, "-hujia|-jijiang|-jiuyuan|-xueyi")
				p:removeTag("LuaXHantong")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[技能名：好施
	相关武将：林·鲁肃
	描述：摸牌阶段，你可以额外摸两张牌，若此时你的手牌多于五张，则将一半（向下取整）的手牌交给全场手牌数最少的一名其他角色。
	引用：LuaHaoshiGive、LuaHaoshi、LuaHaoshiVS
	状态：1217验证通过
]]--
LuaHaoshiCard = sgs.CreateSkillCard{
	name = "LuaHaoshiCard",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone ,
	filter = function(self, targets, to_select)
		if (#targets ~= 0) or to_select:objectName() == sgs.Self:objectName() then return false end
		return to_select:getHandcardNum() == sgs.Self:getMark("LuaHaoshi")
	end,
	on_use = function(self, room, source, targets)
		room:moveCardTo(self, targets[1], sgs.Player_PlaceHand, false)
	end
}
LuaHaoshiVS = sgs.CreateViewAsSkill{
	name = "LuaHaoshi",
	n = 999,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() then return false end
		local length = math.floor(sgs.Self:getHandcardNum() / 2)
		return #selected < length
	end,
	view_as = function(self, cards)
		if #cards ~= math.floor(sgs.Self:getHandcardNum() / 2) then return nil end
		local card = LuaHaoshiCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaHaoshi"
	end
}
LuaHaoshiGive = sgs.CreateTriggerSkill{
	name = "#LuaHaoshiGive",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:hasFlag("LuaHaoshi") then
			player:setFlags("-LuaHaoshi")
			if player:getHandcardNum() <= 5 then return false end
			local other_players = room:getOtherPlayers(player)
			local least = 1000
			for _, _player in sgs.qlist(other_players) do
				least = math.min(_player:getHandcardNum(), least)
			end
			room:setPlayerMark(player, "LuaHaoshi", least)
			local used = room:askForUseCard(player, "@@LuaHaoshi", "@haoshi", -1, sgs.Card_MethodNone)
			if not used then
				local beggar
				for _, _player in sgs.qlist(other_players) do
					if _player:getHandcardNum() == least then
						beggar = _player
						break
					end
				end
				local n = math.floor(player:getHandcardNum() / 2)
				local to_give = player:handCards():mid(0, n)
				local haoshi_card = LuaHaoshiCard:clone()
				for _, card_id in sgs.qlist(to_give) do
					haoshi_card:addSubcard(card_id)
				end
				local targets = {beggar}
				haoshi_card:on_use(room, player, targets)
			end
		end
	end
}
LuaHaoshi = sgs.CreateTriggerSkill{
	name = "LuaHaoshi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	view_as_skill = LuaHaoshiVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaHaoshi") then
			room:setPlayerFlag(player, "LuaHaoshi")
			local count = data:toInt() + 2
			data:setValue(count)
		end
	end
}
--[[技能名：鹤翼
	相关武将：阵·曹洪
	描述：回合结束时，你可以选择包括你在内的至少两名连续的角色，这些角色（除你外）拥有“飞影”，直到你的下个回合结束时。 
	引用：LuaHeyi
	状态：1217验证通过
]]--
LuaHeyiCard = sgs.CreateSkillCard{
	name = "LuaHeyiCard", 
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select) 
		return #targets < 2
	end,
	feasible = function(self, targets)
		return #targets == 2
	end,
	on_use = function(self, room, source, targets) 
		local data = sgs.QVariant()
		data:setValue(source)
		room:setTag("LuaHeyiSource",data)
		local players = room:getAllPlayers()
		local index1,index2 = players:indexOf(targets[1]), players:indexOf(targets[2])
		local index_self = players:indexOf(source)
		local cont_targets = sgs.SPlayerList()
		if index1 == index_self or index2 == index_self then
			while true do
				cont_targets:append(players:at(index1));
				if index1 == index2 then break end
				index1 = index1 + 1
				if index1 >= players:length() then
					index1 = index1 - players:length()
				end
			end
		else 
			if index1 > index2 then
				local temp = index1
				index1 = index2
				index2 = temp
				temp = nil
			end
			if (index_self > index1 and index_self < index2)then
				for i = index1,index2,1 do
					cont_targets:append(players:at(i))
				end
			else 
				while true do
					cont_targets:append(players:at(index2))
					if index1 == index2 then break end
					index2 = index2 + 1
					if index2 >= players:length() then
						index2 = index2 - players:length()
					end
				end
			end
		end
		cont_targets:removeOne(source)
		local list = {}
		for _,p in sgs.qlist(cont_targets)do
			if not p:isAlive() then continue end
			table.insert(list,p:objectName())
			source:setTag("LuaHeyi",sgs.QVariant(table.concat(list,"+")))
			room:acquireSkill(p, "feiying")
		end
	end,
}
LuaHeyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaHeyi", 
	response_pattern = "@@LuaHeyi",
	view_as = function(self, cards) 
		return LuaHeyiCard:clone()
	end, 
}
LuaHeyi = sgs.CreateTriggerSkill{
	name = "LuaHeyi", 
	events = {sgs.EventPhaseChanging,sgs.Death}, 
	view_as_skill = LuaHeyiVS,
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if triggerEvent == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		elseif triggerEvent == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if room:getTag("LuaHeyiSource"):toPlayer() and room:getTag("LuaHeyiSource"):toPlayer():objectName() == player:objectName()then
			room:removeTag("LuaHeyiSource")
			local list = player:getTag(self:objectName()):toString():split("+");
			player:removeTag(self:objectName())
			for _,p in sgs.qlist(room:getOtherPlayers(player))do
				if table.contains(list,p:objectName()) then
					room:detachSkillFromPlayer(p, "feiying", false, true)
				end
			end
		end
		if player and player:isAlive() and player:hasSkill(self:objectName()) and triggerEvent == sgs.EventPhaseChanging then
			room:askForUseCard(player, "@@LuaHeyi", "@LuaHeyi")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	priority = 2
}
--[[技能名：横江
	相关武将：势·臧霸
	描述：每当你受到1点伤害后，你可以令当前回合角色本回合手牌上限-1，然后其回合结束时，若你于此回合发动过“横江”，且其未于弃牌阶段内弃置牌，你摸一张牌。 
	引用：LuaHengjiang,LuaHengjiangDraw,LuaHengjiangMaxcards
	状态：1217验证通过	
	DB:效果（处理方法）和源码一致，但我始终觉得有问题。描述写错了么，还是我脑子还没转过来·····
]]--
LuaHengjiang = sgs.CreateMasochismSkill{
	name = "LuaHengjiang",
	
	on_damaged = function(self,player,damage)
		local room = player:getRoom()
		for i = 1, damage.damage, 1 do 
			local current = room:getCurrent()
			if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then
		break 
	end		
			local value = sgs.QVariant()
				value:setValue(current)
			if room:askForSkillInvoke(player,self:objectName(),value) then
				room:addPlayerMark(current,"@hengjiang")
			end
		end
	end

}
LuaHengjiangDraw = sgs.CreateTriggerSkill{
	name = "#LuaHengjiangDraw",
	events = {sgs.TurnStart,sgs.CardsMoveOneTime,sgs.EventPhaseChanging},
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart then
			room:setPlayerMark(player,"@hengjiang",0)
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and player:objectName() == move.from:objectName() and player:getPhase() == sgs.Player_Discard and bit32.band(move.reason.m_reason,sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				player:setFlags("LuaHengjiangDiscarded")
		end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			local zangba = room:findPlayerBySkillName("LuaHengjiang")
			if not zangba then return false end
			if player:getMark("@hengjiang") > 0 then
			local invoke = false
			if not player:hasFlag("LuaHengjiangDiscarded") then
				invoke = true
			end
				player:setFlags("-LuaHengjiangDiscarded")
				room:setPlayerMark(player,"@hengjiang",0)
			if invoke then
				zangba:drawCards(1)	
				end
			end
		end
	end,

	can_trigger = function(self, target)
		return target ~= nil
	end
}
LuaHengjiangMaxCards = sgs.CreateMaxCardsSkill{
	name = "#LuaHengjiangMaxCards",

	extra_func = function(self, target)
		return -target:getMark("@hengjiang")
	end
}
--[[技能名：弘援
	相关武将：新3V3·诸葛瑾
	描述：摸牌阶段，你可以少摸一张牌，令其他己方角色各摸一张牌。
	引用：LuaXHongyuan、LuaXHongyuanAct
	状态：1217验证通过
]]--
Lua3V3_isFriend = function(player,other)
	local tb = { ["lord"] = "warm", ["loyalist"] = "warm", ["renegade"] = "cold", ["rebel"] = "cold" }
	return tb[player:getRole()] == tb[other:getRole()]
end
LuaXHongyuan = sgs.CreateTriggerSkill{
	name = "LuaXHongyuan",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.DrawNCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName()) then
			player:setFlags(self:objectName())
			local count = data:toInt() - 1
			data:setValue(count)
		end
	end
}
LuaXHongyuanAct = sgs.CreateTriggerSkill {
	name = "#LuaXHongyuanAct",
	frequency = sgs.Skill_Frequent,
	events = { sgs.AfterDrawNCards },
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw then
			if player:hasFlag("LuaXHongyuan") then
				player:setFlags("-LuaXHongyuan")
				for _, other in sgs.qlist(room:getOtherPlayers(player)) do
					if Lua3V3_isFriend(player, other) then
						other:drawCards(1)
					end
				end
			end
		end
		return false
	end
}
--[[技能名：弘援
	相关武将：新3V3·诸葛瑾（身份局）
	描述：摸牌阶段，你可以少摸一张牌，令一至两名其他角色各摸一张牌。
	引用：LuaHongyuan、LuaHongyuanAct
	状态：1217验证通过
]]--
LuaHongyuanCard = sgs.CreateSkillCard{
	name = "LuaHongyuanCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select, Self)
		if to_select:objectName() ~= Self:objectName() then
			return #targets < 2
		end
		return false
	end,
	on_effect = function(self, effect)
		effect.to:setFlags("LuaHongyuan_Target")
	end
}
LuaHongyuanVS = sgs.CreateViewAsSkill{
	name = "LuaHongyuan",
	n = 0,
	view_as = function(self, cards)
		return LuaHongyuanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaHongyuan"
	end
}
LuaHongyuan = sgs.CreateTriggerSkill{
	name = "LuaHongyuan",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	view_as_skill = LuaHongyuanVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForUseCard(player, "@@LuaHongyuan", "@hongyuan") then
			local count = data:toInt() - 1
			data:setValue(count)
			player:setFlags("LuaHongyuan")
		end
		return false
	end
}
LuaHongyuanAct = sgs.CreateTriggerSkill{
	name = "#LuaHongyuanAct",
	frequency = sgs.Skill_Frequent,
	events = {sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw and player:hasFlag("LuaHongyuan") then
			player:setFlags("-LuaHongyuan")
			local targets = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers())do
				if p:hasFlag("LuaHongyuan_Target") then
					p:setFlags("-LuaHongyuan_Target")
					targets:append(p)
				end
			end
			room:drawCards(targets,1,"LuaHongyuan")
		end
		return false
	end
}
--[[技能名：红颜（锁定技）
	相关武将：风·小乔、SP·王战小乔
	描述：你的黑桃牌均视为红桃牌。
	引用：LuaHongyan
	状态：1217验证通过
]]--
LuaHongyan = sgs.CreateFilterSkill{
	name = "LuaHongyan",
	view_filter = function(self, to_select)
		return to_select:getSuit() == sgs.Card_Spade
	end,
	view_as = function(self, card)
		local id = card:getEffectiveId()
		local new_card = sgs.Sanguosha:getWrappedCard(id)
		new_card:setSkillName(self:objectName())
		new_card:setSuit(sgs.Card_Heart)
		new_card:setModified(true)
		return new_card
	end
}
--[[技能名：后援
	相关武将：智·蒋琬
	描述：出牌阶段，你可以弃置两张手牌，指定一名其他角色摸两张牌，每阶段限一次
	引用：LuaHouyuan
	状态：1217验证通过
]]--
LuaHouyuanCard = sgs.CreateSkillCard{
	name = "LuaHouyuanCard" ,
	on_effect = function(self, effect)
		effect.to:drawCards(2)
	end ,
}
LuaHouyuan = sgs.CreateViewAsSkill{
	name = "LuaHouyuan" ,
	n = 2,
	view_filter = function(self, selected, to_select)
		return (not to_select:isEquipped()) and (#selected < 2)
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = LuaHouyuanCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaHouyuanCard")
	end
}
--[[技能名：胡笳
	相关武将：倚天·蔡昭姬
	描述：回合结束阶段开始时，你可以进行判定：若为红色，立即获得此牌，如此往复，直到出现黑色为止，连续发动3次后武将翻面
	引用：LuaCaizhaojiHujia
	状态：1217验证通过
]]--
LuaCaizhaojiHujia = sgs.CreateTriggerSkill{
	name = "LuaCaizhaojiHujia" ,
	events = {sgs.EventPhaseStart, sgs.FinishJudge} ,
	on_trigger = function(self, event, player, data)
		if (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Finish) then
			local times = 0
			local room = player:getRoom()
			while player:askForSkillInvoke(self:objectName()) do
				player:setFlags("LuaCaizhaojiHujia")
				times = times + 1
				if times == 3 then player:turnOver() end
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|red"
				judge.good = true
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
				if judge:isBad() then break end
			end
			player:setFlags("-LuaCaizhaojiHujia")
		elseif event == sgs.FinishJudge then
			if player:hasFlag("LuaCaizhaojiHujia") then
				local judge = data:toJudge()
				if judge.card:isRed() then
					player:obtainCard(judge.card)
				end
			end
		end
		return false
	end
}
--[[技能名：虎威
	相关武将：1v1·关羽1v1
	描述：你登场时，你可以视为使用一张【水淹七军】。
	状态：1217验证通过
]]--
LuaHuwei = sgs.CreateTriggerSkill{
	name = "LuaHuwei", 
	events = {sgs.Debut}, 
	on_trigger = function(self, event, player, data)
		local drowning = sgs.Sanguosha:cloneCard("drowning")
		local opponent = player:getNext()
		if not opponent:isAlive() then return false end
		drowning:setSkillName("_LuaHuwei")
		if not (drowning:isAvailable(player) and player:isProhibited(opponent, drowning)) then
			drowning:deleteLater()
			return false
		end
		if room:askForSkillInvoke(player, objectName()) then
			room:useCard(CardUseStruct(drowning,player,opponent),false)
		end
		return false
	end,
}
--[[技能名：虎啸
	相关武将：SP·关银屏
	描述：每当你于出牌阶段使用【杀】被【闪】抵消后，本阶段你可以额外使用一张【杀】。 
	引用：LuaHuxiaoCount、LuaHuxiao、LuaHuxiaoClear
	状态：0405验证通过
]]--
LuaHuxiao = sgs.CreateTargetModSkill{
	name = "LuaHuxiao",
	residue_func = function(self, from)
		if from:hasSkill(self:objectName()) then
			return from:getMark(self:objectName())
		else
			return 0
		end
	end
}
LuaHuxiaoCount = sgs.CreateTriggerSkill{
	name = "#LuaHuxiao-count" ,
	events = {sgs.SlashMissed,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.SlashMissed then
			if player:getPhase() == sgs.Player_Play then
				room:addPlayerMark(player, "LuaHuxiao")
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.from == sgs.Player_Play then
				if player:getMark("LuaHuxiao") > 0 then
					room:setPlayerMark(player, "LuaHuxiao", 0)
				end
			end
		end
	end
}
LuaHuxiaoClear = sgs.CreateTriggerSkill{
	name = "LuaHuxiao-clear" ,
	events = {sgs.EventLoseSkill} ,
	on_trigger = function(self, event, player, data)
		if data:toString() == "LuaHuxiao" then
			player:getRoom():setPlayerMark(player, "LuaHuxiao", 0)
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：护驾（主公技）
	相关武将：标准·曹操、铜雀台·曹操
	描述：当你需要使用或打出一张【闪】时，你可以令其他魏势力角色打出一张【闪】（视为由你使用或打出）。
	引用：LuaHujia
	状态：1217验证通过
]]--
LuaHujia = sgs.CreateTriggerSkill{
	name = "LuaHujia$",
	frequency = sgs.NotFrequent,
	events = {sgs.CardAsked},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		local prompt = data:toStringList()[2]
		if (pattern ~= "jink") or string.find(prompt, "@hujia-jink") then return false end
		local lieges = room:getLieges("wei", player)
		if lieges:isEmpty() then return false end
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		local tohelp = sgs.QVariant()
		tohelp:setValue(player)
		for _, p in sgs.qlist(lieges) do
			local prompt = string.format("@hujia-jink:%s", player:objectName())
			local jink = room:askForCard(p, "jink", prompt, tohelp, sgs.Card_MethodResponse, player, false,"", true)
			if jink then
				room:provide(jink)
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, player)
		if player then
			return player:hasLordSkill(self:objectName())
		end
		return false
	end
}
--[[技能名：护援
	相关武将：阵·曹洪
	描述：结束阶段开始时，你可以将一张装备牌置于一名角色装备区内，然后你弃置该角色距离1的一名角色区域内的一张牌。 
	状态：1217验证通过
	注备：Xusine1131(数字君)：我真应该扇自己两巴掌……
]]--
LuaHuyuanCard = sgs.CreateSkillCard{
	name = "LuaHuyuanCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	
	filter = function(self, targets, to_select)
		if not #targets == 0 then return false end
		local card = sgs.Sanguosha:getCard(self:getEffectiveId())
		local equip = card:getRealCard():toEquipCard()
		local index = equip:location()
		return to_select:getEquip(index) == nil
	end,
	
	on_effect = function(self, effect)
		local caohong = effect.from
		local room = caohong:getRoom()
		room:moveCardTo(self, caohong, effect.to, sgs.Player_PlaceEquip,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, caohong:objectName(), "LuaYuanhu", ""))
		local card = sgs.Sanguosha:getCard(self:getEffectiveId())
		local targets = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getAllPlayers()) do
			if effect.to:distanceTo(p) == 1 and caohong:canDiscard(p, "he") then
				targets:append(p)
			end
		end
		if not targets:isEmpty() then
		local to_dismantle = room:askForPlayerChosen(caohong, targets, "LuaHuyuan", "@huyuan-discard:" .. effect.to:objectName())
		local card_id = room:askForCardChosen(caohong, to_dismantle, "he", "LuaHuyuan", false,sgs.Card_MethodDiscard)
			room:throwCard(sgs.Sanguosha:getCard(card_id), to_dismantle, caohong)
		end
	end
}
LuaHuyuanVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaHuyuan",
	filter_pattern = "EquipCard",
	response_pattern = "@@LuaHuyuan",
	view_as = function(self, card)
		local first = LuaHuyuanCard:clone()
			first:addSubcard(card:getId())
			first:setSkillName(self:objectName())
		return first
	end,

}
LuaHuyuan = sgs.CreatePhaseChangeSkill{
	name = "LuaHuyuan",
	view_as_skill = LuaHuyuanVS,
	on_phasechange = function(self,target)
		local room = target:getRoom()
		if target:getPhase() == sgs.Player_Finish and not target:isNude() then
			room:askForUseCard(target, "@@LuaHuyuan", "@huyuan-equip", -1, sgs.Card_MethodNone)
		end
	end
}
--[[技能名：化身
	相关武将：山·左慈
	描述：所有人都展示武将牌后，你随机获得两张未加入游戏的武将牌，称为“化身牌”，选一张置于你面前并声明该武将的一项技能，你获得该技能且同时将性别和势力属性变成与该武将相同直到“化身牌”被替换。在你的每个回合开始时和结束后，你可以替换“化身牌”，然后（无论是否替换）你为当前的“化身牌”声明一项技能（你不可以声明限定技、觉醒技或主公技）。
	引用：LuaHuashen LuaHuashenDetach
	状态：1217验证通过（源码功能完全实现）
	备注：Xusine（所谓的数字君1131561728）：这个技能使用了JsonForLua的库，请将json.lua放在游戏目录或者放在lua\lib
]]--
local json = require ("json")
function isNormalGameMode (mode_name)
	return mode_name:endsWith("p") or mode_name:endsWith("pd") or mode_name:endsWith("pz")
end
function GetAvailableGenerals(zuoci) ----完全按照源码写的，累死了……
	local all = sgs.Sanguosha:getLimitedGeneralNames()
	local room = zuoci:getRoom()
		if (isNormalGameMode(room:getMode()) or room:getMode():find("_mini_")or room:getMode() == "custom_scenario") then
			table.removeTable(all,sgs.GetConfig("Banlist/Roles",""):split(","))
		elseif (room:getMode() == "04_1v3") then
			table.removeTable(all,sgs.GetConfig("Banlist/HulaoPass",""):split(","))
		elseif (room:getMode() == "06_XMode") then
			table.removeTable(all,sgs.GetConfig("Banlist/XMode",""):split(","))
			for _,p in sgs.qlist(room:getAlivePlayers())do
				table.removeTable(all,(p:getTag("XModeBackup"):toStringList()) or {})
			end
		elseif (room:getMode() == "02_1v1") then
			table.removeTable(all,sgs.GetConfig("Banlist/1v1",""):split(","))
			for _,p in sgs.qlist(room:getAlivePlayers())do
				table.removeTable(all,(p:getTag("1v1Arrange"):toStringList()) or {})
			end
		end
		local Huashens = {}
		local Hs_String = zuoci:getTag("LuaHuashens"):toString()
		if Hs_String and Hs_String ~= "" then
			Huashens = Hs_String:split("+")
		end
		table.removeTable(all,Huashens)
		for _,player in sgs.qlist(room:getAlivePlayers())do
			local name = player:getGeneralName()
			if sgs.Sanguosha:isGeneralHidden(name) then
				local fname = sgs.Sanguosha:findConvertFrom(name);
				if fname ~= "" then name = fname end
			end
			table.removeOne(all,name)

			if player:getGeneral2() == nil then continue end

			name = player:getGeneral2Name();
			if sgs.Sanguosha:isGeneralHidden(name) then
				local fname = sgs.Sanguosha:findConvertFrom(name);
				if fname ~= "" then name = fname end
			end
			table.removeOne(all,name)
		end

		local banned = {"zuoci", "guzhielai", "dengshizai", "caochong", "jiangboyue", "bgm_xiahoudun"}
		table.removeTable(all,banned)

		return all
end
function AcquireGenerals(zuoci, n)
	local room = zuoci:getRoom();
	local Huashens = {}
	local Hs_String = zuoci:getTag("LuaHuashens"):toString()
	if Hs_String and Hs_String ~= "" then
		Huashens = Hs_String:split("+")
	end
	local list = GetAvailableGenerals(zuoci)
	if #list == 0 then return end
	n = math.min(n, #list)
	local acquired = {}
	repeat
		local rand = math.random(1,#list)
		if not table.contains(acquired,list[rand]) then
			table.insert(acquired,(list[rand]))
		end
	until #acquired == n
	
		for _,name in pairs(acquired)do
			table.insert(Huashens,name)
			localgeneral = sgs.Sanguosha:getGeneral(name)
			if general then
				for _,skill in sgs.list(general:getTriggerSkills()) do
					if skill:isVisible() then
						room:getThread():addTriggerSkill(skill)
					end
				end
			end
		end
		zuoci:setTag("LuaHuashens", sgs.QVariant(table.concat(Huashens, "+")))

		local hidden = {}
		for i = 1,n,1 do
			table.insert(hidden,"unknown")
		end
		for _,p in sgs.qlist(room:getAllPlayers())do
			local splist = sgs.SPlayerList()
			splist:append(p)
			if p:objectName() == zuoci:objectName() then
				room:doAnimate(4, zuoci:objectName(), table.concat(acquired,":"), splist)
			else
				room:doAnimate(4, zuoci:objectName(),table.concat(hidden,":"),splist);
			end
		end

		local log = sgs.LogMessage()
		log.type = "#GetHuashen"
		log.from = zuoci
		log.arg = n
		log.arg2 = #Huashens
		room:sendLog(log)
		--Json大法好 ^_^
		local jsonLog ={
			"#GetHuashenDetail",
			zuoci:objectName(),
			"",
			"",
			table.concat(acquired,"\\, \\"),
			"",
		}
		room:doNotify(zuoci,sgs.CommandType.S_COMMAND_LOG_SKILL,json.encode(jsonLog));
		room:setPlayerMark(zuoci, "@huashen", #Huashens)
end
function SelectSkill(zuoci)
	local room = zuoci:getRoom();
	local ac_dt_list = {}
	local huashen_skill = zuoci:getTag("LuaHuashenSkill"):toString();
		if huashen_skill ~= "" then
			table.insert(ac_dt_list,"-"..huashen_skill)
		end
		local Huashens = {}
		local Hs_String = zuoci:getTag("LuaHuashens"):toString()
		if Hs_String and Hs_String ~= "" then
			Huashens = Hs_String:split("+")
		end
		if #Huashens == 0 then return end
		local huashen_generals = {}
		for _,huashen in pairs(Huashens)do
			table.insert(huashen_generals,huashen)
		end
		local skill_names = {}
		local skill_name
		local general 
		local ai = zuoci:getAI();
		if (ai) then
			local hash = {}
			for _,general_name in pairs (huashen_generals) do
				local general = sgs.Sanguosha:getGeneral(general_name)
				for _,skill in (general:getVisibleSkillList())do
					if skill:isLordSkill() or skill:getFrequency() == sgs.Skill_Limited or skill:getFrequency() == sgs.Skill_Wake then
						continue
					end
					if not table.contains(skill_names,skill:objectName()) then
						hash[skill:objectName()] = general;
						table.insert(skill_names,skill:objectName())
					end
				end
			end
			if #skill_names == 0 then return end
			skill_name = ai:askForChoice("huashen",table.concat(skill_names,"+"), sgs.QVariant());
			general = hash[skill_name]
		else
			local general_name = room:askForGeneral(zuoci, table.concat(huashen_generals,"+"))
			general = sgs.Sanguosha:getGeneral(general_name)
			assert(general)
			for _,skill in sgs.qlist(general:getVisibleSkillList())do
				if skill:isLordSkill() or skill:getFrequency() == sgs.Skill_Limited or skill:getFrequency() == sgs.Skill_Wake then
					continue
				end
				if not table.contains(skill_names,skill:objectName()) then
					table.insert(skill_names,skill:objectName())
				end
			end
			if #skill_names > 0 then
				skill_name = room:askForChoice(zuoci, "huashen",table.concat(skill_names,"+"))
			end
		end
		local kingdom = general:getKingdom()
		if zuoci:getKingdom() ~= kingdom then
			if kingdom == "god" then
				kingdom = room:askForKingdom(zuoci);
				local log = sgs.LogMessage()
				log.type = "#ChooseKingdom";
				log.from = zuoci;
				log.arg = kingdom;
				room:sendLog(log);
			end
			room:setPlayerProperty(zuoci, "kingdom", sgs.QVariant(kingdom))
		end
		if zuoci:getGender() ~= general:getGender() then
			zuoci:setGender(general:getGender())
		end
		----Json大法又释放了一次英姿！
		local jsonValue = {
			9,
			zuoci:objectName(),
			general:objectName(),
			skill_name,
		}
		room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
		zuoci:setTag("LuaHuashenSkill",sgs.QVariant(skill_name))
		if skill_name ~= "" then
			table.insert(ac_dt_list,skill_name)
		end
		room:handleAcquireDetachSkills(zuoci, table.concat(ac_dt_list,"|"), true)
end
LuaHuashen = sgs.CreateTriggerSkill{
	name = "LuaHuashen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart, sgs.EventPhaseStart},
	priority = -1,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			room:notifySkillInvoked(player, "huashen")
			AcquireGenerals(player, 2)
			SelectSkill(player)
		else
			local phase = player:getPhase()
			if phase == sgs.Player_RoundStart or phase == sgs.Player_NotActive then
				if room:askForSkillInvoke(player, self:objectName()) then
					SelectSkill(player)
				end
			end
		end
	end
}
LuaHuashenDetach = sgs.CreateTriggerSkill{
	name = "#LuaHuashen-clear",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventLoseSkill},
	priority = -1,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local skill_name = data:toString()
		if skill_name == "LuaHuashen" then
			if player:getKingdom() ~= player:getGeneral():getKingdom() and player:getGeneral():getKingdom() ~= "god" then
				room:setPlayerProperty(player, "kingdom", sgs.QVariant(player:getGeneral():getKingdom()))
			end
			if player:getGender() ~= player:getGeneral():getGender() then
				player:setGender(player:getGeneral():getGender())
			end
			local huashen_skill = player:getTag("LuaHuashenSkill"):toString()
			if  huashen_skill ~= "" then
				room:detachSkillFromPlayer(player, huashen_skill, false, true)
			end
			player:removeTag("LuaHuashens")
			room:setPlayerMark(player, "@huashen", 0)
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[技能名：缓释
	相关武将：新3V3·诸葛瑾
	描述：在一名己方角色的判定牌生效前，你可以打出一张牌代替之。
	引用：LuaXHuanshi
	状态:1217验证通过
]]--
Lua3V3_isFriend = function(player,other)
	local tb = { ["lord"] = "warm", ["loyalist"] = "warm", ["renegade"] = "cold", ["rebel"] = "cold" }
	return tb[player:getRole()] == tb[other:getRole()]
end
LuaXHuanshi = sgs.CreateTriggerSkill {
	name = "LuaXHuanshi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.AskForRetrial },
	on_trigger = function(self, event, player, data)
		if player:isNude() then return false end
		local judge = data:toJudge()
		local room = player:getRoom()
		if not (Lua3V3_isFriend(player,judge.who) and room:getMode():startsWith("06_") )then return false end
		local prompt_list = { "@huanshi-card", judge.who:objectName(), self:objectName(), judge.reason, judge.card:getEffectiveId() }
		local prompt = table.concat(prompt_list, ":")
		local card = room:askForCard(player, "..", prompt, data, sgs.Card_MethodResponse, judge.who, true)
		if card then
			room:retrial(card, player, judge, self:objectName())
		end
		return false
	end
}
--[[技能名：缓释
	相关武将：新3V3·诸葛瑾（身份局）
	描述：每当一名角色的判定牌生效前，你可以令该角色观看你的手牌，然后该角色选择一张牌，你打出该牌代替之。
	引用：LuaXHuanshi
	状态：1217验证通过
]]--
LuaXHuanshi = sgs.CreateTriggerSkill {
	name = "LuaXHuanshi",
	frequency = sgs.Skill_NotFrequent,
	events = { sgs.AskForRetrial },
	on_trigger = function(self, event, player, data)
		if player:isNude() then return false end
		local judge = data:toJudge()
		local room = player:getRoom()
		local card
		local ids, disabled_ids,all = sgs.IntList(),sgs.IntList(),sgs.IntList()
			for _,card in sgs.qlist(player:getCards("he"))do
				if player:isCardLimited(card, sgs.Card_MethodResponse) then
					disabled_ids:append(card:getEffectiveId())
				else
					ids:append(card:getEffectiveId())
				end
				all:append(card:getEffectiveId())
			end
			if (not ids:isEmpty()) and room:askForSkillInvoke(player, self:objectName(), data)) {
				if judge.who:objectName() ~= player:objectName() and not player:isKongcheng() then
					local jsonLog ={
						"$ViewAllCards",
						judge.who:objectName(),
						player:objectName(),
						table.concat(sgs.QList2Table(player:handCards()),"+"),
						"",
						"",
					}
					room:doNotify(judge.who,sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
				end
				room:fillAG(all, judge.who, disabled_ids)
				local card_id = room:askForAG(judge.who, ids, false, self:objectName())
				room:clearAG(judge.who)
				card = sgs.Sanguosha:getCard(card_id)
			end
		if card then
			room:retrial(card, player, judge, self:objectName())
		end
		return false
	end
}
--[[技能名：皇恩
	相关武将：贴纸·刘协
	描述：每当一张锦囊牌指定了不少于两名目标时，你可以令成为该牌目标的至多X名角色各摸一张牌，则该锦囊牌对这些角色无效。（X为你当前体力值）
	引用：LuaXHuangen
	状态：1217验证通过
]]--
LuaXHuangenCard = sgs.CreateSkillCard{
	name = "LuaXHuangenCard",
	target_fixed = false,
	filter = function(self, targets, to_select, player)
		if #targets < player:getHp() then
			return to_select:hasFlag("huangen")
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		for _,p in ipairs(targets) do
			room:setPlayerFlag(p, "huangenremove")
		end
	end
}
LuaXHuangenVS = sgs.CreateViewAsSkill{
	name = "LuaXHuangen",
	n = 0,
	view_as = function(self, cards)
		return LuaXHuangenCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaXHuangen"
	end,
}
LuaXHuangen = sgs.CreateTriggerSkill{
	name = "LuaXHuangen",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed},
	view_as_skill = LuaXHuangenVS,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local trick = use.card
		if trick and trick:isKindOf("TrickCard") then
			if use.to:length() >= 2 then
				local room = player:getRoom()
				if trick:subcardsLength() ~= 0 or trick:getEffectiveId() ~= -1 then
					room:moveCardTo(trick, nil, sgs.Player_PlaceTable, true)
				end
				local splayer = room:findPlayerBySkillName(self:objectName())
				if splayer then
					for _,p in sgs.qlist(use.to) do
						room:setPlayerFlag(p,"huangen")
					end
					local x = 1
					local cardname = trick:objectName()
					room:setPlayerFlag(splayer, cardname)
					if room:askForUseCard(splayer,"@@LuaXHuangen","@LuaXHuangen") then
						local newtargets = sgs.SPlayerList()
						for _,p in sgs.qlist(use.to) do
							room:setPlayerFlag(p, "-huangen")
							if p:hasFlag("huangenremove") then
								room:setPlayerFlag(p, "-huangenremove")
								p:drawCards(1)
							else
								newtargets:append(p)
							end
						end
						room:setPlayerFlag(splayer, "-" .. cardname)
						use.to = newtargets
						if use.to:isEmpty() then
							return true
						end
						data:setValue(use)
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return true
	end
}
--[[技能名：黄天（主公技）
	相关武将：风·张角
	描述：出牌阶段限一次，其他群雄角色的出牌阶段，该角色可以交给你一张【闪】或【闪电】。
	引用：LuaHuangtian；LuaHuangtianVS（技能暗将）
	状态：1217验证通过
]]--
LuaHuangtianCard = sgs.CreateSkillCard{
	name = "LuaHuangtianCard",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:hasSkill("LuaHuangtian")
		   and to_select:objectName() ~= sgs.Self:objectName() and not to_select:hasFlag("LuaHuangtianInvoked")
	end,
	on_use = function(self, room, source, targets)
		local zhangjiao = targets[1]
		if zhangjiao:hasLordSkill("LuaHuangtian") then
			room:setPlayerFlag(zhangjiao, "LuaHuangtianInvoked")
			room:notifySkillInvoked(zhangjiao, "LuaHuangtian")
			zhangjiao:obtainCard(self);
			local zhangjiaos = room:getLieges("qun",zhangjiao)
			if zhangjiaos:isEmpty() then
				room:setPlayerFlag(source, "ForbidHuangtian")
			end
		end
	end
}
LuaHuangtianVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaHuangtianVS",
	filter_pattern = "Jink,Lightning",
	view_as = function(self, card)
		local acard = LuaHuangtianCard:clone()
		acard:addSubcard(card)
		return acard
	end,
	enabled_at_play = function(self, player)
		if player:getKingdom() == "qun" then
			return not player:hasFlag("ForbidHuangtian")
		end
		return false
	end
}
LuaHuangtian = sgs.CreateTriggerSkill{
	name = "LuaHuangtian$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart, sgs.EventPhaseChanging,sgs.EventAcquireSkill,sgs.EventLoseSkill},
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		local lords = room:findPlayersBySkillName(self:objectName())
		if (triggerEvent == sgs.TurnStart)or(triggerEvent == sgs.EventAcquireSkill and data:toString() == "LuaHuangtian") then 
			if lords:isEmpty() then return false end
			local players
			if lords:length() > 1 then
				players = room:getAlivePlayers()
			else
				players = room:getOtherPlayers(lords:first())
			end
			for _,p in sgs.qlist(players) do
				if not p:hasSkill("LuaHuangtianVS") then
					room:attachSkillToPlayer(p, "LuaHuangtianVS")
				end
			end
		elseif triggerEvent == sgs.EventLoseSkill and data:toString() == "LuaHuangtian" then
			if lords:length() > 2 then return false end
			local players
			if lords:isEmpty() then
				players = room:getAlivePlayers()
			else
				players:append(lords:first())
			end
			for _,p in sgs.qlist(players) do
				if p:hasSkill("LuaHuangtianVS") then
					room:detachSkillFromPlayer(p, "LuaHuangtianVS", true)
				end
			end
		elseif (triggerEvent == sgs.EventPhaseChanging) then
			local phase_change = data:toPhaseChange()
			if phase_change.from ~= sgs.Player_Play then return false end
			if player:hasFlag("ForbidHuangtian") then
				room:setPlayerFlag(player, "-ForbidHuangtian")
			end
			local players = room:getOtherPlayers(player);
			for _,p in sgs.qlist(players) do
				if p:hasFlag("HuangtianInvoked") then
					room:setPlayerFlag(p, "-HuangtianInvoked")
				end
			end
		end
		return false
	end,
}
--[[技能名：挥泪（锁定技）
	相关武将：一将成名·马谡
	描述：你死亡时，杀死你的其他角色弃置其所有牌。 
	引用：LuaHuilei
	状态：0405验证通过
]]--
LuaHuilei = sgs.CreateTriggerSkill{
	name = "LuaHuilei",
	events = {sgs.Death} ,
	frequency = sgs.Skill_Compulsory ,
	can_trigger = function(self, target)
		return target ~= nil and target:hasSkill(self:objectName())
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		local killer
		if death.damage then
			killer = death.damage.from
		else
			killer = nil
		end
		if killer and killer:objectName() ~= player:objectName() then
			room:notifySkillInvoked(player, self:objectName())
			killer:throwAllHandCardsAndEquips()
		end
		return false
	end
}
--[[技能名：火计
	相关武将：火·诸葛亮
	描述：你可以将一张红色手牌当【火攻】使用。
	引用：LuaHuoji
	状态：1217验证通过
]]--
LuaHuoji = sgs.CreateOneCardViewAsSkill{
	name = "LuaHuoji",
	filter_pattern = ".|red|.|hand",
	view_as = function(self, card)
		local suit = card:getSuit()
		local point = card:getNumber()
		local id = card:getId()
		local fireattack = sgs.Sanguosha:cloneCard("FireAttack", suit, point)
		fireattack:setSkillName(self:objectName())
		fireattack:addSubcard(id)
		return fireattack
	end
}
--[[技能名：祸首（锁定技）
	相关武将：林·孟获
	描述：【南蛮入侵】对你无效；当其他角色使用【南蛮入侵】指定目标后，你是该【南蛮入侵】造成伤害的来源。
	引用：LuaHuoshou、LuaSavageAssaultAvoid
	状态：1217验证通过
]]--
LuaHuoshou = sgs.CreateTriggerSkill{
	name = "LuaHuoshou",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed, sgs.ConfirmDamage, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			if player:isAlive() and player:hasSkill(self:objectName()) then
				local use = data:toCardUse()
				local card = use.card
				local source = use.from
				if card:isKindOf("SavageAssault") then
					if not source:hasSkill(self:objectName()) then
						local tag = sgs.QVariant()
						tag:setValue(player)
						room:setTag("HuoshouSource", tag)
					end
				end
			end
		elseif event == sgs.ConfirmDamage then
			local tag = room:getTag("HuoshouSource")
			if tag then
				local damage = data:toDamage()
				local card = damage.card
				if card then
					if card:isKindOf("SavageAssault") then
						local source = tag:toPlayer()
						if source:isAlive() then
							damage.from = source
						else
							damage.from = nil
						end
						data:setValue(damage)
					end
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			local card = use.card
			if card:isKindOf("SavageAssault") then
				room:removeTag("HuoshouSource")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
LuaSavageAssaultAvoid = sgs.CreateTriggerSkill{
	name = "#LuaSavageAssaultAvoid",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if effect.card:isKindOf("SavageAssault") then
			return true
		end
	end
}
--[[技能名：祸水（锁定技）
	相关武将：国战·邹氏
	描述：你的回合内，体力值不少于体力上限一半的其他角色所有武将技能无效。
	引用：LuaHuoshui
	状态：1217验证通过（性能略差）（貌似有时候还会有Bug？）
]]--
LuaXHuoshui = sgs.CreateTriggerSkill{
	name = "LuaXHuoshui",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart, sgs.Death,
			sgs.MaxHpChanged, sgs.EventAcquireSkill,
			sgs.EventLoseSkill,sgs.PreHpLost},
	on_trigger = function(self, triggerEvent, player, data)
		if player == nil or player:isDead() then return end
		local room = player:getRoom()
		local triggerable = function(target)
			return target and target:isAlive() and target:hasSkill(self:objectName())
		end
		if not triggerable(room:getCurrent()) then
			for _,p in sgs.qlist(room:getAlivePlayers())do --在重新加mark之前先全部消除掉……
				for _,skill in sgs.qlist(p:getVisibleSkillList())do
					room:removePlayerMark(p,"Qingcheng"..skill:objectName())
				end
			end
		end
		local jsonValue = {
			8
		}
		room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
		if triggerEvent == sgs.EventPhaseStart then
			if (not triggerable(player)) or (player:getPhase() ~= sgs.Player_RoundStart and player:getPhase() ~= sgs.Player_NotActive) then
				return false
			end
		elseif triggerEvent == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() or (not player:hasSkill(self:objectName())) then 
				return false 
			end
		elseif triggerEvent == sgs.EventLoseSkill then
			if data:toString() ~= self:objectName() or player:getPhase() == sgs.Player_NotActive then return false end
		elseif (triggerEvent == sgs.EventAcquireSkill) then
			if data:toString() ~= self:objectName() or (not player:hasSkill(self:objectName())) or player:getPhase() == sgs.Player_NotActive then
				return false
			end
		elseif triggerEvent == sgs.MaxHpChanged or triggerEvent == sgs.HpChanged then
			if not(room:getCurrent() and room:getCurrent():hasSkill(self:objectName())) then
				return false 
			end
		end
		
		for _,p in sgs.qlist(room:getOtherPlayers(player))do
			if p:getHp() >= (p:getMaxHp()/2) then
				room:filterCards(p,p:getCards("he"),true)
				for _,skill in sgs.qlist(p:getVisibleSkillList())do
					room:addPlayerMark(p,"Qingcheng"..skill:objectName())
				end
			end
		end
		local jsonValue = {
			8
		}
		room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
	end,
	can_trigger = function(self, player)
		return player
	end,
	priority = 5
}
	技能名：祸首（锁定技）
	相关武将：林·孟获
	描述：【南蛮入侵】对你无效；当其他角色使用【南蛮入侵】指定目标后，你是该【南蛮入侵】造成伤害的来源。
]]--
-----------
--[[I区]]--
-----------
-----------
--[[J区]]--
-----------
--[[技能名：鸡肋
	相关武将：SP·杨修
	描述：每当你受到伤害后，你可以选择一种牌的类别，伤害来源不能使用、打出或弃置其该类别的手牌，直到回合结束。 
	引用：LuaJilei、LuaJileiClear
	状态：0405验证通过
]]--
LuaJilei = sgs.CreateTriggerSkill{
	name = "LuaJilei",
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local current  = room:getCurrent()
		if not current or current:getPhase()==sgs.Player_NotActive or current:isDead() or not damage.from then
			return false
		end
		if room:askForSkillInvoke(player, self:objectName(), data) then
			local choice = room:askForChoice(player, self:objectName(), "BasicCard+EquipCard+TrickCard")
			local jileis = damage.from:getTag(self:objectName()):toString():split("+")
			if table.contains(jileis, choice) then return false end
			table.insert(jileis,choice)
			damage.from:setTag(self:objectName(), sgs.QVariant(table.concat(jileis, "+")))
			local _type = choice.."|.|.|hand" --只是手牌
			room:setPlayerCardLimitation(damage.from, "use,response,discard", _type, true)
			local typename = string.lower(string.gsub(choice,"Card",""))
			if damage.from:getMark("@jilei_"..typename) == 0 then
				room:addPlayerMark(damage.from, "@jilei_"..typename)
			end
		end
	end
}
LuaJileiClear = sgs.CreateTriggerSkill{
	name = "#LuaJilei-clear",
	events = {sgs.EventPhaseChanging,sgs.Death},
	priority = 5,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then 
				return false 
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() or player:objectName() ~= room:getCurrent():objectName() then
				return false
			end
		end
		local players = room:getAllPlayers()
		for _,p in sgs.qlist(players) do
			local jilei_list = p:getTag("LuaJilei"):toString():split("+")
			if #jilei_list > 0 then
				for _,jileity in ipairs(jilei_list) do
					room:removePlayerCardLimitation(p, "use,response,discard", jileity.."|.|.|hand$1")
					local typename = string.lower(string.gsub(jileity,"Card",""))
					room:setPlayerMark(p, "@jilei_"..typename, 0)
				end
				p:removeTag("LuaJilei")
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：激昂
	相关武将：山·孙策，☆SP·吕蒙
	描述：每当你指定或成为红色【杀】或【决斗】的目标后，你可以摸一张牌。 
	引用：LuaJiang
	状态：0405验证通过
]]--
luaJiang = sgs.CreateTriggerSkill{
	name = "LuaJiang" ,
	events = {sgs.TargetConfirmed, sgs.TargetSpecified},
	frequency = sgs.Skill_Frequent, 
	on_trigger = function(self, event, sunce, data)
		local use = data:toCardUse()
		if event == sgs.TargetSpecified or (event == sgs.TargetConfirmed and use.to:contains(sunce)) then
			if use.card:isKindOf("Duel") or (use.card:isKindOf("Slash") and use.card:isRed()) then
				if sunce:askForSkillInvoke(self:objectName(), data) then
					sunce:drawCards(1, self:objectName())
				end
			end
		end
		return false
	end
}
--[[技能名：激将（主公技）
	相关武将：标准·刘备、山·刘禅、怀旧-标准·刘备-旧
	描述：当你需要使用或打出一张【杀】时，你可以令其他蜀势力角色打出一张【杀】（视为由你使用或打出）。
	引用：LuaJijiang
	状态：1217验证通过
]]--
LuaJijiangCard = sgs.CreateSkillCard{
	name = "LuaJijiangCard" ,
	filter = function(self, targets, to_select)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local plist = sgs.PlayerList()
		for i = 1, #targets, 1 do
			plist:append(targets[i])
		end
		return slash:targetFilter(plist, to_select, sgs.Self)
	end ,
	on_validate = function(self, cardUse) --这是0610新加的哦~~~~
		cardUse.m_isOwnerUse = false
		local liubei = cardUse.from
		local targets = cardUse.to
		room = liubei:getRoom()
		local slash = nil
		local lieges = room:getLieges("shu", liubei)
		for _, target in sgs.qlist(targets) do
			target:setFlags("LuaJijiangTarget")
		end
		for _, liege in sgs.qlist(lieges) do
			slash = room:askForCard(liege, "slash", "@jijiang-slash:" .. liubei:objectName(), sgs.QVariant(), sgs.Card_MethodResponse, liubei) --未处理胆守
			if slash then
				for _, target in sgs.qlist(targets) do
					target:setFlags("-LuaJijiangTarget")
				end
				return slash
			end
		end
		for _, target in sgs.qlist(targets) do
			target:setFlags("-LuaJijiangTarget")
		end
		room:setPlayerFlag(liubei, "Global_LuaJijiangFailed")
		return nil
	end
}
hasShuGenerals = function(player)
	for _, p in sgs.qlist(player:getSiblings()) do
		if p:isAlive() and (p:getKingdom() == "shu") then
			return true
		end
	end
	return false
end
LuaJijiangVS = sgs.CreateViewAsSkill{
	name = "LuaJijiang$" ,
	n = 0 ,
	view_as = function()
		return LuaJijiangCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return hasShuGenerals(player)
		   and player:hasLordSkill("LuaJijiang")
		   and (not player:hasFlag("Global_LuaJijiangFailed"))
		   and sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return hasShuGenerals(player)
		   and player:hasLordSkill("LuaJijiang")
		   and ((pattern == "slash") or (pattern == "@jijiang"))
		   and (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE)
		   and (not player:hasFlag("Global_LuaJijiangFailed"))
	end
}
LuaJijiang = sgs.CreateTriggerSkill{
	name = "LuaJijiang$" ,
	events = {sgs.CardAsked} ,
	view_as_skill = LuaJijiangVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pattern = data:toStringList()[1]
		local prompt = data:toStringList()[2]
		if (pattern ~= "slash") or string.find(prompt, "@jijiang-slash") then return false end
		local lieges = room:getLieges("shu", player)
		if lieges:isEmpty() then return false end
		if not room:askForSkillInvoke(player, self:objectName(), data) then return false end
		for _, liege in sgs.qlist(lieges) do
			local slash = room:askForCard(liege, "slash", "@jijiang-slash:" .. player:objectName(), sgs.QVariant(), sgs.Card_MethodResponse, player)
			if slash then
				room:provide(slash)
				return true
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:hasLordSkill("LuaJijiang")
	end
}
--[[技能名：极略
	相关武将：神·司马懿
	描述：你可以弃一枚“忍”并发动以下技能之一：“鬼才”、“放逐”、“集智”、“制衡”、“完杀”。   
	引用：LuaJilve、LuaJilveClear
	状态：0405验证通过
]]--
LuaJilveCard = sgs.CreateSkillCard{
	name = "LuaJilveCard",
	target_fixed = true,
	about_to_use = function(self, room, use)
		local shensimayi = use.from
		local choices = {}
		if not shensimayi:hasFlag("LuaJilveZhiheng") and shensimayi:canDiscard(shensimayi, "he") then
			table.insert(choices,"zhiheng")
		end
		if not shensimayi:hasFlag("LuaJilveWansha") then
			table.insert(choices,"wansha")
		end
		table.insert(choices,"cancel")
		if #choices == 1 then return end
		local choice = room:askForChoice(shensimayi, "LuaJilve", table.concat(choices,"+"))
		if choice == "cancel" then
			room:addPlayerHistory(shensimayi, "#LuaJilveCard", -1)
			return
		end
		shensimayi:loseMark("@bear")
		room:notifySkillInvoked(shensimayi, "LuaJilve")
		if choice == "wansha" then
			room:setPlayerFlag(shensimayi, "LuaJilveWansha")
			room:acquireSkill(shensimayi, "wansha")
		else
			room:setPlayerFlag(shensimayi, "LuaJilveZhiheng")
			room:askForUseCard(shensimayi, "@zhiheng", "@jilve-zhiheng", -1, sgs.Card_MethodDiscard)
		end
	end
}
LuaJilveVS = sgs.CreateZeroCardViewAsSkill{--完杀和制衡
	name = "LuaJilve",
	enabled_at_play = function(self,player)
		return player:usedTimes("#LuaJilveCard") < 2 and player:getMark("@bear") > 0
	end,
	view_as = function()
		return LuaJilveCard:clone()
	end
}
LuaJilve = sgs.CreateTriggerSkill{
	name = "LuaJilve",
	events = {sgs.CardUsed, sgs.AskForRetrial, sgs.Damaged},--分别为集智、鬼才、放逐
	view_as_skill = LuaJilveVS,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) and target:getMark("@bear") > 0
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		player:setMark("JilveEvent",tonumber(event))
		if event == sgs.CardUsed then
			local jizhi = sgs.Sanguosha:getTriggerSkill("jizhi")
			local use = data:toCardUse()
			if jizhi and use.card and use.card:getTypeId() == sgs.Card_TypeTrick and player:askForSkillInvoke(self:objectName(), data) then
				room:notifySkillInvoked(player, self:objectName())
				player:loseMark("@bear")
				jizhi:trigger(event, room, player, data)
			end
		elseif event == sgs.AskForRetrial then
			local guicai = sgs.Sanguosha:getTriggerSkill("guicai")
			if guicai and not player:isKongcheng() and player:askForSkillInvoke(self:objectName(), data) then
				room:notifySkillInvoked(player, self:objectName())
				player:loseMark("@bear")
				guicai:trigger(event, room, player, data)
			end
		elseif event == sgs.Damaged then
			local fangzhu = sgs.Sanguosha:getTriggerSkill("fangzhu")
			if fangzhu and player:askForSkillInvoke(self:objectName(), data) then
				room:notifySkillInvoked(player, self:objectName())
				player:loseMark("@bear")
				fangzhu:trigger(event, room, player, data)
			end
		end
		player:setMark("JilveEvent", 0)
		return false
	end
}
LuaJilveClear = sgs.CreateTriggerSkill{
	name = "#LuaJilve-clear",
	events = {sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		room:detachSkillFromPlayer(player, "wansha", false, true)
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasFlag("LuaJilveWansha")
	end
}
--[[技能名：急救
	相关武将：标准·华佗
	描述：你的回合外，你可以将一张红色牌当【桃】使用。
	引用：LuaJijiu
	状态：1217验证通过
]]--
LuaJijiu = sgs.CreateViewAsSkill{
	name = "LuaJijiu",
	n = 1,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return to_select:isRed()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local suit = card:getSuit()
			local point = card:getNumber()
			local id = card:getId()
			local peach = sgs.Sanguosha:cloneCard("peach", suit, point)
			peach:setSkillName(self:objectName())
			peach:addSubcard(id)
			return peach
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		local phase = player:getPhase()
		if phase == sgs.Player_NotActive then
			return string.find(pattern, "peach")
		end
		return false
	end
}
--[[技能名：急速
	相关武将：奥运·叶诗文
	描述：你可以跳过你此回合的判定阶段和摸牌阶段。若如此做，视为对一名其他角色使用一张【杀】。
	引用：LuaXJisu
	状态：1217验证通过
]]--
LuaXJisuCard = sgs.CreateSkillCard{
	name = "LuaXJisuCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return sgs.Self:canSlash(to_select, nil, false)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName(self:objectName())
		local use = sgs.CardUseStruct()
		use.card = slash
		use.from = source
		for _,p in pairs(targets) do
			use.to:append(p)
		end
		room:useCard(use)
	end
}
LuaXJisuVS = sgs.CreateViewAsSkill{
	name = "LuaXJisu",
	n = 0,
	view_as = function(self, cards)
		return LuaXJisuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaXJisu"
	end
}
LuaXJisu = sgs.CreateTriggerSkill{
	name = "LuaXJisu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	view_as_skill = LuaXJisuVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		local nextphase = change.to
		if nextphase == sgs.Player_Judge then
			if not player:isSkipped(sgs.Player_Judge) then
				if not player:isSkipped(sgs.Player_Draw) then
					if room:askForUseCard(player, "@@LuaXJisu", "@LuaXJisu") then
						player:skip(sgs.Player_Judge)
						player:skip(sgs.Player_Draw)
					end
				end
			end
		end
		return false
	end
}
--[[技能名：急袭
	相关武将：山·邓艾
	描述：你可以将一张“田”当【顺手牵羊】使用。
	引用：LuaJixi
	状态：0405验证通过(需与技能“屯田”配合使用)
]]--
LuaJixi = sgs.CreateOneCardViewAsSkill{
	name = "LuaJixi", 
	filter_pattern = ".|.|.|field",
	expand_pile = "field",
	view_as = function(self, originalCard) 
		local snatch = sgs.Sanguosha:cloneCard("snatch", originalCard:getSuit(), originalCard:getNumber())
		snatch:addSubcard(originalCard:getId())
		snatch:setSkillName(self:objectName())
		return snatch
	end, 
	enabled_at_play = function(self, player)
		return not player:getPile("field"):isEmpty()
	end
}
--[[技能名：集智
	相关武将：标准·黄月英
	描述：每当你使用锦囊牌选择目标后，你可以展示牌堆顶的一张牌。若此牌为基本牌，你选择一项：1.将之置入弃牌堆；2.用一张手牌替换之。若此牌不为基本牌，你获得之。
	引用：LuaJizhi
	状态：1217验证通过
]]--
LuaJizhi = sgs.CreateTriggerSkill{
	name = "LuaJizhi" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		local room = player:getRoom()
		if (use.card:getTypeId() == sgs.Card_TypeTrick) then
			if not (player:getMark("JilveEvent") > 0) then
				if not room:askForSkillInvoke(player, self:objectName()) then return false end
			end
			local ids = room:getNCards(1, false)
			local move = sgs.CardsMoveStruct()
			move.card_ids = ids
			move.to = player
			move.to_place = sgs.Player_PlaceTable
			move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
			room:moveCardsAtomic(move, true)
			local id = ids:first()
			local card = sgs.Sanguosha:getCard(id)
			if not card:isKindOf("BasicCard") then
				player:obtainCard(card)
			else
				local card_ex
				if not player:isKongcheng() then
					local card_data = sgs.QVariant()
					card_data:setValue(card)
					card_ex = room:askForCard(player, ".", "@jizhi-exchange:::" .. card:objectName(), card_data, sgs.Card_MethodNone)
				end
				if card_ex then
					local reason1 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), nil)
					local reason2 = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_OVERRIDE, player:objectName(), self:objectName(), nil)
					local move1 = sgs.CardsMoveStruct()
					move1.card_ids:append(card_ex:getEffectiveId())
					move1.from = player
					move1.to = nil
					move1.to_place = sgs.Player_DrawPile
					move1.reason = reason1
					local move2 = sgs.CardsMoveStruct()
					move2.card_ids = ids
					move2.from = player
					move2.to = player
					move2.to_place = sgs.Player_PlaceHand
					move2.reason = reason2
					local moves = sgs.CardsMoveList()
					moves:append(move1)
					moves:append(move2)
					room:moveCardsAtomic(moves, false)
				else
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NAUTRAL_ENTER, player:objectName(), self:objectName(), nil)
					room:throwCard(card, reason, nil)
				end
			end
		end
		return false
	end
}
--[[
	技能名：集智
	相关武将：怀旧-标准·黄月英-旧、1v1·黄月英1v1、SP·台版黄月英
	描述：每当你使用非延时类锦囊牌选择目标后，你可以摸一张牌。
	引用：LuaNosJizhi
	状态：0405验证通过
]]--
LuaNosJizhi = sgs.CreateTriggerSkill{
	name = "LuaNosJizhi" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isNDTrick() and room:askForSkillInvoke(player, self:objectName()) then
			player:drawCards(1, self:objectName())
		end
		return false
	end
}
--[[技能名：嫉恶（锁定技）
	相关武将：☆SP·张飞
	描述：你使用的红色【杀】造成的伤害+1。
	引用：LuaJie
	状态：1217验证通过
]]--
LuaJie = sgs.CreateTriggerSkill{
	name = "LuaJie",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local card = damage.card
		if card then
			if card:isKindOf("Slash") and card:isRed() then
				local hurt = damage.damage
				damage.damage = hurt + 1
				data:setValue(damage)
			end
		end
		return false
	end
}
--[[技能名：奸雄
	相关武将：界限突破·曹操
	描述：每当你受到伤害后，你可以选择一项：获得对你造成伤害的牌，或摸一张牌。 
	引用：LuaJianxiong
	状态：0405验证通过
]]--
LuaJianxiong = sgs.CreateMasochismSkill{
	name = "LuaJianxiong" ,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local data = sgs.QVariant()
		data:setValue(damage)
		local choices = {"draw+cancel"}
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
	end
}
--[[技能名：奸雄
	相关武将：标准·曹操、铜雀台·曹操
	描述：每当你受到伤害后，你可以获得对你造成伤害的牌。 
	引用：LuaNosJianxiong
	状态：0405验证通过
]]--
LuaNosJianxiong = sgs.CreateMasochismSkill{
	name = "LuaNosJianxiong" ,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local card = damage.card
		if not card then return end
		local ids = sgs.IntList()
		if card:isVirtualCard() then
			ids = card:getSubcards()
		else
			ids:append(card:getEffectiveId())
		end
		if ids:isEmpty() then return end
		for _, id in sgs.qlist(ids) do
			if room:getCardPlace(id) ~= sgs.Player_PlaceTable then return end
		end
		local data = sgs.QVariant()
		data:setValue(damage)
		if room:askForSkillInvoke(player, self:objectName(), data) then
			player:obtainCard(card)
		end
	end
}
--[[技能名：坚守
	相关武将：测试·蹲坑曹仁
	描述：回合结束阶段开始时，你可以摸五张牌，然后将你的武将牌翻面
	引用：LuaXJianshou
	状态：1217验证通过
]]--
LuaXJianshou = sgs.CreateTriggerSkill{
	name = "LuaXJianshou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if player:askForSkillInvoke(self:objectName(), data) then
				player:drawCards(5, true, self:objectName())
				player:turnOver()
			end
		end
	end
}
--[[技能名：将驰
	相关武将：二将成名·曹彰
	描述：摸牌阶段，你可以选择一项：1、额外摸一张牌，若如此做，你不能使用或打出【杀】，直到回合结束。2、少摸一张牌，若如此做，出牌阶段你使用【杀】时无距离限制且你可以额外使用一张【杀】，直到回合结束。
	引用：LuaJiangchi、LuaJiangchiTargetMod
	状态：1217验证通过
]]--
LuaJiangchi = sgs.CreateTriggerSkill{
	name = "LuaJiangchi" ,
	events = {sgs.DrawNCards} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local choice = room:askForChoice(player, self:objectName(), "jiang+chi+cancel")
		if choice == "cancel" then return false end
		if choice == "jiang" then
			room:setPlayerCardLimitation(player, "use,response", "Slash", true)
			data:setValue(data:toInt() + 1)
			return false
		else
			room:setPlayerFlag(player, "LuaJiangchiInvoke")
			data:setValue(data:toInt() - 1)
			return false
		end
	end
}
LuaJiangchiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaJiangchi-target" ,
	residue_func = function(self, from)
		if from:hasSkill("LuaJiangchi") and from:hasFlag("LuaJiangchiInvoke") then
			return 1
		else
			return 0
		end
	end ,
	distance_limit_func = function(self, from)
		if from:hasSkill("LuaJiangchi") and from:hasFlag("LuaJiangchiInvoke") then
			return 1000
		else
			return 0
		end
	end
}
--[[技能名：节命
	相关武将：火·荀彧
	描述：每当你受到1点伤害后，你可以令一名角色将手牌补至X张（X为该角色的体力上限且至多为5）。
	引用：LuaJieming
	状态：1217验证通过
]]--
LuaJieming = sgs.CreateTriggerSkill{
	name = "LuaJieming" ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		for i = 0, damage.damage - 1, 1 do
			local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "jieming-invoke", true, true)
			if not to then break end
			local upper = math.min(5, to:getMaxHp())
			local x = upper - to:getHandcardNum()
			if x <= 0 then
			else
				to:drawCards(x)
			end
		end
	end
}
--[[技能名：结姻
	相关武将：界限突破·孙尚香、标准·孙尚香、SP·孙尚香
	描述：出牌阶段限一次，你可以弃置两张手牌并选择一名已受伤的男性角色，你和该角色各回复1点体力。
	引用：LuaJieyin
	状态：0405验证通过
]]--
LuaJieyinCard = sgs.CreateSkillCard{
	name = "LuaJieyinCard" ,
	filter = function(self, targets, to_select)
		if #targets ~= 0 then return false end
		return to_select:isMale() and to_select:isWounded() and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local recover = sgs.RecoverStruct()
		recover.card = self
		recover.who = effect.from
		room:recover(effect.from, recover, true)
		room:recover(effect.to, recover, true)
	end
}
LuaJieyin = sgs.CreateViewAsSkill{
	name = "LuaJieyin" ,
	n = 2 ,
	view_filter = function(self, selected, to_select)
		if #selected > 1 or sgs.Self:isJilei(to_select) then return false end
		return not to_select:isEquipped()
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local jieyin_card = LuaJieyinCard:clone()
		for _,card in pairs(cards) do
			jieyin_card:addSubcard(card)
		end
		return jieyin_card
	end ,
	enabled_at_play = function(self, target)
		return target:getHandcardNum() >= 2 and not target:hasUsed("#LuaJieyinCard")
	end
}
--[[技能名：竭缘
	相关武将：铜雀台·灵雎、SP·灵雎
	描述：每当你对一名其他角色造成伤害时，若其体力值大于或等于你的体力值，你可以弃置一张黑色手牌：若如此做，此伤害+1。每当你受到一名其他角色造成的伤害时，若其体力值大于或等于你的体力值，你可以弃置一张红色手牌：若如此做，此伤害-1。 
	引用：LuaJieyuan
	状态：0405验证通过
]]--
LuaJieyuan = sgs.CreateTriggerSkill{
	name = "LuaJieyuan" ,
	events = {sgs.DamageCaused, sgs.DamageInflicted} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if event == sgs.DamageCaused then
			if damage.to and damage.to:isAlive() and damage.to:getHp() >= player:getHp() and damage.to:objectName() ~= player:objectName() and player:canDiscard(player, "h") and room:askForCard(player, ".black", "@jieyuan-increase:" .. damage.to:objectName(), data, self:objectName()) then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif event == sgs.DamageInflicted then
			if damage.from and damage.from:isAlive() and damage.from:getHp() >= player:getHp() and damage.from:objectName() ~= player:objectName() and player:canDiscard(player, "h") and room:askForCard(player, ".red", "@jieyuan-decrease:" .. damage.from:objectName(), data, self:objectName()) then
				damage.damage = damage.damage - 1
				data:setValue(damage)
				if damage.damage < 1 then return true end
			end
		end
		return false
	end
}
--[[技能名：解烦（限定技）
	相关武将：二将成名·韩当
	描述：出牌阶段，你可以指定一名角色，攻击范围内含有该角色的所有角色须依次选择一项：弃置一张武器牌；或令该角色摸一张牌。
	引用：LuaJiefan
	状态：1217验证通过
]]--
LuaJiefanCard = sgs.CreateSkillCard{
	name = "LuaJiefanCard" ,
	filter = function(self, targets, to_select)
		return #targets == 0
	end  ,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@rescue")
		local target = targets[1]
		local _targetdata = sgs.QVariant()
		_targetdata:setValue(target)
		source:setTag("LuaJiefanTarget", _targetdata)
		for _, player in sgs.qlist(room:getAllPlayers()) do
			if player:isAlive() and player:inMyAttackRange(target) then
				room:cardEffect(self, source, player)
			end
		end
		source:removeTag("LuaJiefanTarget")
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local target = effect.from:getTag("LuaJiefanTarget"):toPlayer()
		local data = effect.from:getTag("LuaJiefanTarget")
		if target then
			if not room:askForCard(effect.to, ".Weapon", "@jiefan-discard::" .. target:objectName(), data) then
				target:drawCards(1)
			end
		end
	end
}
LuaJiefanVS = sgs.CreateViewAsSkill{
	name = "LuaJiefan" ,
	n = 0,
	view_as = function()
		return LuaJiefanCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return player:getMark("@rescue") >= 1
	end
}
LuaJiefan = sgs.CreateTriggerSkill{
	name = "LuaJiefan" ,
	frequency = sgs.Skill_Limited,
	limit_mark = "@rescue",
	events = {},
	view_as_skill = LuaJiefanVS ,

	on_trigger = function()
		return false
	end
}
--[[技能名：解烦
	相关武将：怀旧·韩当
	描述：你的回合外，当一名角色处于濒死状态时，你可以对当前正进行回合的角色使用一张【杀】（无距离限制），此【杀】造成伤害时，你防止此伤害，视为对该濒死角色使用一张【桃】。
	引用：LuaNosJiefan
	状态：1217验证通过
]]--
LuaNosJiefanCard = sgs.CreateSkillCard{
	name = "LuaNosJiefanCard",
	target_fixed = true,
	mute = true,
	on_use = function(self,room,handang,targets)
		local current = room:getCurrent()
		if not current or current:isDead() or current:getPhase() == sgs.Player_NotActive then return end
		local who = room:getCurrentDyingPlayer()
		if not who then return end
		handang:setFlags("NosJiefanUsed")
		local data = sgs.QVariant()
		data:setValue(who)
		room:setTag("NosJiefanTarget",data)
		local use_slash = room:askForUseSlashTo(handang,current,"nosjiefan-slash:"..current:objectName(),false)
		if not use_slash then
			handang:setFlags("-NosJiefanUsed")
			room:removeTag("NosJiefanTarget")
			room:setPlayerFlag(handang,"Global_NosJiefanFailed")
		end
	end
}
LuaNosJiefanvs = sgs.CreateViewAsSkill{
	name = "LuaNosJiefan",
	n = 0,
	enabled_at_play = function(self,player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		if not string.find(pattern,"peach") then return false end
		if player:hasFlag("Global_NosJiefanFailed") then return false end
		for _,p in sgs.qlist(player:getAliveSiblings()) do
			if p:getPhase() ~=sgs.Player_NotActive then
				return true
			end
		end
		return false
	end,
	view_as = function(self,cards)
		return LuaNosJiefanCard:clone()
	end
}
LuaNosJiefan = sgs.CreateTriggerSkill{
	name = "LuaNosJiefan",
	events = {sgs.DamageCaused,sgs.CardFinished,sgs.PreCardUsed},
	view_as_skill = LuaNosJiefanvs,
	on_trigger = function(self,event,handang,data)
		local room = handang:getRoom()
		if event == sgs.PreCardUsed then
			if not handang:hasFlag("NosJiefanUsed") then return false end
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				handang:setFlags("-NosJiefanUsed")
				room:setCardFlag(use.card,"nosjiefan-slash")
			end
		elseif event == sgs.DamageCaused then
			local current = room:getCurrent()
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and damage.card:hasFlag("nosjiefan-slash") then
				local log2 = sgs.LogMessage()
				log2.type = "#NosJiefanPrevent"
				log2.from = handang
				log2.to:append(damage.to)
				room:sendLog(log2)
				local target = room:getTag("NosJiefanTarget"):toPlayer()
				if target and target:getHp() > 0 then
					local log = sgs.LogMessage()
					log.type = "#NosJiefanNull1"
					log.from = target
					room:sendLog(log)
				elseif target and target:isDead() then
					local log = sgs.LogMessage()
					log.type = "#NosJiefanNull2"
					log.from = target					
					room:sendLog(log)
				elseif handang:hasFlag("Global_PreventPeach") then
					local log = sgs.LogMessage()
					log.type = "#NosJiefanNull3"
					log.from = current
					log.to:append(handang)
					room:sendLog(log)
				else
					local peach = sgs.Sanguosha:cloneCard("peach",sgs.Card_NoSuit,0)
					peach:setSkillName(self:objectName())
					room:setCardFlag(damage.card,"nosjiefan_success")
					room:useCard(sgs.CardUseStruct(peach,handang,target))
				end
				return true
			end
			return false
		elseif event == sgs.CardFinished and room:getTag("NosJiefanTarget"):toPlayer() then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and use.card:hasFlag("nosjiefan-slash") then
				if not use.card:hasFlag("nosjiefan_success") then
					room:setPlayerFlag(handang,"Global_NosJiefanFailed")
				end
				room:removeTag("NosJiefanTarget")
			end
		end
		return false
	end
}
--[[技能名：解惑（觉醒技）
	相关武将：智·司马徽
	描述：当你发动“授业”目标累计超过6个时，须减去一点体力上限，将技能“授业”改为每阶段限一次，并获得技能“师恩”
	引用：LuaJiehuo
	状态：1217验证通过
	注：智水镜的三个技能均有联系，为了方便起见统一使用本LUA版本的技能，并非原版
]]--
LuaJiehuo = sgs.CreateTriggerSkill{
	name = "LuaJiehuo" ,
	events = {sgs.CardFinished} ,
	frequency = sgs.Skill_Wake ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:setPlayerMark(player, "LuaJiehuo", 1)
		player:loseAllMarks("@shouye")
		if room:changeMaxHpForAwakenSkill(player) then
			room:acquireSkill(player, "LuaShien")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (target:getMark("LuaJiehuo") == 0) and (target:getMark("@shouye") >= 7)
	end
}
--[[技能名：解围
	相关武将：风·曹仁
	描述：每当你的武将牌翻面后，你可以摸一张牌，然后你可以使用一张锦囊牌或装备牌：若如此做，该牌结算后，你可以弃置场上一张同类型的牌。
	状态：1217验证通过
]]--
LuaJiewei = sgs.CreateTriggerSkill{
	name = "LuaJiewei",
	events = {sgs.TurnedOver} ,
	frequency = sgs.Skill_NotFrequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not room:askForSkillInvoke(player, self:objectName()) then return false end
		player:drawCards(1)
		local card = room:askForUseCard(player, "TrickCard+^Nullification,EquipCard|.|.|hand", "@Luajiewei")
		if not card then return false end
		local targets = sgs.SPlayerList()
		if card:getTypeId() == sgs.Card_TypeTrick then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				local can_discard = false
				for _, judge in sgs.qlist(p:getJudgingArea()) do
					if (judge:getTypeId() == sgs.Card_TypeTrick) and (player:canDiscard(p, judge:getEffectiveId())) then
						can_discard = true
						break
					elseif judge:getTypeId() == sgs.Card_TypeSkill then
						local real_card = Sanguosha:getEngineCard(judge:getEffectiveId())
						if (real_card:getTypeId() == sgs.Card_TypeTrick) and (player:canDiscard(p, real_card:getEffectiveId())) then
							can_discard = true
							break
						end
					end
				end
				if can_discard then targets:append(p) end
			end
		elseif (card:getTypeId() == sgs.Card_TypeEquip) then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
						if (not p:getEquips():isEmpty()) and (player:canDiscard(p, "e")) then
							targets:append(p)
				else
					for _, judge in sgs.qlist(p:getJudgingArea()) do
									if judge:getTypeId() == sgs.Card_TypeSkill then
						local real_card = Sanguosha:getEngineCard(judge:getEffectiveId())
						 				if (real_card:getTypeId() == sgs.Card_TypeEquip) and (player:canDiscard(p, real_card:getEffectiveId())) then
												targets:append(p)
							   					break
							end
						end
					end
				end
			end
		end
		if targets:isEmpty() then return false end
		local to_discard = room:askForPlayerChosen(player, targets, self:objectName(), "@Luajiewei-discard", true)
		if to_discard then
			local disabled_ids = sgs.IntList()
			for _, c in sgs.qlist(to_discard:getCards("ej")) do
				local pcard = c 
				if (pcard:getTypeId() == sgs.Card_TypeSkill) then
					pcard = sgs.Sanguosha:getEngineCard(c:getEffectiveId())
				end
				if (pcard:getTypeId()~= card:getTypeId()) then
					disabled_ids:append(pcard:getEffectiveId())
				end
			end
			local id = room:askForCardChosen(player, to_discard, "ej", self:objectName(), false, sgs.Card_MethodDiscard, disabled_ids)
			room:throwCard(id, to_discard, player)
		end
		return false
	end	
}
--[[技能名：尽瘁
	相关武将：智·张昭
	描述：当你死亡时，可令一名角色摸取或者弃置三张牌
	引用：LuaXJincui
	状态：1217验证通过
]]--
LuaXJincui = sgs.CreateTriggerSkill{
	name = "LuaXJincui",
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		local alives = room:getAlivePlayers()
		if player:objectName() == death.who:objectName() then
			if not alives:isEmpty() then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					local target = room:askForPlayerChosen(player, alives, self:objectName())
					local ai_data = sgs.QVariant()
					ai_data:setValue(target)
					local choice = room:askForChoice(player, self:objectName(), "draw+throw", ai_data)
					if choice == "draw" then
						target:drawCards(3)
					else
						local count = math.min(3, target:getCardCount(true))
						room:askForDiscard(target, self:objectName(), count, count, false, true)
					end
				end
			end
		end
		return
	end,
	can_trigger = function(self, target)
		 return target and target:hasSkill(self:objectName())
	end
}
--[[技能名：禁酒（锁定技）
	相关武将：一将成名·高顺
	描述：你的【酒】均视为【杀】。
	引用：LuaJinjiu
	状态：1217验证通过
]]--
LuaJinjiu = sgs.CreateFilterSkill{
	name = "LuaJinjiu" ,
	view_filter = function(self, card)
		return card:objectName() == "analeptic"
	end ,
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:setSkillName(self:objectName())
		local wrap = sgs.Sanguosha:getWrappedCard(card:getId())
		wrap:takeOver(slash)
		return wrap
	end
}
--[[技能名：精策
	相关武将：一将成名2013·郭淮
	描述：出牌阶段结束时，若你本回合已使用的牌数大于或等于你当前的体力值，你可以摸两张牌。
	引用：LuaJingce
	状态：1217验证通过
]]--
LuaJingce = sgs.CreateTriggerSkill{
	name = "LuaJingce" ,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseStart, sgs.EventPhaseEnd} ,
	frequency = sgs.Skill_Frequent ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if ((event == sgs.PreCardUsed) or (event == sgs.CardResponded)) and (player:getPhase() <= sgs.Player_Play) then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and (card:getHandlingMethod() == sgs.Card_MethodUse) then
				player:addMark(self:objectName())
			end
		elseif (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_RoundStart) then
			player:setMark(self:objectName(), 0)
		elseif event == sgs.EventPhaseEnd then
			if (player:getPhase() == sgs.Player_Play) and (player:getMark(self:objectName()) >= player:getHp()) then
				if room:askForSkillInvoke(player, self:objectName()) then
					player:drawCards(2)
				end
			end
		end
		return false
	end
}
--[[技能名：酒池
	相关武将：林·董卓
	描述：你可以将一张黑桃手牌当【酒】使用。
	引用：LuaJiuchi
	状态：1217验证通过
]]--
LuaJiuchi = sgs.CreateViewAsSkill{
	name = "LuaJiuchi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (not to_select:isEquipped()) and (to_select:getSuit() == sgs.Card_Spade)
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", cards[1]:getSuit(), cards[1]:getNumber())
			analeptic:setSkillName(self:objectName())
			analeptic:addSubcard(cards[1])
			return analeptic
		end
	end,
	enabled_at_play = function(self, player)
		local newanal = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
		if player:isCardLimited(newanal, sgs.Card_MethodUse) or player:isProhibited(player, newanal) then return false end
		return player:usedTimes("Analeptic") <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, player , newanal)
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "analeptic")
	end
}
--[[技能名：酒诗
	相关武将：一将成名·曹植
	描述：若你的武将牌正面朝上，你可以将你的武将牌翻面，视为使用一张【酒】；若你的武将牌背面朝上时你受到伤害，你可以在伤害结算后将你的武将牌翻转至正面朝上。
	引用：LuaJiushi
	状态：1217验证通过
]]--
LuaJiushivs = sgs.CreateViewAsSkill{
	name = "LuaJiushi",
	n = 0,
	view_as = function(self, cards)
		local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
		analeptic:setSkillName(self:objectName())
		return analeptic
	end,
	enabled_at_play = function(self, player)
		return sgs.Analeptic_IsAvailable(player) and player:faceUp()
	end,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "analeptic") and player:faceUp()
	end
}
LuaJiushi = sgs.CreateTriggerSkill{
	name = "LuaJiushi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.PreCardUsed, sgs.PreDamageDone, sgs.DamageComplete},
	view_as_skill = LuaJiushivs,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			local card = use.card
			if card:getSkillName() == "LuaJiushi" then
				player:turnOver()
			end
		elseif event == sgs.PreDamageDone then
			room:setTag("PredamagedFace", sgs.QVariant(player:faceUp()))
		elseif event == sgs.DamageComplete then
			local faceup = room:getTag("PredamagedFace"):toBool()
			room:removeTag("PredamagedFace")
			if not (faceup or player:faceUp()) then
				if player:askForSkillInvoke("LuaJiushi", data) then
					player:turnOver()
				end
			end
		end
	end
}
--[[技能名：救援（主公技、锁定技）
	相关武将：标准·孙权、测试·制霸孙权
	描述：其他吴势力角色使用的【桃】指定你为目标后，回复的体力+1。
	引用：LuaJiuyuan
	状态：1217验证通过
]]--
LuaJiuyuan = sgs.CreateTriggerSkill{
	name = "LuaJiuyuan$",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed, sgs.PreHpRecover},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.card:isKindOf("Peach") and use.from and (use.from:getKingdom() == "wu")
					and (player:objectName() ~= use.from:objectName()) and player:hasFlag("Global_Dying") then
				room:setCardFlag(use.card, "LuaJiuyuan")
			end
		elseif event == sgs.PreHpRecover then
			local rec = data:toRecover()
			if rec.card and rec.card:hasFlag("LuaJiuyuan") then
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		end
	end,
	can_trigger = function(self, target)
		if target then
			return target:hasLordSkill(self:objectName())
		end
		return false
	end
}
--[[技能名：救主
	相关武将：2013-3v3·赵云
	描述：每当一名其他己方角色处于濒死状态时，若你的体力值大于1，你可以失去1点体力并弃置一张牌，令该角色回复1点体力。
	引用：LuaJiuzhu
	状态：1217验证通过(2013-3v3模式)
]]--
LuaJiuzhuCard = sgs.CreateSkillCard{
	name = "LuaJiuzhuCard",
	target_fixed = true,
	on_use = function(self,room,player,targets)
		local who = room:getCurrentDyingPlayer()
		if not who then return end
		room:loseHp(player)
		local recover = sgs.RecoverStruct()
		recover.who = player
		room:recover(who,recover)
	end
}
LuaJiuzhuvs = sgs.CreateViewAsSkill{
	name = "LuaJiuzhu",
	n = 1,
	view_filter = function(self,selected,to_select)
		return #selected == 0 
	end,
	enabled_at_play = function(self,player)
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		if pattern ~= "peach" or not player:canDiscard(player,"he") or player:getHp() <= 1 then return false end
		local dyingobj = player:property("currentdying"):toString()
		local who = nil
		for _,p in sgs.qlist(player:getAliveSiblings()) do 
			if p:objectName() == dyingobj then
				who = p
				break
			end
		end
		if not who then return false end
		if player:getMark("_3v3mode") > 0 then
			return string.sub(player:getRole(),1,1) == string.sub(who:getRole(),1,1)
		else
			return true
		end
	end,
	view_as = function(self,cards)
		if #cards ~= 1 then return nil end
		local card = LuaJiuzhuCard:clone()
		card:addSubcard(cards[1])
		return card
	end
}
LuaJiuzhu = sgs.CreateTriggerSkill{
	name = "LuaJiuzhu",
	events = {sgs.GameStart},
	view_as_skill = LuaJiuzhuvs,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if player:getGameMode():startsWith("06_") then
			room:setPlayerMark(player,"_3v3mode",1)
		end
		return false
	end
}
--[[技能名：举荐
	相关武将：一将成名·徐庶
	描述：回合结束阶段开始时，你可以弃置一张非基本牌，令一名其他角色选择一项：摸两张牌，或回复1点体力，或将其武将牌翻至正面朝上并重置之。
	引用：LuaJujian
	状态：1217验证通过
]]--
LuaJujianCard = sgs.CreateSkillCard{
	name = "LuaJujianCard",
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
		local choice = room:askForChoice(effect.to, "LuaJujian", table.concat(choiceList, "+"))
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
LuaJujianVS = sgs.CreateViewAsSkill{
	name = "LuaJujian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (not to_select:isKindOf("BasicCard")) and (not sgs.Self:isJilei(to_select))
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local jujiancard = LuaJujianCard:clone()
			jujiancard:addSubcard(cards[1])
			return jujiancard
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaJujian"
	end
}
LuaJujian = sgs.CreateTriggerSkill{
	name = "LuaJujian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaJujianVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Finish) and player:canDiscard(player, "he") then
			room:askForUseCard(player, "@@LuaJujian", "@jujian-card", -1, sgs.Card_MethodNone)
		end
		return false
	end
}
--[[技能名：举荐
	相关武将：怀旧·徐庶
	描述：出牌阶段，你可以弃置至多三张牌，然后令一名其他角色摸等量的牌。若你以此法弃置三张同一类别的牌，你回复1点体力。每阶段限一次。
	引用：LuaNosJujian
	状态：1217验证通过
]]--
LuaNosJujianCard = sgs.CreateSkillCard{
	name = "LuaNosJujianCard" ,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_effect = function(self, effect)
		local n = self:subcardsLength()
		effect.to:drawCards(n)
		local room = effect.from:getRoom()
		if n == 3 then
			local thetype = nil
			for _, card_id in sgs.qlist(effect.card:getSubcards()) do
				if thetype == nil then
					thetype = sgs.Sanguosha:getCard(card_id):getTypeId()
				elseif sgs.Sanguosha:getCard(card_id):getTypeId() ~= thetype then
					return false
				end
			end
			local recover = sgs.RecoverStruct()
			recover.card = self
			recover.who = effect.from
			room:recover(effect.from, recover)
		end
	end
}
LuaNosJujian = sgs.CreateViewAsSkill{
	name = "LuaNosJujian" ,
	n = 3 ,
	view_filter = function(self, selected, to_select)
		return (#selected < 3) and (not sgs.Self:isJilei(to_select))
	end ,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local card = LuaNosJujianCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and (not player:hasUsed("#LuaNosJujianCard"))
	end
}
--[[技能名：巨象（锁定技）
	相关武将：林·祝融
	描述：【南蛮入侵】对你无效；当其他角色使用的【南蛮入侵】在结算后置入弃牌堆时，你获得之。
	引用：LuaSavageAssaultAvoid（与祸首一致，注意重复技能）、LuaJuxiang
	状态：1217验证通过
]]--
LuaSavageAssaultAvoid = sgs.CreateTriggerSkill{
	name = "#LuaSavageAssaultAvoid",
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if effect.card:isKindOf("SavageAssault") then
			return true
		else
			return false
		end
	end
}
LuaJuxiang = sgs.CreateTriggerSkill{
	name = "LuaJuxiang",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.BeforeCardsMove,sgs.CardUsed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("SavageAssault") then
				if use.card:isVirtualCard() and (use.card:subcardsLength() ~= 1) then return false end
				if sgs.Sanguosha:getEngineCard(use.card:getEffectiveId())
						and sgs.Sanguosha:getEngineCard(use.card:getEffectiveId()):isKindOf("SavageAssault") then
					room:setCardFlag(use.card:getEffectiveId(), "real_SA")
				end
			end
		elseif player and player:isAlive() and player:hasSkill(self:objectName()) then
			local move = data:toMoveOneTime()
			if (move.card_ids:length() == 1) and move.from_places:contains(sgs.Player_PlaceTable) and (move.to_place == sgs.Player_DiscardPile)
					and (move.reason.m_reason == sgs.CardMoveReason_S_REASON_USE) then
				local card = sgs.Sanguosha:getCard(move.card_ids:first())
				if card:hasFlag("real_SA") and (player:objectName() ~= move.from:objectName()) then
					player:obtainCard(card)
					move.card_ids = sgs.IntList()
					data:setValue(move)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[技能名：倨傲
	相关武将：智·许攸
	描述：出牌阶段，你可以选择两张手牌背面向上移出游戏，指定一名角色，被指定的角色到下个回合开始阶段时，跳过摸牌阶段，得到你所移出游戏的两张牌。每阶段限一次
	引用：LuaJuao
	状态：1217验证通过
]]--
LuaJuaoCard = sgs.CreateSkillCard{
	name = "LuaJuaoCard" ,
	will_throw = false ,
	handling_method = sgs.Card_MethodNone ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:getMark("LuaJuao") == 0)
	end ,
	on_effect = function(self, effect)
		effect.to:addToPile("hautain", self, false)
		effect.to:addMark("LuaJuao")
	end
}
LuaJuaoVS = sgs.CreateViewAsSkill{
	name = "LuaJuao" ,
	n = 2 ,
	view_filter = function(self, selected, to_select)
		if (#selected >= 2) then return false end
		return not to_select:isEquipped()
	end ,
	view_as = function(self, cards)
		if #cards ~= 2 then return nil end
		local card = LuaJuaoCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		return card
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaJuaoCard")
	end
}
LuaJuao = sgs.CreateTriggerSkill{
	name = "LuaJuao" ,
	events = {sgs.EventPhaseStart} ,
	view_as_skill = LuaJuaoVS ,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			player:setMark("LuaJuao", 0)
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			for _, card_id in sgs.qlist(player:getPile("hautain")) do
				dummy:addSubcard(card_id)
			end
			player:obtainCard(dummy, false)
			player:skip(sgs.Player_Draw)
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (target:getMark("LuaJuao") > 0)
	end
}
--[[技能名：据守
	相关武将：风·曹仁
	描述：结束阶段开始时，你可以摸一张牌，然后将你的武将牌翻面。
	引用：LuaJushou
	状态：1217验证通过
]]--
LuaJushou = sgs.CreatePhaseChangeSkill{
	name = "LuaJushou",

	on_phasechange = function(self,target)
		local room = target:getRoom()
		if target:getPhase() == sgs.Player_Finish then
		if room:askForSkillInvoke(target,self:objectName()) then
			target:drawCards(1)
			target:turnOver()
			end
		end
	end 
}
--[[技能名：据守·旧
	相关武将：怀旧·曹仁
	描述：结束阶段开始时，你可以摸三张牌，然后将你的武将牌翻面。
	引用：LuaJushou
	状态：1217验证通过
]]--
LuaNosJushou = sgs.CreatePhaseChangeSkill{
	name = "LuaNosJushou",

	on_phasechange = function(self,target)
		local room = target:getRoom()
		if target:getPhase() == sgs.Player_Finish then
		if room:askForSkillInvoke(target,self:objectName()) then
			target:drawCards(3)
			target:turnOver()
			end
		end
	end 
}
--[[技能名：据守
	相关武将：翼·曹仁
	描述：回合结束阶段开始时，你可以摸2+X张牌（X为你已损失的体力值），然后将你的武将牌翻面。
	引用：LuaXNeoJushou
	状态：1217验证通过
]]--
LuaXNeoJushou = sgs.CreateTriggerSkill{
	name = "LuaXNeoJushou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			if room:askForSkillInvoke(player, self:objectName()) then
				local lost = player:getLostHp()
				player:drawCards(2 + lost)
				player:turnOver()
			end
		end
		return false
	end
}
--[[技能名：绝策
	相关武将：一将成名2013·李儒
	描述：你的回合内，一名体力值大于0的角色失去最后的手牌后，你可以对其造成1点伤害。
	引用：LuaJuece
	状态：1217验证通过
]]--
LuaJuece = sgs.CreateTriggerSkill{
	name = "LuaJuece" ,
	events = {sgs.CardsMoveOneTime},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if player:getPhase() ~= sgs.Player_NotActive and move.from and move.from_places:contains(sgs.Player_PlaceHand)and move.is_last_handcard then
		local from = room:findPlayer(move.from:getGeneralName())
		if from:getHp() > 0 and room:askForSkillInvoke(player, self:objectName(), data) then
			room:damage(sgs.DamageStruct(self:objectName(),player,from))
		end
	end
end
}
--[[技能名：绝汲
	相关武将：倚天·张儁乂
	描述：出牌阶段，你可以和一名角色拼点：若你赢，你获得对方的拼点牌，并可立即再次与其拼点，如此反复，直到你没赢或不愿意继续拼点为止。每阶段限一次。
	引用：LuaXJueji
	状态：1217验证通过
]]--
LuaXJuejiCard = sgs.CreateSkillCard{
	name = "LuaXJuejiCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return not to_select:isKongcheng()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local success = source:pindian(target, "LuaXJueji", self)
		local data = sgs.QVariant()
		data:setValue(target)
		while success do
			if target:isKongcheng() then
				break
			elseif source:isKongcheng() then
				break
			elseif source:askForSkillInvoke("LuaXJueji", data) then
				success = source:pindian(target, "LuaXJueji")
			else
				break
			end
		end
	end
}
LuaXJuejivs = sgs.CreateViewAsSkill{
	name = "LuaXJueji",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local juejiCard = LuaXJuejiCard:clone()
			juejiCard:addSubcard(cards[1])
			return juejiCard
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaXJuejiCard")
	end
}
LuaXJueji = sgs.CreateTriggerSkill{
	name = "LuaXJueji",	
	events = {sgs.Pindian},
	view_as_skill = LuaXJuejivs,
	on_trigger = function(self, event, player, data)
		local pindian = data:toPindian()
		if pindian.reason == "LuaXJueji" then
			if pindian.from_card:getNumber() > pindian.to_card:getNumber() then
				player:obtainCard(pindian.to_card)
			end
		end
		return false
	end,
	priority = -1
}
--[[技能名：绝境（锁定技）
	相关武将：神·赵云
	描述：摸牌阶段，你额外摸X张牌。你的手牌上限+2。（X为你已损失的体力值） 
	引用：LuaJuejing、LuaJuejingDraw
	状态：0405验证通过
]]--
LuaJuejing = sgs.CreateMaxCardsSkill{
	name = "LuaJuejing" ,
	extra_func = function(self, target)
		if target:hasSkill(self:objectName()) then
			return 2
		else
			return 0
		end
	end
}
LuaJuejingDraw = sgs.CreateDrawCardsSkill{
	name = "#LuaJuejing-draw" ,
	frequency = sgs.Skill_Compulsory ,
	draw_num_func = function(self, player, n)
		if player:isWounded() then
			player:getRoom():sendCompulsoryTriggerLog(player, "LuaJuejing")
		end
		return n + player:getLostHp()
	end
}
--[[技能名：绝境（锁定技）
	相关武将：测试·高达一号
	描述：摸牌阶段，你不摸牌。每当你的手牌数变化后，若你的手牌数不为4，你须将手牌补至或弃置至四张。
	引用：LuaXNosJuejing
	状态：1217验证通过
]]--
LuaXNosJuejing = sgs.CreateTriggerSkill{
	name = "LuaXNosJuejing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			local source = move.from
			local target = move.to
			if not source or source:objectName() ~= player:objectName() then
				if not target or target:objectName() ~= player:objectName() then
					return false
				end
			end
			if move.to_place ~= sgs.Player_PlaceHand then
				if not move.from_places:contains(sgs.Player_PlaceHand) then
					return false
				end
			end
			if player:getPhase() == sgs.Player_Discard then
				return false
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			local nextphase = change.to
			if nextphase == sgs.Player_Draw then
				player:skip(nextphase)
				return false
			elseif nextphase ~= sgs.Player_Finish then
				return false
			end
		end
		local count = player:getHandcardNum()
		if count == 4 then
			return false
		elseif count < 4 then
			player:drawCards(4 - count)
		elseif count > 4 then
			local room = player:getRoom()
			room:askForDiscard(player, self:objectName(), count - 4, count - 4)
		end
		return false
	end
}
--[[技能名：绝情（锁定技）
	相关武将：一将成名·张春华、怀旧·张春华
	描述：你即将造成的伤害均视为失去体力。
	引用：LuaJueqing
	状态：1217验证通过
]]--
LuaJueqing = sgs.CreateTriggerSkill{
	name = "LuaJueqing",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Predamage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		room:loseHp(damage.to, damage.damage)
		return true
	end,
}
--[[技能名：军威
	相关武将：☆SP·甘宁
	描述：结束阶段开始时，你可以将三张“锦”置入弃牌堆并选择一名角色，令该角色选择一项：1.展示一张【闪】并将该【闪】交给由你选择的一名角色；2.失去1点体力，然后你将其装备区的一张牌移出游戏，该角色的下个回合结束后，将这张装备牌移回其装备区。
	引用：LuaJunwei,LuaJunweiGot
	状态：1217验证通过(需与技能“银铃”配合使用)
]]--
LuaJunwei = sgs.CreateTriggerSkill{
	name = "LuaJunwei",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, ganning, data)
		local room = ganning:getRoom()
		if ganning:getPhase() == sgs.Player_Finish and ganning:getPile("brocade"):length() >= 3 then
			local target = room:askForPlayerChosen(ganning,room:getAllPlayers(),self:objectName(),"junwei-invoke",true,true)
			if not target then return false end
			local brocade = ganning:getPile("brocade")
			local to_throw = sgs.IntList()
			for i = 0,2,1 do
				local card_id = 0
				room:fillAG(brocade,ganning)
				if brocade:length() == 3 - i then
					card_id = brocade:first()
				else
					card_id = room:askForAG(ganning,brocade,false,self:objectName())
				end
				room:clearAG(ganning)
				brocade:removeOne(card_id)
				to_throw:append(card_id)
			end
			local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
			for _,id in sgs.qlist(to_throw) do
				slash:addSubcard(id)
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE,"",self:objectName(),"")
			room:throwCard(slash,reason,nil)
			slash:deleteLater()
			local card = room:askForCard(target,"Jink","@junwei-show",data,sgs.Card_MethodNone)
			if card then
				room:showCard(target,card:getEffectiveId())
				local receiver = room:askForPlayerChosen(ganning,room:getAllPlayers(),"junweigive","@junwei-give")
				if receiver:objectName() ~= target:objectName() then
					receiver:obtainCard(card)
				end
			else
				room:loseHp(target,1)
				if not target:isAlive() then return false end
				if target:hasEquip() then
					local card_id = room:askForCardChosen(ganning,target,"e",self:objectName())
					target:addToPile("junwei_equip",card_id)
					if target:objectName() == ganning:objectName() then
						room:setPlayerMark(target,tostring(card_id),1)
					end
				end
			end
		end
		return false
	end
}
LuaJunweiGot = sgs.CreateTriggerSkill{
	name = "#LuaJunweiGot",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target ~= nil
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive or player:getPile("junwei_equip"):length() == 0 then return false end
		for _,card_id in sgs.qlist(player:getPile("junwei_equip")) do
			if player:getMark(tostring(card_id)) > 0 then
				room:setPlayerMark(player,tostring(card_id),0)
				continue
			end
			local card = sgs.Sanguosha:getCard(card_id)
			local equip_index = -1
			local equip = card:getRealCard():toEquipCard()
			equip_index = equip:location()
			local exchangeMove = sgs.CardsMoveList()
			local move1 = sgs.CardsMoveStruct(card_id,player,sgs.Player_PlaceEquip,
				sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT,player:objectName()))
			exchangeMove:append(move1)
			if player:getEquip(equip_index) ~= nil then
				local move2 = sgs.CardsMoveStruct(player:getEquip(equip_index):getId(),nil,sgs.Player_DiscardPile,
					sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_CHANGE_EQUIP,player:objectName()))
				exchangeMove:append(move2)
			end
			local log = sgs.LogMessage()
			log.type = "$JunweiGot"
			log.from = player
			log.card_str = tonumber(card_id)
			room:sendLog(log)
			room:moveCardsAtomic(exchangeMove,true)
		end
		return false
	end
}
--[[技能名：峻刑
	相关武将：一将成名2013·满宠
	描述：出牌阶段限一次，你可以弃置至少一张手牌并选择一名其他角色，该角色须弃置一张与你弃置的牌类型均不同的手牌，否则将其武将牌翻面并摸X张牌。（X为你弃置的牌的数量）
	引用：LuaJunxing
	状态：1217验证通过
]]--
LuaJunxingCard = sgs.CreateSkillCard{
	name = "LuaJunxing" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		if not target:isAlive() then return end
		local type_name = {"BasicCard", "TrickCard", "EquipCard"}
		local types = {"BasicCard", "TrickCard", "EquipCard"}
		for _, id in sgs.qlist(self:getSubcards()) do
			local c = sgs.Sanguosha:getCard(id)
			table.removeOne(types,type_name[c:getTypeId()])
			if #types == 0 then break end
		end
		if (not target:canDiscard(target, "h")) or #types == 0 then
			target:turnOver()
			target:drawCards(self:getSubcards():length(), "LuaJunxing")
		elseif not room:askForCard(target, table.concat(types, ",") .. "|.|.|hand", "@junxing-discard") then
			target:turnOver()
			target:drawCards(self:getSubcards():length(), "LuaJunxing")
		end
	end
}
LuaJunxing = sgs.CreateViewAsSkill{
	name = "LuaJunxing" ,
	n = 999 ,
	view_filter = function(self, selected, to_select)
		return (not to_select:isEquipped()) and (not sgs.Self:isJilei(to_select))
	end ,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local card = LuaJunxingCard:clone()
		for _, c in ipairs(cards) do
			card:addSubcard(c)
		end
		card:setSkillName(self:objectName())
		return card
	end ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "h") and (not player:hasUsed("#LuaJunxingCard"))
	end
}
	技能名：绝境（锁定技）
	相关武将：神·赵云
	描述：摸牌阶段，你摸牌的数量改为你已损失的体力值+2；你的手牌上限+2。
]]--
-----------
--[[K区]]--
-----------
--[[
	技能名：看破
	相关武将：火·诸葛亮
	描述：你可以将一张黑色手牌当【无懈可击】使用。
	引用：LuaKanpo
	状态：1217验证通过
]]--
LuaKanpo = sgs.CreateOneCardViewAsSkill{
	name = "LuaKanpo",
	filter_pattern = ".|black|.|hand",
	response_pattern = "nullification",
	view_as = function(self, first)
		local ncard = sgs.Sanguosha:cloneCard("nullification", first:getSuit(), first:getNumber())
		ncard:addSubcard(first)
		ncard:setSkillName(self:objectName())
		return ncard
	end,
	enabled_at_nullification = function(self, player)
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:isBlack() then return true end
		end
		return false
	end
}
--[[
	技能名：慷忾
	相关武将：SP·曹昂
	描述：每当一名距离1以内的角色成为【杀】的目标后，你可以摸一张牌，然后正面朝上交给该角色一张牌：若该牌为装备牌，该角色可以使用之。 
	引用：LuaKangkai
	状态：1217验证通过
]]--
LuaKangkai = sgs.CreateTriggerSkill{
	name = "LuaKangkai" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			for _,to in sgs.qlist(use.to) do
				if not player:isAlive() then break end
				if player:distanceTo(to) <= 1 and player:hasSkill(self:objectName()) then
					--player:setTag("LuaKangkaiSlash", data)
					local to_data = sgs.QVariant()
					to_data:setValue(to)
					local will_use = room:askForSkillInvoke(player, self:objectName(), to_data)
					--player:removeTag("LuaKangkaiSlash")
					if will_use  then
						player:drawCards(1)
						if not player:isNude() and player:objectName() ~= to:objectName() then
							local card = nil
							if player:getCardCount() > 1 then
								card = room:askForCard(player, "..!", "@kangkai-give:" .. to:objectName(), data, sgs.Card_MethodNone);
								if not card then
									card = player:getCards("he"):at(math.random(player:getCardCount()))
								end
							else
								card = player:getCards("he"):first()
							end
							to:obtainCard(card)
							if card:getTypeId() == sgs.Card_TypeEquip and room:getCardOwner(card:getEffectiveId()):objectName() == to:objectName() and not to:isLocked(card) then
								--local xdata = sgs.QVariant()
								--xdata:setValue(card)
								--to:setTag("LuaKangkaiSlash", data)
								--to:setTag("LuaKangkaiGivenCard", xdata)
								local will_use = room:askForSkillInvoke(to, "kangkai_use", sgs.QVariant("use"))
								--to:removeTag("LuaKangkaiSlash")
								--to:removeTag("LuaKangkaiGivenCard")
								if will_use then
									room:useCard(sgs.CardUseStruct(card, to, to))
								end							
							end
						end
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：克构（觉醒技）
	相关武将：倚天·陆抗
	描述：回合开始阶段开始时，若你是除主公外唯一的吴势力角色，你须减少1点体力上限并获得技能“连营”
	引用：LuaKegou
	状态：1217验证通过
]]--
LuaKegou = sgs.CreateTriggerSkill{
	name = "LuaKegou" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Wake ,
	on_trigger = function(self, event, player, data)
		for _, _player in sgs.qlist(player:getSiblings()) do
			if _player:isAlive() and (_player:getKingdom() == "wu")
					and (not _player:isLord()) and (_player:objectName() ~= player:objectName()) then
				return false
			end
		end
		player:setMark("LuaKegou", 1)
		local room = player:getRoom()
		player:gainMark("@waked")
		room:loseMaxHp(player)
		room:acquireSkill(player, "lianying")
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName())
				and (target:getPhase() == sgs.Player_Start)
				and (target:getMark("LuaKegou") == 0)
				and (target:getKingdom() == "wu")
				and (not target:isLord())
	end
}
--[[
	技能名：克己
	相关武将：标准·吕蒙、界限突破·吕蒙、☆SP·吕蒙
	描述：若你未于出牌阶段内使用或打出【杀】，你可以跳过弃牌阶段。 
	引用：LuaKeji
	状态：0405验证通过
]]--
LuaKeji = sgs.CreateTriggerSkill{
	name = "LuaKeji" ,
	frequency = sgs.Skill_Frequent ,
	global = true ,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseChanging} ,   
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseChanging then
			local can_trigger = true
			if player:hasFlag("LuaKejiSlashInPlayPhase") then
				can_trigger = false
				player:setFlags("-LuaKejiSlashInPlayPhase")
			end
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Discard and player:isAlive() and player:hasSkill(self:objectName()) then
				if can_trigger and player:askForSkillInvoke(self:objectName()) then
					player:skip(sgs.Player_Discard)
				end
			end
		else
			if player:getPhase() == sgs.Player_Play then
				local card = nil
				if event == sgs.PreCardUsed then
					card = data:toCardUse().card
				else
					card = data:toCardResponse().m_card			 
				end
				if card:isKindOf("Slash") then
					player:setFlags("LuaKejiSlashInPlayPhase")
				end
			end
		end
		return false
	end
}
--[[
	技能名：空城（锁定技）
	相关武将：标准·诸葛亮、测试·五星诸葛
	描述：若你没有手牌，你不能被选择为【杀】或【决斗】的目标。
	引用：LuaKongcheng
	状态：1217验证通过
]]--
LuaKongcheng = sgs.CreateProhibitSkill{
	name = "LuaKongcheng",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("Slash") or card:isKindOf("Duel")) and to:isKongcheng()
	end
}
--[[
	技能名：苦肉
	相关武将：界限突破·黄盖
	描述：出牌阶段限一次，你可以弃置一张牌：若如此做，你失去1点体力。 
	引用：LuaKurou
	状态：0405验证通过
]]--
LuaKurouCard = sgs.CreateSkillCard{
	name = "LuaKurouCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:loseHp(source)
	end
}
LuaKurou = sgs.CreateOneCardViewAsSkill{
	name = "LuaKurou",
	filter_pattern = ".!",
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaKurouCard")
	end, 
	view_as = function(self, originalCard) 
		local card = LuaKurouCard:clone()
		card:addSubcard(originalCard)
		card:setSkillName(self:objectName())
		return card
	end
}
--[[
	技能名：苦肉
	相关武将：标准·黄盖、SP·台版黄盖
	描述：出牌阶段，你可以失去1点体力：若如此做，你摸两张牌。
	引用：LuaNosKurou
	状态：0405验证通过
]]--
LuaNosKurouCard = sgs.CreateSkillCard{
	name = "LuaNosKurouCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:loseHp(source)
		if source:isAlive() then
			room:drawCards(source, 2, "noskurou")
		end
	end
}
LuaNosKurou = sgs.CreateZeroCardViewAsSkill{
	name = "LuaNosKurou",
	view_as = function()
		return LuaNosKurouCard:clone()
	end
}
--[[
	技能名：狂暴（锁定技）
	相关武将：神·吕布
	描述：游戏开始时，你获得两枚“暴怒”标记。每当你造成或受到1点伤害后，你获得一枚“暴怒”标记。 
	引用：LuaKuangbao
	状态：0405验证通过
]]--
LuaKuangbao = sgs.CreateTriggerSkill{
	name = "LuaKuangbao" ,
	events = {sgs.GameStart, sgs.Damage, sgs.Damaged} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			player:gainMark("@wrath", 2)
			room:notifySkillInvoked(player, self:objectName())
		else
			local damage = data:toDamage()
			player:gainMark("@wrath", damage.damage)
			room:notifySkillInvoked(player, self:objectName())
		end
	end
}
--[[
	技能名：狂风
	相关武将：神·诸葛亮
	描述：结束阶段开始时，你可以将一张“星”置入弃牌堆并选择一名角色，若如此做，你的下回合开始前，每当其受到的火焰伤害结算开始时，此伤害+1。
	引用：LuaKuangfeng
	状态：0405验证通过(需与本手册的技能“七星”配合使用)
	备注：医治永恒&水饺wch哥：源码的狂风和大雾的技能询问与标记的清除分别位于七星的QixingAsk和QixingClear中，此技能独立出来了。需与本手册的技能“七星”配合使用
]]--
LuaKuangfengCard = sgs.CreateSkillCard{
	name = "LuaKuangfengCard",
	handling_method = sgs.Card_MethodNone,
	will_throw = false,
	filter = function(self, targets, to_select, player)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "LuaKuangfeng", "")
		effect.to:getRoom():throwCard(self, reason, nil)
		effect.from:setTag("LuaQixing_user", sgs.QVariant(true))
		effect.to:gainMark("@gale")
	end,
}
LuaKuangfengVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaKuangfeng", 
	response_pattern = "@@LuaKuangfeng",
	filter_pattern = ".|.|.|stars",
	expand_pile = "stars",
	view_as = function(self, card)
		local kf = LuaKuangfengCard:clone()
		kf:addSubcard(card)
		return kf
	end,
}
LuaKuangfeng = sgs.CreateTriggerSkill{
	name = "LuaKuangfeng",
	events = {sgs.DamageForseen},
	view_as_skill = LuaKuangfengVS,
	can_trigger = function(self, player)
		return player ~= nil and player:getMark("@gale") > 0
	end,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.nature == sgs.DamageStruct_Fire then
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
		return false
	end,
}
--[[
	技能名：狂斧
	相关武将：国战·潘凤
	描述：每当你使用的【杀】对一名角色造成一次伤害后，你可以将其装备区里的一张牌弃置或置入你的装备区。
	引用：LuaKuangfu
	状态：1217验证通过
]]--
LuaKuangfu = sgs.CreateTriggerSkill{
	name = "LuaKuangfu" ,
	events = {sgs.Damage} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local target = damage.to
		if damage.card and damage.card:isKindOf("Slash") and target:hasEquip() and (not damage.chain) and (not damage.transfer) then
			local equiplist = {}
			for i = 0, 3, 1 do
				if not target:getEquip(i) then continue end
				if player:canDiscard(target, target:getEquip(i):getEffectiveId()) or (player:getEquip(i) == nil) then
					table.insert(equiplist,tostring(i))
				end
			end
			if #equiplist == nil then return false end
			if not player:askForSkillInvoke(self:objectName(), data) then return false end
			local _data = sgs.QVariant()
			_data:setValue(target)
			local room = player:getRoom()
			local equip_index = tonumber(room:askForChoice(player, "LuaKuangfu_equip", table.concat(equiplist, "+"), _data))
			local card = target:getEquip(equip_index)
			local card_id = card:getEffectiveId()
			local choicelist = {}
			if player:canDiscard(target, card_id) then
				table.insert(choicelist, "throw")
			end
			if (equip_index > -1) and (player:getEquip(equip_index) == nil) then
				table.insert(choicelist, "move")
			end
			local choice = room:askForChoice(player, "LuaKuangfu", table.concat(choicelist, "+"))
			if choice == "move" then
				room:moveCardTo(card, player, sgs.Player_PlaceEquip)
			else
				room:throwCard(card, target, player)
			end
		end
		return false
	end
}
--[[
	技能名：狂骨（锁定技）
	相关武将：风·魏延
	描述：每当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。
	引用：LuaKuanggu
	状态：1217验证通过
]]--
LuaKuanggu = sgs.CreateTriggerSkill{
	name = "LuaKuanggu",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.Damage, sgs.PreDamageDone},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if (event == sgs.PreDamageDone) and damage.from and damage.from:hasSkill(self:objectName()) and damage.from:isAlive() then
			local weiyan = damage.from
			weiyan:setTag("invokeLuaKuanggu", sgs.QVariant((weiyan:distanceTo(damage.to) <= 1)))
		elseif (event == sgs.Damage) and player:hasSkill(self:objectName()) and player:isAlive() then
			local invoke = player:getTag("invokeLuaKuanggu"):toBool()
			player:setTag("invokeLuaKuanggu", sgs.QVariant(false))
			if invoke and player:isWounded() then
				local recover = sgs.RecoverStruct()
				recover.who = player
				recover.recover = damage.damage
				room:recover(player, recover)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：狂骨·1V1
	相关武将：1v1·魏延
	描述：每当你造成伤害后，你可以进行判定：若结果为黑色，你回复1点体力。
	引用：LuaKOFKuanggu
	状态：1217验证通过
]]--
LuaKOFKuanggu = sgs.CreateTriggerSkill{
	name = "LuaKOFKuanggu",
	events = {sgs.Damage},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player,self:objectName(),data) then
		local judge = sgs.JudgeStruct()
			judge.pattern = ".|black"
			judge.who = player
			judge.reason = self:objectName()
			room:judge(judge)
		if judge:isGood() and player:isWounded() then
			local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			end
		end
	end
}
--[[
	技能名：溃围
	相关武将：☆SP·曹仁
	描述：结束阶段开始时，你可以摸X+2张牌，然后将你的武将牌翻面，且你的下个摸牌阶段开始时，你弃置X张牌。（X为当前场上武器牌的数量）
	引用：LuaKuiwei
	状态：1217验证通过
]]--
getWeaponCountKuiwei = function(caoren)
	local n = 0
	for _, p in sgs.qlist(caoren:getRoom():getAlivePlayers()) do
		if p:getWeapon() then n = n + 1 end
	end
	return n
end
LuaKuiwei = sgs.CreateTriggerSkill{
	name = "LuaKuiwei" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			if not player:hasSkill(self:objectName()) then return false end
			if not player:askForSkillInvoke(self:objectName()) then return false end
			local n = getWeaponCountKuiwei(player)
			player:drawCards(n + 2)
			player:turnOver()
			if player:getMark("@kuiwei") == 0 then
				player:getRoom():addPlayerMark(player, "@kuiwei")
			end
		elseif player:getPhase() == sgs.Player_Draw then
			if player:getMark("@kuiwei") == 0 then return false end
			local room = player:getRoom()
			room:removePlayerMark(player, "@kuiwei")
			local n = getWeaponCountKuiwei(player)
			if n > 0 then
				room:askForDiscard(player, self:objectName(), n, n, false, true)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:isAlive() and (target:hasSkill(self:objectName()) or (target:getMark("@kuiwei") > 0))
	end
}
	技能名：狂骨（锁定技）
	相关武将：风·魏延
	描述：每当你对距离1以内的一名角色造成1点伤害后，你回复1点体力。
]]--
-----------
--[[L区]]--
-----------
--[[
	技能名：狼顾
	相关武将：贴纸·司马昭
	描述：每当你受到1点伤害后，你可以进行一次判定，然后你可以打出一张手牌代替此判定牌：若如此做，你观看伤害来源的所有手牌，并弃置其中任意数量的与判定牌花色相同的牌。
	引用：LuaXLanggu
	状态：1217验证通过
]]--
LuaXLanggu = sgs.CreateTriggerSkill{
	name = "LuaXLanggu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged, sgs.AskForRetrial},
	on_trigger = function(self, event, player, data)
		if event == sgs.Damaged then
			local damage = data:toDamage()
			if not damage.from or damage.from:isKongcheng() then
				return
			end
			local target = damage.from
			local num = damage.damage
			local n = 0
			while n < num do
				if player:askForSkillInvoke(self:objectName(), data) then
					local room = player:getRoom()
					local judge = sgs.JudgeStruct()
					judge.reason = self:objectName()
					judge.pattern = "."
					judge.who = player
					room:judge(judge)
					local ids = target:handCards()
					room:fillAG(ids, player)
					local mark = judge.card:getSuitString()
					room:setPlayerFlag(player, mark)
					while not target:isKongcheng() do
						local card_id = room:askForAG(player, ids, true, "LuaXLanggu")
						if card_id == -1 then
							room:clearAG(player)
							break
						end
						local card = sgs.Sanguosha:getCard(card_id)
						if judge.card:getSuit() == card:getSuit() then
							room:throwCard(card_id, target)
						end
					end
					room:setPlayerFlag(player, "-" .. mark)
				else
					break
				end
				n = n + 1
			end
			return
		elseif event == sgs.AskForRetrial then
			local room = player:getRoom()
			local judge = data:toJudge()
			if judge.reason == self:objectName() then
				if judge.who:objectName() == player:objectName() then
					local card = room:askForCard(player, ".", "@LuaXLanggu", data, sgs.AskForRetrial)
					if card then
						room:retrial(card, player, judge, self:objectName(), false)
					end
				end
			end
			return false
		end
	end,
}
--[[
	技能名：乐学
	相关武将：倚天·姜伯约
	描述：出牌阶段，可令一名有手牌的其他角色展示一张手牌，若为基本牌或非延时锦囊，则你可将与该牌同花色的牌当作该牌使用或打出直到回合结束；若为其他牌，则立刻被你获得。每阶段限一次
	引用：LuaXLexue
	状态：1217验证通过
]]--
LuaXLexueCard = sgs.CreateSkillCard{
	name = "LuaXLexueCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:objectName() ~= sgs.Self:objectName() then
				return not to_select:isKongcheng()
			end
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = target:getRoom()
		local card = room:askForCardShow(target, source, "LuaXLexue")
		local card_id = card:getEffectiveId()
		room:showCard(target, card_id)
		local type_id = card:getTypeId()
		if type_id == sgs.Card_Basic or card:isNDTrick() then
			room:setPlayerMark(source, "lexue", card_id)
			room:setPlayerFlag(source, "lexue")
		else
			source:obtainCard(card)
			room:setPlayerFlag(source, "-lexue")
		end
	end
}
LuaXLexue = sgs.CreateViewAsSkill{
	name = "LuaXLexue",
	n = 1,
	view_filter = function(self, selected, to_select)
		if sgs.Self:hasUsed("#LuaXLexueCard") then
			if #selected == 0 then
				if sgs.Self:hasFlag("lexue") then
					local card_id = sgs.Self:getMark("lexue")
					local card = sgs.Sanguosha:getCard(card_id)
					return to_select:getSuit() == card:getSuit()
				end
			end
		end
		return false
	end,
	view_as = function(self, cards)
		if sgs.Self:hasUsed("#LuaXLexueCard") then
			if sgs.Self:hasFlag("lexue") then
				if #cards == 1 then
					local card_id = sgs.Self:getMark("lexue")
					local card = sgs.Sanguosha:getCard(card_id)
					local first = cards[1]
					local name = card:objectName()
					local suit = first:getSuit()
					local point = first:getNumber()
					local new_card = sgs.Sanguosha:cloneCard(name, suit, point)
					new_card:addSubcard(first)
					new_card:setSkillName(self:objectName())
					return new_card
				end
			end
		else
			return LuaXLexueCard:clone()
		end
	end,
	enabled_at_play = function(self, player)
		if player:hasUsed("#LuaXLexueCard") then
			if player:hasFlag("lexue") then
				local card_id = player:getMark("lexue")
				local card = sgs.Sanguosha:getCard(card_id)
				return card:isAvailable(player)
			end
			return false
		end
		return true
	end,
	enabled_at_response = function(self, player, pattern)
		if player:getPhase() ~= sgs.Player_NotActive then
			if player:hasFlag("lexue") then
				if player:hasUsed("#LuaXLexueCard") then
					local card_id = player:getMark("lexue")
					local card = sgs.Sanguosha:getCard(card_id)
					return string.find(pattern, card:objectName())
				end
			end
		end
		return false
	end,
	enabled_at_nullification = function(self, player)
		if player:hasFlag("lexue") then
			local card_id = player:getMark("lexue")
			local card = sgs.Sanguosha:getCard(card_id)
			if card:objectName() == "nullification" then
				local cards = player:getHandcards()
				for _,c in sgs.qlist(cards) do
					if c:objectName() == "nullification" or c:getSuit() == card:getSuit() then
						return true
					end
				end
				cards = player:getEquips()
				for _,c in sgs.qlist(cards) do
					if c:objectName() == "nullification" or c:getSuit() == card:getSuit() then
						return true
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：雷击
	相关武将：风·张角
	描述：每当你使用【闪】选择目标后或打出【闪】，你可以令一名角色进行一次判定：若判定结果为黑色，你对该角色造成1点雷电伤害，然后你回复1点体力。 
	引用：LuaLeiji
	状态：1217验证通过
]]--
LuaLeiji = sgs.CreateTriggerSkill{
	name = "LuaLeiji",
	events = {sgs.CardResponded},

	on_trigger = function(self, event, player, data)
		local card_star = data:toCardResponse().m_card
		local room = player:getRoom()
		if card_star:isKindOf("Jink") then
			local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "LuaLeiji-invoke", true, true)
			if not target then return false end
			local judge = sgs.JudgeStruct()
				judge.pattern = ".|black"
				judge.good = false
				judge.negative = true
				judge.reason = self:objectName()
				judge.who = target
				room:judge(judge)
			if judge:isBad() then
				room:damage(sgs.DamageStruct(self:objectName(), player, target, 1, sgs.DamageStruct_Thunder))
			if player:isAlive() then
				local recover = sgs.RecoverStruct()
					recover.who = player
					room:recover(player, recover)
				end
			end
		end
	end
}
--[[
	技能名：雷击
	相关武将：怀旧·张角
	描述：当你使用或打出一张【闪】（若为使用则在选择目标后），你可以令一名角色进行一次判定，若判定结果为黑桃，你对该角色造成2点雷电伤害。
	引用：LuaLeiji
	状态：1217验证通过
]]--
LuaLeiji = sgs.CreateTriggerSkill{
	name = "LuaLeiji" ,
	events = {sgs.CardResponded} ,
	on_trigger = function(self, event, player, data)
		local card_star = data:toCardResponse().m_card
		local room = player:getRoom()
		if card_star:isKindOf("Jink") then
			local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "LuaLeiji-invoke", true, true)
			if target then
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|spade"
				judge.good = false
				judge.negative = true
				judge.reason = self:objectName()
				judge.who = target
				room:judge(judge)
				if judge:isBad() then
					room:damage(sgs.DamageStruct(self:objectName(), player, target, 2, sgs.DamageStruct_Thunder))
				end
			end
		end
		return false
	end
}
--[[
	技能名：离魂
	相关武将：☆SP·貂蝉
	描述：出牌阶段限一次，你可以弃置一张牌将武将牌翻面，然后获得一名男性角色的所有手牌，且出牌阶段结束时，你交给该角色X张牌。（X为该角色的体力值）
	引用：LuaLihun
	状态：1217验证通过
]]--
LuaLihunCard = sgs.CreateSkillCard{
	name = "LuaLihunCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and to_select:isMale() and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		effect.from:turnOver()
		local dummy_card = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, cd in sgs.qlist(effect.to:getHandcards()) do
			dummy_card:addSubcard(cd)
		end
		if not effect.to:isKongcheng() then
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, effect.from:objectName(),effect.to:objectName(), "LuaLihun", nil)
			room:moveCardTo(dummy_card, effect.to, effect.from, sgs.Player_PlaceHand, reason, false)
		end
		effect.to:setFlags("LuaLihunTarget")
	end
}
LuaLihunVS = sgs.CreateViewAsSkill{
	name = "LuaLihun" ,
	n = 1,
	view_filter = function(self, cards, to_select)
		if #cards == 0 then
			return not sgs.Self:isJilei(to_select)
		else
			return false
		end
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaLihunCard:clone()
		card:addSubcard(cards[1])
		return card
	end ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and (not player:hasUsed("#LuaLihunCard"))
	end
}
LuaLihun = sgs.CreateTriggerSkill{
	name = "LuaLihun" ,
	events = {sgs.EventPhaseStart, sgs.EventPhaseEnd} ,
	view_as_skill = LuaLihunVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseEnd) and (player:getPhase() == sgs.Player_Play) then
			local target
			for _, other in sgs.qlist(room:getOtherPlayers(player)) do
				if other:hasFlag("LuaLihunTarget") then
					other:setFlags("-LuaLihunTarget")
					target = other
					break
				end
			end
			if (not target) or (target:getHp() < 1) or player:isNude() then return false end
			local to_back = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			if player:getCardCount(true) <= target:getHp() then
				if not player:isKongcheng() then to_goback = player:wholeHandCards() end
				for i = 0, 3, 1 do
					if player:getEquip(i) then to_goback:addSubcard(player:getEquip(i):getEffectiveId()) end
				end
			else
				to_goback = room:askForExchange(player, self:objectName(), target:getHp(), true, "LuaLihunGoBack")
			end
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, player:objectName(), target:objectName(), self:objectName(), nil)
			room:moveCardTo(to_goback, player, target, sgs.Player_PlaceHand, reason)
		elseif (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_NotActive) then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:hasFlag("LuaLihunTarget") then
					p:setFlags("-LuaLihunTarget")
				end
			end
		end
	end ,
	can_trigger = function(self, target)
		return target and target:hasUsed("#LuaLihunCard")
	end
}

--[[
	技能名：离间
	相关武将：标准·貂蝉
	描述：出牌阶段限一次，你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】。 
	引用：LuaLijian
	状态：0405验证通过
]]--
LuaLijianCard = sgs.CreateSkillCard{
	name = "LuaLijianCard" ,
	filter = function(self, targets, to_select)
		if not to_select:isMale() then
			return false
		end
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:deleteLater()
		if #targets == 0 and to_select:isProhibited(to_select, duel) then
			return false
		elseif #targets == 1 and to_select:isCardLimited(duel, sgs.Card_MethodUse) then 
			return false 
		end
		return #targets < 2 and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	feasible = function(self, targets)
		return #targets == 2
	end ,
	about_to_use = function(self, room, card_use)
		local use = card_use
		local data = sgs.QVariant()
		data:setValue(card_use)
		local thread = room:getThread()
		thread:trigger(sgs.PreCardUsed, room, card_use.from, data)
		use = data:toCardUse()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, card_use.from:objectName(), "", "LuaLijian", "")
		room:moveCardTo(self, card_use.from, nil, sgs.Player_DiscardPile, reason, true)
		thread:trigger(sgs.CardUsed, room, card_use.from, data)
		thread:trigger(sgs.CardFinished, room, card_use.from, data)
	end ,
	on_use = function(self, room, source, targets)
		local to = targets[1]
		local from = targets[2]
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:toTrick():setCancelable(true)-- 这里true改为false 就是旧版技能
		duel:setSkillName(self:objectName())
		if not from:isCardLimited(duel, sgs.Card_MethodUse) and not from:isProhibited(to, duel) then
			room:useCard(sgs.CardUseStruct(duel, from, to))
		else
			duel:deleteLater()
		end
	end
}
LuaLijian = sgs.CreateOneCardViewAsSkill{
	name = "LuaLijian" ,
	filter_pattern = ".!" ,
	view_as = function(self, card)
		local lijian_card = LuaLijianCard:clone()
		lijian_card:addSubcard(card:getId())
		return lijian_card
	end ,
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and not player:hasUsed("#LuaLijianCard") and player:getAliveSiblings():length() > 1
	end
}
--[[
	技能名：离间
	相关武将：怀旧-标准·貂蝉-旧、SP·貂蝉、SP·台版貂蝉
	描述：出牌阶段限一次，你可以弃置一张牌并选择两名男性角色：若如此做，视为其中一名角色对另一名角色使用一张【决斗】，此【决斗】不能被【无懈可击】响应。 
	引用：LuaLijian
	状态：0405验证通过
	注：仅需将新版离间的 "duel:toTrick():setCancelable(true)" 那一行改掉即可
]]--
--[[
	技能名：离迁（锁定技）
	相关武将：倚天·夏侯涓
	描述：当你处于连理状态时，势力与连理对象的势力相同；当你处于未连理状态时，势力为魏
	引用:LuaLiqian
	状态：1217验证通过(技能的实现被耦合在本手册的技能“连理”中，这里只是空壳，做一个技能按钮而已)
]]--
LuaLiqian = sgs.CreateTriggerSkill{
	name = "LuaLiqian",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()	end
}
--[[
	技能名：礼让
	相关武将：国战·孔融
	描述：当你的牌因弃置而置入弃牌堆时，你可以将其中任意数量的牌以任意分配方式交给任意数量的其他角色。
	引用：LuaXLirang
	状态：1217验证通过
]]--
LuaXLirang = sgs.CreateTriggerSkill{
	name = "LuaXLirang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local source = move.from
		if source and source:objectName() == player:objectName() then
			if move.to_place == sgs.Player_DiscardPile then
				local reason = move.reason
				local basic = bit32.band(reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
				if basic == sgs.CardMoveReason_S_REASON_DISCARD then
					local room = player:getRoom()
					local i = 0
					local lirang_card = sgs.IntList()
					for _,card_id in sgs.qlist(move.card_ids) do
						if room:getCardOwner(card_id):objectName() == move.from:objectName() then
							local place = move.from_places:at(i)
							if place == sgs.Player_PlaceHand or place == sgs.Player_PlaceEquip then
								lirang_card:append(card_id)
							end
						end
						i = i + 1
					end
					if not lirang_card:isEmpty() then
						if player:askForSkillInvoke(self:objectName(), data) then
							local original_lirang = lirang_card
							while room:askForYiji(player, lirang_card, self:objectName(), false, true, true, -1, sgs.SPlayerList(), move.reason, "@lirang-distribute", true) do
								if player:isDead() then return false end
							end
							local ids = move.card_ids
							i = 0
							for _,card_id in sgs.qlist(ids) do
								if (original_lirang:contains(card_id) and not lirang_card:contains(card_id)) then
									move.card_ids:removeOne(card_id)
									move.from_places:removeAt(i)
								end
								i = i+1
							end
							data:setValue(move)
						end
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：疠火
	相关武将：二将成名·程普
	描述：你可以将一张普通【杀】当火【杀】使用，若以此法使用的【杀】造成了伤害，在此【杀】结算后你失去1点体力；你使用火【杀】时，可以额外选择一个目标。
	引用：LuaLihuo、LuaLihuoTarget
	状态：1217验证通过
]]--
LuaLihuoVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaLihuo" ,
	filter_pattern = "%slash" ,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE and pattern == "slash"
	end ,
	view_as = function(self, card)
		local acard = sgs.Sanguosha:cloneCard("fire_slash", card:getSuit(), card:getNumber())
		acard:addSubcard(card)
		acard:setSkillName(self:objectName())
		return acard
	end ,
}
invokeLihuo = {}
LuaLihuo = sgs.CreateTriggerSkill{
	name = "LuaLihuo" ,
	events = {sgs.PreDamageDone, sgs.CardFinished} ,
	view_as_skill = LuaLihuoVS ,
	can_trigger = function(self, target)
		return target
	end ,
	on_trigger = function(self, event, player, data)
		if event == sgs.PreDamageDone then
			local damage = data:toDamage()
			if damage.card and damage.card:isKindOf("Slash") and (damage.card:getSkillName() == self:objectName()) then
				table.insert(invokeLihuo, damage.card)
			end
		elseif (player and player:isAlive() and player:hasSkill(self:objectName())) and (not player:hasFlag("Global_ProcessBroken")) then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") then return false end
			local can_invoke = false
			for _, c in ipairs(invokeLihuo) do
				if c:getEffectiveId() == use.card:getEffectiveId() then
					can_invoke = true
					table.removeOne(invokeLihuo,c)
					break
				end
			end
			if not can_invoke then return false end
			player:getRoom():loseHp(player)
		end
		return false
	end
}
LuaLihuoTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaLihuo-target" ,
	extra_target_func = function(self, from, card)
		if from:hasSkill("LuaLihuo") and card:isKindOf("FireSlash") then
			return 1
		end
		return 0
	end ,
}
--[[
	技能名：连环
	相关武将：火·庞统
	描述：你可以将一张梅花手牌当【铁索连环】使用或重铸。
	引用：LuaLianhuan
	状态：1217验证通过
]]--
LuaLianhuan = sgs.CreateViewAsSkill{
	name = "LuaLianhuan",
	n = 1,
	view_filter = function(self, selected, to_select)
		return (not to_select:isEquipped()) and (to_select:getSuit() == sgs.Card_Club)
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local chain = sgs.Sanguosha:cloneCard("iron_chain", cards[1]:getSuit(), cards[1]:getNumber())
			chain:addSubcard(cards[1])
			chain:setSkillName(self:objectName())
			return chain
		end
	end
}
--[[
	技能名：连理
	相关武将：倚天·夏侯涓
	描述：回合开始阶段开始时，你可以选择一名男性角色，你和其进入连理状态直到你的下回合开始：该角色可以帮你出闪，你可以帮其出杀
	引用：LuaLianStart,LuaLianliSlash,LuaLianliJink,LuaLianliClear,LuaLianli,LuaLianlivs(技能暗将，或加入技能库)
	状态：1217验证通过
]]--
LuaLianliStart = sgs.CreateTriggerSkill{
	name = "#LuaLianliStart",
	events = {sgs.GameStart},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local players = room:getOtherPlayers(player)
		for _,p in sgs.qlist(players) do
			if p:isMale() then
				room:attachSkillToPlayer(p,"LuaLianliSlash")
			end 
		end
		return false
	end
}
LuaLianliSlashCard = sgs.CreateSkillCard{
	name = "LuaLianliSlashCard",
	filter = function(self,targets,to_select)
		local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
		slash:deleteLater()
		local qtargets = sgs.PlayerList()
		for _,p in ipairs(targets) do
			qtargets:append(p)
		end
		return slash:targetFilter(qtargets,to_select,sgs.Self)
	end,
	on_validate = function(self,carduse)
		carduse.m_isOwnerUse = false
		local zhangfei = carduse.from
		local room = zhangfei:getRoom()
		local xiahoujuan = room:findPlayerBySkillName("LuaLianli")
		if xiahoujuan then
			local slash = room:askForCard(xiahoujuan,"slash","@lianli-slash",sgs.QVariant(),sgs.Card_MethodResponse,nil,false,"",true)
			if slash then
				return slash
			end
		end
		room:setPlayerFlag(zhangfei,"Global_LianliFailed")
		return nil
	end
}
LuaLianliSlashvs = sgs.CreateViewAsSkill{
	name = "LuaLianliSlash",
	n = 0,
	attached_lord_skill = true,
	enabled_at_play = function(self,player)
		return player:getMark("@tied") > 0 and sgs.Slash_IsAvailable(player) and not player:hasFlag("Global_LianliFailed")
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern == "slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE 
		and not player:hasFlag("Global_LianliFailed")
	end,
	view_as = function(self,cards)
		return LuaLianliSlashCard:clone()
	end
}
LuaLianliSlash = sgs.CreateTriggerSkill{
	name = "#LuaLianliSlash",
	events = {sgs.CardAsked},
	can_trigger = function(self,target)
		return target ~= nil and target:getMark("@tied") > 0 and not target:hasSkill("LuaLianli")
	end,
	on_trigger = function(self,event,player,data)
		local pattern = data:toStringList()[1]
		if pattern ~= "slash" then return false end
		if not player:askForSkillInvoke("LuaLianli",data) then return false end
		local room = player:getRoom()
		local xiahoujuan = room:findPlayerBySkillName("LuaLianli")
		if xiahoujuan then
			local slash = room:askForCard(xiahoujuan,"slash","@lianli-slash",data,sgs.Card_MethodResponse,nil,false,"",true)
			if slash then
				room:provide(slash)
				return true
			end
		end
		return false
	end
}
LuaLianliJink = sgs.CreateTriggerSkill{
	name = "#LuaLianliJink",
	events = {sgs.CardAsked},
	can_trigger = function(self,target)
		return target ~= nil and target:getMark("@tied") > 0 and target:isAlive() and target:hasSkill(self:objectName())
	end,
	on_trigger = function(self,event,xiahoujuan,data)
		local pattern = data:toStringList()[1]
		if pattern ~= "jink" then return false end
		if not xiahoujuan:askForSkillInvoke("LuaLianli",data) then return false end
		local room = xiahoujuan:getRoom()
		local players = room:getOtherPlayers(xiahoujuan)
		for _ ,player in sgs.qlist(players) do
			if player:getMark("@tied") > 0 then
				local zhangfei = player
				local jink = room:askForCard(zhangfei,"jink","@lianli-jink",data,sgs.Card_MethodResponse,nil,false,"",true)
				if jink then
					room:provide(jink)
					return true
				end
				break
			end
		end
		return false
	end
}
LuaLianli = sgs.CreateTriggerSkill{
	name = "LuaLianli",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self,event,target,data)
		if target:getPhase() == sgs.Player_Start then
			local room = target:getRoom()
			local males = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:isMale() then
					males:append(p)
				end
			end
			local zhangfei = room:askForPlayerChosen(target,males,self:objectName(),"@lianli-card",true,true)
			if males:isEmpty() or zhangfei == nil then
				if target:hasSkill("LuaLiqian") and target:getKingdom() ~= "wei" then
					room:setPlayerProperty(target,"kingdom",sgs.QVariant("wei"))
				end
				local players = room:getAllPlayers()
				for _,p in sgs.qlist(players) do
					if p:getMark("@tied") > 0 then
						p:loseMark("@tied")
					end
				end
				return false
			end
			local log = sgs.LogMessage()
			log.type = "#LianliConnection"
			log.from = target
			log.to:append(zhangfei)
			room:sendLog(log)
			if target:getMark("@tied") == 0 then
				target:gainMark("@tied")
			end
			if zhangfei:getMark("@tied") == 0 then
				for _,p in sgs.qlist(room:getOtherPlayers(target)) do
					if p:getMark("@tied") > 0 then
						p:loseMark("@tied")
						break
					end
				end
				zhangfei:gainMark("@tied")
			end
			if target:hasSkill("LuaLiqian") and target:getKingdom() ~= zhangfei:getKingdom() then
				room:setPlayerProperty(target,"kingdom",sgs.QVariant(zhangfei:getKingdom()))
			end
		end
		return false
	end
}
LuaLianliClear = sgs.CreateTriggerSkill{
	name = "#LuaLianliClear",
	events = {sgs.Death},
	can_trigger = function(self,target)
		return target ~= nil and target:hasSkill(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		for _,p in sgs.qlist(room:getAlivePlayers()) do
			if player:getMark("@tied") > 0 then
				player:loseMark("@tied")
			end
		end
		return false
	end
}
--[[
	技能名：连破
	相关武将：神·司马懿
	描述：每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以进行一个额外的回合。   
	引用：LuaLianpoCount、LuaLianpo
	状态：0405验证通过
]]--
LuaLianpoCount = sgs.CreateTriggerSkill{
	name = "#LuaLianpo-count" ,
	events = {sgs.Death, sgs.TurnStart} ,
	global = true ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
			local killer
			if death.damage then
				killer = death.damage.from
			else
				killer = nil
			end
			local current = room:getCurrent()
			if killer and current and (current:isAlive() or current:objectName() == death.who:objectName()) and current:getPhase() ~= sgs.Playr_NotActive then
				killer:addMark("LuaLianpo")
			end
		else
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				p:setMark("LuaLianpo", 0)
			end
		end
		return false
	end
}
LuaLianpo = sgs.CreatePhaseChangeSkill{
	name = "LuaLianpo" ,
	frequency = sgs.Skill_Frequent ,
	priority = 1 ,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_NotActive then
			local shensimayi = player:getRoom():findPlayerBySkillName(self:objectName())
			if not shensimayi or shensimayi:getMark("LuaLianpo") <= 0 or not shensimayi:askForSkillInvoke(self:objectName()) then return false end
			shensimayi:gainAnExtraTurn()
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：连营
	相关武将：界限突破·陆逊
	描述：每当你失去最后的手牌后，你可以令至多X名角色各摸一张牌。（X为你失去的手牌数） 
	引用：LuaLianying
	状态：0405验证通过
]]--

LuaLianyingCard = sgs.CreateSkillCard{
	name = "LuaLianyingCard",
	filter = function(self, targets, to_select, erzhang)
		return #targets < sgs.Self:getMark("lianying")
	end,
	on_effect = function(self, effect)
		effect.to:drawCards(1, "lianying")
	end
}
LuaLianyingVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaLianying",
	response_pattern = "@@LuaLianying",
	view_as = function()
		return LuaLianyingCard:clone()
	end
}
LuaLianying = sgs.CreateTriggerSkill{
	name = "LuaLianying",
	events = {sgs.CardsMoveOneTime},
	view_as_skill = LuaLianyingVS ,
	on_trigger = function(self, event, luxun, data)
		local room = luxun:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == luxun:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard  then
			luxun:setTag("LianyingMoveData", data)
			local count = 0
			for i = 0, move.from_places:length() - 1, 1 do
				if move.from_places:at(i) == sgs.Player_PlaceHand then
					count = count + 1
				end
			end
			room:setPlayerMark(luxun, "lianying", count)
			room:askForUseCard(luxun, "@@LuaLianying", "@lianying-card:::" .. tostring(count))
		end
		return false
	end
}
--[[
	技能名：连营
	相关武将：标准·陆逊、SP·台版陆逊、倚天·陆抗
	描述：每当你失去最后的手牌后，你可以摸一张牌。
	引用：LuaNosLianying
	状态：0405验证通过
]]--
LuaNosLianying = sgs.CreateTriggerSkill{
	name = "LuaNosLianying" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, luxun, data)
		local room = luxun:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == luxun:objectName() and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard then
			if room:askForSkillInvoke(luxun, self:objectName(), data) then
				luxun:drawCards(1, self:objectName())
			end
		end
		return false
	end
}
--[[
	技能名：烈弓
	相关武将：风·黄忠
	描述：当你在出牌阶段内使用【杀】指定一名角色为目标后，以下两种情况，你可以令其不可以使用【闪】对此【杀】进行响应：
		1.目标角色的手牌数大于或等于你的体力值。2.目标角色的手牌数小于或等于你的攻击范围。
	引用：LuaLiegong
	状态：1217验证通过
]]--
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaLiegong = sgs.CreateTriggerSkill{
	name = "LuaLiegong" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if (player:objectName() ~= use.from:objectName()) or (player:getPhase() ~= sgs.Player_Play) or (not use.card:isKindOf("Slash")) then return false end
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			local handcardnum = p:getHandcardNum()
			if (player:getHp() <= handcardnum) or (player:getAttackRange() >= handcardnum) then
				local _data = sgs.QVariant()
				_data:setValue(p)
				if player:askForSkillInvoke(self:objectName(), _data) then
					jink_table[index] = 0
				end
			end
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(Table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
		return false
	end
}
--[[
	技能名：烈弓
	相关武将：1v1·黄忠1v1
	描述：每当你于出牌阶段内使用【杀】指定对手为目标后，若对手的手牌数大于或等于你的体力值，你可以令该角色不能使用【闪】对此【杀】进行响应。
	引用：LuaKOFLiegong
	状态：1217验证通过
]]--
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaKOFLiegong = sgs.CreateTriggerSkill{
	name = "LuaKOFLiegong" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if player:objectName() ~= use.from:objectName() or player:getPhase() ~= sgs.Player_Play or not use.card:isKindOf("Slash") then return false end
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			local _data = sgs.QVariant()
				_data:setValue(p)
			if player:getHp() <= p:getHandcardNum() and player:askForSkillInvoke(self:objectName(), _data) then
				jink_table[index] = 0
			end
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(Table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
	end
}
--[[
	技能名：烈刃
	相关武将：火·祝融、1v1·祝融1v1
	描述：每当你使用【杀】对目标角色造成伤害后，你可以与该角色拼点：若你赢，你获得其一张牌。 
	引用：LuaLieren
	状态：0405验证通过
]]--
LuaLieren = sgs.CreateTriggerSkill{
	name = "LuaLieren",
	events = {sgs.Damage},
	on_trigger = function(self, event, zhurong, data)
		local room = zhurong:getRoom()
		local damage = data:toDamage()
		local target = damage.to
		if damage.card and damage.card:isKindOf("Slash") and (not zhurong:isKongcheng()) and (not target:isKongcheng()) and (not target:hasFlag("Global_DebutFlag")) and (not damage.chain) and (not damage.transfer) then
			if room:askForSkillInvoke(zhurong, self:objectName(), data) then
				local success = zhurong:pindian(target, "LuaLieren", nil)
				if not success then return false end
				if not target:isNude() then
					local card_id = room:askForCardChosen(zhurong, target, "he", self:objectName())
					local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, zhurong:objectName())
					room:obtainCard(zhurong, sgs.Sanguosha:getCard(card_id), reason, room:getCardPlace(card_id) ~= Player_PlaceHand)
				end
			end
		end
		return false
	end
}
--[[
	技能名：裂围
	相关武将：1v1·牛金
	描述：每当你杀死对手后，你可以摸三张牌。 
	引用：LuaLiewei
	状态：1217验证通过
]]--
LuaLiewei = sgs.CreateTriggerSkill{
	name = "LuaLiewei",
	events = {sgs.BuryVictim},
	frequency = sgs.Skill_Frequent,
	priority = -2,
	can_trigger = function(target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		local room = player:getRoom()
		if death.damage and death.damage.from and death.damage.from:hasSkill(self:objectName()) then
			if room:askForSkillInvoke(death.damage.from, self:objectName(), data) then
				death.damage.from:drawCards(3, self:objectName())
			end
		end
		return false
	end,
}
--[[
	技能名：流离
	相关武将：标准·大乔、SP·台版大乔、SP·王战大乔
	描述：当你成为【杀】的目标时，你可以弃置一张牌，将此【杀】转移给你攻击范围内的一名其他角色（此【杀】的使用者除外）。
	引用：LuaLiuli
	状态：1217验证通过	
]]--
LuaLiuliCard = sgs.CreateSkillCard{
	name = "LuaLiuliCard" ,
	filter = function(self, targets, to_select)
		if #targets > 0 then return false end
		if to_select:hasFlag("LuaLiuliSlashSource") or (to_select:objectName() == sgs.Self:objectName()) then return false end
		local from
		for _, p in sgs.qlist(sgs.Self:getSiblings()) do
			if p:hasFlag("LuaLiuliSlashSource") then
				from = p
				break
			end
		end
		local slash = sgs.Card_Parse(sgs.Self:property("lualiuli"):toString())
		if from and (not from:canSlash(to_select, slash, false)) then return false end
		local card_id = self:getSubcards():first()
		local range_fix = 0
		if sgs.Self:getWeapon() and (sgs.Self:getWeapon():getId() == card_id) then
			local weapon = sgs.Self:getWeapon():getRealCard():toWeapon()
			range_fix = range_fix + weapon:getRange() - 1
		elseif sgs.Self:getOffensiveHorse() and (sgs.Self:getOffensiveHorse():getId() == card_id) then
			range_fix = range_fix + 1
		end
		return sgs.Self:distanceTo(to_select, range_fix) <= sgs.Self:getAttackRange()
	end,
	on_effect = function(self, effect)
		effect.to:setFlags("LuaLiuliTarget")
	end
}
LuaLiuliVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaLiuli" ,
	response_pattern = "@@LuaLiuli",
	filter_pattern = ".!",
	view_as = function(self, card)
		local liuli_card = LuaLiuliCard:clone()
		liuli_card:addSubcard(card)
		return liuli_card
	end
}
LuaLiuli = sgs.CreateTriggerSkill{
	name = "LuaLiuli" ,
	events = {sgs.TargetConfirming} ,
	view_as_skill = LuaLiuliVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card and use.card:isKindOf("Slash")
				and use.to:contains(player) and player:canDiscard(player,"he") and (room:alivePlayerCount() > 2) then
			local players = room:getOtherPlayers(player)
			players:removeOne(use.from)
			local can_invoke = false
			for _, p in sgs.qlist(players) do
				if use.from:canSlash(p, use.card) and player:inMyAttackRange(p) then
					can_invoke = true
					break
				end
			end
			if can_invoke then
				local prompt = "@liuli:" .. use.from:objectName()
				room:setPlayerFlag(use.from, "LuaLiuliSlashSource")
				room:setPlayerProperty(player, "lualiuli", sgs.QVariant(use.card:toString()))
				if room:askForUseCard(player, "@@LuaLiuli", prompt, -1, sgs.Card_MethodDiscard) then
					room:setPlayerProperty(player, "lualiuli", sgs.QVariant())
					room:setPlayerFlag(use.from, "-LuaLiuliSlashSource")
					for _, p in sgs.qlist(players) do
						if p:hasFlag("LuaLiuliTarget") then
							p:setFlags("-LuaLiuliTarget")
							use.to:removeOne(player)
							use.to:append(p)
							room:sortByActionOrder(use.to)
							data:setValue(use)
							room:getThread():trigger(sgs.TargetConfirming, room, p, data)
							return false
						end
					end
				else
					room:setPlayerProperty(player, "lualiuli", sgs.QVariant())
					room:setPlayerFlag(use.from, "-LuaLiuliSlashSource")
				end
			end
		end
		return false
	end
}


--[[
	技能名：龙胆
	相关武将：标准·赵云、☆SP·赵云、翼·赵云、2013-3v3·赵云、SP·台版赵云
	描述：你可以将一张【杀】当【闪】，一张【闪】当【杀】使用或打出。
	引用：LuaLongdan
	状态：1217验证通过
]]--
LuaLongdan = sgs.CreateViewAsSkill{
	name = "LuaLongdan" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if #selected > 0 then return false end
		local card = to_select
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return card:isKindOf("Jink")
		elseif (usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE) or (usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "slash" then
				return card:isKindOf("Jink")
			else
				return card:isKindOf("Slash")
			end
		else
			return false
		end
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local originalCard = cards[1]
		if originalCard:isKindOf("Slash") then
			local jink = sgs.Sanguosha:cloneCard("jink", originalCard:getSuit(), originalCard:getNumber())
			jink:addSubcard(originalCard)
			jink:setSkillName(self:objectName())
			return jink
		elseif originalCard:isKindOf("Jink") then
			local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
			slash:addSubcard(originalCard)
			slash:setSkillName(self:objectName())
			return slash
		else
			return nil
		end
	end ,
	enabled_at_play = function(self, target)
		return sgs.Slash_IsAvailable(target)
	end,
	enabled_at_response = function(self, target, pattern)
		return (pattern == "slash") or (pattern == "jink")
	end
}
--[[
	技能名：龙魂
	相关武将：神·赵云
	描述：你可以将X张同花色的牌按以下规则使用或打出：红桃当【桃】；方块当火【杀】；黑桃当【无懈可击】；梅花当【闪】。（X为你的体力值且至少为1） 
	引用：LuaLonghun
	状态：0405验证通过
]]--
LuaLonghun = sgs.CreateViewAsSkill{
	name = "LuaLonghun" ,
	response_or_use = true ,
	n = 999 ,
	view_filter = function(self, selected, card)
		local n = math.max(1, sgs.Self:getHp())
		if #selected >= n or card:hasFlag("using") then
			return false 
		end
		if n > 1 and not #selected == 0 then
			local suit = selected[1]:getSuit()
			return card:getSuit() == suit
		end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and card:getSuit() == sgs.Card_Heart then
				return true
			elseif card:getSuit() == sgs.Card_Diamond then
				local slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, -1)
				slash:addSubcard(card:getEffectiveId())
				slash:deleteLater()
				return slash:isAvailable(sgs.Self)
			else
				return false
			end
		elseif sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "jink" then
				return card:getSuit() == sgs.Card_Club
			elseif pattern == "nullification" then
				return card:getSuit() == sgs.Card_Spade
			elseif string.find(pattern, "peach") then
				return card:getSuit() == sgs.Card_Heart
			elseif pattern == "slash" then
				return card:getSuit() == sgs.Card_Diamond
			end
			return false
		end
		return false
	end ,
	view_as = function(self, cards)
		local n = math.max(1, sgs.Self:getHp())
		if #cards ~= n then 
			return nil 
		end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("nullification", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			new_card:setSkillName(self:objectName())
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end ,
	enabled_at_play = function(self, player)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash" or pattern == "jink" or (string.find(pattern, "peach") and player:getMark("Global_PreventPeach") == 0) or (pattern == "nullification")
	end ,
	enabled_at_nullification = function(self, player)
		local n = math.max(1, player:getHp())
		local count = 0
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= n then return true end
		end
		for _, card in sgs.qlist(player:getEquips()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= n then return true end
		end
		return false
	end
}
--[[
	技能名：龙魂
	相关武将：测试·高达一号
	描述：你可以将一张牌按以下规则使用或打出：?当【桃】；?当火【杀】；?当【无懈可击】；?当【闪】。回合开始阶段开始时，若其他角色的装备区内有【青釭剑】，你可以获得之。
	引用：LuaXNosLonghun、LuaXDuojian
	状态：1217验证通过
]]--
LuaLonghun = sgs.CreateViewAsSkill{
	name = "LuaLonghun" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if (#selected >= 1) or to_select:hasFlag("using") then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			if sgs.Self:isWounded() and (to_select:getSuit() == sgs.Card_Heart) then
				return true
			elseif sgs.Slash_IsAvailable(sgs.Self) and (to_select:getSuit() == sgs.Card_Diamond) then
				if sgs.Self:getWeapon() and (to_select:getEffectiveId() == sgs.Self:getWeapon():getId())
						and to_select:isKindOf("Crossbow") then
					return sgs.Self:canSlashWithoutCrossbow()
				else
					return true
				end
			else
				return false
			end
		elseif (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE)
				or (sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE) then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "jink" then
				return to_select:getSuit() == sgs.Card_Club
			elseif pattern == "nullification" then
				return to_select:getSuit() == sgs.Card_Spade
			elseif string.find(pattern, "peach") then
				return to_select:getSuit() == sgs.Card_Heart
			elseif pattern == "slash" then
				return to_select:getSuit() == sgs.Card_Diamond
			end
			return false
		end
		return false
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = cards[1]
		local new_card = nil
		if card:getSuit() == sgs.Card_Spade then
			new_card = sgs.Sanguosha:cloneCard("nullification", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Heart then
			new_card = sgs.Sanguosha:cloneCard("peach", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Club then
			new_card = sgs.Sanguosha:cloneCard("jink", sgs.Card_SuitToBeDecided, 0)
		elseif card:getSuit() == sgs.Card_Diamond then
			new_card = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
		end
		if new_card then
			new_card:setSkillName(self:objectName())
			for _, c in ipairs(cards) do
				new_card:addSubcard(c)
			end
		end
		return new_card
	end ,
	enabled_at_play = function(self, player)
		return player:isWounded() or sgs.Slash_IsAvailable(player)
	end ,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "slash")
				or (pattern == "jink")
				or (string.find(pattern, "peach") and (not player:hasFlag("Global_PreventPeach")))
				or (pattern == "nullification")
	end ,
	enabled_at_nullification = function(self, player)
		local count = 0
		for _, card in sgs.qlist(player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
		for _, card in sgs.qlist(player:getEquips()) do
			if card:getSuit() == sgs.Card_Spade then count = count + 1 end
			if count >= 1 then return true end
		end
	end
}
LuaXDuojian = sgs.CreateTriggerSkill{
	name = "#LuaXDuojian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			local room = player:getRoom()
			local others = room:getOtherPlayers(player)
			for _,p in sgs.qlist(others) do
				local weapon = p:getWeapon()
				if weapon and weapon:objectName() == "QinggangSword" then
					if room:askForSkillInvoke(player, self:objectName()) then
						player:obtainCard(weapon)
					end
				end
			end
		end
		return false
	end
}

--[[
	技能名：龙吟
	相关武将：一将成名2013·关平
	描述：每当一名角色于其出牌阶段内使用【杀】选择目标后，你可以弃置一张牌，令此【杀】不计入出牌阶段限制的使用次数，若此【杀】为红色，你摸一张牌。
	引用：LuaLongyin
	状态：1217验证通过
]]--
LuaLongyin = sgs.CreateTriggerSkill{
	name = "LuaLongyin",
	events = {sgs.CardUsed},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
		local me = room:findPlayerBySkillName(self:objectName())
		if me and me:canDiscard(me,"he") and room:askForCard(me, "..", "@LuaLongyin", data,self:objectName()) then
		if use.m_addHistory then
			room:addPlayerHistory(player, use.card:getClassName(),-1)
		if use.card:isRed() then
			me:drawCards(1)
				end
			end
		end
	end
end,
	can_trigger = function(self, target)
		return target:getPhase() == sgs.Player_Play
	end
}

--[[
	技能名：笼络
	相关武将：智·张昭
	描述：回合结束阶段开始时，你可以选择一名其他角色摸取与你弃牌阶段弃牌数量相同的牌
	引用：LuaLongluo
	状态：1217验证通过
]]--
LuaLongluo = sgs.CreateTriggerSkill{
	name = "LuaLongluo" ,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Finish then
				local drawnum = player:getMark(self:objectName())
				if drawnum > 0 then
					if player:askForSkillInvoke(self:objectName(), data) then
						local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName())
						target:drawCards(drawnum)
					end
				end
			elseif player:getPhase() == sgs.Player_NotActive then
				room:setPlayerMark(player, self:objectName(), 0)
			end
		elseif player:getPhase() == sgs.Player_Discard then
			local move = data:toMoveOneTime()
			if move.from:objectName() == player:objectName() and
					(bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
				room:setPlayerMark(player, self:objectName(), player:getMark(self:objectName()) + move.card_ids:length())
			end
		end
		return false
	end
}
--[[
	技能名：乱击
	相关武将：火·袁绍
	描述：你可以将两张花色相同的手牌当【万箭齐发】使用。
	引用：LuaLuanji
	状态：1217验证通过
]]--
LuaLuanji = sgs.CreateViewAsSkill{
	name = "LuaLuanji",
	n = 2,
	view_filter = function(self, selected, to_select)
		if #selected == 0 then
			return not to_select:isEquipped()
		elseif #selected == 1 then
			local card = selected[1]
			if to_select:getSuit() == card:getSuit() then
				return not to_select:isEquipped()
			end
		else
			return false
		end
	end,
	view_as = function(self, cards)
		if #cards == 2 then
			local cardA = cards[1]
			local cardB = cards[2]
			local suit = cardA:getSuit()
			local aa = sgs.Sanguosha:cloneCard("archery_attack", suit, 0);
			aa:addSubcard(cardA)
			aa:addSubcard(cardB)
			aa:setSkillName(self:objectName())
			return aa
		end
	end
}
--[[
	技能名：乱武（限定技）
	相关武将：林·贾诩、SP·贾诩
	描述：出牌阶段，你可以令所有其他角色对距离最近的另一名角色使用一张【杀】，否则该角色失去1点体力。 
	引用：LuaLuanwu
	状态：0405验证通过	
]]--
LuaLuanwuCard = sgs.CreateSkillCard{
	name = "LuaLuanwuCard",
	target_fixed = true,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@chaos")
		local players = room:getOtherPlayers(source)
		for _,p in sgs.qlist(players) do
			if p:isAlive() then
				room:cardEffect(self, source, p)
			end
			room:getThread():delay()
		end
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local players = room:getOtherPlayers(effect.to)
		local distance_list = sgs.IntList()
		local nearest = 1000
		for _,player in sgs.qlist(players) do
			local distance = effect.to:distanceTo(player)
			distance_list:append(distance)
			nearest = math.min(nearest, distance)
		end
		local luanwu_targets = sgs.SPlayerList()
		for i = 0, distance_list:length() - 1, 1 do
			if distance_list:at(i) == nearest and effect.to:canSlash(players:at(i), nil, false) then
				luanwu_targets:append(players:at(i))
			end
		end
		if luanwu_targets:length() == 0 or not room:askForUseSlashTo(effect.to, luanwu_targets, "@luanwu-slash") then
			room:loseHp(effect.to)
		end
	end
}
LuaLuanwuVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaLuanwu",
	view_as = function(self, cards)
		return LuaLuanwuCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@chaos") >= 1
	end
}
LuaLuanwu = sgs.CreateTriggerSkill{
	name = "LuaLuanwu" ,
	frequency = sgs.Skill_Limited ,
	view_as_skill = LuaLuanwuVS ,
	limit_mark = "@chaos" ,
	on_trigger = function()
	end
}
--[[
	技能名：裸衣
	相关武将：标准·许褚
	描述：摸牌阶段，你可以少摸一张牌，若如此做，你使用的【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直到回合结束。
	引用：LuaLuoyiBuff、LuaLuoyi
	状态：1217验证通过
]]--
LuaLuoyiBuff = sgs.CreateTriggerSkill{
	name = "#LuaLuoyiBuff",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.chain or damage.transfer or (not damage.by_user) then return false end
		local reason = damage.card
		if reason and (reason:isKindOf("Slash") or reason:isKindOf("Duel")) then
			damage.damage = damage.damage + 1
			data:setValue(damage)
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasFlag("LuaLuoyi") and target:isAlive()
	end
}
LuaLuoyi = sgs.CreateTriggerSkill{
	name = "LuaLuoyi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local count = data:toInt()
		if count > 0 then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				count = count - 1
				room:setPlayerFlag(player, "LuaLuoyi")
				data:setValue(count)
			end
		end
	end
}
--[[
	技能名：裸衣
	相关武将：翼·许褚
	描述：出牌阶段，你可以弃置一张装备牌，若如此做，你使用的【杀】或【决斗】（你为伤害来源时）造成的伤害+1，直到回合结束。每阶段限一次。
	引用：LuaXNeoLuoyi、LuaXNeoLuoyiBuff
	状态：1217验证通过
]]--
LuaXNeoLuoyiCard = sgs.CreateSkillCard{
	name = "LuaXNeoLuoyiCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		source:setFlags("LuaXNeoLuoyi")
	end
}
LuaXNeoLuoyi = sgs.CreateViewAsSkill{
	name = "LuaXNeoLuoyi",
	n = 1,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("EquipCard")
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = LuaXNeoLuoyiCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if not player:hasUsed("#LuaXNeoLuoyiCard") then
			return not player:isNude()
		end
		return false
	end
}
LuaXNeoLuoyiBuff = sgs.CreateTriggerSkill{
	name = "#LuaXNeoLuoyiBuff",
	frequency = sgs.Skill_Frequent,
	events = {sgs.ConfirmDamage},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local reason = damage.card
		if reason then
			if reason:isKindOf("Slash") or reason:isKindOf("Duel") then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:hasFlag("LuaXNeoLuoyi") then
				return target:isAlive()
			end
		end
		return false
	end
}
--[[
	技能名：洛神
	相关武将：标准·甄姬、1v1·甄姬1v1、SP·甄姬、SP·台版甄姬
	描述：准备阶段开始时，你可以进行一次判定，若判定结果为黑色，你获得生效后的判定牌且你可以重复此流程。
	引用：LuaLuoshen
	状态：1217验证通过
]]--
LuaLuoshen = sgs.CreateTriggerSkill{
	name = "LuaLuoshen",
	frequency = sgs.Skill_Frequent,
	events = {sgs.EventPhaseStart, sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				while player:askForSkillInvoke(self:objectName()) do
					local judge = sgs.JudgeStruct()
					judge.pattern = ".|black"
					judge.good = true
					judge.reason = self:objectName()
					judge.who = player
					judge.time_consuming = true
					room:judge(judge)
					if judge:isBad() then
						break
					end
				end
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == self:objectName() then
				local card = judge.card
				if card:isBlack() then
					player:obtainCard(card)
					return true
				end
			end
		end
		return false
	end
}

--[[
	技能名：落雁（锁定技）
	相关武将：SP·大乔&小乔
	描述：若你的武将牌上有“星舞牌”，你视为拥有技能“天香”和“流离”。
	引用：LuaLuoyan
	状态：1217验证通过(需与技能“星舞”配合使用)
]]--
LuaLuoyan = sgs.CreateTriggerSkill{
	name = "LuaLuoyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.CardsMoveOneTime,sgs.EventAcquireSkill,sgs.EventLoseSkill},
	can_trigger = function(self,player)
		return player ~= nil 
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.EventLoseSkill and data:toString() == self:objectName() then
			room:handleAcquireDetachSkills(player,"-tianxiang|-liuli",true)
		elseif event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			if not player:getPile("xingwu"):isEmpty() then
				room:notifySkillInvoked(player,self:objectName())
				room:handleAcquireDetachSkills(player,"tianxiang|liuli")
			end
		elseif event == sgs.CardsMoveOneTime and player:isAlive() and player:hasSkill(self:objectName(),true) then
			local move = data:toMoveOneTime()
			if move.to and move.to:objectName() == player:objectName() and move.to_place == sgs.Player_PlaceSpecial and move.to_pile_name == "xingwu" then
				if player:getPile("xingwu"):length() == 1 then
					room:notifySkillInvoked(player,self:objectName())
					room:handleAcquireDetachSkills(player,"tianxiang|liuli")
				end
			elseif move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceSpecial) and table.contains(move.from_pile_names,"xingwu") then
				if player:getPile("xingwu"):isEmpty() then
					room:handleAcquireDetachSkills(player,"-tianxiang|-liuli",true)
				end
			end
		end
		return false
	end
}
--[[
	技能名：落英
	相关武将：一将成名·曹植
	描述：当其他角色的梅花牌因弃置或判定而置入弃牌堆时，你可以获得之。
	引用：LuaLuoying
	状态：1217验证通过
]]--
listIndexOf = function(theqlist, theitem)
	local index = 0
	for _, item in sgs.qlist(theqlist) do
		if item == theitem then return index end
		index = index + 1
	end
end
LuaLuoying = sgs.CreateTriggerSkill{
	name = "LuaLuoying",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if (move.from == nil) or (move.from:objectName() == player:objectName()) then return false end
		if (move.to_place == sgs.Player_DiscardPile)
				and ((bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)
				or (move.reason.m_reason == sgs.CardMoveReason_S_REASON_JUDGEDONE)) then
			local card_ids = sgs.IntList()
			local i = 0
			for _, card_id in sgs.qlist(move.card_ids) do
				if (sgs.Sanguosha:getCard(card_id):getSuit() == sgs.Card_Club)
						and (((move.reason.m_reason == sgs.CardMoveReason_S_REASON_JUDGEDONE)
						and (move.from_places:at(i) == sgs.Player_PlaceJudge)
						and (move.to_place == sgs.Player_DiscardPile))
						or ((move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_JUDGEDONE)
						and (room:getCardOwner(card_id):objectName() == move.from:objectName())
						and ((move.from_places:at(i) == sgs.Player_PlaceHand) or (move.from_places:at(i) == sgs.Player_PlaceEquip)))) then
					card_ids:append(card_id)
				end
				i = i + 1
			end
			if card_ids:isEmpty() then
				return false
			elseif player:askForSkillInvoke(self:objectName(), data) then
				while not card_ids:isEmpty() do
					room:fillAG(card_ids, player)
					local id = room:askForAG(player, card_ids, true, self:objectName())
					if id == -1 then
						room:clearAG(player)
						break
					end
					card_ids:removeOne(id)
					room:clearAG(player)
				end
				if not card_ids:isEmpty() then
					for _, id in sgs.qlist(card_ids) do
						if move.card_ids:contains(id) then
							move.from_places:removeAt(listIndexOf(move.card_ids, id))
							move.card_ids:removeOne(id)
							data:setValue(move)
						end
						room:moveCardTo(sgs.Sanguosha:getCard(id), player, sgs.Player_PlaceHand, move.reason, true)
						if not player:isAlive() then break end
					end
				end
			end
		end
		return false
	end
}
	技能名：流离
	相关武将：标准·大乔
	描述：当你成为【杀】的目标时，你可以弃置一张牌，将此【杀】转移给你攻击范围内的一名其他角色（此【杀】的使用者除外）。
]]--
-----------
--[[M区]]--
-----------
--[[
	技能名：马术（锁定技）
	相关武将：标准·马超、火·庞德、SP·庞德、SP·关羽、SP·最强神话、SP·暴怒战神、SP·马超、一将成名2012·马岱、一将成名2012·马岱-旧、国战·马腾、3v3·吕布、SP·台版马超、界限突破·马超、JSP·关羽
	描述：你计算的与其他角色的距离-1。
	引用：LuaMashu
	状态：0405验证通过
]]--
LuaMashu = sgs.CreateDistanceSkill{
	name = "LuaMashu",
	correct_func = function(self, from)
		if from:hasSkill(self:objectName()) then
			return -1
		else
			return 0
		end
	end,
}
--[[
	技能名：蛮裔
	相关武将：1v1·孟获1v1、1v1·祝融1v1
	描述：你登场时，你可以视为使用一张【南蛮入侵】。锁定技，【南蛮入侵】对你无效。
	引用：LuaSavageAssaultAvoid,LuaManyi
	状态：1217验证通过（kof1v1模式下通过）
]]--
LuaSavageAssaultAvoid = sgs.CreateTriggerSkill{
	name = "#LuaSavageAssaultAvoid",
	events = {sgs.CardEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if effect.card:isKindOf("SavageAssault") then
			return true
		else
			return false
		end
	end
}
LuaManyi = sgs.CreateTriggerSkill{
	name = "LuaManyi",
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local opponent = player:getNext()
		if not opponent:isAlive() then return end
		local nm = sgs.Sanguosha:cloneCard("savage_assault", sgs.Card_NoSuit, 0)
		nm:setSkillName(self:objectName())
		if not nm:isAvailable(player) then nm = nil return end
		if player:askForSkillInvoke(self:objectName()) then
			room:useCard(sgs.CardUseStruct(nm, player, nil))
			return
		end
	end
}
--[[
	技能名：漫卷
	相关武将：☆SP·庞统
	描述：每当你将获得任何一张手牌，将之置于弃牌堆。若此情况处于你的回合中，你可依次将与该牌点数相同的一张牌从弃牌堆置于你的手上。
	引用：LuaManjuan
	状态：1217验证通过
]]--
DoManjuan = function(player, id, skillname)
	local room = player:getRoom()
	player:setFlags("ManjuanInvoke")
	local DiscardPile = room:getDiscardPile()
	local toGainList = sgs.IntList()
	local card = sgs.Sanguosha:getCard(id)
	for _,cid in sgs.qlist(DiscardPile) do
		local cd = sgs.Sanguosha:getCard(cid)
		if cd:getNumber() == card:getNumber() then
			toGainList:append(cid)
		end
	end
	room:fillAG(toGainList, player)
	local card_id = room:askForAG(player, toGainList, false, skillname)
	if card_id ~= -1 then
		local gain_card = sgs.Sanguosha:getCard(card_id)
		room:moveCardTo(gain_card, player, sgs.Player_PlaceHand, true)
	end
	room:clearAG(player)
end
LuaManjuan = sgs.CreateTriggerSkill{
	name = "LuaManjuan",
	frequency = sgs.Skill_Frequent,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		if player:hasFlag("ManjuanInvoke") then
			player:setFlags("-ManjuanInvoke")
			return false
		end
		local card_id = -1
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), self:objectName(), "")
		local room = player:getRoom()
		if room:getTag("FirstRound"):toBool() then return false end
		local move = data:toMoveOneTime()
		local dest = move.to
		local flag = true
		local ids = sgs.IntList()
		if dest then
			if dest:objectName() == player:objectName() then
				if move.to_place == sgs.Player_PlaceHand then
					for _,card_id in sgs.qlist(move.card_ids) do
						local card = sgs.Sanguosha:getCard(card_id)
						room:moveCardTo(card, nil, nil, sgs.Player_DiscardPile, reason)
						flag = false
					end
				end
			end
		end
		if flag then
			return false
		end
		local x=move.card_ids:length()
		for i = x-1, 0, -1 do
			ids:append(move.card_ids:at(i))
			move.card_ids:removeAt(i)
		end
		data:setValue(move)
		if player:getPhase() ~= sgs.Player_NotActive then
			if player:askForSkillInvoke(self:objectName(), data) then
				for _,card_id in sgs.qlist(ids) do
					DoManjuan(player, card_id, self:objectName())
				end
				return event ~= sgs.CardsMoveOneTime
			end
		end
		return false
	end,
	priority = 2
}
--[[
	技能名：猛进
	相关武将：火·庞德、SP·庞德
	描述：当你使用的【杀】被目标角色的【闪】抵消时，你可以弃置其一张牌。
	引用：LuaMengjin
	状态：0405验证通过
]]--
LuaMengjin = sgs.CreateTriggerSkill{
	name = "LuaMengjin",
	events = {sgs.SlashMissed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local effect = data:toSlashEffect()
		if effect.to:isAlive() and player:canDiscard(effect.to, "he") then
			if player:askForSkillInvoke(self:objectName(), data) then
				local to_throw = room:askForCardChosen(player, effect.to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
				room:throwCard(sgs.Sanguosha:getCard(to_throw), effect.to, player)
			end
		end
		return false
	end,
}
--[[
	技能名：秘计
	相关武将：一将成名2012·王异
	描述：结束阶段开始时，若你已受伤，你可以摸一至X张牌（X为你已损失的体力值），然后将相同数量的手牌以任意分配方式交给任意数量的其他角色。
	引用：LuaMiji
	状态：1217验证通过
]]--
LuaMiji = sgs.CreateTriggerSkill{
	name = "LuaMiji" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (player:getPhase() == sgs.Player_Finish) and player:isWounded() then
			if player:askForSkillInvoke(self:objectName()) then
				local draw_num = {}
				for i = 1, player:getLostHp(), 1 do
					table.insert(draw_num, tostring(i))
				end
				local num = tonumber(room:askForChoice(player, "LuaMiji_draw", table.concat(draw_num, "+")))
				player:drawCards(num, self:objectName())
				if not player:isKongcheng() then
					local n = 0
					while true do
						local original_handcardnum = player:getHandcardNum()
						if (n < num) and (not player:isKongcheng()) then
							local handcards = player:handCards()
							if (not room:askForYiji(player,handcards,self:objectName(),false, false, false, num - n)) then break end
							n = n + (original_handcardnum - player:getHandcardNum())
						else
							break
						end
					end
					if (n < num) and (not player:isKongcheng()) then
						local rest_num = num - n
						while true do
							local handcard_list = player:handCards()
							--qShuffle(handcard_list);
							math.randomseed(os.time)
							local give = math.random(1, rest_num)
							rest_num = rest_num - give
							local to_give
							if handcard_list:length() < give then
								to_give = handcard_list
							else
								to_give = handcard_list:mid(0, give)
							end
							local receiver = room:getOtherPlayers(player):at(math.random(0, player:aliveCount() - 1))
							local dummy = sgs.Sanguosha:getCard("slash", sgs.Card_NoSuit, 0)
							for _, id in sgs.qlist(to_give) do
								dummy:addSubcard(id)
							end
							room:obtainCard(receiver, dummy, false)
							if (rest_num == 0) or player:isKongcheng() then break end
						end
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：秘计
	相关武将：怀旧-一将2·王异-旧
	描述：回合开始/结束阶段开始时，若你已受伤，你可以进行一次判定，若判定结果为黑色，你观看牌堆顶的X张牌（X为你已损失的体力值），然后将这些牌交给一名角色。
	引用：LuaNosMiji
	状态：1217验证通过
]]--
LuaNosMiji = sgs.CreateTriggerSkill{
	name = "LuaNosMiji" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Frequent ,
	on_trigger = function(self, event, player, data)
		if not player:isWounded() then return false end
		if (player:getPhase() == sgs.Player_Start) or (player:getPhase() == sgs.Player_Finish) then
			if not player:askForSkillInvoke(self:objectName()) then return false end
			local room = player:getRoom()
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|black"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = player
			room:judge(judge)
			if judge:isGood() and player:isAlive() then
				local pile_ids = room:getNCards(player:getLostHp(), false)
				room:fillAG(pile_ids, player)
				local target = room:askForPlayerChosen(player, room:getAllPlayers(), self:objectName())
				room:clearAG(player)
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in sgs.qlist(pile_ids) do
					dummy:addSubcard(id)
				end
				player:setFlags("Global_GongxinOperator")
				target:obtainCard(dummy, false)
				player:setFlags("-Global_GongxinOperator")
			end
		end
		return false
	end
}
--[[
	技能名：密信
	相关武将：铜雀台·伏皇后
	描述：出牌阶段限一次，你可以将一张手牌交给一名其他角色，该角色须对你选择的另一名角色使用一张【杀】（无距离限制），否则你选择的角色观看其手牌并获得其中任意一张。
	引用：LuaXMixin
	状态：1217验证通过
]]--
LuaXMixinCard = sgs.CreateSkillCard{
	name = "LuaXMixinCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		target:obtainCard(self, false)
		local others = sgs.SPlayerList()
		local list = room:getOtherPlayers(target)
		for _,p in sgs.qlist(list) do
			if target:canSlash(p, nil, false) then
				others:append(p)
			end
		end
		if not others:isEmpty() then
			local target2 = room:askForPlayerChosen(source, others, "LuaXMixin")
			if not room:askForUseSlashTo(target, target2, "#mixin", false) then
				local card_ids = target:handCards()
				room:fillAG(card_ids, target2)
				local cdid = room:askForAG(target2, card_ids, false, self:objectName())
				room:obtainCard(target2, cdid, false)
				room:clearAG(player)
			end
			return
		end
	end
}
LuaXMixin = sgs.CreateViewAsSkill{
	name = "LuaXMixin",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = LuaXMixinCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaXMixinCard")
	end
}
--[[
	技能名：密诏
	相关武将：铜雀台·汉献帝、SP·刘协
	描述：出牌阶段限一次，你可以将所有手牌（至少一张）交给一名其他角色：若如此做，你令该角色与另一名由你指定的有手牌的角色拼点：若一名角色赢，视为该角色对没赢的角色使用一张【杀】。
	引用：LuaXMizhao
	状态：1217验证通过
]]--
LuaXMizhaoCard = sgs.CreateSkillCard{
	name = "LuaXMizhaoCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			return to_select:objectName() ~= sgs.Self:objectName()
		end
		return false
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		target:obtainCard(effect.card, false)
		local room = source:getRoom()
		local targets = sgs.SPlayerList()
		local others = room:getOtherPlayers(target)
		for _,p in sgs.qlist(others) do
			if not p:isKongcheng() then
				targets:append(p)
			end
		end
		if not target:isKongcheng() then
			if not targets:isEmpty() then
				local dest = room:askForPlayerChosen(source, targets, "LuaXMizhao")
				target:pindian(dest, "LuaXMizhao", nil)
			end
		end
	end
}
LuaXMizhaoVS = sgs.CreateViewAsSkill{
	name = "LuaXMizhao",
	n = 999,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local count = sgs.Self:getHandcardNum()
		if #cards == count then
			local card = LuaXMizhaoCard:clone()
			for _,cd in pairs(cards) do
				card:addSubcard(cd)
			end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if not player:isKongcheng() then
			return not player:hasUsed("#LuaXMizhaoCard")
		end
		return false
	end
}
LuaXMizhao = sgs.CreateTriggerSkill{
	name = "LuaXMizhao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Pindian},
	view_as_skill = LuaXMizhaoVS,
	on_trigger = function(self, event, player, data)
		local pindian = data:toPindian()
		if pindian.reason == self:objectName() then
			local fromNumber = pindian.from_card:getNumber()
			local toNumber = pindian.to_card:getNumber()
			if fromNumber ~= toNumber then
				local winner
				local loser
				if fromNumber > toNumber then
					winner = pindian.from
					loser = pindian.to
				else
					winner = pindian.to
					loser = pindian.from
				end
				if winner:canSlash(loser, nil, false) then
					local room = player:getRoom()
					local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					slash:setSkillName("LuaXMizhao")
					local card_use = sgs.CardUseStruct()
					card_use.from = winner
					card_use.to:append(loser)
					card_use.card = slash
					room:useCard(card_use, false)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	priority = -1
}
--[[
	技能名：灭计（锁定技）
	相关武将：一将成名2013·李儒
	描述：你使用黑色非延时类锦囊牌的目标数上限至少为二。
	引用：LuaMieji、LuaMiejiTargetMod
	状态：1217验证通过
]]--
---------------------Ex借刀杀人技能卡---------------------
function targetsTable2QList(thetable)
	local theqlist = sgs.PlayerList()
	for _, p in ipairs(thetable) do
		theqlist:append(p)
	end
	return theqlist
end
LuaExtraCollateralCard = sgs.CreateSkillCard{
	name = "LuaExtraCollateralCard" ,
	filter = function(self, targets, to_select)
		local coll = sgs.Card_Parse(sgs.Self:property("extra_collateral"):toString())
		if (not coll) then return false end
		local tos = sgs.Self:property("extra_collateral_current_targets"):toString():split("+")
		if (#targets == 0) then
			return (not table.contains(tos, to_select:objectName())) 
					and (not sgs.Self:isProhibited(to_select, coll)) and coll:targetFilter(targetsTable2QList(targets), to_select, sgs.Self)
		else
			return coll:targetFilter(targetsTable2QList(targets), to_select, sgs.Self)
		end
	end ,
	about_to_use = function(self, room, cardUse)
		local killer = cardUse.to:first()
		local victim = cardUse.to:last()
		killer:setFlags("ExtraCollateralTarget")
		local _data = sgs.QVariant()
		_data:setValue(victim)
		killer:setTag("collateralVictim", _data)
	end
}
----------------------------------------------------------
LuaMiejiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaMieji" ,
	pattern = "SingleTargetTrick|black" ,
	extra_target_func = function(self, from)
		if (from:hasSkill("LuaMieji")) then
			return 1
		end
		return 0
	end
}
LuaMiejiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaMieji" ,
	response_pattern = "@@LuaMieji" ,
	view_as = function()
		return LuaExtraCollateralCard:clone()
	end
}
LuaMieji = sgs.CreateTriggerSkill{
	name = "LuaMieji" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.PreCardUsed} ,
	view_as_skill = LuaMiejiVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if (use.card:isBlack() and (use.card:isKindOf("ExNihilo") or use.card:isKindOf("Collateral"))) then
			local targets = sgs.SPlayerList()
			local extra = nil
			if (use.card:isKindOf("ExNihilo")) then
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if (not use.to:contains(p)) and (not room:isProhibited(player, p, use.card)) then
						targets:append(p)
					end
				end
				if (targets:isEmpty()) then return false end
				extra = room:askForPlayerChosen(player, targets, self:objectName(), "@qiaoshui-add:::"..use.card:objectName(), true)
			elseif (use.card:isKindOf("Collateral")) then
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if (use.to:contains(p) or room:isProhibited(player, p, use.card)) then continue end
					if use.card:targetFilter(sgs.PlayerList(), p, player) then
						targets:append(p)
					end
				end
				if (targets:isEmpty()) then return false end
				local tos = {}
				for _, t in sgs.qlist(use.to) do
					table.insert(tos, t:objectName())
				end
				room:setPlayerProperty(player, "extra_collateral", sgs.QVariant(use.card:toString()))
				room:setPlayerProperty(player, "extra_collateral_current_targets", sgs.QVariant(table.concat(tos, "+")))
				local used = room:askForUseCard(player, "@@LuaMieji", "@qiaoshui-add:::collateral")
				room:setPlayerProperty(player, "extra_collateral", sgs.QVariant(""))
				room:setPlayerProperty(player, "extra_collateral_current_targets", sgs.QVariant("+"))
				if not used then return false end
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("ExtraCollateralTarget") then
						p:setFlags("-ExtraColllateralTarget")
						extra = p
						break
					end
				end
			end
			if extra == nil then return false end
			use.to:append(extra)
			room:sortByActionOrder(use.to)
			data:setValue(use)
		end
		return false
	end
}
--[[
	技能名：名士（锁定技）（0224及以前版）
	相关武将：国战·孔融
	描述：每当你受到伤害时，若伤害来源有手牌，需展示所有手牌，否则此伤害-1。
	引用：LuaXMingshi
	状态：1217验证通过
]]--
LuaXMingshi = sgs.CreateTriggerSkill{
	name = "LuaXMingshi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local source = damage.from
		if source then
			local choice
			if not source:isKongcheng() then
				choice = room:askForChoice(source, self:objectName(), "yes+no", data)
			else
				choice = "yes"
			end
			if choice == "no" then
				damage.damage = damage.damage - 1
				if damage.damage < 1 then
					return true
				end
				data:setValue(damage)
			else
				room:showAllCards(source)
			end
		end
		return false
	end
}
--[[
	技能名：名士（锁定技）（0610版）
	相关武将：国战·孔融
	描述：每当你受到伤害时，若伤害来源装备区的牌数不大于你的装备区的牌数，此伤害-1。
	引用：LuaMingshi610
	状态：1217验证通过
]]--
LuaMingshi610 = sgs.CreateTriggerSkill{
	name = "LuaMingshi610" ,
	events = {sgs.DamageInflicted} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.from then
			if damage.from:getEquips():length() <= player:getEquips():length() then
				damage.damage = damage.damage - 1
				if damage.damage < 1 then return true end
				data:setValue(damage)
			end
		end
		return false
	end
}
--[[
	技能名：明策
	相关武将：一将成名·陈宫
	描述：出牌阶段限一次，你可以将一张装备牌或【杀】交给一名其他角色，该角色需视为对其攻击范围内你选择的另一名角色使用一张【杀】，若其未如此做或其攻击范围内没有使用【杀】的目标，其摸一张牌。
	引用：LuaMingce
	状态：1217验证通过
]]--
LuaMingceCard = sgs.CreateSkillCard{
	name = "LuaMingceCard" ,
	will_throw = false ,
	handling_method = sgs.Card_MethodNone ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		local targets = sgs.SPlayerList()
		if sgs.Slash_IsAvailable(effect.to) then
			for _, p in sgs.qlist(room:getOtherPlayers(effect.to)) do
				if effect.to:canSlash(p) then
					targets:append(p)
				end
			end
		end
		local target
		local choicelist = {"draw"}
		if (not targets:isEmpty()) and effect.from:isAlive() then
			target = room:askForPlayerChosen(effect.from, targets, self:objectName(), "@dummy-slash2:" .. effect.to:objectName())
			target:setFlags("LuaMingceTarget")
			table.insert(choicelist, "use")
		end
		effect.to:obtainCard(self)
		local choice = room:askForChoice(effect.to, self:objectName(), table.concat(choicelist, "+"))
		if target and target:hasFlag("LuaMingceTarget") then target:setFlags("-LuaMingceTarget") end
		if choice == "use" then
			if effect.to:canSlash(target, nil, false) then
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("_LuaMingce")
				room:useCard(sgs.CardUseStruct(slash, effect.to, target), false)
			end
		elseif choice == "draw" then
			effect.to:drawCards(1)
		end
	end
}
LuaMingce = sgs.CreateViewAsSkill{
	name = "LuaMingce" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return to_select:isKindOf("EquipCard") or to_select:isKindOf("Slash")
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local mingcecard = LuaMingceCard:clone()
		mingcecard:addSubcard(cards[1])
		return mingcecard
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaMingceCard")
	end
}
--[[
	技能名：明鉴
	相关武将：贴纸·辛宪英
	描述：任一角色回合开始时，你可以立即优先执行下列两项中的一项：
		1.弃置一张牌，跳过该角色的判定阶段。
		2.竖置一张手牌于其武将牌上，该角色本回合内的判定均不受任何人物技能影响，该角色回合结束后将该牌置入弃牌堆。
	引用：LuaMingjian、LuaXMingjianStop
	状态：1217验证通过
]]--
LuaXMingjianCard = sgs.CreateSkillCard{
	name = "LuaXMingjianCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local target = room:getCurrent()
		target:addToPile("jian", self)
	end
}
LuaXMingjianVS = sgs.CreateViewAsSkill{
	name = "LuaXMingjian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = cards[1]
			local vs_card = LuaXMingjianCard:clone()
			vs_card:setSkillName(self:objectName())
			vs_card:addSubcard(card)
			return vs_card
		end
	end,
	enabled_at_play=function()
		return false
	end,
	enabled_at_response = function(self,player,pattern)
		return pattern == "@@LuaXMingjian"
	end
}
LuaXMingjian = sgs.CreateTriggerSkill{
	name = "LuaXMingjian",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaXMingjianVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local phase = player:getPhase()
		local xin = room:findPlayerBySkillName(self:objectName())
		if phase == sgs.Player_NotActive then
			player:removePileByName("jian")
			return
		end
		if xin then
			if phase == sgs.Player_RoundStart then
				if not xin:isNude() then
					local string = not player:getJudgingArea():isEmpty() and "ming+jian+cancel" or "jian+cancel"
					local choice = room:askForChoice(xin, self:objectName(), string)
					if  choice == "cancel" then
						return false
					elseif choice == "ming" then
						local data = sgs.QVariant()
						data:setValue(player)
						local card = room:askForCard(xin, ".|.|.|.|.", "@mingjiana", data, "LuaXMingjian")
						if card then
							player:skip(sgs.Player_Judge)
						end
					elseif choice == "jian"  then
						room:askForUseCard(xin, "@@LuaXMingjian", "@mingjianb", -1, sgs.Card_MethodNone)
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
LuaXMingjianStop = sgs.CreateTriggerSkill{
	name = "#LuaXMingjianStop",
	priority = 5,
	events = sgs.AskForRetrial ,
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		local jianpile = judge.who:getPile("jian")
		return not jianpile:isEmpty()
	end,
	can_trigger = function()
		return true
	end
}
--[[
	技能名：明哲
	相关武将：新3V3·诸葛瑾
	描述：你的回合外，当你因使用、打出或弃置而失去一张红色牌时，你可以摸一张牌。
	引用：LuaXMingzhe
	状态：1217验证通过
]]--
LuaXMingzhe=sgs.CreateTriggerSkill{
	name="LuaXMingzhe",
	frequency=sgs.Skill_Frequent,
	events={sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_trigger=function(self, event, player, data)
		local room = player:getRoom()
		if (player:getPhase() ~= sgs.Player_NotActive) then
			return
		end
		local move = data:toMoveOneTime()
		if move.from:objectName() ~= player:objectName() then
			return
		end
		if event == sgs.BeforeCardsMove then
			local reason = move.reason.m_reason
			local reasonx = bit32.band(reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
			local Yes = reasonx == sgs.CardMoveReason_S_REASON_DISCARD
			or reasonx == sgs.CardMoveReason_S_REASON_USE or reasonx == sgs.CardMoveReason_S_REASON_RESPONSE
			if Yes then
				local card
				local i = 0
				for _,id in sgs.qlist(move.card_ids) do
					card = sgs.Sanguosha:getCard(id)
					if move.from_places:at(i) == sgs.Player_PlaceHand
						or move.from_places:at(i) == sgs.Player_PlaceEquip then
						if card and room:getCardOwner(id):getSeat() == player:getSeat() then
							player:addMark(self:objectName())
						end
					end
					i = i + 1
				end
			end
		else
			for i = 0, player:getMark(self:objectName()) - 1 do
				if player:askForSkillInvoke(self:objectName(),data) then
					player:drawCards(1)
				else
					break
				end
			end
			player:setMark(self:objectName(), 0)
		end
	end,
}
--[[
	技能名：谋断（转化技）
	相关武将：☆SP·吕蒙
	描述：通常状态下，你拥有标记“武”并拥有技能“激昂”和“谦逊”。当你的手牌数为2张或以下时，你须将你的标记翻面为“文”，将该两项技能转化为“英姿”和“克己”。任一角色的回合开始前，你可弃一张牌将标记翻回。
	引用：LuaMouduanStart、LuaMouduan、LuaMouduanClear
	状态：1217验证通过
]]--
LuaMouduanStart = sgs.CreateTriggerSkill{
	name = "#LuaMouduan-start" ,
	events = {sgs.GameStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		player:gainMark("@wu")
		room:acquireSkill(player, "jiang")
		room:acquireSkill(player, "qianxun")
	end ,
}
LuaMouduan = sgs.CreateTriggerSkill{
	name = "LuaMouduan" ,
	events = {sgs.EventPhaseStart, sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local lvmeng = room:findPlayerBySkillName(self:objectName())
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and (move.from:objectName() == player:objectName()) and (player and player:isAlive() and player:hasSkill(self:objectName()))
					and (player:getMark("@wu") > 0) and (player:getHandcardNum() <= 2) then
				player:loseMark("@wu")
				player:gainMark("@wen")
				room:handleAcquireDetachSkills(player, "-jiang|-qianxun|yingzi|keji")
			end
		elseif (player:getPhase() == sgs.Player_RoundStart) and lvmeng and (lvmeng:getMark("@wen") > 0)
				and lvmeng:canDiscard(lvmeng, "he") then
			if room:askForCard(lvmeng, "..", "@LuaMouduan", sgs.QVariant(), self:objectName()) then
				if lvmeng:getHandcardNum() > 2 then
					lvmeng:loseMark("@wen")
					lvmeng:gainMark("@wu")
					room:handleAcquireDetachSkills(lvmeng, "-yingzi|-keji|jiang|qianxun")
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
LuaMouduanClear = sgs.CreateTriggerSkill{
	name = "#LuaMouduan-clear" ,
	events = {sgs.EventLoseSkill} ,
	on_trigger = function(self, event, player, data)
		if data:toString() == "LuaMouduan" then
			local room = player:getRoom()
			if player:getMark("@wu") > 0 then
				room:detachSkillFromPlayer(player, "jiang")
				room:detachSkillFromPlayer(player, "qianxun")
			elseif player:getMark("@wen") > 0 then
				room:detachSkillFromPlayer(player, "yingzi")
				room:detachSkillFromPlayer(player, "keji")
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：谋溃
	相关武将：铜雀台·穆顺、SP·伏完
	描述：当你使用【杀】指定一名角色为目标后，你可以选择一项：摸一张牌，或弃置其一张牌。若如此做，此【杀】被【闪】抵消时，该角色弃置你的一张牌。
	引用：LuaXMoukui
	状态：1217验证通过
]]--
LuaXMoukui = sgs.CreateTriggerSkill{
	name = "LuaXMoukui",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TargetConfirmed, sgs.SlashMissed, sgs.CardFinished},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if player:objectName() == use.from:objectName() then
				if player:isAlive() and player:hasSkill(self:objectName()) then
					local slash = use.card
					if slash:isKindOf("Slash") then
						for _,p in sgs.qlist(use.to) do
							local ai_data = sgs.QVariant()
							ai_data:setValue(p)
							if player:askForSkillInvoke(self:objectName(), ai_data) then
								local choice
								if p:isNude() then
									choice = "draw"
								else
									choice = room:askForChoice(player, self:objectName(), "draw+discard")
								end
								if choice == "draw" then
									player:drawCards(1)
								else
									local disc = room:askForCardChosen(player, p, "he", self:objectName())
									room:throwCard(disc, p, player)
								end
								local mark = string.format("%s%s", self:objectName(), slash:toString())
								local count = p:getMark(mark) + 1
								room:setPlayerMark(p, mark,	count)
							end
						end
					end
				end
			end
		elseif event == sgs.SlashMissed then
			local effect = data:toSlashEffect()
			local dest = effect.to
			local source = effect.from
			local slash = effect.slash
			local mark = string.format("%s%s", self:objectName(), slash:toString())
			if dest:getMark(mark) > 0 then
				if source:isAlive() and dest:isAlive() and not source:isNude() then
					local disc = room:askForCardChosen(dest, source, "he", self:objectName())
					room:throwCard(disc, source, dest)
					local count = dest:getMark(mark) - 1
					room:setPlayerMark(dest, mark, count)
				end
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") then
				local players = room:getAllPlayers()
				for _,p in sgs.qlist(players) do
					local mark = string.format("%s%s", self:objectName(), use.card:toString())
					room:setPlayerMark(p, mark, 0)
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：谋诛
	相关武将：1v1·何进
	描述：出牌阶段限一次，你可以令对手交给你一张手牌，然后若你的手牌数大于对手的手牌数，对手选择一项：视为对你使用一张【杀】，或视为对你使用一张【决斗】。
	引用：LuaMouzhu
	状态：1217验证成功
]]--
LuaMouzhuCard = sgs.CreateSkillCard{
	name = "LuaMouzhu",
	filter = function(self, targets, to_select, player)
		return #targets<1 and to_select:objectName() ~= self:objectName() and not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if effect.to:isKongcheng() then return end
		local card = nil
		if effect.to:getHandcardNum() > 1 then
			card = room:askForCard(effect.to, ".!", "@mouzhu-give:" .. effect.from:objectName(), sgs.QVariant(), sgs.Card_MethodNone)
			if not card then
				card = effect.to:getHandcards():at(math.fmod(math.random(1, effect.to:getHandcardNum())))
			end
		else
			card = effect.to:getHandcards():first()
		end
		if card == nil then return end
		effect.from:obtainCard(card, false)
		if not effect.from:isAlive() or not effect.to:isAlive() then return end
		if effect.from:getHandcardNum() > effect.to:getHandcardNum() then
			local choicelist = {}
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName(self:objectName())
			local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
			duel:setSkillName(self:objectName())
			if not effect.to:isLocked(slash) and effect.to:canSlash(effect.from, slash, false) then
				table.insert(choicelist, "slash")
			end
			if not effect.to:isLocked(duel) and not effect.to:isProhibited(effect.from, duel) then
				table.insert(choicelist, "duel")
			end
			if #choicelist == 0 then return end
			local choice = room:askForChoice(effect.to, self:objectName(), table.concat(choicelist, "+"))
			local use = sgs.CardUseStruct()
			use.from = effect.to
			use.to:append(effect.from)
			if choice == "slash" then
				use.card = slash
			else
				use.card = duel
			end
			room:useCard(use)
		end
	end,
}
LuaMouzhu = sgs.CreateViewAsSkill{
	name = "LuaMouZhu",
	n = 0,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaMouzhu")
	end,
	view_as = function(self, cards)
		return LuaMouzhuCard:clone()
	end,
}
	技能名：明策
	相关武将：一将成名·陈宫
	描述：出牌阶段，你可以交给一名其他角色一张装备牌或【杀】，该角色选择一项：1. 视为对其攻击范围内你选择的另一名角色使用一张【杀】。2. 摸一张牌。每回合限一次。
]]--
-----------
--[[N区]]--
-----------
--[[
	技能名：纳蛮
	相关武将：SP·马良
	描述：每当其他角色打出的【杀】因打出而置入弃牌堆时，你可以获得之。 
	引用：LuaNaman
	状态：0405验证通过
]]--

LuaNaman = sgs.CreateTriggerSkill{
	name = "LuaNaman",
	events = {sgs.BeforeCardsMove}, 
	on_trigger = function(self, event, player, data)
		local room =  player:getRoom()
		local move = data:toMoveOneTime()
		if (move.to_place ~= sgs.Player_DiscardPile) then return end
		local to_obtain = nil
		if bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) ==    sgs.CardMoveReason_S_REASON_RESPONSE then 
			if move.from and player:objectName() == move.from:objectName() then return end 
			to_obtain = move.reason.m_extraData:toCard()
			if not to_obtain or not to_obtain:isKindOf("Slash") then return end
		else
			return 
		end
		if to_obtain and room:askForSkillInvoke(player, self:objectName(), data) then 
			room:obtainCard(player, to_obtain)
			move:removeCardIds(move.card_ids)
			data:setValue(move)
		end
	return
	end,
}
--[[
	技能名：逆乱
	相关武将：1v1·韩遂
	描述：对手的结束阶段开始时，若其当前的体力值比你大，或其于此回合内对你使用过【杀】，你可以将一张黑色牌当【杀】对其使用。 
	引用：LuaNiluan、LuaNiluanRecord
	状态：1217验证通过
]]--
LuaNiluanVS = sgs.CreateOneCardViewAsSkill {
	name = "LuaNiluan",
	filter_pattern = ".|black",
	response_pattern = "@@niluan",
	view_as = function(slef, card)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
		slash:addSubcard(card)
		slash:setSkillName("LuaNiluan")
		return slash
	end,
}
LuaNiluan = sgs.CreateTriggerSkill{
	name = "LuaNiluan",
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaNiluanVS,
	can_trigger = function(self, player)
		return player:isAlive()
	end,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local room = player:getRoom()
			local owner = room:findPlayerBySkillName(self:objectName())
			if owner and owner:objectName()~=player:objectName() and owner:canSlash(player, false) then
				if player:getHp() > owner:getHp() or not owner:hasFlag("LuaNiluanSlashTarget") then
					if owner:isKongcheng() then
						local has_black = false
						for i=0, 3, 1 do
							local equip = owner:getEquip(i)
							if equip and equip:isBlack() then
								has_black = true
								break
							end
						end
						if not has_black then return false end
					end
					room:setPlayerFlag(owner, "slashTargetFix")
					room:setPlayerFlag(owner, "slashNoDistanceLimit")
					room:setPlayerFlag(owner, "slashTargetFixToOne")
					room:setPlayerFlag(player, "SlashAssignee")
					local slash = room:askForUseCard(owner, "@@niluan", "@niluan-slash:" .. player:objectName())
					if slash == nil then
						room:setPlayerFlag(owner, "-slashTargetFix")
						room:setPlayerFlag(owner, "-slashNoDistanceLimit")
						room:setPlayerFlag(owner, "-slashTargetFixToOne")
						room:setPlayerFlag(player, "-SlashAssignee")
					end
				end
			end
		end
		return false
	end,
}
LuaNiluanRecord = sgs.CreateTriggerSkill{
	name = "#LuaNiluan-record",
	events = {sgs.TargetConfirmed, sgs.EventPhaseStart},
	priority = 4,
	can_trigger = function(self, player)
		return player ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and use.card:isKindOf("Slash") then
				for _,to in sgs.qlist(use.to) do
					if not to:hasFlag("LuaNiluanSlashTarget") then
						to:setFlags("LuaNiluanSlashTarget")
					end
				end
			end
		else 
			if player:getPhase() == sgs.Player_RoundStart then
				for _,p in sgs.qlist(room:getAlivePlayers()) do
					p:setFlags("-LuaNiluanSlashTarget")
				end
			end
		end
		return false
	end,
}
--[[
	技能名：鸟翔
	相关武将：阵·蒋钦
	描述：每当一名角色被指定为【杀】的目标后，若你与此【杀】使用者均与该角色相邻，你可以令该角色须使用两张【闪】抵消此【杀】。 
	引用：LuaNiaoxiang
	状态：1217验证通过
]]--
function Table2IntList(thetable)
	local theqlist = sgs.IntList()
	for _, p in ipairs(thetable) do
		theqlist:append(p)
	end
	return theqlist
end
LuaNiaoxiang = sgs.CreateTriggerSkill{
	name = "LuaNiaoxiang",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.from:isAlive() then
			local jink_list = use.from:getTag("Jink_"..use.card:toString()):toIntList()
			for i=0, use.to:length()-1, 1 do
				local to = use.to:at(i)
				if to:isAlive() and to:isAdjacentTo(player) and to:isAdjacentTo(use.from) then
					local new_data = sgs.QVariant()
					new_data:setValue(to)			--for AI
					if room:askForSkillInvoke(player, self:objectName(), new_data) then
						local jink_table = sgs.QList2Table(jink_list)
						if jink_list:at(i) == 1 then
							jink_table[i+1] = 2
						end
						jink_list = Table2IntList(jink_table)
						local list_data = sgs.QVariant()
						list_data:setValue(jink_list)
						use.from:setTag("Jink_" .. use.card:toString(), list_data)
					end
				end
			end
		end
		return false
	end,
}
--[[
	技能名：涅槃（限定技）
	相关武将：火·庞统
	描述：当你处于濒死状态时，你可以：弃置你区域里所有的牌，然后将你的武将牌翻至正面朝上并重置之，再摸三张牌且体力回复至3点。
	引用：LuaNiepan、LuaNiepanStart
	状态：1217验证通过
]]--
LuaNiepan = sgs.CreateTriggerSkill{
	name = "LuaNiepan",
	frequency = sgs.Skill_Limited,
	events = {sgs.AskForPeaches},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying_data = data:toDying()
		local source = dying_data.who
		if source:objectName() == player:objectName() then
			if player:askForSkillInvoke(self:objectName(), data) then
				player:loseMark("@nirvana")
				player:throwAllCards()
				local maxhp = player:getMaxHp()
				local hp = math.min(3, maxhp)
				room:setPlayerProperty(player, "hp", sgs.QVariant(hp))
				player:drawCards(3)
				if player:isChained() then
					local damage = dying_data.damage
					if (damage == nil) or (damage.nature == sgs.DamageStruct_Normal) then
						room:setPlayerProperty(player, "chained", sgs.QVariant(false))
					end
				end
				if not player:faceUp() then
					player:turnOver()
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:hasSkill(self:objectName()) then
				if target:isAlive() then
					return target:getMark("@nirvana") > 0
				end
			end
		end
		return false
	end
}
LuaNiepanStart = sgs.CreateTriggerSkill{
	name = "#LuaNiepanStart",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		player:gainMark("@nirvana")
	end
}
-----------
--[[O区]]--
-----------

-----------
--[[P区]]--
-----------
--[[
	技能名：排异
	相关武将：一将成名·钟会
	描述：出牌阶段限一次，你可以将一张“权”置入弃牌堆并选择一名角色：若如此做，该角色摸两张牌：若其手牌多于你，该角色受到1点伤害。
	引用：LuaPaiyi
	状态：0405证通过
]]--
LuaPaiyiCard = sgs.CreateSkillCard{
	name = "LuaPaiyiCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		return #targets == 0
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local target = effect.to
		local room = source:getRoom()
		local powers = source:getPile("power")
		if powers:isEmpty() then return false end
		local card_id = self:getSubcards():first()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", target:objectName(), self:objectName(), "")
		room:throwCard(sgs.Sanguosha:getCard(card_id), reason, nil)
		room:drawCards(target, 2, self:objectName())
		if target:getHandcardNum() > source:getHandcardNum() then
			room:damage(sgs.DamageStruct(self:objectName(), source, target))
		end
	end
}
LuaPaiyi = sgs.CreateOneCardViewAsSkill{
	name = "LuaPaiyi",
	filter_pattern = ".|.|.|power",
	expand_pile = "power",
	view_as = function(self, card)
		local py = LuaPaiyiCard:clone()
		py:addSubcard(card)
		return py
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaPaiyiCard") and not player:getPile("power"):isEmpty()
	end
}
--[[
	技能名：咆哮（锁定技）
	相关武将：界限突破·张飞、标准·张飞-旧、翼·张飞。夏侯霸、关兴&张苞
	描述：你在出牌阶段内使用【杀】时无次数限制。
	引用：LuaPaoxiao
	状态：0405验证通过
]]--
LuaPaoxiao = sgs.CreateTargetModSkill{
	name = "LuaPaoxiao",
	frequency = sgs.Skill_NotCompulsory,
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end
}
--[[
	技能名：翩仪（锁定技）
	相关武将：1v1·貂蝉1v1
	描述：你登场时，若处于对手的回合，当前回合结束。
	状态：等某神杀版本支持throwEvent的时候我会考虑这个技能……
]]--
--[[
	技能名：破军
	相关武将：一将成名·徐盛
	描述：每当你使用【杀】对目标角色造成一次伤害后，你可以令其摸X张牌（X为该角色当前的体力值且至多为5），然后该角色将其武将牌翻面。
	引用：LuaPojun
	状态：1217验证通过
]]--
LuaPojun = sgs.CreateTriggerSkill{
	name = "LuaPojun" ,
	events = {sgs.Damage} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and (not damage.chain) and (not damage.transfer)
				and damage.to:isAlive() then
			if player:getRoom():askForSkillInvoke(player, self:objectName(), data) then
				local x = math.min(5, damage.to:getHp())
				damage.to:drawCards(x)
				damage.to:turnOver()
			end
		end
		return false
	end
}
--[[
	技能名：普济
	相关武将：1v1·华佗
	描述：出牌阶段限一次，若对手有牌，你可以弃置一张牌：若如此做，你弃置其一张牌，然后以此法弃置?牌的角色摸一张牌。 
	引用：LuaPuji
	状态：1217验证成功
]]--
LuaPujiCard = sgs.CreateSkillCard{
	name = "LuaPuji",
	filter = function(self, targets, to_select, player)
		return #targets<1 and player:canDiscard(to_select, "he") and to_select:objectName() ~= player:objectName()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local id = room:askForCardChosen(effect.from, effect.to, "he", "LuaPuji")
		room:throwCard(id, effect.to, effect.from)
		if effect.from:isAlive() and self:getSuit() == sgs.Card_Spade then
			effect.from:drawCards(1)
		end
		if effect.to:isAlive() and sgs.Sanguosha:getCard(id):getSuit() == sgs.Card_Spade then
			effect.to:drawCards(1)
		end
	end,
}
LuaPuji = sgs.CreateOneCardViewAsSkill{
	name = "LuaPuji",
	filter_pattern = ".!",
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he") and not player:hasUsed("#LuaPuji")
	end,
	view_as = function(self, card)
		local pujiCard = LuaPujiCard:clone()
		pujiCard:addSubcard(card)
		return pujiCard
	end,
}
-----------
--[[Q区]]--
-----------
--[[
	技能名：七星
	相关武将：神·诸葛亮
	描述：分发起始手牌时，共发你十一张牌，你选四张作为手牌，其余的面朝下置于一旁，称为“星”；摸牌阶段结束时，你可以用任意数量的手牌等量替换这些“星”。
	引用：LuaQixing、LuaQixingStart、LuaQixingAsk、LuaQingxingClear
	状态：0405验证通过
	备注：水饺wch哥：医神要把0405耦合的“狂风”和“大雾”解耦吗？
]]--
LuaQixingCard = sgs.CreateSkillCard{
	name = "LuaQixingCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	target_fixed = true,
	on_use = function(self, room, source, targets)
		local pile = source:getPile("stars")
		local subCards = self:getSubcards()
		local to_handcard = sgs.IntList()
		local to_pile = sgs.IntList()
		local set = source:getPile("stars")
		for _,id in sgs.qlist(subCards) do
			set:append(id)
		end
		for _,id in sgs.qlist(set) do
			if not subCards:contains(id) then
				to_handcard:append(id)
			elseif not pile:contains(id) then
				to_pile:append(id)
			end
		end
		assert(to_handcard:length() == to_pile:length())
		if to_pile:length() == 0 or to_handcard:length() ~= to_pile:length() then return end
		room:notifySkillInvoked(source, "LuaQixing")
		source:addToPile("stars", to_pile, false)
		local to_handcard_x = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _,id in sgs.qlist(to_handcard) do
			to_handcard_x:addSubcard(id)
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXCHANGE_FROM_PILE, source:objectName())
		room:obtainCard(source, to_handcard_x, reason, false)
	end,
}
LuaQixingVS = sgs.CreateViewAsSkill{
	name = "LuaQixing", 
	n = 998,
	response_pattern = "@@LuaQixing",
	expand_pile = "stars",
	view_filter = function(self, selected, to_select)
		if #selected < sgs.Self:getPile("stars"):length() then
			return not to_select:isEquipped()
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == sgs.Self:getPile("stars"):length() then
			local c = LuaQixingCard:clone()
			for _,card in ipairs(cards) do
				c:addSubcard(card)
			end
			return c
		end
		return nil
	end,
}
LuaQixing = sgs.CreateTriggerSkill{
	name = "LuaQixing",
	events = {sgs.EventPhaseEnd},
	view_as_skill = LuaQixingVS,
	can_trigger = function(self, player)
		return player:isAlive() and player:hasSkill(self:objectName()) and player:getPile("stars"):length() > 0
			and player:getPhase() == sgs.Player_Draw
	end,
	on_trigger = function(self, event, player, data)
		player:getRoom():askForUseCard(player, "@@LuaQixing", "@qixing-exchange", -1, sgs.Card_MethodNone)
		return false
	end,
}
LuaQixingStart = sgs.CreateTriggerSkill{
	name = "#LuaQixingStart",
	events = {sgs.DrawInitialCards,sgs.AfterDrawInitialCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.DrawInitialCards then
			room:sendCompulsoryTriggerLog(player, "LuaQixing")
			data:setValue(data:toInt() + 7)
		elseif event == sgs.AfterDrawInitialCards then
			local exchange_card = room:askForExchange(player, "LuaQixing", 7, 7)
			player:addToPile("stars", exchange_card:getSubcards(), false)
			exchange_card:deleteLater()
		end
		return false
	end,
}
LuaQixingAsk = sgs.CreateTriggerSkill{
	name = "#LuaQixingAsk",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			if player:getPile("stars"):length() > 0 and player:hasSkill("LuaKuangfeng") then
				room:askForUseCard(player, "@@LuaKuangfeng", "@kuangfeng-card", -1, sgs.Card_MethodNone)
			end
			if player:getPile("stars"):length() > 0 and player:hasSkill("LuaDawu") then
				room:askForUseCard(player, "@@LuaDawu", "@dawu-card", -1, sgs.Card_MethodNone)
			end
		end
		return false
	end,
}
LuaQixingClear = sgs.CreateTriggerSkill{
	name = "#LuaQixingClear",
	events = {sgs.EventPhaseStart, sgs.Death, sgs.EventLoseSkill},
	can_trigger = function(self, player)
		return player ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if sgs.event == EventPhaseStart or event == sgs.Death then
			if event == sgs.Death then
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() then
					return false
				end
			end
			if not player:getTag("LuaQixing_user"):toBool() then
				return false
			end
			local invoke = false
			if (event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart) or event == sgs.Death then
				invoke = true
			end
			if not invoke then
				return false
			end
			local players = room:getAllPlayers()
			for _,p in sgs.qlist(players) do
				p:loseAllMarks("@gale")
				p:loseAllMarks("@fog")
			end
			player:removeTag("LuaQixing_user")
		elseif event == sgs.EventLoseSkill and data:toString() == "LuaQixing" then
			player:clearOnePrivatePile("stars")
		end
		return false
	end,
}
--[[
	技能名：戚乱
	相关武将：阵·何太后
	描述：每当一名角色的回合结束后，若你于本回合杀死至少一名角色，你可以摸三张牌。
	引用：LuaQiluan 
	状态：1217验证通过
]]--
LuaQiluan = sgs.CreateTriggerSkill{
	name = "LuaQiluan", 
	frequency = sgs.Skill_Frequent, --, NotFrequent, Compulsory, Limited, Wake 
	events = {sgs.Death,sgs.EventPhaseStart}, 
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if (triggerEvent == sgs.Death) then
            local death = data:toDeath()
            if death.who:objectName() ~= player:objectName() then return false end
            local killer = death.damage.from
            local current = room:getCurrent();
            if killer and current and (current:isAlive() or death.who == current)
                and current:getPhase() ~= sgs.Player_NotActive then
                killer:addMark(self:objectName())
			end
        else 
            if player:getPhase() == sgs.Player_NotActive then
                local hetaihous = sgs.SPlayerList()
                for _,p in sgs.qlist(room:getAllPlayers()) do
                    if p:getMark(self:objectName()) > 0 and player:hasSkill(self:objectName()) then
                        hetaihous:append(p)
					end
                    p:setMark(self:objectName(), 0);
                end

                for _,p in sgs.qlist(hetaihous)do
                    if room:askForSkillInvoke(p, self:objectName()) then
                        p:drawCards(3)
					end
                end
            end
        end
        return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能名：奇才（锁定技）
	相关武将：标准·黄月英、JSP·黄月英
	描述：你使用锦囊牌无距离限制。你装备区里除坐骑牌外的牌不能被其他角色弃置。
	状态：尚未完成
	备注：前半部分与奇才一样，后半部分被写入源码，详见Player::canDiscard
]]--
--[[
	技能名：奇才（锁定技）
	相关武将：怀旧-标准·黄月英-旧、SP·台版黄月英
	描述：你使用锦囊牌时无距离限制。
	引用：LuaNosQicai
	状态：0405验证通过
]]--
LuaNosQicai = sgs.CreateTargetModSkill{
	name = "LuaNosQicai" ,
	pattern = "TrickCard" ,
	distance_limit_func = function(self, from, card)
		if from:hasSkill(self:objectName()) then
			return 1000
		else
			return 0
		end
	end
}
--[[
	技能名：奇策
	相关武将：二将成名·荀攸
	描述：出牌阶段限一次，你可以将你的所有手牌（至少一张）当任意一张非延时锦囊牌使用。
	引用：LuaQice
	状态：0405验证通过
]]--
LuaQiceCard = sgs.CreateSkillCard{
	name = "LuaQiceCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select)
		local card = sgs.Self:getTag("LuaQice"):toCard()
		card:addSubcards(sgs.Self:getHandcards())
		card:setSkillName(self:objectName())
		if card and card:targetFixed() then
			return false
		end
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		return card and card:targetFilter(qtargets, to_select, sgs.Self) 
			and not sgs.Self:isProhibited(to_select, card, qtargets)
	end,
	feasible = function(self, targets)
		local card = sgs.Self:getTag("LuaQice"):toCard()
		card:addSubcards(sgs.Self:getHandcards())
		card:setSkillName(self:objectName())
		local qtargets = sgs.PlayerList()
		for _, p in ipairs(targets) do
			qtargets:append(p)
		end
		if card and card:canRecast() and #targets == 0 then
			return false
		end
		return card and card:targetsFeasible(qtargets, sgs.Self)
	end,	
	on_validate = function(self, card_use)
		local xunyou = card_use.from
		local room = xunyou:getRoom()
		local use_card = sgs.Sanguosha:cloneCard(self:getUserString())
		use_card:addSubcards(xunyou:getHandcards())
		use_card:setSkillName(self:objectName())
		local available = true
		for _,p in sgs.qlist(card_use.to) do
			if xunyou:isProhibited(p,use_card)	then
				available = false
				break
			end
		end
		available = available and use_card:isAvailable(xunyou)
		if not available then return nil end
		return use_card		
	end,
}
LuaQice = sgs.CreateViewAsSkill{
	name = "LuaQice",
	n = 0,
	view_filter = function(self, selected, to_select)
		return false
	end,
	view_as = function(self, cards)
		local c = sgs.Self:getTag("LuaQice"):toCard()
		if c then
			local card = LuaQiceCard:clone()
			card:setUserString(c:objectName())	
			return card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#LuaQice")) and (not player:isKongcheng())
	end,
}
LuaQice:setGuhuoDialog("r")
--[[
	技能名：千幻
	相关武将：阵·于吉
	描述：每当一名角色受到伤害后，该角色可以将牌堆顶的一张牌置于你的武将牌上。每当一名角色被指定为基本牌或锦囊牌的唯一目标时，若该角色同意，你可以将一张“千幻牌”置入弃牌堆：若如此做，取消该目标。
	引用：LuaQianhuan
	状态：1217验证通过
]]--
LuaQianhuan = sgs.CreateTriggerSkill{
	name = "LuaQianhuan", 
	events = {sgs.Damaged,sgs.TargetConfirming}, 
	on_trigger = function(self, triggerEvent, player, data)
		local room = player:getRoom()
		if triggerEvent == sgs.Damaged and player:isAlive() then
            local yuji = room:findPlayerBySkillName(self:objectName())
            if yuji and room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("choice:" .. yuji:objectName()))then
                if (yuji:objectName() ~= player:objectName()) then
                    room:notifySkillInvoked(yuji, self:objectName());
                end
                local id = room:drawCard()
                local suit = sgs.Sanguosha:getCard(id):getSuit()
                local duplicate = false;
                for _,card_id in sgs.qlist(yuji:getPile("sorcery")) do
                    if (sgs.Sanguosha:getCard(card_id):getSuit() == suit) then
                        duplicate = true
                        break
                    end
                end
                yuji:addToPile("sorcery", id)
                if (duplicate) then
                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE,"", self:objectName(), "")
                    room:throwCard(sgs.Sanguosha:getCard(id), reason, nil)
                end
            end
        elseif triggerEvent == sgs.TargetConfirming then
            local use = data:toCardUse()
            if (not use.card) or use.card:getTypeId() == sgs.Card_TypeEquip or use.card:getTypeId() == sgs.Card_TypeSkill then return false end
            if use.to:length() ~= 1 then return false end
            local yuji = room:findPlayerBySkillName(self:objectName());
            if yuji == nil or yuji:getPile("sorcery"):isEmpty() then return false end
            if room:askForSkillInvoke(yuji, self:objectName(), data) then
                if (yuji:objectName() == player:objectName() or room:askForChoice(player, self:objectName(), "accept+reject", data) == "accept") then
                    local ids = yuji:getPile("sorcery")
                    local id = -1
                    if (ids:length() > 1) then
                        room:fillAG(ids, yuji)
                        id = room:askForAG(yuji, ids, false, self:objectName())
                        room:clearAG(yuji)
                    else
                        id = ids:first()
                    end
                    local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", self:objectName(),"")
                    room:throwCard(sgs.Sanguosha:getCard(id), reason,nil);
                    use.to = sgs.SPlayerList()
                    data:setValue(use)
                end
            end
        end
        return false;
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能名：奇袭
	相关武将：标准·甘宁、SP·台版甘宁
	描述：你可以将一张黑色牌当【过河拆桥】使用。
	引用：LuaQixi
	状态：1217验证通过
]]--
LuaQixi = sgs.CreateOneCardViewAsSkill{
	name = "LuaQixi", 
	filter_pattern = ".|black",
	view_as = function(self, card) 
		local acard = sgs.Sanguosha:cloneCard("dismantlement", card:getSuit(), card:getNumber())
		acard:addSubcard(card:getId())
		acard:setSkillName(self:objectName())
		return acard
	end, 
}
--[[
	技能名：谦逊（锁定技）
	相关武将：标准·陆逊、国战·陆逊
	描述：你不能被选择为【顺手牵羊】和【乐不思蜀】的目标。
	引用：LuaNosQianxun
	状态：0405验证通过
]]--
LuaNosQianxun = sgs.CreateProhibitSkill{
	name = "LuaNosQianxun",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("Snatch") or card:isKindOf("Indulgence"))
	end
}
--[[
	技能名：潜袭
	相关武将：一将成名2012·马岱
	描述：准备阶段开始时，你可以进行一次判定，然后令一名距离为1的角色不能使用或打出与判定结果颜色相同的手牌，直到回合结束。
	引用：LuaQianxi、LuaQianxiClear
	状态：1217验证通过
]]--
LuaQianxi = sgs.CreateTriggerSkill{
	name = "LuaQianxi" ,
	events = {sgs.EventPhaseStart,sgs.FinishJudge} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.EventPhaseStart) and (player and player:isAlive() and player:hasSkill(self:objectName())) and (player:getPhase() == sgs.Player_Start) then
			if room:askForSkillInvoke(player, self:objectName()) then
			local judge = sgs.JudgeStruct()
				judge.reason = self:objectName()
				judge.play_animation = false
				judge.who = player
				room:judge(judge)
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if (judge.reason ~= self:objectName()) or (not player:isAlive()) then return false end
			local color
			if judge.card:isRed() then
				color = "red"
			else
				color = "black"
			end
			player:setTag(self:objectName(), sgs.QVariant(color))
			local to_choose = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if player:distanceTo(p)  == 1 then
					to_choose:append(p)
				end
			end
			if to_choose:isEmpty() then return false end
			local victim = room:askForPlayerChosen(player, to_choose, self:objectName())
			local pattern = ".|" .. color .. "|.hand$0"
			room:setPlayerFlag(victim, "LuaQianxiTarget")
			room:addPlayerMark(victim, "@qianxi_" .. color)
			room:setPlayerCardLimitation(victim, "use,response", pattern, false)
		end
		return false
	end ,
	can_trigger = function(self,target)
		return target
	end
}
LuaQianxiClear = sgs.CreateTriggerSkill{
	name = "#LuaQianxi-clear" ,
	events = {sgs.EventPhaseChanging, sgs.Death} ,
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then return false end
		end
		local color = player:getTag("LuaQianxi"):toString()
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasFlag("LuaQianxiTarget") then
				room:removePlayerCardLimitation(p, "use,response", ".|" .. color .. ".|hand$0")
				room:setPlayerMark(p, "@qianxi_" .. color, 0)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return not (target:getTag("LuaQianxi"):toString() == "")
	end
}
--[[
	技能名：潜袭
	相关武将：怀旧-一将2·马岱-旧
	描述：每当你使用【杀】对距离为1的目标角色造成伤害时，你可以进行一次判定，若判定结果不为红桃，你防止此伤害，改为令其减1点体力上限。
	引用：LuaNosQianxi
	状态：1217验证通过
]]--
LuaNosQianxi = sgs.CreateTriggerSkill{
	name = "LuaNosQianxi" ,
	events = {sgs.DamageCaused} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if (player:distanceTo(damage.to) == 1) and damage.card and damage.card:isKindOf("Slash")
				and damage.by_user and (not damage.chain) and (not damage.transfer) then
			if player:askForSkillInvoke(self:objectName(), data) then
				local room = player:getRoom()
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|heart"
				judge.good = false
				judge.who = player
				judge.reason = self:objectName()
				room:judge(judge)
				if judge:isGood() then
					room:loseMaxHp(damage.to)
					return true
				end
			end
		end
		return false
	end
}
--[[
	技能名：强袭
	相关武将：火·典韦
	描述：出牌阶段限一次，你可以失去1点体力或弃置一张武器牌，并选择攻击范围内的一名角色：若如此做，你对该角色造成1点伤害。  
	引用：LuaQiangxi
	状态：0405验证通过
]]--

LuaQiangxiCard = sgs.CreateSkillCard{
	name = "LuaQiangxiCard", 
	filter = function(self, targets, to_select) 
		if #targets ~= 0 or to_select:objectName() == sgs.Self:objectName() then return false end--根据描述应该可以选择自己才对
		local rangefix = 0
		if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
		end
		return sgs.Self:inMyAttackRange(to_select, rangefix);
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		if self:getSubcards():isEmpty() then 
			room:loseHp(effect.from)
		end
		room:damage(sgs.DamageStruct(self:objectName(), effect.from, effect.to))
	end
}
LuaQiangxi = sgs.CreateViewAsSkill{
	name = "LuaQiangxi", 
	n = 1, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaQiangxiCard")
	end,
	view_filter = function(self, selected, to_select)
		return #selected == 0 and to_select:isKindOf("Weapon") and not sgs.Self:isJilei(to_select)
	end, 
	view_as = function(self, cards) 
		if #cards == 0 then
			return LuaQiangxiCard:clone()
		elseif #cards == 1 then
			local card = LuaQiangxiCard:clone()
			card:addSubcard(cards[1])
			return card
		else 
			return nil
		end
	end
}
--[[
	技能名：枪舞
	相关武将：SP·星彩
	描述：出牌阶段限一次，你可以进行判定，直到回合结束，你使用点数比结果小的【杀】无距离限制，且你使用的点数比结果大的【杀】不计入限制的使用次数。
	引用：LuaQiangwu、LuaQiangwutarmod
	状态：1217验证通过
]]--
LuaQiangwucard = sgs.CreateSkillCard{
	name = "LuaQiangwu" ,
	target_fixed = true ,
	on_use = function(self, room, source)
		if source:getMark("LuaQiangwu") > 0 then
			room:askForUseCard(source, "Slash|.|"..(source:getMark("LuaQiangwu")+1).."~", "@LuaQiangwu", -1, sgs.Card_MethodUse, false)
		else
			local judge = sgs.JudgeStruct()
			judge.who = source
			judge.reason = "LuaQiangwu"
			judge.play_animation = false
			room:judge(judge)
		end
	end
}
LuaQiangwuvs = sgs.CreateZeroCardViewAsSkill{
	name = "LuaQiangwu" ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaQiangwu") or player:getMark("LuaQiangwu") > 0
	end ,
	view_as = function()
		return LuaQiangwucard:clone()
	end
}
LuaQiangwu = sgs.CreateTriggerSkill{
	name = "LuaQiangwu" ,
	view_as_skill = LuaQiangwuvs ,
	events = {sgs.FinishJudge, sgs.EventPhaseStart, sgs.PreCardUsed},
	can_trigger = function(self, player)
		return player
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == "LuaQiangwu" then
				room:setPlayerMark(player, "LuaQiangwu", judge.card:getNumber())
			end
		elseif event == sgs.EventPhaseStart then
			if (player:getPhase() == sgs.Player_NotActive) and (player:getMark("LuaQiangwu") > 0) then
				room:setPlayerMark(player, "LuaQiangwu", 0)
			end
		elseif event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") and (player:getMark("LuaQiangwu") > 0) 
					and (use.card:getNumber() > player:getMark("LuaQiangwu")) then
				if (use.m_addHistory) then
					room:addPlayerHistory(player, use.card:getClassName(), -1)
					use.m_addHistory = false
					data:setValue(use)
				end
			end
		end
		return false
	end ,
}
LuaQiangwutarmod = sgs.CreateTargetModSkill{
	name = "#LuaQiangwu-tarmod" ,
	distance_limit_func = function(self, player, card)
		local n = player:getMark("LuaQiangwu")
		if (n > 0) and (n > card:getNumber()) and (card:getNumber() ~= 0) then
			return 998
		end
		return 0
	end
}
--[[
	技能名：巧变
	相关武将：山·张郃
	描述：除准备阶段和结束阶段的阶段开始前，你可以弃置一张手牌：若如此做，你跳过该阶段。若以此法跳过摸牌阶段，你可以依次获得一至两名其他角色的各一张手牌；若以此法跳过出牌阶段，你可以将场上的一张牌置于另一名角色相应的区域内。 
	引用：LuaQiaobian
	状态：0405验证通过
]]--
LuaQiaobianCard = sgs.CreateSkillCard{
	name = "LuaQiaobianCard",
	feasible = function(self, targets)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			return #targets <= 2 and #targets > 0
		elseif phase == sgs.Player_Play then
			return #targets == 1
		end
		return false
	end,
	filter = function(self, targets, to_select)
		local phase = sgs.Self:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			return #targets < 2 and not to_select:isKongcheng() and to_select:objectName() ~= sgs.Self:objectName()
		elseif phase == sgs.Player_Play then
			return #targets == 0 and (to_select:getJudgingArea():length() > 0 or to_select:getEquips():length() > 0)
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local phase = source:getMark("qiaobianPhase")
		if phase == sgs.Player_Draw then
			if #targets == 0 then return end
			for _, target in pairs(targets)do
				if source:isAlive() and target:isAlive() then
					room:cardEffect(self, source, target)
				end
			end
		elseif phase == sgs.Player_Play then
			if #targets == 0 then return end
			local from = targets[1]
			if not from:hasEquip() and from:getJudgingArea():length() == 0 then return end
			local card_id = room:askForCardChosen(source, from, "ej", self:objectName())
			local card = sgs.Sanguosha:getCard(card_id)
			local place = room:getCardPlace(card_id)
			local equip_index = -1
			if place == sgs.Player_PlaceEquip then
				local equip = card:getRealCard():toEquipCard()
				equip_index = equip:location()
			end
			local tos = sgs.SPlayerList()
			local list = room:getAlivePlayers()
			for _, p in sgs.qlist(list) do
				if equip_index ~= -1 then
					if not p:getEquip(equip_index) then
						tos:append(p)
					end
				else
					if not source:isProhibited(p, card) and not p:containsTrick(card:objectName()) then
						tos:append(p)
					end
				end
			end
			local tag = sgs.QVariant()
			tag:setValue(from)
			room:setTag("QiaobianTarget", tag)
			local to = room:askForPlayerChosen(source, tos, self:objectName(), "@qiaobian-to" .. card:objectName())
			if to then
				room:moveCardTo(card, from, to, place, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TRANSFER, source:objectName(), self:objectName(), ""))
			end
			room:removeTag("QiaobianTarget")
		end
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then
			local card_id = room:askForCardChosen(effect.from, effect.to, "h", "LuaQiaobian")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, false)
		end
	end,
}
LuaQiaobianVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaQiaobian",
	response_pattern = "@@LuaQiaobian",
	view_as = function(self, cards)
		return LuaQiaobianCard:clone()
	end
}
LuaQiaobian = sgs.CreateTriggerSkill{
	name = "LuaQiaobian",
	events = {sgs.EventPhaseChanging},
	view_as_skill = LuaQiaobianVS,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName()) and target:isAlive() and target:canDiscard(target, "h")
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		room:setPlayerMark(player, "qiaobianPhase", change.to)
		local index = 0
		if change.to == sgs.Player_Judge then
			index = 1
		elseif change.to == sgs.Player_Draw then
			index = 2
		elseif change.to == sgs.Player_Play then
			index = 3
		elseif change.to == sgs.Player_Discard then
			index = 4
		end
		local discard_prompt = string.format("#qiaobian-%d", index)
		local use_prompt = string.format("@qiaobian-%d", index)
		if index > 0 and room:askForDiscard(player, self:objectName(), 1, 1, true, false, discard_prompt) then
			if not player:isAlive() then return false end
			if not player:isSkipped(change.to) and (index == 2 or index == 3) then
				room:askForUseCard(player, "@@LuaQiaobian", use_prompt, index)
			end
			player:skip(change.to)
		end
		return false
	end
}
--[[
	技能名：巧说
	相关武将：一将成名2013·简雍
	描述：出牌阶段开始时，你可以与一名角色拼点：若你赢，本回合你使用的下一张基本牌或非延时类锦囊牌可以增加一个额外目标（无距离限制）或减少一个目标（若原有多余一个目标）；若你没赢，你不能使用锦囊牌，直到回合结束。
	引用：LuaQiaoshui、LuaQiaoshuiTargetMod、LuaQiaoshuiUse
	状态：1217验证通过
]]--
---------------------Ex借刀杀人技能卡---------------------
function targetsTable2QList(thetable)
	local theqlist = sgs.PlayerList()
	for _, p in ipairs(thetable) do
		theqlist:append(p)
	end
	return theqlist
end
LuaExtraCollateralCard = sgs.CreateSkillCard{
	name = "LuaExtraCollateralCard" ,
	filter = function(self, targets, to_select)
		local coll = sgs.Card_Parse(sgs.Self:property("extra_collateral"):toString())
		if (not coll) then return false end
		local tos = sgs.Self:property("extra_collateral_current_targets"):toString():split("+")
		if (#targets == 0) then
			return (not table.contains(tos, to_select:objectName())) 
					and (not sgs.Self:isProhibited(to_select, coll)) and coll:targetFilter(targetsTable2QList(targets), to_select, sgs.Self)
		else
			return coll:targetFilter(targetsTable2QList(targets), to_select, sgs.Self)
		end
	end ,
	about_to_use = function(self, room, cardUse)
		local killer = cardUse.to:first()
		local victim = cardUse.to:last()
		killer:setFlags("ExtraCollateralTarget")
		local _data = sgs.QVariant()
		_data:setValue(victim)
		killer:setTag("collateralVictim", _data)
	end
}
----------------------------------------------------------
LuaQiaoshuiCard = sgs.CreateSkillCard{
	name = "LuaQiaoshuiCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (not to_select:isKongcheng()) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_use = function(self, room, source, targets)
		local success = source:pindian(targets[1], "LuaQiaoshui", nil)
		if (success) then
			source:setFlags("LuaQiaoshuiSuccess")
		else
			room:setPlayerCardLimitation(source, "use", "TrickCard", true)
		end
	end
}
LuaQiaoshuiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaQiaoshui" ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return string.find(pattern, "@@LuaQiaoshui")
	end ,
	view_as = function()
		local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
		if string.find(pattern, "!") then
			return LuaExtraCollateralCard:clone()
		else
			return LuaQiaoshuiCard:clone()
		end
	end
}
LuaQiaoshui = sgs.CreatePhaseChangeSkill{
	name = "LuaQiaoshui" ,
	view_as_skill = LuaQiaoshuiVS ,
	on_phasechange = function(self, jianyong)
		if (jianyong:getPhase() == sgs.Player_Play) and (not jianyong:isKongcheng()) then
			local room = jianyong:getRoom()
			local can_invoke = false
			local other_players = room:getOtherPlayers(jianyong)
			for _, player in sgs.qlist(other_players) do
				if not player:isKongcheng() then
					can_invoke = true
					break
				end
			end
			if (can_invoke) then
				room:askForUseCard(jianyong, "@@LuaQiaoshui", "@qiaoshui-card", 1)
			end
		end
		return false
	end ,
}
LuaQiaoshuiUse = sgs.CreateTriggerSkill{
	name = "#LuaQiaoshui-use" ,
	events = {sgs.PreCardUsed} ,
	on_trigger = function(self, event, jianyong, data)
		if not jianyong:hasFlag("LuaQiaoshuiSuccess") then return false end
		local use = data:toCardUse()
		if (use.card:isNDTrick() or use.card:isKindOf("BasicCard")) then
			local room = jianyong:getRoom()
			jianyong:setFlags("-LuaQiaoshuiSuccess")
			if (sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_PLAY) then return false end
			local available_targets = sgs.SPlayerList()
			if (not use.card:isKindOf("AOE")) and (not use.card:isKindOf("GlobalEffect")) then
				room:setPlayerFlag(jianyong, "LuaQiaoshuiExtraTarget")
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if (use.to:contains(p) or room:isProhibited(jianyong, p, use.card)) then continue end
					if (use.card:targetFixed()) then
						if (not use.card:isKindOf("Peach")) or (p:isWounded()) then
							available_targets:append(p)
						end
					else
						if (use.card:targetFilter(sgs.PlayerList(), p, jianyong)) then
							available_targets:append(p)
						end
					end
				end
				room:setPlayerFlag(jianyong, "-LuaQiaoshuiExtraTarget")
			end
			local choices = {}
			table.insert(choices, "cancel")
			if (use.to:length() > 1) then table.insert(choices, 1, "remove") end
			if (not available_targets:isEmpty()) then table.insert(choices, 1, "add") end
			if #choices == 1 then return false end
			local choice = room:askForChoice(jianyong, "LuaQiaoshui", table.concat(choices, "+"), data)
			if (choice == "cancel") then
				return false
			elseif choice == "add" then
				local extra = nil
				if not use.card:isKindOf("Collateral") then
					extra = room:askForPlayerChosen(jianyong, available_targets, "LuaQiaoshui", "@qiaoshui-add:::" .. use.card:objectName())
				else
					local tos = {}
					for _, t in sgs.qlist(use.to) do
						table.insert(tos, t:objectName())
					end
					room:setPlayerProperty(jianyong, "extra_collateral", sgs.QVariant(use.card:toString()))
					room:setPlayerProperty(jianyong, "extra_collateral_current_targets", sgs.QVariant(table.concat(tos, "+")))
					room:askForUseCard(jianyong, "@@LuaQiaoshui!", "@qiaoshui-add:::collateral")
					room:setPlayerProperty(jianyong, "extra_collateral", sgs.QVariant(""))
					room:setPlayerProperty(jianyong, "extra_collateral_current_targets", sgs.QVariant("+"))
					for _, p in sgs.qlist(room:getOtherPlayers(jianyong)) do
						if p:hasFlag("ExtraCollateralTarget") then
							p:setFlags("-ExtraColllateralTarget")
							extra = p
							break
						end
					end
					if (extra == nil) then
						extra = available_targets:at(math.random(available_targets:length()) - 1)
						local victims = sgs.SPlayerList()
						for _, p in sgs.qlist(room:getOtherPlayers(extra)) do
							if (extra:canSlash(p) and not (p:objectName() == jianyong:objectName() and p:hasSkill("kongcheng") and p:isLastHandCard(use.card, true))) then
								victims:append(p)
							end
						end
						assert(not victims:isEmpty())
						local _data = sgs.QVariant()
						_data:setValue(victims:at(math.random(victims:length()) - 1))
						extra:setTag("collateralVictim", _data)
					end
				end
				use.to:append(extra)
				room:sortByActionOrder(use.to)
			else
				local removed = room:askForPlayerChosen(jianyong, use.to, "LuaQiaoshui", "@qiaoshui-remove:::" .. use.card:objectName())
				use.to:removeOne(removed)
			end
		end
		data:setValue(use)
		return false
	end ,
}
LuaQiaoshuiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaQiaoshui-target" ,
	pattern = "Slash,TrickCard+^DelayedTrick" ,
	distance_limit_func = function(self, from)
		if (from:hasFlag("LuaQiaoshuiExtraTarget")) then
			return 1000
		end
		return 0
	end
}

--[[
	技能名：琴音
	相关武将：神·周瑜
	描述：弃牌阶段结束时，若你于本阶段内弃置了至少两张你的牌，你可以选择一项：令所有角色各回复1点体力，或令所有角色各失去1点体力。
	引用：LuaQinyin
	状态：0405验证通过
]]--	
LuaQinyin = sgs.CreateTriggerSkill{
	name = "LuaQinyin" ,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseEnd, sgs.EventPhaseChanging} ,
	can_trigger = function(self, target)
		return target ~= nil
	end ,
	on_trigger = function(self, event, shenzhouyu, data)
		local room = shenzhouyu:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if shenzhouyu:getPhase() == sgs.Player_Discard and move.from and move.from:objectName() == shenzhouyu:objectName() and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
				shenzhouyu:addMark("qinyin", move.card_ids:length())
			end
		elseif event == sgs.EventPhaseEnd and shenzhouyu:getPhase() == sgs.Player_Discard and shenzhouyu:getMark("qinyin") >= 2 then
			local choices = {"down+cancel"}
			local all_players = room:getAllPlayers()
			for _, player in sgs.qlist(all_players) do
				if player:isWounded() then
					table.insert(choices, "up")
					break
				end
			end
			local result = room:askForChoice(shenzhouyu, self:objectName(), table.concat(choices, "+"))
			if result == "cancel" then
				return
			else
				room:notifySkillInvoked(shenzhouyu, "qinyin")
				if result == "up" then
					for _, player in sgs.qlist(all_players) do
						room:recover(player, sgs.RecoverStruct(shenzhouyu))
					end
				elseif result == "down" then
					for _, player in sgs.qlist(all_players) do
						room:loseHp(player)
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			shenzhouyu:setMark("qinyin", 0)
		end
		return false
	end
}
--[[
	技能名：青囊
	相关武将：标准·华佗
	描述： 出牌阶段限一次，你可以弃置一张手牌并选择一名已受伤的角色，令该角色回复1点体力。
	引用：LuaQingnang
	状态：1217验证通过
]]--
LuaQingnangCard = sgs.CreateSkillCard{
	name = "LuaQingnangCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:isWounded())
	end,
	feasible = function(self, targets)
		if #targets == 1 then
			return targets[1]:isWounded()
		end
		return #targets == 0 and sgs.Self:isWounded()
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1] or source
		local effect = sgs.CardEffectStruct()
		effect.card = self
		effect.from = source
		effect.to = target
		room:cardEffect(effect)
	end,
	on_effect = function(self, effect)
		local dest = effect.to
		local room = dest:getRoom()
		local recover = sgs.RecoverStruct()
		recover.card = self
		recover.who = effect.from
		room:recover(dest, recover)
	end
}
LuaQingnang = sgs.CreateOneCardViewAsSkill{
	name = "LuaQingnang", 
	filter_pattern = ".|.|.|hand!",
	view_as = function(self, card) 
		local qnc = LuaQingnangCard:clone()
		qnc:addSubcard(card)
		qnc:setSkillName(self:objectName())
		return qnc
	end, 
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "h") and not player:hasUsed("#LuaQingnangCard")
	end, 
}

--[[
	技能名：倾城
	相关武将：国战·邹氏
	描述：出牌阶段，你可以弃置一张装备牌，令一名其他角色的一项武将技能无效，直到其下回合开始。
	引用：LuaQingcheng
	状态：1217验证通过
]]--
local json = require ("json")
LuaQingchengCard = sgs.CreateSkillCard{
	name = "LuaQingchengCard", 
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select) 
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	about_to_use = function(self,room,card_use)
		local player,to = card_use.from,card_use.to:first()
		local log = sgs.LogMessage()
		log.from = player
		log.to = card_use.to
		log.type = "#UseCard"
		log.card_str = card_use.card:toString()
		room:sendLog(log)
		local skill_list = {}
		local Qingchenglist = to:getTag("Qingcheng"):toString():split("+") or {}
		for _,skill in sgs.qlist(to:getVisibleSkillList()) do
			if (not table.contains(skill_list,skill:objectName())) and not skill:isAttachedLordSkill() then
				table.insert(skill_list,skill:objectName())
			end
		end
		table.removeTable(skill_list,Qingchenglist)
		local skill_qc = ""
		if (#skill_list > 0) then
			skill_qc = room:askForChoice(player, "LuaQingcheng", table.concat(skill_list,"+"))
		end
		if (skill_qc ~= "") then
			table.insert(Qingchenglist,skill_qc)
			to:setTag("Qingcheng",sgs.QVariant(table.concat(Qingchenglist,"+")))
			room:addPlayerMark(to, "Qingcheng" .. skill_qc)
			for _,p in sgs.qlist(room:getAllPlayers())do
				room:filterCards(p, p:getCards("he"), true)
			end
			local jsonValue = {
				8
			}
			room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
		end
		local data = sgs.QVariant()
		data:setValue(card_use)
		local thread = room:getThread()
		thread:trigger(sgs.PreCardUsed, room, player, data)
		card_use = data:toCardUse()
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_THROW, player:objectName(), "", card_use.card:getSkillName(), "")
		room:moveCardTo(self, player, nil, sgs.Player_DiscardPile, reason, true)
		thread:trigger(sgs.CardUsed, room, player, data)
		thread:trigger(sgs.CardFinished, room, player, data)
	end,
}
LuaQingchengVs = sgs.CreateOneCardViewAsSkill{
	name = "LuaQingcheng", 
	filter_pattern = "EquipCard",
	view_as = function(self, card) 
		local qcc = LuaQingchengCard:clone()
		qcc:addSubcard(card)
		qcc:setSkillName(self:objectName())
		return qcc
	end, 
	enabled_at_play = function(self, player)
		return player:canDiscard(player, "he")
	end, 
}
LuaQingcheng = sgs.CreateTriggerSkill{
	name = "LuaQingcheng", 
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaQingchengVs,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_RoundStart then
			local room = player:getRoom()
            local Qingchenglist = player:getTag("Qingcheng"):toString():split("+")
            if #Qingchenglist == 0 then return false end
            for _,skill_name in pairs(Qingchenglist)do
                room:setPlayerMark(player, "Qingcheng" .. skill_name, 0);
            end
            player:removeTag("Qingcheng")
            for _,p in sgs.qlist(room:getAllPlayers())do
                room:filterCards(p, p:getCards("he"), true)
			end
            local jsonValue = {
				8
			}
			room:doBroadcastNotify(sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
        end
        return false
	end,
	can_trigger = function(self, target)
		return target
	end,
	priority = 6
}
--[[
	技能名：倾国
	相关武将：标准·甄姬、SP·甄姬、SP·台版甄姬
	描述：你可以将一张黑色手牌当【闪】使用或打出。  
	引用：LuaQingguo
	状态：0405证通过
]]--
LuaQingguo = sgs.CreateOneCardViewAsSkill{
	name = "LuaQingguo", 
	response_pattern = "jink",
	filter_pattern = ".|black|.|hand",
	response_or_use = true,
	view_as = function(self, card) 
		local jink = sgs.Sanguosha:cloneCard("jink",card:getSuit(),card:getNumber())
		jink:setSkillName(self:objectName())
		jink:addSubcard(card:getId())
		return jink
	end
}
--[[
	技能名：倾国1V1
	相关武将：1v1·甄姬1v1
	描述：你可以将一张装备区的牌当【闪】使用或打出。   
	引用：LuaKOFQingguo
	状态：0405验证通过
]]--
LuaKOFQingguo = sgs.CreateOneCardViewAsSkill{
	name = "LuaKOFQingguo", 
	filter_pattern = ".|.|.|equipped",
	view_as = function(self, card) 
		local jink = sgs.Sanguosha:cloneCard("jink",card:getSuit(),card:getNumber())
		jink:setSkillName(self:objectName());
		jink:addSubcard(card:getId());
		return jink
	end,
	enabled_at_play = function(self, target)
		return false
	end,
	enabled_at_response = function(self, target, pattern)
		return pattern == "jink" and target:getEquips():length() > 0
	end
}
--[[
	技能名：清俭
	相关武将：界限突破·夏侯惇
	描述：每当你于摸牌阶段外获得手牌后，你可以将其中至少一张牌任意分配给其他角色。    
	引用：LuaQingjian
	状态：0405验证通过
]]--
LuaQingjian = sgs.CreateTriggerSkill{
	name = "LuaQingjian",
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local room = player:getRoom()
		if not room:getTag("FirstRound"):toBool() and player:getPhase() ~= sgs.Player_Draw and move.to and move.to:objectName() == player:objectName() then
			local ids = sgs.IntList()
			for _,id in sgs.qlist(move.card_ids) do
				if room:getCardOwner(id) == player and room:getCardPlace(id) == sgs.Player_PlaceHand then
					ids:append(id)
				end
			end
			if ids:isEmpty() then return false end
			player:setTag("QingjianCurrentMoveSkill", sgs.QVariant(move.reason.m_skillName))
			while room:askForYiji(player, ids, self:objectName(), false, false, true, -1, sgs.SPlayerList(), sgs.CardMoveReason(), "@LuaQingjian-distribute", true) do
				if player:isDead() then return false end
			end
		end
		return false
	end
}
--[[
	技能名：求援
	相关武将：一将成名2013·伏皇后
	描述：每当你成为【杀】的目标时，你可以令一名除此【杀】使用者外的有手牌的其他角色正面朝上交给你一张手牌。若此牌不为【闪】，该角色也成为此【杀】的目标。
	引用：LuaQiuyuan
	状态：1217验证通过
]]--
LuaQiuyuan = sgs.CreateTriggerSkill{
	name = "LuaQiuyuan" ,
	events = {sgs.TargetConfirming} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") then
			local room = player:getRoom()
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if (not p:isKongcheng()) and (p:objectName() ~= use.from:objectName()) then
					targets:append(p)
				end
			end
			if targets:isEmpty() then return false end
			local target = room:askForPlayerChosen(player, targets, self:objectName(), "qiuyuan-invoke", true, true)
			if target then
				local card = nil
				if target:getHandcardNum() > 1 then
					card = room:askForCard(target, ".!", "@qiuyuan-give:" .. player:objectName(), data, sgs.Card_MethodNone)
					if not card then
						card = target:getHandcards():at(math.random(0, target:getHandcardNum() - 1))
					end
				else
					card = target:getHandcards():first()
				end
				player:obtainCard(card)
				room:showCard(player, card:getEffectiveId())
				if not card:isKindOf("Jink") then
					if use.from:canSlash(target, use.card, false) then
						use.to:append(target)
						room:sortByActionOrder(use.to)
						data:setValue(use)
						room:getThread():trigger(sgs.TargetConfirming, room, target, data)
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：驱虎
	相关武将：火·荀彧
	描述：出牌阶段限一次，你可以与一名当前的体力值大于你的角色拼点：若你赢，其对其攻击范围内你选择的另一名角色造成1点伤害。若你没赢，其对你造成1点伤害。
	引用：LuaQuhu
	状态：1217验证通过
]]--
LuaQuhuCard = sgs.CreateSkillCard{
	name = "LuaQuhuCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:getHp() > sgs.Self:getHp()) and (not to_select:isKongcheng())
	end,
	on_use = function(self, room, source, targets)
		local tiger = targets[1]
		local success = source:pindian(tiger, self:objectName(), nil)
		if success then
			local players = room:getOtherPlayers(tiger)
			local wolves = sgs.SPlayerList()
			for _,player in sgs.qlist(players) do
				if tiger:inMyAttackRange(player) then
					wolves:append(player)
				end
			end
			if wolves:isEmpty() then
				return
			end
			local wolf = room:askForPlayerChosen(source, wolves, self:objectName(), "@quhu-damage:" .. tiger:objectName())
			room:damage(sgs.DamageStruct(self:objectName(), tiger, wolf))
		else
			room:damage(sgs.DamageStruct(self:objectName(), tiger, source))
		end
	end
}
LuaQuhu = sgs.CreateZeroCardViewAsSkill{
	name = "LuaQuhu",
	view_as = function(self, cards) 
		return LuaQuhuCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#LuaQuhuCard")) and not player:isKongcheng()
	end, 
}

--[[
	技能名：权计
	相关武将：一将成名·钟会
	描述：每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于武将牌上，称为“权”。每有一张“权”，你的手牌上限+1。 
	引用：LuaQuanji、LuaQuanjiKeep
	状态：0405证通过
]]--
LuaQuanji = sgs.CreateMasochismSkill{
	name = "LuaQuanji",
	frequency = sgs.Skill_Frequent,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local x = damage.damage
		for i = 0, x - 1, 1 do
			if player:askForSkillInvoke(self:objectName()) then
				room:drawCards(player, 1, self:objectName())
				if not player:isKongcheng() then
					local card_id = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					if player:getHandcardNum() == 1 then
						card_id = player:handCards():first()
						room:getThread():delay()
					else
						card_id = room:askForExchange(player, self:objectName(), 1, 1, false, "QuanjiPush"):getSubcards():first()
					end
					player:addToPile("power", card_id)
				end
			end
		end
	end
}
LuaQuanjiKeep = sgs.CreateMaxCardsSkill{
	name = "#LuaQuanji-keep",
	frequency = sgs.Skill_Frequent,
	extra_func = function(self, target)
		if target:hasSkill(self:objectName()) then
			return target:getPile("power"):length()
		else
			return 0
		end
	end
}
	技能名：权计
	相关武将：一将成名·钟会
	描述：每当你受到1点伤害后，你可以摸一张牌，然后将一张手牌置于你的武将牌上，称为“权”；每有一张“权”，你的手牌上限便+1。
]]--
-----------
--[[R区]]--
-----------
--[[
	技能名：仁德
	相关武将：标准·刘备
	描述：出牌阶段限一次，你可以将至少一张手牌交给其他角色，若你以此法交给其他角色的手牌数量不少于2，你回复1点体力。
	状态：1217验证通过
	引用：LuaRende
	注备：为什么table.contains不好使……
]]--
LuaRendeCard = sgs.CreateSkillCard{
	name = "LuaRendeCard" ,
	will_throw = false ,
	handling_method = sgs.Card_MethodNone ,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_use = function(self, room, source, targets)
		local target = targets[1];
		source:speak("a")
		local old_value = source:getMark("LuaRende");
		local rende_list = {}
		if old_value > 0 then
			rende_list = source:property("LuaRende"):toString():split("+")
		else
			rende_list = sgs.QList2Table(source:handCards())
		end
		for _,id in sgs.qlist(self:getSubcards())do
			table.removeOne(rende_list,id)
		end
		room:setPlayerProperty(source, "LuaRende", sgs.QVariant(table.concat(rende_list,"+")));
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), target:objectName(), "LuaRende","")
		room:moveCardTo(self,target,sgs.Player_PlaceHand,reason)
		local new_value = old_value + self:getSubcards():length()
		room:setPlayerMark(source, "LuaRende", new_value);
		if (old_value < 2 and new_value >= 2) then
			local recover = sgs.RecoverStruct()
			recover.card = self
			recover.who = source;
			room:recover(source, recover);
		end
		if room:getMode() == "04_1v3" and source:getMark("LuaRende") >= 2 then return end
		if source:isKongcheng() or source:isDead() or #rende_list == 0 then return end
		room:addPlayerHistory(source, "#LuaRendeCard", -1);
		if not room:askForUseCard(source, "@@LuaRende", "@rende-give", -1, sgs.Card_MethodNone) then
			room:addPlayerHistory(source,"#LuaRendeCard")
		end
	end,
}
LuaRendeVs = sgs.CreateViewAsSkill{
	name = "LuaRende", 
	n = 10086, 
	response_pattern = "@@LuaRende",
	view_filter = function(self, selected, to_select)
		if sgs.Self:property("GameMode"):toString() == "04_1v3" and #selected + sgs.Self:getMark("LuaRende") >= 2 then
		   return false
		else
			if to_select:isEquipped() then return false end
			if sgs.Sanguosha:getCurrentCardUsePattern() == "@@LuaRende" then
				local rende_list = sgs.Self:property("LuaRende"):toString():split("+")
				return function()
					for _,id in pairs(rende_list)do
						if id == to_select:getEffectiveId() then
							return true
						end
					end
					return false
				end
			else
				return true
			end
			return true
		end
	end, 
	view_as = function(self, cards) 
		if #cards > 0 then
			local rende =  LuaRendeCard:clone()
			for _,c in ipairs(cards)do
				rende:addSubcard(c)
			end
			return rende
		end
	end, 
	enabled_at_play = function(self, player)
		if player:property("GameMode"):toString() == "04_1v3" and player:getMark("LuaRende") >= 2 then
		   return false
		end
		return (not player:hasUsed("#LuaRendeCard")) and not player:isKongcheng()
	end, 
}
LuaRende = sgs.CreateTriggerSkill{
	name = "LuaRende" ,
	events = {sgs.EventPhaseChanging,sgs.TurnStart} ,
	view_as_skill = LuaRendeVs ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging and player:getMark("LuaRende") > 0 then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
				room:setPlayerMark(player,"LuaRende", 0)
			return false
		elseif event == sgs.TurnStart and player:property("GameMode"):toString() == "" then
			room:setPlayerProperty(player,"GameMode",sgs.QVariant(room:getMode()))
		end
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：仁德
	相关武将：怀旧-标准·刘备-旧
	描述：出牌阶段，你可以将至少一张手牌任意分配给其他角色。你于本阶段内以此法给出的手牌首次达到两张或更多后，你回复1点体力。  
	引用：LuaNosRende
	状态：0405验证通过
	备注：虎牢关部分没有lua
]]--
LuaNosRendeCard = sgs.CreateSkillCard{
	name = "LuaNosRendeCard" ,
	will_throw = false ,
	handling_method = sgs.Card_MethodNone ,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_use = function(self, room, source, targets)
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName(), targets[1]:objectName(), "LuaNosRende", "")
		room:obtainCard(targets[1], self, reason, false)
		local old_value = source:getMark("LuaNosRende")
		local new_value = old_value + self:getSubcards():length()
		room:setPlayerMark(source, "LuaNosRende", new_value)
		if old_value < 2 and new_value >= 2 then
			room:recover(source, sgs.RecoverStruct(source))
		end
	end
}
LuaNosRendeVS = sgs.CreateViewAsSkill{
	name = "LuaNosRende" ,
	n = 999 ,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end ,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local rende_card = LuaNosRendeCard:clone()
		for _, c in ipairs(cards) do
			rende_card:addSubcard(c)
		end
		return rende_card
	end ,
	enabled_at_play = function(self, player)
		return not player:isKongcheng()
	end
}
LuaNosRende = sgs.CreateTriggerSkill{
	name = "LuaNosRende" ,
	events = {sgs.EventPhaseChanging} ,
	view_as_skill = LuaNosRendeVS ,
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then return false end
		player:getRoom():setPlayerMark(player, self:objectName(), 0)
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:getMark(self:objectName()) > 0
	end
}
--[[
	技能名：仁德
	相关武将：虎牢关·刘备
	描述：出牌阶段，你可以将最多两张手牌交给其他角色，若此阶段你给出的牌张数达到两张时，你回复1点体力。
	引用：LuaRende
	状态：验证通过
]]--
LuaRendeCard = sgs.CreateSkillCard{
	name = "LuaRendeCard",
	target_fixed = false,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local target
		if #targets == 0 then
			local list = room:getAlivePlayers()
			for _,player in sgs.qlist(list) do
				if player:objectName() ~= source:objectName() then
					target = player
					break
				end
			end
		else
			target = targets[1]
		end
		room:obtainCard(target, self, false)
		local subcards = self:getSubcards()
		local old_value = source:getMark("rende")
		local new_value = old_value + subcards:length()
		room:setPlayerMark(source, "rende", new_value)
		if old_value < 2 then
			if new_value >= 2 then
				local recover = sgs.RecoverStruct()
				recover.card = self
				recover.who = source
				room:recover(source, recover)
			end
		end
	end
}
LuaRendeVS = sgs.CreateViewAsSkill{
	name = "LuaRende",
	n = 2,
	view_filter = function(self, selected, to_select)
		if not to_select:isEquipped() then
			local markCount = sgs.Self:getMark("rende")
			return #selected + markCount < 2
		end
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local rende_card = LuaRendeCard:clone()
			for i=1, #cards, 1 do
				local id = cards[i]:getId()
				rende_card:addSubcard(id)
			end
			return rende_card
		end
	end
}
LuaRende = sgs.CreateTriggerSkill{
	name = "LuaRende",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaRendeVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:setPlayerMark(player, "rende", 0)
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:isAlive() then
				if target:hasSkill(self:objectName()) then
					if target:getPhase() == sgs.Player_NotActive then
						return target:hasUsed("#LuaRendeCard")
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：仁望
	相关武将：1v1·刘备
	描述：对手于其出牌阶段内对包括你的角色使用第二张及以上【杀】或非延时锦囊牌时，你可以弃置其一张牌。
	引用：LuaRenwang
	状态：1217验证通过
]]--
LuaRenwang = sgs.CreateTriggerSkill{
	name = "LuaRenwang" ,
	events = {sgs.CardUsed, sgs.EventPhaseChanging} ,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardUsed and player:getPhase() == sgs.Player_Play then
			local use = data:toCardUse()
			if not use.card:isKindOf("Slash") and not use.card:isNDTrick() then return false end
			local first = sgs.SPlayerList()
			for _,to in sgs.qlist(use.to) do
				if to:objectName() ~= player:objectName() and not to:hasFlag("LuaRenwangEffect") then
					first:append(to)
					to:setFlags("LuaRenwangEffect")
				end
			end
			for _,p in sgs.qlist(room:getOtherPlayers(use.from)) do
				if use.to:contains(p) and not first:contains(p) and p:canDiscard(use.from, "he") and  p:hasFlag("LuaRenwangEffect") and p:isAlive() and p:hasSkill(self:objectName()) then
					if not room:askForSkillInvoke(p, self:objectName(), data) then return false end
					room:throwCard(room:askForCardChosen(p, use.from, "he", self:objectName(), false, sgs.Card_MethodDiscard), use.from, p);
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				for _,to in sgs.qlist(room:getAlivePlayers()) do
					if to:hasFlag("LuaRenwangEffect") then
						to:setFlags("-LuaRenwangEffect")
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：仁心
	相关武将：一将成名2013·曹冲
	描述：一名其他角色处于濒死状态时，你可以将武将牌翻面并将所有手牌交给该角色，令该角色回复1点体力。
	引用：LuaRenxin
	状态：1217验证通过
]]--
LuaRenxinCard = sgs.CreateSkillCard{
	name = "LuaRenxinCard",
	target_fixed = true,

	on_use = function(self, room, source, targets)
		local who = room:getCurrentDyingPlayer()
		if who then
			source:turnOver()
			room:obtainCard(who,source:wholeHandCards(),false)
		local recover = sgs.RecoverStruct()
			recover.who = source
			room:recover(who,recover)
		end
	end
}
LuaRenxin = sgs.CreateZeroCardViewAsSkill{
	name = "LuaRenxin",

	view_as = function(self) 
		return LuaRenxinCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return false
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "peach" and not player:isKongcheng()
	end
}
--[[
	技能名：忍戒（锁定技）
	相关武将：神·司马懿
	描述：每当你受到1点伤害后或于弃牌阶段因你的弃置而失去一张牌后，你获得一枚“忍”。 
	引用：LuaRenjie
	状态：0405验证通过
]]--
LuaRenjie = sgs.CreateTriggerSkill{
	name = "LuaRenjie" ,
	events = {sgs.Damaged, sgs.CardsMoveOneTime} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			if player:getPhase() == sgs.Player_Discard then
				local move = data:toMoveOneTime()
				if move.from:objectName() == player:objectName() and bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
					local n = move.card_ids:length()
					if n > 0 then
						room:notifySkillInvoked(player, self:objectName())
						player:gainMark("@bear", n)
					end
				end
			end
		elseif event == sgs.Damaged then
			room:notifySkillInvoked(player, self:objectName())
			local damage = data:toDamage()
			player:gainMark("@bear",damage.damage)
		end
		return false
	end
}
--[[
	技能名：肉林（锁定技）
	相关武将：林·董卓
	当你使用【杀】指定一名女性角色为目标后，该角色需连续使用两张【闪】才能抵消；当你成为女性角色使用【杀】的目标后，你需连续使用两张【闪】才能抵消。
	引用：LuaRoulin
	状态：1217验证通过
]]--
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaRoulin = sgs.CreateTriggerSkill{
	name = "LuaRoulin",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.TargetConfirmed},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and player:objectName() == use.from:objectName() then
			local jink_table = sgs.QList2Table(use.from:getTag("Jink_" .. use.card:toString()):toIntList())
			local index = 1
			local play_effect = false
			if use.from and use.from:isAlive() and use.from:hasSkill(self:objectName()) then
				for _,p in sgs.qlist(use.to) do
					if p:isFemale() then
						play_effect = true
						if jink_table[index] == 1 then
							jink_table[index] = 2
						end
					end
					index = index + 1
				end
				local jink_data = sgs.QVariant()
				jink_data:setValue(Table2IntList(jink_table))
				use.from:setTag("Jink_" .. use.card:toString(), jink_data)
				if play_effect then
					room:notifySkillInvoked(use.from, self:objectName())
				end
			elseif use.from:isFemale() then
				for _,p in sgs.qlist(use.to) do
					if p:hasSkill(self:objectName()) then
						play_effect = true
						if jink_table[index] == 1 then
							jink_table[index] = 2
						end
					end
					index = index + 1
				end
				local jink_data = sgs.QVariant()
				jink_data:setValue(Table2IntList(jink_table))
				use.from:setTag("Jink_" .. use.card:toString(), jink_data)
				if play_effect then
					for _,p in sgs.qlist(use.to) do
						if p:hasSkill(self:objectName()) then
							room:notifySkillInvoked(p, self:objectName())
						end
					end
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil and (target:hasSkill(self:objectName()) or target:isFemale())
	end
}
--[[
	技能名：若愚（主公技、觉醒技）
	相关武将：山·刘禅
	描述：回合开始阶段开始时，若你的体力是全场最少的（或之一），你须加1点体力上限，回复1点体力，并获得技能“激将”。
	引用：LuaRuoyu
	状态：1217验证通过
]]--
LuaRuoyu = sgs.CreateTriggerSkill{
	name = "LuaRuoyu$",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Wake,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local can_invoke = true
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if player:getHp() > p:getHp() then
				can_invoke = false
				break
			end
		end
		if can_invoke then
			room:addPlayerMark(player, "LuaRuoyu")
			if room:changeMaxHpForAwakenSkill(player, 1) then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
				if player:isLord() then
					room:acquireSkill(player, "jijiang")
				end
			end
		end
	end,

	can_trigger = function(self, target)
		return target and (target:getPhase() == sgs.Player_Start)
				and target:hasLordSkill("LuaRuoyu")
				and target:isAlive()
				and (target:getMark("LuaRuoyu") == 0)
	end
}
	技能名：若愚（主公技、觉醒技）
	相关武将：山·刘禅
	描述：回合开始阶段开始时，若你的体力是全场最少的（或之一），你须加1点体力上限，回复1点体力，并获得技能“激将”。
]]--
-----------
--[[S区]]--
-----------
--[[
	技能名：伤逝
	相关武将：一将成名·张春华
	描述：弃牌阶段外，当你的手牌数小于X时，你可以将手牌补至X张（X为你已损失的体力值且最多为2）。
	引用：LuaShangshi
	状态：1217验证通过
]]--
LuaShangshi = sgs.CreateTriggerSkill{
	name = "LuaShangshi",
	events = {sgs.EventPhaseChanging, sgs.CardsMoveOneTime, sgs.MaxHpChanged, sgs.HpChanged},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, triggerEvent, zhangchunhua, data)
		local room = zhangchunhua:getRoom()
		local losthp = math.min(zhangchunhua:getLostHp(),2)
		--如果是怀旧版请这么写。
		--local losthp = zhangchunhua:getLostHp()
		if (triggerEvent == sgs.CardsMoveOneTime) then
			local move = data:toMoveOneTime()
			if zhangchunhua:getPhase() == sgs.Player_Discard then
				local changed = false
				if move.from and move.from:objectName() == zhangchunhua:objectName() and move.from_places:contains(sgs.Player_PlaceHand) then
					changed = true
				end
				if moce.to and move.to:objectName() == zhangchunhua:objectName() and move.to_place == sgs.Player_PlaceHand then
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
			zhangchunhua:drawCards(losthp - zhangchunhua:getHandcardNum());
		end
		return false;
	end
}
--[[
	技能名：伤逝
	相关武将：怀旧·张春华
	描述：弃牌阶段外，当你的手牌数小于X时，你可以将手牌补至X张（X为你已损失的体力值）
	引用：LuaNosShangshi
	状态：1217验证通过（见上）
]]--

--[[
	技能名：尚义
	相关武将：阵·蒋钦
	描述：出牌阶段限一次，你可以令一名其他角色观看你的手牌，然后你选择一项：1.观看其手牌，然后你可以弃置其中一张黑色牌。2.观看其身份牌。 
	引用：LuaShangyi
	状态：1217验证通过
]]--
local json = require ("json")
LuaShangyiCard = sgs.CreateSkillCard{
	name = "LuaShangyiCard", 
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select) 
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom()
		local player = effect.to
		if not effect.from:isKongcheng() then
			room:showAllCards(effect.from, player)
		end
		local choicelist = {}
		if not effect.to:isKongcheng() then
			table.insert(choicelist,"handcards")
		end
		if (room:getMode() == "04_1v3" or room:getMode() == "06_3v3")then
			
		elseif (room:getMode() == "06_XMode") then
			local backup = player:getTag("XModeBackup"):toStringList()
			if #backup > 0 then
				table.insert(choicelist,"remainedgenerals")
			end
		elseif (room:getMode() == "02_1v1") then
			local list = player:getTag("1v1Arrange"):toStringList()
			if #list > 0 then
				table.insert(choicelist,"remainedgenerals")
			end
		elseif sgs.GetConfig("EnableBasara",true) then
			if player:getGeneralName() == "anjiang" or player:getGeneral2Name() == "anjiang"then
				table.insert(choicelist,"generals")
			end
		elseif not player:isLord() then
			table.insert(choicelist,"role")
		end
		if #choicelist == 0 then return end
		local choice = room:askForChoice(effect.from, "shangyi", table.concat(choicelist,"+"))
		local jsonLog ={
			"$ShangyiView",
			effect.from:objectName(),
			effect.to:objectName(),
			"",
			"shangyi:" .. choice,
			"",
		}
		room:doBroadcastNotify(room:getOtherPlayers(effect.from), sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
		if choice == "handcards"then
			local ids = sgs.IntList()
			for _,card in sgs.qlist(player:getHandcards())do
				if card:isBlack() then
					ids:append(card:getEffectiveId())
				end
			end
			local card_id = room:doGongxin(effect.from, player, ids, "shangyi");
			if card_id == -1 then return end
			effect.from:removeTag("shangyi")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISMANTLE, effect.from:objectName(),"", "shangyi","")
			room:throwCard(sgs.Sanguosha:getCard(card_id), reason, effect.to, effect.from)
		elseif choice == "remainedgenerals" then
			local list;
			if room:getMode() == "02_1v1" then
				list = player:getTag("1v1Arrange"):toStringList()
			elseif room:getMode() == "06_XMode" then
				list = player:getTag("XModeBackup"):toStringList()
			end
			for _,name in pairs(list)do
				local jsonLog ={
					"$ShangyiViewRemained",
					effect.from:objectName(),
					player:objectName(),
					"",
					name,
					"",
				}
				room:doNotify(effect.from, sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
			end
			local jsonValue = {
				"shangyi",
				sgs.QList2Table(list)
			}
			room:doNotify(effect.from, sgs.CommandType.S_COMMAND_VIEW_GENERALS, json.encode(jsonValue))
		elseif choice == "generals" then
			local list = room:getTag(player:objectName()).toStringList();
			for _,name in pairs(list)do
				local jsonLog ={
					"$ShangyiViewUnknown",
					effect.from:objectName(),
					player:objectName(),
					"",
					name,
					"",
				}
				room:doNotify(effect.from, sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
			end
			local jsonValue = {
				"shangyi",
				sgs.QList2Table(list)
			}
			room:doNotify(effect.from, sgs.CommandType.S_COMMAND_VIEW_GENERALS, json.encode(jsonValue))
		elseif choice == "role" then
			local jsonValue = {
				player:objectName(),
				"role",
				player:getRole(),
			}
			room:doNotify(effect.from, sgs.CommandType.S_COMMAND_SET_PROPERTY, json.encode(jsonValue)); --源码这里竟然有坑……
			local jsonLog ={
				"$ViewRole",
				effect.from:objectName(),
				player:objectName(),
				"",
				player:getRole(),
				"",
			}
			room:doNotify(effect.from, sgs.CommandType.S_COMMAND_LOG_SKILL, json.encode(jsonLog))
		end
	end,
}
LuaShangyi = sgs.CreateZeroCardViewAsSkill{
	name = "LuaShangyi",
	view_as = function(self) 
		return LuaShangyiCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaShangyiCard")
	end, 
}
--[[
	技能名：烧营
	相关武将：倚天·陆伯言
	描述：当你对一名不处于连环状态的角色造成一次火焰伤害时，你可选择一名其距离为1的另外一名角色并进行一次判定：若判定结果为红色，则你对选择的角色造成一点火焰伤害
	引用：LuaShaoying
	状态：1217验证通过
]]--
LuaShaoying = sgs.CreateTriggerSkill{
	name = "LuaShaoying" ,
	events = {sgs.PreDamageDone, sgs.DamageComplete} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if event == sgs.PreDamageDone then
			if (not player:isChained()) and damage.from and (damage.nature == sgs.DamageStruct_Fire) and
					(damage.from:isAlive() and damage.from:hasSkill(self:objectName())) then
				local targets = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if (player:distanceTo(p) == 1) then
						targets:append(p)
					end
				end
				if targets:isEmpty() then return false end
				if damage.from:askForSkillInvoke(self:objectName(), data) then
					local target = room:askForPlayerChosen(damage.from, targets, self:objectName())
					local _data = sgs.QVariant()
					_data:setValue(target)
					damage.from:setTag("LuaShaoyingTarget", _data)
				end
			end
			return false
		elseif event == sgs.DamageComplete then
			if damage.from == nil then return false end
			local target = damage.from:getTag("LuaShaoyingTarget"):toPlayer()
			damage.from:removeTag("LuaShaoyingTarget")
			if (not target) or (not damage.from) or (damage.from:isDead()) then return false end
			local judge = sgs.JudgeStruct()
			judge.pattern = ".|red"
			judge.good = true
			judge.reason = self:objectName()
			judge.who = damage.from
			room:judge(judge)
			if judge:isGood() then
				local shaoying_damage = sgs.DamageStruct()
				shaoying_damage.nature = sgs.DamageStruct_Fire
				shaoying_damage.from = damage.from
				shaoying_damage.to = target
				room:damage(shaoying_damage)
			end
			return false
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：涉猎
	相关武将：神·吕蒙
	描述：摸牌阶段开始时，你可以放弃摸牌并亮出牌堆顶的五张牌。若如此做，你获得其中每种花色的牌各一张，然后将其余的牌置入弃牌堆。 
	引用：LuaShelie
	状态：0405验证通过
	备注：与源码略有区别，源码的自定义函数删除，新增自定义函数
]]--
function getCardList(intlist)
	local ids = sgs.CardList()
	for _, id in sgs.qlist(intlist) do
		ids:append(sgs.Sanguosha:getCard(id))
	end
	return ids
end
LuaShelie = sgs.CreateTriggerSkill{
	name = "LuaShelie",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, shenlvmeng, data)
		if shenlvmeng:getPhase() ~= sgs.Player_Draw then
			return false
		end
		local room = shenlvmeng:getRoom()
		if not shenlvmeng:askForSkillInvoke(self:objectName()) then
			return false
		end
		local card_ids = room:getNCards(5)
		room:fillAG(card_ids)
		local to_get = sgs.IntList()
		local to_throw = sgs.IntList()
		while not card_ids:isEmpty() do
			local card_id = room:askForAG(shenlvmeng, card_ids, false, "shelie")
			card_ids:removeOne(card_id)
			to_get:append(card_id)--弃置剩余所有符合花色的牌(原文：throw the rest cards that matches the same suit)
			local card = sgs.Sanguosha:getCard(card_id)
			local suit = card:getSuit()
			room:takeAG(shenlvmeng, card_id, false)
			local _card_ids = card_ids
			for _,id in sgs.qlist(_card_ids) do
				local c = sgs.Sanguosha:getCard(id)
				if c:getSuit() == suit then
					card_ids:removeOne(id)
					room:takeAG(nil, id, false)
					to_throw:append(id)
				end
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not to_get:isEmpty() then
			dummy:addSubcards(getCardList(to_get))
			shenlvmeng:obtainCard(dummy)
		end
		dummy:clearSubcards()
		if not to_throw:isEmpty() then
			dummy:addSubcards(getCardList(to_throw))
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, shenlvmeng:objectName(), self:objectName(),"")
			room:throwCard(dummy, reason, nil)
		end
		dummy:deleteLater()
		room:clearAG()
		return true
	end
}

--[[
	技能名：神愤
	相关武将：神·吕布、SP·神吕布
	描述：出牌阶段限一次，你可以弃六枚“暴怒”标记：若如此做，所有其他角色受到1点伤害，弃置装备区的所有牌，弃置四张手牌，然后你将武将牌翻面。 
	引用：LuaShenfen
	状态：0405验证通过（未处理胆守）
]]--
LuaShenfenCard = sgs.CreateSkillCard{
	name = "LuaShenfenCard" ,
	target_fixed = true ,
	on_use = function(self, room, source, targets)
		source:setFlags("LuaShenfenUsing")
		source:loseMark("@wrath", 6)
		local players = room:getOtherPlayers(source)
		for _, player in sgs.qlist(players) do
			room:damage(sgs.DamageStruct("LuaShenfen", source, player))
		end
		for _, player in sgs.qlist(players) do
			player:throwAllEquips()
		end
		for _, player in sgs.qlist(players) do
			room:askForDiscard(player, "LuaShenfen", 4, 4)
		end
		source:turnOver()
		source:setFlags("-LuaShenfenUsing")
	end
}
LuaShenfen = sgs.CreateZeroCardViewAsSkill{
	name = "LuaShenfen",
	view_as = function()
		return LuaShenfenCard:clone()
	end , 
	enabled_at_play = function(self,player)
		return player:getMark("@wrath") >= 6 and not player:hasUsed("#LuaShenfenCard")
	end
}
--[[
	技能名：甚贤
	相关武将：SP·星彩
	描述：你的回合外，每当有其他角色因弃置而失去牌时，若其中有基本牌，你可以摸一张牌。
	引用：LuaShenxian
	状态：1217验证通过
]]--
LuaShenxian = sgs.CreateTriggerSkill{
	name = "LuaShenxian" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if move.from and (move.from:objectName() ~= player:objectName())
				and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip))
				and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD)
				and (player:getPhase() == sgs.Player_NotActive) then
			local can_draw = 0
			for _, id in sgs.qlist(move.card_ids) do
				if sgs.Sanguosha:getCard(id):isKindOf("BasicCard") then
					can_draw = can_draw + 1
				end
			end
			if can_draw > 0 then
				if move.reason.m_reason == sgs.CardMoveReason_S_REASON_RULEDISCARD then
					local n = 0
					for n = 1, can_draw , 1 do
						if player:askForSkillInvoke(self:objectName()) then
							player:drawCards(1)
						else
							break
						end
					end
				elseif player:askForSkillInvoke(self:objectName()) then
					player:drawCards(1)
				end
			end
		end
		return false
	end ,
}
--[[
	技能名：神戟
	相关武将：SP·暴怒战神、2013-3v3·吕布
	描述：若你的装备区没有武器牌，当你使用【杀】时，你可以额外选择至多两个目标。
	引用：LuaShenji
	状态：0405验证通过
]]--
LuaShenji = sgs.CreateTargetModSkill{
	name = "LuaShenji" ,
	extra_target_func = function(self, from)
		if from:hasSkill(self:objectName()) and from:getWeapon() == nil then
			return 2
		else
			return 0
		end
	end
}
--[[
	技能名：神君（锁定技）
	相关武将：倚天·陆伯言
	描述：游戏开始时，你必须选择自己的性别。回合开始阶段开始时，你必须倒转性别，异性角色对你造成的非雷电属性伤害无效
	引用：LuaShenjun
	状态：1217验证通过
]]--
LuaShenjun = sgs.CreateTriggerSkill{
	name = "LuaShenjun" ,
	events = {sgs.GameStart, sgs.EventPhaseStart, sgs.DamageInflicted} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.GameStart then
			local gender = room:askForChoice(player, self:objectName(), "male+female")
			local is_male = player:isMale()
			if gender == "female" then
				if is_male then
					player:setGender(sgs.General_Female)
				end
			elseif gender == "male" then
				if not is_male then
					player:setGender(sgs.General_Male)
				end
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				if player:isMale() then
					player:setGender(sgs.General_Female)
				else
					player:setGender(sgs.General_Male)
				end
			end
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			if (damage.nature ~= sgs.DamageStruct_Thunder) and damage.from and
					(damage.from:isMale() ~= player:isMale()) then
				return true
			end
		end
		return false
	end
}
--[[
	技能名：神力（锁定技）
	相关武将：倚天·古之恶来
	描述：出牌阶段，你使用【杀】造成的第一次伤害+X，X为当前死战标记数且最大为3
	引用：LuaShenli
	状态：1217验证通过
]]--
LuaShenli = sgs.CreateTriggerSkill{
	name = "LuaShenli" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.ConfirmDamage} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and (player:getPhase() == sgs.Player_Play) and (not player:hasFlag("shenli")) then
			player:setFlags("shenli")
			local x = player:getMark("@struggle")
			if x > 0 then
				x = math.min(3, x)
				damage.damage = damage.damage + x
				data:setValue(damage)
			end
		end
		return false
	end
}
--[[
	技能名：神速
	相关武将：风·夏侯渊、1v1·夏侯渊1v1
	描述：你可以选择一至两项：
		1.跳过你的判定阶段和摸牌阶段。
		2.跳过你的出牌阶段并弃置一张装备牌。
		你每选择一项，视为对一名其他角色使用一张【杀】（无距离限制）。
	引用：LuaShensu、LuaShensuSlash
	状态：1217验证通过
]]--
LuaShensuCard = sgs.CreateSkillCard{
	name = "LuaShensuCard" ,
	filter = function(self, targets, to_select)
		local targets_list = sgs.PlayerList()
		for _, target in ipairs(targets) do
			targets_list:append(target)
		end
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("LuaShensu")
		slash:deleteLater()
		return slash:targetFilter(targets_list, to_select, sgs.Self)
	end ,
	on_use = function(self, room, source, targets)
		local targets_list = sgs.SPlayerList()
		for _, target in ipairs(targets) do
			if source:canSlash(target, nil, false) then
				targets_list:append(target)
			end
		end
		if targets_list:length() > 0 then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			slash:setSkillName("LuaShensu")
			room:useCard(sgs.CardUseStruct(slash, source, targets_list))
		end
	end
}
LuaShensuVS = sgs.CreateViewAsSkill{
	name = "LuaShensu" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if string.endsWith(sgs.Sanguosha:getCurrentCardUsePattern(), "1") then 
			return false
		else
			return #selected == 0 and to_select:isKindOf("EquipCard") and not sgs.Self:isJilei(to_select)
		end
	end ,
	view_as = function(self, cards)
		if string.endsWith(sgs.Sanguosha:getCurrentCardUsePattern(), "1") then
			return #cards == 0 and LuaShensuCard:clone() or nil
		else
			if #cards ~= 1 then
				return nil
			end
			local card = LuaShensuCard:clone()
			for _, cd in ipairs(cards) do
				card:addSubcard(cd)
			end
			return card
		end
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return string.startsWith(pattern, "@@LuaShensu")
	end
}
LuaShensu = sgs.CreateTriggerSkill{
	name = "LuaShensu" ,
	events = {sgs.EventPhaseChanging} ,
	view_as_skill = LuaShensuVS ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Judge and not player:isSkipped(sgs.Player_Judge) 
			and not player:isSkipped(sgs.Player_Draw) then
			if sgs.Slash_IsAvailable(player) and room:askForUseCard(player, "@@LuaShensu1", "@shensu1", 1) then
				player:skip(sgs.Player_Judge)
				player:skip(sgs.Player_Draw)
			end
		elseif sgs.Slash_IsAvailable(player) and change.to == sgs.Player_Play and not player:isSkipped(sgs.Player_Play) then
			if player:canDiscard(player, "he") and room:askForUseCard(player, "@@LuaShensu2", "@shensu2", 2, sgs.Card_MethodDiscard) then
				player:skip(sgs.Player_Play)
			end
		end
		return false
	end
}
LuaShensuSlash = sgs.CreateTargetModSkill{
	name = "#LuaShensu-slash" ,
	pattern = "Slash" ,
	distance_limit_func = function(self, player, card)
		if player:hasSkill("LuaShensu") and (card:getSkillName() == "LuaShensu") then
			return 1000
		else
			return 0
		end
	end
}
--[[
	技能名：神威（锁定技）
	相关武将：SP·暴怒战神
	描述：摸牌阶段，你额外摸两张牌；你的手牌上限+2。
	引用：LuaShenwei、LuaShenweiDraw
	状态：0405验证通过
]]--
LuaShenweiDraw = sgs.CreateDrawCardsSkill{
	name = "#LuaShenwei-draw" ,
	frequency = sgs.Skill_Compulsory ,
	draw_num_func = function(self, player, n)
		player:getRoom():sendCompulsoryTriggerLog(player, "LuaShenwei")
		return n + 2
	end
}
LuaShenwei = sgs.CreateMaxCardsSkill{
	name = "LuaShenwei" ,
	extra_func = function(self, target)
		if target:hasSkill(self:objectName()) then
			return 2
		else
			return 0
		end
	end
}
--[[
	技能名：神智
	相关武将：国战·甘夫人
	描述：准备阶段开始时，你可以弃置所有手牌。若你以此法弃置的牌不少于X张，你回复1点体力。（X为你当前的体力值）
	引用：LuaShenzhi
	状态：1217验证通过
]]--
LuaShenzhi = sgs.CreateTriggerSkill{
	name = "LuaShenzhi" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (player:getPhase() ~= sgs.Player_Start) or (player:isKongcheng()) then return false end
		if room:askForSkillInvoke(player, self:objectName()) then
			for _, card in sgs.qlist(player:getHandcards()) do
				if player:isJilei(card) then return false end
			end
			local handcard_num = player:getHandcardNum()
			player:throwAllHandCards()
			if handcard_num >= player:getHp() then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			end
		end
		return false
	end
}
--[[
	技能名：生息
	相关武将：阵·蒋琬&费祎
	描述：每当你的出牌阶段结束时，若你于此阶段未造成伤害，你可以摸两张牌。 
	引用：LuaShengxi
	状态：0405验证通过
]]--

LuaShengxi = sgs.CreateTriggerSkill{
	name = "LuaShengxi", 
	frequency = sgs.Skill_Frequent, 
	events = {sgs.PreDamageDone,sgs.EventPhaseEnd}, 
	global = true, 
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseEnd then
			local can_trigger = true
			if player:hasFlag("ShengxiDamageInPlayPhase") then
				can_trigger = false	
				player:setFlags("-ShengxiDamageInPlayPhase")	
			end
			if player and player:isAlive() and player:hasSkill(self:objectName()) and player:getPhase() == sgs.Player_Play and can_trigger and player:askForSkillInvoke(self:objectName()) then
				player:drawCards(2)
			end
		elseif event == sgs.PreDamageDone then
			local damage = data:toDamage()
			if damage.from and damage.from:getPhase() == sgs.Player_Play and not damage.from:hasFlag("ShengxiDamageInPlayPhase") then
				damage.from:setFlags("ShengxiDamageInPlayPhase")
			end
		end
		return false
	end
}
--[[
	技能名：师恩
	相关武将：智·司马徽
	描述：其他角色使用非延时锦囊时，可以让你摸一张牌
	引用：LuaShien
	状态：1217验证通过
	注：智水镜的三个技能均有联系，为了方便起见统一使用本LUA版本的技能，并非原版
]]--
LuaShien = sgs.CreateTriggerSkill{
	name = "LuaShien" ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		if not player then return false end
		if (player:getMark("forbid_LuaShien") > 0) or (player:hasFlag("forbid_LuaShien")) then return false end
		local card = data:toCardUse().card
		if card and card:isNDTrick() then
			local room = player:getRoom()
			local shuijing = room:findPlayerBySkillName(self:objectName())
			if not shuijing then return false end
			local _data = sgs.QVariant()
			_data:setValue(shuijing)
			if room:askForSkillInvoke(player, self:objectName(), _data) then
				shuijing:drawCards(1)
			else
				local choice = room:askForChoice(player, "forbid_LuaShien", "yes+no+maybe")
				if choice == "yes" then
					room:setPlayerMark(player, "forbid_LuaShien", 1)
				elseif choice == "maybe" then
					room:setPlayerFlag(player, "forbid_LuaShien")
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (not target:hasSkill(self:objectName()))
	end
}
--[[
	技能名：识破
	相关武将：智·田丰
	描述：任意角色判定阶段判定前，你可以弃置两张牌，获得该角色判定区里的所有牌
	引用：LuaShipo
	状态：1217验证通过
]]--
LuaShipo = sgs.CreateTriggerSkill{
	name = "LuaShipo" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		if (player:getPhase() ~= sgs.Player_Judge) or (player:getJudgingArea():length() == 0) then return false end
		local room = player:getRoom()
		local tians = room:findPlayersBySkillName(self:objectName())
		for _, tianfeng in sgs.qlist(tians) do
			if tianfeng:getCardCount(true) >= 2 then
				local _data = sgs.QVariant()
				_data:setValue(player)
				if room:askForSkillInvoke(tianfeng, self:objectName(), _data) then
					if room:askForDiscard(tianfeng, self:objectName(), 2, 2, false, true) then
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						dummy:addSubcards(player:getJudgingArea())
						tianfeng:obtainCard(dummy)
						break
					end
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：恃才（锁定技）
	相关武将：智·许攸
	描述：当你拼点成功时，摸一张牌
	引用：LuaShicai
	状态：1217验证通过
]]--
LuaShicai = sgs.CreateTriggerSkill{
	name = "LuaShicai" ,
	events = {sgs.Pindian} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xuyou = room:findPlayerBySkillName(self:objectName())
		if not xuyou then return false end
		local pindian = data:toPindian()
		if (pindian.from:objectName() ~= xuyou:objectName()) and (pindian.to:objectName() ~= xuyou:objectName()) then return false end
		local winner = nil
		if pindian.from_number > pindian.to_number then
			winner = pindian.from
		else
			winner = pindian.to
		end
		if winner:objectName() == xuyou:objectName() then
			xuyou:drawCards(1)
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：恃勇（锁定技）
	相关武将：二将成名·华雄
	描述：每当你受到一次红色的【杀】或因【酒】生效而伤害+1的【杀】造成的伤害后，你减1点体力上限。
	引用：LuaShiyong
	状态：1217验证通过
]]--
LuaShiyong = sgs.CreateTriggerSkill{
	name = "LuaShiyong" ,
	events = {sgs.Damaged} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash")
				and (damage.card:isRed() or damage.card:hasFlag("drank")) then
			player:getRoom():loseMaxHp(player)
		end
		return false
	end
}
--[[
	技能名：誓仇（主公技、限定技）
	相关武将：☆SP·刘备
	描述：准备阶段开始时，你可以交给一名其他蜀势力角色两张牌。每当你受到伤害时，你将此伤害转移给该角色，然后该角色摸X张牌，直到其第一次进入濒死状态时。（X为伤害点数）
	引用：LuaShichou
	状态：1217验证通过
]]--
LuaShichou = sgs.CreateTriggerSkill{
	name = "LuaShichou$",
	frequency = sgs.Skill_Limited,
	limit_mark = "@hate";
	events = {sgs.EventPhaseStart, sgs.DamageInflicted, sgs.Dying, sgs.DamageComplete},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:hasLordSkill(self:objectName()) then
				if player:getPhase() == sgs.Player_Start then
					if player:getMark("shichouInvoke") == 0 then
						if player:getCards("he"):length() > 1 then
							local targets = room:getOtherPlayers(player)
							local victims = sgs.SPlayerList()
							for _,target in sgs.qlist(targets) do
								if target:getKingdom() == "shu" then
									victims:append(target)
								end
							end
							if victims:length() > 0 then
								if player:askForSkillInvoke(self:objectName()) then
									player:loseMark("@hate", 1)
									room:setPlayerMark(player, "shichouInvoke", 1)
									local victim = room:askForPlayerChosen(player, victims, self:objectName())
									room:setPlayerMark(victim, "@chou", 1)
									local tagvalue = sgs.QVariant()
									tagvalue:setValue(victim)
									room:setTag("ShichouTarget", tagvalue)
									local card = room:askForExchange(player, self:objectName(), 2, true, "ShichouGive")
									room:obtainCard(victim, card, false)
								end
							end
						end
					end
				end
			end
		elseif event == sgs.DamageInflicted then
			if player:hasLordSkill(self:objectName(), true) then
				local tag = room:getTag("ShichouTarget")
				if tag then
					local target = tag:toPlayer()
					if target then
						room:setPlayerFlag(target, "Shichou")
						if player:objectName() ~= target:objectName() then
							local damage = data:toDamage()
							damage.to = target
							damage.transfer = true
							room:damage(damage)
							return true
						end
					end
				end
			end
		elseif event == sgs.DamageComplete then
			if player:hasFlag("Shichou") then
				local damage = data:toDamage()
				local count = damage.damage
				player:drawCards(count)
				room:setPlayerFlag(player, "-Shichou")
			end
		elseif event == sgs.Dying then
			if player:getMark("@chou") > 0 then
				player:loseMark("@chou")
				local list = room:getAlivePlayers()
				for _,lord in sgs.qlist(list) do
					if lord:hasLordSkill(self:objectName(), true) then
						local tag = room:getTag("ShichouTarget")
						local target = tag:toPlayer()
						if target:objectName() == player:objectName() then
							room:removeTag("ShichouTarget")
						end
					end
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：慎拒（锁定技）
	相关武将：1v1·吕蒙
	描述：你的手牌上限+X。（X为弃牌阶段开始时其他角色最大的体力值）
	引用：LuaShenju LuaShenjuMark
	状态：1217验证通过
]]--
LuaShenju = sgs.CreateMaxCardsSkill{
	name = "Luashenju",
	extra_func = function(self, target) 
		if target:hasSkill(self:objectName()) then
			return target:getMark("shenju")
		else
			return 0
		end
	end
}
LuaShenjuMark = sgs.CreateTriggerSkill{
	name = "#LuaShenjuMark",
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Discard then
			local max_hp = -1000
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				local hp = p:getHp()
				if hp > max_hp then
					max_hp = hp
				end
			end 
			player:setMark("shenju", math.max(max_hp, 0))
		end
		return false
	end,
}
--[[
	技能名：守成
	相关武将：阵·蒋琬费祎
	描述：每当一名角色于其回合外失去最后的手牌后，你可以令该角色选择是否摸一张牌。 
	引用：LuaShoucheng
	状态：1217验证通过
]]--
LuaShoucheng = sgs.CreateTriggerSkill{
	name = "LuaShoucheng", 
	frequency = sgs.Skill_NotFrequency, --Frequent, NotFrequent, Compulsory, Limited, Wake 
	events = {sgs.CardsMoveOneTime}, 
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		local room = player:getRoom()
		if (move.from and move.from:isAlive() and move.from:getPhase() == sgs.Player_NotActive
			and move.from_places:contains(sgs.Player_PlaceHand) and move.is_last_handcard) then
			local target = nil
			for _,p in sgs.qlist(room:getAlivePlayers())do
				if p:objectName() == move.from:objectName() then
					target = p
				end
			end
			local ai_data = sgs.QVariant()
			ai_data:setValue(target)
			if (room:askForSkillInvoke(player, self:objectName(), ai_data)) then
				target:drawCards(1)
			end
		end
		return false
	end,
}
--[[
	技能名：授业
	相关武将：智·司马徽
	描述：出牌阶段，你可以弃置一张红色手牌，指定最多两名其他角色各摸一张牌
	引用：LuaShouye
	状态：1217验证通过
	注：智水镜的三个技能均有联系，为了方便起见统一使用本LUA版本的技能，并非原版
]]--
LuaShouyeCard = sgs.CreateSkillCard{
	name = "LuaShouyeCard" ,
	filter = function(self, targets, to_select)
		if #targets >= 2 then return false end
		if to_select:objectName() == sgs.Self:objectName() then return false end
		return true
	end ,
	on_effect = function(self, effect)
		effect.to:drawCards(1)
		if effect.from:getMark("LuaJiehuo") == 0 then
			effect.from:gainMark("@shouye")
		end
	end
}
LuaShouye = sgs.CreateViewAsSkill{
	name = "LuaShouye" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and (not to_select:isEquipped()) and (to_select:isRed())
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaShouyeCard:clone()
		card:addSubcard(cards[1])
		return card
	end ,
	enabled_at_play = function(self, player)
		return (player:getMark("LuaJiehuo") == 0) or (not player:hasUsed("#LuaShouyeCard"))
	end
}
--[[
	技能名：淑德
	相关武将：贴纸·王元姬
	描述：结束阶段开始时，你可以将手牌数补至等于体力上限的张数。
	引用：LuaShude
	状态：1217验证通过
]]--
LuaShude = sgs.CreateTriggerSkill{
	name = "LuaShude" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Finish then
			local upper = player:getMaxHp()
			local handcard = player:getHandcardNum()
			if handcard < upper then
				if player:getRoom():askForSkillInvoke(player, self:objectName()) then
					player:drawCards(upper - handcard)
				end
			end
		end
	end
}
--[[
	技能名：淑慎
	相关武将：国战·甘夫人
	描述：每当你回复1点体力后，你可以令一名其他角色摸一张牌。
	引用：LuaShushen
	状态：1217验证通过
]]--
LuaShushen = sgs.CreateTriggerSkill{
	name = "LuaShushen" ,
	events = {sgs.HpRecover} ,
	on_trigger = function(self, event, player, data)
		local recover_struct = data:toRecover()
		local recover = recover_struct.recover
		local room = player:getRoom()
		for i = 0, recover - 1, 1 do
			local target = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "shushen-invoke", true, true)
			if target then
				target:drawCards(1)
			else
				break
			end
		end
		return false
	end
}
--[[
	技能名：双刃
	相关武将：国战·纪灵
	描述：出牌阶段开始时，你可以与一名其他角色拼点：若你赢，视为你一名其他角色使用一张无距离限制的普通【杀】（此【杀】不计入出牌阶段使用次数的限制）；若你没赢，你结束出牌阶段。
	引用：LuaXShuangren
	状态：1217验证通过
]]--
LuaXShuangrenCard = sgs.CreateSkillCard{
	name = "LuaXShuangrenCard",
	target_fixed = false,
	will_throw = false,
	handling_method = sgs.Card_MethodPindian,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if not to_select:isKongcheng() then
				return to_select:objectName() ~= sgs.Self:objectName()
			end
		end
		return false
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local success = effect.from:pindian(effect.to, "LuaXShuangren")
		if success then
			local targets = sgs.SPlayerList()
			local others = room:getOtherPlayers(effect.from)
			for _,target in sgs.qlist(others) do
				if effect.from:canSlash(target, nil, false) then
					targets:append(target)
				end
			end
			if not targets:isEmpty() then
				local target = room:askForPlayerChosen(effect.from, targets, "shuangren-slash")
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName("LuaXShuangren")
				local card_use = sgs.CardUseStruct()
				card_use.card = slash
				card_use.from = effect.from
				card_use.to:append(target)
				room:useCard(card_use, false)
			end
		else
			room:setPlayerFlag(effect.from, "SkipPlay")
		end
	end
}
LuaXShuangrenVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXShuangren",
	response_pattern = "@@LuaXShuangren",
	view_as = function(self) 
		return LuaXShuangrenCard:clone()
	end, 
}
LuaXShuangren = sgs.CreateTriggerSkill{
	name = "LuaXShuangren",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaXShuangrenVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Play then
			local room = player:getRoom()
			local can_invoke = false
			local other_players = room:getOtherPlayers(player)
			for _,p in sgs.qlist(other_players) do
				if not player:isKongcheng() then
					can_invoke = true
					break
				end
			end
			if can_invoke and not player:isKongcheng() then
				room:askForUseCard(player, "@@LuaXShuangren", "@shuangren-card", -1, sgs.Card_MethodPindian)
			end
			if player:hasFlag("SkipPlay") then
				return true
			end
		end
		return false
	end
}
--[[
	技能名：双雄
	相关武将：火·颜良文丑
	描述：摸牌阶段开始时，你可以放弃摸牌，改为进行一次判定，你获得生效后的判定牌，然后你可以将一张与此判定牌颜色不同的手牌当【决斗】使用，直到回合结束。
	引用：LuaShuangxiong LuaShuangxiongJudge
	状态：1217验证通过，可能会有Bug。
]]--
local json = require ("json")
LuaShuangxiong = sgs.CreateOneCardViewAsSkill{
	name = "LuaShuangxiong",
	view_filter = function(self,to_select)
		if to_select:isEquipped() then return false end
		local value = sgs.Self:getMark("LuaShuangxiong")
		if value == 1 then
			return to_select:isBlack()
		elseif value == 2 then
			return to_select:isRed()
		end
		return false
	end,
	view_as = function(self, card)
		local duel = sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber())
		duel:addSubcard(card)
		duel:setSkillName(self:objectName())
		return duel
	end,
	enabled_at_play = function(self, player)
		return (player:getMark("LuaShuangxiong") > 0) and (not player:isKongcheng())
	end
}
LuaShuangxiongJudge = sgs.CreateTriggerSkill{
	name = "#LuaShuangxiongJudge",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart, sgs.FinishJudge,sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				room:setPlayerMark(player, "LuaShuangxiong", 0)
			elseif (player:getPhase() == sgs.Player_Draw) and (player and player:isAlive() and player:hasSkill("LuaShuangxiong")) then
				if player:askForSkillInvoke("LuaShuangxiong") then
					room:setPlayerFlag(player, "LuaShuangxiong")
					local judge = sgs.JudgeStruct()
					judge.good = true
					judge.reason = "LuaShuangxiong"
					judge.who = player
					room:judge(judge)
					local markid = 2
					if judge.card:isRed() then markid = 1 end
					room:setPlayerMark(player, "LuaShuangxiong", markid)
					return true
				end
			elseif player:getPhase() == sgs.Player_Finish then
					if player:getMark("LuaShuangxiong_Lost") ~= 1 then return false end
					room:setPlayerMark(player, "QingchengLuaShuangxiong", 0)
					room:setPlayerMark(player,"LuaShuangxiong_Lost",0)
					local jsonValue = {
						4,
						player:objectName(),
						"LuaShuangxiong"
					}
					room:doNotify(player,sgs.CommandType.S_COMMAND_LOG_EVENT, json.encode(jsonValue))
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == "LuaShuangxiong" then
				player:obtainCard(judge.card)
			end
		elseif event == sgs.EventLoseSkill then
			if data:toString() == "LuaShuangxiong" then
				room:doNotify(player, sgs.CommandType.S_COMMAND_ATTACH_SKILL, json.encode("LuaShuangxiong"))
				room:addPlayerMark(player, "QingchengLuaShuangxiong")
				room:setPlayerFlag(player, "LuaShuangxiong")
				room:setPlayerMark(player,"LuaShuangxiong_Lost",1)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：水箭
	相关武将：奥运·孙扬
	描述：摸牌阶段摸牌时，你可以额外摸X+1张牌，X为你装备区的牌数量的一半（向下取整）。
	引用：LuaXShuijian
	状态：1217验证通过
]]--
LuaXShuijian = sgs.CreateTriggerSkill{
	name = "LuaXShuijian",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			local equips = player:getEquips()
			local length = equips:length()
			local extra = (length / 2) + 1
			local count = data:toInt() + extra
			data:setValue(count)
			return false
		end
	end
}
--[[
	技能名：水泳（锁定技）
	相关武将：奥运·叶诗文
	描述：防止你受到的火焰伤害。
	引用：LuaXShuiyong
	状态：1217验证通过
]]--
LuaXShuiyong = sgs.CreateTriggerSkill{
	name = "LuaXShuiyong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		return damage.nature == sgs.DamageStruct_Fire
	end
}
--[[
	技能：死谏
	相关武将：国战·田丰
	描述：每当你失去最后的手牌后，你可以弃置一名其他角色的一张牌。
	引用：LuaSijian
	状态：1217验证通过
]]--
LuaSijian = sgs.CreateTriggerSkill{
	name = "LuaSijian" ,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local move = data:toMoveOneTime()
		if (move.from and move.from:objectName() == player:objectName()) and move.from_places:contains(sgs.Player_PlaceHand) then
			if event == sgs.BeforeCardsMove then
				if player:isKongcheng() then return false end
				for _, id in sgs.qlist(player:handCards()) do
					if not move.card_ids:contains(id) then return false end
				end
				player:addMark(self:objectName())
			else
				if player:getMark(self:objectName()) == 0 then return false end
				player:removeMark(self:objectName())
				local room = player:getRoom()
				local other_players = room:getOtherPlayers(player)
				local targets = sgs.SPlayerList()
				for _, p in sgs.qlist(other_players) do
					if player:canDiscard(p, "he") then
						targets:append(p)
					end
				end
				if targets:isEmpty() then return false end
				local to = room:askForPlayerChosen(player, targets, self:objectName(), "sijian-invoke", true, true)
				if to then
					local card_id = room:askForCardChosen(player, to, "he", self:objectName(), false, sgs.Card_MethodDiscard)
					room:throwCard(card_id, to, tianfeng)
				end
			end
		end
		return false
	end
}
--[[
	技能名：死战（锁定技）
	相关武将：倚天·古之恶来
	描述：当你受到伤害时，防止该伤害并获得与伤害点数等量的死战标记；你的回合结束阶段开始时，你须弃掉所有的X个死战标记并流失X点体力
	引用：LuaSizhan
	状态：1217验证通过
]]--
LuaSizhan = sgs.CreateTriggerSkill{
	name = "LuaSizhan" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.DamageInflicted, sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		if event == sgs.DamageInflicted then
			local damage = data:toDamage()
			player:gainMark("@struggle", damage.damage)
			return true
		elseif (event == sgs.EventPhaseStart) and (player:getPhase() == sgs.Player_Finish) then
			local x = player:getMark("@struggle")
			if x > 0 then
				player:getRoom():loseHp(player, x)
			end
			player:setFlags("-shenli")
		end
		return false
	end
}
--[[
	技能名：颂词
	相关武将：SP·陈琳
	描述：出牌阶段，你可以选择一项：1、令一名手牌数小于其当前的体力值的角色摸两张牌。2、令一名手牌数大于其当前的体力值的角色弃置两张牌。每名角色每局游戏限一次。
	引用：LuaSongci
	状态：1217验证通过
]]--
LuaSongciCard = sgs.CreateSkillCard{
	name = "LuaSongciCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:getMark("@songci") == 0) and (to_select:getHandcardNum() ~= to_select:getHp())
	end ,
	on_effect = function(self, effect)
		local handcard_num = effect.to:getHandcardNum()
		local hp = effect.to:getHp()
		effect.to:gainMark("@songci")
		if handcard_num > hp then
			effect.to:getRoom():askForDiscard(effect.to, "LuaSongci", 2, 2, false, true)
		else
			effect.to:drawCards(2, "LuaSongci")
		end
	end
}
LuaSongciVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaSongci",
	view_as = function()
		return LuaSongciCard:clone()
	end ,
	enabled_at_play = function(self, player)
		if (player:getMark("@songci") == 0) and (player:getHandcardNum() ~= player:getHp()) then return true end
		for _, sib in sgs.qlist(player:getSiblings()) do
			if (sib:getMark("@songci") == 0) and (sib:getHandcardNum() ~= sib:getHp()) then return true end
		end
		return false
	end 
}
LuaSongci = sgs.CreateTriggerSkill{
	name = "LuaSongci" ,
	events = {sgs.Death} ,
	view_as_skill = LuaSongciVS ,
	on_trigger = function(self, event, player, data)
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		for _, p in sgs.qlist(player:getRoom():getAllPlayers()) do
			if p:getMark("@songci") > 0 then
				player:getRoom():setPlayerMark(p, "@songci", 0)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end
}
--[[
	技能名：颂威（主公技）
	相关武将：林·曹丕、铜雀台·曹丕
	描述：其他魏势力角色的黑色判定牌生效后，该角色可以令你摸一张牌。 
	引用：LuaSongwei
	状态：0405验证通过
]]--
LuaSongwei = sgs.CreateTriggerSkill{
	name = "LuaSongwei$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		local card = judge.card
		local caopis = sgs.SPlayerList()
		if card:isBlack() then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:hasLordSkill(self:objectName()) then
					caopis:append(p)
				end
			end
		end
		while not caopis:isEmpty() do
			local caopi = room:askForPlayerChosen(player, caopis, self:objectName(), "@LuaSongwei-to", true)
			if caopi then
				caopi:drawCards(1)
				caopis:removeOne(caopi)
			else
				break
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and (target:getKingdom() == "wei")
	end
}

--[[
	技能：肃资
	相关武将：1v1·夏侯渊1v1
	描述：每当已死亡的对手的牌因弃置而置入弃牌堆前，你可以获得之。
	引用：LuaSuzi
	状态：1217验证通过
]]--
LuaSuzi = sgs.CreateTriggerSkill{
	name = "LuaSuzi",
	events = {sgs.BuryVictim},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isNude() then return false end
		local xiahouyuan = room:findPlayerBySkillName(self:objectName())
		local death = data:toDeath()
		if xiahouyuan and xiahouyuan:objectName() == death.who:objectName() then return false end
		if room:askForSkillInvoke(xiahouyuan, self:objectName(), data) then
			local dummy = sgs.Sanguosha:cloneCard("jink")
			local cards = player:getCards("he")
			for _, card in sgs.qlist(cards) do
				dummy:addSubcard(card);
			end
			if dummy:subcardsLength() > 0 then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, xiahouyuan:objectName())
				room:moveCardTo(dummy, player, xiahouyuan, sgs.Player_PlaceHand, reason)
			end
			dummy:deleteLater()
		end
		return false
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end,
	
}
--[[
	技能：随势
	相关武将：国战·田丰
	描述：每当其他角色进入濒死状态时，伤害来源可以令你摸一张牌；每当其他角色死亡时，伤害来源可以令你失去1点体力。
	引用：LuaSuishi
	状态：1217验证通过
]]--
LuaSuishi = sgs.CreateTriggerSkill{
	name = "LuaSuishi" ,
	events = {sgs.Dying, sgs.Death} ,
	on_trigger = function(self, event, player, data)
		local target = nil
		if event == sgs.Dying then
			local dying = data:toDying()
			if dying.damage and dying.damage.from then
				target = dying.damage.from
			end
			if (dying.who:objectName() ~= player:objectName()) and target then
				if player:getRoom():askForSkillInvoke(target, self:objectName(), sgs.QVariant("draw:" .. player:objectName())) then
					player:drawCards(1)
				end
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.damage and death.damage.from then
				target = death.damage.from
			end
			if target then
				if player:getRoom():askForSkillInvoke(target, self:objectName(), sgs.QVariant("losehp:" .. player:objectName())) then
					player:getRoom():loseHp(player)
				end
			end
		end
		return false
	end
}
	技能名：颂威（主公技）
	相关武将：林·曹丕
	描述：其他魏势力角色的判定牌为黑色且生效后，该角色可以令你摸一张牌。
]]--
-----------
--[[T区]]--
-----------
--[[
	技能名：抬榇
	相关武将：倚天·庞令明
	描述：出牌阶段，你可以自减1点体力或弃置一张武器牌，弃置你攻击范围内的一名角色区域的两张牌。每回合中，你可以多次使用抬榇
	引用：LuaTaichen
	状态：1217验证通过
]]--
LuaTaichenCard = sgs.CreateSkillCard{
	name = "LuaTaichenCard" ,
	will_throw = false ,
	filter = function(self, targets, to_select)
		if (#targets ~= 0) or (not sgs.Self:canDiscard(to_select, "hej")) then return false end
		if self:subcardsLength() > 0 then
			local card_id = self:getSubcards():first()
			local range_fix = 0
			if sgs.Self:getWeapon() and (sgs.Self:getWeapon():getId() == card_id) then
				local weapon = sgs.Self:getWeapon():getRealCard():toWeapon()
				range_fix = range_fix + weapon:getRange() - 1
			elseif sgs.Self:getOffensiveHorse() and (self:getOffensiveHorse():getId() == card_id) then
				range_fix = range_fix + 1
			end
			return sgs.Self:distanceTo(to_select, range_fix) <= sgs.Self:getAttackRange()
		else
			return sgs.Self:inMyAttackRange(to_select)
		end
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if self:getSubcards():isEmpty() then
			room:loseHp(effect.from)
		else
			room:throwCard(self, effect.from)
		end
		for i = 1, 2, 1 do
			if effect.from:canDiscard(effect.to, "hej") then
				room:throwCard(room:askForCardChosen(effect.from, effect.to, "hej", "LuaTaichen"), effect.to, effect.from)
			end
		end
	end
}
LuaTaichen = sgs.CreateViewAsSkill{
	name = "LuaTaichen" ,
	n = 1,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and to_select:isKindOf("Weapon")
	end ,
	view_as = function(self, cards)
		if #cards <= 1 then
			local taichen_card = LuaTaichenCard:clone()
			if #cards == 1 then
				taichen_card:addSubcard(cards[1])
			end
			return taichen_card
		else
			return nil
		end
	end
}
--[[
	技能名：贪婪
	相关武将：智·许攸
	描述：每当你受到一次伤害，可与伤害来源进行拼点：若你赢，你获得两张拼点牌
	引用：LuaTanlan
	状态：1217验证通过
]]--
LuaTanlan = sgs.CreateTriggerSkill{
	name = "LuaTanlan" ,
	events = {sgs.Pindian, sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		if event == sgs.Damaged then
			local damage = data:toDamage()
			local from = damage.from
			local room = player:getRoom()
			if from and (from:objectName() ~= player:objectName()) and (not from:isKongcheng()) and (not player:isKongcheng()) then
				if room:askForSkillInvoke(player, self:objectName(), data) then
					player:pindian(from, self:objectName())
				end
			end
		else
			local pindian = data:toPindian()
			if (pindian.reason == self:objectName() and pindian.success) then
				player:obtainCard(pindian.to_card)
				player:obtainCard(pindian.from_card)
			end
		end
		return false
	end
}
--[[
	技能名：探虎
	相关武将：☆SP·吕蒙
	描述：出牌阶段限一次，你可以与一名角色拼点：若你赢，你拥有以下锁定技：你无视与该角色的距离，你使用的非延时类锦囊牌对该角色结算时不能被【无懈可击】响应，直到回合结束。
	引用：LuaTanhu
	状态：1217验证通过
]]--
LuaTanhuCard = sgs.CreateSkillCard{
	name = "LuaTanhuCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (not to_select:isKongcheng()) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_use = function(self, room, source, targets)
		local success = source:pindian(targets[1], "LuaTanhu", nil)
		if success then
			local _playerdata = sgs.QVariant()
			_playerdata:setValue(targets[1])
			source:setTag("LuaTanhuInvoke", _playerdata)
			targets[1]:setFlags("LuaTanhuTarget")
			room:setFixedDistance(source, targets[1], 1)
		end
	end
}
LuaTanhuVS = sgs.CreateViewAsSkill{
	name = "LuaTanhu" ,
	n = 0,
	view_as = function()
		return LuaTanhuCard:clone()
	end ,
	enabled_at_play = function(self, target)
		return (not target:hasUsed("#LuaTanhuCard")) and (not target:isKongcheng())
	end
}
LuaTanhu = sgs.CreateTriggerSkill{
	name = "LuaTanhu" ,
	events = {sgs.EventPhaseChanging, sgs.Death, sgs.EventLoseSkill, sgs.TrickCardCanceling} ,
	view_as_skill = LuaTanhuVS ,
	on_trigger = function(self, event, player, data)
		if event == sgs.TrickCardCanceling then
			local effect = data:toCardEffect()
			if effect.from and effect.from:hasSkill(self:objectName()) and effect.from:isAlive()
					and effect.to and effect.to:hasFlag("LuaTanhuTarget") then
				return true
			end
		elseif player:getTag("LuaTanhuInvoke"):toPlayer() then
			if event == sgs.EventPhaseChanging then
				local change = data:toPhaseChange()
				if change.to ~= sgs.Player_NotActive then return false end
			elseif event == sgs.Death then
				local death = data:toDeath()
				if death.who:objectName() ~= player:objectName() then return false end
			elseif event == sgs.EventLoseSkill then
				if data:toString() ~= "LuaTanhu" then return false end
			end
			local target = player:getTag("LuaTanhuInvoke"):toPlayer()
			target:setFlags("-LuaTanhuTarget")
			player:getRoom():setFixedDistance(player, target, -1)
			player:removeTag("LuaTanhuInvoke")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：探囊（锁定技）
	相关武将：翼·张飞
	描述：你计算的与其他角色的距离-X（X为你已损失的体力值）。
	引用：LuaXTannang
	状态：0504验证通过
]]--
LuaXTannang = sgs.CreateDistanceSkill{
	name = "LuaXTannang",
	correct_func = function(self, from, to)
		if from:hasSkill(self:objectName()) then
			return -from:getLostHp(
		end
	end
}

--[[
	技能名：替巾
	相关武将：TWYJ·祖茂
	描述：当其他角色使用【杀】指定目标时，若你在其攻击范围内且目标数为1，你可以将之转移给自己，若如此做，当此【杀】结算结束后，你弃置其一张牌。 
	引用：LuaTijin
	状态：0428验证通过
]]--
LuaTijinMap = {}
LuaTijin = sgs.CreateTriggerSkill{
    name = "LuaTijin" ,
    events = {sgs.TargetSpecifying, sgs.CardFinished} ,
    can_trigger = function(self, target)
        return target and target:isAlive()
    end ,
    on_trigger = function(self, event, player, data)
        local room = player:getRoom()
        local use = data:toCardUse()
        if (event == sgs.TargetSpecifying) then
            if (use.from and use.card and use.card:isKindOf("Slash") and (use.to:length() == 1)) then
                local zumao = room:findPlayerBySkillName(self:objectName())
                if (not zumao) or (not (zumao:isAlive() and zumao:hasSkill(self))) or (use.from:objectName() == zumao:objectName()) or (not use.from:inMyAttackRange(zumao)) then
                    return false
                end
                
                if (zumao:askForSkillInvoke(self, data)) then
                    use.to:first():removeQinggangTag(use.card)
                    while not use.to:isEmpty() do
                        use.to:removeAt(0)
                    end
                    use.to:append(zumao)
                    
                    data:setValue(use)
                    
                    LuaTijinMap[use.card:toString()] = zumao
                end
            end
        else
            if (use.from and use.card) then
                if (LuaTijinMap[use.card:toString()]) then
                    local zumao = LuaTijinMap[use.card:toString()]
                    if (zumao and zumao:isAlive() and zumao:canDiscard(use.from, "he")) then
                        local id = room:askForCardChosen(zumao, use.from, "he", self:objectName(), false, sgs.Card_MethodDiscard)
                        room:throwCard(id, use.from, zumao)
                    end
                end
                LuaTijinMap[use.card:toString()] = nil
            end
        end
        return false
    end ,
}
--[[
	技能名：天妒
	相关武将：标准·郭嘉、SP·台版郭嘉
	描述：在你的判定牌生效后，你可以获得此牌。
	引用：LuaTiandu
	状态：1217验证通过
]]--
LuaTiandu = sgs.CreateTriggerSkill{
	name = "LuaTiandu",
	frequency = sgs.Skill_Frequent,
	events = {sgs.FinishJudge},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		local card = judge.card
		local card_data = sgs.QVariant()
		card_data:setValue(card)
		if room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceJudge and player:askForSkillInvoke(self:objectName(), card_data) then
			player:obtainCard(card)
		end
	end
}
--[[
	技能名：天覆
	相关武将：阵·姜维
	描述：你或与你相邻的角色的回合开始时，该角色可以令你拥有“看破”，直到回合结束。 
	引用：LuaTianfu
	状态：1217验证通过
]]--
LuaTianfu = sgs.CreateTriggerSkill{
	name = "LuaTianfu",
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging},
	priority = 4,

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_RoundStart then
			local jiangweis = room:findPlayersBySkillName(self:objectName())
			for _, jiangwei in sgs.qlist(jiangweis) do 
				local _data = sgs.QVariant()
				_data:setValue(jiangwei)
				if jiangwei:isAlive() and player:objectName() == jiangwei:objectName() or player:isAdjacentTo(jiangwei) and room:askForSkillInvoke(player, self:objectName(),_data) then
					if player:objectName() ~= jiangwei:objectName() then
						room:notifySkillInvoked(jiangwei, self:objectName())
					end
					jiangwei:addMark(self:objectName())
					room:acquireSkill(jiangwei, "kanpo")
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
			for _, p in sgs.qlist(room:getAllPlayers()) do 
				if p:getMark(self:objectName()) > 0 then
					p:setMark(self:objectName(), 0)
					room:detachSkillFromPlayer(p, "kanpo", false, true)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：天命
	相关武将：铜雀台·汉献帝、SP·刘协
	描述： 每当你被指定为【杀】的目标时，你可以弃置两张牌，然后摸两张牌。若全场唯一的体力值最多的角色不是你，该角色也可以弃置两张牌，然后摸两张牌。 
	引用：LuaTianming
	状态：0405验证通过
]]--
LuaTianming = sgs.CreateTriggerSkill{
	name = "LuaTianming",
	events = {sgs.TargetConfirming},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and room:askForSkillInvoke(player,self:objectName()) then
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
				room:askForDiscard(mosthp, self:objectName(), 2, 2, false, true)
				mosthp:drawCards(2)
			end
		end
		return false
	end
}
--[[
	技能名：天香
	相关武将：风·小乔
	描述：每当你受到伤害时，你可以弃置一张红桃手牌，将此伤害转移给一名其他角色，然后该角色摸X张牌（X为该角色当前已损失的体力值）。
	引用：LuaTianxiang、LuaTianxiangDraw
	状态：1217验证
]]--
LuaTianxiangCard = sgs.CreateSkillCard{
	name = "LuaTianxiangCard" ,
	filter = function(self, selected, to_select)
		return (#selected == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		effect.to:addMark("LuaTianxiangTarget")
		local damage = effect.from:getTag("LuaTianxiangDamage"):toDamage()
		if damage.card and damage.card:isKindOf("Slash") then
			effect.from:removeQinggangTag(damage.card)
		end
		damage.to = effect.to
		damage.transfer = true
		room:damage(damage)
	end
}
LuaTianxiangVS = sgs.CreateViewAsSkill{
	name = "LuaTianxiang" ,
	n = 1 ,
	view_filter = function(self, selected, to_select)
		if #selected ~= 0 then return false end
		return (not to_select:isEquipped()) and (to_select:getSuit() == sgs.Card_Heart) and (not sgs.Self:isJilei(to_select))
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local tianxiangCard = LuaTianxiangCard:clone()
		tianxiangCard:addSubcard(cards[1])
		return tianxiangCard
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaTianxiang"
	end
}
LuaTianxiang = sgs.CreateTriggerSkill{
	name = "LuaTianxiang" ,
	events = {sgs.DamageInflicted} ,
	view_as_skill = LuaTianxiangVS ,
	on_trigger = function(self, event, player, data)
		if player:canDiscard(player, "h") then
			player:setTag("LuaTianxiangDamage", data)
			return player:getRoom():askForUseCard(player, "@@LuaTianxiang", "@tianxiang-card", -1, sgs.Card_MethodDiscard)
		end
		return false
	end
}
LuaTianxiangDraw = sgs.CreateTriggerSkill{
	name = "#LuaTianxiang" ,
	events = {sgs.DamageComplete} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if player:isAlive() and (player:getMark("LuaTianxiangTarget") > 0) and damage.transfer then
			player:drawCards(player:getLostHp())
			player:removeMark("LuaTianxiangTarget")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：天义
	相关武将：火·太史慈
	描述：出牌阶段限一次，你可以与一名角色拼点。若你赢，你获得以下锁定技，直到回合结束：你使用【杀】无距离限制；你于出牌阶段内能额外使用一张【杀】；你使用【杀】选择目标的个数上限+1。若你没赢，你不能使用【杀】，直到回合结束。
	引用：LuaTianyi、LuaTianyiTargetMod
	状态：1217验证通过
]]--
LuaTianyiCard = sgs.CreateSkillCard{
	name = "LuaTianyiCard",

	filter = function(self, targets, to_select)
		return #targets == 0 and (not to_select:isKongcheng()) and to_select:objectName() ~= sgs.Self:objectName()
	end,

	on_use = function(self, room, source, targets)
		local success = source:pindian(targets[1], "tianyi", nil)
		if success then
			room:setPlayerFlag(source, "tianyi_success")
		else
			room:setPlayerCardLimitation(source, "use", "Slash", true)
		end
	end
}
LuaTianyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaTianyi",
	view_as = function(self) 
		return LuaTianyiCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaTianyiCard") and not player:isKongcheng()
	end, 
}
LuaTianyi = sgs.CreateTriggerSkill{
	name = "LuaTianyi",
	events = {sgs.EventLoseSkill},
	view_as_skill = LuaTianyiVS,
	on_trigger = function(self, event, player, data)
		if data:toString() == self:objectName() then
			room:setPlayerFlag(player, "-tianyi_success")
		end
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasFlag("tianyi_success")
	end,
}
LuaTianyiTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaTianyiTargetMod",
	frequency = sgs.Skill_NotFrequent,
	pattern = "Slash",
	residue_func = function(self, player)
		if player:hasSkill(self:objectName()) and player:hasFlag("tianyi_success") then
			return 1
		else
			return 0
		end
	end,
	distance_limit_func = function(self, player)
		if player:hasSkill(self:objectName()) and player:hasFlag("tianyi_success") then
			return 1000
		else
			return 0
		end
	end,
	extra_target_func = function(self, player)
		if player:hasSkill(self:objectName()) and player:hasFlag("tianyi_success") then
			return 1
		else
			return 0
		end
	end,
}
--[[
	技能名：挑衅
	相关武将：山·姜维，1V1姜维
	描述：出牌阶段，你可以令一名你在其攻击范围内的其他角色选择一项：对你使用一张【杀】，或令你弃置其一张牌。每阶段限一次。
	引用：LuaTiaoxin
	状态：1217验证通过
]]--
LuaTiaoxinCard = sgs.CreateSkillCard{
	name = "LuaTiaoxinCard" ,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:inMyAttackRange(sgs.Self) and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		local use_slash = false
		if effect.to:canSlash(effect.from, nil, false) then
			use_slash = room:askForUseSlashTo(effect.to,effect.from, "@tiaoxin-slash:" .. effect.from:objectName())
		end
		if (not use_slash) and effect.from:canDiscard(effect.to, "he") then
			room:throwCard(room:askForCardChosen(effect.from,effect.to, "he", "LuaTiaoxin", false, sgs.Card_MethodDiscard), effect.to, effect.from)
		end
	end
}
LuaTiaoxin = sgs.CreateViewAsSkill{
	name = "LuaTiaoxin",
	n = 0 ,
	view_as = function()
		return LuaTiaoxinCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaTiaoxinCard")
	end
}
--[[
	技能名：铁骑
	相关武将：标准·马超-旧、SP·马超、1v1·马超1v1、SP·台版马超
	描述： 每当你指定【杀】的目标后，你可以进行判定：若结果为红色，该角色不能使用【闪】响应此【杀】。 
	引用：LuaTieji
	状态：0405验证通过
]]--
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaNosTieji = sgs.CreateTriggerSkill{
	name = "LuaNosTieji" ,
	events = {sgs.TargetSpecified} ,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return false end
		local jink_table = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
		local index = 1
		for _, p in sgs.qlist(use.to) do
			if not player:isAlive() then break end
			local _data = sgs.QVariant()
			_data:setValue(p)
			if player:askForSkillInvoke(self:objectName(), _data) then
				p:setFlags("LuaNosTiejiTarget")
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|red"
				judge.good = true
				judge.reason = self:objectName()
				judge.who = player
				player:getRoom():judge(judge)
				if judge:isGood() then
					jink_table[index] = 0
				end
				p:setFlags("-LuaNosTiejiTarget")
			end
			index = index + 1
		end
		local jink_data = sgs.QVariant()
		jink_data:setValue(Table2IntList(jink_table))
		player:setTag("Jink_" .. use.card:toString(), jink_data)
		return false
	end
}
--[[
	技能名：同疾（锁定技）
	相关武将：标准·袁术
	描述：若你的手牌数大于你的体力值，且你在一名其他角色的攻击范围内，则其他角色不能被选择为该角色的【杀】的目标。
	引用：LuaTongji
	状态：1217验证通过
]]
LuaTongji = sgs.CreateProhibitSkill{
	name = "LuaTongji" ,
	is_prohibited = function(self, from, to, card)
		if card:isKindOf("Slash") then
			local rangefix = 0
			if card:isVirtualCard() then
				local subcards = card:getSubcards()
				if from:getWeapon() and subcards:contains(from:getWeapon():getId()) then
					local weapon = from:getWeapon():getRealCard():toWeapon()
					rangefix = rangefix + weapon:getRange() - 1
				end 
				if from:getOffensiveHorse() and subcards:contains(self:getOffensiveHorse():getId()) then
					rangefix = rangefix + 1
				end
			end
			for _, p in sgs.qlist(from:getAliveSiblings()) do
				if p:hasSkill(self:objectName()) and (p:objectName() ~= to:objectName()) and (p:getHandcardNum() > p:getHp())
						and (from:distanceTo(p, rangefix) <= from:getAttackRange()) then
					return true
				end
			end
		end
		return false
	end
}
--[[
	技能名：同心
	相关武将：倚天·夏侯涓
	描述：处于连理状态的两名角色，每受到一点伤害，你可以令你们两人各摸一张牌
	引用：LuaTongxin
	状态：1217验证通过
]]--
LuaTongxin = sgs.CreateTriggerSkill{
	name = "LuaTongxin" ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		local xiahoujuan = room:findPlayerBySkillName(self:objectName())
		if xiahoujuan then
			if xiahoujuan:askForSkillInvoke(self:objectName(), data) then
				local zhangfei = nil
				if player:objectName() == xiahoujuan:objectName() then
					local players = room:getOtherPlayers(xiahoujuan)
					for _, _player in sgs.qlist(players) do
						if _player:getMark("@tied") > 0 then
							zhangfei = _player
							break
						end
					end
				else
					zhangfei = player
				end
				xiahoujuan:drawCards(damage.damage)
				if zhangfei then
					zhangfei:drawCards(damage.damage)
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (target:getMark("@tied") > 0)
	end
}
--[[
	技能名：偷渡
	相关武将：倚天·邓士载
	描述：当你的武将牌背面向上时若受到伤害，你可以弃置一张手牌并将你的武将牌翻面，视为对一名其他角色使用了一张【杀】
	引用：LuaToudu、LuaTouduNDL
	状态：1217验证通过
]]--
LuaTouduCard = sgs.CreateSkillCard{
	name = "LuaTouduCard" ,

	filter = function(self, targets, to_select)
		return #targets == 0 and sgs.Self:canSlash(to_select,nil,false)
	end,

	on_effect = function(self, effect)
		effect.from:turnOver()
		local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
			slash:setSkillName("LuaToudu")
		local use = sgs.CardUseStruct()
			use.card = slash
			use.from = effect.from
			use.to:append(effect.to)
			effect.from:getRoom():useCard(use)
		end
}
LuaTouduVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaToudu",
	
	view_filter = function(self,to_select)
		return not to_select:isEquipped()
	end,
	
	view_as = function(self, cards)
		local toudu = LuaTouduCard:clone()
			toudu:addSubcard(cards)
		return toudu
	end,

	enabled_at_play = function()
		return false
	end,
	
	enabled_at_response=function(self, player, pattern)
		return pattern == "@@LuaToudu"
	end
}
LuaToudu = sgs.CreateMasochismSkill{
	name = "LuaToudu",
	view_as_skill = LuaTouduVS,
	
	on_damaged = function(self, player)
		if player:faceUp() or player:isKongcheng() then return false end
			player:getRoom():askForUseCard(player, "@@LuaToudu","@toudu", -1,sgs.Card_MethodDiscard,false)
	end
}
--[[
	技能名：突骑（锁定技）
	相关武将：贴纸·公孙瓒
	描述：准备阶段开始时，若你的武将牌上有“扈”，你将所有“扈”置入弃牌堆：若X小于或等于2，你摸一张牌。本回合你与其他角色的距离-X。（X为准备阶段开始时置于弃牌堆的“扈”的数量）
	引用：LuaXTuqi、LuaXTuqiDist
	状态：1217验证通过
]]--
LuaXTuqi = sgs.CreateTriggerSkill{
	name = "LuaXTuqi",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.EventPhaseStart,sgs.EventPhaseChanging},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
		
			if player:getPhase() == sgs.Player_Start and player:getPile("retinue"):length() > 0 then
				room:notifySkillInvoked(player, self:objectName())
				local n = player:getPile("retinue"):length()
				room:setPlayerMark(player, "tuqi_dist", n)
				player:clearOnePrivatePile("retinue")
				if n <= 2 then
					player:drawCards(1)
				end
			end
		
		else
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then return false end
				room:setPlayerMark(player, "tuqi_dist", 0)
		end
	end
}
LuaXTuqiDist = sgs.CreateDistanceSkill{
	name = "#LuaXTuqi",
	correct_func = function(self, from, to)
		if from:hasSkill(self:objectName()) then
			return -from:getMark("tuqi_dist")
		end
	end,
}
--[[
	技能名：突袭
	相关武将：界限突破·张辽
	描述：摸牌阶段，你可以少摸至少一张牌并选择等量的有手牌的手牌不少于你的其他角色：若如此做，你依次获得这些角色各一张手牌。 
	引用：LuaTuxi、LuaTuxiAct
	状态：0405验证通过
]]--
LuaTuxiCard = sgs.CreateSkillCard{
	name = "LuaTuxiCard",
	filter = function(self, targets, to_select)
		if #targets >= sgs.Self:getMark("LuaTuxi") or to_select:getHandcardNum() < sgs.Self:getHandcardNum() or to_select:objectName() == sgs.Self:objectName() then return false end
		return not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		effect.to:setFlags("LuaTuxiTarget")
	end
}
LuaTuxiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaTuxi",
	response_pattern = "@@LuaTuxi",
	view_as = function() 
		return LuaTuxiCard:clone()
	end
}
LuaTuxi = sgs.CreateDrawCardsSkill{
	name = "LuaTuxi" ,
	view_as_skill = LuaTuxiVS,
	priority = 1,
	draw_num_func = function(self, player, n)
		local room = player:getRoom()
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getHandcardNum() >= player:getHandcardNum() then
				targets:append(p)
			end
		end
		local num = math.min(targets:length(), n)
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			p:setFlags("-LuaTuxiTarget")
		end
		if num > 0 then
			room:setPlayerMark(player, "LuaTuxi", num)
			local count = 0
			if room:askForUseCard(player, "@@LuaTuxi", "@tuxi-card:::" .. tostring(num)) then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:hasFlag("LuaTuxiTarget") then
						count = count + 1
					end
				end
			else 
				room:setPlayerMark(player, "LuaTuxi", 0)
			end
			return n - count
		else
			return n
		end
	end
}
LuaTuxiAct = sgs.CreateTriggerSkill{
	name = "#LuaTuxi" ,
	events = {sgs.AfterDrawNCards} ,
	can_trigger = function(self, target)
		return target ~= nil
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getMark("LuaTuxi") == 0 then return false end
		room:setPlayerMark(player, "LuaTuxi", 0)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasFlag("LuaTuxiTarget") then
				p:setFlags("-LuaTuxiTarget")
				targets:append(p)
			end
		end
		for _, p in sgs.qlist(targets) do
			if not player:isAlive() then
				break
			end
			if p:isAlive() and not p:isKongcheng() then
				local card_id = room:askForCardChosen(player, p, "h", "LuaTuxi")
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, player:objectName())
				room:obtainCard(player, sgs.Sanguosha:getCard(card_id), reason, false)
			end
		end
		return false
	end
}
--[[
	技能名：突袭
	相关武将：标准·张辽、SP·台版张辽
	描述：摸牌阶段开始时，你可以放弃摸牌并选择一至两名有手牌的其他角色：若如此做，你依次获得这些角色各一张手牌。 
	引用：LuaNosTuxi
	状态：0405验证通过
]]--

LuaNosTuxiCard = sgs.CreateSkillCard{
	name = "LuaNosTuxiCard",
	filter = function(self, targets, to_select)
		if #targets >= 2 or to_select:objectName() == sgs.Self:objectName() then return false end
		return not to_select:isKongcheng()
	end,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if effect.from:isAlive() and not effect.to:isKongcheng() then
			local card_id = room:askForCardChosen(effect.from, effect.to, "h", "LuaNosTuxi")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, effect.from:objectName())
			room:obtainCard(effect.from, sgs.Sanguosha:getCard(card_id), reason, false)
		end
	end
}
LuaNosTuxiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaNosTuxi",
	response_pattern = "@@LuaNosTuxi",
	view_as = function(self) 
		return LuaNosTuxiCard:clone()
	end
}
LuaNosTuxi = sgs.CreatePhaseChangeSkill{
	name = "LuaNosTuxi" ,
	view_as_skill = LuaNosTuxiVS,
	on_phasechange = function(self, player)
		if player:getPhase() == sgs.Player_Draw then
			local room = player:getRoom()
			local can_invoke = false
			local other_players = room:getOtherPlayers(player)
			for _, player in sgs.qlist(other_players) do
				if not player:isKongcheng() then
					can_invoke = true
					break
				end
			end
			if can_invoke and room:askForUseCard(player, "@@LuaNosTuxi", "@nostuxi-card") then
				return true
			end
		end
		return false
	end
}
--[[
	技能名：突袭
	相关武将：1v1·张辽1v1
	描述：摸牌阶段，若你的手牌数小于对手的手牌数，你可以少摸一张牌并你获得对手的一张手牌。
	引用：LuaKOFTuxi、LuaKOFTuxiAct
	状态：1217验证通过
]]--
LuaKOFTuxi = sgs.CreateDrawCardsSkill{
	name = "LuaKOFTuxi",
	
	draw_num_func = function(self,player,n)
		local room = player:getRoom() 
		local can_invoke = false
		local targets = sgs.SPlayerList()
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:getHandcardNum() > player:getHandcardNum() then
				targets:append(p)
			end
		end
		if not targets:isEmpty() then
			can_invoke = true
		end 
		if can_invoke then
			local target = room:askForPlayerChosen(player, targets, self:objectName(), "koftuxi-invoke", true, true)
			if (target) then
				target:setFlags("LuaKOFTuxiTarget")
				player:setFlags("Luakoftuxi")
				return n - 1
			else 
				return n
			end
		else
			return n
		end
end
}
LuaKOFTuxiAct = sgs.CreateTriggerSkill{
	name = "#Luakoftuxi",
	events = {sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if not player:hasFlag("Luakoftuxi") then
			return false
		end
		player:setFlags("-Luakoftuxi")
		local target = nil
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			if p:hasFlag("LuaKOFTuxiTarget") then
				p:setFlags("-LuaKOFTuxiTarget")
				target = p
				break
			end
		end
		if not target then return false end
		local card_id = room:askForCardChosen(player, target, "h", "koftuxi")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, self:objectName())
		room:moveCardTo(sgs.Sanguosha:getCard(card_id),player,sgs.Player_PlaceHand,reason)
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：屯田
	相关武将：山·邓艾
	描述：你的回合外，当你失去牌时，你可以进行一次判定，将非红桃结果的判定牌置于你的武将牌上，称为“田”；每有一张“田”，你计算的与其他角色的距离便-1。
	引用：LuaTuntian、LuaTuntianDistance
	状态：1217验证通过
]]--
LuaTuntian = sgs.CreateTriggerSkill{
	name = "LuaTuntian",
	frequency = sgs.Skill_Frequent,
	events = {sgs.CardsMoveOneTime, sgs.FinishJudge, sgs.EventLoseSkill},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.from and (move.from:objectName() == player:objectName()) and (move.from_places:contains(sgs.Player_PlaceHand) or  move.from_places:contains(sgs.Player_PlaceEquip))) and not (move.to and (move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip))) then
				if not player:askForSkillInvoke("LuaTuntian", data) then return end
				local judge = sgs.JudgeStruct()
				judge.pattern = ".|heart"
				judge.good = false
				judge.reason = self:objectName()
				judge.who = player
				room:judge(judge)
			end
		elseif event == sgs.FinishJudge then
			local judge = data:toJudge()
			if judge.reason == self:objectName() and judge:isGood() and room:getCardPlace(judge.card:getEffectiveId()) == sgs.Player_PlaceJudge then
				player:addToPile("field", judge.card:getEffectiveId())
			end
		end
		if event == sgs.EventLoseSkill then
			if data:toString() == self:objectName() then
				player:removePileByName("field")
			end
		end
	end,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_NotActive
	end
}
LuaTuntianDistance = sgs.CreateDistanceSkill{
	name = "#LuaTuntianDistance",
	correct_func = function(self, from, to)
		if from:hasSkill(self:objectName()) then
			return - from:getPile("field"):length()
		else
			return 0
		end
	end  
}
	name = "LuaTuoqiao",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaTuoqiao", data) then
			room:changeHero(player, "sp_diaochan", true, true, false, true)
		end
	end
}
-----------
--[[U区]]--
-----------
--[[
	技能名：
	相关武将：
]]--
-----------
--[[V区]]--
-----------
--[[
	技能名：
	相关武将：
]]--
-----------
--[[W区]]--
-----------
--[[
	技能名：婉容
	相关武将：1v1·大乔
	描述：每当你成为【杀】的目标后，你可以摸一张牌。  
	引用：LuaWanrong
	状态：0405验证通过
]]--
LuaWanrong = sgs.CreateTriggerSkill{
	name = "LuaWanrong",
	events = {sgs.TargetConfirmed},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and use.to:contains(player) and player:getRoom():askForSkillInvoke(player, self:objectName(), data) then
			player:drawCards(1, self:objectName())
		end
		return false
	end
}
--[[
	技能名：忘隙
	相关武将：势·李典
	描述：每当你对一名其他角色造成1点伤害后，或你受到其他角色造成的1点伤害后，若该角色存活，你可以与其各摸一张牌。
	引用：LuaWangxi
	状态：1217验证通过
]]--
LuaWangxi = sgs.CreateTriggerSkill{
	name = "LuaWangxi" ,
	events = {sgs.Damage,sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local target = nil
		if event == sgs.Damage then
			target = damage.to
		else
			target = damage.from
		end
		if not target or target:objectName() == player:objectName() then return false end
		local players = sgs.SPlayerList()
			players:append(player)
			players:append(target)
			room:sortByActionOrder(players)
		for i = 1, damage.damage, 1 do
			if not target:isAlive() or not player:isAlive() then return false end
			local value = sgs.QVariant()
				value:setValue(target)
			if room:askForSkillInvoke(player,self:objectName(),value) then
				room:drawCards(players,1,self:objectName())
			end
		end
	end
}
--[[
	技能名：妄尊
	相关武将：标准·袁术
	描述：主公的准备阶段开始时，你可以摸一张牌，然后主公本回合手牌上限-1。
	引用：LuaWangzun、LuaWangzunMaxCards
	状态：1217验证通过
]]--
LuaWangzun = sgs.CreatePhaseChangeSkill{
	name = "LuaWangzun" ,
	on_phasechange = function(self, target)
		local room = target:getRoom()
		local mode = room:getMode()
		if mode:endsWith("p") or mode:endsWith("pd") or mode:endsWith("pz") then
			if target:isLord() and target:getPhase() == sgs.Player_Start then
				local yuanshu = room:findPlayerBySkillName(self:objectName())
				if yuanshu and room:askForSkillInvoke(yuanshu, self:objectName()) then
					yuanshu:drawCards(1)
					room:setPlayerFlag(target, "LuaWangzunDecMaxCards")
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
LuaWangzunMaxCards = sgs.CreateMaxCardsSkill{
	name = "#LuaWangzunMaxCards" ,
	extra_func = function(self, target)
		if target:hasFlag("LuaWangzunDecMaxCards") then
			return -1
		else
			return 0
		end
	end
}
--[[
	技能名：危殆（主公技）
	相关武将：智·孙策
	描述：当你需要使用一张【酒】时，所有吴势力角色按行动顺序依次选择是否打出一张黑桃2~9的手牌，视为你使用了一张【酒】，直到有一名角色或没有任何角色决定如此做时为止
	引用：LuaWeidai
	状态：1217验证通过
]]--
hasWuGenerals = function(player)
	for _, p in sgs.qlist(player:getSiblings()) do
		if p:isAlive() and p:getKingdom() == "wu" then
			return true
		end
	end
	return false
end
LuaWeidaiCard = sgs.CreateSkillCard{
	name = "LuaWeidaiCard",
	target_fixed = true,
		mute = true,
	on_validate = function(self, card_use)
		card_use.m_isOwnerUse = false
		local sunce = card_use.from
		local room = sunce:getRoom()
		for _ , liege in sgs.qlist(room:getLieges("wu", sunce)) do
			local tohelp = sgs.QVariant()
			tohelp:setValue(sunce)
			local prompt = string.format("@weidai-analeptic:%s", sunce:objectName())
			local card = room:askForCard(liege, ".|spade|2~9|hand", prompt, tohelp, sgs.Card_MethodNone)
			if card then
				local reason=sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, liege:objectName(), "LuaWeidai", "")
				room:moveCardTo(card, nil, sgs.Player_DiscardPile, reason, true)
				local ana = sgs.Sanguosha:cloneCard("analeptic", card:getSuit(), card:getNumber())
				ana:setSkillName("LuaWeidai")
				ana:addSubcard(card)
				return ana
			end
		end
		room:setPlayerFlag(sunce, "Global_LuaWeidaiFailed")
		return nil
	end,
	on_validate_in_response = function(self, user)
		local room = user:getRoom()
		for _ , liege in sgs.qlist(room:getLieges("wu", user)) do
			local tohelp = sgs.QVariant()
			tohelp:setValue(user)
			local prompt = string.format("@weidai-analeptic:%s", user:objectName())
			local card = room:askForCard(liege, ".|spade|2~9|hand", prompt, tohelp, sgs.Card_MethodNone)
			if card then
				local reason=sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, liege:objectName(), "LuaWeidai", "")
				room:moveCardTo(card, nil, sgs.Player_DiscardPile, reason, true)
				local ana = sgs.Sanguosha:cloneCard("analeptic", card:getSuit(), card:getNumber())
				ana:setSkillName("LuaWeidai")
				ana:addSubcard(card)
				return ana
			end
		end
		room:setPlayerFlag(user, "Global_LuaWeidaiFailed")
		return nil
	end
}
LuaWeidai = sgs.CreateZeroCardViewAsSkill{
	name = "LuaWeidai$",
	view_as = function()
		return LuaWeidaiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return hasWuGenerals(player) and player:hasLordSkill("LuaWeidai")
			   and not player:hasFlag("Global_LuaWeidaiFailed")
			   and sgs.Analeptic_IsAvailable(player)
	end,
	enabled_at_response = function(self, player, pattern)
		return hasWuGenerals(player) and pattern == "peach+analeptic" and not player:hasFlag("Global_LuaWeidaiFailed")
	end
}

--[[
	技能名：围堰
	相关武将：倚天·陆抗
	描述：你可以将你的摸牌阶段当作出牌阶段，出牌阶段当作摸牌阶段执行
	引用：LuaLukangWeiyan
	状态：1217验证通过
]]--
LuaLukangWeiyan = sgs.CreateTriggerSkill{
	name = "LuaLukangWeiyan" ,
	events = {sgs.EventPhaseChanging} ,
	on_trigger = function(self, event, player, data)
		local change = data:toPhaseChange()
		if change.to == sgs.Player_Draw then
			if not player:isSkipped(sgs.Player_Draw) then
				if player:askForSkillInvoke(self:objectName(), sgs.QVariant("draw2play")) then
					change.to = sgs.Player_Play
					data:setValue(change)
				end
			end
		elseif change.to == sgs.Player_Play then
			if not player:isSkipped(sgs.Player_Play) then
				if player:askForSkillInvoke(self:objectName(), sgs.QVariant("play2draw")) then
					change.to = sgs.Player_Draw
					data:setValue(change)
				end
			end
		else
			return false
		end
		return false
	end
}
--[[
	技能名：帷幕（锁定技）
	相关武将：林·贾诩、SP·贾诩
	描述：你不能被选择为黑色锦囊牌的目标。
	引用：LuaWeimu
	状态：0405验证通过
]]--
LuaWeimu = sgs.CreateProhibitSkill{
	name = "LuaWeimu" ,
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("TrickCard") or card:isKindOf("QiceCard")) 
		and card:isBlack() and card:getSkillName() ~= "nosguhuo" --特别注意旧蛊惑
	end
}
--[[
	技能名：伪帝（锁定技）
	相关武将：SP·袁术、SP·台版袁术
	描述：你拥有当前主公的主公技。
	状态：0405验证失败--目测永远实现不了
]]--
--[[
	技能名：温酒（锁定技）
	相关武将：智·华雄
	描述：你使用黑色的【杀】造成的伤害+1，你无法闪避红色的【杀】
	引用：LuaWenjiu
	状态：1217验证通过
]]--
LuaWenjiu = sgs.CreateTriggerSkill{
	name = "LuaWenjiu" ,
	events = {sgs.ConfirmDamage, sgs.SlashProceed} ,
	frequency = sgs.Skill_Compulsory ,
	priority = 3 ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local hua = room:findPlayerBySkillName(self:objectName())
		if not hua then return false end
		if event == sgs.SlashProceed then
			local effect = data:toSlashEffect()
			if (effect.to:objectName() == hua:objectName()) and effect.slash:isRed() then
				room:slashResult(effect, nil)
				return true
			end
		elseif event == sgs.ConfirmDamage then
			local damage = data:toDamage()
			local reason = damage.card
			if (not reason) or (damage.from:objectName() ~= hua:objectName()) then return false end
			if reason:isKindOf("Slash") and reason:isBlack() then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：无谋（锁定技）
	相关武将：神·吕布、SP·神吕布
	描述：每当你使用一张非延时锦囊牌时，你须选择一项：失去1点体力，或弃一枚“暴怒”标记。 
	引用：LuaWumou
	状态：0405验证通过
]]--
LuaWumou = sgs.CreateTriggerSkill{
	name = "LuaWumou" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if use.card:isNDTrick() then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			local num = player:getMark("@wrath")
			if num >= 1 and room:askForChoice(player, self:objectName(), "discard+losehp") == "discard" then
				player:loseMark("@wrath")
			else
				room:loseHp(player)
			end
		end
		return false
	end
}
--[[
	技能名：无前
	相关武将：神·吕布、SP·神吕布
	描述：出牌阶段，你可以弃两枚“暴怒”标记并选择一名其他角色：若如此做，你拥有“无双”且该角色防具无效，直到回合结束。
	引用：LuaWuqian
	状态：0405验证通过
]]--
LuaWuqianCard = sgs.CreateSkillCard{
	name = "LuaWuqianCard" ,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName()
	end ,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		effect.from:loseMark("@wrath", 2)
		room:acquireSkill(effect.from, "wushuang")
		effect.from:setFlags("LuaWuqianSource")
		effect.to:setFlags("LuaWuqianTarget")
		room:addPlayerMark(effect.to, "Armor_Nullified")
	end
}
LuaWuqianVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaWuqian" ,
	view_as = function()
		return LuaWuqianCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return player:getMark("@wrath") >= 2
	end
}
LuaWuqian = sgs.CreateTriggerSkill{
	name = "LuaWuqian" ,
	events = {sgs.EventPhaseChanging, sgs.Death} ,
	view_as_skill = LuaWuqianVS ,
	can_trigger = function(self, target)
		return target and target:hasFlag("LuaWuqianSource")
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("WuqianTarget") then
				p:setFlags("-WuqianTarget")
				if p:getMark("Armor_Nullified") then
					room:removePlayerMark(p, "Armor_Nullified")
				end
			end
		end
		room:detachSkillFromPlayer(player, "wushuang", false, true)
		return false
	end
}
--[[
	技能名：无双（锁定技）
	相关武将：界限突破·吕布、标准·吕布、SP·最强神话、SP·暴怒战神、SP·台版吕布
	描述：当你使用【杀】指定一名角色为目标后，该角色需连续使用两张【闪】才能抵消；与你进行【决斗】的角色每次需连续打出两张【杀】。
	引用：LuaWushuang
	状态：0405验证通过
	备注：与源码略有不同，体验感稍差
]]--
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
LuaWushuang = sgs.CreateTriggerSkill{
	name = "LuaWushuang" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.TargetSpecified,sgs.CardEffected } ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TargetSpecified then
			local use = data:toCardUse()
			if use.card:isKindOf("Slash") and player and player:isAlive() and player:hasSkill(self:objectName()) then
				room:sendCompulsoryTriggerLog(player, self:objectName())
				local jink_list = sgs.QList2Table(player:getTag("Jink_" .. use.card:toString()):toIntList())
				for i = 0, use.to:length() - 1, 1 do
					if jink_list[i + 1] == 1 then
						jink_list[i + 1] = 2
					end
				end
				local jink_data = sgs.QVariant()
				jink_data:setValue(Table2IntList(jink_list))
				player:setTag("Jink_" .. use.card:toString(), jink_data)
			end
		elseif event == sgs.CardEffected then
			local effect = data:toCardEffect()
			local can_invoke = false
			if effect.card:isKindOf("Duel") then				
				if effect.from and effect.from:isAlive() and effect.from:hasSkill(self:objectName()) then
					can_invoke = true
				end
				if effect.to and effect.to:isAlive() and effect.to:hasSkill(self:objectName()) then
					can_invoke = true
				end
			end
			if not can_invoke then return false end
			if effect.card:isKindOf("Duel") then
				if room:isCanceled(effect) then
					effect.to:setFlags("Global_NonSkillNullify")
					return true;
				end
				if effect.to:isAlive() then
					local second = effect.from
					local first = effect.to
					room:setEmotion(first, "duel");
					room:setEmotion(second, "duel")
					while true do
						if not first:isAlive() then
							break
						end
						local slash
						if second:hasSkill(self:objectName()) then
							slash = room:askForCard(first,"slash","@Luawushuang-slash-1:" .. second:objectName(),data,sgs.Card_MethodResponse, second);
							if slash == nil then
								break
							end

							slash = room:askForCard(first, "slash", "@Luawushuang-slash-2:" .. second:objectName(),data,sgs.Card_MethodResponse,second);
							if slash == nil then
								break
							end
						else
							slash = room:askForCard(first,"slash","duel-slash:" .. second:objectName(),data,sgs.Card_MethodResponse,second)
							if slash == nil then
								break
							end
						end
						local temp = first
						first = second
						second = temp
					end
					local daamgeSource = function() if second:isAlive() then return secoud else return nil end end
					local damage = sgs.DamageStruct(effect.card, daamgeSource() , first)
					if second:objectName() ~= effect.from:objectName() then
						damage.by_user = false;
					end
					room:damage(damage)
				end
				room:setTag("SkipGameRule",sgs.QVariant(true))
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：无言（锁定技）
	相关武将：一将成名·徐庶
	描述：你防止你造成或受到的任何锦囊牌的伤害。
	引用：LuaWuyan
	状态：1217验证通过
]]--
LuaWuyan = sgs.CreateTriggerSkill{
	name = "LuaWuyan",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.DamageCaused, sgs.DamageInflicted},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if damage.card and (damage.card:getTypeId() == sgs.Card_TypeTrick) then
			if (event == sgs.DamageInflicted) and player:hasSkill(self:objectName()) then
				return true
			elseif (event == sgs.DamageCaused) and (damage.from and damage.from:isAlive() and damage.from:hasSkill(self:objectName())) then
				return true
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：无言（锁定技）
	相关武将：怀旧·徐庶
	描述：你使用的非延时类锦囊牌对其他角色无效；其他角色使用的非延时类锦囊牌对你无效。
	引用：LuaNosWuyan
	状态：1217验证通过
]]--
LuaNosWuyan = sgs.CreateTriggerSkill{
	name = "LuaNosWuyan" ,
	events = {sgs.CardEffected} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if effect.to:objectName() == effect.from:objectName() then return false end
		if effect.card:isNDTrick() then
			if effect.from and effect.from:hasSkill(self:objectName()) then
				return true
			elseif effect.to:hasSkill(self:objectName()) and effect.from then
				return true
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：五灵
	相关武将：倚天·晋宣帝
	描述：回合开始阶段，你可选择一种五灵效果发动，该效果对场上所有角色生效
		该效果直到你的下回合开始为止，你选择的五灵效果不可与上回合重复
		[风]场上所有角色受到的火焰伤害+1
		[雷]场上所有角色受到的雷电伤害+1
		[水]场上所有角色使用桃时额外回复1点体力
		[火]场上所有角色受到的伤害均视为火焰伤害
		[土]场上所有角色每次受到的属性伤害至多为1
	引用：LuaWulingExEffect、LuaWulingEffect、LuaWuling
	状态：1217验证通过
]]--
LuaWulingExEffect = sgs.CreateTriggerSkill{
	name = "#LuaWuling-ex-effect" ,
	events = {sgs.PreHpRecover, sgs.DamageInflicted} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xuandi = room:findPlayerBySkillName(self:objectName())
		if not xuandi then return false end
		local wuling = xuandi:getTag("LuaWuling"):toString()
		if (event == sgs.PreHpRecover) and (wuling == "water") then
			local rec = data:toRecover()
			if rec.card and (rec.card:isKindOf("Peach")) then
				rec.recover = rec.recover + 1
				data:setValue(rec)
			end
		elseif (event == sgs.DamageInflicted) and (wuling == "earth") then
			local damage = data:toDamage()
			if (damage.nature ~= sgs.DamageStruct_Normal) and (damage.damage > 1) then
				damage.damage = 1
				data:setValue(damage)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
LuaWulingEffect = sgs.CreateTriggerSkill{
	name = "#LuaWuling-effect" ,
	events = {sgs.DamageInflicted} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xuandi = room:findPlayerBySkillName(self:objectName())
		if not xuandi then return false end
		local wuling = xuandi:getTag("LuaWuling"):toString()
		local damage = data:toDamage()
		if wuling == "wind" then
			if damage.nature == sgs.DamageStruct_Fire then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif wuling == "thunder" then
			if damage.nature == sgs.DamageStruct_Thunder then
				damage.damage = damage.damage + 1
				data:setValue(damage)
			end
		elseif wuling == "fire" then
			if damage.nature ~= sgs.DamageStruct_Fire then
				damage.nature = sgs.DamageStruct_Fire
				data:setValue(damage)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end ,
}
LuaWuling = sgs.CreateTriggerSkill{
	name = "LuaWuling" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local LuaWulingEffects = {"wind", "thunder", "water", "fire", "earth"}
		if player:getPhase() == sgs.Player_Start then
			local current = player:getTag("LuaWuling"):toString()
			local choices = {}
			for _, effect in ipairs(LuaWulingEffects) do
				if effect ~= current then
					table.insert(choices, effect)
				end
			end
			local room = player:getRoom()
			local choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
			if not (current == "" or current == nil) then
				player:loseMark("@" .. current)
			end
			player:gainMark("@" .. choice)
			player:setTag("LuaWuling", sgs.QVariant(choice))
		end
		return false
	end
}
--[[
	技能名：武魂（锁定技）
	相关武将：神·关羽
	描述：每当你受到伤害扣减体力前，伤害来源获得等于伤害点数的“梦魇”标记。你死亡时，你选择一名存活的“梦魇”标记数最多（不为0）的角色，该角色进行判定：若结果不为【桃】或【桃园结义】，该角色死亡。 
	引用：LuaWuhun、LuaWuhunRevenge
	状态：0405验证通过
]]--
LuaWuhun = sgs.CreateTriggerSkill{
	name = "LuaWuhun" ,
	events = {sgs.PreDamageDone},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local room = player:getRoom()
		if damage.from and damage.from:objectName() ~= player:objectName() then
			damage.from:gainMark("@nightmare", damage.damage)
			room:notifySkillInvoked(player, self:objectName())
		end
		return false
	end
}
LuaWuhunRevenge = sgs.CreateTriggerSkill{
	name = "#LuaWuhun" ,
	events = {sgs.Death},
	can_trigger = function(self, target)
		return target ~= nil and target:hasSkill("LuaWuhun");
	end ,
	on_trigger = function(self, event, shenguanyu, data)
		local death = data:toDeath()
		local room = shenguanyu:getRoom()
		if death.who:objectName() ~= shenguanyu:objectName() then
			return false
		end
		local players = room:getOtherPlayers(shenguanyu)
		local max = 0
		for _, player in sgs.qlist(players) do
			max = math.max(max, player:getMark("@nightmare"))
		end
		if max == 0 then return false end
		local foes = sgs.SPlayerList()
		for _, player in sgs.qlist(players) do
			if player:getMark("@nightmare") == max then
				foes:append(player)
			end
		end
		if foes:isEmpty() then
			return false
		end
		local foe
		if foes:length() == 1 then
			foe = foes:first()
		else
			foe = room:askForPlayerChosen(shenguanyu, foes, "wuhun", "@wuhun-revenge")
		end
		room:notifySkillInvoked(shenguanyu, "wuhun")
		local judge = sgs.JudgeStruct()
		judge.pattern = "Peach,GodSalvation"
		judge.good = true
		judge.negative = true
		judge.reason = "wuhun"
		judge.who = foe
		room:judge(judge)
		if judge:isBad() then
			room:killPlayer(foe)
		end
		local killers = room:getAllPlayers()
		for _, player in sgs.qlist(killers) do
			player:loseAllMarks("@nightmare")
		end
		return false
	end
}
--[[
	技能名：武继（觉醒技）
	相关武将：SP·关银屏
	描述：结束阶段开始时，若你于本回合造成了至少3点伤害，你增加1点体力上限，回复1点体力，然后失去“虎啸”。 
	引用：LuaWuji
	状态：0405验证通过
]]--
LuaWuji = sgs.CreatePhaseChangeSkill{
	name = "LuaWuji",
	frequency = sgs.Skill_Wake,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		room:setPlayerMark(player, self:objectName(), 1)
		if room:changeMaxHpForAwakenSkill(player, 1) then
			room:recover(player, sgs.RecoverStruct(player))
			room:detachSkillFromPlayer(player, "huxiao")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_Finish 
		and target:getMark(self:objectName()) == 0 and target:getMark("damage_point_round") >= 3
	end
}
--[[
	技能名：武神（锁定技）
	相关武将：神·关羽
	描述：你的红桃手牌视为普通【杀】。你使用红桃【杀】无距离限制。 
	引用：LuaWushen、LuaWushenTargetMod
	状态：0405验证通过
]]--


LuaWushen = sgs.CreateFilterSkill{
	name = "LuaWushen", 
	view_filter = function(self,to_select)
		local room = sgs.Sanguosha:currentRoom()
		local place = room:getCardPlace(to_select:getEffectiveId())
		return (to_select:getSuit() == sgs.Card_Heart) and (place == sgs.Player_PlaceHand)
	end,
	view_as = function(self, originalCard)
		local slash = sgs.Sanguosha:cloneCard("slash", originalCard:getSuit(), originalCard:getNumber())
		slash:setSkillName(self:objectName())
		local card = sgs.Sanguosha:getWrappedCard(originalCard:getId())
		card:takeOver(slash)
		return card
	end
}
LuaWushenTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaWushen-target",
	distance_limit_func = function(self, from, card)
		if from:hasSkill("LuaWushen") and (card:getSuit() == sgs.Card_Heart) then
			return 1000
		else
			return 0
		end
	end
}
--[[
	技能名：武圣
	相关武将：界限突破·关羽、JSP·关羽、SP·关羽、标准·关羽、翼·关羽、2013-3v3·关羽、1v1·关羽1v1
	描述：你可以将一张红色牌当【杀】使用或打出。
	引用：LuaWusheng
	状态：0405验证通过
]]--
LuaWusheng = sgs.CreateOneCardViewAsSkill{
	name = "LuaWusheng",
	response_or_use = true,
	view_filter = function(self, card)
		if not card:isRed() then return false end
		if sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_SuitToBeDecided, -1)
			slash:addSubcard(card:getEffectiveId())
			slash:deleteLater()
			return slash:isAvailable(sgs.Self)
		end
		return true
	end,
	view_as = function(self, card)
		local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
		slash:addSubcard(card:getId())
		slash:setSkillName(self:objectName())
		return slash
	end,
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player)
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "slash"
	end
}
	技能名：武神（锁定技）
	相关武将：神·关羽
	描述：你的红桃手牌均视为【杀】；你使用红桃【杀】时无距离限制。
]]--
-----------
--[[X区]]--
-----------
--[[
	技能名：惜粮
	相关武将：倚天·张公祺
	描述：你可将其他角色弃牌阶段弃置的红牌收为“米”或加入手牌
	引用：LuaXiliang
	状态：1217验证通过
]]--
LuaXiliang = sgs.CreateTriggerSkill{
	name = "LuaXiliang" ,
	events = {sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Discard then return false end
		local zhanglu = room:findPlayerBySkillName(self:objectName())
		if not zhanglu then return false end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName()
				and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
			for _, id in sgs.qlist(move.card_ids) do
				local c = sgs.Sanguosha:getCard(id)
				if (room:getCardPlace(id) == sgs.Player_DiscardPile) and c:isRed() then dummy:addSubcard(id) end
			end
		end
		if dummy:subcardsLength() == 0 then return false end
		if not zhanglu:askForSkillInvoke(self:objectName(), data) then return false end
		local canput = (5 - zhanglu:getPile("rice"):length() >= dummy:subcardsLength())
		if canput then
			if room:askForChoice(zhanglu, self:objectName(), "put+obtain") == "put" then
				zhanglu:addToPile("rice", dummy)
			else
				zhanglu:obtainCard(dummy)
			end
		else
			zhanglu:obtainCard(dummy)
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and (not target:hasSkill(self:objectName()))
	end
}
--[[
	技能名：陷嗣
	相关武将：一将成名2013·刘封
	描述：准备阶段开始时，你可以将一至两名角色的各一张牌置于你的武将牌上，称为“逆”。其他角色可以将两张“逆”置入弃牌堆，视为对你使用一张【杀】。
	引用：LuaXiansi LuaXiansiAttach LuaXiansiSlash（技能暗将）
	状态：1217验证通过
]]--
LuaXiansiCard = sgs.CreateSkillCard{
	name = "LuaXiansiCard", 
	target_fixed = false,
	filter = function(self, targets, to_select) 
		return #targets < 2 and not to_select:isNude()
	end,
	on_effect = function(self, effect) 
		if effect.to:isNude() then return end
		local id = effect.from:getRoom():askForCardChosen(effect.from, effect.to, "he", "LuaXiansi")
		effect.from:addToPile("counter", id)
	end,
}

LuaXiansiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXiansi",
	response_pattern = "@@LuaXiansi",
	view_as = function(self) 
		return LuaXiansiCard:clone()
	end, 
}

LuaXiansi = sgs.CreateTriggerSkill{
	name = "LuaXiansi", 
	events = {sgs.EventPhaseStart}, 
	view_as_skill = LuaXiansiVS,
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Start then
			player:getRoom():askForUseCard(player, "@@LuaXiansi", "@xiansi-card")
		end
	end,
}

LuaXiansiAttach = sgs.CreateTriggerSkill{
	name = "#LuaXiansiAttach", 
	events = {sgs.TurnStart,sgs.EventAcquireSkill,sgs.EventLoseSkill}, 
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local source = room:findPlayerBySkillName("LuaXiansi")
		if event == sgs.TurnStart then
			if (event == sgs.TurnStart and source and source:isAlive()) or (event == sgs.EventAcquireSkill and data:toString() == "LuaXiansi") then
				for _,p in sgs.qlist(room:getOtherPlayers(source))do
					if not p:hasSkill("LuaXiansiSlash") then
						room:attachSkillToPlayer(p,"LuaXiansiSlash")
					end
				end
			end
		elseif event == sgs.EventLoseSkill and data:toString() == "LuaXiansi"then
			for _,p in sgs.qlist(room:getOtherPlayers(player))do
				if p:hasSkill("LuaXiansiSlash") then
					room:detachSkillFromPlayer(p, "LuaXiansiSlash", true)
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target
	end,
}

LuaXiansiSlashCard = sgs.CreateSkillCard{
	name = "LuaXiansiSlashCard", 
	target_fixed = false,
	filter = function(self, targets, to_select) 
		return to_select:hasSkill("LuaXiansi") and to_select:getPile("counter"):length() >1 and sgs.Self:canSlash(to_select,nil)
	end,
	on_validate = function(self,carduse)
		local source = carduse.from
		local target = carduse.to:first()
		local room = source:getRoom()
		local dummy = sgs.Sanguosha:cloneCard("jink")
		if target:getPile("counter"):length() == 2 then
			dummy:addSubcard(target:getPile("counter"):first())
			dummy:addSubcard(target:getPile("counter"):last())
		else
			local ids = target:getPile("counter")
			for i = 0,1,1 do
				room:fillAG(ids, source);
				local id = room:askForAG(source, ids, false, "LuaXiansi");
				dummy:addSubcard(id);
				ids:removeOne(id);
				room:clearAG(source)
			end
		end
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "LuaXiansi", "");
		room:throwCard(dummy, reason, nil);
		if source:canSlash(target, nil, false) then
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:setSkillName("_LuaXiansi")
			return slash
		end
	end,
}
function canSlashLiufeng (player)
	local liufeng = nil;
	for _,p in sgs.qlist(player:getAliveSiblings()) do
		if (p:hasSkill("LuaXiansi") and p:getPile("counter"):length() > 1) then
			liufeng = p;
			break;
		end
	end
	if liufeng == nil then return false end
	local slash = sgs.Sanguosha:cloneCard("slash")
	return slash:targetFilter(sgs.PlayerList(), liufeng, player);
end

LuaXiansiSlash = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXiansiSlash",
	view_as = function(self) 
		return LuaXiansiSlashCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return sgs.Slash_IsAvailable(player) and canSlashLiufeng(player)
	end, 
	enabled_at_response = function(self, player, pattern)
		return  pattern == "slash"and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE
			   and canSlashLiufeng(player)
	end,
}
--[[
	技能名：陷阵
	相关武将：一将成名·高顺
	描述：出牌阶段限一次，你可以与一名其他角色拼点：若你赢，你获得以下技能：本回合，该角色的防具无效，你无视与该角色的距离，你对该角色使用【杀】无数量限制；若你没赢，你不能使用【杀】，直到回合结束。
	引用：LuaXianzhen
	状态：1217验证通过
]]--
LuaXianzhenCard = sgs.CreateSkillCard{
	name = "LuaXianzhenCard", 
	filter = function(self, targets, to_select) 
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng();
	end,
	on_effect = function(self, effect) 
		local room = effect.from:getRoom();
		if effect.from:pindian(effect.to, "LuaXianzhen",nil) then
			local target = effect.to
			local data = sgs.QVariant()
			data:setValue(target)
			effect.from:setTag("XianzhenTarget",data) 
			room:setPlayerFlag(effect.from, "XianzhenSuccess");
			local assignee_list = effect.from:property("extra_slash_specific_assignee"):toString():split("+")
			table.insert(assignee_list,target:objectName())
			room:setPlayerProperty(effect.from, "extra_slash_specific_assignee", sgs.QVariant(table.concat(assignee_list,"+")))
			room:setFixedDistance(effect.from, effect.to, 1);
			room:addPlayerMark(effect.to, "Armor_Nullified");
		else
			room:setPlayerCardLimitation(effect.from, "use", "Slash", true);
		end
	end,
}

LuaXianzhenVs = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXianzhen",
	view_as = function(self) 
		return LuaXianzhenCard:clone()
	end, 
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#LuaXianzhenCard")) and (not player:isKongcheng())
	end, 
}

LuaXianzhen = sgs.CreateTriggerSkill{
	name = "LuaXianzhen",  
	events = {sgs.EventPhaseChanging,sgs.Death}, 
	view_as_skill = LuaXianzhenVs,
	on_trigger = function(self, event, gaoshun, data)
		if (triggerEvent == sgs.EventPhaseChanging) then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		local room = gaoshun:getRoom()
		local target = gaoshun:getTag("XianzhenTarget"):toPlayer()
		if (triggerEvent == sgs.Death) then
			local death = data:toDeath()
			if death.who:objectName() ~= gaoshun:objectName() then
				if death.who:objectName() == target:objectName() then
					room:setFixedDistance(gaoshun, target, -1);
					gaoshun:removeTag("XianzhenTarget");
					room:setPlayerFlag(gaoshun, "-XianzhenSuccess");
				end
				return false;
			end
		end
		if target then
			local assignee_list = gaoshun:property("extra_slash_specific_assignee"):toString():split("+")
			table.removeOne(assignee_list,target:objectName())
			room:setPlayerProperty(gaoshun, "extra_slash_specific_assignee", sgs.QVariant(table.concat(assignee_list,"+")));
			room:setFixedDistance(gaoshun, target, -1);
			gaoshun:removeTag("XianzhenTarget");
			room:removePlayerMark(target, "Armor_Nullified");
		end
		return false;
	end,
	can_trigger = function(self, target)
		return target and target:getTag("XianzhenTarget"):toPlayer()
	end,
}
--[[
	技能名：享乐（锁定技）
	相关武将：山·刘禅
	描述：当其他角色使用【杀】指定你为目标时，需弃置一张基本牌，否则此【杀】对你无效。
	引用：LuaXiangle
	状态：1217验证通过
]]--
LuaXiangle = sgs.CreateTriggerSkill{
	name = "LuaXiangle" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.SlashEffected, sgs.TargetConfirming} ,
	on_trigger = function(self, event, player, data)
		if event == sgs.TargetConfirming then
			local use = data:toCardUse()
			if use.card and use.card:isKindOf("Slash") then
				player:setMark("LuaXiangle", 0)
				local dataforai = sgs.QVariant()
				dataforai:setValue(player)
				if not player:getRoom():askForCard(use.from,".Basic","@xiangle-discard",dataforai) then
					player:addMark("LuaXiangle")
				end
			end
		else
			local effect= data:toSlashEffect()
			if player:getMark("LuaXiangle") > 0 then
				player:removeMark("LuaXiangle")
				return true
			end
		end
	end
}
--[[
	技能名：枭姬
	相关武将：标准·孙尚香、SP·孙尚香、JSP·孙尚香
	描述：每当你失去一张装备区的装备牌后，你可以摸两张牌。 
	引用：LuaXiaoji
	状态：0405证通过
]]--

LuaXiaoji = sgs.CreateTriggerSkill{
	name = "LuaXiaoji" ,
	frequency = sgs.Skill_Frequent ,
	events = {sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and move.from:objectName() == player:objectName() and move.from_places:contains(sgs.Player_PlaceEquip) then
			for i = 0, move.card_ids:length() - 1, 1 do
				if not player:isAlive() then return false end
				if move.from_places:at(i) == sgs.Player_PlaceEquip then
					if room:askForSkillInvoke(player, self:objectName()) then
						player:drawCards(2)
					else
						break
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：枭姬
	相关武将：1v1·孙尚香1v1
	描述：每当你失去一张装备区的装备牌后，你可以选择一项：摸两张牌，或回复1点体力。
	引用：Lua1V1Xiaoji
	状态：1217验证通过
]]--
Lua1V1Xiaoji = sgs.CreateTriggerSkill{
	name = "Lua1V1Xiaoji" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.from and (move.from:objectName() == player:objectName()) and move.from_places:contains(sgs.Player_PlaceEquip) then
			for i = 0, move.card_ids:length() - 1, 1 do
				if not player:isAlive() then return false end
				if move.from_places:at(i) == sgs.Player_PlaceEquip then
					local choices = {}
					table.insert(choices, "draw")
					table.insert(choices, "cancel") 
					if player:isWounded() then
						table.insert(choices, "recover") 
					end
					local choice
					if #choices == 1 then
						choice = choices[1]
					else
						choice = room:askForChoice(player, self:objectName(), table.concat(choices, "+"))
					end
					if choice == "recover" then
						local recover = sgs.RecoverStruct()
						recover.who = player
						room:recover(player, recover)
					elseif choice == "draw" then
						player:drawCards(2)
					else
						break
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：骁果
	相关武将：国战·乐进、SP乐进
	描述：其他角色的结束阶段开始时，你可以弃置一张基本牌：若如此做，该角色选择一项：1.弃置一张装备牌，然后令你摸一张牌；2.受到1点伤害。 
	引用：LuaXiaoguo
	状态：0405验证通过
]]--
LuaXiaoguo = sgs.CreateTriggerSkill{
	name = "LuaXiaoguo" ,
	events = {sgs.EventPhaseStart} ,
	can_trigger = function(self, target)
		return target ~= nil
	end ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Finish then return false end
		local yuejin = room:findPlayerBySkillName(self:objectName())
		if not yuejin or yuejin:objectName() == player:objectName() then return false end
		if yuejin:canDiscard(yuejin, "h") and room:askForCard(yuejin, ".Basic", "@xiaoguo", sgs.QVariant(), self:objectName()) then
			if not room:askForCard(player, ".Equip", "@xiaoguo-discard", sgs.QVariant()) then
				room:damage(sgs.DamageStruct(self:objectName(), yuejin, player))
			else--如果是写国战·骁果的话这一行和下一行删除
				yuejin:drawCards(1, self:objectName())
			end
		end
		return false
	end
}
--[[
	技能名：骁袭
	相关武将：1v1·马超1v1
	描述：你登场时，你可以视为使用一张【杀】。
	引用：LuaXiaoxi
	状态：1217验证通过
]]--
LuaXiaoxi = sgs.CreateTriggerSkill{
	name = "LuaXiaoxi",
	events = {sgs.Debut},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local opponent = player:getNext()
		if not opponent:isAlive() then
			return false
		end
		local aSlash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		aSlash:setSkillName(self:objectName())
		if not aSlash:isAvailable(player) or not player:canSlash(opponent, nil) then
			aSlash = nil
			return false
		end
		if player:askForSkillInvoke(self:objectName()) then
			room:useCard(sgs.CardUseStruct(aSlash, player, opponent), false)
			return false
		end
	end
}
--[[
	技能名：孝德
	相关武将：SP·夏侯氏
	描述：每当一名其他角色死亡结算后，你可以拥有该角色武将牌上的一项技能（除主公技与觉醒技），且“孝德”无效，直到你的回合结束时。每当你失去“孝德”后，你失去以此法获得的技能。 
	引用：LuaXiaode, LuaXiaoEx
	状态：1217验证通过
]]--
function addSkillList(general)
	if not general then return nil end
	local skill_list = {}
	for _, skill in sgs.qlist(general:getSkillList()) do
		if skill:isVisible() and not skill:isLordSkill() and skill:getFrequency() ~= sgs.Skill_Wake then
			table.insert(skill_list, skill:objectName())
		end
	end
	return table.concat(skill_list, "+")
end
LuaXiaode = sgs.CreateTriggerSkill{
	name = "LuaXiaode" ,
	events = {sgs.BuryVictim} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xiahoushi = room:findPlayerBySkillName(self:objectName())
		if not xiahoushi or xiahoushi:getTag("LuaXiaodeSkill"):toString() ~= "" then return false end
		local skill_list = xiahoushi:getTag("LuaXiaodeVictimSkills"):toString():split("+")
		if #skill_list == 0 then return false end
		if not room:askForSkillInvoke(xiahoushi, self:objectName()) then return false end
		local skill_name = room:askForChoice(xiahoushi, self:objectName(), table.concat(skill_list, "+"))
		xiahoushi:setTag("LuaXiaodeSkill", sgs.QVariant(skill_name))
		room:acquireSkill(xiahoushi, skill_name)
			return false
	end ,
	can_trigger = function(self, target)
		return target ~= nil
	end ,
	priority = -2
}
LuaXiaodeEx = sgs.CreateTriggerSkill{
	name = "#LuaXiaode" ,
	events = {sgs.EventPhaseChanging, sgs.EventLoseSkill, sgs.Death} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
				local skill_name = player:getTag("LuaXiaodeSkill"):toString()
				if skill_name ~= "" then
					room:detachSkillFromPlayer(player, skill_name, false, true)
							player:setTag("LuaXiaodeSkill", sgs.QVariant())
				end
			end
		elseif event == sgs.EventLoseSkill and data:toString() == sef:objectName() then
			local skill_name = player:getTag("LuaXiaodeSkill"):toString()
			if skill_name ~= "" then
				room:detachSkillFromPlayer(player, skill_name, false, true)
						player:setTag("LuaXiaodeSkill", sgs.QVariant())
			end
		elseif event == sgs.Death and self:triggerable(player) then
			local death = data:toDeath()
			local skill_list = {}
			table.insert(skill_list, addSkillList(death.who:getGeneral()))
			table.insert(skill_list, addSkillList(death.who:getGeneral2()))
			player:setTag("LuaXiaodeVictimSkills", sgs.QVariant(table.concat(skill_list, "+")))
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：挟缠（限定技）
	相关武将：1v1·许褚1v1
	描述：出牌阶段，你可以与对手拼点：若你赢，视为你对对手使用一张【决斗】；若你没赢，视为对手对你使用一张【决斗】。
	引用：LuaXiechan
	状态：1217验证通过
]]--
LuaXiechanCard = sgs.CreateSkillCard{
	name = "LuaXiechanCard",
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and not to_select:isKongcheng() 
	end,
	on_use = function(self, room, xuchu, targets)
		room:removePlayerMark(xuchu,"@twine")
		local succes = xuchu:pindian(targets[1], "LuaXiechan")
		local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
		duel:setSkillName("LuaXiechan")
		local from, to = nil, nil
		if succes then
			from = xuchu
			to = targets[1]
		else
			from = targets[1]
			to = xuchu
		end
		if not from:isLocked(duel) and not from:isProhibited(to, duel) then
			room:useCard(sgs.CardUseStruct(duel,from, to))
		end
	end
}
LuaXiechanVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXiechan",
	view_as = function(self, cards)
		return LuaXiechanCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@twine") >= 1 and not player:isKongcheng()
	end
}
LuaXiechan = sgs.CreateTriggerSkill{
	name = "LuaXiechan",
	frequency = sgs.Skill_Limited,
	limit_mark = "@twine",
	events = {sgs.GameStart},
	view_as_skill = LuaXiechanVS,
	on_trigger = function()
		return false
	end
}
--[[
	技能名：心战
	相关武将：一将成名·马谡
	描述：出牌阶段，若你的手牌数大于你的体力上限，你可以：观看牌堆顶的三张牌，然后亮出其中任意数量的红桃牌并获得之，其余以任意顺序置于牌堆顶。每阶段限一次。
	引用：LuaXinzhan
	状态：1217验证通过
]]--
LuaXinzhanCard = sgs.CreateSkillCard{
	name = "LuaXinzhanCard" ,
	target_fixed = true ,
	on_use = function(self, room, source, targets)
		local cards = room:getNCards(3)
		local left = cards
		local hearts = sgs.IntList()
		local non_hearts = sgs.IntList()
		for _, card_id in sgs.qlist(cards) do
			local card = sgs.Sanguosha:getCard(card_id)
			if card:getSuit() == sgs.Card_Heart then
				hearts:append(card_id)
			else
				non_hearts:append(card_id)
			end
		end
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not hearts:isEmpty() then
			repeat
				room:fillAG(left, source, non_hearts)
				local card_id = room:askForAG(source, hearts, true, "LuaXinzhan")
				if (card_id == -1) then
					room:clearAG(source)
					break
				end
				hearts:removeOne(card_id)
				left:removeOne(card_id)
				dummy:addSubcard(card_id)
				room:clearAG(source)
			until hearts:isEmpty()
			if dummy:subcardsLength() > 0 then
				room:doBroadcastNotify(56, tostring(room:getDrawPile():length() + dummy:subcardsLength()))
				source:obtainCard(dummy)
				for _, id in sgs.qlist(dummy:getSubcards()) do
					room:showCard(source, id)
				end
			end
		end
		if not left:isEmpty() then
			room:askForGuanxing(source, left, sgs.Room_GuanxingUpOnly)
		end
	end ,
}
LuaXinzhan = sgs.CreateViewAsSkill{
	name = "LuaXinzhan" ,
	n = 0,
	view_as = function()
		return LuaXinzhanCard:clone()
	end ,
	enabled_at_play = function(self, player)
		return (not player:hasUsed("#LuaXinzhanCard")) and (player:getHandcardNum() > player:getMaxHp())
	end
}
--[[
	技能名：新生
	相关武将：山·左慈
	描述：每当你受到1点伤害后，你可以获得一张“化身牌”。
	引用：LuaXinSheng
	状态：1217验证通过
	备注：需调用ChapterH 的acquireGenerals 函数
]]--
LuaXinSheng = sgs.CreateTriggerSkill{
	name = "LuaXinSheng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName()) then
			AcquireGenerals(player, data:toDamage().damage) --需调用ChapterH 的acquieGenerals 函数
		end
	end
}
--[[
	技能名：星舞
	相关武将：SP·大乔&小乔
	描述：弃牌阶段开始时，你可以将一张与你本回合使用的牌颜色均不同的手牌置于武将牌上。
		若你有三张“星舞牌”，你将其置入弃牌堆，然后选择一名男性角色，你对其造成2点伤害并弃置其装备区的所有牌。
	引用：LuaXingwu
	状态：1217验证通过
]]--
LuaXingwu = sgs.CreateTriggerSkill{
	name = "LuaXingwu" ,
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseStart, sgs.CardsMoveOneTime} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if (event == sgs.PreCardUsed) or (event == sgs.CardResponded) then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and (card:getTypeId() ~= sgs.Card_TypeSkill) and (card:getHandlingMethod() == sgs.Card_MethodUse) then
				local n = player:getMark(self:objectName())
				if card:isBlack() then
					n = bit32.bor(n, 1)
				elseif card:isRed() then
					n = bit32.bor(n, 2)
				end
				player:setMark(self:objectName(), n)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Discard then
				local n = player:getMark(self:objectName())
				local red_avail = (bit32.band(n, 2) == 0)
				local black_avail = (bit32.band(n, 1) == 0)
				if player:isKongcheng() or ((not red_avail) and (not black_avail)) then return false end
				local pattern = ".|.|.|hand"
				if red_avail ~= black_avail then
					if red_avail then
						pattern = ".|red|.|hand"
					else
						pattern = ".|black|.|hand"
					end
				end
				local card = room:askForCard(player, pattern, "@xingwu", sgs.QVariant(), sgs.Card_MethodNone)
				if card then
					player:addToPile(self:objectName(), card)
				end
			elseif player:getPhase() == sgs.Player_RoundStart then
				player:setMark(self:objectName(), 0)
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (move.to and move.to:objectName() == player:objectName()) and (move.to_place == sgs.Player_PlaceSpecial) and (player:getPile(self:objectName()):length() >= 3) then
				player:clearOnePrivatePile(self:objectName())
				local males = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:isMale() then
						males:append(p)
					end
				end
				if males:isEmpty() then return false end
				local target = room:askForPlayerChosen(player, males, self:objectName(), "@xingwu-choose")
				room:damage(sgs.DamageStruct(self:objectName(), player, target, 2))
				if not player:isAlive() then return false end
				local equips = target:getEquips()
				if not equips:isEmpty() then
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					for _, equip in sgs.qlist(equips) do
						if player:canDiscard(target, equip:getEffectiveId()) then
							dummy:addSubcard(equip)
						end
					end
					if dummy:subcardsLength() > 0 then
						room:throwCard(dummy, target, player)
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：行殇
	相关武将：林·曹丕、铜雀台·曹丕
	描述：每当一名其他角色死亡时，你可以获得该角色的牌。    
	引用：LuaXingshang
	状态：0405验证通过
]]--
LuaXingshang = sgs.CreateTriggerSkill{
	name = "LuaXingshang",
	events = {sgs.Death},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		local splayer = death.who
		if splayer:objectName() == player:objectName() or player:isNude() then return false end
		if player:isAlive() and room:askForSkillInvoke(player, self:objectName(), data) then
			local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
			local cards = splayer:getCards("he")
			for _,card in sgs.qlist(cards) do
				dummy:addSubcard(card)
			end
			if cards:length() > 0 then
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_RECYCLE, player:objectName())
				room:obtainCard(player, dummy, reason, false)
			end
			dummy:deleteLater()
		end
		return false
	end
}
--[[
	技能：雄异（限定技）
	相关武将：国战·马腾
	描述：出牌阶段，你可以令你与任意数量的角色摸三张牌：若以此法摸牌的角色数不大于全场角色数的一半，你回复1点体力。
	引用：LuaXiongyi
	状态：1217验证通过
]]--
LuaXiongyiCard = sgs.CreateSkillCard{
	name = "LuaXiongyiCard",
	mute = true,
	target_fixed = false,
	will_throw = true,
	filter = function(self, targets, to_select)
		return true
	end,
	feasible = function(self, targets)
		return true
	end,
	about_to_use = function(self, room, cardUse)
		local use = cardUse
		if not use.to:contains(use.from) then
			use.to:append(use.from)
		end
		room:removePlayerMark(use.from, "@arise")
		self:cardOnUse(room, use)
	end,
	on_use = function(self, room, source, targets)
		for _,p in ipairs(targets) do
			p:drawCards(3)
		end
		if #targets <= room:getAlivePlayers():length() / 2 and source:isWounded() then
			local rec = sgs.RecoverStruct()
			rec.who = source
			room:recover(source, rec)
		end
	end
}
LuaXiongyiVS = sgs.CreateZeroCardViewAsSkill{
	name = "LuaXiongyi",
	view_as = function(self, cards)
		return LuaXiongyiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@arise") >= 1
	end
}
LuaXiongyi = sgs.CreateTriggerSkill{
	name = "LuaXiongyi",
	frequency = sgs.Skill_Limited,
	events = {sgs.GameStart},
	limit_mark = "@arise",
	view_as_skill = LuaXiongyiVS,
	on_trigger = function()
	end
}

--[[
	技能名：修罗
	相关武将：SP·暴怒战神
	描述：准备阶段开始时，你可以弃置一张与判定区内延时锦囊牌花色相同的手牌：若如此做，你弃置该延时锦囊牌。 
	引用：LuaXiuluo
	状态：0405验证通过
]]--
hasDelayedTrickXiuluo = function(target)
	for _, card in sgs.qlist(target:getJudgingArea()) do
		if not card:isKindOf("SkillCard") then return true end
	end
	return false
end
containsTable = function(t, tar)
	for _, i in ipairs(t) do
		if i == tar then return true end
	end
	return false
end
LuaXiuluo = sgs.CreatePhaseChangeSkill{
	name = "LuaXiuluo" ,
	on_phasechange = function(self, player)
		local room = player:getRoom()
		while hasDelayedTrickXiuluo(player) and player:canDiscard(player, "h") do
			local suits = {}
			for _, jcard in sgs.qlist(player:getJudgingArea()) do
				if not containsTable(suits, jcard:getSuitString()) then
					table.insert(suits, jcard:getSuitString())
				end
			end
			local card = room:askForCard(player, ".|" .. table.concat(suits, ",") .. "|.|hand", "@xiuluo", sgs.QVariant(), self:objectName())
			if not card or not hasDelayedTrickXiuluo(player) then break end
			local avail_list = sgs.IntList()
			local other_list = sgs.IntList()
			local all_list = sgs.IntList()
			for _, jcard in sgs.qlist(player:getJudgingArea()) do
				if jcard:isKindOf("SkillCard") then continue end
				if jcard:getSuit() == card:getSuit() then
					avail_list:append(jcard:getEffectiveId())
				else
					other_list:append(jcard:getEffectiveId())
				end
			end
			for _, l in sgs.qlist(avail_list) do
				all_list:append(l)
			end
			for _, l in sgs.qlist(other_list) do
				all_list:append(l)
			end
			room:fillAG(all_list, nil, other_list)
			local id = room:askForAG(player, avail_list, false, self:objectName())
			room:clearAG()
			room:throwCard(id, nil)
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName())and target:getPhase() == sgs.Player_Start
		and target:canDiscard(target, "h") and hasDelayedTrickXiuluo(target)
	end
}
--[[
	技能名：旋风
	相关武将：一将成名·凌统
	描述：当你失去装备区里的牌时，或于弃牌阶段内弃置了两张或更多的手牌后，你可以依次弃置一至两名其他角色的共计两张牌。
	引用：LuaXuanfeng
	状态：1217验证通过
]]--
LuaXuanfengCard = sgs.CreateSkillCard{
	name = "LuaXuanfengCard" ,
	filter = function(self, targets, to_select)
		if #targets >= 2 then return false end
		if to_select:objectName() == sgs.Self:objectName() then return false end
		return sgs.Self:canDiscard(to_select, "he")
	end ,
	on_use = function(self, room, source, targets)
		local map = {}
		local totaltarget = 0
		for _, sp in ipairs(targets) do
			map[sp] = 1
		end
		totaltarget = #targets
		if totaltarget == 1 then
			for _, sp in ipairs(targets) do
				map[sp] = map[sp] + 1
			end
		end
		for _, sp in ipairs(targets) do
			while map[sp] > 0 do
				if source:isAlive() and sp:isAlive() and source:canDiscard(sp, "he") then
					local card_id = room:askForCardChosen(source, sp, "he", self:objectName(), false, sgs.Card_MethodDiscard)
					room:throwCard(card_id, sp, source)
				end
				map[sp] = map[sp] - 1
			end
		end
	end
}
LuaXuanfengVS = sgs.CreateViewAsSkill{
	name = "LuaXuanfeng" ,
	n = 0 ,
	view_as = function()
		return LuaXuanfengCard:clone()
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, target, pattern)
		return pattern == "@@LuaXuanfeng"
	end
}
LuaXuanfeng = sgs.CreateTriggerSkill{
	name = "LuaXuanfeng" ,
	events = {sgs.CardsMoveOneTime, sgs.EventPhaseStart} ,
	view_as_skill = LuaXuanfengVS ,
	on_trigger = function(self, event, player, data)
		if event == sgs.EventPhaseStart then
			player:setMark("LuaXuanfeng", 0)
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if (not move.from) or (move.from:objectName() ~= player:objectName()) then return false end
			if (move.to_place == sgs.Player_DiscardPile) and (player:getPhase() == sgs.Player_Discard)
					and (bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD) then
				player:setMark("LuaXuanfeng", player:getMark("LuaXuanfeng") + move.card_ids:length())
			end
			if ((player:getMark("LuaXuanfeng") >= 2) and (not player:hasFlag("LuaXuanfengUsed")))
					or move.from_places:contains(sgs.Player_PlaceEquip) then
				local room = player:getRoom()
				local targets = sgs.SPlayerList()
				for _, target in sgs.qlist(room:getOtherPlayers(player)) do
					if player:canDiscard(target, "he") then
						targets:append(target)
					end
				end
				if targets:isEmpty() then return false end
				local choice = room:askForChoice(player, self:objectName(), "throw+nothing") --这个地方令我非常无语…………用askForSkillInvoke不好么…………
				if choice == "throw" then
					--player:setFlags("LuaXuanfengUsed") --这是源码Bug的地方
					if player:getPhase() == sgs.Player_Discard then player:setFlags("LuaXuanfengUsed") end --修复源码Bug
					room:askForUseCard(player, "@@LuaXuanfeng", "@xuanfeng-card")
				end
			end
		end
		return false
	end
}
--[[
	技能名：旋风
	相关武将：怀旧·凌统
	描述：当你失去一次装备区里的牌时，你可以选择一项：1. 视为对一名其他角色使用一张【杀】；你以此法使用【杀】时无距离限制且不计入出牌阶段内的使用次数限制。2. 对距离为1的一名角色造成1点伤害。
	引用：LuaNosXuanfeng
	状态：1217验证通过
]]--
LuaNosXuanfeng = sgs.CreateTriggerSkill{
	name = "LuaNosXuanfeng",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardsMoveOneTime},
	on_trigger = function(self, event, player, data)
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and move.from:objectName() == player:objectName() then
				if move.from_places:contains(sgs.Player_PlaceEquip) then
					local room = player:getRoom()
					local choicecount = 1
					local choicelist = "nothing"
					local targets1 = sgs.SPlayerList()
					local list = room:getAlivePlayers()
					for _,target in sgs.qlist(list) do
						if player:canSlash(target, nil, false) then
							targets1:append(target)
						end
					end
					if targets1:length() > 0 then
						choicelist = string.format("%s+%s", choicelist, "slash")
						choicecount = choicecount + 1
					end
					local targets2 = sgs.SPlayerList()
					others = room:getOtherPlayers(player)
					for _,p in sgs.qlist(others) do
						if player:distanceTo(p) <= 1 then
							targets2:append(p)
						end
					end
					if targets2:length() > 0 then
						choicelist = string.format("%s+%s", choicelist, "damage")
						choicecount = choicecount + 1
					end
					if choicecount > 1 then
						local choice = room:askForChoice(player, self:objectName(), choicelist)
						if choice == "slash" then
							local target = room:askForPlayerChosen(player, targets1, "xuanfeng-slash")
							local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							slash:setSkillName(self:objectName())
							local card_use = sgs.CardUseStruct()
							card_use.card = slash
							card_use.from = player
							card_use.to:append(target)
							room:useCard(card_use, false)
						elseif choice == "damage" then
							local target = room:askForPlayerChosen(player, targets2, "xuanfeng-damage")
							local damage = sgs.DamageStruct()
							damage.from = player
							damage.to = target
							room:damage(damage)
						end
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：眩惑
	相关武将：一将成名·法正
	描述：摸牌阶段开始时，你可以放弃摸牌，改为令一名其他角色摸两张牌，然后令其对其攻击范围内你选择的另一名角色使用一张【杀】，若该角色未如此做或其攻击范围内没有其他角色，你获得其两张牌。
	引用：LuaXuanhuo、LuaXuanhuoFakeMove
	状态：1217验证通过
]]--

LuaXuanhuo = sgs.CreateTriggerSkill{
	name = "LuaXuanhuo" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Draw then
			local to = room:askForPlayerChosen(player, room:getOtherPlayers(player), self:objectName(), "xuanhuo-invoke", true, true)
			if to then
				room:drawCards(to, 2)
				if (not player:isAlive()) or (not to:isAlive()) then return true end
				local targets = sgs.SPlayerList()
				for _, vic in sgs.qlist(room:getOtherPlayers(to)) do
					if to:canSlash(vic) then
						targets:append(vic)
					end
				end
				local victim
				if not targets:isEmpty() then
					victim = room:askForPlayerChosen(player, targets, "xuanhuo_slash", "@dummy-slash2:" .. to:objectName())
				end
				if victim then --不得已写了两遍movecard…………
					if not room:askForUseSlashTo(to, victim, "xuanhuo-slash:" .. player:objectName() .. ":" .. victim:objectName()) then
						if to:isNude() then return true end
						room:setPlayerFlag(to, "LuaXuanhuo_InTempMoving")
						local first_id = room:askForCardChosen(player, to, "he", self:objectName())
						local original_place = room:getCardPlace(first_id)
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						dummy:addSubcard(first_id)
						to:addToPile("#xuanhuo", dummy, false)
						if not to:isNude() then
							local second_id = room:askForCardChosen(player, to, "he", self:objectName())
							dummy:addSubcard(second_id)
						end
						room:moveCardTo(sgs.Sanguosha:getCard(first_id), to, original_place, false)
						room:setPlayerFlag(to, "-LuaXuanhuo_InTempMoving")
						room:moveCardTo(dummy, player, sgs.Player_PlaceHand, false)
						--delete dummy
					end
				else
					if to:isNude() then return true end
					room:setPlayerFlag(to, "LuaXuanhuo_InTempMoving")
					local first_id = room:askForCardChosen(player, to, "he", self:objectName())
					local original_place = room:getCardPlace(first_id)
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					dummy:addSubcard(first_id)
					to:addToPile("#xuanhuo", dummy, false)
					if not to:isNude() then
						local second_id = room:askForCardChosen(player, to, "he", self:objectName())
						dummy:addSubcard(second_id)
					end
					room:moveCardTo(sgs.Sanguosha:getCard(first_id), to, original_place, false)
					room:setPlayerFlag(to, "-LuaXuanhuo_InTempMoving")
					room:moveCardTo(dummy, player, sgs.Player_PlaceHand, false)
					--delete dummy
				end
				return true
			end
		end
		return false
	end
}
LuaXuanhuoFakeMove = sgs.CreateTriggerSkill{
	name = "#LuaXuanhuo-fake-move" ,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime} ,
	priority = 10 ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("LuaXuanhuo_InTempMoving") then return true end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end,
}
--[[
	技能名：眩惑
	相关武将：怀旧·法正
	描述：出牌阶段，你可以将一张红桃手牌交给一名其他角色，然后你获得该角色的一张牌并交给除该角色外的其他角色。每阶段限一次。
	引用：LuaNosXuanhuo
	状态：1217验证通过
]]--
LuaNosXuanhuoCard = sgs.CreateSkillCard{
	name = "LuaNosXuanhuoCard",
	target_fixed = false,
	will_throw = true,
	on_effect = function(self, effect)
		local source = effect.from
		local dest = effect.to
		dest:obtainCard(self)
		local room = source:getRoom()
		local card_id = room:askForCardChosen(source, dest, "he", self:objectName())
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, source:objectName())
		local card = sgs.Sanguosha:getCard(card_id)
		local place = room:getCardPlace(card_id)
		local unhide = (place ~= sgs.Player_PlaceHand)
		room:obtainCard(source, card, unhide)
		local targets = room:getOtherPlayers(dest)
		local target = room:askForPlayerChosen(source, targets, self:objectName())
		if target:objectName() ~= source:objectName() then
			reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, source:objectName())
			reason.m_playerId = target:objectName()
			room:obtainCard(target, card, false)
		end
	end
}
LuaNosXuanhuo = sgs.CreateViewAsSkill{
	name = "LuaNosXuanhuo",
	n = 1,
	view_filter = function(self, selected, to_select)
		if not to_select:isEquipped() then
			return to_select:getSuit() == sgs.Card_Heart
		end
		return false
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local xuanhuoCard = LuaNosXuanhuoCard:clone()
			xuanhuoCard:addSubcard(cards[1])
			return xuanhuoCard
		end
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaNosXuanhuoCard")
	end
}
--[[
	技能名：雪恨（锁定技）
	相关武将：☆SP·夏侯惇
	描述：一名角色的结束阶段开始时，若你的体力牌处于竖置状态，你横置之，然后选择一项：1.弃置当前回合角色X张牌。 2.视为你使用一张无距离限制的【杀】。（X为你已损失的体力值）
	引用：LuaXuehen、LuaXuehenNDL、LuaXuehenFakeMove
	状态：1217验证通过
]]--
LuaXuehen = sgs.CreateTriggerSkill{
	name = "LuaXuehen" ,
	events = {sgs.EventPhaseStart} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local xiahou = room:findPlayerBySkillName(self:objectName())
		if not xiahou then return false end
		if (player:getPhase() == sgs.Player_Finish) and (xiahou:getMark("@fenyong") > 0) then
			xiahou:loseMark("@fenyong")
			local targets = sgs.SPlayerList()
			for _, p in sgs.qlist(room:getOtherPlayers(xiahou)) do
				if xiahou:canSlash(p, nil, false) then
					targets:append(p)
				end
			end
			local choice
			if (not sgs.Slash_IsAvailable(xiahou)) or targets:isEmpty() then
				choice = "discard"
			else
				choice = room:askForChoice(xiahou, self:objectName(), "discard+slash")
			end
			if choice == "slash" then
				local victim = room:askForPlayerChosen(xiahou, targets, self:objectName(), "@dummy-slash")
				local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				slash:setSkillName(self:objectName())
				room:useCard(sgs.CardUseStruct(slash, xiahou, victim), false)
			else
				room:setPlayerFlag(player, "LuaXuehen_InTempMoving")
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				local card_ids = sgs.IntList()
				local original_places = sgs.IntList()
				for i = 0, xiahou:getLostHp() - 1, 1 do
					if not xiahou:canDiscard(player, "he") then break end
					card_ids:append(room:askForCardChosen(xiahou, player, "he", self:objectName(), false, sgs.Card_MethodDiscard))
					original_places:append(room:getCardPlace(card_ids:at(i)))
					dummy:addSubcard(card_ids:at(i))
					player:addToPile("#xuehen", card_ids:at(i), false)
				end
				for i = 0, dummy:subcardsLength() - 1, 1 do
					room:moveCardTo(sgs.Sanguosha:getCard(card_ids:at(i)), player, original_places:at(i), false)
				end
				room:setPlayerFlag(player, "-LuaXuehen_InTempMoving")
				if dummy:subcardsLength() > 0 then
					room:throwCard(dummy, player, xiahou)
				end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end ,
}
LuaXuehenNDL = sgs.CreateTargetModSkill{
	name = "#LuaXuehen-slash-ndl" ,
	pattern = "Slash" ,
	distance_limit_func = function(self, player, card)
		if player:hasSkill("LuaXuehen") and (card:getSkillName() == "LuaXuehen") then
			return 1000
		else
			return 0
		end
	end
}
LuaXuehenFakeMove = sgs.CreateTriggerSkill{
	name = "#LuaXuehen-fake-move" ,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime} ,
	priority = 10 ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:hasFlag("LuaXuehen_InTempMoving") then return true end
		end
		return false
	end
}
--[[
	技能名：血祭
	相关武将：SP·关银屏
	描述：出牌阶段限一次，你可以弃置一张红色牌并选择你攻击范围内的至多X名角色：若如此做，你对这些角色各造成1点伤害，然后这些角色各摸一张牌。（X为你已损失的体力值） 
	引用：LuaXueji
	状态：0405验证通过
]]--
LuaXuejiCard = sgs.CreateSkillCard{
	name = "LuaXuejiCard" ,
	filter = function(self, targets, to_select)
		if #targets >= sgs.Self:getLostHp() then return false end
		if to_select:objectName() == sgs.Self:objectName() then return false end
		local rangefix = 0
		if not self:getSubcards():isEmpty() and sgs.Self:getWeapon() and sgs.Self:getWeapon():getId() == self:getSubcards():first() then
			local card = sgs.Self:getWeapon():getRealCard():toWeapon()
			rangefix = rangefix + card:getRange() - sgs.Self:getAttackRange(false)
		end
		return sgs.Self:inMyAttackRange(to_select, rangefix)
	end ,
	on_use = function(self, room, source, targets)
		local damage = sgs.DamageStruct()
		damage.from = source
		damage.reason = "LuaXueji"
		for _, p in ipairs(targets) do
			damage.to = p
			room:damage(damage)
		end
		for _, p in ipairs(targets) do
			if p:isAlive() then
				p:drawCards(1, "LuaXueji")
			end
		end
	end
}
LuaXueji = sgs.CreateOneCardViewAsSkill{
	name = "LuaXueji" ,
	filter_pattern = ".|red!" ,
	view_as = function(self, card)
		local first = LuaXuejiCard:clone()
		first:addSubcard(card:getId())
		first:setSkillName(self:objectName())
		return first
	end ,
	enabled_at_play = function(self, player)
		return player:getLostHp() > 0 and player:canDiscard(player, "he") and not player:hasUsed("#LuaXuejiCard")
	end
}
--[[
	技能名：血裔（主公技、锁定技）
	相关武将：火·袁绍
	描述：每有一名其他群雄角色存活，你的手牌上限便+2。
	引用：LuaXueyi
	状态：1217验证通过
]]--
LuaXueyi = sgs.CreateMaxCardsSkill{
	name = "LuaXueyi$",
	extra_func = function(self, target)
		local extra = 0
		local players = target:getSiblings()
		for _,player in sgs.qlist(players) do
			if player:isAlive() then
				if player:getKingdom() == "qun" then
					extra = extra + 2
				end
			end
		end
		if target:hasLordSkill(self:objectName()) then
			return extra
		end
	end
}
--[[
	技能名：恂恂
	相关武将：势·李典
	描述：摸牌阶段开始时，你可以放弃摸牌并观看牌堆顶的四张牌，你获得其中的两张牌，然后将其余的牌以任意顺序置于牌堆底。
	引用：LuaXunxun
	状态：1217验证通过
]]--
LuaXunxun = sgs.CreatePhaseChangeSkill{
	name = "LuaXunxun",
	frequency = sgs.Skill_Frequent,

	on_phasechange = function(self,player)
		if player:getPhase() == sgs.Player_Draw then
			local room = player:getRoom()
			if room:askForSkillInvoke(player,self:objectName()) then
			local card_ids = room:getNCards(4)
			local obtained = sgs.IntList()
				room:fillAG(card_ids,player)
			local id1 = room:askForAG(player,card_ids,false,self:objectName())
				card_ids:removeOne(id1)
				obtained:append(id1)
				room:takeAG(player,id1,false)
			local id2 = room:askForAG(player,card_ids,false,self:objectName())
				card_ids:removeOne(id2)
				obtained:append(id2)
				room:clearAG(player)
				room:askForGuanxing(player,card_ids,sgs.Room_GuanxingDownOnly)
			local dummy = sgs.Sanguosha:cloneCard("jink",sgs.Card_NoSuit,0)
			for _,id in sgs.qlist(obtained) do
				dummy:addSubcard(id)
			end
				player:obtainCard(dummy,false)
			return true
			end
		end
	end 
}
--[[
	技能名：迅猛（锁定技）
	相关武将：僵尸·僵尸
	描述：你的杀造成的伤害+1。你的杀造成伤害时若你体力大于1，你流失1点体力。
	引用：LuaXunmeng
	状态：1217验证通过
]]--
LuaXunmeng = sgs.CreateTriggerSkill{
	name = "LuaXunmeng",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.ConfirmDamage},

	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") then
			damage.damage = damage.damage + 1
			data:setValue(damage)
			if player:getHp() > 1 then
				room:loseHp(player)
			end
		end
	end
}
--[[
	技能名：殉志
	相关武将：倚天·姜伯约
	描述：出牌阶段，你可以摸三张牌并变身为其他未上场或已阵亡的蜀势力角色，回合结束后你立即死亡
	引用：LuaXXunzhi
	状态：1217验证通过
]]--
LuaXXunzhiCard = sgs.CreateSkillCard{
	name = "LuaXXunzhiCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		source:drawCards(3)
		local players = room:getAlivePlayers()
		local general_names = {}
		for _,player in sgs.qlist(players) do
			table.insert(general_names, player:getGeneralName())
		end
		local all_generals = sgs.Sanguosha:getLimitedGeneralNames()
		local shu_generals = {}
		for _,name in ipairs(all_generals) do
			local general = sgs.Sanguosha:getGeneral(name)
			if general:getKingdom() == "shu" then
				if not table.contains(general_names, name) then
					table.insert(shu_generals, name)
				end
			end
		end
		local general = room:askForGeneral(source, table.concat(shu_generals, "+"))
		source:setTag("newgeneral", sgs.QVariant(general))
		local isSecondaryHero = not (sgs.Sanguosha:getGeneral(source:getGeneralName()):hasSkill("LuaXXunzhi"))
		if isSecondaryHero then
			source:setTag("originalGeneral",sgs.QVariant(source:getGeneral2Name()))
		else
			source:setTag("originalGeneral",sgs.QVariant(source:getGeneralName()))
		end
		room:changeHero(source, general, false, false, isSecondaryHero)
		room:setPlayerFlag(source, "LuaXXunzhi")
		room:acquireSkill(source, "LuaXXunzhi", false)
	end
}
LuaXXunzhiVS = sgs.CreateViewAsSkill{
	name = "LuaXXunzhi",
	n = 0,
	view_as = function(self, cards)
		return LuaXXunzhiCard:clone()
	end,
	enabled_at_play = function(self, player)
		return not player:hasFlag("LuaXXunzhi")
	end
}
LuaXXunzhi = sgs.CreateTriggerSkill{
	name = "LuaXXunzhi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseChanging},
	view_as_skill = LuaXXunzhiVS,
	on_trigger = function(self, event, player, data)
		if data:toPhaseChange().to == sgs.Player_NotActive then
			if player:hasFlag("LuaXXunzhi") then
				local room = player:getRoom()
				local isSecondaryHero = player:getGeneralName() ~= player:getTag("newgeneral"):toString()
				room:changeHero(player, player:getTag("originalGeneral"):toString(), false, false, isSecondaryHero)
				room:killPlayer(player)
			end
		end
		return false
	end,
}
	技能名：血裔（主公技、锁定技）
	相关武将：火·袁绍
	描述：每有一名其他群雄角色存活，你的手牌上限便+2。
]]--
-----------
--[[Y区]]--
-----------
--[[
	技能名：延祸
	相关武将：1v1·何进
	描述：你死亡时，你可以依次弃置对手的X张牌。（X为你死亡时的牌数）
	引用：LuaYanhuo
	状态：1217验证通过
]]--
LuaYanhuo = sgs.CreateTriggerSkill{
	name = "LuaYanhuo",
	events = {sgs.BeforeGameOverJudge,sgs.Death},
	can_trigger = function(self,target)
		return target and not target:isAlive() and target:hasSkill(self:objectName())
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.BeforeGameOverJudge then
			player:setMark(self:objectName(),player:getCardCount())
		else
			local n = player:getMark(self:objectName())
			if n == 0 then return false end			
			local killer = nil
			if room:getMode() == "02_1v1" then
				killer = room:getOtherPlayers(player):first()
			end
			if killer and killer:isAlive() and player:canDiscard(killer,"he") and room:askForSkillInvoke(player,self:objectName()) then
				for i = 1, n, 1 do
					if player:canDiscard(killer,"he") then
						local card_id = room:askForCardChosen(player,killer,"he",self:objectName(),false,sgs.Card_MethodDiscard)
						room:throwCard(sgs.Sanguosha:getCard(card_id),killer,player)
					else
						break
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：严整
	相关武将：☆SP·曹仁
	描述：若你的手牌数大于你的体力值，你可以将你装备区内的牌当【无懈可击】使用。
	引用：LuaYanzheng
	状态：1217验证通过
]]--
LuaYanzheng = sgs.CreateViewAsSkill{
	name = "LuaYanzheng" ,
	n = 1 ,
	view_filter = function(self, cards, to_select)
		return (#cards == 0) and to_select:isEquipped()
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local ncard = sgs.Sanguosha:cloneCard("nullification", cards[1]:getSuit(), cards[1]:getNumber())
		ncard:addSubcard(cards[1])
		ncard:setSkillName(self:objectName())
		return ncard
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "nullification") and (player:getHandcardNum() > player:getHp())
	end ,
	enabled_at_nullification = function(self, player)
		return (player:getHandcardNum() > player:getHp()) and (not player:getEquips():isEmpty())
	end
}

--[[
	技能名：言笑
	相关武将：☆SP·大乔
	描述：出牌阶段，你可以将一张方块牌置于一名角色的判定区内，判定区内有“言笑”牌的角色下个判定阶段开始时，获得其判定区里的所有牌。
	引用：LuaYanxiao
	状态：1217验证通过
]]--
LuaYanxiaoCard = sgs.CreateTrickCard{
	name = "YanxiaoCard",
	class_name = "YanxiaoCard",
	target_fixed = false,
	subclass = sgs.LuaTrickCard_TypeDelayedTrick, -- LuaTrickCard_TypeNormal, LuaTrickCard_TypeSingleTargetTrick, LuaTrickCard_TypeDelayedTrick, LuaTrickCard_TypeAOE, LuaTrickCard_TypeGlobalEffect
	filter = function(self, targets, to_select) 
		if #targets ~= 0 then return false end
		if to_select:containsTrick("YanxiaoCard") then return false end		
		return true
	end,
	is_cancelable = function(self, effect)
		return false
	end,
}
LuaYanxiaoVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaYanxiao",
	filter_pattern = ".|diamond",
	view_as = function(self,originalCard)
		local yanxiao = LuaYanxiaoCard:clone()
		yanxiao:addSubcard(originalCard:getId())
		yanxiao:setSkillName(self:objectName())
		return yanxiao
	end
}
LuaYanxiao = sgs.CreatePhaseChangeSkill{
	name = "LuaYanxiao",
	view_as_skill = LuaYanxiaoVS,
	can_trigger = function(self,target)
		if target and target:getPhase() == sgs.Player_Judge then			
			if target:containsTrick("YanxiaoCard") then return true end
		end
		return false
	end,
	on_phasechange = function(self,target)
		local room = target:getRoom()
		local move = sgs.CardsMoveStruct()
		local log = sgs.LogMessage()
		log.type = "$YanxiaoGot"
		log.from = target		
		for _,card in sgs.qlist(target:getJudgingArea()) do
			move.card_ids:append(card:getEffectiveId())			
		end
		log.card_str = table.concat(sgs.QList2Table(move.card_ids),"+")
		room:sendLog(log)
		move.to = target
		move.to_place = sgs.Player_PlaceHand
		room:moveCardsAtomic(move,true)
		return false
	end
}
--[[
	技能名：燕语
	相关武将：SP·夏侯氏
	描述：一名角色的出牌阶段开始时，你可以弃置一张牌：若如此做，本回合的出牌阶段内限三次，一张与该牌类型相同的牌置入弃牌堆时，你可以令一名角色获得之。 
	引用：LuaYanyu
	状态：1217验证通过
]]--
LuaYanyu = sgs.CreateTriggerSkill{
	name = "LuaYanyu" ,
	events = {sgs.EventPhaseStart, sgs.BeforeCardsMove , sgs.EventPhaseChanging} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseStart then
			local xiahou = room:findPlayerBySkillName(self:objectName())
			if xiahou and player:getPhase() == sgs.Player_Play then
				if not xiahou:canDiscard(xiahou, "he") then return false end
				local card = room:askForCard(xiahou, "..", "@yanyu-discard", sgs.QVariant(), self:objectName())
				if card then
					xiahou:addMark("LuaYanyuDiscard" .. tostring(card:getTypeId()), 3)
				end
			end
		elseif event == sgs.BeforeCardsMove and self:triggerable(player) then
			local current = room:getCurrent()
			if not current or current:getPhase() ~= sgs.Player_Play then return false end
			local move = data:toMoveOneTime()
			if move.to_place == sgs.Player_DiscardPile then
				local ids, disabled = sgs.IntList(), sgs.IntList()
				local all_ids = move.card_ids
				for _, id in sgs.qlist(move.card_ids) do
					local card = sgs.Sanguosha:getCard(id)
					if player:getMark("LuaYanyuDiscard" .. tostring(card:getTypeId())) > 0 then
						ids:append(id)
					else
						disabled:append(id)
					end
				end
				if ids:isEmpty() then return false end
					while not ids:isEmpty() do
					room:fillAG(all_ids, player, disabled)
					local only = (all_ids:length() == 1)
					local card_id = -1 
					if only then
						card_id = ids:first()
					else
						card_id = room:askForAG(player, ids, true, self:objectName())
					end
					room:clearAG(player)
					if card_id == -1 then break end
					if only then
						player:setMark("YanyuOnlyId", card_id + 1)
					end
					local card = sgs.Sanguosha:getCard(card_id)
					local target = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(),
						string.format("@yanyu-give:::%s:%s\\%s", card:objectName(), card:getSuitString().."_char"
						, card:getNumberString()),only, true)
					player:setMark("YanyuOnlyId", 0)
					if target then
						player:removeMark("LuaYanyuDiscard" .. tostring(card:getTypeId()))
						local index = move.card_ids:indexOf(card_id)
						local place = move.from_places:at(index)
						move.from_places:removeAt(index)
						move.card_ids:removeOne(card_id)
						data:setValue(move)
						ids:removeOne(card_id)
						disabled:append(card_id)
						for _, id in sgs.qlist(ids) do
							local card = sgs.Sanguosha:getCard(id)
							if player:getMark("LuaYanyuDiscard" .. tostring(card:getTypeId())) == 0 then
												ids:removeOne(id)
												disabled:append(id)
							end
						end
						if move.from and move.from:objectName() == target:objectName() and place ~= sgs.Player_PlaceTable then																																																																																														   
							local log = sgs.LogMessage()
							log.type = "$MoveCard"
							log.from = target
							log.to:append(target)
							log.card_str = tostring(card_id)
							room:sendLog(log)
						end
						target:obtainCard(card)
					else
						break
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Discard then
				for _, p in sgs.qlist(room:getAlivePlayers()) do
							p:setMark("LuaYanyuDiscard1", 0)
							p:setMark("LuaYanyuDiscard2", 0)
							p:setMark("LuaYanyuDiscard3", 0)
						end
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：耀武（锁定技）
	相关武将：标准·华雄
	描述：每当你受到红色【杀】的伤害时，伤害来源选择一项：回复1点体力，或摸一张牌。
	引用：LuaYaowu
	状态：1217验证通过
]]--
LuaYaowu = sgs.CreateTriggerSkill{
	name = "LuaYaowu" ,
	events = {sgs.DamageInflicted} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		if damage.card and damage.card:isKindOf("Slash") and damage.card:isRed() and damage.from and damage.from:isAlive() then
			local choice = "draw"
			if damage.from:isWounded() then
				choice = room:askForChoice(damage.from, self:objectName(), "recover+draw", data)
			end
			if choice == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = damage.to
				room:recover(damage.from, recover)
			else
				damage.from:drawCards(1)
			end
		end
		return false
	end
}


--[[
	技能名：业炎（限定技）
	相关武将：神·周瑜
	描述：出牌阶段，你可以对一至三名角色各造成1点火焰伤害；或你可以弃置四种花色的手牌各一张，失去3点体力并选择一至两名角色：若如此做，你对这些角色造成共计至多3点火焰伤害且对其中一名角色造成至少2点火焰伤害。 
	引用：LuaYeyan
	状态：0405验证通过
]]--

Fire = function(player,target,damagePoint)
	local damage = sgs.DamageStruct()
	damage.from = player
	damage.to = target
	damage.damage = damagePoint
	damage.nature = sgs.DamageStruct_Fire
	player:getRoom():damage(damage)
end
function toSet(self)
	local set = {}
	for _,ele in pairs(self)do
		if not table.contains(set,ele) then
			table.insert(set,ele)
		end
	end
	return set
end
LuaGreatYeyanCard = sgs.CreateSkillCard{
	name="LuaGreatYeyanCard",
	will_throw = true,
	skill_name = "LuaYeyan",
	filter = function(self, targets, to_select)
		local i = 0
		for _,p in pairs(targets)do
			if p:objectName() == to_select:objectName() then
				i = i + 1
			end
		end
		local maxVote = math.max(3-#targets,0)+i
		return maxVote
	end,
	feasible = function(self, targets)
		if self:getSubcards():length() ~= 4 then return false end
		local all_suit = {}
		for _,id in sgs.qlist(self:getSubcards())do
			local c = sgs.Sanguosha:getCard(id)
			if not table.contains(all_suit,c:getSuit()) then
				table.insert(all_suit,c:getSuit())
			else
				return false
			end
		end
		if #toSet(targets) == 1 then
			return true
		elseif #toSet(targets) == 2 then
			return #targets == 3
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local criticaltarget = 0
		local totalvictim = 0
		local map = {}
		for _,sp in pairs(targets)do
			if map[sp:objectName()] then
				map[sp:objectName()] = map[sp:objectName()] + 1
			else
				map[sp:objectName()] = 1
			end
		end
		
		if #targets == 1 then
			map[targets[1]:objectName()] = map[targets[1]:objectName()] + 2
		end
		local target_table = sgs.SPlayerList()
		for sp,va in pairs(map)do
			if va > 1 then criticaltarget = criticaltarget + 1  end
			totalvictim = totalvictim + 1
			for _,p in pairs(targets)do
				if p:objectName() == sp then
					target_table:append(p)
					break
				end
			end
		end
		if criticaltarget > 0 then
			room:removePlayerMark(source, "@flame")	
			room:loseHp(source, 3)	
			room:sortByActionOrder(target_table)
			for _,sp in sgs.qlist(target_table)do
				Fire(source, sp, map[sp:objectName()])
			end
		end
	end,
}
LuaSmallYeyanCard = sgs.CreateSkillCard{
	name="LuaSmallYeyanCard",
	will_throw = true,
	skill_name = "LuaYeyan",
	filter = function(self, targets, to_select)
		return #targets < 3
	end,
	feasible = function(self, targets)
		return #targets > 0
	end,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@flame")
		for _,sp in sgs.list(targets)do
			Fire(source, sp, 1)
		end
	end,
}
LuaYeyanVS = sgs.CreateViewAsSkill{ 
	name = "LuaYeyan",
	n = 4,
	view_filter = function(self, selected, to_select)
		if to_select:isEquipped() or sgs.Self:isJilei(to_select) then
			return false
		end
		for _,ca in sgs.list(selected)do
			if ca:getSuit() == to_select:getSuit() then return false end
		end
		return true
	end,
	view_as = function(self,cards) 
		if #cards == 0 then
			return LuaSmallYeyanCard:clone()
		end
		if #cards == 4 then
			local YeyanCard = LuaGreatYeyanCard:clone()
			for _,card in ipairs(cards) do
				YeyanCard:addSubcard(card)
			end
			return YeyanCard
		end
	end,
	enabled_at_play = function(self, player)
		return player:getMark("@flame") > 0
	end
}
LuaYeyan = sgs.CreateTriggerSkill{
		name = "LuaYeyan",
		frequency = sgs.Skill_Limited,
		limit_mark = "@flame",
		view_as_skill = LuaYeyanVS ,
		on_trigger = function() 
		end
}
--[[
	技能名：遗计
	相关武将：标准·郭嘉
	描述：每当你受到1点伤害后，你可以观看牌堆顶的两张牌，将其中一张交给一名角色，然后将另一张交给一名角色。
	引用：LuaYiji
	状态：1217验证通过
]]--
LuaYiji = sgs.CreateTriggerSkill{
	name = "LuaYiji",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local damage = data:toDamage()
		local x = damage.damage
		for i = 0, x - 1, 1 do
			if not player:isAlive() then return end
			if not room:askForSkillInvoke(player, self:objectName()) then return end
			local _guojia = sgs.SPlayerList()
			_guojia:append(player)
			local yiji_cards = room:getNCards(2, false)
			local move = sgs.CardsMoveStruct(yiji_cards, nil, player, sgs.Player_PlaceTable, sgs.Player_PlaceHand,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), self:objectName(), nil))
			local moves = sgs.CardsMoveList()
			moves:append(move)
			room:notifyMoveCards(true, moves, false, _guojia)
			room:notifyMoveCards(false, moves, false, _guojia)
			local origin_yiji = sgs.IntList()
			for _, id in sgs.qlist(yiji_cards) do
				origin_yiji:append(id)
			end
			while room:askForYiji(player, yiji_cards, self:objectName(), true, false, true, -1, room:getAlivePlayers()) do
				local move = sgs.CardsMoveStruct(sgs.IntList(), player, nil, sgs.Player_PlaceHand, sgs.Player_PlaceTable,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), self:objectName(), nil))
				for _, id in sgs.qlist(origin_yiji) do
					if room:getCardPlace(id) ~= sgs.Player_DrawPile then
						move.card_ids:append(id)
						yiji_cards:removeOne(id)
					end
				end
				origin_yiji = sgs.IntList()
				for _, id in sgs.qlist(yiji_cards) do
					origin_yiji:append(id)
				end
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true, moves, false, _guojia)
				room:notifyMoveCards(false, moves, false, _guojia)
				if not player:isAlive() then return end
			end
			if not yiji_cards:isEmpty() then
				local move = sgs.CardsMoveStruct(yiji_cards, player, nil, sgs.Player_PlaceHand, sgs.Player_PlaceTable,
							sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PREVIEW, player:objectName(), self:objectName(), nil))
				local moves = sgs.CardsMoveList()
				moves:append(move)
				room:notifyMoveCards(true, moves, false, _guojia)
				room:notifyMoveCards(false, moves, false, _guojia)
				local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
				for _, id in sgs.qlist(yiji_cards) do
					dummy:addSubcard(id)
				end
				player:obtainCard(dummy, false)
			end
		end
		return false
	end
}
--[[
	技能名：疑城
	相关武将：阵·徐盛
	描述：每当一名角色被指定为【杀】的目标后，你可以令该角色摸一张牌，然后弃置一张牌。
	引用：LuaYicheng
	状态：1217验证通过 
]]--
LuaYicheng = sgs.CreateTriggerSkill{
	name = "LuaYicheng",
	events = {sgs.TargetConfirmed},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") then return false end
		for _,p in sgs.qlist(use.to) do
			local d = sgs.QVariant()
			d:setValue(p)
			if room:askForSkillInvoke(player,self:objectName(),d) then
				p:drawCards(1)
				if p:isAlive() and p:canDiscard(p,"he") then
					room:askForDiscard(p,self:objectName(),1,1,false,true)
				end
				if not player:isAlive() then
					break
				end
			end
		end
		return false
	end
}
--[[
	技能名：倚天（联动技）
	相关武将：倚天·倚天剑
	描述：当你对曹操造成伤害时，可令该伤害-1
	引用：LuaYitian
	状态：1217验证通过
]]--
LuaYitian = sgs.CreateTriggerSkill{
	name = "LuaYitian" ,
	events = {sgs.DamageCaused} ,
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		if string.find(damage.to:getGeneralName(), "caocao") or string.find(damage.to:getGeneral2Name(), "caocao") then
			if player:askForSkillInvoke(self:objectName(), data) then
				damage.damage = damage.damage - 1
				if damage.damage <= 0 then return true end
				data:setValue(damage)
			end
		end
		return false
	end
}
--[[
	技能名：义从（锁定技）
	相关武将：界限突破·公孙瓒、SP·公孙瓒、翼·公孙瓒、翼·赵云、JSP·赵云
	描述：若你的体力值大于2，你与其他角色的距离-1；若你的体力值小于或等于2，其他角色与你的距离+1。 
	引用：LuaYicong
	状态：0405证通过
]]--
LuaYicong = sgs.CreateDistanceSkill{
	name = "LuaYicong" ,
	correct_func = function(self, from, to)
		local correct = 0
		if from:hasSkill(self:objectName()) and (from:getHp() > 2) then
			correct = correct - 1
		end
		if to:hasSkill(self:objectName()) and (to:getHp() <= 2) then
			correct = correct + 1
		end
		return correct
	end
}
--[[
	技能名：义从
	相关武将：贴纸·公孙瓒
	描述：弃牌阶段结束时，你可以将任意数量的牌置于武将牌上，称为“扈”。每有一张“扈”，其他角色计算与你的距离+1。
	引用：LuaDIYYicong、LuaDIYYicongDistance、LuaDIYYicongClear
	状态：1217验证通过
]]--
LuaDIYYicongCard = sgs.CreateSkillCard{
	name = "LuaDIYYicongCard" ,
	target_fixed = true ,
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	on_use = function(self, room, source, targets)
		source:addToPile("retinue", self)
	end
}
LuaDIYYicongVS = sgs.CreateViewAsSkill{
	name = "LuaDIYYicong" ,
	n = 999,
	view_filter = function()
		return true
	end ,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local acard = LuaDIYYicongCard:clone()
		for _, c in ipairs(cards) do
			acard:addSubcard(c)
		end
		return acard
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player , pattern)
		return pattern == "@@LuaDIYYicong"
	end ,
}
LuaDIYYicong = sgs.CreateTriggerSkill{
	name = "LuaDIYYicong" ,
	events = {sgs.EventPhaseEnd} ,
	view_as_skill = LuaDIYYicongVS ,
	on_trigger = function(self, event, player, data)
		if (player:getPhase() == sgs.Player_Discard) and (not player:isNude()) then
			player:getRoom():askForUseCard(player, "@@LuaDIYYicong", "@diyyicong", -1, sgs.Card_MethodNone)
		end
		return false
	end
}
LuaDIYYicongDistance = sgs.CreateDistanceSkill{
	name = "#LuaDIYYicong-dist" ,
	correct_func = function(self, from, to)
		if to:hasSkill("LuaDIYYicong") then
			return to:getPile("retinue"):length()
		else
			return 0
		end
	end
}
LuaDIYYicongClear = sgs.CreateTriggerSkill{
	name = "#LuaDIYYicong-clear" ,
	events = {sgs.EventLoseSkill} ,
	on_trigger = function(self, event, player, data)
		if data:toString() == "LuaDIYYicong" then
			player:clearOnePrivatePile("retinue")
		end
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：义舍
	相关武将：倚天·张公祺
	描述：出牌阶段，你可将任意数量手牌正面朝上移出游戏称为“米”（至多存在五张）或收回；其他角色在其出牌阶段可选择一张“米”询问你，若你同意，该角色获得这张牌，每阶段限两次
	引用：LuaXYishe；LuaXYisheAsk（技能暗将）
	状态：1217验证通过
]]--
LuaXYisheCard = sgs.CreateSkillCard{
	name = "LuaXYisheCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		local rice = source:getPile("rice")
		local subs = self:getSubcards()
		if subs:isEmpty() then
			for _,card_id in sgs.qlist(rice) do
				room:obtainCard(source, card_id)
			end
		else
			for _,card_id in sgs.qlist(subs) do
				source:addToPile("rice", card_id)
			end
		end
	end
}
LuaXYisheVS = sgs.CreateViewAsSkill{
	name = "LuaXYishe",
	n = 5,
	view_filter = function(self, selected, to_select)
		local n = sgs.Self:getPile("rice"):length()
		if #selected + n >= 5 then
			return false
		end
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		local n = sgs.Self:getPile("rice"):length()
		if n == 0 and #cards == 0 then return nil end
		local card = LuaXYisheCard:clone()
		for _,cd in ipairs(cards) do
			card:addSubcard(cd)
		end
		return card		
	end,
	enabled_at_play = function(self, player)
		if player:getPile("rice"):isEmpty() then
			return not player:isKongcheng()
		else
			return true
		end
	end
}
LuaXYisheAskCard = sgs.CreateSkillCard{
	name = "LuaXYisheAskCard",
	target_fixed = true,
	will_throw = true,
	on_use = function(self, room, source, targets)
		local boss = room:findPlayerBySkillName("LuaXYishe")
		if boss then
			local yishe = boss:getPile("rice")
			if not yishe:isEmpty() then
				local card_id
				if yishe:length() == 1 then
					card_id = yishe:first()
				else
					room:fillAG(yishe, source)
					card_id = room:askForAG(source, yishe, false, "LuaXYisheAsk")
					source:invoke("clearAG")
				end
				room:showCard(source, card_id)
				local choice = room:askForChoice(boss, "LuaXYisheAsk", "allow+disallow")
				if choice == "allow" then
					local card = sgs.Sanguosha:getCard(card_id)
					source:obtainCard(card)
					room:showCard(source, card_id)
				end
			end
		end
	end
}
LuaXYisheAsk = sgs.CreateViewAsSkill{
	name = "LuaXYisheAsk",
	n = 0,
	view_as = function(self, cards)
		return LuaXYisheAskCard:clone()
	end,
	enabled_at_play = function(self, player)
		if not player:hasSkill("LuaXYishe") then
			if player:usedTimes("#LuaXYisheAskCard") < 2 then
				local boss = nil
				local players = player:getSiblings()
				for _,p in sgs.qlist(players) do
					if p:isAlive() then
						if p:hasSkill("LuaXYishe") then
							boss = p
							break
						end
					end
				end
				if boss then
					return not boss:getPile("rice"):isEmpty()
				end
			end
		end
		return false
	end
}
LuaXYishe = sgs.CreateTriggerSkill{
	name = "LuaXYishe",
	events = {sgs.GameStart},
	view_as_skill = LuaXYisheVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local others = room:getOtherPlayers(player)
		for _,p in sgs.qlist(others) do
			room:attachSkillToPlayer(p, "LuaXYisheAsk")
		end
	end
}
--[[
	技能名：义释
	相关武将：翼·关羽
	描述：每当你使用红桃【杀】对目标角色造成伤害时，你可以防止此伤害，改为获得其区域里的一张牌。
	引用：LuaXYishi
	状态：1217验证通过
]]--
LuaXYishi = sgs.CreateTriggerSkill{
	name = "LuaXYishi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DamageCaused},
	on_trigger = function(self, event, player, data)
		local damage = data:toDamage()
		local slash = damage.card
		if slash and slash:isKindOf("Slash") then
			if slash:getSuit() == sgs.Card_Heart then
				if not damage.chain and not damage.transfer then
					if player:askForSkillInvoke(self:objectName(), data) then
						local target = damage.to
						if not target:isAllNude() then
							local room = player:getRoom()
							local card_id = room:askForCardChosen(player, target, "hej", self:objectName())
							local name = player:objectName()
							local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, name)
							local card = sgs.Sanguosha:getCard(card_id)
							local place = room:getCardPlace(card_id)
							room:obtainCard(player, card, place ~= sgs.Player_PlaceHand)
						end
						return true
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：异才
	相关武将：智·姜维
	描述：每当你使用一张非延时类锦囊时(在它结算之前)，可立即对攻击范围内的角色使用一张【杀】
	引用：LuaXYicai
	状态：1217验证通过
]]--
LuaXYicai = sgs.CreateTriggerSkill{
	name = "LuaXYicai",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.CardUsed, sgs.CardResponsed},
	on_trigger = function(self, event, player, data)
		local card = nil
		local room = player:getRoom()
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			card = use.card
		elseif event == sgs.CardResponsed then
			card = data:toResponsed().m_card
		end
		if card:isNDTrick() then
			if room:askForSkillInvoke(player, self:objectName(), data) then
				room:throwCard(card, nil)
				room:askForUseCard(player, "slash", "@askforslash")
			end
		end
		return false
	end
}
--[[
	技能名：毅重（锁定技）
	相关武将：一将成名·于禁
	描述：若你的装备区没有防具牌，黑色【杀】对你无效。 
	引用：LuaYizhong
	状态：0405验证通过
]]--

LuaYizhong = sgs.CreateTriggerSkill{
	name = "LuaYizhong",
	frequency = sgs.Skill_Compulsory,
	events = {sgs.SlashEffected},
	on_trigger = function(self, event, player, data)
		local effect = data:toSlashEffect()
		if effect.slash:isBlack() then
			player:getRoom():notifySkillInvoked(player, self:objectName())
			return true
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil and target:isAlive() and target:hasSkill(self:objectName()) and (target:getArmor() == nil)
	end
}
--[[
	技能名：姻礼
	相关武将：1v1·孙尚香1v1
	描述： 对手的回合内，其拥有的装备牌以未经转化的方式置入弃牌堆时，你可以获得之。
	引用：LuaYinli
	状态：1217验证通过
]]--
LuaYinli = sgs.CreateTriggerSkill{
	name = "LuaYinli",
	events = {sgs.BeforeCardsMove},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if (move.from == nil) or (move.from:objectName() == player:objectName()) then return false end
		if (move.from:getPhase() ~= sgs.Player_NotActive) and (move.to_place == sgs.Player_DiscardPile) then
				local card_ids = sgs.IntList()
			local i = 0
				for _, card_id in sgs.qlist(move.card_ids) do
						if (sgs.Sanguosha:getCard(card_id):getTypeId() == sgs.Card_TypeEquip)  
						and (room:getCardOwner(card_id):objectName() == move.from:objectName())
						and ((move.from_places:at(i) == sgs.Player_PlaceHand) or (move.from_places:at(i) == sgs.Player_PlaceEquip)) then
							card_ids:append(card_id)
						end
				i = i + 1
			end
			if card_ids:isEmpty() then
				return false
	  			elseif player:askForSkillInvoke(self:objectName(), data) then
					while not card_ids:isEmpty() do
					room:fillAG(card_ids, player)
	   				local id = room:askForAG(player, card_ids, true, self:objectName())
						if id == -1 then
					room:clearAG(player)
					break
				end
						card_ids:removeOne(id)
				room:clearAG(player)
					end
			if not card_ids:isEmpty() then
						for _, id in sgs.qlist(card_ids) do
								if move.card_ids:contains(id) then
									move.from_places:removeAt(move.card_ids:indexOf(id))
						 			move.card_ids:removeOne(id)
						data:setValue(move)
								end
					room:moveCardTo(sgs.Sanguosha:getCard(id), player, sgs.Player_PlaceHand, move.reason, true)
								if not player:isAlive() then break end 
								end
						end
					end
			end
			return false
	end
}
--[[
	技能名：银铃
	相关武将：☆SP·甘宁
	描述：出牌阶段，你可以弃置一张黑色牌并指定一名其他角色。若如此做，你获得其一张牌并置于你的武将牌上，称为“锦”。（数量最多为四）
	引用：LuaYinling、LuaYinlingClear
	状态：1217验证通过
]]--
LuaYinlingCard = sgs.CreateSkillCard{
	name = "LuaYinlingCard" ,
	filter = function(self, targets, to_select)
		return (#targets == 0) and (to_select:objectName() ~= sgs.Self:objectName())
	end,
	on_effect = function(self, effect)
		local room = effect.to:getRoom()
		if not effect.from:canDiscard(effect.to, "he") or (effect.from:getPile("brocade"):length() >= 4) then return end
		local card_id = room:askForCardChosen(effect.from, effect.to, "he", "LuaYinling", false, sgs.Card_MethodDiscard)
		effect.from:addToPile("brocade", card_id)
	end
}
LuaYinling = sgs.CreateViewAsSkill{
	name = "LuaYinling" ,
	n = 1,
	view_filter = function(self, selected, to_select)
		return (#selected == 0) and to_select:isBlack() and (not sgs.Self:isJilei(to_select))
	end ,
	view_as = function(self, cards)
		if #cards ~= 1 then return nil end
		local card = LuaYinlingCard:clone()
		card:addSubcard(cards[1])
		return card
	end ,
	enabled_at_play = function(self, player)
		return player:getPile("brocade"):length() < 4
	end
}
LuaYinlingClear = sgs.CreateTriggerSkill{
	name = "#LuaYinling-clear" ,
	events = {sgs.EventLoseSkill} ,
	on_trigger = function(self, event, player, data)
		if data:toString() == "LuaYinling" then
			player:clearOnePrivatePile("brocade")
		end
	end ,
	can_trigger = function(self, target)
		return target
	end
}

--[[
	技能名：英魂
	相关武将：林·孙坚、山·孙策
	描述：准备阶段开始时，若你已受伤，你可以选择一名其他角色并选择一项：1.令其摸一张牌，然后弃置X张牌；2.令其摸X张牌，然后弃置一张牌。（X为你已损失的体力值）
	引用：LuaYinghun
	状态：1217验证通过
]]--
LuaYinghunCard = sgs.CreateSkillCard{
	name = "LuaYinghunCard",
	target_fixed = false,
	will_throw = true,
	on_effect = function(self, effect)
		local source = effect.from
		local dest = effect.to
		local x = source:getLostHp()
		local room = source:getRoom()
		local good = false
		if x == 1 then
			dest:drawCards(1)
			room:askForDiscard(dest, self:objectName(), 1, 1, false, true);
			good = true
		else
			local choice = room:askForChoice(source, self:objectName(), "d1tx+dxt1")
			if choice == "d1tx" then
				dest:drawCards(1)
				x = math.min(x, dest:getCardCount(true))
				room:askForDiscard(dest, self:objectName(), x, x, false, true)
				good = false
			else
				dest:drawCards(x)
				room:askForDiscard(dest, self:objectName(), 1, 1, false, true)
				good = true
			end
		end
		if good then
			room:setEmotion(dest, "good")
		else
			room:setEmotion(dest, "bad")
		end
	end
}
LuaYinghunVS = sgs.CreateViewAsSkill{
	name = "LuaYinghun",
	n = 0,
	view_as = function(self, cards)
		return LuaYinghunCard:clone()
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@LuaYinghun"
	end
}
LuaYinghun = sgs.CreateTriggerSkill{
	name = "LuaYinghun",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	view_as_skill = LuaYinghunVS,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:askForUseCard(player, "@@LuaYinghun", "@yinghun")
		return false
	end,
	can_trigger = function(self, target)
		if target then
			if target:isAlive() and target:hasSkill(self:objectName()) then
				if target:getPhase() == sgs.Player_Start then
					return target:isWounded()
				end
			end
		end
		return false
	end
}
--[[
	技能名：英姿
	相关武将：标准·周瑜、山·孙策、翼·周瑜
	描述：摸牌阶段，你可以额外摸一张牌。
	引用：LuaYingzi
	状态：1217验证通过
]]--
LuaYingzi = sgs.CreateTriggerSkill{
	name = "LuaYingzi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaYingzi", data) then
			local count = data:toInt() + 1
			data:setValue(count)
		end
	end
}
--[[
	技能名：影兵
	相关武将：SP·张宝
	描述：每当一张“咒缚牌”成为判定牌后，你可以摸两张牌。
	引用：LuaYingbing
	状态：1217验证通过
	
	注：此技能与咒缚有联系，有联系的地方请使用本手册当中的咒缚，并非原版
]]--
LuaYingbing = sgs.CreateTriggerSkill{
	name = "LuaYingbing",
	events = {sgs.StartJudge},
	frequency = sgs.Skill_Frequent,
	priority = -1,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local judge = data:toJudge()
		local id = judge.card:getEffectiveId()
		local zhangbao = player:getTag("LuaZhoufuSource" .. tostring(id)):toPlayer()
		if zhangbao and zhangbao:isAlive() and zhangbao:hasSkill(self:objectName()) and zhangbao:askForSkillInvoke(self:objectName(),data) then
			zhangbao:drawCards(2)
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil
	end
}
--[[
	技能名：庸肆（锁定技）
	相关武将：SP·袁术、SP·台版袁术
	描述：摸牌阶段，你额外摸X张牌。弃牌阶段开始时，你须弃置X张牌。（X为现存势力数） 
	引用：LuaYongsi
	状态：0405验证通过
]]--
getKingdoms = function(yuanshu)
	local kingdom_set = {}
	local room = yuanshu:getRoom()
	for _, p in sgs.qlist(room:getAlivePlayers()) do
		table.insert(kingdom_set, p:getKingdom())
	end
	return #kingdom_set
end
LuaYongsi = sgs.CreateTriggerSkill{
	name = "LuaYongsi" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.DrawNCards, sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local x = getKingdoms(player)
		if event == sgs.DrawNCards then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			data:setValue(data:toInt() + x)
		elseif event == sgs.EventPhaseStart and player:getPhase() == sgs.Player_Discard then
			room:sendCompulsoryTriggerLog(player, self:objectName())
			if x > 0 then
				room:askForDiscard(player, self:objectName(), x, x, false, true)
			end
		end
		return false
	end
}
--[[
	技能名：勇决
	相关武将：势·糜夫人
	描述：若一名角色于出牌阶段内使用的第一张牌为【杀】，此【杀】结算完毕后置入弃牌堆时，你可以令其获得之。
	引用：LuaYongjue,LuaYongjueRecord
	状态：1217验证通过
]]--
LuaYongjueRecord = sgs.CreateTriggerSkill{
	name = "#LuaYongjueRecord",
	events = {sgs.PreCardUsed,sgs.CardResponded,sgs.EventPhaseChanging},
	can_trigger = function(self,target)
		return target ~= nil
	end,
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		if event == sgs.PreCardUsed or event == sgs.CardResponded then
			if player:getPhase() ~= sgs.Player_Play then return false end
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			else
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and card:getHandlingMethod() == sgs.Card_MethodUse and player:getMark("LuaYongjue") == 0 then
				player:addMark("LuaYongjue")
				if card:isKindOf("Slash") then
					local ids = sgs.IntList()
					if not card:isVirtualCard() then
						ids:append(card:getEffectiveId())
					else
						if card:subcardsLength() > 0 then
							ids = card:getSubcards()
						end
					end
					if not ids:isEmpty() then
						room:setCardFlag(card,"LuaYongjue")
						local pdata ,cdata= sgs.QVariant() ,sgs.QVariant()
						pdata:setValue(player)
						cdata:setValue(card)
						room:setTag("LuaYongjue_user",pdata)
						room:setTag("LuaYongjue_card",cdata)
					end
				end
			end			
		else
			local change = data:toPhaseChange()
			if change.to == sgs.Player_Play then
				player:setMark("LuaYongjue",0)
			end
		end
		return false
	end		
}
LuaYongjue = sgs.CreateTriggerSkill{
	name = "LuaYongjue",
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self,event,player,data)
		local room = player:getRoom()
		local move = data:toMoveOneTime()
		if move.card_ids:isEmpty() then return false end
		if not (move.from and move.from:isAlive() and move.from:getPhase() == sgs.Player_Play) then return false end		
		local basic = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
		if move.from_places:contains(sgs.Player_PlaceTable) and move.to_place == sgs.Player_DiscardPile and
			(basic == sgs.CardMoveReason_S_REASON_USE) then			
			local yongjue_user = room:getTag("LuaYongjue_user"):toPlayer()
			local yongjue_card = room:getTag("LuaYongjue_card"):toCard()
			room:removeTag("LuaYongjue_card")
			room:removeTag("LuaYongjue_user")
			if yongjue_card and yongjue_user and yongjue_card:hasFlag("LuaYongjue") and move.from:objectName() == yongjue_user:objectName() then
				local ids = sgs.IntList()
				if not yongjue_card:isVirtualCard() then					
					ids:append(yongjue_card:getEffectiveId())
				else
					if yongjue_card:subcardsLength() > 0 then
						ids = yongjue_card:getSubcards()
					end
				end
				if not ids:isEmpty() then					
					for _,id in sgs.qlist(ids) do						
						if not move.card_ids:contains(id) then return false end
					end
				else
					return false
				end
				local pdata = sgs.QVariant()
				pdata:setValue(yongjue_user)				
				if room:askForSkillInvoke(player,self:objectName(),pdata) then
					local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit,0)
					for _,id in sgs.qlist(ids) do
						slash:addSubcard(id)
					end
					yongjue_user:obtainCard(slash)
					slash:deleteLater()
					move.card_ids = sgs.IntList()
					data:setValue(move)
				end
			end
		end
		return false
	end	
}
--[[
	技能名：狱刎（锁定技）
	相关武将：智·田丰
	描述：当你死亡时，凶手视为自己
	引用：LuaXYuwen
	状态：1217验证通过（和源码不同）
	附注：除死亡笔记结果不可更改外，其他情况均通过
]]--
LuaXYuwen = sgs.CreateTriggerSkill{
	name = "luaXYuwen",
	events = {sgs.AskForPeachesDone},
	frequency = sgs.Skill_Compulsory,
	priority = 1,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dying = data:toDying()
		if player:getHp() <= 0 and dying.damage and dying.damage.from then
			dying.damage.from = player
			room:killPlayer(player,dying.damage)
			room:setTag("SkipGameRule",sgs.QVariant(true))
		end
	end,
}

--[[
	技能名：御策
	相关武将：一将成名2013·满宠
	描述：每当你受到一次伤害后，你可以展示一张手牌，若此伤害有来源，伤害来源须弃置一张与该牌类型不同的手牌，否则你回复1点体力。
	引用：LuaYuce
	状态：1217验证通过
]]--
LuaYuce = sgs.CreateTriggerSkill{
	name = "LuaYuce" ,
	events = {sgs.Damaged} ,
	on_trigger = function(self, event, player, data)
		if player:isKongcheng() then return false end
		local room = player:getRoom()
		local card = room:askForCard(player, ".", "@yuce-show", data, sgs.Card_MethodNone)
		if card then
			room:showCard(player, card:getEffectiveId())
			local damage = data:toDamage()
			if (not damage.from) or (damage.from:isDead()) then return false end
			local type_name = {"BasicCard", "TrickCard", "EquipCard"}
			local types = {"BasicCard", "TrickCard", "EquipCard"}
			table.removeOne(types,type_name[card:getTypeId()])
			if not damage.from:canDiscard(damage.from, "h") then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			elseif not room:askForCard(damage.from, table.concat(types, ",") .. "|.|.hand",
					"@yuce-discard:" .. player:objectName() .. "::" .. types[1] .. ":" .. types[2], data) then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			end
		end
		return false
	end
}
--[[
	技能名：援护
	相关武将：SP·曹洪
	描述：结束阶段开始时，你可以将一张装备牌置于一名角色装备区内：若此牌为武器牌，你弃置该角色距离1的一名角色区域内的一张牌；若此牌为防具牌，该角色摸一张牌；若此牌为坐骑牌，该角色回复1点体力。  
	引用：LuaYuanhu
	状态：0405验证通过
]]--
LuaYuanhuCard = sgs.CreateSkillCard{
	name = "LuaYuanhuCard",
	will_throw = false ,
	handling_method = sgs.Card_MethodNone ,
	filter = function(self, targets, to_select)
		if #targets ~= 0 then return false end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local equip = card:getRealCard():toEquipCard()
		local equip_index = equip:location()
		return to_select:getEquip(equip_index) == nil
	end,
	on_effect = function(self, effect)
		local source = effect.from
		local room = source:getRoom()
		room:moveCardTo(self, source, effect.to, sgs.Player_PlaceEquip, sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, source:objectName(), "LuaYuanhu", ""))
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		if card:isKindOf("Weapon") then
			local targets = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAllPlayers()) do
				if effect.to:distanceTo(p) == 1 and source:canDiscard(p, "hej") then
					targets:append(p)
				end
			end
			if not targets:isEmpty() then
				local to_dismantle = room:askForPlayerChosen(source, targets, "LuaYuanhu", "@yuanhu-discard:"..effect.to:objectName())
				local card_id = room:askForCardChosen(source, to_dismantle, "hej", "LuaYuanhu", false, sgs.Card_MethodDiscard)
				room:throwCard(sgs.Sanguosha:getCard(card_id), to_dismantle, source)
			end
		elseif card:isKindOf("Armor") then
			effect.to:drawCards(1, "LuaYuanhu")
		elseif card:isKindOf("Horse") then
			room:recover(effect.to, sgs.RecoverStruct(source))
		end
	end
}
LuaYuanhuVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaYuanhu",
	filter_pattern = "EquipCard",
	response_pattern = "@@LuaYuanhu",
	view_as = function(self, card)
		local first = LuaYuanhuCard:clone()
		first:addSubcard(card:getId())
		first:setSkillName(self:objectName())
		return first
	end
}
LuaYuanhu = sgs.CreatePhaseChangeSkill{
	name = "LuaYuanhu",
	view_as_skill = LuaYuanhuVS,
	on_phasechange = function(self, player)
		if player:getPhase() == sgs.Player_Finish and not player:isNude() then
			player:getRoom():askForUseCard(player, "@@LuaYuanhu", "@yuanhu-equip", -1, sgs.Card_MethodNone)
		end
		return false
	end
}
	name = "LuaYingzi",
	frequency = sgs.Skill_Frequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, "LuaYingZi", data) then
			local count = data:toInt() + 1
			data:setValue(count)
		end
	end
}
-----------
--[[Z区]]--
-----------
--[[
	技能名：灾变（锁定技）
	相关武将：僵尸·僵尸
	描述：你的出牌阶段开始时，若人类玩家数-僵尸玩家数+1大于0，你多摸该数目的牌。
	引用：LuaZaibian
	状态：1217验证通过
]]--
isZombie = function(player)		--这里是以副将来判断是否僵尸，与源码以身份来判断不同
	if player:getGeneral2Name() == "zombie" then 
		return true
	end
end
LuaZaibian = sgs.CreateTriggerSkill{
	name = "LuaZaibian",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Play then
			local ZombieNo = 0
			local HumanNo = 0
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if isZombie(p) then
					ZombieNo = ZombieNo +1
				else
					HumanNo = HumanNo +1
				end
			end
			local x = HumanNo-ZombieNo+1
			if x> 0 then
				player:drawCards(x)
			end
		end
	end
}

--[[
	技能名：再起
	相关武将：林·孟获
	描述：摸牌阶段开始时，若你已受伤，你可以放弃摸牌，改为从牌堆顶亮出X张牌（X为你已损失的体力值），你回复等同于其中红桃牌数量的体力，然后将这些红桃牌置入弃牌堆，并获得其余的牌。
	引用：LuaZaiqi
	状态：1217验证通过
]]--
LuaZaiqi = sgs.CreateTriggerSkill{
	name = "LuaZaiqi",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		if player:getPhase() == sgs.Player_Draw then
			if player:isWounded() then
				local room = player:getRoom()
				if room:askForSkillInvoke(player, self:objectName()) then
					local x = player:getLostHp()
					local has_heart = false
					local ids = room:getNCards(x, false)
					local move = sgs.CardsMoveStruct()
					move.card_ids = ids
					move.to = player
					move.to_place = sgs.Player_PlaceTable
					move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
					room:moveCardsAtomic(move, true)
					local card_to_throw = {}
					local card_to_gotback = {}
					for i=0, x-1, 1 do
						local id = ids:at(i)
						local card = sgs.Sanguosha:getCard(id)
						local suit = card:getSuit()
						if suit == sgs.Card_Heart then
							table.insert(card_to_throw, id)
						else
							table.insert(card_to_gotback, id)
						end
					end
					if #card_to_throw > 0 then
						local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, id in ipairs(card_to_throw) do
							dummy:addSubcard(id)
						end
						local recover = sgs.RecoverStruct()
						recover.card = nil
						recover.who = player
						recover.recover = #card_to_throw
						room:recover(player, recover)
						local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, player:objectName(), self:objectName(), nil)
						room:throwCard(dummy, reason, nil)
						has_heart = true
					end
					if #card_to_gotback > 0 then
						local dummy2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
						for _, id in ipairs(card_to_gotback) do
							dummy2:addSubcard(id)
						end
						room:obtainCard(player, dummy2)
					end
					return true
				end
			end
		end
		return false
	end
}
--[[
	技能名：凿险（觉醒技）
	相关武将：山·邓艾
	描述：回合开始阶段开始时，若“田”的数量达到3或更多，你须减1点体力上限，并获得技能“急袭”。
	引用：LuaZaoxian
	状态：1217验证通过
]]--
LuaZaoxian = sgs.CreateTriggerSkill{
	name = "LuaZaoxian" ,
	frequency = sgs.Skill_Wake ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		room:addPlayerMark(player, "LuaZaoxian")
		if room:changeMaxHpForAwakenSkill(player) then
			room:acquireSkill(player, "jixi")
		end
	end ,
	can_trigger = function(self, target)
		return (target and target:isAlive() and target:hasSkill(self:objectName()))
			and (target:getPhase() == sgs.Player_Start)
			and (target:getMark("LuaZaoxian") == 0)
			and (target:getPile("field"):length() >= 3)
	end
}
--[[
	技能名：早夭（锁定技）
	相关武将：倚天·曹冲
	描述：回合结束阶段开始时，若你的手牌大于13张，则你必须弃置所有手牌并流失1点体力
	引用：LuaZaoyao
	状态：1217验证通过
]]--
LuaZaoyao = sgs.CreateTriggerSkill{
	name = "LuaZaoyao" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		if (player:getPhase() == sgs.Player_Finish) and (player:getHandcardNum() > 13) then
			player:throwAllHandCards()
			player:getRoom():loseHp(player)
		end
		return false
	end
}
--[[
	技能名：战神（觉醒技）
	相关武将：2013-3v3·吕布
	描述：准备阶段开始时，若你已受伤且有己方角色已死亡，你减1点体力上限，弃置装备区的武器牌，然后获得技能“马术”和“神戟”。
	引用：LuaZhanshen
	状态：1217验证通过
]]--
LuaZhanshen = sgs.CreateTriggerSkill{
	name = "LuaZhanshen",
	events = {sgs.Death, sgs.EventPhaseStart},
	frequency = sgs.Skill_Wake,
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() then
				return false
			end
			local lvbu = room:findPlayerBySkillName(self:objectName())
			if string.sub(room:getMode(), 1, 3) == "06_" then
				if lvbu:getMark(self:objectName()) == 0 and lvbu:getMark("zhanshen_fight") == 0
						and string.sub(lvbu:getRole(), 1, 1) == string.sub(player:getRole(), 1, 1) then
					lvbu:addMark("zhanshen_fight")
				end
			else
				if lvbu:getMark(self:objectName()) == 0 and lvbu:getMark("@fight") == 0		--身份局
						and room:askForSkillInvoke(player, self:objectName(), sgs.QVariant("mark:"..lvbu:objectName())) then
					room:addPlayerMark(lvbu, "@fight")
				end
			end
		else
			if player:getPhase() == sgs.Player_Start and player:getMark(self:objectName()) == 0 and player:isWounded()
					and (player:getMark("zhanshen_fight") > 0 or player:getMark("@fight") > 0) and player:hasSkill(self:objectName()) then
				if player:getMark("@fight") > 0 then
					room:setPlayerMark(player, "@fight", 0)
				end
				player:setMark("zhanshen_fight", 0)
				room:addPlayerMark(player, self:objectName())
				if room:changeMaxHpForAwakenSkill(player) then
					if player:getWeapon() then
						room:throwCard(player:getWeapon(), player)
					end
					room:handleAcquireDetachSkills(player, "mashu|shenji")
				end
			end
		end
		return false
	end,
}
--[[
	技能名：昭烈
	相关武将：☆SP·刘备
	描述：摸牌阶段摸牌时，你可以少摸一张牌，指定你攻击范围内的一名其他角色亮出牌堆顶上3张牌，将其中全部的非基本牌和【桃】置于弃牌堆，该角色进行二选一：你对其造成X点伤害，然后他获得这些基本牌；或他依次弃置X张牌，然后你获得这些基本牌。（X为其中非基本牌的数量）。
	引用：LuaZhaolie、LuaZhaolieAct
	状态：1217验证通过
]]--
LuaZhaolie = sgs.CreateTriggerSkill{
	name = "LuaZhaolie",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.DrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local targets = room:getOtherPlayers(player)
		local victims = sgs.SPlayerList()
		for _,p in sgs.qlist(targets) do
			if player:inMyAttackRange(p) then
				victims:append(p)
			end
		end
		if victims:length() > 0 then
			if room:askForSkillInvoke(player, self:objectName()) then
				room:setPlayerFlag(player, "Invoked")
				local count = data:toInt() - 1
				data:setValue(count)
			end
		end
	end
}
LuaZhaolieAct = sgs.CreateTriggerSkill{
	name = "#LuaZhaolie",
	frequency = sgs.Skill_Frequent,
	events = {sgs.AfterDrawNCards},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local no_basic = 0
		local cards = {}
		local targets = room:getOtherPlayers(player)
		local victims = sgs.SPlayerList()
		for _,p in sgs.qlist(targets) do
			if player:inMyAttackRange(p) then
				victims:append(p)
			end
		end
		if player:getPhase() == sgs.Player_Draw then
			if player:hasFlag("Invoked") then
				room:setPlayerFlag(player, "-Invoked")
				local victim = room:askForPlayerChosen(player, victims, "LuaZhaolie")
				local cardIds = sgs.IntList()
				for i=1, 3, 1 do
					local id = room:drawCard()
					cardIds:append(id)
				end
				assert(cardIds:length() == 3)
				local move = sgs.CardsMoveStruct()
				move.card_ids = cardIds
				move.to_place = sgs.Player_PlaceTable
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "", "LuaZhaolie", "")
				room:moveCards(move, true)
				room:getThread():delay()
				local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, "", "LuaZhaolie", "")
				for i=0, 2, 1 do
					local card_id = cardIds:at(i)
					local card = sgs.Sanguosha:getCard(card_id)
					if not card:isKindOf("BasicCard") or card:isKindOf("Peach") then
						if not card:isKindOf("BasicCard") then
							no_basic = no_basic + 1
						end
						room:throwCard(card, reason, nil)
					else
						table.insert(cards, card)
					end
				end
				local choicelist = "damage"
				local flag = false
				local victim_cards = victim:getCards("he")
				if victim_cards:length() >= no_basic then
					choicelist = "damage+throw"
					flag = true
				end
				local choice
				if flag then
					local data = sgs.QVariant(no_basic)
					choice = room:askForChoice(victim, "LuaZhaolie", choicelist, data)
				else
					choice = "damage"
				end
				if choice == "damage" then
					if no_basic > 0 then
						local damage = sgs.DamageStruct()
						damage.card = nil
						damage.from = player
						damage.to = victim
						damage.damage = no_basic
						room:damage(damage)
					end
					if #cards > 0 then
						local reasonA = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, victim:objectName())
						local reasonB = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_NATURAL_ENTER, victim:objectName(), "LuaZhaolie", "")
						for _,c in pairs(cards) do
							if victim:isAlive() then
								room:obtainCard(victim, c, true)
							else
								room:throwCard(c, reasonB, nil)
							end
						end
					end
				else
					if no_basic > 0 then
						while no_basic > 0 do
							room:askForDiscard(victim, "LuaZhaolie", 1, 1, false, true)
							no_basic = no_basic - 1
						end
					end
					if #cards > 0 then
						reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GOTBACK, player:objectName())
						for _,c in pairs(cards) do
							room:obtainCard(player, c)
						end
					end
				end
			end
		end
		return false
	end
}
--[[
	技能名：昭心
	相关武将：贴纸·司马昭
	描述：摸牌阶段结束时，你可以展示所有手牌，若如此做，视为你使用一张【杀】，每阶段限一次。
	引用：LuaZhaoxin
	状态：1217验证通过
]]--
LuaZhaoxinCard = sgs.CreateSkillCard{
	name = "LuaZhaoxinCard" ,
	filter = function(self, targets, to_select)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		local tarlist = sgs.PlayerList()
		for i = 1, #targets, 1 do
			tarlist:append(targets[i])
		end
		return slash:targetFilter(tarlist, to_select, sgs.Self)
	end ,
	on_use = function(self, room, source, targets)
		room:showAllCards(source)
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		slash:setSkillName("_LuaZhaoxin")
		local tarlist = sgs.SPlayerList()
		for i = 1, #targets, 1 do
			tarlist:append(targets[i])
		end
		room:useCard(sgs.CardUseStruct(slash, source, tarlist))
	end
}
LuaZhaoxinVS = sgs.CreateViewAsSkill{
	name = "LuaZhaoxin" ,
	n = 0 ,
	view_as = function()
		return LuaZhaoxinCard:clone()
	end ,
	enabled_at_play = function()
		return false
	end ,
	enabled_at_response = function(self, player, pattern)
		return (pattern == "@@LuaZhaoxin") and sgs.Slash_IsAvailable(player)
	end ,
}
LuaZhaoxin = sgs.CreateTriggerSkill{
	name = "LuaZhaoxin" ,
	events = {sgs.EventPhaseEnd} ,
	view_as_skill = LuaZhaoxinVS ,
	on_trigger = function(self, event, player, data)
		if player:getPhase() ~= sgs.Player_Draw then return false end
		if player:isKongcheng() or (not sgs.Slash_IsAvailable(player)) then return false end
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(player:getRoom():getAllPlayers()) do
			if player:canSlash(p) then
				targets:append(p)
			end
		end
		if targets:isEmpty() then return false end
		player:getRoom():askForUseCard(player, "@@LuaZhaoxin", "@zhaoxin")
		return false
	end
}
--[[
	技能名：贞烈
	相关武将：一将成名2012·王异
	描述： 每当你成为一名其他角色使用的【杀】或非延时类锦囊牌的目标后，你可以失去1点体力，令此牌对你无效，然后你弃置其一张牌。
	引用：LuaZhenlie
	状态：0405验证通过
]]--
LuaZhenlie = sgs.CreateTriggerSkill{
	name = "LuaZhenlie" ,
	events = {sgs.TargetConfirmed} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
			if event == sgs.TargetConfirmed then
			local use = data:toCardUse()
			if use.to:contains(player) and use.from:objectName() ~= player:objectName() then
				if use.card:isKindOf("Slash") or use.card:isNDTrick() then
					if room:askForSkillInvoke(player, self:objectName(), data) then
						player:setFlags("-ZhenlieTarget")
						player:setFlags("ZhenlieTarget")
						room:loseHp(player)
						if player:isAlive() and player:hasFlag("ZhenlieTarget") then
							player:setFlags("-ZhenlieTarget")
							local nullified_list = use.nullified_list
											table.insert(nullified_list, player:objectName())
											use.nullified_list = nullified_list
							data:setValue(use)
							if player:canDiscard(use.from, "he") then
								local id = room:askForCardChosen(player, use.from, "he", self:objectName(), false, sgs.Card_MethodDiscard)
								room:throwCard(id, use.from, player)
							end
						end
					end
				end
			end
			end
		return false
	end
}
--[[
	技能名：贞烈·旧
	相关武将：怀旧-一将2·王异-旧
	描述：在你的判定牌生效前，你可以从牌堆顶亮出一张牌代替之。
	引用：LuaNosZhenlie
	状态：1217验证通过
]]--
LuaNosZhenlie = sgs.CreateTriggerSkill{
	name = "LuaNosZhenlie" ,
	events = {sgs.AskForRetrial} ,
	on_trigger = function(self, event, player, data)
		local judge = data:toJudge()
		if judge.who:objectName() ~= player:objectName() then return false end
		if player:askForSkillInvoke(self:objectName(), data) then
			local room = player:getRoom()
			local card_id = room:drawCard()
			room:getThread():delay()
			local card = sgs.Sanguosha:getCard(card_id)
			room:retrial(card, player, judge, self:objectName())
		end
		return false
	end
}
--[[
	技能名：鸩毒
	相关武将：阵·何太后
	描述：每当一名其他角色的出牌阶段开始时，你可以弃置一张手牌：若如此做，视为该角色使用一张【酒】（计入限制），然后你对该角色造成1点伤害。 
	引用：LuaZhendu
	状态：1217验证通过
]]--
LuaZhendu = sgs.CreateTriggerSkill {
	name = "LuaZhendu",
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_Play then
			return false
		end
		local hetaihou = room:findPlayerBySkillName(self:objectName())
		if not hetaihou or not hetaihou:isAlive() or not hetaihou:canDiscard(hetaihou, "h")
				or hetaihou:getPhase() == sgs.Player_Play then
			return false
		end
		if room:askForCard(hetaihou, ".", "@zhendu-discard", sgs.QVariant(), self:objectName()) then
			local analeptic = sgs.Sanguosha:cloneCard("analeptic", sgs.Card_NoSuit, 0)
			analeptic:setSkillName(self:objectName())
			room:useCard(sgs.CardUseStruct(analeptic, player, sgs.SPlayerList(), true))
			if player:isAlive() then
				room:damage(sgs.DamageStruct(self:objectName(), hetaihou, player))
			end
		end
		return false
	end
}
--[[
	技能名：镇威
	相关武将：倚天·倚天剑
	描述：你的【杀】被手牌中的【闪】抵消时，可立即获得该【闪】。
	引用：LuaYTZhenwei
	状态：1217验证通过
]]--
LuaYTZhenwei = sgs.CreateTriggerSkill{
	name = "LuaYTZhenwei" ,
	events = {sgs.SlashMissed} ,
	on_trigger = function(self, event, player, data)
		local effect = data:toSlashEffect()
		if effect.jink and (player:getRoom():getCardPlace(effect.jink:getEffectiveId()) == sgs.Player_DiscardPile) then
			if player:askForSkillInvoke(self:objectName(), data) then
				player:obtainCard(effect.jink)
			end
		end
		return false
	end
}
--[[
	技能名：镇卫（锁定技）
	相关武将：2013-3v3·文聘
	描述：对方角色与其他己方角色的距离+1。
	身份局：回合结束後，你可以令至多X名其他角色获得“守”(X为其他存活角色数的一半(向下取整))，则其他角色计算与目标角色的距离时，始终+1，直到你的下回合开始。
	引用：LuaZhenweiDistance、LuaZhenwei
	状态：1217验证成功
]]--
LuaZhenweiDistance = sgs.CreateDistanceSkill{
	name = "#LuaZhenwei",
	correct_func = function(self, from, to)
		if to:hasSkill("LuaZhenwei") then return 0
		else
			local hasWenpin = false
			for _,p in sgs.qlist(to:getAliveSiblings()) do
				if p:hasSkill("LuaZhenwei") then
					hasWenpin = true
					break
				end
			end
			if not hasWenpin then return 0 end
		end
		if sgs.GetConfig("GameMode", "06_3v3") == "06_3v3" then		--3v3
			if string.sub(from:getRole(), 1, 1) ~= string.sub(to:getRole(), 1, 1) then
				for _,p in sgs.qlist(to:getAliveSiblings()) do
					if p:hasSkill(self:objectName()) and string.sub(p:getRole(), 1, 1) == string.sub(to:getRole(), 1, 1) then
						return 1
					end
				end
			end
		else		--身份局
			if to:getMark("@defense") > 0 and from:getMark("@defense") == 0 and not from:hasSkill("LuaZhenwei") then
				return 1
			end
		end
		return 0
	end
}
LuaZhenweiCard = sgs.CreateSkillCard{
	name = "LuaZhenwei",
	filter = function(self, targets, to_select, player)
		local total = player:getSiblings():length()+1
		return #targets < total / 2 - 1 and to_select ~= player
	end,
	on_effect = function(self, effect)
		effect.to:gainMark("@defense")
	end,
}
LuaZhenweiViewAsSkill = sgs.CreateZeroCardViewAsSkill{
	name = "LuaZhenwei",
	response_pattern = "@@zhenwei",
	view_as = function(self)
		return LuaZhenweiCard:clone()
	end,
}
LuaZhenwei = sgs.CreateTriggerSkill{
	name = "LuaZhenwei",
	events = {sgs.EventPhaseChanging, sgs.Death, sgs.EventLoseSkill},
	view_as_skill = LuaZhenweiViewAsSkill,
	frequency = sgs.Skill_Compulsory,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if string.sub(room:getMode(),1,3) == "06_" then return false end
		if event == sgs.EventLoseSkill then
			if data:toString() ~= self:objectName() then 
				return false 
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() or not player:hasSkill(self:objectName()) then
				return false
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		end
		for _,p in sgs.qlist(room:getOtherPlayers(player)) do
			room:setPlayerMark(p, "@defense", 0)
		end
		if event == sgs.EventPhaseChanging and sgs.Sanguosha:getPlayerCount(room:getMode()) > 3 then
			room:askForUseCard(player, "@@zhenwei", "@zhenwei")
			return false
		end
	end,
}
--[[
	技能名：争锋（锁定技）
	相关武将：倚天·倚天剑
	描述：当你的装备区没有武器时，你的攻击范围为X，X为你当前体力值。
]]--
--[[
	技能名：争功
	相关武将：倚天·邓士载
	描述：其他角色的回合开始前，若你的武将牌正面向上，你可以将你的武将牌翻面并立即进入你的回合，你的回合结束后，进入该角色的回合
	引用：LuaXZhenggong
	状态：1217验证通过
]]--
LuaXZhenggong = sgs.CreateTriggerSkill{
	name = "LuaXZhenggong",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart},
	on_trigger = function(self, event, player, data)
		if player then
			local room = player:getRoom()
			local dengshizai = room:findPlayerBySkillName(self:objectName())
			if dengshizai and dengshizai:faceUp() then
				if dengshizai:askForSkillInvoke(self:objectName()) then
					dengshizai:turnOver()
					local tag = room:getTag("Zhenggong")
					if tag then
						local zhenggong = tag:toPlayer()
						if not zhenggong then
							tag:setValue(player)
							room:setTag("Zhenggong", tag)
							player:gainMark("@zhenggong")
						end
					end
					room:setCurrent(dengshizai)
					dengshizai:play()
					return true
				end
			end
			local tag = room:getTag("Zhenggong")
			if tag then
				local p = tag:toPlayer()
				if p and not player:hasFlag("isExtraTurn") then
					p:loseMark("@zhenggong")
					room:setCurrent(p)
					room:setTag("Zhenggong", sgs.QVariant())
				end
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		if target then
			return not target:hasSkill(self:objectName())
		end
		return false
	end
}
--[[
	技能名：争功(0610版)
	相关武将：倚天·邓士载
	描述：其他角色的回合开始前，若你的武将牌正面朝上，你可以进行一个额外的回合，然后将武将牌翻面。
	引用：LuaZhenggong610
	状态：1217验证通过
]]--
LuaZhenggong610 = sgs.CreateTriggerSkill{
	name = "LuaZhenggong610" ,
	events = {sgs.TurnStart} ,
	on_trigger = function(self, event, player, data)
		if not player then return false end
		local room = player:getRoom()
		local dengshizai = room:findPlayerBySkillName(self:objectName())
		if dengshizai and dengshizai:faceUp() then
			if dengshizai:askForSkillInvoke(self:objectName()) then
				dengshizai:gainAnExtraTurn()
				dengshizai:turnOver()
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and not target:hasSkill(self:objectName())
	end
}

--[[
	技能名：征服
	相关武将：E.SP 凯撒
	描述：当你使用【杀】指定一个目标后，你可以选择一种牌的类别，令其选择一项：1．将一张此类别的牌交给你，若如此做，此次对其结算的此【杀】对其无效；2．不能使用【闪】响应此【杀】。 
	引用：LuaConqueror
	状态：0425验证通过
]]--
LuaConqueror = sgs.CreateTriggerSkill{
    name = "LuaConqueror" ,
    events = {sgs.TargetConfirmed} ,
    on_trigger = function(self, event, player, data)
        local use = data:toCardUse()
        if (use.card and use.card:isKindOf("Slash")) then
            local n = 0
            for _, target in sgs.qlist(use.to) do
                local _target = sgs.QVariant()
                _target:setValue(target)
                if (player:askForSkillInvoke(self, _target)) then
                    local room = player:getRoom()
                    local choice = room:askForChoice(player, self:objectName(), "BasicCard+EquipCard+TrickCard", _target)
                    local c = room:askForCard(target, choice, "@conqueror-exchange:" .. player:objectName() .. "::" .. choice, sgs.QVariant(choice), sgs.Card_MethodNone)
                    if c then
                        local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_GIVE, target:objectName(), player:objectName(), self:objectName(), nil)
                        room:obtainCard(player, c, reason)
                        local nullified_list = use.nullified_list
                        table.insert(nullified_list, target:objectName())
                        use.nullified_list = nullified_list
                        data:setValue(use)
                    else
                        local jink_list = player:getTag("Jink_" .. use.card:toString()):toIntList()
                        jink_list:replace(n, 0)
                        local _jink_list = sgs.QVariant()
                        _jink_list:setValue(jink_list)
                        player:setTag("Jink_" .. use.card:toString(), _jink_list)
                    end
                end
                n = n + 1
            end
        end
        return false
    end ,
}

--[[
	技能名：直谏
	相关武将：山·张昭张纮
	描述：出牌阶段，你可以将手牌中的一张装备牌置于一名其他角色装备区内：若如此做，你摸一张牌。
	引用：LuaZhijian
	状态：0405验证通过
]]--
LuaZhijianCard = sgs.CreateSkillCard{
	name = "LuaZhijianCard",
	will_throw = false,
	handling_method = sgs.Card_MethodNone,
	filter = function(self, targets, to_select, erzhang)
		if #targets ~= 0 or to_select:objectName() == erzhang:objectName() then return false end
		local card = sgs.Sanguosha:getCard(self:getSubcards():first())
		local equip = card:getRealCard():toEquipCard()
		local equip_index = equip:location()
		return to_select:getEquip(equip_index) == nil
	end,
	on_effect = function(self, effect)
		local erzhang = effect.from
		erzhang:getRoom():moveCardTo(self, erzhang, effect.to, sgs.Player_PlaceEquip,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, erzhang:objectName(), "zhijian", ""))
		erzhang:drawCards(1, "zhijian")
	end
}
LuaZhijian = sgs.CreateOneCardViewAsSkill{
	name = "LuaZhijian",	
	filter_pattern = "EquipCard|.|.|hand",
	view_as = function(self, card)
		local zhijian_card = LuaZhijianCard:clone()
		zhijian_card:addSubcard(card)
		zhijian_card:setSkillName(self:objectName())
		return zhijian_card
	end
}
--[[
	技能名：直言
	相关武将：一将成名2013·虞翻
	描述：结束阶段开始时，你可以令一名角色摸一张牌并展示之。若此牌为装备牌，该角色回复1点体力，然后使用之。
	引用：LuaZhiyan
	状态：1217验证通过
]]--
LuaZhiyan = sgs.CreateTriggerSkill{
	name = "LuaZhiyan" ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		if player:getPhase() ~= sgs.Player_Finish then return false end
		local room = player:getRoom()
		local to = room:askForPlayerChosen(player, room:getAlivePlayers(), self:objectName(), "LuaZhiyan-invoke", true, true)
		if to then
			local ids = room:getNCards(1, false)
			local card = sgs.Sanguosha:getCard(ids:first())
			room:obtainCard(to, card, false)
			if not to:isAlive() then return false end
			room:showCard(to, ids:first())
			if card:isKindOf("EquipCard") then
				if (to:isWounded()) then
					local recover = sgs.RecoverStruct()
					recover.who = player
					room:recover(to, recover)
				end
				if to:isAlive() and (not to:isCardLimited(card, sgs.Card_MethodUse)) then
					room:useCard(sgs.CardUseStruct(card, to, to))
				end
			end
		end
		return false
	end
}
--[[
	技能名：志继（觉醒技）
	相关武将：山·姜维
	描述：回合开始阶段开始时，若你没有手牌，你须选择一项：回复1点体力，或摸两张牌。然后你减1点体力上限，并获得技能“观星”。
	引用：LuaZhiji
	状态：1217验证通过
]]--
LuaZhiji = sgs.CreateTriggerSkill{
	name = "LuaZhiji" ,
	frequency = sgs.Skill_Wake ,
	events = {sgs.EventPhaseStart} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:isWounded() then
			if room:askForChoice(player, self:objectName(), "recover+draw") == "recover" then
				local recover = sgs.RecoverStruct()
				recover.who = player
				room:recover(player, recover)
			else
				room:drawCards(player, 2)
			end
		else
			room:drawCards(player, 2)
		end
		room:addPlayerMark(player, "LuaZhiji")
		if room:changeMaxHpForAwakenSkill(player) then
			room:acquireSkill(player, "guanxing")
		end
		return false
	end ,
	can_trigger = function(self, target)
		return (target and target:isAlive() and target:hasSkill(self:objectName()))
				and (target:getMark("LuaZhiji") == 0)
				and (target:getPhase() == sgs.Player_Start)
				and target:isKongcheng()
	end
}
--[[
	技能名：制霸（主公技）
	相关武将：山·孙策
	描述：出牌阶段限一次，其他吴势力角色的出牌阶段可以与你拼点（“魂姿”发动后，你可以拒绝此拼点）。若其没赢，你可以获得两张拼点的牌。
	引用：LuaZhiba；LuaZhibaPindian（技能暗将）
	状态：1217验证通过
]]--
LuaZhibaCard = sgs.CreateSkillCard{
	name = "LuaZhibaCard",
	target_fixed = false,
	will_throw = false,
	filter = function(self, targets, to_select)
		if #targets == 0 then
			if to_select:hasLordSkill("LuaSunceZhiba") then
				if to_select:objectName() ~= sgs.Self:objectName() then
					if not to_select:isKongcheng() then
						return not to_select:hasFlag("ZhibaInvoked")
					end
				end
			end
		end
		return false
	end,
	on_use = function(self, room, source, targets)
		local target = targets[1]
		room:setPlayerFlag(target, "ZhibaInvoked")
		if target:getMark("hunzi") > 0 then
			local choice = room:askForChoice(target, "LuaZhibaPindian", "accept+reject")
			if choice == "reject" then
				return
			end
		end
		source:pindian(target, "LuaZhibaPindian", self)
		local sunces = sgs.SPlayerList()
		local players = room:getOtherPlayers(source)
		for _,p in sgs.qlist(players) do
			if p:hasLordSkill("sunce_zhiba") then
				if not p:hasFlag("ZhibaInvoked") then
					sunces:append(p)
				end
			end
		end
		if sunces:length() == 0 then
			room:setPlayerFlag(source, "ForbidZhiba")
		end
	end
}
LuaZhibaPindian = sgs.CreateViewAsSkill{
	name = "LuaZhibaPindian",
	n = 1,
	view_filter = function(self, selected, to_select)
		return not to_select:isEquipped()
	end,
	view_as = function(self, cards)
		if #cards == 1 then
			local card = LuaZhibaCard:clone()
			card:addSubcard(cards[1])
			return card
		end
	end,
	enabled_at_play = function(self, player)
		if player:getKingdom() == "wu" then
			if not player:isKongcheng() then
				return not player:hasFlag("ForbidZhiba")
			end
		end
		return false
	end
}
LuaZhiba = sgs.CreateTriggerSkill{
	name = "LuaZhiba$",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.TurnStart, sgs.Pindian, sgs.EventPhaseChanging, sgs.EventAcquireSkill, sgs.EventLoseSkill},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.TurnStart or event == sgs.EventAcquireSkill and data:toString() == self:objectName() then
			local lords = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:hasLordSkill(self:objectName()) then
					lords:append(p)
				end
			end
			if lords:isEmpty() then return false end
			local players = sgs.SPlayerList()
			if lords:length()>1 then player = room:getAlivePlayers()
			else players = room:getOtherPlayers(lords:first())
			end
			for _,p in sgs.qlist(players) do
				if not p:hasSkill("LuaZhibaPindian") then
					room:attachSkillToPlayer(p, "LuaZhibaPindian")
				end
			end
		elseif event == sgs.EventLoseSkill and data:toString() == "LuaSunceZhiba" then
			local lords = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:hasLordSkill(self:objectName()) then
					lords:append(p)
				end
			end
			if lords:length() > 2 then return false end
			local players = sgs.SPlayerList()
			if lords:isEmpty() then player = room:getAlivePlayers()
			else players:append(lords:first())
			end
			for _,p in sgs.qlist(players) do
				if p:hasSkill("LuaZhibaPindian") then
					room:detachSkillToPlayer(p, "LuaZhibaPindian", true)
				end
			end
		elseif event == sgs.Pindian then
			local pindian = data:toPindian()
			if pindian.reason == "LuaZhibaPindian" then
				local target = pindian.to
				if target:hasLordSkill(self:objectName()) then
					if pindian.from_card:getNumber() <= pindian.to_card:getNumber() then
						local choice = room:askForChoice(target, "LuaSunceZhiba", "yes+no")
						if choice == "yes" then
							target:obtainCard(pindian.from_card)
							target:obtainCard(pindian.to_card)
						end
					end
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local phase_change = data:toPhaseChange()
			if phase_change.from == sgs.Player_Play then
				if player:hasFlag("ForbidZhiba") then
					room:setPlayerFlag(player, "-ForbidZhiba")
				end
				local players = room:getOtherPlayers(player)
				for _,p in sgs.qlist(players) do
					if p:hasFlag("ZhibaInvoked") then
						room:setPlayerFlag(p, "-ZhibaInvoked")
					end
				end
			end
		end
		return false
	end,
	priority = -1,
}
--[[
	技能名：制霸
	相关武将：测试·制霸孙权
	描述：出牌阶段，你可以弃置任意数量的牌，然后摸取等量的牌。每阶段可用X+1次，X为你已损失的体力值
	引用：LuaXZhiBa
	状态：1217验证通过
]]--
LuaZhihengCard = sgs.CreateSkillCard{
	name = "LuaZhihengCard",
	target_fixed = true,
	will_throw = false,
	on_use = function(self, room, source, targets)
		room:throwCard(self, source)
		if source:isAlive() then
			local count = self:subcardsLength()
			room:drawCards(source, count)
		end
	end
}
LuaXZhiBa = sgs.CreateViewAsSkill{
	name = "LuaXZhiba",
	n = 999,
	view_filter = function(self, selected, to_select)
		return true
	end,
	view_as = function(self, cards)
		if #cards > 0 then
			local zhiheng_card = LuaZhihengCard:clone()
			for _,card in pairs(cards) do
				zhiheng_card:addSubcard(card)
			end
			zhiheng_card:setSkillName(self:objectName())
			return zhiheng_card
		end
	end,
	enabled_at_play = function(self, player)
		local lost = player:getLostHp()
		local used = player:usedTimes("#LuaZhihengCard")
		return used < (lost + 1)
	end
}
--[[
	技能名：制衡
	相关武将：标准·孙权
	描述：出牌阶段限一次，你可以弃置至少一张牌：若如此做，你摸等量的牌。 
	引用：LuaZhiheng
	状态：0405验证通过
]]--

LuaZhihengCard = sgs.CreateSkillCard{
	name = "LuaZhihengCard",
    target_fixed = true,
    mute = true,
	on_use = function(self, room, source, targets)
		if source:isAlive() then
			room:drawCards(source, self:subcardsLength(), "zhiheng")
		end
	end
}
LuaZhiheng = sgs.CreateViewAsSkill{
	name = "LuaZhiheng",
	n = 999,
	view_filter = function(self, selected, to_select)
        return not sgs.Self:isJilei(to_select)
	end,
	view_as = function(self, cards)
		if #cards == 0 then return nil end
		local zhiheng_card = LuaZhihengCard:clone()
		for _,card in pairs(cards) do
			zhiheng_card:addSubcard(card)
		end
		zhiheng_card:setSkillName(self:objectName())
		return zhiheng_card
	end,
	enabled_at_play = function(self, player)
		return not player:hasUsed("#LuaZhihengCard") and player:canDiscard(player, "he")
	end,
	enabled_at_response = function(self, target, pattern)
		return pattern == "@zhiheng"
	end
}
--[[
	技能名：智迟（锁定技）
	相关武将：一将成名·陈宫
	描述：你的回合外，每当你受到一次伤害后，【杀】或非延时类锦囊牌对你无效，直到回合结束。
	引用：LuaZhichi、LuaZhichiProtect、LuaZhichiClear
	状态：1217验证通过
]]--
LuaZhichi = sgs.CreateTriggerSkill{
	name = "LuaZhichi" ,
	events = {sgs.Damaged} ,
	frequency = sgs.Skill_Compulsory ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_NotActive then return false end
		local current = room:getCurrent()
		if current and current:isAlive() and (current:getPhase() ~= sgs.Player_NotActive) then
			if player:getMark("@late") == 0 then
				room:addPlayerMark(player, "@late")
			end
		end
	end
}
LuaZhichiProtect = sgs.CreateTriggerSkill{
	name = "#LuaZhichi-protect" ,
	events = {sgs.CardEffected} ,
	on_trigger = function(self, event, player, data)
		local effect = data:toCardEffect()
		if (effect.card:isKindOf("Slash") or effect.card:isNDTrick()) and (effect.to:getMark("@late") > 0) then
			return true
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
LuaZhichiClear = sgs.CreateTriggerSkill{
	name = "#LuaZhichi-clear" ,
	events = {sgs.EventPhaseChanging, sgs.Death} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to ~= sgs.Player_NotActive then
				return false
			end
		else
			local death = data:toDeath()
			if (death.who:objectName() ~= player:objectName()) or (player:objectName() ~= room:getCurrent():objectName()) then
				return false
			end
		end
		for _, p in sgs.qlist(room:getAllPlayers()) do
			if p:getMark("@late") > 0 then
				room:setPlayerMark(p, "@late", 0)
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：智愚
	相关武将：二将成名·荀攸
	描述：每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。 
	引用：LuaZhiyu
	状态：0405验证通过
]]--
LuaZhiyu = sgs.CreateMasochismSkill{
	name = "LuaZhiyu" ,
	on_damaged = function(self, target, damage)
		if target:askForSkillInvoke(self:objectName(), sgs.QVariant():setValue(damage)) then
			target:drawCards(1, self:objectName())
			local room = target:getRoom()
			if target:isKongcheng() then return false end
			room:showAllCards(target)
			local cards = target:getHandcards()
			local color = cards:first():isRed()
			local same_color = true
			for _, card in sgs.qlist(cards) do
				if card:isRed() ~= color then
					same_color = false
					break
				end
			end
			if same_color and damage.from and damage.from:canDiscard(damage.from, "h") then
				room:askForDiscard(damage.from, self:objectName(), 1, 1)
			end
		end
	end
}
--[[
	技能名：忠义（限定技）
	相关武将：2013-3v3·关羽
	描述：出牌阶段，你可以将一张红色手牌置于武将牌上。若你有“忠义”牌，己方角色使用的【杀】对目标角色造成伤害时，此伤害+1。身份牌重置后，你将“忠义”牌置入弃牌堆。
	引用：LuaZhongyi
	状态：1217验证通过
]]--
LuaZhongyiCard = sgs.CreateSkillCard{
	name = "LuaZhongyiCard",
	will_throw = false,
	target_fixed = true,
	handling_method = sgs.Card_MethodNone,
	on_use = function(self, room, source, targets)
		room:removePlayerMark(source, "@loyal")
		source:addToPile("loyal", self)
	end,
}
LuaZhongyiViewAsSkill = sgs.CreateOneCardViewAsSkill{
	name = "LuaZhongyi",
	filter_pattern = ".|red|.|hand",
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and player:getMark("@loyal") > 0
	end,
	view_as = function(self, originalCard)
		local card = LuaZhongyiCard:clone()
		card:addSubcard(originalCard)
		return card
	end,
}
LuaZhongyi = sgs.CreateTriggerSkill{
	name = "LuaZhongyi",
	events = {sgs.DamageCaused, sgs.EventPhaseStart, sgs.ActionedReset},
	frequency = sgs.Skill_Limited,
	limit_mark = "@loyal",
	view_as_skill = LuaZhongyiViewAsSkill,
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local mode = room:getMode()
		if event == sgs.DamageCaused then
			local damage = data:toDamage()
			if damage.chain or damage.transfer or not damage.by_user then return false end
			if damage.card and damage.card:isKindOf("Slash") then
				for _,p in sgs.qlist(room:getAllPlayers()) do
					if not p:getPile("loyal"):isEmpty() then
						local on_effect = false
						if string.sub(room:getMode(), 1, 3) == "06_" then
							on_effect = string.sub(player:getRole(), 1, 1) == string.sub(p:getRole(), 1, 1)
						else
							on_effect = room:askForSkillInvoke(p, "zhongyi", data)
						end
						if on_effect then
							damage.damage = damage.damage + 1
						end
					end
				end
			end
			data:setValue(damage)
		elseif (mode == "06_3v3" and event == sgs.ActionedReset) or (mode ~= "06_3v3" and event == sgs.EventPhaseStart) then
			if event == sgs.EventPhaseStart and player:getPhase() ~= sgs.Player_RoundStart then
				return false
			end
			if player:getPile("loyal"):length() > 0 then
				player:clearOnePrivatePile("loyal")
			end
		end
		return false
	end,
}
--[[
	技能名：咒缚
	相关武将：SP·张宝
	描述：阶段技。你可以将一张手牌移出游戏并选择一名无“咒缚牌”的其他角色：若如此做，该角色进行判定时，以“咒缚牌”作为判定牌。一名角色的回合结束后，若该角色有“咒缚牌”，你获得该牌。 
	引用：LuaZhoufu
	状态：1217验证通过
]]--
LuaZhoufuCard = sgs.CreateSkillCard{
	name = "LuaZhoufuCard",
	will_throw = false,
	handling_method =sgs.Card_MethodNone,
	
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() and to_select:getPile("incantation"):isEmpty()
	end,
	
	on_use = function(self, room, source, targets)
		local target = targets[1]
		local value = sgs.QVariant()
			value:setValue(source)
			target:setTag("LuaZhoufuSource" .. tostring(self:getEffectiveId()),value)
			target:addToPile("incantation",self)
	end
}
LuaZhoufuVS = sgs.CreateOneCardViewAsSkill{
	name = "LuaZhoufu",
	filter_pattern = ".|.|.|hand",
	
	view_as = function(self, cards)
		local card = LuaZhoufuCard:clone()
			card:addSubcard(cards)
		return card
	end,

	enabled_at_play = function(self,player)
		return not player:hasUsed("#LuaZhoufuCard")
	end
}
LuaZhoufu = sgs.CreateTriggerSkill{
	name = "LuaZhoufu",
	events = {sgs.StartJudge,sgs.EventPhaseChanging},
	view_as_skill = LuaZhoufuVS,
	
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.StartJudge then
			local card_id = player:getPile("incantation"):first()
			local judge = data:toJudge()
				judge.card = sgs.Sanguosha:getCard(card_id)
				room:moveCardTo(judge.card,nil,judge.who,sgs.Player_PlaceJudge,sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_JUDGE,judge.who:objectName(),self:objectName(),"",judge.reason),true)
				judge:updateResult()
				room:setTag("SkipGameRule",sgs.QVariant(true))
		else
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive then
			local id = player:getPile("incantation"):first()
			local zhangbao = player:getTag("LuaZhoufuSource" .. tostring(id)):toPlayer()
			if zhangbao and zhangbao:isAlive() then
				zhangbao:obtainCard(sgs.Sanguosha:getCard(id))
				end
			end
		end
	end,
	can_trigger = function(self, target)
		return target ~= nil and target:getPile("incantation"):length() > 0
	end
}
--[[
	技能名：筑楼
	相关武将：翼·公孙瓒
	描述：回合结束阶段开始时，你可以摸两张牌，然后失去1点体力或弃置一张武器牌。
	引用：LuaXZhulou
	状态：1217验证通过
]]--
LuaXZhulou = sgs.CreateTriggerSkill{
	name = "LuaXZhulou",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseStart},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom();
		if player:getPhase() == sgs.Player_Finish then
			if player:askForSkillInvoke(self:objectName()) then
				player:drawCards(2)
				if not room:askForCard(player, ".Weapon", "@zhulou-discard", sgs.QVariant(), sgs.Card_MethodDiscard) then
					room:loseHp(player)
				end
			end
		end
		return false
	end
}
--[[
	技能名：追忆
	相关武将：二将成名·步练师
	描述：你死亡时，可以令一名其他角色（杀死你的角色除外）摸三张牌并回复1点体力。
	引用：LuaZhuiyi
	状态：1217验证通过
]]--
LuaZhuiyi = sgs.CreateTriggerSkill{
	name = "LuaZhuiyi" ,
	events = {sgs.Death} ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local death = data:toDeath()
		if death.who:objectName() ~= player:objectName() then return false end
		local targets
		if death.damage and death.damage.from then
			targets = room:getOtherPlayers(death.damage.from)
		else
			targets = room:getAlivePlayers()
		end
		if targets:isEmpty() then return false end
		local prompt = "zhuiyi-invoke"
		if death.damage and death.damage.from and (death.damage.from:objectName() ~= player:objectName()) then
			prompt = "zhuiyi-invokex:" .. death.damage.from:objectName()
		end
		local target = room:askForPlayerChosen(player,targets,self:objectName(), prompt, true, true)
		if not target then return false end
		target:drawCards(3)
		local recover = sgs.RecoverStruct()
		recover.who = player
		recover.recover = 1
		room:recover(target, recover, true)
		return false
	end,
	can_trigger = function(self, target)
		return target and target:hasSkill(self:objectName())
	end
}
--[[
	技能名：惴恐
	相关武将：一将成名2013·伏皇后
	描述： 一名其他角色的回合开始时，若你已受伤，你可以与其拼点：若你赢，该角色跳过出牌阶段；若你没赢，该角色与你距离为1，直到回合结束。
	引用：LuaZhuikong、LuaZhuikongClear
	状态：1217验证通过
]]--
LuaZhuikong = sgs.CreateTriggerSkill{
	name = "LuaZhuikong",
	events = {sgs.EventPhaseStart},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if player:getPhase() ~= sgs.Player_RoundStart or player:isKongcheng() then
			return false
		end
		local skip = false
		local fuhuanghou = room:findPlayerBySkillName(self:objectName())
		if player:objectName() ~= fuhuanghou:objectName() and fuhuanghou:isWounded() and not fuhuanghou:isKongcheng()
				and room:askForSkillInvoke(fuhuanghou, self:objectName()) then
			if fuhuanghou:pindian(player, self:objectName(), nil) then
				if not skip then
					player:skip(sgs.Player_Play)
					skip = true
				end
			else
				room:setFixedDistance(player, fuhuanghou, 1)
				local new_data = sgs.QVariant()
				new_data:setValue(fuhuanghou)
				player:setTag(self:objectName(), new_data)
			end
		end
		return false
	end	
}
LuaZhuikongClear = sgs.CreateTriggerSkill{
	name = "#LuaZhuikong-clear",
	events = {sgs.EventPhaseChanging},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local change = data:toPhaseChange()
		if change.to ~= sgs.Player_NotActive then
			return false
		end
		local fuhuanghou = player:getTag("LuaZhuikong"):toPlayer() 
		if fuhuanghou then
			room:setFixedDistance(player, fuhuanghou, -1)
		end
		player:removeTag("zhuikong")
		return false
	end,
}
--[[
	技能名：资粮
	相关武将：阵·邓艾
	描述：每当一名角色受到伤害后，你可以将一张“田”交给该角色。
	引用：LuaZiliang
	状态：1217验证成功
]]--
LuaZiliang = sgs.CreateTriggerSkill{
	name = "LuaZiliang",
	events  = {sgs.Damaged},
	can_trigger = function(self, target)
		return target ~= nil
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local dengai = room:findPlayerBySkillName(self:objectName())
		if not player:isAlive() then return false end
		if dengai:getPile("field"):isEmpty() then return false end
		if not room:askForSkillInvoke(dengai, self:objectName(), data) then return false end
		room:fillAG(dengai:getPile("field"), dengai)
		local id = room:askForAG(dengai, dengai:getPile("field"), false, self:objectName())
		room:clearAG(dengai)
		room:obtainCard(player, id)
		return false
	end,
}
--[[
	技能名：自立（觉醒技）
	相关武将：一将成名·钟会
	描述：准备阶段开始时，若“权”大于或等于三张，你失去1点体力上限，摸两张牌或回复1点体力，然后获得“排异”。
	引用：LuaZili
	状态：0405验证通过
]]
LuaZili = sgs.CreatePhaseChangeSkill{
	name = "LuaZili" ,
	frequency = sgs.Skill_Wake ,
	on_phasechange = function(self, player)
		local room = player:getRoom()
        room:notifySkillInvoked(player, self:objectName())
		room:setPlayerMark(player, self:objectName(), 1)
		if room:changeMaxHpForAwakenSkill(player) then
			if player:isWounded() and room:askForChoice(player, self:objectName(), "recover+draw") == "recover" then
				room:recover(player, sgs.RecoverStruct(player))
			else
				room:drawCards(player, 2)
			end
			if player:getMark(self:objectName()) == 1 then
				room:acquireSkill(player, "paiyi")
			end
		end
		return false
	end ,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:hasSkill(self:objectName()) and target:getPhase() == sgs.Player_Start
		and target:getMark(self:objectName()) == 0 and target:getPile("power"):length() >= 3
	end
}
--[[
	技能名：自守
	相关武将：二将成名·刘表
	描述：摸牌阶段，若你已受伤，你可以额外摸X张牌（X为你已损失的体力值），然后跳过你的出牌阶段。
	引用：LuaZishou
	状态：1217验证通过
]]--
LuaZishou = sgs.CreateTriggerSkill{
	name = "LuaZishou" ,
	events = {sgs.DrawNCards} ,
	on_trigger = function(self, event, player, data)
		local n = data:toInt()
		local room = player:getRoom()
		if player:isWounded() then
			if room:askForSkillInvoke(player, self:objectName()) then
				local losthp = player:getLostHp()
				player:clearHistory()
				player:skip(sgs.Player_Play)
				data:setValue(n + losthp)
			else
				data:setValue(n)
			end
		else
			data:setValue(n)
		end
	end
}
--[[
	技能名：宗室（锁定技）
	相关武将：二将成名·刘表
	描述：你的手牌上限+X（X为现存势力数）。
	引用：LuaZongshi
	状态：1217验证通过
]]--
LuaZongshi = sgs.CreateMaxCardsSkill{
	name = "LuaZongshi" ,
	extra_func = function(self, target)
		local extra = 0
		local kingdom_set = {}
		table.insert(kingdom_set, target:getKingdom())
		for _, p in sgs.qlist(target:getSiblings()) do
			local flag = true
			for _, k in ipairs(kingdom_set) do
				if p:getKingdom() == k then
					flag = false
					break
				end
			end
			if flag then table.insert(kingdom_set, p:getKingdom()) end
		end
		extra = #kingdom_set
		if target:hasSkill(self:objectName()) then
			return extra
		else
			return 0
		end
	end
}
--[[
	技能名：纵火（锁定技）
	相关武将：倚天·陆伯言
	描述：你的杀始终带有火焰属性
	引用：LuaZonghuo
	状态：1217验证通过
]]--
LuaZonghuo = sgs.CreateTriggerSkill{
	name = "LuaZonghuo" ,
	frequency = sgs.Skill_Compulsory ,
	events = {sgs.CardUsed} ,
	on_trigger = function(self, room, player, data)
		local use = data:toCardUse()
		if use.card:isKindOf("Slash") and (not use.card:isKindOf("FireSlash")) then
			local fire_slash = sgs.Sanguosha:cloneCard("fire_slash", sgs.Card_SuitToBeDecided, 0)
			if not use.card:isVirtualCard() then
				fire_slash:addSubcard(use.card)
			elseif use.card:subcardsLength() > 0 then
				for _, id in sgs.qlist(use.card:getSubcards()) do
					fire_slash:addSubcard(id)
				end
			end
			fire_slash:setSkillName(self:objectName())
			use.card = fire_slash
			data:setValue(use)
		end
		return false
	end
}
--[[
	技能名：纵适
	相关武将：一将成名2013·简雍
	描述：每当你拼点赢，你可以获得对方的拼点牌。每当你拼点没赢，你可以获得你的拼点牌。
	引用：LuaZongshih
	状态：1217验证通过
]]--
LuaZongshih = sgs.CreateTriggerSkill{
	name = "LuaZongshih" ,
	events = {sgs.Pindian} ,
	frequency = sgs.Skill_Frequent ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local pindian = data:toPindian()
		local to_obtain = nil
		local jianyong = nil
		if (pindian.from and pindian.from:isAlive() and pindian.from:hasSkill(self:objectName())) then
			jianyong = pindian.from
			if pindian.from_number > pindian.to_number then
				to_obtain = pindian.to_card
			else
				to_obtain = pindian.from_card
			end
		elseif (pindian.to and pindian.to:isAlive() and pindian.to:hasSkill(self:objectName())) then
			jianyong = pindian.to
			if pindian.from_number < pindian.to_number then
				to_obtain = pindian.from_card
			else
				to_obtain = pindian.to_card
			end
		end
		if jianyong and to_obtain and (room:getCardPlace(to_obtain:getEffectiveId()) == sgs.Player_PlaceTable) then
			if room:askForSkillInvoke(jianyong, self:objectName(), data) then
				jianyong:obtainCard(to_obtain)
			end
		end
		return false
	end,
	can_trigger = function(self, target)
		return target
	end
}
--[[
	技能名：诈降（锁定技）
	相关武将：界限突破·黄盖
	描述：每当你失去1点体力后，你摸三张牌，若此时为你的回合，本回合，你可以额外使用一张【杀】，你使用红色【杀】无距离限制且此【杀】指定目标后，目标角色不能使用【闪】响应此【杀】。 
	引用：LuaZhaxiang、LuaZhaxiangRedSlash、LuaZhaxiangTargetMod
	状态：0405验证通过
]]--
LuaZhaxiang = sgs.CreateTriggerSkill {
	name = "LuaZhaxiang",
	events = {sgs.HpLost, sgs.EventPhaseChanging},
	frequency = sgs.Skill_Compulsory,
	priority = function(self, event, priority)
		if event == sgs.EventPhaseChanging then
			return priority == 8
		end
		return self:getPriority(event)
	end,
	can_trigger = function(self, target)
		return target
	end,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if event == sgs.HpLost and player and player:isAlive() and player:hasSkill(self:objectName()) then
			local lose = data:toInt()
			for i = 1, lose, 1 do
				room:sendCompulsoryTriggerLog(player, self:objectName())
				player:drawCards(3)
				if player:getPhase() == sgs.Player_Play then
					room:addPlayerMark(player, self:objectName())
				end
			end
		elseif event == sgs.EventPhaseChanging then
			local change = data:toPhaseChange()
			if change.to == sgs.Player_NotActive or change.to == sgs.Player_RoundStart then
				room:setPlayerMark(player, self:objectName(), 0)
			end
		end
		return false
	end
}
LuaZhaxiangRedSlash = sgs.CreateTriggerSkill {
	name = "#LuaZhaxiang",
	events = {sgs.TargetSpecified},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, target)
		return target and target:isAlive() and target:getMark("LuaZhaxiang") > 0
	end,
	on_trigger = function(self, event, player, data)
		local use = data:toCardUse()
		if not use.card:isKindOf("Slash") or not use.card:isRed() then return end
		local jink_list = sgs.QList2Table(player:getTag("Jink_"..use.card:toString()):toIntList())
		local index = 1
		local new_jink_list = sgs.IntList()
		for _, p in sgs.qlist(use.to) do
			jink_list[index] = 0
			index = index + 1
		end
		local result = sgs.IntList()
		for i = 1, #jink_list, 1 do
			result:append(jink_list[i])
		end
		local d = sgs.QVariant()
		d:setValue(result)
		player:setTag("Jink_"..use.card:toString(), d)
		return false
	end
}		
LuaZhaxiangTargetMod = sgs.CreateTargetModSkill{
	name = "#LuaZhaxiang-target",
	distance_limit_func = function(self, from, card)
		if from:getMark("LuaZhaxiang") > 0 and card:isRed() then
			return 1000
		else
			return 0
		end
	end,
	residue_func = function(self, from)
		return from:getMark("LuaZhaxiang")
	end
}
--[[
	技能名：纵玄
	相关武将：一将成名2013·虞翻
	描述：当你的牌因弃置而置入弃牌堆前，你可以将其中任意数量的牌以任意顺序依次置于牌堆顶。
	引用：LuaZongxuan
	状态：1217验证通过
]]--
LuaZongxuanCard = sgs.CreateSkillCard{
	name = "LuaZongxuanCard",
	target_fixed = true,
	will_throw = false,
	handling_method =sgs.Card_MethodNone,
	on_use = function(self, room, source, targets)
		local sbs = {}
		if source:getTag("LuaZongxuan"):toString() ~= "" then
			sbs = source:getTag("LuaZongxuan"):toString():split("+")
		end
		for _,cdid in sgs.qlist(self:getSubcards()) do table.insert(sbs, tostring(cdid))  end
		source:setTag("LuaZongxuan", sgs.QVariant(table.concat(sbs, "+")))
	end
}
LuaZongxuanVS = sgs.CreateViewAsSkill{
	name = "LuaZongxuan",
	n = 998,
	view_filter = function(self, selected, to_select)
		local str = sgs.Self:property("LuaZongxuan"):toString()
		return string.find(str, tostring(to_select:getEffectiveId())) end,
	view_as = function(self, cards)
		if #cards ~= 0 then
			local card = LuaZongxuanCard:clone()
			for var=1,#cards do card:addSubcard(cards[var]) end
			return card
		end
	end,
	enabled_at_play = function(self, player)
		return false
	end,
	enabled_at_response=function(self,player,pattern)
		return pattern == "@@LuaZongxuan"
	end,
}
function listIndexOf(theqlist, theitem)
	local index = 0
	for _, item in sgs.qlist(theqlist) do
		if item == theitem then return index end
		index = index + 1
	end
end
LuaZongxuan = sgs.CreateTriggerSkill{
	name = "LuaZongxuan",
	view_as_skill = LuaZongxuanVS,
	events = {sgs.BeforeCardsMove},
	on_trigger = function(self, event, player, data)
		local room=player:getRoom()
		local move = data:toMoveOneTime()
		local source = move.from
		if not move.from or source:objectName() ~= player:objectName() then return end
		local reason = move.reason.m_reason
		if move.to_place == sgs.Player_DiscardPile then
			if bit32.band(reason, sgs.CardMoveReason_S_MASK_BASIC_REASON) == sgs.CardMoveReason_S_REASON_DISCARD then
				local zongxuan_card = sgs.IntList()
				for i=0, (move.card_ids:length()-1), 1 do
					local card_id = move.card_ids:at(i)
					if room:getCardOwner(card_id):getSeat() == source:getSeat()
						and (move.from_places:at(i) == sgs.Player_PlaceHand
						or move.from_places:at(i) == sgs.Player_PlaceEquip) then
						zongxuan_card:append(card_id)
					end
				end
				if zongxuan_card:isEmpty() then
					return
				end
				local zongxuantable = sgs.QList2Table(zongxuan_card)
				room:setPlayerProperty(player, "LuaZongxuan", sgs.QVariant(table.concat(zongxuantable, "+")))
				while not zongxuan_card:isEmpty() do
					if not room:askForUseCard(player, "@@LuaZongxuan", "@LuaZongxuanput") then break end
					local subcards = sgs.IntList()
					local subcards_variant = player:getTag("LuaZongxuan"):toString():split("+")
					if #subcards_variant>0 then
						for _,ids in ipairs(subcards_variant) do 
							subcards:append(tonumber(ids)) 
						end
						local zongxuan = player:property("LuaZongxuan"):toString():split("+")
						for _, id in sgs.qlist(subcards) do
							zongxuan_card:removeOne(id)
							table.removeOne(zongxuan,tonumber(id))
							if move.card_ids:contains(id) then
								move.from_places:removeAt(listIndexOf(move.card_ids, id))
								move.card_ids:removeOne(id)
								data:setValue(move)
							end
							room:setPlayerProperty(player, "zongxuan_move", sgs.QVariant(tonumber(id)))
							room:moveCardTo(sgs.Sanguosha:getCard(id), player, nil ,sgs.Player_DrawPile, move.reason, true)
							if not player:isAlive() then break end
						end
					end
					player:removeTag("LuaZongxuan")
				end
			end
		end
		return
	end,
}
--[[
	技能名：醉乡（限定技）
	相关武将：☆SP·庞统
	描述：准备阶段开始时，你可以将牌堆顶的三张牌置于你的武将牌上。此后每个准备阶段开始时，你重复此流程，直到你的武将牌上出现同点数的“醉乡牌”，然后你获得所有“醉乡牌”（不能发动“漫卷”）。你不能使用或打出“醉乡牌”中存在的类别的牌，且这些类别的牌对你无效。
	引用：LuaZuixiang
	状态：1217验证成功
	Fs注：此技能与“漫卷”有联系，而有联系部分使用的为本LUA手册的“漫卷”技能并非原版
]]--
LuaZuixiangType = {
	"BasicCard",	--sgs.Card_TypeBasic (1)
	"TrickCard",	--sgs.Card_TypeTrick (2)
	"EquipCard"		--sgs.Card_TypeEquip (3)
}
LuaDoZuixiang = function(player)
	local room = player:getRoom()
	local type_list = {
		0,	--sgs.Card_TypeBasic (1)
		0,	--sgs.Card_TypeTrick (2)
		0	--sgs.Card_TypeEquip (3)
	}
	for _, card_id in sgs.qlist(player:getPile("dream")) do
		local c = sgs.Sanguosha:getCard(card_id)
		type_list[c:getTypeId()] = 1
	end
	local ids = room:getNCards(3, false)
	local move = sgs.CardsMoveStruct()
	move.card_ids = ids
	move.to = player
	move.to_place = sgs.Player_PlaceTable
	move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), "LuaZuixiang", nil)
	room:moveCardsAtomic(move, true)
	player:addToPile("dream", ids, true)
	for _, id in sgs.qlist(ids) do
		local cd = sgs.Sanguosha:getCard(id)
		if LuaZuixiangType[cd:getTypeId()] == "EquipCard" then
			if player:getMark("Equips_Nullified_to_Yourself") == 0 then
				room:setPlayerMark(player, "Equips_Nullified_to_Yourself", 1)
			end
			if player:getMark("Equips_of_Others_Nullified_to_You") == 0 then
				room:setPlayerMark(player, "Equips_of_Others_Nullified_to_You", 1)
			end
		end
		if type_list[cd:getTypeId()] == 0 then
			type_list[cd:getTypeId()] = 1
			room:setPlayerCardLimitation(player, "use,response", LuaZuixiangType[cd:getTypeId()], false)
		end
	end
	local zuixiang = player:getPile("dream")
	local numbers = {}
	local zuixiangDone = false
	for _, id in sgs.qlist(zuixiang) do
		local card = sgs.Sanguosha:getCard(id)
		if table.contains(numbers, card:getNumber()) then
			zuixiangDone = true
			break
		end
		table.insert(numbers, card:getNumber())
	end
	if zuixiangDone then
		player:addMark("LuaZuixiangHasTrigger")
		room:setPlayerMark(player, "Equips_Nullified_to_Yourself", 0)
		room:setPlayerMark(player, "Equips_of_Others_Nullified_to_You", 0)
		room:removePlayerCardLimitation(player, "use,response", "BasicCard$0")
		room:removePlayerCardLimitation(player, "use,response", "TrickCard$0")
		room:removePlayerCardLimitation(player, "use,response", "EquipCard%0")
		player:setFlags("LuaManjuanNullified")
		local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_PUT, player:objectName(), nil, "LuaZuixiang", nil)
		local move = sgs.CardsMoveStruct()
		move.card_ids = zuixiang
		move.to = player
		move.to_place = sgs.Player_PlaceHand
		move.reason = reason
		room:moveCardsAtomic(move, true)
		player:setFlags("-LuaManjuanNullified")
	end
end
LuaZuixiang = sgs.CreateTriggerSkill{
	name = "LuaZuixiang" ,
	events = {sgs.EventPhaseStart, sgs.SlashEffected, sgs.CardEffected} ,
	limit_mark = "@sleep",
	frequency = sgs.Skill_Limited ,
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		local zuixiang = player:getPile("dream")
		if (event == sgs.EventPhaseStart) and (player:getMark("LuaZuixiangHasTrigger") == 0) then
			if player:getPhase() == sgs.Player_Start then
				if player:getMark("@sleep") > 0 then
					if not player:askForSkillInvoke(self:objectName()) then return false end
					room:removePlayerMark(player, "@sleep")
					LuaDoZuixiang(player)
				else
					LuaDoZuixiang(player)
				end
			end
		elseif event == sgs.CardEffected then
			if zuixiang:isEmpty() then return false end
			local effect = data:toCardEffect()
			if effect.card:isKindOf("Slash") then return false end
			local eff = true
			for _, card_id in sgs.qlist(zuixiang) do
				local c = sgs.Sanguosha:getCard(card_id)
				if c:getTypeId() == effect.card:getTypeId() then
					eff = false
					break
				end
			end
			return not eff
		elseif event == sgs.SlashEffected then
			if zuixiang:isEmpty() then return false end
			local effect = data:toSlashEffect()
			local eff = true
			for _, card_id in sgs.qlist(zuixiang) do
				local c = sgs.Sanguosha:getCard(card_id)
				if c:getTypeId() == sgs.Card_TypeBasic then
					eff = false
					break
				end
			end
			return not eff
		end
		return false
	end
}