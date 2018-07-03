local ban_list = {"zhonghui", "guojia", "xunyu", "lidian", "simalang", "dianwei", "chenqun", "xizhicai", "caopi", "zhangchunhua", "xiahoushi", "pangtong", "liaohua", "menghuo", "mizhu", "weiyan", "huangzhong", "ganfuren", "xiaoqiao", "sunjian", "sunce", "zumao", "huanggai", "zhoutai", "jiaxu", "tianfeng", "yuji", "zhangren", "zhangxiu", "liubiao", "hejin", "dongzhuo", "huangquan_shu", "huangquan_wei"}
local extra_list = extra_general_init()
table.insert(ban_list, "caochong")
table.insert(extra_list, "shalu_caochong")
table.insert(ban_list, "litong")
table.insert(extra_list, "shalu_litong")
table.insert(extra_list, "shalu_guojia")
table.insert(extra_list, "shalu_weiyan")
local hash, multy_kingdom = init(extra_list, ban_list)
game_use_value, defult_value = initValue()
shalu = sgs.CreateTriggerSkill{
	name = "shalu",
	priority = 0,  --先进行君主替换
	events = {sgs.DamageCaused, sgs.GameStart, sgs.DamageInflicted, sgs.HpRecover, sgs.PreHpRecover, sgs.Damaged},
	on_effect = function(self, event, room, player, data,ask_who)
		if event == sgs.GameStart then
			for _, p in sgs.qlist(room:getAllPlayers()) do 
				p:showGeneral(true, false)
				p:showGeneral(false, false)
			end
			for _, p in sgs.qlist(room:getAllPlayers()) do 
				local max_hp = 0
				local offense = 0
				local defense = 0
				local intelligence = 0
				local health = 0
				local general1 = p:getGeneralName()
				if game_use_value[general1] and #game_use_value[general1] > 0 then
					max_hp = max_hp + game_use_value[general1][1]
					offense = offense + game_use_value[general1][2]
					defense = defense + game_use_value[general1][3]
					intelligence = intelligence + game_use_value[general1][4]
					health = health + game_use_value[general1][5]
				else
					max_hp = max_hp + defult_value[1]
					offense = offense + defult_value[2]
					defense = defense + defult_value[3]
					intelligence = intelligence + defult_value[4]
					health = health + defult_value[5]
				end
				local general2 = p:getGeneral2Name()
				if game_use_value[general2] and #game_use_value[general2] > 0 then
					max_hp = max_hp + game_use_value[general2][1]
					offense = offense + game_use_value[general2][2]
					defense = defense + game_use_value[general2][3]
					intelligence = intelligence + game_use_value[general2][4]
					health = health + game_use_value[general2][5]
				else
					max_hp = max_hp + defult_value[1]
					offense = offense + defult_value[2]
					defense = defense + defult_value[3]
					intelligence = intelligence + defult_value[4]
					health = health + defult_value[5]
				end
				local mhp = sgs.QVariant()
				mhp:setValue(max_hp)
				room:setPlayerProperty(p, "maxhp", mhp)
				room:setPlayerProperty(p, "hp", mhp)
				room:setPlayerMark(p, "@shalu1_maxhp", max_hp)
				room:setPlayerMark(p, "@shalu2_offense", offense / 2)
				room:setPlayerMark(p, "@shalu3_defense", defense / 2)
				room:setPlayerMark(p, "@shalu4_intelligence", intelligence / 2)
				room:setPlayerMark(p, "@shalu5_health", health / 2)
			end
		--[[elseif event == sgs.DamageCaused then
			local offense = player:getMark("@shalu2_offense")
			local intelligence = player:getMark("@shalu4_intelligence")
			local damage = data:toDamage()
			local damage_base = damage.damage
			if damage.chain or damage.transfer  then return false end
			damage.damage = damage_base * offense * (1 + 0.01 * intelligence)
			data:setValue(damage)--]]
		elseif event == sgs.DamageInflicted then
			local damage = data:toDamage()
			local damage_base = damage.damage
			local to_defense = player:getMark("@shalu3_defense")
			local to_intelligence = player:getMark("@shalu4_intelligence")
			local from_offense
			local from_intelligence
			if damage.from then
				from_offense = damage.from:getMark("@shalu2_offense")
				from_intelligence = damage.from:getMark("@shalu4_intelligence")
				damage.damage = damage_base * from_offense * (1 + 0.01 * from_intelligence) - to_defense * (1 + 0.01 * to_intelligence)
			else
				damage.damage = damage_base * 100 - to_defense * (1 + 0.01 * to_intelligence)
			end
			if damage.chain or damage.transfer  then return false end
			if damage.damage <= 0 then 
				return true
			end
			data:setValue(damage)
		elseif event == sgs.PreHpRecover then	
			local losthp = player:getMaxHp() - player:getHp()
			local recover = data:toRecover()
			local health = player:getMark("@shalu5_health")
			local recover_base = recover.recover
			recover.recover = recover_base * health
			if recover.recover > losthp then recover.recover = losthp end
			data:setValue(recover)
		elseif event == sgs.HpRecover then	
			local recover = data:toRecover()
			local hp = player:getMark("@shalu1_maxhp")
			room:setPlayerMark(player, "@shalu1_maxhp", hp + recover.recover)
		elseif event == sgs.Damaged then	
			local damage = data:toDamage()
			local hp = player:getMark("@shalu1_maxhp")
			local health = player:getMark("@shalu5_health")
			room:setPlayerMark(player, "@shalu1_maxhp", hp - damage.damage)
			if damage.card and damage.card:isKindOf("Slash") and health > 30 then
				room:setPlayerMark(player, "@shalu5_health", health - 1)
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
	["#fengkuang"] = "什么鬼哦",
}
return sgs.CreateLuaScenario(fengkuang_mode)