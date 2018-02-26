extension = sgs.Package("strengthen", sgs.Package_GeneralPack)
xx1 = sgs.General(extension, "xx1", "wei","3",false,true,true) 
caocao = sgs.General(extension, "caocao", "wei","4",true,false,false) 
weiyan = sgs.General(extension, "weiyan", "shu","4",true,false,false)
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
xx1:addSkill(lizhan)
xx1:addSkill(zhaxiang)
xx1:addSkill(lianying)
xx1:addSkill(danqi)
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

sgs.LoadTranslationTable{
	["strengthen"] = "加强包",
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
}
return extension