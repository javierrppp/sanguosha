fengkuang_maxCard = sgs.CreateMaxCardsSkill{  --手牌上限
    name = "fengkuang_maxCard" ,
	global = true,
    extra_func = function(self, target)
		if target:getMark("@shalu1_maxhp") > 0 then
			return - target:getHp() --+ target:getHp() / 10 - 1
		end
    end
}
extraSlashParams = sgs.CreateTargetModSkill{
	name = "extraSlashParams",
	global = true,
	residue_func = function(self, from)
		return from:getMark("@extraSlashTimes")
	end,
	distance_limit_func = function(self, player)
		if player:getMark("@infinite") > 0 then
			return 999
		else
			return player:getMark("@extraSlashAttackRange")
		end
	end,
	extra_target_func = function(self, player)
		return player:getMark("@extraSlashTargets")
	end,
}
extraSlashClear = sgs.CreateTriggerSkill{
	name = "extraSlashClear",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if player:getPhase() ~= sgs.Player_Finish then return "" end
		player:loseAllMarks("@extraSlashTimes")
		player:loseAllMarks("@infinite")
		player:loseAllMarks("@extraSlashAttackRange")
		player:loseAllMarks("@extraSlashTargets")
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
extraDistance = sgs.CreateDistanceSkill{
	name = "extraDistance",
	global = true,
	correct_func = function(self, from, to)
		if to:getMark("@extraDefense") > 0 then
			return to:getMark("@extraDefense")
		end
		if from:getMark("@extraOffense") > 0 then
			return -from:getMark("@extraOffense")
		end
		return 0
	end
}
extraDistanceClear = sgs.CreateTriggerSkill{
	name = "extraDistanceClear",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.EventPhaseEnd},
	can_trigger = function(self, event, room, player, data)
		if not player or player:isDead() then return "" end
		if player:getPhase() ~= sgs.Player_Finish then return "" end
		player:loseAllMarks("@extraDefense")
		player:loseAllMarks("@extraOffense")
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
initYinYangMark = sgs.CreateTriggerSkill{
	name = "initYinYangMark",
	global = true,
	frequency = sgs.Skill_NotFrequent,
	events = {sgs.GameStart, sgs.EventAcquireSkill, sgs.CardsMoveOneTime},
	can_trigger = function(self, event, room, player, data)
		local skill_table = {"juzhan"}
		--if event == sgs.GameStart then
			for _, p in sgs.qlist(room:getAlivePlayers()) do
				if p:getMark("@yang") == 0 and p:getMark("@yin") == 0 then
					p:gainMark("@yang")
				end
				--[[local has = false
				for _, skill in pairs(skill_table) do
					if p:hasSkill("juzhan") then
						has = true
					end
				end
				if has then
				sendMsg(room,"efefw")
					initYinYangMark(p)
				end--]]
			end
		--elseif event == sgs.EventAcquireSkill and table.contains(skill_table, data:toString()) then
			--initYinYangMark(player)
		--end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		return false 
	end,
	on_effect = function(self, event, room, player, data,ask_who)
		return false
	end
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("fengkuang_maxCard") then
skillList:append(fengkuang_maxCard)
end
if not sgs.Sanguosha:getSkill("extraSlashParams") then
skillList:append(extraSlashParams)
end
if not sgs.Sanguosha:getSkill("extraSlashClear") then
skillList:append(extraSlashClear)
end
if not sgs.Sanguosha:getSkill("initYinYangMark") then
skillList:append(initYinYangMark)
end
if not sgs.Sanguosha:getSkill("extraDistance") then
skillList:append(extraDistance)
end
if not sgs.Sanguosha:getSkill("extraDistanceClear") then
skillList:append(extraDistanceClear)
end
sgs.Sanguosha:addSkills(skillList)	