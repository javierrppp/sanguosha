--君临天下·变

--[[
1. 由于楼主不会做AI，因此所有武将目前暂无AI。（有空时会从身份局复制AI）
2. 描述为楼主在爆料描述的基础上进行的调整。（请无视荀攸又臭又长的描述）
3. “变更副将”的定义：你从剩余武将牌堆中连续亮出武将牌直到亮出一张与你势力相同的武将牌变更为你的副将直接加入游戏。（而不是飞龙夺凤那样的自己选武将）
4. 由于很多FAQ尚未公布，不保证结算准确性。
5. 图片及称号均采用@Magic96 在吧内发的图片，在此表示感谢。
]]--

sgs.LoadTranslationTable{				--（未修描述）
	["Transformation"] = "君临天下·变",
	["Transformation_Equip"] = "君临天下·变",
	["transform"] = "变更副将",
----------------------------------------------------------------------------------------------------
	["XunYou"] = "荀攸",
	["&XunYou"] = "荀攸",
	["#XunYou"] = "曹魏的谋主",
	["designer:XunYou"] = "淬毒",
	["illustrator:XunYou"] = "G.G.G.",
	["~XunYou"] = "主公……臣下先行告退……",
	
	["Qice"] = "奇策",
	--[":Qice"] = "你可将所有手牌当任意使用时机为出牌阶段空闲时间点且额定目标数不大于X的非延时类锦囊牌使用，且此牌的目标数上限至多为X，然后你可变更副将。每阶段限一次。（X为你的手牌数）",
	--[":Qice"] = "出牌阶段限一次，你可以将所有手牌当一张目标数不大于X的非延时类锦囊牌使用（X为你的手牌数），当此牌结算后，你可以变更副将的武将牌。",
	[":Qice"] = "出牌阶段限一次，你可以将所有手牌当一张目标数不大于X的非延时类锦囊牌使用（X为你的手牌数）。",
	["Qice:transform"] = "你可发动“奇策”变更副将",
	["$Qice1"] = "亲力为国，算无遗策。",
	["$Qice2"] = "奇策在此，谁与争锋。",
	
	["Zhiyu"] = "智愚",
	--[":Zhiyu"] = "当你受到伤害后，你可摸一张牌，然后展示所有手牌，若颜色均相同，来源弃置一张手牌。",
	[":Zhiyu"] = "每当你受到伤害后，你可以摸一张牌：若如此做，你展示所有手牌。若你的手牌均为同一颜色，伤害来源弃置一张手牌。",
	["$Zhiyu1"] = "大勇若怯，大智如愚。",
	["$Zhiyu2"] = "愚者既出，智者何存。",
----------------------------------------------------------------------------------------------------
	["BianFuRen"] = "卞夫人",
	["&BianFuRen"] = "卞夫人",
	["#BianFuRen"] = "奕世之雍容",
	["illustrator:BianFuRen"] = "biou09",
	["cv:BianFuRen"] = "无",
	
	["Wanwei"] = "挽危",
	--[":Wanwei"] = "当你因其他角色的弃置或获得而失去牌时，你可用等量的牌替换失去的牌。",
	[":Wanwei"] = "当你因被其他角色获得或弃置而失去牌时，你可以改为自己选择失去的牌。",
	["@Wanwei"] = "请选择 %arg 张牌替换将被弃置/获得的 %src",
	["$WanweiVisible"] = "%from 用 %card 替换失去的牌",
	["#WanweiInvisible"] = "%from 用 %arg 张手牌替换失去的牌",
	["$WanweiPartiallyVisible"] = "%from 用 %card 和 %arg 张手牌替换失去的牌",
	
	["Yuejian"] = "约俭",
	--[":Yuejian"] = "与你势力相同的角色的弃牌阶段开始时，若其于此回合内未使用过确定目标包括除其外的角色的牌，你令其手牌上限于此回合内为X（X为其体力上限）。",
	[":Yuejian"] = "与你势力相同角色的弃牌阶段开始时，若其本回合未使牌指定过除该角色外的其他角色，你可令其本回合手牌上限等于其体力上限。",
	["#YuejianMaxCards"] = "%to 此回合内手牌上限为 %arg",
----------------------------------------------------------------------------------------------------
	["MaSu"] = "马谡",
	["&MaSu"] = "马谡",
	["#MaSu"] = "兵法在胸",
	["illustrator:MaSu"] = "张帅",
	["~MaSu"] = "败军之罪，万死难赎",
	
	["Sanyao"] = "散谣",
	--[":Sanyao"] = "出牌阶段限一次，你可弃置一张牌并选择一名体力值最大的角色，对其造成1点伤害。",
	[":Sanyao"] = "出牌阶段限一次，你可以弃置一张牌，然后对体力最多的一名角色造成1点伤害。",
	["$Sanyao1"] = "散谣惑敌，不攻自破",
	["$Sanyao2"] = "三人成虎事多有",
	
	["Zhiman_MaSu"] = "制蛮",
	--[":Zhiman"] = "当你对其他角色造成伤害时，你可防止此伤害，获得其装备区或判定区里的一张牌，然后若其与你势力相同，其可明置所有武将牌，然后变更副将。",
	--[":Zhiman"] = "当你对其他角色造成伤害时，你可以防止此伤害，然后你获得其装备区或判定区的一张牌。若该角色与你势力相同，则其可以明置所有武将牌，并变更其副将的武将牌。",
	[":Zhiman"] = "当你对其他角色造成伤害时，你可以防止此伤害，然后你获得其装备区或判定区的一张牌。",
	["#Zhiman-second_MaSu"] = "制蛮（获得目标装备区或判定区里的一张牌）",
	["#Zhiman"] = "%from 防止了对 %to 的伤害",
	["$Zhiman_MaSu1"] = "丞相多虑，且看我的",
	["$Zhiman_MaSu2"] = "兵法谙熟于心，取胜千里之外",
----------------------------------------------------------------------------------------------------
	["ShaMoKe"] = "沙摩柯",
	["&ShaMoKe"] = "沙摩柯",
	["#ShaMoKe"] = "五溪番王",
	["cv:ShaMoKe"] = "无",
	["illustrator:ShaMoKe"] = "张帅",
	
	["Jili"] = "蒺藜",
	--[":Jili"] = "当你于出牌阶段内使用第X张牌时，你可摸X张牌；你使用【杀】的额外次数上限+X。（X为你的攻击范围）",
	[":Jili"] = "每当你于出牌阶段内使用第X张牌时，你可以摸X张牌；你可以额外使用X张【杀】（X为你装备区里武器牌的攻击范围）。",
----------------------------------------------------------------------------------------------------
	["LingTong"] = "凌统",
	["&LingTong"] = "凌统",
	["#LingTong"] = "旋略勇进",
	["illustrator:LingTong"] = "霸三国",
	["~LingTong"] = "大丈夫不惧死亡。",
	
	["Liefeng"] = "烈风",
	--[":Liefeng"] = "当你失去一张装备牌后，你可弃置一名其他角色的一张牌。",
	[":Liefeng"] = "每当你失去装备区里的牌时，可以弃置一名其他角色一张牌。",
	
	["Xuanlue"] = "旋略",
	--[":Xuanlue"] = "限定技，出牌阶段，你可获得场上的一至三张装备牌，然后将这些牌置入至多三名角色的装备区。",
	[":Xuanlue"] = "限定技，出牌阶段，你可以获得场上至多三张装备牌，然后将这些牌置入至多三名角色装备区内",
----------------------------------------------------------------------------------------------------
	["LyuFan"] = "吕范",
	["&LyuFan"] = "吕范",
	["#LyuFan"] = "忠笃亮直",
	["cv:LyuFan"] = "无",
	["illustrator:LyuFan"] = "琛·美弟奇",
	
	["Diaodu"] = "调度",
	--[":Diaodu"] = "出牌阶段限一次，你可令与你势力相同的所有角色各选择一项：1. 使用手牌中的一张装备牌；2. 将装备区里的一张牌置入另一名与你势力相同的角色的装备区。",
	[":Diaodu"] = "出牌阶段限一次，你可令所有与你相同势力的角色依次选择一项：使用手牌中的一张装备牌，或将装备区里的一张牌移动至另一名与你相同势力的角色的装备区。",
	
	["Diancai"] = "典才",
	--[":Diancai"] = "其他角色的出牌阶段结束时，若你于此阶段内失去的牌数不小于你已损失的体力值，你可将手牌补至X张（X为你的体力上限），然后你可变更副将。",
	[":Diancai"] = "其他角色的出牌阶段结束时，若你本阶段失去了X张或更多的牌（X为你已损失的体力值），你可以将手牌补至体力上限，然后你可以变更副将的武将牌。",
----------------------------------------------------------------------------------------------------
	["Zuoci"] = "左慈",
	["&Zuoci"] = "左慈",
	["#Zuoci"] = "谜之仙人",
	["cv:Zuoci"] = "东方胤弘，眠眠",
	["illustrator:Zuoci"] = "biou09",
	["~Zuoci"] = "释知遗形，神灭形消。",
	
	["Huashen"] = "化身",
	--[":Huashen"] = "准备阶段开始时，你可随机选择并观看五张游戏外的武将牌，然后亮出其中两张势力相同的武将牌并将这些牌置于一旁，形成“化身牌堆”，且将“化身牌堆”中的其他武将牌移出游戏，若如此做，你获得所有“化身牌”的技能，然后暗置你的另一张武将牌；你不能明置另一张武将牌。",
	[":Huashen"] = "准备阶段开始时，你可以观看剩余武将牌堆中的五张牌，亮出其中两张相同势力的武将牌置于你的武将牌旁，称为“化身”（若已有“化身”则将原来的“化身”置入剩余武将牌堆），你获得“化身”的技能，暗置你的另一张武将牌；若此武将牌处于明置状态，你不能明置另一张武将牌。",
	["$Huashen1"] = "藏形变身，自在吾心。",
	["$Huashen2"] = "遁形幻千，随意所欲。",
	["$Huashen3"] = "藏形变身，自在吾心。(女声)",
	["$Huashen4"] = "遁形幻千，随意所欲。(女声)",
	
	["Xinsheng"] = "新生",
	--[":Xinsheng"] = "当你受到伤害后，你可随机亮出一张游戏外的武将牌，若此武将势力与“化身牌”：相同，你可用此牌替换一张“化身牌”；不同，你重复此流程。",
	[":Xinsheng"] = "当你受到伤害后，你可以从剩余武将牌中连续亮出武将牌，直到亮出一张与“化身”相同势力的武将牌为止，然后你可以将之与一张“化身”替换。",
	["$Xinsheng1"] = "吐故纳新，师法天地。",
	["$Xinsheng2"] = "灵根不灭，连绵不绝。",
	["$Xinsheng3"] = "吐故纳新，师法天地。(女声)",
	["$Xinsheng4"] = "灵根不灭，连绵不绝。(女声)",
----------------------------------------------------------------------------------------------------
	["LiJueGuoSi"] = "李傕＆郭汜",
	["&LiJueGuoSi"] = "李傕郭汜",
	["#LiJueGuoSi"] = "飞熊狂豺",
	["cv:LiJueGuoSi"] = "无",
	["illustrator:LiJueGuoSi"] = "XXX",
	
	["Xichou"] = "隙仇",
	--[":Xichou"] = "锁定技，当你首次明置此武将牌后，你加2点体力上限，然后回复2点体力；锁定技，当你于出牌阶段内使用牌时，若此牌与你于此阶段内使用的上一张牌的颜色不同且没有角色处于濒死状态，你失去1点体力。",
	[":Xichou"] = "锁定技，当你第一次明置此武将牌时，你加2点体力上限并回复2点体力；当你于出牌阶段使用与本阶段你使用的上一张牌不同颜色的牌时，若没有角色处于濒死状态，你失去1点体力。",
----------------------------------------------------------------------------------------------------
	["lord_SunQuan"] = "孙权-君",
	["&lord_SunQuan"] = "孙权",
	["#lord_SunQuan"] = "蛟盘江南？",
	["cv:lord_SunQuan"] = "无",
	["illustrator:lord_SunQuan"] = "张帅",
	
	["Jiahe"] = "嘉禾",
	--[":Jiahe"] = "君主技，锁定技，你拥有“缘江烽火图”。",
	[":Jiahe"] = "君主技，若此武将牌处于明置状态，你便拥有“缘江烽火图”。",
	
	["Lianzi"] = "敛资",
	--[":Lianzi"] = "出牌阶段限一次，你可弃置一张手牌，观看牌堆顶的X张牌（X为吴势力角色装备区里的牌数之和），然后先展示其中任意数量的与你执行消耗弃置的牌类别相同的牌再获得之。",
	[":Lianzi"] = "出牌阶段限一次，你可以弃置一张手牌，然后观看牌堆顶的X张牌（X为吴势力角色装备牌里的牌数量之和），展示并获得其中任意张与你弃置的牌相同类别的牌。",
	
	["Jubao"] = "聚宝",
	--[":Jubao"] = "锁定技，其他角色不能获得你装备区里的宝物牌；锁定技，结束阶段开始时，你获得一名装备区里有【定澜夜明珠】的角色的一张牌，然后摸一张牌。",
	[":Jubao"] = "锁定技，你装备区里的宝物牌不能被其他角色获得；结束阶段开始时，你获得装备区里有【定澜夜明珠】的角色的一张牌，然后摸一张牌。",
----------------------------------------------------------------------------------------------------
	["LuminousPearl"] = "定澜夜明珠",
	--[":LuminousPearl"] = "装备牌·宝物\n\n技能：锁定技，若你有“制衡”，此“制衡”描述中的“一至X张牌”改为“至少一张牌”，否则你拥有“制衡”。",
	[":LuminousPearl"] = "装备牌·宝物\n\n技能：锁定技，你视为拥有技能“制衡”若你已拥有“制衡”，则改为取消弃置牌数的限制。",
}

---------------------------------------------君临天下·变--------------------------------------------

extension = sgs.Package("Transformation", sgs.Package_GeneralPack)
--extensionEquip = sgs.Package("Transformation_Equip", sgs.Package_CardPack)

--[[ WEI ??? 荀攸
	武将：XunYou
	武将名：荀攸
	体力上限：3
	武将技能：
		奇策：你可将所有手牌当任意使用时机为出牌阶段空闲时间点且额定目标数不大于X的非延时类锦囊牌使用，且此牌的目标数上限至多为X，然后你可变更副将。每阶段限一次。（X为你的手牌数）
		智愚：当你受到伤害后，你可摸一张牌，然后展示所有手牌，若颜色均相同，来源弃置一张手牌。
	状态：验证通过
]]--
XunYou = sgs.General(extension, "XunYou", "wei", 3, true)
XunYou:addCompanion("xunyu")

--[[
	技能名：奇策
	技能：Qice
	描述：你可将所有手牌当任意使用时机为出牌阶段空闲时间点且额定目标数不大于X的非延时类锦囊牌使用，且此牌的目标数上限至多为X，然后你可变更副将。每阶段限一次。（X为你的手牌数）
	状态：验证通过
]]--
QiceCard = sgs.CreateSkillCard{
	name = "QiceCard",
	skill_name = "Qice",
	will_throw = false,
	target_fixed = function(self)
        local _card = sgs.Sanguosha:cloneCard(sgs.Self:getTag("Qice"):toString())
        if _card == nil then
            return false
        end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:addSubcards(self:getSubcards())
		card:setCanRecast(false)
		card:deleteLater()
		return card and card:targetFixed()
	end,
	filter = function(self, targets, to_select)
		local players = sgs.PlayerList()
		if next(targets) ~= nil then
			for i = 1 , #targets do
				players:append(targets[i])
			end
		end
        local _card = sgs.Sanguosha:cloneCard(sgs.Self:getTag("Qice"):toString())
        if _card == nil or _card:targetFixed() then  --为什么在targetFixed里判断没用？？
            return false
        end
        local card = sgs.Sanguosha:cloneCard(_card)
		card:addSubcards(self:getSubcards())
        card:setCanRecast(false)
        card:deleteLater()
		if (players:length() >= self:subcardsLength()) and not card:isKindOf("Collateral") then
			return false
		end
		
		if card:isKindOf("AllianceFeast") then
			if to_select:getRole() == "careerist" then
				if self:subcardsLength() < 2 then return false end
			else
				local af_targets = sgs.PlayerList()
				for _,p in sgs.qlist(sgs.Self:getAliveSiblings()) do
					if (p:getRole() ~= "careerist") and p:hasShownOneGeneral() and (p:getKingdom() == to_select:getKingdom()) and not sgs.Self:isProhibited(p, card) then
						af_targets:append(p)
					end
				end
				if (af_targets:length() >= self:subcardsLength()) then return false end
			end
		end
        return card and card:targetFilter(players, to_select, sgs.Self) and not sgs.Self:isProhibited(to_select, card, players)
	end,
	feasible = function(self, targets)
		local players = sgs.PlayerList()
		if next(targets) ~= nil then
			for i = 1 , #targets do
				players:append(targets[i])
			end
		end
		local _card = sgs.Sanguosha:cloneCard(sgs.Self:getTag("Qice"):toString())
        if _card == nil then
            return false
        end
		local card = sgs.Sanguosha:cloneCard(_card)
		card:addSubcards(self:getSubcards())
		local can_recast = card:canRecast()
		card:setCanRecast(false)
		card:deleteLater()
		if card:isKindOf("Collatereal") then
			if players:length() / 2 > self:subcardsLength() then return false end
		else
			if players:length() > self:subcardsLength() then return false end
		end
		
		if can_recast and not card:isKindOf("FightTogether") then   --知己知彼源码有bug（968行忘加rec &&）
			if players:length() == 0 then return false end
		end
		return card and card:targetsFeasible(players, sgs.Self)
    end,
	on_validate = function(self, card_use)
        local xunyou = card_use.from
        local room = xunyou:getRoom()
        local user_str = self:getUserString()
        --local user_str = self:toString():split(":"):last()
        --xunyou:setTag("GuhuoSlash", sgs.QVariant(user_str))
		local use_card = sgs.Sanguosha:cloneCard(user_str)
        use_card:setSkillName("Qice")
        use_card:addSubcards(self:getSubcards())
        use_card:setCanRecast(false)
        use_card:setShowSkill("Qice")
		
		local available = true
		local targets = sgs.SPlayerList()
		if use_card:isKindOf("AwaitExhausted") then
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if not xunyou:isProhibited(p, use_card) and xunyou:hasShownOneGeneral() and (xunyou:getRole() ~= "careerist") and (p:getRole() ~= "careerist") and p:hasShownOneGeneral() and (p:getKingdom() == xunyou:getKingdom()) then
					targets:append(p)
				end
			end
		elseif (use_card:getSubtype() == "global_effect") and not use_card:isKindOf("FightTogether") then
			for _,p in sgs.qlist(room:getAlivePlayers()) do
				if not xunyou:isProhibited(p, use_card) then
					targets:append(p)
				end
			end
		elseif use_card:isKindOf("FightTogether") then
			--local big_kingdoms = xunyou:getBigKingdoms("Qice", sgs.MaxCardsType_Normal)
			local big_kingdoms = xunyou:getBigKingdoms("Qice", 0)
			local bigs = sgs.SPlayerList()
			local smalls = sgs.SPlayerList()
			for _,p in sgs.qlist(room:getAllPlayers()) do
				if not xunyou:isProhibited(p, use_card) then
					local kingdom = p:objectName()
					if (#big_kingdoms == 1) and string.startsWith(big_kingdoms[1], "sgs") then  --for JadeSeal
						if table.contains(big_kingdoms, kingdom) then
							bigs:append(p)
						else
							smalls:append(p)
						end
					else
						if not p:hasShownOneGeneral() then
							smalls:append(p)
						else
							if p:getRole() == "careerist" then
								kingdom = "careerist"
							else
								kingdom = p:getKingdom()
							end
							if table.contains(big_kingdoms, kingdom) then
								bigs:append(p)
							else
								smalls:append(p)
							end
						end
					end
				end
			end
			if ((smalls:length() > 0) and (smalls:length() < bigs:length()) and (bigs:length() > 0)) or ((smalls:length() > 0) and (bigs:length() == 0)) then
				targets = smalls
			elseif ((smalls:length() > 0) and (smalls:length() --[[>]]>= bigs:length()) and (bigs:length() > 0)) or ((smalls:length() == 0) and (bigs:length() > 0)) then  --疑似源码bug
				targets = bigs
			end
		elseif (use_card:getSubtype() == "aoe") and (not use_card:isKindOf("BurningCamps")) then  --源码subtype打成AOE是bug
			for _,p in sgs.qlist(room:getOtherPlayers(xunyou)) do
				if not xunyou:isProhibited(p, use_card) then
					targets:append(p)
				end
			end
		elseif use_card:isKindOf("BurningCamps") then
			local players = xunyou:getNextAlive():getFormation()
			for _,p in sgs.qlist(players) do
				if not xunyou:isProhibited(p, use_card) then
					--targets:append(room:findPlayerbyobjectName(p:objectName()))  --findPlayerbyobjectName未定义
					for _,p2 in sgs.qlist(room:getAllPlayers()) do
						if p2:objectName() == p:objectName() then
							targets:append(p2)
						end
					end
				end
			end
		end
		if targets:length() > self:subcardsLength() then
			return nil
		end
		
        local tos = card_use.to
        for _, to in sgs.qlist(tos) do
            --[[local skill = room:isProhibited(xunyou, to, use_card)
            if skill then
				if skill:isVisible() then
					local msg = sgs.LogMessage()
					msg.type = "#SkillAvoid"
					msg.from = to
					msg.arg = skill:objectName()
					msg.arg2 = use_card:objectName()
					room:sendLog(msg)
					room:broadcastSkillInvoke(skill:objectName())
				end
                card_use.to:removeOne(to)
            end]]  --本来觉得我这段代码才对，源代码碰到prohibited直接无效，但实测竟然可以……
			if xunyou:isProhibited(to, use_card) then
				available = false
				break
			end
        end
		available = available and use_card:isAvailable(xunyou)
		use_card:deleteLater()
		if not available then return nil end
        return use_card
    end
}
QiceVS = sgs.CreateZeroCardViewAsSkill{   
	name = "Qice",
	view_as = function(self)
		local c = sgs.Self:getTag(self:objectName()):toString()
		if c ~= "" then
			local card = QiceCard:clone()
			card:addSubcards(sgs.Self:getHandcards())
			--[[card:setSkillName(self:objectName())
			card:setShowSkill(self:objectName())
			card:setCanRecast(false)]]
			card:setUserString(c)
			return card
		end
		return nil
	end,
	enabled_at_play = function(self, player)
		return not player:isKongcheng() and player:usedTimes("#QiceCard") == 0
	end,
}
Qice = sgs.CreateTriggerSkill{
	name = "Qice",
	can_preshow = false,
	events = {sgs.CardFinished},
	guhuo_type = "t",
	view_as_skill = QiceVS,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive()) then return "" end
		local use = data:toCardUse()
		if use.card:getTypeId() == sgs.Card_TypeTrick and use.card:getSkillName(true) == "Qice" then
			--return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke("transform") then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		--transformDupGeneral(player)
		return false 
	end,
}
XunYou:addSkill(Qice)

--[[
	技能名：智愚
	技能：Zhiyu
	描述：当你受到伤害后，你可摸一张牌，然后展示所有手牌，若颜色均相同，来源弃置一张手牌。
	状态：验证通过
]]--
Zhiyu = sgs.CreateMasochismSkill{
	name = "Zhiyu",
	can_preshow = true,
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)	
		if not player or player:isDead() or not player:hasSkill(self:objectName()) then return "" end
		return self:objectName()
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true 
		end
		return false 
	end,
	on_damaged = function(self, player, damage)
		local room = player:getRoom()
		room:drawCards(player, 1, self:objectName())
		room:showAllCards(player)
		local same = true
		local isRed = player:getHandcards():first():isRed()
		for _,cd in sgs.qlist(player:getHandcards()) do
			if cd:isRed() ~= isRed then
				same = false
				break
			end
		end
		if same and damage.from and not damage.from:isKongcheng() and damage.from:canDiscard(damage.from, "h") then
			--room:doAnimate(sgs.AnimateType.S_ANIMATE_INDICATE, player:objectName(), damage.from:objectName())
			room:doAnimate(1, player:objectName(), damage.from:objectName())
			room:askForDiscard(damage.from, self:objectName(), 1, 1)
		end
	end,
}
XunYou:addSkill(Zhiyu)

----------------------------------------------------------------------------------------------------

--[[ WEI ??? 卞夫人
	武将：BianFuRen
	武将名：卞夫人
	体力上限：3
	武将技能：
		挽危：当你因其他角色的弃置或获得而失去牌时，你可用等量的牌替换失去的牌。
		约俭：与你势力相同的角色的弃牌阶段开始时，若其于此回合内未使用过确定目标包括除其外的角色的牌，你令其手牌上限于此回合内为X（X为其体力上限）。
	状态：验证通过
]]--
BianFuRen = sgs.General(extension, "BianFuRen", "wei", 3, false)
BianFuRen:addCompanion("caocao")
BianFuRen:addCompanion("CaoCao_LB")

--[[
	技能名：挽危
	技能：Wanwei
	描述：当你因其他角色的弃置或获得而失去牌时，你可用等量的牌替换失去的牌。
	状态：验证通过（但是程序机构有bug）
]]--
Wanwei = sgs.CreateTriggerSkill{
	name = "Wanwei",
	can_preshow = true,
	events = {sgs.BeforeCardsMove, sgs.CardsMoveOneTime},
	on_record = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return end
		if event == sgs.CardsMoveOneTime then
			local move = data:toMoveOneTime()
			if move.from and (move.from:objectName() == player:objectName()) and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) and not (move.to and (move.to:objectName() ~= player:objectName()) and ((move.to_place == sgs.Player_PlaceHand) or (move.to_place == sgs.Player_PlaceEquip))) then
				for _,id in sgs.qlist(move.card_ids) do
					room:setCardFlag(id, "-Wanwei")
					room:setCardFlag(id, "-WanweiAvailable")
				end
			end
		end
	end,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if event == sgs.BeforeCardsMove then
			local move = data:toMoveOneTime()
			if move.from and (move.from:objectName() == player:objectName()) and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) and (((move.reason.m_reason == sgs.CardMoveReason_S_REASON_DISMANTLE) and (move.reason.m_playerId ~= move.reason.m_targetId)) or (move.to and (move.to:objectName() ~= player:objectName()) and (move.to_place == sgs.Player_PlaceHand) and (move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_GIVE) and (move.reason.m_reason ~= sgs.CardMoveReason_S_REASON_SWAP))) then
				for _,id in sgs.qlist(move.card_ids) do
					if sgs.Sanguosha:getCard(id):hasFlag("Wanwei") then return "" end
					room:setCardFlag(id, "WanweiAvailable")  --与源码的不同之处：为了防止出现一个move中包含多个区域，用此flag标注可替代的牌
				end
				return self:objectName()
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data)
		local move = data:toMoveOneTime()
		local num = 0
		local card_names = {}
		--local handcard_force_visible = false
		for _,id in sgs.qlist(move.card_ids) do
			if sgs.Sanguosha:getCard(id):hasFlag("WanweiAvailable") then
				num = num + 1
				table.insert(card_names, sgs.Sanguosha:getCard(id):getFullName(true))
				--[[if (room:getCardPlace(id) == sgs.Player_PlaceHand) and move.open:at(move.card_ids:indexOf(id)) then
					handcard_force_visible = true
				end]]
			end
		end
		local prompt = "@Wanwei:" .. table.concat(card_names, ",") .. ":" .. num
		local result = room:askForExchange(player, self:objectName(), num, num, prompt, "")
		if not result or (result:subcardsLength() < num) then return false end
		for _,id in sgs.qlist(move.card_ids) do
			if sgs.Sanguosha:getCard(id):hasFlag("WanweiAvailable") then
				room:setCardFlag(id, "-WanweiAvailable")
				move.from_places:removeAt(move.card_ids:indexOf(id))
				table.remove(move.from_pile_names, move.card_ids:indexOf(id)+1)
				--move.open:removeAt(move.card_ids:indexOf(id))
				move.card_ids:removeOne(id)
			end
		end
		--local equips = {}
		--local handcards = {}
		for _,id in sgs.qlist(result:getSubcards()) do
			room:setCardFlag(id, "Wanwei")
			move.from_places:append(room:getCardPlace(id))
			move.card_ids:append(id)
			--move.open:append((room:getCardPlace(id) == sgs.Player_PlaceEquip) and true or handcard_force_visible)
			--table.insert((room:getCardPlace(id) == sgs.Player_PlaceEquip) and equips or handcards, sgs.Sanguosha:getCard(card_id):toString())
		end
		data:setValue(move)
		
		--[[local msg = sgs.LogMessage()
		if ((next(equips) ~= nil) and (next(handcards) == nil)) or handcard_force_visible then
			msg.type = "$WanweiVisible"
			msg.card_str = table.concat({table.concat(equips, "+"), table.concat(handcards, "+")}, "+")
		elseif (next(equips) == nil) and (next(handcards) ~= nil) then
			msg.type = "#WanweiInvisible"
			msg.arg = #handcards
		else
			msg.type = "$WanweiPartiallyVisible"
			msg.card_str = table.concat(equips, "+")
			msg.arg = #handcards
		end
		msg.from = player
		room:sendLog(msg)]]
		return false
	end,
}
BianFuRen:addSkill(Wanwei)

--[[
	技能名：约俭
	技能：Yuejian
	描述：与你势力相同的角色的弃牌阶段开始时，若其于此回合内未使用过确定目标包括除其外的角色的牌，你令其手牌上限于此回合内为X（X为其体力上限）。
	状态：验证通过
]]--
Yuejian = sgs.CreateTriggerSkill{
	name = "Yuejian",
	can_preshow = true,
	events = {sgs.CardUsed, sgs.EventPhaseStart},
	on_record = function(self, event, room, player, data)
		if (event == sgs.CardUsed) and not player:hasFlag("Yuejian") and (room:getCurrent():objectName() == player:objectName()) then
			local use = data:toCardUse()
			if (use.card:getTypeId() ~= sgs.Card_TypeSkill) and use.from then
				for _,p in sgs.qlist(use.to) do
					if p:objectName() ~= player:objectName() then
						room:setPlayerFlag(player, "Yuejian")
						break
					end
				end
			end
		end
	end,
	can_trigger = function(self, event, room, player, data)
		if (event == sgs.EventPhaseStart) and not player:hasFlag("Yuejian") and (player:getPhase() == sgs.Player_Discard) then
			local skills = {}
			local players = {}
			for _,bianfuren in sgs.qlist(room:findPlayersBySkillName(self:objectName())) do
				if bianfuren:willBeFriendWith(player) then
					table.insert(skills, self:objectName())
					table.insert(players, bianfuren:objectName())
				end
			end
			return table.concat(skills, "|"), table.concat(players, "|")  --luaskills.i L466-493
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data, ask_who)
		if ask_who:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), ask_who)
			return true 
		end
		return false 
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		room:setPlayerFlag(player, "YuejianKeep")
		local msg = sgs.LogMessage()
		msg.type, msg.arg = "#YuejianMaxCards", player:getMaxHp()
		msg.to:append(player)
		room:sendLog(msg)
	end,
}
YuejianMaxCards = sgs.CreateMaxCardsSkill{
	name = "#Yuejian-MaxCard",
	fixed_func = function(self, target)
		if target:hasFlag("YuejianKeep") then
			return target:getMaxHp()
		end
		return -1
	end
}
BianFuRen:addSkill(Yuejian)
BianFuRen:addSkill(YuejianMaxCards)
extension:insertRelatedSkills("Yuejian", "#Yuejian-MaxCard")

----------------------------------------------------------------------------------------------------

--[[ SHU ??? 马谡
	武将：MaSu
	武将名：马谡
	体力上限：3
	武将技能：
		散谣：出牌阶段限一次，你可以弃置一张牌，然后对体力最多的一名角色造成1点伤害。
		制蛮：当你对其他角色造成伤害时，你可以防止此伤害，然后你获得其装备区或判定区的一张牌。若该角色与你势力相同，则其可以明置所有武将牌，并变更其副将的武将牌。
	状态：验证通过
]]--
MaSu = sgs.General(extension, "MaSu", "shu", 3, true)

--[[
	技能名：散谣
	技能：Sanyao
	描述：出牌阶段限一次，你可以弃置一张牌，然后对体力最多的一名角色造成1点伤害。
	状态：验证通过
]]--
SanyaoCard = sgs.CreateSkillCard{
	name = "SanyaoCard",
	skill_name = "Sanyao",
    will_throw = true,
	filter = function(self, selected, to_select)
		if not to_select then return false end
		local players = sgs.Self:getAliveSiblings()
		players:append(sgs.Self)
		local maxhp = -1000
		for _,p in sgs.qlist(players) do
			maxhp = math.max(maxhp, p:getHp())
		end
		return to_select:getHp() == maxhp
	end,
	on_effect = function(self, effect)
		effect.from:getRoom():damage(sgs.DamageStruct("Sanyao", effect.from, effect.to))
	end,
}
Sanyao = sgs.CreateOneCardViewAsSkill{
	name = "Sanyao",
	filter_pattern = ".!",
	view_as = function(self, card)
        local sanyao_card = SanyaoCard:clone()
		sanyao_card:addSubcard(card)
        sanyao_card:setShowSkill(self:objectName())
        return sanyao_card
	end,
	enabled_at_play = function(self, player)
        return player:canDiscard(player, "he") and not player:hasUsed("#SanyaoCard")
	end,
}
MaSu:addSkill(Sanyao)

--[[
	技能名：制蛮
	技能：Zhiman
	描述：当你对其他角色造成伤害时，你可以防止此伤害，然后你获得其装备区或判定区的一张牌。若该角色与你势力相同，则其可以明置所有武将牌，并变更其副将的武将牌。
	状态：验证通过（技能代码移至关索）
]]--
Zhiman_MaSu = sgs.CreateZhimanSkill("MaSu")
ZhimanSecond_MaSu = sgs.CreateZhimanSecondSkill("MaSu")
MaSu:addSkill(Zhiman_MaSu)
MaSu:addSkill(ZhimanSecond_MaSu)
extension:insertRelatedSkills("Zhiman_MaSu", "#Zhiman-second_MaSu")
--[[Zhiman = sgs.CreateTriggerSkill{
	name = "Zhiman",
	can_preshow = true,
	events = {sgs.DamageCaused},
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		local damage = data:toDamage()
		if damage.to and (player:objectName() ~= damage.to:objectName()) then
			return self:objectName()
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		player:setTag("Zhiman_data", data)  --for AI
		local dat = sgs.QVariant()
		dat:setValue(data:toDamage().to)
		local invoke = player:askForSkillInvoke(self:objectName(), dat)
		player:removeTag("Zhiman_data")
		if invoke then
			room:broadcastSkillInvoke(self:objectName(), 1, player)
			return true
		end
		return false
	end,
	on_effect = function(self, event, room, player, data)
		local damage = data:toDamage()
		local to = damage.to
		local msg = sgs.LogMessage()
		msg.type, msg.from, msg.arg = "#Zhiman", player, self:objectName()
		msg.to:append(to)
		room:sendLog(msg)
		room:setPlayerMark(to, self:objectName(), 1)
		local dat = sgs.QVariant()
		dat:setValue(player)
		to:setTag("Zhiman_from", dat)
		return true
	end,
}
ZhimanSecond = sgs.CreateTriggerSkill{
	name = "Zhiman-second",
	global = true,
	events = {sgs.DamageComplete},
	can_trigger = function(self, event, room, player, data)
		local damage = data:toDamage()
		if (damage.to:objectName() == player:objectName()) and (player:getMark("Zhiman") > 0) then
			local masu = player:getTag("Zhiman_from"):toPlayer()
			if masu and (masu:objectName() == damage.from:objectName()) and masu:hasShownSkill("Zhiman") then
				return self:objectName(), masu
			end
		end
		return ""
	end,
	on_effect = function(self, event, room, player, data, ask_who)
		player:removeTag("Zhiman_from")
		room:setPlayerMark(player, "Zhiman", 0)
		if not player:getCards("ej"):isEmpty() then  --to be replaced with canget
			local card_id = room:askForCardChosen(ask_who, player, "ej", "Zhiman")
			local reason = sgs.CardMoveReason(sgs.CardMoveReason_S_REASON_EXTRACTION, ask_who:objectName())
			room:obtainCard(ask_who, sgs.Sanguosha:getCard(card_id), reason)
		end
		--if player:isFriendWith(ask_who) and player:askForSkillInvoke("transform") then
		--end
	end,
}
MaSu:addSkill(Zhiman)
local skills = sgs.SkillList()
if not sgs.Sanguosha:getSkill("Zhiman-second") then skills:append(ZhimanSecond) end
sgs.Sanguosha:addSkills(skills)]]

----------------------------------------------------------------------------------------------------

--[[ SHU ??? 沙摩柯
	武将：ShaMoKe
	武将名：沙摩柯
	体力上限：4
	武将技能：
		蒺藜：每当你于出牌阶段内使用第X张牌时，你可以摸X张牌；你可以额外使用X张【杀】（X为你装备区里武器牌的攻击范围）。
	状态：
]]--
ShaMoKe = sgs.General(extension, "ShaMoKe", "shu", 4, true)

--[[
	技能名：蒺藜
	技能：Jili
	描述：每当你于出牌阶段内使用第X张牌时，你可以摸X张牌；你可以额外使用X张【杀】（X为你装备区里武器牌的攻击范围）。
	状态：
	注：亮将代码在from_v2的showTMSkillForSlash中
]]--
JiliRecord = sgs.CreateTriggerSkill{
	name = "#Jili-record", 
	events = {sgs.PreCardUsed, sgs.CardResponded, sgs.EventPhaseChanging},
	global = true,
	priority = 7,
	on_record = function(self, event, room, player, data)
		if ((event == sgs.PreCardUsed) or (event == sgs.CardResponded)) and (player:getPhase() == sgs.Player_Play) then
			local card = nil
			if event == sgs.PreCardUsed then
				card = data:toCardUse().card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			if card and (card:getHandlingMethod() == sgs.Card_MethodUse) and (card:getTypeId() ~= sgs.Card_TypeSkill) then
				room:addPlayerMark(player, "Jili")
			end
		elseif (event == sgs.EventPhaseChanging) and (data:toPhaseChange().from == sgs.Player_Play) then  --todo：验证被明鉴是否会清空
			room:setPlayerMark(player, "Jili", 0)
		end
	end,
	can_trigger = function(self, event, room, player, data)
		return ""
	end,
}
Jili = sgs.CreateTriggerSkill{
	name = "Jili", 
	events = {sgs.CardUsed, sgs.CardResponded},
	frequency = sgs.Skill_Frequent,
	can_trigger = function(self, event, room, player, data)
		if not (player and player:isAlive() and player:hasSkill(self:objectName())) then return "" end
		if (player:getPhase() == sgs.Player_Play) and player:getWeapon() then
			local card = nil
			if event == sgs.CardUsed then
				card = data:toCardUse().card
			elseif event == sgs.CardResponded then
				local response = data:toCardResponse()
				if response.m_isUse then
					card = response.m_card
				end
			end
			local wcard = player:getWeapon():getRealCard():toWeapon()
			if card and (card:getHandlingMethod() == sgs.Card_MethodUse) and (card:getTypeId() ~= sgs.Card_TypeSkill) then
				if player:getMark(self:objectName()) == wcard:getRange() then
					return self:objectName()
				end
			end
		end
		return ""
	end,
	on_cost = function(self, event, room, player, data)
		if player:askForSkillInvoke(self:objectName(), data) then
			room:broadcastSkillInvoke(self:objectName(), player)
			return true
		end
	end,
	on_effect = function(self, event, room, player, data)
		if player:getWeapon() then
			local wcard = player:getWeapon():getRealCard():toWeapon()
			player:drawCards(wcard:getRange(), self:objectName())
		end
		return false
	end,
}
JiliTM = sgs.CreateTargetModSkill{
	name = "#Jili-slash",
	residue_func = function(self, from, card)
		--if not sgs.Sanguosha:matchExpPattern(pattern, from, card) then return 0 end
		if from:hasSkill(self:objectName()) and from:getWeapon() then
			local weapon = from:getWeapon():getRealCard():toWeapon()
			assert(weapon)
			if card:isVirtualCard() and card:getSubcards():contains(weapon:getEffectiveId()) then return 0 end
			return weapon:getRange()
		else
			return 0
		end
	end,
}
ShaMoKe:addSkill(Jili)
ShaMoKe:addSkill(JiliRecord)
ShaMoKe:addSkill(JiliTM)
extension:insertRelatedSkills("Jili", "#Jili-record")
extension:insertRelatedSkills("Jili", "#Jili-slash")

----------------------------------------------------------------------------------------------------

return {extension--[[, extensionEquip]]}