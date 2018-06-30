--一个不知道为什么的bug迫使我把代码写在了这里
local hash, multy_kingdom = init(extra_general_init(), {"zhonghui"})
rule = sgs.CreateTriggerSkill{ 
	name = "rule" ,
	priority = 0,  --先进行君主替换
	events = {sgs.GameStart, sgs.GeneralShown, sgs.Death} ,
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GameStart then
			--[[for key,value in pairs(multy_kingdom) do
				sendMsg(room, ".."..table.concat(value, "+"))
			end
			sendMsg(room, "hashNum:" .. #hash)
			local general_name = table.concat(hash, "+")
			sendMsg(room, "?" .. general_name)--]]
		end
		if event == sgs.GeneralShown then
			if not player or player:isDead() then return false end
			if player:getRole() == "careerist" or player:getMark("@shouhu") > 0 then return false end
			local head = true 
			if not player:hasShownGeneral1() then
				head = false
			end
			if player:isLord() and player:hasShownGeneral1() then
				for _, p in sgs.qlist(room:getAllPlayers(true)) do 
					if p:objectName() ~= player:objectName() and p:getMark("@shouhu") > 0 and p:getKingdom() == player:getKingdom() then
						local lose_skill_str = p:getTag("shouhuSkillTag"):toString()
						if lose_skill_str and p:hasSkill(lose_skill_str) then
							room:detachSkillFromPlayer(p,lose_skill_str)
						end
						room:detachSkillFromPlayer(p,"shouhu")
						p:loseMark("@shouhu")
					end
				end
				player:gainMark("@shouhu")
				room:acquireSkill(player, "shouhu", true, head)
			else
				local invoke = true
				for _, p in sgs.qlist(room:getAllPlayers(true)) do 
					if p:objectName() ~= player:objectName() and p:hasShownOneGeneral() and p:getKingdom() == player:getKingdom() then
						invoke = false
						break
					end
				end
				if invoke then
					player:gainMark("@shouhu")
					room:acquireSkill(player, "shouhu", true, head)
				end
			end
		elseif event == sgs.Death then
			if not player then return false end
			local death = data:toDeath()
			if death.who:getMark("@shouhu") > 0 then
				local player_list = sgs.SPlayerList()
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					if not p:hasShownOneGeneral() then
						local choice = room:askForChoice(p, "rule", "zhujiang+fujiang")
						if choice == "zhujiang" then
							p:showGeneral(true)
						else
							p:showGeneral(false)
						end
					end
				end
				if death.who:getRole() == "careerist" then return false end
				for _, p in sgs.qlist(room:getAlivePlayers()) do 
					if p:getKingdom() == death.who:getKingdom() and p:getRole() ~= "careerist" then
						player_list:append(p)
					end
				end
				if player_list:length() == 0 then return false end
				for _, p in sgs.qlist(player_list) do
					room:setPlayerProperty(p, "role", sgs.QVariant("careerist"))
					room:setEmotion(p, "yele")
				end
				room:getThread():delay(2500)
				for _, p in sgs.qlist(player_list) do
					room:askForDiscard(p, "role", 100, 100, false, true)
				end
				for _, p in sgs.qlist(player_list) do
					local recover = sgs.RecoverStruct()
					recover.who = p
					room:recover(p, recover)
				end
				for _, p in sgs.qlist(player_list) do
					p:drawCards(3)
				end
			end
		end
		return false
	end
}
erhu_rule = sgs.CreateTriggerSkill{
	name = "erhu_rule",
	events = {sgs.GameStart},
	on_effect = function(self, event, room, player, data,ask_who)
		--[[for key,value in pairs(multy_kingdom) do
			sendMsg(room, ".."..table.concat(value, "+"))
		end
		sendMsg(room, "hashNum:" .. #hash)
		local general_name = table.concat(hash, "+")
		sendMsg(room, "?" .. general_name)--]]
	end,
	priority = 1,
}