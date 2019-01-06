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
sgs.Sanguosha:addSkills(skillList)	