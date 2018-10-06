sgs.ai_skill_invoke.qiancai = function(self, data)
  return true
end
sgs.ai_skill_invoke.huanbian = function(self, data)
  return true
end
sgs.ai_skill_invoke.moyu = function(self, data)
  return true
end
sgs.ai_skill_invoke.jingguai = function(self, data)
  return true
end
sgs.ai_skill_invoke.juejue = function(self, data)
  if self.player:faceUp() then return true end
end
sgs.ai_skill_invoke.suoyue = function(self, data)
  if self.player:getHandcardNum()>self.player:getHp() then return false end 
  return true
end
sgs.ai_skill_invoke.mowang = function(self, data)
  if self.player:getMark("@xue")>0 and self.player:isWounded() then return true end
end
sgs.ai_skill_invoke.guwei = function(self, data)
  return true 
end
sgs.ai_skill_invoke.lingyuan = function(self, data)
  if self.player:getJudgingArea():isEmpty() then 
  return false else return true end
end
sgs.ai_skill_invoke.yinxue = function(self, data)
  return true
end
sgs.ai_skill_invoke.shuang = function(self, data)
  return true
end
sgs.ai_skill_invoke.duxue = function(self, data)
   local damage=data:toDamage()
   if self:isFriend(damage.to) then return true end
   if self.player:isWounded() then return true else return false end
end
sgs.ai_skill_invoke.tongxin = function(self, data)
   local damage=data:toDamage()
   if self:isWeak(self.player) and not self.player:isKongcheng() and self:isFriendWith(damage.from)and damage.from:hasShownOneGeneral()
   then return true else return false end
end
sgs.ai_skill_invoke.zhanqi = function(self, data)
	local damage = data:toDamage()
	local target = damage.to
	local count=damage.damage
	local source=self.player
	local room=self.room
	if self:isFriend(target) then
	  if target:getHp()==1 then return true end
	  if count>1 then return true end
	end 
	return false
end
qiyuan_skill = {}
qiyuan_skill.name = "qiyuan"
table.insert(sgs.ai_skills, qiyuan_skill)
qiyuan_skill.getTurnUseCard = function(self,inclusive)
	local room=self.room
	local list=room:getAllPlayers()
	if self.player:hasFlag("qiyuan_used") then return nil end
	local benefit = 0
	local count=0	
	for _, player in sgs.qlist(list) do
		if player:isWounded() then
		    count=count+1
			if self:isFriend(player) then 
				benefit = benefit + 1
			else 
				benefit = benefit - 1
			end
		end
	end
	if count==0 then return nil end
	if benefit < 0 then
		return nil
	end
	local cardsnum=self.player:getHandcardNum()
	local cards=sgs.QList2Table(self.player:getHandcards())
	local ids={}
	for _,card in ipairs(cards) do
	  table.insert(ids, card:getEffectiveId())
	end
	  local card_str=("#qiyuanCard:"..(table.concat(ids,"+"))..":&qiyuan")	
	  assert(card_str)
	  return sgs.Card_Parse(card_str)
end
sgs.ai_skill_use_func["#qiyuanCard"] = function(card, use, self) 
	use.card = card	
end
sgs.ai_skill_invoke.juejing = function(self, data)
  local player=self.player
  if player:isKongcheng() then return true end
  if self:isWeak(player) then return false end
  return false
end
juepan_skill = {}
juepan_skill.name = "juepan"
table.insert(sgs.ai_skills, juepan_skill)
juepan_skill.getTurnUseCard = function(self)   
	if self:needBear() then return end			
	if self.player:getMark("@pan")>=6 then		
		return sgs.Card_Parse("#juepanCard:.:&juepan")
	end
end
sgs.ai_skill_use_func["#juepanCard"] = function(card, use, self)
	if #self.enemies == 0 then return end		
	if (self.player:getHandcardNum()<=1) then return end
	if not self:isWeak(self.player) then
	  sgs.ai_use_priority["juepanCard"] = 3
	  local list=self.room:getOtherPlayers(self.player)
     --sgs.ai_use_priority["shenjiangCard"] = 10
	 local can_pin={}	
	for _, player in sgs.qlist(list) do
	  if self:isEnemy(player) then			  
	     table.insert(can_pin,player)
	  end
	end
	    self:sort(can_pin, "threat")
	    local target=can_pin[1]
		if #can_pin>0 then
	    local card_str = "#juepanCard:.:&juepan->"..target:objectName()
	    local acard=sgs.Card_Parse(card_str)	 
	    assert(acard)
	    use.card=acard
	    if use.to then
          use.to:append(target)
        end
	    return 
	   else return	
	   end
   end
end
sgs.ai_skill_invoke.huahun = function(self, data)
  local player=self.player
  if not player:faceUp() then return true end
  local current=self.room:getCurrent()
  if player==current then return false end
  if self:isWeak(player) then return false end
  return true
end
sgs.ai_skill_invoke.zhongjue = function(self, data)
  return true
end
sgs.ai_skill_choice["zhongjue"]=function(self, choices, data)
  local player=self.player
  if self:isWeak(player) then return "rec"end
  if player:getHandcardNum()<2 then return "draw"end
  return "change"
end
sgs.ai_skill_invoke.guming = function(self, data)
  return true
end
sgs.ai_skill_choice["guming"]=function(self, choices, data)
  local player=self.player
  local use = data:toCardUse()
  if self:isFriend(use.from) then return "drawtwo" end
  if player:isKongcheng() and (not player:hasEquip()) then return "drawtwo" end
  if use.card:isKindOf("AmazingGrace") then return "drawtwo" end
  if use.card:isKindOf("GodSalvation") then
    return "drawtwo"  
  end 
  if use.card:isKindOf("ExNihilo") then
    return "drawtwo"  
  end 
  local cards=sgs.QList2Table(self.player:getHandcards())
  local effect=false
  local can_discard=false
  local slash_count=0
  local jink_count=0
  self:sortByUseValue(cards, true)
  for _,card in ipairs(cards) do
    if card:isKindOf("Nullification") then
	  effect=true
    end
	if (not card:isKindOf("Peach")) and (not card:isKindOf("Nullification"))then
	  can_discard=true
    end
	if card:isKindOf("Slash") then
	  slash_count=slash_count+1
	end
	if card:isKindOf("Jink") then
	  jink_count=jink_count+1
	end
  end
  if effect then return "drawtwo" end
  local armor=self.player:getArmor()
  if use.card:isKindOf("FireAttack")and armor and armor:isKindOf("Vine") then
    return "noeffect"
  end	
  if use.card:isKindOf("IronChain") and armor and armor:isKindOf("Vine") then 
    return "noeffect"
  end	
  if use.card:isKindOf("Dismantlement") and player:hasEquip() then
    if can_discard then return "noeffect"
	  else return "drawtwo" 
	end
  end
  if use.card:isKindOf("peach")and player:hasEquip()then
    if can_discard then return "noeffect"
	else return "drawtwo" 
	end
  end
  if use.card:isKindOf("Duel") then
    local use = data:toCardUse()
    local cardsnum=use.from:getHandcardNum()
	if (slash_count==0) then return "noeffect" end
	if (slash_count+2>cardsnum) then return "drawtwo" 
	else return "noeffect" end
  end
  if use.card:isKindOf("SavageAssault") then
    if self:isEquip("Vine")or(slash_count>0) then return "drawtwo"
	else return "noeffect" end
  end
  if use.card:isKindOf("ArcheryAttack") then
    if self:isEquip("Vine")or(jink_count>0) or self:isEquip("EightDiagram") then return "drawtwo"	  
	else return "noeffect" end
  end
  return "drawtwo"
end
local shenjiang = {}
shenjiang.name = "shenjiang"
table.insert(sgs.ai_skills, shenjiang)
shenjiang.getTurnUseCard = function(self) 	
	if not self.player:hasUsed("#shenjiangCard") and not self.player:isKongcheng() then		
		return sgs.Card_Parse("#shenjiangCard:.:&shenjiang")
	end
end
sgs.ai_skill_use_func["#shenjiangCard"] = function(card, use, self)
	if #self.enemies == 0 then return end		
	local room=self.room
	if (self.player:getHandcardNum()<=1) then return end
	if not self:isWeak(self.player) then
	  local log = sgs.LogMessage()
      log.type = "a"
      room:sendLog(log)
	  sgs.ai_use_priority["shenjiangCard"] = 10
	  local max_card = self:getMaxCard()
	    local log = sgs.LogMessage()
      log.type = "b"
      room:sendLog(log)
	  if not max_card then return end
	  local max_point = max_card:getNumber()
	  local list=self.room:getOtherPlayers(self.player)
	  local can_pin={}	
	  local log = sgs.LogMessage()
      log.type = "c"
      room:sendLog(log)
	  for _, player in sgs.qlist(list) do
	   if not self:isFriend(player) and player:getHp()>self.player:getHp() then			  
	     table.insert(can_pin,player)
		end
	  end
	  local log = sgs.LogMessage()
      log.type = "d"
      room:sendLog(log)
     --sgs.ai_use_priority["shenjiangCard"] = 10
	  if #can_pin > 0 then
	  local log = sgs.LogMessage()
      log.type = "e"
      room:sendLog(log)
	    self:sort(can_pin, "threat")
	    local target=can_pin[1]
	    local card_str = "#shenjiangCard:.:&shenjiang->"..target:objectName()
	    local acard=sgs.Card_Parse(card_str)	 
	    assert(acard)
	    use.card=acard
		local log = sgs.LogMessage()
      log.type = "f"
      room:sendLog(log)
	    if use.to then
		local log = sgs.LogMessage()
      log.type = "g"
      room:sendLog(log)
          use.to:append(target)
        end
	    return 
	   else return	
	end
  else
  local log = sgs.LogMessage()
      log.type = "h"
      room:sendLog(log)
    sgs.ai_use_priority["shenjiangCard"] = 3
	local min_card = self:getMinCard()
	local log = sgs.LogMessage()
      log.type = "i"
      room:sendLog(log)
	if not min_card then return end
	local min_point = min_card:getNumber()
	local list=self.room:getOtherPlayers(self.player)
	local can_pin={}
local log = sgs.LogMessage()
      log.type = "j"
      room:sendLog(log)	
	for _, player in sgs.qlist(list) do
	  if not self:isFriend(player) and player:getHp()>self.player:getHp() then				  
	     table.insert(can_pin,player)
	  end
	end
	local log = sgs.LogMessage()
      log.type = "k"
      room:sendLog(log)	
	if #can_pin > 0 then    
	local log = sgs.LogMessage()
      log.type = "l"
      room:sendLog(log)	
	    self:sort(can_pin, "threat")
	    local target=can_pin[1]
	    local card_str = "#shenjiangCard:.:&shenjiang->"..target:objectName()
		local log = sgs.LogMessage()
      log.type = "m"
      room:sendLog(log)	
	    local acard=sgs.Card_Parse(card_str)	 
	    assert(acard)
	    use.card=acard
		local log = sgs.LogMessage()
      log.type = "n"
      room:sendLog(log)	
	    if use.to then
		local log = sgs.LogMessage()
      log.type = "o"
      room:sendLog(log)	
          use.to:append(target)
        end
	    return 
	  else return	
	end
  end
end

sgs.ai_skill_invoke.shenyue = function(self, data)
  local source=self.player
  local room=self.room 
  local move=data:toMoveOneTime()
  if move then 
	  return true end
  local use=data:toCardUse()	 
  local log = sgs.LogMessage()
      log.type = "d"
      room:sendLog(log)
  if self:isEnemy(use.from) then
  local log = sgs.LogMessage()
      log.type = "e"
      room:sendLog(log)
    if use.card:isKindOf("ExNihilo") then
	  return false
	end
	return true
  end
  return false
end 
sgs.ai_skill_invoke.qianxin=function(self, data)
   return true
end
sgs.ai_view_as.heiying = function(card, player, card_place, class_name)
    if not player:getPile("xin"):isEmpty() then 
	  local card = sgs.Sanguosha:getCard(player:getPile("xin"):first())
	  local suit = card:getSuitString()
	  local point = card:getNumberString()
	  local id = card:getEffectiveId()
	  if card_place == sgs.Player_PlaceSpecial and player:getPileName(id) == "xin" then
		local acard=string.format("nullification:heiying[%s:%s]=%d&heiying", suit, point, id)
		return acard
	end
	end
end
sgs.ai_skill_invoke.huanyue=function(self, data)
   local player=self.player
   local room=self.room
   if player:getPhase()==sgs.Player_Discard then return true end
   local dying=data:toDying()
   local victim = dying.who
   local yes=true   
   if player:objectName()==victim:objectName() or(self:isFriend(victim) and not player:getPile("tao"):isEmpty()) then yes=false end
   if (not player:isKongcheng() or player:hasEquip()) and yes then
       local cards=player:getCards("he")
       local effect=false
       local can_discard=false
       self:sortByUseValue(cards, true)
      if #cards>0 then 
      return true   
      end
	end
	return false
end
sgs.ai_view_as.huanyue = function(card, player, card_place)
    local room=player:getRoom()
    if player:getPile("tao"):isEmpty()then
		return 
	end
	 local card = sgs.Sanguosha:getCard(player:getPile("tao"):first())
	  local suit = card:getSuitString()
	  local point = card:getNumberString()
	  local id = card:getEffectiveId()
	  if card_place == sgs.Player_PlaceSpecial and player:getPileName(id) == "tao" then
		local acard=string.format("peach:heiying[%s:%s]=%d&huanyue", suit, point, id)
		return acard
	end
end
--[[huanyue_skill.getTurnUseCard = function(self, inclusive)
	local club= self.player:getPile("yue"):first()
	local room=self.room
		local suit = club:getSuitString()
		local point = club:getNumberString()
		local id = club:getEffectiveId()
		local str = string.format("peach:huanyue[%s:%s]=%d&huanyue", suit, point, id)
		return sgs.Card_Parse(str)
end]]--


local huanyue_skill = {}
huanyue_skill.name = "huanyue"
table.insert(sgs.ai_skills, huanyue_skill)
huanyue_skill.getTurnUseCard = function(self)
	if self.player:getPile("tao"):isEmpty() then
		return nil
	end
	local can_use = false
	local peach=sgs.Sanguosha:getCard(self.player:getPile("tao"):first())
				local suit = peach:getSuitString()
				local number = peach:getNumberString()
				local card_id = peach:getEffectiveId()
				local card_str = ("peach:huanyue[%s:%s]=%d%s"):format(suit, number, card_id, "&huanyue")
				local peach = sgs.Card_Parse(card_str)
				assert(peach)
				return peach
end
leiying_skill = {}
leiying_skill.name = "leiying"
table.insert(sgs.ai_skills,leiying_skill)
leiying_skill.getTurnUseCard = function(self)
  
end

sgs.ai_skill_invoke.yuanan=function(self, data)
  local room=self.room
  local player=self.player
  local list=room:getOtherPlayers(player)
  if player:isWounded() then return true end
  for _,p in sgs.qlist(list) do
    if self:isFriend(p) and p:isWounded() then 
	  return true
	end
	if not p:isWounded() then 
	  return true
	end
  end
  return false
end
sgs.ai_skill_playerchosen["yuanan"] = function(self, targets)
    self:sort(targets, "hp")
	for _,p in sgs.qlist(targets) do
	  if p:objectName()==self.player:objectName() or self:isFriend(p) then return p end
	  if not p:isFriendWith(self.player) and p:getHp()==p:getMaxHp() then return p end
	end
	return targets:first()
end