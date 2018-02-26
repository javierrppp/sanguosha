extension = sgs.Package("shopping", sgs.Package_GeneralPack)


local all_products = {"peachUse","treasure1","fireGun","thunder","slashUse","getJink","getAnaleptic","getAwaitExhausted","getFireAttack","no_careerist","bet","_discard","super_discard","box","coffer","extraProduct","upgradeSoldier","getYitianjian","getShengguangbaiyi","getJuechen","getNanmanxiang"}
local forbid = {}
local sendMsg = function(room,message)
	local msg = sgs.LogMessage()
	msg.type = "#message"
	msg.arg = message
	room:sendLog(msg)
end
local sendMsgByFrom = function(room,message,player)
	local msg = sgs.LogMessage()
	msg.from = player
	msg.type = "#message1"
	msg.arg = message
	room:sendLog(msg)
end
local getNProducts = function(num,removeProducts)
	local products = {}
	local products_copy = {}
	for _, choice in pairs(all_products) do
		if not table.contains(removeProducts,choice) then
			table.insert(products_copy,choice)
		end
	end
	for i =0,num-1,1 do
		local randomNum = math.random(1,#products_copy)
		local product = products_copy[randomNum]
		table.remove(products_copy,randomNum)
		table.insert(products,product)
		if #products_copy == 0 then break end
	end
	return products
end
local addProduct = function(player,product)
	local products = player:getTag("products1"):toString():split("+") or {}
	table.insert(products,product)
	player:setTag("products1",sgs.QVariant(table.concat(products,"+")))
end
shoupaishangxian = sgs.CreateMaxCardsSkill{  --手牌上限
    name = "shoupaishangxian" ,
	global = true,
    extra_func = function(self, target)
		local x = target:getMark("@shangxianjianyi")
		local y = target:getMark("@shangxianjiayi")
		return y - x
    end
}
shoupaishangxianmarklose = sgs.CreateTriggerSkill{  --清空手牌上限mark
	name = "shoupaishangxianmarklose" ,
	events = {sgs.EventPhaseStart} ,
	global= true,
	can_trigger = function(self, event, room, player, data)
		local room = player:getRoom()
		if player:getPhase() == sgs.Player_Finish then
			if player:getMark("@shangxianjianyi") > 0 then
				player:loseAllMarks("@shangxianjianyi")
			end
			if player:getMark("@shangxianjiayi") > 0 then
				player:loseAllMarks("@shangxianjiayi")
			end
		end
		return ""
	end
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("shoupaishangxian") then
skillList:append(shoupaishangxian)
end
if not sgs.Sanguosha:getSkill("shoupaishangxianmarklose") then
skillList:append(shoupaishangxianmarklose)
end
sgs.Sanguosha:addSkills(skillList)	

xx = sgs.General(extension, "xx", "wei","30",false,true,true) 
jingruishibing1 = sgs.General(extension, "jingruishibing1", "wu","4",true,true,true)
jingruishibing2 = sgs.General(extension, "jingruishibing2", "wu","4",false,true,true)
yongmengshibing1 = sgs.General(extension, "yongmengshibing1", "wu","4",true,true,true)
yongmengshibing2 = sgs.General(extension, "yongmengshibing2", "wu","4",false,true,true)
texunshibing1 = sgs.General(extension, "texunshibing1", "wu","4",true,true,true)
texunshibing2 = sgs.General(extension, "texunshibing2", "wu","4",false,true,true)
moushi1 = sgs.General(extension, "moushi1", "wu","4",true,true,true)
moushi2 = sgs.General(extension, "moushi2", "wu","4",false,true,true)

texun = sgs.CreateTriggerSkill{
	name = "texun",
	events = {sgs.EventPhaseStart},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("texun") then return "" end
		if player:getPhase() ~= sgs.Player_Play then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		local targets = sgs.SPlayerList()
		for _, p in sgs.qlist(room:getOtherPlayers(player)) do
			if not p:isKongcheng() then
				targets:append(p)
			end
		end
		local to = room:askForPlayerChosen(player, targets, self:objectName(), self:objectName().."-invoke", true, true)
		if to then
			ask_who:showGeneral(ask_who:inHeadSkills("texun"))
			local id = room:askForCardChosen(ask_who, to, "h", self:objectName(), false)
			room:showCard(to, id)
			local card = sgs.Sanguosha:getCard(id)
			if card:isKindOf("Jink") then
				room:throwCard(card, to, ask_who)
			elseif card:isKindOf("Slash") then
				local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit, 0)
				slash:setSkillName(self:objectName())
				local use = sgs.CardUseStruct()
				use.card = slash
				use.from = ask_who
				use.to:append(to)
				room:useCard(use)
			end
			if card:isRed() and ask_who:getPhase() ~= sgs.Player_NotActive then
				ask_who:gainMark("@shangxianjiayi")
			end
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		return false
	end
}
texunshibing1:addSkill(texun)
texunshibing2:addSkill(texun)
mouceTrigger = sgs.CreateTriggerSkill{
	name = "#mouceTrigger",
	events = {sgs.EventPhaseStart,sgs.PreCardUsed,sgs.CardFinished},
	global = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("mouce") then return "" end
		if event == sgs.PreCardUsed then
			local use = data:toCardUse()
			if use.card:isKindOf("EquipCard") then
				if use.card:hasFlag("mouceFlag") then
					room:setPlayerMark(player,"@cardMark",1)
				end
			end
			return ""
		elseif event == sgs.CardFinished then
			local effect = data:toCardEffect()
			if player:getMark("cardMark") > 0 then
				room:setPlayerMark(player,"@cardMark",0)
				room:setCardFlag(effect.card, "mouceFlag")
			end
			return ""
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start then
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			ask_who:showGeneral(ask_who:inHeadSkills("mouce"))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local ids = room:getNCards(1)
		local move = sgs.CardsMoveStruct()
		move.card_ids = ids
		move.to = player
		move.to_place = sgs.Player_PlaceTable
		move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
		room:moveCardsAtomic(move, true)
		local card = sgs.Sanguosha:getCard(ids:first())
		room:getThread():delay(1500)
		room:setCardFlag(ids:first(), "mouceFlag")
		player:obtainCard(sgs.Sanguosha:getCard(ids:first()))
		return false
	end
}
mouceTrigger1 = sgs.CreateTriggerSkill{
	name = "#mouceTrigger1",
	events = {sgs.CardsMoveOneTime},
	global = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("mouce") then return "" end
		local move = data:toMoveOneTime()
		if move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip) then
			if move.to_place == sgs.Player_PlaceEquip then
				if move.to:objectName() == player:objectName() then
					if move.card_ids:length() == 1 and sgs.Sanguosha:getCard(move.card_ids:first()):isKindOf("EquipCard") then
						if sgs.Sanguosha:getCard(move.card_ids:first()):hasFlag("mouceFlag") then
							--坑
						end
					end
				end
			end
		end
		local removeFlag = false
		if move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip then
			if move.to:objectName() ~= player:objectName() then
				removeFlag = true
			end
		else
			removeFlag = true
		end
		if removeFlag then
			for _, c in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(c)
				if card:hasFlag("mouceFlag") then
					room:setCardFlag(card, "-mouceFlag")
				end
			end
		end
	end
}
mouce = sgs.CreateOneCardViewAsSkill{
	name = "mouce",
	response_or_use = true,
	view_filter = function(self, card)
		local usereason = sgs.Sanguosha:getCurrentCardUseReason()
		if usereason == sgs.CardUseStruct_CARD_USE_REASON_PLAY then
			return card:hasFlag("mouceFlag") and (card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade)
		elseif usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE or usereason == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
			local pattern = sgs.Sanguosha:getCurrentCardUsePattern()
			if pattern == "jink" then
				return card:hasFlag("mouceFlag") and card:getSuit() == sgs.Card_Diamond
			elseif pattern == "nullification" then
				return card:hasFlag("mouceFlag") and card:getSuit() == sgs.Card_Club
			end
		else
			return false
		end
	end,
	view_as = function(self, card)
		if card:getSuit() == sgs.Card_Heart then
			local peach = sgs.Sanguosha:cloneCard("peach", card:getSuit(), card:getNumber())
			peach:addSubcard(card:getId())
			peach:setSkillName(self:objectName())
			return peach
		elseif card:getSuit() == sgs.Card_Diamond then
			local jink = sgs.Sanguosha:cloneCard("jink",card:getSuit(),card:getNumber())
			jink:setSkillName(self:objectName())
			jink:addSubcard(card:getId())
			return jink
		elseif card:getSuit() == sgs.Card_Spade then
			local duel = sgs.Sanguosha:cloneCard("duel",card:getSuit(),card:getNumber())
			duel:setSkillName(self:objectName())
			duel:addSubcard(card:getId())
			return duel
		elseif card:getSuit() == sgs.Card_Club then
			local nullification = sgs.Sanguosha:cloneCard("nullification",card:getSuit(),card:getNumber())
			nullification:setSkillName(self:objectName())
			nullification:addSubcard(card:getId())
			return nullification
		end
	end,
	enabled_at_play = function(self, player)
		local has = false
		for _,c in sgs.qlist(sgs.Self:getHandcards()) do
			if c:hasFlag("mouceFlag") and c:getSuit() ~= sgs.Card_Club and c:getSuit() ~= sgs.Card_Diamond then
				has = true
				break
			end
		end
		for _,c in sgs.qlist(sgs.Self:getEquips()) do
			if c:hasFlag("mouceFlag") and c:getSuit() ~= sgs.Card_Club and c:getSuit() ~= sgs.Card_Diamond then
				has = true
				break
			end
		end
		return has
	end, 
	enabled_at_response = function(self, player, pattern)
		return pattern == "jink" or pattern == "nullification"
	end,
	enabled_at_nullification = function(self, player)
		local has_null = false
		for _,c in sgs.qlist(player:getHandcards()) do
			if c:hasFlag("mouceFlag") then
				if c:getSuit() == sgs.Card_Club then
					return true
				end
			end
		end
		for _,c in sgs.qlist(player:getEquips()) do
			if c:hasFlag("mouceFlag") then
				if c:getSuit() == sgs.Card_Club then
					return true
				end
			end
		end
		return false
	end
}
mouceClear = sgs.CreateTriggerSkill{
	name = "#mouceClear",
	events = {sgs.EventPhaseStart},
	global = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("mouce") then return "" end
		if player:getPhase() == sgs.Player_Start then
			for _,c in sgs.qlist(player:getHandcards()) do
				if c:hasFlag("mouceFlag") then
					room:setCardFlag(c, "-mouceFlag")
				end
			end
			for _,c in sgs.qlist(player:getEquips()) do
				if c:hasFlag("mouceFlag") then
					room:setCardFlag(c, "-mouceFlag")
				end
			end
		end
		return ""
	end,
	priority = 100
}
moushi1:addSkill(mouce)
moushi1:addSkill(mouceTrigger)
moushi1:addSkill(mouceTrigger1)
moushi1:addSkill(mouceClear)
moushi2:addSkill(mouce)
moushi2:addSkill(mouceTrigger)
moushi2:addSkill(mouceTrigger1)
moushi2:addSkill(mouceClear)
extension:insertRelatedSkills("mouce","#mouceTrigger")
extension:insertRelatedSkills("mouce","#mouceTrigger1")
extension:insertRelatedSkills("mouce","#mouceClear")
jingbing = sgs.CreateTriggerSkill{
	name = "jingbing",
	events = {sgs.DamageCaused,sgs.EventPhaseStart},
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local jingbing = room:findPlayerBySkillName(self:objectName())
		if jingbing then
			if event == sgs.DamageCaused then
				local damage = data:toDamage()
				if damage.from:objectName() ~= player:objectName() then return "" end
				if damage.from:objectName() ~= room:getCurrent():objectName() then return "" end
				if damage.to:objectName() == jingbing:objectName() then
					room:setPlayerMark(jingbing,"jingbingmark",1)
					return ""
				end
			elseif event == sgs.EventPhaseStart then
				if player:getPhase() == sgs.Player_Finish then
					if jingbing:getMark("jingbingmark") > 0 then
						room:setPlayerMark(jingbing,"jingbingmark",0)
						if player:isKongcheng() then return "" end
						return self:objectName(),jingbing:objectName()
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
		local card = room:askForCard(player, ".|.|.|hand!", "@jingbing", data, sgs.Card_MethodNone, ask_who)
		if card then
			ask_who:obtainCard(card)
		end
		return false
	end
}
jingruishibing1:addSkill(jingbing)
jingruishibing2:addSkill(jingbing)
yongmengTrigger = sgs.CreateTriggerSkill{
	name = "#yongmengTrigger",
	events = {sgs.EventPhaseStart},
	global = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("yongmeng") then return "" end
		if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data,ask_who)
		if room:askForSkillInvoke(ask_who,self:objectName(),data) then
			ask_who:showGeneral(ask_who:inHeadSkills("yongmeng"))
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		room:broadcastSkillInvoke(self:objectName())
		local ids = room:getNCards(1)
		local move = sgs.CardsMoveStruct()
		move.card_ids = ids
		move.to = player
		move.to_place = sgs.Player_PlaceTable
		move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_TURNOVER, player:objectName(), self:objectName(), nil)
		room:moveCardsAtomic(move, true)
		local card = sgs.Sanguosha:getCard(ids:first())
		player:gainMark("@q"..card:getSuitString())
		room:getThread():delay(1500)
		room:throwCard(ids:first(),player)
		if player:getPhase() == sgs.Player_Start then
			room:setPlayerMark(player,"phaseMark",1)  
		elseif player:getPhase() == sgs.Player_Finish then
			room:setPlayerMark(player,"phaseMark",2)
		end
		return false
	end
}
yongmengClear = sgs.CreateTriggerSkill{
	name = "#yongmengClear",
	events = {sgs.CardUsed,sgs.CardResponded,sgs.EventPhaseStart},
	global = true,
	frequency = sgs.Skill_NotFrequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if not player:hasSkill("yongmeng") then return "" end
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.card:getSkillName() == "yongmeng" then
				room:setPlayerMark(player,"@qspade",0)
				room:setPlayerMark(player,"@qheart",0)
				room:setPlayerMark(player,"@qclub",0)
				room:setPlayerMark(player,"@qdiamond",0)
			end
		elseif event == sgs.CardResponded then
			local card_star = data:toCardResponse().m_card
			local room = player:getRoom()
			if card_star:getSkillName() == "yongmeng" then
				room:setPlayerMark(player,"@qspade",0)
				room:setPlayerMark(player,"@qheart",0)
				room:setPlayerMark(player,"@qclub",0)
				room:setPlayerMark(player,"@qdiamond",0)
			end
		elseif event == sgs.EventPhaseStart then
			if player:getPhase() == sgs.Player_Start or player:getPhase() == sgs.Player_Finish then
				room:setPlayerMark(player,"@phaseMark",0)
				room:setPlayerMark(player,"@qspade",0)
				room:setPlayerMark(player,"@qheart",0)
				room:setPlayerMark(player,"@qclub",0)
				room:setPlayerMark(player,"@qdiamond",0)
			end
		end
		return ""
	end,
	priority = 100
}
yongmeng = sgs.CreateOneCardViewAsSkill{
	name = "yongmeng",
	response_or_use = true,
	view_filter = function(self, card)
		if sgs.Self:getMark("@qspade") > 0 then
			return card:getSuit() == sgs.Card_Spade
		elseif sgs.Self:getMark("@qheart") > 0 then
			return card:getSuit() == sgs.Card_Heart
		elseif sgs.Self:getMark("@qclub") > 0 then
			return card:getSuit() == sgs.Card_Club
		elseif sgs.Self:getMark("@qdiamond") > 0 then
			return card:getSuit() == sgs.Card_Diamond
		end
	end,
	view_as = function(self, card)
		if sgs.Self:getMark("phaseMark") == 1 then
			local slash = sgs.Sanguosha:cloneCard("slash", card:getSuit(), card:getNumber())
			slash:addSubcard(card:getId())
			slash:setSkillName(self:objectName())
			return slash
		elseif sgs.Self:getMark("phaseMark") == 2 then
			local jink = sgs.Sanguosha:cloneCard("jink",card:getSuit(),card:getNumber())
			jink:setSkillName(self:objectName())
			jink:addSubcard(card:getId())
			jink:setSkillName(self:objectName())
			return jink
		end
	end,
	enabled_at_play = function(self, player)
		if sgs.Self:getMark("phaseMark") == 1 then
			return sgs.Slash_IsAvailable(player)
		end
		return true
	end, 
	enabled_at_response = function(self, player, pattern)
		if sgs.Self:getMark("phaseMark") == 1 then
			return pattern == "slash"
		elseif sgs.Self:getMark("phaseMark") == 2 then
			return pattern == "jink"
		end
	end
}
yongmengshibing1:addSkill(yongmeng)
yongmengshibing2:addSkill(yongmeng)
yongmengshibing1:addSkill(yongmengTrigger)
yongmengshibing2:addSkill(yongmengTrigger)
yongmengshibing1:addSkill(yongmengClear)
yongmengshibing2:addSkill(yongmengClear)
extension:insertRelatedSkills("yongmeng","#yongmengTrigger")
extension:insertRelatedSkills("yongmeng","#yongmengClear")

shopCard = sgs.CreateSkillCard{
	name = "shopCard",
	target_fixed = true,
	mute = true,
	on_use = function(self, room, source, targets)
		local products = source:getTag("products1"):toString():split("+") or {}
		local do_not_choose = source:getTag("do_not_choose"):toString():split("+") or {}
		--sendMsg(room,source:getTag("products1"):toString())
		local choices = table.copyFrom(products)
		table.insert(choices,"cancel")
		local i = 0
		local j = 0
		local productstr = ""
		for _, p in pairs(choices) do
			if i == 0 then
				productstr = productstr..p
			else
				productstr = productstr.."+"..p
			end
			i = i + 1 
			j = j + 1
			if i == 5 then
				i = 0
				if j < #choices then
					productstr = productstr.."|"
				end
			end
		end
		room:setEmotion(source, "shop")
		local product_choice = room:askForChoice(source, "shop",productstr)
		sendMsg(room,"choice:"..product_choice)
		if product_choice == "peachUse" then
			if source:getMark("@coin") < 5 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			if not source:isWounded() then sendMsg(room,"未受到伤害，不能使用桃") room:broadcastSkillInvoke("shop",3) return false end
			source:loseMark("@coin",5)
			local peach = sgs.Sanguosha:cloneCard("peach",sgs.Card_NoSuit, 0)
			peach:setSkillName(self:objectName())
			local use = sgs.CardUseStruct()
			use.card = peach
			use.from = source
			use.to:append(source)
			room:useCard(use)
		elseif product_choice == "slashUse" then
			local targets = sgs.SPlayerList()
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if source:inMyAttackRange(p) then
				    if source:canSlash(p, nil, false) then 
						targets:append(p)
					end
				end
			end
			if targets:length() == 0 then sendMsg(room,"没有可以指定的角色") room:broadcastSkillInvoke("shop",3) return false end
			if source:getMark("@coin") < 3 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local dest = room:askForPlayerChosen(source, targets, "shopSlash","shop-slash-invoke",true,true)
			if dest then
				room:setEmotion(source,"slash")
				source:loseMark("@coin",3)
				local slash = sgs.Sanguosha:cloneCard("slash",sgs.Card_NoSuit, 0)
				slash:setSkillName(self:objectName())
				local use = sgs.CardUseStruct()
				use.card = slash
				use.from = source
				use.to:append(dest)
				room:useCard(use)
			else
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
		elseif product_choice == "fireGun" then
			local targets = sgs.SPlayerList()
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if source:inMyAttackRange(p) then
					targets:append(p)
				end
			end
			if targets:length() == 0 then sendMsg(room,"没有可以指定的角色") room:broadcastSkillInvoke("shop",3) return false end
			if source:getMark("@coin") < 5 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local dest = room:askForPlayerChosen(source, targets, "shopFireGun","shop-fireGun-invoke",true,true)
			if dest then
				room:setEmotion(source,"fireGun")
				source:loseMark("@coin",5)
				local damage = sgs.DamageStruct()
				damage.from = source
				damage.to = dest
				damage.damage = 1
				damage.nature = sgs.DamageStruct_Fire
				room:damage(damage)
			else
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
		elseif product_choice == "thunder" then
			local targets = sgs.SPlayerList()
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if source:inMyAttackRange(p) then
					targets:append(p)
				end
			end
			if targets:length() == 0 then sendMsg(room,"没有可以指定的角色") room:broadcastSkillInvoke("shop",3) return false end
			if source:getMark("@coin") < 4 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local dest = room:askForPlayerChosen(source, targets, "shopThunder","shop-thunder-invoke",true,true)
			if dest then
				room:setEmotion(source,"thunder")
				source:loseMark("@coin",4)
				local damage = sgs.DamageStruct()
				damage.from = source
				damage.to = dest
				damage.damage = 1
				damage.nature = sgs.DamageStruct_Thunder
				room:damage(damage)
			else
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
		elseif product_choice == "treasure1" then
			if source:getMark("@coin") < 6 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			room:setEmotion(source, "treasure1")
			source:loseMark("@coin",6)
			source:drawCards(3)
			if math.random(1,2) == 1 then
				source:gainMark("@coin")
				room:setEmotion(source, "coin")
				room:broadcastSkillInvoke("shop",1)
			end
		elseif product_choice == "upgradeSoldier" then
			if source:getMark("@coin") < 12 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local choices = {}
			if source:getGeneralName() == "sujiang" or source:getGeneralName() == "sujiangf" then
				sendMsg(room,source:getGender())
				table.insert(choices,"headChoose")
			elseif source:getGeneral2Name() == "sujiang" or source:getGeneral2Name() == "sujiangf" then
				table.insert(choices,"deputyChoose")
			end
			local choice
			if #choices > 0 then
				choice = room:askForChoice(source, "shopGeneralChoose", table.concat(choices, "+"))
			end
				sendMsg(room,#choices)
			
			local generals = {}
			if (choice == "headChoose" and source:getGeneral():getGender() == sgs.General_Male) or (choice == "deputyChoose" and source:getGeneral2():getGender() == sgs.General_Male) then
				if not table.contains(forbid,"jingruishibing1") then
					table.insert(generals,"jingruishibing1")
				end
				if not table.contains(forbid,"yongmengshibing1") then
					table.insert(generals,"yongmengshibing1")
				end
				if not table.contains(forbid,"texunshibing1") then
					table.insert(generals,"texunshibing1")
				end
				if not table.contains(forbid,"moushi1") then
					table.insert(generals,"moushi1")
				end
			elseif (choice == "headChoose" and source:getGeneral():getGender() == sgs.General_Female) or (choice == "deputyChoose" and source:getGeneral2():getGender() == sgs.General_Female) then
				if not table.contains(forbid,"jingruishibing2") then
					table.insert(generals,"jingruishibing2")
				end
				if not table.contains(forbid,"yongmengshibing2") then
					table.insert(generals,"yongmengshibing2")
				end
				if not table.contains(forbid,"texunshibing2") then
					table.insert(generals,"texunshibing2")
				end
				if not table.contains(forbid,"moushi2") then
					table.insert(generals,"moushi2")
				end
			end
			local general_choices = {}
			for i=1,2,1 do
				if #generals == 0 then break end
				local randomNum = math.random(1,#generals)
				table.insert(general_choices,generals[randomNum])
				table.remove(generals,randomNum)
			end
			if #general_choices == 0 then sendMsg(room,"很遗憾，已经没有能训练的士兵了") room:broadcastSkillInvoke("shop",3) return false end
			local g = room:askForGeneral(source, table.concat(general_choices,"+"), general_choices[1], true)
			if g then
				room:doSuperLightbox("shengji", "upgradeSoldier1")
				if choice == "headChoose" then
					room:changePlayerGeneral(source, g)
					source:loseMark("@coin",12)
					local general = sgs.Sanguosha:getGeneral(g)
					for _,skill in sgs.list(general:getVisibleSkillList(true,false)) do
						if skill:isVisible() then
							room:acquireSkill(source, skill,true,true)
						end
					end
				else
					room:changePlayerGeneral2(source, g)
					source:loseMark("@coin",12)
					local general = sgs.Sanguosha:getGeneral(g)
					for _,skill in sgs.list(general:getVisibleSkillList(true,false)) do
						if skill:isVisible() then
							room:acquireSkill(source, skill,true,false)
						end
					end
				end
				local a = string.sub(g,1,string.len(g) - 1)
				local j1 = a.."1"
				local j2 = a.."2"
				table.insert(forbid,j1)
				table.insert(forbid,j2)
			end
		elseif product_choice == "box" then
			if source:getMark("@coin") < 6 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("@box") > 0 then
					sendMsg(room,"收纳箱只能一个人拥有") room:broadcastSkillInvoke("shop",3)
					return false
				end
			end
			room:setEmotion(source, "box")
			source:loseMark("@coin",6)
			source:gainMark("@box")
			--for i = 1 , #all_products, 1 do if all_products[i] == product_choice then table.remove(all_products,i) break end end
			--room:setEmotion(source, "coin")
			--room:broadcastSkillInvoke("shop",1)
		elseif product_choice == "extraProduct" then
			if source:getMark("@coin") < 2 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			room:setEmotion(source,"upgrade")
			source:loseMark("@coin",2)
			if source:getMark("@extraProduct") > 0 then
				source:loseMark("@extraProduct")
				source:gainMark("@extraProduct2")
			else
				source:gainMark("@extraProduct")
			end
		elseif product_choice == "coffer" then
			if source:getMark("@coin") < 7 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("@coffer") > 0 then
					sendMsg(room,"保险箱只能一个人拥有") room:broadcastSkillInvoke("shop",3)
					return false
				end
			end
			source:loseMark("@coin",7)
			source:gainMark("@coffer")
			room:setEmotion(source, "coffer")
			room:doLightbox("$coffer",1200)
			local password = room:askForChoice(source, "password","1+2+3+4+5+6+7")
			local num_table = {}
			for i = 1, 7 ,1 do
				table.insert(num_table,i)
			end
			source:setTag("password_not_selected",sgs.QVariant(table.concat(num_table,"+")))
			source:setTag("password",sgs.QVariant(password))
		elseif product_choice == "no_careerist" then
			if source:getMark("@coin") < 12 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			source:loseMark("@coin",12)
			if not source:hasShownOneGeneral() then sendMsg(room,"你还没有亮出武将") room:broadcastSkillInvoke("shop",3) return false end
			if source:getRole() ~= "careerist" then sendMsg(room,"只有野心家才能用") room:broadcastSkillInvoke("shop",3) return false end
			sendMsgByFrom(room,"在商店购买了“恢复原始身份”，将势力调整为国家势力",source)
			room:doSuperLightbox("huitoushian", "no_careerist1")
			room:setPlayerProperty(source, "role", sgs.QVariant(source:getKingdom()))
			local no_enemy = true
			for _, p in sgs.qlist(room:getOtherPlayers(source)) do
				if p:getKingdom() ~= source:getKingdom() or p:getRole() == "careerist" then
					no_enemy = false
				end
			end
			if no_enemy then
				room:gameOver(source:objectName()) --有问题
			end
		elseif product_choice == "bet" then
			if source:getMark("@coin") < 2 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			room:setEmotion(source,"bet")
			source:loseMark("@coin",2)
			local num = math.random(1,100)
			if num >= 1 and num <= 25 then
				source:drawCards(1)
				sendMsgByFrom(room,"在商店购买了“赌博”，摸了一张牌",source)
			elseif num >= 26 and num <= 50 then
				source:gainMark("@coin")
				room:setEmotion(source, "coin")
				room:broadcastSkillInvoke("shop",1)
				sendMsgByFrom(room,"在商店购买了“赌博”，获得了一个金币",source)
			elseif num >= 51 and num < 65 then
				local damage = sgs.DamageStruct()
				damage.to = source
				damage.from = nil
				damage.damage = 1
				room:damage(damage)
				room:setEmotion(source, "bad")
				room:broadcastSkillInvoke("shop",3)
				sendMsgByFrom(room,"在商店购买了“赌博”，受到了一点伤害",source)
			elseif num >= 66 and num < 80 then
				source:drawCards(2)
				sendMsgByFrom(room,"在商店购买了“赌博”，摸了两张牌",source)
			elseif num >= 81 and num < 92 then
				source:gainMark("@coin",2)
				room:setEmotion(source, "coin")
				room:broadcastSkillInvoke("shop",1)
				sendMsgByFrom(room,"在商店购买了“赌博”，获得了两个金币",source)
			elseif num >= 93 and num <= 100 then
				source:gainMark("@coin",3)
				room:setEmotion(source, "coin")
				room:broadcastSkillInvoke("shop",1)
				room:broadcastSkillInvoke("shop",2)
				room:setEmotion(source, "lucky")
				sendMsgByFrom(room,"在商店购买了“赌博”，获得了三个金币",source)
			end
		elseif product_choice == "getJink" then
			if source:getMark("@coin") < 3 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local DiscardPile = room:getDiscardPile()
			local card = nil
			for _,cid in sgs.qlist(DiscardPile) do
				local cd = sgs.Sanguosha:getCard(cid)
				if cd:isKindOf("Jink") then
					card = cd
					break
				end
			end
			if card == nil then
				local DiscardPile = room:getDrawPile()
				for _,cid in sgs.qlist(DiscardPile) do
					local cd = sgs.Sanguosha:getCard(cid)
					if cd:isKindOf("Jink") then
						card = cd
						break
					end
				end
			end
			if card == nil then sendMsg(room,"当前弃牌堆与摸牌堆均没有【闪】") room:broadcastSkillInvoke("shop",3) return false end
			sendMsgByFrom(room,"在商店购买了“召唤【闪】”，获得了一张【闪】",source)
			source:loseMark("@coin",3)
			source:obtainCard(card)
		elseif product_choice == "_discard" then
			if source:getMark("@coin") < 2 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local targets = sgs.SPlayerList()
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if not p:isAllNude() then
					targets:append(p)
				end
			end
			if targets:length() == 0 then sendMsg(room,"没有可以指定的角色") room:broadcastSkillInvoke("shop",3) return false end
			local dest = room:askForPlayerChosen(source, targets, "shopDiscard","shop-discard-invoke",true,true)
			if dest then
				room:setEmotion(source, "_discard")
				source:loseMark("@coin",2)
				local id = room:askForCardChosen(source, dest, "hej", self:getSkillName(), false)
				local card = sgs.Sanguosha:getCard(id)
				sendMsgByFrom(room,"在商店购买了“偷袭”，拆掉对方一张牌",source)
				local ids = sgs.IntList()
				ids:append(id)
				local move = sgs.CardsMoveStruct()
				move.card_ids = ids
				move.to_place = sgs.Player_DiscardPile
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, source:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
			else
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
		elseif product_choice == "super_discard" then
			if source:getMark("@coin") < 4 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local targets = sgs.SPlayerList()
		    for _, p in sgs.qlist(room:getOtherPlayers(source)) do
			    if not p:isAllNude() then
					targets:append(p)
				end
			end
			if targets:length() == 0 then sendMsg(room,"没有可以指定的角色") room:broadcastSkillInvoke("shop",3) return false end
			local dest = room:askForPlayerChosen(source, targets, "shopSuperDiscard","shop-super-discard-invoke",true,true)
			if dest then
				room:setEmotion(source, "super_discard")
				source:loseMark("@coin",4)
				local id = room:askForCardChosen(source, dest, "hej", self:getSkillName(), false)
				local ids = sgs.IntList()
				ids:append(id)
				local card = sgs.Sanguosha:getCard(id)
				sendMsgByFrom(room,"在商店购买了“强力偷袭”，拆掉对方一张牌",source)
				local move = sgs.CardsMoveStruct()
				move.card_ids = ids
				move.to_place = sgs.Player_DiscardPile
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, source:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
				if dest:isAllNude() then return false end
				local id1 = room:askForCardChosen(source, dest, "hej", self:getSkillName(), false)
				local ids1 = sgs.IntList()
				ids1:append(id1)
				local card1 = sgs.Sanguosha:getCard(id1)
				sendMsgByFrom(room,"的“强力偷袭”生效，拆掉对方一张牌",source)
				local move = sgs.CardsMoveStruct()   --解决收纳箱bug
				move.card_ids = ids1
				move.to_place = sgs.Player_DiscardPile
				move.reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_DISCARD, source:objectName(), self:objectName(), nil)
				room:moveCardsAtomic(move, true)
			else
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
		elseif product_choice == "getYitianjian" then
			if source:getMark("@coin") < 8 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for i = 0, 10000 do
				local card = sgs.Sanguosha:getEngineCard(i)
				if card == nil then break end
				if card:isKindOf("Yitianjian") then
					--room:setPlayerMark(source,"yitianjianMark",1)
					source:gainMark("yitianjianMark")
					source:obtainCard(card)
					source:loseMark("@coin",8)
				end
			end
		elseif product_choice == "getJuechen" then
			if source:getMark("@coin") < 8 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for i = 0, 10000 do
				local card = sgs.Sanguosha:getEngineCard(i)
				if card == nil then break end
				if card:objectName() == "juechen" then
					room:setPlayerMark(source,"juechenMark",1)
					source:obtainCard(card)
					source:loseMark("@coin",8)
				end
			end
		elseif product_choice == "getNanmanxiang" then
			if source:getMark("@coin") < 7 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for i = 0, 10000 do
				local card = sgs.Sanguosha:getEngineCard(i)
				if card == nil then break end
				if card:objectName() == "nanmanxiang" then
					room:setPlayerMark(source,"nanmanxiangMark",1)
					source:obtainCard(card)
					source:loseMark("@coin",7)
				end
			end
		elseif product_choice == "getShengguangbaiyi" then
			if source:getMark("@coin") < 8 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			for i = 0, 10000 do
				local card = sgs.Sanguosha:getEngineCard(i)
				if card == nil then break end
				if card:isKindOf("Shengguangbaiyi") then
					room:setPlayerMark(source,"shengguangbaiyiMark",1)
					source:obtainCard(card)
					source:loseMark("@coin",8)
				end
			end
		elseif product_choice == "getAnaleptic" then
			if source:getMark("@coin") < 3 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local DiscardPile = room:getDiscardPile()
			local card = nil
			for _,cid in sgs.qlist(DiscardPile) do
				local cd = sgs.Sanguosha:getCard(cid)
				if cd:isKindOf("Analeptic") then
					card = cd
					break
				end
			end
			if card == nil then
				local DiscardPile = room:getDrawPile()
				for _,cid in sgs.qlist(DiscardPile) do
					local cd = sgs.Sanguosha:getCard(cid)
					if cd:isKindOf("Analeptic") then
						card = cd
						break
					end
				end
			end
			if card == nil then sendMsg(room,"当前弃牌堆与摸牌堆均没有【酒】")
				room:broadcastSkillInvoke("shop",3) 
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false 
			end
			sendMsgByFrom(room,"在商店购买了“召唤【酒】”，获得了一张【酒】",source)
			source:loseMark("@coin",3)
			source:obtainCard(card)
		elseif product_choice == "getAwaitExhausted" then
			if source:getMark("@coin") < 4 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local DiscardPile = room:getDiscardPile()
			local card = nil
			for _,cid in sgs.qlist(DiscardPile) do
				local cd = sgs.Sanguosha:getCard(cid)
				if cd:isKindOf("AwaitExhausted") then
					card = cd
					break
				end
			end
			if card == nil then
				local DiscardPile = room:getDrawPile()
				for _,cid in sgs.qlist(DiscardPile) do
					local cd = sgs.Sanguosha:getCard(cid)
					if cd:isKindOf("AwaitExhausted") then
						card = cd
						break
					end
				end
			end
			if card == nil then sendMsg(room,"当前弃牌堆与摸牌堆均没有【以逸待劳】") 
				room:broadcastSkillInvoke("shop",3) 
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false 
			end
			sendMsgByFrom(room,"在商店购买了“召唤【以逸待劳】”，获得了一张【以逸待劳】",source)
			source:loseMark("@coin",4)
			source:obtainCard(card)
		elseif product_choice == "getFireAttack" then
			if source:getMark("@coin") < 3 then sendMsg(room,"铜钱不够") room:broadcastSkillInvoke("shop",3) return false end
			local DiscardPile = room:getDiscardPile()
			local card = nil
			for _,cid in sgs.qlist(DiscardPile) do
				local cd = sgs.Sanguosha:getCard(cid)
				if cd:isKindOf("FireAttack") then
					card = cd
					break
				end
			end
			if card == nil then
				local DiscardPile = room:getDrawPile()
				for _,cid in sgs.qlist(DiscardPile) do
					local cd = sgs.Sanguosha:getCard(cid)
					if cd:isKindOf("FireAttack") then
						card = cd
						break
					end
				end
			end
			if card == nil then sendMsg(room,"当前弃牌堆与摸牌堆均没有【火攻】") 
				room:broadcastSkillInvoke("shop",3) 
				table.insert(do_not_choose,product_choice)
				source:setTag("do_not_choose",sgs.QVariant(table.concat(do_not_choose,"+")))
				return false
			end
			sendMsgByFrom(room,"在商店购买了“召唤【火攻】”，获得了一张【火攻】",source)
			source:loseMark("@coin",3)
			source:obtainCard(card)
		elseif product_choice == "cancel" then
			source:setTag("do_not",sgs.QVariant(true))
			return false
		end
		if product_choice ~= "cancel" then
			room:broadcastSkillInvoke("shop",4)
			room:addPlayerMark(source,"buyNum",1)
		end
		for i = 1 , #products, 1 do if products[i] == product_choice then table.remove(products,i) break end end
		source:setTag("products1",sgs.QVariant(table.concat(products,"+")))
	end
}
shop = sgs.CreateZeroCardViewAsSkill{
	name = "shop",
	view_as = function(self, cards)
		local shopCard = shopCard:clone()
		shopCard:setSkillName(self:objectName())
		return shopCard
	end,
	enabled_at_play = function(self, player)
		return player:getMark("buyNum") < 2
	end,
}
shopTrigger = sgs.CreateTriggerSkill{
	name = "#shopTrigger",
	global = true,
	priority = 0,  --先进行君主替换
	events = {sgs.GameStart,sgs.EventPhaseEnd,sgs.DamageCaused,sgs.Damaged,sgs.Death,sgs.EventPhaseStart,sgs.CardsMoveOneTime,sgs.BeforeCardsMove},
	can_trigger = function(self, event, room, player, data)
		if event == sgs.GameStart then
			if player ~= nil then return "" end
			for _,player in sgs.qlist(room:getAllPlayers()) do
				player:gainMark("@coin",player:getMaxHp())
				--player:gainMark("@coin",100)     --测试用
				room:setEmotion(player, "coin")
				room:broadcastSkillInvoke("shop",1)
				room:acquireSkill(player,shop)
			end
		elseif event == sgs.EventPhaseStart then
			if not (player and player:isAlive()) then return "" end
			if player:getPhase() == sgs.Player_Play then
				player:setTag("do_not_choose",sgs.QVariant())
				player:setTag("do_not",sgs.QVariant(false))
				local removeProducts = {}
				for _, p in sgs.qlist(room:getAlivePlayers()) do
					if p:getMark("@box") > 0 then
						table.insert(removeProducts,"box")
					end
					if p:getMark("@coffer") > 0 then
						table.insert(removeProducts,"coffer")
					end
					local cards = p:getHandcards()
					for _, c in sgs.qlist(p:getEquips()) do
						cards:append(c)
					end
					for _, c in sgs.qlist(cards) do
						if c:isKindOf("Yitianjian") then
							table.insert(removeProducts,"getYitianjian")
						end
					end
					for _, c in sgs.qlist(cards) do
						if c:isKindOf("Shengguangbaiyi") then
							table.insert(removeProducts,"getShengguangbaiyi")
						end
					end
					for _, c in sgs.qlist(cards) do
						if c:objectName() == "juechen" then
							table.insert(removeProducts,"getJuechen")
						end
					end
					for _, c in sgs.qlist(cards) do
						if c:objectName() == "nanmanxiang" then
							table.insert(removeProducts,"getNanmanxiang")
						end
					end
				end
				if player:getGeneralName() ~= "sujiang" and player:getGeneral2Name() ~= "sujiang" and player:getGeneralName() ~= "sujiangf" and player:getGeneral2Name() ~= "sujiangf" then
					table.insert(removeProducts,"upgradeSoldier")
				end
				if player:getRole() ~= "careerist" then table.insert(removeProducts,"no_careerist") end
				if player:getMark("@extraProduct") > 1 or player:getMark("@extraProduct2") > 0 then table.insert(removeProducts,"extraProduct") end
				local num = 0
				if player:getMark("@extraProduct") > 0 then
					num = 1
				end
				if player:getMark("@extraProduct2") > 0 then
					num = 2
				end
				products = getNProducts(3+num,removeProducts)    --测试时可把这一行的数字改为商品总数的大小，方便测试
				player:setTag("products1",sgs.QVariant(table.concat(products,"+")))
			elseif player:getPhase() == sgs.Player_Start then
				local num = math.random(1,100)
				if num >=1 and num <= 50 then
				elseif num >= 51 and num <= 80 then
					player:gainMark("@coin")
					room:broadcastSkillInvoke("shop",1)
					room:setEmotion(player, "coin")
				elseif num >= 81 and num <= 95 then
					player:gainMark("@coin",2)
					room:broadcastSkillInvoke("shop",1)
					room:setEmotion(player, "coin")
				elseif num >= 96 and num <= 100 then
					player:gainMark("@coin",3)
					room:broadcastSkillInvoke("shop",1)
					room:setEmotion(player, "coin")
					room:broadcastSkillInvoke("shop",2)
					room:setEmotion(player, "lucky")
				end
				if player:getMark("@box") > 0 then   --收纳箱操作
					player:loseMark("@box")
					local card_ids = player:getPile("box_cards")
					if card_ids:length() == 0 then return false end
					room:fillAG(card_ids, player)	
					local to_back = room:askForAG(player, card_ids, false, self:objectName())
					room:clearAG()
					local dummy = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					local dummy1 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
					local remain_card_ids = sgs.IntList()
					for _, id in sgs.qlist(card_ids) do
						if sgs.Sanguosha:getCard(id):getSuit() == sgs.Sanguosha:getCard(to_back):getSuit() then
							dummy:addSubcard(sgs.Sanguosha:getCard(id))
						else
							dummy1:addSubcard(sgs.Sanguosha:getCard(id))
							remain_card_ids:append(id)
						end
					end
					room:obtainCard(player, dummy, false)
					local suit = nil
					if sgs.Sanguosha:getCard(to_back):getSuitString() == "spade" then suit = "黑桃"
					elseif sgs.Sanguosha:getCard(to_back):getSuitString() == "heart" then suit = "红桃"
					elseif sgs.Sanguosha:getCard(to_back):getSuitString() == "club" then suit = "梅花"
					elseif sgs.Sanguosha:getCard(to_back):getSuitString() == "diamond" then suit = "方块" end
					sendMsgByFrom(room,"获得了收纳箱里所有的 "..suit.." 牌",player)
					if remain_card_ids:length() > 0 then
						local dest = room:askForPlayerChosen(player, room:getOtherPlayers(player), "shopBox","shop-box-invoke",true,true)
						if dest then
							room:fillAG(remain_card_ids, player)	
							local to_back1 = room:askForAG(player, remain_card_ids, false, self:objectName())
							room:clearAG()
							local dummy2 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							local dummy3 = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
							for _, id in sgs.qlist(remain_card_ids) do
								if sgs.Sanguosha:getCard(id):getSuit() == sgs.Sanguosha:getCard(to_back1):getSuit() then
									dummy2:addSubcard(sgs.Sanguosha:getCard(id))
								else
									dummy3:addSubcard(sgs.Sanguosha:getCard(id))
								end
							end
							room:obtainCard(dest, dummy2, false)
							local suit1 = nil
							if sgs.Sanguosha:getCard(to_back1):getSuitString() == "spade" then suit1 = "黑桃"
							elseif sgs.Sanguosha:getCard(to_back1):getSuitString() == "heart" then suit1 = "红桃"
							elseif sgs.Sanguosha:getCard(to_back1):getSuitString() == "club" then suit1 = "梅花"
							elseif sgs.Sanguosha:getCard(to_back1):getSuitString() == "diamond" then suit1 = "方块" end
							sendMsgByFrom(room,"获得了收纳箱里所有的 "..suit1.." 牌",dest)
							if dummy3:getSubcards():length() > 0 then
								room:throwCard(dummy3, player)
							end
						else
							if dummy1:getSubcards():length() > 0 then
								room:throwCard(dummy1, player)
							end
						end
					end
				end
			end
		elseif event == sgs.EventPhaseEnd then
			if not (player and player:isAlive()) then return "" end
			if player:getPhase() == sgs.Player_Play then
				player:setTag("products1",sgs.QVariant())
				room:setPlayerMark(player,"buyNum",0)
				player:removeTag("do_not")
				player:removeTag("do_not_choose")
			end
		--[[elseif event == sgs.DamageCaused then
			if not (player and player:isAlive()) then return "" end
			local damage = data:toDamage()
			if damage.from:objectName() ~= player:objectName() then return "" end
			player:gainMark("@coin")
			room:broadcastSkillInvoke("shop",1)
			room:setEmotion(player, "coin")--]]
		elseif event == sgs.Damaged then
			if not (player and player:isAlive()) then return "" end
			local damage = data:toDamage()
			player:gainMark("@coin")
			room:broadcastSkillInvoke("shop",1)
			room:setEmotion(player, "coin")
			if damage.from then
				damage.from:gainMark("@coin")
				room:broadcastSkillInvoke("shop",1)
				room:setEmotion(damage.from, "coin")
			end
		elseif event == sgs.Death then
			local death = data:toDeath()
			if death.who:objectName() ~= player:objectName() and death.damage.from and death.damage.from:objectName() == player:objectName() then
				player:gainMark("@coin",death.who:getMark("@coin")/2)
				room:broadcastSkillInvoke("shop",1)
				room:setEmotion(player, "coin")
			end
		elseif event == sgs.CardsMoveOneTime then
			if not (player and player:isAlive()) then return "" end
			local me = nil
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("@box") > 0 then
					me = p
				end
			end
			if not me then return "" end
			local current = room:getCurrent()
			local move = data:toMoveOneTime()
			local source = move.from
			if not move.from_places:contains(sgs.Player_PlaceHand) and not move.from_places:contains(sgs.Player_PlaceEquip) then return "" end
			if source and current:objectName() == source:objectName() then
				if player:objectName() == source:objectName() then
					local flag = bit32.band(move.reason.m_reason, sgs.CardMoveReason_S_MASK_BASIC_REASON)
					if flag == sgs.CardMoveReason_S_REASON_DISCARD then
						room:fillAG(move.card_ids, me)	
						local to_back = room:askForAG(me, move.card_ids, false, self:objectName())
						me:addToPile("box_cards",to_back,false)
						room:clearAG()
					end
				end
			end
		elseif event == sgs.BeforeCardsMove then
			local move = data:toMoveOneTime()
			if player:getHp() > 0 and move.from and move.from:isAlive() and move.from:objectName() == player:objectName() and player:getMark("@coffer") > 0 
				and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) and ((move.reason.m_reason == sgs.CardMoveReason_S_REASON_DISMANTLE
				and move.reason.m_playerId ~= move.from:objectName())
				or (move.to and move.to:objectName() ~= move.from:objectName())) then
				for _, p in sgs.qlist(room:getOtherPlayers(player)) do
					if p:objectName() == move.reason.m_playerId then
						room:doLightbox("$password_guess",1500)
						local password_not_selected = player:getTag("password_not_selected"):toString():split("+")
						local password = player:getTag("password"):toString()
						local password_select = room:askForChoice(p, "password",player:getTag("password_not_selected"):toString())
						if password == password_select then
							sendMsgByFrom(room,"选择的数字是"..password_select..",成功解密保险箱",p)
							room:doLightbox("$bingo",1500)
							player:loseMark("@coffer")
							player:setTag("password_not_selected",sgs.QVariant())
						else
							sendMsgByFrom(room,"选择的数字是"..password_select.."，没有选中",p)
							room:doLightbox("$not_bingo",1500)
							for i = 1 , #password_not_selected, 1 do if password_not_selected[i] == password_select then table.remove(password_not_selected,i) break end end
							player:setTag("password_not_selected",sgs.QVariant(table.concat(password_not_selected,"+")))
							move.card_ids = sgs.IntList()
							data:setValue(move)
						end
						break
					end
				end
			end
		end
		--[[elseif event == sgs.CardUsed then
			player:drawCards(33)
			if not (player or player:isAlive()) then return "" end
			local use = data:toCardUse()
			if use.card:getNumber() >= 2 and use.card:getNumber() <= 9 and use.card:getSuit() == sgs.Card_Heart then
				player:gainMark("@coin")
				room:broadcastSkillInvoke("shop",1)
				room:setEmotion(player, "coin")
			end
		end--]]
		return ""
	end
}
xx:addSkill(shop)
xx:addSkill(shopTrigger)
extension:insertRelatedSkills("shop","#shopTrigger")
sgs.LoadTranslationTable{
	["shopping"] = "商店模式",
	["shopCard"] = "商店",
	["shop"] = "商店",
	["cancel"] = "取消",    --选择商品时点击退出
 	[":shop"] = "游戏开始时，你获得等同于你的体力上限数量枚铜钱。你的回合开始时，你有概率获得0~3个铜钱。当你受到或者造成至少一点伤害时，你获得一枚铜钱，当你杀死一名角色时，你获得该角色一半的铜钱（向下取整）。当你使用红桃2~红桃9的牌时，获得一个铜钱。商店的刷新周期为一个出牌阶段，且每个出牌阶段最多只能买两件商品。<hr /><font color=\"pink\"><ul>商品列表:<li>使用【桃】</li><li>使用【杀】</li><li>召唤【闪】</li><li>召唤【酒】</li><li>召唤【火攻】</li><li>召唤【以逸待劳】</li><li>商店扩张（最多只能增两个，下个出牌阶段生效）</li><li>烈火燎原：对攻击范围内的一名角色造成一点火属性伤害</li><li>呼风唤雨：对攻击范围内的一名角色造成一点雷属性伤害</li><li>倚天剑：获得武器【倚天剑】。</li><li>圣光白衣：获得防具【圣光白衣】。</li><li>绝尘：获得防御马【绝尘】。</li><li>南蛮象：获得进攻马【南蛮象】。</li><li>幸运宝藏：摸三张牌，50%概率返回1铜钱</li><li>回头是岸：野心家可使用，变回原势力</li><li>赌博：有概率获得1~3个铜钱，摸一或两张牌，也有概率受到一点无来源的伤害。</li><li>偷袭：弃置一名觉色的一张牌</li><li>强力偷袭：弃置一名觉色的两张牌</li><li>收纳箱：使用后，其他角色于其回合内弃置牌时，你选择其中一张牌存入你的收纳箱。你的回合开始时，你展示收纳箱中的所有牌，选择获得其中一种花色的牌，然后你可以令一名其他角色获得另外一种花色的牌，然后将其余的牌弃置。场上只能有一个角色拥有收纳箱。</li><li>保险箱：获得保险箱标记，然后设置初始密码（1~7中选择一个数字）。当你的手牌或装备牌因为其他角色而即将失去时，该角色须从1~7中选择一个数字，若其选的数字与密码相同，你失去保险箱标记，否则你不失去此牌并且其他角色不能再选择该数字。场上只能有一个角色拥有保险箱。（保险箱不能防偷袭）</li><li>升级士兵：若你有武将被移除，那么你可以将替换后的士兵升级为高级士兵。士兵为随机出现两名。</li></ul></font>",
	["@coin"] = "铜钱",
	["@box"] = "收纳箱",
	["@coffer"] = "保险箱",
	["peachUse"] = "使用【桃】 5铜钱",
	["treasure1"] = "幸运宝藏  6铜钱",
	["fireGun"] = "烈火燎原  5铜钱",
	["thunder"] = "呼风唤雨  4铜钱",
	["slashUse"] = "使用【杀】  3铜钱",
	["getJink"] = "召唤【闪】  3铜钱",
	["getAnaleptic"] = "召唤【酒】  3铜钱",
	["no_careerist"] = "回头是岸  12铜钱",
	["bet"] = "赌博  2铜钱",
	["_discard"] = "偷袭  2铜钱",
	["super_discard"] = "强力偷袭  4铜钱",
	["box"] = "收纳箱  6铜钱",
	["coffer"] = "保险箱  7铜钱",
	["getAwaitExhausted"] = "召唤【以逸待劳】  4铜钱",
	["getFireAttack"] = "召唤【火攻】  3铜钱",
	["extraProduct"] = "商店扩张  2铜钱",
	["upgradeSoldier"] = "升级士兵  12铜钱",
	["getYitianjian"] = "倚天剑  8铜钱",
	["getShengguangbaiyi"] = "圣光白衣  8铜钱",
	["getJuechen"] = "绝尘  8铜钱",
	["getNanmanxiang"] = "南蛮象  7铜钱",
	["extraProduct"] = "商店扩张  2铜钱",
	
	["@extraProduct"] = "新的栏位",
	["@extraProduct2"] = "新的栏位",
	["shopBox"] = "收纳箱",
	["box_cards"] = "收纳箱",
	["shopDiscard"] = "偷袭",
	["shopSuperDiscard"] = "强力偷袭",
	["shopSlash"] = "【杀】",
	["shop-slash-invoke"] = "你可以指定一名其他角色，视为使用了【杀】",
	["shop-fireGun-invoke"] = "你可以指定一名攻击范围内的其他角色，对其造成一点火属性伤害。",
	["shopFireGun"] = "烈火燎原",
	["shop-thunder-invoke"] = "你可以指定一名攻击范围内的其他角色，对其造成一点雷属性伤害。",
	["shopThunder"] = "呼风唤雨",
	["shop-discard-invoke"] = "你可以弃置一名觉色的一张牌",
	["shop-super-discard-invoke"] = "你可以弃置一名觉色的两张牌",
	["shop-box-invoke"] = "你可以令一名其他角色获得收纳箱中一种花色的牌",
	["#message"] = "%arg",
	["#message1"] = "%from %arg",
	["password"] = "密码",
	
	["$coffer"] = "注意，使用保险箱了！",
	["$password_guess"] = "猜保险箱密码啦",
	["$not_bingo"] = "没有猜中保险箱的密码~",
	["$bingo"] = "猜中保险箱的密码，保险箱已失效",
	
	
	
	["@qspade"] = "黑桃",
	["@qheart"] = "红桃",
	["@qclub"] = "梅花",
	["@qdiamond"] = "方块",
	
	["no_careerist1"] = "回头是岸",
	["upgradeSoldier1"] = "升级士兵",
	
	["jingruishibing1"] = "精锐士兵",
	["jingruishibing2"] = "精锐士兵",
	["jingbing"] = "精兵",
	[":jingbing"] = "一名觉色的回合结束后，若其此回合对你造成过伤害，你可以令其交给你一张手牌。",
	["yongmengshibing1"] = "勇猛士兵",
	["yongmengshibing2"] = "勇猛士兵",
	["yongmeng"] = "勇猛",
	["#yongmengTrigger"] = "勇猛",
	[":yongmeng"] = "你的回合开始时，你可以展示牌堆顶的一张牌，然后此回合你可以将与此牌花色相同的牌当作【杀】使用或打出；你的回合结束后，你可以展示牌堆顶的一张牌，然后直到你的下个回合开始时你可以将与此牌花色相同的牌当作【闪】使用或打出。当你因此法使用或打出牌时，你失去该技能效果。",
	["texunshibing1"] = "特训士兵",
	["texunshibing2"] = "特训士兵",
	["texun"] = "特训",
	[":texun"] = "出牌阶段开始时，你可以展示一名其他角色的一张手牌，若该牌为【杀】，视为你对其使用了一张【杀】；若该牌为【闪】，你弃置之。然后若该牌为红色，你该回合增加一点手牌上限。",
	["texun-invoke"] = "你可以指定一名角色发动“特训”",
	["moushi1"] = "谋士",
	["moushi2"] = "谋士",
	["mouce"] = "谋策",
	[":mouce"] = "你的回合开始时，你可以展示牌堆顶的一张牌并获得此牌，然后你可以根据该牌的花色将此牌当作如下牌使用或打出，直到你失去此牌或使用此牌或下个回合开始时：红桃，【桃】；方块：【闪】；黑桃：【决斗】；梅花：【无懈可击】。",
	["#mouceTrigger"] = "谋策",
	
	["@jingbing"] = "请将一张手牌交给对方。",
}
return {extension}