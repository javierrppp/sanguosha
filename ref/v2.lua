--[[
	���ܴ����ٲ��ֲ�
	���ð汾����1005��
	��飺���ֲ��ΪA~Z��26���½ڣ��ֱ��Լ�������һ���ֵ�ƴ������ĸ���࣬����ChapterV���ڴ��һЩ�����Ƶļ��ܡ�
]]--
-----------
--[[A��]]--
-----------
--[[�����������
	����佫����SP������
	������ÿ����ʹ�á�ɱ����Ŀ���ɫ����˺�ʱ������Է�ֹ���˺�������������ý�ɫ����һ�����ƣ�Ȼ������һ���ơ�ÿ�����Ϊ��ɱ����Ŀ��ʱ�����������һ�����ƣ�����������ˡ�ɱ����ʹ������һ���ƣ��ˡ�ɱ��������Ч��
	���ã�LuaAnxian
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����������������ʦ
	���������ƽ׶Σ������ѡ����������������ȵ�������ɫ�������������ٵĽ�ɫ������ƶ�Ľ�ɫ��һ�����Ʋ�չʾ֮�������Ʋ�Ϊ���ң�����һ���ơ�ÿ�׶���һ�Ρ�
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
--[[����������������������
	����佫��һ������2013�����&����
	��������������ÿ����ʹ�á�ɱ����Ŀ���ɫ����˺�ʱ�����㲻���乥����Χ�ڣ����˺�+1��
	���ã�LuaAnjian
	״̬��0405��֤ͨ��
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
--[[������������
	����佫��SP������
	��������Ļغ��⣬ÿ������Ҫʹ�û���һ�Ż�����ʱ������Թۿ��ƶѶ��������ƣ�Ȼ��ʹ�û�������һ�Ÿ����Ļ����ơ�
	״̬��0405��֤ͨ��[��Դ����������]
	���ã�LuaAocai
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
	room:returnToTopDrawPile(ids)--������������ƷŻ��ƶѶ�
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
--[[B��]]--
-----------
 --[[����������������������
	����佫������ģʽ����
	������������ʱ��ɱ�����������ɫ�������������ơ�
	���ã�LuaBossBeiming
	״̬��0405��֤ͨ��
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
--[[����������������������
	����佫���ǡ���ά
	������������������ʧȥ��������ʱ����Ϊ���һ��������ɫʹ����һ�š�ɱ���������������������Ϊ����Լ�ʹ����һ�š�ɱ��
	���ã�LuaBeifa
	״̬��0405��֤ͨ��
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
				target = room:askForPlayerChosen(jiangwei, players, self:objectName())--û�д���TargetMod
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
--[[������������
	����佫��SP������
	������ÿ�����ܵ�����Դ���˺������˺���Դ���������������С��X������Խ����Ʋ���X������Ϊ5���ţ�����X���������������X+1�����ƣ�Ȼ����˺���Դ���1���˺�����XΪ�˺���Դ����������
	���ã�LuaBeiyu
	״̬��0405��֤ͨ��
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
--[[�����������裨���Ѽ���
	����佫���ơ���׿
	���������ƽ׶ν���ʱ�����㱾����Ϸ����������������������3���������ޣ��ظ�3��������Ȼ���á���������
	���ã�LuaBaoling
	״̬��0405��֤ͨ��
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
--[[���������Ե�
	����佫���ǡ�����
	�����������Ϊ��ɫ�ġ�ɱ��Ŀ��������ʹ��һ�š�ɱ��
	���ã�LuaBadao
	״̬��0405��֤ͨ��
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
--[[�����������䣨��������
	����佫��SP���ĺ��
	�����������������������ֵΪ��3����ͣ���ӵ�С����ơ���2����ͣ���ӵ�С���������1����ͣ���ӵ�С����١���
	���ã�LuaBaobian
	״̬��0405��֤ͨ��
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
--[[������������
	����佫��TWһ���������ĺ��
	����������ʹ�á�ɱ���򡾾�������Ŀ���ɫ����˺�ʱ�������������㣺��ͬ������Է�ֹ���˺������佫���Ʋ���X�ţ�XΪ���������ޣ�����ͬ��������������������ֵ�������������Y�����ƣ�YΪ��������������ֵ�Ĳ�� 
	���ã�LuaTWBaobian
	״̬��0405��֤ͨ��
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
						local id = hc:at(math.random(0, hc:length() - 1))--ȡ������ƴ���askForCardChosen
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
--[[����������������������
	����佫������ģʽ��ţͷ������ģʽ�����޳�
	�����������׶ο�ʼʱ�����������ơ� 
	���ã�LuaBossBaolian
	״̬��0405��֤ͨ��
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
--[[������������
	����佫���ǡ����
	������ÿ����ʹ�õġ�ɱ��������������ʱ���������Ŀ���ɫƴ�㣺����Ӯ��������Ϊ�������������ɫ��ʹ����һ�š�ɱ������ɱ������ÿ�׶ε�ʹ�����ƣ���
	���ã�LuaBawang
	״̬��0405��֤ͨ��
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
--[[����������Ҽ
	����佫��һ������2014����Ӻ
	�����������׶ο�ʼʱ�����������ƣ������չʾ�������ƣ�����Ϊͬһ��ɫ�������������X����ɫ����һ���ơ���XΪ�����������
	���ã�LuaBingyi
	״̬��0405��֤ͨ��
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
--[[��������������������
	����佫���������
	�����������װ����û�з����ƣ���Ϊ��װ���š������󡿡�
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
--[[����������ӡ�����Ѽ���
	����佫����˾��ܲ
	�������غϿ�ʼ�׶ο�ʼʱ������ӵ��4ö�����ġ��̡���ǣ������1���������ޣ�����ü��ܡ����ԡ���
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
--[[����������Ű����������
	����佫���֡���׿
	������ÿ������Ⱥ�۽�ɫ���һ���˺��󣬸ý�ɫ���Խ���һ���ж������ж����Ϊ���ң���ظ�1��������
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
--[[������������
	����佫��ɽ�����ļ���SP�����ļ�
	������ÿ��һ����ɫ�ܵ���ɱ����ɵ�һ���˺������������һ���ƣ��������һ���ж����ж����Ϊ������ �ý�ɫ�ظ�1������������ �ý�ɫ�������ƣ�÷�� �˺���Դ���������ƣ����� �˺���Դ�����佫�Ʒ��档
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
--[[����������������������
	����佫���֡���׿
	�������غϽ����׶ο�ʼʱ�����㲻�ǵ�ǰ������ֵ���ٵĽ�ɫ֮һ������ʧȥ1���������1���������ޡ� 
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
--[[������������
	����佫����׼��������SP����
	�������غϽ����׶ο�ʼʱ���������һ���ơ�
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
--[[������������
	����佫��һ�����������̫
	��������һ����ɫ�������״̬ʱ�������չʾ�ý�ɫ��һ�����ƣ������Ʋ�Ϊ�����ƣ��ý�ɫ����֮��Ȼ��ظ�1��������
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
--[[������������
	����佫���硤��̩
	������ÿ����ۼ�1�����������㵱ǰ������ֵΪ0������Դ��ƶѶ�����һ������������佫���ϣ������Ƶĵ��������佫�������е��κ�һ���ƶ���ͬ���㲻����������������ͬ�������ƣ���������״̬��
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
--[[������������
	����佫�����ɡ���̩
	������ÿ����ۼ�1�����������������ֵΪ0������Խ��ƶѶ���һ���������佫���ϣ���Ϊ�������������С������ĵ�������ͬ���㲻��������״̬��
	���ã�LuaNosBuqu��LuaNosBuquRemove
	״̬��0405��֤ͨ��
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
--[[����������Ϯ����������
	����佫��һ������2014����ܲ
	����������������Ļغ��ڣ�����������ɫ�ľ���-X����Ļغ��ڣ�����������������ɫ�����Ϊ1��������ɫ�ķ�����Ч����ʹ�á�ɱ�����Զ���ѡ��һ��Ŀ�ꡣ��XΪ���غ�����ʹ�ý�����ϵ�������
	���ã�LuaBenxi��LuaBenxiTargetMod��LuaBenxiDistance
	״̬��0405��֤ͨ��
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
--[[���������ʷ�
	����佫��SP������
	�����������׶ο�ʼʱ������Խ�һ�������Ƴ���Ϸ��ѡ��һ��������ɫ���ý�ɫ�ĻغϿ�ʼʱ���ۿ����ƣ�Ȼ��ѡ��һ�������һ�������������ͬ���Ʋ���ø��ƣ��򽫸����������ƶѲ�ʧȥ1��������
	���ã�LuaBifa
	״̬��0405��֤ͨ��
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
--[[�����ٲ��ֲᣨC����
	����������
		��ʴ���ػ������䡢��Թ���������ǡ����󡢳��󡢳��󡢳�ӯ�����ء����󡢳𺣡����������ݡ����ġ����ġ��������ϻۡ����á�����
]]--
--[[����������ʴ
	����佫��SP�����
	���������ƽ׶ο�ʼʱ������Է������ƣ���X���ƣ�X Ϊ�����˵Ľ�ɫ��������������������ڴ˻غ���ʹ�û����ƻ������ʱ��������һ���ơ� 
	���ã�LuaCanshi
	״̬��0405��֤ͨ��	
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
--[[���������ػ�
	����佫��1v1������Ӣ1v1
	������������ʱ������Խ�װ����������װ�����Ƴ���Ϸ���������������¸��佫�ǳ�ʱ������Щ������װ������
	���ã�LuaCangji��LuaCangjiInstall
	״̬��0405��֤ͨ��(KOF2013ģʽ)
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
--[[������������
	����佫��ͭȸ̨�����ʺ�
	���������ƽ׶ο�ʼʱ������Իظ�1���������������ƣ�Ȼ������佫�Ʒ��棻������ɫ�Ļغ��ڣ������ã�ÿ�غ���һ�Σ�/ʧȥһ����ʱ��������佫�Ʊ��泯�ϣ��������ý�ɫ��/����һ���ơ�
	���ã�LuaCangni
	״̬��0405��֤ͨ��
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
--[[����������Թ����������
	����佫���硤�ڼ�
	�������㲻�����ɡ��ƻ󡱡����������ֵΪ1����������佫������Ч��
	���ã�LuaChanyuan
	״̬��1217��֤ͨ��(����ϱ��ֲ�ġ��ƻ�һ��ʹ��)
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
--[[����������������
	����佫�����ԡ��������
	�������غϿ�ʼ�׶Σ�����Թۿ��ƶѶ���5���ƣ�������������������������˳�������ƶѶ���������������˳�������ƶѵ�
	���ã�LuaXSuperGuanxing
	״̬��0405��֤ͨ��
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
--[[������������
	����佫������һ������2013���ܳ�
	������ ÿ�����ܵ�һ���˺��������չʾ�ƶѶ��������ƣ�Ȼ��������������������֮��С��13���ƣ�������������������ƶѡ�
	���ã�LuaChengxiang
	״̬��0405��֤ͨ��
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
--[[������������
	����佫�����졤�ܳ�
	������ÿ�����ܵ�һ���˺������������X�ŵ���֮��������˺����Ƶĵ�����ȵ��ƣ������ѡ������X����ɫ��������������ظ�1�������������������ơ�
	���ã�LuaYTChengxiang
	״̬��0405��֤ͨ��
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
--[[������������
	����佫��һ������2013���ܳ�
	������ ÿ�����ܵ�һ���˺��������չʾ�ƶѶ��������ƣ�Ȼ��������������������֮��С�ڻ����13���ƣ�������������������ƶѡ�
	���ã�LuaChengxiang
	״̬��0405��֤ͨ��
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
--[[�����������أ���������
	����佫��ͭȸ̨������
	����������������޵�������������ޣ�������ɫ����ʱ�����1���������ޡ�
	���ã�LuaChizhongKeep��LuaChizhong
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����SP������
	������ÿ���㷢����������ʹ�û���һ������ʱ�������������öԷ���һ�����ơ�
	���ã�LuaChongzhen
	״̬��0405��֤ͨ��
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
--[[���������𺣣���������
	����佫��SP�����
	�����������ܵ��˺�ʱ������û�����ƣ�������˺�+1�� 
	���ã�LuaChouhai
	״̬��0405��֤ͨ��
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
--[[������������
	����佫���ǡ�����
	�������غϽ����׶ο�ʼʱ�����������������ţ�����Դ��ƶѶ�����4-X���ƣ�XΪ��������������������еĻ����ƣ�����������������ƶ�
	���ã�LuaChouliang
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����׼����٢
	�������׶μ����������ƣ������ѡ������һ������������ͬ�����Ƶ�������ɫ�����������������������Щ��ɫ��һ���ƣ�Ȼ���Դ˷�����?�ƵĽ�ɫ��һ���ơ� 
	���ã�LuaChuli
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����������������
	�����������׶ο�ʼʱ��������佫����û���ƣ�����Խ����������ġ�ɱ����������佫���ϣ���Ϊ����������һ����ɫ���ڱ���״̬ʱ������Խ�һ�š������������ƶѣ���ý�ɫ��Ϊʹ��һ�š��ơ���
	���ã�LuaChunlao
	״̬��0405��֤ͨ��
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
--[[���������ϻۣ���������
	����佫�����졤�ܳ�
	�������㽫��Զ����������ƽ׶�
	���ã�LuaConghui
	״̬��0405��֤ͨ��
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
--[[������������
	����佫���ơ��ӷ���
	�������޶��������ƽ׶Σ������ʧȥ�����㡱�͡����á���Ȼ����һ����ɫ��á��¾�������һ����ɫ�ڳ��ƽ׶���ʹ�õĵ�һ����Ϊ��ɱ�����ˡ�ɱ��������Ϻ��������ƶ�ʱ�������������֮���������ý�ɫ�����㣬�ý�ɫ�������ơ� 
	���ã�LuaCunsi��LuaCunsiStart
	״̬��1217��֤ͨ��
	
	ע���˼������������ϵ������ϵ�ĵط���ʹ�ñ��ֲᵱ�еĹ��㣬����ԭ��
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
--[[��������������������
	����佫��1v1��ţ��
	�����������ʼ������ΪX+2��XΪ�㱸ѡ�����佫�Ƶ����������������ǳ���ĵ�һ���ж��׶Ρ� 
	���ã�LuaCuorui
	״̬��1217��֤ͨ��
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
--[[D��]]--
-----------
--[[�����������
	����佫����SP���ŷ�
	���������ƽ׶���һ�Σ��������һ����ɫƴ�㣺����Ӯ������Խ��ý�ɫ��ƴ���ƽ���һ������ֵ��������Ľ�ɫ�����غϸý�ɫʹ�õķ�?��������Ч������ûӮ����չʾ�������ƣ�Ȼ������һ�����ơ�
	���ã�LuaDahe��LuaDahePindian
	״̬��0504��֤ͨ��
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
--[[������������
	����佫���������
	�����������׶ο�ʼʱ������Խ�X�š��ǡ��������ƶѲ�ѡ��X����ɫ���������������»غϿ�ʼǰ��ÿ����Щ��ɫ�ܵ��ķ��׵��˺����㿪ʼʱ����ֹ���˺���
	���ã�LuaDawu
	״̬��0405��֤ͨ��(���뱾�ֲ�ġ����ǡ����ʹ��)
	��ע��ҽ������&ˮ��wch�磺Դ����ʹ���ļ���ѯ�����ǵ�����ֱ�λ�����ǵ�QixingAsk��QixingClear�У��˼��ܶ��������ˡ�
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
--[[��������������Ѽ���
	����佫��SP������
	������׼���׶ο�ʼʱ���������������������ֵ���ұ�����Ϸ����Ϊ�ܲ٣����1���������ޣ�Ȼ���ü��ܡ���������
	���ã�LuaDanji
	״̬��0405��֤ͨ��
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
--[[������������
	����佫��һ������2013����Ȼ
	������ ÿ��������˺����������һ���ƣ�Ȼ�������ǰ�غϲ�����һ�н��㡣
	״̬��Lua�޷�ʵ��
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
--[[�����������
	����佫��SP������
	������ÿ������������ɫ��Ϊ�����Ƶ�Ŀ�������ΪĿ���ɫ���������һ���ƣ�Ȼ��ý����ƶ�����Ч��   
	���ã�LuaDanlao
	״̬��0405��֤ͨ��
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
--[[�����������ȣ���������
	����佫�������������λ�
	�������غϿ�ʼʱ����ִ��һ������ĳ��ƽ׶Ρ�
	���ã�LuaDangxian
	״̬��0405��֤ͨ��
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
--[[������������
	����佫���֡�³��
	���������ƽ׶���һ�Σ���������������������Ʋ�ѡ����������������ڸ�������������ɫ�������������������ɫ�������ǵ����ơ� 
	���ã�LuaDimeng
	״̬��0405��֤ͨ��
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
--[[����������Ʒ
	����佫���Ľ�����Ⱥ
	���������ƽ׶Σ����������һ�����㱾�غ���ʹ�û����õ���������ͬ�����ƣ�Ȼ����һ�������˵Ľ�ɫ�����ж��������Ϊ��ɫ���ý�ɫ��X���ƣ����㱾�׶β��ܶԸý�ɫ��������Ʒ������ɫ���㽫�佫�Ʒ��档��XΪ�ý�ɫ����ʧ������ֵ��
	���ã�LuaDingpin
	״̬��0428��֤ͨ��
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
--[[������������
	����佫�����졤���ĺ�
	�������غϿ�ʼ�׶ο�ʼʱ�������ָ��һ��������ɫ���ý�ɫ���������ƶ��㴦�ڿɼ�״̬��ֱ����ı��غϽ�����������ɫ����֪�����˭�����˶��켼�ܣ�����������Ľ�ɫ����
	���ã�LuaDongcha
	״̬��1217��֤ͨ��
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
--[[����������ʿ����������
	����佫�����졤���ĺ�
	������ɱ����Ľ�ɫ��ñ�������ֱ����Ϸ����
	���ã�LuaDushi
	״̬��0405��֤ͨ��
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
--[[����������ҽ
	����佫��ͭȸ̨������
	���������ƽ׶���һ�Σ�����������ƶѶ���һ���Ʋ�����һ����ɫ��������Ϊ��ɫ���ý�ɫ����ʹ�û��������ƣ�ֱ���غϽ�����
	���ã�LuaDuyi
	״̬��0504��֤ͨ��
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
--[[������������
	����佫��SP������
	���������ƽ׶Σ������ѡ�񹥻���Χ�ڵ�һ��������ɫ������X���ƣ������������Ըý�ɫ���1���˺���
		�����Դ˷���ý�ɫ�������״̬�������������ʧȥ1���������ұ��׶��㲻���ٴη��������䡱����XΪ�ý�ɫ��ǰ������ֵ��
	״̬��0504��֤ͨ��
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
--[[���������̱�
	����佫����ս������
	��������ʹ�á�ɱ�����Զ���ѡ��һ������1��Ŀ�ꡣ
	���ã�LuaXDuanbing
	״̬��0504��֤ͨ��
	��ע��ԭ�����漰�޸�Դ�롣Lua�İ汾�Դ˷���ʵ�֣����������΢Ƿ�ѡ�
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
--[[���������ϳ�����������
	����佫��ɽ�����ļ���SP�����ļ�
	������ɱ����Ľ�ɫʧȥ�����佫���ܡ� 
	���ã�LuaDuanchang
	״̬��0405��֤ͨ��
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
--[[������������
	����佫���֡����
	����������Խ�һ�ź�ɫ�Ļ����ƻ��ɫ��װ���Ƶ���������ϡ�ʹ�á���ʹ�á�������ϡ��ľ�������Ϊ2�� 
	���ã�LuaDuanliangTargetMod��LuaDuanliang
	״̬��0405��֤ͨ��
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
--[[����������ָ
	����佫��ͭȸ̨������
	�����������Ϊ������ɫʹ�õ��Ƶ�Ŀ�����������������������ƣ�Ҳ���Բ����ã���Ȼ��ʧȥ1��������
	���ã�LuaXDuanzhi��LuaXDuanzhiFakeMove
	״̬��1217��֤ͨ��	
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
			local dummy = sgs.Sanguosha:cloneCard("slash") --û�취�ˣ���ʱ�������DummyCard�ɡ���
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
--[[���������ᵶ
	����佫��һ������2013�����&����
	������ÿ�����ܵ�һ�Ρ�ɱ����ɵ��˺������������һ���ƣ�����˺���Դװ�����������ơ�
	���ã�LuaDuodao
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����ս��½ѷ
	���������ƽ׶����ĴΣ����������һ�ź�ɫ���Ʋ�ѡ������������������ɫ��������Щ��ɫ�ȸ��������ƣ�Ȼ������������ơ�
	���ã�LuaXDuoshi
	״̬��1217��֤ͨ��	
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
	������������
	����佫���֡����
	����������Խ�һ�ź�ɫ�Ƶ���������ϡ�ʹ�ã����Ʊ���Ϊ�����ƻ�װ���ƣ�����ԶԾ���2���ڵ�һ��������ɫʹ�á�������ϡ��� 
]]--
-----------
--[[E��]]--
-----------
--[[����������Թ
	����佫��һ������������
	��������ÿ�λ��һ��������ɫ���Ż�������ʱ������������һ���ƣ�ÿ�����ܵ�1���˺�����������˺���Դѡ��һ�������һ�����ƣ���ʧȥ1��������
	���ã�LuaEnyuan
	״̬��1217��֤ͨ��
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
				end   --��ȥMoveOneTime��from��Ȼ��player����splayer������ö������splayer��ȡ�¡���
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
--[[����������Թ����������
	����佫�����ɡ�����
	������������ɫÿ����ظ�1���������ý�ɫ��һ���ƣ�������ɫÿ�������һ���˺����轻����һ�ź������ƣ�����ý�ɫʧȥ1��������
	���ã�LuaNosEnyuan
	״̬��0405��֤ͨ��
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
--[[F��]]--
-----------
--[[������������
	����佫����׼�����
	���������ƽ׶Σ��������һ��������ɫ˵��һ�ֻ�ɫ��Ȼ�������һ�����Ʋ�չʾ֮�������Ʋ�Ϊ������֮��ɫ����Ըý�ɫ���1���˺���ÿ�׶���һ�Ρ�
	���ã�LuaFanjian
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�������
	���������ƽ׶Σ������ѡ��һ�����ƣ���һ��������ɫ˵��һ�ֻ�ɫ��չʾ�����֮�����´������ܵ��������ɵ�1���˺���ÿ�׶���һ�Ρ�
	���ã�LuaXNeoFanjian
	״̬��1217��֤ͨ��
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
--[[������������
	����佫������ͻ�ơ�˾��ܲ
	������ÿ�����ܵ�1���˺�������Ի���˺���Դ��һ���ơ� 
	���ã�LuaFankui
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����׼��˾��ܲ
	������ÿ�����ܵ��˺�������Ի���˺���Դ��һ���ơ�   
	���ã�LuaNosFankui
	״̬��0405��֤ͨ��
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
--[[������������
	����佫������ͻ��SP����ά
	���������Ѽ�������������״̬ʱ�����1���������޲�������ֵ�ָ���2�㣬Ȼ���ü��ܡ����ơ��������ܡ����ܡ���Ϊ����������   
	���ã�LuaFengliang
	״̬��0504��֤ͨ��
	��ע��zy��Ҫ���ֲ�����������ʹ�á����߽���õı�Ǹ�Ϊ��fengliang��������LuaKunfen����Ϊ��kunfen��
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
--[[����������Ȩ
	����佫��ɽ������
	�����������������ĳ��ƽ׶Σ�������������ڻغϽ���ʱ��������һ��������һ��������ɫ����һ������Ļغϡ�
	���ã�LuaFangquan��LuaFangquanGive
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���֡���ا��ͭȸ̨����ا����˾��ܲ
	������ÿ�����ܵ��˺����������һ��������ɫ��X���ƣ�Ȼ�����佫�Ʒ��档��XΪ������ʧ������ֵ��   
	���ã�LuaFangzhu
	״̬��0405��֤ͨ��
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
--[[����������Ӱ����������
	����佫���񡤲ܲ١����졤κ���
	������������ɫ����ľ���+1 
	���ã�LuaFeiying
	״̬��0405��֤ͨ��
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
--[[���������ٳǣ��޶�����
	����佫��һ������2013������
	���������ƽ׶Σ������������������ɫѡ��һ�����X���ƣ����ܵ��������ɵ�1������˺�����XΪ�ý�ɫװ�����Ƶ�����������Ϊ1��
	���ã�LuaFencheng
	״̬��1217��֤ͨ��
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
--[[�����������ģ��޶�����
	����佫��ͭȸ̨�����¡�SP������
	����������ɱ��һ����������ɫʱ�����䷭�������֮ǰ���������ý�ɫ��������ơ���������Ϊ����ʱ���ܷ����˼��ܡ���
	���ã�LuaXFenxin
	״̬��1217��֤ͨ��
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
--[[���������ܼ�
	����佫���硤��̩
	������ÿ��һ����ɫ����������һ����ɫ�����û���Ϊ���ƶ�ʧȥ�������ʧȥ1������������������ý�ɫ�������ơ� 
	���ã�LuaFenji
	״̬��0405��֤ͨ��
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
--[[����������Ѹ
	����佫����ս������
	���������ƽ׶���һ�Σ����������һ���Ʋ�ѡ��һ��������ɫ���������������������غ���������ý�ɫ�ľ��롣
	���ã�LuaFenxun
	״̬��1217��֤ͨ��
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
--[[������������
	����佫����SP���ĺ
	������ÿ�����ܵ�һ���˺��������������������ƣ������������Ϊ����״̬ʱ����ֹ���ܵ��������˺���
	���ã�LuaFenyong��LuaFenyongClear
	״̬��1217��֤ͨ��
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
--[[����������ӡ
	����佫��ͭȸ̨������
	������������ɫ�ĻغϿ�ʼʱ�����䵱ǰ������ֵ�������٣�����Խ�����һ�š�ɱ����������������ƽ׶κ����ƽ׶Ρ�
	���ã�LuaFengyin
	״̬��1217��֤ͨ��
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
--[[���������������޶�����
	����佫�������������λ�
	���������㴦�ڱ���״̬ʱ������Խ������ظ���X�㣨XΪ�ִ�����������Ȼ������佫�Ʒ��档
	���ã�LuaFuli��LuaLaoji1
	״̬��1217��֤ͨ��
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
--[[������������
	����佫����ֽ����Ԫ��
	���������ƽ׶���һ�Σ�����δ�ڱ��׶�ʹ�ù���ɱ�������������������ͬ��ɫ���ƣ����㹥����Χ�ڵ�һ��������ɫ���佫�Ʒ��棬Ȼ���㲻��ʹ�á�ɱ��ֱ���غϽ�����
	���ã�LuaFuluan��LuaFuluanForbid
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���ǡ�����
	���������н�ɫƴ��ʱ������Դ��һ�ŵ���С��8�����ƣ�������һ����ɫ��ƴ���Ƽ��������Ƶ����Ķ���֮һ������ȡ����
	���ã�LuaFuzuo
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��һ������2012������&�Ű�
	����������Խ��������Ƶ���ͨ��ɱ��ʹ�û�����ÿ�����ڳ��ƽ׶����Դ˷�ʹ�á�ɱ������˺������ü��ܡ���ʥ��������������ֱ���غϽ�����
	���ã�LuaFuhun
	״̬��1217��֤ͨ��
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
--[[������������
	����佫������-һ��2����&��-��
	���������ƽ׶ο�ʼʱ������Է������ƣ���Ϊ���ƶѶ����������Ʋ����֮��������������ɫ��ͬ�����ü��ܡ���ʥ��������������ֱ���غϽ�����
	���ã�LuaNosFuhun
	״̬��1217��֤ͨ��
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
--[[G��]]--
-----------
--[[����������¶
	����佫��һ�����������̫
	���������ƽ׶���һ�Σ��������װ������װ�������������������ʧ����ֵ��������ɫ��������װ������װ���ơ���
	���ã�LuaGanlu
	״̬��1217��֤ͨ��
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
--[[����������Ⱦ����������
	����佫����ʬ����ʬ
	���������װ���ƶ���Ϊ����������
	���ã�LuaXGanran
	״̬��0405��֤ͨ��
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
--[[������������
	����佫������ͻ�ơ��ĺ
	������ÿ�����ܵ�1���˺�������Խ����ж��������Ϊ��ɫ������˺���Դ���1���˺�����ɫ���������˺���Դһ���ơ� 
	���ã�LuaGanglie
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����׼���ĺ
	������ÿ�����ܵ��˺�������Խ����ж����������Ϊ?�����˺���Դѡ��һ������������ƣ����ܵ�1���˺��� 
	���ã�LuaNosGanglie
	״̬��0405��֤ͨ��
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
--[[������������
	����佫��2013-3v3���ĺ
	������ ÿ�����ܵ��˺��������ѡ��һ���Է���ɫ������һ���ж������ж������Ϊ?����ý�ɫѡ��һ������������ƣ����ܵ�����ɵ�1���˺���
	���ã�LuaVsGanglie
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�����ĺ
	������ÿ�����ܵ�һ���˺�������Խ���һ���ж������ж������Ϊ���ң���ѡ��һ����˺���Դ�����������ƣ����ܵ��������ɵ�1���˺���
	���ã�LuaXNeoGanglie
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��һ������2012������
	���������ƽ׶���һ�Σ����������һ���ƣ������ڴ˻غ��ڹ�����Χ���ޣ������Դ˷����õ���Ϊװ���ƣ����������һ��������ɫ��һ���ơ�
	���ã�LuaGongqi
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�����ɡ�����
	����������Խ�һ��װ���Ƶ���ɱ��ʹ�û��������Դ˷�ʹ�õġ�ɱ���޾������ơ�
	���ã�LuaNosGongqi��LuaNosGongqiTargetMod
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�������ɣ��硤����
	���������ƽ׶���һ�Σ�����Թۿ�һ��������ɫ�����ƣ�Ȼ��ѡ������һ��?�Ʋ�ѡ��һ�����֮����֮�����ƶѶ���
	���ã�LuaGongxin
	״̬��0405��֤ͨ��
]]--
LuaGongxinCard = sgs.CreateSkillCard{
	name = "LuaGongxinCard" ,
	filter = function(self, targets, to_select)
		return #targets == 0 and to_select:objectName() ~= sgs.Self:objectName() --and not to_select:isKongcheng() �������ѡ��û�����ƵĽ�ɫ�ͼ�����һ�䣬Դ����û������
	end ,
	on_effect = function(self, effect)
		local room = effect.from:getRoom()
		if not effect.to:isKongcheng() then--���������������Ǿ䣬���Ͷ�Ӧ��end����ɾ��
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
--[[����������ı
	����佫�����졤��ʿ��
	�������غϽ����׶ο�ʼʱ�����ָ��һ��������ɫ���������ƽ׶����ƺ������X�����ƣ�XΪ����������Է��������Ľ�Сֵ����Ȼ������ѡ��X�����ƽ����Է�
	���ã�LuaXGongmou��LuaXGongmouExchange
	״̬��1217��֤ͨ��
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
--[[���������ƻ�
	����佫���硤�ڼ�
	����������Կ���һ�����Ƶ���һ�Ż����ƻ����ʱ������ʹ�û�����������ɫѡ���Ƿ����ɣ����޽�ɫ���ɣ���չʾ���ƣ�ȡ�����Ϸ���Ŀ�겢�����������ͽ��㣻���н�ɫ���ɣ���ֹ����ѯ�ʲ�չʾ���ƣ�������Ϊ�棬�ý�ɫ��á���Թ�������������㲻�����ɡ��ƻ󡱡����������ֵΪ1����������佫������Ч������ȡ�����Ϸ���Ŀ�겢�����������ͽ��㣻������Ϊ�٣��㽫���������ƶѡ�ÿ����ɫ�Ļغ���һ�Ρ� 
	���ã�guhuo_new
	״̬��0405��֤ͨ��(����ϱ��ֲ�Ĳ�Թһ��ʹ��)��֪�Ƿ������ص�����
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
        if string.find(pattern, "[%u%d]") then return false end--���Ǹ����䰹��ĺڿͣ��� ���������Ҫȥ��ֹ������ģʽ
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
--[[���������ƻ�
	����佫�����ɡ��ڼ�
	�����������˵��һ�Ż����ƻ����ʱ������Ƶ����ƣ������泯��ʹ�û���һ�����ơ�����������ɫ���ɣ����������Ʋ���������֮�ƽ��㡣����������ɫ������������������Ϊ�棬�����߸�ʧȥ1����������Ϊ�٣������߸���һ���ơ����Ǳ����ɵ���Ϊ������Ϊ�棬������Ȼ���н��㣬����������٣��������������ƶѡ�
	���ã�LuaNosguhuo
	״̬��1217��֤ͨ��	
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
--[[������������
	����佫���ǡ����
	�������غ��⣬����ʹ�û���һ�Ż�����ʱ��������һ����
	���ã�LuaXGushou
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��ɽ����������
	������������ɫ�����ƽ׶ν���ʱ������Խ��ý�ɫ�ڴ˽׶������õ�һ���ƴ����ƶѷ��������ƣ��������������Ի�����ƶ��������ڴ˽׶������õ��ơ�
	���ã�LuaGuzheng��LuaGuzhengGet
	״̬��1217��֤ͨ��
	��ע�����ַ�����ʽ���濨��id
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
					if card_data ~= "" then --���ƽ׶�û�������ַ���Ϊ""
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
--[[������������
	����佫����׼���������ɽ����ά��SP��̨�������
	������׼���׶ο�ʼʱ������Թۿ��ƶѶ���X���ƣ�Ȼ��������������������˳�������ƶѶ������������������˳�������ƶѵס���XΪ����ɫ��������Ϊ5����
	���ã�LuaGuanxing
	״̬��1217��֤ͨ��������ԭ�������޸�askForGuanxing��
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
--[[������������������������������
	����佫��SP�����
	������������������ɫ����Ļغ�����Ϊ�����˵Ľ�ɫ�� 
	���ã�LuaGuiming
	״̬��Lua�޷�ʵ�֣����Կ���д�ڲ�ʴ��
]]--
--[[���������麺
	����佫�����졤���Ѽ�
	���������ƽ׶Σ��������������������ͬ��ɫ�ĺ�ɫ���ƣ�����ָ����һ����������ɫ����λ�á�ÿ�׶���һ��
	���ã�LuaGuihan
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���񡤲ܲ�
	������ÿ�����ܵ�1���˺�����������λ������������ɫ�����ڵ�һ���ƣ�Ȼ���佫�Ʒ��档 
	���ã�LuaGuixin
	״̬��0405��֤ͨ��
]]--
LuaGuixin = sgs.CreateMasochismSkill{
	name = "LuaGuixin" ,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		local n = player:getMark("LuaGuixinTimes")--������Ϊ��ai
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
--[[������������
	����佫�����졤κ���
	�������غϽ����׶Σ�����������¶�ѡһ��\
	  1. ���øı�һ��������ɫ������\
	  2. ���û��һ��δ�ϳ�����������ɫ����������(��ú�ʹ�㲻��������Ȼ��Ч)"
	���ã�LuaXWeiwudiGuixin
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���ơ��ӷ���
	������ÿ����ʧȥ�����㡱������Իظ�1���������޶�����׼���׶ο�ʼʱ����ƽ׶Σ�������������ơ� 
	���ã�LuaGuixiu��LuaGuixiuDetach
	״̬��1217��֤ͨ��
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
--[[�����������
	����佫������ͻ�ơ�˾��ܲ
	������ÿ��һ����ɫ���ж�����Чǰ������Դ��һ���ƴ���֮�� 
	���ã�LuaGuicai
	״̬��0405��֤ͨ��
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
--[[�����������
	����佫����׼��˾��ܲ
	������ÿ��һ����ɫ���ж�����Чǰ������Դ��һ�����ƴ���֮��
	���ã�LuaNosGuicai
	״̬��0405��֤ͨ��
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
--[[�����������
	����佫���硤�Žǡ��ɷ硤�Ž�
	������ÿ��һ����ɫ���ж�����Чǰ������Դ��һ�ź�ɫ���滻֮��
	���ã�LuaGuidao
	״̬��0405��֤ͨ��
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
--[[����������ɫ
	����佫����׼�����ǡ�SP��̨����ǡ�SP����ս����
	����������Խ�һ�ŷ����Ƶ����ֲ�˼��ʹ�á�
	���ã�LuaGuose
	״̬��1217��֤ͨ��
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
--[[H��]]--
-----------
--[[����������ͳ
	����佫����ֽ����Э
	���������ƽ׶Σ�����Խ������õ����������佫���ϣ���Ϊ��گ��������Խ�һ�š�گ���������ƶѣ�Ȼ����ӵ�в��������¼���֮һ�������ݡ�����������������Ԯ������Ѫ�ᡱ��ֱ����ǰ�غϽ�����
	���ã�LuaXHantong��LuaXHantongDetach
	״̬��1217��֤ͨ��
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
--[[����������ʩ
	����佫���֡�³��
	���������ƽ׶Σ�����Զ����������ƣ�����ʱ������ƶ������ţ���һ�루����ȡ���������ƽ���ȫ�����������ٵ�һ��������ɫ��
	���ã�LuaHaoshiGive��LuaHaoshi��LuaHaoshiVS
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���󡤲ܺ�
	�������غϽ���ʱ�������ѡ����������ڵ��������������Ľ�ɫ����Щ��ɫ�������⣩ӵ�С���Ӱ����ֱ������¸��غϽ���ʱ�� 
	���ã�LuaHeyi
	״̬��1217��֤ͨ��
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
--[[���������Ὥ
	����佫���ơ�갰�
	������ÿ�����ܵ�1���˺���������ǰ�غϽ�ɫ���غ���������-1��Ȼ����غϽ���ʱ�������ڴ˻غϷ��������Ὥ��������δ�����ƽ׶��������ƣ�����һ���ơ� 
	���ã�LuaHengjiang,LuaHengjiangDraw,LuaHengjiangMaxcards
	״̬��1217��֤ͨ��	
	DB:Ч��������������Դ��һ�£�����ʼ�վ��������⡣����д����ô�����������ӻ�ûת��������������
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
--[[����������Ԯ
	����佫����3V3������
	���������ƽ׶Σ����������һ���ƣ�������������ɫ����һ���ơ�
	���ã�LuaXHongyuan��LuaXHongyuanAct
	״̬��1217��֤ͨ��
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
--[[����������Ԯ
	����佫����3V3�����誣���ݾ֣�
	���������ƽ׶Σ����������һ���ƣ���һ������������ɫ����һ���ơ�
	���ã�LuaHongyuan��LuaHongyuanAct
	״̬��1217��֤ͨ��
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
--[[�����������գ���������
	����佫���硤С�ǡ�SP����սС��
	��������ĺ����ƾ���Ϊ�����ơ�
	���ã�LuaHongyan
	״̬��1217��֤ͨ��
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
--[[����������Ԯ
	����佫���ǡ�����
	���������ƽ׶Σ�����������������ƣ�ָ��һ��������ɫ�������ƣ�ÿ�׶���һ��
	���ã�LuaHouyuan
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�����졤���Ѽ�
	�������غϽ����׶ο�ʼʱ������Խ����ж�����Ϊ��ɫ��������ô��ƣ����������ֱ�����ֺ�ɫΪֹ����������3�κ��佫����
	���ã�LuaCaizhaojiHujia
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��1v1������1v1
	��������ǳ�ʱ���������Ϊʹ��һ�š�ˮ���߾�����
	״̬��1217��֤ͨ��
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
--[[����������Х
	����佫��SP��������
	������ÿ�����ڳ��ƽ׶�ʹ�á�ɱ���������������󣬱��׶�����Զ���ʹ��һ�š�ɱ���� 
	���ã�LuaHuxiaoCount��LuaHuxiao��LuaHuxiaoClear
	״̬��0405��֤ͨ��
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
--[[�����������ݣ���������
	����佫����׼���ܲ١�ͭȸ̨���ܲ�
	������������Ҫʹ�û���һ�š�����ʱ�������������κ������ɫ���һ�š���������Ϊ����ʹ�û�������
	���ã�LuaHujia
	״̬��1217��֤ͨ��
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
--[[����������Ԯ
	����佫���󡤲ܺ�
	�����������׶ο�ʼʱ������Խ�һ��װ��������һ����ɫװ�����ڣ�Ȼ�������øý�ɫ����1��һ����ɫ�����ڵ�һ���ơ� 
	״̬��1217��֤ͨ��
	ע����Xusine1131(���־�)������Ӧ�����Լ������ơ���
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
--[[������������
	����佫��ɽ�����
	�����������˶�չʾ�佫�ƺ�������������δ������Ϸ���佫�ƣ���Ϊ�������ơ���ѡһ����������ǰ���������佫��һ��ܣ����øü�����ͬʱ���Ա���������Ա������佫��ֱͬ���������ơ����滻�������ÿ���غϿ�ʼʱ�ͽ�����������滻�������ơ���Ȼ�������Ƿ��滻����Ϊ��ǰ�ġ������ơ�����һ��ܣ��㲻���������޶��������Ѽ�������������
	���ã�LuaHuashen LuaHuashenDetach
	״̬��1217��֤ͨ����Դ�빦����ȫʵ�֣�
	��ע��Xusine����ν�����־�1131561728�����������ʹ����JsonForLua�Ŀ⣬�뽫json.lua������ϷĿ¼���߷���lua\lib
]]--
local json = require ("json")
function isNormalGameMode (mode_name)
	return mode_name:endsWith("p") or mode_name:endsWith("pd") or mode_name:endsWith("pz")
end
function GetAvailableGenerals(zuoci) ----��ȫ����Դ��д�ģ������ˡ���
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
		--Json�󷨺� ^_^
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
		----Json�����ͷ���һ��Ӣ�ˣ�
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
--[[������������
	����佫����3V3������
	��������һ��������ɫ���ж�����Чǰ������Դ��һ���ƴ���֮��
	���ã�LuaXHuanshi
	״̬:1217��֤ͨ��
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
--[[������������
	����佫����3V3�����誣���ݾ֣�
	������ÿ��һ����ɫ���ж�����Чǰ���������ý�ɫ�ۿ�������ƣ�Ȼ��ý�ɫѡ��һ���ƣ��������ƴ���֮��
	���ã�LuaXHuanshi
	״̬��1217��֤ͨ��
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
--[[���������ʶ�
	����佫����ֽ����Э
	������ÿ��һ�Ž�����ָ���˲���������Ŀ��ʱ����������Ϊ����Ŀ�������X����ɫ����һ���ƣ���ý����ƶ���Щ��ɫ��Ч����XΪ�㵱ǰ����ֵ��
	���ã�LuaXHuangen
	״̬��1217��֤ͨ��
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
--[[�����������죨��������
	����佫���硤�Ž�
	���������ƽ׶���һ�Σ�����Ⱥ�۽�ɫ�ĳ��ƽ׶Σ��ý�ɫ���Խ�����һ�š����������硿��
	���ã�LuaHuangtian��LuaHuangtianVS�����ܰ�����
	״̬��1217��֤ͨ��
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
--[[�����������ᣨ��������
	����佫��һ������������
	������������ʱ��ɱ�����������ɫ�����������ơ� 
	���ã�LuaHuilei
	״̬��0405��֤ͨ��
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
--[[�����������
	����佫���������
	����������Խ�һ�ź�ɫ���Ƶ����𹥡�ʹ�á�
	���ã�LuaHuoji
	״̬��1217��֤ͨ��
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
--[[�����������ף���������
	����佫���֡��ϻ�
	���������������֡�������Ч����������ɫʹ�á��������֡�ָ��Ŀ������Ǹá��������֡�����˺�����Դ��
	���ã�LuaHuoshou��LuaSavageAssaultAvoid
	״̬��1217��֤ͨ��
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
--[[����������ˮ����������
	����佫����ս������
	��������Ļغ��ڣ�����ֵ��������������һ���������ɫ�����佫������Ч��
	���ã�LuaHuoshui
	״̬��1217��֤ͨ���������Բ��ò����ʱ�򻹻���Bug����
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
			for _,p in sgs.qlist(room:getAlivePlayers())do --�����¼�mark֮ǰ��ȫ������������
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
	�����������ף���������
	����佫���֡��ϻ�
	���������������֡�������Ч����������ɫʹ�á��������֡�ָ��Ŀ������Ǹá��������֡�����˺�����Դ��
]]--
-----------
--[[I��]]--
-----------
-----------
--[[J��]]--
-----------
--[[������������
	����佫��SP������
	������ÿ�����ܵ��˺��������ѡ��һ���Ƶ�����˺���Դ����ʹ�á��������������������ƣ�ֱ���غϽ����� 
	���ã�LuaJilei��LuaJileiClear
	״̬��0405��֤ͨ��
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
			local _type = choice.."|.|.|hand" --ֻ������
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
--[[������������
	����佫��ɽ����ߣ���SP������
	������ÿ����ָ�����Ϊ��ɫ��ɱ���򡾾�������Ŀ����������һ���ơ� 
	���ã�LuaJiang
	״̬��0405��֤ͨ��
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
--[[����������������������
	����佫����׼��������ɽ������������-��׼������-��
	������������Ҫʹ�û���һ�š�ɱ��ʱ���������������������ɫ���һ�š�ɱ������Ϊ����ʹ�û�������
	���ã�LuaJijiang
	״̬��1217��֤ͨ��
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
	on_validate = function(self, cardUse) --����0610�¼ӵ�Ŷ~~~~
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
			slash = room:askForCard(liege, "slash", "@jijiang-slash:" .. liubei:objectName(), sgs.QVariant(), sgs.Card_MethodResponse, liubei) --δ������
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
--[[������������
	����佫����˾��ܲ
	�������������һö���̡����������¼���֮һ������š��������𡱡������ǡ������ƺ⡱������ɱ����   
	���ã�LuaJilve��LuaJilveClear
	״̬��0405��֤ͨ��
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
LuaJilveVS = sgs.CreateZeroCardViewAsSkill{--��ɱ���ƺ�
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
	events = {sgs.CardUsed, sgs.AskForRetrial, sgs.Damaged},--�ֱ�Ϊ���ǡ���š�����
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
--[[������������
	����佫����׼����٢
	��������Ļغ��⣬����Խ�һ�ź�ɫ�Ƶ����ҡ�ʹ�á�
	���ã�LuaJijiu
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�����ˡ�Ҷʫ��
	�����������������˻غϵ��ж��׶κ����ƽ׶Ρ������������Ϊ��һ��������ɫʹ��һ�š�ɱ����
	���ã�LuaXJisu
	״̬��1217��֤ͨ��
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
--[[����������Ϯ
	����佫��ɽ���˰�
	����������Խ�һ�š������˳��ǣ��ʹ�á�
	���ã�LuaJixi
	״̬��0405��֤ͨ��(���뼼�ܡ�������ʹ��)
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
--[[������������
	����佫����׼������Ӣ
	������ÿ����ʹ�ý�����ѡ��Ŀ��������չʾ�ƶѶ���һ���ơ�������Ϊ�����ƣ���ѡ��һ�1.��֮�������ƶѣ�2.��һ�������滻֮�������Ʋ�Ϊ�����ƣ�����֮��
	���ã�LuaJizhi
	״̬��1217��֤ͨ��
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
	������������
	����佫������-��׼������Ӣ-�ɡ�1v1������Ӣ1v1��SP��̨�����Ӣ
	������ÿ����ʹ�÷���ʱ�������ѡ��Ŀ����������һ���ơ�
	���ã�LuaNosJizhi
	״̬��0405��֤ͨ��
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
--[[��������������������
	����佫����SP���ŷ�
	��������ʹ�õĺ�ɫ��ɱ����ɵ��˺�+1��
	���ã�LuaJie
	״̬��1217��֤ͨ��
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
--[[������������
	����佫������ͻ�ơ��ܲ�
	������ÿ�����ܵ��˺��������ѡ��һ���ö�������˺����ƣ�����һ���ơ� 
	���ã�LuaJianxiong
	״̬��0405��֤ͨ��
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
--[[������������
	����佫����׼���ܲ١�ͭȸ̨���ܲ�
	������ÿ�����ܵ��˺�������Ի�ö�������˺����ơ� 
	���ã�LuaNosJianxiong
	״̬��0405��֤ͨ��
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
--[[������������
	����佫�����ԡ��׿Ӳ���
	�������غϽ����׶ο�ʼʱ��������������ƣ�Ȼ������佫�Ʒ���
	���ã�LuaXJianshou
	״̬��1217��֤ͨ��
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
--[[������������
	����佫����������������
	���������ƽ׶Σ������ѡ��һ�1��������һ���ƣ�����������㲻��ʹ�û�����ɱ����ֱ���غϽ�����2������һ���ƣ�������������ƽ׶���ʹ�á�ɱ��ʱ�޾�������������Զ���ʹ��һ�š�ɱ����ֱ���غϽ�����
	���ã�LuaJiangchi��LuaJiangchiTargetMod
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��������
	������ÿ�����ܵ�1���˺����������һ����ɫ�����Ʋ���X�ţ�XΪ�ý�ɫ����������������Ϊ5����
	���ã�LuaJieming
	״̬��1217��֤ͨ��
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
--[[������������
	����佫������ͻ�ơ������㡢��׼�������㡢SP��������
	���������ƽ׶���һ�Σ�����������������Ʋ�ѡ��һ�������˵����Խ�ɫ����͸ý�ɫ���ظ�1��������
	���ã�LuaJieyin
	״̬��0405��֤ͨ��
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
--[[����������Ե
	����佫��ͭȸ̨�����¡�SP������
	������ÿ�����һ��������ɫ����˺�ʱ����������ֵ���ڻ�����������ֵ�����������һ�ź�ɫ���ƣ�������������˺�+1��ÿ�����ܵ�һ��������ɫ��ɵ��˺�ʱ����������ֵ���ڻ�����������ֵ�����������һ�ź�ɫ���ƣ�������������˺�-1�� 
	���ã�LuaJieyuan
	״̬��0405��֤ͨ��
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
--[[���������ⷳ���޶�����
	����佫����������������
	���������ƽ׶Σ������ָ��һ����ɫ��������Χ�ں��иý�ɫ�����н�ɫ������ѡ��һ�����һ�������ƣ�����ý�ɫ��һ���ơ�
	���ã�LuaJiefan
	״̬��1217��֤ͨ��
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
--[[���������ⷳ
	����佫�����ɡ�����
	��������Ļغ��⣬��һ����ɫ���ڱ���״̬ʱ������ԶԵ�ǰ�����лغϵĽ�ɫʹ��һ�š�ɱ�����޾������ƣ����ˡ�ɱ������˺�ʱ�����ֹ���˺�����Ϊ�Ըñ�����ɫʹ��һ�š��ҡ���
	���ã�LuaNosJiefan
	״̬��1217��֤ͨ��
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
--[[����������󣨾��Ѽ���
	����佫���ǡ�˾���
	���������㷢������ҵ��Ŀ���ۼƳ���6��ʱ�����ȥһ���������ޣ������ܡ���ҵ����Ϊÿ�׶���һ�Σ�����ü��ܡ�ʦ����
	���ã�LuaJiehuo
	״̬��1217��֤ͨ��
	ע����ˮ�����������ܾ�����ϵ��Ϊ�˷������ͳһʹ�ñ�LUA�汾�ļ��ܣ�����ԭ��
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
--[[����������Χ
	����佫���硤����
	������ÿ������佫�Ʒ�����������һ���ƣ�Ȼ�������ʹ��һ�Ž����ƻ�װ���ƣ�������������ƽ������������ó���һ��ͬ���͵��ơ�
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���ǡ�����
	��������������ʱ������һ����ɫ��ȡ��������������
	���ã�LuaXJincui
	״̬��1217��֤ͨ��
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
--[[�����������ƣ���������
	����佫��һ����������˳
	��������ġ��ơ�����Ϊ��ɱ����
	���ã�LuaJinjiu
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��һ������2013������
	���������ƽ׶ν���ʱ�����㱾�غ���ʹ�õ��������ڻ�����㵱ǰ������ֵ��������������ơ�
	���ã�LuaJingce
	״̬��1217��֤ͨ��
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
--[[���������Ƴ�
	����佫���֡���׿
	����������Խ�һ�ź������Ƶ����ơ�ʹ�á�
	���ã�LuaJiuchi
	״̬��1217��֤ͨ��
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
--[[����������ʫ
	����佫��һ����������ֲ
	������������佫�����泯�ϣ�����Խ�����佫�Ʒ��棬��Ϊʹ��һ�š��ơ���������佫�Ʊ��泯��ʱ���ܵ��˺�����������˺����������佫�Ʒ�ת�����泯�ϡ�
	���ã�LuaJiushi
	״̬��1217��֤ͨ��
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
--[[����������Ԯ������������������
	����佫����׼����Ȩ�����ԡ��ư���Ȩ
	������������������ɫʹ�õġ��ҡ�ָ����ΪĿ��󣬻ظ�������+1��
	���ã�LuaJiuyuan
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��2013-3v3������
	������ÿ��һ������������ɫ���ڱ���״̬ʱ�����������ֵ����1�������ʧȥ1������������һ���ƣ���ý�ɫ�ظ�1��������
	���ã�LuaJiuzhu
	״̬��1217��֤ͨ��(2013-3v3ģʽ)
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
--[[���������ټ�
	����佫��һ������������
	�������غϽ����׶ο�ʼʱ�����������һ�ŷǻ����ƣ���һ��������ɫѡ��һ��������ƣ���ظ�1�������������佫�Ʒ������泯�ϲ�����֮��
	���ã�LuaJujian
	״̬��1217��֤ͨ��
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
--[[���������ټ�
	����佫�����ɡ�����
	���������ƽ׶Σ�������������������ƣ�Ȼ����һ��������ɫ���������ơ������Դ˷���������ͬһ�����ƣ���ظ�1��������ÿ�׶���һ�Ρ�
	���ã�LuaNosJujian
	״̬��1217��֤ͨ��
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
--[[��������������������
	����佫���֡�ף��
	���������������֡�������Ч����������ɫʹ�õġ��������֡��ڽ�����������ƶ�ʱ������֮��
	���ã�LuaSavageAssaultAvoid�������һ�£�ע���ظ����ܣ���LuaJuxiang
	״̬��1217��֤ͨ��
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
--[[���������ư�
	����佫���ǡ�����
	���������ƽ׶Σ������ѡ���������Ʊ��������Ƴ���Ϸ��ָ��һ����ɫ����ָ���Ľ�ɫ���¸��غϿ�ʼ�׶�ʱ���������ƽ׶Σ��õ������Ƴ���Ϸ�������ơ�ÿ�׶���һ��
	���ã�LuaJuao
	״̬��1217��֤ͨ��
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
--[[������������
	����佫���硤����
	�����������׶ο�ʼʱ���������һ���ƣ�Ȼ������佫�Ʒ��档
	���ã�LuaJushou
	״̬��1217��֤ͨ��
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
--[[�����������ء���
	����佫�����ɡ�����
	�����������׶ο�ʼʱ��������������ƣ�Ȼ������佫�Ʒ��档
	���ã�LuaJushou
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��������
	�������غϽ����׶ο�ʼʱ���������2+X���ƣ�XΪ������ʧ������ֵ����Ȼ������佫�Ʒ��档
	���ã�LuaXNeoJushou
	״̬��1217��֤ͨ��
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
--[[������������
	����佫��һ������2013������
	��������Ļغ��ڣ�һ������ֵ����0�Ľ�ɫʧȥ�������ƺ�����Զ������1���˺���
	���ã�LuaJuece
	״̬��1217��֤ͨ��
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
--[[������������
	����佫�����졤�Ńy�V
	���������ƽ׶Σ�����Ժ�һ����ɫƴ�㣺����Ӯ�����öԷ���ƴ���ƣ����������ٴ�����ƴ�㣬��˷�����ֱ����ûӮ��Ը�����ƴ��Ϊֹ��ÿ�׶���һ�Ρ�
	���ã�LuaXJueji
	״̬��1217��֤ͨ��
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
--[[����������������������
	����佫��������
	���������ƽ׶Σ��������X���ơ������������+2����XΪ������ʧ������ֵ�� 
	���ã�LuaJuejing��LuaJuejingDraw
	״̬��0405��֤ͨ��
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
--[[����������������������
	����佫�����ԡ��ߴ�һ��
	���������ƽ׶Σ��㲻���ơ�ÿ������������仯���������������Ϊ4�����뽫���Ʋ��������������š�
	���ã�LuaXNosJuejing
	״̬��1217��֤ͨ��
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
--[[�����������飨��������
	����佫��һ���������Ŵ��������ɡ��Ŵ���
	�������㼴����ɵ��˺�����Ϊʧȥ������
	���ã�LuaJueqing
	״̬��1217��֤ͨ��
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
--[[������������
	����佫����SP������
	�����������׶ο�ʼʱ������Խ����š������������ƶѲ�ѡ��һ����ɫ����ý�ɫѡ��һ�1.չʾһ�š����������á�������������ѡ���һ����ɫ��2.ʧȥ1��������Ȼ���㽫��װ������һ�����Ƴ���Ϸ���ý�ɫ���¸��غϽ����󣬽�����װ�����ƻ���װ������
	���ã�LuaJunwei,LuaJunweiGot
	״̬��1217��֤ͨ��(���뼼�ܡ����塱���ʹ��)
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
--[[������������
	����佫��һ������2013������
	���������ƽ׶���һ�Σ��������������һ�����Ʋ�ѡ��һ��������ɫ���ý�ɫ������һ���������õ������;���ͬ�����ƣ��������佫�Ʒ��沢��X���ơ���XΪ�����õ��Ƶ�������
	���ã�LuaJunxing
	״̬��1217��֤ͨ��
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
	����������������������
	����佫��������
	���������ƽ׶Σ������Ƶ�������Ϊ������ʧ������ֵ+2�������������+2��
]]--
-----------
--[[K��]]--
-----------
--[[
	������������
	����佫���������
	����������Խ�һ�ź�ɫ���Ƶ�����и�ɻ���ʹ�á�
	���ã�LuaKanpo
	״̬��1217��֤ͨ��
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
	������������
	����佫��SP���ܰ�
	������ÿ��һ������1���ڵĽ�ɫ��Ϊ��ɱ����Ŀ����������һ���ƣ�Ȼ�����泯�Ͻ����ý�ɫһ���ƣ�������Ϊװ���ƣ��ý�ɫ����ʹ��֮�� 
	���ã�LuaKangkai
	״̬��1217��֤ͨ��
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
	���������˹������Ѽ���
	����佫�����졤½��
	�������غϿ�ʼ�׶ο�ʼʱ�������ǳ�������Ψһ����������ɫ���������1���������޲���ü��ܡ���Ӫ��
	���ã�LuaKegou
	״̬��1217��֤ͨ��
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
	���������˼�
	����佫����׼�����ɡ�����ͻ�ơ����ɡ���SP������
	����������δ�ڳ��ƽ׶���ʹ�û�����ɱ����������������ƽ׶Ρ� 
	���ã�LuaKeji
	״̬��0405��֤ͨ��
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
	���������ճǣ���������
	����佫����׼������������ԡ��������
	����������û�����ƣ��㲻�ܱ�ѡ��Ϊ��ɱ���򡾾�������Ŀ�ꡣ
	���ã�LuaKongcheng
	״̬��1217��֤ͨ��
]]--
LuaKongcheng = sgs.CreateProhibitSkill{
	name = "LuaKongcheng",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("Slash") or card:isKindOf("Duel")) and to:isKongcheng()
	end
}
--[[
	������������
	����佫������ͻ�ơ��Ƹ�
	���������ƽ׶���һ�Σ����������һ���ƣ������������ʧȥ1�������� 
	���ã�LuaKurou
	״̬��0405��֤ͨ��
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
	������������
	����佫����׼���Ƹǡ�SP��̨��Ƹ�
	���������ƽ׶Σ������ʧȥ1��������������������������ơ�
	���ã�LuaNosKurou
	״̬��0405��֤ͨ��
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
	���������񱩣���������
	����佫��������
	��������Ϸ��ʼʱ��������ö����ŭ����ǡ�ÿ������ɻ��ܵ�1���˺�������һö����ŭ����ǡ� 
	���ã�LuaKuangbao
	״̬��0405��֤ͨ��
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
	�����������
	����佫���������
	�����������׶ο�ʼʱ������Խ�һ�š��ǡ��������ƶѲ�ѡ��һ����ɫ���������������»غϿ�ʼǰ��ÿ�����ܵ��Ļ����˺����㿪ʼʱ�����˺�+1��
	���ã�LuaKuangfeng
	״̬��0405��֤ͨ��(���뱾�ֲ�ļ��ܡ����ǡ����ʹ��)
	��ע��ҽ������&ˮ��wch�磺Դ��Ŀ��ʹ���ļ���ѯ�����ǵ�����ֱ�λ�����ǵ�QixingAsk��QixingClear�У��˼��ܶ��������ˡ����뱾�ֲ�ļ��ܡ����ǡ����ʹ��
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
	����������
	����佫����ս���˷�
	������ÿ����ʹ�õġ�ɱ����һ����ɫ���һ���˺�������Խ���װ�������һ�������û��������װ������
	���ã�LuaKuangfu
	״̬��1217��֤ͨ��
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
	����������ǣ���������
	����佫���硤κ��
	������ÿ����Ծ���1���ڵ�һ����ɫ���1���˺�����ظ�1��������
	���ã�LuaKuanggu
	״̬��1217��֤ͨ��
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
	����������ǡ�1V1
	����佫��1v1��κ��
	������ÿ��������˺�������Խ����ж��������Ϊ��ɫ����ظ�1��������
	���ã�LuaKOFKuanggu
	״̬��1217��֤ͨ��
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
	����������Χ
	����佫����SP������
	�����������׶ο�ʼʱ���������X+2���ƣ�Ȼ������佫�Ʒ��棬������¸����ƽ׶ο�ʼʱ��������X���ơ���XΪ��ǰ���������Ƶ�������
	���ã�LuaKuiwei
	״̬��1217��֤ͨ��
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
	����������ǣ���������
	����佫���硤κ��
	������ÿ����Ծ���1���ڵ�һ����ɫ���1���˺�����ظ�1��������
]]--
-----------
--[[L��]]--
-----------
--[[
	���������ǹ�
	����佫����ֽ��˾����
	������ÿ�����ܵ�1���˺�������Խ���һ���ж���Ȼ������Դ��һ�����ƴ�����ж��ƣ������������ۿ��˺���Դ���������ƣ������������������������ж��ƻ�ɫ��ͬ���ơ�
	���ã�LuaXLanggu
	״̬��1217��֤ͨ��
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
	����������ѧ
	����佫�����졤����Լ
	���������ƽ׶Σ�����һ�������Ƶ�������ɫչʾһ�����ƣ���Ϊ�����ƻ����ʱ���ң�����ɽ������ͬ��ɫ���Ƶ�������ʹ�û���ֱ���غϽ�������Ϊ�����ƣ������̱����á�ÿ�׶���һ��
	���ã�LuaXLexue
	״̬��1217��֤ͨ��
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
	���������׻�
	����佫���硤�Ž�
	������ÿ����ʹ�á�����ѡ��Ŀ���������������������һ����ɫ����һ���ж������ж����Ϊ��ɫ����Ըý�ɫ���1���׵��˺���Ȼ����ظ�1�������� 
	���ã�LuaLeiji
	״̬��1217��֤ͨ��
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
	���������׻�
	����佫�����ɡ��Ž�
	����������ʹ�û���һ�š���������Ϊʹ������ѡ��Ŀ��󣩣��������һ����ɫ����һ���ж������ж����Ϊ���ң���Ըý�ɫ���2���׵��˺���
	���ã�LuaLeiji
	״̬��1217��֤ͨ��
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
	�����������
	����佫����SP������
	���������ƽ׶���һ�Σ����������һ���ƽ��佫�Ʒ��棬Ȼ����һ�����Խ�ɫ���������ƣ��ҳ��ƽ׶ν���ʱ���㽻���ý�ɫX���ơ���XΪ�ý�ɫ������ֵ��
	���ã�LuaLihun
	״̬��1217��֤ͨ��
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
	�����������
	����佫����׼������
	���������ƽ׶���һ�Σ����������һ���Ʋ�ѡ���������Խ�ɫ�������������Ϊ����һ����ɫ����һ����ɫʹ��һ�š��������� 
	���ã�LuaLijian
	״̬��0405��֤ͨ��
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
		duel:toTrick():setCancelable(true)-- ����true��Ϊfalse ���Ǿɰ漼��
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
	�����������
	����佫������-��׼������-�ɡ�SP��������SP��̨������
	���������ƽ׶���һ�Σ����������һ���Ʋ�ѡ���������Խ�ɫ�������������Ϊ����һ����ɫ����һ����ɫʹ��һ�š����������ˡ����������ܱ�����и�ɻ�����Ӧ�� 
	���ã�LuaLijian
	״̬��0405��֤ͨ��
	ע�����轫�°����� "duel:toTrick():setCancelable(true)" ��һ�иĵ�����
]]--
--[[
	����������Ǩ����������
	����佫�����졤�ĺ��
	���������㴦������״̬ʱ����������������������ͬ�����㴦��δ����״̬ʱ������Ϊκ
	����:LuaLiqian
	״̬��1217��֤ͨ��(���ܵ�ʵ�ֱ�����ڱ��ֲ�ļ��ܡ������У�����ֻ�ǿտǣ���һ�����ܰ�ť����)
]]--
LuaLiqian = sgs.CreateTriggerSkill{
	name = "LuaLiqian",
	frequency = sgs.Skill_Compulsory,
	events = {},
	on_trigger = function()	end
}
--[[
	������������
	����佫����ս������
	������������������ö��������ƶ�ʱ������Խ�������������������������䷽ʽ��������������������ɫ��
	���ã�LuaXLirang
	״̬��1217��֤ͨ��
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
	���������ݻ�
	����佫����������������
	����������Խ�һ����ͨ��ɱ������ɱ��ʹ�ã����Դ˷�ʹ�õġ�ɱ��������˺����ڴˡ�ɱ���������ʧȥ1����������ʹ�û�ɱ��ʱ�����Զ���ѡ��һ��Ŀ�ꡣ
	���ã�LuaLihuo��LuaLihuoTarget
	״̬��1217��֤ͨ��
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
	������������
	����佫������ͳ
	����������Խ�һ��÷�����Ƶ�������������ʹ�û�������
	���ã�LuaLianhuan
	״̬��1217��֤ͨ��
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
	������������
	����佫�����졤�ĺ��
	�������غϿ�ʼ�׶ο�ʼʱ�������ѡ��һ�����Խ�ɫ��������������״ֱ̬������»غϿ�ʼ���ý�ɫ���԰������������԰����ɱ
	���ã�LuaLianStart,LuaLianliSlash,LuaLianliJink,LuaLianliClear,LuaLianli,LuaLianlivs(���ܰ���������뼼�ܿ�)
	״̬��1217��֤ͨ��
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
	������������
	����佫����˾��ܲ
	������ÿ��һ����ɫ�ĻغϽ����������ڱ��غ�ɱ������һ����ɫ������Խ���һ������Ļغϡ�   
	���ã�LuaLianpoCount��LuaLianpo
	״̬��0405��֤ͨ��
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
	����������Ӫ
	����佫������ͻ�ơ�½ѷ
	������ÿ����ʧȥ�������ƺ������������X����ɫ����һ���ơ���XΪ��ʧȥ���������� 
	���ã�LuaLianying
	״̬��0405��֤ͨ��
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
	����������Ӫ
	����佫����׼��½ѷ��SP��̨��½ѷ�����졤½��
	������ÿ����ʧȥ�������ƺ��������һ���ơ�
	���ã�LuaNosLianying
	״̬��0405��֤ͨ��
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
	���������ҹ�
	����佫���硤����
	�����������ڳ��ƽ׶���ʹ�á�ɱ��ָ��һ����ɫΪĿ������������������������䲻����ʹ�á������Դˡ�ɱ��������Ӧ��
		1.Ŀ���ɫ�����������ڻ�����������ֵ��2.Ŀ���ɫ��������С�ڻ������Ĺ�����Χ��
	���ã�LuaLiegong
	״̬��1217��֤ͨ��
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
	���������ҹ�
	����佫��1v1������1v1
	������ÿ�����ڳ��ƽ׶���ʹ�á�ɱ��ָ������ΪĿ��������ֵ����������ڻ�����������ֵ���������ý�ɫ����ʹ�á������Դˡ�ɱ��������Ӧ��
	���ã�LuaKOFLiegong
	״̬��1217��֤ͨ��
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
	������������
	����佫����ף�ڡ�1v1��ף��1v1
	������ÿ����ʹ�á�ɱ����Ŀ���ɫ����˺����������ý�ɫƴ�㣺����Ӯ��������һ���ơ� 
	���ã�LuaLieren
	״̬��0405��֤ͨ��
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
	����������Χ
	����佫��1v1��ţ��
	������ÿ����ɱ�����ֺ�������������ơ� 
	���ã�LuaLiewei
	״̬��1217��֤ͨ��
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
	������������
	����佫����׼�����ǡ�SP��̨����ǡ�SP����ս����
	�����������Ϊ��ɱ����Ŀ��ʱ�����������һ���ƣ����ˡ�ɱ��ת�Ƹ��㹥����Χ�ڵ�һ��������ɫ���ˡ�ɱ����ʹ���߳��⣩��
	���ã�LuaLiuli
	״̬��1217��֤ͨ��	
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
	������������
	����佫����׼�����ơ���SP�����ơ������ơ�2013-3v3�����ơ�SP��̨������
	����������Խ�һ�š�ɱ������������һ�š���������ɱ��ʹ�û�����
	���ã�LuaLongdan
	״̬��1217��֤ͨ��
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
	������������
	����佫��������
	����������Խ�X��ͬ��ɫ���ư����¹���ʹ�û��������ҵ����ҡ������鵱��ɱ�������ҵ�����и�ɻ�����÷��������������XΪ�������ֵ������Ϊ1�� 
	���ã�LuaLonghun
	״̬��0405��֤ͨ��
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
	������������
	����佫�����ԡ��ߴ�һ��
	����������Խ�һ���ư����¹���ʹ�û�����?�����ҡ���?����ɱ����?������и�ɻ�����?�����������غϿ�ʼ�׶ο�ʼʱ����������ɫ��װ�������С����G����������Ի��֮��
	���ã�LuaXNosLonghun��LuaXDuojian
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ������2013����ƽ
	������ÿ��һ����ɫ������ƽ׶���ʹ�á�ɱ��ѡ��Ŀ������������һ���ƣ���ˡ�ɱ����������ƽ׶����Ƶ�ʹ�ô��������ˡ�ɱ��Ϊ��ɫ������һ���ơ�
	���ã�LuaLongyin
	״̬��1217��֤ͨ��
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
	������������
	����佫���ǡ�����
	�������غϽ����׶ο�ʼʱ�������ѡ��һ��������ɫ��ȡ�������ƽ׶�����������ͬ����
	���ã�LuaLongluo
	״̬��1217��֤ͨ��
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
	���������һ�
	����佫����Ԭ��
	����������Խ����Ż�ɫ��ͬ�����Ƶ�������뷢��ʹ�á�
	���ã�LuaLuanji
	״̬��1217��֤ͨ��
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
	�����������䣨�޶�����
	����佫���֡���ڼ��SP����ڼ
	���������ƽ׶Σ������������������ɫ�Ծ����������һ����ɫʹ��һ�š�ɱ��������ý�ɫʧȥ1�������� 
	���ã�LuaLuanwu
	״̬��0405��֤ͨ��	
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
	������������
	����佫����׼������
	���������ƽ׶Σ����������һ���ƣ������������ʹ�õġ�ɱ���򡾾���������Ϊ�˺���Դʱ����ɵ��˺�+1��ֱ���غϽ�����
	���ã�LuaLuoyiBuff��LuaLuoyi
	״̬��1217��֤ͨ��
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
	������������
	����佫��������
	���������ƽ׶Σ����������һ��װ���ƣ������������ʹ�õġ�ɱ���򡾾���������Ϊ�˺���Դʱ����ɵ��˺�+1��ֱ���غϽ�����ÿ�׶���һ�Ρ�
	���ã�LuaXNeoLuoyi��LuaXNeoLuoyiBuff
	״̬��1217��֤ͨ��
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
	������������
	����佫����׼���缧��1v1���缧1v1��SP���缧��SP��̨���缧
	������׼���׶ο�ʼʱ������Խ���һ���ж������ж����Ϊ��ɫ��������Ч����ж�����������ظ������̡�
	���ã�LuaLuoshen
	״̬��1217��֤ͨ��
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
	�����������㣨��������
	����佫��SP������&С��
	������������佫�����С������ơ�������Ϊӵ�м��ܡ����㡱�͡����롱��
	���ã�LuaLuoyan
	״̬��1217��֤ͨ��(���뼼�ܡ����衱���ʹ��)
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
	����������Ӣ
	����佫��һ����������ֲ
	��������������ɫ��÷���������û��ж����������ƶ�ʱ������Ի��֮��
	���ã�LuaLuoying
	״̬��1217��֤ͨ��
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
	������������
	����佫����׼������
	�����������Ϊ��ɱ����Ŀ��ʱ�����������һ���ƣ����ˡ�ɱ��ת�Ƹ��㹥����Χ�ڵ�һ��������ɫ���ˡ�ɱ����ʹ���߳��⣩��
]]--
-----------
--[[M��]]--
-----------
--[[
	����������������������
	����佫����׼���������ӵ¡�SP���ӵ¡�SP������SP����ǿ�񻰡�SP����ŭս��SP������һ������2012����ᷡ�һ������2012�����-�ɡ���ս�����ڡ�3v3��������SP��̨����������ͻ�ơ�����JSP������
	��������������������ɫ�ľ���-1��
	���ã�LuaMashu
	״̬��0405��֤ͨ��
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
	������������
	����佫��1v1���ϻ�1v1��1v1��ף��1v1
	��������ǳ�ʱ���������Ϊʹ��һ�š��������֡��������������������֡�������Ч��
	���ã�LuaSavageAssaultAvoid,LuaManyi
	״̬��1217��֤ͨ����kof1v1ģʽ��ͨ����
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
	������������
	����佫����SP����ͳ
	������ÿ���㽫����κ�һ�����ƣ���֮�������ƶѡ��������������Ļغ��У�������ν�����Ƶ�����ͬ��һ���ƴ����ƶ�����������ϡ�
	���ã�LuaManjuan
	״̬��1217��֤ͨ��
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
	���������ͽ�
	����佫�����ӵ¡�SP���ӵ�
	����������ʹ�õġ�ɱ����Ŀ���ɫ�ġ���������ʱ�������������һ���ơ�
	���ã�LuaMengjin
	״̬��0405��֤ͨ��
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
	���������ؼ�
	����佫��һ������2012������
	�����������׶ο�ʼʱ�����������ˣ��������һ��X���ƣ�XΪ������ʧ������ֵ����Ȼ����ͬ������������������䷽ʽ��������������������ɫ��
	���ã�LuaMiji
	״̬��1217��֤ͨ��
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
	���������ؼ�
	����佫������-һ��2������-��
	�������غϿ�ʼ/�����׶ο�ʼʱ�����������ˣ�����Խ���һ���ж������ж����Ϊ��ɫ����ۿ��ƶѶ���X���ƣ�XΪ������ʧ������ֵ����Ȼ����Щ�ƽ���һ����ɫ��
	���ã�LuaNosMiji
	״̬��1217��֤ͨ��
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
	������������
	����佫��ͭȸ̨�����ʺ�
	���������ƽ׶���һ�Σ�����Խ�һ�����ƽ���һ��������ɫ���ý�ɫ�����ѡ�����һ����ɫʹ��һ�š�ɱ�����޾������ƣ���������ѡ��Ľ�ɫ�ۿ������Ʋ������������һ�š�
	���ã�LuaXMixin
	״̬��1217��֤ͨ��
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
	����������گ
	����佫��ͭȸ̨�����׵ۡ�SP����Э
	���������ƽ׶���һ�Σ�����Խ��������ƣ�����һ�ţ�����һ��������ɫ���������������ý�ɫ����һ������ָ���������ƵĽ�ɫƴ�㣺��һ����ɫӮ����Ϊ�ý�ɫ��ûӮ�Ľ�ɫʹ��һ�š�ɱ����
	���ã�LuaXMizhao
	״̬��1217��֤ͨ��
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
	����������ƣ���������
	����佫��һ������2013������
	��������ʹ�ú�ɫ����ʱ������Ƶ�Ŀ������������Ϊ����
	���ã�LuaMieji��LuaMiejiTargetMod
	״̬��1217��֤ͨ��
]]--
---------------------Ex�赶ɱ�˼��ܿ�---------------------
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
	����������ʿ������������0224����ǰ�棩
	����佫����ս������
	������ÿ�����ܵ��˺�ʱ�����˺���Դ�����ƣ���չʾ�������ƣ�������˺�-1��
	���ã�LuaXMingshi
	״̬��1217��֤ͨ��
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
	����������ʿ������������0610�棩
	����佫����ս������
	������ÿ�����ܵ��˺�ʱ�����˺���Դװ�������������������װ���������������˺�-1��
	���ã�LuaMingshi610
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ���������¹�
	���������ƽ׶���һ�Σ�����Խ�һ��װ���ƻ�ɱ������һ��������ɫ���ý�ɫ����Ϊ���乥����Χ����ѡ�����һ����ɫʹ��һ�š�ɱ��������δ��������乥����Χ��û��ʹ�á�ɱ����Ŀ�꣬����һ���ơ�
	���ã�LuaMingce
	״̬��1217��֤ͨ��
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
	������������
	����佫����ֽ������Ӣ
	��������һ��ɫ�غϿ�ʼʱ���������������ִ�����������е�һ�
		1.����һ���ƣ������ý�ɫ���ж��׶Ρ�
		2.����һ�����������佫���ϣ��ý�ɫ���غ��ڵ��ж��������κ����＼��Ӱ�죬�ý�ɫ�غϽ����󽫸����������ƶѡ�
	���ã�LuaMingjian��LuaXMingjianStop
	״̬��1217��֤ͨ��
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
	������������
	����佫����3V3������
	��������Ļغ��⣬������ʹ�á���������ö�ʧȥһ�ź�ɫ��ʱ���������һ���ơ�
	���ã�LuaXMingzhe
	״̬��1217��֤ͨ��
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
	��������ı�ϣ�ת������
	����佫����SP������
	������ͨ��״̬�£���ӵ�б�ǡ��䡱��ӵ�м��ܡ��������͡�ǫѷ���������������Ϊ2�Ż�����ʱ�����뽫��ı�Ƿ���Ϊ���ġ������������ת��Ϊ��Ӣ�ˡ��͡��˼�������һ��ɫ�ĻغϿ�ʼǰ�������һ���ƽ���Ƿ��ء�
	���ã�LuaMouduanStart��LuaMouduan��LuaMouduanClear
	״̬��1217��֤ͨ��
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
	��������ı��
	����佫��ͭȸ̨����˳��SP������
	����������ʹ�á�ɱ��ָ��һ����ɫΪĿ��������ѡ��һ���һ���ƣ���������һ���ơ�����������ˡ�ɱ��������������ʱ���ý�ɫ�������һ���ơ�
	���ã�LuaXMoukui
	״̬��1217��֤ͨ��
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
	��������ı��
	����佫��1v1���ν�
	���������ƽ׶���һ�Σ����������ֽ�����һ�����ƣ�Ȼ����������������ڶ��ֵ�������������ѡ��һ���Ϊ����ʹ��һ�š�ɱ��������Ϊ����ʹ��һ�š���������
	���ã�LuaMouzhu
	״̬��1217��֤�ɹ�
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
	������������
	����佫��һ���������¹�
	���������ƽ׶Σ�����Խ���һ��������ɫһ��װ���ƻ�ɱ�����ý�ɫѡ��һ�1. ��Ϊ���乥����Χ����ѡ�����һ����ɫʹ��һ�š�ɱ����2. ��һ���ơ�ÿ�غ���һ�Ρ�
]]--
-----------
--[[N��]]--
-----------
--[[
	������������
	����佫��SP������
	������ÿ��������ɫ����ġ�ɱ���������������ƶ�ʱ������Ի��֮�� 
	���ã�LuaNaman
	״̬��0405��֤ͨ��
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
	������������
	����佫��1v1������
	���������ֵĽ����׶ο�ʼʱ�����䵱ǰ������ֵ����󣬻����ڴ˻غ��ڶ���ʹ�ù���ɱ��������Խ�һ�ź�ɫ�Ƶ���ɱ������ʹ�á� 
	���ã�LuaNiluan��LuaNiluanRecord
	״̬��1217��֤ͨ��
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
	������������
	����佫���󡤽���
	������ÿ��һ����ɫ��ָ��Ϊ��ɱ����Ŀ���������ˡ�ɱ��ʹ���߾���ý�ɫ���ڣ��������ý�ɫ��ʹ�����š����������ˡ�ɱ���� 
	���ã�LuaNiaoxiang
	״̬��1217��֤ͨ��
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
	���������������޶�����
	����佫������ͳ
	���������㴦�ڱ���״̬ʱ������ԣ����������������е��ƣ�Ȼ������佫�Ʒ������泯�ϲ�����֮�������������������ظ���3�㡣
	���ã�LuaNiepan��LuaNiepanStart
	״̬��1217��֤ͨ��
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
--[[O��]]--
-----------

-----------
--[[P��]]--
-----------
--[[
	������������
	����佫��һ���������ӻ�
	���������ƽ׶���һ�Σ�����Խ�һ�š�Ȩ���������ƶѲ�ѡ��һ����ɫ������������ý�ɫ�������ƣ��������ƶ����㣬�ý�ɫ�ܵ�1���˺���
	���ã�LuaPaiyi
	״̬��0405֤ͨ��
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
	����������������������
	����佫������ͻ�ơ��ŷɡ���׼���ŷ�-�ɡ����ŷɡ��ĺ�ԡ�����&�Ű�
	���������ڳ��ƽ׶���ʹ�á�ɱ��ʱ�޴������ơ�
	���ã�LuaPaoxiao
	״̬��0405��֤ͨ��
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
	�����������ǣ���������
	����佫��1v1������1v1
	��������ǳ�ʱ�������ڶ��ֵĻغϣ���ǰ�غϽ�����
	״̬����ĳ��ɱ�汾֧��throwEvent��ʱ���һῼ��������ܡ���
]]--
--[[
	���������ƾ�
	����佫��һ����������ʢ
	������ÿ����ʹ�á�ɱ����Ŀ���ɫ���һ���˺��������������X���ƣ�XΪ�ý�ɫ��ǰ������ֵ������Ϊ5����Ȼ��ý�ɫ�����佫�Ʒ��档
	���ã�LuaPojun
	״̬��1217��֤ͨ��
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
	���������ռ�
	����佫��1v1����٢
	���������ƽ׶���һ�Σ����������ƣ����������һ���ƣ������������������һ���ƣ�Ȼ���Դ˷�����?�ƵĽ�ɫ��һ���ơ� 
	���ã�LuaPuji
	״̬��1217��֤�ɹ�
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
--[[Q��]]--
-----------
--[[
	������������
	����佫���������
	�������ַ���ʼ����ʱ��������ʮһ���ƣ���ѡ������Ϊ���ƣ�������泯������һ�ԣ���Ϊ���ǡ������ƽ׶ν���ʱ����������������������Ƶ����滻��Щ���ǡ���
	���ã�LuaQixing��LuaQixingStart��LuaQixingAsk��LuaQingxingClear
	״̬��0405��֤ͨ��
	��ע��ˮ��wch�磺ҽ��Ҫ��0405��ϵġ���硱�͡�����������
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
	������������
	����佫���󡤺�̫��
	������ÿ��һ����ɫ�ĻغϽ����������ڱ��غ�ɱ������һ����ɫ��������������ơ�
	���ã�LuaQiluan 
	״̬��1217��֤ͨ��
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
	����������ţ���������
	����佫����׼������Ӣ��JSP������Ӣ
	��������ʹ�ý������޾������ơ���װ�����������������Ʋ��ܱ�������ɫ���á�
	״̬����δ���
	��ע��ǰ�벿�������һ������벿�ֱ�д��Դ�룬���Player::canDiscard
]]--
--[[
	����������ţ���������
	����佫������-��׼������Ӣ-�ɡ�SP��̨�����Ӣ
	��������ʹ�ý�����ʱ�޾������ơ�
	���ã�LuaNosQicai
	״̬��0405��֤ͨ��
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
	�����������
	����佫����������������
	���������ƽ׶���һ�Σ�����Խ�����������ƣ�����һ�ţ�������һ�ŷ���ʱ������ʹ�á�
	���ã�LuaQice
	״̬��0405��֤ͨ��
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
	��������ǧ��
	����佫�����ڼ�
	������ÿ��һ����ɫ�ܵ��˺��󣬸ý�ɫ���Խ��ƶѶ���һ������������佫���ϡ�ÿ��һ����ɫ��ָ��Ϊ�����ƻ�����Ƶ�ΨһĿ��ʱ�����ý�ɫͬ�⣬����Խ�һ�š�ǧ���ơ��������ƶѣ����������ȡ����Ŀ�ꡣ
	���ã�LuaQianhuan
	״̬��1217��֤ͨ��
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
	����������Ϯ
	����佫����׼��������SP��̨�����
	����������Խ�һ�ź�ɫ�Ƶ������Ӳ��š�ʹ�á�
	���ã�LuaQixi
	״̬��1217��֤ͨ��
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
	��������ǫѷ����������
	����佫����׼��½ѷ����ս��½ѷ
	�������㲻�ܱ�ѡ��Ϊ��˳��ǣ�򡿺͡��ֲ�˼�񡿵�Ŀ�ꡣ
	���ã�LuaNosQianxun
	״̬��0405��֤ͨ��
]]--
LuaNosQianxun = sgs.CreateProhibitSkill{
	name = "LuaNosQianxun",
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("Snatch") or card:isKindOf("Indulgence"))
	end
}
--[[
	��������ǱϮ
	����佫��һ������2012�����
	������׼���׶ο�ʼʱ������Խ���һ���ж���Ȼ����һ������Ϊ1�Ľ�ɫ����ʹ�û������ж������ɫ��ͬ�����ƣ�ֱ���غϽ�����
	���ã�LuaQianxi��LuaQianxiClear
	״̬��1217��֤ͨ��
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
	��������ǱϮ
	����佫������-һ��2�����-��
	������ÿ����ʹ�á�ɱ���Ծ���Ϊ1��Ŀ���ɫ����˺�ʱ������Խ���һ���ж������ж������Ϊ���ң����ֹ���˺�����Ϊ�����1���������ޡ�
	���ã�LuaNosQianxi
	״̬��1217��֤ͨ��
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
	��������ǿϮ
	����佫���𡤵�Τ
	���������ƽ׶���һ�Σ������ʧȥ1������������һ�������ƣ���ѡ�񹥻���Χ�ڵ�һ����ɫ�������������Ըý�ɫ���1���˺���  
	���ã�LuaQiangxi
	״̬��0405��֤ͨ��
]]--

LuaQiangxiCard = sgs.CreateSkillCard{
	name = "LuaQiangxiCard", 
	filter = function(self, targets, to_select) 
		if #targets ~= 0 or to_select:objectName() == sgs.Self:objectName() then return false end--��������Ӧ�ÿ���ѡ���Լ��Ŷ�
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
	��������ǹ��
	����佫��SP���ǲ�
	���������ƽ׶���һ�Σ�����Խ����ж���ֱ���غϽ�������ʹ�õ����Ƚ��С�ġ�ɱ���޾������ƣ�����ʹ�õĵ����Ƚ����ġ�ɱ�����������Ƶ�ʹ�ô�����
	���ã�LuaQiangwu��LuaQiangwutarmod
	״̬��1217��֤ͨ��
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
	���������ɱ�
	����佫��ɽ�����A
	��������׼���׶κͽ����׶εĽ׶ο�ʼǰ�����������һ�����ƣ�����������������ý׶Ρ����Դ˷��������ƽ׶Σ���������λ��һ������������ɫ�ĸ�һ�����ƣ����Դ˷��������ƽ׶Σ�����Խ����ϵ�һ����������һ����ɫ��Ӧ�������ڡ� 
	���ã�LuaQiaobian
	״̬��0405��֤ͨ��
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
	����������˵
	����佫��һ������2013����Ӻ
	���������ƽ׶ο�ʼʱ���������һ����ɫƴ�㣺����Ӯ�����غ���ʹ�õ���һ�Ż����ƻ����ʱ������ƿ�������һ������Ŀ�꣨�޾������ƣ������һ��Ŀ�꣨��ԭ�ж���һ��Ŀ�꣩������ûӮ���㲻��ʹ�ý����ƣ�ֱ���غϽ�����
	���ã�LuaQiaoshui��LuaQiaoshuiTargetMod��LuaQiaoshuiUse
	״̬��1217��֤ͨ��
]]--
---------------------Ex�赶ɱ�˼��ܿ�---------------------
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
	������������
	����佫�������
	���������ƽ׶ν���ʱ�������ڱ��׶���������������������ƣ������ѡ��һ������н�ɫ���ظ�1���������������н�ɫ��ʧȥ1��������
	���ã�LuaQinyin
	״̬��0405��֤ͨ��
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
	������������
	����佫����׼����٢
	������ ���ƽ׶���һ�Σ����������һ�����Ʋ�ѡ��һ�������˵Ľ�ɫ����ý�ɫ�ظ�1��������
	���ã�LuaQingnang
	״̬��1217��֤ͨ��
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
	�����������
	����佫����ս������
	���������ƽ׶Σ����������һ��װ���ƣ���һ��������ɫ��һ���佫������Ч��ֱ�����»غϿ�ʼ��
	���ã�LuaQingcheng
	״̬��1217��֤ͨ��
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
	�����������
	����佫����׼���缧��SP���缧��SP��̨���缧
	����������Խ�һ�ź�ɫ���Ƶ�������ʹ�û�����  
	���ã�LuaQingguo
	״̬��0405֤ͨ��
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
	�����������1V1
	����佫��1v1���缧1v1
	����������Խ�һ��װ�������Ƶ�������ʹ�û�����   
	���ã�LuaKOFQingguo
	״̬��0405��֤ͨ��
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
	�����������
	����佫������ͻ�ơ��ĺ
	������ÿ���������ƽ׶��������ƺ�����Խ���������һ������������������ɫ��    
	���ã�LuaQingjian
	״̬��0405��֤ͨ��
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
	����������Ԯ
	����佫��һ������2013�����ʺ�
	������ÿ�����Ϊ��ɱ����Ŀ��ʱ���������һ�����ˡ�ɱ��ʹ������������Ƶ�������ɫ���泯�Ͻ�����һ�����ơ������Ʋ�Ϊ���������ý�ɫҲ��Ϊ�ˡ�ɱ����Ŀ�ꡣ
	���ã�LuaQiuyuan
	״̬��1217��֤ͨ��
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
	������������
	����佫��������
	���������ƽ׶���һ�Σ��������һ����ǰ������ֵ������Ľ�ɫƴ�㣺����Ӯ������乥����Χ����ѡ�����һ����ɫ���1���˺�������ûӮ����������1���˺���
	���ã�LuaQuhu
	״̬��1217��֤ͨ��
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
	��������Ȩ��
	����佫��һ���������ӻ�
	������ÿ�����ܵ�1���˺����������һ���ƣ�Ȼ��һ�����������佫���ϣ���Ϊ��Ȩ����ÿ��һ�š�Ȩ���������������+1�� 
	���ã�LuaQuanji��LuaQuanjiKeep
	״̬��0405֤ͨ��
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
	��������Ȩ��
	����佫��һ���������ӻ�
	������ÿ�����ܵ�1���˺����������һ���ƣ�Ȼ��һ��������������佫���ϣ���Ϊ��Ȩ����ÿ��һ�š�Ȩ��������������ޱ�+1��
]]--
-----------
--[[R��]]--
-----------
--[[
	���������ʵ�
	����佫����׼������
	���������ƽ׶���һ�Σ�����Խ�����һ�����ƽ���������ɫ�������Դ˷�����������ɫ����������������2����ظ�1��������
	״̬��1217��֤ͨ��
	���ã�LuaRende
	ע����Ϊʲôtable.contains����ʹ����
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
	���������ʵ�
	����佫������-��׼������-��
	���������ƽ׶Σ�����Խ�����һ��������������������ɫ�����ڱ��׶����Դ˷������������״δﵽ���Ż�������ظ�1��������  
	���ã�LuaNosRende
	״̬��0405��֤ͨ��
	��ע�����ιز���û��lua
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
	���������ʵ�
	����佫�����ιء�����
	���������ƽ׶Σ�����Խ�����������ƽ���������ɫ�����˽׶���������������ﵽ����ʱ����ظ�1��������
	���ã�LuaRende
	״̬����֤ͨ��
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
	������������
	����佫��1v1������
	����������������ƽ׶��ڶ԰�����Ľ�ɫʹ�õڶ��ż����ϡ�ɱ�������ʱ������ʱ�������������һ���ơ�
	���ã�LuaRenwang
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ������2013���ܳ�
	������һ��������ɫ���ڱ���״̬ʱ������Խ��佫�Ʒ��沢���������ƽ����ý�ɫ����ý�ɫ�ظ�1��������
	���ã�LuaRenxin
	״̬��1217��֤ͨ��
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
	���������̽䣨��������
	����佫����˾��ܲ
	������ÿ�����ܵ�1���˺���������ƽ׶���������ö�ʧȥһ���ƺ�����һö���̡��� 
	���ã�LuaRenjie
	״̬��0405��֤ͨ��
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
	�����������֣���������
	����佫���֡���׿
	����ʹ�á�ɱ��ָ��һ��Ů�Խ�ɫΪĿ��󣬸ý�ɫ������ʹ�����š��������ܵ����������ΪŮ�Խ�ɫʹ�á�ɱ����Ŀ�����������ʹ�����š��������ܵ�����
	���ã�LuaRoulin
	״̬��1217��֤ͨ��
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
	�����������ޣ������������Ѽ���
	����佫��ɽ������
	�������غϿ�ʼ�׶ο�ʼʱ�������������ȫ�����ٵģ���֮һ���������1���������ޣ��ظ�1������������ü��ܡ���������
	���ã�LuaRuoyu
	״̬��1217��֤ͨ��
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
	�����������ޣ������������Ѽ���
	����佫��ɽ������
	�������غϿ�ʼ�׶ο�ʼʱ�������������ȫ�����ٵģ���֮һ���������1���������ޣ��ظ�1������������ü��ܡ���������
]]--
-----------
--[[S��]]--
-----------
--[[
	������������
	����佫��һ���������Ŵ���
	���������ƽ׶��⣬�����������С��Xʱ������Խ����Ʋ���X�ţ�XΪ������ʧ������ֵ�����Ϊ2����
	���ã�LuaShangshi
	״̬��1217��֤ͨ��
]]--
LuaShangshi = sgs.CreateTriggerSkill{
	name = "LuaShangshi",
	events = {sgs.EventPhaseChanging, sgs.CardsMoveOneTime, sgs.MaxHpChanged, sgs.HpChanged},
	frequency = sgs.Skill_Frequent,
	on_trigger = function(self, triggerEvent, zhangchunhua, data)
		local room = zhangchunhua:getRoom()
		local losthp = math.min(zhangchunhua:getLostHp(),2)
		--����ǻ��ɰ�����ôд��
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
	������������
	����佫�����ɡ��Ŵ���
	���������ƽ׶��⣬�����������С��Xʱ������Խ����Ʋ���X�ţ�XΪ������ʧ������ֵ��
	���ã�LuaNosShangshi
	״̬��1217��֤ͨ�������ϣ�
]]--

--[[
	������������
	����佫���󡤽���
	���������ƽ׶���һ�Σ��������һ��������ɫ�ۿ�������ƣ�Ȼ����ѡ��һ�1.�ۿ������ƣ�Ȼ���������������һ�ź�ɫ�ơ�2.�ۿ�������ơ� 
	���ã�LuaShangyi
	״̬��1217��֤ͨ��
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
			room:doNotify(effect.from, sgs.CommandType.S_COMMAND_SET_PROPERTY, json.encode(jsonValue)); --Դ�����ﾹȻ�пӡ���
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
	����������Ӫ
	����佫�����졤½����
	�����������һ������������״̬�Ľ�ɫ���һ�λ����˺�ʱ�����ѡ��һ�������Ϊ1������һ����ɫ������һ���ж������ж����Ϊ��ɫ�������ѡ��Ľ�ɫ���һ������˺�
	���ã�LuaShaoying
	״̬��1217��֤ͨ��
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
	������������
	����佫��������
	���������ƽ׶ο�ʼʱ������Է������Ʋ������ƶѶ��������ơ������������������ÿ�ֻ�ɫ���Ƹ�һ�ţ�Ȼ����������������ƶѡ� 
	���ã�LuaShelie
	״̬��0405��֤ͨ��
	��ע����Դ����������Դ����Զ��庯��ɾ���������Զ��庯��
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
			to_get:append(card_id)--����ʣ�����з��ϻ�ɫ����(ԭ�ģ�throw the rest cards that matches the same suit)
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
	�����������
	����佫����������SP��������
	���������ƽ׶���һ�Σ����������ö����ŭ����ǣ��������������������ɫ�ܵ�1���˺�������װ�����������ƣ������������ƣ�Ȼ���㽫�佫�Ʒ��档 
	���ã�LuaShenfen
	״̬��0405��֤ͨ����δ�����أ�
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
	������������
	����佫��SP���ǲ�
	��������Ļغ��⣬ÿ����������ɫ�����ö�ʧȥ��ʱ���������л����ƣ��������һ���ơ�
	���ã�LuaShenxian
	״̬��1217��֤ͨ��
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
	�����������
	����佫��SP����ŭս��2013-3v3������
	�����������װ����û�������ƣ�����ʹ�á�ɱ��ʱ������Զ���ѡ����������Ŀ�ꡣ
	���ã�LuaShenji
	״̬��0405��֤ͨ��
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
	���������������������
	����佫�����졤½����
	��������Ϸ��ʼʱ�������ѡ���Լ����Ա𡣻غϿ�ʼ�׶ο�ʼʱ������뵹ת�Ա����Խ�ɫ������ɵķ��׵������˺���Ч
	���ã�LuaShenjun
	״̬��1217��֤ͨ��
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
	����������������������
	����佫�����졤��֮����
	���������ƽ׶Σ���ʹ�á�ɱ����ɵĵ�һ���˺�+X��XΪ��ǰ��ս����������Ϊ3
	���ã�LuaShenli
	״̬��1217��֤ͨ��
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
	������������
	����佫���硤�ĺ�Ԩ��1v1���ĺ�Ԩ1v1
	�����������ѡ��һ�����
		1.��������ж��׶κ����ƽ׶Ρ�
		2.������ĳ��ƽ׶β�����һ��װ���ơ�
		��ÿѡ��һ���Ϊ��һ��������ɫʹ��һ�š�ɱ�����޾������ƣ���
	���ã�LuaShensu��LuaShensuSlash
	״̬��1217��֤ͨ��
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
	����������������������
	����佫��SP����ŭս��
	���������ƽ׶Σ�������������ƣ������������+2��
	���ã�LuaShenwei��LuaShenweiDraw
	״̬��0405��֤ͨ��
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
	������������
	����佫����ս���ʷ���
	������׼���׶ο�ʼʱ������������������ơ������Դ˷����õ��Ʋ�����X�ţ���ظ�1����������XΪ�㵱ǰ������ֵ��
	���ã�LuaShenzhi
	״̬��1217��֤ͨ��
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
	����������Ϣ
	����佫���󡤽���&�ѵt
	������ÿ����ĳ��ƽ׶ν���ʱ�������ڴ˽׶�δ����˺���������������ơ� 
	���ã�LuaShengxi
	״̬��0405��֤ͨ��
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
	��������ʦ��
	����佫���ǡ�˾���
	������������ɫʹ�÷���ʱ����ʱ������������һ����
	���ã�LuaShien
	״̬��1217��֤ͨ��
	ע����ˮ�����������ܾ�����ϵ��Ϊ�˷������ͳһʹ�ñ�LUA�汾�ļ��ܣ�����ԭ��
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
	��������ʶ��
	����佫���ǡ����
	�����������ɫ�ж��׶��ж�ǰ����������������ƣ���øý�ɫ�ж������������
	���ã�LuaShipo
	״̬��1217��֤ͨ��
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
	���������Ѳţ���������
	����佫���ǡ�����
	����������ƴ��ɹ�ʱ����һ����
	���ã�LuaShicai
	״̬��1217��֤ͨ��
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
	�����������£���������
	����佫����������������
	������ÿ�����ܵ�һ�κ�ɫ�ġ�ɱ�����򡾾ơ���Ч���˺�+1�ġ�ɱ����ɵ��˺������1���������ޡ�
	���ã�LuaShiyong
	״̬��1217��֤ͨ��
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
	���������ĳ����������޶�����
	����佫����SP������
	������׼���׶ο�ʼʱ������Խ���һ��������������ɫ�����ơ�ÿ�����ܵ��˺�ʱ���㽫���˺�ת�Ƹ��ý�ɫ��Ȼ��ý�ɫ��X���ƣ�ֱ�����һ�ν������״̬ʱ����XΪ�˺�������
	���ã�LuaShichou
	״̬��1217��֤ͨ��
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
	�����������ܣ���������
	����佫��1v1������
	�����������������+X����XΪ���ƽ׶ο�ʼʱ������ɫ��������ֵ��
	���ã�LuaShenju LuaShenjuMark
	״̬��1217��֤ͨ��
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
	���������س�
	����佫���󡤽����ѵt
	������ÿ��һ����ɫ����غ���ʧȥ�������ƺ��������ý�ɫѡ���Ƿ���һ���ơ� 
	���ã�LuaShoucheng
	״̬��1217��֤ͨ��
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
	����������ҵ
	����佫���ǡ�˾���
	���������ƽ׶Σ����������һ�ź�ɫ���ƣ�ָ���������������ɫ����һ����
	���ã�LuaShouye
	״̬��1217��֤ͨ��
	ע����ˮ�����������ܾ�����ϵ��Ϊ�˷������ͳһʹ�ñ�LUA�汾�ļ��ܣ�����ԭ��
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
	�����������
	����佫����ֽ����Ԫ��
	�����������׶ο�ʼʱ������Խ����������������������޵�������
	���ã�LuaShude
	״̬��1217��֤ͨ��
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
	������������
	����佫����ս���ʷ���
	������ÿ����ظ�1���������������һ��������ɫ��һ���ơ�
	���ã�LuaShushen
	״̬��1217��֤ͨ��
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
	��������˫��
	����佫����ս������
	���������ƽ׶ο�ʼʱ���������һ��������ɫƴ�㣺����Ӯ����Ϊ��һ��������ɫʹ��һ���޾������Ƶ���ͨ��ɱ�����ˡ�ɱ����������ƽ׶�ʹ�ô��������ƣ�������ûӮ����������ƽ׶Ρ�
	���ã�LuaXShuangren
	״̬��1217��֤ͨ��
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
	��������˫��
	����佫���������ĳ�
	���������ƽ׶ο�ʼʱ������Է������ƣ���Ϊ����һ���ж���������Ч����ж��ƣ�Ȼ������Խ�һ������ж�����ɫ��ͬ�����Ƶ���������ʹ�ã�ֱ���غϽ�����
	���ã�LuaShuangxiong LuaShuangxiongJudge
	״̬��1217��֤ͨ�������ܻ���Bug��
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
	��������ˮ��
	����佫�����ˡ�����
	���������ƽ׶�����ʱ������Զ�����X+1���ƣ�XΪ��װ��������������һ�루����ȡ������
	���ã�LuaXShuijian
	״̬��1217��֤ͨ��
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
	��������ˮӾ����������
	����佫�����ˡ�Ҷʫ��
	��������ֹ���ܵ��Ļ����˺���
	���ã�LuaXShuiyong
	״̬��1217��֤ͨ��
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
	���ܣ�����
	����佫����ս�����
	������ÿ����ʧȥ�������ƺ����������һ��������ɫ��һ���ơ�
	���ã�LuaSijian
	״̬��1217��֤ͨ��
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
	����������ս����������
	����佫�����졤��֮����
	�����������ܵ��˺�ʱ����ֹ���˺���������˺�������������ս��ǣ���ĻغϽ����׶ο�ʼʱ�������������е�X����ս��ǲ���ʧX������
	���ã�LuaSizhan
	״̬��1217��֤ͨ��
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
	���������̴�
	����佫��SP������
	���������ƽ׶Σ������ѡ��һ�1����һ��������С���䵱ǰ������ֵ�Ľ�ɫ�������ơ�2����һ�������������䵱ǰ������ֵ�Ľ�ɫ���������ơ�ÿ����ɫÿ����Ϸ��һ�Ρ�
	���ã�LuaSongci
	״̬��1217��֤ͨ��
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
	����������������������
	����佫���֡���ا��ͭȸ̨����ا
	����������κ������ɫ�ĺ�ɫ�ж�����Ч�󣬸ý�ɫ����������һ���ơ� 
	���ã�LuaSongwei
	״̬��0405��֤ͨ��
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
	���ܣ�����
	����佫��1v1���ĺ�Ԩ1v1
	������ÿ���������Ķ��ֵ��������ö��������ƶ�ǰ������Ի��֮��
	���ã�LuaSuzi
	״̬��1217��֤ͨ��
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
	���ܣ�����
	����佫����ս�����
	������ÿ��������ɫ�������״̬ʱ���˺���Դ����������һ���ƣ�ÿ��������ɫ����ʱ���˺���Դ��������ʧȥ1��������
	���ã�LuaSuishi
	״̬��1217��֤ͨ��
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
	����������������������
	����佫���֡���ا
	����������κ������ɫ���ж���Ϊ��ɫ����Ч�󣬸ý�ɫ����������һ���ơ�
]]--
-----------
--[[T��]]--
-----------
--[[
	��������̧�
	����佫�����졤������
	���������ƽ׶Σ�������Լ�1������������һ�������ƣ������㹥����Χ�ڵ�һ����ɫ����������ơ�ÿ�غ��У�����Զ��ʹ��̧�
	���ã�LuaTaichen
	״̬��1217��֤ͨ��
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
	��������̰��
	����佫���ǡ�����
	������ÿ�����ܵ�һ���˺��������˺���Դ����ƴ�㣺����Ӯ����������ƴ����
	���ã�LuaTanlan
	״̬��1217��֤ͨ��
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
	��������̽��
	����佫����SP������
	���������ƽ׶���һ�Σ��������һ����ɫƴ�㣺����Ӯ����ӵ����������������������ý�ɫ�ľ��룬��ʹ�õķ���ʱ������ƶԸý�ɫ����ʱ���ܱ�����и�ɻ�����Ӧ��ֱ���غϽ�����
	���ã�LuaTanhu
	״̬��1217��֤ͨ��
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
	��������̽�ң���������
	����佫�����ŷ�
	��������������������ɫ�ľ���-X��XΪ������ʧ������ֵ����
	���ã�LuaXTannang
	״̬��0504��֤ͨ��
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
	�����������
	����佫��TWYJ����ï
	��������������ɫʹ�á�ɱ��ָ��Ŀ��ʱ���������乥����Χ����Ŀ����Ϊ1������Խ�֮ת�Ƹ��Լ���������������ˡ�ɱ�������������������һ���ơ� 
	���ã�LuaTijin
	״̬��0428��֤ͨ��
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
	�����������
	����佫����׼�����Ρ�SP��̨�����
	������������ж�����Ч������Ի�ô��ơ�
	���ã�LuaTiandu
	״̬��1217��֤ͨ��
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
	���������츲
	����佫���󡤽�ά
	����������������ڵĽ�ɫ�ĻغϿ�ʼʱ���ý�ɫ��������ӵ�С����ơ���ֱ���غϽ����� 
	���ã�LuaTianfu
	״̬��1217��֤ͨ��
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
	������������
	����佫��ͭȸ̨�����׵ۡ�SP����Э
	������ ÿ���㱻ָ��Ϊ��ɱ����Ŀ��ʱ����������������ƣ�Ȼ���������ơ���ȫ��Ψһ������ֵ���Ľ�ɫ�����㣬�ý�ɫҲ�������������ƣ�Ȼ���������ơ� 
	���ã�LuaTianming
	״̬��0405��֤ͨ��
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
	������������
	����佫���硤С��
	������ÿ�����ܵ��˺�ʱ�����������һ�ź������ƣ������˺�ת�Ƹ�һ��������ɫ��Ȼ��ý�ɫ��X���ƣ�XΪ�ý�ɫ��ǰ����ʧ������ֵ����
	���ã�LuaTianxiang��LuaTianxiangDraw
	״̬��1217��֤
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
	������������
	����佫����̫ʷ��
	���������ƽ׶���һ�Σ��������һ����ɫƴ�㡣����Ӯ������������������ֱ���غϽ�������ʹ�á�ɱ���޾������ƣ����ڳ��ƽ׶����ܶ���ʹ��һ�š�ɱ������ʹ�á�ɱ��ѡ��Ŀ��ĸ�������+1������ûӮ���㲻��ʹ�á�ɱ����ֱ���غϽ�����
	���ã�LuaTianyi��LuaTianyiTargetMod
	״̬��1217��֤ͨ��
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
	������������
	����佫��ɽ����ά��1V1��ά
	���������ƽ׶Σ��������һ�������乥����Χ�ڵ�������ɫѡ��һ�����ʹ��һ�š�ɱ����������������һ���ơ�ÿ�׶���һ�Ρ�
	���ã�LuaTiaoxin
	״̬��1217��֤ͨ��
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
	������������
	����佫����׼����-�ɡ�SP������1v1����1v1��SP��̨����
	������ ÿ����ָ����ɱ����Ŀ�������Խ����ж��������Ϊ��ɫ���ý�ɫ����ʹ�á�������Ӧ�ˡ�ɱ���� 
	���ã�LuaTieji
	״̬��0405��֤ͨ��
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
	��������ͬ������������
	����佫����׼��Ԭ��
	����������������������������ֵ��������һ��������ɫ�Ĺ�����Χ�ڣ���������ɫ���ܱ�ѡ��Ϊ�ý�ɫ�ġ�ɱ����Ŀ�ꡣ
	���ã�LuaTongji
	״̬��1217��֤ͨ��
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
	��������ͬ��
	����佫�����졤�ĺ��
	��������������״̬��������ɫ��ÿ�ܵ�һ���˺�����������������˸���һ����
	���ã�LuaTongxin
	״̬��1217��֤ͨ��
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
	��������͵��
	����佫�����졤��ʿ��
	������������佫�Ʊ�������ʱ���ܵ��˺������������һ�����Ʋ�������佫�Ʒ��棬��Ϊ��һ��������ɫʹ����һ�š�ɱ��
	���ã�LuaToudu��LuaTouduNDL
	״̬��1217��֤ͨ��
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
	��������ͻ���������
	����佫����ֽ�������
	������׼���׶ο�ʼʱ��������佫�����С��衱���㽫���С��衱�������ƶѣ���XС�ڻ����2������һ���ơ����غ�����������ɫ�ľ���-X����XΪ׼���׶ο�ʼʱ�������ƶѵġ��衱��������
	���ã�LuaXTuqi��LuaXTuqiDist
	״̬��1217��֤ͨ��
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
	��������ͻϮ
	����佫������ͻ�ơ�����
	���������ƽ׶Σ��������������һ���Ʋ�ѡ������������Ƶ����Ʋ��������������ɫ����������������λ����Щ��ɫ��һ�����ơ� 
	���ã�LuaTuxi��LuaTuxiAct
	״̬��0405��֤ͨ��
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
	��������ͻϮ
	����佫����׼�����ɡ�SP��̨������
	���������ƽ׶ο�ʼʱ������Է������Ʋ�ѡ��һ�����������Ƶ�������ɫ����������������λ����Щ��ɫ��һ�����ơ� 
	���ã�LuaNosTuxi
	״̬��0405��֤ͨ��
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
	��������ͻϮ
	����佫��1v1������1v1
	���������ƽ׶Σ������������С�ڶ��ֵ������������������һ���Ʋ����ö��ֵ�һ�����ơ�
	���ã�LuaKOFTuxi��LuaKOFTuxiAct
	״̬��1217��֤ͨ��
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
	������������
	����佫��ɽ���˰�
	��������Ļغ��⣬����ʧȥ��ʱ������Խ���һ���ж������Ǻ��ҽ�����ж�����������佫���ϣ���Ϊ�����ÿ��һ�š������������������ɫ�ľ����-1��
	���ã�LuaTuntian��LuaTuntianDistance
	״̬��1217��֤ͨ��
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
--[[U��]]--
-----------
--[[
	��������
	����佫��
]]--
-----------
--[[V��]]--
-----------
--[[
	��������
	����佫��
]]--
-----------
--[[W��]]--
-----------
--[[
	������������
	����佫��1v1������
	������ÿ�����Ϊ��ɱ����Ŀ����������һ���ơ�  
	���ã�LuaWanrong
	״̬��0405��֤ͨ��
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
	����������϶
	����佫���ơ����
	������ÿ�����һ��������ɫ���1���˺��󣬻����ܵ�������ɫ��ɵ�1���˺������ý�ɫ��������������һ���ơ�
	���ã�LuaWangxi
	״̬��1217��֤ͨ��
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
	������������
	����佫����׼��Ԭ��
	������������׼���׶ο�ʼʱ���������һ���ƣ�Ȼ���������غ���������-1��
	���ã�LuaWangzun��LuaWangzunMaxCards
	״̬��1217��֤ͨ��
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
	��������Σ������������
	����佫���ǡ����
	������������Ҫʹ��һ�š��ơ�ʱ��������������ɫ���ж�˳������ѡ���Ƿ���һ�ź���2~9�����ƣ���Ϊ��ʹ����һ�š��ơ���ֱ����һ����ɫ��û���κν�ɫ���������ʱΪֹ
	���ã�LuaWeidai
	״̬��1217��֤ͨ��
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
	��������Χ��
	����佫�����졤½��
	����������Խ�������ƽ׶ε������ƽ׶Σ����ƽ׶ε������ƽ׶�ִ��
	���ã�LuaLukangWeiyan
	״̬��1217��֤ͨ��
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
	���������Ļ����������
	����佫���֡���ڼ��SP����ڼ
	�������㲻�ܱ�ѡ��Ϊ��ɫ�����Ƶ�Ŀ�ꡣ
	���ã�LuaWeimu
	״̬��0405��֤ͨ��
]]--
LuaWeimu = sgs.CreateProhibitSkill{
	name = "LuaWeimu" ,
	is_prohibited = function(self, from, to, card)
		return to:hasSkill(self:objectName()) and (card:isKindOf("TrickCard") or card:isKindOf("QiceCard")) 
		and card:isBlack() and card:getSkillName() ~= "nosguhuo" --�ر�ע��ɹƻ�
	end
}
--[[
	��������α�ۣ���������
	����佫��SP��Ԭ����SP��̨��Ԭ��
	��������ӵ�е�ǰ��������������
	״̬��0405��֤ʧ��--Ŀ����Զʵ�ֲ���
]]--
--[[
	���������¾ƣ���������
	����佫���ǡ�����
	��������ʹ�ú�ɫ�ġ�ɱ����ɵ��˺�+1�����޷����ܺ�ɫ�ġ�ɱ��
	���ã�LuaWenjiu
	״̬��1217��֤ͨ��
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
	����������ı����������
	����佫����������SP��������
	������ÿ����ʹ��һ�ŷ���ʱ������ʱ������ѡ��һ�ʧȥ1������������һö����ŭ����ǡ� 
	���ã�LuaWumou
	״̬��0405��֤ͨ��
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
	����������ǰ
	����佫����������SP��������
	���������ƽ׶Σ����������ö����ŭ����ǲ�ѡ��һ��������ɫ�������������ӵ�С���˫���Ҹý�ɫ������Ч��ֱ���غϽ�����
	���ã�LuaWuqian
	״̬��0405��֤ͨ��
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
	����������˫����������
	����佫������ͻ�ơ���������׼��������SP����ǿ�񻰡�SP����ŭս��SP��̨������
	����������ʹ�á�ɱ��ָ��һ����ɫΪĿ��󣬸ý�ɫ������ʹ�����š��������ܵ�����������С��������Ľ�ɫÿ��������������š�ɱ����
	���ã�LuaWushuang
	״̬��0405��֤ͨ��
	��ע����Դ�����в�ͬ��������Բ�
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
	�����������ԣ���������
	����佫��һ������������
	���������ֹ����ɻ��ܵ����κν����Ƶ��˺���
	���ã�LuaWuyan
	״̬��1217��֤ͨ��
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
	�����������ԣ���������
	����佫�����ɡ�����
	��������ʹ�õķ���ʱ������ƶ�������ɫ��Ч��������ɫʹ�õķ���ʱ������ƶ�����Ч��
	���ã�LuaNosWuyan
	״̬��1217��֤ͨ��
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
	������������
	����佫�����졤������
	�������غϿ�ʼ�׶Σ����ѡ��һ������Ч����������Ч���Գ������н�ɫ��Ч
		��Ч��ֱ������»غϿ�ʼΪֹ����ѡ�������Ч���������ϻغ��ظ�
		[��]�������н�ɫ�ܵ��Ļ����˺�+1
		[��]�������н�ɫ�ܵ����׵��˺�+1
		[ˮ]�������н�ɫʹ����ʱ����ظ�1������
		[��]�������н�ɫ�ܵ����˺�����Ϊ�����˺�
		[��]�������н�ɫÿ���ܵ��������˺�����Ϊ1
	���ã�LuaWulingExEffect��LuaWulingEffect��LuaWuling
	״̬��1217��֤ͨ��
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
	����������꣨��������
	����佫���񡤹���
	������ÿ�����ܵ��˺��ۼ�����ǰ���˺���Դ��õ����˺������ġ����ʡ���ǡ�������ʱ����ѡ��һ�����ġ����ʡ��������ࣨ��Ϊ0���Ľ�ɫ���ý�ɫ�����ж����������Ϊ���ҡ�����԰���塿���ý�ɫ������ 
	���ã�LuaWuhun��LuaWuhunRevenge
	״̬��0405��֤ͨ��
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
	����������̣����Ѽ���
	����佫��SP��������
	�����������׶ο�ʼʱ�������ڱ��غ����������3���˺���������1���������ޣ��ظ�1��������Ȼ��ʧȥ����Х���� 
	���ã�LuaWuji
	״̬��0405��֤ͨ��
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
	��������������������
	����佫���񡤹���
	��������ĺ���������Ϊ��ͨ��ɱ������ʹ�ú��ҡ�ɱ���޾������ơ� 
	���ã�LuaWushen��LuaWushenTargetMod
	״̬��0405��֤ͨ��
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
	����������ʥ
	����佫������ͻ�ơ�����JSP������SP�����𡢱�׼������������2013-3v3������1v1������1v1
	����������Խ�һ�ź�ɫ�Ƶ���ɱ��ʹ�û�����
	���ã�LuaWusheng
	״̬��0405��֤ͨ��
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
	��������������������
	����佫���񡤹���
	��������ĺ������ƾ���Ϊ��ɱ������ʹ�ú��ҡ�ɱ��ʱ�޾������ơ�
]]--
-----------
--[[X��]]--
-----------
--[[
	��������ϧ��
	����佫�����졤�Ź���
	��������ɽ�������ɫ���ƽ׶����õĺ�����Ϊ���ס����������
	���ã�LuaXiliang
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ������2013������
	������׼���׶ο�ʼʱ������Խ�һ��������ɫ�ĸ�һ������������佫���ϣ���Ϊ���桱��������ɫ���Խ����š��桱�������ƶѣ���Ϊ����ʹ��һ�š�ɱ����
	���ã�LuaXiansi LuaXiansiAttach LuaXiansiSlash�����ܰ�����
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ����������˳
	���������ƽ׶���һ�Σ��������һ��������ɫƴ�㣺����Ӯ���������¼��ܣ����غϣ��ý�ɫ�ķ�����Ч����������ý�ɫ�ľ��룬��Ըý�ɫʹ�á�ɱ�����������ƣ�����ûӮ���㲻��ʹ�á�ɱ����ֱ���غϽ�����
	���ã�LuaXianzhen
	״̬��1217��֤ͨ��
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
	�����������֣���������
	����佫��ɽ������
	��������������ɫʹ�á�ɱ��ָ����ΪĿ��ʱ��������һ�Ż����ƣ�����ˡ�ɱ��������Ч��
	���ã�LuaXiangle
	״̬��1217��֤ͨ��
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
	���������ɼ�
	����佫����׼�������㡢SP�������㡢JSP��������
	������ÿ����ʧȥһ��װ������װ���ƺ�������������ơ� 
	���ã�LuaXiaoji
	״̬��0405֤ͨ��
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
	���������ɼ�
	����佫��1v1��������1v1
	������ÿ����ʧȥһ��װ������װ���ƺ������ѡ��һ��������ƣ���ظ�1��������
	���ã�Lua1V1Xiaoji
	״̬��1217��֤ͨ��
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
	�����������
	����佫����ս���ֽ���SP�ֽ�
	������������ɫ�Ľ����׶ο�ʼʱ�����������һ�Ż����ƣ�����������ý�ɫѡ��һ�1.����һ��װ���ƣ�Ȼ��������һ���ƣ�2.�ܵ�1���˺��� 
	���ã�LuaXiaoguo
	״̬��0405��֤ͨ��
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
			else--�����д��ս������Ļ���һ�к���һ��ɾ��
				yuejin:drawCards(1, self:objectName())
			end
		end
		return false
	end
}
--[[
	����������Ϯ
	����佫��1v1����1v1
	��������ǳ�ʱ���������Ϊʹ��һ�š�ɱ����
	���ã�LuaXiaoxi
	״̬��1217��֤ͨ��
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
	��������Т��
	����佫��SP���ĺ���
	������ÿ��һ��������ɫ��������������ӵ�иý�ɫ�佫���ϵ�һ��ܣ�������������Ѽ������ҡ�Т�¡���Ч��ֱ����ĻغϽ���ʱ��ÿ����ʧȥ��Т�¡�����ʧȥ�Դ˷���õļ��ܡ� 
	���ã�LuaXiaode, LuaXiaoEx
	״̬��1217��֤ͨ��
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
	��������Ю�����޶�����
	����佫��1v1������1v1
	���������ƽ׶Σ�����������ƴ�㣺����Ӯ����Ϊ��Զ���ʹ��һ�š�������������ûӮ����Ϊ���ֶ���ʹ��һ�š���������
	���ã�LuaXiechan
	״̬��1217��֤ͨ��
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
	����������ս
	����佫��һ������������
	���������ƽ׶Σ��������������������������ޣ�����ԣ��ۿ��ƶѶ��������ƣ�Ȼ�������������������ĺ����Ʋ����֮������������˳�������ƶѶ���ÿ�׶���һ�Ρ�
	���ã�LuaXinzhan
	״̬��1217��֤ͨ��
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
	������������
	����佫��ɽ�����
	������ÿ�����ܵ�1���˺�������Ի��һ�š������ơ���
	���ã�LuaXinSheng
	״̬��1217��֤ͨ��
	��ע�������ChapterH ��acquireGenerals ����
]]--
LuaXinSheng = sgs.CreateTriggerSkill{
	name = "LuaXinSheng",
	frequency = sgs.Skill_Frequent,
	events = {sgs.Damaged},
	on_trigger = function(self, event, player, data)
		local room = player:getRoom()
		if room:askForSkillInvoke(player, self:objectName()) then
			AcquireGenerals(player, data:toDamage().damage) --�����ChapterH ��acquieGenerals ����
		end
	end
}
--[[
	������������
	����佫��SP������&С��
	���������ƽ׶ο�ʼʱ������Խ�һ�����㱾�غ�ʹ�õ�����ɫ����ͬ�����������佫���ϡ�
		���������š������ơ����㽫���������ƶѣ�Ȼ��ѡ��һ�����Խ�ɫ����������2���˺���������װ�����������ơ�
	���ã�LuaXingwu
	״̬��1217��֤ͨ��
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
	������������
	����佫���֡���ا��ͭȸ̨����ا
	������ÿ��һ��������ɫ����ʱ������Ի�øý�ɫ���ơ�    
	���ã�LuaXingshang
	״̬��0405��֤ͨ��
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
	���ܣ����죨�޶�����
	����佫����ս������
	���������ƽ׶Σ���������������������Ľ�ɫ�������ƣ����Դ˷����ƵĽ�ɫ��������ȫ����ɫ����һ�룬��ظ�1��������
	���ã�LuaXiongyi
	״̬��1217��֤ͨ��
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
	������������
	����佫��SP����ŭս��
	������׼���׶ο�ʼʱ�����������һ�����ж�������ʱ�����ƻ�ɫ��ͬ�����ƣ���������������ø���ʱ�����ơ� 
	���ã�LuaXiuluo
	״̬��0405��֤ͨ��
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
	������������
	����佫��һ����������ͳ
	����������ʧȥװ���������ʱ���������ƽ׶������������Ż��������ƺ��������������һ������������ɫ�Ĺ��������ơ�
	���ã�LuaXuanfeng
	״̬��1217��֤ͨ��
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
				local choice = room:askForChoice(player, self:objectName(), "throw+nothing") --����ط����ҷǳ������������askForSkillInvoke����ô��������
				if choice == "throw" then
					--player:setFlags("LuaXuanfengUsed") --����Դ��Bug�ĵط�
					if player:getPhase() == sgs.Player_Discard then player:setFlags("LuaXuanfengUsed") end --�޸�Դ��Bug
					room:askForUseCard(player, "@@LuaXuanfeng", "@xuanfeng-card")
				end
			end
		end
		return false
	end
}
--[[
	������������
	����佫�����ɡ���ͳ
	����������ʧȥһ��װ���������ʱ�������ѡ��һ�1. ��Ϊ��һ��������ɫʹ��һ�š�ɱ�������Դ˷�ʹ�á�ɱ��ʱ�޾��������Ҳ�������ƽ׶��ڵ�ʹ�ô������ơ�2. �Ծ���Ϊ1��һ����ɫ���1���˺���
	���ã�LuaNosXuanfeng
	״̬��1217��֤ͨ��
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
	��������ѣ��
	����佫��һ������������
	���������ƽ׶ο�ʼʱ������Է������ƣ���Ϊ��һ��������ɫ�������ƣ�Ȼ��������乥����Χ����ѡ�����һ����ɫʹ��һ�š�ɱ�������ý�ɫδ��������乥����Χ��û��������ɫ�������������ơ�
	���ã�LuaXuanhuo��LuaXuanhuoFakeMove
	״̬��1217��֤ͨ��
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
				if victim then --������д������movecard��������
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
	��������ѣ��
	����佫�����ɡ�����
	���������ƽ׶Σ�����Խ�һ�ź������ƽ���һ��������ɫ��Ȼ�����øý�ɫ��һ���Ʋ��������ý�ɫ���������ɫ��ÿ�׶���һ�Ρ�
	���ã�LuaNosXuanhuo
	״̬��1217��֤ͨ��
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
	��������ѩ�ޣ���������
	����佫����SP���ĺ
	������һ����ɫ�Ľ����׶ο�ʼʱ������������ƴ�������״̬�������֮��Ȼ��ѡ��һ�1.���õ�ǰ�غϽ�ɫX���ơ� 2.��Ϊ��ʹ��һ���޾������Ƶġ�ɱ������XΪ������ʧ������ֵ��
	���ã�LuaXuehen��LuaXuehenNDL��LuaXuehenFakeMove
	״̬��1217��֤ͨ��
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
	��������Ѫ��
	����佫��SP��������
	���������ƽ׶���һ�Σ����������һ�ź�ɫ�Ʋ�ѡ���㹥����Χ�ڵ�����X����ɫ����������������Щ��ɫ�����1���˺���Ȼ����Щ��ɫ����һ���ơ���XΪ������ʧ������ֵ�� 
	���ã�LuaXueji
	״̬��0405��֤ͨ��
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
	��������Ѫ�ᣨ����������������
	����佫����Ԭ��
	������ÿ��һ������Ⱥ�۽�ɫ������������ޱ�+2��
	���ã�LuaXueyi
	״̬��1217��֤ͨ��
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
	������������
	����佫���ơ����
	���������ƽ׶ο�ʼʱ������Է������Ʋ��ۿ��ƶѶ��������ƣ��������е������ƣ�Ȼ���������������˳�������ƶѵס�
	���ã�LuaXunxun
	״̬��1217��֤ͨ��
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
	��������Ѹ�ͣ���������
	����佫����ʬ����ʬ
	���������ɱ��ɵ��˺�+1�����ɱ����˺�ʱ������������1������ʧ1��������
	���ã�LuaXunmeng
	״̬��1217��֤ͨ��
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
	��������ѳ־
	����佫�����졤����Լ
	���������ƽ׶Σ�������������Ʋ�����Ϊ����δ�ϳ�������������������ɫ���غϽ���������������
	���ã�LuaXXunzhi
	״̬��1217��֤ͨ��
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
	��������Ѫ�ᣨ����������������
	����佫����Ԭ��
	������ÿ��һ������Ⱥ�۽�ɫ������������ޱ�+2��
]]--
-----------
--[[Y��]]--
-----------
--[[
	���������ӻ�
	����佫��1v1���ν�
	������������ʱ��������������ö��ֵ�X���ơ���XΪ������ʱ��������
	���ã�LuaYanhuo
	״̬��1217��֤ͨ��
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
	������������
	����佫����SP������
	����������������������������ֵ������Խ���װ�����ڵ��Ƶ�����и�ɻ���ʹ�á�
	���ã�LuaYanzheng
	״̬��1217��֤ͨ��
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
	����������Ц
	����佫����SP������
	���������ƽ׶Σ�����Խ�һ�ŷ���������һ����ɫ���ж����ڣ��ж������С���Ц���ƵĽ�ɫ�¸��ж��׶ο�ʼʱ��������ж�����������ơ�
	���ã�LuaYanxiao
	״̬��1217��֤ͨ��
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
	������������
	����佫��SP���ĺ���
	������һ����ɫ�ĳ��ƽ׶ο�ʼʱ�����������һ���ƣ�������������غϵĳ��ƽ׶��������Σ�һ�������������ͬ�����������ƶ�ʱ���������һ����ɫ���֮�� 
	���ã�LuaYanyu
	״̬��1217��֤ͨ��
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
	��������ҫ�䣨��������
	����佫����׼������
	������ÿ�����ܵ���ɫ��ɱ�����˺�ʱ���˺���Դѡ��һ��ظ�1������������һ���ơ�
	���ã�LuaYaowu
	״̬��1217��֤ͨ��
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
	��������ҵ�ף��޶�����
	����佫�������
	���������ƽ׶Σ�����Զ�һ��������ɫ�����1������˺�����������������ֻ�ɫ�����Ƹ�һ�ţ�ʧȥ3��������ѡ��һ��������ɫ����������������Щ��ɫ��ɹ�������3������˺��Ҷ�����һ����ɫ�������2������˺��� 
	���ã�LuaYeyan
	״̬��0405��֤ͨ��
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
	���������ż�
	����佫����׼������
	������ÿ�����ܵ�1���˺�������Թۿ��ƶѶ��������ƣ�������һ�Ž���һ����ɫ��Ȼ����һ�Ž���һ����ɫ��
	���ã�LuaYiji
	״̬��1217��֤ͨ��
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
	���������ɳ�
	����佫������ʢ
	������ÿ��һ����ɫ��ָ��Ϊ��ɱ����Ŀ����������ý�ɫ��һ���ƣ�Ȼ������һ���ơ�
	���ã�LuaYicheng
	״̬��1217��֤ͨ�� 
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
	�����������죨��������
	����佫�����졤���콣
	����������Բܲ�����˺�ʱ��������˺�-1
	���ã�LuaYitian
	״̬��1217��֤ͨ��
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
	����������ӣ���������
	����佫������ͻ�ơ�����趡�SP������趡�������趡������ơ�JSP������
	���������������ֵ����2������������ɫ�ľ���-1�����������ֵС�ڻ����2��������ɫ����ľ���+1�� 
	���ã�LuaYicong
	״̬��0405֤ͨ��
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
	�����������
	����佫����ֽ�������
	���������ƽ׶ν���ʱ������Խ������������������佫���ϣ���Ϊ���衱��ÿ��һ�š��衱��������ɫ��������ľ���+1��
	���ã�LuaDIYYicong��LuaDIYYicongDistance��LuaDIYYicongClear
	״̬��1217��֤ͨ��
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
	������������
	����佫�����졤�Ź���
	���������ƽ׶Σ���ɽ����������������泯���Ƴ���Ϸ��Ϊ���ס�������������ţ����ջأ�������ɫ������ƽ׶ο�ѡ��һ�š��ס�ѯ���㣬����ͬ�⣬�ý�ɫ��������ƣ�ÿ�׶�������
	���ã�LuaXYishe��LuaXYisheAsk�����ܰ�����
	״̬��1217��֤ͨ��
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
	������������
	����佫��������
	������ÿ����ʹ�ú��ҡ�ɱ����Ŀ���ɫ����˺�ʱ������Է�ֹ���˺�����Ϊ������������һ���ơ�
	���ã�LuaXYishi
	״̬��1217��֤ͨ��
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
	�����������
	����佫���ǡ���ά
	������ÿ����ʹ��һ�ŷ���ʱ�����ʱ(��������֮ǰ)���������Թ�����Χ�ڵĽ�ɫʹ��һ�š�ɱ��
	���ã�LuaXYicai
	״̬��1217��֤ͨ��
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
	�����������أ���������
	����佫��һ���������ڽ�
	�����������װ����û�з����ƣ���ɫ��ɱ��������Ч�� 
	���ã�LuaYizhong
	״̬��0405��֤ͨ��
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
	������������
	����佫��1v1��������1v1
	������ ���ֵĻغ��ڣ���ӵ�е�װ������δ��ת���ķ�ʽ�������ƶ�ʱ������Ի��֮��
	���ã�LuaYinli
	״̬��1217��֤ͨ��
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
	������������
	����佫����SP������
	���������ƽ׶Σ����������һ�ź�ɫ�Ʋ�ָ��һ��������ɫ�����������������һ���Ʋ���������佫���ϣ���Ϊ�����������������Ϊ�ģ�
	���ã�LuaYinling��LuaYinlingClear
	״̬��1217��֤ͨ��
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
	��������Ӣ��
	����佫���֡���ᡢɽ�����
	������׼���׶ο�ʼʱ�����������ˣ������ѡ��һ��������ɫ��ѡ��һ�1.������һ���ƣ�Ȼ������X���ƣ�2.������X���ƣ�Ȼ������һ���ơ���XΪ������ʧ������ֵ��
	���ã�LuaYinghun
	״̬��1217��֤ͨ��
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
	��������Ӣ��
	����佫����׼����褡�ɽ����ߡ������
	���������ƽ׶Σ�����Զ�����һ���ơ�
	���ã�LuaYingzi
	״̬��1217��֤ͨ��
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
	��������Ӱ��
	����佫��SP���ű�
	������ÿ��һ�š��丿�ơ���Ϊ�ж��ƺ�������������ơ�
	���ã�LuaYingbing
	״̬��1217��֤ͨ��
	
	ע���˼������丿����ϵ������ϵ�ĵط���ʹ�ñ��ֲᵱ�е��丿������ԭ��
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
	��������ӹ������������
	����佫��SP��Ԭ����SP��̨��Ԭ��
	���������ƽ׶Σ��������X���ơ����ƽ׶ο�ʼʱ����������X���ơ���XΪ�ִ��������� 
	���ã�LuaYongsi
	״̬��0405��֤ͨ��
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
	���������¾�
	����佫���ơ��ӷ���
	��������һ����ɫ�ڳ��ƽ׶���ʹ�õĵ�һ����Ϊ��ɱ�����ˡ�ɱ��������Ϻ��������ƶ�ʱ�������������֮��
	���ã�LuaYongjue,LuaYongjueRecord
	״̬��1217��֤ͨ��
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
	�����������أ���������
	����佫���ǡ����
	��������������ʱ��������Ϊ�Լ�
	���ã�LuaXYuwen
	״̬��1217��֤ͨ������Դ�벻ͬ��
	��ע���������ʼǽ�����ɸ����⣬���������ͨ��
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
	������������
	����佫��һ������2013������
	������ÿ�����ܵ�һ���˺��������չʾһ�����ƣ������˺�����Դ���˺���Դ������һ����������Ͳ�ͬ�����ƣ�������ظ�1��������
	���ã�LuaYuce
	״̬��1217��֤ͨ��
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
	��������Ԯ��
	����佫��SP���ܺ�
	�����������׶ο�ʼʱ������Խ�һ��װ��������һ����ɫװ�����ڣ�������Ϊ�����ƣ������øý�ɫ����1��һ����ɫ�����ڵ�һ���ƣ�������Ϊ�����ƣ��ý�ɫ��һ���ƣ�������Ϊ�����ƣ��ý�ɫ�ظ�1��������  
	���ã�LuaYuanhu
	״̬��0405��֤ͨ��
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
--[[Z��]]--
-----------
--[[
	���������ֱ䣨��������
	����佫����ʬ����ʬ
	��������ĳ��ƽ׶ο�ʼʱ�������������-��ʬ�����+1����0�����������Ŀ���ơ�
	���ã�LuaZaibian
	״̬��1217��֤ͨ��
]]--
isZombie = function(player)		--�������Ը������ж��Ƿ�ʬ����Դ����������жϲ�ͬ
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
	������������
	����佫���֡��ϻ�
	���������ƽ׶ο�ʼʱ�����������ˣ�����Է������ƣ���Ϊ���ƶѶ�����X���ƣ�XΪ������ʧ������ֵ������ظ���ͬ�����к�����������������Ȼ����Щ�������������ƶѣ������������ơ�
	���ã�LuaZaiqi
	״̬��1217��֤ͨ��
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
	�����������գ����Ѽ���
	����佫��ɽ���˰�
	�������غϿ�ʼ�׶ο�ʼʱ��������������ﵽ3����࣬�����1���������ޣ�����ü��ܡ���Ϯ����
	���ã�LuaZaoxian
	״̬��1217��֤ͨ��
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
	����������ز����������
	����佫�����졤�ܳ�
	�������غϽ����׶ο�ʼʱ����������ƴ���13�ţ�������������������Ʋ���ʧ1������
	���ã�LuaZaoyao
	״̬��1217��֤ͨ��
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
	��������ս�񣨾��Ѽ���
	����佫��2013-3v3������
	������׼���׶ο�ʼʱ���������������м�����ɫ�����������1���������ޣ�����װ�����������ƣ�Ȼ���ü��ܡ��������͡���ꪡ���
	���ã�LuaZhanshen
	״̬��1217��֤ͨ��
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
				if lvbu:getMark(self:objectName()) == 0 and lvbu:getMark("@fight") == 0		--��ݾ�
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
	������������
	����佫����SP������
	���������ƽ׶�����ʱ�����������һ���ƣ�ָ���㹥����Χ�ڵ�һ��������ɫ�����ƶѶ���3���ƣ�������ȫ���ķǻ����ƺ͡��ҡ��������ƶѣ��ý�ɫ���ж�ѡһ����������X���˺���Ȼ���������Щ�����ƣ�������������X���ƣ�Ȼ��������Щ�����ơ���XΪ���зǻ����Ƶ���������
	���ã�LuaZhaolie��LuaZhaolieAct
	״̬��1217��֤ͨ��
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
	������������
	����佫����ֽ��˾����
	���������ƽ׶ν���ʱ�������չʾ�������ƣ������������Ϊ��ʹ��һ�š�ɱ����ÿ�׶���һ�Ρ�
	���ã�LuaZhaoxin
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ������2012������
	������ ÿ�����Ϊһ��������ɫʹ�õġ�ɱ�������ʱ������Ƶ�Ŀ��������ʧȥ1������������ƶ�����Ч��Ȼ����������һ���ơ�
	���ã�LuaZhenlie
	״̬��0405��֤ͨ��
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
	�����������ҡ���
	����佫������-һ��2������-��
	������������ж�����Чǰ������Դ��ƶѶ�����һ���ƴ���֮��
	���ã�LuaNosZhenlie
	״̬��1217��֤ͨ��
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
	��������𲶾
	����佫���󡤺�̫��
	������ÿ��һ��������ɫ�ĳ��ƽ׶ο�ʼʱ�����������һ�����ƣ������������Ϊ�ý�ɫʹ��һ�š��ơ����������ƣ���Ȼ����Ըý�ɫ���1���˺��� 
	���ã�LuaZhendu
	״̬��1217��֤ͨ��
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
	������������
	����佫�����졤���콣
	��������ġ�ɱ���������еġ���������ʱ����������øá�������
	���ã�LuaYTZhenwei
	״̬��1217��֤ͨ��
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
	����������������������
	����佫��2013-3v3����Ƹ
	�������Է���ɫ������������ɫ�ľ���+1��
	��ݾ֣��غϽ����ᣬ�����������X��������ɫ��á��ء�(XΪ��������ɫ����һ��(����ȡ��))����������ɫ������Ŀ���ɫ�ľ���ʱ��ʼ��+1��ֱ������»غϿ�ʼ��
	���ã�LuaZhenweiDistance��LuaZhenwei
	״̬��1217��֤�ɹ�
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
		else		--��ݾ�
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
	�����������棨��������
	����佫�����졤���콣
	�����������װ����û������ʱ����Ĺ�����ΧΪX��XΪ�㵱ǰ����ֵ��
]]--
--[[
	������������
	����佫�����졤��ʿ��
	������������ɫ�ĻغϿ�ʼǰ��������佫���������ϣ�����Խ�����佫�Ʒ��沢����������Ļغϣ���ĻغϽ����󣬽���ý�ɫ�Ļغ�
	���ã�LuaXZhenggong
	״̬��1217��֤ͨ��
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
	������������(0610��)
	����佫�����졤��ʿ��
	������������ɫ�ĻغϿ�ʼǰ��������佫�����泯�ϣ�����Խ���һ������Ļغϣ�Ȼ���佫�Ʒ��档
	���ã�LuaZhenggong610
	״̬��1217��֤ͨ��
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
	������������
	����佫��E.SP ����
	����������ʹ�á�ɱ��ָ��һ��Ŀ��������ѡ��һ���Ƶ��������ѡ��һ�1����һ�Ŵ������ƽ����㣬����������˴ζ������Ĵˡ�ɱ��������Ч��2������ʹ�á�������Ӧ�ˡ�ɱ���� 
	���ã�LuaConqueror
	״̬��0425��֤ͨ��
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
	��������ֱ��
	����佫��ɽ����������
	���������ƽ׶Σ�����Խ������е�һ��װ��������һ��������ɫװ�����ڣ��������������һ���ơ�
	���ã�LuaZhijian
	״̬��0405��֤ͨ��
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
	��������ֱ��
	����佫��һ������2013���ݷ�
	�����������׶ο�ʼʱ���������һ����ɫ��һ���Ʋ�չʾ֮��������Ϊװ���ƣ��ý�ɫ�ظ�1��������Ȼ��ʹ��֮��
	���ã�LuaZhiyan
	״̬��1217��֤ͨ��
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
	��������־�̣����Ѽ���
	����佫��ɽ����ά
	�������غϿ�ʼ�׶ο�ʼʱ������û�����ƣ�����ѡ��һ��ظ�1�����������������ơ�Ȼ�����1���������ޣ�����ü��ܡ����ǡ���
	���ã�LuaZhiji
	״̬��1217��֤ͨ��
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
	���������ưԣ���������
	����佫��ɽ�����
	���������ƽ׶���һ�Σ�������������ɫ�ĳ��ƽ׶ο�������ƴ�㣨�����ˡ�����������Ծܾ���ƴ�㣩������ûӮ������Ի������ƴ����ơ�
	���ã�LuaZhiba��LuaZhibaPindian�����ܰ�����
	״̬��1217��֤ͨ��
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
	���������ư�
	����佫�����ԡ��ư���Ȩ
	���������ƽ׶Σ���������������������ƣ�Ȼ����ȡ�������ơ�ÿ�׶ο���X+1�Σ�XΪ������ʧ������ֵ
	���ã�LuaXZhiBa
	״̬��1217��֤ͨ��
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
	���������ƺ�
	����佫����׼����Ȩ
	���������ƽ׶���һ�Σ��������������һ���ƣ���������������������ơ� 
	���ã�LuaZhiheng
	״̬��0405��֤ͨ��
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
	���������ǳ٣���������
	����佫��һ���������¹�
	��������Ļغ��⣬ÿ�����ܵ�һ���˺��󣬡�ɱ�������ʱ������ƶ�����Ч��ֱ���غϽ�����
	���ã�LuaZhichi��LuaZhichiProtect��LuaZhichiClear
	״̬��1217��֤ͨ��
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
	������������
	����佫����������������
	������ÿ�����ܵ��˺����������һ���ƣ������������չʾ�������ơ���������ƾ�Ϊͬһ��ɫ���˺���Դ����һ�����ơ� 
	���ã�LuaZhiyu
	״̬��0405��֤ͨ��
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
	�����������壨�޶�����
	����佫��2013-3v3������
	���������ƽ׶Σ�����Խ�һ�ź�ɫ���������佫���ϡ������С����塱�ƣ�������ɫʹ�õġ�ɱ����Ŀ���ɫ����˺�ʱ�����˺�+1����������ú��㽫�����塱���������ƶѡ�
	���ã�LuaZhongyi
	״̬��1217��֤ͨ��
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
	���������丿
	����佫��SP���ű�
	�������׶μ�������Խ�һ�������Ƴ���Ϸ��ѡ��һ���ޡ��丿�ơ���������ɫ������������ý�ɫ�����ж�ʱ���ԡ��丿�ơ���Ϊ�ж��ơ�һ����ɫ�ĻغϽ��������ý�ɫ�С��丿�ơ������ø��ơ� 
	���ã�LuaZhoufu
	״̬��1217��֤ͨ��
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
	����������¥
	����佫���������
	�������غϽ����׶ο�ʼʱ��������������ƣ�Ȼ��ʧȥ1������������һ�������ơ�
	���ã�LuaXZhulou
	״̬��1217��֤ͨ��
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
	��������׷��
	����佫����������������ʦ
	������������ʱ��������һ��������ɫ��ɱ����Ľ�ɫ���⣩�������Ʋ��ظ�1��������
	���ã�LuaZhuiyi
	״̬��1217��֤ͨ��
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
	��������㷿�
	����佫��һ������2013�����ʺ�
	������ һ��������ɫ�ĻغϿ�ʼʱ�����������ˣ����������ƴ�㣺����Ӯ���ý�ɫ�������ƽ׶Σ�����ûӮ���ý�ɫ�������Ϊ1��ֱ���غϽ�����
	���ã�LuaZhuikong��LuaZhuikongClear
	״̬��1217��֤ͨ��
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
	������������
	����佫���󡤵˰�
	������ÿ��һ����ɫ�ܵ��˺�������Խ�һ�š�������ý�ɫ��
	���ã�LuaZiliang
	״̬��1217��֤�ɹ�
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
	�����������������Ѽ���
	����佫��һ���������ӻ�
	������׼���׶ο�ʼʱ������Ȩ�����ڻ�������ţ���ʧȥ1���������ޣ��������ƻ�ظ�1��������Ȼ���á����족��
	���ã�LuaZili
	״̬��0405��֤ͨ��
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
	������������
	����佫����������������
	���������ƽ׶Σ����������ˣ�����Զ�����X���ƣ�XΪ������ʧ������ֵ����Ȼ��������ĳ��ƽ׶Ρ�
	���ã�LuaZishou
	״̬��1217��֤ͨ��
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
	�����������ң���������
	����佫����������������
	�����������������+X��XΪ�ִ�����������
	���ã�LuaZongshi
	״̬��1217��֤ͨ��
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
	���������ݻ���������
	����佫�����졤½����
	���������ɱʼ�մ��л�������
	���ã�LuaZonghuo
	״̬��1217��֤ͨ��
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
	������������
	����佫��һ������2013����Ӻ
	������ÿ����ƴ��Ӯ������Ի�öԷ���ƴ���ơ�ÿ����ƴ��ûӮ������Ի�����ƴ���ơ�
	���ã�LuaZongshih
	״̬��1217��֤ͨ��
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
	��������թ������������
	����佫������ͻ�ơ��Ƹ�
	������ÿ����ʧȥ1�����������������ƣ�����ʱΪ��Ļغϣ����غϣ�����Զ���ʹ��һ�š�ɱ������ʹ�ú�ɫ��ɱ���޾��������Ҵˡ�ɱ��ָ��Ŀ���Ŀ���ɫ����ʹ�á�������Ӧ�ˡ�ɱ���� 
	���ã�LuaZhaxiang��LuaZhaxiangRedSlash��LuaZhaxiangTargetMod
	״̬��0405��֤ͨ��
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
	������������
	����佫��һ������2013���ݷ�
	������������������ö��������ƶ�ǰ������Խ�����������������������˳�����������ƶѶ���
	���ã�LuaZongxuan
	״̬��1217��֤ͨ��
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
	�����������磨�޶�����
	����佫����SP����ͳ
	������׼���׶ο�ʼʱ������Խ��ƶѶ�����������������佫���ϡ��˺�ÿ��׼���׶ο�ʼʱ�����ظ������̣�ֱ������佫���ϳ���ͬ�����ġ������ơ���Ȼ���������С������ơ������ܷ��������������㲻��ʹ�û����������ơ��д��ڵ������ƣ�����Щ�����ƶ�����Ч��
	���ã�LuaZuixiang
	״̬��1217��֤�ɹ�
	Fsע���˼����롰��������ϵ��������ϵ����ʹ�õ�Ϊ��LUA�ֲ�ġ��������ܲ���ԭ��
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