fengkuang_maxCard = sgs.CreateMaxCardsSkill{  --手牌上限
    name = "fengkuang_maxCard" ,
	global = true,
    extra_func = function(self, target)
		if target:getMark("@shalu1_maxhp") > 0 then
			return - target:getHp() --+ target:getHp() / 10 - 1
		end
    end
}
local skillList = sgs.SkillList()
if not sgs.Sanguosha:getSkill("fengkuang_maxCard") then
skillList:append(fengkuang_maxCard)
end