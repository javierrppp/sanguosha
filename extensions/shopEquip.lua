extension = sgs.Package("shopEquip", sgs.Package_CardPack)
Table2IntList = function(theTable)
	local result = sgs.IntList()
	for i = 1, #theTable, 1 do
		result:append(theTable[i])
	end
	return result
end
local sendMsg = function(room,message)
	local msg = sgs.LogMessage()
	msg.type = "#message"
	msg.arg = message
	room:sendLog(msg)
end
yitianjian = sgs.CreateWeapon{
    name = "yitianjian",
	class_name = "Yitianjian",
	suit = nil,
	number = nil,
	range = 3,
	on_install = function(self,player)
	    local room = player:getRoom()
		local skill = sgs.Sanguosha:getTriggerSkill("yitian")
		room:getThread():addTriggerSkill(skill)
	end
}
moveEquip = sgs.CreateTriggerSkill{
	name = "moveEquip" ,
	global = true,
	priority = 0,  --先进行君主替换
	events = {sgs.GameStart,sgs.CardsMoveOneTime} ,
	can_trigger = function(self, event, room, player, data)	
		if event == sgs.GameStart then
			local DrawPile = room:getDrawPile()
			for _,cid in sgs.qlist(DrawPile) do
				local cd = sgs.Sanguosha:getCard(cid)
				if cd:isKindOf("Yitianjian") or cd:isKindOf("Shengguangbaiyi") or cd:objectName() == "juechen" or cd:objectName() == "nanmanxiang" then
					--[[local reason = sgs.CardMoveReason()
					local moves = sgs.CardsMoveList()
					local card_list = sgs.IntList()
					card_list:append(cid)
					local move = sgs.CardsMoveStruct(card_list, nil,  sgs.Player_PlaceTable, reason)
					moves:append(move)
					room:moveCardsAtomic(moves, true)--]]
					room:moveCardTo(cd, nil, sgs.Player_PlaceTable)
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:isKindOf("Yitianjian") then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.to and move.to:objectName() == p:objectName() then
							if p:getMark("yitianjianMark") > 0 and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip) then
								return false								
							end
						end
					end
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.from and move.from:objectName() == p:objectName() then
							if p:getMark("yitianjianMark") > 0 then
								room:setPlayerMark(p,"yitianjianMark",0)
							end
						end
					end
					room:moveCardTo(card, nil, sgs.Player_PlaceTable)
				end
				if card:isKindOf("Shengguangbaiyi") then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.to and move.to:objectName() == p:objectName() then
							if p:getMark("shengguangbaiyiMark") > 0 and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip) then 
								return false 
							end
						end
					end
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.from and move.from:objectName() == p:objectName() then
							if p:getMark("shengguangbaiyiMark") > 0 then
								room:setPlayerMark(p,"shengguangbaiyiMark",0)
							end
						end
					end
					room:moveCardTo(card, nil, sgs.Player_PlaceTable)
				end
				if card:objectName() == "juechen" then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.to and move.to:objectName() == p:objectName() then
							if p:getMark("juechenMark") > 0 and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip) then 
								return false 
							end
						end
					end
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.from and move.from:objectName() == p:objectName() then
							if p:getMark("juechenMark") > 0 then
								room:setPlayerMark(p,"juechenMark",0)
							end
						end
					end
					room:moveCardTo(card, nil, sgs.Player_PlaceTable)
				end
				if card:objectName() == "nanmanxiang" then
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.to and move.to:objectName() == p:objectName() then
							if p:getMark("nanmanxiangMark") > 0 and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip) then 
								return false 
							end
						end
					end
					for _, p in sgs.qlist(room:getAlivePlayers()) do
						if move.from and move.from:objectName() == p:objectName() then
							if p:getMark("nanmanxiangMark") > 0 then
								room:setPlayerMark(p,"nanmanxiangMark",0)
							end
						end
					end
					room:moveCardTo(card, nil, sgs.Player_PlaceTable)
				end
			end
		end
	end
}
yitian = sgs.CreateTriggerSkill{
	name = "yitian" ,
	global = true,
	events = {sgs.TargetConfirmed} ,
	can_trigger = function(self, event, room, player, data)	
		local card = player:getWeapon()
		if not card then return "" end
		if card:objectName() == "yitianjian" then
			local use = data:toCardUse()
			if use.from and use.from:objectName() == player:objectName() and use.card:isKindOf("Slash") then 
				local jink_list = player:getTag("Jink_"..use.card:toString()):toList()
				for _, p in sgs.qlist(use.to) do
					local index = use.to:indexOf(p)
					if player:getHp() <= p:getHp() then
						jink_list:replace(index,sgs.QVariant(0))
					end
				end
				player:setTag("Jink_"..use.card:toString(), sgs.QVariant(jink_list))
			end
		end
		return ""
	end,
	priority = 10
}
shengguangbaiyi = sgs.CreateArmor{
    name = "shengguangbaiyi",
	class_name = "Shengguangbaiyi",
	suit = nil,
	number = nil,
	range = 1,
	on_install = function(self,player)
	    local room = player:getRoom()
		local skill = sgs.Sanguosha:getTriggerSkill("shengguang")
		room:getThread():addTriggerSkill(skill)
	end
}
shengguang = sgs.CreateTriggerSkill{
	name = "shengguang" ,
	global = true,
	events = {sgs.CardAsked} ,
	can_trigger = function(self, event, room, player, data)	
		local pattern = data:toStringList()[1]
		if pattern ~= "jink" then return false end
		local card = player:getEquip(1)
		if not card then return "" end
		if card:objectName() == "shengguangbaiyi" then
			for _, p in sgs.qlist(room:getOtherPlayers(player)) do
				if p:getMark("jiluMark") > 0 and not p:isKongcheng() then
					if room:askForSkillInvoke(player,self:objectName(),data) then
						player:drawCards(1)
						if player:isKongcheng() then return "" end
						local pd = sgs.PindianStruct()
						pd = player:pindianSelect(p, self:objectName())
						local success = player:pindian(pd)
						if pd.from_card:getNumber() > pd.to_card:getNumber() then
							local jink = sgs.Sanguosha:cloneCard("jink",sgs.Card_NoSuit, 0)
						    jink:setSkillName(self:objectName())
						    room:provide(jink)
						end
					end
				end
			end
		end
		return ""
	end,
	priority = 10
}
cardUse = sgs.CreateTriggerSkill{
	name = "cardUse" ,
	global = true,
	events = {sgs.CardUsed,sgs.CardFinished} ,
	can_trigger = function(self, event, room, player, data)	
		if event == sgs.CardUsed then
			local use = data:toCardUse()
			if use.from:objectName() ~= player:objectName() then return "" end
			if use.card:isKindOf("Slash") or use.card:isKindOf("ArcheryAttack") then
				room:setPlayerMark(player,"jiluMark",1)
			end
		elseif event == sgs.CardFinished then
			local use = data:toCardUse()
			if use.from:objectName() ~= player:objectName() then return "" end
			if player:getMark("jiluMark") > 0 then
				room:setPlayerMark(player,"jiluMark",0)
			end
		end
		return ""
	end,
	priority = 10
}
local juechen = sgs.Sanguosha:cloneCard("DefensiveHorse", sgs.Card_Club, 1)
juechen:setObjectName("juechen")
juechen:setParent(extension)
juechenDefense = sgs.CreateDistanceSkill{
	name = "juechenDefense" ,
	correct_func = function(self, from, to)
		local card = to:getEquip(2)
		if card and card:objectName() == "juechen" and from:getHp() > to:getHp() then
			return from:getHp() - to:getHp()
		end
	end
}
local nanmanxiang = sgs.Sanguosha:cloneCard("OffensiveHorse", sgs.Card_Diamond, 1)
nanmanxiang:setObjectName("nanmanxiang")
nanmanxiang:setParent(extension)
nanmanxiangEffect = sgs.CreateTriggerSkill{
	name = "nanmanxiangEffect",
	frequency = sgs.Skill_Compulsory,
	global = true,
	events = {sgs.TargetConfirmed,sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		local card = player:getEquip(3)
		if event == sgs.TargetConfirmed then
			if card and card:objectName() == "nanmanxiang" then
				local use = data:toCardUse()
				if use.card:isKindOf("SavageAssault") then
					room:setEmotion(player, "cancel")
					local nullified_list = use.nullified_list
					table.insert(nullified_list, player:objectName())
					use.nullified_list = nullified_list
					data:setValue(use)
				end
			end
		elseif event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			for _, id in sgs.qlist(move.card_ids) do
				local card = sgs.Sanguosha:getCard(id)
				if card:objectName() == "nanmanxiang" and move.from and move.from:objectName() == player:objectName() and move.to_place ~= sgs.Player_PlaceEquip and move.from_places:contains(sgs.Player_PlaceEquip) then
					local to_list = room:askForPlayersChosen(player,room:getOtherPlayers(player),self:objectName(),0,room:getOtherPlayers(player):length(),"nanman-invoke",true)
					if to_list:length() == 0 then return false end
					local savage_assault = sgs.Sanguosha:cloneCard("SavageAssault", sgs.Card_NoSuit, 0)
					savage_assault:setSkillName(self:objectName())
					local card_use = sgs.CardUseStruct()
					card_use.from = player
					card_use.to = to_list
					card_use.card = savage_assault
					room:useCard(card_use, false)
					break
				end
			end
		end
		return ""
	end,
	priority = -11.2
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("yitian") then
	skillList:append(yitian)
end
if not sgs.Sanguosha:getSkill("moveEquip") then
	skillList:append(moveEquip)
end
if not sgs.Sanguosha:getSkill("cardUse") then
	skillList:append(cardUse)
end
if not sgs.Sanguosha:getSkill("shengguang") then
	skillList:append(shengguang)
end
if not sgs.Sanguosha:getSkill("juechenDefense") then
	skillList:append(juechenDefense)
end
if not sgs.Sanguosha:getSkill("nanmanxiangEffect") then
	skillList:append(nanmanxiangEffect)
end
sgs.Sanguosha:addSkills(skillList)
addcard = function(card, snn)
	local n = #snn
	for i=1, n, 2 do
		local tcard = card:clone()
		tcard:setSuit(snn[i])
		tcard:setNumber(snn[i+1])
		tcard:setParent(extension)
	end
end
addcard(yitianjian,{sgs.Card_Spade,1})
addcard(shengguangbaiyi,{sgs.Card_Heart,1})
sgs.LoadTranslationTable{
	["#message"] = "%arg",
	["shopEquip"] = "商店装备包",
	["yitianjian"] = "倚天剑",
	[":yitianjian"] = "装备牌·武器<br><B>攻击范围：</B>3<br><B>武器技能:</B>锁定技，若目标角色体力值不小于你，其不能用【闪】响应你的【杀】。",
	["shengguangbaiyi"] = "圣光白衣",
	["shengguang"] = "圣光白衣",
	[":shengguangbaiyi"] = "装备牌·防具<br><B>防具技能：</B>当你需要使用或打出【闪】时，你可以摸一张牌并与来源角色拼点，若你赢，视为你使用或打出了【闪】。",
	["juechen"] = "绝尘",
	[":juechen"] = "装备牌·坐骑<br><B>技能：</B>其他角色与你的距离+1。体力值大于你的角色计算与你的距离时，始终+x（x为其体力值减去你的体力值）。<br /><font color=\"pink\">注：与+1效果可叠加。</font>",
	["nanmanxiang"] = "南蛮象",
	[":nanmanxiang"] = "装备牌·坐骑<br><B>技能：</B>你与其他角色的距离-1。南蛮入侵对你无效。当你失去此装备牌时，你可以指定任意名其他角色视为对这些角色使用了一张【南蛮入侵】。",
	["nanman-invoke"] = "你可以指定任意名其他角色，视为对指定的角色使用【南蛮入侵】",
	
	["nanmanxiangEffect"] = "南蛮象",
}
return {extension}