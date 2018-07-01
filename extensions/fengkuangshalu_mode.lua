local ban_list = {"zhonghui", "guojia", "xunyu", "simalang", "dianwei", "chenqun", "xizhicai", "caopi", "zhangchunhua", "xiahoushi", "pangtong", "menghuo", "mizhu", "huangzhong", "ganfuren", "xiaoqiao", "sunjian", "sunce", "zumao", "huanggai", "zhoutai", "jiaxu", "tianfeng", "yuji", "zhangren", "zhangxiu", "liubiao", "hejin", "dongzhuo"}
local hash, multy_kingdom = init(extra_general_init(), ban_list)
game_use_value, defult_value = initValue()
shalu = sgs.CreateTriggerSkill{
	name = "shalu",
	priority = 0,  --先进行君主替换
	events = {sgs.BuryVictim, sgs.GameStart},
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GameStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do 
				p:showGeneral(true, false)
				p:showGeneral(false, false)
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do 
				local max_hp = 0
				local general1 = p:getGeneralName()
				if game_use_value[general1] and #game_use_value[general1] > 0 then
					max_hp = max_hp + game_use_value[general1][1]
				else
					max_hp = max_hp + defult_value[1]
				end
				local general2 = p:getGeneral2Name()
				if game_use_value[general2] and #game_use_value[general2] > 0 then
					max_hp = max_hp + game_use_value[general2][1]
				else
					max_hp = max_hp + defult_value[1]
				end
				local mhp = sgs.QVariant()
				mhp:setValue(max_hp)
				room:setPlayerProperty(p, "maxhp", mhp)
				room:setPlayerProperty(p, "hp", mhp)
			end
		end
	end
}
fengkuang_mode = {
	name = "fengkuang",
	expose_role = false,
	player_count = 8,
	random_seat = true,
	rule = shalu,
	on_assign = function(self, room)
		local generals, generals2, kingdoms = {},{},{}
		local selected = {}
		for i = 1,8,1 do
			local player = room:getPlayers():at(i-1) 
			player:clearSelected() 
			local random_general = getRandomAllGenerals(sgs.GetConfig("HegemonyMaxChoice",0), hash,selected)
			for _,general in pairs(random_general)do
				player:addToSelected(general)
				table.insert(selected,general)
			end
		end
		room:chooseGenerals(room:getPlayers(),true,true)
		for i = 1,8,1 do 
			local player = room:getPlayers():at(i-1)
			local general = sgs.Sanguosha:getGeneral(player:getGeneralName())
			generals[i] = player:getGeneralName()
			generals2[i] = player:getGeneral2Name() 
			kingdoms[i] = general:getKingdom()
		end
		return generals, generals2,kingdoms
	end,
}
sgs.LoadTranslationTable{
	["fengkuang"] = "疯狂杀戮",
}
return sgs.CreateLuaScenario(fengkuang_mode)