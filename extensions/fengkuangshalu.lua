extension_fengkuangshalu = sgs.Package("shalu_general", sgs.Package_GeneralPack)

shalu_caochong = sgs.General(extension_fengkuangshalu, "shalu_caochong", "wei","3",true, true, false)
shalu_litong = sgs.General(extension_fengkuangshalu, "shalu_litong", "wei","4",true, true, false)
shalu_guojia = sgs.General(extension_fengkuangshalu, "shalu_guojia", "wei","3",true, true, false)
shalu_weiyan = sgs.General(extension_fengkuangshalu, "shalu_weiyan", "shu","4",false, true, false)

-----曹冲-----

shaluRenxin = sgs.CreateTriggerSkill{
	name = "shaluRenxin",
	can_preshow = true,
	events = {sgs.DamageInflicted},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if damage.to and damage.to:isAlive() then 
			if damage.to:getHp() <= 150 then
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
shalu_caochong:addSkill("chengxiang")
shalu_caochong:addSkill(shaluRenxin)

-----李通-----

shaluTuifeng = sgs.CreateMasochismSkill{
	name = "shaluTuifeng",
	can_preshow = true, 
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		if player:isNude() then return "" end
		local damage = data:toDamage()
		local trigger_list = {}
		return self:objectName()
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
shaluTuifengThrow = sgs.CreateTriggerSkill{
	name = "#shaluTuifeng-throw",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_Compulsory,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if player:getPhase() ~= sgs.Player_Start then return "" end
		return (player:getPile("lead"):length() > 0) and self:objectName() or ""
	end,
	on_cost = function(self, event, room, player, data)
		room:broadcastSkillInvoke("tuifeng", 1, player)
		if player:ownSkill("shaluTuifeng") and not player:hasShownSkill("shaluTuifeng") then
			player:showGeneral(player:inHeadSkills("shaluTuifeng"))
		end
		return true
	end,
	on_effect = function(self, event, room, player, data)
		local x = player:getPile("lead"):length()
		if x > 0 then
			room:sendCompulsoryTriggerLog(player, "shaluTuifeng", true)
			local dummy = sgs.DummyCard(player:getPile("lead"))
			dummy:deleteLater()
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_REMOVE_FROM_PILE, "", "tuifeng", "")
			room:throwCard(dummy, reason, nil)
			player:drawCards(2*x)
			room:setPlayerMark(player, "@lead", x)
		end
	end,
}
shaluTuifengClear = sgs.CreateTriggerSkill{
	name = "#shaluTuifeng-clear",
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
		elseif (event == sgs.EventLoseSkill) and data:toString() == "shaluTuifeng" then
			player:clearOnePrivatePile("lead")
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
shaluTuifengTargetMod = sgs.CreateTargetModSkill{
	name = "#shaluTuifeng-targetmod",
	pattern = "Slash",
	residue_func = function(self, from, card)
		return from:getMark("@lead")
	end,
}
shalu_litong:addSkill(shaluTuifeng)
shalu_litong:addSkill(shaluTuifengThrow)
shalu_litong:addSkill(shaluTuifengClear)
shalu_litong:addSkill(shaluTuifengTargetMod)
extension_fengkuangshalu:insertRelatedSkills("shaluTuifeng","#shaluTuifeng-throw")
extension_fengkuangshalu:insertRelatedSkills("shaluTuifeng","#shaluTuifeng-clear")
extension_fengkuangshalu:insertRelatedSkills("hontuifenggde","#shaluTuifeng-targetmod")

zhinangVS = sgs.CreateViewAsSkill{
	name = "zhinang",
	n = 1,
	response_or_use = true,
	view_filter = function(self, selected, to_select)
		local ids = sgs.Self:property("zhinangProp"):toString():split("+")
		if #selected == 1 then return false end
		return table.contains(ids, tostring(to_select:getId()))
	end,
	view_as = function(self, cards)
		return cards[1]
	end,
	enabled_at_response = function(self, player, pattern)
		return pattern == "@@zhinang"
	end
}
zhinang = sgs.CreateTriggerSkill{
	name = "zhinang",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.Damaged},
	can_preshow = true, 
	view_as_skill = zhinangVS,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
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
		local card_ids = room:getNCards(2, true)
		local ids = {}
		local cardNames = {}
		local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		for _, id in sgs.qlist(card_ids) do
			dummy:addSubcard(id)
			local card = sgs.Sanguosha:getCard(id)
			local need_remove = false
			if card:isKindOf("Jink") or card:isKindOf("Nullification") then
				need_remove = true
			end
			if card:isKindOf("Peach") and not player:isWounded() then
				need_remove = true
			end
			if not need_remove then
				table.insert(ids, id)
				table.insert(cardNames, card:objectName())
			end
		end
		room:obtainCard(player, dummy, false)
		local promp = "@zhinang:"
		if cardNames[1] then
			promp = promp .. cardNames[1] .. "::"
		end
		if cardNames[2] then
			promp = promp .. cardNames[2]
		end
		if #ids > 0 then
			room:setPlayerProperty(player, "zhinangProp", sgs.QVariant(table.concat(ids, "+")))
			room:askForUseCard(player, "@@zhinang", promp)
			room:setPlayerProperty(player, "zhinangProp", sgs.QVariant(""))
		end
	end
}
shaluTiandu = sgs.CreateTriggerSkill{
	name = "shaluTiandu",
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.FinishJudge},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
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
		local room = player:getRoom()
		local judge = data:toJudge()
		local card = judge.card
		local card_data = sgs.QVariant()
		card_data:setValue(card)
		if room:getCardPlace(card:getEffectiveId()) == sgs.Player_PlaceJudge then
			player:obtainCard(card)
		end
		return true
	end,
}
shalu_guojia:addSkill(zhinang)
shalu_guojia:addSkill(shaluTiandu)

-----魏延-----

shaluKuanggu = sgs.CreateTriggerSkill{
	name = "shaluKuanggu",
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
				return self:objectName()
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
		player:drawCards(1, self:objectName())
		local hp = player:getHp()
		local recover_hp = 50
		if recover_hp + hp > player:getMaxHp() then
			recover_hp = player:getMaxHp() - hp
		end
		room:setPlayerProperty(player, "hp", sgs.QVariant(hp + recover_hp))
		room:setPlayerMark(player, "@shalu1_maxhp", hp + recover_hp)
		sendMsgByFrom(room, "增加了"..recover_hp.."点体力值" , player)
		return false
	end
}
shalu_weiyan:addSkill(shaluKuanggu)
shalu_weiyan:addCompanion("huangzhong")

sgs.LoadTranslationTable{
	["shalu_general"] = "杀戮专属",

	["shalu_caochong"] = "曹冲",
	["#shalu_caochong"] = "仁爱的神童",
	["~shalu_caochong"] = "子桓哥哥……",
	["shaluRenxin"] = "仁心",
	[":shaluRenxin"] = "当其他角色受到伤害时，若其体力值不大于150，你可以弃置一张装备牌，叠置，然后防止此伤害。",
	["$shaluRenxin1"] = "仁者爱人，人恒爱之。",
	["$shaluRenxin2"] = "有我在，别怕。",
	
	["shalu_litong"] = "李通",
	["~shalu_litong"] = "战死沙场，快哉",
	["#shalu_litong"] = "万亿吾独往",
	["shaluTuifeng"] = "推锋",
	[":shaluTuifeng"] = "当你受到伤害后，你可以将一张牌置于武将牌上，称为“锋”；准备阶段开始时，若你的武将牌上有“锋”，你移去所有“锋”，摸2X张牌，若如此做，你于此回合的出牌阶段内可以多使用X张【杀】（X为你此次移去的“锋”数）。",
	["$shaluTuifeng1"] = "摧锋陷阵，以杀贼首。",
	["$shaluTuifeng2"] = "敌锋之锐，我已尽知。",
	
	["shalu_guojia"] = "郭嘉",
	["#shalu_guojia"] = "早终的先知",
	["~shalu_guojia"] = "咳，咳......",
	["shaluTiandu"] = "天妒",
	[":shaluTiandu"] = "每当你的判定牌生效后，你可以获得之。",
	["$shaluTiandu1"] = "天意如此吗？",
	["$shaluTiandu2"] = "那，就这样吧。",
	["zhinang"] = "智囊",
	[":zhinang"] = "每当你受到伤害后，你可以摸两张牌，然后你可以使用其中一张。",
	["$zhinang1"] = "以此计行，辽东可定。",
	["$zhinang2"] = "锦囊妙策，终定舍己。",
	["@zhinang"] = "你可以使用这些牌：%src %arg",
	
	["shalu_weiyan"] = "魏延",
	["#shalu_weiyan"] = "嗜血的独狼",
	["~shalu_weiyan"] = "奸贼！害我。。",
	["shaluKuanggu"] = "狂骨",
	[":shaluKuanggu"] = "每当你对距离1以内的一名角色造成伤害后，你可以增加50点体力值并且摸一张牌。 <br /><font color=\"pink\">注：增加体力值与回复体力值不同，增加体力值不计算公式。</font>",
	["$shaluKuanggu1"] = "哼！也不看看我是何人。",
	["$shaluKuanggu2"] = "嗯哈哈哈哈哈哈，赢你，还不容易！",
}
return {extension_fengkuangshalu}