local hash, multy_kingdom = init(extra_general_init(), {})
shouhu_mode2 = {
	name = "shouhu_mode2",
	expose_role = false,
	player_count = 10,
	random_seat = true,
	rule = rule,
	on_assign = function(self, room)
		local generals, generals2, kingdoms = {},{},{}
		local selected = {}
		for i = 1,10,1 do --开始给每名玩家分配待选择的武将。
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
		for i = 1,10,1 do --依次设置genera1、general2。
			local player = room:getPlayers():at(i-1)
			local general = sgs.Sanguosha:getGeneral(player:getGeneralName())
			general:addSkill("shijiu")
			generals[i] = player:getGeneralName() --获取武将，这个是chooseGenerals分配的。
			generals2[i] = player:getGeneral2Name() --同上
			kingdoms[i] = general:getKingdom()
			--kingdoms[i] = general:getKingdom()
		end
		return generals, generals2,kingdoms
	end,
}
sgs.LoadTranslationTable{
	["shouhu_mode2"] = "守护神模式",
	
}
return sgs.CreateLuaScenario(shouhu_mode2)