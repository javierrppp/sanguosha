local hash, multy_kingdom = initByKingdom(extra_general_init(), {"zhonghui"})

sanfen_rule = sgs.CreateTriggerSkill{ 
	name = "sanfen_rule" ,
	events = {sgs.GameStart, sgs.GeneralShown, sgs.Death} ,
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GameStart then
		end
	end
}
sanfen_mode = {
	name = "sanfen_mode",
	expose_role = false,
	player_count = 9,
	random_seat = true,
	rule = sanfen_rule,
	on_assign = function(self, room)
	local generals, generals2, kingdoms = {},{},{}
		local kingdom = {"wei","shu","wu","qun",}
		local removeKingdom = kingdom[math.random(1,#kingdom)]
		table.removeOne(kingdom, removeKingdom)
		local rules_count = {["wei"] = 0,["shu"] = 0,["wu"] = 0,["qun"] = 0}
		for i = 1, 9, 1 do
			local role = kingdom[math.random(1,#kingdom)]
			rules_count[role] = rules_count[role] + 1
			if rules_count[role] == 3 then table.removeOne(kingdom,role) end
			table.insert(kingdoms, role)
		end
		local selected = {}
		for i = 1,9,1 do 
			local player = room:getPlayers():at(i-1) 
			player:clearSelected()  
			local random_general = getRandomGenerals(sgs.GetConfig("HegemonyMaxChoice",0), hash,kingdoms[i],selected)
			for _,general in pairs(random_general)do
				player:addToSelected(general)
				table.insert(selected,general)
			end
		end
		room:chooseGenerals(room:getPlayers(),true,true)
		for i = 1,9,1 do 
			local player = room:getPlayers():at(i-1)
			generals[i] = player:getGeneralName()
			generals2[i] = player:getGeneral2Name()
		end
		return generals, generals2,kingdoms
	end,
}
sgs.LoadTranslationTable{
	["sanfen_mode"] = "三分天下",
}
return sgs.CreateLuaScenario(sanfen_mode)