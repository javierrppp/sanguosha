
local all_products = {"peachUse","treasure1","fireGun","thunder","slashUse","getJink","getAnaleptic","getAwaitExhausted","getFireAttack","no_careerist","bet","_discard","super_discard","box","coffer","extraProduct","upgradeSoldier","getYitianjian","getShengguangbaiyi","getJuechen","getNanmanxiang"}
local forbid = {}
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

local hash, multy_kingdom = init()


shop_rule = sgs.CreateTriggerSkill{
	name = "shop_rule",
	events = {sgs.GameStart,sgs.EventPhaseEnd,sgs.DamageCaused,sgs.Damaged,sgs.Death,sgs.EventPhaseStart,sgs.CardsMoveOneTime,sgs.BeforeCardsMove},
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GameStart then
			for _,player in sgs.qlist(room:getAllPlayers()) do
				player:gainMark("@coin",player:getMaxHp())
				--player:gainMark("@coin",100)     --测试用
				room:setEmotion(player, "coin")
				room:broadcastSkillInvoke("shop",1)
			end
		elseif event == sgs.EventPhaseStart then
			if not (player and player:isAlive()) then return false end
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
			end
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
		elseif event == sgs.EventPhaseEnd then
			if not (player and player:isAlive()) then return false end
			if player:getPhase() == sgs.Player_Play then
				player:setTag("products1",sgs.QVariant())
				room:setPlayerMark(player,"buyNum",0)
				player:removeTag("do_not")
				player:removeTag("do_not_choose")
			end
		elseif event == sgs.Damaged then
			if not (player and player:isAlive()) then return false end
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
			if death.who:objectName() ~= player:objectName() and death.damage and death.damage.from and death.damage.from:objectName() == player:objectName() then
				player:gainMark("@coin",death.who:getMark("@coin")/2)
				room:broadcastSkillInvoke("shop",1)
				room:setEmotion(player, "coin")
			end
		elseif event == sgs.CardsMoveOneTime then
			if not (player and player:isAlive()) then return false end
			local me = nil
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("@box") > 0 then
					me = p
				end
			end
			if not me then return false end
			local current = room:getCurrent()
			local move = data:toMoveOneTime()
			local source = move.from
			if not move.from_places:contains(sgs.Player_PlaceHand) and not move.from_places:contains(sgs.Player_PlaceEquip) then return false end
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
	end,
	priority = 0,
}
shop_mode = {
	name = "shop_mode",
	expose_role = false,
	player_count = 8,
	random_seat = true,
	rule = shop_rule,
	on_assign = function(self, room)
		local generals, generals2, kingdoms = {},{},{}
		local selected = {}
		for i = 1,8,1 do --开始给每名玩家分配待选择的武将。
			local player = room:getPlayers():at(i-1) --获取相关玩家
			player:clearSelected()  --清除已经分配的武将
			--如果不清除的话可能会获得上次askForGeneral的武将。
			local random_general = getRandomAllGenerals(sgs.GetConfig("HegemonyMaxChoice",0), hash, selected)
			--随机获得HegemonyMaxChoice个武将。
			--函数getRandomGenerals在本文件内定义，可以参考之。
			for _,general in pairs(random_general)do
				player:addToSelected(general)
				--这个函数就是把武将分发给相关玩家。
				--分发的武将会在选将框中出现。
				table.insert(selected,general)
			end
		end
		room:chooseGenerals(room:getPlayers(),false,true)
		--这部分将在附录A中介绍。
		for i = 1,8,1 do --依次设置genera1、general2。
			local player = room:getPlayers():at(i-1)
			local general = sgs.Sanguosha:getGeneral(player:getGeneralName())
			general:addSkill("shop")
			generals[i] = player:getGeneralName() --获取武将，这个是chooseGenerals分配的。
			generals2[i] = player:getGeneral2Name() --同上
			kingdoms[i] = general:getKingdom()
		end
		local v1 = table.concat(generals, "+")
		local v2 = table.concat(generals2, "+")
		local v3 = table.concat(kingdoms, "+")
		sendMsg(room, "v1:" .. v1 .. ", v2:" .. v2 .. ", v3:" .. v3)
		--return {"zhouyu", "zhangliao"}, {"huanggai", "zhanghe"}, {"wu", "wei"}
		return generals, generals2,kingdoms
	end,
}
sgs.LoadTranslationTable{
	["shop_mode"] = "商店模式",
	
}
return sgs.CreateLuaScenario(shop_mode)