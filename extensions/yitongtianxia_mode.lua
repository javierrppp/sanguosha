local hash, multy_kingdom = initByKingdom(extra_general_init(), {"zhonghui"})

XmodeRule = sgs.CreateTriggerSkill{
	name = "XmodeRule",
	events = {sgs.BuryVictim, sgs.GameStart},
	on_effect = function(self, event, room, player, data,ask_who)
		--[[for _, kingdom in pairs(hash) do 
			local general_name = table.concat(kingdom, "+")
			sendMsg(room, general_name)
		end--]]
		player:bury()
		local times = room:getTag(player:getKingdom().."_Change"):toInt()
		player:speak(times)
		if times >= 3 then return false end
		local used = room:getTag("Xmode_UsedGeneral"):toString():split("+")
		local random_general = getRandomGenerals(sgs.GetConfig("HegemonyMaxChoice",0),hash, player:getKingdom(),used)
		local choice = room:askForGeneral(player,table.concat(random_general,"+"),nil,false):split("+")
		table.insertTable(used,choice)
		room:setTag("Xmode_UsedGeneral",sgs.QVariant(table.concat(used,"+")))
		room:doDragonPhoenix(player,choice[1], choice[2],true,player:getKingdom(),false,"",true)
		player:drawCards(4)
		room:broadcastProperty(player,"kingdom")
		times = times + 1
		room:setTag(player:getKingdom().."_Change",sgs.QVariant(times))
		return true --不知道能不能处理飞龙
	end,
	priority = 1,
}
Xmode = {
	name = "Xmode_hegemony",
	expose_role = false,
	player_count = 8,
	random_seat = true,
	rule = XmodeRule,
	on_assign = function(self, room)
		local generals, generals2, kingdoms = {},{},{}
		local kingdom = {"wei","shu","wu","qun",}
		local rules_count = {["wei"] = 0,["shu"] = 0,["wu"] = 0,["qun"] = 0}
		for i = 1, 8, 1 do
			local role = kingdom[math.random(1,#kingdom)]
			rules_count[role] = rules_count[role] + 1
			if rules_count[role] == 2 then table.removeOne(kingdom,role) end
			table.insert(kingdoms, role)
		end
		local selected = {}
		for i = 1,8,1 do
			local player = room:getPlayers():at(i-1) 
			player:clearSelected() 
			local random_general = getRandomGenerals(sgs.GetConfig("HegemonyMaxChoice",0), hash,kingdoms[i],selected)
			for _,general in pairs(random_general)do
				player:addToSelected(general)
				table.insert(selected,general)
			end
		end
		room:chooseGenerals(room:getPlayers(),true,true)
		for i = 1,8,1 do 
			local player = room:getPlayers():at(i-1)
			generals[i] = player:getGeneralName()
			generals2[i] = player:getGeneral2Name() 
			local used = room:getTag("Xmode_UsedGeneral"):toString():split("+") 
			table.insert(used,generals[i]) 
			table.insert(used,generals2[i])	
			room:setTag("Xmode_UsedGeneral",sgs.QVariant(table.concat(used,"+")))
		end
		return generals, generals2,kingdoms
	end,
}
sgs.LoadTranslationTable{
	["Xmode_hegemony"] = "一统天下",
}
return sgs.CreateLuaScenario(Xmode)