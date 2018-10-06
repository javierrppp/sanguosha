math.randomseed(os.time())

------------------------------------------通用函数（技能）------------------------------------------

-------------------------------------------通用函数（AI）-------------------------------------------

--判断是否需要将牌置于牌堆顶（纵玄、涯角、攻心、灭计）【未写】
function SmartAI:shouldPutCardsToDrawPile(cards, skillName, judge_only, obtain_cards)
--参数解释：judge_only为是否仅判断下家判定牌，不考虑下家摸的牌及洛神潜袭等情况（适用于灭计活墨这种重点是后续效果而非放牌的）
--obtain_cards为可以立刻通过技能获得的牌（目前只有涯角成功时为这张涯角牌，其余都为空）（以后会有心战等技能）
--返回两个table，第一个为置于牌堆顶的牌，第二个为立刻获得的牌（如果obtain_cards不为空），其余未返回的牌默认按置入弃牌堆处理
	
end

--出牌阶段使用牌剩余的次数上限（雅望、狂才）【todo：用于在activate判断，按照一个Table采取梯级顺序使用牌，防止使用一堆无关紧要的牌】
function SmartAI:getUseCardLimit(from, isSkillCard)
	--雅望
	
	if from:hasFlag("KuangcaiInvoked") then
		local time_limit = from:getMark("KuangcaiTimeLimit") * 1000
		local AI_time = sgs.GetConfig("AIDelay", 0) + 5  --考虑到延迟（实际很多时候狂才1秒根本没法出牌）
		return math.ceil((time_limit - AI_time) / 1000)
	end
	
	return 999
end

--判断是否需要防止使用低价值锦囊，防止在锦囊作用低时使用（如手牌溢出时的过拆）（滔乱、无谋）
function SmartAI:preventLowValueTrick(card, player)
	if not card then self.room:writeToConsole(debug.traceback()) return end
	player = player or self.player
	
	if card:getSkillName() and (card:getSkillName() == "Taoluan" or card:getSkillName() == "TaoluanOL") then
		return true
	end
	if player:hasShownSkill("Wumou") and not self:needToLoseHp(self.player) then
		return true
	end
	
	return false
end

--------------------------------------------重写原AI函数--------------------------------------------

--smart							（todo：移植getBestHp）
function setInitialTables()
	sgs.ai_type_name =          {"Skill", "Basic", "Trick", "Equip"}
	sgs.lose_equip_skill = "xiaoji"
	sgs.lose_one_equip_skill = ""
	sgs.need_kongcheng = "kongcheng|Lianying"
	sgs.masochism_skill =       "yiji|fankui|jieming|ganglie|fangzhu|hengjiang|qianhuan|FankuiLB|GanglieLB_XiaHouDun_LB|YijiLB|Guixin|Chengxiang|Tuifeng"
	sgs.wizard_skill =      "guicai|guidao|tiandu|GuicaiLB|tiandu_GuoJia_LB|Luoying"
	sgs.wizard_harm_skill =     "guicai|guidao|GuicaiLB"
	sgs.priority_skill =        "dimeng|haoshi|qingnang|jizhi|guzheng|qixi|jieyin|guose|duanliang|fanjian|lijian|tuxi|qiaobian|zhiheng|luoshen|rende|wansha|qingcheng|shuangren|TuxiLB|RendeLB|qixi_GanNing_LB|Gongxin_LyuMeng_LB|Gongxin_ShenLyuMeng|KurouLB+Zhaxiang|GuoseLB|Mingce|Xiansi|Junxing|Zhengnan|Taoluan|TaoluanOL"  --同时改ActivePSkill
	sgs.save_skill =        "jijiu|jijiu_HuaTuo_LB|Longhun|Renxin"
	sgs.exclusive_skill =       "duanchang|buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15|Wuhun"
	sgs.Active_cardneed_skill =     "paoxiao|tianyi|shuangxiong|jizhi|guose|duanliang|qixi|qingnang|luoyi|" ..
								"jieyin|zhiheng|rende|luanji|qiaobian|lirang|LuoyiLB|RendeLB|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao|qixi_GanNing_LB|GuoseLB|Mingce|Jingce|Qiaoshui|Junxing|Danshou|Ziyuan|TaoluanOL"
	sgs.notActive_cardneed_skill =      "kanpo|guicai|guidao|beige|xiaoguo|liuli|tianxiang|jijiu|Fenji15|GuicaiLB|liuli_DaQiao_LB|jijiu_HuaTuo_LB|Zhuhai|Zhuikong|Longyin"
	sgs.cardneed_skill =  sgs.Active_cardneed_skill .. "|" .. sgs.notActive_cardneed_skill
	sgs.drawpeach_skill =       "tuxi|qiaobian|TuxiLB|Gongxin_LyuMeng_LB|Gongxin_ShenLyuMeng"
	--sgs.recover_skill =     "rende|kuanggu|zaiqi|jieyin|qingnang|yinghun|hunzi|shenzhi|buqu"
	sgs.recover_skill =     "rende|kuanggu|zaiqi|jieyin|qingnang|yinghun_sunjian|yinghun_sunce|shenzhi|buqu|RendeLB|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15|Longhun"
	sgs.use_lion_skill =         "duanliang|qixi|guidao|lijian|zhiheng|fenxun|qingcheng|Fenji15|GuicaiLB|qixi_GanNing_LB|KurouLB|Chuli|Longhun|Mingce|Renxin|Longyin|Duodao|Danshou|QianxiRE|Tuifeng|Dingpan"
	sgs.need_equip_skill =      "shensu|beige|huyuan|qingcheng|Longhun|Mingce|Renxin|Zhiyan"
	sgs.judge_reason =      "bazhen|EightDiagram|supply_shortage|tuntian|qianxi|indulgence|lightning|leiji|tieqi|luoshen|ganglie|GanglieLB_XiaHouDun_LB|TieqiLB|Wuhun"
	
	--以下为手动添加
	sgs.straight_damage_skill = "fanjian|qiangxi|Danshou|Wurong"
	sgs.double_slash_skill = "paoxiao|tianyi|shuangxiong|luanji|shuangren|paoxiao_ZhangFei_LB|KurouLB+Zhaxiang|Dangxian_LiaoHua|Dangxian_GuanSuo"  --源码仅用于矢北（可以投放至智迟亮将）
	sgs.need_maxhp_skill = "zaiqi|yinghun_sunjian|yinghun_sunce|Juejing"
	sgs.bad_skills = "benghuai|Liyu|Yaowu|Tongji|Wumou|Shizhi|Ranshang"
	sgs.pindian_skill = "tianyi|quhu|shuangren|lieren|Yijue|Zhuikong"  --自创（取自连横）
	sgs.save_others_skill = ""  --自创（取自ableToSave），注意仅包括在处于濒死时使用非桃的方式救人的（因为ableToSave仅在濒死求桃调用），与save_skill的不同在于急救龙魂类、补益类不算
	sgs.defense_skill = "jianxiong|qingguo|tuntian|kongcheng|longdan|bazhen|xiangle|liuli|tianxiang|leiji|weimu|beige|mingshi|shoucheng|yicheng|qianhuan|JianxiongLB|longdan_ZhaoYun_LB|Yajiao|Fenwei|liuli_DaQiao_LB|Lianying|Wuhun|Jiushi|Zhichi|Qiuyuan|Yuce|Taoluan|TaoluanOL"   --自创，用于回合外防御（取自原项目义绝铁骑）
	sgs.niepan_skill = "niepan|jizhao"  --自创（引申自原项目义绝铁骑）、注意类似替身的延时涅槃不算
	sgs.turnfinish_others_skill = "xiaoguo|guzheng|qiluan|Zhuhai|Qieting"  --自创，在其他角色弃牌/回合结束发动的技能（用于非锁无效）
	sgs.force_damage_skill = "tieqi|liegong|TieqiLB"  --自创，靠杀的真强命，不是伪强命（如无双猛进）
	sgs.fake_force_damage_skill = "wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu|mengjin|qianxi|QianxiRE|PojunRE"  --伪强命（包括并非不能闪避的、由目标决定的、不稳定的）
	sgs.viewhas_armor_skill = "bazhen|jgyizhong"  --自创，视为装备防具技能（若你未装备防具，XXXXX）
	sgs.general_shown_skill = "Qixing|Jugu"  --明置武将牌时发动的技能（用于化身）
	sgs.Active_priority_skill =        "dimeng|haoshi|qingnang|jizhi|qixi|jieyin|guose|duanliang|fanjian|lijian|tuxi|qiaobian|zhiheng|luoshen|rende|wansha|qingcheng|shuangren|TuxiLB|RendeLB|qixi_GanNing_LB|Gongxin_LyuMeng_LB|Gongxin_ShenLyuMeng|KurouLB+Zhaxiang|GuoseLB|Mingce|Xiansi|Junxing|Taoluan|TaoluanOL"  --自创，用于考虑翻面
	
	--以下关于需要特定牌的技能主要用于荐言，计划应用至getCardNeedPlayer、AG等函数
	sgs.need_trick_skill = "jizhi|Qiaoshui|Mieji"  --自创，需要锦囊牌的技能		【todo：参考getCardNeedPlayer调整下面这三个的值】
	sgs.need_weapon_skill = "qiangxi|liegong|Anjian"  --自创，需要武器牌的技能（类似蒺藜）
	sgs.need_as_many_slash_skill = "paoxiao|tianyi|KurouLB+Zhaxiang|Tuifeng"  --自创，需要越多越好的杀的技能
	sgs.need_slash_skill = sgs.need_as_many_slash_skill .. "|luoyi|tieqi|liegong|lieren|fenxun|wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu|mengjin|chuanxin|LuoyiLB|TieqiLB|Zhuhai|Anjian|Wurong|PojunRE|Shichou"  --自创，需要杀的技能（菜刀）（这里的不会判断是否已经有杀）
	sgs.need_red_cards_skill = "wusheng|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo|duoshi|jijiu|jijiu_HuaTuo_LB"
	sgs.need_black_cards_skill = "qingguo|duanliang|kanpo|qixi|qixi_GanNing_LB|guidao"
	
	sgs.need_less_cards_skill = "hengzheng|Tongji|TuxiLB|Lianying"  --自创，需要尽量减少手牌数的技能（计划投放至仁德、节命等补牌技能防止补牌，以及尽可能多出牌）
	sgs.prevent_kongcheng_skill = "qiaobian|shenzhi|tianxiang|Yuce"  --自创，需要保证有手牌/避免空城的技能
	sgs.prevent_nude_skill = "liuli|liuli_DaQiao_LB|Fenji15|Tuifeng"  --自创，需要保证有牌的技能

	sgs.Friend_All = 0
	sgs.Friend_Draw = 1
	sgs.Friend_Male = 2
	sgs.Friend_Female = 3
	sgs.Friend_Wounded = 4
	sgs.Friend_MaleWounded = 5
	sgs.Friend_FemaleWounded = 6

	for _, p in sgs.qlist(global_room:getAlivePlayers()) do
		if p:getState() == "robot" then table.insert(sgs.robot, p) end
		local kingdom = p:getKingdom()
		if not table.contains(sgs.KingdomsTable, kingdom) then
			table.insert(sgs.KingdomsTable, kingdom)
		end
		sgs.ai_loyalty[kingdom] = {}
		sgs.shown_kingdom[p:getKingdom()] = 0
		sgs.ai_explicit[p:objectName()] = "unknown"
		sgs.general_shown[p:objectName()] = {}
		if string.len(p:getRole()) == 0 then
			global_room:setPlayerProperty(p, "role", sgs.QVariant(p:getKingdom()))
		end
		if not table.contains(sgs.RolesTable, p:getRole()) then
			table.insert(sgs.RolesTable, kingdom)
		end
	end

	for _, p in sgs.qlist(global_room:getAlivePlayers()) do
		local kingdom = p:getKingdom()
		for kingdom, v in pairs(sgs.ai_loyalty) do
			sgs.ai_loyalty[kingdom][p:objectName()] = 0
		end
	end

end
function SmartAI:useEquipCard(card, use)									--峻刑、急救、奇袭、国色、直言、仁德、咆哮、龙魂
	if not card then global_room:writeToConsole(debug.traceback()) return end
	if self.player:hasSkill("xiaoji") and self:evaluateArmor(card) > -5 then
		local armor = self.player:getArmor()
		if armor and armor:objectName() == "PeaceSpell" and card:isKindOf("Armor") then
			if (self:getAllPeachNum() == 0 and self.player:getHp() < 3) and not (self.player:getHp() < 2 and self:getCardsNum("Analeptic") > 0) then
				return
			end
		end
		if self.player:getWeapon() and self.player:getWeapon():objectName() == "Crossbow" and self:getCardsNum("Slash") > 2 then
			local d_use = {isDummy = true,to = sgs.SPlayerList()}
			local slash = sgs.Sanguosha:cloneCard("slash")
			slash:deleteLater()
			self:useCardSlash(slash,d_use)
			if d_use.card then
				return
			end
		end
		use.card = card
		return
	end
	if self.player:hasSkills(sgs.lose_equip_skill) and self:evaluateArmor(card) > -5 and #self.enemies > 1 then
		local armor = self.player:getArmor()
		if armor and armor:objectName() == "PeaceSpell" and card:isKindOf("Armor") then
			if (self:getAllPeachNum() == 0 and self.player:getHp() < 3) and not (self.player:getHp() < 2 and self:getCardsNum("Analeptic") > 0) then
				return
			end
		end
		use.card = card
		return
	end
	if self.player:getHandcardNum() == 1 and self:needKongcheng() and self:evaluateArmor(card) > -5 then
		local armor = self.player:getArmor()
		if armor and armor:objectName() == "PeaceSpell" and card:isKindOf("Armor") then
			if (self:getAllPeachNum() == 0 and self.player:getHp() < 3) and not (self.player:getHp() < 2 and self:getCardsNum("Analeptic") > 0) then
				return
			end
		end
		use.card = card
		return
	end
	if card:isKindOf("Armor") and card:objectName() == "PeaceSpell" then
		local lord_zhangjiao = sgs.findPlayerByShownSkillName("wendao") --有君张角在其他人（受伤/有防具）则不装备太平要术
		if lord_zhangjiao and lord_zhangjiao:isAlive() and not self:isWeak(lord_zhangjiao) then
			if self.player:objectName() ~= lord_zhangjiao:objectName() and (self.player:isWounded() or self.player:getArmor()) then
				return
			end
		end
	end
	if card:isKindOf("Weapon") and card:objectName() == "DragonPhoenix" then
		local lord_liubei = sgs.findPlayerByShownSkillName("zhangwu") --有君刘备在（其他势力/除他以外有武器）的人不装备龙凤剑
		if lord_liubei and lord_liubei:isAlive() then
			if not self.player:isFriendWith(lord_liubei) or (self.player:objectName() ~= lord_liubei:objectName() and self.player:getWeapon()) then
				return
			end
		end
	end
	local same = self:getSameEquip(card)
	local zzzh, isfriend_zzzh, isenemy_zzzh = sgs.findPlayerByShownSkillName("guzheng")
	if zzzh then
		if self:isFriend(zzzh) then isfriend_zzzh = true
		else isenemy_zzzh = true
		end
	end
	if same then
		if (self.player:hasSkills("rende|RendeLB") and self:findFriendsByType(sgs.Friend_Draw))
			or (self.player:hasSkills("qixi|duanliang|qixi_GanNing_LB") and (card:isBlack() or same:isBlack()))
			or (self.player:hasSkills("guose|Longhun") and (card:getSuit() == sgs.Card_Diamond or same:getSuit() == sgs.Card_Diamond))
			or (self.player:hasSkills("GuoseLB") and (card:getSuit() == sgs.Card_Diamond or same:getSuit() == sgs.Card_Diamond) and not self.player:hasUsed("#GuoseLBCard"))
			or (self.player:hasSkills("jijiu|jijiu_HuaTuo_LB") and (card:isRed() or same:isRed()))
			or (self.player:hasSkill("guidao") and same:isBlack() and card:isRed())
            or (self.player:hasSkill("Junxing") and not self.player:hasUsed("#JunxingCard"))
            or (self.player:hasSkill("Zhiyan") and self.player:getPhase() <= sgs.Player_Discard and self:getOverflow() > 0)
			or isfriend_zzzh
			then return end
	end
	local canUseSlash = self:getCardId("Slash") and self:slashIsAvailable(self.player)
	self:useCardByClassName(card, use)
	if use.card then return end
	if card:isKindOf("Weapon") then
		if same and self.player:hasSkill("qiangxi") and not self.player:hasUsed("QiangxiCard") then
			local dummy_use = { isDummy = true }
			self:useSkillCard(sgs.Card_Parse("@QiangxiCard=" .. same:getEffectiveId().. "&qiangxi"), dummy_use)
			if dummy_use.card and dummy_use.card:getSubcards():length() == 1 then return end
		end
		if self.player:hasSkills("rende|RendeLB") then
			for _, friend in ipairs(self.friends_noself) do
				if not friend:getWeapon() then return end
			end
		end
		if self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") and card:isKindOf("Crossbow") then return end
		if not self:needKongcheng() and not self.player:hasSkills(sgs.lose_equip_skill) and self:getOverflow() <= 0 and not canUseSlash then return end
		--if (not use.to) and self.player:getWeapon() and not self.player:hasSkills(sgs.lose_equip_skill) then return end
		if self.player:hasSkill("zhiheng") and not self.player:hasUsed("ZhihengCard") and self.player:getWeapon() and not card:isKindOf("Crossbow") then return end
		if not self:needKongcheng() and self.player:getHandcardNum() <= self.player:getHp() - 2 then return end
		if not self.player:getWeapon() or self:evaluateWeapon(card) > self:evaluateWeapon(self.player:getWeapon()) then
			use.card = card
		end
	elseif card:isKindOf("Armor") then
		local lion = self:getCard("SilverLion")
		if lion and self.player:isWounded() and not self.player:hasArmorEffect("SilverLion") and not card:isKindOf("SilverLion")
			and not (self.player:hasSkills("bazhen|jgyizhong") and not self.player:getArmor()) then
			use.card = lion
			return
		end
		if self.player:hasSkills("rende|RendeLB") and self:evaluateArmor(card) < 4 then
			for _, friend in ipairs(self.friends_noself) do
				if not friend:getArmor() then return end
			end
		end
		if self:evaluateArmor(card) > self:evaluateArmor() or isenemy_zzzh and self:getOverflow() > 0 then use.card = card end
		return
	elseif card:isKindOf("OffensiveHorse") then
		if self.player:hasSkills("rende|RendeLB") then
			for _,friend in ipairs(self.friends_noself) do
				if not friend:getOffensiveHorse() then return end
			end
			use.card = card
			return
		else
			if not self.player:hasSkills(sgs.lose_equip_skill) and self:getOverflow() <= 0 and not (canUseSlash or self:getCardId("Snatch")) then
				return
			else
				if self.lua_ai:useCard(card) then
					use.card = card
					return
				end
			end
		end
	elseif card:isKindOf("DefensiveHorse") then
		local tiaoxin = true
		if self.player:hasSkill("tiaoxin") then
			local dummy_use = { isDummy = true, defHorse = true }
			self:useSkillCard(sgs.Card_Parse("@TiaoxinCard=.&tiaoxin"), dummy_use)
			if not dummy_use.card then tiaoxin = false end
		end
		if tiaoxin and self.lua_ai:useCard(card) then
			use.card = card
		end
	elseif card:isKindOf("Treasure") then
		if not card:isKindOf("WoodenOx") and not self.player:getTreasure()then
			for _, friend in ipairs(self.friends) do
				if (friend:getTreasure() and friend:getPile("wooden_ox"):length() > 1) then
					return
				end
			end
		end
		if not self.player:getTreasure() or card:isKindOf("JadeSeal") then
			use.card = card
		end
	elseif self.lua_ai:useCard(card) then
		use.card = card
	end
end
function sgs.getDefense(player)												--武圣、咆哮、铁骑、父魂、称象、御策、急救、非锁无效、克己、突袭、刚烈、仁德、
																			--龙胆、奸雄、鬼才、遗计、天妒、不屈、归心、燃殇
	if not player then return 0 end
	local hp = player:getHp()
	if player:hasShownSkill("benghuai") and player:getHp() > 4 then hp = 4 end
	if player:hasShownSkill("Ranshang") then hp = math.max(0, hp - player:getMark("@ranshang") * 2) end
	local defense = math.min(hp * 2 + player:getHandcardNum(), hp * 3)
	local hasEightDiagram = false
	if player:hasArmorEffect("EightDiagram") or player:hasArmorEffect("bazhen") then
		hasEightDiagram = true
	end

	if player:getArmor() and player:hasArmorEffect(player:getArmor():objectName()) then defense = defense + 2 end
	if player:getDefensiveHorse() then defense = defense + 0.5 end

	if player:hasTreasure("JadeSeal") then defense = defense + 2 end
	defense = defense + player:getHandPile():length()
	if hasEightDiagram then
		if player:hasShownSkills("tiandu|tiandu_GuoJia_LB") then defense = defense + 1 end
		if player:hasShownSkill("leiji") then defense = defense + 1 end
		if player:hasShownSkill("hongyan") then defense = defense + 1 end
	end

	local m = sgs.masochism_skill:split("|")
	for _, masochism in ipairs(m) do
		if player:hasShownSkill(masochism) then
			local goodHp = player:getHp() > 1 or getCardsNum("Peach", player) >= 1 or getCardsNum("Analeptic", player) >= 1
							or hasBuquEffect(player) or hasNiepanEffect(player)
			if goodHp then defense = defense + 1 end
		end
	end

	if player:hasShownSkill("jieming") then defense = defense + 3 end
	if player:hasShownSkill("yiji") then defense = defense + 2 end
	if player:hasShownSkill("YijiLB") then defense = defense + 2 end
    if player:hasShownSkill("Guixin") then defense = defense + player:aliveCount() - 1 end
	if player:hasShownSkill("Yuce") then defense = defense + 2 end
	if player:hasShownSkill("Chengxiang") then defense = defense + 2 end
	if player:hasShownSkill("JianxiongLB") then defense = defense + 1 end
	if player:hasShownSkill("tuxi") then defense = defense + 0.5 end
	if player:hasShownSkill("TuxiLB") then defense = defense + 0.4 end
	if player:hasShownSkill("luoshen") then defense = defense + 1 end

	if player:hasShownSkills("rende|RendeLB") and player:getHp() > 2 then defense = defense + 1 end
	if player:hasShownSkill("zaiqi") and player:getHp() > 1 then defense = defense + player:getLostHp() * 0.5 end
	if player:hasShownSkills("tieqi|liegong|kuanggu|TieqiLB") then defense = defense + 0.5 end
	if player:hasShownSkill("xiangle") then defense = defense + 1 end
	if player:hasShownSkill("shushen") then defense = defense + 1 end
	if player:hasShownSkill("kongcheng") and player:isKongcheng() then defense = defense + 2 end
	if player:hasShownSkill("shouyue") then
		for _, p in sgs.qlist(global_room:getAlivePlayers()) do
			if p:getKingdom() == "shu" then
				if p:hasShownSkills("wusheng|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo") then defense = defense + 1 end
				if p:hasShownSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then defense = defense + 1 end
				if p:hasShownSkills("longdan|longdan_ZhaoYun_LB") then defense = defense + 1 end
				if p:hasShownSkill("liegong") then defense = defense + 1 end
				if p:hasShownSkills("tieqi|TieqiLB") then defense = defense + 1 end
				if p:hasShownSkill("Fuhun") then defense = defense + 0.5 end
			end
		end
	end

	if player:hasShownSkills("yinghun_sunjian|yinghun_sunce") and player:getLostHp() > 0 then defense = defense + player:getLostHp() - 0.5 end
	if player:hasShownSkill("tianxiang") then defense = defense + player:getHandcardNum() * 0.5 end
	if player:hasShownSkill("buqu") then defense = defense + math.max(4 - player:getPile("buqu"):length(), 0) end
	if player:hasShownSkill("BuquRenew_ZhouTai_13") then defense = defense + math.max(4 - player:getPile("chuang_ZhouTai_13"):length(), 0) end
	if player:hasShownSkill("BuquRenew_ZhouTai_15") then defense = defense + math.max(4 - player:getPile("chuang_ZhouTai_15"):length(), 0) end
	if player:hasShownSkill("guzheng") then defense = defense + 1 end
	if player:hasShownSkill("dimeng") then defense = defense + 2 end
	if player:hasShownSkills("keji|keji_LyuMeng_LB") then defense = defense + player:getHandcardNum() * 0.5 end
	if player:hasShownSkill("jieyin") and player:getHandcardNum() > 1 then defense = defense + 2 end

	if player:hasShownSkill("qianhuan") then defense = defense + (player:getPile("sorcery"):length() + 1) * 2 end
	if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") then defense = defense + 2 end
	if player:hasShownSkill("lijian") then defense = defense + 0.5 end
	if player:hasLordSkill("hongfa") then
		for _, p in sgs.qlist(global_room:getAlivePlayers()) do
			if sgs.ai_explicit[p:objectName()] == "qun" then defense = defense + 1 end
		end
	end

    if player:getMark("@skill_invalidity") > 0 then defense = defense - 3 * player:getMark("@skill_invalidity") end
	
	if not player:faceUp() then defense = defense - 0.5 end
	if player:containsTrick("indulgence") then defense = defense - 0.5 end
	if player:containsTrick("supply_shortage") then defense = defense - 0.5 end

	--似乎此函数写的时候没加屯田相关，于是补上了
	if player:hasShownSkills("qingguo+yiji|duoshi+xiaoji|jijiu+qianhuan|yiji+ganglie|yiji+GanglieLB_XiaHouDun_LB|qingguo+YijiLB|YijiLB+ganglie|YijiLB+GanglieLB_XiaHouDun_LB|tiandu+tuntian|tiandu_GuoJia_LB+tuntian|YijiLB+tuntian|luoshen+GuicaiLB|qingguo+Chengxiang|yiji+Yuce|YijiLB+Yuce|Chengxiang+Yuce") then defense = defense + 2 end
	if player:hasShownSkills("yiji+qiaobian|xiaoji+zhiheng|buqu+yinghun_sunjian|luoshen+guicai|BuquRenew_ZhouTai_13+yinghun_sunjian|BuquRenew_ZhouTai_15+yinghun_sunjian|YijiLB+qiaobian|RendeLB+kongcheng|jijiu_HuaTuo_LB+qianhuan|Chengxiang+qiaobian") then defense = defense + 1.5 end

	if global_room:getCurrent() then
		defense = defense + (player:aliveCount() - (player:getSeat() - global_room:getCurrent():getSeat()) % player:aliveCount()) / 4
	end

	return defense
end
function SmartAI:damageIsEffective_(damageStruct)							--制蛮、大雾、仁心、RE破军
	if type(damageStruct) ~= "table" and type(damageStruct) ~= "DamageStruct" and type(damageStruct) ~= "userdata" then self.room:writeToConsole(debug.traceback()) return end
	if not damageStruct.to then self.room:writeToConsole(debug.traceback()) return end
	local to = damageStruct.to
	local nature = damageStruct.nature or sgs.DamageStruct_Normal
	local damage = damageStruct.damage or 1
	local from = damageStruct.from

	if type(to) == "table" then self.room:writeToConsole(debug.traceback()) return end

	if to:hasShownSkill("mingshi") and from and not from:hasShownAllGenerals() then
		damage = damage - 1
		if damage < 1 then return false end
	end
	
	local isSlash = damageStruct.card and damageStruct.card:isKindOf("Slash")
	local ignoreArmor = isSlash and from and (IgnoreArmor(from, to) or (from:hasShownSkill("PojunRE") and from:getPhase() == sgs.Player_Play and to:getHp() > 0))

	if to:hasArmorEffect("PeaceSpell") and not ignoreArmor and not (from and ((from:hasWeapon("IceSword") and isSlash) or from:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo"))) and nature ~= sgs.DamageStruct_Normal then return false end  --寒冰剑是从新版本AI抄来的；源码忘记判断是否存在from
	if to:hasShownSkills("jgyuhuo_pangtong|jgyuhuo_zhuque") and nature == sgs.DamageStruct_Fire then return false end
	if ((to:getMark("@fog") > 0) or (to:getMark("@fog_ShenZhuGeLiang") > 0)) and nature ~= sgs.DamageStruct_Thunder then return false end
	if to:getHp() == 1 and self:hasRenxinEffect_(damageStruct, false, true) then return false end
	if to:hasArmorEffect("Breastplate") and not ignoreArmor and (damage > to:getHp() or (to:getHp() > 1 and damage == to:getHp())) then return false end  --源码忘记ignoreArmor

	for _, callback in pairs(sgs.ai_damage_effect) do
		if type(callback) == "function" then
			local is_effective = callback(self, damageStruct)
			if not is_effective then return false end
		end
	end

	return true
end
function SmartAI:cardNeed(card)												--武圣、苦肉、克己、征南、裸衣、暗箭（贯石斧）、不屈、武神、酒诗、龙魂
	if not self.friends then self.room:writeToConsole(debug.traceback()) self.room:writeToConsole(sgs.turncount) return end
	local class_name = card:getClassName()
	local suit_string = card:getSuitString()
	local value
	if card:isKindOf("Peach") then
		self:sort(self.friends,"hp")
		if self.friends[1]:getHp() < 2 then return 10 end
		if (self.player:getHp() < 3 or self.player:getLostHp() > 1 and not self.player:hasSkills("buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15|Longhun")) or self.player:hasSkills("kurou|benghuai|KurouLB+Zhaxiang") then return 14 end
		return self:getUseValue(card)
	end
	if self:isWeak() and card:isKindOf("Jink") and self:getCardsNum("Jink") < 1 then return 12 end

	local i = 0
	for _, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		if sgs[askill:objectName() .. "_keep_value"] then
			local v = sgs[askill:objectName() .. "_keep_value"][class_name]
			if v then
				i = i + 1
				if value then value = value + v else value = v end
			end
		end
	end
	if value then return value / i + 4 end
	i = 0
	for _, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		if sgs[askill:objectName() .. "_suit_value"] then
			local v = sgs[askill:objectName() .. "_suit_value"][suit_string]
			if v then
				i = i + 1
				if value then value = value + v else value = v end
			end
		end
	end
	if value then return value / i + 4 end

	if card:isKindOf("Slash") then
		if self:getCardsNum("Slash") == 0 then return 5.9
		else return 4 end
	end
	if card:isKindOf("Analeptic") then
		if self.player:getHp() < 2 then return 10 end
	end
	if card:isKindOf("Crossbow") and self.player:hasSkills("luoshen|kurou|keji|wusheng|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo|keji_LyuMeng_LB|Wushen|Zhengnan") then return 20 end
	if card:isKindOf("Axe") and self.player:hasSkills("luoyi|LuoyiLB|Jiushi|Anjian") then return 15 end
	if card:isKindOf("Weapon") and (not self.player:getWeapon()) and (self:getCardsNum("Slash") > 1) then return 6 end
	if card:isKindOf("Nullification") and self:getCardsNum("Nullification") == 0 then
		if self:willSkipPlayPhase() or self:willSkipDrawPhase() then return 10 end
		for _, friend in ipairs(self.friends) do
			if self:willSkipPlayPhase(friend) or self:willSkipDrawPhase(friend) then return 9 end
		end
		return 6
	end
	if card:getTypeId() == sgs.Card_TypeTrick then
		return card:isAvailable(self.player) and self:getUseValue(card) or 0
	end
	return self:getUseValue(card)
end
function SmartAI:getCardNeedPlayer(cards, friends_table, skillname)			--武圣、咆哮、急救、克己、征南、仁德、龙胆、资援、清俭、遗计、自创技能分类
	local rende_dummycount = 0
	if skillname == "RendeLB" then
		rende_dummycount = self.RendeLB_DummyCount or 0
	elseif skillname == "Ziyuan" then
		rende_dummycount = math.max(#cards - 1, 0)
	elseif self.Qingjian_using then
		rende_dummycount = self.Qingjian_DummyCount or 0
	elseif self.YijiLB_using then
		rende_dummycount = self.YijiLB_DummyCount or 0
	end
	
	local allocated_dummy = {}
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		allocated_dummy[p:objectName()] = 0
		if skillname == "RendeLB" and self.RendeLB_Allocation and self.RendeLB_Allocation[p:objectName()] then
			allocated_dummy[p:objectName()] = allocated_dummy[p:objectName()] + #self.RendeLB_Allocation[p:objectName()]
		elseif skillname == "Qingjian" and self.Qingjian_Allocation and self.Qingjian_Allocation[p:objectName()] then
			allocated_dummy[p:objectName()] = allocated_dummy[p:objectName()] + self.Qingjian_Allocation[p:objectName()]
		elseif self.YijiLB_using and self.YijiLB_Allocation and self.YijiLB_Allocation[p:objectName()] then
			allocated_dummy[p:objectName()] = allocated_dummy[p:objectName()] + #self.YijiLB_Allocation[p:objectName()]
		end
	end
	
	cards = cards or sgs.QList2Table(self.player:getHandcards())

	local cardtogivespecial = {}
	local keptslash = 0
	local friends = {}
	local cmpByAction = function(a,b)
		if self.YijiLB_using then  --防止给当前回合角色
			local current = a:getRoom():getCurrent()
			if current and current:getPhase() >= sgs.Player_Draw then
				if current:objectName() == b:objectName() then return false end
				if current:objectName() == a:objectName() then return true end
			end
		end
		return a:getRoom():getFront(a, b):objectName() == a:objectName()
	end

	local cmpByNumber = function(a,b)
		return a:getNumber() > b:getNumber()
	end
	
	local cmpByRealHandcard = function(a, b)
		local c1 = a:getHandcardNum() + allocated_dummy[a:objectName()]
		local c2 = b:getHandcardNum() + allocated_dummy[b:objectName()]
		if c1 == c2 then
			return sgs.getDefenseSlash(a, self) < sgs.getDefenseSlash(b, self)
		else
			return c1 < c2
		end
	end

	local AssistTarget = self:AssistTarget()
	if AssistTarget and (self:needKongcheng(AssistTarget, true) or self:willSkipPlayPhase(AssistTarget) or AssistTarget:getHandcardNum() > 10) then
		AssistTarget = nil
	end

	local found
	local xunyu, huatuo
	local friends_table = friends_table or self.friends_noself
	for i = 1, #friends_table do
		local player = friends_table[i]
		local exclude = self:needKongcheng(player) or self:willSkipPlayPhase(player)
		if player:hasShownSkills("keji|qiaobian|shensu|keji_LyuMeng_LB") or player:getHp() - player:getHandcardNum() - allocated_dummy[player:objectName()] >= 3
			or (player:isLord() and self:isWeak(player) and self:getEnemyNumBySeat(self.player, player) >= 1) then
			exclude = false
		end
		if self:objectiveLevel(player) <= -2 and not exclude then
			if AssistTarget and AssistTarget:objectName() == player:objectName() then AssistTarget = player end
			if player:hasShownSkill("jieming") then xunyu = player end
			if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") then huatuo = player end
			table.insert(friends, player)
		end
	end
	if not found then AssistTarget = nil end

	if xunyu and huatuo and #cardtogivespecial == 0 and self.player:hasSkills("rende|RendeLB") and self.player:getPhase() == sgs.Player_Play then
		local no_distance = self.slash_distance_limit
		local redcardnum = 0
		for _, acard in ipairs(cards) do
			if isCard("Slash", acard, self.player) then
				if self.player:canSlash(xunyu, nil, not no_distance) and self:slashIsEffective(acard, xunyu) then
					keptslash = keptslash + 1
				end
				if keptslash > 0 then
					table.insert(cardtogivespecial, acard)
				end
			elseif isCard("Duel", acard, self.player) then
				table.insert(cardtogivespecial, acard)
			end
		end
		for _, hcard in ipairs(cardtogivespecial) do
			if hcard:isRed() then redcardnum = redcardnum + 1 end
		end
		if self.player:getHandcardNum() - rende_dummycount > #cardtogivespecial and redcardnum > 0 then
			for _, hcard in ipairs(cardtogivespecial) do
				if hcard:isRed() then return hcard, huatuo end
				return hcard, xunyu
			end
		end
	end

	local cardtogive = {}
	local keptjink = 0
	for _, acard in ipairs(cards) do
		if isCard("Jink", acard, self.player) and keptjink < 1 and not self.player:hasSkill("kongcheng") then
			keptjink = keptjink + 1
		else
			table.insert(cardtogive, acard)
		end
	end

	self:sort(friends, "defense")
	for _, friend in ipairs(friends) do
		if self:isWeak(friend) and friend:getHandcardNum() + allocated_dummy[friend:objectName()] < 3 then
			for _, hcard in ipairs(cards) do
				if isCard("Peach", hcard, friend) or (isCard("Jink", hcard, friend) and self:getEnemyNumBySeat(self.player,friend) > 0) or isCard("Analeptic", hcard, friend) then
					return hcard, friend
				end
			end
		end
	end

	if (skillname == "rende" and self.player:hasSkill("rende") and self.player:isWounded() and self.player:getMark("rende") < 3) and not self.player:hasSkill("kongcheng") then
		if (self.player:getHandcardNum() < 3 and self.player:getMark("rende") == 0 and self:getOverflow() <= 0) then return end
	end
	if (skillname == "RendeLB" and self.player:hasSkill("RendeLB") and self.player:isWounded() and self.player:getMark("RendeLB") + rende_dummycount < 2) and not self.player:hasSkill("kongcheng") then
		if (self.player:getHandcardNum() - rende_dummycount < 2 and self.player:getMark("RendeLB") + rende_dummycount == 0 and self:getOverflow() - rende_dummycount <= 0) then return end
	end

	for _, friend in ipairs(friends) do
		if friend:getHp() <= 2 and friend:faceUp() then
			for _, hcard in ipairs(cards) do
				if (hcard:isKindOf("Armor") and not friend:getArmor() and not friend:hasShownSkills(sgs.viewhas_armor_skill))
					or (hcard:isKindOf("DefensiveHorse") and not friend:getDefensiveHorse()) then
					return hcard, friend
				end
			end
		end
	end

	self:sortByUseValue(cards, true)
	for _, friend in ipairs(friends) do
		if friend:hasShownSkills("jijiu|jieyin|jijiu_HuaTuo_LB") and friend:getHandcardNum() + allocated_dummy[friend:objectName()] < 4 then
			for _, hcard in ipairs(cards) do
				if (hcard:isRed() and friend:hasShownSkills("jijiu|jijiu_HuaTuo_LB")) or friend:hasShownSkill("jieyin") then
					return hcard, friend
				end
			end
		end
	end

	for _, friend in ipairs(friends) do
		if friend:hasShownSkills("jizhi")  then
			for _, hcard in ipairs(cards) do
				if hcard:isKindOf("TrickCard") then
					return hcard, friend
				end
			end
		end
	end

	for _, friend in ipairs(friends) do
		if friend:hasShownSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then
			for _, hcard in ipairs(cards) do
				if hcard:isKindOf("Slash") then
					return hcard, friend
				end
			end
		end
	end

	--Crossbow
	for _, friend in ipairs(friends) do
		if friend:hasShownSkills("longdan|wusheng|keji|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo|longdan_ZhaoYun_LB|keji_LyuMeng_LB|Zhengnan") and not self:hasCrossbowEffect(friend) and friend:getHandcardNum() + allocated_dummy[friend:objectName()] >= 2 then
			for _, hcard in ipairs(cards) do
				if hcard:isKindOf("Crossbow") then
					return hcard, friend
				end
			end
		end
	end

	for _, friend in ipairs(friends) do
		if getKnownCard(friend, self.player, "Crossbow") > 0 then
			for _, p in ipairs(self.enemies) do
				if sgs.isGoodTarget(p, self.enemies, self) and friend:distanceTo(p) <= 1 then
					for _, hcard in ipairs(cards) do
						if isCard("Slash", hcard, friend) then
							return hcard, friend
						end
					end
				end
			end
		end
	end

	table.sort(friends, cmpByAction)

	for _, friend in ipairs(friends) do
		if friend:faceUp() then
			local can_slash = false
			for _, p in sgs.qlist(self.room:getOtherPlayers(friend)) do
				if self:isEnemy(p) and sgs.isGoodTarget(p, self.enemies, self) and friend:distanceTo(p) <= friend:getAttackRange() then
					can_slash = true
					break
				end
			end
			local flag = string.format("weapon_done_%s_%s",self.player:objectName(),friend:objectName())
			if not can_slash then
				for _, p in sgs.qlist(self.room:getOtherPlayers(friend)) do
					if self:isEnemy(p) and sgs.isGoodTarget(p, self.enemies, self) and friend:distanceTo(p) > friend:getAttackRange() then
						for _, hcard in ipairs(cardtogive) do
							if hcard:isKindOf("Weapon") and friend:distanceTo(p) <= friend:getAttackRange() + (sgs.weapon_range[hcard:getClassName()] or 0)
									and not friend:getWeapon() and not friend:hasFlag(flag) then
								self.room:setPlayerFlag(friend, flag)
								return hcard, friend
							end
							if hcard:isKindOf("OffensiveHorse") and friend:distanceTo(p) <= friend:getAttackRange() + 1
									and not friend:getOffensiveHorse() and not friend:hasFlag(flag) then
								self.room:setPlayerFlag(friend, flag)
								return hcard, friend
							end
						end
					end
				end
			end

		end
	end

	table.sort(cardtogive, cmpByNumber)

	for _, friend in ipairs(friends) do
		if not self:needKongcheng(friend, true) and friend:faceUp() then
			for _, hcard in ipairs(cardtogive) do
				for _, askill in sgs.qlist(friend:getVisibleSkillList(true)) do
					local callback = sgs.ai_cardneed[askill:objectName()]
					if type(callback) == "function" and callback(friend, hcard, self) then
						return hcard, friend
					end
				end
			end
		end
	end
	
	--加入对自创技能分类的处理
	for _, friend in ipairs(friends) do
		if not self:needKongcheng(friend, true) and friend:faceUp() then
			local flag = string.format("weapon_done_%s_%s",self.player:objectName(),friend:objectName())
			local hasEnemy = false
			for _, p in ipairs(self:getEnemies(friend)) do
				if friend:inMyAttackRange(p) then
					hasEnemy = true
					break
				end
			end
			
			for _, hcard in ipairs(cardtogive) do
				if --(isCard("TrickCard", hcard, friend) and friend:hasShownSkills(sgs.need_trick_skill))  --巧说灭计直接写在技能里
					(isCard("Weapon", hcard, friend) and friend:hasShownSkills(sgs.need_weapon_skill) and not friend:getWeapon() and not friend:hasFlag(flag))
					or (isCard("Slash", hcard, friend) and hasEnemy and (friend:hasShownSkills(sgs.need_as_many_slash_skill) or (friend:hasShownSkills(sgs.need_slash_skill) and getCardsNum("Slash", friend, self.player) < 1)))
					or (isCard("EquipCard", hcard, friend) and friend:hasShownSkills(sgs.need_equip_skill) and getKnownCard(friend, self.player, "EquipCard", true, "he") < 2) then
					return hcard, friend
				end
			end
		end
	end

	--if skillname ~= "WoodenOx" then
	if skillname ~= "WoodenOx" and not self.YijiLB_using and next(self.enemies) then
		self:sort(self.enemies, "defense")
		--if #self.enemies > 0 and self.enemies[1]:isKongcheng() and self.enemies[1]:hasShownSkill("kongcheng") then
		if #self.enemies > 0 and self.enemies[1]:getHandcardNum() + allocated_dummy[self.enemies[1]:objectName()] == 0 and self.enemies[1]:hasShownSkill("kongcheng") then
			for _, acard in ipairs(cardtogive) do
				if acard:isKindOf("Lightning") or acard:isKindOf("Collateral") or (acard:isKindOf("Slash") and self.player:getPhase() == sgs.Player_Play)
					or acard:isKindOf("OffensiveHorse") or acard:isKindOf("Weapon") or acard:isKindOf("AmazingGrace") then
					return acard, self.enemies[1]
				end
			end
		end
	end

	if AssistTarget then
		for _, hcard in ipairs(cardtogive) do
			return hcard, AssistTarget
		end
	end
	
	--新加入的一段（防止部分队友空城）
	if skillname ~= "WoodenOx" and not self.YijiLB_using then
		for _, hcard in ipairs(cardtogive) do
			for _, friend in ipairs(sgs.reverse(friends)) do
				if not self:needKongcheng(friend, true) and ((friend:hasShownSkills(sgs.prevent_kongcheng_skill) and friend:getHandcardNum() + allocated_dummy[friend:objectName()] == 0) or (friend:hasShownSkills(sgs.prevent_nude_skill) and friend:getCardCount(true) + allocated_dummy[friend:objectName()] == 0)) then
					if (self:getOverflow() - rende_dummycount >= 0 or self.player:getHandcardNum() - rende_dummycount >= 3) then
						return hcard, friend
					end
				end
			end
		end
	end

	self:sort(friends, "defense")
	for _, hcard in ipairs(cardtogive) do
		for _, friend in ipairs(friends) do
			if not self:needKongcheng(friend, true) and not self:willSkipPlayPhase(friend) and friend:hasShownSkills(sgs.priority_skill) then
				if (self:getOverflow() - rende_dummycount > 0 or self.player:getHandcardNum() - rende_dummycount > 3) and friend:getHandcardNum() + allocated_dummy[friend:objectName()] <= 3 then
					return hcard, friend
				end
			end
		end
	end

	local shoulduse = (skillname == "rende" and self.player:isWounded() and self.player:hasSkill("rende") and self.player:getMark("rende") < 3)
					or (skillname == "RendeLB" and self.player:isWounded() and self.player:hasSkill("RendeLB") and self.player:getMark("RendeLB") + rende_dummycount < 2)

	if #cardtogive == 0 and shoulduse then cardtogive = cards end

	self:sort(friends, "handcard")
	for _, hcard in ipairs(cardtogive) do
		for _, friend in ipairs(friends) do
			if not self:needKongcheng(friend, true) then
				if friend:getHandcardNum() + allocated_dummy[friend:objectName()] <= 3 and (self:getOverflow() - rende_dummycount > 0 or self.player:getHandcardNum() - rende_dummycount > 3 or shoulduse) and not friend:hasShownSkills(sgs.need_less_cards_skill) then
					return hcard, friend
				end
			end
		end
	end


	for _, hcard in ipairs(cardtogive) do
		for _, friend in ipairs(friends) do
			if not self:needKongcheng(friend, true) or #friends == 1 then
				if self:getOverflow() - rende_dummycount > 0 or self.player:getHandcardNum() - rende_dummycount > 3 or shoulduse then
					return hcard, friend
				end
			end
		end
	end

	for _, hcard in ipairs(cardtogive) do
		for _, friend in ipairs(friends_table) do
			if (not self:needKongcheng(friend, true) or #friends_table == 1) and (self:getOverflow() - rende_dummycount > 0 or self.player:getHandcardNum() - rende_dummycount > 3 or shoulduse) then
				return hcard, friend
			end
		end
	end

end
local function getPlayerSkillList(player)									--为cardsViewValue cardsView服务（因为local）
	local skills = sgs.QList2Table(player:getVisibleSkillList(true))
	return skills
end
local function cardsView(self, class_name, player, cards)					--为getCardsNum服务（因为local）
	local returnList = {}
	for _, skill in ipairs(getPlayerSkillList(player)) do
		local askill = skill:objectName()
		if player:hasSkill(askill) or player:hasLordSkill(askill) then
			local callback = sgs.ai_cardsview[askill]
			if type(callback) == "function" then
				local ret = callback(self, class_name, player, cards)
				if ret then
					if type(ret) == "table" then
						table.insertTable(returnList,ret)
					else
						table.insert(returnList,ret)
					end
				end
			end
		end
	end
	return returnList
end
local function cardsViewValue(self, class_name, player,reason)				-- 优先权最高的ViewCards。  --为getCardsNum服务（因为local）
	local returnList = {}
	for _, skill in ipairs(getPlayerSkillList(player)) do
		local askill = skill:objectName()
		if player:hasSkill(askill) or player:hasLordSkill(askill) then
			local callback = sgs.ai_cardsview_value[askill]
			if type(callback) == "function" then
				local ret = callback(self, class_name, player,reason)
				if ret then
					if type(ret) == "table" then
						table.insertTable(returnList,ret)
					else
						table.insert(returnList,ret)
					end
				end
			end
		end
	end
	return returnList
end
function getCardsNum(class_name, player, from)								--武圣、急救、龙胆、武神、酒诗、矢志、龙魂
	if not player then
		global_room:writeToConsole(debug.traceback())
		return 0
	end

	local cards = sgs.QList2Table(player:getHandcards())
	for _, id in sgs.qlist(player:getHandPile()) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	local num = 0
	local shownum = 0
	local redpeach = 0
	local redslash = 0
	local blackcard = 0
	local blacknull = 0
	local equipnull = 0
	local equipcard = 0
	local trickcard = 0
	local heartslash = 0
	local heartpeach = 0
	local spadenull = 0
	local spadewine = 0
	local spadecard = 0
	local diamondcard = 0
	local clubcard = 0
	local slashjink = 0
	local other = {}

	for _, card in ipairs(cards) do
		if sgs.cardIsVisible(card, player, from) then
			shownum = shownum + 1
			if isCard(class_name, card, player) then
				num = num + 1
			else
				table.insert(other, card)
			end
			if card:isKindOf("EquipCard") then
				equipcard = equipcard + 1
			end
			if card:isKindOf("TrickCard") then
				trickcard = trickcard + 1
			end
			if card:isKindOf("Slash") or card:isKindOf("Jink") then
				slashjink = slashjink + 1
			end
			if card:isRed() then
				if not card:isKindOf("Slash") then
					redslash = redslash + 1
				end
				if not card:isKindOf("Peach") then
					redpeach = redpeach + 1
				end
			end
			if card:isBlack() then
				blackcard = blackcard + 1
				if not card:isKindOf("Nullification") then
					blacknull = blacknull + 1
				end
			end
			if card:getSuit() == sgs.Card_Heart then
				if not card:isKindOf("Slash") then
					heartslash = heartslash + 1
				end
				if not card:isKindOf("Peach") then
					heartpeach = heartpeach + 1
				end
			end
			if card:getSuit() == sgs.Card_Spade then
				if not card:isKindOf("Nullification") then
					spadenull = spadenull + 1
				end
				if not card:isKindOf("Analeptic") then
					spadewine = spadewine + 1
				end
			end
			if card:getSuit() == sgs.Card_Diamond and not card:isKindOf("Slash") then
				diamondcard = diamondcard + 1
			end
			if card:getSuit() == sgs.Card_Club then
				clubcard = clubcard + 1
			end
		end
	end

	local ecards = player:getCards("e")
	for _, card in sgs.qlist(ecards) do
		table.insert(other, card)
		equipcard = equipcard + 1
		if player:getHandcardNum() > player:getHp() then
			equipnull = equipnull + 1
		end
		if card:isRed() then
			redpeach = redpeach + 1
			redslash = redslash + 1
		end
		if card:getSuit() == sgs.Card_Heart then
			heartpeach = heartpeach + 1
		end
		if card:getSuit() == sgs.Card_Spade then
			spadecard = spadecard + 1
		end
		if card:getSuit() == sgs.Card_Diamond  then
			diamondcard = diamondcard + 1
		end
		if card:getSuit() == sgs.Card_Club then
			clubcard = clubcard + 1
		end
	end
	num = num + #cardsViewValue(sgs.ais[player:objectName()], class_name, player,"getCardsNum")
	num = num + #cardsView(sgs.ais[player:objectName()], class_name, player, other)

	if not from or player:objectName() ~= from:objectName() then
		if class_name == "Slash" then
			local slashnum
			if player:hasShownSkills("wusheng|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo") then
				slashnum = redslash + num + (player:getHandcardNum() - shownum) * 0.69
			elseif player:hasShownSkill("Wushen") then
				slashnum = heartslash + num + (player:getHandcardNum() - shownum) * 0.5
			elseif player:hasShownSkill("Longhun") then
				slashnum = diamondcard + num + (player:getHandcardNum() - shownum) * 0.5
			elseif player:hasShownSkills("longdan|longdan_ZhaoYun_LB") or (player:hasShownSkill("Shizhi") and player:getHp() == 1) then
				slashnum = slashjink + (player:getHandcardNum() - shownum) * 0.72
			else
				slashnum = num + (player:getHandcardNum() - shownum) * 0.35
			end
			if player:hasWeapon("Spear") then
				local slashnum2 = math.floor((player:getHandcardNum() - shownum) / 2) + num
				return math.max(slashnum, slashnum2)
			end
			return slashnum
		elseif class_name == "Jink" then
			if player:hasShownSkill("qingguo") then
				return blackcard + num + (player:getHandcardNum() - shownum) * 0.85
			elseif player:hasShownSkills("longdan|longdan_ZhaoYun_LB") then
				return slashjink + (player:getHandcardNum() - shownum) * 0.72
			elseif player:hasShownSkill("Longhun") then
				return clubcard + num + (player:getHandcardNum() - shownum) * 0.65
			elseif player:hasShownSkill("Shizhi") and player:getHp() == 1 then
				return num
			else
				return num + (player:getHandcardNum() - shownum) * 0.6
			end
		elseif class_name == "Peach" then
			if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") then
				return num + redpeach + (player:getHandcardNum() - shownum) * 0.6
			elseif player:hasShownSkill("Longhun") then
				return num + heartpeach + (player:getHandcardNum() - shownum) * 0.5
			else
				return num
			end
		elseif class_name == "Analeptic" then
			if player:hasShownSkill("Jiushi") then
				return num + 1
			else
				return num
			end
		elseif class_name == "Nullification" then
			if player:hasShownSkill("kanpo") then
				return num + blacknull + (player:getHandcardNum() - shownum) * 0.5
			elseif player:hasShownSkill("Longhun") then
				return num + spadenull + (player:getHandcardNum() - shownum) * 0.5
			else
				return num
			end
		end
	end
	return num
end
function sgs.hasNullSkill(skill_name, player)								--非锁无效
	local head_valid, deputy_valid = true, true
	if sgs.Sanguosha:getSkill(skill_name):getFrequency() ~= sgs.Skill_Compulsory then
		if player:property("NonCompulsoryInvalidity"):toString() ~= "" then
			local invalid_list = player:property("NonCompulsoryInvalidity"):toString():split(",")
			for _, str in ipairs(invalid_list) do
				if str:startsWith("head") then
					head_valid = false
				end
				if str:startsWith("deputy") then
					deputy_valid = false
				end
			end
		end
	end
	if sgs.general_shown[player:objectName()]["head"] and player:inHeadSkills(skill_name) and ((#player:disableShow(true) > 0
		and not player:hasShownGeneral1()) or not head_valid) then
		return true
	elseif sgs.general_shown[player:objectName()]["deputy"] and player:inDeputySkills(skill_name) and ((#player:disableShow(false) > 0
		and not player:hasShownGeneral2()) or not deputy_valid) then
		return true
	end
	return
end
function SmartAI:dontRespondPeachInJudge(judge)								--judge reason：铁骑
	if not judge or type(judge) ~= "JudgeStruct" then self.room:writeToConsole(debug.traceback()) return end
	local peach_num = self:getCardsNum("Peach")
	if peach_num == 0 then return false end
	if self:willSkipPlayPhase() and self:getCardsNum("Peach") > self:getOverflow(self.player, true) then return false end
	if judge.reason == "lightning" and self:isFriend(judge.who) then return false end

	local card = self:getCard("Peach")
	local dummy_use = { isDummy = true }
	self:useBasicCard(card, dummy_use)
	if dummy_use.card then return true end

	if peach_num <= self.player:getLostHp() then return true end

	if peach_num > self.player:getLostHp() then
		for _, friend in ipairs(self.friends) do
			if self:isWeak(friend) then return true end
		end
	end

	if (judge.reason == "EightDiagram" or judge.reason == "bazhen") and
		self:isFriend(judge.who) and (not self:isWeak(judge.who) or judge.who:hasShownSkills(sgs.masochism_skill)) then return true
	elseif judge.reason == "tieqi" or judge.reason == "TieqiLB" then return true
	elseif judge.reason == "qianxi" then return true
	elseif judge.reason == "beige" then return true
	end

	return false
end
function SmartAI:adjustUsePriority(card, v)									--龙吟、诈降、狂风、大雾、武神、耀武、矢志、燃殇、怒斩
	local suits = {"club", "spade", "diamond", "heart"}

	if card:getTypeId() == sgs.Card_TypeSkill then return v end
	if card:getTypeId() == sgs.Card_TypeEquip then return v end

	for _, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		local callback = sgs.ai_suit_priority[askill:objectName()]
		if type(callback) == "function" then
			suits = callback(self, card):split("|")
			break
		elseif type(callback) == "string" then
			suits = callback:split("|")
			break
		end
	end

	table.insert(suits, "no_suit")
	if card:isKindOf("Slash") then
		if card:getSkillName() == "Spear" then v = v - 0.1 end
		if card:isRed() then
			if self.player:hasSkill("Longyin") and self.player:canDiscard(self.player, "he") then v = v + 0.32
			else
				for _, friend in ipairs(self.friends_noself) do
					if friend:hasShownSkill("Longyin") and friend:canDiscard(friend, "he") then
						v = v + 0.32
						break
					end
				end
			end
			if self:canZhaxiang(self.player, true, card) then v = v + 0.32 end
			for _, enemy in ipairs(self.enemies) do
				if self:hasYaowuEffect(enemy, card, false, self.player) then v = v + 0.09 break end
			end
			v = v - 0.05
		end
		if card:isKindOf("NatureSlash") then
			if self.slashAvail == 1 then
				v = v + 0.05
				if card:isKindOf("FireSlash") then
					for _, enemy in ipairs(self.enemies) do
						if enemy:hasArmorEffect("Vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or (enemy:hasShownSkill("Ranshang") and not enemy:hasShownSkill("hongfa")) then v = v + 0.07 break end
					end
				elseif card:isKindOf("ThunderSlash") then
					for _, enemy in ipairs(self.enemies) do
						if enemy:getMark("@fog") > 0 or enemy:getMark("@fog_ShenZhuGeLiang") > 0 then v = v + 0.06 break end
					end
				end
			else v = v - 0.05
			end
		end
		if self.player:hasSkill("jiang") and card:isRed() then v = v + 0.21 end
        if self.player:hasShownSkill("Wushen") and card:getSuit() == sgs.Card_Heart then v = v + 0.12 end  --唯一一个ShownSkill，防止在有杀时亮将
        if self.player:hasShownSkill("Shizhi") and self.player:getHp() == 1 and card:getEffectiveId() >= 0 and sgs.Sanguosha:getEngineCard(card:getEffectiveId()):isKindOf("Jink") then v = v - 0.12 end  --锁定视为技中唯一一个减的（回复体力后继续当闪）
		if self.player:hasSkill("Nuzhan") and card:isVirtualCard() and (card:subcardsLength() == 1) and sgs.Sanguosha:getCard(card:getSubcards():first()):isKindOf("TrickCard") and self:getCardsNum("Slash", "he") > 1 then v = v + 0.26 end
		if self.slashAvail == 1 then
			v = v + math.min(sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card) * 0.1, 0.5)
			v = v + math.min(sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, card) * 0.05, 0.5)
		end
	end

	if card:isKindOf("HalberdCard") then v = v + 1 end
	if self.player:getHandPile():contains(card:getEffectiveId()) then
		v = v + 0.1
	end
	local suits_value = {}
	for index, suit in ipairs(suits) do
		suits_value[suit] = -index
	end
	v = v + (suits_value[card:getSuitString()] or 0) / 1000
	v = v + (13 - card:getNumber()) / 10000
	return v
end
function SmartAI:hasTrickEffective(card, to, from)							--DisableOtherTargets（不知道为什么剑阁机关的ai_trick_prohibit被注释了）、制蛮、
																			--智迟
	from = from or self.room:getCurrent()
	to = to or self.player
	--if sgs.Sanguosha:isProhibited(from, to, card) then return false end
	if to:isRemoved() then return false end
	if from:hasFlag("DisableOtherTargets") then return false end
    if to:getMark("@late") > 0 and not card:isKindOf("DelayedTrick") then return false end
	
	if from then
		if from:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") and self:isFriend(to, from) and (card:isKindOf("Duel") or card:isKindOf("ArcheryAttack") or card:isKindOf("SavageAssault")) then return false end
		if from:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") and self:isFriend(to, from) and (card:isKindOf("FireAttack") or card:isKindOf("BurningCamps")) and not self:isGoodChainTarget(to, from, sgs.DamageStruct_Fire) then
			return false
		end
		if card:isKindOf("SavageAssault") then
			local menghuo = sgs.findPlayerByShownSkillName("huoshou")
			if menghuo and self:isFriend(to, menghuo) and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return false end
		end
	end

	if not card:isKindOf("TrickCard") then self.room:writeToConsole(debug.traceback()) return end
	if to:hasShownSkill("hongyan") and card:isKindOf("Lightning") then return false end
	if to:hasShownSkill("qianxun") and card:isKindOf("Snatch") then return false end
	if to:hasShownSkill("qianxun") and card:isKindOf("Indulgence") then return false end
	if card:isKindOf("Indulgence") then
		if to:hasSkills("jgjiguan_qinglong|jgjiguan_baihu|jgjiguan_zhuque|jgjiguan_xuanwu") then return false end
		if to:hasSkills("jgjiguan_bian|jgjiguan_suanni|jgjiguan_chiwen|jgjiguan_yazi") then return false end
	end
	if to:hasShownSkill("weimu") and card:isBlack() then
		if from:objectName() == to:objectName() and card:isKindOf("Disaster") then
		else
			return false
		end
	end
	if to:hasShownSkill("kongcheng") and to:isKongcheng() and card:isKindOf("Duel") then return false end

	if card:isKindOf("IronChain") and not to:canBeChainedBy(from) then return false end

	local nature = sgs.DamageStruct_Normal
	if card:isKindOf("FireAttack") or card:isKindOf("BurningCamps") then nature = sgs.DamageStruct_Fire
	elseif card:isKindOf("Drowning") then nature = sgs.DamageStruct_Thunder end

	if (card:isKindOf("Duel") or card:isKindOf("FireAttack") or card:isKindOf("ArcheryAttack") or card:isKindOf("SavageAssault"))
		and not self:damageIsEffective(to, nature, from) then return false end

	if to:hasArmorEffect("IronArmor") and (card:isKindOf("FireAttack") or card:isKindOf("BurningCamps")) then return false end

	for _, callback in pairs(sgs.ai_trick_prohibit) do
		if type(callback) == "function" then
			if callback(self, card, to, from) then return false end
		end
	end

	return true
end
function SmartAI:willUsePeachTo(dying)										--DisableOtherTargets、不屈、武魂、酒诗
	local card_str
	local forbid = sgs.cloneCard("peach")
	if self.player:isLocked(forbid) or dying:isLocked(forbid) then return "." end
	if self.player:hasFlag("DisableOtherTargets") and (dying:objectName() ~= self.player:objectName()) then return "." end
	if self.player:objectName() == dying:objectName() and not self:needDeath(dying) then
		local analeptic = sgs.cloneCard("analeptic")
		if not self.player:isLocked(analeptic) and self:getCardId("Analeptic") then return self:getCardId("Analeptic") end
		if self:getCardId("Peach") then return self:getCardId("Peach") end
	end

	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if (type(damage) == "DamageStruct" or type(damage) == "userdata") and damage.to and damage.to:objectName() == dying:objectName() and damage.from
		and (damage.from:objectName() == self.player:objectName()
			or self.player:isFriendWith(damage.from)
			or self:evaluateKingdom(damage.from) == self.player:getKingdom())
		and (self.player:getKingdom() ~= sgs.ai_explicit[damage.to:objectName()] or self.role == "careerist") then
		return "."
	end

	if self:isFriend(dying) then
        if self:needDeath(dying) then return "." end
		if not self.player:isFriendWith(dying) and self:isWeak() then return "." end

		if self:getCardsNum("Peach") + self:getCardsNum("Analeptic") <= sgs.ai_NeedPeach[self.player:objectName()] then return "." end

		if math.ceil(self:getAllPeachNum()) < 1 - dying:getHp() then return "." end

		if dying:objectName() ~= self.player:objectName() then
			local possible_friend = 0
			for _, friend in ipairs(self.friends_noself) do
				if (self:getKnownNum(friend) == friend:getHandcardNum() and getCardsNum("Peach", friend, self.player) == 0)
					or (self:playerGetRound(friend) < self:playerGetRound(self.player)) then
				elseif sgs.card_lack[friend:objectName()]["Peach"] == 1 then
				elseif not self:ableToSave(friend, dying) then
				elseif friend:getHandcardNum() > 0 or getCardsNum("Peach", friend, self.player) > 0 then
					possible_friend = possible_friend + 1
				end
			end
			if possible_friend == 0 and self:getCardsNum("Peach") < 1 - dying:getHp() then
				return "."
			end
		end


		local buqu = dying:getPile("buqu")
		if not buqu:isEmpty() then
			local same = false
			for i, card_id in sgs.qlist(buqu) do
				for j, card_id2 in sgs.qlist(buqu) do
					if i ~= j and sgs.Sanguosha:getCard(card_id):getNumber() == sgs.Sanguosha:getCard(card_id2):getNumber() then
						same = true
						break
					end
				end
			end
			if not same then return "." end
		end
		if dying:hasShownSkills("BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15") and hasBuquEffect(dying) then return "." end
		if dying:hasFlag("Kurou_toDie") and (not dying:getWeapon() or dying:getWeapon():objectName() ~= "Crossbow") then return "." end
        if self.player:objectName() ~= dying:objectName() and dying:hasShownSkill("Jiushi") and dying:faceUp() and dying:getHp()== 0 then
            return "."
        end

		if (self.player:objectName() == dying:objectName()) then
			card_str = self:getCardId("Analeptic")
			if not card_str then card_str = self:getCardId("Peach") end
		elseif self:doNotSave(dying) then return "."
		else card_str = self:getCardId("Peach") end
	else --救对方的情形
        if dying:hasShownSkill("Wuhun") then --濒死者有技能“武魂”		（源码主要考虑身份，移植太麻烦，因此这里只考虑君主）
			--local should = self.role == "renegade" and self.room:alivePlayerCount() > 2
							--or (self.role == "lord" or self.role == "loyalist") and sgs.current_mode_players["rebel"] + sgs.current_mode_players["renegade"] > 1
			
			--if should then --可能有救的必要
			local willKillLord = false
			local willKillSelf = false
			local revengeTargets = self:getWuhunRevengeTargets() --武魂复仇目标
			if #revengeTargets > 0 then
				local lord = self.player:getLord()
				if lord then
					for _, target in pairs(revengeTargets) do
						if target:objectName() == lord:objectName() then
							willKillLord = true
							break
						end
					end
				end
				if self.room:alivePlayerCount() == 3 then  --剩3人时防止自己被带走
					local other_friends
					for _,friend in sgs.qlist(self.room:getOtherPlayers(self.player)) do
						if self:isFriendWith(friend) then
							other_friends = friend
							break
						end
					end
					if not other_friends then
						if #revengeTargets == 1 and revengeTargets[1]:objectName() == self.player:objectName() then
							willKillSelf = true
						end
					end
				end
			end
			if willKillLord or willKillSelf then --君主/自己会被武魂带走，真的有必要……
				local finalRetrial, wizard = self:getFinalRetrial(self.room:getCurrent(), "Wuhun")
				if finalRetrial == 0 then --没有判官，需要考虑观星、心战、攻心的结果（已忽略）
					card_str = self:getCardId("Peach")
				elseif finalRetrial == 1 then --己方后判，需要考虑最后的判官是否有桃或桃园结义改判（已忽略）
					local flag = wizard:hasShownSkills("guidao|GuicaiLB") and "he" or "h"
					if getKnownCard(wizard, self.player, "Peach", false, flag) > 0 or getKnownCard(wizard, self.player, "GodSalvation", false, flag) > 0 then return "." end
					card_str = self:getCardId("Peach")
				elseif finalRetrial == 2 then --对方后判，这个一定要救了……
					card_str = self:getCardId("Peach")
				end
			end
			--end
        end
	end
	if not card_str then return nil end
	return card_str
end
function SmartAI:needToLoseHp(to, from, isSlash, passive, recover)			--惴恐、仁德、潜心、龙魂（todo：移植至getBestHp）
	to = to or self.player
	if isSlash and from and from:hasWeapon("IceSword") and to:getCards("he"):length() > 1 and not self:isFriend(from, to) then
		return false
	end
	if from and self:hasHeavySlashDamage(from, nil, to) then return false end
	local n = to:getMaxHp()
	if to:hasShownSkill("Longhun") and to:getCards("he"):length() > 2 then n = 1 end

	if not passive then
		if to:hasShownSkills("rende|RendeLB") and to:getMaxHp() > 2 and not self:willSkipPlayPhase(to) and self:findFriendsByType(sgs.Friend_Draw, to) then
			n = math.min(n, to:getMaxHp() - 1)
		elseif to:hasShownSkill("hengzheng") and sgs.ai_skill_invoke.hengzheng(sgs.ais[to:objectName()]) then
			n = math.min(n, to:getMaxHp() - 1)
		elseif to:hasShownSkills("yinghun_sunjian|yinghun_sunce|zaiqi") then
			n = math.min(n, to:getMaxHp() - 1)
		end
		if to:hasShownSkill("Zhuikong") and self:getOverflow() >= 0 then
			n = math.min(n, to:getMaxHp() - 1)
		end
		if to:hasShownSkill("Qianxin") and not to:isWounded() and to:getMaxHp() > 3 then
			n = math.min(n, to:getMaxHp() - 1)
		end
	end

	local xiangxiang = sgs.findPlayerByShownSkillName("jieyin")
	if xiangxiang and xiangxiang:isWounded() and self:isFriend(xiangxiang, to) and not to:isWounded() and to:isMale()
		and (xiangxiang:getPhase() == sgs.Player_Play and xiangxiang:getHandcardNum() >= 2 and not xiangxiang:hasUsed("JieyinCard")
			or self:getEnemyNumBySeat(self.room:getCurrent(), xiangxiang, self.player) <= 1) then
		local friends = self:getFriendsNoself(to)
		local need_jieyin = true
		self:sort(friends, "hp")
		for _, friend in ipairs(friends) do
			if friend:isMale() and friend:isWounded() then need_jieyin = false end
		end
		if need_jieyin then n = math.min(n, to:getMaxHp() - 1) end
	end

	if recover then return to:getHp() >= n end

	return to:getHp() > n
end
function SmartAI:hasHeavySlashDamage(from, slash, to, getValue)				--暗箭、裸衣、狂风、仁心、忠义、怒斩
	from = from or self.room:getCurrent()
	if not slash or not slash:isKindOf("Slash") then
		slash = self.player:objectName() == from:objectName() and self:getCard("Slash") or sgs.cloneCard("slash")
	end
	to = to or self.player
	if not from or not to then self.room:writeToConsole(debug.traceback()) return false end
	if to:hasArmorEffect("SilverLion") and not IgnoreArmor(from, to) then
		if getValue then return 1
		else return false end
	end
	local dmg = 1
	local fireSlash = slash and (slash:isKindOf("FireSlash") or slash:objectName() == "slash" and from:hasWeapon("Fan"))
	local thunderSlash = slash and slash:isKindOf("ThunderSlash")

	if (slash and slash:hasFlag("drank")) then
		dmg = dmg + 1
	elseif from:getMark("drank") > 0 then
		dmg = dmg + from:getMark("drank")
	end
	if from:hasFlag("luoyi") then dmg = dmg + 1 end
	if from:getMark("@LuoyiLB") > 0 then dmg = dmg + from:getMark("@LuoyiLB") end
	
	--todo：绝情
	if from:hasShownSkill("Anjian") and not to:inMyAttackRange(from) then dmg = dmg + 1 end
	local guanyu = self.room:findPlayerBySkillName("Zhongyi")
	if guanyu and guanyu:getPile("loyal"):length() > 0 and from:isFriendWith(guanyu) then dmg = dmg + 1 end
	if from:hasShownSkill("Nuzhan") and slash then
		if slash:hasFlag("Nuzhan_slash") then dmg = dmg + 1
		elseif slash:isVirtualCard() and (slash:subcardsLength() == 1) and sgs.Sanguosha:getCard(slash:getSubcards():first()):isKindOf("EquipCard") then
			dmg = dmg + 1
		end
	end
	if from:hasWeapon("GudingBlade") and slash and to:isKongcheng() then dmg = dmg + 1 end
	if to:getMark("@gale") > 0 and fireSlash then dmg = dmg + 1 end
	if to:getMark("@gale_ShenZhuGeLiang") > 0 and fireSlash then dmg = dmg + 1 end
	local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
	if jiaren_zidan and jiaren_zidan:isFriendWith(to) then
		dmg = 1
	end
	if to:getHp() == 1 and self:hasRenxinEffect(to, from, false, dmg, true, slash) then
		if getValue then return 1  --擦边球，因为严格来说并不是伤害点数变成了1，但是曹冲翻面的成本差不多1血了
		else return false end
	end
	if to:hasArmorEffect("Vine") and not IgnoreArmor(from, to) and fireSlash then
		dmg = dmg + 1
	end

	if getValue then return dmg end
	return (dmg > 1)
end
function SmartAI:filterEvent(event, player, data)							--纵玄、奋激
	if not sgs.recorder then
		sgs.recorder = self
	end
	if player:objectName() == self.player:objectName() then
		if sgs.debugmode and type(sgs.ai_debug_func[event]) == "table" then
			for _, callback in pairs(sgs.ai_debug_func[event]) do
				if type(callback) == "function" then callback(self, player, data) end
			end
		end
		if type(sgs.ai_chat_func[event]) == "table" and sgs.GetConfig("AIChat", false) and sgs.GetConfig("OriginAIDelay", 0) > 0 then
			for _, callback in pairs(sgs.ai_chat_func[event]) do
				if type(callback) == "function" then callback(self, player, data) end
			end
		end
		if type(sgs.ai_event_callback[event]) == "table" then
			for _, callback in pairs(sgs.ai_event_callback[event]) do
				if type(callback) == "function" then callback(self, player, data) end
			end
		end
	end

	-- if not sgs.DebugMode_Niepan and event == sgs.AskForPeaches and self.room:getCurrentDyingPlayer():objectName() == self.player:objectName() then endlessNiepan(self, data:toDying().who) end

	sgs.lastevent = event
	sgs.lasteventdata = data
	if event == sgs.ChoiceMade and (self == sgs.recorder or self.player:objectName() == sgs.recorder.player:objectName()) then
		local carduse = data:toCardUse()
		if carduse and carduse.card ~= nil then
			for _, callback in ipairs(sgs.ai_choicemade_filter.cardUsed) do
				if type(callback) == "function" then
					callback(self, player, carduse)
				end
			end
		elseif data:toString() then
			promptlist = data:toString():split(":")
			local callbacktable = sgs.ai_choicemade_filter[promptlist[1]]
			if callbacktable and type(callbacktable) == "table" then
				local index = 2
				if promptlist[1] == "cardResponded" then

					if promptlist[2]:match("jink") and not self:hasEightDiagramEffect(player) then
						sgs.card_lack[player:objectName()]["Jink"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					elseif promptlist[2]:match("slash") then
						sgs.card_lack[player:objectName()]["Slash"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					elseif promptlist[2]:match("peach") then
						sgs.card_lack[player:objectName()]["Peach"] = promptlist[#promptlist] == "_nil_" and 1 or 0
					end

					index = 3
				end
				local callback = callbacktable[promptlist[index]] or callbacktable.general
				if type(callback) == "function" then
					callback(self, player, promptlist)
				end
			end

		end
	elseif event == sgs.GameStart or event == sgs.EventPhaseStart or event == sgs.RemoveStateChanged then--event == sgs.CardFinished
		self:updatePlayers(self == sgs.recorder)
	elseif event == sgs.BuryVictim or event == sgs.HpChanged or event == sgs.MaxHpChanged then
		self:updatePlayers(self == sgs.recorder)
	end

	if event == sgs.BuryVictim then
		if self == sgs.recorder then sgs.updateAlivePlayerRoles() end
	end

	if self.player:objectName() == player:objectName() and event == sgs.AskForPeaches then
		local dying = data:toDying()
		if self:isFriend(dying.who) and dying.who:getHp() < 1 then
			sgs.card_lack[player:objectName()]["Peach"] = 1
		end
	end
	if self.player:objectName() == player:objectName() and player:getPhase() ~= sgs.Player_Play and event == sgs.CardsMoveOneTime then
		local move = data:toMoveOneTime()
		if move.to and move.to:objectName() == player:objectName() and (move.to_place == sgs.Player_PlaceHand or move.to_place == sgs.Player_PlaceEquip) then
			self:assignKeep()
		-- elseif move.from and move.from:objectName() == player:objectName()   and (move.from_places:contains(sgs.Player_PlaceHand) or move.from_places:contains(sgs.Player_PlaceEquip)) then
			-- self:assignKeep()
		end
	end

	if self ~= sgs.recorder then return end

	if event == sgs.GeneralShown then
		self:updatePlayerKingdom(player, data)
	elseif event == sgs.GeneralHidden then
		if player:getAI() then player:setSkillsPreshowed("hd", true) end
	elseif event == sgs.TargetConfirmed then
		local struct = data:toCardUse()
		local from = struct.from
		local card = struct.card
		local tos = sgs.QList2Table(struct.to)
		if from and from:objectName() == player:objectName() then
			local callback = sgs.ai_card_intention[card:getClassName()]
			if callback then
				if type(callback) == "function" then
					callback(self, card, from, tos)
				elseif type(callback) == "number" then
					sgs.updateIntentions(from, tos, callback, card)
				end
			end
			-- AI Chat
			speakTrigger(card, from, tos)
			if card:getClassName() == "LuaSkillCard" and card:isKindOf("LuaSkillCard") then
				local luacallback = sgs.ai_card_intention[card:objectName()]
				if luacallback then
					if type(luacallback) == "function" then
						luacallback(self, card, from, tos)
					elseif type(luacallback) == "number" then
						sgs.updateIntentions(from, tos, luacallback, card)
					end
				end
			end
		end

		if card:isKindOf("AOE") and self.player:objectName() == player:objectName() then
			for _, t in sgs.qlist(struct.to) do
				if t:hasShownSkill("fangzhu") then sgs.ai_AOE_data = data break end
				if t:hasShownSkill("guidao") and t:hasShownSkill("leiji") and card:isKindOf("ArcheryAttack") then sgs.ai_AOE_data = data break end
			end
		end

	elseif event == sgs.PreDamageDone then
		local damage = data:toDamage()
		local clear = true
		if clear and damage.to:isChained() then
			for _, p in sgs.qlist(self.room:getOtherPlayers(damage.to)) do
				if p:isChained() and damage.nature ~= sgs.DamageStruct_Normal then
					clear = false
					break
				end
			end
		end
		if not clear then
			if damage.nature ~= sgs.DamageStruct_Normal and not damage.chain then
				for _, p in sgs.qlist(self.room:getAlivePlayers()) do
					local added = 0
					if p:objectName() == damage.to:objectName() and p:isChained() and p:getHp() <= damage.damage then
						sgs.ai_NeedPeach[p:objectName()] = damage.damage + 1 - p:getHp()
					elseif p:objectName() ~= damage.to:objectName() and p:isChained() and self:damageIsEffective(p, damage.nature, damage.from) then
						if damage.nature == sgs.DamageStruct_Fire then
							added = p:hasArmorEffect("Vine") and added + 1 or added
							sgs.ai_NeedPeach[p:objectName()] = damage.damage + 1 + added - p:getHp()
						elseif damage.nature == sgs.DamageStruct_Thunder then
							sgs.ai_NeedPeach[p:objectName()] = damage.damage + 1 + added - p:getHp()
						end
					end
				end
			end
		else
			for _, p in sgs.qlist(self.room:getAlivePlayers()) do
				sgs.ai_NeedPeach[p:objectName()] = 0
			end
		end
	elseif event == sgs.CardUsed then
		local struct = data:toCardUse()
		local card = struct.card
		local who
		if not struct.to:isEmpty() then who = struct.to:first() end

		if card:isKindOf("Snatch") or card:isKindOf("Dismantlement") then
			for _, p in sgs.qlist(struct.to) do
				for _, c in sgs.qlist(p:getCards("hej")) do
					self.room:setCardFlag(c, "-AIGlobal_SDCardChosen_"..card:objectName())
				end
			end
		end

		if card:isKindOf("AOE") and sgs.ai_AOE_data then
			sgs.ai_AOE_data = nil
		end

		if card:isKindOf("Collateral") then sgs.ai_collateral = false end

	elseif event == sgs.CardsMoveOneTime then
		local move = data:toMoveOneTime()
		local from = nil   -- convert move.from from const Player * to ServerPlayer *
		local to = nil   -- convert move.to to const Player * to ServerPlayer *
		if move.from then from = findPlayerByObjectName(move.from:objectName(), true) end
		if move.to then to = findPlayerByObjectName(move.to:objectName(), true) end
		local reason = move.reason
		local from_places = sgs.QList2Table(move.from_places)

        if self.room:findPlayerBySkillName("Fenji") or self.room:findPlayerBySkillName("Fenji15") then
            sgs.ai_fenji_target = nil
            if from and from:isAlive() and move.from_places:contains(sgs.Player_PlaceHand)
                and ((move.reason.m_reason == sgs.CardMoveReason_S_REASON_DISMANTLE and move.reason.m_playerId ~= move.reason.m_targetId)
                        or (to and to:objectName() ~= from:objectName() and move.to_place == sgs.Player_PlaceHand)) then
                sgs.ai_fenji_target = from
            end
        end

		for i = 0, move.card_ids:length() - 1 do
			local place = move.from_places:at(i)
			local card_id = move.card_ids:at(i)
			local card = sgs.Sanguosha:getCard(card_id)
			
			if place == sgs.Player_DrawPile
                or (move.to_place == sgs.Player_DrawPile and not self.room:getTag("ZongxuanMoving"):toBool()) then  --纵玄
				if self.top_draw_pile_id ~= nil then
					self.top_draw_pile_id = nil
				end
            end

			if move.to_place == sgs.Player_PlaceHand and to and player:objectName() == to:objectName() then
				if card:hasFlag("visible") then
					if isCard("Slash", card, player) then sgs.card_lack[player:objectName()]["Slash"] = 0 end
					if isCard("Jink", card, player) then sgs.card_lack[player:objectName()]["Jink"] = 0 end
					if isCard("Peach", card, player) then sgs.card_lack[player:objectName()]["Peach"] = 0 end
				else
					sgs.card_lack[player:objectName()]["Slash"] = 0
					sgs.card_lack[player:objectName()]["Jink"] = 0
					sgs.card_lack[player:objectName()]["Peach"] = 0
				end

				if place == sgs.Player_DrawPile then
					local count = self.room:getTag("SwapPile"):toInt()
					for _, p in sgs.qlist(self.room:getOtherPlayers(to)) do
						if sgs.ai_guangxing[p:objectName()][count] and table.contains(sgs.ai_guangxing[p:objectName()][count], tostring(card_id)) then
							table.removeOne(sgs.ai_guangxing[p:objectName()][count], card_id)
							local flag = string.format("%s_%s_%s", "visible", p:objectName(), to:objectName())
							self.room:setCardFlag(card_id, flag, p)
						end
					end
				end
			end

			if move.to_place == sgs.Player_PlaceHand and to and place ~= sgs.Player_DrawPile then
				if from and player:objectName() == from:objectName()
					and from:objectName() ~= to:objectName() and place == sgs.Player_PlaceHand and not card:hasFlag("visible") then
					local flag = string.format("%s_%s_%s", "visible", from:objectName(), to:objectName())
					global_room:setCardFlag(card_id, flag, from)
				end
			end

			if player:hasFlag("AI_Playing") and player:hasShownSkill("leiji") and player:getPhase() == sgs.Player_Discard and isCard("Jink", card, player)
				and player:getHandcardNum() >= 2 and reason.m_reason == sgs.CardMoveReason_S_REASON_RULEDISCARD then sgs.card_lack[player:objectName()]["Jink"] = 2 end
		end
	elseif event == sgs.EventPhaseEnd and player:getPhase() == sgs.Player_Player then
		player:setFlags("AI_Playing")
	elseif event == sgs.EventPhaseStart then
		if player:getPhase() == sgs.Player_RoundStart then
			if not sgs.ai_setSkillsPreshowed then
				self:setSkillsPreshowed()
				sgs.ai_setSkillsPreshowed = true
			end
			if player:getAI() then player:setSkillsPreshowed("hd", true) end
			-- sgs.printFEList(player)
			-- sgs.debugFunc(player, 3)
		elseif player:getPhase() == sgs.Player_NotActive then
			if sgs.recorder.player:objectName() == player:objectName() then sgs.turncount = sgs.turncount + 1 end
		end
	end
end
function SmartAI:getDistanceLimit(card, from)								--巧说
	from = from or self.player
	if (card:isKindOf("Snatch") or card:isKindOf("SupplyShortage") or card:isKindOf("Slash")) and card:getSkillName() ~= "Qiaoshui" then
		return 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, from, card)
	elseif card:isKindOf("Indulgence") or card:isKindOf("FireAttack") then
		return 999
	end
end
function SmartAI:getMaxCard(player, cards, observer)						--巧说
	player = player or self.player

	if player:isKongcheng() then
		return nil
	end

	cards = cards or player:getHandcards()
	local max_card, max_point = nil, 0
	for _, card in sgs.qlist(cards) do
		if (player:objectName() == self.player:objectName() and not self:isValuableCard(card)) or sgs.cardIsVisible(card, player, observer) then
			local point = card:getNumber()
			if point > max_point then
				max_point = point
				max_card = card
			end
		end
	end
	if player:objectName() == self.player:objectName() and not max_card then
		for _, card in sgs.qlist(cards) do
			local point = card:getNumber()
			if point > max_point then
				max_point = point
				max_card = card
			end
		end
	end

	if player:objectName() ~= self.player:objectName() then return max_card end

	if player:hasShownSkill("tianyi") and max_point > 0 then
		for _, card in sgs.qlist(cards) do
			if card:getNumber() == max_point and not isCard("Slash", card, player) then
				return card
			end
		end
	end
	if player:hasShownSkill("Qiaoshui") and max_point > 0 then
        for _, card in sgs.qlist(cards) do
            if card:getNumber() == max_point and not card:isNDTrick() then
                return card
            end
        end
    end

	return max_card
end
function SmartAI:askForCardChosen(who, flags, reason, method, disable_list)	--急救、归心、明策、仁心
	local isDiscard = (method == sgs.Card_MethodDiscard)
	local disable_list = disable_list or {}
	local cardchosen = sgs.ai_skill_cardchosen[string.gsub(reason, "%-", "_")]
	local card
	if type(cardchosen) == "function" then
		card = cardchosen(self, who, flags, method, disable_list)
		if type(card) == "number" then return card
		elseif card then return card:getEffectiveId() end
	elseif type(cardchosen) == "number" then
		sgs.ai_skill_cardchosen[string.gsub(reason, "%-", "_")] = nil
		for _, acard in sgs.qlist(who:getCards(flags)) do
			if acard:getEffectiveId() == cardchosen then return cardchosen end
		end
	end

	if ("snatch|dismantlement"):match(reason) then
		local flag = "AIGlobal_SDCardChosen_" .. reason
		local to_choose
		for _, card in sgs.qlist(who:getCards(flags)) do
			if card:hasFlag(flag) then
				card:setFlags("-" .. flag)
				to_choose = card:getId()
				break
			end
		end
		if to_choose then return to_choose end
	end

	if self:isFriend(who) then
		if flags:match("j") and not (who:hasShownSkill("qiaobian") and who:getHandcardNum() > 0) then
			local tricks = who:getCards("j")
			local lightning, indulgence, supply_shortage
			for _, trick in sgs.qlist(tricks) do
				if table.contains(disable_list, trick:getEffectiveId()) then continue end
				if trick:isKindOf("Lightning") and (not isDiscard or self.player:canDiscard(who, trick:getId())) then
					lightning = trick:getId()
				elseif trick:isKindOf("Indulgence") and (not isDiscard or self.player:canDiscard(who, trick:getId()))  then
					indulgence = trick:getId()
				elseif not trick:isKindOf("Disaster") and (not isDiscard or self.player:canDiscard(who, trick:getId())) then
					supply_shortage = trick:getId()
				end
			end

			if self:hasWizard(self.enemies) and lightning then
				return lightning
			end

			if indulgence and supply_shortage then
				if who:getHp() < who:getHandcardNum() then
					return indulgence
				else
					return supply_shortage
				end
			end

			if indulgence or supply_shortage then
				return indulgence or supply_shortage
			end
		end

		if flags:match("e") then
			if who:getArmor() and self:evaluateArmor(who:getArmor(), who) < -5 and (not isDiscard or self.player:canDiscard(who, who:getArmor():getEffectiveId()))
				and not table.contains(disable_list, who:getArmor():getEffectiveId()) then
				return who:getArmor():getEffectiveId()
			end
			if who:hasShownSkills(sgs.lose_equip_skill) and self:isWeak(who) then
				if who:getWeapon() and (not isDiscard or self.player:canDiscard(who, who:getWeapon():getEffectiveId())) and not table.contains(disable_list, who:getWeapon():getEffectiveId()) then
					return who:getWeapon():getEffectiveId()
				end
				if who:getOffensiveHorse() and (not isDiscard or self.player:canDiscard(who, who:getOffensiveHorse():getEffectiveId())) and not table.contains(disable_list, who:getOffensiveHorse():getEffectiveId()) then
					return who:getOffensiveHorse():getEffectiveId()
				end
			end
		end
	else
		if (reason == "hengzheng" or reason == "Guixin") and self.player:getHp() <= 2 then  --归心拿牌方式应该和横征差不多
			local hasweapon = self.player:getWeapon()
			local hasarmor = self.player:getArmor()
			local hasoffhorse = self.player:getOffensiveHorse()
			local hasdefhorse = self.player:getDefensiveHorse()
			for _, id in sgs.qlist(self.player:getHandPile()) do
				if sgs.Sanguosha:getCard(id):isKindOf("Weapon") then hasweapon = true end
				if sgs.Sanguosha:getCard(id):isKindOf("Armor") then hasarmor = true end
				if sgs.Sanguosha:getCard(id):isKindOf("OffensiveHorse") then hasoffhorse = true end
				if sgs.Sanguosha:getCard(id):isKindOf("DefensiveHorse") then hasdefhorse = true end
			end
			if hasweapon and who:getWeapon() then table.insert(disable_list, who:getWeapon():getEffectiveId()) end
			if hasarmor and who:getArmor() then table.insert(disable_list, who:getArmor():getEffectiveId()) end
			if hasoffhorse and who:getOffensiveHorse() then table.insert(disable_list, who:getOffensiveHorse():getEffectiveId()) end
			if hasdefhorse and who:getDefensiveHorse() then table.insert(disable_list, who:getDefensiveHorse():getEffectiveId()) end
			if #disable_list >= who:getEquips():length() + who:getHandcardNum() then
				disable_list = {}
			end
		end

		local dangerous = self:getDangerousCard(who)
		if flags:match("e") and dangerous and (not isDiscard or self.player:canDiscard(who, dangerous)) and not table.contains(disable_list, dangerous) then return dangerous end
		if flags:match("e") and who:getTreasure() and (who:getPile("wooden_ox"):length() > 1 or who:hasTreasure("JadeSeal")) and (not isDiscard or self.player:canDiscard(who, who:getTreasure():getId()))
			and not table.contains(disable_list, who:getTreasure():getId()) then
			return who:getTreasure():getId()
		end
		if flags:match("e") and who:hasArmorEffect("EightDiagram") and not self:needToThrowArmor(who) and (not isDiscard or self.player:canDiscard(who, who:getArmor():getId()))
			and not table.contains(disable_list, who:getArmor():getEffectiveId()) then
			return who:getArmor():getId()
			end
		local willRenxin = false
		for _,p in ipairs(self:getFriendsNoself(who)) do
			if p:getHp() <= 2 then willRenxin = who:hasShownSkill("Renxin") break end
		end
		if flags:match("e") and (who:hasShownSkills("jijiu|beige|weimu|qingcheng|jijiu_HuaTuo_LB|Mingce") or willRenxin) and not self:doNotDiscard(who, "e", false, 1, reason) then
			if who:getDefensiveHorse() and (not isDiscard or self.player:canDiscard(who, who:getDefensiveHorse():getEffectiveId())) and not table.contains(disable_list, who:getDefensiveHorse():getEffectiveId()) then
				return who:getDefensiveHorse():getEffectiveId()
			end
			if who:getArmor() and (not isDiscard or self.player:canDiscard(who, who:getArmor():getEffectiveId())) and not table.contains(disable_list, who:getArmor():getEffectiveId()) then
				return who:getArmor():getEffectiveId()
			end
			if who:getOffensiveHorse() and (not who:hasShownSkills("jijiu|jijiu_HuaTuo_LB") or who:getOffensiveHorse():isRed()) and (not isDiscard or self.player:canDiscard(who, who:getOffensiveHorse():getEffectiveId()))
				and not table.contains(disable_list, who:getOffensiveHorse():getEffectiveId()) then
				return who:getOffensiveHorse():getEffectiveId()
			end
			if who:getWeapon() and (not who:hasShownSkills("jijiu|jijiu_HuaTuo_LB") or who:getWeapon():isRed()) and (not isDiscard or self.player:canDiscard(who, who:getWeapon():getEffectiveId()))
				and not table.contains(disable_list, who:getWeapon():getEffectiveId()) then
				return who:getWeapon():getEffectiveId()
			end
		end
		if flags:match("e") then
			local valuable = self:getValuableCard(who)
			if valuable and (not isDiscard or self.player:canDiscard(who, valuable)) and not table.contains(disable_list, valuable) then
				return valuable
			end
		end
		if flags:match("h") and (not isDiscard or self.player:canDiscard(who, "h")) then
			if who:hasShownSkills("jijiu|qingnang|qiaobian|jieyin|beige|jijiu_HuaTuo_LB")
				and not who:isKongcheng() and who:getHandcardNum() <= 2 and not self:doNotDiscard(who, "h", false, 1, reason) then
				return self:getCardRandomly(who, "h", disable_list)
			end
			if who:getHp() == 1 and not self:needKongcheng(who)
				and not who:isKongcheng() and who:getHandcardNum() <= 2 and not self:doNotDiscard(who, "h", false, 1, reason) then
				return self:getCardRandomly(who, "h", disable_list)
			end
			local cards = sgs.QList2Table(who:getHandcards())
			if #cards <= 2 and not self:doNotDiscard(who, "h", false, 1, reason) then
				for _, cc in ipairs(cards) do
					if sgs.cardIsVisible(cc, who, self.player) and (cc:isKindOf("Peach") or cc:isKindOf("Analeptic")) then
						return self:getCardRandomly(who, "h", disable_list)
					end
				end
			end
		end

		if flags:match("j") then
			local tricks = who:getCards("j")
			local lightning
			for _, trick in sgs.qlist(tricks) do
				if table.contains(disable_list, trick:getEffectiveId()) then
					continue
				else
					if trick:isKindOf("Lightning") and (not isDiscard or self.player:canDiscard(who, trick:getId())) then
						lightning = trick:getId()
					end
				end
			end
			if self:hasWizard(self.enemies, true) and lightning then
				return lightning
			end
		end

		if flags:match("h") and not self:doNotDiscard(who, "h") then
			if (who:getHandcardNum() == 1 and sgs.getDefenseSlash(who, self) < 3 and who:getHp() <= 2) or who:hasShownSkills(sgs.cardneed_skill) then
				return self:getCardRandomly(who, "h", disable_list)
			end
		end

		if flags:match("e") and not self:doNotDiscard(who, "e") then
			if who:getDefensiveHorse() and (not isDiscard or self.player:canDiscard(who, who:getDefensiveHorse():getEffectiveId())) and not table.contains(disable_list, who:getDefensiveHorse():getEffectiveId()) then
				return who:getDefensiveHorse():getEffectiveId()
			end
			if who:getArmor() and not self:needToThrowArmor(who) and (not isDiscard or self.player:canDiscard(who, who:getArmor():getEffectiveId())) and not table.contains(disable_list, who:getArmor():getEffectiveId()) then
				return who:getArmor():getEffectiveId()
			end
			if who:getOffensiveHorse() and (not isDiscard or self.player:canDiscard(who, who:getOffensiveHorse():getEffectiveId())) and not table.contains(disable_list, who:getOffensiveHorse():getEffectiveId()) then
				return who:getOffensiveHorse():getEffectiveId()
			end
			if who:getWeapon() and (not isDiscard or self.player:canDiscard(who, who:getWeapon():getEffectiveId())) and not table.contains(disable_list, who:getWeapon():getEffectiveId()) then
				return who:getWeapon():getEffectiveId()
			end
			if who:getTreasure() and (not isDiscard or self.player:canDiscard(who, who:getTreasure():getEffectiveId())) and not table.contains(disable_list, who:getTreasure():getEffectiveId()) then
				return who:getTreasure():getEffectiveId()
			end
		end

		if flags:match("h") then
			if (not who:isKongcheng() and who:getHandcardNum() <= 2) and not self:doNotDiscard(who, "h", false, 1, reason) then
				return self:getCardRandomly(who, "h", disable_list)
			end
		end
	end
	local cards = who:getCards(flags)

	for _, c in sgs.qlist(who:getCards(flags)) do
		if table.contains(disable_list, c:getEffectiveId()) then cards:removeOne(c) end
		if isDiscard and not self.player:canDiscard(who, c:getEffectiveId()) then
			cards:removeOne(c)
		end
	end
	if cards:length() > 0 and not reason:match("dummy") then
		local r = math.random(0, cards:length() - 1)
		return cards:at(r):getEffectiveId()
	else
		return -1
	end
end
function SmartAI:evaluateWeapon(card, player, target)						--急救、奇袭、暗箭、咆哮
	player = player or self.player
	local deltaSelfThreat, inAttackRange = 0
	local currentRange
	local enemies = target and { target } or self:getEnemies(player)
	if not card then self.room:writeToConsole(debug.traceback()) return -1
	else
		currentRange = sgs.weapon_range[card:getClassName()] or 0
	end

	local callback = sgs.ai_weapon_value[card:objectName()]
	local callback2 = sgs.ai_slash_weaponfilter[card:objectName()]

	for _, enemy in ipairs(enemies) do
		if player:distanceTo(enemy) <= currentRange then
			inAttackRange = true
			local def = sgs.getDefenseSlash(enemy, self) / 2
			if def < 0 then def = 6 - def
			elseif def <= 1 then def = 6
			else def = 6 / def
			end
			deltaSelfThreat = deltaSelfThreat + def
			if type(callback) == "function" then deltaSelfThreat = deltaSelfThreat + (callback(self, enemy, player) or 0) end
			if type(callback2) == "function" and callback2(self, enemy, player) then deltaSelfThreat = deltaSelfThreat + 1 end
		end
	end


	if card:isKindOf("Crossbow") and not player:hasShownSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") and inAttackRange then
		local slash_num = player:objectName() == self.player:objectName() and self:getCardsNum("Slash") or getCardsNum("Slash", player, self.player)
		local analeptic_num = player:objectName() == self.player:objectName() and self:getCardsNum("Analeptic") or getCardsNum("Analeptic", player, self.player)
		local peach_num = player:objectName() == self.player:objectName() and self:getCardsNum("Peach") or getCardsNum("Peach", player, self.player)

		deltaSelfThreat = deltaSelfThreat + slash_num * 3 - 2
		if player:hasShownSkill("kurou") then deltaSelfThreat = deltaSelfThreat + peach_num + analeptic_num + self.player:getHp() end
		if player:getWeapon() and not self:hasCrossbowEffect(player) and not player:canSlashWithoutCrossbow() and slash_num > 0 then
			for _, enemy in ipairs(enemies) do
				if player:distanceTo(enemy) <= currentRange
					and (sgs.card_lack[enemy:objectName()]["Jink"] == 1 or slash_num >= enemy:getHp()) then
					deltaSelfThreat = deltaSelfThreat + 10
				end
			end
		end
	end

	if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") and card:isRed() then deltaSelfThreat = deltaSelfThreat + 0.5 end
	if player:hasShownSkills("qixi|guidao|qixi_GanNing_LB") and card:isBlack() then deltaSelfThreat = deltaSelfThreat + 0.5 end
	
	if player:hasShownSkill("Anjian") and currentRange >= 2 then
		for _, enemy in ipairs(enemies) do
			if not enemy:inMyAttackRange(player) and (sgs.card_lack[enemy:objectName()]["Jink"] == 1) then
				deltaSelfThreat = deltaSelfThreat + 1
			end
		end
	end

	return deltaSelfThreat, inAttackRange
end
function SmartAI:evaluateArmor(card, player)								--急救、奇袭
	player = player or self.player
	local ecard = card or player:getArmor()
	if not ecard then return 0 end

	local value = 0
	if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") and ecard:isRed() then value = value + 0.5 end
	if player:hasShownSkills("qixi|guidao|qixi_GanNing_LB") and ecard:isBlack() then value = value + 0.5 end
	for _, askill in sgs.qlist(player:getVisibleSkillList()) do
		local callback = sgs.ai_armor_value[askill:objectName()]
		if type(callback) == "function" then
			return value + (callback(ecard, player, self) or 0)
		end
	end
	local callback = sgs.ai_armor_value[ecard:objectName()]
	if type(callback) == "function" then
		return value + (callback(player, self) or 0)
	end
	return value + 0.5
end
function SmartAI:findPlayerToDiscard(flags, include_self, isDiscard, players, return_table)	--急救、仁心、克己、明策
	local player_table = {}
	if isDiscard == nil then isDiscard = true end
	local friends, enemies = {}, {}
	if not players then
		friends = include_self and self.friends or self.friends_noself
		enemies = self.enemies
	else
		for _, player in sgs.qlist(players) do
			if self:isFriend(player) and (include_self or player:objectName() ~= self.player:objectName()) then table.insert(friends, player)
			elseif self:isEnemy(player) then table.insert(enemies, player) end
		end
	end
	flags = flags or "he"

	if next(enemies) then self:sort(enemies, "defense") end  --不加这个if可能导致enemies为空时强行排序（？）
	if flags:match("e") then
		for _, enemy in ipairs(enemies) do
			if self.player:canDiscard(enemy, "e") then
				local dangerous = self:getDangerousCard(enemy)
				if dangerous and (not isDiscard or self.player:canDiscard(enemy, dangerous)) then
					table.insert(player_table, enemy)
				end
			end
		end
		for _, enemy in ipairs(enemies) do
			if enemy:hasArmorEffect("EightDiagram") and not self:needToThrowArmor(enemy) and self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId()) then
				table.insert(player_table, enemy)
			end
		end
	end

	if flags:match("j") then
		for _, friend in ipairs(friends) do
			if ((friend:containsTrick("indulgence") and not friend:hasShownSkills("keji|keji_LyuMeng_LB")) or friend:containsTrick("supply_shortage"))
				and not (friend:hasShownSkill("qiaobian") and not friend:isKongcheng())
				and (not isDiscard or self.player:canDiscard(friend, "j")) then
				table.insert(player_table, friend)
			end
		end
		for _, friend in ipairs(friends) do
			if friend:containsTrick("lightning") and self:hasWizard(enemies, true) and (not isDiscard or self.player:canDiscard(friend, "j")) then table.insert(player_table, friend) end
		end
		for _, enemy in ipairs(enemies) do
			if enemy:containsTrick("lightning") and self:hasWizard(enemies, true) and (not isDiscard or self.player:canDiscard(enemy, "j")) then table.insert(player_table, enemy) end
		end
	end

	if flags:match("e") then
		for _, friend in ipairs(friends) do
			if self:needToThrowArmor(friend) and (not isDiscard or self.player:canDiscard(friend, friend:getArmor():getEffectiveId())) then
				table.insert(player_table, friend)
			end
		end
		for _, enemy in ipairs(enemies) do
			if self.player:canDiscard(enemy, "e") then
				local valuable = self:getValuableCard(enemy)
				if valuable and (not isDiscard or self.player:canDiscard(enemy, valuable)) then
					table.insert(player_table, enemy)
				end
			end
		end
		local willRenxin
		for _, enemy in ipairs(enemies) do
			willRenxin = false
			for _,p in ipairs(self:getFriendsNoself(enemy)) do
				if p:getHp() <= 2 then willRenxin = enemy:hasShownSkill("Renxin") break end
			end
			if (enemy:hasShownSkills("jijiu|beige|weimu|qingcheng|jijiu_HuaTuo_LB|Mingce") or willRenxin) and not self:doNotDiscard(enemy, "e") then
				if enemy:getDefensiveHorse() and (not isDiscard or self.player:canDiscard(enemy, enemy:getDefensiveHorse():getEffectiveId())) then table.insert(player_table, enemy) end
				if enemy:getArmor() and not self:needToThrowArmor(enemy) and (not isDiscard or self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId())) then table.insert(player_table, enemy) end
				if enemy:getOffensiveHorse() and (not enemy:hasShownSkills("jijiu|jijiu_HuaTuo_LB") or enemy:getOffensiveHorse():isRed()) and (not isDiscard or self.player:canDiscard(enemy, enemy:getOffensiveHorse():getEffectiveId())) then
					table.insert(player_table, enemy)
				end
				if enemy:getWeapon() and (not enemy:hasShownSkills("jijiu|jijiu_HuaTuo_LB") or enemy:getWeapon():isRed()) and (not isDiscard or self.player:canDiscard(enemy, enemy:getWeapon():getEffectiveId())) then
					table.insert(player_table, enemy)
				end
			end
		end
	end

	if flags:match("h") then
		for _, enemy in ipairs(enemies) do
			local cards = sgs.QList2Table(enemy:getHandcards())
			if #cards <= 2 and not enemy:isKongcheng() and not (enemy:hasShownSkill("tuntian") and enemy:getPhase() == sgs.Player_NotActive) then
				for _, cc in ipairs(cards) do
					if sgs.cardIsVisible(cc, enemy, self.player) and (cc:isKindOf("Peach") or cc:isKindOf("Analeptic")) and (not isDiscard or self.player:canDiscard(enemy, cc:getId())) then
						table.insert(player_table, enemy)
					end
				end
			end
		end
	end

	if flags:match("e") then
		for _, enemy in ipairs(enemies) do
			if enemy:hasEquip() and not self:doNotDiscard(enemy, "e") and (not isDiscard or self.player:canDiscard(enemy, "e")) then
				table.insert(player_table, enemy)
			end
		end
	end

	if flags:match("h") then
		self:sort(enemies, "handcard")
		for _, enemy in ipairs(enemies) do
			if (not isDiscard or self.player:canDiscard(enemy, "h")) and not self:doNotDiscard(enemy, "h") then
				table.insert(player_table, enemy)
			end
		end
	end

	if flags:match("h") then
		local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
		if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, zhugeliang) > 0
			and zhugeliang:getHp() <= 2 and (not isDiscard or self.player:canDiscard(zhugeliang, "h")) then
			table.insert(player_table, zhugeliang)
		end
	end
	if return_table then return player_table
	else
		if #player_table == 0 then return nil else return player_table[1] end
	end
end
function SmartAI:getGuixinValue(player)										--急救、流离
	if player:isAllNude() then return 0 end
	local card_id = self:askForCardChosen(player, "hej", "dummy")
	if self:isEnemy(player) then
		for _, card in sgs.qlist(player:getJudgingArea()) do
			if card:getEffectiveId() == card_id then
				if card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies, true) then return 0.8
					elseif self:hasWizard(self.friends, true) then return 0.4
					else return 0.5 * (#self.friends) / (#self.friends + #self.enemies) end
				else
					return -0.2
				end
			end
		end
		for i = 0, 3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId() == card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0 end
				local value = 0
				if self:getDangerousCard(player) == card_id then value = 1.5
				elseif self:getValuableCard(player) == card_id then value = 1.1
				elseif i == 1 then value = 1
				elseif i == 2 then value = 0.8
				elseif i == 0 then value = 0.7
				elseif i == 3 then value = 0.5
				end
				if player:hasShownSkills(sgs.lose_equip_skill) or self:doNotDiscard(player, "e", true) then value = value - 0.2 end
				return value
			end
		end
		if self:needKongcheng(player) and player:getHandcardNum() == 1 then return 0 end
		if not self:hasLoseHandcardEffective() then return 0.1
		else
			local index = player:hasShownSkills("jijiu|qingnang|leiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|tianxiang|lijian|liuli_DaQiao_LB|jijiu_HuaTuo_LB") and 0.7 or 0.6
			local value = 0.2 + index / (player:getHandcardNum() + 1)
			if self:doNotDiscard(player, "h", true) then value = value - 0.1 end
			return value
		end
	elseif self:isFriend(player) then
		for _, card in sgs.qlist(player:getJudgingArea()) do
			if card:getEffectiveId() == card_id then
				if card:isKindOf("Lightning") then
					if self:hasWizard(self.enemies, true) then return 1
					elseif self:hasWizard(self.friends, true) then return 0.8
					else return 0.4 * (#self.enemies) / (#self.friends + #self.enemies) end
				else
					return 1.5
				end
			end
		end
		for i = 0, 3 do
			local card = player:getEquip(i)
			if card and card:getEffectiveId() == card_id then
				if card:isKindOf("Armor") and self:needToThrowArmor(player) then return 0.9 end
				local value = 0
				if i == 1 then value = 0.1
				elseif i == 2 then value = 0.2
				elseif i == 0 then value = 0.25
				elseif i == 3 then value = 0.25
				end
				if player:hasShownSkills(sgs.lose_equip_skill) then value = value + 0.1 end
				if player:hasShownSkill("tuntian") then value = value + 0.1 end
				return value
			end
		end
		if self:needKongcheng(player, true) and player:getHandcardNum() == 1 then return 0.5
		elseif self:needKongcheng(player) and player:getHandcardNum() == 1 then return 0.3 end
		if not self:hasLoseHandcardEffective() then return 0.2
		else
			local index = player:hasShownSkills("jijiu|qingnang|leiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|tianxiang|lijian|liuli_DaQiao_LB|jijiu_HuaTuo_LB") and 0.5 or 0.4
			local value = 0.2 - index / (player:getHandcardNum() + 1)
			if player:hasShownSkill("tuntian") then value = value + 0.1 end
			return value
		end
	end
	return 0.3
end
function SmartAI:getLeastHandcardNum(player)								--连营
	player = player or self.player
	local least = 0
	if player:hasShownSkill("Lianying") and least < 1 then least = 1 end
	local jwfy = sgs.findPlayerByShownSkillName("shoucheng")
	if least < 1 and jwfy and self:isFriend(jwfy, player) then least = 1 end
	return least
end
function SmartAI:getDynamicUsePriority(card)								--奇袭、攻心、国色、潜心
	if not card then return 0 end
	if card:hasFlag("AIGlobal_KillOff") then return 15 end
	if self.Gongxin_Use_Immediately and type(self.Gongxin_Use_Immediately) == "string" then	--攻心（立刻使用摸牌性卡牌或技能）
		if (card:getClassName() == self.Gongxin_Use_Immediately) or (card:isKindOf("LuaSkillCard") and (card:objectName() == self.Gongxin_Use_Immediately)) then
			--self.Gongxin_Use_Immediately = nil  --排序结束前不能清空
			return 13
		end
	end

	if card:isKindOf("Slash") then
		for _, p in ipairs(self.friends) do
			if p:hasShownSkill("yongjue") and self.player:isFriendWith(p) then return 12 end
		end
		--if self.player:hasSkill("Qianxin") and self.player:isWounded() and not self.player:hasSkill("jueqing") then return 0 end
		if self.player:hasSkill("Qianxin") and self.player:isWounded() then return 0 end
	elseif card:isKindOf("AmazingGrace") then
		local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
		if zhugeliang and self:isEnemy(zhugeliang) and zhugeliang:isKongcheng() then
			return math.max(sgs.ai_use_priority.Slash, sgs.ai_use_priority.Duel) + 0.1
		end
	elseif card:isKindOf("Peach") and self.player:hasSkill("kuanggu") then return 1.01
	elseif card:isKindOf("DelayedTrick") and #card:getSkillName() > 0 then
		return (sgs.ai_use_priority[card:getClassName()] or 0.01) - 0.01
	elseif card:isKindOf("Duel") then
		if self:hasCrossbowEffect()
			or self.player:canSlashWithoutCrossbow()
			or sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.cloneCard("slash")) > 0
			or self.player:hasUsed("FenxunCard") then
			return sgs.ai_use_priority.Slash - 0.1
		end
	elseif card:isKindOf("AwaitExhausted") and self.player:hasSkills("guose|duanliang|GuoseLB") then
		return 0
	end

	local value = self:getUsePriority(card) or 0
	if card:getTypeId() == sgs.Card_TypeEquip then
		if self.player:hasSkills("xiaoji+qixi|xiaoji+qixi_GanNing_LB") and self:getSameEquip(card) and self:getSameEquip(card):isBlack() then return 3.3 end
		if self.player:hasSkills(sgs.lose_equip_skill) then value = value + 12 end
		if card:isKindOf("Weapon") and self.player:getPhase() == sgs.Player_Play and #self.enemies > 0 then
			self:sort(self.enemies)
			local enemy = self.enemies[1]
			local v, inAttackRange = self:evaluateWeapon(card, self.player, enemy) / 20
			value = value + string.format("%3.2f", v)
			if inAttackRange then value = value + 0.5 end
		end
	end

	if card:isKindOf("AmazingGrace") then
		local dynamic_value = 10
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			dynamic_value = dynamic_value - 1
			if self:isEnemy(player) then dynamic_value = dynamic_value - ((player:getHandcardNum() + player:getHp()) / player:getHp()) * dynamic_value
			else dynamic_value = dynamic_value + ((player:getHandcardNum() + player:getHp()) / player:getHp()) * dynamic_value
			end
		end
		value = value + dynamic_value
	elseif card:isKindOf("ArcheryAttack") and self.player:hasSkill("luanji") then
		value = value + 5.5
	elseif card:isKindOf("Duel") and self.player:hasSkill("shuangxiong") then
		value = value + 6.3
	elseif card:isKindOf("WendaoCard") and self.player:hasShownSkills("wendao+hongfa") and not self.player:getPile("heavenly_army"):isEmpty()
		and self.player:getArmor() and self.player:getArmor():objectName() == "PeaceSpell" then
		value = value + 8
	end

	return value
end
function SmartAI:getOverflow(player, getMaxCards)							--克己
	player = player or self.player
	local MaxCards = player:getMaxCards()
	if player:hasShownSkill("qiaobian") and not player:hasFlag("AI_ConsideringQiaobianSkipDiscard") then
		MaxCards = math.max(self.player:getHandcardNum() - 1, MaxCards)
		player:setFlags("-AI_ConsideringQiaobianSkipDiscard")
	end
	if player:hasShownSkills("keji|keji_LyuMeng_LB") and not player:hasFlag("KejiSlashInPlayPhase") then MaxCards = self.player:getHandcardNum() end
	if getMaxCards then return MaxCards end
	return player:getHandcardNum() - MaxCards
end
function SmartAI:willSkipPlayPhase(player, NotContains_Null)				--克己
	local player = player or self.player

	if player:isSkipped(sgs.Player_Play) then return true end
	if player:hasFlag("willSkipPlayPhase") then return true end

	local friend_null = 0
	local friend_snatch_dismantlement = 0
	local cp = self.room:getCurrent()
	if cp and self.player:objectName() == cp:objectName() and self.player:objectName() ~= player:objectName() and self:isFriend(player) then
		for _, hcard in sgs.qlist(self.player:getCards("he")) do
			if (isCard("Snatch", hcard, self.player) and self.player:distanceTo(player) == 1) or isCard("Dismantlement", hcard, self.player) then
				local trick = sgs.cloneCard(hcard:objectName(), hcard:getSuit(), hcard:getNumber())
				if self:hasTrickEffective(trick, player) then friend_snatch_dismantlement = friend_snatch_dismantlement + 1 end
			end
		end
	end
	if not NotContains_Null then
		for _, p in sgs.qlist(self.room:getAllPlayers()) do
			if self:isFriend(p, player) then friend_null = friend_null + getCardsNum("Nullification", p, self.player) end
			if self:isEnemy(p, player) then friend_null = friend_null - getCardsNum("Nullification", p, self.player) end
		end
	end
	if player:containsTrick("indulgence") then
		if self.player:hasSkills("keji|keji_LyuMeng_LB") or (player:hasShownSkill("qiaobian") and not player:isKongcheng()) then return false end
		if friend_null + friend_snatch_dismantlement > 1 then return false end
		return true
	end
	return false
end
function SmartAI:askForNullification(trick, from, to, positive)				--制蛮、突袭、仁德、当先、天妒、狂风、武魂、燃殇、无谋
	if self.player:isDead() then return nil end
	if trick:isKindOf("SavageAssault") and self:isFriend(to) and positive then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		if menghuo and self:isFriend(to, menghuo) and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return nil end
	end
	if from and self:isFriend(to, from) and self:isFriend(to) and positive and from:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return nil end
	local nullcards = self.player:getCards("Nullification")
	local null_num = self:getCardsNum("Nullification")
	local null_card = self:getCardId("Nullification")
	local targets = sgs.SPlayerList()
	local players = self.room:getTag("targets" .. trick:toString()):toList()
	local names = {}
	for _, q in sgs.qlist(players) do
		targets:append(q:toPlayer())
	end
	if null_num > 1 then
		for _, card in sgs.qlist(nullcards) do
			if not card:isKindOf("HegNullification") then
				null_card = card:toString()
				break
			end
		end
	end
	local keep				--要为被乐的友方保留无懈
	if null_num == 1 then
		local only = true
		for _, p in ipairs(self.friends_noself) do
			if getKnownCard(p, self.player, "Nullification", nil, "he") > 0 then
				only = false
				break
			end
		end
		if only then
			for _, p in ipairs(self.friends) do
				if p:containsTrick("indulgence") and not p:hasShownSkills("guanxing|yizhi|shensu|qiaobian|Dangxian_LiaoHua|Dangxian_GuanSuo") and p:getHandcardNum() >= p:getHp() and not trick:isKindOf("Indulgence") then
					keep = true
					break
				end
			end
		end
	end

	if null_card then null_card = sgs.Card_Parse(null_card) else return nil end
	assert(null_card)
	if self.player:isLocked(null_card) then return nil end
	if (from and from:isDead()) or (to and to:isDead()) then return nil end

	local jgyueying = sgs.findPlayerByShownSkillName("jgjingmiao")
	if jgyueying and self:isEnemy(jgyueying) and self.player:getHp() == 1 then return nil end
    if self.player:hasShownSkill("Wumou") then
        if self.player:getMark("@wrath") == 0 and (self:isWeak() or self.player:isLord()) then return nil end
        if to:objectName() == self.player:objectName() and not self:isWeak() and (trick:isKindOf("AOE") or trick:isKindOf("Duel") or trick:isKindOf("FireAttack") or trick:isKindOf("Drowning")) then
            return
        end
    end

	if trick:isKindOf("FireAttack") then
		if to:isKongcheng() or from:isKongcheng() then return nil end
		if self.player:objectName() == from:objectName() and self.player:getHandcardNum() == 1 and self.player:handCards():first() == null_card:getId() then return nil end
	end

	if ("snatch|dismantlement"):match(trick:objectName()) and to:isAllNude() then return nil end

	if from then
		if (trick:isKindOf("Duel") or trick:isKindOf("FireAttack") or trick:isKindOf("AOE")) and self:getDamagedEffects(to, from) and self:isFriend(to) then
			return nil
		end
		if (trick:isKindOf("Duel") or trick:isKindOf("AOE")) and not self:damageIsEffective(to, sgs.DamageStruct_Normal) then return nil end
		if trick:isKindOf("FireAttack") and not self:damageIsEffective(to, sgs.DamageStruct_Fire) then return nil end
	end
	if (trick:isKindOf("Duel") or trick:isKindOf("FireAttack") or trick:isKindOf("AOE")) and self:needToLoseHp(to, from) and self:isFriend(to) then
		return nil
	end

	local callback = sgs.ai_nullification[trick:getClassName()]
	if type(callback) == "function" then
		local shouldUse, single = callback(self, trick, from, to, positive, keep)
		if self.room:getTag("NullifyingTimes"):toInt() > 0 then single = true end
		if shouldUse and not single then
			local heg_null_card = self:getCard("HegNullification")
			if heg_null_card then null_card = heg_null_card end
		end
		return shouldUse and null_card
	end

	if positive then

		if from and (trick:isKindOf("FireAttack") or trick:isKindOf("Duel") or trick:isKindOf("ArcheryAttack") or trick:isKindOf("SavageAssault")) and (self:needDeath(to) or self:cantbeHurt(to, from)) then  --武魂（needDeath）
			if self:isFriend(from) then return null_card end
			return
		end

		local isEnemyFrom = from and self:isEnemy(from)

		if isEnemyFrom and self.player:hasSkill("kongcheng") and self.player:getHandcardNum() == 1 and self.player:isLastHandCard(null_card) and trick:isKindOf("SingleTargetTrick") then
			return null_card
		elseif trick:isKindOf("ExNihilo") then
			if isEnemyFrom and self:evaluateKingdom(from) ~= "unknown" and (self:isWeak(from) or from:hasShownSkills(sgs.cardneed_skill)) then
				return null_card
			end
		elseif trick:isKindOf("Snatch") then
			if (to:containsTrick("indulgence") or to:containsTrick("supply_shortage")) and self:isFriend(to) and to:isNude() then return nil end
			if isEnemyFrom and self:isFriend(to, from) and to:getCards("j"):length() > 0 then
				return null_card
			elseif from and self:isFriend(from) and self:isFriend(to) and self:askForCardChosen(to, "ej", "dummyreason") then return false
			elseif self:isFriend(to) then return null_card
			end
		elseif trick:isKindOf("Dismantlement") then
			if (to:containsTrick("indulgence") or to:containsTrick("supply_shortage")) and self:isFriend(to) and to:isNude() then return nil end
			if isEnemyFrom and self:isFriend(to, from) and to:getCards("j"):length() > 0 then
				return null_card
			end
			if from and self:isFriend(from) and self:isFriend(to) and self:askForCardChosen(to, "ej", "dummyreason") then return false end
			if self:isFriend(to) then
				if self:getDangerousCard(to) or self:getValuableCard(to) then return null_card end
				if to:getHandcardNum() == 1 and not self:needKongcheng(to) then
					if (getKnownCard(to, self.player, "TrickCard", false) == 1 or getKnownCard(to, self.player, "EquipCard", false) == 1 or getKnownCard(to, self.player, "Slash", false) == 1) then
						return nil
					end
					return null_card
				end
			end
		elseif trick:isKindOf("IronChain") then
			if isEnemyFrom and self:isFriend(to) then return to:hasArmorEffect("Vine") and null_card end
		elseif trick:isKindOf("Duel") then
			if trick:getSkillName() == "lijian" then
				if self:isFriend(to) and (self:isWeak(to) or null_num > 1 or self:getOverflow() or not self:isWeak()) then return null_card end
				return
			end
			if isEnemyFrom and self:isFriend(to) then
				if self:isWeak(to) then return null_card
				elseif self.player:objectName() == to:objectName() then
					if self:getCardsNum("Slash") > getCardsNum("Slash", from, self.player) then return
					elseif self.player:hasSkills(sgs.masochism_skill) and
						(self.player:getHp() > 1 or self:getCardsNum("Peach") > 0 or self:getCardsNum("Analeptic") > 0) then
						return nil
					elseif self:getCardsNum("Slash") == 0 then
						return null_card
					end
				end
			end
		elseif trick:isKindOf("FireAttack") then
			if to:isChained() then return not self:isGoodChainTarget(to, from, nil, nil, trick) and null_card end
			if isEnemyFrom and self:isFriend(to) then
				if from:getHandcardNum() > 2 or self:isWeak(to) or to:hasArmorEffect("Vine") or to:getMark("@gale") > 0 or to:getMark("@gale_ShenZhuGeLiang") > 0 or (to:hasShownSkill("Ranshang") and not to:hasShownSkill("hongfa")) then
					return null_card
				end
			end
		elseif trick:isKindOf("Indulgence") then
			if self:isFriend(to) and not to:isSkipped(sgs.Player_Play) then
				if (to:hasShownSkill("guanxing") or to:hasShownSkill("yizhi") and to:inDeputySkills("yizhi"))
					and (global_room:alivePlayerCount() > 4 or to:hasShownSkill("yizhi")) then return end
				if to:getHp() - to:getHandcardNum() >= 2 then return nil end
				if to:hasShownSkill("tuxi") and to:getHp() > 2 then return nil end
				if to:hasShownSkill("TuxiLB") and to:getHp() > 2 and to:getHandcardNum() <= 2 then return nil end
				if to:hasShownSkill("qiaobian") and not to:isKongcheng() then return nil end
				if (to:containsTrick("supply_shortage") or self:willSkipDrawPhase(to)) and null_num <= 1 and self:getOverflow(to) < -1 then return nil end
				return null_card
			end
		elseif trick:isKindOf("SupplyShortage") then
			if self:isFriend(to) and not to:isSkipped(sgs.Player_Draw) then
				if (to:hasShownSkill("guanxing") or to:hasShownSkill("yizhi") and to:inDeputySkills("yizhi"))
					and (global_room:alivePlayerCount() > 4 or to:hasShownSkill("yizhi")) then return end
				if to:hasShownSkills("guidao|tiandu|tiandu_GuoJia_LB") then return nil end
				if to:hasShownSkill("qiaobian") and not to:isKongcheng() then return nil end
				if (to:containsTrick("indulgence") or self:willSkipPlayPhase(to)) and null_num <= 1 and self:getOverflow(to) > 1 then return nil end
				return null_card
			end

		elseif trick:isKindOf("ArcheryAttack") then
			if self:isFriend(to) then
				local heg_null_card = self:getCard("HegNullification")
				if heg_null_card then
					for _, friend in ipairs(self.friends) do
						if self:playerGetRound(to) < self:playerGetRound(friend) and (self:aoeIsEffective(trick, to, from) or self:getDamagedEffects(to, from)) then
						else
							return heg_null_card
						end
					end
				end
				if not self:aoeIsEffective(trick, to, from) then return
				elseif self:getDamagedEffects(to, from) then return
				elseif to:objectName() == self.player:objectName() and self:canAvoidAOE(trick) then return
				elseif getKnownCard(to, self.player, "Jink", true, "he") >= 1 and to:getHp() > 1 then return
				elseif not self:isFriendWith(to) and self:playerGetRound(to) < self:playerGetRound(self.player) and self:isWeak() then return
				else
					return null_card
				end
			end
		elseif trick:isKindOf("SavageAssault") then
			if self:isFriend(to) then
				local menghuo
				for _, p in sgs.qlist(self.room:getAlivePlayers()) do
					if p:hasShownSkill("huoshou") then menghuo = p break end
				end
				local heg_null_card = self:getCard("HegNullification")
				if heg_null_card then
					for _, friend in ipairs(self.friends) do
						if self:playerGetRound(to) < self:playerGetRound(friend)
							and (self:aoeIsEffective(trick, to, menghuo or from) or self:getDamagedEffects(to, menghuo or from)) then
						else
							return heg_null_card
						end
					end
				end
				if not self:aoeIsEffective(trick, to, menghuo or from) then return
				elseif self:getDamagedEffects(to, menghuo or from) then return
				elseif to:objectName() == self.player:objectName() and self:canAvoidAOE(trick) then return
				elseif getKnownCard(to, self.player, "Slash", true, "he") >= 1 and to:getHp() > 1 then return
				elseif not self:isFriendWith(to) and self:playerGetRound(to) < self:playerGetRound(self.player) and self:isWeak() then return
				else
					return null_card
				end
			end
		elseif trick:isKindOf("AmazingGrace") then
			if self:isEnemy(to) then
				local NP = self.room:nextPlayer(to)
				if self:isFriend(NP) then
					local ag_ids = self.room:getTag("AmazingGrace"):toStringList()
					local peach_num, exnihilo_num, snatch_num, analeptic_num, crossbow_num = 0, 0, 0, 0, 0
					for _, ag_id in ipairs(ag_ids) do
						local ag_card = sgs.Sanguosha:getCard(ag_id)
						if ag_card:isKindOf("Peach") then peach_num = peach_num + 1 end
						if ag_card:isKindOf("ExNihilo") then exnihilo_num = exnihilo_num + 1 end
						if ag_card:isKindOf("Snatch") then snatch_num = snatch_num + 1 end
						if ag_card:isKindOf("Analeptic") then analeptic_num = analeptic_num + 1 end
						if ag_card:isKindOf("Crossbow") then crossbow_num = crossbow_num + 1 end
					end
					if (peach_num == 1) or (peach_num > 0 and (self:isWeak(to) or self:getOverflow(NP) < 1)) then
						return null_card
					end
					if peach_num == 0 and not self:willSkipPlayPhase(NP) then
						if exnihilo_num > 0 then
							if NP:hasShownSkills("jizhi|rende|zhiheng|RendeLB") then return null_card end
						else
							for _, enemy in ipairs(self.enemies) do
								if snatch_num > 0 and to:distanceTo(enemy) == 1 and
									(self:willSkipPlayPhase(enemy, true) or self:willSkipDrawPhase(enemy, true)) then
									return null_card
								elseif analeptic_num > 0 and (enemy:hasWeapon("Axe") or getCardsNum("Axe", enemy, self.player) > 0) then
									return null_card
								elseif crossbow_num > 0 and getCardsNum("Slash", enemy, self.player) >= 3 then
									local slash = sgs.cloneCard("slash")
									for _, friend in ipairs(self.friends) do
										if enemy:distanceTo(friend) == 1 and self:slashIsEffective(slash, friend, enemy) then
											return null_card
										end
									end
								end
							end
						end
					end
				end
			end
		elseif trick:isKindOf("GodSalvation") then
			if self:isEnemy(to) and self:evaluateKingdom(to) ~= "unknown" and self:isWeak(to) then return null_card end
		end

	else

		if from and from:objectName() == self.player:objectName() then return end

		if (trick:isKindOf("FireAttack") or trick:isKindOf("Duel") or trick:isKindOf("AOE")) and (self:needDeath(to) or self:cantbeHurt(to, from)) then  --武魂（needDeath）
			if isEnemyFrom then return null_card end
		end
		if from and from:objectName() == to:objectName() then
			if self:isFriend(from) then return null_card else return end
		end

		if trick:isKindOf("Duel") then
			if trick:getSkillName() == "lijian" then
				if self:isEnemy(to) and (self:isWeak(to) or null_num > 1 or self:getOverflow() > 0 or not self:isWeak()) then return null_card end
				return
			end
			return from and self:isFriend(from) and not self:isFriend(to) and null_card
		elseif trick:isKindOf("GodSalvation") then
			if self:isFriend(to) and self:isWeak(to) then return null_card end
		elseif trick:isKindOf("AmazingGrace") then
			if self:isFriend(to) then return null_card end
		elseif not (trick:isKindOf("GlobalEffect") or trick:isKindOf("AOE")) then
			if from and self:isFriend(from) and not self:isFriend(to) then
				if ("snatch|dismantlement"):match(trick:objectName()) and to:isNude() then
				elseif trick:isKindOf("FireAttack") and to:isKongcheng() then
				else return null_card end
			end
		end
	end
	return
end
function SmartAI:getAoeValue(card)											--制蛮、滔乱、奸雄、神吕布
	local attacker = self.player
	local good, bad, isEffective_F, isEffective_E = 0, 0, 0, 0

	local current = self.room:getCurrent()
	local wansha = current:hasShownSkill("wansha")
	local peach_num = self:getCardsNum("Peach")
	local null_num = self:getCardsNum("Nullification")
	local punish
	local enemies, kills = 0, 0
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self.player:isFriendWith(p) and self:evaluateKingdom(p) ~= self.player:getKingdom() then enemies = enemies + 1 end
		if self:isFriend(p) then
			if not wansha then peach_num = peach_num + getCardsNum("Peach", p, self.player) end
			null_num = null_num + getCardsNum("Nullification", p, self.player)
		else
			null_num = null_num - getCardsNum("Nullification", p, self.player)
		end
	end
	if card:isVirtualCard() and card:subcardsLength() > 0 then
		for _, subcardid in sgs.qlist(card:getSubcards()) do
			local subcard = sgs.Sanguosha:getCard(subcardid)
			if isCard("Peach", subcard, self.player) then peach_num = peach_num - 1 end
			if isCard("Nullification", subcard, self.player) then null_num = null_num - 1 end
		end
	end

	local zhiman = self.player:hasSkills("Zhiman_MaSu|Zhiman_GuanSuo")
	local zhimanprevent
	if card:isKindOf("SavageAssault") then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		attacker = menghuo or attacker
		if self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhiman = true end  --似乎源码忘记了ShownSkill
		if not self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhimanprevent = true end  --源码忘记判断menghuo是否存在
	end
	
	local function getAoeValueTo(to)
		local value, sj_num = 0, 0
		if card:isKindOf("ArcheryAttack") then sj_num = getCardsNum("Jink", to, self.player) end
		if card:isKindOf("SavageAssault") then sj_num = getCardsNum("Slash", to, self.player) end

		if self:aoeIsEffective(card, to, self.player) then
			local sameKingdom
			if self:isFriend(to) then
				isEffective_F = isEffective_F + 1
				if self.player:isFriendWith(to) or self:evaluateKingdom(to) == self.player:getKingdom() then sameKingdom = true end
			else
				isEffective_E = isEffective_E + 1
			end
			
			local jink = sgs.cloneCard("jink")
			local slash = sgs.cloneCard("slash")
			local isLimited
			if card:isKindOf("ArcheryAttack") and to:isCardLimited(jink, sgs.Card_MethodResponse) then isLimited = true
			elseif card:isKindOf("SavageAssault") and to:isCardLimited(slash, sgs.Card_MethodResponse) then isLimited = true end
			if card:isKindOf("SavageAssault") and sgs.card_lack[to:objectName()]["Slash"] == 1
				or card:isKindOf("ArcheryAttack") and sgs.card_lack[to:objectName()]["Jink"] == 1
				or sj_num < 1 or isLimited then
				--value = -20
				if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
					if self:isFriend(to) and not zhiman then value = -20 end
				elseif card:isKindOf("SavageAssault") then
					if self:isFriend(to) then
						if zhimanprevent then
							value = - 30
						elseif not zhiman then
							value = - 20
						end
					else
						if zhimanprevent and self:isFriend(to, attacker) then
							value = - 30
						else
							value = - 20
						end
					end
				end
			else
				--value = -10
				if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
					if self:isFriend(to) and not zhiman then value = -10 end
				elseif card:isKindOf("SavageAssault") then
					if self:isFriend(to) then
						if zhimanprevent then
							value = - 20
						elseif not zhiman then
							value = - 10
						end
					else
						if zhimanprevent and self:isFriend(to, attacker) then
							value = - 20
						else
							value = - 10
						end
					end
				end
			end
			-- value = value + math.min(50, to:getHp() * 10)

			if self:getDamagedEffects(to, self.player) then value = value + 30 end
			if self:needToLoseHp(to, self.player) then value = value + 20 end

			if card:isKindOf("ArcheryAttack") then
				if to:hasShownSkills("leiji") and (sj_num >= 1 or self:hasEightDiagramEffect(to)) and self:findLeijiTarget(to, 50, self.player) then
					value = value + 20
					if self:hasSuit("spade", true, to) then value = value + 50
					else value = value + to:getHandcardNum() * 10
					end
				elseif self:hasEightDiagramEffect(to) then
					value = value + 5
					if self:getFinalRetrial(to) == 2 then
						value = value - 10
					elseif self:getFinalRetrial(to) == 1 then
						value = value + 10
					end
				end
			end

			if card:isKindOf("ArcheryAttack") and sj_num >= 1 then
				if to:hasShownSkill("xiaoguo") then value = value - 4 end
			elseif card:isKindOf("SavageAssault") and sj_num >= 1 then
				if to:hasShownSkill("xiaoguo") then value = value - 4 end
			end

			if to:getHp() == 1 then
				if sameKingdom then
					if not zhiman then
						if null_num > 0 then null_num = null_num - 1
						elseif getCardsNum("Analeptic", to, self.player) > 0 then
						elseif not wansha and peach_num > 0 then peach_num = peach_num - 1
						elseif wansha and (getCardsNum("Peach", to, self.player) > 0 or self:isFriend(current) and getCardsNum("Peach", to, self.player) > 0) then
						else
							if not punish then
								punish = true
								value = value - self.player:getCardCount(true) * 10
							end
							value = value - to:getCardCount(true) * 10
						end
					end
				else
					if card:isKindOf("SavageAssault") and zhiman and self:isFriend(to) then
					elseif card:isKindOf("SavageAssault") and zhimanprevent and self:isFriend(to, attacker) then
					else
						kills = kills + 1
						if wansha and (sgs.card_lack[to:objectName()]["Peach"] == 1 or getCardsNum("Peach", to, self.player) == 0) then
							value = value - sgs.getReward(to) * 10
						end
					end
				end
			end

			if not sgs.isAnjiang(to) and to:isLord() then value = value - self.room:getLieges(to:getKingdom(), to):length() * 5 end

			if to:getHp() > 1 and to:hasShownSkills("jianxiong|JianxiongLB") then
				value = value + ((card:isVirtualCard() and card:subcardsLength() * 10) or 10)
			end
			if to:getHp() > 1 and to:hasShownSkills("Kuangbao+Shenfen") then
				value = value + math.min(15, to:getMark("@wrath") * 3)
			end

		else
			value = 0
			if to:hasShownSkill("juxiang") and not card:isVirtualCard() then value = value + 10 end
		end

		return value
	end

	if card:isKindOf("SavageAssault") then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		attacker = menghuo or attacker
	end

	for _, p in sgs.qlist(self.room:getAllPlayers()) do
		if p:objectName() == self.player:objectName() then continue end
		if self:isFriend(p) then
			good = good + getAoeValueTo(p)
			if zhiman then
				--if attacker:canGetCard(p, "j") then
				if not p:getJudgingArea():isEmpty() then
					good = good + 10
				--elseif attacker:canGetCard(p, "e") and p:hasShownSkills(sgs.lose_equip_skill) then
				elseif not p:getEquips():isEmpty() and p:hasShownSkills(sgs.lose_equip_skill) then
					good = good + 10
				end
			end
		else
			bad = bad + getAoeValueTo(p)
			if zhimanprevent and self:isFriend(p, attacker) then
				--if attacker:canGetCard(p, "j") then
				if not p:getJudgingArea():isEmpty() then
					bad = bad + 10
				--elseif attacker:canGetCard(p, "e") and p:hasShownSkills(sgs.lose_equip_skill) then
				elseif not p:getEquips():isEmpty() and p:hasShownSkills(sgs.lose_equip_skill) then
					bad = bad + 10
				end
			end
		end
		if self:aoeIsEffective(card, p, self.player) and self:cantbeHurt(p, attacker) then bad = bad + 250 end
		if kills == enemies then return 998 end
	end

	if isEffective_F == 0 and isEffective_E == 0 then
		return attacker:hasShownSkill("jizhi") and 10 or -100
	elseif isEffective_E == 0 then
		return -100
	end

	if attacker:hasShownSkill("jizhi") then good = good + 10 end
	if attacker:hasShownSkills("Kuangbao+Shenfen") then good = good + 6 * isEffective_E end
	if attacker:hasShownSkill("luanji") then good = good + 5 * isEffective_E end
	if attacker:hasShownSkills("Taoluan|TaoluanOL") then good = good + 5 * isEffective_E end

	return good - bad
end
function SmartAI:needRetrial(judge)											--突袭、天妒、神愤		（todo：补充界铁骑、界刚烈）
	local reason = judge.reason
	local who = judge.who
	if reason == "lightning" then
		if who:hasShownSkill("hongyan") then return false end

		if who:hasArmorEffect("SilverLion") and who:getHp() > 1 then return false end

		if who:hasArmorEffect("PeaceSpell") then return false end

		if self:isFriend(who) then
			if who:isChained() and self:isGoodChainTarget(who, self.player, sgs.DamageStruct_Thunder, 3) then return false end
		else
			if who:isChained() and not self:isGoodChainTarget(who, self.player, sgs.DamageStruct_Thunder, 3) then return judge:isGood() end
		end
	elseif reason == "indulgence" then
		if who:isSkipped(sgs.Player_Draw) and who:isKongcheng() then
			if (who:hasShownSkill("Shenfen") and who:getMark("@wrath") >= 6)
				or (who:hasShownSkill("kurou") and who:getHp() >= 3) then
				if self:isFriend(who) then
					return not judge:isGood()
				else
					return judge:isGood()
				end
			end
		end
		if self:isFriend(who) then
			local drawcardnum = self:ImitateResult_DrawNCards(who, who:getVisibleSkillList(true))
			if who:getHp() - who:getHandcardNum() >= drawcardnum and self:getOverflow() < 0 then return false end
			if who:hasShownSkill("tuxi") and who:getHp() > 2 and self:getOverflow() < 0 then return false end
			if who:hasShownSkill("TuxiLB") and who:getHp() > 2 and who:getHandcardNum() <= 2 and self:getOverflow() < 0 then return false end
			return not judge:isGood()
		else
			return judge:isGood()
		end
	elseif reason == "supply_shortage" then
		if self:isFriend(who) then
			if who:hasShownSkills("guidao|tiandu|tiandu_GuoJia_LB") then return false end
			return not judge:isGood()
		else
			return judge:isGood()
		end
	elseif reason == "luoshen" then
		if self:isFriend(who) then
			if who:getHandcardNum() > 30 then return false end
			if self:hasCrossbowEffect(who) or getKnownCard(who, self.player, "Crossbow", false) > 0 then return not judge:isGood() end
			if self:getOverflow(who) > 1 and self.player:getHandcardNum() < 3 then return false end
			return not judge:isGood()
		else
			return judge:isGood()
		end
	elseif reason == "tuntian" then
		if self:isFriend(who) then
			if self.player:objectName() == who:objectName() then
				return not self:isWeak()
			else
				return not judge:isGood() and not who:hasShownSkills("tiandu|tiandu_GuoJia_LB")
			end
		else
			return judge:isGood()
		end
	elseif reason == "beige" then
		return true
	end

	if self:isFriend(who) then
		return not judge:isGood()
	elseif self:isEnemy(who) then
		return judge:isGood()
	else
		return false
	end
end
function SmartAI:needRende()												--仁德
	local rende_dummycount = self.RendeLB_DummyCount or 0
	if self.player:hasSkill("RendeLB") and self:findFriendsByType(sgs.Friend_Draw) and (self.player:getMark("RendeLB") + rende_dummycount < 2) then
		if self.player:getLostHp() > 1 then return true end
		if self:willUseRendeLBAnaleptic(true) then return true end
	end
	return self.player:getLostHp() > 1 and self:findFriendsByType(sgs.Friend_Draw) and (self.player:hasSkill("rende") and self.player:getMark("rende") < 3)
end
function SmartAI:hasCrossbowEffect(player)									--咆哮、龙吟
	player = player or self.player
	local guanping = sgs.findPlayerByShownSkillName("Longyin")
	if guanping and self:isFriend(guanping, player) and (guanping:getCardCount(true) >= 4 or self:getLeastHandcardNum(guanping) > 0) and not self.Longyin_testing then return true end
	return player:hasWeapon("Crossbow") or player:hasShownSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") or (player == self.player and self.player:hasSkill("Longyin") and (player:getCardCount(true) >= 4 or self:getLeastHandcardNum(player) > 0) and not self.Longyin_testing)
end
function SmartAI:canRetrial(player, to_retrial, reason)						--鬼才、武魂
	player = player or self.player
	to_retrial = to_retrial or self.player
	if player:hasShownSkill("guidao") and not (reason and reason == "Wuhun") then
		local blackequipnum = 0
		for _, equip in sgs.qlist(player:getEquips()) do
			if equip:isBlack() then blackequipnum = blackequipnum + 1 end
		end
		if blackequipnum + player:getHandcardNum() > 0 then return true end
	end
	if player:hasShownSkill("guicai") and player:getHandcardNum() > 0 then return true end
	if player:hasShownSkill("GuicaiLB") and player:getCards("he"):length() > 0 then return true end
	return
end
function SmartAI:getRetrialCardId(cards, judge, self_card)					--天妒
	if self_card == nil then self_card = true end
	local can_use = {}
	local reason = judge.reason
	local who = judge.who

	local other_suit, hasSpade = {}
	for _, card in ipairs(cards) do
		local card_x = sgs.Sanguosha:getEngineCard(card:getEffectiveId())
		local is_peach = self:isFriend(who) and who:hasShownSkills("tiandu|tiandu_GuoJia_LB") or isCard("Peach", card_x, self.player)  --源码忘记Shown
		if who:hasShownSkill("hongyan") and card_x:getSuit() == sgs.Card_Spade then
			card_x = sgs.cloneCard(card_x:objectName(), sgs.Card_Heart, card:getNumber())
		end
		if reason == "beige" and not is_peach then
			local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
			if damage.from then
				if self:isFriend(damage.from) then
					if not self:toTurnOver(damage.from, 0) and judge.card:getSuit() ~= sgs.Card_Spade and card_x:getSuit() == sgs.Card_Spade then
						table.insert(can_use, card)
						hasSpade = true
					elseif (not self_card or self:getOverflow() > 0) and judge.card:getSuit() ~= card_x:getSuit() then
						local retr = true
						if (judge.card:getSuit() == sgs.Card_Heart and who:isWounded() and self:isFriend(who))
							or (judge.card:getSuit() == sgs.Card_Club and self:needToThrowArmor(damage.from)) then
							retr = false
						end
						if retr
							and ((self:isFriend(who) and card_x:getSuit() == sgs.Card_Heart and who:isWounded())
								or (card_x:getSuit() == sgs.Card_Club and (self:needToThrowArmor(damage.from) or damage.from:isNude())))
								or (judge.card:getSuit() == sgs.Card_Spade and self:toTurnOver(damage.from, 0)) then
							table.insert(other_suit, card)
						end
					end
				else
					if not self:toTurnOver(damage.from, 0) and card_x:getSuit() ~= sgs.Card_Spade and judge.card:getSuit() == sgs.Card_Spade then
						table.insert(can_use, card)
					end
				end
			end
		elseif self:isFriend(who) and judge:isGood(card_x)
				and not (self_card and (self:getFinalRetrial() == 2 or self:dontRespondPeachInJudge(judge)) and is_peach) then
			table.insert(can_use, card)
		elseif self:isEnemy(who) and not judge:isGood(card_x)
				and not (self_card and (self:getFinalRetrial() == 2 or self:dontRespondPeachInJudge(judge)) and is_peach) then
			table.insert(can_use, card)
		end
	end
	if not hasSpade and #other_suit > 0 then table.insertTable(can_use, other_suit) end

	if reason ~= "lightning" then
		for _, aplayer in sgs.qlist(self.room:getAllPlayers()) do
			if aplayer:containsTrick("lightning") then
				for i, card in ipairs(can_use) do
					if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
						table.remove(can_use, i)
						break
					end
				end
			end
		end
	end

	if next(can_use) then
		if self:needToThrowArmor() then
			for _, c in ipairs(can_use) do
				if c:getEffectiveId() == self.player:getArmor():getEffectiveId() then return c:getEffectiveId() end
			end
		end
		self:sortByKeepValue(can_use)
		return can_use[1]:getEffectiveId()
	else
		return -1
	end
end
function hasBuquEffect(player)												--不屈
	return (player:hasShownSkill("buqu") and player:getPile("buqu"):length() <= 4)
		or (player:hasShownSkill("BuquRenew_ZhouTai_13") and player:getPile("chuang_ZhouTai_13"):length() <= 4 and not player:hasFlag("BuquRenew_ZhouTai_13InMyTurn"))
		or (player:hasShownSkill("BuquRenew_ZhouTai_15") and player:getPile("chuang_ZhouTai_15"):length() <= 4 and not player:hasFlag("BuquRenew_ZhouTai_15InMyTurn"))
end
function SmartAI:doNotDiscard(to, flags, conservative, n, cant_choose)		--奋激
	if not to then global_room:writeToConsole(debug.traceback()) return end
	n = n or 1
	flags = flags or "he"
	if to:isNude() then return true end
	conservative = conservative or (sgs.turncount <= 2 and self.room:alivePlayerCount() > 2)
	local enemies = self:getEnemies(to)
	if #enemies == 1 and enemies[1]:hasShownSkills("qianxun|weimu") and self.room:alivePlayerCount() == 2 then conservative = false end

	if cant_choose then
		if self:needKongcheng(to) and to:getHandcardNum() <= n then return true end
		if self:getLeastHandcardNum(to) <= n then return true end
		if to:hasShownSkills(sgs.lose_equip_skill) and to:hasEquip() then return true end
		if self:needToThrowArmor(to) then return true end
	else
		if flags:match("e") then
			if to:hasShownSkills("jieyin+xiaoji") and to:getDefensiveHorse() then return false end
			if to:hasShownSkills("jieyin+xiaoji") and to:getArmor() and not to:getArmor():isKindOf("SilverLion") then return false end
		end
		if flags == "h" or (flags == "he" and not to:hasEquip()) then
			if to:isKongcheng() or not self.player:canDiscard(to, "h") then return true end
			if not self:hasLoseHandcardEffective(to) then return true end
			if to:getHandcardNum() == 1 and self:needKongcheng(to) then return true end
			if self:hasFenjiEffect(to) then return true end
			if #self.friends > 1 and to:getHandcardNum() == 1 and to:hasShownSkill("sijian") then return false end
		elseif flags == "e" or (flags == "he" and to:isKongcheng()) then
			if not to:hasEquip() then return true end
			if to:hasShownSkills(sgs.lose_equip_skill) then return true end
			if to:getCardCount(true) == 1 and self:needToThrowArmor(to) then return true end
		end
		if flags == "he" and n == 2 then
			if not self.player:canDiscard(to, "e") then return true end
			if to:getCardCount(true) < 2 then return true end
			if not to:hasEquip() then
				if not self:hasLoseHandcardEffective(to) then return true end
				if to:getHandcardNum() <= 2 and self:needKongcheng(to) then return true end
				if self:hasFenjiEffect(to) then return true end
			end
			if to:hasShownSkills(sgs.lose_equip_skill) and to:getHandcardNum() < 2 then return true end
			if to:getCardCount(true) <= 2 and self:needToThrowArmor(to) then return true end
		end
	end
	if flags == "he" and n > 2 then
		if not self.player:canDiscard(to, "e") then return true end
		if to:getCardCount(true) < n then return true end
	end
	return false
end
function SmartAI:cantbeHurt(player, from, damageNum)						--武魂
	from = from or self.player
	damageNum = damageNum or 1
	if not player then self.room:writeToConsole(debug.traceback()) return end
	
	--武魂
	if player:hasShownSkill("Wuhun") then
		local actual_friends_from = {}
		for _,friend in sgs.qlist(self.room:getAlivePlayers()) do
			if friend:objectName() == from:objectName() or from:isFriendWith(friend) then
				table.insert(actual_friends_from, friend)
			end
		end
		local actual_friends_to = {}
		for _,friend in sgs.qlist(self.room:getAlivePlayers()) do
			if friend:objectName() == player:objectName() or player:isFriendWith(friend) then
				table.insert(actual_friends_to, friend)
			end
		end
		if not ((#actual_friends_from + #actual_friends_to == self.room:alivePlayerCount()) and (#actual_friends_to == 1)) then --两势力对战，对面仅剩神关一人
			local targets = self:getWuhunRevengeTargets(player)
			local real_damage = damageNum
			if player:getHp() <= damageNum and math.ceil(self:getAllPeachNum(player)) < 1 - (player:getHp() - damageNum) then
				real_damage = 0  --由于时机修改
			end
			local maxmark = targets[1] and targets[1]:getMark("@nightmare") or 0
			
			if sgs.ais[from:objectName()]:objectiveLevel(player) > 3 then
				if maxmark < from:getMark("@nightmare") + real_damage then  --伤害来源将成为新的武魂目标
					return true
				elseif (maxmark == from:getMark("@nightmare") + real_damage) and #actual_friends_from == 1 then  --没有队友，还是不要拿自己势力冒险了
				else  --对自己没有威胁
					local help_friend = false
					for _,target in ipairs(targets) do
						if sgs.ais[player:objectName()]:objectiveLevel(target) > 0 and self:isFriendWith(from, target) then help_friend = true break end  --帮队友压神关血线
					end
					if not help_friend then return true end  --别多管闲事
				end
			end
		end
	end

	if player:hasShownSkill("duanchang") and not player:isLord() and #(self:getFriendsNoself(player)) > 0 and player:getHp() <= 1 then
		if not (from:getMaxHp() == 3 and from:getArmor() and from:getDefensiveHorse()) then
			if from:getMaxHp() <= 3 or (from:isLord() and self:isWeak(from)) then return true end
		end
	end
	if player:hasShownSkill("tianxiang") and getKnownCard(player, self.player, "diamond|club", false) < player:getHandcardNum() then
		local peach_num = self.player:objectName() == from:objectName() and self:getCardsNum("Peach") or getCardsNum("Peach", from, self.player)
		local dyingfriend = 0
		for _, friend in ipairs(self:getFriends(from)) do
			if friend:getHp() < 2 and peach_num == 0 then
				dyingfriend = dyingfriend + 1
			end
		end
		if dyingfriend > 0 and player:getHandcardNum() > 0 then
			return true
		end
	end
	if player:hasShownSkill("hengzheng") and player:getHandcardNum() ~= 0 and player:getHp() - damageNum == 1
		and from:getNextAlive():objectName() == player:objectName() then
		if sgs.ai_skill_invoke.hengzheng(sgs.ais[player:objectName()]) then return true end
	end
	return false
end
function sgs.ai_skill_cardask.nullfilter(self, data, pattern, target)		--武魂、无谋、龙魂
	if self.player:isDead() then return "." end
	local damage_nature = sgs.DamageStruct_Normal
	local effect
	if type(data) == "SlashEffectStruct" or type(data) == "userdata" then
		effect = data:toSlashEffect()
		if effect and effect.slash then
			damage_nature = effect.nature
		end
	end
	if effect and self:hasHeavySlashDamage(target, effect.slash, self.player) then return end
	if not self:damageIsEffective(nil, damage_nature, target) then return "." end
	if effect and target and target:hasWeapon("IceSword") and self.player:getCards("he"):length() > 1 then return end
	if self:getDamagedEffects(self.player, target) or self:needToLoseHp() then return "." end

	if target and self:needDeath() then return "." end  --武魂（needDeath）
    if self.player:hasShownSkill("Wumou") and self.player:getMark("@wrath") < 7 and self.player:getHp() > 2 then return "." end
	if self.player:hasSkill("tianxiang") then
		local dmgStr = {damage = 1, nature = damage_nature or sgs.DamageStruct_Normal}
		local willTianxiang = sgs.ai_skill_use["@@tianxiang"](self, dmgStr, sgs.Card_MethodDiscard)
		if willTianxiang ~= "." then return "." end
	elseif self.player:hasSkill("Longhun") and self.player:getHp() > 1 then
		return "."
	end
end
function SmartAI:adjustKeepValue(card, v)									--武神、矢志
	local suits = {"club", "spade", "diamond", "heart"}
	for _, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		local callback = sgs.ai_suit_priority[askill:objectName()]
		if type(callback) == "function" then
			suits = callback(self, card):split("|")
			break
		elseif type(callback) == "string" then
			suits = callback:split("|")
			break
		end
	end
	table.insert(suits, "no_suit")

	if card:isKindOf("Slash") then
		if card:isRed() then v = v + 0.02 end
		if card:isKindOf("NatureSlash") then v = v + 0.03 end
		if self.player:hasSkill("jiang") and card:isRed() then v = v + 0.04 end
        if self.player:hasSkill("Wushen") and card:getSuit() == sgs.Card_Heart then v = v + 0.03 end
        if self.player:hasSkill("Shizhi") and self.player:getHp() == 1 and card:getEffectiveId() >= 0 and sgs.Sanguosha:getEngineCard(card:getEffectiveId()):isKindOf("Jink") then v = v + 0.03 end
	elseif card:isKindOf("HegNullification") then v = v + 0.02
	end
	if self.player:getHandPile():contains(card:getEffectiveId()) then
		v = v - 0.1
	end

	local suits_value = {}
	for index,suit in ipairs(suits) do
		suits_value[suit] = index * 2
	end
	v = v + (suits_value[card:getSuitString()] or 0) / 100
	v = v + card:getNumber() / 500
	return v
end
local function prohibitUseDirectly(card, player)							--为isCard服务（因为local）
	if player:isCardLimited(card, card:getHandlingMethod()) then return true end
	if card:isKindOf("Peach") and player:hasFlag("Global_PreventPeach") then return true end
	return false
end
local function getSkillViewCard(card, class_name, player, card_place)		--为isCard服务（因为local）
	for _, skill in ipairs(getPlayerSkillList(player)) do
		local askill = skill:objectName()
		if player:hasSkill(askill) or player:hasLordSkill(askill) then
			local callback = sgs.ai_view_as[askill]
			if type(callback) == "function" then
				local skill_card_str = callback(card, player, card_place, class_name)
				if skill_card_str then
					local skill_card = sgs.Card_Parse(skill_card_str)
					assert(skill_card)
					if skill_card:isKindOf("HalberdCard") and not player:isCardLimited(skill_card, skill_card:getHandlingMethod()) and class_name == "Slash" then return skill_card_str end
					if skill_card:isKindOf(class_name) and not player:isCardLimited(skill_card, skill_card:getHandlingMethod()) then return skill_card_str end
				end
			end
		end
	end
end
function isCard(class_name, card, player)									--武神、矢志
	if not player or not card then global_room:writeToConsole(debug.traceback()) end
	if not card:isKindOf(class_name) then
		local place
		local id = card:getEffectiveId()
		if global_room:getCardOwner(id) == nil or global_room:getCardOwner(id):objectName() ~= player:objectName() then place = sgs.Player_PlaceHand
		else place = global_room:getCardPlace(id) end
		if getSkillViewCard(card, class_name, player, place) then return true end
		if player:hasShownSkill("Wushen") and card:getSuit() == sgs.Card_Heart and class_name == "Slash" then return true end
        if player:hasShownSkill("Shizhi") and player:getHp() == 1 and card:isKindOf("Jink") and class_name == "Slash" then return true end
	else
        if player:hasShownSkill("Wushen") and card:getSuit() == sgs.Card_Heart and class_name ~= "Slash" then return false end
        if player:hasShownSkill("Shizhi") and player:getHp() == 1 and class_name == "Jink" and not player:hasShownSkills("longdan|longdan_ZhaoYun_LB") then return false end
		if not prohibitUseDirectly(card, player) then return true end
	end
	return false
end
function SmartAI:aoeIsEffective(card, to, source)							--智迟、悍勇
	local players = self.room:getAlivePlayers()
	players = sgs.QList2Table(players)
	source = source or self.room:getCurrent()

	if to:hasArmorEffect("Vine") then
		return false
	end

	if to:isLocked(card) then
		return false
	end

	if card:isKindOf("SavageAssault") then
		if to:hasShownSkills("huoshou|juxiang") then
			return false
		end
	end
	
    if to:getMark("@late") > 0 then
        return false
    end

	if to:hasShownSkill("weimu") and card:isBlack() then return false end

	local hasHeavyDamage = (card:hasFlag("HanyongAddDamage"))
	if not hasHeavyDamage then
		if not self:hasTrickEffective(card, to, source) or not self:damageIsEffective(to, nil, source) then
			return false
		end
	else
		local damageStruct = {}
		damageStruct.to = to
		damageStruct.from = source
		damageStruct.nature = sgs.DamageStruct_Normal
		damageStruct.damage = 2
		if not self:hasTrickEffective(card, to, source) or not self:damageIsEffective_(damageStruct) then
			return false
		end
	end
	return true
end
function SmartAI:isFriendWith(player)										--修复野心家不是自己Friend的问题
	if self.player:isFriendWith(player) then return true end  --这两行交换顺序
	if self.role == "careerist" then return false end
	local kingdom = self.player:getKingdom()
	local p_kingdom = self:evaluateKingdom(player)
	if kingdom == p_kingdom then
		local kingdom_num = self.player:getPlayerNumWithSameKingdom("AI")
		if not self.player:hasShownOneGeneral() then kingdom_num = kingdom_num + 1 end
		if not player:hasShownOneGeneral() then kingdom_num = kingdom_num + 1 end
		if self.player:aliveCount() / 2 > kingdom_num or player:getLord() then return true end
	end

	return false
end
function SmartAI:getUseValue(card)											--诈降、推锋、怒斩、无谋
	if card == nil then global_room:writeToConsole(debug.traceback()) end
	local class_name = card:isKindOf("LuaSkillCard") and card:objectName() or card:getClassName()
	local v = sgs.ai_use_value[class_name] or 0

	if card:getTypeId() == sgs.Card_TypeSkill then
		return v
	elseif card:getTypeId() == sgs.Card_TypeEquip then
		if self.player:hasEquip(card) then
			if card:isKindOf("OffensiveHorse") and self.player:getAttackRange() > 2 then return 5.5 end
			if card:isKindOf("DefensiveHorse") and self:hasEightDiagramEffect() then return 5.5 end
			return 9
		end
		if not self:getSameEquip(card) then v = 6.7 end
		if self.weaponUsed and card:isKindOf("Weapon") then v = 2 end
		if self.player:hasSkills("qiangxi") and card:isKindOf("Weapon") then v = 2 end
		if self.player:hasSkill("kurou") and card:isKindOf("Crossbow") then return 9 end
		if self.player:hasSkills("bazhen|jgyizhong") and card:isKindOf("Armor") then v = 2 end

		if self.player:hasSkills(sgs.lose_equip_skill) then return 10 end
	elseif card:getTypeId() == sgs.Card_TypeBasic then
		if card:isKindOf("Slash") then
			if self.player:hasFlag("TianyiSuccess") or self.player:getMark("Zhaxiang") > 0 or self.player:getMark("@lead") > 0  --看v2似乎是给多杀用的
				or (self.player:hasSkill("Nuzhan") and self:willShowForAttack() and card:isVirtualCard() and (card:subcardsLength() == 1) and sgs.Sanguosha:getCard(card:getSubcards():first()):isKindOf("TrickCard") and self:getCardsNum("Slash", "he") > 1)  --同理待加入枪舞
				or self:hasHeavySlashDamage(self.player, card) then v = 8.7 end
			if self.player:getPhase() == sgs.Player_Play and self:slashIsAvailable() and #self.enemies > 0 and self:getCardsNum("Slash") == 1 then v = v + 5 end
			if self:hasCrossbowEffect() then v = v + 4 end
			if card:getSkillName() == "Spear" then v = v - 1 end
		elseif card:isKindOf("Jink") then
			if self:getCardsNum("Jink") > 1 then v = v - 6 end
		elseif card:isKindOf("Peach") then
			if self.player:isWounded() then v = v + 6 end
		end
	elseif card:getTypeId() == sgs.Card_TypeTrick then
		if self.player:getPhase() == sgs.Player_Play and not card:isAvailable(self.player) then v = 0 end
		if self.player:getWeapon() and not self.player:hasSkills(sgs.lose_equip_skill) and card:isKindOf("Collateral") then v = 2 end
		if card:getSkillName() == "shuangxiong" then v = 6 end
		if card:isKindOf("Duel") then v = v + self:getCardsNum("Slash") * 2 end
		if self.player:hasSkill("jizhi") then v = v + 4 end
        if self.player:hasShownSkill("Wumou") and card:isNDTrick() and (not card:isKindOf("AOE") or card:isKindOf("AllianceFeast")) and not self:needToLoseHp() then
            if not (card:isKindOf("Duel") and self.player:hasUsed("#WuqianCard")) then v = 1 end
        end
	end

	if self.player:hasSkills(sgs.need_kongcheng) then
		if self.player:getHandcardNum() == 1 then v = 10 end
	end
	if self.player:getHandPile():contains(card:getEffectiveId()) then
		v = v + 1
	end

	if card:isKindOf("HalberdCard") then v = v + 20 end

	if self.player:getPhase() == sgs.Player_Play then v = self:adjustUsePriority(card, v) end
	return v
end
function SmartAI:sortByKeepValue(cards, inverse, kept)						--技能卡排序bug
	local values = {}
	for _, card in ipairs(cards) do
		values[card:toString()] = self:getKeepValue(card)
	end

	local compare_func = function(a, b)
		local v1 = values[a:toString()]
		local v2 = values[b:toString()]

		if v1 ~= v2 then
			if inverse then return v1 > v2 end
			return v1 < v2
		else
			if not inverse then return a:getNumber() > b:getNumber() end
			return a:getNumber() < b:getNumber()
		end
	end

	table.sort(cards, compare_func)
end
function SmartAI:sortByUseValue(cards, inverse)								--技能卡排序bug
	local values = {}
	for _, card in ipairs(cards) do
		values[card:toString()] = self:getUseValue(card)
	end

	local compare_func = function(a, b)
		local value1 = values[a:toString()]
		local value2 = values[b:toString()]

		if value1 ~= value2 then
			if not inverse then return value1 > value2 end
			return value1 < value2
		else
			if not inverse then return a:getNumber() > b:getNumber() end
			return a:getNumber() < b:getNumber()
		end
	end

	table.sort(cards, compare_func)
end
function SmartAI:sortByUsePriority(cards)									--技能卡排序bug
	local values = {}
	for _, card in ipairs(cards) do
		values[card:toString()] = self:getUsePriority(card)
	end

	local compare_func = function(a, b)
		local value1 = values[a:toString()]
		local value2 = values[b:toString()]

		if value1 ~= value2 then
			return value1 > value2
		else
			return a:getNumber() > b:getNumber()
		end
	end
	table.sort(cards, compare_func)
end
function SmartAI:sortByDynamicUsePriority(cards)							--技能卡排序bug
	local values = {}
	for _, card in ipairs(cards) do
		values[card:toString()] = self:getDynamicUsePriority(card)
	end

	local compare_func = function(a,b)
		local value1 = values[a:toString()]
		local value2 = values[b:toString()]

		if value1 ~= value2 then
			return value1 > value2
		else
			return a and a:getTypeId() ~= sgs.Card_TypeSkill and not (b and b:getTypeId() ~= sgs.Card_TypeSkill)
		end
	end

	table.sort(cards, compare_func)
end
function SmartAI:sortByCardNeed(cards, inverse)								--技能卡排序bug
	local values = {}
	for _, card in ipairs(cards) do
		values[card:toString()] = self:cardNeed(card)
	end

	local compare_func = function(a,b)
		local value1 = values[a:toString()]
		local value2 = values[b:toString()]

		if value1 ~= value2 then
			if inverse then return value1 > value2 end
			return value1 < value2
		else
			if not inverse then return a:getNumber() > b:getNumber() end
			return a:getNumber() < b:getNumber()
		end
	end

	table.sort(cards, compare_func)
end
function SmartAI:useTrickCard(card, use)									--无谋
	if not card then global_room:writeToConsole(debug.traceback()) return end
    if self.player:hasShownSkill("Wumou") and self.player:getMark("@wrath") < 7 and not self:needToLoseHp() then
        if not ((card:isKindOf("AOE") and not card:isKindOf("AllianceFeast")) or card:isKindOf("DelayedTrick") or card:isKindOf("IronChain") or card:isKindOf("Drowning") or card:isKindOf("FightTogether") or card:isKindOf("KnownBoth"))
            and not (card:isKindOf("Duel") and self.player:getMark("@wrath") > 0) then return end
    end
	if self:needRende() and not card:isKindOf("ExNihilo") then return end
	self:useCardByClassName(card, use)
end
function SmartAI:isWeak(player)												--龙魂
	player = player or self.player
	if hasBuquEffect(player) then return false end
	if hasNiepanEffect(player) then return false end
	if player:hasShownSkill("kongcheng") and player:isKongcheng() and player:getHp() >= 2 then return false end
	if player:hasShownSkill("Longhun") and player:getCards("he"):length() > 2 then return false end
	if (player:getHp() <= 2 and player:getHandcardNum() <= 2) or player:getHp() <= 1 then return true end
	return false
end

--standard_cards
sgs.ai_skill_cardask["slash-jink"] = function(self, data, pattern, target)	--绝策、制蛮、仁德、耀武
	local isdummy = type(data) == "number"
	local function getJink()
		local cards = self:getCards("Jink")
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if self.room:isJinkEffected(self.player, card) then return card:toString() end
		end
		return not isdummy and "."
	end
	if self:isFriend(self.player, target) and target:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") and not self.player:hasSkill("leiji") then return "." end
	
	local slash
	if type(data) == "SlashEffectStruct" or type(data) == "userdata" then
		local effect = data:toSlashEffect()
		slash = effect.slash
	else
		slash = sgs.cloneCard("slash")
	end
	local cards = sgs.QList2Table(self.player:getHandcards())
	if not self:slashIsEffective(slash,self.player,target) then return "." end
	if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) then return "." end
	if not target then return getJink() end
	if not self:hasHeavySlashDamage(target, slash, self.player) and self:getDamagedEffects(self.player, target, slash) then return "." end
	if slash:isKindOf("NatureSlash") and self.player:isChained() and self:isGoodChainTarget(self.player, target, nil, nil, slash) then return "." end
	if self:isFriend(target) then
		if self:findLeijiTarget(self.player, 50, target) then return getJink() end
		if target:hasShownSkill("jieyin") and not self.player:isWounded() and self.player:isMale() and not self.player:hasSkill("leiji") then return "." end
		if target:hasShownSkills("rende|RendeLB") and self.player:hasSkill("jieming") then return "." end
		if self:hasYaowuEffect(self.player, slash, true, target) then return "." end  --耀武（让队友回血）
	else
		if self:hasHeavySlashDamage(target, slash) then return getJink() end
		
		local current = self.room:getCurrent()
		if current and current:hasShownSkill("Juece") and self.player:getHp() > 0 then
			local use = false
			for _, card in ipairs(self:getCards("Jink")) do
				if not self.player:isLastHandCard(card, true) then
					use = true
					break
				end
			end
			if not use then return not isdummy and "." end
		end
		if self.player:getHandcardNum() == 1 and self:needKongcheng() then return getJink() end
		if not self:hasLoseHandcardEffective() and not self.player:isKongcheng() then return getJink() end
		if target:hasShownSkill("mengjin") then
			if self:doNotDiscard(self.player, "he", true) then return getJink() end
			if self.player:getCards("he"):length() == 1 and not self.player:getArmor() then return getJink() end
			if self.player:hasSkills("jijiu|qingnang|jijiu_HuaTuo_LB") and self.player:getCards("he"):length() > 1 then return "." end
			if (self:getCardsNum("Peach") > 0 or (self:getCardsNum("Analeptic") > 0 and self:isWeak()))
				and not self.player:hasSkill("tuntian") and not self:willSkipPlayPhase() then
				return "."
			end
		end
		if target:hasWeapon("Axe") then
			if target:hasShownSkills(sgs.lose_equip_skill) and target:getEquips():length() > 1 and target:getCards("he"):length() > 2 then return not isdummy and "." end
			if target:getHandcardNum() - target:getHp() > 2 and not self:isWeak() and not self:getOverflow() then return not isdummy and "." end
		end
	end
	return getJink()
end
sgs.ai_skill_cardask.aoe = function(self, data, pattern, target, name)		--绝策、制蛮、奸雄、悍勇
	if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) then return "." end

	local aoe
	if type(data) == "CardEffectStruct" or type(data) == "userdata" then aoe = data:toCardEffect().card else aoe = sgs.cloneCard(name) end
	assert(aoe ~= nil)
	local menghuo = sgs.findPlayerByShownSkillName("huoshou")
	local attacker = target
	if aoe:isKindOf("ArcheryAttack") then  --以下为处理制蛮部分
		if not self.player:hasSkill("leiji") and self:isFriend(self.player, target) and target:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return "." end
	elseif aoe:isKindOf("SavageAssault") then
		if not menghuo and self:isFriend(self.player, target) and target:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return "." end
		if menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") and self:isFriend(self.player, menghuo) then return "." end
	end
	if menghuo and aoe:isKindOf("SavageAssault") then attacker = menghuo end

	local hasHeavyDamage = (aoe:hasFlag("HanyongAddDamage"))
	if not hasHeavyDamage then
		if not self:damageIsEffective(nil, nil, attacker) then return "." end
		if self:getDamagedEffects(self.player, attacker) or self:needToLoseHp(self.player, attacker) then return "." end
	else
		local damageStruct = {}
		damageStruct.to = self.player
		damageStruct.from = attacker
		damageStruct.nature = sgs.DamageStruct_Normal
		damageStruct.damage = 2
		if not self:damageIsEffective_(damageStruct) then return "." end
	end

	if self.player:hasSkills("jianxiong|JianxiongLB") and (self.player:getHp() > 1 or self:getAllPeachNum() > 0)
		and not self:willSkipPlayPhase() and not hasHeavyDamage then
		if not self:needKongcheng(self.player, true) and self:getAoeValue(aoe) > 0 then return "." end
	end
	
	local current = self.room:getCurrent()
	if current and current:hasShownSkill("Juece") and self:isEnemy(current) and self.player:getHp() > 0 and not hasHeavyDamage then
		local classname = (name == "savage_assault" and "Slash" or "Jink")
		local use = false
		for _, card in ipairs(self:getCards(classname)) do
			if not self.player:isLastHandCard(card, true) then
				use = true
				break
			end
		end
		if not use then return "." end
	end
end
function turnUse_spear(self, inclusive, skill_name)							--武圣、咆哮、连营
	if self.player:hasSkills("wusheng|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo") then
		local cards = self.player:getCards("he")
		cards = sgs.QList2Table(cards)
		for _, id in sgs.qlist(self.player:getHandPile()) do
			table.insert(cards, sgs.Sanguosha:getCard(id))
		end
		for _, acard in ipairs(cards) do
			if isCard("Slash", acard, self.player) then return end
		end
	end

	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards)
	local newcards = {}
	for _, card in ipairs(cards) do
		if not isCard("Slash", card, self.player) and not isCard("Peach", card, self.player) and not (isCard("ExNihilo", card, self.player) and self.player:getPhase() == sgs.Player_Play) then table.insert(newcards, card) end
	end
	if #cards <= self.player:getHp() - 1 and self.player:getHp() <= 4 and not self:hasHeavySlashDamage(self.player)
		and not self.player:hasSkills("kongcheng|paoxiao|Lianying|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then return end
	if #newcards < 2 then return end

	local card_id1 = newcards[1]:getEffectiveId()
	local card_id2 = newcards[2]:getEffectiveId()

	if newcards[1]:isBlack() and newcards[2]:isBlack() then
		local black_slash = sgs.cloneCard("slash", sgs.Card_NoSuitBlack)
		local nosuit_slash = sgs.cloneCard("slash")

		self:sort(self.enemies, "defenseSlash")
		for _, enemy in ipairs(self.enemies) do
			if self.player:canSlash(enemy) and not self:slashProhibit(nosuit_slash, enemy) and self:slashIsEffective(nosuit_slash, enemy)
				and self:canAttack(enemy) and self:slashProhibit(black_slash, enemy) and self:isWeak(enemy) then
				local redcards, blackcards = {}, {}
				for _, acard in ipairs(newcards) do
					if acard:isBlack() then table.insert(blackcards, acard) else table.insert(redcards, acard) end
				end
				if #redcards == 0 then break end

				local redcard, othercard

				self:sortByUseValue(blackcards, true)
				self:sortByUseValue(redcards, true)
				redcard = redcards[1]

				othercard = #blackcards > 0 and blackcards[1] or redcards[2]
				if redcard and othercard then
					card_id1 = redcard:getEffectiveId()
					card_id2 = othercard:getEffectiveId()
					break
				end
			end
		end
	end

	local card_str = ("slash:%s[%s:%s]=%d+%d&%s"):format(skill_name, "to_be_decided", 0, card_id1, card_id2, skill_name)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)
	return slash
end
function SmartAI:getValuableCard(who)										--武圣、急救、奇袭、暗箭、国色、潜袭、龙魂、鬼才（待处理：活墨）
	local weapon = who:getWeapon()
	local armor = who:getArmor()
	local offhorse = who:getOffensiveHorse()
	local defhorse = who:getDefensiveHorse()
	local treasure = who:getTreasure()
	self:sort(self.friends, "hp")
	local friend
	if #self.friends > 0 then friend = self.friends[1] end
	if friend and self:isWeak(friend) and who:distanceTo(friend) <= who:getAttackRange(false) and not self:doNotDiscard(who, "e", true) then
		if weapon and (who:distanceTo(friend) > 1) then
			return weapon:getEffectiveId()
		end
		if offhorse and who:distanceTo(friend) > 1 then
			return offhorse:getEffectiveId()
		end
	end

	if treasure then
		if (treasure:isKindOf("WoodenOx") and who:getPile("wooden_ox"):length() > 1) or treasure:isKindOf("JadeSeal") then
			return treasure:getEffectiveId()
		end
	end

	if defhorse and not self:doNotDiscard(who, "e")
		and not (self.player:hasWeapon("KylinBow") and self.player:canSlash(who) and self:slashIsEffective(sgs.cloneCard("slash"), who, self.player)
				and (getCardsNum("Jink", who, self.player) < 1 or sgs.card_lack[who:objectName()].Jink == 1 )) then
		return defhorse:getEffectiveId()
	end

	if armor and self:evaluateArmor(armor, who) > 3
	  and not self:needToThrowArmor(who)
	  and not self:doNotDiscard(who, "e") then
		return armor:getEffectiveId()
	end

	if offhorse then
		if who:hasShownSkills("kuanggu|duanbing|qianxi|QianxiRE") then
			return offhorse:getEffectiveId()
		end
	end

	local equips = sgs.QList2Table(who:getEquips())
	for _,equip in ipairs(equips) do
		if who:hasShownSkills("Longhun") and equip:getSuit() ~= sgs.Card_Diamond then return equip:getEffectiveId() end
		if who:hasShownSkills("GuicaiLB") and (equip:getSuit() == sgs.Card_Heart or equip:getSuit() == sgs.Card_Club or (equip:getSuit() == sgs.Card_Spade and equip:getNumber() >= 2 and equip:getNumber() <= 9)) then return equip:getEffectiveId() end  --测试
		if who:hasShownSkills("guose|GuoseLB") and equip:getSuit() == sgs.Card_Diamond then  return equip:getEffectiveId() end
		if who:hasShownSkills("qixi|duanliang|guidao|qixi_GanNing_LB") and equip:isBlack() then  return equip:getEffectiveId() end
		if who:hasShownSkills("wusheng|jijiu|wusheng_GuanYu_LB|wusheng_GuanXingZhangBao|wusheng_GuanYu_JSP|wusheng_GuanSuo|jijiu_HuaTuo_LB") and equip:isRed() then  return equip:getEffectiveId() end
		if who:hasShownSkills(sgs.need_equip_skill) and not who:hasShownSkills(sgs.lose_equip_skill) then return equip:getEffectiveId() end
		if who:hasShownSkills("Anjian") and equip:isKindOf("Weapon") then
			for _,friend in ipairs(self.friends) do
				if not friend:inMyAttackRange(who) and getCardsNum("Jink", friend, self.player) < 1 then
					return equip:getEffectiveId()
				end
			end
		end
	end

	if armor and not self:needToThrowArmor(who) and not self:doNotDiscard(who, "e") then
		return armor:getEffectiveId()
	end

	if offhorse and who:getHandcardNum() > 1 then
		if not self:doNotDiscard(who, "e", true) then
			for _,friend in ipairs(self.friends) do
				if who:distanceTo(friend) == who:getAttackRange() and who:getAttackRange() > 1 then
					return offhorse:getEffectiveId()
				end
			end
		end
	end

	if weapon and who:getHandcardNum() > 1 then
		if not self:doNotDiscard(who, "e", true) then
			for _,friend in ipairs(self.friends) do
				if (who:distanceTo(friend) <= who:getAttackRange()) and (who:distanceTo(friend) > 1) then
					return weapon:getEffectiveId()
				end
			end
		end
	end
end
sgs.ai_skill_invoke.IceSword = function(self, data)							--铁骑、诈降
	local damage = data:toDamage()
	local target = damage.to
	if self:isFriend(target) then
		if self:getDamagedEffects(target, self.players, true) or self:needToLoseHp(target, self.player, true) then return false
		elseif target:isChained() and self:isGoodChainTarget(target, self.player, nil, nil, damage.card) then return false
		elseif self:isWeak(target) or damage.damage > 1 then return true
		elseif target:getLostHp() < 1 then return false end
		return true
	else
		if target:hasArmorEffect("PeaceSpell") and damage.nature ~= sgs.DamageStruct_Normal then return true end
		if self:isWeak(target) then return false end
		if damage.damage > 1 or self:hasHeavySlashDamage(self.player, damage.card, target) then return false end
		if target:hasShownSkill("lirang") and #self:getFriendsNoself(target) > 0 then return false end
		if target:getArmor() and self:evaluateArmor(target:getArmor(), target) > 3 and not (target:hasArmorEffect("SilverLion") and target:isWounded()) then return true end
		local num = target:getHandcardNum()
		if self.player:hasSkills("tieqi|TieqiLB") or self:canLiegong(target, self.player) or self:canZhaxiang(self.player, nil, damage.card) then return false end
		if target:hasShownSkill("tuntian") and target:getPhase() == sgs.Player_NotActive then return false end
		if target:hasShownSkills(sgs.need_kongcheng) then return false end
		if target:getCards("he"):length()<4 and target:getCards("he"):length()>1 then return true end
		return false
	end
end
sgs.ai_skill_askforag.amazing_grace = function(self, card_ids)				--铁骑、急救、无双、诈降、克己、仁德、鬼才、天妒、狂风、归心、落英、燃殇、潜袭、
																			--RE破军

	local NextPlayerCanUse, NextPlayerisEnemy
	local NextPlayer = self.player:getNextAlive()
	if sgs.turncount > 1 and not self:willSkipPlayPhase(NextPlayer) then
		if self:isFriend(NextPlayer) then
			NextPlayerCanUse = true
		else
			NextPlayerisEnemy = true
		end
	end

	local cards = {}
	local trickcard = {}
	for _, card_id in ipairs(card_ids) do
		local acard = sgs.Sanguosha:getCard(card_id)
		table.insert(cards, acard)
		if acard:isKindOf("TrickCard") then
			table.insert(trickcard , acard)
		end
	end

	local nextfriend_num = 0
	local aplayer = self.player:getNextAlive()
	for i =1, self.player:aliveCount() do
		if self:isFriend(aplayer) then
			aplayer = aplayer:getNextAlive()
			nextfriend_num = nextfriend_num + 1
		else
			break
		end
	end

	local SelfisCurrent
	if self.room:getCurrent():objectName() == self.player:objectName() then SelfisCurrent = true end

---------------

	local friendneedpeach, peach
	local peachnum, jinknum = 0, 0
	if NextPlayerCanUse then
		if (not self.player:isWounded() and NextPlayer:isWounded()) or
			(self.player:getLostHp() < self:getCardsNum("Peach")) or
			(not SelfisCurrent and self:willSkipPlayPhase() and self.player:getHandcardNum() + 2 > self.player:getMaxCards()) then
			friendneedpeach = true
		end
	end
	for _, card in ipairs(cards) do
		if isCard("Peach", card, self.player) then
			peach = card:getEffectiveId()
			peachnum = peachnum + 1
		end
		if card:isKindOf("Jink") then jinknum = jinknum + 1 end
	end
	if (not friendneedpeach and peach) or peachnum > 1 then return peach end

	local exnihilo, jink, analeptic, nullification, snatch, dismantlement, befriendattacking
	for _, card in ipairs(cards) do
		if isCard("ExNihilo", card, self.player) then
			if not NextPlayerCanUse or (not self:willSkipPlayPhase() and (self.player:hasSkills("jizhi|zhiheng|rende|RendeLB") or not NextPlayer:hasShownSkills("jizhi|zhiheng|rende|RendeLB"))) then
				exnihilo = card:getEffectiveId()
			end
		elseif isCard("Jink", card, self.player) then
			jink = card:getEffectiveId()
		elseif isCard("Analeptic", card, self.player) then
			analeptic = card:getEffectiveId()
		elseif isCard("Nullification", card, self.player) then
			nullification = card:getEffectiveId()
		elseif isCard("Snatch", card, self.player) then
			snatch = card
		elseif isCard("Dismantlement", card, self.player) then
			dismantlement = card
		elseif isCard("BefriendAttacking", card, self.player) then
			befriendattacking = card
		end

	end

	for _, target in sgs.qlist(self.room:getAlivePlayers()) do
		if self:willSkipPlayPhase(target) or self:willSkipDrawPhase(target) then
			if nullification then return nullification
			elseif self:isFriend(target) and snatch and self:hasTrickEffective(snatch, target, self.player) and
				not self:willSkipPlayPhase() and self.player:distanceTo(target) == 1 then
				return snatch:getEffectiveId()
			elseif self:isFriend(target) and dismantlement and self:hasTrickEffective(dismantlement, target, self.player) and
				not self:willSkipPlayPhase() and self.player:objectName() ~= target:objectName() then
				return dismantlement:getEffectiveId()
			end
		end
	end

	if SelfisCurrent then
		if exnihilo then return exnihilo end
		if befriendattacking then
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasShownOneGeneral() and not self.player:isFriendWith(p) then return befriendattacking end
			end
		end
		if (jink or analeptic) and (self:getCardsNum("Jink") == 0 or (self:isWeak() and self:getOverflow() <= 0)) then
			return jink or analeptic
		end
	else
		local CP = self.room:getCurrent()
		local possible_attack = 0
		for _, enemy in ipairs(self.enemies) do
			if enemy:inMyAttackRange(self.player) and self:playerGetRound(CP, enemy) < self:playerGetRound(CP, self.player) then
				possible_attack = possible_attack + 1
			end
		end
		if possible_attack > self:getCardsNum("Jink") and self:getCardsNum("Jink") <= 2 and sgs.getDefenseSlash(self.player, self) <= 2 then
			if jink or analeptic or exnihilo then return jink or analeptic or exnihilo end
		else
			if exnihilo then return exnihilo end
			if befriendattacking then
				for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
					if p:hasShownOneGeneral() and not self.player:isFriendWith(p) then return befriendattacking end
				end
			end
		end
	end

	if nullification and (self:getCardsNum("Nullification") < 2 or not NextPlayerCanUse) then
		return nullification
	end

	if jinknum == 1 and jink and self:isEnemy(NextPlayer) and (NextPlayer:isKongcheng() or sgs.card_lack[NextPlayer:objectName()]["Jink"] == 1) then
		return jink
	end

	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		for _, skill in sgs.qlist(self.player:getVisibleSkillList()) do
			local callback = sgs.ai_cardneed[skill:objectName()]
			if type(callback) == "function" and callback(self.player, card, self) then
				return card:getEffectiveId()
			end
		end
	end

	local eightdiagram, silverlion, vine, renwang, ironarmor, DefHorse, OffHorse, jadeseal
	local weapon, crossbow, halberd, double, qinggang, axe, gudingdao
	for _, card in ipairs(cards) do
		if card:isKindOf("EightDiagram") then eightdiagram = card:getEffectiveId()
		elseif card:isKindOf("SilverLion") then silverlion = card:getEffectiveId()
		elseif card:isKindOf("Vine") then vine = card:getEffectiveId()
		elseif card:isKindOf("RenwangShield") then renwang = card:getEffectiveId()
		elseif card:isKindOf("IronArmor") then ironarmor = card:getEffectiveId()

		elseif card:isKindOf("DefensiveHorse") and not self:getSameEquip(card) then DefHorse = card:getEffectiveId()
		elseif card:isKindOf("OffensiveHorse") and not self:getSameEquip(card) then OffHorse = card:getEffectiveId()

		elseif card:isKindOf("Crossbow") then crossbow = card
		elseif card:isKindOf("DoubleSword") then double = card:getEffectiveId()
		elseif card:isKindOf("QinggangSword") then qinggang = card:getEffectiveId()
		elseif card:isKindOf("Axe") then axe = card:getEffectiveId()
		elseif card:isKindOf("GudingBlade") then gudingdao = card:getEffectiveId()
		elseif card:isKindOf("Halberd") then halberd = card:getEffectiveId()

		elseif card:isKindOf("JadeSeal") then jadeseal = card:getEffectiveId()  end

		if not weapon and card:isKindOf("Weapon") then weapon = card:getEffectiveId() end
	end

	if eightdiagram then
		if not self.player:hasSkill("bazhen") and self.player:hasSkills("tiandu|leiji|hongyan|tiandu_GuoJia_LB") and not self:getSameEquip(card) then
			return eightdiagram
		end
		if NextPlayerisEnemy and NextPlayer:hasShownSkills("tiandu|leiji|hongyan|tiandu_GuoJia_LB") and not self:getSameEquip(card, NextPlayer) then
			return eightdiagram
		end
	end

	if silverlion then
		local lightning, canRetrial
		for _, aplayer in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if aplayer:hasShownSkill("leiji") and self:isEnemy(aplayer) then  --源码忘记加Shown
				return silverlion
			end
			if aplayer:containsTrick("lightning") then
				lightning = true
			end
			if aplayer:hasShownSkills("guicai|guidao|GuicaiLB") and self:isEnemy(aplayer) then
				canRetrial = true
			end
		end
		if lightning and canRetrial then return silverlion end
		if self.player:isChained() then
			for _, friend in ipairs(self.friends) do
				if friend:hasArmorEffect("Vine") and friend:isChained() then
					return silverlion
				end
			end
		end
		if self.player:isWounded() then return silverlion end
	end

	if vine then
		if sgs.ai_armor_value.Vine(self.player, self) > 0 and self.room:alivePlayerCount() <= 3 then
			return vine
		end
	end

	if renwang then
		if sgs.ai_armor_value.RenwangShield(self.player, self) > 0 and self:getCardsNum("Jink") == 0 then return renwang end
	end

	if ironarmor then
		for _, enemy in ipairs(self.enemies) do
			if enemy:hasShownSkill("huoji") then return ironarmor end
			if getCardsNum("FireAttack", enemy, self.player) > 0 then return ironarmor end
			if getCardsNum("FireSlash", enemy, self.player) > 0 then return ironarmor end
			if enemy:getFormation():contains(self.player) and getCardsNum("BurningCamps", enemy, self.player) > 0 then return ironarmor end
		end
	end

	if DefHorse and (not self.player:hasSkill("leiji") or self:getCardsNum("Jink") == 0) then
		local before_num, after_num = 0, 0
		for _, enemy in ipairs(self.enemies) do
			if enemy:canSlash(self.player, nil, true) then
				before_num = before_num + 1
			end
			if enemy:canSlash(self.player, nil, true, 1) then
				after_num = after_num + 1
			end
		end
		if before_num > after_num and (self:isWeak() or self:getCardsNum("Jink") == 0) then return DefHorse end
	end

	if jadeseal then
		for _, friend in ipairs(self.friends) do
			if not (friend:getTreasure() and friend:getPile("wooden_ox"):length() > 1) then return jadeseal end
		end
	end

	if analeptic then
		local slashes = self:getCards("Slash")
		for _, enemy in ipairs(self.enemies) do
			local hit_num = 0
			for _, slash in ipairs(slashes) do
				if self:slashIsEffective(slash, enemy) and self.player:canSlash(enemy, slash) and self:slashIsAvailable() then
					hit_num = hit_num + 1
					if getCardsNum("Jink", enemy, self.player) < 1
						or enemy:isKongcheng()
						or self:canLiegong(enemy, self.player)
						or self:canZhaxiang(self.player)
						or self.player:hasSkills("tieqi|wushuang|qianxi|TieqiLB|wushuang_LyuBu_LB|wushuang_ShenLyuBu|QianxiRE")
						or (self.player:hasSkill("PojunRE") and enemy:getHandcardNum() <= enemy:getHp())
						or (self.player:hasWeapon("Axe") or self:getCardsNum("Axe") > 0) and self.player:getCards("he"):length() > 4
						then
						return analeptic
					end
				end
			end
			if self:hasCrossbowEffect(self.player) and hit_num >= 2 then return analeptic end
		end
	end

	if weapon and (self:getCardsNum("Slash") > 0 and self:slashIsAvailable() or not SelfisCurrent) then
		local current_range = (self.player:getWeapon() and sgs.weapon_range[self.player:getWeapon():getClassName()]) or 1
		local nosuit_slash = sgs.cloneCard("slash", sgs.Card_NoSuit, 0)
		local slash = SelfisCurrent and self:getCard("Slash") or nosuit_slash

		self:sort(self.enemies, "defense")

		if crossbow then
			if #self:getCards("Slash") > 1 or self.player:hasSkills("kurou|keji|keji_LyuMeng_LB")
				or (self.player:hasSkills("luoshen|guzheng|Luoying") and not SelfisCurrent and self.room:alivePlayerCount() >= 4) then
				return crossbow:getEffectiveId()
			end
			if self.player:hasSkill("Guixin") and self.room:alivePlayerCount() >= 6 and (self.player:getHp() > 1 or self:getCardsNum("Peach") > 0) then
				return crossbow:getEffectiveId()
			end
			if self.player:hasSkills("rende|RendeLB") then
				for _, friend in ipairs(self.friends_noself) do
					if getCardsNum("Slash", friend, self.player) > 1 then
						return crossbow:getEffectiveId()
					end
				end
			end
			if self:isEnemy(NextPlayer) then
				local CanSave, huanggai, zhenji
				for _, enemy in ipairs(self.enemies) do
					if enemy:hasShownSkills("jijiu|jijiu_HuaTuo_LB") and getKnownCard(enemy, self.player, "red", nil, "he") > 1 then CanSave = true end
					if enemy:hasShownSkill("kurou") then huanggai = enemy end
					if enemy:hasShownSkills("keji|keji_LyuMeng_LB") then return crossbow:getEffectiveId() end
					if enemy:hasShownSkills("luoshen|guzheng") then return crossbow:getEffectiveId() end
					if enemy:hasShownSkill("Luoying") and crossbow:getSuit() ~= sgs.Card_Club then return crossbow:getEffectiveId() end  --源码的card应该打错
				end
				if huanggai then
					if huanggai:getHp() > 2 then return crossbow:getEffectiveId() end
					if CanSave then return crossbow:getEffectiveId() end
				end
				if getCardsNum("Slash", NextPlayer, self.player) >= 3 and NextPlayerisEnemy then return crossbow:getEffectiveId() end
			end
		end

		if halberd then
--@todo
		end

		if gudingdao then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, slash, true, range_fix) and enemy:isKongcheng() and
					(not SelfisCurrent or (self:getCardsNum("Dismantlement") > 0 or (self:getCardsNum("Snatch") > 0 and self.player:distanceTo(enemy) == 1))) then
					return gudingdao
				end
			end
		end

		if axe then
			local range_fix = current_range - 3
			local FFFslash = self:getCard("FireSlash")
			for _, enemy in ipairs(self.enemies) do
				if (enemy:hasArmorEffect("Vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or (enemy:hasShownSkill("Ranshang") and not enemy:hasShownSkill("hongfa"))) and FFFslash and self:slashIsEffective(FFFslash, enemy) and
					self.player:getCardCount(true) >= 3 and self.player:canSlash(enemy, FFFslash, true, range_fix) then
					return axe
				elseif self:getCardsNum("Analeptic") > 0 and self.player:getCardCount(true) >= 4 and
					self:slashIsEffective(slash, enemy) and self.player:canSlash(enemy, slash, true, range_fix) then
					return axe
				end
			end
		end

		if double then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:getGender() ~= enemy:getGender() and self.player:canSlash(enemy, nil, true, range_fix) then
					return double
				end
			end
		end

		if qinggang then
			local range_fix = current_range - 2
			for _, enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, slash, true, range_fix) and self:slashIsEffective(slash, enemy, self.player, true) then
					return qinggang
				end
			end
		end

	end

	local classNames = { "Snatch", "Dismantlement", "Indulgence", "SupplyShortage", "Collateral", "Duel", "Drowning", "ArcheryAttack", "SavageAssault", "FireAttack",
							"GodSalvation", "Lightning" }
	local className2objectName = { Snatch = "snatch", Dismantlement = "dismantlement", Indulgence = "indulgence", SupplyShortage = "supply_shortage", Collateral = "collateral",
									Duel = "duel", Drowning = "drowning", ArcheryAttack = "archery_attack", SavageAssault = "savage_assault", FireAttack = "fire_attack",
									GodSalvation = "god_salvation", Lightning = "lightning" }
	local new_enemies = {}
	if #self.enemies > 0 then new_enemies = self.enemies
	else
		for _, aplayer in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if not string.find(self:evaluateKingdom(aplayer), self.player:getKingdom()) then
				table.insert(new_enemies, aplayer)
			end
		end
	end
	if not self:willSkipPlayPhase() or not NextPlayerCanUse then
		for _, className in ipairs(classNames) do
			for _, card in ipairs(cards) do
				if isCard(className, card, self.player) then
					local card_x = className ~= card:getClassName() and sgs.cloneCard(className2objectName[className], card:getSuit(), card:getNumber()) or card
					self.enemies = new_enemies
					local dummy_use = { isDummy = true }
					self:useTrickCard(card_x, dummy_use)
					self:updatePlayers(false)
					if dummy_use.card then return card end
				end
			end
		end
	elseif #trickcard > nextfriend_num + 1 and NextPlayerCanUse then
		for i = #classNames, 1, -1 do
			className = classNames[i]
			for _, card in ipairs(cards) do
				if isCard(className, card, self.player) then
					local card_x = className ~= card:getClassName() and sgs.cloneCard(className2objectName[className], card:getSuit(), card:getNumber()) or card
					self.enemies = new_enemies
					local dummy_use = { isDummy = true }
					self:useTrickCard(card_x, dummy_use)
					self:updatePlayers(false)
					if dummy_use.card then return card end
				end
			end
		end
	end

	if weapon and not self.player:getWeapon() and self:getCardsNum("Slash") > 0 and (self:slashIsAvailable() or not SelfisCurrent) then
		local inAttackRange
		for _, enemy in ipairs(self.enemies) do
			if self.player:inMyAttackRange(enemy) then
				inAttackRange = true
				break
			end
		end
		if not inAttackRange then return weapon end
	end

	if eightdiagram or silverlion or vine or renwang or ironarmor then
		return renwang or eightdiagram or ironarmor or silverlion or vine
	end

	self:sortByCardNeed(cards, true)
	for _, card in ipairs(cards) do
		if not card:isKindOf("TrickCard") and not card:isKindOf("Peach") then
			return card:getEffectiveId()
		end
	end

	return cards[1]:getEffectiveId()
end
function sgs.isJinkAvailable(from, to, slash, judge_considered)				--搬运
	return (not judge_considered and from:hasShownSkills("tieqi|TieqiLB"))
			or (from:hasShownSkill("liegong") and from:getPhase() == sgs.Player_Play
				and (to:getHandcardNum() <= from:getAttackRange() or to:getHandcardNum() >= from:getHp()))
			--or (from:hasFlag("ZhaxiangInvoked") and slash and slash:isRed())
end
function sgs.getDefenseSlash(player, self)									--非锁无效（todo：搬运至sgs.getDefense）、急救、无双、仁德、奸雄、遗计、天妒、
																			--归心、燃殇、潜袭、义绝、铁骑、RE破军、龙魂
	if not player or not self then global_room:writeToConsole(debug.traceback()) return 0 end
	local attacker = self.player
	local unknownJink = getCardsNum("Jink", player, attacker)
	local defense = unknownJink

	local knownJink = getKnownCard(player, attacker, "Jink", true, "he")
	
	local canPojunREArmor = false
	if attacker:hasShownSkill("PojunRE") and attacker:getPhase() == sgs.Player_Play and not self:isFriend(attacker, player) and player:getHp() > 0 and not player:isNude() then
		canPojunREArmor = player:getArmor() and not self:hasSkill(sgs.viewhas_armor_skill, player)
		local pojun_ratio = (math.min(player:getHp(), player:getCardCount(true)) - (player:getArmor() and 1 or 0)) / player:getHandcardNum()
		if pojun_ratio > 1 then pojun_ratio = 1 end  --能被移走的手牌比例（如5手牌2血则为2/5）
		unknownJink = unknownJink * (1 - pojun_ratio)
		knownJink = knownJink * (1 - pojun_ratio)
	end

	if sgs.card_lack[player:objectName()]["Jink"] == 1 and knownJink == 0 then defense = 0 end

	defense = defense + knownJink * 1.2

	if attacker:canSlashWithoutCrossbow() and attacker:getPhase() == sgs.Player_Play then
		local hcard = player:getHandcardNum()
		if attacker:hasShownSkill("liegong") and (hcard >= attacker:getHp() or hcard <= attacker:getAttackRange()) then defense = 0 end
	end

	local niaoxiang_BA = false
	local jiangqin = sgs.findPlayerByShownSkillName("niaoxiang")
	if jiangqin then
		if jiangqin:inSiegeRelation(jiangqin, player) then
			niaoxiang_BA = true
		end
	end
	local need_double_jink = attacker:hasShownSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") or niaoxiang_BA
	if need_double_jink and knownJink < 2 and unknownJink < 1.5 then
		defense = 0
	end

	local jink = sgs.cloneCard("jink")
	if player:isCardLimited(jink, sgs.Card_MethodUse) then defense = 0 end
	
	if player:getMark("Yijue") > 0 then defense = 0 end
	if attacker:hasShownSkill("TieqiLB") and not self:isFriend(attacker, player) then defense = defense * 0.2 end

	if player:hasFlag("QianxiTarget") or player:hasFlag("QianxiRETarget") then
		local red = player:getMark("@qianxi_red") > 0
		local black = player:getMark("@qianxi_black") > 0
		if red then
			if player:hasShownSkill("qingguo") or (player:hasShownSkill("Longhun") and player:getHp() <= 1) then
				defense = defense - 1
			else
				defense = 0
			end
		end
		if black then  --源码是elseif black then，这里拆成两段是考虑到马岱/RE马岱双将
			if player:hasShownSkill("qingguo") or (player:hasShownSkill("Longhun") and player:getHp() <= 1) then
				defense = defense - 1
			end
		end
	end

	defense = defense + math.min(player:getHp() * 0.45, 10)
	if sgs.isAnjiang(player) then defense = defense - 1 end
	
	--插入关于非锁无效的处理（只处理预估可以非锁无效的，因为已经无效的话hasShownSkill和hasNullSkill会自动处理）
	local nonCompInvalid = false
	if attacker:hasShownSkill("TieqiLB") and not player:hasShownSkills("liuli|xiangle|liuli_DaQiao_LB") then
		nonCompInvalid = true
	elseif player:getMark("Yijue") > 0 then
		nonCompInvalid = true
	elseif attacker:hasShownSkill("Yijue") and (attacker:getPhase() == sgs.Player_Play) and not attacker:hasUsed("#YijueCard") and not attacker:isKongcheng() then
		--local max_point = 0
		--for _,cd in sgs.qlist(attacker:getHandcards()) do
		--	max_point = math.max(pax_point, cd:getNumber())
		--end
		--if max_point >= 10 then nonCompInvalid = true end]]  --未知错误
		nonCompInvalid = true
	end
	if self:isFriend(player, attacker) then nonCompInvalid = false end

	local hasEightDiagram = false

	if (player:hasArmorEffect("EightDiagram") or (player:hasShownSkill("bazhen") and not player:getArmor()))
	  and not IgnoreArmor(attacker, player) and not canPojunREArmor then
		hasEightDiagram = true
	end

	--以下各段加入对nonCompInvalid的判断
	if hasEightDiagram then
		defense = defense + 1.3
		if player:hasShownSkills("qingguo+tiandu|qingguo+tiandu_GuoJia_LB") then defense = defense + (nonCompInvalid and 0.6 or 10)
		elseif player:hasShownSkills("tiandu|tiandu_GuoJia_LB") then defense = defense + (nonCompInvalid and 0 or 0.6) end
		if player:hasShownSkill("leiji") then defense = defense + (nonCompInvalid and 0 or 0.4) end
		if player:hasShownSkill("hongyan") then defense = defense + 0.2 end
	end

	if player:hasShownSkill("tuntian") and player:hasShownSkill("jixi") and unknownJink >= 1 and not nonCompInvalid then
		defense = defense + 1.5
	end

	if attacker and not nonCompInvalid then
		local m = sgs.masochism_skill:split("|")
		for _, masochism in ipairs(m) do
			if player:hasShownSkill(masochism) and sgs.isGoodHp(player, self.player) then
				defense = defense + 1
			end
		end
		if player:hasShownSkill("jieming") then defense = defense + 4 end
		if player:hasShownSkills("yiji|YijiLB") then defense = defense + 4 end
		if player:hasShownSkill("Guixin") then defense = defense + 4 end
		if player:hasShownSkill("JianxiongLB") then defense = defense + 2 end
	end

	if not sgs.isGoodTarget(player, nil, self) then defense = defense + 10 end

	if player:hasShownSkills("rende|RendeLB") and player:getHp() > 2 then defense = defense + 1 end
	if player:hasShownSkill("kuanggu") and player:getHp() > 1 then defense = defense + 0.2 end
	if player:hasShownSkill("zaiqi") and player:getHp() > 1 then defense = defense + 0.35 end

	if player:getHp() <= 2 then defense = defense - 0.4 end

	local playernum = global_room:alivePlayerCount()
	if (player:getSeat()-attacker:getSeat()) % playernum >= playernum-2 and playernum>3 and player:getHandcardNum()<=2 and player:getHp()<=2 then
		defense = defense - 0.4
	end

	if player:hasShownSkill("tianxiang") and not nonCompInvalid then defense = defense + player:getHandcardNum() * 0.5 end
	local isInPile = function()
		for _,pile in sgs.list(player:getPileNames())do
			if pile:startsWith("&") or pile == "wooden_ox" then
				if not player:getPile(pile):isEmpty() then
					return false
				end
			end
		end
		return true
	end
	if player:getHandcardNum() == 0 and player:getHandPile():isEmpty() and not player:hasShownSkills("kongcheng") then
		if player:getHp() <= 1 then defense = defense - 2.5 end
		if player:getHp() == 2 then defense = defense - 1.5 end
		if not hasEightDiagram then defense = defense - 2 end
	end

	local has_fire_slash
	local cards = sgs.QList2Table(attacker:getHandcards())
	for i = 1, #cards, 1 do
		if (attacker:hasWeapon("Fan") and cards[i]:objectName() == "slash" and not cards[i]:isKindOf("ThunderSlash")) or cards[i]:isKindOf("FireSlash")  then
			has_fire_slash = true
			break
		end
	end

	if (player:hasArmorEffect("Vine") and not IgnoreArmor(attacker, player)) or (player:hasShownSkill("Ranshang") and not player:hasShownSkill("hongfa")) and has_fire_slash then
		defense = defense - 0.6
	end

	if player:hasTreasure("JadeSeal") then defense = defense - 0.5 end

	if not player:faceUp() then defense = defense - 0.35 end

	if player:containsTrick("indulgence") then defense = defense - 0.15 end
	if player:containsTrick("supply_shortage") then defense = defense - 0.15 end

	if not hasEightDiagram then
		if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") then
			defense = defense - 3
		elseif sgs.hasNullSkill("jijiu", player) or sgs.hasNullSkill("jijiu_HuaTuo_LB", player) then
			defense = defense - 4
		end
		if player:hasShownSkill("dimeng") then
			defense = defense - 2.5
		elseif sgs.hasNullSkill("dimeng", player) then
			defense = defense - 3.5
		end
		if player:hasShownSkill("guzheng") and knownJink == 0 then
			defense = defense - 2.5
		elseif sgs.hasNullSkill("guzheng", player) and knownJink == 0 then
			defense = defense - 3.5
		end
		if player:hasShownSkill("qiaobian") then
			defense = defense - 2.4
		elseif sgs.hasNullSkill("qiaobian", player) then
			defense = defense - 3.4
		end
		if player:hasShownSkill("jieyin") then
			defense = defense - 2.3
		elseif sgs.hasNullSkill("jieyin", player) then
			defense = defense - 3.3
		end
		if player:hasShownSkill("lijian") then
			defense = defense - 2.2
		elseif sgs.hasNullSkill("lijian", player) then
			defense = defense - 3.2
		end

		local m = sgs.masochism_skill:split("|")
		for _, masochism in ipairs(m) do
			if sgs.hasNullSkill(masochism, player) then
				defense = defense - 1
			end
		end

	end
	return defense
end
function SmartAI:slashIsEffective(slash, to, from, ignore_armor)			--DisableOtherTargets、同疾、智迟、RE破军
	if not slash or not to then self.room:writeToConsole(debug.traceback()) return end
	from = from or self.player
	if to:hasShownSkill("kongcheng") and to:isKongcheng() then return false end
	if to:isRemoved() then return false end
	if from:hasFlag("DisableOtherTargets") then return false end
	if (to:getMark("@late") > 0) then return false end
	
	for _,yuanshu in sgs.qlist(self.room:getOtherPlayers(from)) do
		if yuanshu:hasShownSkill("Tongji") and (yuanshu:getHandcardNum() > yuanshu:getHp()) and from:inMyAttackRange(yuanshu) and (yuanshu:objectName() ~= to:objectName()) then
			return false
		end
	end

	local nature = sgs.Slash_Natures[slash:getClassName()]
	local damage = {}
	damage.from = from
	damage.to = to
	damage.nature = nature
	damage.damage = 1
	if not from:hasShownAllGenerals() and to:hasShownSkill("mingshi") then
		local dummy_use = { to = sgs.SPlayerList() }
		dummy_use.to:append(to)
		local analeptic = self:searchForAnaleptic(dummy_use, to, slash)
		if analeptic and self:shouldUseAnaleptic(to, dummy_use, analeptic) and analeptic:getEffectiveId() ~= slash:getEffectiveId() then
			damage.damage = damage.damage + 1
		end
	end
	damage.card = slash  --自行加入，使得damageIsEffective_中能辨别出造成伤害的牌是杀
	if not self:damageIsEffective_(damage) then return false end

	if to:hasSkill("jgyizhong") and not to:getArmor() and slash:isBlack() then
		if (from:hasWeapon("DragonPhoenix") or from:hasWeapon("DoubleSword") and (from:isMale() and to:isFemale() or from:isFemale() or to:isMale()))
			and (to:getCardCount(true) == 1 or #self:getEnemies(from) == 1) then
		else
			return false
		end
	end
	
	if not ignore_armor and  to:hasArmorEffect("IronArmor") and slash:isKindOf("FireSlash") then return false end

	if not (ignore_armor or IgnoreArmor(from, to) or (from:hasShownSkill("PojunRE") and from:getPhase() == sgs.Player_Play and to:getHp() > 0 and not to:hasShownSkills(sgs.viewhas_armor_skill))) then
		if to:hasArmorEffect("RenwangShield") and slash:isBlack() then
			if (from:hasWeapon("DragonPhoenix") or from:hasWeapon("DoubleSword") and (from:isMale() and to:isFemale() or from:isFemale() or to:isMale()))
				and (to:getCardCount(true) == 1 or #self:getEnemies(from) == 1) then
			else
				return false
			end
		end

		if to:hasArmorEffect("Vine") and not slash:isKindOf("NatureSlash") then
			if (from:hasWeapon("DragonPhoenix") or from:hasWeapon("DoubleSword") and (from:isMale() and to:isFemale() or from:isFemale() or to:isMale()))
				and (to:getCardCount(true) == 1 or #self:getEnemies(from) == 1) then
			else
				local skill_name = slash:getSkillName() or ""
				local can_convert = false
				local skill = sgs.Sanguosha:getSkill(skill_name)
				if not skill or skill:inherits("FilterSkill") then
					can_convert = true
				end
				if not can_convert or not from:hasWeapon("Fan") then return false end
			end
		end
	end

	if slash:isKindOf("ThunderSlash") then
		local f_slash = self:getCard("FireSlash")
		if f_slash and self:hasHeavySlashDamage(from, f_slash, to, true) > self:hasHeavySlashDamage(from, slash, to, true)
			and (not to:isChained() or self:isGoodChainTarget(to, from, sgs.DamageStruct_Fire, nil, f_slash)) then
			return self:slashProhibit(f_slash, to, from)
		end
	elseif slash:isKindOf("FireSlash") then
		local t_slash = self:getCard("ThunderSlash")
		if t_slash and self:hasHeavySlashDamage(from, t_slash, to, true) > self:hasHeavySlashDamage(from, slash, to, true)
			and (not to:isChained() or self:isGoodChainTarget(to, from, sgs.DamageStruct_Thunder, nil, t_slash)) then
			return self:slashProhibit(t_slash, to, from)
		end
	end

	return true
end
function SmartAI:useCardSlash(card, use)									--求援、巧说、克己、耀武、乱战、无前
	if not use.isDummy and not self:slashIsAvailable(self.player, card) then return end
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, card) > 50
						or self.player:hasFlag("slashNoDistanceLimit")
						or card:getSkillName() == "Qiaoshui"
	self.slash_targets = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card)
	if self.player:hasSkill("duanbing") and self:willShowForAttack() then self.slash_targets = self.slash_targets + 1 end
	if self.player:hasFlag("HalberdUse") then self.slash_targets = self.slash_targets + 99 end
	local rangefix = 0
	if card:isVirtualCard() then
		if self.player:getWeapon() and card:getSubcards():contains(self.player:getWeapon():getEffectiveId()) then
			if self.player:getWeapon():getClassName() ~= "Weapon" then
				rangefix = sgs.weapon_range[self.player:getWeapon():getClassName()] - self.player:getAttackRange(false)
			end
		end
		if self.player:getOffensiveHorse() and card:getSubcards():contains(self.player:getOffensiveHorse():getEffectiveId()) then
			rangefix = rangefix + 1
		end
	end

	local function canAppendTarget(target)
		if not self:isWeak(target) and self:hasSkills("keji|keji_LyuMeng_LB") and not self.player:hasFlag("KejiSlashInPlayPhase") and self:getOverflow() > 2
			and self:getCardsNum("Crossbow", "he") == 0 then return end
		if self.player:hasSkill("qingnang") and not self.player:hasUsed("QingnangCard") and self:isWeak() and self.player:getHandcardNum() <= 2
			and (target:getHp() > 1 or getCardsNum("Peach", target, self.player) + getCardsNum("Peach", target, self.player) > 0) then return end
		local targets = sgs.PlayerList()
		if use.to and not use.to:isEmpty() then
			if use.to:contains(target) then return false end
			for _, to in sgs.qlist(use.to) do
				targets:append(to)
			end
		end
		return card:targetFilter(targets, target, self.player)
	end

	for _, friend in ipairs(self.friends_noself) do
		if self:isPriorFriendOfSlash(friend, card) and not self:slashProhibit(card, friend) then
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))		--current_targets 是原目标
				and (self.player:canSlash(friend, card, not no_distance, rangefix)
				or (use.isDummy and (self.player:distanceTo(friend, rangefix) <= self.predictedRange)))
				and self:slashIsEffective(card, friend) then
				use.card = card
				if use.to and canAppendTarget(friend) then
					use.to:append(friend)
				end
				if not use.to or self.slash_targets <= use.to:length() then return end
			end
		end
	end

	local function shouldUseWuqianTo(target)
		return self.player:hasSkill("Wuqian") and self.player:getMark("@wrath") >= 2 and self:willShowForAttack()
							and not target:isLocked(sgs.Sanguosha:cloneCard("jink"))
							and (not self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu")
								or target:getArmor() and target:hasArmorEffect(target:getArmor():objectName()) and not self.player:hasWeapon("QinggangSword"))
							and ((self:hasHeavySlashDamage(self.player, card, target) and (getCardsNum("Jink", target, self.player) > 0 or (target:getArmor() and target:hasArmorEffect(target:getArmor():objectName()) and not self.player:hasWeapon("QinggangSword"))))
								or (getCardsNum("Jink", target, self.player) < 2 and getCardsNum("Jink", target, self.player) >= 1 and target:getHp() <= 2))
	end
	
	local targets = {}
	local forbidden = {}
	self:sort(self.enemies, "defenseSlash")
	for _, enemy in ipairs(self.enemies) do
		if not self:slashProhibit(card, enemy, self.player, shouldUseWuqianTo(enemy)) and sgs.isGoodTarget(enemy, self.enemies, self, true) then
			if self:hasQiuyuanEffect(self.player, enemy) then table.insert(forbidden, enemy)
			elseif not self:getDamagedEffects(enemy, self.player, true) then table.insert(targets, enemy) else table.insert(forbidden, enemy) end
		end
	end
	if #targets == 0 and #forbidden > 0 then targets = forbidden end

	for _, target in ipairs(targets) do
		local canliuli = false
		for _, friend in ipairs(self.friends_noself) do
			if self:canLiuli(target, friend) and self:slashIsEffective(card, friend) and #targets > 1 and friend:getHp() < 3 then canliuli = true end
		end
		local use_wuqian = self.player:hasSkill("Wuqian") and self.player:getMark("@wrath") >= 2 and self:willShowForAttack()
							and not target:isLocked(sgs.Sanguosha:cloneCard("jink"))
							and (not self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu")
								or target:getArmor() and target:hasArmorEffect(target:getArmor():objectName()) and not self.player:hasWeapon("QinggangSword"))
							and ((self:hasHeavySlashDamage(self.player, card, target) and (getCardsNum("Jink", target, self.player) > 0 or (target:getArmor() and target:hasArmorEffect(target:getArmor():objectName()) and not self.player:hasWeapon("QinggangSword"))))
								or (getCardsNum("Jink", target, self.player) < 2 and getCardsNum("Jink", target, self.player) >= 1 and target:getHp() <= 2))
		if (not use.current_targets or not table.contains(use.current_targets, target:objectName()))
			and(self.player:canSlash(target, card, not no_distance, rangefix)
			or (use.isDummy and self.predictedRange and self.player:distanceTo(target, rangefix) <= self.predictedRange))
			and self:objectiveLevel(target) > 3
			and not canliuli
			and not (not self:isWeak(target) and #self.enemies > 1 and #self.friends > 1 and self.player:hasSkills("keji|keji_LyuMeng_LB")
			and self:getOverflow() > 0 and not self:hasCrossbowEffect()) then

			if target:getHp() > 1 and target:hasShownSkills("jianxiong|JianxiongLB") and self.player:hasWeapon("Spear") and card:getSkillName() == "Spear" then
				local ids, isGood = card:getSubcards(), true
				for _, id in sgs.qlist(ids) do
					local c = sgs.Sanguosha:getCard(id)
					if isCard("Peach", c, target) or isCard("Analeptic", c, target) then isGood = false break end
				end
				if not isGood then continue end
			end

			-- fill the card use struct
			local usecard = card
			if not use.to or use.to:isEmpty() then
				if self.player:hasWeapon("Spear") and card:getSkillName() == "Spear" then
				elseif self.player:hasWeapon("Crossbow") and self:getCardsNum("Slash") > 0 then
				elseif not use.isDummy then
					local weapon = self:findWeaponToUse(target)
					if weapon then
						use.card = weapon
						return
					end
				end

				if target:isChained() and self:isGoodChainTarget(target, nil, nil, nil, card) and not use.card then
					if self:hasCrossbowEffect() and card:isKindOf("NatureSlash") then
						for _, slash in ipairs(self:getCards("Slash")) do
							if not slash:isKindOf("NatureSlash") and self:slashIsEffective(slash, target)
								and not self:slashProhibit(slash, target) then
								usecard = slash
								break
							end
						end
					elseif not card:isKindOf("NatureSlash") then
						local slash = self:getCard("NatureSlash")
						if slash and self:slashIsEffective(slash, target) and not self:slashProhibit(slash, target) then usecard = slash end
					end
				end
				local godsalvation = self:getCard("GodSalvation")
				if not use.isDummy and godsalvation and godsalvation:getId() ~= card:getId() and self:willUseGodSalvation(godsalvation) and
					(not target:isWounded() or not self:hasTrickEffective(godsalvation, target, self.player)) then
					use.card = godsalvation
					return
				end
			end

			if not use.isDummy then
				local analeptic = self:searchForAnaleptic(use, target, use.card or usecard)
				if analeptic and self:shouldUseAnaleptic(target, use, analeptic) and analeptic:getEffectiveId() ~= card:getEffectiveId() then
					use.card = analeptic
					if use.to then use.to = sgs.SPlayerList() end
					return
				end
				if use_wuqian then
					use.card = sgs.Card_Parse("#WuqianCard:.:&Wuqian")
					if use.to then use.to = sgs.SPlayerList() use.to:append(target) end
					return
				end
			end

			use.card = use.card or usecard
			if use.to and canAppendTarget(target) then use.to:append(target) end
			if not use.to or self.slash_targets <= use.to:length() then return end
		end
	end

	for _, friend in ipairs(self.friends_noself) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))
			and not self:slashProhibit(card, friend) and not self:hasHeavySlashDamage(self.player, card, friend)
			and (self:getDamagedEffects(friend, self.player) or self:needToLoseHp(friend, self.player, true, true) or self:hasYaowuEffect(friend, card, true, self.player))  --耀武（队友杀华雄回血）
			and (self.player:canSlash(friend, card, not no_distance, rangefix)
			or (use.isDummy and self.predictedRange and self.player:distanceTo(friend, rangefix) <= self.predictedRange)) then
			use.card = card
			if use.to and canAppendTarget(friend) then use.to:append(friend) end
			if not use.to or self.slash_targets <= use.to:length() then return end
		end
	end
	
	if self.player:hasShownSkill("Luanzhan") and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then
		for _, enemy in ipairs(self.enemies) do  --需要将目标撑到X
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))
				and (self.player:canSlash(enemy, card, not no_distance, rangefix)
				or (use.isDummy and self.predictedRange and self.player:distanceTo(enemy, rangefix) <= self.predictedRange))
				and not self:slashIsEffective(card, enemy) then
				if canAppendTarget(enemy) then use.to:append(enemy) end
				if self.slash_targets <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName()))
				and (self.player:canSlash(target, card, not no_distance, rangefix)
				or (use.isDummy and self.predictedRange and self.player:distanceTo(target, rangefix) <= self.predictedRange))
				and not self:slashIsEffective(card, target) then
				if canAppendTarget(target) then use.to:append(target) end
				if self.slash_targets <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
end
sgs.ai_skill_use.slash = function(self, prompt)								--陷嗣、仁德
	if prompt == "@Halberd" then
		local ret = sgs.ai_skill_cardask["@Halberd"](self)
		return ret or "."
	end

	local parsedPrompt = prompt:split(":")
	local callback = sgs.ai_skill_cardask[parsedPrompt[1]] -- for askForUseSlashTo
	if self.player:hasFlag("slashTargetFixToOne") and type(callback) == "function" then
		local slash
		local target
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if player:hasFlag("SlashAssignee") then target = player break end
		end
		local target2 = nil
		if #parsedPrompt >= 3 then target2 = findPlayerByObjectName(parsedPrompt[3]) end
		if not target then return "." end
		local ret = callback(self, nil, nil, target, target2, prompt)
		if ret == nil or ret == "." then return "." end
		slash = sgs.Card_Parse(ret)
		assert(slash)
		if slash:isKindOf("HalberdCard") then return ret  --源码写成HalbedrCard也是醉了
		elseif not self.player:hasFlag("Global_HalberdFailed") and self.player:getMark("Equips_Nullified_to_Yourself") == 0 and self.player:hasWeapon("Halberd") then
			local HalberdCard = sgs.Card_Parse("@HalberdCard=.")
			assert(HalberdCard)
			return "@HalberdCard=."
		end
		local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, slash) > 50 or self.player:hasFlag("slashNoDistanceLimit")
		local targets = {}
		local use = { to = sgs.SPlayerList() }
		if self.player:canSlash(target, slash, not no_distance) then use.to:append(target) else return "." end

		if target:hasShownSkill("Xiansi") and target:getPile("counter"):length() > 1
			and not (self:needKongcheng() and self.player:isLastHandCard(slash, true)) then
			local ints = sgs.QList2Table(target:getPile("counter"))
			local a, b = ints[1], ints[2]
			if a and b then
				return "#XiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&->" .. target:objectName()
			end
		end  --应该有更好的写法（考虑到13-15年AI应该有更新，怀疑在ai_cardview_valuable），但是似乎无法做到只选择一个特定目标……
		
		self:useCardSlash(slash, use)
		for _, p in sgs.qlist(use.to) do table.insert(targets, p:objectName()) end
		if table.contains(targets, target:objectName()) then return ret .. "->" .. table.concat(targets, "+") end
		return "."
	end
	local useslash, target
	local slashes = self:getCards("Slash")
	self:sortByUseValue(slashes)
	self:sort(self.enemies, "defenseSlash")
	for _, slash in ipairs(slashes) do
		local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, slash) > 50 or self.player:hasFlag("slashNoDistanceLimit")
		for _, friend in ipairs(self.friends_noself) do
			if not self:hasHeavySlashDamage(self.player, slash, friend)
				and self.player:canSlash(friend, slash, not no_distance) and not self:slashProhibit(slash, friend)
				and self:slashIsEffective(slash, friend)
				and (self:findLeijiTarget(friend, 50, self.player) or (friend:hasShownSkill("jieming") and self.player:hasSkills("rende|RendeLB")))
				and not (self.player:hasFlag("slashTargetFix") and not friend:hasFlag("SlashAssignee"))
				and not (slash:objectName() == "XiansiSlashCard" and friend:getPile("counter"):length() < 2) then

				useslash = slash
				target = friend
				break
			end
		end
	end
	if not useslash then
		for _, slash in ipairs(slashes) do
			local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, slash) > 50 or self.player:hasFlag("slashNoDistanceLimit")
			for _, enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, slash, not no_distance) and not self:slashProhibit(slash, enemy)
					and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
					and not (self.player:hasFlag("slashTargetFix") and not enemy:hasFlag("SlashAssignee")) then

					useslash = slash
					target = enemy
					break
				end
			end
		end
	end
	if useslash and target then
		local targets = {}
		local use = { to = sgs.SPlayerList() }
		use.to:append(target)

		if target:hasShownSkill("Xiansi") and target:getPile("counter"):length() > 1 and not (self:needKongcheng() and self.player:isLastHandCard(slash, true)) then
			local ints = sgs.QList2Table(target:getPile("counter"))
			local a, b = ints[1], ints[2]
			if a and b then
				return "#XiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&->" .. target:objectName()
			end
		end
		
		self:useCardSlash(useslash, use)
		for _, p in sgs.qlist(use.to) do table.insert(targets, p:objectName()) end
		if table.contains(targets, target:objectName()) then return useslash:toString() .. "->" .. table.concat(targets, "+") end
	end
	return "."
end
function SmartAI:useCardCollateral(card, use)								--巧说（防止新加目标与原有目标重复）、界陆逊、咆哮
	local fromList = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	local toList = sgs.QList2Table(self.room:getAlivePlayers())

	local cmp = function(a, b)
		local alevel = self:objectiveLevel(a)
		local blevel = self:objectiveLevel(b)

		if alevel ~= blevel then return alevel > blevel end

		local anum = getCardsNum("Slash", a, self.player)
		local bnum = getCardsNum("Slash", b, self.player)

		if anum ~= bnum then return anum < bnum end
		return a:getHandcardNum() < b:getHandcardNum()
	end

	table.sort(fromList, cmp)
	self:sort(toList, "defense")

	local needCrossbow = false
	for _, enemy in ipairs(self.enemies) do
		if self.player:canSlash(enemy) and self:objectiveLevel(enemy) > 3
			and sgs.isGoodTarget(enemy, self.enemies, self) and not self:slashProhibit(nil, enemy) then
			needCrossbow = true
			break
		end
	end

	needCrossbow = needCrossbow and self:getCardsNum("Slash") > 2 and not self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao")

	if needCrossbow then
		for i = #fromList, 1, -1 do
			local friend = fromList[i]
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and friend:getWeapon() and friend:getWeapon():isKindOf("Crossbow") and self:hasTrickEffective(card, friend) then
				for _, enemy in ipairs(toList) do
					if friend:canSlash(enemy, nil) and friend:objectName() ~= enemy:objectName() then
						if not use.isDummy then self.room:setPlayerFlag(self.player, "AI_needCrossbow") end
						use.card = card
						if use.to then use.to:append(friend) end
						if use.to then use.to:append(enemy) end
						return
					end
				end
			end
		end
	end

	local n = nil
	local final_enemy = nil
	for _, enemy in ipairs(fromList) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
			and self:hasTrickEffective(card, enemy)
			and not enemy:hasShownSkills(sgs.lose_equip_skill)
			and not (enemy:hasShownSkill("weimu") and card:isBlack())  --源码忘记Shown
			and not enemy:hasShownSkill("tuntian")  --源码忘记Shown
			and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)))  --界陆逊
			and self:objectiveLevel(enemy) >= 0
			and enemy:getWeapon() then

			for _, enemy2 in ipairs(toList) do
				if enemy:canSlash(enemy2) and self:objectiveLevel(enemy2) > 3 and enemy:objectName() ~= enemy2:objectName() then
					n = 1
					final_enemy = enemy2
					break
				end
			end

			if not n then
				for _, enemy2 in ipairs(toList) do
					if enemy:canSlash(enemy2) and self:objectiveLevel(enemy2) <=3 and self:objectiveLevel(enemy2) >=0 and enemy:objectName() ~= enemy2:objectName() then
						n = 1
						final_enemy = enemy2
						break
					end
				end
			end

			if not n then
				for _, friend in ipairs(toList) do
					if enemy:canSlash(friend) and self:objectiveLevel(friend) < 0 and enemy:objectName() ~= friend:objectName()
							and (self:needToLoseHp(friend, enemy, true, true) or self:getDamagedEffects(friend, enemy, true)) then
						n = 1
						final_enemy = friend
						break
					end
				end
			end

			if not n then
				for _, friend in ipairs(toList) do
					if enemy:canSlash(friend) and self:objectiveLevel(friend) < 0 and enemy:objectName() ~= friend:objectName()
							and (getKnownCard(friend, self.player, "Jink", true, "he") >= 2 or getCardsNum("Slash", enemy, self.player) < 1) then
						n = 1
						final_enemy = friend
						break
					end
				end
			end

			if n then
				use.card = card
				if use.to then use.to:append(enemy) end
				if use.to then use.to:append(final_enemy) end
				return
			end
		end
		n = nil
	end

	for _, friend in ipairs(fromList) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and friend:getWeapon() and (getKnownCard(friend, self.player, "Slash", true, "he") > 0 or getCardsNum("Slash", friend, self.player) > 1 and friend:getHandcardNum() >= 4)
			and self:hasTrickEffective(card, friend)
			and self:objectiveLevel(friend) < 0 then

			for _, enemy in ipairs(toList) do
				if friend:canSlash(enemy, nil) and self:objectiveLevel(enemy) > 3 and friend:objectName() ~= enemy:objectName()
						and sgs.isGoodTarget(enemy, self.enemies, self) and not self:slashProhibit(nil, enemy) then
					use.card = card
					if use.to then use.to:append(friend) end
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	end

	self:sort(toList)

	for _, friend in ipairs(fromList) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and friend:getWeapon() and (friend:hasShownSkills(sgs.lose_equip_skill) or (friend:hasShownSkills("QianxunLB+Lianying") and not friend:isNude()))  --界陆逊
			and self:hasTrickEffective(card, friend)
			and self:objectiveLevel(friend) < 0
			and not (friend:getWeapon():isKindOf("Crossbow") and getCardsNum("Slash", friend, self.player) > 1) then

			for _, enemy in ipairs(toList) do
				if friend:canSlash(enemy, nil) and friend:objectName() ~= enemy:objectName() then
					use.card = card
					if use.to then use.to:append(friend) end
					if use.to then use.to:append(enemy) end
					return
				end
			end
		end
	end
end
function SmartAI:useCardSnatchOrDismantlement(card, use)					--巧说（防止新加目标与原有目标重复）、胆守、急救、界陆逊、仁心、乱战、滔乱
	local isSkillCard = card:isKindOf("DanshouCard")  --待加入银铃
	local isJixi = card:getSkillName() == "jixi"
	local isDiscard = (not card:isKindOf("Snatch"))
	local name = card:objectName()
	local players = self.room:getOtherPlayers(self.player)
	local tricks
	local usecard = false

	local targets = {}
	local targets_num = isSkillCard and 1 or (1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card))  --银铃胆守

	local addTarget = function(player, cardid)
		if not table.contains(targets, player:objectName()) 
			and (not use.current_targets or not table.contains(use.current_targets, player:objectName())) then  --巧说
			if not usecard then
				use.card = card
				usecard = true
			end
			table.insert(targets, player:objectName())
			if usecard and use.to and use.to:length() < targets_num then
				use.to:append(player)
				if not use.isDummy then
					sgs.Sanguosha:getCard(cardid):setFlags("AIGlobal_SDCardChosen_" .. name)
				end
			end
			if #targets == targets_num then return true end
		end
	end

	players = self:exclude(players, card)
	if not isSkillCard then
		for _, player in ipairs(players) do
			if not player:getJudgingArea():isEmpty() and (self:hasTrickEffective(card, player) or isSkillCard)  --银铃胆守
				and ((player:containsTrick("lightning") and self:getFinalRetrial(player) == 2) or #self.enemies == 0) then
				tricks = player:getCards("j")
				for _, trick in sgs.qlist(tricks) do
					if trick:isKindOf("Lightning") and (not isDiscard or self.player:canDiscard(player, trick:getId())) then
						local invoke
						for _, p in ipairs(self.friends) do
							if self:hasTrickEffective(trick, p) or isSkillCard then
								invoke = true
								break
							end
						end
						if not invoke then continue end
						if addTarget(player, trick:getEffectiveId()) then return end
					end
				end
			end
		end
	end

	local enemies = {}
	if #self.enemies == 0 and self:getOverflow() > 0 then
		enemies = self:exclude(enemies, card)
		self:sort(enemies, "defense")
		enemies = sgs.reverse(enemies)
		local temp = {}
		for _, enemy in ipairs(enemies) do
			if self:hasTrickEffective(card, enemy) or isSkillCard then  --银铃胆守
				table.insert(temp, enemy)
			end
		end
		enemies = temp
	else
		enemies = self:exclude(self.enemies, card)
		self:sort(enemies, "defense")
		local temp = {}
		for _, enemy in ipairs(enemies) do
			if self:hasTrickEffective(card, enemy) or isSkillCard then  --银铃胆守
				table.insert(temp, enemy)
			end
		end
		enemies = temp
	end

	if self:slashIsAvailable() then
		local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardSlash(sgs.cloneCard("slash"), dummyuse)
		if not dummyuse.to:isEmpty() then
			local tos = self:exclude(dummyuse.to, card)
			for _, to in ipairs(tos) do
				if to:getHandcardNum() == 1 and to:getHp() <= 2 and self:hasLoseHandcardEffective(to) and not to:hasShownSkill("kongcheng")  --源码忘记Shown
					and (not self:hasEightDiagramEffect(to) or IgnoreArmor(self.player, to)) then
					if addTarget(to, to:getRandomHandCardId()) then return end
				end
			end
		end
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() then
			local dangerous = self:getDangerousCard(enemy)
			if dangerous and (not isDiscard or self.player:canDiscard(enemy, dangerous)) then
				if addTarget(enemy, dangerous) then return end
			end
		end
	end

	self:sort(self.friends_noself, "defense")
	local friends = self:exclude(self.friends_noself, card)
	if not isSkillCard then
		for _, friend in ipairs(friends) do
			if (friend:containsTrick("indulgence") or friend:containsTrick("supply_shortage")) then
				local cardchosen
				tricks = friend:getJudgingArea()
				for _, trick in sgs.qlist(tricks) do
					if trick:isKindOf("Indulgence") and (not isDiscard or self.player:canDiscard(friend, trick:getId())) then
						if friend:getHp() <= friend:getHandcardNum() or friend:isLord() or name == "snatch" then
							cardchosen = trick:getEffectiveId()
							break
						end
					end
					if trick:isKindOf("SupplyShortage") and (not isDiscard or self.player:canDiscard(friend, trick:getId())) then
						cardchosen = trick:getEffectiveId()
						break
					end
					if trick:isKindOf("Indulgence") and (not isDiscard or self.player:canDiscard(friend, trick:getId())) then
						cardchosen = trick:getEffectiveId()
						break
					end
				end
				if cardchosen then
					if addTarget(friend, cardchosen) then return end
				end
			end
		end
	end

	local hasLion, target
	for _, friend in ipairs(friends) do
		if self:needToThrowArmor(friend) and (not isDiscard or self.player:canDiscard(friend, friend:getArmor():getEffectiveId())) then
			hasLion = true
			target = friend
		end
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() then
			local valuable = self:getValuableCard(enemy)
			if valuable and (not isDiscard or self.player:canDiscard(enemy, valuable)) then
				if addTarget(enemy, valuable) then return end
			end
		end
	end

	for _, enemy in ipairs(enemies) do
		local cards = sgs.QList2Table(enemy:getHandcards())
		if #cards <= 2 and not enemy:isKongcheng() and not self:doNotDiscard(enemy, "h", true) then
			for _, cc in ipairs(cards) do
				if sgs.cardIsVisible(cc, enemy, self.player) and (cc:isKindOf("Peach") or cc:isKindOf("Analeptic")) then
					if addTarget(enemy, self:getCardRandomly(enemy, "h")) then return end
				end
			end
		end
	end

	local willRenxin
	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() then
			willRenxin = false
			for _,p in ipairs(self:getFriendsNoself(enemy)) do
				if p:getHp() <= 2 then willRenxin = enemy:hasShownSkill("Renxin") break end
			end
			if enemy:hasShownSkills("jijiu|qingnang|jieyin|jijiu_HuaTuo_LB") or willRenxin then
				local cardchosen
				local equips = { enemy:getDefensiveHorse(), enemy:getArmor(), enemy:getOffensiveHorse(), enemy:getWeapon(),enemy:getTreasure()}
				for _, equip in ipairs(equips) do
					if equip and (not enemy:hasShownSkills("jijiu|jijiu_HuaTuo_LB") or equip:isRed()) and (not isDiscard or self.player:canDiscard(enemy, equip:getEffectiveId())) then  --源码忘记Shown
						cardchosen = equip:getEffectiveId()
						break
					end
				end
				if not cardchosen and not enemy:isKongcheng() and enemy:getHandcardNum() < 3 and self:isWeak(enemy)
					and (not self:needKongcheng(enemy) and enemy:getHandcardNum() == 1)
					and (not isDiscard or self.player:canDiscard(enemy, "h")) then
					cardchosen = self:getCardRandomly(enemy, "h")
				end
				if not cardchosen and enemy:getDefensiveHorse() and (not isDiscard or self.player:canDiscard(enemy, enemy:getDefensiveHorse():getEffectiveId())) then cardchosen = enemy:getDefensiveHorse():getEffectiveId() end
				if not cardchosen and enemy:getArmor() and not self:needToThrowArmor(enemy) and (not isDiscard or self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId())) then
					cardchosen = enemy:getArmor():getEffectiveId()
				end

				if cardchosen then
					if addTarget(enemy, cardchosen) then return end
				end
			end
		end
	end

	for _, enemy in ipairs(enemies) do
		if enemy:hasArmorEffect("EightDiagram") and not self:needToThrowArmor(enemy)
			and (not isDiscard or self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId())) then
			addTarget(enemy, enemy:getArmor():getEffectiveId())
		end
		if enemy:getTreasure() and (enemy:getPile("wooden_ox"):length() > 1 or enemy:hasTreasure("JadeSeal"))
			and (not isDiscard or self.player:canDiscard(enemy, enemy:getTreasure():getEffectiveId())) then
			addTarget(enemy, enemy:getTreasure():getEffectiveId())
		end
	end

	for i = 1, 2 + (isJixi and 3 or 0), 1 do
		for _, enemy in ipairs(enemies) do
			if not enemy:isNude() and not (self:needKongcheng(enemy) and i <= 2) and not self:doNotDiscard(enemy) then
				if (enemy:getHandcardNum() == i and sgs.getDefenseSlash(enemy, self) < 6 + (isJixi and 6 or 0) and enemy:getHp() <= 3 + (isJixi and 2 or 0)) then
					local cardchosen
					if self.player:distanceTo(enemy) == self.player:getAttackRange() + 1 and enemy:getDefensiveHorse() and not self:doNotDiscard(enemy, "e")
						and (not isDiscard or self.player:canDiscard(enemy, enemy:getDefensiveHorse():getEffectiveId()))then
						cardchosen = enemy:getDefensiveHorse():getEffectiveId()
					elseif enemy:getArmor() and not self:needToThrowArmor(enemy) and not self:doNotDiscard(enemy, "e")
						and (not isDiscard or self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId()))then
						cardchosen = enemy:getArmor():getEffectiveId()
					elseif not isDiscard or self.player:canDiscard(enemy, "h") then
						cardchosen = self:getCardRandomly(enemy, "h")
					end
					if cardchosen then
						if addTarget(enemy, cardchosen) then return end
					end
				end
			end
		end
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isNude() then
			local valuable = self:getValuableCard(enemy)
			if valuable and (not isDiscard or self.player:canDiscard(enemy, valuable)) then
				if addTarget(enemy, valuable) then return end
			end
		end
	end

	if hasLion and (not isDiscard or self.player:canDiscard(target, target:getArmor():getEffectiveId())) then
		if addTarget(target, target:getArmor():getEffectiveId()) then return end
	end
	
	--界陆逊的配合插在这里应该不错了吧……求不打脸  （这里往上的情况都是敌方陆逊无论如何都要弃，往下的则是需要考虑连营）
	for _, friend in ipairs(friends) do
		if friend:hasShownSkills("QianxunLB+Lianying") and friend:getHandcardNum() >= 2 and not isSkillCard and (not isDiscard or self.player:canDiscard(friend, "hej")) then
			if addTarget(friend, self:getCardRandomly(friend, "h")) then return end
		end
	end

	for _, enemy in ipairs(enemies) do
		if not enemy:isKongcheng() and not self:doNotDiscard(enemy, "h")
			and enemy:hasShownSkills(sgs.cardneed_skill) and (not isDiscard or self.player:canDiscard(enemy, "h"))
			and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)) and not isSkillCard) then  --界陆逊
			if addTarget(enemy, self:getCardRandomly(enemy, "h")) then return end
		end
	end

	for _, enemy in ipairs(enemies) do
		if enemy:hasEquip() and not self:doNotDiscard(enemy, "e") 
			and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)) and #self:getFriends(enemy) >= 2 and not isSkillCard) then  --界陆逊
			local cardchosen
			if enemy:getDefensiveHorse() and (not isDiscard or self.player:canDiscard(enemy, enemy:getDefensiveHorse():getEffectiveId())) then
				cardchosen = enemy:getDefensiveHorse():getEffectiveId()
			elseif enemy:getArmor() and not self:needToThrowArmor(enemy) and (not isDiscard or self.player:canDiscard(enemy, enemy:getArmor():getEffectiveId())) then
				cardchosen = enemy:getArmor():getEffectiveId()
			elseif enemy:getOffensiveHorse() and (not isDiscard or self.player:canDiscard(enemy, enemy:getOffensiveHorse():getEffectiveId())) then
				cardchosen = enemy:getOffensiveHorse():getEffectiveId()
			elseif enemy:getWeapon() and (not isDiscard or self.player:canDiscard(enemy, enemy:getWeapon():getEffectiveId())) then
				cardchosen = enemy:getWeapon():getEffectiveId()
			end
			if cardchosen then
				if addTarget(enemy, cardchosen) then return end
			end
		end
	end

	if (name == "snatch" or self:getOverflow() > 0) and not self:preventLowValueTrick(card) then
		for _, enemy in ipairs(enemies) do
			local equips = enemy:getEquips()
			if not enemy:isNude() and not self:doNotDiscard(enemy, "he")
				and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)) and not isSkillCard) then  --界陆逊
				local cardchosen
				if not equips:isEmpty() and not self:doNotDiscard(enemy, "e") then
					cardchosen = self:getCardRandomly(enemy, "e")
				else
					cardchosen = self:getCardRandomly(enemy, "h") end
				if cardchosen then
					if addTarget(enemy, cardchosen) then return end
				end
			end
		end
	end
	
	if self.player:hasShownSkill("Luanzhan") and card:isBlack() and not isSkilLCard and usecard and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X（暂时不考虑距离技）
		local ineffective_targets = {}
		--照抄exclude
		local from = self.player
		local limit = self:getDistanceLimit(card, from)
		local range_fix = 0
		if card:isKindOf("Snatch") and card:getSkillName() == "jixi" then
			range_fix = range_fix + 1
		end
		if card:isVirtualCard() then
			for _, id in sgs.qlist(card:getSubcards()) do
				if from:getOffensiveHorse() and from:getOffensiveHorse():getEffectiveId() == id then range_fix = range_fix + 1 end
			end
		end
		for _, player in sgs.qlist(self.room:getOtherPlayers(player)) do
			if not from:isProhibited(player, card) and not self:hasTrickEffective(card, player, from)
				and (not limit or from:distanceTo(player, range_fix) <= limit) and card:targetFilter(sgs.PlayerList(), player, from) then
				table.insert(ineffective_targets, player)
			end
		end
		for _, target in ipairs(ineffective_targets) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target) then
				use.to:append(target)
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
end
SmartAI.useCardSnatch = SmartAI.useCardSnatchOrDismantlement
SmartAI.useCardDismantlement = SmartAI.useCardSnatchOrDismantlement
function SmartAI:useCardDuel(duel, use)										--巧说（防止新加目标与原有目标重复）、急救、无双、制蛮、仁德、奸雄、乱战、无前

	local enemies = self:exclude(self.enemies, duel)
	local friends = self:exclude(self.friends_noself, duel)
	duel:setFlags("AI_Using")
	local n1 = self:getCardsNum("Slash")
	duel:setFlags("-AI_Using")
	if self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") or use.isWuqian then n1 = n1 * 2 end
	local huatuo = sgs.findPlayerByShownSkillName("jijiu")
	local huatuoLB = sgs.findPlayerByShownSkillName("jijiu_HuaTuo_LB")
	local hasHuatuoFriend = (huatuo and self:isFriend(huatuo)) or (huatuoLB and self:isFriend(huatuoLB))
	local targets = {}

	local canUseDuelTo=function(target)
		return self:hasTrickEffective(duel, target) and self:damageIsEffective(target,sgs.DamageStruct_Normal)
	end

	for _, friend in ipairs(friends) do
		if not ((not use.current_targets or not table.contains(use.current_targets, friend:objectName())) and canUseDuelTo(friend)) then continue end  --巧说
		if friend:hasShownSkill("jieming") and self.player:hasSkills("rende|RendeLB") and hasHuatuoFriend then  --源码忘记Shown
			table.insert(targets, friend)
		end
		--if self.player:hasSkill("Zhiman_MaSu|Zhiman_GuanSuo") and (self.player:canGetCard(friend, "j") or ((friend:hasShownSkills(sgs.lose_equip_skill) or self:needToThrowArmor(friend)) and self.player:canGetCard(friend, "e"))) then
		if self.player:hasSkill("Zhiman_MaSu|Zhiman_GuanSuo") and (not friend:getCards("j"):isEmpty() or ((friend:hasShownSkills(sgs.lose_equip_skill) or self:needToThrowArmor(friend)) and not friend:getEquips():isEmpty())) then
			table.insert(targets, friend)
		end
	end

	for _, enemy in ipairs(enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
			and self.player:hasFlag("duelTo_" .. enemy:objectName()) and canUseDuelTo(enemy) then
			table.insert(targets, enemy)
		end
	end

	local cmp = function(a, b)
		local v1 = getCardsNum("Slash", a, self.player) + a:getHp()
		local v2 = getCardsNum("Slash", b, self.player) + b:getHp()

		if self:getDamagedEffects(a, self.player) then v1 = v1 + 20 end
		if self:getDamagedEffects(b, self.player) then v2 = v2 + 20 end

		if not self:isWeak(a) and a:hasShownSkills("jianxiong|JianxiongLB") then v1 = v1 + 10 end  --源码忘记Shown
		if not self:isWeak(b) and b:hasShownSkills("jianxiong|JianxiongLB") then v2 = v2 + 10 end

		if self:needToLoseHp(a) then v1 = v1 + 5 end
		if self:needToLoseHp(b) then v2 = v2 + 5 end

		if a:hasShownSkills(sgs.masochism_skill) then v1 = v1 + 5 end
		if b:hasShownSkills(sgs.masochism_skill) then v2 = v2 + 5 end

		if not self:isWeak(a) and a:hasShownSkill("jiang") then v1 = v1 + 5 end  --源码忘记Shown
		if not self:isWeak(b) and b:hasShownSkill("jiang") then v2 = v2 + 5 end

		if v1 == v2 then return sgs.getDefenseSlash(a, self) < sgs.getDefenseSlash(b, self) end

		return v1 < v2
	end

	table.sort(enemies, cmp)

	for _, enemy in ipairs(enemies) do
		local useduel
		local n2 = getCardsNum("Slash", enemy, self.player)
		if enemy:hasShownSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") then n2 = n2 * 2 end  --源码忘记Shown
		if sgs.card_lack[enemy:objectName()]["Slash"] == 1 then n2 = 0 end
		useduel = n1 >= n2 or self:needToLoseHp(self.player, nil, nil, true)
					or self:getDamagedEffects(self.player, enemy) or (n2 < 1 and sgs.isGoodHp(self.player, self.player))
					or ((self:hasSkills("jianxiong|JianxiongLB") or self.player:getMark("shuangxiong") > 0) and sgs.isGoodHp(self.player, self.player)
						and n1 + self.player:getHp() >= n2 and self:isWeak(enemy))

		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
			and self:objectiveLevel(enemy) > 3 and canUseDuelTo(enemy) and not self:cantbeHurt(enemy) and useduel and sgs.isGoodTarget(enemy, enemies, self) then
			if not table.contains(targets, enemy) then table.insert(targets, enemy) end
		end
	end

	if #targets > 0 then

		local godsalvation = self:getCard("GodSalvation")
		if godsalvation and godsalvation:getId() ~= duel:getId() and self:willUseGodSalvation(godsalvation) then
			local use_gs = true
			for _, p in ipairs(targets) do
				if not p:isWounded() or not self:hasTrickEffective(godsalvation, p, self.player) then break end
				use_gs = false
			end
			if use_gs then
				use.card = godsalvation
				return
			end
		end

		local targets_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, duel)
		if use.isDummy and use.xiechan then targets_num = 100 end
		local enemySlash = 0
		local setFlag = false

		use.card = duel

		for i = 1, #targets, 1 do
			local n2 = getCardsNum("Slash", targets[i], self.player)
			if sgs.card_lack[targets[i]:objectName()]["Slash"] == 1 then n2 = 0 end
			if self:isEnemy(targets[i]) then enemySlash = enemySlash + n2 end

			if use.to then
				if i == 1 and not use.current_targets then  --巧说
					use.to:append(targets[i])
				--elseif n1 >= enemySlash and not targets[i]:hasSkill("danlao") and not (lx and self:isEnemy(lx) and lx:getHp() > targets_num / 2) then
				elseif n1 >= enemySlash then
					use.to:append(targets[i])
				end
				if not setFlag and self.player:getPhase() == sgs.Player_Play and self:isEnemy(targets[i]) then
					self.player:setFlags("duelTo" .. targets[i]:objectName())
					setFlag = true
				end
				if use.to:length() == targets_num then return end
			end
		end
	end

	local targets_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, duel)
	if use.isDummy and use.xiechan then targets_num = 100 end
	if self.player:hasShownSkill("Luanzhan") and duel:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and not canUseDuelTo(enemy) and not self.player:isProhibited(enemy, duel) then
				use.to:append(enemy)
				if not setFlag and self.player:getPhase() == sgs.Player_Play and self:isEnemy(enemy) then
					self.player:setFlags("duelTo" .. enemy:objectName())
					setFlag = true
				end
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and not canUseDuelTo(target) and not self.player:isProhibited(target, duel) then
				use.to:append(target)
				if not setFlag and self.player:getPhase() == sgs.Player_Play and self:isEnemy(target) then
					self.player:setFlags("duelTo" .. target:objectName())
					setFlag = true
				end
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
end
function SmartAI:useCardBefriendAttacking(BefriendAttacking, use)			--巧说（防止新加目标与原有目标重复）、急救、界陆逊、乱战、滔乱
	if not BefriendAttacking:isAvailable(self.player) then return end
	if self:getOverflow() >= 2 and not self:hasCrossbowEffect()
		and not (self.player:getPhase() ~= sgs.Player_NotActive and self.player:hasSkills(sgs.Active_cardneed_skill))
		and not (self.player:getPhase() == sgs.Player_NotActive and self.player:hasSkills(sgs.notActive_cardneed_skill)) then
		if self:preventLowValueTrick(BefriendAttacking) then return end
	end
	
	local targets = sgs.PlayerList()
	local total_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, BefriendAttacking)  --乱战（配OL滔乱）
	local players = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(players)
	for _, to_select in ipairs(players) do
		if (not use.current_targets or not table.contains(use.current_targets, to_select:objectName()))  --巧说
			and self:isFriend(to_select) and BefriendAttacking:targetFilter(targets, to_select, self.player) and not targets:contains(to_select)
			and self:hasTrickEffective(BefriendAttacking, to_select, self.player) then
			targets:append(to_select)
			if use.to then use.to:append(to_select) end
		end
	end
	if targets:length() < total_num then  --（这里原本都是targets:isEmpty()，下同）
		for _, to_select in ipairs(players) do
			if (not use.current_targets or not table.contains(use.current_targets, to_select:objectName()))  --巧说
				and BefriendAttacking:targetFilter(targets, to_select, self.player) and not targets:contains(to_select)
				and self:hasTrickEffective(BefriendAttacking, to_select, self.player) then
				if self:isEnemy(to_select) and to_select:hasShownSkills("jijiu|qingnang|kanpo|jijiu_HuaTuo_LB") then continue end
				if self:isEnemy(to_select) and (to_select:hasShownSkills("QianxunLB+Lianying") and to_select:getHandcardNum() >= math.min(3, #self:getFriends(to_select))) then continue end  --界陆逊
				targets:append(to_select)
				if use.to then use.to:append(to_select) end
			end
		end
	end
	
	if self.player:hasShownSkill("Luanzhan") and BefriendAttacking:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and BefriendAttacking:targetFilter(targets, enemy, self.player) and not self:hasTrickEffective(BefriendAttacking, enemy, self.player) and not self.player:isProhibited(enemy, BefriendAttacking) then
				targets:append(enemy)
				use.to:append(enemy)
				if self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and BefriendAttacking:targetFilter(targets, target, self.player) and not self:hasTrickEffective(BefriendAttacking, target, self.player) and not self.player:isProhibited(target, BefriendAttacking) then
				targets:append(target)
				use.to:append(target)
				if self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
	if not targets:isEmpty() then
		use.card = BefriendAttacking
		return
	end
end
function SmartAI:useCardKnownBoth(KnownBoth, use)							--巧说（防止新加目标与原有目标重复）、界陆逊、乱战、无谋、滔乱（重铸）
	self.knownboth_choice = {}
	if not KnownBoth:isAvailable(self.player) then return false end
	
	if self.player:hasShownSkill("Wumou") and self.player:getMark("@wrath") < 7 then
		local targets = sgs.PlayerList()
		local canRecast = KnownBoth:targetsFeasible(targets, self.player) and KnownBoth:getSkillName() ~= "Taoluan" and KnownBoth:getSkillName() ~= "TaoluanOL"
		if canRecast then
			use.card = KnownBoth
			if use.to then use.to = sgs.SPlayerList() end
		end
		return
	end
	
	local targets = sgs.PlayerList()
	local total_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, KnownBoth)
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if (not use.current_targets or not table.contains(use.current_targets, player:objectName()))  --巧说
			and KnownBoth:targetFilter(targets, player, self.player) and sgs.isAnjiang(player) and not targets:contains(player)
			and player:getMark(("KnownBoth_%s_%s"):format(self.player:objectName(), player:objectName())) == 0 and self:hasTrickEffective(KnownBoth, player, self.player) then
			use.card = KnownBoth
			targets:append(player)
			if use.to then use.to:append(player) end
			self.knownboth_choice[player:objectName()] = "head_general"
		end
	end

	--界陆逊配合
	if total_num > targets:length() then
		self:sort(self.friends_noself, "handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and KnownBoth:targetFilter(targets, friend, self.player) and not targets:contains(friend)
				and self:hasTrickEffective(KnownBoth, friend, self.player) 
				and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() then  --界陆逊
				targets:append(friend)
				if use.to then use.to:append(friend) end
				self.knownboth_choice[friend:objectName()] = "handcards"
			end
		end
	end
	if total_num > targets:length() and not targets:isEmpty() and not self:preventLowValueTrick(KnownBoth) then  --后一个条件自加（因为有了上面界陆逊的一段）
		self:sort(self.enemies, "handcard")
		sgs.reverse(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
				and KnownBoth:targetFilter(targets, enemy, self.player) and enemy:getHandcardNum() - self:getKnownNum(enemy, self.player) > 3 and not targets:contains(enemy)
				and self:hasTrickEffective(KnownBoth, enemy, self.player)
				and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy))) then  --界陆逊
				use.card = KnownBoth
				targets:append(enemy)
				if use.to then use.to:append(enemy) end
				self.knownboth_choice[enemy:objectName()] = "handcards"
			end
		end
	end
	if total_num > targets:length() and not targets:isEmpty() then
		self:sort(self.friends_noself, "handcard")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and self:getKnownNum(friend, self.player) ~= friend:getHandcardNum() and KnownBoth:targetFilter(targets, friend, self.player) and not targets:contains(friend)  --源码为card:targetFilter，但是card未定义
				and self:hasTrickEffective(KnownBoth, friend, self.player) then
				use.card = KnownBoth  --源码似乎漏掉了？
				targets:append(friend)
				if use.to then use.to:append(friend) end
				self.knownboth_choice[friend:objectName()] = "handcards"
			end
		end
	end

	if self.player:hasShownSkill("Luanzhan") and KnownBoth:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") and total_num > targets:length() then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do  --重新看敌方手牌
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
				and KnownBoth:targetFilter(targets, enemy, self.player) and not targets:contains(enemy)
				and self:hasTrickEffective(KnownBoth, enemy, self.player) then
				targets:append(enemy)
				if use.to then use.to:append(enemy) end
				self.knownboth_choice[enemy:objectName()] = "handcards"
				if total_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, friend in ipairs(self.friends_noself) do  --重新看己方手牌
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and KnownBoth:targetFilter(targets, friend, self.player) and not targets:contains(friend)
				and self:hasTrickEffective(KnownBoth, friend, self.player) then
				targets:append(friend)
				if use.to then use.to:append(friend) end
				self.knownboth_choice[friend:objectName()] = "handcards"
				if total_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and KnownBoth:targetFilter(targets, enemy, self.player) and not self.player:isProhibited(enemy, duel) and not self:hasTrickEffective(KnownBoth, enemy, self.player) then
				targets:append(enemy)
				use.to:append(enemy)
				if total_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and KnownBoth:targetFilter(targets, target, self.player) and not self.player:isProhibited(target, duel) and not self:hasTrickEffective(KnownBoth, target, self.player) then
				targets:append(target)
				use.to:append(target)
				if total_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end

	if not use.card then
		targets = sgs.PlayerList()
		local canRecast = KnownBoth:targetsFeasible(targets, self.player) and KnownBoth:getSkillName() ~= "Taoluan" and KnownBoth:getSkillName() ~= "TaoluanOL"
		if canRecast then
			use.card = KnownBoth
			if use.to then use.to = sgs.SPlayerList() end
		end
	end
end
function SmartAI:isPriorFriendOfSlash(friend, card, source)					--急救、制蛮、仁德
	source = source or self.player
	local huatuo = sgs.findPlayerByShownSkillName("jijiu")
	local huatuoLB = sgs.findPlayerByShownSkillName("jijiu_HuaTuo_LB")
	local hasHuatuoFriend = (huatuo and self:isFriend(huatuo, source)) or (huatuoLB and self:isFriend(huatuoLB, source))
	if source:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then
		--local promo = self:findPlayerToDiscard("ej", false, sgs.Card_MethodGet, nil, true)
		local promo = self:findPlayerToDiscard("ej", false, false, nil, true)
		if table.contains(promo, friend) then
			return true
		end
	end
	if not self:hasHeavySlashDamage(source, card, friend)
		and (self:findLeijiTarget(friend, 50, source) or (friend:hasShownSkill("jieming") and source:hasShownSkills("rende|RendeLB") and hasHuatuoFriend)) then
		return true
	end
	if card:isKindOf("NatureSlash") and friend:isChained() and self:isGoodChainTarget(friend, source, nil, nil, card) then return true end
	return
end
function SmartAI:useCardIndulgence(card, use)								--急救、界陆逊、奇袭、克己、攻心、峻刑、反间、诈降、国色、滔乱、突袭、仁德、当先、
																			--天妒、遗计（牌堆）、琴音、归心、明策、落英、推锋（牌堆）、除疠、神愤
	local enemies = {}

	if #self.enemies == 0 then
		if sgs.turncount <= 1 and sgs.isAnjiang(self.player:getNextAlive()) then
			enemies = self:exclude({self.player:getNextAlive()}, card)
		end
	else
		enemies = self:exclude(self.enemies, card)
	end

	local zhanghe = sgs.findPlayerByShownSkillName("qiaobian")
	local zhanghe_seat = zhanghe and zhanghe:faceUp() and not zhanghe:isKongcheng() and not self:isFriend(zhanghe) and zhanghe:getSeat() or 0
	local daqiao = sgs.findPlayerByShownSkillName("GuoseLB")  --解乐
	local daqiao_seat = daqiao and daqiao:faceUp() and not self:willSkipPlayPhase(daqiao) and (getKnownCard(daqiao, self.player, "diamond", false) > 0) and not self:isFriend(daqiao) and daqiao:getSeat() or 0
	
	if #enemies == 0 then return end

	local getvalue = function(enemy)
		if enemy:hasSkills("jgjiguan_qinglong|jgjiguan_baihu|jgjiguan_zhuque|jgjiguan_xuanwu") then return -101 end
		if enemy:hasSkills("jgjiguan_bian|jgjiguan_suanni|jgjiguan_chiwen|jgjiguan_yazi") then return -101 end
		if enemy:hasShownSkill("qianxun") then return -101 end
		if enemy:hasShownSkill("weimu") and card:isBlack() then return -101 end
		if enemy:containsTrick("indulgence") then return -101 end
		if enemy:hasShownSkill("qiaobian") and not enemy:containsTrick("supply_shortage") and not enemy:containsTrick("indulgence") then return -101 end
		if zhanghe_seat > 0 and (self:playerGetRound(zhanghe) <= self:playerGetRound(enemy) and self:enemiesContainsTrick() <= 1 or not enemy:faceUp()) then
			return -101 end
		if daqiao_seat > 0 and (self:playerGetRound(daqiao) <= self:playerGetRound(enemy) and self:enemiesContainsTrick() <= 1 or not enemy:faceUp()) then
			return -101 end  --国色解乐

		local yiji_pile = enemy:getPile("YijiLB"):length() or 0
		local tuifeng_pile = enemy:getPile("lead"):length() * 2 or 0
		local value = enemy:getHandcardNum() + yiji_pile + tuifeng_pile - enemy:getHp()

		if enemy:hasShownSkills("lijian|fanjian|dimeng|jijiu|jieyin|zhiheng|rende|RendeLB|jijiu_HuaTuo_LB|Zhaxiang") then value = value + 10 end
		if enemy:hasShownSkills("qixi|guose|duanliang|luoshen|jizhi|wansha|qixi_GanNing_LB|Mingce|Junxing|FanjianLB|GuoseLB|Chuli|Taoluan|TaoluanOL") then value = value + 5 end
		if enemy:hasShownSkills("guzheng|duoshi|Gongxin_LyuMeng_LB|Gongxin_ShenLyuMeng|Guixin|Shenfen|Luoying") then value = value + 3 end
		if self:isWeak(enemy) then value = value + 3 end
		if enemy:isLord() then value = value + 3 end

		if self:objectiveLevel(enemy) < 3 then value = value - 10 end
		if not enemy:faceUp() then value = value - 10 end
		if enemy:hasShownSkills("keji|shensu|keji_LyuMeng_LB|Dangxian_LiaoHua|Dangxian_GuanSuo") then value = value - enemy:getHandcardNum() end
		if enemy:hasShownSkills("QianxunLB+Lianying") then value = value - enemy:getHandcardNum() end  --界陆逊
		if enemy:hasShownSkills("lirang|guanxing") then value = value - 5 end
		if enemy:hasShownSkills("tuxi|tiandu|tiandu_GuoJia_LB|Qinyin") then value = value - 3 end
		if enemy:hasShownSkills("TuxiLB") and enemy:getHandcardNum() <= 2 then value = value - 3 end
		if not sgs.isGoodTarget(enemy, self.enemies, self) then value = value - 1 end
		if getKnownCard(enemy, self.player, "Dismantlement", true) > 0 then value = value + 2 end
		value = value + (self.room:alivePlayerCount() - self:playerGetRound(enemy)) / 2
		return value
	end

	local cmp = function(a,b)
		return getvalue(a) > getvalue(b)
	end

	table.sort(enemies, cmp)

	local target = enemies[1]
	if getvalue(target) > -100 then
		use.card = card
		if use.to then use.to:append(target) end
		return
	end
end
function SmartAI:canHit(to, from, conservative)								--无双、诈降、义绝、铁骑、RE破军
	from = from or self.room:getCurrent()
	to = to or self.player
	local jink = sgs.cloneCard("jink")
	if to:isCardLimited(jink, sgs.Card_MethodUse) then return true end
	if self:canLiegong(to, from) then return true end
	if self:canZhaxiang(from) then return true end
	if not self:isFriend(to, from) then
		if from:hasWeapon("Axe") and from:getCards("he"):length() > 2 then return true end
		if from:hasShownSkill("mengjin") and not self:hasHeavySlashDamage(from, nil, to) and not self:needLeiji(to, from) then
			if self:doNotDiscard(to, "he", true) then
			elseif to:getCards("he"):length() == 1 and not to:getArmor() then
			elseif self:willSkipPlayPhase() then
			elseif (getCardsNum("Peach", to, from) > 0 or getCardsNum("Analeptic", to, from) > 0) then return true
			elseif not self:isWeak(to) and to:getArmor() and not self:needToThrowArmor() then return true
			elseif not self:isWeak(to) and to:getDefensiveHorse() then return true
			end
		end
	end

	local hasHeart, hasRed, hasBlack
	if to:objectName() == self.player:objectName() then
		for _, card in ipairs(self:getCards("Jink")) do
			if card:getSuit() == sgs.Card_Heart then hasHeart = true end
			if card:isRed() then hasRed = true end
			if card:isBlack() then hasBlack = true end
		end
	end
	if to:getMark("@qianxi_red") > 0 and not hasBlack then return true end
	if to:getMark("@qianxi_black") > 0 and not hasRed then return true end
	if not conservative and self:hasHeavySlashDamage(from, nil, to) then conservative = true end
	
	local canPojunREArmor = false  --插入
	local canPojunREAllHandcards = false
	if self:hasSkill("PojunRE", from) and from:getPhase() == sgs.Player_Play and not self:isFriend(to, from) and to:getHp() > 0 and not to:isNude() then
		canPojunREArmor = to:getArmor() and not self:hasSkill(sgs.viewhas_armor_skill, to)
		canPojunREAllHandcards = (math.min(to:getHp(), to:getCardCount(true)) - (to:getArmor() and 1 or 0)) >= to:getHandcardNum()
	end
	
	if not conservative and self:hasEightDiagramEffect(to) and not IgnoreArmor(from, to) then return false end
	if to:getMark("Yijue") > 0 then return true end
	if from:hasShownSkill("TieqiLB") and not self:isFriend(to, from) and to:getCardCount(true) <= 2 then return true end  --是不是太保守了……
	local need_double_jink = from and from:hasShownSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu")
	if to:objectName() == self.player:objectName() then
		if getCardsNum("Jink", to, from) == 0 then return true end
		if need_double_jink and getCardsNum("Jink", to, from) < 2 then return true end
	end
	if getCardsNum("Jink", to, from) == 0 or canPojunREAllHandcards then return true end
	if need_double_jink and getCardsNum("Jink", to, from) < 2 then return true end
	return false
end
function SmartAI:willUseLightning(card)										--界陆逊
	if not card then self.room:writeToConsole(debug.traceback()) return false end
	if self.player:containsTrick("lightning") then return end
	if self.player:hasSkill("weimu") and card:isBlack() then
		local shouldUse = true
		for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if self:evaluateKingdom(p) == "unknown" then shouldUse = false break end
			if self:evaluateKingdom(p) == self.player:getKingdom() then shouldUse = false break end
		end
		if shouldUse then return true end
	end
	--if sgs.Sanguosha:isProhibited(self.player, self.player, card) then return end

	local function hasDangerousFriend()
		local hashy = false
		for _, aplayer in ipairs(self.enemies) do
			if aplayer:hasShownSkill("hongyan") then hashy = true break end  --源码忘记Shown
		end
		for _, aplayer in ipairs(self.enemies) do
			--if aplayer:hasSkill("guanxing") and self:isFriend(aplayer:getNextAlive()) then return true end
			if aplayer:hasShownSkill("guanxing") or aplayer:hasShownSkill("yizhi") or (aplayer:hasShownSkills("Gongxin_LyuMeng_LB|Gongxin_ShenLyuMeng") and hashy) then
			--or aplayer:hasSkill("xinzhan") then
				if self:isFriend(aplayer:getNextAlive()) then return true end
			end
		end
		return false
	end

	if self:getFinalRetrial(self.player) == 2 then
		return
	elseif self:getFinalRetrial(self.player) == 1 then
		return true
	elseif self.player:hasSkills("QianxunLB+Lianying") and not hasDangerousFriend() then  --界陆逊
		local shouldUse = true
		for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if self:evaluateKingdom(p) == "unknown" then shouldUse = false break end
			if self:evaluateKingdom(p) == self.player:getKingdom() then shouldUse = false break end
		end
		if shouldUse then return true end
	elseif not hasDangerousFriend() then
		if self.player:hasSkills("guanxing|kongcheng") and self.player:isLastHandCard(card) == 1 then return true end
		local players = self.room:getAllPlayers()
		players = sgs.QList2Table(players)

		local friends = 0
		local enemies = 0

		for _, player in ipairs(players) do
			if self:objectiveLevel(player) >= 4 and not player:hasShownSkill("hongyan") and not (player:hasShownSkill("weimu") and card:isBlack()) then  --源码忘记Shown，下同
				enemies = enemies + 1
			elseif self:isFriend(player) and not player:hasShownSkill("hongyan") and not (player:hasShownSkill("weimu") and card:isBlack()) then
				friends = friends + 1
			end
		end

		local ratio

		if friends == 0 then ratio = 999
		else ratio = enemies/friends
		end

		if ratio > 1.5 then
			return true
		end
	end
end
function SmartAI:useCardPeach(card, use)									--奇袭、陷嗣、仁德、龙魂
	if not self.player:isWounded() then return end

	local mustusepeach = false

	if self.player:hasSkill("Longhun") and
		math.min(self.player:getMaxCards(), self.player:getHandcardNum()) + self.player:getCards("e"):length() > 3 then return end

	local peaches = 0
	local cards = sgs.QList2Table(self.player:getHandcards())

	for _, card in ipairs(cards) do
		if isCard("Peach", card, self.player) then peaches = peaches + 1 end
	end

	if self.player:hasSkills("rende|RendeLB") and self:findFriendsByType(sgs.Friend_Draw) then return end

	if not use.isDummy then
		if self.player:hasArmorEffect("SilverLion") then
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if card:isKindOf("Armor") and self:evaluateArmor(card) > 0 then
				use.card = card
				return
			end
		end
		end

		local SilverLion, OtherArmor
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if card:isKindOf("SilverLion") then
				SilverLion = card
			elseif card:isKindOf("Armor") and not card:isKindOf("SilverLion") and self:evaluateArmor(card) > 0 then
				OtherArmor = true
			end
		end
		if SilverLion and OtherArmor then
			use.card = SilverLion
			return
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if self.player:getHandcardNum() < 3 and
				(enemy:hasShownSkills(sgs.drawpeach_skill) or getCardsNum("Dismantlement", enemy, self.player) >= 1
					or enemy:hasShownSkill("jixi") and enemy:getPile("field"):length() >0 and enemy:distanceTo(self.player) == 1
					or enemy:hasShownSkills("qixi|qixi_GanNing_LB") and getKnownCard(enemy, self.player, "black", nil, "he") >= 1
					or getCardsNum("Snatch", enemy, self.player) >= 1 and enemy:distanceTo(self.player) == 1
					or (enemy:hasShownSkill("tiaoxin") and (self.player:inMyAttackRange(enemy) and self:getCardsNum("Slash") < 1 or not self.player:canSlash(enemy))))
					or (enemy:hasShownSkill("Xiansi") and (self.player:getEquips():isEmpty() or self.player:hasShownSkills(sgs.lose_equip_skill) or (self.player:getEquips():length() == 1 and self:needToThrowArmor())))  --陷嗣防止偷桃
				then
			mustusepeach = true
			break
		end
	end

	local maxCards = self:getOverflow(self.player, true)
	local overflow = self:getOverflow() > 0
	if self.player:hasSkill("buqu") and self.player:getHp() < 1 and maxCards == 0 then
		use.card = card
		return
	end

	if mustusepeach or peaches > maxCards or self.player:getHp() == 1 then
		use.card = card
		return
	end

	if not overflow and #self.friends_noself > 0 then
		return
	end

	local useJieyinCard
	if self.player:hasSkill("jieyin") and not self.player:hasUsed("JieyinCard") and overflow and self.player:getPhase() == sgs.Player_Play then
		self:sort(self.friends, "hp")
		for _, friend in ipairs(self.friends) do
			if friend:isWounded() and friend:isMale() then useJieyinCard = true end
		end
	end

	if overflow then
		self:sortByKeepValue(cards)
		local handcardNum = self.player:getHandcardNum() - (useJieyinCard and 2 or 0)
		local discardNum = handcardNum - maxCards
		if discardNum > 0 then
			for i, c in ipairs(cards) do
				if c:getEffectiveId() == card:getEffectiveId() then
					use.card = card
					return
				end
				if i >= discardNum then break end
			end
		end
	end

	local lord = self.player:getLord()
	if lord and lord:getHp() <= 2 and self:isWeak(lord) then
		if self.player:isLord() then use.card = card end
		return
	end

	if self:needToLoseHp(self.player, nil, nil, nil, true) then return end

	self:sort(self.friends, "hp")
	if self.friends[1]:objectName() == self.player:objectName() or self.player:getHp() < 2 then
		use.card = card
		return
	end

	if #self.friends > 1 and ((not hasBuquEffect(self.friends[2]) and self.friends[2]:getHp() < 3 and self:getOverflow() < 2)
								or (not hasBuquEffect(self.friends[1]) and self.friends[1]:getHp() < 2 and peaches <= 1 and self:getOverflow() < 3)) then
		return
	end

	use.card = card
end
function SmartAI:getDangerousCard(who)										--暗箭、裸衣、咆哮、酒诗
	local weapon = who:getWeapon()
	local armor = who:getArmor()
	local treasure = who:getTreasure()
	if treasure then
		if treasure:isKindOf("JadeSeal") then
			return treasure:getEffectiveId()
		end
	end
	if weapon and (weapon:isKindOf("Crossbow") or weapon:isKindOf("GudingBlade")) then
		for _, friend in ipairs(self.friends) do
			if weapon:isKindOf("Crossbow") and who:distanceTo(friend) <= 1 and getCardsNum("Slash", who, self.player) > 0 then
				return weapon:getEffectiveId()
			end
			if weapon:isKindOf("GudingBlade") and who:inMyAttackRange(friend) and friend:isKongcheng() and not friend:hasShownSkill("kongcheng") and getCardsNum("Slash", who) > 0 then  --源码忘记Shown
				return weapon:getEffectiveId()
			end
		end
	end
	if (weapon and weapon:isKindOf("Spear") and who:hasShownSkills("paoxiao|paoxiao_ZhangFei_LB") and who:getHandcardNum() >= 1) then return weapon:getEffectiveId() end  --没算小关张，毕竟人家自带丈八；源码忘记Shown
	if weapon and weapon:isKindOf("Axe") and who:hasShownSkills("luoyi|LuoyiLB|Jiushi") then  --源码忘记Shown
		return weapon:getEffectiveId()
	end
	if armor and armor:isKindOf("EightDiagram") and who:hasShownSkills("leiji") then return armor:getEffectiveId() end  --源码忘记Shown

	if (weapon and who:hasShownSkills("liegong|Anjian")) then return weapon:getEffectiveId() end  --源码忘记Shown

	if weapon then
		for _, friend in ipairs(self.friends) do
			if who:distanceTo(friend) < who:getAttackRange(false) and self:isWeak(friend) and not self:doNotDiscard(who, "e", true) then return weapon:getEffectiveId() end
		end
	end
end
function SmartAI:enemiesContainsTrick(EnemyCount)							--克己、国色
	local trick_all, possible_indul_enemy, possible_ss_enemy = 0, 0, 0
	local indul_num = self:getCardsNum("Indulgence")
	local ss_num = self:getCardsNum("SupplyShortage")
	local enemy_num, temp_enemy = 0

	local zhanghe = sgs.findPlayerByShownSkillName("qiaobian")
	if zhanghe and (not self:isEnemy(zhanghe) or zhanghe:isKongcheng() or not zhanghe:faceUp()) then zhanghe = nil end
	local daqiao = sgs.findPlayerByShownSkillName("GuoseLB")  --解乐
	if daqiao and (not self:isEnemy(daqiao) or (getKnownCard(daqiao, self.player, "diamond", false) < 1) or not daqiao:faceUp() or self:willSkipPlayPhase(daqiao)) then daqiao = nil end

	if self.player:hasSkill("guose") then
		for _, acard in sgs.qlist(self.player:getCards("he")) do
			if acard:getSuit() == sgs.Card_Diamond then indul_num = indul_num + 1 end
		end
	elseif self.player:hasSkill("GuoseLB") and not self.player:hasUsed("#GuoseLBCard") then
		local canUse = false
		for _, acard in sgs.qlist(self.player:getCards("he")) do
			if acard:getSuit() == sgs.Card_Diamond then canUse = true end
		end
		if canUse then indul_num = indul_num + 1 end
	end

	if self.player:hasSkill("duanliang") then
		for _, acard in sgs.qlist(self.player:getCards("he")) do
			if acard:isBlack() then ss_num = ss_num + 1 end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if enemy:containsTrick("indulgence") then
			if not enemy:hasShownSkills("keji|keji_LyuMeng_LB") and (not zhanghe or self:playerGetRound(enemy) >= self:playerGetRound(zhanghe))  --源码忘记Shown
				and (not daqiao or self:playerGetRound(enemy) >= self:playerGetRound(daqiao)) then  --国色解乐
				trick_all = trick_all + 1
				if not temp_enemy or temp_enemy:objectName() ~= enemy:objectName() then
					enemy_num = enemy_num + 1
					temp_enemy = enemy
				end
			end
		else
			possible_indul_enemy = possible_indul_enemy + 1
		end
		if self.player:distanceTo(enemy) == 1 or self.player:hasSkill("duanliang") and self.player:distanceTo(enemy) <= 2 then
			if enemy:containsTrick("supply_shortage") then
				if not enemy:hasShownSkill("shensu") and (not zhanghe or self:playerGetRound(enemy) >= self:playerGetRound(zhanghe)) then  --源码忘记Shown
					trick_all = trick_all + 1
					if not temp_enemy or temp_enemy:objectName() ~= enemy:objectName() then
						enemy_num = enemy_num + 1
						temp_enemy = enemy
					end
				end
			else
				possible_ss_enemy = possible_ss_enemy + 1
			end
		end
	end
	indul_num = math.min(possible_indul_enemy, indul_num)
	ss_num = math.min(possible_ss_enemy, ss_num)
	if not EnemyCount then
		return trick_all + indul_num + ss_num
	else
		return enemy_num + indul_num + ss_num
	end
end
function SmartAI:canLiuli(daqiao, another)									--流离
	if not daqiao:hasShownSkills("liuli|liuli_DaQiao_LB") then return false end
	if type(another) == "table" then
		if #another == 0 then return false end
		for _, target in ipairs(another) do
			if target:getHp() < 3 and self:canLiuli(daqiao, target) then return true end
		end
		return false
	end

	if not self:needToLoseHp(another, self.player, true) or not self:getDamagedEffects(another, self.player, true) then return false end
	if another:hasShownSkill("xiangle") then return false end
	local n = daqiao:getHandcardNum()
	if n > 0 and (daqiao:distanceTo(another) <= daqiao:getAttackRange()) then return true
	elseif daqiao:getWeapon() and daqiao:getOffensiveHorse() and (daqiao:distanceTo(another) <= daqiao:getAttackRange()) then return true
	elseif daqiao:getWeapon() or daqiao:getOffensiveHorse() then return daqiao:distanceTo(another) <= 1
	else return false end
end
sgs.ai_skill_cardask["duel-slash"] = function(self, data, pattern, target)	--制蛮、仁德、不屈
	if self:isFriend(self.player, target) and target:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then return "." end
	if self.player:getPhase()==sgs.Player_Play then return self:getCardId("Slash") end

	if sgs.ai_skill_cardask.nullfilter(self, data, pattern, target) then return "." end

	if self:cantbeHurt(target) then return "." end

	if self:isFriend(target) and target:hasShownSkills("rende|RendeLB") and self.player:hasSkill("jieming") then return "." end  --源码忘记Shown
	if self:isEnemy(target) and not self:isWeak() and self:getDamagedEffects(self.player, target) then return "." end

	if self:isFriend(target) then
		if self:getDamagedEffects(self.player, target) or self:needToLoseHp(self.player, target) then return "." end
		if self:getDamagedEffects(target, self.player) or self:needToLoseHp(target, self.player) then
			return self:getCardId("Slash")
		else
			return "."
		end
	end

	if (not self:isFriend(target) and self:getCardsNum("Slash") >= getCardsNum("Slash", target, self.player))
		or (target:getHp() > 2 and self.player:getHp() <= 1 and self:getCardsNum("Peach") == 0 and not self.player:hasSkills("buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15")) then
		return self:getCardId("Slash")
	else return "." end

end
function sgs.ai_weapon_value.Axe(self, enemy, player)						--裸衣、暗箭、酒诗
	if player:hasShownSkills("luoyi|LuoyiLB|Jiushi|Anjian") then return 6 end
	if enemy and self:getOverflow() > 0 then return 2 end
	if enemy and enemy:getHp() < 3 then return 3 - enemy:getHp() end
end
sgs.ai_card_intention.Duel = function(self, card, from, tos)				--利驭
	if string.find(card:getSkillName(), "lijian") then return end
	if card:getSkillName() == "Liyu" then return end
	sgs.updateIntentions(from, tos, 80)
end
function sgs.ai_armor_value.EightDiagram(player, self)						--天妒、陷嗣
	local haszj = self:hasSkills("guidao", self:getEnemies(player))
	if haszj then
		return 2
	end
	if player:hasShownSkills("tiandu|leiji|tiandu_GuoJia_LB") then
		return 6
	end
	if player:hasShownSkill("Xiansi") and player:getPile("counter"):length() >= 3 then
		return 5
	end

	return 4
end
sgs.ai_skill_cardask["@Axe"] = function(self, data, pattern, target)		--不屈
	if target and self:isFriend(target) then return "." end
	local effect = data:toSlashEffect()
	local allcards = self.player:getCards("he")
	allcards = sgs.QList2Table(allcards)
	if self:hasHeavySlashDamage(self.player, effect.slash, target)
	  or (#allcards - 3 >= self.player:getHp())
	  or (self.player:hasSkill("kuanggu") and self.player:isWounded() and self.player:distanceTo(effect.to) == 1)
	  or (effect.to:getHp() == 1 and not effect.to:hasShownSkills("buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15"))
	  or (self:needKongcheng() and self.player:getHandcardNum() > 0)
	  or (self.player:hasSkills(sgs.lose_equip_skill) and self.player:getEquips():length() > 1 and self.player:getHandcardNum() < 2)
	  or self:needToThrowAll() then
		local discard = self.yongsi_discard
		if discard then return "$"..table.concat(discard, "+") end

		local hcards = {}
		for _, c in sgs.qlist(self.player:getHandcards()) do
			if not (isCard("Slash", c, self.player) and self:hasCrossbowEffect())
				and (not isCard("Peach", c, self.player) or target:getHp() == 1 and self:isWeak(target)) then
				table.insert(hcards, c)
			end
		end
		self:sortByKeepValue(hcards)
		local cards = {}
		local hand, armor, def, off = 0, 0, 0, 0
		if self:needToThrowArmor() then
			table.insert(cards, self.player:getArmor():getEffectiveId())
			armor = 1
		end
		if (self.player:hasSkills(sgs.need_kongcheng) or not self:hasLoseHandcardEffective()) and self.player:getHandcardNum() > 0 then
			hand = 1
			for _, card in ipairs(hcards) do
				table.insert(cards, card:getEffectiveId())
				if #cards == 2 then break end
			end
		end
		if #cards < 2 and self.player:hasSkills(sgs.lose_equip_skill) then
			if #cards < 2 and self.player:getOffensiveHorse() then
				off = 1
				table.insert(cards, self.player:getOffensiveHorse():getEffectiveId())
			end
			if #cards < 2 and self.player:getArmor() then
				armor = 1
				table.insert(cards, self.player:getArmor():getEffectiveId())
			end
			if #cards < 2 and self.player:getDefensiveHorse() then
				def = 1
				table.insert(cards, self.player:getDefensiveHorse():getEffectiveId())
			end
		end

		if #cards < 2 and hand < 1 and self.player:getHandcardNum() > 2 then
			hand = 1
			for _, card in ipairs(hcards) do
				table.insert(cards, card:getEffectiveId())
				if #cards == 2 then break end
			end
		end

		if #cards < 2 and off < 1 and self.player:getOffensiveHorse() then
			off = 1
			table.insert(cards, self.player:getOffensiveHorse():getEffectiveId())
		end
		if #cards < 2 and hand < 1 and self.player:getHandcardNum() > 0 then
			hand = 1
			for _, card in ipairs(hcards) do
				table.insert(cards, card:getEffectiveId())
				if #cards == 2 then break end
			end
		end
		if #cards < 2 and armor < 1 and self.player:getArmor() then
			armor = 1
			table.insert(cards, self.player:getArmor():getEffectiveId())
		end
		if #cards < 2 and def < 1 and self.player:getDefensiveHorse() then
			def = 1
			table.insert(cards, self.player:getDefensiveHorse():getEffectiveId())
		end

		if #cards == 2 then
			local num = 0
			for _, id in ipairs(cards) do
				if self.player:hasEquip(sgs.Sanguosha:getCard(id)) then num = num + 1 end
			end
			local eff = self:damageIsEffective(effect.to, effect.nature, self.player)
			if not eff then return "." end
			return "$" .. table.concat(cards, "+")
		end
	end
end
function SmartAI:canAttack(enemy, attacker, nature)							--狂风
	attacker = attacker or self.player
	nature = nature or sgs.DamageStruct_Normal
	local damage = 1
	if nature == sgs.DamageStruct_Fire and not enemy:hasArmorEffect("SilverLion") then
		if enemy:hasArmorEffect("Vine") then damage = damage + 1 end
		if enemy:getMark("@gale") > 0 then damage = damage + 1 end
		if enemy:getMark("@gale_ShenZhuGeLiang") > 0 then damage = damage + 1 end
	end
	if #self.enemies == 1 then return true end
	if self:getDamagedEffects(enemy, attacker) or (self:needToLoseHp(enemy, attacker, false, true) and #self.enemies > 1) or not sgs.isGoodTarget(enemy, self.enemies, self) then return false end
	if self:objectiveLevel(enemy) <= 2 or self:cantbeHurt(enemy, self.player, damage) or not self:damageIsEffective(enemy, nature, attacker) then return false end
	if nature ~= sgs.DamageStruct_Normal and enemy:isChained() and not self:isGoodChainTarget(enemy, self.player, nature) then return false end
	return true
end
function sgs.isGoodTarget(player, targets, self, isSlash)					--武魂
	if not self then global_room:writeToConsole(debug.traceback()) end
	-- self = self or sgs.ais[player:objectName()]
	local arr = { "jieming", "yiji", "fangzhu" }
	local m_skill = false
	local attacker = global_room:getCurrent()

	if targets and type(targets)=="table" then
		if #targets == 1 then return true end
		local foundtarget = false
		for i = 1, #targets, 1 do
			if sgs.isGoodTarget(targets[i], nil, self) and not self:cantbeHurt(targets[i]) then
				foundtarget = true
				break
			end
		end
		if not foundtarget then return true end
	end

	for _, masochism in ipairs(arr) do
		if player:hasShownSkill(masochism) then
			if masochism == "jieming" and self and self:getJiemingChaofeng(player) > -4 then m_skill = false
			elseif masochism == "yiji" and self and not self:findFriendsByType(sgs.Friend_Draw, player) then m_skill = false
			else
				m_skill = true
				break
			end
		end
	end
	
	--if not (attacker and attacker:hasSkill("jueqing")) and player:hasShownSkill("Wuhun") and (player:getHp() <= 2) then
	if player:hasShownSkill("Wuhun") and (player:getHp() <= 2) and global_room:alivePlayerCount() > 2 then  --？？
		return false
	end

	if isSlash and self and (self:hasCrossbowEffect() or self:getCardsNum("Crossbow") > 0) and self:getCardsNum("Slash") > player:getHp() then
		return true
	end

	if m_skill and sgs.isGoodHp(player, self and self.player) then
		return false
	else
		return true
	end
end
sgs.ai_card_intention.Peach = function(self, card, from, tos)				--武魂
	for _, to in ipairs(tos) do
		if to:hasShownSkill("Wuhun") then continue end
		sgs.updateIntention(from, to, -120)
	end
end
function SmartAI:slashProhibit(card, enemy, from, ignore_armor)				--燃殇、无前（ignore_armor）
	card = card or sgs.cloneCard("slash", sgs.Card_NoSuit, 0)
	from = from or self.player
	if enemy:isRemoved() then return true end

	local nature = card:isKindOf("FireSlash") and sgs.DamageStruct_Fire
					or card:isKindOf("ThunderSlash") and sgs.DamageStruct_Thunder
	for _, askill in sgs.qlist(enemy:getVisibleSkillList(true)) do
		local filter = sgs.ai_slash_prohibit[askill:objectName()]
		if filter and type(filter) == "function" and filter(self, from, enemy, card) then return true end
	end

	if self:isFriend(enemy, from) then
		if (card:isKindOf("FireSlash") or from:hasWeapon("Fan")) and (enemy:hasArmorEffect("Vine") or enemy:hasShownSkill("Ranshang"))
			and not (enemy:isChained() and self:isGoodChainTarget(enemy, from, nil, nil, card)) then return true end
		if enemy:isChained() and card:isKindOf("NatureSlash") and self:slashIsEffective(card, enemy, from, ignore_armor)
			and not self:isGoodChainTarget(enemy, from, nature, nil, card) then return true end
		if getCardsNum("Jink",enemy, from) == 0 and enemy:getHp() < 2 and self:slashIsEffective(card, enemy, from, ignore_armor) then return true end
	else
		if card:isKindOf("NatureSlash") and enemy:isChained() and not self:isGoodChainTarget(enemy, from, nature, nil, card) and self:slashIsEffective(card, enemy, from, ignore_armor) then
			return true
		end
	end

	return not self:slashIsEffective(card, enemy, from, ignore_armor) -- @todo: param of slashIsEffective
end
function sgs.ai_slash_weaponfilter.Fan(self, to, player)					--燃殇
	return player:distanceTo(to) <= math.max(sgs.weapon_range.Fan, player:getAttackRange())
		and (to:hasArmorEffect("Vine") or (to:hasShownSkill("Ranshang") and not to:hasShownSkill("hongfa")))
end
function SmartAI:useCardArcheryAttack(card, use)							--悍勇
	if self:getAoeValue(card) > 0 then
		use.card = card
	elseif self.player:hasSkill("Hanyong") and self:willShowForAttack() then
		local first
		for _,p in sgs.qlist(self.room:getAllPlayers()) do
			if p:getSeat() == 1 then
				first = p
				break
			end
		end
		if self.player:getHp() < first:getMark("Global_TurnCount") - first:getMark("HanyongExtraTurnCount") + first:property("HanyongDragonPhoenixTurnCount"):toInt() then
			if self:getHanyongAoeValue(card, 2) > 0 then
				use.card = card
			end
		end
	end
end
function SmartAI:useCardSavageAssault(card, use)							--悍勇
	if self:getAoeValue(card) > 0 then
		use.card = card
	elseif self.player:hasSkill("Hanyong") and self:willShowForAttack() then
		local first
		for _,p in sgs.qlist(self.room:getAllPlayers()) do
			if p:getSeat() == 1 then
				first = p
				break
			end
		end
		if self.player:getHp() < first:getMark("Global_TurnCount") - first:getMark("HanyongExtraTurnCount") + first:property("HanyongDragonPhoenixTurnCount"):toInt() then
			if self:getHanyongAoeValue(card, 2) > 0 then
				use.card = card
			end
		end
	end
end
sgs.ai_nullification.ArcheryAttack = function(self, card, from, to, positive, keep)	--悍勇
	local targets = sgs.SPlayerList()
	local players = self.room:getTag("targets" .. card:toString()):toList()
	for _, q in sgs.qlist(players) do
		targets:append(q:toPlayer())
	end

	local hasHeavyDamage = (card:hasFlag("HanyongAddDamage"))

	if positive then
		if self:isFriend(to) then
			if keep then
				for _, p in sgs.qlist(targets) do
					if self:isFriend(p) and self:aoeIsEffective(card, p, from)
						and not p:hasArmorEffect("EightDiagram") and self:getDamagedEffects(p, from) and self:isWeak(p)  --怎么看怎么觉得应该是not getEffects
						and getKnownCard(p, self.player, "Jink", true, "he") == 0 then
						keep = false
					end
				end
			end
			if keep then return false end

			local heg_null_card = self:getCard("HegNullification") or (self.room:getTag("NullifyingTimes"):toInt() > 0 and self.room:getTag("NullificatonType"):toBool())
			if heg_null_card and self:aoeIsEffective(card, to, from) then
				targets:removeOne(to)
				for _, p in sgs.qlist(targets) do
					if to:isFriendWith(p) and self:aoeIsEffective(card, p, from) then return true, false end
				end
			end

			if not self:aoeIsEffective(card, to, from) then
				return
			elseif self:getDamagedEffects(to, from) and not hasHeavyDamage then
				return
			elseif to:objectName() == self.player:objectName() and self:canAvoidAOE(card) then
				return
			elseif (getKnownCard(to, self.player, "Jink", true, "he") >= 1 or to:hasArmorEffect("EightDiagram")) and to:getHp() > 1 then
				return
			elseif not self:isFriendWith(to) and self:playerGetRound(to) < self:playerGetRound(self.player) and self:isWeak() then
				return
			else
				return true, true
			end
		end
	else
		if not self:isFriend(from) or not(self:isEnemy(to) and from:isFriendWith(to)) then return false end
		if keep then
			for _, p in sgs.qlist(targets) do
				if self:isEnemy(p) and self:aoeIsEffective(card, p, from)
					and not p:hasArmorEffect("EightDiagram") and self:getDamagedEffects(p, from) and self:isWeak(p)
					and getKnownCard(p, self.player, "Jink", true, "he") == 0 then
					keep = false
				end
			end
		end
		if keep or not self:isEnemy(to) then return false end
		local nulltype = self.room:getTag("NullificatonType"):toBool()
		if nulltype then
			targets:removeOne(to)
			local num = 0
			local weak
			for _, p in sgs.qlist(targets) do
				if to:isFriendWith(p) and self:aoeIsEffective(card, p, from) then
					num = num + 1
				end
				if self:isWeak(to) or self:isWeak(p) then
					weak = true
				end
			end
			return num > 1 or weak, true
		else
			if self:isWeak(to) then return true, true end
		end		
	end
	return
end
sgs.ai_nullification.SavageAssault = function(self, card, from, to, positive, keep)	--悍勇
	local targets = sgs.SPlayerList()
	local players = self.room:getTag("targets" .. card:toString()):toList()
	for _, q in sgs.qlist(players) do
		targets:append(q:toPlayer())
	end

	local hasHeavyDamage = (card:hasFlag("HanyongAddDamage"))

	if positive then
		if self:isFriend(to) then
			local menghuo = sgs.findPlayerByShownSkillName("huoshou")
			local zhurong = sgs.findPlayerByShownSkillName("juxiang")
			if menghuo then targets:removeOne(menghuo) end
			if zhurong then targets:removeOne(zhurong) end

			if keep then
				for _, p in sgs.qlist(targets) do
					if self:isFriend(p) and self:aoeIsEffective(card, p, menghuo or from)
						and self:getDamagedEffects(p, menghuo or from) and self:isWeak(p)
						and getKnownCard(p, self.player, "Slash", true, "he") == 0 then
						keep = false
					end
				end
			end
			if keep then return false end

			local heg_null_card = self:getCard("HegNullification") or (self.room:getTag("NullifyingTimes"):toInt() > 0 and self.room:getTag("NullificatonType"):toBool())
			if heg_null_card and self:aoeIsEffective(card, to, menghuo or from) then
				targets:removeOne(to)
				for _, p in sgs.qlist(targets) do
					if to:isFriendWith(p) and self:aoeIsEffective(card, p, menghuo or from) then return true, false end
				end
			end

			if not self:aoeIsEffective(card, to, menghuo or from) then
				return
			elseif self:getDamagedEffects(to, menghuo or from) and not hasHeavyDamage then
				return
			elseif to:objectName() == self.player:objectName() and self:canAvoidAOE(card) then
				return
			elseif getKnownCard(to, self.player, "Slash", true, "he") >= 1 and to:getHp() > 1 then
				return
			elseif not self:isFriendWith(to) and self:playerGetRound(to) < self:playerGetRound(self.player) and self:isWeak() then
				return
			else
				return true, true
			end
		end
	else
		if not self:isFriend(from) or not(self:isEnemy(to) and from:isFriendWith(to)) then return false end
		if keep then
			for _, p in sgs.qlist(targets) do
				if self:isEnemy(p) and self:aoeIsEffective(card, p, menghuo or from)
					and self:getDamagedEffects(p, menghuo or from) and self:isWeak(p)
					and getKnownCard(p, self.player, "Slash", true, "he") == 0 then
					keep = false
				end
			end
		end
		if keep or not self:isEnemy(to) then return false end
		local nulltype = self.room:getTag("NullificatonType"):toBool()
		if nulltype then
			targets:removeOne(to)
			local num = 0
			local weak
			for _, p in sgs.qlist(targets) do
				if to:isFriendWith(p) and self:aoeIsEffective(card, p, menghuo or from) then
					num = num + 1
				end
				if self:isWeak(to) or self:isWeak(p) then
					weak = true
				end
			end
			return num > 1 or weak, true
		else
			if self:isWeak(to) then return true, true end
		end		
	end
	return
end
sgs.ai_card_intention.Collateral = function(self,card, from, tos)			--巧说乱战（目标数不为1）
	--assert(#tos == 1)
	sgs.ai_collateral = true
end
function SmartAI:useCardExNihilo(card, use)									--滔乱
	if self:getOverflow() >= 2 and not self:hasCrossbowEffect()
		and not (self.player:getPhase() ~= sgs.Player_NotActive and self.player:hasSkills(sgs.Active_cardneed_skill))
		and not (self.player:getPhase() == sgs.Player_NotActive and self.player:hasSkills(sgs.notActive_cardneed_skill)) then
		if self:preventLowValueTrick(card) then return end
	end
	use.card = card
end
function SmartAI:slashIsAvailable(player, slash) -- @todo: param of slashIsAvailable  --滔乱
	player = player or self.player
	if slash and not slash:isKindOf("Slash") and (slash:objectName() == "TaoluanCard" or slash:objectName() == "TaoluanOLCard") then
		local userstring = slash:toString()
		userstring = (userstring:split(":"))[4]:split("&")[1]
		local taoluancard = sgs.Sanguosha:cloneCard(userstring, slash:getSuit(), slash:getNumber())
		local skillName = (slash:objectName() == "TaoluanCard") and "Taoluan" or "TaoluanOL"
		taoluancard:setSkillName(skillName)
		taoluancard:setShowSkill(skillName)
		return self:slashIsAvailable(player, taoluancard)
	end
	if slash and not slash:isKindOf("Slash") then
		self.room:writeToConsole(debug.traceback())
	end
	slash = slash or sgs.cloneCard("slash")
	return slash:isAvailable(player)
end

--maneuvering
function SmartAI:useCardIronChain(card, use)								--巧说（防止新加目标与原有目标重复）、界陆逊、乱战、滔乱、无谋
	local needTarget = not card:canRecast() or card:getSkillName() == "Taoluan" or card:getSkillName() == "TaoluanOL"
	if self.player:isLocked(card) then return end
	use.card = card
	if not needTarget then
		if #self.enemies == 1 and #self:getChainedFriends() <= 1 then return end
		if self.player:hasShownSkill("Wumou") and self.player:getMark("@wrath") < 7 then return end
	end
	local friendtargets, friendtargets2 = {}, {}
	local enemytargets = {}
	self:sort(self.friends, "defense")
	for _, friend in ipairs(self.friends) do
		if use.current_targets and table.contains(use.current_targets, friend:objectName()) then continue end  --巧说
		if friend:isChained() and not self:isGoodChainPartner(friend) and self:hasTrickEffective(card, friend, self.player) then
			if friend:containsTrick("lightning") then
				table.insert(friendtargets, friend)
			else
				table.insert(friendtargets2, friend)
			end
		end
	end
	table.insertTable(friendtargets, friendtargets2)
	self:sort(self.enemies, "defense")
	for _, enemy in ipairs(self.enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
			and not enemy:isChained()
			and self:hasTrickEffective(card, enemy, self.player) and self:objectiveLevel(enemy) > 3
			and not self:getDamagedEffects(enemy) and not self:needToLoseHp(enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then
			table.insert(enemytargets, enemy)
		end
	end
	local luxun_friend
	for _, friend in ipairs(self.friends_noself) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and self:hasTrickEffective(card, friend, self.player) 
			and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() then  --界陆逊
			luxun_friend = friend
			break
		end
	end

	local chainSelf = (not use.current_targets or not table.contains(use.current_targets, self.player:objectName()))  --巧说
						and self:hasTrickEffective(card, self.player, self.player) and not self.player:isChained()
						and (self:needToLoseHp(self.player, nil, nil, true) or self:getDamagedEffects(self.player))
						and (self:getCardId("FireSlash") or self:getCardId("ThunderSlash")
							or (self:getCardId("Slash") and self.player:hasWeapon("Fan"))
							or (self:getCardId("FireAttack") and self.player:getHandcardNum() > 2))

	local targets_num = 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, card)

	if #friendtargets > 1 then
		if use.to then
			for _, friend in ipairs(friendtargets) do
				use.to:append(friend)
				if use.to:length() == targets_num then return end
			end
		end
	elseif #friendtargets == 1 then
		if #enemytargets > 0 then
			if use.to then
				use.to:append(friendtargets[1])
				for _, enemy in ipairs(enemytargets) do
					use.to:append(enemy)
					if use.to:length() == targets_num then return end
				end
			end
		elseif chainSelf then
			if use.to then use.to:append(friendtargets[1]) end
			if use.to then use.to:append(self.player) end
		elseif use.current_targets then  --巧说
			if use.to then use.to:append(friendtargets[1]) end
		end
	elseif #enemytargets > 1 then
		if use.to then
			for _, enemy in ipairs(enemytargets) do
				use.to:append(enemy)
				if use.to:length() == targets_num then return end
			end
		end
	elseif luxun_friend then  --界陆逊
		if use.to then
			use.to = sgs.SPlayerList()
			use.to:append(luxun_friend)
			return
		end
	elseif #enemytargets == 1 then
		if chainSelf then
			if use.to then use.to:append(enemytargets[1]) end
			if use.to then use.to:append(self.player) end
		elseif use.current_targets then  --巧说
			if use.to then use.to:append(enemytargets[1]) end
		end
	end
	
	if self.player:hasShownSkill("Luanzhan") and card:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and not self:hasTrickEffective(card, enemy, self.player) and not self.player:isProhibited(enemy, card) then
				use.to:append(enemy)
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getAlivePlayers()) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and not self:hasTrickEffective(card, target, self.player) and not self.player:isProhibited(target, card) then
				use.to:append(target)
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
	if use.to then assert(use.to:length() < targets_num + 1) end
	if needTarget and use.to and use.to:isEmpty() then use.card = nil end  --滔乱（needTarget）
end
sgs.ai_skill_cardask["@fire-attack"] = function(self, data, pattern, target)--界陆逊（火攻队友）、燃殇、乱战（撑目标）
	--处理被迫火攻队友的情况（如与界陆逊配合、队友严白虎被寄篱）
	if self:isFriend(target) then
		local damage = 1
		if not target:hasArmorEffect("SilverLion") then
			if target:hasArmorEffect("Vine") then damage = damage + 1 end
		end
		if target:hasShownSkill("mingshi") and not self.player:hasShownAllGenerals() then
			damage = damage - 1
		end
		local fire_attack = sgs.Sanguosha:cloneCard("fire_attack")
		fire_attack:deleteLater()
		if self:damageIsEffective(target, sgs.DamageStruct_Fire, self.player)
			and not (target:isChained() and self:isGoodChainTarget(target, self.player, sgs.DamageStruct_Fire, damage, fire_attack)) then
			return "."
		end
	end
	if not self:damageIsEffective(target, sgs.DamageStruct_Fire, self.player) then return "." end  --乱战撑目标的情况
	
	local cards = sgs.QList2Table(self.player:getHandcards())
	local convert = { [".S"] = "spade", [".D"] = "diamond", [".H"] = "heart", [".C"] = "club"}
	local card

	self:sortByUseValue(cards, true)

	for _, acard in ipairs(cards) do
		if acard:getSuitString() == convert[pattern] then
			if not isCard("Peach", acard, self.player) then
				card = acard
				break
			else
				local needKeepPeach = true
				if (self:isWeak(target) and not self:isWeak()) or target:getHp() == 1
						or self:isGoodChainTarget(target) or target:hasArmorEffect("Vine") or (target:hasShownSkill("Ranshang") and not target:hasShownSkill("hongfa")) then
					needKeepPeach = false
				end
				if not needKeepPeach then
					card = acard
					break
				end
			end
		end
	end
	return card and card:getId() or "."
end
function SmartAI:useCardFireAttack(fire_attack, use)						--巧说（防止新加目标与原有目标重复）、界陆逊、燃殇、乱战、滔乱

	local lack = {
		spade = true,
		club = true,
		heart = true,
		diamond = true,
	}

	local cards = self.player:getHandcards()
	local canDis = {}
	for _, card in sgs.qlist(cards) do
		if card:getEffectiveId() ~= fire_attack:getEffectiveId() then
			table.insert(canDis, card)
			lack[card:getSuitString()] = false
		end
	end

	if self.player:hasSkill("hongyan") then
		lack.spade = true
	end

	local suitnum = 0
	for suit,islack in pairs(lack) do
		if not islack then suitnum = suitnum + 1  end
	end


	self:sort(self.enemies, "defense")

	local can_attack = function(enemy)
		if self.player:hasFlag("FireAttackFailed_" .. enemy:objectName()) then
			return false
		end
		local damage = 1
		if not enemy:hasArmorEffect("SilverLion") then
			if enemy:hasArmorEffect("Vine") then damage = damage + 1 end
		end
		if enemy:hasShownSkill("mingshi") and not self.player:hasShownAllGenerals() then
			damage = damage - 1
		end
		return self:objectiveLevel(enemy) > 3 and damage > 0 and not enemy:isKongcheng()
				and self:damageIsEffective(enemy, sgs.DamageStruct_Fire, self.player) and not self:cantbeHurt(enemy, self.player, damage)
				and self:hasTrickEffective(fire_attack, enemy)
				and sgs.isGoodTarget(enemy, self.enemies, self)
				and (not (enemy:hasShownSkills("jianxiong|JianxiongLB") and not self:isWeak(enemy)) and not self:getDamagedEffects(enemy, self.player)
						and not (enemy:isChained() and not self:isGoodChainTarget(enemy, nil, nil, nil, fire_attack)))
	end

	local enemies, targets = {}, {}
	for _, enemy in ipairs(self.enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and can_attack(enemy)  --巧说
			and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)) and #self:getFriends(enemy) >= 3) then  --界陆逊（这里的要求比别的苛刻一些，因为火攻骗谦逊然后酒杀还是很常见的）
			table.insert(enemies, enemy)
		end
	end

	local can_FireAttack_self
	for _, card in ipairs(canDis) do
		if (not isCard("Peach", card, self.player) or self:getCardsNum("Peach") >= 3) and not self.player:hasArmorEffect("IronArmor")
			and (not isCard("Analeptic", card, self.player) or self:getCardsNum("Analeptic") >= 2) then
			can_FireAttack_self = true
		end
	end

	if (not use.current_targets or not table.contains(use.current_targets, self.player:objectName())) --巧说
		and can_FireAttack_self and self.player:isChained() and self:isGoodChainTarget(self.player, nil, nil, nil, fire_attack)
		and self.player:getHandcardNum() > 1
		and self:damageIsEffective(self.player, sgs.DamageStruct_Fire, self.player) and not self:cantbeHurt(self.player)
		and self:hasTrickEffective(fire_attack, self.player) then

		if hasNiepanEffect(self.player) then
			table.insert(targets, self.player)
		elseif hasBuquEffect(self.player)then
			table.insert(targets, self.player)
		else
			local leastHP = 1
			if self.player:hasArmorEffect("Vine") then leastHP = leastHP + 1 end
			if self.player:getHp() > leastHP then
				table.insert(targets, self.player)
			elseif self:getCardsNum("Peach") + self:getCardsNum("Analeptic") > self.player:getHp() - leastHP then
				table.insert(targets, self.player)
			end
		end
	end

	for _, enemy in ipairs(enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and enemy:getHandcardNum() == 1 then  --巧说
			local handcards = sgs.QList2Table(enemy:getHandcards())
			if sgs.cardIsVisible(handcards[1], enemy, self.player) then
				local suitstring = handcards[1]:getSuitString()
				if not lack[suitstring] and not table.contains(targets, enemy) then
					table.insert(targets, enemy)
				end
			end
		end
	end

	if ((suitnum == 2 and lack.diamond == false) or suitnum <= 1)
		and (self:getOverflow() <= (self.player:hasSkill("jizhi") and -2 or 0) or self:preventLowValueTrick(fire_attack))
		and #targets == 0 then return end
		

	for _, enemy in ipairs(enemies) do
		local damage = 1
		if not enemy:hasArmorEffect("SilverLion") then
			if enemy:hasArmorEffect("Vine") then damage = damage + 1 end
		end
		if enemy:hasShownSkill("mingshi") and not self.player:hasShownAllGenerals() then
			damage = damage - 1
		end
		if damage > 0 and enemy:hasShownSkill("Ranshang") and not enemy:hasShownSkill("hongfa") then
			damage = damage + 1
		end
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
			and self:damageIsEffective(enemy, sgs.DamageStruct_Fire, self.player) and damage > 1 then
			if not table.contains(targets, enemy) then table.insert(targets, enemy) end
		end
	end
	
	--界陆逊配合
	for _, friend in ipairs(self.friends_noself) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and self:hasTrickEffective(fire_attack, friend) and (#targets == 0) and (use.to and use.to:length() == 0)
			and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() then  --界陆逊
			use.card = fire_attack
			if use.to then use.to:append(friend) return end
		end
	end
	
	for _, enemy in ipairs(enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not table.contains(targets, enemy) then table.insert(targets, enemy) end  --巧说
	end

	if #targets > 0 then
		local godsalvation = self:getCard("GodSalvation")
		if godsalvation and godsalvation:getId() ~= fire_attack:getId() and self:willUseGodSalvation(godsalvation) then
			local use_gs = true
			for _, p in ipairs(targets) do
				if not p:isWounded() or not self:hasTrickEffective(godsalvation, p, self.player) then break end
				use_gs = false
			end
			if use_gs then
				use.card = godsalvation
				return
			end
		end

		local targets_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, fire_attack)
		use.card = fire_attack
		for i = 1, #targets, 1 do
			if use.to then
				use.to:append(targets[i])
				if use.to:length() == targets_num then return end
			end
		end
	end
	
	local targets_num = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, fire_attack)
	if self.player:hasShownSkill("Luanzhan") and fire_attack:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and (not self:damageIsEffective(enemy, sgs.DamageStruct_Fire, self.player) or not self:hasTrickEffective(fire_attack, enemy)) and not self.player:isProhibited(enemy, fire_attack) and not enemy:isKongcheng() then
				use.to:append(enemy)
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getAlivePlayers()) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and (not self:damageIsEffective(target, sgs.DamageStruct_Fire, self.player) or not self:hasTrickEffective(fire_attack, target)) and not self.player:isProhibited(target, fire_attack) and not target:isKongcheng() then
				use.to:append(target)
				if targets_num <= use.to:length() or self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
end
function SmartAI:shouldUseAnaleptic(target, card_use, anal)					--铁骑、无双、归心、诈降、仁心、义绝、RE破军、酒诗、滔乱

	if target:hasArmorEffect("SilverLion") and not self.player:hasWeapon("QinggangSword") then return false end
	if self:evaluateKingdom(target) == "unknown" then return end

	for _, p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:hasShownSkill("qianhuan") and not p:getPile("sorcery"):isEmpty() and p:getKingdom() == target:getKingdom() and card_use.to:length() <= 1 then
			return false
		end
	end

	if target:hasShownSkill("xiangle") then
		local basicnum = 0
		for _, acard in sgs.qlist(self.player:getHandcards()) do
			if acard:getTypeId() == sgs.Card_TypeBasic and not acard:isKindOf("Peach") then basicnum = basicnum + 1 end
		end
		if basicnum < 3 then return false end
	end
	
	local canPojunREArmor = false
	local pojun_ratio = 0
	if self.player:hasSkill("PojunRE") and self.player:getPhase() == sgs.Player_Play and target:getHp() > 0 and not target:isNude() then
		canPojunREArmor = target:getArmor() and not self:hasSkill(sgs.viewhas_armor_skill, target)
		local pojun_ratio = (math.min(target:getHp(), target:getCardCount(true)) - (target:getArmor() and 1 or 0)) / target:getHandcardNum()
		if pojun_ratio > 1 then pojun_ratio = 1 end  --能被移走的手牌比例（如5手牌2血则为2/5）
	end

	if target:getHp() == 1 and self:hasRenxinEffect(target, self.player, false, 2, true, card_use.card, nil, true) then return false end
	if target:getHp() == 1 and ((target:hasShownSkill("BuquRenew_ZhouTai_13") and not target:hasFlag("BuquRenew_ZhouTai_13InMyTurn"))
		or (target:hasShownSkill("BuquRenew_ZhouTai_15") and not target:hasFlag("BuquRenew_ZhouTai_15InMyTurn"))) then return false end
	if target:hasArmorEffect("Breastplate") and target:getHp() <= 2 and not IgnoreArmor(self.player, target) and not canPojunREArmor then return false end  --帮助开发组

	if target:hasArmorEffect("PeaceSpell") and not IgnoreArmor(self.player, target) and not canPojunREArmor and card_use.card and card_use.card:isKindOf("NatureSlash") then return false end  --似乎忘了IgnoreArmor？帮忙补上了
	
	if target:hasShownSkill("Guixin") and self.player:aliveCount() >= 4 then return false end

	local hcard = target:getHandcardNum()
	if self.player:hasSkill("liegong") and self.player:getPhase() == sgs.Player_Play and (hcard >= self.player:getHp() or hcard <= self.player:getAttackRange()) then return true end
	if self.player:hasSkills("tieqi|TieqiLB") then return true end
	if card_use.card and self:canZhaxiang(self.player, nil, card_use.card) then return true end
	if target:getMark("Yijue") > 0 then return true end

	if self.player:hasWeapon("Axe") and self.player:getCards("he"):length() > 4 then return true end

	if self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") then
		if getKnownCard(target, player, "Jink", true, "he") >= 2 then return false end
		return getCardsNum("Jink", target, self.player) < 2
	end
	
	local isOverflow = false
	if anal:getSkillName() == "Jiushi" then
		isOverflow = not self:toTurnOver(self.player) or self.player:hasSkills("jushou|Jushou_13")
	elseif anal:getSkillName() == "Taoluan" or anal:getSkillName() == "TaoluanOL" then
	else
		isOverflow = (self:getOverflow() > 0)
	end
	
	if pojun_ratio > 0 then
		if pojun_ratio == 1 then return true end
		if getKnownCard(target, self.player, "Jink", true, "he") * (1 - pojun_ratio) >= 0.5 and not (isOverflow and self:getCardsNum("Analeptic") > 1) then return false end
		return self:getCardsNum("Analeptic") > 1 or getCardsNum("Jink", target, self.player) * (1 - pojun_ratio) < 1 or sgs.card_lack[target:objectName()]["Jink"] == 1 or isOverflow
	end

	if getKnownCard(target, self.player, "Jink", true, "he") >= 1 and not (self:getOverflow() > 0 and self:getCardsNum("Analeptic") > 1) then return false end
	return self:getCardsNum("Analeptic") > 1 or getCardsNum("Jink", target, self.player) < 1 or sgs.card_lack[target:objectName()]["Jink"] == 1 or isOverflow
end
function SmartAI:useCardSupplyShortage(card, use)							--界陆逊、克己、急救、反间、突袭、遗计（牌堆）、峻刑、涉猎、琴音、弘德、绝境
	local enemies = self:exclude(self.enemies, card)

	local zhanghe = sgs.findPlayerByShownSkillName("qiaobian")
	local zhanghe_seat = zhanghe and zhanghe:faceUp() and not zhanghe:isKongcheng() and not self:isFriend(zhanghe) and zhanghe:getSeat() or 0

	if #enemies == 0 then return end

	local getvalue = function(enemy)
		if card:isBlack() and enemy:hasShownSkill("weimu") then return -100 end
		if enemy:containsTrick("supply_shortage") or enemy:containsTrick("YanxiaoCard") then return -100 end
		if enemy:hasShownSkill("qiaobian") and not enemy:containsTrick("supply_shortage") and not enemy:containsTrick("indulgence") then return -100 end
		if zhanghe_seat > 0 and (self:playerGetRound(zhanghe) <= self:playerGetRound(enemy) and self:enemiesContainsTrick() <= 1 or not enemy:faceUp()) then
			return - 100 end
			
		local yiji_pile = enemy:getPile("YijiLB"):length() or 0
		local value = 0 - enemy:getHandcardNum() + yiji_pile * 2

		if enemy:hasShownSkills("haoshi|tuxi|lijian|fanjian|dimeng|jijiu|jieyin|beige|jijiu_HuaTuo_LB|TuxiLB|FanjianLB|Junxing")
		  or (enemy:hasShownSkill("zaiqi") and enemy:getLostHp() > 1)
			then value = value + 10
		end
		if enemy:hasShownSkills(sgs.cardneed_skill .. "|tianxiang|Qinyin")
			then value = value + 5
		end
		if enemy:hasShownSkills("yingzi_zhouyu|yingzi_sunce|duoshi|Shelie") then value = value + 1 end
		if enemy:hasShownSkill("Hongde") and self:findFriendsByType(sgs.Friend_Draw, enemy) then value = value + 1 end
		if enemy:hasShownSkill("Juejing") and enemy:getLostHp() > 0 then value = value + 1 end
		if self:isWeak(enemy) then value = value + 5 end
		if enemy:isLord() then value = value + 3 end

		if self:objectiveLevel(enemy) < 3 then value = value - 10 end
		if not enemy:faceUp() then value = value - 10 end
		if enemy:hasShownSkills("keji|shensu|keji_LyuMeng_LB") then value = value - enemy:getHandcardNum() end
		if enemy:hasShownSkills("QianxunLB+Lianying") then value = value - enemy:getHandcardNum() end  --界陆逊
		if enemy:hasShownSkills("guanxing|tiandu|guidao") then value = value - 5 end
		if not sgs.isGoodTarget(enemy, self.enemies, self) then value = value - 1 end
		if self:needKongcheng(enemy) then value = value - 1 end
		return value
	end

	local cmp = function(a,b)
		return getvalue(a) > getvalue(b)
	end

	table.sort(enemies, cmp)

	local target = enemies[1]
	if getvalue(target) > -100 then
		use.card = card
		if use.to then use.to:append(target) end
		return
	end
end
function sgs.ai_armor_value.Vine(player, self)								--业炎、陷嗣、燃殇、龙魂、仁德（待处理：活墨振赡）
	if self:needKongcheng(player) and player:getHandcardNum() == 1 then
		return player:hasShownSkill("kongcheng") and 5 or 3.8
	end
	if self.player:hasSkills(sgs.lose_equip_skill) then return 3.8 end
	if not self:damageIsEffective(player, sgs.DamageStruct_Fire) then return 6 end

	local fslash = sgs.cloneCard("fire_slash")
	local tslash = sgs.cloneCard("thunder_slash")
	if player:isChained() and (not self:isGoodChainTarget(player, self.player, nil, nil, fslash) or not self:isGoodChainTarget(player, self.player, nil, nil, tslash)) then return -2 end
	if player:hasShownSkill("Ranshang") and not player:hasShownSkill("hongfa") then return -2 end

	for _, enemy in ipairs(self:getEnemies(player)) do
		if enemy:hasShownSkill("jgbiantian") then return -2 end
		if (enemy:canSlash(player) and (enemy:hasWeapon("Fan") or enemy:hasShownSkills("Longhun|RendeLB"))) or enemy:hasShownSkill("huoji")  --V2源码是和火计放一块，这里分开了
			or (enemy:hasShownSkill("Yeyan") and enemy:getMark("@flame") > 0) then return -2 end
		if getKnownCard(enemy, player, "FireSlash", true) >= 1 or getKnownCard(enemy, player, "FireAttack", true) >= 1 or
			getKnownCard(enemy, player, "Fan") >= 1 then return -2 end
	end

	if player:hasShownSkill("Xiansi") and player:getPile("counter"):length() >= 3 then return 7 end
	if (#self.enemies < 3 and sgs.turncount > 2) or player:getHp() <= 2 then return 5 end
	return 1
end
function SmartAI:isGoodChainTarget_(damageStruct)							--狂风
	local to = damageStruct.to
	if not to then self.room:writeToConsole(debug.traceback()) return end
	if not to:isChained() then return not self:isFriend(to) end
	local from = damageStruct.from or self.player
	local nature = damageStruct.nature or sgs.DamageStruct_Fire
	local damage = damageStruct.damage or 1
	local card = damageStruct.card

	if card and card:isKindOf("Slash") then
		nature = card:isKindOf("FireSlash") and sgs.DamageStruct_Fire
					or card:isKindOf("ThunderSlash") and sgs.DamageStruct_Thunder
					or sgs.DamageStruct_Normal
		damage = self:hasHeavySlashDamage(from, card, to, true)
	elseif nature == sgs.DamageStruct_Fire then
		if to:getMark("@gale") > 0 then damage = damage + 1 end
		if to:getMark("@gale_ShenZhuGeLiang") > 0 then damage = damage + 1 end
	end

	if not self:damageIsEffective_(damageStruct) then return end
	if card and card:isKindOf("TrickCard") and not self:hasTrickEffective(card, to, self.player) then return end

	local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
	if jiaren_zidan and jiaren_zidan:isFriendWith(to) then
		damage = 1
	end

	if nature == sgs.DamageStruct_Fire then
		if to:hasArmorEffect("Vine") then damage = damage + 1 end
	end

	if to:hasArmorEffect("SilverLion") then damage = 1 end

	local punish
	local kills, the_enemy = 0
	local good, bad, F_count, E_count = 0, 0, 0, 0
	local peach_num = self.player:objectName() == from:objectName() and self:getCardsNum("Peach") or getCardsNum("Peach", from, self.player)

	local function getChainedPlayerValue(target, dmg)
		local newvalue = 0
		if self:isGoodChainPartner(target) then newvalue = newvalue + 1 end
		if self:isWeak(target) then newvalue = newvalue - 1 end
		if dmg and nature == sgs.DamageStruct_Fire then
			if target:hasArmorEffect("Vine") then dmg = dmg + 1 end
			if target:getMark("@gale") > 0 then dmg = dmg + 1 end
			if target:getMark("@gale_ShenZhuGeLiang") > 0 then dmg = dmg + 1 end
		end
		if self:cantbeHurt(target, from, damage) then newvalue = newvalue - 100 end
		if damage + (dmg or 0) >= target:getHp() then
			if self:isFriend(target) or self:isFriend(from) then newvalue = newvalue - sgs.getReward(to) end
			if self:isFriend(from) and self:isFriend(target) and not punish and getCardsNum("Peach", from, self.player) + getCardsNum("Peach", target, self.player) == 0 then
				punish = true
				newvalue = newvalue - from:getCardCount(true)
			end
			if self:isEnemy(target) then kills = kills + 1 end
			if target:objectName() == self.player:objectName() and #self.friends_noself == 0 and peach_num < damage + (dmg or 0) then newvalue = newvalue - 100 end
		else
			if self:isEnemy(target) and self:isFriend(from) and from:getHandcardNum() < 2 and target:hasShownSkills("ganglie") and from:getHp() == 1
				and self:damageIsEffective(from, nil, target) and peach_num < 1 then newvalue = newvalue - 100 end
		end

		if target:hasArmorEffect("SilverLion") then return newvalue - 1 end
		return newvalue - damage * 2 - (dmg and dmg * 2 or 0)
	end

	local value = getChainedPlayerValue(to)
	if self:isFriend(to) then
		good = value
		F_count = F_count + 1
	elseif self:isEnemy(to) then
		bad = value
		E_count = E_count + 1
	end

	if nature == sgs.DamageStruct_Normal then return good > bad end

	if card and card:isKindOf("FireAttack") and from:objectName() == to:objectName() then good = good - 1 end

	for _, player in sgs.qlist(self.room:getAllPlayers()) do
		local newDamageStruct = damageStruct
		newDamageStruct.to = player
		if nature == sgs.DamageStruct_Fire and player:hasArmorEffect("Vine") then newDamageStruct.damage = newDamageStruct.damage + 1 end
		if player:objectName() ~= to:objectName() and player:isChained() and self:damageIsEffective_(newDamageStruct)
			and not (card and card:isKindOf("FireAttack") and not self:hasTrickEffective(card, to, self.player)) then
			local getvalue = getChainedPlayerValue(player, 0)
			if kills == #self.enemies and sgs.getDefenseSlash(player, self) < 2 then
				if card and from:objectName() == self.room:getCurrent():objectName() and from:getPhase() == sgs.Player_Play then
					self.room:setCardFlag(card, "AIGlobal_KillOff") end
				return true
			end
			if self:isFriend(player) then
				good = good + getvalue
				F_count = F_count + 1
			else
				bad = bad + getvalue
				E_count = E_count + 1
				the_enemy = player
			end
		end
	end

	if card and F_count == 1 and E_count == 1 and the_enemy and the_enemy:isKongcheng() and the_enemy:getHp() == 1 then
		for _, c in ipairs(self:getCards("Slash")) do
			if not c:isKindOf("NatureSlash") and not self:slashProhibit(c, the_enemy, source) then return end
		end
	end

	if F_count > 0 and E_count <= 0 then return end

	return good > bad
end
function SmartAI:useCardAnaleptic(card, use)								--酒诗（曹植曹仁）
	if ((not self.player:hasEquip(card) and not self:hasLoseHandcardEffective() and not self:isWeak())
		or (card:getSkillName() == "Jiushi" and (self.player:hasSkills("jushou|Jushou_13") or not self:toTurnOver(self.player))))
		and sgs.Analeptic_IsAvailable(self.player, card) then
		use.card = card
	end
end
sgs.ai_skill_invoke.Fan = function(self, data)								--燃殇
	local use = data:toCardUse()

	for _, target in sgs.qlist(use.to) do
		if self:isFriend(target) then
			if not self:damageIsEffective(target, sgs.DamageStruct_Fire) then return true end
			if target:isChained() and self:isGoodChainTarget(target, nil, nil, nil, use.card) then return true end
		else
			if not self:damageIsEffective(target, sgs.DamageStruct_Fire) then return false end
			if target:isChained() and not self:isGoodChainTarget(target, nil, nil, nil, use.card) then return false end
			if target:hasArmorEffect("Vine") or target:hasShownSkill("Ranshang") then
				return true
			end
		end
	end
	return false
end
function sgs.ai_weapon_value.Fan(self, enemy)								--燃殇
	if enemy and (enemy:hasArmorEffect("Vine") or (enemy:hasShownSkill("Ranshang") and not enemy:hasShownSkill("hongfa"))) then return 6 end
end

--momentum
function sgs.ai_armor_value.PeaceSpell(player, self)						--燃殇
	if player:hasShownSkills("hongfa+wendao") then return 1000 end
	if getCardsNum("Peach", player, player) + getCardsNum("Analeptic", player, player) == 0 and player:getHp() == 1 then
		if player:hasArmorEffect("PeaceSpell") then return 99
		else return -99
		end
	end
	if player:hasShownSkill("Ranshang") then return 10 end
	return 3.5
end

--strategic_advantage
sgs.ai_skill_use_func.TransferCard = function(transferCard, use, self)		--绝策、拼点类技能

	local friends, friends_other = {}, {}
	local targets = sgs.PlayerList()
	for _, friend in ipairs(self.friends_noself) do
		if transferCard:targetFilter(targets, friend, self.player) and not self:needKongcheng(friend, true) then
			if friend:hasShownOneGeneral() then
				table.insert(friends, friend)
			else
				table.insert(friends_other, friend)
			end
		end
	end

	local cards = {}
	local oneJink = self.player:hasSkill("kongcheng")
	for _, c in sgs.qlist(self.player:getCards("he")) do
		if c:isTransferable() and (not isCard("Peach", c, self.player) or #friends > 0) then
			if not oneJink and isCard("Jink", c, self.player) then
				oneJink = true
				continue
			elseif c:getNumber() > 10 and self.player:hasSkills(sgs.pindian_skill) then --self.player:hasSkills("tianyi|quhu|shuangren|lieren") then
				continue
			end
			table.insert(cards, c)
		end
	end
	if #cards == 0 then return end

	if #friends > 0 then
		self:sortByUseValue(cards)
		if #friends > 0 then
			local card, target = self:getCardNeedPlayer(cards, friends, "transfer")
			if card and target then
				use.card = sgs.Card_Parse("@TransferCard=" .. card:getEffectiveId())
				if use.to then use.to:append(target) end
				return
			end
		end
	end

	if #friends_other > 0 then
		local card, target = self:getCardNeedPlayer(cards, friends_other, "transfer")
		if card and target then
			use.card = sgs.Card_Parse("@TransferCard=" .. card:getEffectiveId())
			if use.to then use.to:append(target) end
			return
		end
	end

	for _, card in ipairs(cards) do
		if card:isKindOf("ThreatenEmperor") then
			local anjiang = 0
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if sgs.isAnjiang(p) then anjiang = anjiang + 1 end
			end

			local big_kingdoms = self.player:getBigKingdoms("AI")
			local big_kingdom = #big_kingdoms > 0 and big_kingdoms[1]
			local maxNum = (big_kingdom and (big_kingdom:startsWith("sgs") and 99 or self.player:getPlayerNumWithSameKingdom("AI", big_kingdom)))
							or (anjiang == 0 and 99)
							or 0

			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasShownOneGeneral() and transferCard:targetFilter(targets, p, self.player) and (not p:hasFlag("preventgivecard"))		--加入（绝策）
					and p:objectName() ~= big_kingdom and (not table.contains(big_kingdoms, p:getKingdom()) or p:getRole() == "careerist")
					and (maxNum == 99 or p:getPlayerNumWithSameKingdom("AI") + anjiang < maxNum) then
					use.card = sgs.Card_Parse("@TransferCard=" .. card:getEffectiveId())
					if use.to then use.to:append(p) end
					return
				end
			end
		elseif card:isKindOf("BurningCamps") then
			local gameProcess = sgs.gameProcess()
			if string.find(gameProcess, self.player:getKingdom() .. ">") then
				for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
					if transferCard:targetFilter(targets, p, self.player) and (self:isFriend(p) or (p:hasShownOneGeneral() and self:willSkipPlayPhase(p))) and (not p:hasFlag("preventgivecard")) then		--加入（绝策）
						use.card = sgs.Card_Parse("@TransferCard=" .. card:getEffectiveId())
						if use.to then use.to:append(p) end
						return
					end
				end
			else
				for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
					if p:hasShownOneGeneral() and transferCard:targetFilter(targets, p, self.player) and card:isAvailable(p) and (not p:hasFlag("preventgivecard")) then		--加入（绝策）
						local np = p:getNextAlive()
						if not self:isFriend(np) and (not np:isChained() or self:isGoodChainTarget(np, p, sgs.DamageStruct_Fire, 1, use.card)) then
							use.card = sgs.Card_Parse("@TransferCard=" .. card:getEffectiveId())
							if use.to then use.to:append(p) end
							return
						end
					end
				end
			end
		end
	end
end
function SmartAI:useCardDrowning(card, use)									--巧说（防止新加目标与原有目标重复）、界陆逊、乱战
	if not card:isAvailable(self.player) then return end

	self:sort(self.enemies, "equip_defense")

	local players = sgs.PlayerList()
	for _, enemy in ipairs(self.enemies) do
		if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))
			and card:targetFilter(players, enemy, self.player) and not players:contains(enemy) and enemy:hasEquip()
			and self:hasTrickEffective(card, enemy) and self:damageIsEffective(enemy, sgs.DamageStruct_Thunder, self.player) and self:canAttack(enemy)
			and not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player) and not self:needToThrowArmor(enemy)
			and not (enemy:hasArmorEffect("PeaceSpell") and (enemy:getHp() > 1 or self:needToLoseHp(enemy, self.player)))
			and not (enemy:hasArmorEffect("Breastplate") and enemy:getHp() == 1)
			and not (enemy:hasShownSkills("QianxunLB+Lianying") and enemy:getHandcardNum() >= math.min(3, #self:getFriends(enemy)) and enemy:getEquips():length() <= 1) then  --界陆逊
			local dangerous
			local chained = {}
			--if enemy:isChained() and not self.player:hasShownSkill("jueqing") then
			if enemy:isChained() then
				for _, p in sgs.qlist(self.room:getOtherPlayers(enemy)) do
					if not self:isGoodChainTarget(enemy, p, sgs.DamageStruct_Thunder) and self:damageIsEffective(p, sgs.DamageStruct_Thunder) and self:isFriend(p) then
						table.insert(chained, p)
						if self:isWeak(p) then dangerous = true end
					end
				end
			end
			if #chained >= 2 then dangerous = true end
			if not dangerous then
				players:append(enemy)
				if use.to then use.to:append(enemy) end
			end
		end
	end

	for _, friend in ipairs(self.friends_noself) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and card:targetFilter(players, friend, self.player) and not players:contains(friend) and self:needToThrowArmor(friend) and friend:getEquips():length() == 1 then
			players:append(friend)
			if use.to then use.to:append(friend) end
		end
	end
	
	if self.player:hasShownSkill("Luanzhan") and card:isBlack() and use.to and not use.to:isEmpty() and use.to:length() < self.player:getMark("LuanzhanCount") then  --需要将目标撑到X
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName())) and not use.to:contains(enemy)
				and (not self:hasTrickEffective(card, enemy) or not self:damageIsEffective(enemy, sgs.DamageStruct_Thunder, self.player)) and card:targetFilter(players, enemy, self.player) and not self.player:isProhibited(enemy, card) then
				players:append(enemy)
				use.to:append(enemy)
				if self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and (not self:hasTrickEffective(card, target) or not self:damageIsEffective(target, sgs.DamageStruct_Thunder, self.player)) and card:targetFilter(players, target, self.player) and not self.player:isProhibited(target, card) then
				players:append(target)
				use.to:append(target)
				if self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end

	if not players:isEmpty() then
		use.card = card
		return
	end
end
function SmartAI:useCardLureTiger(LureTiger, use)							--巧说（防止新加目标与原有目标重复）、界陆逊、乱战、诛害、滔乱
	sgs.ai_use_priority.LureTiger = 4.9
	if not LureTiger:isAvailable(self.player) then return end

	local players = sgs.PlayerList()

	local card = self:getCard("BurningCamps")
	if card and card:isAvailable(self.player) then
		local nextp = self.room:nextPlayer(self.player)
		local first
		while true do
			if (not use.current_targets or not table.contains(use.current_targets, nextp:objectName()))  --巧说
				and LureTiger:targetFilter(players, nextp, self.player) and self:hasTrickEffective(LureTiger, nextp, self.player) then
				if not first then
					if self:isEnemy(nextp) then
						first = nextp
					else
						players:append(nextp)
					end
				else
					if not first:isFriendWith(nextp) then
						players:append(nextp)
					end
				end
				nextp = self.room:nextPlayer(nextp)
			else
				break
			end
		end
		if first then
			use.card = LureTiger
			if use.to then use.to = sgs.PlayerList2SPlayerList(players) end
			return
		end
	end

	players = sgs.PlayerList()

	card = self:getCard("ArcheryAttack")
	if card and card:isAvailable(self.player) and self:getAoeValue(card) > 0 then
		self:sort(self.friends_noself, "hp")
		--优先考虑界陆逊
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and self:isFriendWith(friend) and LureTiger:targetFilter(players, friend, self.player) and self:hasTrickEffective(LureTiger, friend, self.player)
				and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() then  --界陆逊
				players:append(friend)
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and self:isFriendWith(friend) and LureTiger:targetFilter(players, friend, self.player) and self:hasTrickEffective(LureTiger, friend, self.player) then
				players:append(friend)
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and LureTiger:targetFilter(players, friend, self.player) and not players:contains(friend) and self:hasTrickEffective(LureTiger, friend, self.player) then
				players:append(friend)
			end
		end
		if players:length() > 0 then
			sgs.ai_use_priority.LureTiger = sgs.ai_use_priority.ArcheryAttack + 0.2
			use.card = LureTiger
			if use.to then use.to = sgs.PlayerList2SPlayerList(players) end
			return
		end
	end

	players = sgs.PlayerList()

	card = self:getCard("SavageAssault")
	if card and card:isAvailable(self.player) and self:getAoeValue(card) > 0 then
		self:sort(self.friends_noself, "hp")
		--优先考虑界陆逊
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and self:isFriendWith(friend) and LureTiger:targetFilter(players, friend, self.player) and self:aoeIsEffective(LureTiger, friend, self.player) 
				and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() then  --界陆逊
				players:append(friend)
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and self:isFriendWith(friend) and LureTiger:targetFilter(players, friend, self.player) and self:aoeIsEffective(LureTiger, friend, self.player) then
				players:append(friend)
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
				and LureTiger:targetFilter(players, friend, self.player) and not players:contains(friend) and self:aoeIsEffective(LureTiger, friend, self.player) then
				players:append(friend)
			end
		end
		if players:length() > 0 then
			sgs.ai_use_priority.LureTiger = sgs.ai_use_priority.SavageAssault + 0.2
			use.card = LureTiger
			if use.to then use.to = sgs.PlayerList2SPlayerList(players) end
			return
		end
	end

	players = sgs.PlayerList()

	card = self:getCard("Slash")
	if card and self:slashIsAvailable(self.player, card) then
		local dummyuse = { isDummy = true, to = sgs.SPlayerList() }
		self.player:setFlags("slashNoDistanceLimit")
		self:useCardSlash(card, dummyuse)
		self.player:setFlags("-slashNoDistanceLimit")
		if dummyuse.card then
			local total_num = 2 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, LureTiger)
			local function getPlayersFromTo(one)
				local targets1 = sgs.PlayerList()
				local targets2 = sgs.PlayerList()
				local nextp = self.room:nextPlayer(self.player)
				while true do
					if (not use.current_targets or not table.contains(use.current_targets, nextp:objectName()))  --巧说
						and LureTiger:targetFilter(targets1, nextp, self.player) and self:hasTrickEffective(LureTiger, nextp, self.player) then
						if one:objectName() ~= nextp:objectName() then
							targets1:append(nextp)
						else
							break
						end
						nextp = self.room:nextPlayer(nextp)
					else
						targets1 = sgs.PlayerList()
						break
					end
				end
				nextp = self.room:nextPlayer(one)
				while true do
					if (not use.current_targets or not table.contains(use.current_targets, nextp:objectName()))  --巧说
						and LureTiger:targetFilter(targets2, nextp, self.player) and self:hasTrickEffective(LureTiger, nextp, self.player) then
						if self.player:objectName() ~= nextp:objectName() then
							targets2:append(nextp)
						else
							break
						end
						nextp = self.room:nextPlayer(nextp)
					else
						targets2 = sgs.PlayerList()
						break
					end
				end
				if targets1:length() > 0 and targets2:length() >= targets1:length() and targets1:length() <= total_num then
					return targets1
				elseif targets2:length() > 0 and targets1:length() >= targets2:length() and targets2:length() <= total_num then
					return targets2
				end
				return
			end

			for _, to in sgs.qlist(dummyuse.to) do
				if self.player:distanceTo(to) > self.player:getAttackRange() and self.player:distanceTo(to, -total_num) <= self.player:getAttackRange() then
					local sps = getPlayersFromTo(to)
					if sps then
						sgs.ai_use_priority.LureTiger = 3
						use.card = LureTiger
						if use.to then use.to = sgs.PlayerList2SPlayerList(sps) end
						return
					end
				end
			end
		end

	end

	players = sgs.PlayerList()

	card = self:getCard("GodSalvation")
	if card and card:isAvailable(self.player) then
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if (not use.current_targets or not table.contains(use.current_targets, enemy:objectName()))  --巧说
				and LureTiger:targetFilter(players, enemy, self.player) and self:hasTrickEffective(LureTiger, enemy, self.player) then
				players:append(enemy)
			end
		end
		if players:length() > 0 and not (players:length() == 1 and players:first():hasShownSkills("QianxunLB+Lianying") and players:first():getHandcardNum() >= math.min(3, #self:getFriends(players:first())) and not self:isWeak(players:first())) then  --界陆逊
			sgs.ai_use_priority.LureTiger = sgs.ai_use_priority.GodSalvation + 0.1
			use.card = LureTiger
			if use.to then use.to = sgs.PlayerList2SPlayerList(players) end
			return
		end
	end

	--界陆逊配合
	players = sgs.PlayerList()

	for _, friend in ipairs(self.friends_noself) do
		if (not use.current_targets or not table.contains(use.current_targets, friend:objectName()))  --巧说
			and LureTiger:targetFilter(players, friend, self.player) and self:hasTrickEffective(LureTiger, friend, self.player)
			and friend:hasShownSkills("QianxunLB+Lianying") and not friend:isKongcheng() and (use.to and use.to:isEmpty()) then  --界陆逊
			sgs.ai_use_priority.LureTiger = 0.32
			use.card = LureTiger
			if use.to then use.to:append(friend) end
			return
		end
	end

	players = sgs.PlayerList()
	local needLuanzhan = self.player:hasShownSkill("Luanzhan") and LureTiger:isBlack() and use.to and self.player:getMark("LuanzhanCount") > 1  --真要详细处理乱战的话，上面那些开A开桃园之类的都得写，但是懒得动了……

	if self.player:objectName() == self.room:getCurrent():objectName() and not self:preventLowValueTrick(LureTiger) then
		local xushu = sgs.findPlayerByShownSkillName("Zhuhai")  --防诛害
		if xushu and self:isEnemy(xushu) and xushu:canSlash(self.player, false) and self.player:hasFlag("ZhuhaiDamageInTurn")
			and not self:slashIsEffective(sgs.cloneCard("slash"), self.player, xushu) and not self:slashProhibit(nil, self.player, xushu) and not self:getDamagedEffects(self.player, xushu, true)
			and (not use.current_targets or not table.contains(use.current_targets, xushu:objectName()))  --巧说
			and LureTiger:targetFilter(players, xushu, self.player) and self:hasTrickEffective(LureTiger, xushu, self.player) then
			sgs.ai_use_priority.LureTiger = 0.3
			use.card = LureTiger
			if use.to then use.to:append(xushu) end
			if not needLuanzhan then return end
			needLuanzhan = self.player:hasShownSkill("Luanzhan") and LureTiger:isBlack() and use.to and use.to:length() < self.player:getMark("LuanzhanCount")
		end
		
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, player:objectName()))  --巧说
				and LureTiger:targetFilter(players, player, self.player) and self:hasTrickEffective(LureTiger, player, self.player) then
				sgs.ai_use_priority.LureTiger = 0.3
				use.card = LureTiger
				if use.to then use.to:append(player) end
				if not needLuanzhan then return end
				needLuanzhan = self.player:hasShownSkill("Luanzhan") and LureTiger:isBlack() and use.to and use.to:length() < self.player:getMark("LuanzhanCount")
			end
		end
		if not needLuanzhan then return end
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if (not use.current_targets or not table.contains(use.current_targets, target:objectName())) and not use.to:contains(target)
				and not self:hasTrickEffective(LureTiger, target) and LureTiger:targetFilter(players, target, self.player) and not self.player:isProhibited(target, LureTiger) then
				use.to:append(target)
				if self.player:getMark("LuanzhanCount") <= use.to:length() then return end
			end
		end
	end
end
function sgs.ai_armor_value.IronArmor(player, self)							--燃殇
	if self:isWeak(player) then
		for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
			if p:hasShownSkill("huoji") and self:isEnemy(player, p) then
				return 5
			end
		end
	end
	if player:hasShownSkill("Ranshang") and not player:hasShownSkill("hongfa") then return 4 end
	return 2.5
end
sgs.ai_nullification.BurningCamps = function(self, card, from, to, positive, keep)	--燃殇（待处理：绝情）
	local targets = sgs.SPlayerList()
	local players = self.room:getTag("targets" .. card:toString()):toList()
	for _, q in sgs.qlist(players) do
		targets:append(q:toPlayer())
	end
	if positive then
		if from:objectName() == self.player:objectName() then return false end
		local chained = {}
		local dangerous
		if self:damageIsEffective(to, sgs.DamageStruct_Fire) and to:isChained() --[[and not from:hasShownSkill("jueqing")]] then
			for _, p in sgs.qlist(self.room:getOtherPlayers(to)) do
				if not self:isGoodChainTarget(to, p, sgs.DamageStruct_Fire) and self:damageIsEffective(p, sgs.DamageStruct_Fire) and self:isFriend(p) then
					table.insert(chained, p)
					if self:isWeak(p) then dangerous = true end
				end
			end
		end
		if to:hasArmorEffect("Vine") and #chained > 0 then dangerous = true end
		local friends = {}
		if self:isFriend(to) then
			for _, p in sgs.qlist(targets) do
				if self:damageIsEffective(p, sgs.DamageStruct_Fire) then
					table.insert(friends, p)
					if self:isWeak(p) or p:hasArmorEffect("Vine") or (p:hasShownSkill("Ranshang") and not p:hasShownSkill("hongfa")) then dangerous = true end
				end
			end
		end
		if #chained + #friends > 2 or dangerous then return true, #friends <= 1 end
		if keep then return false end
		if self:isFriendWith(to) and self:isEnemy(from) then return true, #friends <= 1 end
	else
		if not self:isFriend(from) then return false end
		local chained = {}
		local dangerous
		local enemies = {}
		local good
		if self:damageIsEffective(to, sgs.DamageStruct_Fire) and to:isChained() --[[and not from:hasShownSkill("jueqing")]] then
			for _, p in sgs.qlist(self.room:getOtherPlayers(to)) do
				if not self:isGoodChainTarget(to, p, sgs.DamageStruct_Fire) and self:damageIsEffective(p, sgs.DamageStruct_Fire) and self:isFriend(p) then
					table.insert(chained, p)
					if self:isWeak(p) then dangerous = true end
				end
				if not self:isGoodChainTarget(to, p, sgs.DamageStruct_Fire) and self:damageIsEffective(p, sgs.DamageStruct_Fire) and self:isEnemy(p) then
					table.insert(enemies, p)
					if self:isWeak(p) then good = true end
				end
			end
		end
		if to:hasArmorEffect("Vine") and #chained > 0 then dangerous = true end
		if to:hasArmorEffect("Vine") and #enemies > 0 then good = true end
		local friends = {}
		if self:isFriend(to) then
			for _, p in sgs.qlist(targets) do
				if self:damageIsEffective(p, sgs.DamageStruct_Fire) then
					table.insert(friends, p)
					if self:isWeak(p) or p:hasArmorEffect("Vine") or (p:hasShownSkill("Ranshang") and not p:hasShownSkill("hongfa")) then dangerous = true end
				end
			end
		end
		if self:isEnemy(to) then
			for _, p in sgs.qlist(targets) do
				if self:damageIsEffective(p, sgs.DamageStruct_Fire) then
					if self:isWeak(p) or p:hasArmorEffect("Vine") or (p:hasShownSkill("Ranshang") and not p:hasShownSkill("hongfa")) then good = true end
				end
			end
		end
		if #chained + #friends > 2 or dangerous then return false end
		if keep then
			local nulltype = self.room:getTag("NullificatonType"):toBool()
			if nulltype and targets:length() > 1 then good = true end
			if good then keep = false end
		end
		if keep then return false end
		if self:isFriend(from) and self:isEnemy(to) then return true, true end
	end
	return
end
function SmartAI:useCardThreatenEmperor(card, use)							--忠义
	if not card:isAvailable(self.player) then return end
	if self.player:getCardCount(true) < 2 then return end
	if not self:hasTrickEffective(card, self.player, self.player) then return end
	if self.player:getPile("loyal"):length() > 0 then return end
	use.card = card
end
function SmartAI:useCardFightTogether(card, use)							--滔乱（重铸）、无谋
	self.FightTogether_choice = nil
	if not card:isAvailable(self.player) then return end
	
	if self.player:hasShownSkill("Wumou") and self.player:getMark("@wrath") < 7 then
		if not self.player:isCardLimited(card, sgs.Card_MethodRecast) and card:canRecast() and card:getSkillName() ~= "Taoluan" and card:getSkillName() ~= "TaoluanOL" then
			self.FightTogether_choice = "recast"
		end
		if self.FightTogether_choice then
			use.card = card
		end
		return
	end

	--@todo: consider hongfa

	local big_kingdoms = self.player:getBigKingdoms("AI")
	local bigs, smalls = {}, {}
	local isBig, isSmall
	for _, p in sgs.qlist(self.room:getAllPlayers()) do
		if self:hasTrickEffective(card, p, self.player) then
			local kingdom = p:objectName()
			if #big_kingdoms == 1 and big_kingdoms[1]:startsWith("sgs") then
				if table.contains(big_kingdoms, kingdom) then
					table.insert(bigs, p)
					if p:objectName() == self.player:objectName() then isBig = true end
				else
					if not(p:hasArmorEffect("IronArmor") and not p:isChained()) then
						table.insert(smalls, p)
						if p:objectName() == self.player:objectName() then isSmall = true end
					end
				end
			else
				if not p:hasShownOneGeneral() and not(p:hasArmorEffect("IronArmor") and not p:isChained()) then
					if p:objectName() == self.player:objectName() then isSmall = true end
					table.insert(smalls, p)
					continue
				elseif p:getRole() == "careerist" then
					kingdom = "careerist"
				else
					kingdom = p:getKingdom()
				end
				if table.contains(big_kingdoms, kingdom) then
					if p:objectName() == self.player:objectName() then isBig = true end
					table.insert(bigs, p)
				else
					if not(p:hasArmorEffect("IronArmor") and not p:isChained()) then
						if p:objectName() == self.player:objectName() then isSmall = true end
						table.insert(smalls, p)
					end
				end
			end
		end
	end

	local choices = {}
	if #bigs > 0 then table.insert(choices, "big") end
	if #smalls > 0 then table.insert(choices, "small") end

	if #choices > 0 then
		local v_big, v_small = 0, 0
		for _, p in ipairs(bigs) do
			v_big = v_big + (p:isChained() and -1 or 1)
		end
		if isBig then v_big = -v_big end
		for _, p in ipairs(smalls) do
			v_small = v_small + (p:isChained() and -1 or 1)
		end
		if isSmall then v_small = -v_small end

		if #choices == 1 then
			if table.contains(choices, "big") then
				if v_big > 0 then self.FightTogether_choice = "big" end
			else
				if v_small > 0 then self.FightTogether_choice = "small" end
			end
		else
			if isBig then
				if v_big > 0 and v_big == #bigs then self.FightTogether_choice = "big"
				elseif v_small > 0 then self.FightTogether_choice = "small"
				elseif v_big > 0 then self.FightTogether_choice = "big"
				end
			elseif isSmall then
				if v_small > 0 and v_small == #smalls then self.FightTogether_choice = "small"
				elseif v_big >= 0 then self.FightTogether_choice = "big"
				elseif v_small > 0 then self.FightTogether_choice = "small"
				end
			else
				if v_big > v_small and v_big > 0 then self.FightTogether_choice = "big"
				elseif v_small > v_big and v_small > 0 then self.FightTogether_choice = "small"
				elseif v_big == v_small and v_big > 0 then
					if #bigs > #smalls then self.FightTogether_choice = "big"
					elseif #bigs < #smalls then self.FightTogether_choice = "small"
					else
						self.FightTogether_choice = math.random(1, 2) == 1 and "big" or "small"
					end
				end
			end
		end
	end
	if (self.FightTogether_choice == "big" and #bigs == 1) or (self.FightTogether_choice == "small" and #smalls == 1) then
		local check
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			if p:isChained() and self:isEnemy(p) then
				check = true
				break
			end
		end
		if not check then self.FightTogether_choice = nil end
	end

	if not self.FightTogether_choice and not self.player:isCardLimited(card, sgs.Card_MethodRecast) and card:canRecast() and card:getSkillName() ~= "Taoluan" and card:getSkillName() ~= "TaoluanOL" then
		self.FightTogether_choice = "recast"
	end
	if self.FightTogether_choice then
		use.card = card
	end
end
function SmartAI:useCardImperialOrder(card, use)							--滔乱
	if not card:isAvailable(self.player) then return end
	if self:preventLowValueTrick(card) then return end
	use.card = card
end

--basara
sgs.ai_skill_choice["GameRule:TriggerOrder"] = function(self, choices, data)--董卓李儒（不过董卓的似乎没用？）、耀武、同时机技能顺序、仁德、七星、突袭、巨贾、
																			--资援、燃殇、弘德
	local canShowHead = string.find(choices, "GameRule_AskForGeneralShowHead")
	local canShowDeputy = string.find(choices, "GameRule_AskForGeneralShowDeputy")

	local firstShow = ("luanji|qianhuan"):split("|")
	local bothShow = ("luanji+shuangxiong|luanji+huoshui|huoji+jizhi|luoshen+fangzhu|guanxing+jizhi"):split("|")
	local followShow = ("qianhuan|duoshi|rende|cunsi|jieyin|xiongyi|shouyue|hongfa|RendeLB|Zhongyi|Ziyuan|Hongde"):split("|")

	local notshown, shown, allshown, f, e, eAtt = 0, 0, 0, 0, 0, 0
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if  not p:hasShownOneGeneral() then
			notshown = notshown + 1
		end
		if p:hasShownOneGeneral() then
			shown = shown + 1
			if self:evaluateKingdom(p) == self.player:getKingdom() then
				f = f + 1
			else
				e = e + 1
				if self:isWeak(p) and p:getHp() == 1 and self.player:distanceTo(p) <= self.player:getAttackRange() then eAtt= eAtt + 1 end
			end
		end
		if p:hasShownAllGenerals() then
			allshown = allshown + 1
		end
	end

	local showRate = math.random() + shown/20

	local firstShowReward = false
	if sgs.GetConfig("RewardTheFirstShowingPlayer", true) then
		if shown == 0 then
			firstShowReward = true
		end
	end

	if (firstShowReward or self:willShowForAttack()) and not self:willSkipPlayPhase() then
		for _, skill in ipairs(bothShow) do
			if self.player:hasSkills(skill) then
				if canShowHead and showRate > 0.7 then
					return "GameRule_AskForGeneralShowHead"
				elseif canShowDeputy and showRate > 0.7 then
					return "GameRule_AskForGeneralShowDeputy"
				end
			end
		end
	end

	if firstShowReward and not self:willSkipPlayPhase() then
		for _, skill in ipairs(firstShow) do
			if self.player:hasSkill(skill) and not self.player:hasShownOneGeneral() then
				if self.player:inHeadSkills(skill) and canShowHead and showRate > 0.8 then
					return "GameRule_AskForGeneralShowHead"
				elseif canShowDeputy and showRate > 0.8 then
					return "GameRule_AskForGeneralShowDeputy"
				end
			end
		end
		if not self.player:hasShownOneGeneral() then
			if canShowHead and showRate > 0.9 then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy and showRate > 0.9 then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	if self.player:inHeadSkills("baoling") then
		if (self.player:hasSkill("luanwu") and self.player:getMark("@chaos") ~= 0)
			or (self.player:hasSkill("xiongyi") and self.player:getMark("@arise") ~= 0)
			or (self.player:hasSkill("Fencheng") and self.player:getMark("@burn") ~= 0) then
			canShowHead = false
		end
	end
	if self.player:inHeadSkills("baoling") then
		if (self.player:hasSkill("mingshi") and allshown >= (self.room:alivePlayerCount() - 1))
			or (self.player:hasSkill("luanwu") and self.player:getMark("@chaos") == 0)
			or (self.player:hasSkill("xiongyi") and self.player:getMark("@arise") == 0)
			or (self.player:hasSkill("Fencheng") and self.player:getMark("@burn") == 0) then
			if canShowHead then
				return "GameRule_AskForGeneralShowHead"
			end
		end
	end

	if self.player:hasSkill("guixiu") and not self.player:hasShownSkill("guixiu") then
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3 and not self:willSkipPlayPhase() ) then
			if self.player:inHeadSkills("guixiu") and canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	if self.player:hasSkill("Ranshang") and self.player:getMark("Ranshang") == 0 then  --燃殇优先级比隙仇耀武高
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3) or (self.player:hasSkill("huashen") and not self.player:hasShownSkill("huashen")) then
			if self.player:inHeadSkills("Ranshang") and canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end
	
	if self.player:hasSkill("Yaowu") and self.player:getMark("Yaowu") == 0 then  --来自隙仇
		--if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3) or (self.player:hasSkill("huashen") and not self.player:hasShownSkill("huashen")) then
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3) then
			if self.player:inHeadSkills("Yaowu") and canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end
	
	if self.player:hasSkill("Qixing") and self.player:getMark("Qixing") == 0 then
		local needDawu = false
		for _,friend in ipairs(self.friends) do
			if self:isWeak(friend) then needDawu = true break end
		end
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3) or needDawu then
			if self.player:inHeadSkills("Qixing") and canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end
	
	if self.player:hasSkill("Jugu") and self.player:getMark("Jugu") == 0 then
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3) then  --不像闺秀考虑跳出牌阶段，因为加手牌上限
			if self.player:inHeadSkills("Jugu") and canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	for _,p in ipairs(self.friends) do
		if p:hasShownSkill("jieyin") then
			if canShowHead and self.player:getGeneral():isMale() then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy and self.player:getGeneral():isFemale() and self.player:getGeneral2():isMale() then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end
	
	local doNotShowTuxiYet = false  --防止回合开始时亮张辽摸牌，导致突袭不成（但是似乎这样会导致另一个将也亮不出来？）
	if self.player:hasSkill("TuxiLB") and not self.player:hasSkill("Qingjian") and not self:willSkipDrawPhase() then
		local tuxi_targets = self:findTuxiLBTarget(2)
		if #tuxi_targets > 0 then
			self:sort(tuxi_targets, "handcard")
			
			local draw_num = self.player:getMark("HalfMaxHpLeft") + self.player:getMark("CompanionEffect") * ((self:isWeak() and self.player:isWounded()) and 0 or 2)
			if self.player:hasSkill("luoshen") then draw_num = draw_num + 1 end
			if self.player:getPile("YijiLB"):length() > 0 then draw_num = draw_num + self.player:getPile("YijiLB"):length() end
			if tuxi_targets[1]:getHandcardNum() < self.player:getHandcardNum() + draw_num then
				doNotShowTuxiYet = true
			end
		end
	end

	if self.player:getMark("CompanionEffect") > 0 then
		if self:isWeak() or (shown > 0 and eAtt > 0 and e - f < 3 and not self:willSkipPlayPhase()) and not doNotShowTuxiYet then
			if canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	if self.player:getMark("HalfMaxHpLeft") > 0 then
		if self:isWeak() and self:willShowForDefence() and not doNotShowTuxiYet then
			if canShowHead and showRate > 0.6 then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy and showRate >0.6 then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	if self.player:hasTreasure("JadeSeal") then
		if not self.player:hasShownOneGeneral() then
			if canShowHead then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end

	for _, skill in ipairs(followShow) do
		if ((shown > 0 and e < notshown) or self.player:hasShownOneGeneral()) and self.player:hasSkill(skill) then
			if self.player:inHeadSkills(skill) and canShowHead and showRate > 0.6 then
				return "GameRule_AskForGeneralShowHead"
			elseif canShowDeputy and showRate > 0.6 then
				return "GameRule_AskForGeneralShowDeputy"
			end
		end
	end
	for _, skill in ipairs(followShow) do
		if not self.player:hasShownOneGeneral() then
			for _,p in sgs.qlist(self.room:getOtherPlayers(player)) do
				if p:hasShownSkill(skill) and p:getKingdom() == self.player:getKingdom() then
					if canShowHead and canShowDeputy and showRate > 0.2 then
						local cho = { "GameRule_AskForGeneralShowHead", "GameRule_AskForGeneralShowDeputy"}
						return cho[math.random(1, #cho)]
					elseif canShowHead and showRate > 0.2 then
						return "GameRule_AskForGeneralShowHead"
					elseif canShowDeputy and showRate > 0.2 then
						return "GameRule_AskForGeneralShowDeputy"
					end
				end
			end
		end
	end

	local skillTrigger = false
	local skillnames = choices:split("+")
	table.removeOne(skillnames, "GameRule_AskForGeneralShowHead")
	table.removeOne(skillnames, "GameRule_AskForGeneralShowDeputy")
	table.removeOne(skillnames, "cancel")
	if #skillnames ~= 0 then
		skillTrigger = true
	end

	if skillTrigger then
		--Damaged
		if string.find(choices, "jieming") then return "jieming" end
		if string.find(choices, "wangxi") and (string.find(choices, "fankui") or string.find(choices, "FankuiLB") or string.find(choices, "Guixin")) then 
			local from = data:toDamage().from
			if from and from:isNude() then return "wangxi" end
		end
		if string.find(choices, "fankui") and string.find(choices, "ganglie") then return "fankui" end
		if string.find(choices, "FankuiLB") and string.find(choices, "ganglie") then return "FankuiLB" end
		if string.find(choices, "fankui") and string.find(choices, "GanglieLB_XiaHouDun_LB") then return "fankui" end
		if string.find(choices, "FankuiLB") and string.find(choices, "GanglieLB_XiaHouDun_LB") then return "FankuiLB" end
		if string.find(choices, "wangxi") and string.find(choices, "ganglie") then return "ganglie" end
		if string.find(choices, "wangxi") and string.find(choices, "GanglieLB_XiaHouDun_LB") then return "GanglieLB_XiaHouDun_LB" end
		if string.find(choices, "luoshen") and string.find(choices, "guanxing") then return "guanxing" end  --shenmegui?
		if string.find(choices, "wangxi") and string.find(choices, "fangzhu") then return "fangzhu" end
		if string.find(choices, "GanglieLB_XiaHouDun_LB") and string.find(choices, "fangzhu") then return "GanglieLB_XiaHouDun_LB" end
		if string.find(choices, "Guixin") and string.find(choices, "ganglie") then return "Guixin" end
		if string.find(choices, "Guixin") and string.find(choices, "GanglieLB_XiaHouDun_LB") then return "Guixin" end
		if string.find(choices, "Guixin") and string.find(choices, "fangzhu") then return "fangzhu" end
		
		if string.find(choices, "Yuce") and string.find(choices, "fangzhu") then return "Yuce" end  --御策专题
		if string.find(choices, "Yuce") and string.find(choices, "ganglie") then return "ganglie" end
		if string.find(choices, "Yuce") and string.find(choices, "GanglieLB_XiaHouDun_LB") then return "GanglieLB_XiaHouDun_LB" end
		if string.find(choices, "Yuce") and string.find(choices, "wangxi") then return self.player:isKongcheng() and "wangxi" or "Yuce" end
		if string.find(choices, "Yuce") and string.find(choices, "fankui") then return "fankui" end
		if string.find(choices, "Yuce") and string.find(choices, "FankuiLB") then return "FankuiLB" end
		if string.find(choices, "Yuce") and string.find(choices, "Guixin") then return "Guixin" end
		if string.find(choices, "Yuce") and string.find(choices, "yiji") then return "yiji" end
		if string.find(choices, "Yuce") and string.find(choices, "YijiLB") then return "YijiLB" end
		if string.find(choices, "Yuce") and string.find(choices, "jianxiong") then return "jianxiong" end
		if string.find(choices, "Yuce") and string.find(choices, "JianxiongLB") then return "JianxiongLB" end
		if string.find(choices, "Yuce") and string.find(choices, "ziliang") then return "ziliang" end
		if string.find(choices, "Yuce") and string.find(choices, "Chengxiang") then return "Chengxiang" end
		if string.find(choices, "YijiLB") and string.find(choices, "fankui") then return "fankui" end  --界遗计专题
		if string.find(choices, "YijiLB") and string.find(choices, "FankuiLB") then return "FankuiLB" end
		if string.find(choices, "YijiLB") and string.find(choices, "Guixin") then return "Guixin" end
		if string.find(choices, "YijiLB") and string.find(choices, "wangxi") then return "wangxi" end
		if string.find(choices, "YijiLB") and string.find(choices, "jianxiong") then return "jianxiong" end
		if string.find(choices, "YijiLB") and string.find(choices, "JianxiongLB") then return "JianxiongLB" end
		if string.find(choices, "YijiLB") and string.find(choices, "ziliang") then return "ziliang" end
		if string.find(choices, "YijiLB") and string.find(choices, "Chengxiang") then return "Chengxiang" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "fankui") then return "fankui" end  --推锋专题
		if string.find(choices, "Tuifeng") and string.find(choices, "FankuiLB") then return "FankuiLB" end
		if string.find(choices, "Tuifeng") and string.find(choices, "wangxi") then return "wangxi" end
		if string.find(choices, "Tuifeng") and string.find(choices, "Guixin") then return "Guixin" end
		if string.find(choices, "Tuifeng") and string.find(choices, "yiji") then return "yiji" end
		if string.find(choices, "Tuifeng") and string.find(choices, "YijiLB") then return "YijiLB" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "jianxiong") then return "jianxiong" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "JianxiongLB") then return "JianxiongLB" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "ziliang") then return "ziliang" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "Chengxiang") then return "Chengxiang" end
		if string.find(choices, "Tuifeng") and table.contains(skillnames, "Yuce") then return "Yuce" end
		
		--EventPhaseStart (Player_Start)
		if table.contains(skillnames, "Tishen") and table.contains(skillnames, "QianxiRE") then return "Tishen" end
		if table.contains(skillnames, "shenzhi") and table.contains(skillnames, "QianxiRE") then return "QianxiRE" end
		if string.find(choices, "QianxiRE") and sgs.ai_skill_invoke.QianxiRE(sgs.ais[self.player:objectName()]) then return "QianxiRE" end
		
		--EventPhaseStart (Player_Finish)
		if string.find(choices, "Zhiyan") and string.find(choices, "fenming") then return self.player:isNude() and "fenming" or "Zhiyan" end
		if string.find(choices, "Kuangfeng") and string.find(choices, "Dawu") then return "Dawu" end
		if table.contains(skillnames, "biyue") and table.contains(skillnames, "Ranshang") then return "biyue" end
		if table.contains(skillnames, "Juece") and table.contains(skillnames, "Ranshang") then return "Juece" end
		
		--EventPhaseStart (Player_Draw)
		if table.contains(skillnames, "#YijiLB-obtain") then return "#YijiLB-obtain" end  --string.find对#无效
		
		--Damage
		if string.find(choices, "Qiaomeng") and string.find(choices, "kuangfu") then return "kuangfu" end
		if string.find(choices, "lieren") and string.find(choices, "Qianxin") then return "Qianxin" end
		
		--DrawNCards
		if string.find(choices, "TuxiLB") and string.find(choices, "luoyi") then return "TuxiLB" end  --其实是裸衣bug，没判断可用摸牌数
		
		--CardUsed/CardResponded
		if string.find(choices, "longdan") and string.find(choices, "Yajiao") then return "Yajiao" end  --五虎将大旗龙胆
		if table.contains(skillnames, "Longyin") and table.contains(skillnames, "Yajiao") then return "Yajiao" end
		
		--CardsMoveOneTime
		if table.contains(skillnames, "Lianying") and string.find(choices, "BuquRenew") then return "Lianying" end

		--FinishJudge
		if table.contains(skillnames, "tiandu") then
			local judge = data:toJudge()
			if judge.card:isKindOf("Peach") or judge.card:isKindOf("Analeptic") then
				return "tiandu"
			end
		end
		if table.contains(skillnames, "tiandu_GuoJia_LB") then
			local judge = data:toJudge()
			if judge.card:isKindOf("Peach") or judge.card:isKindOf("Analeptic") then
				return "tiandu_GuoJia_LB"
			end
		end

		local except = {}
		for _, skillname in ipairs(skillnames) do
			local invoke = self:askForSkillInvoke(skillname, data)
			if invoke == true then
				return skillname
			elseif invoke == false then
				table.insert(except, skillname)
			end
		end
		if string.find(choices, "cancel") and not canShowHead and not canShowDeputy and not self.player:hasShownOneGeneral() then
			return "cancel"
		end
		table.removeTable(skillnames, except)

		if #skillnames > 0 then return skillnames[math.random(1, #skillnames)] end
	end

	return "cancel"
end
sgs.ai_skill_choice["GameRule:TurnStart"] = function(self, choices, data)	--耀武、七星、燃殇
	local choice = sgs.ai_skill_choice["GameRule:TriggerOrder"](self, choices, data)
	if choice == "cancel" then
		local canShowHead = string.find(choices, "GameRule_AskForGeneralShowHead")
		local canShowDeputy = string.find(choices, "GameRule_AskForGeneralShowDeputy")
		local showRate = math.random()

		if canShowHead and showRate > 0.8 then
			if self.player:isDuanchang() then return "GameRule_AskForGeneralShowHead" end
			for _, p in ipairs(self.enemies) do
				if p:hasShownSkills("mingshi|huoshui") then return "GameRule_AskForGeneralShowHead" end
			end
		elseif canShowDeputy and showRate > 0.8 then
			if self.player:isDuanchang() then return "GameRule_AskForGeneralShowDeputy" end
			for _, p in ipairs(self.enemies) do
				if p:hasShownSkills("mingshi|huoshui") then return "GameRule_AskForGeneralShowDeputy" end
			end
		end
		if not self.player:hasShownOneGeneral() then
			local gameProcess = sgs.gameProcess():split(">>")
			if self.player:getKingdom() == gameProcess[1] and (self.player:getLord() or sgs.shown_kingdom[self.player:getKingdom()] < self.player:aliveCount() / 2) then
				if self.player:hasSkill("Ranshang") and self.player:getMark("Ranshang") == 0 then
					if self.player:inHeadSkills("Ranshang") and canShowHead then
						return "GameRule_AskForGeneralShowHead"
					elseif canShowDeputy then
						return "GameRule_AskForGeneralShowDeputy"
					end
				end
				if self.player:hasSkill("Yaowu") and self.player:getMark("Yaowu") == 0 then  --来自隙仇
					if self.player:inHeadSkills("Yaowu") and canShowHead then
						return "GameRule_AskForGeneralShowHead"
					elseif canShowDeputy then
						return "GameRule_AskForGeneralShowDeputy"
					end
				end
				if self.player:hasSkill("Qixing") and self.player:getMark("Qixing") == 0 then
					if self.player:inHeadSkills("Qixing") and canShowHead then
						return "GameRule_AskForGeneralShowHead"
					elseif canShowDeputy then
						return "GameRule_AskForGeneralShowDeputy"
					end
				end
				if canShowHead and showRate > 0.6 then return "GameRule_AskForGeneralShowHead"
				elseif canShowDeputy and showRate > 0.6 then return "GameRule_AskForGeneralShowDeputy" end
			end
		end
	end
	return choice
end

--standard-wei
function SmartAI:toTurnOver(player, n, reason) -- @todo: param of toTurnOver  --归心、神愤、弘德、峻刑（待处理：法恩、据守、溃围、离魂、举荐）
	if not player then global_room:writeToConsole(debug.traceback()) return end
	n = n or 0
	if self:isEnemy(player) then
		local manchong = sgs.findPlayerByShownSkillName("Junxing")
		if manchong and self:isFriend(player, manchong) and self:playerGetRound(manchong) < self:playerGetRound(player)
			and manchong:faceUp() and not self:willSkipPlayPhase(manchong)
			and not (manchong:isKongcheng() and self:willSkipDrawPhase(manchong)) then
			return false
		end
	end
	if not player:faceUp() and not player:hasFlag("ShenfenUsing") and not player:hasFlag("GuixinUsing") then return false end
	if reason and reason == "fangzhu" and player:getHp() == 1 and sgs.ai_AOE_data then
		local use = sgs.ai_AOE_data:toCardUse()
		if use.to:contains(player) and self:aoeIsEffective(use.card, player)
			and self:playerGetRound(player) > self:playerGetRound(self.player)
			and player:isKongcheng() then
			return false
		end
	end
	if player:hasShownSkill("Shenfen") and player:faceUp() and player:getPhase() == sgs.Player_Play  --源码hasUsed冲突
		and (not player:hasUsed("#ShenfenCard") and player:getMark("@wrath") >= 6 or player:hasFlag("ShenfenUsing")) then
		return false
	end
	if n > 1 then
		if ( player:getPhase() ~= sgs.Player_NotActive and (player:hasShownSkills(sgs.Active_cardneed_skill) or player:hasWeapon("Crossbow")) )
		or ( player:getPhase() == sgs.Player_NotActive and player:hasShownSkills(sgs.notActive_cardneed_skill) and reason ~= "Junxing")
		or (player:hasShownSkill("Hongde") and n >= 2 and self:findFriendsByType(sgs.Friend_Draw, player) and not player:hasShownSkills(sgs.Active_priority_skill)) then
		return false end
	end
	if player:hasShownSkill("jushou") and player:getPhase() <= sgs.Player_Finish then return false end
	return true
end

--formation
sgs.ai_skill_choice.DragonPhoenix = function(self, choices, data)			--飞龙选将
	local kingdom = data:toString()
	local choices_pri = {}
	choices_t = string.split(choices, "+")
	if (kingdom == "wei") then
		if (string.find(choices, "guojia")) then
			table.insert(choices_pri,"guojia") end
		if (string.find(choices, "xunyu")) then
			table.insert(choices_pri,"xunyu") end
		if (string.find(choices, "lidian")) then
			table.insert(choices_pri,"lidian") end
		if (string.find(choices, "zhanghe")) then
			table.insert(choices_pri,"zhanghe") end
		if (string.find(choices, "caopi")) then
			table.insert(choices_pri,"caopi") end
		if (string.find(choices, "zhangliao")) then
			table.insert(choices_pri,"zhangliao") end
		
		if (string.find(choices, "CaoZhi")) then
			table.insert(choices_pri,"CaoZhi") end
		if (string.find(choices, "CaoChong")) then
			table.insert(choices_pri,"CaoChong") end

		table.removeOne(choices_t, "caohong")
		table.removeOne(choices_t, "zangba")
		table.removeOne(choices_t, "xuchu")
		table.removeOne(choices_t, "dianwei")
		table.removeOne(choices_t, "caoren")

	elseif (kingdom == "shu") then
		if (string.find(choices, "mifuren")) then
			table.insert(choices_pri,"mifuren") end
		if (string.find(choices, "pangtong")) then
			table.insert(choices_pri,"pangtong") end
		if (string.find(choices, "lord_liubei")) then
			table.insert(choices_pri,"lord_liubei") end
		if (string.find(choices, "liushan")) then
			table.insert(choices_pri, "liushan") end
		if (string.find(choices, "jiangwanfeiyi")) then
			table.insert(choices_pri, "jiangwanfeiyi") end
		if (string.find(choices, "wolong")) then
			table.insert(choices_pri, "wolong") end

		table.removeOne(choices_t, "guanyu")
		table.removeOne(choices_t, "zhangfei")
		table.removeOne(choices_t, "weiyan")
		table.removeOne(choices_t, "zhurong")
		table.removeOne(choices_t, "madai")

	elseif (kingdom == "wu") then
		if (string.find(choices, "zhoutai")) then
			table.insert(choices_pri, "zhoutai") end
		if (string.find(choices, "lusu")) then
			table.insert(choices_pri, "lusu") end
		if (string.find(choices, "taishici")) then
			table.insert(choices_pri, "taishici") end
		if (string.find(choices, "sunjian")) then
			table.insert(choices_pri, "sunjian") end
		if (string.find(choices, "sunshangxiang")) then
			table.insert(choices_pri, "sunshangxiang") end
		
		if (string.find(choices, "BuZhi")) then
			table.insert(choices_pri, "BuZhi") end

		table.removeOne(choices_t, "sunce")
		table.removeOne(choices_t, "chenwudongxi")
		table.removeOne(choices_t, "luxun")
		table.removeOne(choices_t, "huanggai")
		
		table.removeOne(choices_t, "ZhuRan")

	elseif (kingdom == "qun") then
		if (string.find(choices, "yuji")) then
			table.insert(choices_pri,"yuji") end
		if (string.find(choices, "caiwenji")) then
			table.insert(choices_pri,"caiwenji") end
		if (string.find(choices, "mateng")) then
			table.insert(choices_pri,"mateng") end
		if (string.find(choices, "kongrong")) then
			table.insert(choices_pri,"kongrong") end
		if (string.find(choices, "lord_zhangjiao")) then
			table.insert(choices_pri,"lord_zhangjiao") end
		if (string.find(choices, "huatuo")) then
			table.insert(choices_pri,"huatuo") end
		
		if (string.find(choices, "ZhangRang")) then
			table.insert(choices_pri,"ZhangRang") end

		table.removeOne(choices_t, "dongzhuo")
		table.removeOne(choices_t, "tianfeng")
		table.removeOne(choices_t, "zhangjiao")
		
		table.removeOne(choices_t, "liguo")  --帮开发组，举手之劳
		table.removeOne(choices_t, "HuaXiong")
		table.removeOne(choices_t, "WuTuGu")

	end

	if #choices_pri > 0 then
		return choices_pri[math.random(1, #choices_pri)]
	end
	if #choices_t == 0 then choices_t = string.split(choices, "+") end
	return choices_t[math.random(1, #choices_t)]
end

-----------------------------------------------新标风-----------------------------------------------

-- WU 013 周泰

-- 不屈
sgs.ai_skill_invoke.BuquRenew_ZhouTai_13 = true
sgs.ai_skill_invoke["#BuquRenew_showmaxcards_ZhouTai_13"] = function(self, data)
	if not self:willShowForDefence() or player:getPile("chuang_ZhouTai_13"):isEmpty() then return false end
	if player:getMaxCards(1) >= player:getPile("chuang_ZhouTai_13"):length() then return false end
	return self:getOverflow() > 0
end

-- 奋激
function SmartAI:hasFenjiEffect(player)
	if not player then return false end
	local zhoutai = sgs.findPlayerByShownSkillName("Fenji")
	local zhoutai15 = sgs.findPlayerByShownSkillName("Fenji15")
	if not zhoutai and not zhoutai15 then return false end
	if not zhoutai and zhoutai15 then
		if zhoutai15:isNude() then return false end
	end
	zhoutai = zhoutai or zhoutai15
	if self:isFriend(player, zhoutai) and not self:isWeak(zhoutai) and not self:needKongcheng(player, true) then
		return zhoutai:hasShownSkill("Zhaxiang") or player:getHandcardNum() < (zhoutai:getHp() <= 1 and 3 or 5)
	end
end
sgs.ai_skill_invoke.Fenji = function(self, data)
	if not self:willShowForDefence() then return false end
	local move = self.player:getTag("FenjiMove"):toMoveOneTime()
	local from = findPlayerByObjectName(move.from:objectName())
	if self:isWeak() or not from or not self:isFriend(from)
		--or hasManjuanEffect(from)
		or self:needKongcheng(from, true) then return false end
	local skill_name = move.reason.m_skillName
	if skill_name == "rende" or skill_name == "RendeLB" then return true end
	if self.player:hasSkill("Zhaxiang") then return true end
	return from:getHandcardNum() < (self.player:getHp() <= 1 and 3 or 5)
end
sgs.ai_choicemade_filter.skillInvoke.Fenji = function(self, player, promptlist)
	if sgs.ai_fenji_target then
		if promptlist[3] == "yes" then
			sgs.updateIntention(player, sgs.ai_fenji_target, -10)
		end
		sgs.ai_fenji_target = nil
	end
end

----------------------------------------------------------------------------------------------------

-- QUN 019 华雄

-- 耀武
function SmartAI:hasYaowuEffect(player, slash, isFriend, from)
	if not player or player:isDead() or not player:hasShownSkill("Yaowu") then return false end
	if not (slash and slash:isKindOf("Slash") and slash:isRed()) then return false end
	from = from or self.player
	if isFriend then
		return from:isWounded() and not self:isWeak(player)
	end
	return true
end
sgs.ai_skill_invoke.Yaowu = function(self, data)
	local source = data:toPlayer()
	return source and self:isFriend(source) and (self:isWeak(source) or self:isWeak())
end
sgs.ai_skill_choice.Yaowu = function(self, choices)
	local huaxiong = sgs.findPlayerByShownSkillName("Yaowu")
	local huatuo = sgs.findPlayerByShownSkillName("qingnang")
	if huaxiong and huaxiong:isAlive() and self:isEnemy(huaxiong) and not self:isWeak() then
		if not (huaxiong:getLostHp() >= 2 and self:isWeak(huaxiong)) or (huatuo and self:isFriend(huaxiong, huatuo)) then
			return "maxhp"
		end
	end
	if --[[self.player:getHp() >= getBestHp(self.player)]] not self.player:isWounded() or (self:needKongcheng(self.player, true) and self.player:getPhase() == sgs.Player_NotActive) then
		return "draw"
	end
	if self.player:isWounded() then return "recover" end
	return "draw"
end

----------------------------------------------------------------------------------------------------

-- QUN 021 袁术

-- 妄尊
sgs.ai_skill_invoke.Wangzun_YuanShu_Renew = function(self, data)
	if not self:willShowForDefence() then return false end
	
	local function isBigKingdom(player)
		if not player:hasShownOneGeneral() then return false end
		local BigKingdom = false
		local big_kingdoms = player:getBigKingdoms("AI", 0)
		if table.contains(big_kingdoms, player:objectName()) then
			BigKingdom = true
		else
			local kingdom = (player:getRole() == "careerist") and "careerist" or player:getKingdom()
			BigKingdom = table.contains(big_kingdoms, kingdom)
		end
		return BigKingdom
	end
	
	local big_player = self.room:getCurrent()
	local invoke_for_self = false
	if (self.player:objectName() == big_player:objectName()) and self:getOverflow(self.player, true) > 1 then
		invoke_for_self = not self:willSkipPlayPhase(self.player) and not self.player:hasSkills(sgs.notActive_cardneed_skill)
	end
	if self:isEnemy(big_player) then
		--local better_targets 
		local doNotInvokeYet = false
		for _,target in sgs.qlist(self.room:getOtherPlayers(big_player)) do  --接下来可能还有更好的目标（敌人）
			if target:objectName() == self.player:objectName() then break end
			if isBigKingdom(target) and self:isEnemy(target) then
				if self:getOverflow(target, true) < self:getOverflow(big_player, true) 
					or (target:hasShownSkills(sgs.notActive_cardneed_skill) and not big_player:hasShownSkills(sgs.notActive_cardneed_skill)) then
					doNotInvokeYet = true
					break
				end
			end
		end
		return not self:needKongcheng(self.player) and not doNotInvokeYet
	elseif self:isFriend(big_player) then
		local canInvokeNow = invoke_for_self 
		if big_player:objectName() ~= self.player:objectName() then
			canInvokeNow = not self:isWeak(big_player) and not big_player:hasShownSkills(sgs.notActive_cardneed_skill)
							or (self:getOverflow(big_player) < -2 or (self:willSkipDrawPhase(big_player) and self:getOverflow(big_player) < 0))
		end
			
		local doNotInvokeYet = false
		for _,target in sgs.qlist(self.room:getOtherPlayers(big_player)) do  --优先妄尊剩下的敌人
			if target:objectName() == self.player:objectName() then break end
			if isBigKingdom(target) and self:isEnemy(target) then
				doNotInvokeYet = true
				break
			end
		end
		for _,target in sgs.qlist(self.room:getOtherPlayers(big_player)) do
			if target:objectName() == self.player:objectName() then break end
			if isBigKingdom(target) and self:isFriend(target) then
				if not self:isWeak(target) and not target:hasShownSkills(sgs.notActive_cardneed_skill)
					and (self:getOverflow(target, true) > self:getOverflow(big_player, true) or target:hasShownSkill("lirang")) then
					doNotInvokeYet = true
					break
				end
			end
		end
		
		return canInvokeNow and not doNotInvokeYet
	elseif invoke_for_self then
		return true
	end
	return false
end
sgs.ai_choicemade_filter.skillInvoke.Wangzun_YuanShu_Renew = function(self, player, promptlist)
	if promptlist[#promptlist] == "yes" then
		local big_player = self.room:getCurrent()
		if not self:isWeak(big_player) or (self:getOverflow(big_player) < -2 or (self:willSkipDrawPhase(big_player) and self:getOverflow(big_player) < 0)) then return end
		sgs.updateIntention(player, big_player, 10)
	end
end

-- 同疾
sgs.ai_skill_invoke.Tongji = function(self, data)
	if not self:willShowForDefence() and not self:willShowForAttack() then return false end
	local use = data:toCardUse()
	local friend_num = 0
	local enemy_num = 0
	
	for _,to in sgs.qlist(use.to) do
		if to:objectName() == self.player:objectName() then continue end
		if self:isFriend(to) then
			if self:slashIsEffective(use.card, to, use.from) and not self:isPriorFriendOfSlash(to, use.card, use.from) then
				friend_num = friend_num + 1
				if self:hasHeavySlashDamage(use.from, use.card, to) or self:isWeak(to) then return true end
			end
		end
		if self:isEnemy(to) then
			if self:slashIsEffective(use.card, to, use.from) or self:isPriorFriendOfSlash(to, use.card, use.from) then
				enemy_num = enemy_num + 1
				if self:hasHeavySlashDamage(use.from, use.card, to) or self:isWeak(to) then return false end
			end
		end
	end
	if (enemy_num == 0) and (friend_num == 0) then return false end
	return friend_num >= enemy_num
end

----------------------------------------------------------------------------------------------------

-- WU 013 周泰（15）

-- 不屈
sgs.ai_skill_invoke.BuquRenew_ZhouTai_15 = sgs.ai_skill_invoke.BuquRenew_ZhouTai_13
sgs.ai_skill_invoke["#BuquRenew_showmaxcards_ZhouTai_15"] = function(self, data)
	if not self:willShowForDefence() or player:getPile("chuang_ZhouTai_15"):isEmpty() then return false end
	if player:getMaxCards(1) >= player:getPile("chuang_ZhouTai_15"):length() then return false end
	return self:getOverflow() > 0
end

-- 奋激
sgs.ai_skill_cardask["@Fenji15"] = function(self, data)
	if not sgs.ai_skill_invoke.Fenji(self, data) then return "." end
	
	local function getLeastValueCard()  --来自龙吟
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		for _, c in ipairs(cards) do
			if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
		end
		if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
		if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < 5 then return "$" .. self.player:getWeapon():getEffectiveId() end
	end
	--[[--来自流离
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if not self.player:isJilei(card) then
			if not (isCard("Peach", card, self.player) or isCard("Analeptic", card, self.player)) then
				return "$" .. card:getEffectiveId()
			end
		end
	end

	local cards = self.player:getCards("e")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		local range_fix = 0
		if not self.player:isJilei(card) then
			return "$" .. card:getEffectiveId()
		end
	end]]
	
	local str = getLeastValueCard()
	if str then return str end
	return "."
end

----------------------------------------------界限突破----------------------------------------------

-- WEI 001 曹操

-- 奸雄
sgs.ai_skill_invoke.JianxiongLB = sgs.ai_skill_invoke.jianxiong
sgs.ai_skill_choice.JianxiongLB = function(self, choices, data)
	local choice_table = choices:split("+")
	if #choice_table == 1 then return choice_table[1] end
	local damage = data:toDamage()
	if not damage.card or (damage.card:isVirtualCard() and damage.card:subcardsLength() == 0) then return "draw" end  --不过理论上这种情况不会有obtain
	if damage.card:isVirtualCard() and damage.card:subcardsLength() > 1 then return "obtain" end
	
	local card = sgs.Sanguosha:getCard(damage.card:getEffectiveId())
	if self:isValuableCard(card, self.player) then return "obtain" end
	local needcard = false
	for _, askill in sgs.qlist(self.player:getVisibleSkillList(true)) do
		local callback = sgs.ai_cardneed[askill:objectName()]
		if type(callback) == "function" and callback(self.player, card, self) then
			needcard = true
			break
		end
	end
	if card:isKindOf("Slash") and not self:hasCrossbowEffect() and self:getCardsNum("Slash") > 0 and not needcard then return "draw" end
	if self:isWeak() and (self:getCardsNum("Slash") > 0 or not card:isKindOf("Slash") or self.player:getHandcardNum() <= self.player:getHp()) then return "draw" end
	if needcard then return "obtain" end
	
	--下面来自原项目
	if card:isKindOf("TrickCard") then  --锦囊全捡
		local trash = (card:isKindOf("Lightening") and not self:hasWizard(self.friends, true)) or card:isKindOf("AmazingGrace") or card:isKindOf("AllianceFeast")
		if not trash then return "obtain" end
	end
	
	local hecards = self.player:getCards("he")	
	local weapon
	local armor
	local ohorse
	local dhorse
	local treasure
	for _, card_id in sgs.qlist(hecards) do
		if card_id:isKindOf("Weapon") then weapon = true end
		if card_id:isKindOf("Armor") then armor = true end	
		if card_id:isKindOf("OffensiveHorse") then ohorse = true end		
		if card_id:isKindOf("DefensiveHorse") then dhorse = true end		
		if card_id:isKindOf("Treasure") then treasure = true end
	end	
	if card:isKindOf("EquipCard") then									--装备卡
		if card:isKindOf("Weapon") and not weapon then return "obtain" end
		if card:isKindOf("Armor") and not armor then return "obtain" end
		if card:isKindOf("DefensiveHorse") and not dhorse then return "obtain" end
		if card:isKindOf("Treasure") and not treasure then return "obtain" end
		if card:isKindOf("OffensiveHorse") and not ohorse then return "obtain" end
	end
	return card:isKindOf("Slash") and "obtain" or "draw"  --如果是杀的能走到这一步，就说明有连弩或者断杀
end

----------------------------------------------------------------------------------------------------

-- WEI 002 司马懿

-- 反馈
sgs.ai_skill_invoke.FankuiLB = function(self, data)  --由于结算修改而需要重写
	if not self:willShowForMasochism() then return false end
	local target = data:toDamage().from
	if not target then return end
	if sgs.ai_need_damaged.FankuiLB(self, target, self.player) then return true end

	if target:objectName() == self.player:objectName() then
		if self:doNotDiscard(target, "e") then return true end
		return (target:hasShownSkills(sgs.lose_equip_skill) and not target:getEquips():isEmpty())
		  or (self:needToThrowArmor(target) and target:getArmor()) or self:doNotDiscard(target, "e")
	end
	if self:isFriend(target) then
		if self:getOverflow(target) > 2 then return true end
		if self:doNotDiscard(target) then return true end
		return (target:hasShownSkills(sgs.lose_equip_skill) and not target:getEquips():isEmpty())
		  or (self:needToThrowArmor(target) and target:getArmor()) or self:doNotDiscard(target)
	end
	if self:isEnemy(target) then
		if self:doNotDiscard(target) then return false end
		return true
	end
	return true
end
sgs.ai_choicemade_filter.cardChosen.FankuiLB = function(self, player, promptlist)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if damage.from then
		local intention = 10
		local id = promptlist[3]
		local card = sgs.Sanguosha:getCard(id)
		local target = damage.from
		if self:needToThrowArmor(target) and self.room:getCardPlace(id) == sgs.Player_PlaceEquip and card:isKindOf("Armor") then
			intention = -intention
		elseif self:doNotDiscard(target) then intention = -intention
		elseif target:hasShownSkills(sgs.lose_equip_skill) and not target:getEquips():isEmpty() and
			self.room:getCardPlace(id) == sgs.Player_PlaceEquip and card:isKindOf("EquipCard") then
				intention = -intention
		elseif sgs.ai_need_damaged.FankuiLB(self, target, player) then intention = 0
		elseif self:getOverflow(target) > 2 then intention = 0
		end
		sgs.updateIntention(player, target, intention)
	end
end
sgs.ai_skill_cardchosen.FankuiLB = function(self, who, flags)
	local suit = sgs.ai_need_damaged.FankuiLB(self, who, self.player)
	if not suit then return nil end

	local cards = sgs.QList2Table(who:getEquips())
	local handcards = (who:objectName() == self.player:objectName()) and {} or sgs.QList2Table(who:getHandcards())
	if #handcards==1 and handcards[1]:hasFlag("visible") then table.insert(cards,handcards[1]) end

	for i=1,#cards,1 do
		if (cards[i]:getSuit() == suit and suit ~= sgs.Card_Spade) or
			(cards[i]:getSuit() == suit and suit == sgs.Card_Spade and cards[i]:getNumber() >= 2 and cards[i]:getNumber()<=9) then
			return cards[i]
		end
	end
	return nil
end
sgs.ai_need_damaged.FankuiLB = function (self, attacker, player)
	if not player:hasSkill("GuicaiLB+FankuiLB") and not player:hasSkill("guicai+FankuiLB") then return false end
	if not attacker then return end
	local need_retrial = function(target)
		local alive_num = self.room:alivePlayerCount()
		return alive_num + target:getSeat() % alive_num > self.room:getCurrent():getSeat()
				and target:getSeat() < alive_num + player:getSeat() % alive_num
	end
	local retrial_card ={["spade"]=nil,["heart"]=nil,["club"]=nil}
	local attacker_card ={["spade"]=nil,["heart"]=nil,["club"]=nil}

	local handcards
	if player:hasSkill("GuicaiLB") then
		handcards = sgs.QList2Table(player:getCards("he"))
	else
		handcards = sgs.QList2Table(player:getHandcards())
	end
	for i=1,#handcards,1 do
		if handcards[i]:getSuit() == sgs.Card_Spade and handcards[i]:getNumber()>=2 and handcards[i]:getNumber()<=9 then
			retrial_card.spade = true
		end
		if handcards[i]:getSuit() == sgs.Card_Heart then
			retrial_card.heart = true
		end
		if handcards[i]:getSuit() == sgs.Card_Club then
			retrial_card.club = true
		end
	end

	local cards = sgs.QList2Table(attacker:getEquips())
	local handcards = sgs.QList2Table(attacker:getHandcards())
	if #handcards==1 and handcards[1]:hasFlag("visible") then table.insert(cards,handcards[1]) end

	for i=1,#cards,1 do
		if cards[i]:getSuit() == sgs.Card_Spade and cards[i]:getNumber()>=2 and cards[i]:getNumber()<=9 then
			attacker_card.spade = sgs.Card_Spade
		end
		if cards[i]:getSuit() == sgs.Card_Heart then
			attacker_card.heart = sgs.Card_Heart
		end
		if cards[i]:getSuit() == sgs.Card_Club then
			attacker_card.club = sgs.Card_Club
		end
	end

	local players = self.room:getOtherPlayers(player)
	for _, aplayer in sgs.qlist(players) do
		if aplayer:containsTrick("lightning") and self:getFinalRetrial(aplayer) ==1 and need_retrial(aplayer) then
			if not retrial_card.spade and attacker_card.spade then return attacker_card.spade end
		end

		if self:isFriend(aplayer, player) and not aplayer:hasShownSkill("qiaobian") then

			if aplayer:containsTrick("indulgence") and self:getFinalRetrial(aplayer) == 1 and need_retrial(aplayer) and aplayer:getHandcardNum() >= aplayer:getHp() then
				if not retrial_card.heart and attacker_card.heart then return attacker_card.heart end
			end
		end
	end
	return false
end

-- 鬼才
sgs.ai_skill_cardask["@GuicaiLB-card"] = function(self, data)
	if not (self:willShowForAttack() or self:willShowForDefence() ) then return "." end
	local judge = data:toJudge()
	local cards = sgs.QList2Table(self.player:getCards("he"))
	local ecards = sgs.QList2Table(self.player:getCards("e"))
	for _, id in sgs.qlist(self.player:getHandPile()) do
		table.insert(cards, 1, sgs.Sanguosha:getCard(id))
	end
	if judge.reason == "tieqi" then
		local target
		for _, p in sgs.qlist(self.room:getAlivePlayers()) do
			if p:hasFlag("TieqiTarget") then target = p break end
		end
		if self:canHit(target, judge.from) then return "." end
		if getCardsNum("Jink", target, self.player) == 0 then return "." end
		if target:objectName() == self.player:objectName() then
			local jinks = self:getCards("Jink")
			local card_id = self:getRetrialCardId(cards, judge)
			if #jinks == 1 and jinks[1]:toString() == tostring(card_id) then
				return "."
			end
		end
	end

	if self:needRetrial(judge) then
		local card_id
		if self:needToThrowArmor() or self.player:hasSkills(sgs.lose_equip_skill) then card_id = self:getRetrialCardId(ecards, judge) end
		if not card_id then card_id = self:getRetrialCardId(cards, judge) end
		if card_id ~= -1 then
			return "$" .. card_id
		end
	end

	return "."
end
sgs.ai_cardneed.GuicaiLB = sgs.ai_cardneed.guicai
sgs.GuicaiLB_suit_value = sgs.guicai_suit_value

----------------------------------------------------------------------------------------------------

-- WEI 003 夏侯惇

-- 刚烈
sgs.ai_skill_invoke.GanglieLB_XiaHouDun_LB = sgs.ai_skill_invoke.ganglie
sgs.ai_need_damaged.GanglieLB_XiaHouDun_LB = sgs.ai_need_damaged.ganglie
function sgs.ai_slash_prohibit.GanglieLB_XiaHouDun_LB(self, from, to)
	if self:isFriend(from, to) then return false end
	--if from:hasSkill("jueqing") or (from:hasSkill("nosqianxi") and from:distanceTo(to) == 1) then return false end
	if from:getHandcardNum() == 1 and from:getEquips():length() == 0 and from:getHandcards():at(0):isKindOf("Slash") and from:getHp() >= 2 then return false end
	return from:getHandcardNum() + from:getHp() < 4 or from:getHp() < 2
end
sgs.ai_choicemade_filter.skillInvoke.GanglieLB_XiaHouDun_LB = sgs.ai_choicemade_filter.skillInvoke.ganglie

-- 清俭
function doQingjian(self, card_ids, forced)
	self.Qingjian_using = true  --for getCardNeedPlayer
	local target, id = sgs.ai_skill_askforyiji.yiji(self, card_ids)
	if target and (target:objectName() ~= self.player:objectName()) then
		self.Qingjian_using = false
		return "#QingjianCard:" .. id .. ":&->" .. target:objectName()
	end
	
	if forced then  --Distribute randomly  （来自礼让）
		if next(self.friends_noself) then
			local cards = {}
			for _, card_id in ipairs(card_ids) do
				table.insert(cards, sgs.Sanguosha:getCard(card_id))
			end
			local card, target = self:getCardNeedPlayer(cards, self.friends_noself, "Qingjian")  --考虑到遗计可能返回自己
			self.Qingjian_using = false
			if card and target then
				return "#QingjianCard:" .. card:getEffectiveId() .. ":&->" .. target:objectName()
			end
			
			self:sort(self.friends_noself, "handcard")
			for _, afriend in ipairs(self.friends_noself) do
				if not self:needKongcheng(afriend, true) then
					return "#QingjianCard:" .. card_ids[math.random(1, #card_ids)] .. ":&->" .. afriend:objectName()
				end
			end
			self:sort(self.friends_noself, "defense")
			return "#QingjianCard:" .. card_ids[math.random(1, #card_ids)] .. ":&->" .. self.friends_noself[1]:objectName()
		end
		local others = self.room:getOtherPlayers(self.player)
		return "#QingjianCard:" .. card_ids[math.random(1, #card_ids)] .. ":&->" .. others:at(math.random(0, others:length() - 1)):objectName()
	end
	return "."
end
sgs.ai_skill_invoke.Qingjian = function(self, data)					--魏国的摸牌后弃牌技能（如陈情缮甲）都加到这里来
	if not self:willShowForDefence() then return false end
	local move_skill = self.player:getTag("QingjianCurrentMoveSkill"):toString()
	if move_skill == "rende" then return false end
	
	self:updatePlayers()  --避免self.enemies为空导致bug
	
	local move = data:toMoveOneTime()
	local card_ids = {}
	for _,id in sgs.qlist(move.card_ids) do
		if self.room:getCardOwner(id):objectName() == self.player:objectName() and self.room:getCardPlace(id) == sgs.Player_PlaceHand then
			table.insert(card_ids, id)
			if move_skill == "Zhiyan" and sgs.Sanguosha:getCard(id):isKindOf("EquipCard") then return false end
		end
	end
	if not next(card_ids) then return false end
	
	local discard_num = 0  --本意：如果马上就要弃牌，立刻清俭全给出去避免弃牌。然而似乎没用，因为大多数onEffect忘了加技能名
	--if move_skill == "await_exhausted" then discard_num = 2
	--elseif move_skill == "yicheng" then discard_num = 1
	--elseif move_skill == "yinghun_sunjian" or move_skill == "yinghun_sunce" then
	if move_skill == "Xuanhuo" then
		local fazheng = sgs.findPlayerByShownSkillName("Xuanhuo")
		if fazheng and self:isEnemy(fazheng) then discard_num = 2 end
	end
	
	self.player:setFlags("-QingjianAI_GiveAll")
	local xunyu = sgs.findPlayerByShownSkillName("jieming")
	local give_all = (self.player:getHandcardNum() - #card_ids - discard_num < self:getLeastHandcardNum(self.player))
				or (((move_skill == "Jingce") or (move_skill == "shengxi") or self:willSkipPlayPhase()) and self:getOverflow() > 0)
				or  self.player:hasSkill("Benyu")
				or (xunyu and self:isFriend(xunyu) and self.player:getHandcardNum() - #card_ids < math.min(self.player:getMaxHp(), 5) and not self:isWeak(xunyu))
				or (self.player:hasSkill("TuxiLB") and not self:willSkipDrawPhase())
	if give_all and next(self.friends_noself) then
		self.Qingjian_DummyCount = 0
		self.Qingjian_Allocation = {}
		self.player:setFlags("QingjianAI_GiveAll")
		return true
	end
	
	local str = doQingjian(self, card_ids, false)
	self.Qingjian_DummyCount = 0
	self.Qingjian_Allocation = {}  --先清空，否则一会askForUseCard时信息会残留
	
	return (str ~= ".")
end
sgs.ai_skill_use["@@Qingjian!"] = function(self, prompt)
	local card_ids_str = self.player:property("Qingjian_hands"):toString() ~= "" and self.player:property("Qingjian_hands"):toString():split("+") or {}
	local card_ids = {}
	for _, id in ipairs(card_ids_str) do
		table.insert(card_ids, tonumber(id))
	end
	if not next(card_ids) then
		self.Qingjian_DummyCount = 0
		self.Qingjian_Allocation = {}
		return "."
	end
	
	local return_str = doQingjian(self, card_ids, string.startsWith(prompt, "@Qingjian-distribute1") or self.player:hasFlag("QingjianAI_GiveAll"))
	if return_str == "." or #card_ids == 1 then  --尝试解决插入结算的残留问题（因为只剩1牌的话下一步肯定会终止清俭结算）
		self.Qingjian_DummyCount = 0
		self.Qingjian_Allocation = {}
		return return_str
	end
	
	--doQingjian的返回值必定只有一个id
	local target = return_str:split("&->")[2]
	if not target then
		self.Qingjian_DummyCount = 0
		self.Qingjian_Allocation = {}
		return return_str
	end
	self.Qingjian_DummyCount = self.Qingjian_DummyCount + 1
	if not self.Qingjian_Allocation[target] then
		self.Qingjian_Allocation[target] = 1
	else
		self.Qingjian_Allocation[target] = self.Qingjian_Allocation[target] + 1
	end
	return return_str
end
sgs.ai_skill_use["@@Qingjian"] = sgs.ai_skill_use["@@Qingjian!"]

----------------------------------------------------------------------------------------------------

-- WEI 004 张辽

-- 突袭
function SmartAI:findTuxiLBTarget(tuxi_mark)

	self:sort(self.enemies, "handcard_defense")
	--local tuxi_mark = self.player:getMark("TuxiLB")
	local targets = {}

	local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
	local luxun = sgs.findPlayerByShownSkillName("Lianying")
	local jiangfei = sgs.findPlayerByShownSkillName("shoucheng")

	local add_player = function (player, isfriend)
		if player:getHandcardNum() < self.player:getHandcardNum() then return #targets end
		if player:getHandcardNum() == 0 or player:objectName() == self.player:objectName() then return #targets end
		
		local f = false
		for _, c in ipairs(targets) do
			if c:objectName() == player:objectName() then
				f = true
				break
			end
		end

		if not f then table.insert(targets, player) end

		if isfriend and isfriend == 1 then
			self.player:setFlags("tuxi_isfriend_"..player:objectName())
		end
		return #targets
	end

	if zhugeliang and self:isFriend(zhugeliang) and sgs.ai_explicit[zhugeliang:objectName()] ~= "unknown" and zhugeliang:getHandcardNum() == 1
		and self:getEnemyNumBySeat(self.player,zhugeliang) > 0 then
		if zhugeliang:getHp() <= 2 then
			if add_player(zhugeliang, 1) == tuxi_mark then return targets end
		else
			local cards = sgs.QList2Table(zhugeliang:getHandcards())
			if #cards == 1 and sgs.cardIsVisible(cards[1], zhugeliang, self.player) then
				if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
					if add_player(zhugeliang, 1) == tuxi_mark then return targets end
				end
			end
		end
	end

	if luxun and self:isFriend(luxun) and luxun:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, luxun) > 0 then
		local cards = sgs.QList2Table(luxun:getHandcards())
		if #cards == 1 and sgs.cardIsVisible(cards[1], luxun, self.player) then
			if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
				if add_player(luxun, 1) == tuxi_mark then return targets end
			end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		local cards = sgs.QList2Table(enemy:getHandcards())
		for _, card in ipairs(cards) do
			if sgs.cardIsVisible(card, enemy, self.player) and (card:isKindOf("Peach") or card:isKindOf("Nullification") or card:isKindOf("Analeptic") ) then
				if add_player(enemy) == tuxi_mark then return targets end
			end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if enemy:hasShownSkills("jijiu|qingnang|leiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|tianxiang|lijian|jijiu_HuaTuo_LB|liuli_DaQiao_LB|Xinzhan") then
			if add_player(enemy) == tuxi_mark then return targets end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		local x = enemy:getHandcardNum()
		local good_target = true
		if not self:hasLoseHandcardEffective(enemy) then good_target = false end
		if x == 1 and self:needKongcheng(enemy) then good_target = false end
		if x >= 2 and enemy:hasShownSkill("tuntian") then good_target = false end
		if good_target and add_player(enemy) == tuxi_mark then return targets end
	end
	
	if jiangfei then
		for _,friend in ipairs(self.friends_noself) do
			if friend:isFriendWith(jiangfei) and friend:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, friend) > 0 then
				local cards = sgs.QList2Table(friend:getHandcards())
				if #cards == 1 and sgs.cardIsVisible(cards[1], friend, self.player) then
					if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
						if add_player(friend, 1) == tuxi_mark then return targets end
					end
				end
			end
		end
	end

	if luxun and add_player(luxun,(self:isFriend(luxun) and 1 or nil)) == tuxi_mark then
		return targets
	end

	for _, enemy in ipairs(self.enemies) do  --守成（抄上面某一段，去掉了守成的判断）
		local x = enemy:getHandcardNum()
		local good_target = true
		if x == 1 and self:needKongcheng(enemy) then good_target = false end
		if x >= 2 and enemy:hasShownSkill("tuntian") then good_target = false end
		if good_target and add_player(enemy) == tuxi_mark then return targets end
	end
	
	local others = self.room:getOtherPlayers(self.player)
	for _, other in sgs.qlist(others) do
		if self:objectiveLevel(other) >= 0 and not other:hasShownSkill("tuntian") and add_player(other) == tuxi_mark then
			return targets
		end
	end
	
	for _, other in sgs.qlist(others) do
		if self:objectiveLevel(other) >= 0 and not other:hasShownSkill("tuntian") and math.random(0, 5) <= 1 and not self.player:hasSkill("qiaobian") then
			add_player(other)
		end
	end
	
	return targets
end
sgs.ai_skill_playerchosen.TuxiLB = function(self, targets, max_num, min_num)
	if not self:willShowForAttack() then return {} end
	local victims = self:findTuxiLBTarget(max_num)
	if type(victims) == "table" and #victims > 0 then
		return victims
	end
	return {}
end

----------------------------------------------------------------------------------------------------

-- WEI 005 许褚

-- 裸衣
sgs.ai_skill_invoke.LuoyiLB = function(self)
	if self.player:getPile("YijiLB"):length() > 1 then return false end
	--先判断能否发动旧裸衣
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local slashtarget = 0
	local dueltarget = 0
	self:sort(self.enemies, "hp")
	for _,card in ipairs(cards) do
		if card:isKindOf("Slash") or (self.player:hasWeapon("Spear") and self.player:getCards("h"):length() > 0) then
			for _,enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, card, true) and self:slashIsEffective(card, enemy) and self:objectiveLevel(enemy) > 3 and sgs.isGoodTarget(enemy, self.enemies, self) then
					if (not enemy:hasArmorEffect("SilverLion") or self.player:hasWeapon("QinggangSword")) and (getCardsNum("Jink", enemy) < 1
					or (self.player:hasWeapon("Axe") and self.player:getCards("he"):length() > 3))
					or (self:getOverflow() > 1)
					then
						slashtarget = slashtarget + 1
					end
				end
			end
		end
		if card:isKindOf("Duel") then
			for _, enemy in ipairs(self.enemies) do
				if self:getCardsNum("Slash") >= getCardsNum("Slash", enemy, self.player) and sgs.isGoodTarget(enemy, self.enemies, self)
				and not enemy:hasArmorEffect("SilverLion")
				and self:objectiveLevel(enemy) > 3 and self:damageIsEffective(enemy) then
					dueltarget = dueltarget + 1
				end
			end
		end
	end
	if (slashtarget+dueltarget) > 0 then
		return true
	end
	
	local diaochan = sgs.findPlayerByShownSkillName("lijian")
	if diaochan and self:isEnemy(diaochan) and self.player:isMale() then
		for _, friend in ipairs(self.friends_noself) do
			if self:isWeak(friend) or friend:getHp() <= 2 then return false end
		end
	end
	
	if not self:willShowForAttack() then return false end
	slashtarget = 0
	local card = sgs.Sanguosha:cloneCard("slash")
	for _,enemy in ipairs(self.enemies) do
		if self.player:canSlash(enemy, true) and self:slashIsEffective(card, enemy) and self:objectiveLevel(enemy) > 3 and sgs.isGoodTarget(enemy, self.enemies, self) then
			if (not enemy:hasArmorEffect("SilverLion") or self.player:hasWeapon("QinggangSword")) and (getCardsNum("Jink", enemy) < 1
			or (self.player:hasWeapon("Axe") and self.player:getCards("he"):length() > 3))
			or (self:getOverflow() > 1)
			then
				slashtarget = slashtarget + 1
			end
		end
	end
	if slashtarget > 0 then return true end
	
	slashtarget = 0  --不同于上面那几行，这是能杀的到的敌人
	local card = sgs.Sanguosha:cloneCard("slash")
	for _,enemy in ipairs(self.enemies) do
		if self.player:canSlash(enemy, true) and self:slashIsEffective(card, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then
			slashtarget = slashtarget + 1
		end
	end
	if slashtarget > 0 then return not self:isWeak() end
	--return not self:isWeak()
	return false
end
sgs.ai_cardneed.LuoyiLB = sgs.ai_cardneed.luoyi
sgs.LuoyiLB_keep_value = sgs.luoyi_keep_value

----------------------------------------------------------------------------------------------------

-- WEI 006 郭嘉

-- 天妒
sgs.ai_skill_invoke.tiandu_GuoJia_LB = sgs.ai_skill_invoke.tiandu
sgs.ai_slash_prohibit.tiandu_GuoJia_LB = sgs.ai_slash_prohibit.tiandu

-- 遗计
sgs.ai_skill_invoke.YijiLB = function(self)
	if not self:willShowForMasochism() then return false end
	if self:needKongcheng(self.player, true) and #self.friends_noself == 0 and self.player:getHandcardNum() == 0 then return false end
	return true
end
sgs.yijicards1 = {}
sgs.yijicards2 = {}
--[[sgs.ai_skill_use["@@YijiLB"] = function(self, prompt)		--魏国跳过摸牌阶段的技能放到这里
	--其实可以像旧遗计一张张给的，但是我反应过来的时候已经写好了……
	if self.yiji_no_target3 then
		self.yiji_no_target3 = false
		return "."
	end
	if self.yijitarget2 and next(sgs.yijicards2) then
		local cards2 = table.copyFrom(sgs.yijicards2)
		sgs.yijicards2 = {}
		if #sgs.yijicards1 + #cards2 < math.min(self.yiji_initial_num, 4) then
			self.yiji_no_target3 = true  --防止在给了两个人3牌后第三次触发遗计
		end
		return ("#YijiLBCard:%s:&->%s"):format(table.concat(cards2, "+"), self.yijitarget2:objectName())
	end
	if self.yiji_no_target2 then
		self.yiji_no_target2 = false
		self.yiji_no_target3 = false
		return "."
	end
	
	self.yijitarget2 = nil
	self.yiji_no_target2 = false
	self.yiji_no_target3 = false
	local target1, target2
	local extra = self:getCardsNum("Jink") - self.player:getHp() - self:getCardsNum("Peach") > 0
	local pushback, pushback_ids = {}, {}
	
	local cards = sgs.CardList()
	for _,id in pairs(self.player:property("YijiLB_hands"):toString():split("+")) do
		if id ~= "" and tonumber(id) then
			cards:append(sgs.Sanguosha:getCard(id))
		end
	end
	self.yiji_initial_num = cards:length()  --记录可以给出的卡牌数（主要用于yiji_no_target3的判断）
	
	local function addYijiTarget(target, cardid, willPushback)
		if willPushback then
			local willSkipDraw = target:hasShownSkills("shensu|qiaobian|LuoyiLB") or self:willSkipDrawPhase(target) or not target:faceUp()
								or target:hasShownSkill("TuxiLB")  --突袭纯粹是为了控手牌数
			if willSkipDraw then
				table.insert(pushback, target)
				if not pushback_ids[target:objectName()] then
					pushback_ids[target:objectName()] = {cardid}
				else
					table.insert(pushback_ids[target:objectName()], cardid)
				end
				return
			end
		end
		if not target1 or target1:objectName() == target:objectName() then
			target1 = target
			if #sgs.yijicards1 < 2 then table.insert(sgs.yijicards1, cardid) end
		elseif not target2 or target2:objectName() == target:objectName() then
			target2 = target
			if #sgs.yijicards2 < 2 then table.insert(sgs.yijicards2, cardid) end
		end
	end
	
	for _,card in sgs.qlist(cards) do
		if card:isKindOf("Peach") or card:isKindOf("Analeptic") then continue end
		if not extra and card:isKindOf("Jink") then continue end
		local ids = {}
		table.insert(ids, card:getEffectiveId())
		local target, cardid = sgs.ai_skill_askforyiji.yiji(self, ids)
		if not target or (target:objectName() == self.player:objectName()) then continue end
		if self:isEnemy(target) and self:needKongcheng(target, true) then continue end  --标遗计的分配会试图破空城，而这不适用于界遗计
		addYijiTarget(target, cardid, true)
	end
	
	if (not target2) and self:getOverflow() >= (self:willSkipPlayPhase() and -1 or 2) then
		for _,target in pairs(pushback) do
			for _,id in pairs(pushback_ids[target:objectName()]) do
				addYijiTarget(target, id, false)
			end
		end
	end
	
	if not target1 then return "." end
	if target2 then self.yijitarget2 = target2
	else self.yiji_no_target2 = true end
	if next(sgs.yijicards1) then
		local cards_str = table.concat(sgs.yijicards1, "+")
		sgs.yijicards1 = {}
		return ("#YijiLBCard:%s:&->%s"):format(cards_str, target1:objectName())
	end
end]]
sgs.ai_skill_playerchosen.YijiLB = function(self)
	self.yijitarget1 = nil
	self.yijitarget2 = nil
	sgs.yijicards1 = {}
	sgs.yijicards2 = {}
	local target1, target2
	local extra = self:getCardsNum("Jink") - self.player:getHp() - self:getCardsNum("Peach") > 0
	local pushback, pushback_ids = {}, {}
	self.YijiLB_DummyCount = 0
	self.YijiLB_Allocation = {}
	
	local cards = self.player:getHandcards()
	
	local function addYijiTarget(target, cardid, willPushback)
		if willPushback then
			local willSkipDraw = target:hasShownSkills("shensu|qiaobian|LuoyiLB") or self:willSkipDrawPhase(target) or not target:faceUp()
								or (self.room:getCurrent() and self.room:getCurrent():objectName() == target:objectName() and target:getPhase() >= sgs.Player_Draw)
								or target:hasShownSkill("TuxiLB")  --突袭纯粹是为了控手牌数
			if willSkipDraw then
				table.insert(pushback, target)
				if not pushback_ids[target:objectName()] then
					pushback_ids[target:objectName()] = {cardid}
				else
					table.insert(pushback_ids[target:objectName()], cardid)
				end
				return
			end
		end
		if not target1 or target1:objectName() == target:objectName() then
			target1 = target
			if #sgs.yijicards1 < 2 then
				table.insert(sgs.yijicards1, cardid) 
				self.YijiLB_DummyCount = self.YijiLB_DummyCount + 1
				self.YijiLB_Allocation[target1:objectName()] = sgs.yijicards1
			end
		elseif not target2 or target2:objectName() == target:objectName() then
			target2 = target
			if #sgs.yijicards2 < 2 then
				table.insert(sgs.yijicards2, cardid) 
				self.YijiLB_DummyCount = self.YijiLB_DummyCount + 1
				self.YijiLB_Allocation[target2:objectName()] = sgs.yijicards2
			end
		end
	end
	
	for _,card in sgs.qlist(cards) do
		if isCard("Peach", card, self.player) or (isCard("Analeptic", card, self.player) and self:isWeak()) or isCard("Nullification", card, self.player) then continue end
		if not extra and isCard("Jink", card, self.player) then continue end
		local ids = {}
		table.insert(ids, card:getEffectiveId())
		self.YijiLB_using = true
		local target, cardid = sgs.ai_skill_askforyiji.yiji(self, ids)
		self.YijiLB_using = false
		if not target or (target:objectName() == self.player:objectName()) then continue end
		if self:isEnemy(target) and self:needKongcheng(target, true) then continue end  --标遗计的分配会试图破空城，而这不适用于界遗计
		addYijiTarget(target, cardid, true)
	end
	
	if (not target2) and self:getOverflow() >= (self:willSkipPlayPhase() and -1 or 2) then
		for _,target in pairs(pushback) do
			for _,id in pairs(pushback_ids[target:objectName()]) do
				addYijiTarget(target, id, false)
			end
		end
	end
	
	if target1 and target2 then
		local target_list = sgs.SPlayerList()
		target_list:append(target1)
		target_list:append(target2)
		self.room:sortByActionOrder(target_list)
		target1, target2 = target_list:first(), target_list:at(1)
		sgs.yijicards1 = self.YijiLB_Allocation[target1:objectName()]  --顺序可能交换了
		sgs.yijicards2 = self.YijiLB_Allocation[target2:objectName()]
	end
	
	if not target1 then return {} end
	self.yijitarget1 = target1
	if target2 then self.yijitarget2 = target2 end
	local targets = {target1}
	if target2 then table.insert(targets, target2) end
	return targets
end
sgs.ai_skill_exchange.YijiLB = function(self, pattern, max_num, min_num, expand_pile)
	local toDis = {}
	if self.yijitarget1 then
		if #sgs.yijicards1 > 0 then
			for _,id in ipairs(sgs.yijicards1) do
				table.insert(toDis, id)
			end
			sgs.yijicards1 = {}
			self.yijitarget1 = nil
			return toDis
		end
	elseif self.yijitarget2 then
		if #sgs.yijicards2 > 0 then
			for _,id in ipairs(sgs.yijicards2) do
				table.insert(toDis, id)
			end
			sgs.yijicards2 = {}
			self.yijitarget2 = nil
			return toDis
		end
	end
	self.room:writeToConsole("Error: Yiji target or cards not found")
	self.player:setFlags("Global_AIDiscardExchanging")  --v2中exchange就是用discard进行的
	local to_exchange = self:askForDiscard("YijiLB", 1, 1, false, false)
	self.player:setFlags("-Global_AIDiscardExchanging")
	return to_exchange
end
sgs.ai_need_damaged.YijiLB = function (self, attacker, player)
	if not player:hasSkill("YijiLB") then return end

	local friends = {}
	for _, ap in sgs.qlist(self.room:getAlivePlayers()) do
		if self:isFriend(ap, player) then
			table.insert(friends, ap)
		end
	end
	self:sort(friends, "hp")

	if #friends > 0 and friends[1]:objectName() == player:objectName() and self:isWeak(player) and getCardsNum("Peach", player, (attacker or self.player)) == 0 then return false end

	return player:getHp() > 2 and sgs.turncount > 2 and #friends > 1 and not self:isWeak(player) and player:getHandcardNum() >= 2
end

----------------------------------------------------------------------------------------------------

-- SHU 001 刘备

-- 仁德
function SmartAI:willUseRendeLBAnaleptic(before_rende)
	before_rende = before_rende or false
	if not self.player:hasSkill("RendeLB") or not sgs.Analeptic_IsAvailable(self.player) then return false end
	if before_rende and self.player:getHandcardNum() <= 2 then return false end
	if self:isWeak() and self.player:isWounded() and self:needToLoseHp(self.player, nil, nil, nil, true) then return false end  --Use peach instead
	if self.player:hasSkill("shengxi") and not self.player:hasFlag("ShengxiDamageInPlayPhase") then return false end
	
	if self:getCardsNum("Slash") >= 1 and self:slashIsAvailable(self.player) then
		local slashes = self:getCards("Slash")
		self:sortByUseValue(slashes)
		slash = slashes[1]
		if slash and self:slashIsAvailable(self.player, slash) then
			local canSlash = false  --此处有杀次数上限已到却返回true的问题（因为CardUseReason不是PLAY），因此手动判断，照抄Slash_isAvailable（同潜心）
			if #self.player:property("extra_slash_specific_assignee"):toString():split("+") > 1 then
				canSlash = true
			elseif self.player:hasWeapon("Crossbow") and not slash:getSubcards():contains(self.player:getWeapon():getEffectiveId()) then
				canSlash = true
			else
				canSlash = self.player:canSlashWithoutCrossbow(slash)
			end
			if canSlash then
				local use = {isDummy = true, card = slash}
				for _, enemy in ipairs(self.enemies) do
					if --[[((enemy:getHp() < 3 and enemy:getHandcardNum() < 3) or (enemy:getHandcardNum() < 2)) and]] self.player:canSlash(enemy, slash) and not self:slashProhibit(slash, enemy, self.player)
						and self:slashIsEffective(slash, enemy, self.player) and sgs.isGoodTarget(enemy, self.enemies, self, true) and self:shouldUseAnaleptic(enemy, use) then
						return true
					end
				end
			end
		end
	end
	return false
end
function SmartAI:shouldUseRendeLB()
	local rende_dummycount = self.RendeLB_DummyCount or 0
	local real_mark = self.player:getMark("RendeLB") + rende_dummycount
	local real_handcard = self.player:getHandcardNum() - rende_dummycount
	local real_overflow = self:getOverflow() - rende_dummycount
	
	if (self:hasCrossbowEffect() or self:getCardsNum("Crossbow") > 0 or self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") ) and self:getCardsNum("Slash") > 0 then
		self:sort(self.enemies, "defense")
		for _, enemy in ipairs(self.enemies) do
			local inAttackRange = self.player:distanceTo(enemy) == 1 or self.player:distanceTo(enemy) == 2
									and self:getCardsNum("OffensiveHorse") > 0 and not self.player:getOffensiveHorse()
			local inPaoxiaoAttackRange =  self.player:distanceTo(enemy) <= self.player:getAttackRange() and self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao")
			if (inAttackRange or inPaoxiaoAttackRange) and sgs.isGoodTarget(enemy, self.enemies, self) then
				local slashes = self:getCards("Slash")
				local slash_count = 0
				for _, slash in ipairs(slashes) do
					if not self:slashProhibit(slash, enemy) and self:slashIsEffective(slash, enemy) then
						slash_count = slash_count + 1
					end
				end
				if slash_count >= enemy:getHp() then return false end
			end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		if enemy:canSlash(self.player) and not self:slashProhibit(nil, self.player, enemy)
			and self:hasCrossbowEffect(enemy) and getCardsNum("Slash", enemy) > 1 and real_overflow <= 0 then
			return false
		end
	end
	for _, player in ipairs(self.friends_noself) do
		if (player:hasShownSkill("haoshi") and not player:containsTrick("supply_shortage")) or player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") then
			return true
		end
	end

	local keepNum = 1
	if real_mark == 0 then
		if real_handcard == 3 then
			keepNum = 0
		end
		if real_handcard > 3 then
			keepNum = 3
		end
	end
	if self.player:hasSkill("kongcheng") then
		keepNum = 0
	elseif self.player:hasSkill("shengxi") and not self.player:hasFlag("ShengxiDamageInPlayPhase") then
		keepNum = math.min(keepNum, math.max(self:getOverflow(self.player, true) - 2, 0))
	end

	if real_overflow > 0 then
		return true
	end
	if real_handcard > keepNum then
		return true
	end
	if real_mark ~= 0 and real_mark < 2
		and (2 - real_mark) >= (real_handcard - keepNum) then
		return true
	end

	if self.player:hasSkill("kongcheng") then
		return true
	end
	if self.player:hasSkill("shengxi") and not self.player:hasFlag("ShengxiDamageInPlayPhase") then
		return true
	end
	
	if real_mark < 2 then
		if self:willUseRendeLBAnaleptic(true) then return true end
	end

	return false
end
local rende_skill = {}
rende_skill.name = "RendeLB"
table.insert(sgs.ai_skills, rende_skill)
rende_skill.getTurnUseCard = function(self)
	if self.player:isKongcheng() then return end

	self.RendeLB_DummyCount = 0
	if self:shouldUseRendeLB() then
		return sgs.Card_Parse("#RendeLBCard:.:&RendeLB")
	end
end
sgs.ai_skill_use_func["#RendeLBCard"] = function(card, use, self)
    local friends, enemies, unknowns = {}, {}, {}
    local arrange = {}
    arrange["count"] = 0
	self.RendeLB_DummyCount = 0  --记录已经决定要给出去但还没有发动的牌（防止在smart-ai的函数里误判断为0）
	self.RendeLB_Allocation = {}  --记录已经决定给每名角色的牌（防止在smart-ai的函数里误判断为0），其实和arrange相同
    for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
        if p:getMark("RendeLBRecipient") == 0 then
            arrange[p:objectName()] = {}
            if self:isFriend(p) then
                table.insert(friends, p)
            elseif self:isEnemy(p) then
                table.insert(enemies, p)
            else
                table.insert(unknowns, p)
            end
        end
    end
	
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)
	local is_anal = self:willUseRendeLBAnaleptic(true)
	if is_anal then
		local slashes = self:getCards("Slash")
		self:sortByUseValue(slashes)
		slash = slashes[1]
		if slash and slash:isAvailable(self.player) then
			cards = self:resetCards(cards, slash)  --留着酒杀
		end
	end
	
	local fazheng = table.contains(friends, sgs.findPlayerByShownSkillName("Enyuan")) and sgs.findPlayerByShownSkillName("Enyuan")
	local buzhi = table.contains(friends, sgs.findPlayerByShownSkillName("Hongde")) and sgs.findPlayerByShownSkillName("Hongde")

	local notFound
	local all_notFound = true
	local index = 1  --依然是烦人的table遍历bug……
	while index <= #cards do
		if not self:shouldUseRendeLB() then break end
		notFound = false
		local card, friend = self:getCardNeedPlayer(cards, friends, "RendeLB")
		if card and friend then
			cards = self:resetCards(cards, card)
		else
			notFound = true
			--continue
		end
		if not friend then
			if (self.player:getHandcardNum() - arrange["count"] < 3 and self.player:hasSkill("kongcheng"))
				or (self:getOverflow() - arrange["count"] > -2 and self.player:hasSkill("shengxi") and not self.player:hasFlag("ShengxiDamageInPlayPhase")) then
				for _, p in ipairs(friends) do
					friend = p
				end
			end
		end
		if not friend then
			if fazheng and arrange[fazheng:objectName()] <= 1 and (#cards >= 2 - arrange[fazheng:objectName()]) then friend = fazheng
			elseif buzhi and arrange[buzhi:objectName()] <= 1 and (#cards >= 2 - arrange[buzhi:objectName()]) then friend = buzhi end
		end
		
		if friend and not card then
			card = cards[index]
			cards = self:resetCards(cards, card)
		end
		if friend and card then notFound = false end
		if notFound then index = index + 1 continue end
		index = 1
		all_notFound = false

		if friend:objectName() == self.player:objectName() or not self.player:getHandcards():contains(card) then continue end

		if card:isAvailable(self.player) and (card:isKindOf("Slash") or card:isKindOf("Duel") or card:isKindOf("Snatch") or card:isKindOf("Dismantlement")) then
			local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
			local cardtype = card:getTypeId()
			self["use" .. sgs.ai_type_name[cardtype + 1] .. "Card"](self, card, dummy_use)
			if dummy_use.card and dummy_use.to:length() > 0 then
				if card:isKindOf("Slash") or card:isKindOf("Duel") then
					local t1 = dummy_use.to:first()
					if dummy_use.to:length() > 1 then continue
					elseif card:isKindOf("Slash") and (t1:getHp() == 1 or sgs.card_lack[t1:objectName()]["Jink"] == 1
							or t1:isCardLimited(sgs.cloneCard("jink"), sgs.Card_MethodResponse)) then continue
					elseif card:isKindOf("Duel") and (t1:getHp() == 1 or sgs.card_lack[t1:objectName()]["slash"] == 1
							or t1:isCardLimited(sgs.cloneCard("slash"), sgs.Card_MethodResponse)) then continue
					end
				elseif (card:isKindOf("Snatch") or card:isKindOf("Dismantlement")) and self:getEnemyNumBySeat(self.player, friend) > 0 then
					local hasDelayedTrick, hasDelayedTrickFriend
					for _, p in sgs.qlist(dummy_use.to) do
						if self:isFriend(p) and (self:willSkipDrawPhase(p) or self:willSkipPlayPhase(p)) then 
							hasDelayedTrick = true 
							hasDelayedTrickFriend = p
							break 
						end
					end
					if hasDelayedTrick then  --留给月英用拆顺
						if not friend:hasShownSkill("jizhi") or not friend:faceUp() or self:willSkipPlayPhase(friend) then continue end
						if a:getRoom():getFront(hasDelayedTrickFriend, friend):objectName() == hasDelayedTrickFriend:objectName() then continue end
					end
				end
			end
		elseif card:isAvailable(self.player) and self:getEnemyNumBySeat(self.player, friend) > 0 and (card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage")) then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then continue end
		end
		
		table.insert(arrange[friend:objectName()], card)
		arrange["count"] = arrange["count"] + 1
		self.RendeLB_DummyCount = arrange["count"]
		self.RendeLB_Allocation = arrange
	end
	
	--[[if all_notFound then  --处理☆SP庞统
		local pangtong = self.room:findPlayerBySkillName("manjuan")
		if not pangtong then return end
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByUseValue(cards, true)
		if self.player:isWounded() and self.player:getHandcardNum() > 3 and self.player:getMark("rende") < 2 then
			local to_give = {}
			for _, card in ipairs(cards) do
				if not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) then table.insert(to_give, card:getId()) end
				if #to_give == 2 - self.player:getMark("rende") then break end
			end
			if #to_give > 0 then
				use.card = sgs.Card_Parse("@RendeCard=" .. table.concat(to_give, "+"))
				if use.to then use.to:append(pangtong) end
			end
		end
	end]]
	
	local max_count, max_name = 0, nil
	if fazheng and next(arrange[fazheng:objectName()]) then
		local cards = arrange[fazheng:objectName()]
		if type(cards) == "table" and #cards >= 2 then
			max_count = #cards
			max_name = fazheng:objectName()
		end
	elseif buzhi and next(arrange[buzhi:objectName()]) then
		local cards = arrange[buzhi:objectName()]
		if type(cards) == "table" and #cards >= 2 then
			max_count = #cards
			max_name = buzhi:objectName()
		end
	else
		for name, cards in pairs(arrange) do
			if type(cards) == "table" then
				local count = #cards
				if count > max_count then
					max_count = count
					max_name = name
				end
			end
		end
	end
    if max_count == 0 or not max_name then
        return 
    end
    local max_target = nil
    for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
        if p:objectName() == max_name then
            max_target = p
            break
        end
    end
    if max_target and type(arrange[max_name]) == "table" and #arrange[max_name] > 0 then
        local to_use = {}
        for _,c in ipairs(arrange[max_name]) do
            table.insert(to_use, c:getEffectiveId())
        end
        local card_str = string.format("#RendeLBCard:%s:&RendeLB", table.concat(to_use, "+"))
        local acard = sgs.Card_Parse(card_str)
        assert(acard)
        use.card = acard
        if use.to then
            use.to:append(max_target)
        end
		self.RendeLB_DummyCount = 0
		self.RendeLB_Allocation = {}
    end
end
sgs.ai_skill_choice["RendeLB"] = function(self, choices)
	local items = choices:split("+")
    if #items == 1 then
        return items[1]
	else
		if self:isWeak() and self.player:isWounded() and table.contains(items, "peach") then return "peach" end
		if table.contains(items, "analeptic") and self:willUseRendeLBAnaleptic(false) then return "analeptic" end
		for _, enemy in ipairs(self.enemies) do
			if self.player:canSlash(enemy) and sgs.isGoodTarget(enemy, self.enemies, self, true) then
				local thunder_slash = sgs.Sanguosha:cloneCard("thunder_slash")
				local fire_slash = sgs.Sanguosha:cloneCard("fire_slash")
				if table.contains(items, "fire_slash") and not self:slashProhibit(fire_slash, enemy, self.player) and self:slashIsEffective(fire_slash, enemy, self.player) then
					return "fire_slash"
				end
				if table.contains(items, "thunder_slash") and not self:slashProhibit(thunder_slash, enemy, self.player) and self:slashIsEffective(thunder_slash, enemy, self.player)then
					return "thunder_slash"
				end
				if table.contains(items, "slash") and not self:slashProhibit(slash, enemy, self.player) and self:slashIsEffective(slash, enemy, self.player)then
					return "slash"
				end
			end
		end
		if self.player:isWounded() and table.contains(items, "peach") then return "peach" end
    end
    return "cancel"
end
sgs.ai_skill_use["@@RendeLB"] = function(self, prompt)
	local class_name = self.player:property("RendeLBBasicCard"):toString()
	local use_card = sgs.Sanguosha:cloneCard(class_name, sgs.Card_NoSuit, 0)
	use_card:setSkillName("_RendeLB")
	assert(use_card)
	local use = {isDummy = true, to = sgs.SPlayerList()}
	self:useBasicCard(use_card, use)
	if not use.card then return end
	local targets = {}
	for _,to in sgs.qlist(use.to) do
		table.insert(targets, to:objectName())
	end
	return use_card:toString() .. "->" .. table.concat(targets, "+")
end
sgs.ai_use_value.RendeLBCard = sgs.ai_use_value.RendeCard
sgs.ai_use_priority.RendeLBCard = sgs.ai_use_priority.RendeCard
sgs.ai_card_intention.RendeLBCard = sgs.ai_card_intention.RendeCard
sgs.dynamic_value.benefit.RendeLBCard = sgs.dynamic_value.benefit.RendeCard

----------------------------------------------------------------------------------------------------

-- SHU 002 关羽

-- 武圣
sgs.ai_view_as.wusheng_GuanYu_LB = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getHandPile():contains(card_id)) and (player:getLord() and player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:wusheng_GuanYu_LB[%s:%s]=%d&wusheng_GuanYu_LB"):format(suit, number, card_id)
	end
end
local wusheng_skill = {}
wusheng_skill.name = "wusheng_GuanYu_LB"
table.insert(sgs.ai_skills, wusheng_skill)
wusheng_skill.getTurnUseCard = function(self, inclusive)
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash") < 2 or self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then disCrossbow = true end

	local hecards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getHandPile()) do
		hecards:prepend(sgs.Sanguosha:getCard(id))
	end
	local cards = {}
	for _, card in sgs.qlist(hecards) do
		if (self.player:getLord() and self.player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Slash")
			and ((not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player)) or useAll)
			and (not isCard("Crossbow", card, self.player) or disCrossbow ) then
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:wusheng_GuanYu_LB[%s:%s]=%d&wusheng_GuanYu_LB"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				table.insert(cards, slash)
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end
function sgs.ai_cardneed.wusheng_GuanYu_LB(to, card)
	return sgs.ai_cardneed.wusheng(to, card)
end
sgs.ai_suit_priority.wusheng_GuanYu_LB = sgs.ai_suit_priority.wusheng

-- 义绝
local yijue_skill = {}
yijue_skill.name = "Yijue"
table.insert(sgs.ai_skills, yijue_skill)
yijue_skill.getTurnUseCard = function(self)
	local haveWoundedFriends = false
	local wounded_friends = self:getWoundedFriend()
	if #wounded_friends > 0 then
		for _, wounded in ipairs(wounded_friends) do
			if wounded:getHandcardNum() > 1 and wounded:getLostHp() / wounded:getMaxHp() >= 0.3 then
				haveWoundedFriends = self:willShowForDefence()
			end
		end
	end
	if not self:willShowForAttack() and not haveWoundedFriends then return end
	if not self.player:hasUsed("#YijueCard") and not self.player:isKongcheng() then return sgs.Card_Parse("#YijueCard:.:&Yijue") end
end
sgs.ai_skill_use_func["#YijueCard"] = function(card, use, self)  --todo：尝试解决义绝目标与集火目标不一的问题（借鉴原项目）；尝试解决先杀再义绝的问题
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard()
	if not max_card then return end
	local max_point = max_card:getNumber()
	if self.player:hasSkill("yingyang") then max_point = math.min(max_point + 3, 13) end
	if self.player:hasSkill("kongcheng") and self.player:getHandcardNum() == 1 then
		for _, enemy in ipairs(self.enemies) do
			--if not enemy:isKongcheng() and self:hasLoseHandcardEffective(enemy) and not (enemy:hasSkills("tuntian") and enemy:getHandcardNum() > 2) then
			if not self:doNotDiscard(enemy, "h", true) then
				sgs.ai_use_priority.YijueCard = 1.2
				self.Yijue_card = max_card:getId()
				use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end

	local zhugeliang = self.room:findPlayerBySkillName("kongcheng")

	sgs.ai_use_priority.YijueCard = 7.2
	self:sort(self.enemies)
	self.enemies = sgs.reverse(self.enemies)
	for _, enemy in ipairs(self.enemies) do
		--if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
		if not self:doNotDiscard(enemy, "h", true) then
			local enemy_max_card = self:getMaxCard(enemy)
			local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
			if enemy_max_card and enemy:hasShownSkill("yingyang") then enemy_max_point = math.min(enemy_max_point + 3, 13) end
			if max_point > enemy_max_point then
				self.Yijue_card = max_card:getId()
				use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		--if not (enemy:hasSkill("kongcheng") and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
		if not self:doNotDiscard(enemy, "h", true) then
			if max_point >= 10 then
				self.Yijue_card = max_card:getId()
				use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
	
	sgs.ai_use_priority.YijueCard = 1.2
	local min_card = self:getMinCard()
	if not min_card then return end
	local min_point = min_card:getNumber()
	if self.player:hasSkill("yingyang") then min_point = math.max(min_point - 3, 1) end

	local wounded_friends = self:getWoundedFriend()
	if #wounded_friends > 0 then
		for _, wounded in ipairs(wounded_friends) do
			if wounded:objectName() == self.player:objectName() then continue end   --源码什么鬼？？
			if wounded:getHandcardNum() > 1 and wounded:getLostHp() / wounded:getMaxHp() >= 0.3 then
				local w_max_card = self:getMaxCard(wounded)
				local w_max_number = w_max_card and w_max_card:getNumber() or 0
				if w_max_card and wounded:hasShownSkill("yingyang") then w_max_number = math.min(w_max_number + 3, 13) end
				if (w_max_card and w_max_number >= min_point) or min_point <= 4 then
					self.Yijue_card = min_card:getId()
					use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
					if use.to then use.to:append(wounded) end
					return
				end
			end
		end
	end

	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)
	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and zhugeliang:objectName() ~= self.player:objectName() then
		if min_point <= 4 then
			self.Yijue_card = min_card:getId()
			use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
			if use.to then use.to:append(zhugeliang) end
			return
		end
		if self:getEnemyNumBySeat(self.player, zhugeliang) >= 1 then
			if isCard("Jink", cards[1], self.player) and self:getCardsNum("Jink") == 1 then return end
			self.Yijue_card = cards[1]:getId()
			use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
			if use.to then use.to:append(zhugeliang) end
			return
		end
	end
	
	sgs.ai_use_priority.YijueCard = 0
	if self:getOverflow() > 0 then  --最后就是随便找个血少的敌人拼（代码来自天义）
		for _, enemy in ipairs(self.enemies) do
			if not self:doNotDiscard(enemy, "h", true) and not enemy:isKongcheng() then
				self.Yijue_card = cards[1]:getId()
				use.card = sgs.Card_Parse("#YijueCard:.:&Yijue")
				if use.to then use.to:append(enemy) end
				return
			end
		end
	end
end
function sgs.ai_skill_pindian.Yijue(minusecard, self, requestor)
	if requestor:getHandcardNum() == 1 then
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		return cards[1]
	end
	return self:getMaxCard()
end
sgs.ai_cardneed.Yijue = function(to, card, self)
	local cards = to:getHandcards()
	local has_big = false
	for _, c in sgs.qlist(cards) do
		local flag = string.format("%s_%s_%s", "visible", self.room:getCurrent():objectName(), to:objectName())
		if c:hasFlag("visible") or c:hasFlag(flag) then
			if c:getNumber() > 10 then
				has_big = true
				break
			end
		end
	end
	return not has_big and card:getNumber() > 10
end
sgs.ai_card_intention.YijueCard = 0
sgs.ai_use_value.YijueCard = 8.5
sgs.ai_skill_choice.Yijue = function(self, choices, data)  --选择武将牌				（todo：处理青龙刀）
	local who = data:toPlayer()
	local choice_table = choices:split("+")
	if #choice_table == 1 then return choice_table[1] end
	
	if who:hasShownSkill("Xiansi") and self:isEnemy(who) and who:getPile("counter"):length() >= 2 and self.player:canSlash(who) and self.player:getPhase() == sgs.Player_Play and self:hasCrossbowEffect() then
		local choice = who:inHeadSkills("Xiansi") and "deputy_general" or "head_general"
		if table.contains(choice_table, choice) then return choice end
	end
	
	if who:property("NonCompulsoryInvalidity"):toString() ~= "" then
		local invalid_list = who:property("NonCompulsoryInvalidity"):toString():split(",")  --已经无效了一张武将牌的情况
		for _, str in ipairs(invalid_list) do
			if str:startsWith("head") then
				return "deputy_general"
			end
			if str:startsWith("deputy") then
				return "head_general"
			end
		end
	end
	
	local skills = {}
	local estimated_damage = (self.player:getMark("drank") > 0) and 2 or 1
	if who:getHp() <= estimated_damage then
		table.insert(skills, sgs.exclusive_skill)
		table.insert(skills, sgs.niepan_skill)
	end
	table.insert(skills, sgs.masochism_skill)
	if who:getHp() <= estimated_damage then table.insert(skills, sgs.save_skill) end
	table.insert(skills, sgs.defense_skill)
	if who:getHp() > estimated_damage then table.insert(skills, sgs.save_skill) end
	if who:getPhase() ~= sgs.Player_NotActive then
		table.insert(skills, sgs.priority_skill)
	end
	table.insert(skills, sgs.lose_equip_skill)
	table.insert(skills, sgs.turnfinish_others_skill)
	skills = table.concat(skills, "|"):split("|")
	for _, skill in ipairs(skills) do
		if sgs.Sanguosha:getSkill(skill) and (sgs.Sanguosha:getSkill(skill):getFrequency() ~= sgs.Skill_Compulsory) and who:hasShownSkill(skill) then
			if self:isFriendWith(who) then
				return who:inHeadSkills(skill) and "deputy_general" or "head_general"
			else
				return who:inHeadSkills(skill) and "head_general" or "deputy_general"
			end
		end
	end
	
	if not who:hasShownGeneral1() then  --防暗将
		return "head_general"
	end
	if not who:hasShownGeneral2() then
		return "deputy_general"
	end
	
	local head_skills = who:getHeadSkillList()
	local head_skill_count = 0
	for _,skill in sgs.qlist(head_skills) do
		if (skill:getFrequency() ~= sgs.Skill_Compulsory) and (skill:getFrequency() ~= sgs.Skill_Limited) then
			head_skill_count = head_skill_count + 1
		elseif (skill:getFrequency() ~= sgs.Skill_Compulsory) and (skill:getFrequency() == sgs.Skill_Limited) then
			if skill:getLimitMark() and who:getMark(skill:getLimitMark()) > 0 then
				head_skill_count = head_skill_count + 1
			end
		end
	end
	local deputy_skills = who:getDeputySkillList()
	local deputy_skill_count = 0
	for _,skill in sgs.qlist(deputy_skills) do
		if (skill:getFrequency() ~= sgs.Skill_Compulsory) and (skill:getFrequency() ~= sgs.Skill_Limited) then
			deputy_skill_count = deputy_skill_count + 1
		elseif (skill:getFrequency() ~= sgs.Skill_Compulsory) and (skill:getFrequency() == sgs.Skill_Limited) then
			if skill:getLimitMark() and who:getMark(skill:getLimitMark()) > 0 then
				deputy_skill_count = deputy_skill_count + 1
			end
		end
	end
	if self:isFriend(who) then
		if head_skill_count >= deputy_skill_count then
			return "deputy_general"
		end
	else
		if head_skill_count >= deputy_skill_count then
			return "head_general"
		end
	end

	return "head_general"
end
sgs.ai_skill_choice.YijueRecover = function(self, choices, data)
	local target = nil
	for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
		if p:hasFlag("YijueTarget") then
			target = p
			break
		end
	end
	return self:isFriend(target) and "recover" or "cancel"
end
sgs.ai_choicemade_filter.skillChoice.Yijue = function(self, player, promptlist)
	local choice = promptlist[#promptlist]
	local intention = (choice == "recover") and -30 or 30
	local target = nil
	for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
		if p:hasFlag("YijueTarget") then
			target = p
			break
		end
	end
	if not target then return end
	sgs.updateIntention(player, target, intention)
end

----------------------------------------------------------------------------------------------------

-- SHU 003 张飞

-- 咆哮
sgs.ai_cardneed.paoxiao_ZhangFei_LB = sgs.ai_cardneed.paoxiao
sgs.paoxiao_ZhangFei_LB_keep_value = sgs.paoxiao_keep_value
sgs.ai_skill_invoke["#paoxiao_null_ZhangFei_LB"] = function(self, data)  --为什么源码会漏掉？
	if not self:willShowForAttack() then return false end

	local target_name = data:toString():split(":")[2]
	local target = findPlayerByObjectName(target_name)
	if not target then return false end
	if self:isFriend(target) then return false end

	local use = self.player:getTag("paoxiao_use"):toCardUse()
	if use.card:isKindOf("FireSlash") and target:hasArmorEffect("Vine") then
		return false
	end
	return true
end

-- 替身
sgs.ai_skill_invoke.Tishen = function(self, data)
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local peaches = 0
	local slashtarget = 0
	for _,card in ipairs(cards) do
		if card:isKindOf("Peach") then
			peaches = peaches + 1
		end
		if card:isKindOf("Slash") then
			for _,enemy in ipairs(self.enemies) do
				if self.player:canSlash(enemy, card, true) and self:slashIsEffective(card, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then
					slashtarget = slashtarget + 1
				end
			end
		end
	end
	local tishen_hp = self.player:property("Tishen_hp"):toInt()

	if self.player:getHp() <= 1 and tishen_hp - self.player:getHp() > 0 and peaches == 0 then return true end
	if tishen_hp - self.player:getHp() > 1 then return true end
	if slashtarget >= 1 and self.player:getMaxHp() <= 3 and self:willShowForAttack() then return true end  --Test
	return false
end
sgs.ai_need_damaged.Tishen = function(self, attacker, player)
	if player:getMark("@substitute") <= 0 then return end
	if player:getHp() <= 1 then return end
	local tishen_hp = player:property("Tishen_hp"):toInt()
	if tishen_hp - self.player:getHp() < 1 then return end
	
	local cards = player:getHandcards()
	cards = sgs.QList2Table(cards)
	local slashtarget, singleslashtarget = 0, 0
	for _,card in ipairs(cards) do
		singleslashtarget = 0
		if card:isKindOf("Slash") then
			for _,enemy in ipairs(self:getEnemies(player)) do
				if player:canSlash(enemy, card, true) and self:slashIsEffective(card, enemy, player) and sgs.isGoodTarget(enemy, self.enemies, self) then
					singleslashtarget = singleslashtarget + 1
					if self:isWeak(enemy) or player:hasSkills(sgs.force_damage_skill .. "|wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") then singleslashtarget = singleslashtarget + 0.3 end
				end
			end
			if not self:hasCrossbowEffect() then
				slashtarget = math.max(slashtarget, singleslashtarget)
			else
				slashtarget = slashtarget + singleslashtarget
			end
		end
	end
	if slashtarget >= 2 then return true end
	return false
end

----------------------------------------------------------------------------------------------------

-- SHU 005 赵云

-- 龙胆
local longdan_skill = {}
longdan_skill.name = "longdan_ZhaoYun_LB"
table.insert(sgs.ai_skills, longdan_skill)
longdan_skill.getTurnUseCard = function(self)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local jink_card

	self:sortByUseValue(cards,true)

	for _,card in ipairs(cards)  do
		if card:isKindOf("Jink") then
			jink_card = card
			break
		end
	end

	if not jink_card then return nil end
	local suit = jink_card:getSuitString()
	local number = jink_card:getNumberString()
	local card_id = jink_card:getEffectiveId()
	local card_str = ("slash:longdan_ZhaoYun_LB[%s:%s]=%d&longdan_ZhaoYun_LB"):format(suit, number, card_id)
	local slash = sgs.Card_Parse(card_str)
	assert(slash)

	return slash

end
sgs.ai_view_as.longdan_ZhaoYun_LB = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if card_place == sgs.Player_PlaceHand or player:getHandPile():contains(card_id) then
		if card:isKindOf("Jink") then
			return ("slash:longdan_ZhaoYun_LB[%s:%s]=%d&longdan_ZhaoYun_LB"):format(suit, number, card_id)
		elseif card:isKindOf("Slash") then
			return ("jink:longdan_ZhaoYun_LB[%s:%s]=%d&longdan_ZhaoYun_LB"):format(suit, number, card_id)
		end
	end
end
sgs.longdan_ZhaoYun_LB_keep_value = sgs.longdan_keep_value

-- 涯角
sgs.ai_skill_invoke.Yajiao = function(self, data)
	return self:willShowForDefence()
end
sgs.ai_skill_playerchosen.Yajiao = function(self, targets)
	local id = self.player:getMark("Yajiao")
	local card = sgs.Sanguosha:getCard(id)
	local cards = { card }
	local c, friend = self:getCardNeedPlayer(cards, self.friends)
	if friend then return friend end

	self:sort(self.friends)
	for _, friend in ipairs(self.friends) do
		if self:isValuableCard(card, friend) --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then return friend end
	end
	for _, friend in ipairs(self.friends) do
		if self:isWeak(friend) --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then return friend end
	end
	local trash = card:isKindOf("Disaster") or card:isKindOf("GodSalvation") or card:isKindOf("AmazingGrace") or card:isKindOf("AllianceFeast") or card:isKindOf("ThreatenEmperor")
	if trash then
		for _, enemy in ipairs(self.enemies) do
			if enemy:getPhase() > sgs.Player_Play and self:needKongcheng(enemy, true) and not (card:isKindOf("ThreatenEmperor") and card:isAvailable(enemy)) --[[and not hasManjuanEffect(enemy)]] then return enemy end
		end
	end
	for _, friend in ipairs(self.friends) do
		if --[[not hasManjuanEffect(friend) and]] not self:needKongcheng(friend, true) then return friend end
	end
end
sgs.ai_playerchosen_intention.Yajiao = function(self, from, to)
	if not self:needKongcheng(to, true) --[[and not hasManjuanEffect(to)]] then sgs.updateIntention(from, to, -50) end
end
sgs.ai_skill_invoke.YajiaoDiscard = function(self, choices, data)  --todo：将涯角、灭计、纵玄、攻心整合成同一个函数，判断是否该将一张牌往牌堆顶放（？）
	local id = self.player:getMark("Yajiao")
	local card = sgs.Sanguosha:getCard(id)
	local valuable = self:isValuableCard(card)
	
	local lord = self.room:getLord(self.player:getKingdom())
	local selfMayObtain = lord and lord:hasLordSkill("shouyue") and lord:hasShownGeneral1()
	if selfMayObtain then
		local valuable = self:isValuableCard(card, self.player)
		return not valuable
	end
	
	local current = self.room:getCurrent()
	if not current then return true end -- avoid potential errors
	if current:isAlive() then
		local currentMayObtain = getKnownCard(current, self.player, "ExNihilo") + getKnownCard(current, self.player, "IronChain") > 0
		if currentMayObtain then
			local valuable = self:isValuableCard(card, current)
			return not (self:isFriend(current) == valuable)
		end
	end

	local hasLightning, hasIndulgence, hasSupplyShortage
	local nextAlive = current:getNextAlive()  --todo：参考纵玄里半途而废的代码，修改对nextAlive的判断（考虑放权挟天子等情况）（灭计同理）
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() --[[and not nextAlive:containsTrick("YanxiaoCard")]] and not nextAlive:hasShownSkills("qianxi|luoshen|yinghun_sunjian|yinghun_sunce") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	
	if nextAlive:hasShownSkills("Jiewei|Jushou15") and not nextAlive:faceUp() then
		return not self:isFriend(nextAlive)
	end
	if nextAlive:hasShownSkill("hongfa") and nextAlive:getPile("heavenly_army"):isEmpty() then
		return true
	end
	if nextAlive:hasShownSkill("luoshen") then
		local valid = card:isRed()
		return (self:isFriend(nextAlive) == valid)
	end
	if nextAlive:hasShownSkill("qianxi") then
		local valid = card:isRed()
		return (self:isFriend(nextAlive) ~= valid)
	end
	if nextAlive:hasShownSkills("yinghun_sunjian|yinghun_sunce") and nextAlive:isWounded() then
		return not self:isFriend(nextAlive)
	end
	if hasLightning then
		local valid = (card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9)
		return (self:isFriend(nextAlive) == valid)
	end
	if hasIndulgence then
		local valid = (card:getSuit() ~= sgs.Card_Heart)
		return (self:isFriend(nextAlive) == valid)
	end
	if hasSupplyShortage then
		local valid = (card:getSuit() ~= sgs.Card_Club)
		return (self:isFriend(nextAlive) == valid)
	end

	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasShownSkill("luoshen")
		and not nextAlive:hasShownSkills("tuxi|TuxiLB") and not (nextAlive:hasShownSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		if self:isValuableCard(card, nextAlive) then
			return false
		end
		if card:isKindOf("Jink") and getCardsNum("Jink", nextAlive, self.player) < 1 then
			return false
		end
		if card:isKindOf("Nullification") and getCardsNum("Nullification", nextAlive, self.player) < 1 then
			return false
		end
		if card:isKindOf("Slash") and self:hasCrossbowEffect(nextAlive) then
			return false
		end
		--for _, skill in ipairs(sgs.getPlayerSkillList(nextAlive)) do  --因为这是local function
		for _, skill in ipairs(sgs.QList2Table(nextAlive:getVisibleSkillList(true))) do
			if sgs.ai_cardneed[skill:objectName()] and sgs.ai_cardneed[skill:objectName()](nextAlive, card, self) then return false end
		end
	end

	local trash = card:isKindOf("Disaster") or card:isKindOf("AmazingGrace") or card:isKindOf("GodSalvation") or card:isKindOf("AllianceFeast")
	if (trash or (card:isKindOf("ThreatenEmperor") and not card:isAvailable(nextAlive))) and self:isEnemy(nextAlive) then return false end
	return true
end

----------------------------------------------------------------------------------------------------

-- SHU 006 马超

-- 铁骑
sgs.ai_skill_invoke.TieqiLB = function(self, data)  --todo：解决铁骑装白银的目标导致弃白银的问题
	if not self:willShowForAttack() then return false end

	local target = data:toPlayer()
	if self:isFriend(target) then return false end

	if target:hasShownSkill("Xiansi") and self:isEnemy(target) and target:getPile("counter"):length() >= 2 and self:hasCrossbowEffect() then
		local lord = self.room:getLord(self.player:getKingdom())
		if lord and lord:hasLordSkill("shouyue") and lord:hasShownGeneral1() then
			return false
		end
	end
	return true
end
sgs.ai_skill_choice.TieqiLB = sgs.ai_skill_choice.Yijue
sgs.ai_skill_cardask["@TieqiLB-discard"] = function(self, data, pattern)
	local suit = pattern:split("|")[2]
	local use = data:toCardUse()
	if self:needToThrowArmor() and self.player:getArmor():getSuitString() == suit then return "$" .. self.player:getArmor():getEffectiveId() end
	if not self:slashIsEffective(use.card, self.player, use.from)
		or (not self:hasHeavySlashDamage(use.from, use.card, self.player)
			and (self:getDamagedEffects(self.player, use.from, true) or self:needToLoseHp(self.player, use.from, true)) and not self.player:getHp() <= 1) then return "." end
	if not self:hasHeavySlashDamage(use.from, use.card, self.player) and self:getCardsNum("Peach") > 0 then return "." end
	if self:getCardsNum("Jink") == 0 or not sgs.isJinkAvailable(use.from, self.player, use.card, true) then return "." end
	
	local equip_index = { 3, 0, 2, 4, 1 }
	if self.player:hasSkills(sgs.lose_equip_skill) then
		for _, i in ipairs(equip_index) do
			if i == 4 then break end
			if self.player:getEquip(i) and self.player:getEquip(i):getSuitString() == suit then return "$" .. self.player:getEquip(i):getEffectiveId() end
		end
	end

	local jiangqin = self.room:findPlayerBySkillName("niaoxiang")
	local need_double_jink = use.from:hasShownSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu")
							--or (use.from:hasSkill("roulin") and self.player:isFemale())
							--or (self.player:hasSkill("roulin") and use.from:isFemale())
							or (jiangqin and jiangqin:inSiegeRelation(jiangqin, player))

	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:getSuitString() ~= suit or (not self:isWeak() and (self:getKeepValue(card) > 8 or self:isValuableCard(card)))
			or (isCard("Jink", card, self.player) and self:getCardsNum("Jink") - 1 < (need_double_jink and 2 or 1)) then continue end
		return "$" .. card:getEffectiveId()
	end

	for _, i in ipairs(equip_index) do
		if self.player:getEquip(i) and self.player:getEquip(i):getSuitString() == suit then
			if not (i == 1 and self:evaluateArmor() > 3)
				and not (i == 4 and self.player:getTreasure():isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() >= 3) then
				return "$" .. self.player:getEquip(i):getEffectiveId()
			end
		end
	end
end
sgs.ai_choicemade_filter.skillInvoke.TieqiLB = function(self, player, promptlist)
	if promptlist[#promptlist] == "yes" then
		local target = findPlayerByObjectName(self.room, promptlist[#promptlist - 1])
		if target then sgs.updateIntention(player, target, 50) end
	end
end

----------------------------------------------------------------------------------------------------

-- SHU 017 徐庶

-- 诛害
sgs.ai_skill_cardask["@Zhuhai-slash"] = function(self, data, pattern, target, target2)
	if not self:willShowForAttack() then return "." end
	
	local slashes = {}
	local prioritize_real_slash = false
	if target2:hasShownSkill("Xiansi") and target2:getPile("counter"):length() > 1 then  --陷嗣杀不会出现在getCards中
		local ints = sgs.QList2Table(target2:getPile("counter"))
		local a, b = ints[1], ints[2]
		if a and b then
			local xiansi_slash = sgs.Card_Parse("#XiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&->" .. target2:objectName())
			if xiansi_slash then
				table.insert(slashes, xiansi_slash)
				if (self:needKongcheng() and self.player:getHandcardNum() == 1 and isCard("Slash", self.player:getHandcards():first(), self.player))
					or self.player:hasSkill("Yajiao") then
					prioritize_real_slash = true
				end
			end
		end
	end
	table.insertTable(slashes, self:getCards("Slash"))
	
	for _, slash in ipairs(slashes) do
		if not self.player:canSlash(target2, slash, false) then continue end
		--抄了很多useCardSlash
		if self:isFriend(target2) and self:isPriorFriendOfSlash(target2, slash)
			and self:slashIsEffective(slash, target2) and not self:slashProhibit(slash, target2) then
			if slash:objectName() == "XiansiSlashCard" and prioritize_real_slash then continue end
			return slash:toString()
		end

		local canliuli = false
		for _, friend in ipairs(self.friends_noself) do
			if self:canLiuli(target2, friend) and self:slashIsEffective(slash, friend) and friend:getHp() < 3 then canliuli = true end
		end
		local nature = sgs.DamageStruct_Normal
		if slash:isKindOf("FireSlash") then nature = sgs.DamageStruct_Fire
		elseif slash:isKindOf("ThunderSlash") then nature = sgs.DamageStruct_Thunder end
		if self:isEnemy(target2) and self:slashIsEffective(slash, target2) and not self:slashProhibit(slash, target2) 
			and self:canAttack(target2, self.player, nature)
			and not canliuli and not self:hasQiuyuanEffect(self.player, target2) and not self:getDamagedEffects(target2, self.player, true)
			and not self:findLeijiTarget(target2, 50, self.player) then
			if slash:objectName() == "XiansiSlashCard" and prioritize_real_slash then continue end
			return slash:toString()
		end
		
		if self:isFriend(target2) and self:slashIsEffective(slash, target2) and not self:hasHeavySlashDamage(self.player, slash, target2)
			and (self:getDamagedEffects(target2, self.player) or self:needToLoseHp(target2, self.player, true, true)) then
			if slash:objectName() == "XiansiSlashCard" and prioritize_real_slash then continue end
			return slash:toString()
		end
		
		if slash:objectName() == "XiansiSlashCard" and self:isFriend(target2) and (not self:slashIsEffective(slash, target2) or target2:hasShownSkill("xiangle")) then
			return slash:toString()
		end
	end
	return "."
end
sgs.ai_cardneed.Zhuhai = function(to, card, self)
	return isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0
end
sgs.Zhuhai_keep_value = {
	FireSlash       = 4.6,
	Slash           = 4.4,
	ThunderSlash    = 4.5,
}

-- 荐言
local jianyan_skill = {}
jianyan_skill.name = "Jianyan"
table.insert(sgs.ai_skills, jianyan_skill)
jianyan_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() and not self:willShowForDefence() then return false end
	if not self.player:hasUsed("#JianyanCard") then return sgs.Card_Parse("#JianyanCard:.:&Jianyan") end
end
sgs.ai_skill_use_func["#JianyanCard"] = function(card, use, self)
	self.jianyan_choice = nil
	self.jianyan_friend = nil
	self.jianyan_enemy = nil
	sgs.ai_use_priority.JianyanCard = 9.5
	self:sort(self.friends)
	local use_card
	for _, friend in ipairs(self.friends) do
		if friend:isMale() --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then
			if self:isWeak(friend) then self.jianyan_choice = "basic" end
			use_card = true
		end
	end
	if use_card then
		use.card = card
		return
	end

	sgs.ai_use_priority.JianyanCard = 0.5
	for _, enemy in ipairs(self.enemies) do
		if enemy:isMale() --[[and not hasManjuanEffect(enemy)]] and self:needKongcheng(enemy, true) then
			self.jianyan_choice = "equip"
			self.jianyan_enemy = enemy
			use.card = card
			return
		end
	end
end
sgs.ai_use_priority.JianyanCard = 9.5
sgs.ai_skill_choice.Jianyan = function(self, choices)		--对特殊卡牌有需求的，是针对杀/装备/锦囊/颜色的加到InitialTables，否则加到这里
	if self.jianyan_choice then return self.jianyan_choice end
	
	local need_trick = sgs.need_trick_skill
	local need_weapon = sgs.need_weapon_skill
	local need_equip = sgs.lose_equip_skill .. "|" .. sgs.need_equip_skill .. "|duanliang"
	local need_slash = string.gsub(sgs.need_slash_skill, "|Zhuhai", "")  --先去掉诛害，否则会一直给自己观基本牌
	local need_basic = need_slash .. "|duanliang|xiaoguo|longdan|longdan_ZhaoYun_LB|leiji"
	if self.player:isMale() and self.player:hasSkill("Zhuhai") and self:getCardsNum("Slash") == 0 then need_basic = need_basic .. "|Zhuhai" end
	local need_red = sgs.need_red_cards_skill .. "|guose|GuoseLB|jiang"
	local need_black = sgs.need_black_cards_skill .. "|lianhuan|Chuli"
	
	self:sort(self.friends)
	local male_friends = {}
	for _, friend in ipairs(self.friends) do
		if friend:isMale() --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then
			table.insert(male_friends, friend)
		end
	end
	
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_trick) then
			self.jianyan_friend = friend
			return "trick"
		end
	end
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_weapon) and not friend:getWeapon() then
			self.jianyan_friend = friend
			return "equip"
		end
	end
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_equip) then
			self.jianyan_friend = friend
			return "equip"
		end
	end
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_red) then
			self.jianyan_friend = friend
			return "no_suit_red"
		end
	end
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_basic) then
			self.jianyan_friend = friend
			return "basic"
		end
	end
	for _, friend in ipairs(male_friends) do
		if friend:hasShownSkills(need_black) then
			self.jianyan_friend = friend
			return "no_suit_black"
		end
	end
	
	for _, friend in ipairs(male_friends) do
		if friend:getHandcardNum() < 3 and friend:getEquips():length() < 2 then return "equip" end
	end
	local rand = math.random(0, 100)
	if rand > 60 then return "trick"
	elseif rand > 35 then return "no_suit_red"
	elseif rand > 10 then return "equip"
	elseif rand > 2 then return "basic"
	else return "no_suit_black"
	end
end
sgs.ai_skill_playerchosen.Jianyan = function(self, targets)
	local id = self.player:getMark("Jianyan")
	local card = sgs.Sanguosha:getCard(id)
	local cards = { card }
	if self.jianyan_enemy and not self:isValuableCard(card, self.jianyan_enemy) then return self.jianyan_enemy end
	--注意：jianyan_enemy是强制性的，而jianyan_friend只是作为参考（也就是说友方CardNeedPlayer优先于jianyan_friend）
	local c, friend = self:getCardNeedPlayer(cards, self.friends)
	if friend and self:isFriend(friend) then return friend end  --加了个isFriend防止给敌人牌（？）
	
	if self.jianyan_friend then return self.jianyan_friend end

	self:sort(self.friends)
	for _, friend in ipairs(self.friends) do
		if friend:isMale() and self:isValuableCard(card, friend) --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then return friend end
	end
	for _, friend in ipairs(self.friends) do
		if friend:isMale() and self:isWeak(friend) --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then return friend end
	end
	
	local trash = card:isKindOf("EquipCard") or card:isKindOf("Disaster") or card:isKindOf("GodSalvation") or card:isKindOf("AmazingGrace") or card:isKindOf("Slash") or card:isKindOf("AllianceFeast") or card:isKindOf("ThreatenEmperor")
	if trash then
		for _, enemy in ipairs(self.enemies) do
			if enemy:isMale() and enemy:getPhase() > sgs.Player_Play and self:needKongcheng(enemy, true) and not (card:isKindOf("ThreatenEmperor") and card:isAvailable(enemy)) --[[and not hasManjuanEffect(enemy)]] then return enemy end
		end
	end
	for _, friend in ipairs(self.friends) do
		if friend:isMale() --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then return friend end
	end
	for _, target in sgs.qlist(targets) do
		if target:isMale() then return target end
	end
end

-- 潜心
sgs.ai_skill_invoke.Qianxin = function(self, data)  --基本抄旧胆守
	if not self:willShowForAttack() then return false end
	local damage = data:toDamage()
	local phase = self.player:getPhase()
	if phase < sgs.Player_Play then
		return self:willSkipPlayPhase()
	elseif phase == sgs.Player_Play then
		--[[if self:getCardsNum("Slash") >= 1 and self:slashIsAvailable() then
			return false
		end]]
		
		--懒办法判断是否还要使用牌，照抄activate（可能会有bug），不直接引用activate是防止聊天
		local willUseCards = false
		local use = {to = sgs.SPlayerList(), isDummy = true}
		local toUse = self:getTurnUse()
		for _, card in ipairs(toUse) do
			if not self.player:isCardLimited(card, card:getHandlingMethod())
				or (card:canRecast() and not self.player:isCardLimited(card, sgs.Card_MethodRecast)) then
				if card:getTypeId() == sgs.Card_TypeSkill then continue end
				local subcard_ids = sgs.IntList()
				if card:isVirtualCard() then
					subcard_ids = card:getSubcards()
				else
					subcard_ids:append(card:getEffectiveId())
				end
				local need_handcard = false
				for _,id in sgs.qlist(self.player:handCards()) do
					if subcard_ids:contains(id) then need_handcard = true break end
				end
				if not need_handcard then continue end
				
				local type = card:getTypeId()

				self["use" .. sgs.ai_type_name[type + 1] .. "Card"](self, card, use)

				--if use:isValid(nil) then
				if use.card and not use.card:isKindOf("Slash") and not (use.card:canRecast() and use.to and use.to:isEmpty()) then  --use:isValid里现在只判断card != NULL了，而且上文use是table不是CardUseStruct
					willUseCards = true
					break
				end
				if use.card and use.card:isKindOf("Slash") and not (not use.to or use.to:isEmpty()) then
					willUseCards = true
					break
				end
			end
		end
		return not willUseCards
	elseif phase > sgs.Player_Play and phase ~= sgs.Player_NotActive then
		return true
	elseif phase == sgs.Player_NotActive then
		local current = self.room:getCurrent()
		if not current or not current:isAlive() or (current:getPhase() == sgs.Player_NotActive) then return true end
		if current:getPhase() > sgs.Player_Play then
			if self:isFriend(current) then return true end
			if current:hasShownSkill("ganglie") and self.player:getHandcardNum() == 0 and self.player:getHp() == 1 and self:getCardsNum("Peach") > 0 then return false end
			if current:hasShownSkill("GanglieLB_XiaHouDun_LB") and self.player:getHp() == 1 and self:getCardsNum("Peach") > 0 then return false end
			if current:hasShownSkills("fankui|FankuiLB|Guixin") and self.player:isNude() then return false end
			return true
		end
		--[[local threat = getCardsNum("Duel", current, self.player) + getCardsNum("AOE", current, self.player)
		if self:slashIsAvailable(current) and getCardsNum("Slash", current, self.player) > 0 then threat = threat + math.min(1, getCardsNum("Slash", current, self.player)) end
		if self:isFriend(current:getNextAlive()) then threat = threat + getCardsNum("BurningCamps", current, self.player) end
		return threat >= 1]]  --这是胆守的代码，不适用于潜心（胆守是为了防止当前回合角色造成伤害）
		local threat = 0
		local save_cards = self.player:getHp() <= 1 and (self:getCardsNum("Peach") + self:getCardsNum("Analeptic")) or 0
		if self:getCardsNum("Slash") > 0 or save_cards > 0 then
			threat = threat + getCardsNum("SavageAssault", current, self.player)
			if not self:isFriend(current) then threat = threat + getCardsNum("Duel", current, self.player) end
		end
		if self:getCardsNum("Jink") > 0 or save_cards > 0 then
			threat = threat + getCardsNum("ArcheryAttack", current, self.player)
			if not self:isFriend(current) and self:slashIsAvailable(current) and current:canSlash(self.player) and getCardsNum("Slash", current, self.player) > 0 then
				threat = threat + (self:hasCrossbowEffect(current) and getCardsNum("Slash", current, self.player) or 1)
			end
		end
		if not self:isFriend(current) and current:getNextAlive() and self:isFriend(current:getNextAlive()) and current:getNextAlive():getHp() <= 1 and (current:getNextAlive():objectName() == self.player:objectName() and save_cards or self:getCardsNum("Peach")) > 0 then
			threat = threat + getCardsNum("BurningCamps", current, self.player)
		end
		return threat < 1
	end
	return false
end

----------------------------------------------------------------------------------------------------

-- WU 002 甘宁

-- 奇袭
local qixi_skill = {}
qixi_skill.name = "qixi_GanNing_LB"
table.insert(sgs.ai_skills, qixi_skill)
qixi_skill.getTurnUseCard = function(self, inclusive)

	local cards = {}
	if self.player:hasSkill("xiaoji") and not self.player:getEquips():isEmpty() then
		for _, c in sgs.qlist(self.player:getEquips()) do
			if c:isBlack() then table.insert(cards, c) end
		end
		if #cards > 0 then
			self:sortByUseValue(cards, true)
			local black_card = cards[1]
			local suit = black_card:getSuitString()
			local number = black_card:getNumberString()
			local card_id = black_card:getEffectiveId()
			local card_str = ("dismantlement:qixi_GanNing_LB[%s:%s]=%d%s"):format(suit, number, card_id, "&qixi_GanNing_LB")
			local dismantlement = sgs.Card_Parse(card_str)

			assert(dismantlement)

			return dismantlement
		end
	end

	cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards, true)

	local has_weapon = false
	local black_card
	for _, card in ipairs(cards) do
		if card:isKindOf("Weapon") and card:isBlack() then has_weapon = true end
	end

	for _, card in ipairs(cards) do
		if card:isBlack() and ((self:getUseValue(card) < sgs.ai_use_value.Dismantlement) or inclusive or self:getOverflow() > 0) then
			local shouldUse = true

			if card:isKindOf("Armor") then
				if not self.player:getArmor() then shouldUse = false
				elseif self.player:hasEquip(card) and not self:needToThrowArmor() then shouldUse = false
				end
			elseif card:isKindOf("Weapon") then
				if not self.player:getWeapon() then shouldUse = false
				elseif self.player:hasEquip(card) and not has_weapon then shouldUse = false
				end
			elseif card:isKindOf("Slash") then
				local dummy_use = {isDummy = true}
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			elseif card:isKindOf("TrickCard") and self:getUseValue(card) > sgs.ai_use_value.Dismantlement then
				local dummy_use = {isDummy = true}
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end

			if not self:willShowForAttack() then
				shouldUse = false
			end

			if shouldUse then
				black_card = card
				break
			end

		end
	end

	if black_card then
		local suit = black_card:getSuitString()
		local number = black_card:getNumberString()
		local card_id = black_card:getEffectiveId()
		local card_str = ("dismantlement:qixi_GanNing_LB[%s:%s]=%d%s"):format(suit, number, card_id, "&qixi_GanNing_LB")
		local dismantlement = sgs.Card_Parse(card_str)

		assert(dismantlement)

		return dismantlement
	end
end
sgs.qixi_GanNing_LB_suit_value = sgs.qixi_suit_value
sgs.ai_suit_priority.qixi_GanNing_LB = sgs.ai_suit_priority.qixi
sgs.ai_cardneed.qixi_GanNing_LB = sgs.ai_cardneed.qixi

-- 奋威
-- （尚未处理因奋威威慑而不放/放心放A的问题，不过那个实在不好弄）
function SmartAI:getAoeValueTo(card, to, from, damageNum)  --抄smart-ai，因为是local function
	--（感觉from替换不彻底可能会有很多问题……不过不管了）
	local value, sj_num = 0, 0
	if card:isKindOf("ArcheryAttack") then sj_num = getCardsNum("Jink", to, from) end
	if card:isKindOf("SavageAssault") then sj_num = getCardsNum("Slash", to, from) end

	--下面的变量是从SmartAI:getAoeValue抄来的，有些实际并无卵用
	local attacker = from
	local good, bad, isEffective_F, isEffective_E = 0, 0, 0, 0
	damageNum = damageNum or 1
	local current = self.room:getCurrent()
	local wansha = current:hasShownSkill("wansha")
	local peach_num = self:getCardsNum("Peach")
	local null_num = self:getCardsNum("Nullification")
	local punish
	local enemies, kills = 0, 0
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self.player:isFriendWith(p) and self:evaluateKingdom(p) ~= self.player:getKingdom() then enemies = enemies + 1 end
		if self:isFriend(p) then
			if not wansha then peach_num = peach_num + getCardsNum("Peach", p, self.player) end
			null_num = null_num + getCardsNum("Nullification", p, self.player)
		else
			null_num = null_num - getCardsNum("Nullification", p, self.player)
		end
	end
	--[[if card:isVirtualCard() and card:subcardsLength() > 0 then
		for _, subcardid in sgs.qlist(card:getSubcards()) do
			local subcard = sgs.Sanguosha:getCard(subcardid)
			if isCard("Peach", subcard, self.player) then peach_num = peach_num - 1 end
			if isCard("Nullification", subcard, self.player) then null_num = null_num - 1 end
		end
	end]]  --此时已经使用此牌
	
	local zhiman = self.player:hasSkills("Zhiman_MaSu|Zhiman_GuanSuo")
	local zhimanprevent
	if card:isKindOf("SavageAssault") then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		attacker = menghuo or attacker
		if self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhiman = true end  --似乎源码忘记了ShownSkill
		if not self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhimanprevent = true end  --源码忘记判断menghuo是否存在
	end
	
	if self:aoeIsEffective(card, to, from) then
		local sameKingdom
		if self:isFriend(to) then
			isEffective_F = isEffective_F + 1
			if from:isFriendWith(to) or self:evaluateKingdom(to) == from:getKingdom() then sameKingdom = true end
		else
			isEffective_E = isEffective_E + 1
		end

		local jink = sgs.cloneCard("jink")
		local slash = sgs.cloneCard("slash")
		local isLimited
		if card:isKindOf("ArcheryAttack") and to:isCardLimited(jink, sgs.Card_MethodResponse) then isLimited = true
		elseif card:isKindOf("SavageAssault") and to:isCardLimited(slash, sgs.Card_MethodResponse) then isLimited = true end
		if card:isKindOf("SavageAssault") and sgs.card_lack[to:objectName()]["Slash"] == 1
			or card:isKindOf("ArcheryAttack") and sgs.card_lack[to:objectName()]["Jink"] == 1
			or sj_num < 1 or isLimited then
			--value = -20
			if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
				if self:isFriend(to) and not zhiman then value = -20 * damageNum end
				if not self:isFriend(to) and damageNum > 1 then value = value - 5 * damageNum end  --源码对敌人的万箭齐发不会给value带来任何变化
			elseif card:isKindOf("SavageAssault") then
				if self:isFriend(to) then
					if zhimanprevent then
						value = - 30
					elseif not zhiman then
						value = - 20 * damageNum
					end
				else
					if zhimanprevent and self:isFriend(to, attacker) then
						value = - 30
					else
						value = - 20 * damageNum
					end
				end
			end
		else
			--value = -10
			if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
				if self:isFriend(to) and not zhiman then value = -10 * damageNum end
				if not self:isFriend(to) and damageNum > 1 then value = value - 5 * damageNum end  --源码对敌人的万箭齐发不会给value带来任何变化
			elseif card:isKindOf("SavageAssault") then
				if self:isFriend(to) then
					if zhimanprevent then
						value = - 20
					elseif not zhiman then
						value = - 10 * damageNum
					end
				else
					if zhimanprevent and self:isFriend(to, attacker) then
						value = - 20
					else
						value = - 10 * damageNum
					end
				end
			end
		end
		-- value = value + math.min(50, to:getHp() * 10)

		if self:getDamagedEffects(to, from) and damageNum <= 1 then value = value + 30 end
		if self:needToLoseHp(to, from) and damageNum <= 1 then value = value + 20 end

		if card:isKindOf("ArcheryAttack") then
			if to:hasShownSkills("leiji") and (sj_num >= 1 or self:hasEightDiagramEffect(to)) and self:findLeijiTarget(to, 50, from) then
				value = value + 20
				if self:hasSuit("spade", true, to) then value = value + 50
				else value = value + to:getHandcardNum() * 10
				end
			elseif self:hasEightDiagramEffect(to) then
				value = value + 5
				if self:getFinalRetrial(to) == 2 then
					value = value - 10
				elseif self:getFinalRetrial(to) == 1 then
					value = value + 10
				end
			end
		end

		if card:isKindOf("ArcheryAttack") and sj_num >= 1 then
			if to:hasShownSkill("xiaoguo") then value = value - 4 end
		elseif card:isKindOf("SavageAssault") and sj_num >= 1 then
			if to:hasShownSkill("xiaoguo") then value = value - 4 end
		end

		if to:getHp() <= damageNum and to:getHp() >= 1 then
			local peach_needed = damageNum - to:getHp() + 1
			if sameKingdom then
				if null_num > 0 then null_num = null_num - 1
				elseif getCardsNum("Analeptic", to, self.player) > peach_needed - 1 then
				elseif not wansha and peach_num > peach_needed - 1 then peach_num = peach_num - peach_needed
				elseif wansha and (getCardsNum("Peach", to, self.player) > peach_needed - 1 or self:isFriend(current) and getCardsNum("Peach", to, self.player) > peach_needed - 1) then
				else
					if not punish then
						punish = true
						value = value - from:getCardCount(true) * 10
					end
					value = value - to:getCardCount(true) * 10
				end
			else
				kills = kills + 1
				if wansha and (sgs.card_lack[to:objectName()]["Peach"] == 1 or getCardsNum("Peach", to, self.player) <= peach_needed - 1) then
					value = value - sgs.getReward(to) * 10
				end
			end
		end

		if not sgs.isAnjiang(to) and to:isLord() then value = value - self.room:getLieges(to:getKingdom(), to):length() * 5 end

		if to:getHp() > 1 and to:hasShownSkills("jianxiong|JianxiongLB") and damageNum <= 1 then
			value = value + ((card:isVirtualCard() and card:subcardsLength() * 10) or 10)
		end
		if to:getHp() > 1 and to:hasShownSkills("Kuangbao+Shenfen") and damageNum <= 1 then
			value = value + math.min(15, to:getMark("@wrath") * 3)
		end

	else
		value = 0
		if to:hasShownSkill("juxiang") and not card:isVirtualCard() then value = value + 10 end
	end

	return value
end
local function getFenweiValue(self, who, card, from)
	if not self:hasTrickEffective(card, who, from) then return 0 end
	if card:isKindOf("AOE") and not card:isKindOf("AllianceFeast") and not card:isKindOf("BurningCamps") then
		if not self:isFriend(who) then return 0 end
		local damageNum = card:hasFlag("HanyongAddDamage") and 2 or 1
		local value = self:getAoeValueTo(card, who, from, damageNum)
		--if value < 0 then return -value / 30 end
		if value < 0 then return -value / 10 end   --国战的getAoeValueTo数值比身份小多了
	elseif card:isKindOf("GodSalvation") then
		if not self:isEnemy(who) or not who:isWounded() --[[or who:getHp() >= getBestHp(who)]] then return 0 end  --getBestHp在国战未定义
		if self:isWeak(who) then return 1.2 end
		if who:hasShownSkills(sgs.masochism_skill) or who:hasShownSkill("shushen") then return 1.0 end
		return 0.9
	elseif card:isKindOf("AmazingGrace") then
		if not self:isEnemy(who) or (self:evaluateKingdom(who) == "unknown") --[[or hasManjuanEffect(who)]] then return 0 end
		if self:needKongcheng(who, keep) then return 0 end  --破空城
		local v = 1.2
		local p = self.room:getCurrent()
		while p:objectName() ~= who:objectName() do
			v = v * 0.9
			p = p:getNextAlive()
		end
		return v
	elseif card:isKindOf("BurningCamps") then
		if not self:isFriend(who) then return 0 end
		if self:isWeak(who) then return 1.5 end
		if who:hasShownSkills(sgs.masochism_skill) or self:needToLoseHp(who) then return 1.0 end
		return 1.2
	elseif card:isKindOf("Snatch") or card:isKindOf("Dismantlement") or card:isKindOf("Drowning") then  --单体锦囊双目标（如巧说），处理尚不完善
		if not self:isFriend(who) then return 0 end
		if self:isFriend(who, from) then return 0 end
		if self:isWeak(who) then return 1.2 end
		return 0.9
	end
	return 0
end
sgs.ai_skill_playerchosen.Fenwei = function(self, targets)
	local targetslist = sgs.QList2Table(targets)
	--local liuxie = self.room:findPlayerBySkillName("huangen")
	--if liuxie and self:isFriend(liuxie) and not self:isWeak(liuxie) then return "." end

	local card = self.player:getTag("Fenwei"):toCardUse().card
	local from = self.player:getTag("Fenwei"):toCardUse().from

	self:sort(targetslist, "defense")
	local target_table = {}
	local value = 0
	local isDanger = false
	for _, player in ipairs(targetslist) do
		if not (--[[player:hasSkill("danlao") or ]](player:hasShownSkills("jianxiong|JianxiongLB") and not self:isWeak(player))) then
			local val = getFenweiValue(self, player, card, from)
			if val > 0 then
				value = value + val
				table.insert(target_table, player)
				if self:isFriend(player) and self:isWeak(player) and (card:isKindOf("SavageAssault") or card:isKindOf("ArcheryAttack") or card:isKindOf("BurningCamps")) then isDanger = true end
			end
		end
	end
	--if #target_table == 0 or value / (self.room:alivePlayerCount() - 1) < 0.55 then return "." end
	local friendcount = 0
	for _,p in sgs.qlist(self.room:getAllPlayers()) do
		if self:isFriendWith(p) or (p:objectName() == self.player:objectName()) then friendcount = friendcount + 1
		elseif self:isFriend(p) then friendcount = friendcount + 0.5
		elseif not self:isEnemy(p) then friendcount = friendcount + 0.1 end
	end
	if isDanger then friendcount = friendcount * 0.8 end
	if #target_table == 0 or value / (self.room:alivePlayerCount() - 1) < friendcount / (self.room:alivePlayerCount() - 1) then return "." end  --国战队友少所以相对宽松一点
	return target_table
end
sgs.ai_choicemade_filter.playerChosen.Fenwei = function(self, from, promptlist)  --ai_playerchosen_intention只对选择一人有效
	if from:objectName() == promptlist[3] then return end
	local reason = string.gsub(promptlist[2], "%-", "_")
	local tos = promptlist[3]:split("+")
	
	local cardx = self.player:getTag("Fenwei"):toCardUse().card
	local from = self.player:getTag("Fenwei"):toCardUse().from
	if not cardx then return end
	local intention = (cardx:isKindOf("AOE") and -50 or 50)
	
	for _,to_str in pairs(tos) do
		to = findPlayerByObjectName(to_str)
		if not to then continue end
		--if to:hasSkill("danlao") or not self:hasTrickEffective(cardx, to, from) then return end
		if cardx:isKindOf("GodSalvation") and not to:isWounded() then return end
		sgs.updateIntention(from, to, intention)
	end
end
--[[sgs.ai_playerchosen_intention.Fenwei = function(self, from, to)
	local cardx = self.player:getTag("Fenwei"):toCardUse().card
	local from = self.player:getTag("Fenwei"):toCardUse().from
	if not cardx then return end
	local intention = (cardx:isKindOf("AOE") and -50 or 50)
	--if to:hasSkill("danlao") or not self:hasTrickEffective(cardx, to, from) then return end
	if cardx:isKindOf("GodSalvation") and not to:isWounded() then return end
	sgs.updateIntention(from, to, intention)
end]]

----------------------------------------------------------------------------------------------------

-- WU 003 吕蒙

-- 克己
sgs.ai_skill_invoke.keji_LyuMeng_LB = sgs.ai_skill_invoke.keji

-- 攻心
local gongxin_skill = {}
gongxin_skill.name = "Gongxin_LyuMeng_LB"
table.insert(sgs.ai_skills,gongxin_skill)
gongxin_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:hasUsed("#GongxinLyuMeng_LBCard") then return end
	self.Gongxin_Use_Immediately = nil
	local gongxin_card = sgs.Card_Parse("#GongxinLyuMeng_LBCard:.:&Gongxin_LyuMeng_LB")
	assert(gongxin_card)
	return gongxin_card
end
sgs.ai_skill_use_func["#GongxinLyuMeng_LBCard"] = function(card,use,self)
	self:sort(self.enemies, "handcard")
	self.enemies = sgs.reverse(self.enemies)

	for _, enemy in ipairs(self.enemies) do
		if not enemy:isKongcheng() and self:objectiveLevel(enemy) > 0
			and (self:hasSuit("heart", false, enemy) or self:getKnownNum(enemy, self.player) ~= enemy:getHandcardNum()) then
			use.card = card
			if use.to then
				use.to:append(enemy)
			end
			return
		end
	end
end
sgs.ai_skill_askforag[""] = function(self, card_ids)  --注：吴国的出牌阶段摸牌技能都要加到这里；源码bug未能传入技能名，因此只能这样写（todo：下版本修复）
	local target = self.player:getTag("Gongxin_LyuMeng_LB"):toPlayer()  --界吕蒙和神吕蒙共享（因为这个函数不能定义第二遍）（todo：下版本拆分）
	local target2 = self.player:getTag("Gongxin_ShenLyuMeng"):toPlayer()
	if not target and not target2 then  --与尚义冲突
		return nil
	end
	target = target or target2
	if self:isFriend(target) then return -1 end
	self.gongxinchoice = nil
	self.Gongxin_Use_Immediately = nil
	local nextAlive = self.player
	repeat
		nextAlive = nextAlive:getNextAlive()
	until nextAlive:faceUp() or nextAlive:hasShownSkills("Jiewei|Jushou15") or (nextAlive:objectName() == self.player:objectName())
	local threaten_emperor = self:getCard("ThreatenEmperor")
	if threaten_emperor and threaten_emperor:isAvailable(self.player) and self.player:getCardCount(true) >= 2 and self:hasTrickEffective(threaten_emperor, self.player, self.player) and self.player:faceUp() then  --抄SmartAI:useCardThreatenEmperor
		nextAlive = self.player
	end

	local peach, ex_nihilo, jink, nullification, slash, befriendattack, pindian, special
	local valuable
	for _, id in ipairs(card_ids) do
		local card = sgs.Sanguosha:getCard(id)
		if card:isKindOf("Peach") then peach = id end
		if card:isKindOf("ExNihilo") then ex_nihilo = id end
		if card:isKindOf("Jink") then jink = id end
		if card:isKindOf("Nullification") then nullification = id end
		if card:isKindOf("Slash") then slash = id end
		if card:isKindOf("BefriendAttacking") then befriendattack = id end
		if card:isKindOf("EquipCard") and (self.player:hasSkills(sgs.lose_equip_skill) or self.player:hasSkills(sgs.need_equip_skill)) then special = id end  --special用于针对自己的特定技能
		if card:getNumber() > 10 and self.player:hasSkills(sgs.pindian_skill) then special = id end
		if card:getNumber() > 10 and target:hasSkills(sgs.pindian_skill) then pindian = id end
	end
	valuable = peach or befriendattack or ex_nihilo or jink or nullification or slash or special or pindian or card_ids[1]
	local card = sgs.Sanguosha:getCard(valuable)
	if self:isEnemy(target) and target:hasShownSkill("tuntian") then
		local zhangjiao = sgs.findPlayerByShownSkillName("guidao")
		if zhangjiao and self:isFriend(zhangjiao, target) and self:canRetrial(zhangjiao, target) and self:isValuableCard(card, zhangjiao) then
			self.gongxinchoice = "discard"
		else
			self.gongxinchoice = target:hasShownSkill("tiandu") and "discard" or "put"
		end
		return valuable
	end

	--根据国战卡牌改了以下代码
	local willUseExNihilo, willRecast, willUseAwaitExhausted, willUseLureTiger
	local recastCard
	if self:getCardsNum("ExNihilo") > 0 then
		local ex_nihilo = self:getCard("ExNihilo")
		if ex_nihilo then
			local dummy_use = { isDummy = true }
			self:useTrickCard(ex_nihilo, dummy_use)
			if dummy_use.card then willUseExNihilo = true end
		end
	elseif self:getCardsNum("IronChain") > 0 then
		local iron_chain = self:getCard("IronChain")
		if iron_chain then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(iron_chain, dummy_use)
			if dummy_use.card and dummy_use.to:isEmpty() then 
				willRecast = true
				recastCard = iron_chain
			end
		end
	elseif self:getCardsNum("KnownBoth") > 0 then
		local known_both = self:getCard("KnownBoth")
		if known_both then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(known_both, dummy_use)
			if dummy_use.card and dummy_use.to:isEmpty() then 
				willRecast = true
				recastCard = known_both
			end
		end
	elseif self:getCardsNum("FightTogether") > 0 then
		local fight_together = self:getCard("FightTogether")
		if fight_together then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(fight_together, dummy_use)
			if dummy_use.card and self.FightTogether_choice == "recast" then 
				willRecast = true
				recastCard = fight_together
			end
		end
	elseif self:getCardsNum("LureTiger") > 0 then
		local lure_tiger = self:getCard("LureTiger")
		if lure_tiger then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(lure_tiger, dummy_use)
			if dummy_use.card and not dummy_use.to:isEmpty() then willUseLureTiger = true end
		end
	elseif self:getCardsNum("AwaitExhausted") > 0 then
		local await_exhausted = self:getCard("AwaitExhausted")
		if await_exhausted then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(await_exhausted, dummy_use)
			if dummy_use.card and not dummy_use.to:isEmpty() then willUseAwaitExhausted = true end
		end
	else
		local transfer = sgs.Card_Parse("@TransferCard=.")
		if transfer then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useSkillCard(transfer, dummy_use)
			if dummy_use.card and not dummy_use.to:isEmpty() then 
				willRecast = true
				recastCard = dummy_use.card
			end
		end
	end
	willUseDrawCard = willUseExNihilo or willRecast or willUseAwaitExhausted or willUseLureTiger
	
	local willUseSkill, skillCard, skillName
	if not willUseDrawCard then
		local draw_skills = {"zhiheng", "kurou", "zhijian", "KurouLB", "GuoseLB", "Anxu"}
		for _, skill in ipairs(sgs.ai_skills) do
			if self:hasSkill(skill) and table.contains(draw_skills, skill.name) then
				local skill_card = skill.getTurnUseCard(self, false)  --不知道第二个参数是干啥的
				if skill_card then
					local dummy_use = { isDummy = true }
					self:useSkillCard(skill_card, dummy_use)
					if dummy_use.card then 
						willUseSkill = true
						skillName = skill.name  --For record only
						skillCard = skill_card
						break
					end
				end
			end
		end
		if self:hasSkill("Zhiyan") then 
			willUseSkill = true
			skillName = "Zhiyan"
		end
		if self:hasSkill("xiaoji") then
			local cards = self.player:getHandcards()
			for _, id in sgs.qlist(self.player:getHandPile()) do
				cards:append(sgs.Sanguosha:getCard(id))
			end
			for _,cd in sgs.qlist(cards) do
				if cd:isKindOf("EquipCard") and cd:toEquipCard() and self.player:getEquip(cd:toEquipCard():location()) then
					willUseSkill = true
					skillName = "xiaoji"
					skillCard = cd
					break
				end
			end
		end
	end
	
	local willUseBefriendAttack
	local befriendAttackTarget
	if self:getCardsNum("BefriendAttacking") > 0 then
		local befriend_attack = self:getCard("BefriendAttacking")
		if befriend_attack then
			local dummy_use = { to = sgs.SPlayerList(), isDummy = true }
			self:useTrickCard(befriend_attack, dummy_use)
			if dummy_use.card and dummy_use.to:isEmpty() then 
				willUseBefriendAttack = not (willUseDrawCard or willUseSkill)
				befriendAttackTarget = dummy_use.to:first()
			end
		end
		
	end
	
	if willUseDrawCard or willUseSkill then
		self.gongxinchoice = nil
		local card = sgs.Sanguosha:getCard(valuable)
		if card:isKindOf("Peach") then
			self.gongxinchoice = "put"
		elseif card:isKindOf("TrickCard") or card:isKindOf("Indulgence") or card:isKindOf("SupplyShortage") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if dummy_use.card then
				self.gongxinchoice = "put"
			end
		elseif card:isKindOf("Jink") and self:getCardsNum("Jink") == 0 then
			self.gongxinchoice = "put"
		elseif card:isKindOf("Nullification") and (self:getCardsNum("Nullification") == 0 or (card:isKindOf("HegNullification") and self:getCardsNum("HegNullification") == 0)) then
			self.gongxinchoice = "put"
		elseif card:isKindOf("Slash") and self:slashIsAvailable() and not (willUseSkill and skillName == "Zhiyan") then
			local dummy_use = { isDummy = true }
			self:useBasicCard(card, dummy_use)
			if dummy_use.card then
				self.gongxinchoice = "put"
			end
		end
		if self.gongxinchoice and self.gongxinchoice == "put" then
			self.Gongxin_Use_Immediately = nil
			self.Gongxin_Use_Immediately = willUseExNihilo and "ExNihilo" 
											or (willRecast and recastCard:getClassName() 
											or (willUseAwaitExhausted and "AwaitExhausted"
											or (willUseLureTiger and "LureTiger")))
			if (self.Gongxin_Use_Immediately == nil) and willUseSkill and skillCard then
				self.Gongxin_Use_Immediately = (skillCard:isKindOf("LuaSkillCard")) and skillCard:objectName() or skillCard:getClassName()
			end
			return valuable
		else
			self.gongxinchoice = "discard"
			return valuable
		end
	end
	if willUseBefriendAttack and self:isFriend(befriendAttackTarget) then
		self.gongxinchoice = nil
		local card = sgs.Sanguosha:getCard(valuable)
		if card:isKindOf("Peach") or card:isKindOf("ExNihilo") then
			self.gongxinchoice = "put"
		elseif card:isKindOf("Jink") and getCardsNum("Jink", befriendAttackTarget) < 1 then
			self.gongxinchoice = "put"
		elseif card:isKindOf("Nullification") and getCardsNum("Nullification", befriendAttackTarget) < 1 then
			self.gongxinchoice = "put"
		elseif card:isKindOf("Slash") and self:hasCrossbowEffect(befriendAttackTarget) then
			self.gongxinchoice = "put"
		end
		if self.gongxinchoice and self.gongxinchoice == "put" then
			self.Gongxin_Use_Immediately = "BefriendAttacking"
			return valuable
		else
			self.gongxinchoice = "discard"
			return valuable
		end
	end
	
	--走到这一步就说明玩家不可能获得这张牌了，所以刷新valuable，注重的是对敌方而不是己方有价值的牌（就是去掉special）
	valuable = peach or befriendattack or ex_nihilo or jink or nullification or slash or pindian or card_ids[1]

	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() then
	--if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end

	if nextAlive:hasShownSkills("Jiewei|Jushou15") and not nextAlive:faceUp() and valuable then
		self.gongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if nextAlive:hasShownSkill("hongfa") and nextAlive:getPile("heavenly_army"):isEmpty() and valuable then
		self.gongxinchoice = "discard"
		return valuable
	end
	if nextAlive:hasShownSkill("luoshen") and valuable then  --源码是需要判断isEnemy才能进入分支，但是如果判定区有牌不是在帮队友大姨妈……
		self.gongxinchoice = self:isEnemy(nextAlive) and "put" or "discard"
		return valuable
	end
	if nextAlive:hasShownSkill("qianxi") and not sgs.findPlayerByShownSkillName("qingguo") and valuable then
		self.gongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if (nextAlive:hasShownSkills("yinghun_sunjian|yinghun_sunce") and nextAlive:isWounded()) or (nextAlive:hasShownSkill("hunshang") and nextAlive:getHp() == 1) then
		self.gongxinchoice = self:isFriend(nextAlive) and "put" or "discard"
		return valuable
	end
	if target:hasShownSkill("hongyan") and hasLightning and self:isEnemy(nextAlive) and not (nextAlive:hasShownSkill("qiaobian") and nextAlive:getHandcardNum() > 0) then
		for _, id in ipairs(card_ids) do
			local card = sgs.Sanguosha:getEngineCard(id)
			if card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				self.gongxinchoice = "put"
				return id
			end
		end
	end
	if hasIndulgence and self:isFriend(nextAlive) then
		self.gongxinchoice = "put"
		return valuable
	end
	if hasSupplyShortage and self:isEnemy(nextAlive) and not (nextAlive:hasShownSkill("qiaobian") and nextAlive:getHandcardNum() > 0) and not (nextAlive:hasShownSkills("QianxunLB+Lianying") and nextAlive:getHandcardNum() > 0) then
		local enemy_null = 0
		for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if self:isFriend(p) then enemy_null = enemy_null - getCardsNum("Nullification", p) end
			if self:isEnemy(p) then enemy_null = enemy_null + getCardsNum("Nullification", p) end
		end
		enemy_null = enemy_null - self:getCardsNum("Nullification")
		if enemy_null < 0.8 then
			self.gongxinchoice = "put"
			return valuable
		end
	end

	if self:isFriend(nextAlive) and not self:willSkipDrawPhase(nextAlive) and not self:willSkipPlayPhase(nextAlive)
		and not nextAlive:hasShownSkills("luoshen|qianxi")
		and not nextAlive:hasShownSkill("tuxi") and not (nextAlive:hasShownSkill("qiaobian") and nextAlive:getHandcardNum() > 0)
		and not (nextAlive:hasShownSkill("hengzheng") and (nextAlive:isKongcheng() or nextAlive:getHp() == 1)) then
		if (peach and valuable == peach) or (ex_nihilo and valuable == ex_nihilo) then
			self.gongxinchoice = "put"
			return valuable
		end
		if jink and valuable == jink and getCardsNum("Jink", nextAlive) < 1 then
			self.gongxinchoice = "put"
			return valuable
		end
		if nullification and valuable == nullification and getCardsNum("Nullification", nextAlive) < 1 then
			self.gongxinchoice = "put"
			return valuable
		end
		if slash and valuable == slash and self:hasCrossbowEffect(nextAlive) then
			self.gongxinchoice = "put"
			return valuable
		end
	end

	local card = sgs.Sanguosha:getCard(valuable)
	local keep = false
	if card:isKindOf("Slash") or card:isKindOf("Jink")
		or card:isKindOf("EquipCard")
		or card:isKindOf("Disaster") or card:isKindOf("GlobalEffect") or card:isKindOf("Nullification")
		or target:isLocked(card) then
		keep = true
	end
	self.gongxinchoice = (target:objectName() == nextAlive:objectName() and keep) and "put" or "discard"
	return valuable
end
sgs.ai_skill_choice.Gongxin_LyuMeng_LB = function(self, choices)
	return self.gongxinchoice or "discard"
end
sgs.ai_use_value.GongxinLyuMeng_LBCard = 8.5
sgs.ai_use_priority.GongxinLyuMeng_LBCard = 11
sgs.ai_card_intention.GongxinLyuMeng_LBCard = 80

----------------------------------------------------------------------------------------------------

-- WU 004 黄盖

-- 苦肉
local function getKurouCard(self, not_slash)
	local card_id
	local hold_crossbow = (self:getCardsNum("Slash") > 1)
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local lightning = self:getCard("Lightning")
	local threaten_emperor = self:getCard("ThreatenEmperor")
	if threaten_emperor and (self.player:isLocked(threaten_emperor) or not threaten_emperor:isAvailable(self.player)) then
		threaten_emperor = nil
	end

	if self:needToThrowArmor() then
		card_id = self.player:getArmor():getId()
	elseif self.player:hasSkills(sgs.lose_equip_skill) and not self.player:getEquips():isEmpty() then
		local ecards = sgs.QList2Table(self.player:getEquips())
		self:sortByKeepValue(ecards)
		card_id = ecards[1]:getEffectiveId()
	elseif self.player:getHandcardNum() > self.player:getHp() then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace") or acard:isKindOf("ImperialOrder") or acard:isKindOf("AllianceFeast") or (threaten_emperor and acard:toString() == threaten_emperor:toString()))
					and not self:isValuableCard(acard) and not (acard:isKindOf("Crossbow") and hold_crossbow)
					and not (acard:isKindOf("Slash") and not_slash) then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	elseif not self.player:getEquips():isEmpty() then
		local player = self.player
		if player:getOffensiveHorse() then card_id = player:getOffensiveHorse():getId()
		elseif player:getWeapon() and self:evaluateWeapon(self.player:getWeapon()) < 3
				and not (player:getWeapon():isKindOf("Crossbow") and hold_crossbow) then card_id = player:getWeapon():getId()
		elseif player:getArmor() and self:evaluateArmor(self.player:getArmor()) < 2 then card_id = player:getArmor():getId()
		end
	end
	if not card_id then
		if lightning and not self:willUseLightning(lightning) then
			card_id = lightning:getEffectiveId()
		else
			for _, acard in ipairs(cards) do
				if (acard:isKindOf("BasicCard") or acard:isKindOf("EquipCard") or acard:isKindOf("AmazingGrace") or acard:isKindOf("ImperialOrder") or acard:isKindOf("AllianceFeast") or (threaten_emperor and acard:toString() == threaten_emperor:toString()))
					and not self:isValuableCard(acard) and not (acard:isKindOf("Crossbow") and hold_crossbow)
					and not (acard:isKindOf("Slash") and not_slash) then
					card_id = acard:getEffectiveId()
					break
				end
			end
		end
	end
	return card_id
end
local kurou_skill = {}
kurou_skill.name = "KurouLB"
table.insert(sgs.ai_skills, kurou_skill)
kurou_skill.getTurnUseCard = function(self, inclusive)
	if not self:willShowForAttack() then return nil end
	if self.player:hasUsed("#KurouLBCard") or not self.player:canDiscard(self.player, "he") or not self.player:hasSkill("Zhaxiang") or (self.player:getHp() <= 0)
		--[[or (self.player:getHp() == 2 and self.player:hasSkill("Chanyuan"))]] then return nil end
	if self.player:getMark("Global_TurnCount") < 2 and not self.player:hasShownOneGeneral() then return nil end
	
	sgs.ai_use_priority.KurouLBCard = 6.8
	--if ((self.player:getHp() > 3 and self.player:getLostHp() <= 1 and self:getOverflow(self.player, false) < 2) or self:getOverflow(self.player, false) < -1) then  --标黄盖的写法，不过感觉不太适合界黄盖
	if (self.player:getHp() > 3 and self:getOverflow(self.player, false) > 0) or (self:getOverflow(self.player, false) < -1) then
		local id = getKurouCard(self)
		if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
	end
	
	if self.player:hasSkill("jieyin") and not self.player:hasUsed("JieyinCard") and not self.player:isWounded() then
		local jiyou = self:getWoundedFriend(true)
		if jiyou then
			local id = getKurouCard(self)
			if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
		end
	end

	if (self.player:getHp() > 2 and self.player:getLostHp() <= 1 and self.player:hasSkills(sgs.lose_equip_skill) and self.player:getCards("e"):length() > 1) then
		local id = getKurouCard(self)
		if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
	end
	
	local red_slash = self:canZhaxiang(self.player, nil)

	local function can_kurou_with_cb(self)
		if self.player:getHp() > 1 then return true end
		local has_save = false
		local huatuo = self.room:findPlayerBySkillName("jijiu")
		local huatuoLB = self.room:findPlayerBySkillName("jijiu_HuaTuo_LB")
		if huatuo and self:isFriend(huatuo) then
			for _, equip in sgs.qlist(huatuo:getEquips()) do
				if equip:isRed() then has_save = true break end
			end
			if not has_save then has_save = (huatuo:getHandcardNum() > 3) end
		end
		if not has_save and huatuoLB and self:isFriend(huatuoLB) then
			for _, equip in sgs.qlist(huatuoLB:getEquips()) do
				if equip:isRed() then has_save = true break end
			end
			if not has_save then has_save = (huatuoLB:getHandcardNum() > 3) end
		end
		if has_save then return true end
		--local handang = self.room:findPlayerBySkillName("nosjiefan")
		--if handang and self:isFriend(handang) and getCardsNum("Slash", handang, self.player) >= 1 then return true end
		return false
	end

	local slash = sgs.Sanguosha:cloneCard("slash")
	if (self:hasCrossbowEffect() or self:getCardsNum("Crossbow") > 0) or self:getCardsNum("Slash") > 1 or red_slash then
		for _, enemy in ipairs(self.enemies) do
			if self.player:canSlash(enemy, slash, not red_slash) and self:slashIsEffective(slash, enemy)
				and sgs.isGoodTarget(enemy, self.enemies, self, true) and not self:slashProhibit(slash, enemy) and can_kurou_with_cb(self) then
				local id = getKurouCard(self, true)
				if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
			end
		end
	end

	if self.player:getHp() == 1 and self:getCardsNum("Analeptic") + self:getCardsNum("Peach") > 1 then
		local id = getKurouCard(self)
		if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
	end
	
	if type(self.kept) == "table" and #self.kept > 0 then
		local hcards = sgs.QList2Table(self.player:getHandcards())
		for _, c in ipairs(self.kept) do
			hcards = self:resetCards(hcards, c)
		end
		for _, c in ipairs(self.kept) do
			if isCard("Peach", c, self.player) or isCard("Analeptic", c, self.player) then
				sgs.ai_use_priority.KurouLBCard = 0
				local id = getKurouCard(self)
				if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
			end
		end
	end
	
	--Suicide by Kurou
	local nextplayer = self.player:getNextAlive()
	if self.player:getHp() == 1 and self:getCardsNum("Armor") == 0 and self:getCardsNum("Jink") == 0 and self:getKingdomCount() > 2 then
		local to_death = false
		if self:isFriend(nextplayer) then
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasShownSkill("xiaoguo") and not self:isFriend(p) and not p:isKongcheng() and self.player:getEquips():isEmpty() then
					to_death = true
					break
				end
			end
			if not to_death and not self:willSkipPlayPhase(nextplayer) then
				if nextplayer:hasShownSkill("jieyin") and self.player:isMale() then return end
				if nextplayer:hasShownSkill("qingnang") then return end
			end
		end
		if not self:isFriend(nextplayer) and (not self:willSkipPlayPhase(nextplayer) or nextplayer:hasShownSkill("shensu")) then
			to_death = true
		end
		if to_death then
			local caopi = sgs.findPlayerByShownSkillName("xingshang")
			if caopi and self:isEnemy(caopi) and self.player:getHandcardNum() > 3 then
				to_death = false
			end
			if #self.friends == 1 and #self.enemies == 1 and self.player:aliveCount() == 2 then to_death = false end
		end
		if to_death then
			self.player:setFlags("Kurou_toDie")
			sgs.ai_use_priority.KurouLBCard = 0
			local id = getKurouCard(self)
			if id then return sgs.Card_Parse("#KurouLBCard:" .. id .. ":&KurouLB") end
		end
	end
end
sgs.ai_skill_use_func["#KurouLBCard"] = function(card, use, self)
	use.card = card
end
sgs.ai_use_priority.KurouLBCard = 6.8

-- 诈降
local function hasRedSlash(self, player)
	player = player or self.player
	local cards = sgs.QList2Table(player:getHandcards())
	for _, id in sgs.qlist(player:getHandPile()) do
		table.insert(cards, sgs.Sanguosha:getCard(id))
	end
	for _, card in ipairs(cards) do
		if isCard("Slash", card, player) and card:isRed() then
			return true
		end
	end
	return false
end
function SmartAI:canZhaxiang(from, red_slash, slash)
	from = from or self.room:getCurrent()
	has_red_slash = red_slash or (slash and slash:isRed()) or (not slash and hasRedSlash(self, from))  --slash不为空时则为用此特定的杀判断
	if not from then return false end
	if slash then return has_red_slash and from:getMark("Zhaxiang") > 0 end
	
	if from:getMark("Zhaxiang") > 0 then return true end
	if (from:hasShownSkill("Zhaxiang") or (from:objectName() == self.player:objectName() and self.player:hasSkill("Zhaxiang"))) and from:getPhase() ~= sgs.Player_NotActive and has_red_slash then
		return self.player:getHp() >= 2 and self.player:canDiscard(self.player, "he")
	end
	return false
end
sgs.ai_skill_invoke.Zhaxiang = true
function sgs.ai_cardneed.Zhaxiang(to, card, self)
	return card:isKindOf("Slash") and (card:isRed() or getKnownCard(to, self.player, "Slash", false) == 0)
end
sgs.Zhaxiang_keep_value = {
	FireSlash       = 5.6,
	Slash           = 4.4,
	ThunderSlash    = 4.5,
}

----------------------------------------------------------------------------------------------------

-- WU 005 周瑜

-- 英姿
sgs.ai_skill_invoke.YingziLB = sgs.ai_skill_invoke.yingzi_zhouyu
sgs.ai_skill_invoke["#YingziLB_showmaxcards"] = function(self, data)
	if not self:willShowForDefence() then return false end
	if self.player:getMaxCards(sgs.Max) >= math.max(self.player:getMaxHp() + sgs.Sanguosha:correctMaxCards(self.player, false, sgs.Max), 0) then return false end
	return self:getOverflow() > 0
end

sgs.ai_skill_invoke.haoshi = function(self, data)
	self.haoshi_target = nil
	local extra = 0
	local draw_skills = { ["yingzi_zhouyu"] = 1, ["yingzi_sunce"] = 1, ["luoyi"] = -1, ["YingziLB"] = 1, ["Juejing"] = getJuejingLostHp(self.player) }
	for skill_name, n in ipairs(draw_skills) do
		if self.player:hasSkill(skill_name) then
			local skill = sgs.Sanguosha:getSkill(skill_name)
			if skill and skill:getFrequency() == sgs.Skill_Compulsory then
				extra = extra + n
			elseif self:askForSkillInvoke(skill_name, data) then
				extra = extra + n
			end
		end
	end
	if self.player:hasTreasure("JadeSeal") then
		extra = extra + 1
	end
	if self.player:getHandcardNum() + extra <= 1 then return true end
	if not self:willShowForDefence() and not self:willShowForAttack() then return false end

	local otherPlayers = sgs.QList2Table(self.room:getOtherPlayers(self.player))
	self:sort(otherPlayers, "handcard")
	local leastNum = otherPlayers[1]:getHandcardNum()

	self:sort(self.friends_noself)
	for _, friend in ipairs(self.friends_noself) do
		if friend:getHandcardNum() == leastNum and friend:isAlive() and self:isFriendWith(friend) then
			self.haoshi_target = friend
		end
	end
	if not self.haoshi_target then
		for _, friend in ipairs(self.friends_noself) do
			if friend:getHandcardNum() == leastNum and friend:isAlive() then
				self.haoshi_target = friend
			end
		end
	end
	if self.haoshi_target then return true end
	return false
end

-- 反间
function findKnownCard(player, from, class_name, viewas, flags, return_table)			--为反间寻找目标牌（来自原项目）
	if not player or (flags and type(flags) ~= "string") then global_room:writeToConsole(debug.traceback()) return 0 end
	flags = flags or "h"
	player = findPlayerByObjectName(player:objectName())
	if not player then global_room:writeToConsole(debug.traceback()) return 0 end
	local cards = player:getCards(flags)
	local suits = {["club"] = 1, ["spade"] = 1, ["diamond"] = 1, ["heart"] = 1}
	local known
	for _, card in sgs.qlist(cards) do
		if sgs.cardIsVisible(card, player, from) then
			if (viewas and isCard(class_name, card, player)) or card:isKindOf(class_name)
				or (suits[class_name] and card:getSuitString() == class_name)
				or (class_name == "red" and card:isRed()) or (class_name == "black" and card:isBlack()) then
				known = card
				break
			end
		end
	end
	if return_table then return known end
	return known
end
local fanjian_skill = {}
fanjian_skill.name = "FanjianLB"
table.insert(sgs.ai_skills, fanjian_skill)
fanjian_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return false end
	if self.player:isKongcheng() or self.player:hasUsed("#FanjianLBCard") then return nil end
	return sgs.Card_Parse("#FanjianLBCard:.:&FanjianLB")
end
sgs.ai_skill_use_func["#FanjianLBCard"] = function(card, use, self)  --todo：处理弘法和敌人的诈降
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards, true)
	self:sort(self.enemies, "defense")

	if self:getCardsNum("Slash") > 0 then
		local slash = self:getCard("Slash")
		local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardSlash(slash, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			sgs.ai_use_priority.FanjianLBCard = sgs.ai_use_priority.Slash + 0.15
			local target = dummy_use.to:first()
			if self:isEnemy(target) and sgs.card_lack[target:objectName()]["Jink"] ~= 1 and target:getMark("Yijue") == 0
				and not target:isKongcheng() and (self:getOverflow() > 0 or target:getHandcardNum() > 2)
				and not (self.player:hasSkill("liegong") and (target:getHandcardNum() >= self.player:getHp() or target:getHandcardNum() <= self.player:getAttackRange())) then
				--and not (self.player:hasShownSkill("kofliegong") and target:getHandcardNum() >= self.player:getHp()) then
				if target:hasShownSkill("qingguo") then
					for _, card in ipairs(cards) do
						if self:getUseValue(card) < 6 and card:isBlack() then
							use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
							if use.to then use.to:append(target) end
							return
						end
					end
				end
				--以下部分代码来自原项目
				if (target:getArmor() and target:getArmor():isKindOf("EightDiagram"))										--搞八卦盾
					or (target:getTreasure() and target:getPile("wooden_ox"):length() > 1) then		--有牌>1牌的木牛流马
					local targetsuit = target:getArmor():getSuit() or target:getTreasure():getSuit()
				end
				if targetsuit then
					for _, c in ipairs(cards) do
						if self:getUseValue(c) < 6 and c:getSuit() == targetsuit then		--所选择的手牌使用价值要小于6
							use.card = sgs.Card_Parse("#FanjianLBCard:" .. c:getEffectiveId() .. ":&FanjianLB")
							if use.to then use.to:append(target) end
							return
						end
					end
				end
				if getKnownCard(target, self.player, "Jink", true, "he") >= 1 or getKnownCard(target, self.player, "Peach", true, "he") >= 1 then			--寻找明牌桃、闪
					local tarcard = findKnownCard(target, self.player, "Jink", true, "he") or findKnownCard(target, self.player, "Peach", true, "he")
					if tarcard then
						for _, c in ipairs(cards) do
							if self:getUseValue(c) < 6 and c:getSuit() == tarcard:getSuit() then	--所选择的手牌使用价值要小于6
								use.card = sgs.Card_Parse("#FanjianLBCard:" .. c:getEffectiveId() .. ":&FanjianLB")
								if use.to then use.to:append(target) end
								return
							end
						end
					end
				end
				for _, card in ipairs(cards) do
					if self:getUseValue(card) < 6 and card:getSuit() == sgs.Card_Diamond then
						use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
						if use.to then use.to:append(target) end
						return
					end
				end
			end
		end
	end

	if self:getOverflow() <= 0 then return end
	sgs.ai_use_priority.FanjianLBCard = 0.2
	local suit_table = { "spade", "club", "heart", "diamond" }
	local equip_val_table = { 1.2, 1.5, 0.5, 1, 1.3 }
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHandcardNum() > 2 then
			local max_suit_num, max_suit = 0, {}
			for i = 0, 3, 1 do
				local suit_num = getKnownCard(enemy, self.player, suit_table[i + 1])
				for j = 0, 4, 1 do
					if enemy:getEquip(j) and enemy:getEquip(j):getSuit() == i then
						local val = equip_val_table[j + 1]
						if j == 1 and self:needToThrowArmor(enemy) then val = -0.5
						else
							if enemy:hasSkills(sgs.lose_equip_skill) then val = val / 8 end
							if enemy:getEquip(j):getEffectiveId() == self:getValuableCard(enemy) then val = val * 1.1 end
							if enemy:getEquip(j):getEffectiveId() == self:getDangerousCard(enemy) then val = val * 1.1 end
						end
						suit_num = suit_num + j
					end
				end
				if suit_num > max_suit_num then
					max_suit_num = suit_num
					max_suit = { i }
				elseif suit_num == max_suit_num then
					table.insert(max_suit, i)
				end
			end
			if max_suit_num == 0 then
				max_suit = {}
				local suit_value = { 1, 1, 1.3, 1.5 }
				for _, skill in sgs.qlist(enemy:getVisibleSkillList(true)) do
					if not enemy:hasShownSkill(skill) then continue end   --不这样处理会导致作弊，但是AI竟然没有读取已明置技能列表的函数
					if sgs[skill:objectName() .. "_suit_value"] then
						for i = 1, 4, 1 do
							local v = sgs[skill:objectName() .. "_suit_value"][suit_table[i]]
							if v then suit_value[i] = suit_value[i] + v end
						end
					end
				end
				local max_suit_val = 0
				for i = 0, 3, 1 do
					local suit_val = suit_value[i + 1]
					if suit_val > max_suit_val then
						max_suit_val = suit_val
						max_suit = { i }
					elseif suit_val == max_suit_val then
						table.insert(max_suit, i)
					end
				end
			end
			for _, card in ipairs(cards) do
				if self:getUseValue(card) < 6 and table.contains(max_suit, card:getSuit()) then
					use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
					if use.to then use.to:append(enemy) end
					return
				end
			end
			if getCardsNum("Peach", enemy, self.player) < 2 then
				for _, card in ipairs(cards) do
					if self:getUseValue(card) < 6 and not self:isValuableCard(card) then
						use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
						if use.to then use.to:append(enemy) end
						return
					end
				end
			end
		end
	end
	
	for _, friend in ipairs(self.friends_noself) do
		if friend:hasShownSkill("hongyan") then
			for _, card in ipairs(cards) do
				if self:getUseValue(card) < 6 and card:getSuit() == sgs.Card_Spade then
					use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
		if friend:hasShownSkill("Zhaxiang") and not self:isWeak(friend) --[[and not (friend:getHp() == 2 and friend:hasShownSkill("Chanyuan"))]] then
			for _, card in ipairs(cards) do
				if self:getUseValue(card) < 6 then
					use.card = sgs.Card_Parse("#FanjianLBCard:" .. card:getEffectiveId() .. ":&FanjianLB")
					if use.to then use.to:append(friend) end
					return
				end
			end
		end
	end
end
sgs.ai_card_intention.FanjianLBCard = function(self, card, from, tos)
	local to = tos[1]
	if to:hasShownSkill("Zhaxiang") then
	elseif card:getSuit() == sgs.Card_Spade and to:hasShownSkill("hongyan") then
		sgs.updateIntention(from, to, -10)
	else
		sgs.updateIntention(from, to, 60)
	end
end
sgs.ai_use_priority.FanjianLBCard = 0.2
sgs.ai_skill_invoke.FanjianLB_discard = function(self, data)
	if self:getCardsNum("Peach") >= 1 and not self:willSkipPlayPhase() then return false end
	if not self:isWeak() and self.player:hasSkill("Zhaxiang") --[[and not (self.player:getHp() == 2 and self.player:hasSkill("chanyuan"))]] then return false end
	if self.player:getHandcardNum() <= 3 or self:isWeak() then return true end
	local suit = self.player:getMark("FanjianSuit")
	local count = 0
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:getSuit() == suit then
			count = count + 1
			if self:isValuableCard(card) then count = count + 0.5 end
		end
	end
	local equip_val_table = { 2, 2.5, 1, 1.5, 2.2 }
	for i = 0, 4, 1 do
		if self.player:getEquip(i) and self.player:getEquip(i):getSuit() == suit then
			if i == 1 and self:needToThrowArmor() then
				count = count - 1
			else
				count = equip_val_table[i + 1]
				if self.player:hasSkills(sgs.lose_equip_skill) then count = count + 0.5 end
			end
		end
	end
	return count / self.player:getCardCount(true) <= 0.6
end

----------------------------------------------------------------------------------------------------

-- WU 006 大乔

-- 国色
local guose_skill = {}
guose_skill.name = "GuoseLB"
table.insert(sgs.ai_skills, guose_skill)
guose_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasUsed("#GuoseLBCard") then return end
	
	local shouldShow = self:willShowForAttack()
	local helpFriend = false
	local mustUseHandcard = false
	--处理解乐（来自ai_skill_use_func）
	for _, friend in ipairs(self.friends) do
		if friend:containsTrick("indulgence") and self:willSkipPlayPhase(friend)
			and not friend:hasShownSkills("shensu|qiaobian") and (self:isWeak(friend) or self:getOverflow(friend) > 1) then
			for _, c in sgs.qlist(friend:getJudgingArea()) do
				if c:isKindOf("Indulgence") and self.player:canDiscard(friend, c:getEffectiveId()) then
					mustUseHandcard = shouldShow
					helpFriend = true
					shouldShow = true
					break
				end
			end
		end
	end

	local cards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
		local c = sgs.Sanguosha:getCard(id)
		cards:prepend(c)
	end
	cards=sgs.QList2Table(cards)

	local card

	self:sortByUseValue(cards, true)

	local has_weapon, has_armor = false, false

	for _,acard in ipairs(cards)  do
		if acard:isKindOf("Weapon") and not (acard:getSuit() == sgs.Card_Diamond) then has_weapon=true end
	end

	for _,acard in ipairs(cards)  do
		if acard:isKindOf("Armor") and not (acard:getSuit() == sgs.Card_Diamond) then has_armor=true end
	end

	for _,acard in ipairs(cards)  do
		if (acard:getSuit() == sgs.Card_Diamond) then
			local valuable = not ((self:getUseValue(acard)<sgs.ai_use_value.Indulgence + 0.5) or inclusive)  --要求比标大乔略松一点，因为能过牌
			if helpFriend then valuable = false end
			if valuable then continue end
			
			local shouldUse=true

			if acard:isKindOf("Armor") and not helpFriend then
				if not self.player:getArmor() then shouldUse = false
				elseif self.player:hasEquip(acard) and not has_armor and self:evaluateArmor() > 0 then shouldUse = false
				end
			end

			if acard:isKindOf("Weapon") and not helpFriend then
				if not self.player:getWeapon() then shouldUse = false
				elseif self.player:hasEquip(acard) and not has_weapon then shouldUse = false
				end
			end

			--if shouldShow and (self.player:handCards():contains(acard:getEffectiveId()) or not mustUseHandcard) then
			if not (self:willShowForAttack() or (helpFriend and self.player:handCards():contains(acard:getEffectiveId()))) then  --帮队友解乐则强制亮将
				shouldUse = false
			end

			if shouldUse then
				card = acard
				break
			end
		end
	end

	if not card then return nil end
	return sgs.Card_Parse("#GuoseLBCard:" .. card:getEffectiveId() .. ":&GuoseLB")
end
sgs.ai_skill_use_func["#GuoseLBCard"] = function(card, use, self)
	self:sort(self.friends)
	local id = card:getEffectiveId()
	local indul_only = not self.player:handCards():contains(id)
	local rcard = sgs.Sanguosha:getCard(id)
	if not indul_only and not self.player:isJilei(rcard) then
		sgs.ai_use_priority.GuoseLBCard = 5.5
		for _, friend in ipairs(self.friends) do
			if friend:containsTrick("indulgence") and self:willSkipPlayPhase(friend)
				and not friend:hasShownSkills("shensu|qiaobian") and (self:isWeak(friend) or self:getOverflow(friend) > 1) then
				for _, c in sgs.qlist(friend:getJudgingArea()) do
					if c:isKindOf("Indulgence") and self.player:canDiscard(friend, c:getEffectiveId()) then
						use.card = card
						if use.to then use.to:append(friend) end
						return
					end
				end
			end
		end
	end

	local indulgence = sgs.Sanguosha:cloneCard("Indulgence")
	indulgence:addSubcard(id)
	if not self.player:isLocked(indulgence) then
		sgs.ai_use_priority.GuoseLBCard = sgs.ai_use_priority.Indulgence
		local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
		self:useCardIndulgence(indulgence, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			use.card = card
			if use.to then use.to:append(dummy_use.to:first()) end
			return
		end
	end

	sgs.ai_use_priority.GuoseLBCard = 5.5
	if not indul_only and not self.player:isJilei(rcard) then
		for _, friend in ipairs(self.friends) do
			if friend:containsTrick("indulgence") and self:willSkipPlayPhase(friend) then
				for _, c in sgs.qlist(friend:getJudgingArea()) do
					if c:isKindOf("Indulgence") and self.player:canDiscard(friend, c:getEffectiveId()) then
						use.card = card
						if use.to then use.to:append(friend) end
						return
					end
				end
			end
		end
	end

	if not indul_only and not self.player:isJilei(rcard) then
		for _, friend in ipairs(self.friends) do
			if friend:containsTrick("indulgence") then
				for _, c in sgs.qlist(friend:getJudgingArea()) do
					if c:isKindOf("Indulgence") and self.player:canDiscard(friend, c:getEffectiveId()) then
						use.card = card
						if use.to then use.to:append(friend) end
						return
					end
				end
			end
		end
	end
end
sgs.ai_use_priority.GuoseLBCard = 5.5
sgs.ai_use_value.GuoseLBCard = 5
sgs.ai_card_intention.GuoseLBCard = -60
sgs.ai_cardneed.GuoseLB = sgs.ai_cardneed.guose
sgs.ai_suit_priority.GuoseLB = sgs.ai_suit_priority.guose
sgs.GuoseLB_suit_value = sgs.guose_suit_value

-- 流离
sgs.ai_skill_use["@@liuli_DaQiao_LB"] = function(self, prompt, method)
	local others = self.room:getOtherPlayers(self.player)
	others = sgs.QList2Table(others)
	local source
	for _, player in ipairs(others) do
		if player:hasFlag("LiuliDaQiao_LBSlashSource") then
			source = player
			break
		end
	end
	local slash = self.player:getTag("liuli_DaQiao_LB-card"):toCard()
	local nature = sgs.Slash_Natures[slash:getClassName()]

	if ((not self:willShowForDefence() and self:getCardsNum("Jink") > 1) or (not self:willShowForMasochism() and self:getCardsNum("Jink") == 0))
		and source:getMark("drank") == 0 then
			return "."
	end

	local doLiuli = function(who)
		if not self:isFriend(who) and who:hasShownSkill("leiji")
			and (self:hasSuit("spade", true, who) or who:getHandcardNum() >= 3)
			and (getKnownCard(who, self.player, "Jink", true) >= 1 or self:hasEightDiagramEffect(who)) then
			return "."
		end

		local cards = self.player:getCards("h")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if not self.player:isCardLimited(card, method) and self.player:canSlash(who) then
				if self:isFriend(who) and not (isCard("Peach", card, self.player) or isCard("Analeptic", card, self.player)) then
					return "#LiuliDaQiao_LBCard:"..card:getEffectiveId()..":&liuli_DaQiao_LB->"..who:objectName()
				else
					return "#LiuliDaQiao_LBCard:"..card:getEffectiveId()..":&liuli_DaQiao_LB->"..who:objectName()
				end
			end
		end

		local cards = self.player:getCards("e")
		cards = sgs.QList2Table(cards)
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			local range_fix = 0
			if card:isKindOf("Weapon") then range_fix = range_fix + sgs.weapon_range[card:getClassName()] - self.player:getAttackRange(false) end
			if card:isKindOf("OffensiveHorse") then range_fix = range_fix + 1 end
			if not self.player:isCardLimited(card, method) and self.player:canSlash(who, nil, true, range_fix) then
				return "#LiuliDaQiao_LBCard:" .. card:getEffectiveId() .. ":&liuli_DaQiao_LB->" .. who:objectName()
			end
		end
		return "."
	end

	local isJinkEffected
	for _, jink in ipairs(self:getCards("Jink")) do
		if self.room:isJinkEffected(user, jink) then isJinkEffected = true break end
	end

	local liuli = {}

	if not self:damageIsEffective(self.player, nature, source) then liuli[2] = "."
	elseif self:needToLoseHp(self.player, source, true) then liuli[2] = "."
	elseif self:getDamagedEffects(self.player, source, true) then liuli[2] = "." end

	self:sort(others, "defense")
	for _, player in ipairs(others) do
		if not (source and source:objectName() == player:objectName()) then
			if self:isEnemy(player) then
				if not (source and source:objectName() == player:objectName()) then
					if self:slashIsEffective(slash, player, false, source) then
						if not self:getDamagedEffects(player, source, true) then
							if self:hasHeavySlashDamage(source, slash, player) then
								if not source or self:isFriend(source, player) then
									local ret = doLiuli(player)
									if ret ~= "." then return ret end
								elseif not liuli[1] then
									local ret = doLiuli(player)
									if ret ~= "." then liuli[1] = ret end
								end
							elseif not liuli[5] then
								local ret = doLiuli(player)
								if ret ~= "." then liuli[5] = ret end
							end
						elseif not liuli[8] then
							local ret = doLiuli(player)
							if ret ~= "." then liuli[8] = ret end
						end
					elseif not liuli[6] then
						local ret = doLiuli(player)
						if ret ~= "." then liuli[6] = ret end
					end
				end
			elseif self:isFriend(player) then
				if not (source and source:objectName() == player:objectName()) then
					if self:slashIsEffective(slash, player, source) then
						if self:findLeijiTarget(player, 50, source) then
							local ret = doLiuli(player)
							if ret ~= "." then liuli[3] = ret end
						elseif not self:hasHeavySlashDamage(source, slash, player) then
							if self:getDamagedEffects(player, source, true) or self:needToLoseHp(player, source, true, true) then
								local ret = doLiuli(player)
								if ret ~= "." then liuli[4] = ret end
							end
						elseif self:isWeak() and (not isJinkEffected or self:canHit(self.player, source)) then
							if getCardsNum("Jink", player, self.player) >= 1 then
								local ret = doLiuli(player)
								if ret ~= "." then liuli[10] = ret end
							elseif not self:isWeak(player) then
								local ret = doLiuli(player)
								if ret ~= "." then liuli[11] = ret end
							end
						end
					else
						local ret = doLiuli(player)
						if ret ~= "." then liuli[7] = ret end
					end
				end
			else
				local ret = doLiuli(player)
				if ret ~= "." then liuli[9] = ret end
			end
		end
	end

	local ret = "."
	local i = 99
	for k, str in pairs(liuli) do
		if k < i then
			i = k
			ret = str
		end
	end

	return ret
end
sgs.ai_slash_prohibit.liuli_DaQiao_LB = sgs.ai_slash_prohibit.liuli
sgs.ai_cardneed.liuli_DaQiao_LB = sgs.ai_cardneed.liuli

----------------------------------------------------------------------------------------------------

-- WU 007 陆逊

-- 谦逊
sgs.ai_skill_invoke.QianxunLB = function(self, data)
	local effect = data:toCardEffect()
	local canLianying = self.player:hasSkill("Lianying")  --似乎这方法还是没从根本上解决问题（原意是只有被火攻拆顺之类的才会单谦逊）
	if not self:willShowForDefence() and not (effect.card:isKindOf("SupplyShortage") and canLianying) and not effect.card:isKindOf("Indulgence") then return false end
	if effect.card:isKindOf("Collateral") and self.player:getWeapon() then
		local victim = self.player:getTag("collateralVictim"):toPlayer()
		if victim and sgs.ai_skill_cardask["collateral-slash"](self, nil, nil, victim, effect.from) ~= "." then return false end
	end
	if self.player:getPhase() == sgs.Player_Judge then
		if effect.card:isKindOf("Lightning") and self:isWeak() and self:getCardsNum("Peach") + self:getCardsNum("Analeptic") > 0 then return false end
		return canLianying or effect.card:isKindOf("Indulgence")
	end
	local current = self.room:getCurrent()
	if current and self:isFriend(current) and effect.from and self:isFriend(effect.from) then return canLianying end
	if effect.card:isKindOf("Duel") and sgs.ai_skill_cardask["duel-slash"](self, data, nil, effect.from) ~= "." then return false end
	if effect.card:isKindOf("AOE") and sgs.ai_skill_cardask.aoe(self, data, nil, effect.from, effect.card:objectName()) ~= "." then return false end
	if effect.card:isKindOf("LureTiger") then return canLianying end
	if self.player:hasArmorEffect("Breastplate") and not (effect.card:isKindOf("Snatch") or effect.card:isKindOf("Dismantlement") or effect.card:isKindOf("Drowning")) then return canLianying end						--有护心镜无条件发动（除非护心镜可能被拆顺）
	if self.player:getHp() == 1 then
		if (self:getCardsNum("Peach") + self:getCardsNum("Analeptic") > 0) or (self.player:getHandcardNum() >= 3 and self:getCardsNum("Jink") > 0) then return false end	--有桃、酒、3牌以上有闪不发动
	end
	if self.player:getHandcardNum() < self:getLeastHandcardNum(self.player) then return true end
	local l_lim, u_lim = math.max(2, self:getLeastHandcardNum(self.player)), math.max(5, #self.friends)
	if u_lim <= l_lim then u_lim = l_lim + 1 end
	return math.random(0, 100) >= (self.player:getHandcardNum() - l_lim) / (u_lim - l_lim + 1) * 100
end

-- 连营
sgs.ai_skill_playerchosen.Lianying = function(self, targets, max_num, min_num)
	if not self:willShowForDefence() and not self:willShowForAttack() then return {} end
	local move = self.player:getTag("LianyingMoveData"):toMoveOneTime()
	local effect = nil
	if move.reason.m_skillName == "QianxunLB" then effect = self.player:getTag("QianxunLBEffectData"):toCardEffect() end

	local target_table = {}
	if self.player:getPhase() <= sgs.Player_Play then
		table.insert(target_table, self.player)
		if max_num == 1 then return target_table end
	end
	local exclude_self, sn_dis_eff = false
	if effect and (effect.card:isKindOf("Snatch") or effect.card:isKindOf("Dismantlement"))
		and effect.from:isAlive() and self:isEnemy(effect.from) then
		if self.player:getEquips():isEmpty() then
			exclude_self = true
		else
			sn_dis_eff = true
		end
	end
	--if hasManjuanEffect(self.player) then exclude_self = true end
	if not exclude_self and effect and effect.card:isKindOf("FireAttack") and effect.from:isAlive()
		and not effect.from:isKongcheng() and self:isEnemy(effect.from) then
		exclude_self = true
	end

	local getValue = function(friend)
		local def = sgs.getDefense(friend)
		if friend:objectName() == self.player:objectName() then
			if sn_dis_eff then def = def + 5 else def = def - 2 end
		end
		return def
	end
	local cmp = function(a, b)
		return getValue(a) < getValue(b)
	end
	table.sort(self.friends, cmp)

	local dimeng_friend
	for _, friend in ipairs(self.friends) do
		if friend:hasFlag("DimengTarget") and not self.player:hasFlag("DimengTarget") then
			local other_dimeng_target
			for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasFlag("DimengTarget") and p:objectName() ~= friend:objectName() then
					other_dimeng_target = p
					break
				end
			end
			if other_dimeng_target then
				table.insert(target_table, other_dimeng_target)
				dimeng_friend = friend
				break
			end
		end
	end
	
	if #target_table < max_num then
		for _, friend in ipairs(self.friends) do
			if --[[not hasManjuanEffect(friend) and]] self:isFriendWith(friend) and not self:needKongcheng(friend, true) and not table.contains(target_table, friend)  --先给同一国的
				and not (exclude_self and friend:objectName() == self.player:objectName()) and not (dimeng_friend and dimeng_friend:objectName() == friend:objectName()) then
				table.insert(target_table, friend)
				if #target_table == max_num then break end
			end
		end
	end
	if #target_table < max_num then
		for _, friend in ipairs(self.friends) do
			if --[[not hasManjuanEffect(friend) and]] not self:needKongcheng(friend, true) and not table.contains(target_table, friend)
				and not (exclude_self and friend:objectName() == self.player:objectName()) and not (dimeng_friend and dimeng_friend:objectName() == friend:objectName()) then
				table.insert(target_table, friend)
				if #target_table == max_num then break end
			end
		end
	end
	return target_table
end

----------------------------------------------------------------------------------------------------

-- QUN 001 华佗

-- 除疠
local chuli_skill = {}
chuli_skill.name = "Chuli"
table.insert(sgs.ai_skills, chuli_skill)
chuli_skill.getTurnUseCard = function(self, inclusive)
	if not self:willShowForAttack() then return nil end
	if not self.player:canDiscard(self.player, "he") or self.player:hasUsed("#ChuliCard") then return nil end

	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)

	if self:needToThrowArmor() and self.player:canDiscard(self.player, self.player:getArmor():getEffectiveId()) then
		self.Chuli_id = self.player:getArmor():getEffectiveId()
		return sgs.Card_Parse("#ChuliCard:.:&Chuli")
	end
	for _, card in ipairs(cards) do
		if self.player:canDiscard(self.player, card:getEffectiveId()) and not self:isValuableCard(card) then
			if card:getSuit() == sgs.Card_Spade then 
				self.Chuli_id = card:getEffectiveId()
				return sgs.Card_Parse("#ChuliCard:.:&Chuli")
			end
		end
	end
	for _, card in ipairs(cards) do
		if self.player:canDiscard(self.player, card:getEffectiveId()) and not self:isValuableCard(card) and not (self.player:hasSkills("jijiu|jijiu_HuaTuo_LB") and card:isRed() and self:getOverflow() < 1) then
			--if card:getSuit() == sgs.Card_Spade then   --源码什么鬼？
				self.Chuli_id = card:getEffectiveId()
				return sgs.Card_Parse("#ChuliCard:.:&Chuli")
			--end
		end
	end
end
sgs.ai_skill_use_func["#ChuliCard"] = function(card, use, self)
	self.chuli_id_choice = {}
	local players = self:findPlayerToDiscard("he", false, true, nil, true)
	local kingdoms = {}
	local targets = {}
	
	local function getDiscardId(player, important_only)
		--源码是先取id再判断是否为黑桃装备，这里改成用disable_list处理，避免id为黑桃装备就不弃了的情况（注意手动加无法弃置的）
		local disable_list = {}
		for _,equip in sgs.qlist(player:getEquips()) do
			if not self.player:canDiscard(player, equip:getEffectiveId()) or (equip:getSuit() == sgs.Card_Spade and not (self:getDangerousCard(player) and self:getDangerousCard(player) == equip:getEffectiveId()) and not self:isFriend(player)) then
				table.insert(disable_list, equip:getEffectiveId())
			end
		end
		for _,hc in sgs.qlist(player:getHandcards()) do
			if not self.player:canDiscard(player, hc:getEffectiveId()) then
				table.insert(disable_list, hc:getEffectiveId())
			end
		end
		
		local id = self:askForCardChosen(player, "he", "dummyreason", sgs.Card_MethodDiscard, disable_list)
		if id and id ~= -1 then
			return id
		end
		if important_only then return nil end
		
		if not self:isFriend(player) and not player:isKongcheng() and not self:doNotDiscard(player, "h", false, 1) then
			return self:getCardRandomly(player, "h", disable_list)
		end
		return nil
	end
	
	local kingdom
	for _, player in ipairs(players) do
		if not player:hasShownOneGeneral() then continue end
		kingdom = (player:getRole() == "careerist") and "careerist" .. player:objectName() or player:getKingdom()
		if self:isFriend(player) and not table.contains(kingdoms, kingdom) then
			if getDiscardId(player, true) then
				table.insert(targets, player)
				table.insert(kingdoms, kingdom)
			end
		end
	end
	for _, player in ipairs(players) do
		if not player:hasShownOneGeneral() then continue end
		kingdom = (player:getRole() == "careerist") and "careerist" .. player:objectName() or player:getKingdom()
		if not table.contains(targets, player, true) and not table.contains(kingdoms, kingdom) then
			if getDiscardId(player, true) then
				table.insert(targets, player)
				table.insert(kingdoms, kingdom)
			end
		end
	end
	for _, player in ipairs(players) do
		if not player:hasShownOneGeneral() then continue end
		kingdom = (player:getRole() == "careerist") and "careerist" .. player:objectName() or player:getKingdom()
		if not table.contains(targets, player, true) and not table.contains(kingdoms, kingdom) then
			if getDiscardId(player) then
				table.insert(targets, player)
				table.insert(kingdoms, kingdom)
			end
		end
	end
	if #targets == 0 then return end
	for _, p in ipairs(targets) do
		local id = getDiscardId(p)
		if id then
			if not use.card then use.card = card end
			self.chuli_id_choice[p:objectName()] = id
			if use.to then use.to:append(p) end
		end
	end
end
sgs.ai_skill_cardask["@ChuliSelfDiscard"] = function(self, data)
	if self.Chuli_id == nil then
		self.room:writeToConsole("Chuli card chosen error!!")
		return self:askForDiscard("Chuli", 1, 1, false, true)
	end
	local id = self.Chuli_id
	self.Chuli_id = nil
	return "$" .. id
end
sgs.ai_skill_cardchosen.Chuli = function(self, who, flags)
	local id = self.chuli_id_choice[who:objectName()]
	if id and id ~= -1 then return id end
	return nil
end
sgs.ai_use_value.ChuliCard = 5
sgs.ai_use_priority.ChuliCard = 4.6
sgs.ai_card_intention.ChuliCard = function(self, card, from, tos)
	for _, to in ipairs(tos) do
		if self.chuli_id_choice and self.chuli_id_choice[to:objectName()] then
			local em_prompt = { "cardChosen", "Chuli", tostring(self.chuli_id_choice[to:objectName()]), from:objectName(), to:objectName() }
			sgs.ai_choicemade_filter.cardChosen.snatch(self, nil, em_prompt)
		end
	end
end
sgs.ai_suit_priority.Chuli = function(self, card)
	if not self.player:hasSkills("jijiu|jijiu_HuaTuo_LB") then
		return "club|diamond|heart|spade"
	else
		return "club|spade|diamond|heart"
	end
end

-- 急救
sgs.ai_view_as.jijiu_HuaTuo_LB = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getHandPile():contains(card_id)) and card:isRed() and player:getPhase() == sgs.Player_NotActive
		and not player:hasFlag("Global_PreventPeach") and (player:getMark("@qianxi_red") <= 0 or card:isEquipped()) then
		return ("peach:jijiu_HuaTuo_LB[%s:%s]=%d&jijiu_HuaTuo_LB"):format(suit, number, card_id)  --todo：用isLocked替代qianxi_red（其他视为技同理）
	end
end
sgs.jijiu_HuaTuo_LB_suit_value = sgs.jijiu_suit_value
sgs.ai_cardneed.jijiu_HuaTuo_LB = function(to, card)
	return sgs.ai_cardneed.jijiu(to, card)
end
sgs.ai_suit_priority.jijiu_HuaTuo_LB = sgs.ai_suit_priority.jijiu

----------------------------------------------------------------------------------------------------

-- QUN 002 吕布

-- 无双
sgs.ai_skill_invoke.wushuang_LyuBu_LB = sgs.ai_skill_invoke.wushuang

-- 利驭
local function getPriorFriendsOfLiyu(self, lvbu)
	lvbu = lvbu or self.player
	local prior_friends = {}
	--原文没有对国战的判断。。。
	--[[if not string.startsWith(self.room:getMode(), "06_") and not sgs.GetConfig("EnableHegemony", false) then
		if lvbu:isLord() then
			for _, friend in ipairs(self:getFriendsNoself(lvbu)) do
				if sgs.evaluatePlayerRole(friend) == "loyalist" then table.insert(prior_friends, friend) end
			end
		elseif lvbu:getRole() == "loyalist" then
			local lord = self.room:getLord()
			if lord then prior_friends = { lord } end
		elseif self.room:getMode() == "couple" then
			local diaochan = self.room:getPlayer("diaochan")
			if diaochan then prior_friends = { diaochan } end
		end
	elseif self.room:getMode() == "06_3v3" then
		if lvbu:getRole() == "loyalist" then
			for _, friend in ipairs(self:getFriendsNoself(lvbu)) do
				if friend:getRole() == "lord" then table.insert(prior_friends, friend) break end
			end
		elseif lvbu:getRole() == "rebel" then
			for _, friend in ipairs(self:getFriendsNoself(lvbu)) do
				if friend:getRole() == "renegade" then table.insert(prior_friends, friend) break end
			end
		end
	elseif self.room:getMode() == "06_XMode" then
		local leader = lvbu:getTag("XModeLeader"):toPlayer()
		local backup = 0
		if leader then
			backup = #leader:getTag("XModeBackup"):toStringList()
			if backup == 0 then
				prior_friends = self:getFriendsNoself(lvbu)
			end
		end
	end]]
	return prior_friends
end
function SmartAI:hasLiyuEffect(target, slash)
	local upperlimit = tonumber(self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") and 2 or 1)
	if #self.friends_noself == 0 or self.player:hasSkill("Jueqing") then return false end
	if not self:slashIsEffective(slash, target, self.player) then return false end

	local targets = { target }
	if not self.player:hasSkill("Jueqing") and target:isChained() and slash:isKindOf("NatureSlash") then
		for _, p in sgs.qlist(self.room:getOtherPlayers(target)) do
			if p:isChained() and p:objectName() ~= self.player:objectName() then table.insert(targets, p) end
		end
	end
	local unsafe = false
	for _, p in ipairs(targets) do
		if self:isEnemy(target) and not target:isNude() then
			unsafe = true
			break
		end
	end
	if not unsafe then return false end

	local duel = sgs.Sanguosha:cloneCard("Duel")
	if self.player:isLocked(duel) then return false end

	local enemy_null = 0
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isFriend(p) then enemy_null = enemy_null - getCardsNum("Nullification", p, self.player) end
		if self:isEnemy(p) then enemy_null = enemy_null + getCardsNum("Nullification", p, self.player) end
	end
	enemy_null = enemy_null - self:getCardsNum("Nullification")
	if enemy_null <= -1 then return false end

	local prior_friends = getPriorFriendsOfLiyu(self)
	if #prior_friends == 0 then return false end
	for _, friend in ipairs(prior_friends) do
		if self:hasTrickEffective(duel, friend, self.player) and self:isWeak(friend) and (getCardsNum("Slash", friend, self.player) < upperlimit or self:isWeak()) then
			return true
		end
	end

	if sgs.isJinkAvailable(self.player, target, slash) and getCardsNum("Jink", target, self.player) >= upperlimit
		and not self:needToLoseHp(target, self.player, true) and not self:getDamagedEffects(target, self.player, true) then return false end
	if slash:hasFlag("AIGlobal_KillOff") or (target:getHp() == 1 and self:isWeak(target) and self:getSaveNum() < 1) then return false end

	--if self.player:hasSkill("wumou") and self.player:getMark("@wrath") == 0 and (self:isWeak() or not self.player:hasSkill("zhaxiang")) then return true end
	if self.player:hasSkills("jizhi") --[[or (self.player:hasSkill("jilve") and self.player:getMark("@bear") > 0)]] then return false end
	--if not string.startsWith(self.room:getMode(), "06_") and not sgs.GetConfig("EnableHegemony", false) and self.role ~= "rebel" then
		for _, friend in ipairs(self.friends_noself) do
			if self:hasTrickEffective(duel, friend, self.player) and self:isWeak(friend) and (getCardsNum("Slash", friend, self.player) < upperlimit or self:isWeak())
				and self:getSaveNum(true) < 1 then
				return true
			end
		end
	--end
	return false
end
sgs.ai_skill_invoke.Liyu = function(self, data)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	local lvbu = damage.from
	local duel = sgs.Sanguosha:cloneCard("duel", sgs.Card_NoSuit, 0)
	local targets = sgs.SPlayerList()
	if lvbu:isAlive() and not lvbu:isLocked(duel) then
		for _,p in sgs.qlist(self.room:getOtherPlayers(lvbu)) do
			if (p:objectName() ~= self.player:objectName()) and duel:targetFilter(sgs.PlayerList(), p, lvbu) then
				targets:append(p)
			end
		end
	end
	self.Liyu_target = nil
	
	local enemies = {}
	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) then table.insert(enemies, target) end
	end
	
	if targets:isEmpty() then
		if self:isFriend(lvbu) and self:needToThrowArmor() and #enemies > 0 then
			self.Liyu_target = enemies[1]
			return true
		else
			return false
		end
	end
	if self:isFriend(lvbu) then
		if not self:isWeak() or self:needKongcheng() then
			self.Liyu_target = enemies[1]
			return true
		else
			return false
		end
	else
		if self.player:getEquips():isEmpty() then
			local all_peach = true
			for _, card in sgs.qlist(self.player:getHandcards()) do
				if not isCard("Peach", card, lvbu) then all_peach = false break end
			end
			if all_peach then return false end
		end
		local upperlimit = tonumber(lvbu:hasShownSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") and 2 or 1)
		local prior_friends = getPriorFriendsOfLiyu(self, lvbu)
		if #prior_friends > 0 then
			for _, friend in ipairs(prior_friends) do
				if self:hasTrickEffective(duel, friend, lvbu) then
					self.Liyu_target = friend
					return true
				end
			end
		end
		if self:getValuableCard(self.player) then return false end
		local valuable = 0
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if self:isValuableCard(card) then valuable = valuable + 1 end
		end
		if valuable / self.player:getHandcardNum() > 0.5 then return false end
	end

	-- the target of the Duel
	self:sort(enemies, "defense")
	for _, enemy in ipairs(enemies) do
		if self:hasTrickEffective(duel, enemy, lvbu) then
			if not (self:isFriend(lvbu) and getCardsNum("Slash", enemy, self.player) > upperlimit and self:isWeak(lvbu)) then
				self.Liyu_target = enemy
				return true
			end
		end
	end
end
sgs.ai_skill_playerchosen.Liyu = function(self, targets)
	if not self.Liyu_target then self.room:writeToConsole("Liyu player chosen error!!") end
	return self.Liyu_target
end
sgs.ai_playerchosen_intention.Liyu = 60

----------------------------------------------------------------------------------------------------

-- QUN 026 公孙瓒

-- 趫猛
sgs.ai_skill_invoke.Qiaomeng = function(self, data)
	if not self:willShowForAttack() then return false end
	local damage = data:toDamage()
	if self:isFriend(damage.to) then return damage.to:getArmor() and self:needToThrowArmor(damage.to) end
	return not self:doNotDiscard(damage.to, "e")
end

-- 义从
sgs.ai_skill_invoke.YicongGongSunZan = function(self, data)
	if self.player:getHp() <= 2 then
		if not self:willShowForDefence() then return false end
		for _, p in ipairs(self.enemies) do
			if self:canAttack(self.player, p) and p:inMyAttackRange(self.player) and (p:distanceTo(self.player, 1) > p:getAttackRange()) then
				return true
			end
		end
	elseif self.player:getHp() > 2 then
		if not self:willShowForAttack() then return false end
		for _, p in ipairs(self.enemies) do
			if self:canAttack(p) and not self.player:inMyAttackRange(p) and (self.player:distanceTo(p, -1) <= self.player:getAttackRange()) then
				return true
			end
		end
	end
	return false
end

-------------------------------------------------神-------------------------------------------------

-- LE 001 神关羽

-- 武神
function willShowWushen(self)
--本来打算也放到view_as里的，结果会导致嵌套
	local cards = sgs.QList2Table(self.player:getHandcards())
	local hearts = {}
	for _,card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Heart then 
			table.insert(hearts, card)
			if self:isWeak() or not self.player:hasSkill("Wuhun") then
				if card:isKindOf("Peach") or card:isKindOf("Analeptic") then return false end
				if card:isKindOf("Jink") and self:getCardsNum("Jink") <= 1 then return false end
			end
		end
	end
	if #hearts == 0 then return true end
	
	self:sortByUseValue(hearts)  --判断价值最高的一张牌是否依然低于杀
	local card = hearts[1]
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local slash = sgs.Card_Parse(("slash:Wushen[%s:%s]=%d&Wushen"):format(suit, number, card_id))
	assert(slash)
	local value = self:getUseValue(slash)
	if self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then  --二次转化大法好
		local jink = sgs.Card_Parse(("jink:longdan[%s:%s]=%d&longdan"):format(suit, number, card_id))
		assert(jink)
		value = math.max(value, self:getUseValue(jink))
	end
	return self:getUseValue(card) < value
end
sgs.ai_view_as.Wushen = function(card, player, card_place)
	if not player:hasShownSkill("Wushen") then
		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		if card_place == sgs.Player_PlaceHand and card:getSuit() == sgs.Card_Heart and not card:isKindOf("Peach") and not card:isKindOf("Slash") and not card:hasFlag("using") then
			return ("slash:Wushen[%s:%s]=%d&Wushen"):format(suit, number, card_id)
		end
	end
end
local wushen_skill = {}
wushen_skill.name = "Wushen"
table.insert(sgs.ai_skills, wushen_skill)
wushen_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasShownSkill("Wushen") then return end
	if not willShowWushen(self) then return end
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end
	
	local handcards = self.player:getHandcards()
	local real_slashes = {}
	for _,slash in sgs.qlist(handcards) do
		if isCard("Slash", slash, self.player) then table.insert(real_slashes, slash) end
	end
	
	local cards = {}
	for _, card in sgs.qlist(handcards) do
		if card:getSuit() == sgs.Card_Heart and not card:isKindOf("Slash")
			and ((not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player)) or useAll) then
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:Wushen[%s:%s]=%d&Wushen"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				local hasEffectiveSlash = false
				if #real_slashes > 0 then  --尝试解决手里有真杀还亮武神的问题
					local use = {to = sgs.SPlayerList(), isDummy = true}
					self:useBasicCard(slash, use)
					if use.card and use.card:isKindOf("Slash") and use.to and not use.to:isEmpty() then
						for _,realslash in ipairs(real_slashes) do
							local use2 = {to = sgs.SPlayerList(), isDummy = true}
							self:useBasicCard(realslash, use2)
							if use2.card and use2.card:isKindOf("Slash") and use2.to and not use2.to:isEmpty() then
								local same_targets = true
								for _,to in sgs.qlist(use.to) do
									if not use2.to:contains(to) then same_targets = false break end
								end
								if same_targets then hasEffectiveSlash = true break end
							end
						end
					end
				end
				if not hasEffectiveSlash then
					table.insert(cards, slash)
				end
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end
sgs.ai_suit_priority.Wushen = "club|spade|diamond|heart"

-- 武魂
sgs.ai_skill_invoke.Wuhun = function(self, data)
	if not self:willShowForMasochism() then return false end
	local target = data:toDamage().from
	local damageNum = data:toDamage().damage
	if not target then return end
	
	local actual_friends_noself = {}
	local has_anjiang = true
	for _,friend in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isFriendWith(friend) then
			table.insert(actual_friends_noself, friend)
		end
		if self:evaluateKingdom(friend) == "unknown" then has_anjiang = true end
	end
	local friendless = (#actual_friends_noself == 0) and not has_anjiang
						if friendless then self.room:writeToConsole("friendless") end

	if self:objectiveLevel(target) >= 3 or friendless then
		if self.player:getHp() <= 1 then return true end
		if self.player:getHp() == 2 and self:getCardsNum("Peach") == 0 then return true end
		
		--[[local maxfriendmark = 0  --被邹氏暗了的情况（算了不管了，问题一大堆顾不上这里……）
		local maxenemymark = 0
		for _, friend in ipairs(self.friends_noself) do
			local friendmark = friend:getMark("@nightmare")
			if friendmark > maxfriendmark then maxfriendmark = friendmark end
		end
		for _, enemy in ipairs(self.enemies) do
			local enemymark = enemy:getMark("@nightmare")
			if enemymark > maxenemymark then maxenemymark = enemymark end
		end
		if (maxfriendmark + maxenemymark > 0) and (maxfriendmark + damageNum - self.player:getHp() / 2 >= maxenemymark) then return true end  ]]
	end
	
	if self:isEnemy(target) or friendless then
		if self.player:hasSkill("Wushen") and not self.player:hasShownSkill("Wushen") and not willShowWushen(self) then return false end
		return true
	end
	return false
end
sgs.ai_skill_playerchosen.Wuhun = function(self, targets)
	local targetlist=sgs.QList2Table(targets)
	local target
	for _, player in ipairs(targetlist) do
		if self:isEnemy(player) and (not target or target:getHp() < player:getHp()) then
			target = player
		end
	end
	if target then return target end
	
	for _, player in ipairs(targetlist) do
		if not self:isFriend(player) and (not target or target:getHp() < player:getHp()) then
			target = player
		end
	end
	if target then return target end
	
	for _, player in ipairs(targetlist) do
		if not self:isFriendWith(player) and (not target or target:getHp() < player:getHp()) then
			target = player
		end
	end
	if target then return target end
	
	self:sort(targetlist, "hp")
	return targetlist[1]
end
function SmartAI:getWuhunRevengeTargets(player)
	player = player or self.player
	if not player:hasSkill("Wuhun") then return {} end
	local targets = {}
	local maxcount = 0
	for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
		local count = p:getMark("@nightmare")
		if count > maxcount then
			targets = { p }
			maxcount = count
		elseif count == maxcount and maxcount > 0 then
			table.insert(targets, p)
		end
	end
	return targets
end
function sgs.ai_slash_prohibit.Wuhun(self, from, to)
	--if from:hasSkill("jueqing") then return false end
	--if from:hasFlag("NosJiefanUsed") then return false end
	local damageNum = self:hasHeavySlashDamage(from, nil, to, true)
	if to:getHp() <= damageNum and math.ceil(self:getAllPeachNum(to)) < 1 - (to:getHp() - damageNum) then
		damageNum = 0  --由于时机修改
	end

	local actual_friends_from = {}
	for _,friend in sgs.qlist(self.room:getAlivePlayers()) do
		if friend:objectName() == from:objectName() or from:isFriendWith(friend) then
			table.insert(actual_friends_from, friend)
		end
	end
	local actual_friends_to = {}
	for _,friend in sgs.qlist(self.room:getAlivePlayers()) do
		if friend:objectName() == to:objectName() or to:isFriendWith(friend) then
			table.insert(actual_friends_to, friend)
		end
	end
	if (#actual_friends_from + #actual_friends_to == self.room:alivePlayerCount()) and (#actual_friends_to == 1) then  --两势力对战，对面仅剩神关一人
		return false
	end
	
	if sgs.ais[from:objectName()]:objectiveLevel(to) > 3 then
		local targets = self:getWuhunRevengeTargets(to)
		local maxmark = targets[1] and targets[1]:getMark("@nightmare") or 0
		if maxmark < from:getMark("@nightmare") + damageNum then  --伤害来源将成为新的武魂目标
			return true
		elseif (maxmark == from:getMark("@nightmare") + damageNum) and #actual_friends_from == 1 then  --没有队友，还是不要拿自己势力冒险了
		else  --对自己没有威胁
			for _,target in ipairs(targets) do
				if sgs.ais[to:objectName()]:objectiveLevel(target) > 0 and self:isFriendWith(from, target) then return false end  --帮队友压神关血线
			end
			return true  --别多管闲事
		end
	end
	
	--[[local maxfriendmark = 0
	local maxenemymark = 0
	for _, friend in ipairs(self:getFriends(from)) do
		local friendmark = friend:getMark("@nightmare")
		if friendmark > maxfriendmark then maxfriendmark = friendmark end
	end
	for _, enemy in ipairs(self:getEnemies(from)) do
		local enemymark = enemy:getMark("@nightmare")
		if enemymark > maxenemymark and enemy:objectName() ~= to:objectName() then maxenemymark = enemymark end
	end
	if self:isEnemy(to, from) then
		maxfriendmark = math.max(maxfriendmark, from:getMark("@nightmare") + damageNum)
									self.room:writeToConsole("Wuhun slash prohibit " .. from:getGeneralName() .. "->" .. to:getGeneralName())
									self.room:writeToConsole("Marks: " .. maxfriendmark .. "," .. maxenemymark)
		if (maxfriendmark >= maxenemymark) and not (#(self:getEnemies(from)) == 1 and #actual_friends + #(self:getEnemies(from)) == self.room:alivePlayerCount()) then
			return true
		end
	end]]
end
function SmartAI:needDeath(player)
	--[[local maxfriendmark = 0
	local maxenemymark = 0
	local maxmark = 0
	local maxmarkplayer]]
	player = player or self.player
	local actual_friends_noself = {}
	for _,friend in sgs.qlist(self.room:getOtherPlayers(player)) do
		if sgs.ais[player:objectName()]:isFriendWith(friend) then
			table.insert(actual_friends_noself, friend)
		end
	end
	if player:hasShownSkill("Wuhun") and #actual_friends_noself > 0 then
		local targets = self:getWuhunRevengeTargets(player)
		for _,target in ipairs(targets) do
			if self:isEnemy(player, target) then return true end
		end
		if #self:getEnemies(player) == 0 then
			for _,target in ipairs(targets) do
				if sgs.ais[player:objectName()]:objectiveLevel(target) > 3 then return true end
			end
		end
		--[[for _, aplayer in sgs.qlist(self.room:getAlivePlayers()) do
			local mark = aplayer:getMark("@nightmare")
			if self:isFriend(player,aplayer) and player:objectName() ~= aplayer:objectName() then
				if mark > maxfriendmark then maxfriendmark = mark end
			end
			if self:isEnemy(player,aplayer) then
				if mark > maxenemymark then maxenemymark = mark end
			end
			
		end
		if maxfriendmark >= maxenemymark then return false
		elseif maxenemymark == 0 then return false
		else return true end]]
	end
	return false
end

----------------------------------------------------------------------------------------------------

-- LE 002 神吕蒙

-- 涉猎
sgs.ai_skill_invoke.Shelie = function(self, data)
	if not self:willShowForAttack() and not self:willShowForDefence() then
		return false
	end
	if self.player:hasSkill("haoshi") then
		if sgs.ai_skill_invoke.haoshi(self, data) then return false end
	end
	local count = 2
	if self.player:hasTreasure("JadeSeal") and self.player:hasShownOneGeneral() then count = count + 1 end
	if self.player:hasSkill("yingzi_zhouyu") then count = count + 1 end
	if self.player:hasSkill("yingzi_sunce") then count = count + 1 end
	if self.player:hasSkill("YingziLB") then count = count + 1 end
	if self.player:hasSkill("Juejing") then count = count + getJuejingLostHp(self.player) end
	if count >= 4 then return false end
	if count == 3 then
		return math.random(0, 5) <= 2
	end
	return true
end
sgs.ai_skill_movecards.Shelie = function(self, upcards, downcards, min_num, max_num)
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	
	local suits = {[sgs.Card_Spade] = {}, [sgs.Card_Club] = {}, [sgs.Card_Heart] = {}, [sgs.Card_Diamond] = {}}
	for _,id in pairs(upcards_copy) do
		table.insert(suits[sgs.Sanguosha:getCard(id):getSuit()], id)
	end
	for suit, ids in pairs(suits) do
		if #ids == 0 then continue end
		local taken = self:askForAG(ids, false, "Shelie")
		table.insert(down, taken)
		table.removeOne(upcards_copy, taken)
	end
	
	return upcards_copy, down
end

-- 攻心
local gongxin_god_skill = {}
gongxin_god_skill.name = "Gongxin_ShenLyuMeng"
table.insert(sgs.ai_skills, gongxin_god_skill)
gongxin_god_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:hasUsed("#GongxinShenLyuMengCard") then return end
	self.Gongxin_Use_Immediately = nil
	local gongxin_card = sgs.Card_Parse("#GongxinShenLyuMengCard:.:&Gongxin_ShenLyuMeng")
	assert(gongxin_card)
	return gongxin_card
end
sgs.ai_skill_use_func["#GongxinShenLyuMengCard"] = sgs.ai_skill_use_func["#GongxinLyuMeng_LBCard"]
sgs.ai_skill_choice.Gongxin_ShenLyuMeng = sgs.ai_skill_choice.Gongxin_LyuMeng_LB
sgs.ai_use_value.GongxinShenLyuMengCard = sgs.ai_use_value.GongxinLyuMeng_LBCard
sgs.ai_use_priority.GongxinShenLyuMengCard = sgs.ai_use_priority.GongxinLyuMeng_LBCard
sgs.ai_card_intention.GongxinShenLyuMengCard = sgs.ai_card_intention.GongxinLyuMeng_LBCard

----------------------------------------------------------------------------------------------------

-- LE 003 神周瑜

-- 琴音
sgs.ai_skill_invoke.Qinyin = function(self, data)
	self:sort(self.friends, "hp")
	self:sort(self.enemies, "hp")
	local up = 0
	local down = 0

	for _, friend in ipairs(self.friends) do
		down = down - 10
		up = up + (friend:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, friend) then
			down = down - 5
			if friend:isWounded() then up = up + 5 end
		end
		if self:needToLoseHp(friend, nil, nil, true) then down = down + 5 end
		if self:needToLoseHp(friend, nil, nil, true, true) and friend:isWounded() then up = up - 5 end

		if self:isWeak(friend) then
			if friend:isWounded() then up = up + 10 + (friend:isLord() and 20 or 0) end
			down = down - 10 - (friend:isLord() and 40 or 0)
			if friend:getHp() <= 1 and not hasBuquEffect(friend) then
				down = down - 20 - (friend:isLord() and 40 or 0)
			end
		end
	end

	for _, enemy in ipairs(self.enemies) do
		down = down + 10
		up = up - (enemy:isWounded() and 10 or 0)
		if self:hasSkills(sgs.masochism_skill, enemy) then
			down = down + 10
			if enemy:isWounded() then up = up - 10 end
		end
		if self:needToLoseHp(enemy, nil, nil, true) then down = down - 5 end
		if self:needToLoseHp(enemy, nil, nil, true, true) and enemy:isWounded() then up = up - 5 end

		if self:isWeak(enemy) then
			if enemy:isWounded() then up = up - 10 end
			down = down + 10
			if enemy:getHp() <= 1 and not hasBuquEffect(enemy) then
				down = down + 10 + ((enemy:isLord() and #self.enemies > 1) and 20 or 0)
			end
		end
	end

	if down > 0 then
		if self:willShowForAttack() then
			sgs.ai_skill_choice.Qinyin = "down"
			return true
		end
	elseif up > 0 then
		if self:willShowForDefence() then
			sgs.ai_skill_choice.Qinyin = "up"
			return true
		end
	end
	return false
end

-- 业炎
local yeyan_skill = {}
yeyan_skill.name = "Yeyan"
table.insert(sgs.ai_skills, yeyan_skill)
yeyan_skill.getTurnUseCard = function(self)
	if self.player:getMark("@flame") == 0 then return end
	if not self:willShowForAttack() then return end
	self.yeyan_type = nil
	if self.player:getHandcardNum() >= 4 then
		local doNotDie = true
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if self:isFriendWith(p) then doNotDie = false break end  --没有队友时不能大业炎自杀
		end
	
		local spade, club, heart, diamond
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if card:getSuit() == sgs.Card_Spade then spade = true
			elseif card:getSuit() == sgs.Card_Club then club = true
			elseif card:getSuit() == sgs.Card_Heart then heart = true
			elseif card:getSuit() == sgs.Card_Diamond then diamond = true
			end
		end
		if spade and club and diamond and heart and (not doNotDie or self.player:getHp() + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") >= 4) then
			self:sort(self.enemies, "hp")
			local target_num = 0
			for _, enemy in ipairs(self.enemies) do
				if ((enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or enemy:hasShownSkill("Ranshang") or enemy:getHp() <= 3) and not enemy:isChained())
					or (enemy:isChained() and self:isGoodChainTarget(enemy, nil, nil, 3)) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
					target_num = target_num + 1
				end
			end

			if target_num >= 1 then
				self.yeyan_type = "Great"
				return sgs.Card_Parse("#YeyanCard:.:&Yeyan")
			end
		end
	end

	self.yeyanchained = false
	if self.player:getHp() + self:getCardsNum("Peach") + self:getCardsNum("Analeptic") <= 2 then
		self.yeyan_type = "Small"
		return sgs.Card_Parse("#YeyanCard:.:&Yeyan")
	end
	local target_num = 0
	local chained = 0
	for _, enemy in ipairs(self.enemies) do
		if ((enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or enemy:hasShownSkill("Ranshang")) or enemy:getHp() <= 1)
			and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
			target_num = target_num + 1
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if enemy:isChained() and self:isGoodChainTarget(enemy) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
			if chained == 0 then target_num = target_num +1 end
			chained = chained + 1
		end
	end
	self.yeyanchained = (chained > 1)
	if target_num > 2 or (target_num > 1 and self.yeyanchained) or
	(#self.enemies + 1 == self.room:alivePlayerCount() and self.room:alivePlayerCount() < sgs.Sanguosha:getPlayerCount(self.room:getMode())) then
		self.yeyan_type = "Small"
		return sgs.Card_Parse("#YeyanCard:.:&Yeyan")
	end
end
sgs.ai_skill_use_func["#YeyanCard"] = function(card, use, self)
	if not self.yeyan_type then return end
	if self.player:getMark("@flame") == 0 then return end
	
	local function useGreatYeyanCard(card, use, self)
		local cards = self.player:getHandcards()
		cards = sgs.QList2Table(cards)
		self:sortByUseValue(cards, true)
		local need_cards = {}
		local spade, club, heart, diamond
		local chains = {}
		for _, card in ipairs(cards) do
			if card:getSuit() == sgs.Card_Spade and not spade then spade = true table.insert(need_cards, card:getId())
			elseif card:getSuit() == sgs.Card_Club and not club then club = true table.insert(need_cards, card:getId())
			elseif card:getSuit() == sgs.Card_Heart and not heart then heart = true table.insert(need_cards, card:getId())
			elseif card:getSuit() == sgs.Card_Diamond and not diamond then diamond = true table.insert(need_cards, card:getId())
			end
			if isCard("IronChain", card, self.player) or isCard("FightTogether", card, self.player) then  --如果有铁索连环和勠力同心则优先使用
				table.insert(chains, card)
			end
		end
		if #need_cards < 4 then return false end
		local greatyeyan = sgs.Card_Parse("#YeyanCard:" .. table.concat(need_cards, "+") .. ":&Yeyan")
		assert(greatyeyan)

		local willUse = false
		repeat
			local first
			self:sort(self.enemies, "hp")
			for _, enemy in ipairs(self.enemies) do
				if not enemy:hasArmorEffect("silver_lion") and self:objectiveLevel(enemy) > 3 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
					and not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and enemy:isChained() and self:isGoodChainTarget(enemy, nil, nil, 3) then
					if enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 then  --todo：仇海链祸
						use.card = greatyeyan
						if use.to then
							use.to:append(enemy)
							use.to:append(enemy)
							use.to:append(enemy)
						end
						willUse = true
						break
					elseif not first then first = enemy end
				end
			end
			if willUse then break end
			if first then
				use.card = greatyeyan
				if use.to then
					use.to:append(first)
					use.to:append(first)
					use.to:append(first)
				end
				willUse = true
				break
			end

			local second
			for _, enemy in ipairs(self.enemies) do
				if not enemy:hasArmorEffect("silver_lion") and self:objectiveLevel(enemy) > 3 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
					and not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and not enemy:isChained() then
					if enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or enemy:hasShownSkill("Ranshang") then
						use.card = greatyeyan
						if use.to then
							use.to:append(enemy)
							use.to:append(enemy)
							use.to:append(enemy)
						end
						willUse = true
						break
					elseif not second then second = enemy end
				end
			end
			if willUse then break end
			if second then
				use.card = greatyeyan
				if use.to then
					use.to:append(second)
					use.to:append(second)
					use.to:append(second)
				end
				willUse = true
				break
			end
		until true
		
		if not willUse then return false end
		if use.isDummy then return true end
		self:sortByUseValue(chains)
		for _,chain in pairs(chains) do
			if table.contains(need_cards, chain:getId()) then continue end
			local dummy_use = sgs.CardUseStruct()
			self:useTrickCard(chain, dummy_use)
			if not dummy_use.card or not dummy_use.to then continue end
			if (chain:isKindOf("IronChain") and (dummy_use.to:length() == 0))
				or (chain:isKindOf("FightTogether") and self.FightTogether_choice == "recast") then continue end
			--todo：本应该考虑是否会对业炎目标造成影响（比如先连几个敌人再业炎，或者同心是否会误伤队友），但是代码太麻烦了就没写
			--if chain:isKindOf("IronChain") then
			--elseif chain:isKindOf("FightTogether") then
			--end
			use.card = chain
			if use.to then use.to = dummy_use.to end
			return true
		end
		return true
	end
	
	local function useSmallYeyanCard(card, use, self)
		if self.player:getMark("@flame") == 0 then return false end
		local targets = sgs.SPlayerList()
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
				and enemy:isChained() and self:isGoodChainTarget(enemy) and (enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0) then
				targets:append(enemy)
				if targets:length() >= 3 then break end
			end
		end
		if targets:length() < 3 then
			for _, enemy in ipairs(self.enemies) do
				if not targets:contains(enemy)
					and not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
					and enemy:isChained() and self:isGoodChainTarget(enemy) then
					targets:append(enemy)
					if targets:length() >= 3 then break end
				end
			end
		end
		if targets:length() < 3 then
			for _, enemy in ipairs(self.enemies) do
				if not targets:contains(enemy)
					and not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
					and not enemy:isChained() and (enemy:hasArmorEffect("vine") or enemy:getMark("@gale") > 0 or enemy:getMark("@gale_ShenZhuGeLiang") > 0 or enemy:hasShownSkill("Ranshang")) then
					targets:append(enemy)
					if targets:length() >= 3 then break end
				end
			end
		end
		if targets:length() < 3 then
			for _, enemy in ipairs(self.enemies) do
				if not targets:contains(enemy)
					and not (enemy:hasShownSkill("tianxiang") and enemy:getHandcardNum() > 0) and self:damageIsEffective(enemy, sgs.DamageStruct_Fire)
					and not enemy:isChained() then
					targets:append(enemy)
					if targets:length() >= 3 then break end
				end
			end
		end
		if targets:length() > 0 then
			use.card = card
			if use.to then use.to = targets end
			return true
		end
		return false
	end
	
	if self.yeyan_type == "Great" then
		if useGreatYeyanCard(card, use, self) then
			sgs.ai_use_value.YeyanCard = 8
			sgs.ai_use_priority.YeyanCard = 9
			sgs.ai_card_intention.YeyanCard = 200
		end
	elseif self.yeyan_type == "Small" then
		if useSmallYeyanCard(card, use, self) then
			sgs.ai_card_intention.YeyanCard = 80
			sgs.ai_use_priority.YeyanCard = 2.3
		end
	end
end

----------------------------------------------------------------------------------------------------

-- LE 004 神诸葛亮

-- 七星
sgs.ai_skill_exchange["#Qixing-show"] = function(self, pattern, max_num, min_num, expand_pile)
	local cards = sgs.QList2Table(self.player:getHandcards())
	local to_discard = {}
	local compare_func = function(a, b)
		return self:getKeepValue(a) < self:getKeepValue(b)
	end
	table.sort(cards, compare_func)
	for _, card in ipairs(cards) do
		if #to_discard >= min_num then break end
		table.insert(to_discard, card:getId())
	end

	return to_discard
end
sgs.ai_skill_cardask["@Qixing-exchange"] = function(self, data, pattern)
	local pile = self.player:getPile("stars")
	local piles = {}
	local cards = self.player:getHandcards()
	cards = sgs.QList2Table(cards)
	local max_num = math.min(pile:length(), #cards)
	if pile:isEmpty() or (#cards == 0) then
		return "."
	end
	for _, card_id in sgs.qlist(pile) do
		table.insert(piles, sgs.Sanguosha:getCard(card_id))
	end
	local exchange_to_pile = {}
	local exchange_to_handcard = {}
	self:sortByCardNeed(cards)
	self:sortByCardNeed(piles)
	for i = 1 , max_num, 1 do
		if #piles == 0 or #cards == 0 then break end  --理论上不该出现的啊……
		if self:cardNeed(piles[#piles]) > self:cardNeed(cards[1]) then					--todo：似乎有时会出现cardNeed中cards[1]为空的问题
			table.insert(exchange_to_handcard, piles[#piles])
			table.insert(exchange_to_pile, cards[1])
			table.removeOne(piles, piles[#piles])
			table.removeOne(cards, cards[1])
		else
			break
		end
	end
	if #exchange_to_handcard == 0 then return "." end
	local exchange = {}
	for _, id in sgs.qlist(pile) do
		table.insert(exchange, id)
	end

	for _, c in ipairs(exchange_to_handcard) do
		table.removeOne(exchange, c:getId())
	end

	for _, c in ipairs(exchange_to_pile) do
		table.insert(exchange, c:getId())
	end

	local dummy = sgs.DummyCard()
	for _,id in pairs(exchange) do
		dummy:addSubcard(id)
	end
	return dummy:toString()
end

-- 狂风
sgs.ai_skill_use["@@Kuangfeng"] = function(self,prompt)
	if self.player:getMark("ThreatenEmperorExtraTurn") > 0 and not self.player:isNude() then return "." end

	local friendly_fire
	for _, friend in ipairs(self.friends_noself) do
		if --[[friend:getMark("@gale") == 0 and friend:getMark("@gale_ShenZhuGeLiang") == 0 and self:damageIsEffective(friend, sgs.DamageStruct_Fire) and]] friend:faceUp() and not self:willSkipPlayPhase(friend)  --被括起来的部分莫名其妙，既然是判断友方是否有火焰伤害，数friend的狂风标记是干啥？
			and (friend:hasShownSkills("huoji|Longhun|RendeLB") or friend:hasWeapon("Fan") or (friend:hasShownSkill("Yeyan") and friend:getMark("@flame") > 0) or (friend:hasShownSkill("Fencheng") and friend:getMark("@burn") > 0)) then
			friendly_fire = true
			break
		end
	end
	
	local function canFriendlyFireTo(enemy)
		for _, friend in ipairs(self.friends_noself) do
			if friend:faceUp() and not self:willSkipPlayPhase(friend) then
				if friend:hasShownSkill("huoji") then
					if self:hasTrickEffective(sgs.cloneCard("fire_attack"), enemy, friend) then return true end
				end
				if friend:hasWeapon("Fan") or friend:hasShownSkill("Longhun|RendeLB") then
					if friend:canSlash(enemy) and self:slashIsEffective(sgs.cloneCard("fire_slash"), enemy, friend) then return true end
				end
				if friend:hasShownSkill("Yeyan") and friend:getMark("@flame") > 0 then
					if friend:getHandcardNum() + (self:willSkipDrawPhase() and 0 or 2) >= 5 then return true end
				end
				if friend:hasShownSkill("Fencheng") and friend:getMark("@burn") > 0 then
					if enemy:getCardCount(true) <= 3 then return true end
				end
				--break
			end
		end
	end

	local is_chained = 0
	local target = {}
	for _, enemy in ipairs(self.enemies) do
		if enemy:getMark("@gale") == 0 and enemy:getMark("@gale_ShenZhuGeLiang") == 0 and self:damageIsEffective(enemy, sgs.DamageStruct_Fire) then
			if enemy:hasArmorEffect("Vine") then  --藤甲和铁索判断顺序交换（两者都满足的情况）
				table.insert(target, 1, enemy)
				if enemy:isChained() then is_chained = is_chained + 1 end
				break
			elseif enemy:isChained() then
				is_chained = is_chained + 1
				table.insert(target, enemy)
			end
		end
	end
	local usecard = false
	if friendly_fire and is_chained > 1 then -- usecard = true end
		for _, enemy in ipairs(target) do
			if canFriendlyFireTo(enemy) then target[1] = enemy usecard = true break end
		end
	end
	self:sort(self.friends, "hp")
	if target[1] and not self:isWeak(self.friends[1]) then
		if target[1]:hasArmorEffect("Vine") and friendly_fire and canFriendlyFireTo(target[1]) then usecard = true end
	end
	if usecard then
		if not target[1] then table.insert(target,self.enemies[1]) end
		if target[1] then
			local s = {}
			for _,id in sgs.qlist(self.player:getPile("stars")) do
				table.insert(s, sgs.Sanguosha:getCard(id))
			end
			self:sortByCardNeed(s)
			--return "#KuangfengCard:" .. self.player:getPile("stars"):first() .. ":&Kuangfeng->" .. target[1]:objectName()
			return "#KuangfengCard:" .. s[1]:getId() .. ":&Kuangfeng->" .. target[1]:objectName()
		else
			return "." 
		end
	else
		return "."
	end
end
sgs.ai_card_intention.KuangfengCard = 80

-- 大雾
sgs.ai_skill_use["@@Dawu"] = function(self, prompt)
	if self.player:getMark("ThreatenEmperorExtraTurn") > 0 and not self.player:isNude() then return "." end
	
	self:sort(self.friends_noself, "hp")
	local targets = {}
	local lord = self.player:getLord()
	self:sort(self.friends_noself,"defense")
	if lord and lord:getMark("@fog") == 0 and lord:getMark("@fog_ShenZhuGeLiang") == 0 and self:isWeak(lord) and (lord:objectName() ~= self.player:objectName()) and not lord:hasShownSkills("buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15") then
		table.insert(targets, lord:objectName())
	else
		for _, friend in ipairs(self.friends_noself) do
			if friend:getMark("@fog") == 0 and friend:getMark("@fog_ShenZhuGeLiang") == 0 and self:isWeak(friend) and not friend:hasShownSkills("buqu|BuquRenew_ZhouTai_13|BuquRenew_ZhouTai_15") then
				table.insert(targets, friend:objectName())
				break
			end
		end
	end
	if self.player:getPile("stars"):length() > #targets and self:isWeak() then table.insert(targets, self.player:objectName()) end
	if #targets > 0 then
		--local s = sgs.QList2Table(self.player:getPile("stars"))
		local s_cards = {}
		for _,id in sgs.qlist(self.player:getPile("stars")) do
			table.insert(s_cards, sgs.Sanguosha:getCard(id))
		end
		self:sortByCardNeed(s_cards)
		local s = {}
		for _,cd in ipairs(s_cards) do
			table.insert(s, cd:getId())
		end
		local length = #targets
		for i = 1, #s - length do
			table.remove(s, #s)
		end
		return "#DawuCard:" .. table.concat(s, "+") .. ":&Dawu->" .. table.concat(targets, "+")
	end
	return "."
end
sgs.ai_card_intention.DawuCard = -70

----------------------------------------------------------------------------------------------------

-- LE 005 神曹操

-- 归心
sgs.ai_skill_invoke.Guixin = function(self, data)
	local damage = data:toDamage()
	--local diaochan = self.room:findPlayerBySkillName("lihun")
	--local lihun_eff = (diaochan and self:isEnemy(diaochan))
	--local manjuan_eff = hasManjuanEffect(self.player)
	--if lihun_eff and not manjuan_eff then return false end
	if not self.player:faceUp() then return true
	else
		--if manjuan_eff then return false end
		local value = 0
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			value = value + self:getGuixinValue(player)
		end
		local left_num = damage.damage - self.player:getMark("GuixinTimes")
		return value >= 1.3 or left_num > 0
	end
end
sgs.ai_need_damaged.Guixin = function(self, attacker, player)
	if not self:toTurnOver(player) then return true end
	if self.room:alivePlayerCount() <= 3 --[[or hasManjuanEffect(self.player)]] then return false end
	--local diaochan = self.room:findPlayerBySkillName("lihun")
	local drawcards = 0
	for _, aplayer in sgs.qlist(self.room:getOtherPlayers(player)) do
		if aplayer:getCards("hej"):length() > 0 then drawcards = drawcards + 1 end
	end
	--return not self:isLihunTarget(player, drawcards)
	return drawcards > 0
end

-- 飞影

----------------------------------------------------------------------------------------------------

-- LE 006 神吕布

-- 狂暴
sgs.ai_skill_invoke.Kuangbao = function(self, data)
	if not willShowWumou(self) then return false end
	return self:willShowForAttack()
end

-- 无谋
function willShowWumou(self)
	if self.player:hasShownSkill("Wumou") or not self.player:hasSkill("Wumou") then return true end
	if not self.player:hasSkills("Kuangbao+Wuqian|Kuangbao+Shenfen") then return false end
	local cards = sgs.QList2Table(self.player:getHandcards())
	local tricks = {}
	for _,card in ipairs(cards) do
		if isCard("TrickCard", card, self.player) and not isCard("DelayedTrick", card, self.player) then 
			table.insert(tricks, card)
		end
	end
	if #tricks == 0 then return true end
	if self:needToLoseHp() then return true end
	
	self:sortByUseValue(tricks)
	local card = tricks[1]
	return self:getUseValue(card) <= 5
end
sgs.ai_skill_invoke.Wumou = function(self, data)
	if not willShowWumou(self) or not self:willShowForAttack() then return false end
	return self:needToLoseHp()
end
sgs.ai_skill_choice.Wumou = function(self, choices)
	if self:needToLoseHp() then return "losehp" end
	if self.player:getMark("@wrath") > 6 then return "discard" end
	if self.player:getHp() + self:getCardsNum("Peach") > 3 then return "losehp"
	else return "discard"
	end
end

-- 无前
local wuqian_skill = {}
wuqian_skill.name = "Wuqian"
table.insert(sgs.ai_skills, wuqian_skill)
wuqian_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#WuqianCard") or self.player:getMark("@wrath") < 2 or not self:willShowForAttack() then return end
	return sgs.Card_Parse("#WuqianCard:.:&Wuqian")
end
sgs.ai_skill_use_func["#WuqianCard"] = function(wuqiancard, use, self)
	if self:getCardsNum("Slash") > 0 and not self.player:hasSkills("wushuang|wushuang_LyuBu_LB|wushuang_ShenLyuBu") then
		for _, card in sgs.qlist(self.player:getHandcards()) do
			if isCard("Duel", card, self.player) then
				local dummy_use = { isDummy = true, isWuqian = true, to = sgs.SPlayerList() }
				local duel = sgs.Sanguosha:cloneCard("duel", card:getSuit(), card:getNumber())
				self:useCardDuel(duel, dummy_use)
				if dummy_use.card and dummy_use.to:length() > 0 and (self:isWeak(dummy_use.to:first()) and dummy_use.to:first():getHp() == 1 or dummy_use.to:length() > 1) then
					use.card = wuqiancard
					if use.to then use.to:append(dummy_use.to:first()) end
					return
				end
			end
		end
	end
end
sgs.ai_use_value.WuqianCard = 5
sgs.ai_use_priority.WuqianCard = 10
sgs.ai_card_intention.WuqianCard = 80

-- 神愤
local shenfen_skill = {}
shenfen_skill.name = "Shenfen"
table.insert(sgs.ai_skills, shenfen_skill)
shenfen_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#ShenfenCard") or self.player:getMark("@wrath") < 6 or not self:willShowForAttack() then return end
	return sgs.Card_Parse("#ShenfenCard:.:&Shenfen")
end
function SmartAI:getSaveNum(isFriend)
	local num = 0
	for _, player in sgs.qlist(self.room:getAllPlayers()) do
		if (isFriend and self:isFriend(player)) or (not isFriend and self:isEnemy(player)) then
			if not self.player:hasSkill("wansha") or player:objectName() == self.player:objectName() then
				if player:hasShownSkills("jijiu|jijiu_HuaTuo_LB") and player:getPhase() == sgs.Player_NotActive then
					num = num + self:getSuitNum("heart", true, player)
					num = num + self:getSuitNum("diamond", true, player)
					num = num + player:getHandcardNum() * 0.4
				end
				--[[if player:hasSkill("nosjiefan") and getCardsNum("Slash", player, self.player) > 0 then
					if self:isFriend(player) or self:getCardsNum("Jink") == 0 then num = num + getCardsNum("Slash", player, self.player) end
				end]]
				num = num + getCardsNum("Peach", player, self.player)
			end
			if player:hasShownSkill("Buyi") and not player:isKongcheng() then num = num + 0.3 end
			if player:hasShownSkill("Chunlao") and not player:getPile("wine"):isEmpty() then num = num + player:getPile("wine"):length() end
			--[[if self:hasSkill("jiuzhu", player) and player:getHp() > 1 and not player:isNude() then
				num = num + 0.9 * math.max(0, math.min(player:getHp() - 1, player:getCardCount()))
			end]]
			--if player:hasSkill("renxin") and player:objectName() ~= self.player:objectName() and not player:isKongcheng() then num = num + 1 end
			if player:hasShownSkill("Renxin") then num = num + getKnownCard(player, self.player, "EquipCard", false, "h") + player:getEquips():length() end
			if player:getHp() == 1 and player:hasArmorEffect("Breastplate") then num = num + 1 end
		end
	end
	return num
end
function SmartAI:canSaveSelf(player)
	if hasBuquEffect(player) then return true end
	if hasNiepanEffect(player) then return true end
	if player:isRemoved() then return false end
	if getCardsNum("Analeptic", player, self.player) > 0 then return true end
	if player:hasShownSkill("Jiushi") and player:faceUp() then return true end
	--[[if player:hasSkill("jiuchi") then
		for _, c in sgs.qlist(player:getHandcards()) do
			if c:getSuit() == sgs.Card_Spade then return true end
		end
	end]]
	return false
end
local function getShenfenUseValueOfHECards(self, to)
	local value = 0
	-- value of handcards
	local value_h = 0
	local hcard = to:getHandcardNum()
	if to:hasShownSkill("Lianying") then
		hcard = hcard - 0.9
	elseif to:hasShownSkill("Shangshi") then
		hcard = hcard - 0.9 * to:getLostHp()
	else
		local jwfy = sgs.findPlayerByShownSkillName("shoucheng")
		if jwfy and jwfy:isFriendWith(to) and (not self:isWeak(jwfy) or jwfy:getHp() > 1) then hcard = hcard - 0.9 end
	end
	if to:hasArmorEffect("PeaceSpell") and to:getHp() > 2 then hcard = hcard + 2 end
	value_h = (hcard > 4) and 16 / hcard or hcard
	if to:hasShownSkill("tuntian") then value_h = value_h * 0.95 end
	if to:hasShownSkill("kongcheng") and not to:isKongcheng() then value_h = value_h * 0.7 end
	if to:hasShownSkill("lirang") then value_h = value_h * 0.6 end
	--if self:hasSkill("jijiu|jijiu_HuaTuo_LB|qingnang|leiji|jieyin|beige|kanpo|liuli|qiaobian|zhiheng|guidao|longhun|xuanfeng|tianxiang|noslijian|lijian", to) then value_h = value_h * 0.95 end
	if to:hasShownSkills(sgs.cardneed_skill) then value_h = value_h * 1.1 end
	value = value + value_h

	-- value of equips
	local value_e = 0
	local equip_num = to:getEquips():length()
	if to:hasArmorEffect("SilverLion") and to:isWounded() then equip_num = equip_num - 1.1 end
	value_e = equip_num * 1.1
	if to:hasShownSkills(sgs.lose_equip_skill) then value_e = value_e * 0.7 end
	if to:hasShownSkills(sgs.viewhas_armor_skill) and to:getArmor() then value_e = value_e - 1 end
	if to:hasArmorEffect("PeaceSpell") and to:getHp() > 1 then value_e = value_e + 1 end
	value = value + value_e

	return value
end
local function getDangerousShenGuanYu(self)
	local most = -100
	local target
	for _, player in sgs.qlist(self.room:getAllPlayers()) do
		local nm_mark = player:getMark("@nightmare")
		if player:objectName() == self.player:objectName() then nm_mark = nm_mark + 1 end
		if nm_mark > 0 and nm_mark > most or (nm_mark == most and self:isEnemy(player)) then
			most = nm_mark
			target = player
		end
	end
	if target and self:isEnemy(target) then return true end
	return false
end
sgs.ai_skill_use_func["#ShenfenCard"] = function(card, use, self)
	if self.player:getLord() and self:isWeak(self.player:getLord()) and not self.player:isLord() then return end
	local benefit = 0
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:isFriend(player) then benefit = benefit - getShenfenUseValueOfHECards(self, player) end
		if self:isEnemy(player) then benefit = benefit + getShenfenUseValueOfHECards(self, player) end
	end
	local friend_save_num = self:getSaveNum(true)
	local enemy_save_num = self:getSaveNum(false)
	local others = 0
	for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if self:damageIsEffective(player, sgs.DamageStruct_Normal) then
			others = others + 1
			local value_d = 3.5 / math.max(player:getHp(), 1)
			if player:getHp() <= 1 or (player:getHp() == 2 and player:hasArmorEffect("PeaceSpell")) then
				if player:hasShownSkill("Wuhun") then
					local can_use = getDangerousShenGuanYu(self)
					if not can_use then return else value_d = value_d * 0.1 end
				end
				if self:canSaveSelf(player) then
					value_d = value_d * 0.9
				elseif self:isFriend(player) and friend_save_num > 0 and not player:isRemoved() then
					friend_save_num = friend_save_num - 1
					value_d = value_d * 0.9
				elseif self:isEnemy(player) and enemy_save_num > 0 and not player:isRemoved() then
					enemy_save_num = enemy_save_num - 1
					value_d = value_d * 0.9
				end
			end
			if player:hasShownSkills("fankui|FankuiLB") then value_d = value_d * 0.8 end
			if player:hasShownSkill("Guixin") then
				if not player:faceUp() then
					value_d = value_d * 0.4
				else
					value_d = value_d * 0.8 * (1.05 - self.room:alivePlayerCount() / 15)
				end
			end
			if self:getDamagedEffects(player, self.player) or self:needToLoseHp(player) then value_d = value_d * 0.8 end
			if self:isFriend(player) then benefit = benefit - value_d end
			if self:isEnemy(player) then benefit = benefit + value_d end
		end
	end
	--if not self.player:faceUp() or self.player:hasSkills("jushou|nosjushou|neojushou|kuiwei") then
	if not self.player:faceUp() or self.player:hasSkills("jushou|Jushou13|Jushou15|Jiushi") then
		benefit = benefit + 1
	else
		local help_friend = false
		for _, friend in ipairs(self.friends_noself) do
			--if self:hasSkill("fangzhu|Jilyue", friend) then
			if friend:hasShownSkill("fangzhu") then
				help_friend = true
				benefit = benefit + 1
				break
			end
		end
		if not help_friend then benefit = benefit - 0.5 end
	end
	benefit = benefit + (others - 7) * 0.05
	if benefit > 0 then
		use.card = card
	end
end
sgs.ai_use_value.ShenfenCard = 8
sgs.ai_use_priority.ShenfenCard = 5.3
sgs.dynamic_value.damage_card.ShenfenCard = true
sgs.dynamic_value.control_card.ShenfenCard = true

----------------------------------------------------------------------------------------------------

-- LE 007 神赵云

-- 绝境
function getJuejingLostHp(player)
	if not player:hasSkill("Juejing") then return 0 end
	local lost_hp = player:getLostHp()
	if player:ownSkill("Juejing") and not player:hasShownSkill("Juejing") and player:getMark("Juejing") == 0 then  --防止化身，只能新开函数处理了
		lost_hp = math.max(lost_hp - 1, 0)
	end
	return lost_hp
end
sgs.ai_skill_invoke.Juejing = function(self, data)
	if not self:willShowForAttack() and not self:willShowForDefence() then
		return false
	end
	if getJuejingLostHp(self.player) <= 0 then return false end
	if self.player:hasFlag("haoshi") then
		local invoke = self.player:getTag("haoshi_Juejing"):toBool()
		self.player:removeTag("haoshi_Juejing")
		if not invoke then return false end
		local extra = self.player:getMark("haoshi_num")
		if self.player:hasShownOneGeneral() and not self.player:hasShownSkill("Juejing") and self.player:getMark("HalfMaxHpLeft") > 0 then
			extra = extra + 1
		end
		if self.player:hasShownOneGeneral() and not self.player:isWounded()	and not self.player:hasShownSkill("Juejing") and player:getMark("CompanionEffect") > 0 then
			extra = extra + 2
		end
		if self.player:getHandcardNum() + extra <= 1 or self.haoshi_target then
			self.player:setMark("haoshi_num", extra)
			return true
		end
		return false
	end
	return true
end
sgs.ai_skill_invoke["#Juejing_showmaxcards"] = function(self, data)
	if not self:willShowForDefence() then return false end
	return self:getOverflow() > 0  --亮将只会减1点体力上限，因此至少会有手牌上限+1
end

-- 龙魂
local longhun_skill = {}
longhun_skill.name = "Longhun"
table.insert(sgs.ai_skills, longhun_skill)
longhun_skill.getTurnUseCard = function(self)
	if self.player:getHp() > 1 then return end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards,true)
	for _, card in ipairs(cards) do
		if card:getSuit() == sgs.Card_Diamond and self:slashIsAvailable() then
			return sgs.Card_Parse(("fire_slash:Longhun[%s:%s]=%d&Longhun"):format(card:getSuitString(), card:getNumberString(), card:getId()))
		end
	end
end
sgs.ai_view_as.Longhun = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if player:getHp() > 1 or (card_place == sgs.Player_PlaceSpecial and not player:getHandPile():contains(card_id)) or card:hasFlag("using") then return end
	if card:getSuit() == sgs.Card_Diamond then
		return ("fire_slash:Longhun[%s:%s]=%d&Longhun"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Club then
		return ("jink:Longhun[%s:%s]=%d&Longhun"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Heart and player:getMark("Global_PreventPeach") == 0 then
		return ("peach:Longhun[%s:%s]=%d&Longhun"):format(suit, number, card_id)
	elseif card:getSuit() == sgs.Card_Spade then
		return ("nullification:Longhun[%s:%s]=%d&Longhun"):format(suit, number, card_id)
	end
end
sgs.Longhun_suit_value = {
	heart = 6.7,
	spade = 5,
	club = 4.2,
	diamond = 3.9,
}
function sgs.ai_cardneed.Longhun(to, card, self)
	if to:getCardCount(true) > 3 then return false end
	if to:isNude() then return true end
	return card:getSuit() == sgs.Card_Heart or card:getSuit() == sgs.Card_Spade
end
sgs.ai_suit_priority.Longhun = "diamond|club|spade|heart"

----------------------------------------------一将成名----------------------------------------------

-- YJ 001 曹植

-- 落英
sgs.ai_skill_exchange.Luoying = function(self, pattern, max_num, min_num, expand_pile)
	local willShow = self:willShowForAttack() or self:willShowForDefence()
	
	if self.player:hasFlag("DimengTarget") then
		local another
		for _, player in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if player:hasFlag("DimengTarget") then
				another = player
				break
			end
		end
		if not another or not self:isFriend(another) then return {} end
	end
	
	if not self:needKongcheng(self.player, true) then
		local card_ids = self.player:property("LuoyingToGet"):toString():split("+")
		local result = {}
		for _,idstr in ipairs(card_ids) do
			table.insert(result, tonumber(idstr))
			local card = sgs.Sanguosha:getCard(tonumber(idstr))
			if isCard("Slash", card, self.player) and self:hasCrossbowEffect() then willShow = true
			elseif card:isKindOf("Armor") and self:evaluateArmor(card) > self:evaluateArmor() + 1 then willShow = true
			elseif card:isKindOf("JadeSeal") then willShow = true end
		end
		if willShow then
			return result
		end
	end
	return {}
end

-- 酒诗
function sgs.ai_cardsview_value.Jiushi(self, class_name, player)
	if class_name == "Analeptic" then  --注：ai_cardsview相关函数只会对自己触发，不用担心ShownSkill
		if player:hasSkill("Jiushi") and player:faceUp() then
			local peaches = 0  --有桃且暂时不会到自己回合，则先酒诗，争取之后用真桃翻回来
			local cards = sgs.QList2Table(player:getHandcards())
			for _, id in sgs.qlist(player:getHandPile()) do
				table.insert(cards, sgs.Sanguosha:getCard(id))
			end
			for _, card in ipairs(cards) do
				if (card:isKindOf("Peach") or card:isKindOf("Analeptic")) and not self.player:isLocked(card) then peaches = peaches + 1 end
			end
			
			if (player:hasSkills("jushou|Jushou_13") and player:getPhase() < sgs.Player_Finish)
				or (player:hasFlag("Global_Dying") and peaches > 0 and self:getEnemyNumBySeat(self.room:getCurrent(), self.player, self.player) >= 2) then
				return ("analeptic:Jiushi[no_suit:0]=.&Jiushi")
			end
		end
	end
end
function sgs.ai_cardsview.Jiushi(self, class_name, player)
	if class_name == "Analeptic" then
		if player:hasSkill("Jiushi") and player:faceUp() then
			return ("analeptic:Jiushi[no_suit:0]=.&Jiushi")
		end
	end
end
local jiushi_skill = {}
jiushi_skill.name = "Jiushi"
table.insert(sgs.ai_skills, jiushi_skill)
jiushi_skill.getTurnUseCard = function(self, inclusive)  --酒诗据守
	if self.player:hasSkills("jushou|Jushou_13") and self.player:faceUp() then
		return sgs.Card_Parse("analeptic:Jiushi[no_suit:0]=.&Jiushi")
	end
end
function sgs.ai_skill_invoke.Jiushi(self, data)
	return not self.player:faceUp()
end
sgs.ai_need_damaged.Jiushi = function(self, attacker, player)
	return player:hasShownSkill("Jiushi") and not self:toTurnOver(player) and not self:isWeak(player)
end

----------------------------------------------------------------------------------------------------

-- YJ 002 陈宫

-- 明策
mingce_skill = {}
mingce_skill.name = "Mingce"
table.insert(sgs.ai_skills, mingce_skill)
mingce_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#MingceCard") then return end
	if not self:willShowForAttack() then return end

	local card
	if self:needToThrowArmor() then
		card = self.player:getArmor()
	end
	if not card then
		local hcards = self.player:getCards("h")
		hcards = sgs.QList2Table(hcards)
		self:sortByUseValue(hcards, true)

		for _, hcard in ipairs(hcards) do
			if hcard:isKindOf("Slash") then
				if self:getCardsNum("Slash") > 1 then
					card = hcard
					break
				else
					local dummy_use = { isDummy = true, to = sgs.SPlayerList() }
					self:useBasicCard(hcard, dummy_use)
					if dummy_use and dummy_use.to and (dummy_use.to:length() == 0
							or (dummy_use.to:length() == 1 and not self:hasHeavySlashDamage(self.player, hcard, dummy_use.to:first()))) then
						card = hcard
						break
					end
				end
			elseif hcard:isKindOf("EquipCard") then
				card = hcard
				break
			end
		end
	end
	if not card then
		local ecards = self.player:getCards("e")
		ecards = sgs.QList2Table(ecards)

		for _, ecard in ipairs(ecards) do
			if ecard:isKindOf("Weapon") or ecard:isKindOf("OffensiveHorse") then
				card = ecard
				break
			end
		end
	end
	if card then
		card = sgs.Card_Parse("#MingceCard:" .. card:getEffectiveId() .. ":&Mingce")
		return card
	end

	return nil
end
sgs.ai_skill_use_func["#MingceCard"] = function(card, use, self)
	local target
	local friends = self.friends_noself
	local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
	local slash_target

	local canMingceTo = function(player)
		local canGive = not self:needKongcheng(player, true)
		return canGive or (not canGive and self:getEnemyNumBySeat(self.player, player) == 0)
	end

	local real_card = sgs.Sanguosha:getCard(card:getEffectiveId())
	self:sort(self.enemies, "defense")
	local _, friend = self:getCardNeedPlayer({real_card}, friends, "Mingce")
	if friend and self:isFriend(friend) and canMingceTo(friend) then
		for _, enemy in ipairs(self.enemies) do
			if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
					and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
					and enemy:objectName() ~= self.player:objectName() then
				target = friend
				slash_target = enemy
				break
			end
		end
	end
	
	if not target then
		for _, friend in ipairs(friends) do
			if canMingceTo(friend) then
				for _, enemy in ipairs(self.enemies) do
					if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2
							and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self)
							and enemy:objectName() ~= self.player:objectName() then
						target = friend
						slash_target = enemy
						break
					end
				end
			end
			if target then break end
		end
	end

	if not target then
		self:sort(friends, "defense")
		local _, friend = self:getCardNeedPlayer({real_card}, friends, "Mingce")
		if friend and self:isFriend(friend) and canMingceTo(friend) then  --getCardNeedPlayer可能破空城
			target = friend
		end
	end

	if not target then
		self:sort(friends, "defense")
		for _, friend in ipairs(friends) do
			if canMingceTo(friend) then
				target = friend
				break
			end
		end
	end

	if target then
		use.card = card
		if use.to then
			use.to:append(target)
			if not slash_target then
				local slash_targets = sgs.SPlayerList()
				if self:slashIsAvailable(target) then
					for _, p in sgs.qlist(self.room:getOtherPlayers(target)) do
						if target:canSlash(p) then
							slash_targets:append(p)
						end
					end
				end
				if not slash_targets:isEmpty() then
					slash_target = sgs.ai_skill_playerchosen.zero_card_as_slash(self, slash_targets)
				end
			end
			if slash_target then
				use.to:append(slash_target)
			end
		end
	end
end
sgs.ai_skill_choice.Mingce = function(self, choices)
	--local chengong = self.room:getCurrent()
	local chengong = sgs.findPlayerByShownSkillName("Mingce")  --防明鉴
	if chengong and not self:isFriend(chengong) then return "draw" end
	if not string.find(choices, "use") then return "draw" end  --防特殊情况（比如未通过二次合法性检测）
	local target = self.player:getTag("MingceTarget"):toPlayer()
	if not target then return "draw" end
	if not self:isFriend(target) then
		local slash = sgs.Sanguosha:cloneCard("slash", sgs.Card_NoSuit, 0)
		if not self:slashProhibit(slash, target) then return "use" end
	end
	return "draw"
end
sgs.ai_use_value.MingceCard = 5.9
sgs.ai_use_priority.MingceCard = 4
sgs.ai_card_intention.MingceCard = function(self, card, from, tos)
	sgs.updateIntention(from, tos[1], -70)
end
sgs.ai_cardneed.Mingce = sgs.ai_cardneed.equip

-- 智迟
sgs.ai_skill_invoke.Zhichi = function(self, data)
	local current = self.room:getCurrent()
	if not current or current:isDead() then return false end
	
	--来自潜心
	local threat = getCardsNum("SavageAssault", current, self.player) + getCardsNum("ArcheryAttack", current, self.player)
	if not self:isFriend(current) then
		threat = threat + getCardsNum("Duel", current, self.player)
		if self:slashIsAvailable(current) and current:canSlash(self.player) and getCardsNum("Slash", current, self.player) > 0 then
			threat = threat + (self:hasCrossbowEffect(current) and getCardsNum("Slash", current, self.player) or 1)
		end
		if not self.player:isNude() then
			threat = threat + getCardsNum("Dismantlement", current, self.player)
			if current:distanceTo(self.player) == 1 or current:hasShownSkill("qicai") then
				threat = threat + getCardsNum("Snatch", current, self.player)
			end
		end
		if not self.player:getEquips():isEmpty() and not self:needToThrowArmor() then
			threat = threat + getCardsNum("Drowning", current, self.player)
		end
		if current:getNextAlive() and self.player:inFormationRalation(current:getNextAlive()) then  --Ralation醉了
			threat = threat + getCardsNum("BurningCamps", current, self.player)
		end
	end
	if threat >= 1 --[[and not self.player:hasSkill("Shibei")]] then return true end
	
	local benefit = getCardsNum("AmazingGrace", current, self.player)
	if self.player:isWounded() then
		benefit = benefit + getCardsNum("GodSalvation", current, self.player)
	end
	if self:isFriend(current) then
		if (self.player:containsTrick("indulgence") or self.player:containsTrick("supply_shortage")) then
			benefit = benefit + getCardsNum("Dismantlement", current, self.player)
			if current:distanceTo(self.player) == 1 or current:hasShownSkill("qicai") then
				benefit = benefit + getCardsNum("Snatch", current, self.player)
			end
		end
		local slash = sgs.cloneCard("slash")  --防止isPriorFriendOfSlash报错
		if self:isPriorFriendOfSlash(self.player, slash, current) and current:canSlash(self.player) and self:slashIsAvailable(current) and getCardsNum("Slash", current, self.player) > 0 then
			benefit = benefit + (self:hasCrossbowEffect(current) and getCardsNum("Slash", current, self.player) or 1)
		end
	end
	
	return self:willShowForDefence() and benefit < 1
end

--写法正严白虎时注意：askForCardsChosen的接口似乎仅存在于新版本
--------------------------------------------一将成名2012--------------------------------------------

--------------------------------------------一将成名2013--------------------------------------------

-- YJ 201 曹冲

-- 称象
sgs.ai_skill_invoke.Chengxiang = function(self)
	if not self:willShowForMasochism() then return false end
	return not self:needKongcheng(self.player, true)
end
function ChengxiangDFS(cards, current, i)
	if i > #cards then return {} end
	local result = {}
	local temp = (current ~= "") and current:split("+") or {}
	table.insertTable(result, ChengxiangDFS(cards, current, i + 1))
	
	local temp_int = {}
	for _,id_str in ipairs(temp) do
		table.insert(temp_int, tonumber(id_str))
	end
	if ChengxiangAsMovePattern(temp_int, cards[i]) then
		table.insert(temp, cards[i])
		table.insert(result, table.concat(temp, "+"))
		table.insertTable(result, ChengxiangDFS(cards, table.concat(temp, "+"), i + 1))
	end
	return result
end
function evaluateChengxiangCards(self, card_str)
	if card_str == "" then return 0 end
	local cards = card_str:split("+")
	local sum = 0
	for _,id in ipairs(cards) do
		sum = sum + self:cardNeed(sgs.Sanguosha:getCard(tonumber(id)))
	end
	return sum
end
function sortChengxiangChoicesByCardNeed(self, choices, inverse)
	local values = {}
	for _, choice in ipairs(choices) do
		values[choice] = evaluateChengxiangCards(self, choice)
	end

	local compare_func = function(a,b)
		local value1 = values[a]
		local value2 = values[b]

		if value1 ~= value2 then
			if inverse then return value1 > value2 end
			return value1 < value2
		else  --牌数
			local a_tab = a:split("+")
			local b_tab = b:split("+")
			if inverse then return #a_tab > #b_tab end
			return #a_tab < #b_tab
		end
	end

	table.sort(choices, compare_func)
	
	--已知bug：排序时是按未拿到手时单独地判断每张牌，如果第二张牌的need会随第一张牌的到手而减少则不会识别出来
	--例如有时会拿2闪而不是1闪1酒，即使拿了1闪以后闪的need比酒低
end
sgs.ai_skill_movecards.Chengxiang = function(self, upcards, downcards, min_num, max_num)
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	
	local choices = ChengxiangDFS(upcards, "", 1)
	sortChengxiangChoicesByCardNeed(self, choices)
	for _,id_str in ipairs(choices[#choices]:split("+")) do
		table.insert(down, tonumber(id_str))
		table.removeAll(upcards_copy, tonumber(id_str))
	end
	
	return upcards_copy, down
end

-- 仁心
sgs.ai_skill_cardask["@Renxin-card"] = function(self, data, pattern)
	local dmg = data:toDamage()
	if not self:willShowForDefence() and not self.player:willBeFriendWith(dmg.to) then return "." end  --同势力的就不管亮没亮将了，先救了再说
	local invoke
	if self:isFriend(dmg.to) then
		if self:damageIsEffective_(dmg) and not self:getDamagedEffects(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash"))
			and not self:needToLoseHp(dmg.to, dmg.from, dmg.card and dmg.card:isKindOf("Slash")) then
			invoke = true
		elseif not self:toTurnOver(self.player) then
			invoke = true
		end
	elseif self:objectiveLevel(dmg.to) == 0 and not self:toTurnOver(self.player) then
		invoke = true
	end
	if invoke then
		local equipCards = {}
		for _, c in sgs.qlist(self.player:getCards("he")) do
			if c:isKindOf("EquipCard") and self.player:canDiscard(self.player, c:getEffectiveId()) then
				table.insert(equipCards, c)
			end
		end
		if #equipCards > 0 then
			self:sortByKeepValue(equipCards)
			return equipCards[1]:getEffectiveId()
		end
	end
	return "."
end
sgs.ai_cardneed.Renxin = function(to, card, self)
	for _,friend in ipairs(self.friends_noself) do
		if self:isWeak(friend) then
			return sgs.ai_cardneed.shensu(to, card, self)
		end
	end
end
function SmartAI:hasRenxinEffect(to, from, needFaceDown, damageNum, isSlash, slash, nature, simulateDamage)  --检测是否会导致无意义的酒杀之类
	if isSlash and (not slash or not slash:isKindOf("Slash")) then
		slash = self.player:objectName() == from:objectName() and self:getCard("Slash") or sgs.cloneCard("slash")
	end
	local damageStruct = {}
	damageStruct.to = to or self.player
	damageStruct.from = from or self.room:getCurrent()
	damageStruct.nature = nature or sgs.DamageStruct_Normal
	damageStruct.damage = damageNum or 1
	damageStruct.card = slash
	if slash and not nature then
		if slash:isKindOf("FireSlash") then
			damageStruct.nature = sgs.DamageStruct_Fire
		elseif slash:isKindOf("ThunderSlash") then
			damageStruct.nature = sgs.DamageStruct_Thunder
		end
	end
	return self:hasRenxinEffect_(damageStruct, needFaceDown, simulateDamage)  --needFaceDown表示只考虑叠置的曹冲翻回来的情况（因为cost比较伤），但是实际上用到的地方全是false。。
end
function SmartAI:hasRenxinEffect_(damageStruct, needFaceDown, simulateDamage)
	if type(damageStruct) ~= "table" and type(damageStruct) ~= "DamageStruct" and type(damageStruct) ~= "userdata" then self.room:writeToConsole(debug.traceback()) return end
	if not damageStruct.to then self.room:writeToConsole(debug.traceback()) return end
	local to = damageStruct.to
	if to:hasFlag("AI_RenxinTesting") then return false end
	if to:getHp() ~= 1 then return false end
	local nature = damageStruct.nature or sgs.DamageStruct_Normal
	local damage = damageStruct.damage or 1
	local from = damageStruct.from
	local card = damageStruct.card
	--if from:hasShownSkill("Jueqing") then return false end
	
	local caochong = sgs.findPlayerByShownSkillName("Renxin")
	if not caochong or (caochong:objectName() == to:objectName()) or not self:isFriend(caochong, to) then return false end
	if getKnownCard(caochong, self.player, "EquipCard", false, "h") + caochong:getEquips():length() < 1 then return false end  --cardIsVisible判断有问题
	local equips = getKnownCard(caochong, self.player, "EquipCard", false, "he", true)
	if next(equips) and caochong:isJilei(equips[1]) then return false end
	
	if not self:toTurnOver(caochong) then return true end
	if needFaceDown then return false end
	
	if simulateDamage then  --抄hasHeavySlashDamage、damageIsEffective_
		if card and card:isKindOf("Slash") then
			if (card and card:hasFlag("drank")) then
				damage = damage + 1
			elseif from:getMark("drank") > 0 then
				damage = damage + from:getMark("drank")
			end
		end
		--if from:hasShownSkill("Jueqing") then return false end
		
		if to:getMark("@gale") > 0 and nature == sgs.DamageStruct_Fire then damage = damage + 1 end
		if to:getMark("@gale_ShenZhuGeLiang") > 0 and nature == sgs.DamageStruct_Fire then damage = damage + 1 end
	
		if card and card:isKindOf("Slash") then
			if from:hasFlag("luoyi") then damage = damage + 1 end
			if from:getMark("@LuoyiLB") > 0 then damage = damage + from:getMark("@LuoyiLB") end
			if from:hasShownSkill("Anjian") and not to:inMyAttackRange(from) then damage = damage + 1 end
			if from:hasWeapon("GudingBlade") and slash and to:isKongcheng() then damage = damage + 1 end
		elseif card and card:isKindOf("Duel") then
			if from:hasFlag("luoyi") then damage = damage + 1 end
			if from:getMark("@LuoyiLB") > 0 then damage = damage + from:getMark("@LuoyiLB") end
		end
		
		if to:hasShownSkill("mingshi") and from and not from:hasShownAllGenerals() then
			damage = damage - 1
		end
		if to:hasShownSkills("jgyuhuo_pangtong|jgyuhuo_zhuque") and nature == sgs.DamageStruct_Fire then return false end
		local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
		if jiaren_zidan and jiaren_zidan:isFriendWith(to) then
			damage = 1
		end
	end
	
	if to:hasArmorEffect("PeaceSpell") and not IgnoreArmor(from, to) and not (from:hasWeapon("IceSword") and card and card:isKindOf("Slash")) and not from:hasShownSkills("zhiman|zhiman_GuanSuo") and nature ~= sgs.DamageStruct_Normal then return false end
	if to:hasArmorEffect("Breastplate") and not IgnoreArmor(from, to) then return false end  --此时体力值为1，因此必能发动护心镜
	if to:hasArmorEffect("Vine") and not IgnoreArmor(from, to) and nature == sgs.DamageStruct_Fire then
		damage = damage + 1
	end
	if to:hasArmorEffect("SilverLion") and not IgnoreArmor(from, to) then
		damage = 1
	end
	if damage > 1 then return true end  --伤害大于1点则曹冲必须仁心
	if damage < 1 then return false end
	
	--if self:needToThrowArmor(caochong) or (caochong:hasShownSkills(sgs.lose_equip_skill) and caochong:canDiscard(caochong, "e")) then return true end
	return false  --此函数目的仅仅是检测酒杀之类，因此不用考虑曹冲翻面是否值得等情况
end
sgs.Renxin_keep_value = sgs.xiaoji_keep_value

----------------------------------------------------------------------------------------------------

-- YJ 202 伏皇后

-- 惴恐
sgs.ai_skill_invoke.Zhuikong = function(self, data)
	if not self:willShowForAttack() then return false end
	if self.player:getHandcardNum() <= (self:isWeak() and 2 or 1) then return false end
	local current = self.room:getCurrent()
	if (not current) or (not self:isEnemy(current)) or current:isSkipped(sgs.Player_Play) or self:willSkipPlayPhase(current) then return false end
	if current:hasFlag("DisableOtherTargets") then return false end
	
	if current:containsTrick("indulgence") then  --中乐（来自askForNullification）
		local indulgence_effective = true
		if (current:hasShownSkill("guanxing") or current:hasShownSkill("yizhi") and current:inDeputySkills("yizhi"))
			and (global_room:alivePlayerCount() > 4 or current:hasShownSkills("guanxing|yizhi")) then indulgence_effective = false end  --疑似源码typo，只有遗志没有观星不行
		if current:hasShownSkill("qiaobian") and not current:isKongcheng() then indulgence_effective = false end
		if indulgence_effective then return false end
	end
	if current:containsTrick("supply_shortage") and current:getHandcardNum() <= 2 then  --低手牌中兵
		local ss_effective = true
		if (current:hasShownSkill("guanxing") or current:hasShownSkill("yizhi") and current:inDeputySkills("yizhi"))
			and (global_room:alivePlayerCount() > 4 or current:hasShownSkills("guanxing|yizhi")) then ss_effective = false end  
		if current:hasShownSkills("guidao|tiandu") then ss_effective = false end
		if current:hasShownSkill("qiaobian") and not current:isKongcheng() then ss_effective = false end
		if ss_effective then return false end
	end
	
	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	if self.player:hasSkill("yingyang") then max_point = math.min(max_point + 3, 13) end
	if not (self:needKongcheng(current) and current:getHandcardNum() == 1) then
		local enemy_max_card = self:getMaxCard(current)
		local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
		if enemy_max_card and current:hasShownSkill("yingyang") then enemy_max_point = math.min(enemy_max_point + 3, 13) end
		if max_point > enemy_max_point or max_point > 10 then
			self.Zhuikong_card = max_card:getEffectiveId()
			return true
		end
	end
	if current:distanceTo(self.player) == 1 and not self:isValuableCard(max_card) then
		self.Zhuikong_card = max_card:getEffectiveId()
		return true
	end
	return false
end
sgs.ai_cardneed.Zhuikong = function(to, card, self)
	return card:getNumber() > 10
end

-- 求援
sgs.ai_skill_playerchosen.Qiuyuan = function(self, targets)
	local use = self.room:getTag("Qiuyuan_data"):toCardUse()
	if ((not self:willShowForDefence() and self:getCardsNum("Jink") > 1) or (not self:willShowForMasochism() and self:getCardsNum("Jink") == 0))
		and use.from:getMark("drank") == 0 then  --来自流离
			return "."
	end
	
	local targetlist = sgs.QList2Table(targets)
	self:sort(targetlist, "handcard")
	local enemy
	for _, p in ipairs(targetlist) do
		local jink = getKnownCard(p, self.player, "Jink", true, "he")
		if self:isEnemy(p) and (jink == 0 or (self:isWeak(p) and jink < 2)) and self:slashIsEffective(use.card, p, use.from) then
			enemy = p
			break
		end
	end
	if enemy then return enemy end
	
	if not self:slashIsEffective(use.card, self.player, use.from) then return nil end
	targetlist = sgs.reverse(targetlist)
	local friend
	for _, p in ipairs(targetlist) do
		local jink = getKnownCard(p, self.player, "Jink", true, "he")
		if self:isFriend(p) then
			if (self:needKongcheng(p) and p:getHandcardNum() == 1 and jink == 1)
				--or (p:getCardCount() >= 2 and self:canLiuli(p, self.enemies))  --明明没有流离的时机
				or self:needLeiji(p) or p:getHandcardNum() > 3 or jink >= 1 
				or not self:slashIsEffective(use.card, p, use.from) then
				friend = p
				break
			end
		end
	end
	if friend then return friend end
	--todo：是否判断无脑求援敌人？（即使敌人有闪）
	return nil
end
sgs.ai_skill_cardask["@Qiuyuan-give"] = function(self, data, pattern, target)
	local give = true
	local huanghou = self.room:findPlayerBySkillName("Qiuyuan")
	if self:isEnemy(huanghou) then
		if not (self:needKongcheng() and self.player:getHandcardNum() == 1) then
			give = false
		end
	elseif self:isFriend(huanghou) then
		if not self:isWeak(huanghou) and self:hasSkill("leiji") then
			give = false
		end
	end
	if give == true then
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		for _, card in ipairs(cards) do
			if card:isKindOf("Jink") then
				return "$" .. card:getEffectiveId()
			end
		end
	end
	return "."
end
function SmartAI:hasQiuyuanEffect(from, to)
	if not from or not to:hasShownSkill("Qiuyuan") then return false end
	for _, target in ipairs(self:getEnemies(to)) do
		if self:isFriend(target) then
			if (target:isKongcheng() and not (target:getHandcardNum() == 1 and self:needKongcheng(target, true))) 
			or self:isWeak(target) then
				return true
			end
		end
	end
	return
end
function sgs.ai_slash_prohibit.Qiuyuan(self, from, to)  --来自原项目
	if self:isFriend(to, from) then return false end
	local prohibit
	if to:hasShownSkill("Qiuyuan") then
		local slash = self:getCard("FireSlash") or self:getCard("ThunderSlash") or self:getCard("Slash")
		if slash then
			for _, friend in ipairs(self:getFriendsNoself(from)) do
				if self:isWeak(friend) and (self:hasEightDiagramEffect(friend) and not self.player:hasWeapon("QinggangSword"))
					and getKnownCard(friend, self.player, "Jink", true, "he") == 0
					and not friend:isRemoved()
					and self:slashIsEffective(slash, friend, from) then
					prohibit = true
					break
				end
			end
		end
	end
	if not prohibit then return false end
end

----------------------------------------------------------------------------------------------------

-- YJ 203 关平

-- 龙吟
sgs.ai_skill_cardask["@Longyin"] = function(self, data)
	local function getLeastValueCard(isRed)
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		if self.player:getPhase() > sgs.Player_Play then
			local cards = sgs.QList2Table(self.player:getHandcards())
			self:sortByKeepValue(cards)
			for _, c in ipairs(cards) do
				if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
			end
			if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
			if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < 5 then return "$" .. self.player:getWeapon():getEffectiveId() end
		else
			local slashc
			local cards = sgs.QList2Table(self.player:getHandcards())
			self:sortByUseValue(cards)
			for _, c in ipairs(cards) do
				if self:getUseValue(c) < 6 and not self:isValuableCard(c) and not self.player:isJilei(c) then
					if isCard("Slash", c, self.player) then
						if not slashc then slashc = c end
					else
						return "$" .. c:getEffectiveId()
					end
				end
			end
			if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
			if isRed and slashc then return "$" .. slashc:getEffectiveId() end
		end
	end
	local use = data:toCardUse()
	local slash = use.card
	local slash_num = 0
	if use.from:objectName() == self.player:objectName() then slash_num = self:getCardsNum("Slash") else slash_num = getCardsNum("Slash", use.from, self.player) end
	if use.from:getTag("yongjue_id") then
		local effectiveId
		if not slash:isVirtualCard() then
			effectiveId = slash:getEffectiveId()
		elseif slash:subcardsLength() == 1 then
			effectiveId = slash:getSubcards():first()
		end
		if use.from:getTag("yongjue_id"):toInt() == effectiveId then
			local has_yongjue = false
			for _,p in sgs.qlist(self.room:findPlayersBySkillName("yongjue")) do
				if p:isFriendWith(use.from) and p:hasShownOneGeneral() then has_yongjue = true break end
			end
			if has_yongjue then slash_num = slash_num + 1 end
		end
	end
	local liufeng = sgs.findPlayerByShownSkillName("Xiansi")
	if liufeng and liufeng:getPile("counter"):length() >= 2 and use.from:inMyAttackRange(liufeng) and (liufeng:objectName() ~= use.from:objectName()) then
		slash_num = slash_num + 1
	end
	
	self.Longyin_testing = true
	if self:isEnemy(use.from) and use.m_addHistory and not self:hasCrossbowEffect(use.from) and slash_num > 0 then
		self.Longyin_testing = false
		return "."
	end
	if (slash:isRed() --[[and not hasManjuanEffect(self.player)]])
		or (use.m_reason == sgs.CardUseStruct_CARD_USE_REASON_PLAY and use.m_addHistory and self:isFriend(use.from) and slash_num >= 1
			and (not self:hasCrossbowEffect(use.from) or slash:isRed())) then
		self.Longyin_testing = false
		if not self:willShowForAttack() then return "." end
		local str = getLeastValueCard(slash:isRed())
		if str then return str end
	end
	self.Longyin_testing = false
	return "."
end
function sgs.ai_cardneed.Longyin(to, card)
	return card:isKindOf("Slash") and card:isRed()
end

----------------------------------------------------------------------------------------------------

-- YJ 204 郭淮

-- 精策
sgs.ai_skill_invoke.Jingce = function(self, data)
	if not self:willShowForDefence() then
		return false
	end
	if self:getOverflow() >= 0 then
		local erzhang = sgs.findPlayerByShownSkillName("guzheng")
		if erzhang and self:isEnemy(erzhang) then return false end
	end
	return true
end

----------------------------------------------------------------------------------------------------

-- YJ 205 简雍
										--todo：巧说的AI似乎还是有点问题，经常不会选额外目标
-- 巧说
sgs.ai_skill_playerchosen.Qiaoshui = function(self, targets)
	if not self:willShowForAttack() then return end
	local trick_num = 0
	for _, card in sgs.qlist(self.player:getHandcards()) do
		if card:isNDTrick() and not card:isKindOf("Nullification") and card:isAvailable(self.player) and not self.player:isLocked(card) then 
			trick_num = trick_num + 1
		end
	end
	self:sort(self.enemies, "handcard")
	local max_card = self:getMaxCard()
	local max_point = max_card:getNumber()
	if self.player:hasSkill("yingyang") then max_point = math.min(max_point + 3, 13) end

	for _, enemy in ipairs(self.enemies) do
		if not (self:needKongcheng(enemy) and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
			local enemy_max_card = self:getMaxCard(enemy)
			local enemy_max_point = enemy_max_card and enemy_max_card:getNumber() or 100
			if enemy_max_card and enemy:hasShownSkill("yingyang") then enemy_max_point = math.min(enemy_max_point + 3, 13) end
			if max_point > enemy_max_point then
				self.Qiaoshui_card = max_card:getEffectiveId()
				return enemy
			end
		end
	end
	for _, enemy in ipairs(self.enemies) do
		if not (self:needKongcheng(enemy) and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() then
			if max_point >= 10 then
				self.Qiaoshui_card = max_card:getEffectiveId()
				return enemy
			end
		end
	end

	if next(self.friends_noself) then
		self:sort(self.friends_noself, "handcard")
		for index = #self.friends_noself, 1, -1 do
			local friend = self.friends_noself[index]
			if not friend:isKongcheng() then
				local friend_min_card = self:getMinCard(friend)
				local friend_min_point = friend_min_card and friend_min_card:getNumber() or 100
				if friend_min_card and friend:hasShownSkill("yingyang") then friend_min_point = math.ax(enemy_max_point - 3, 1) end
				if max_point > friend_min_point then
					self.Qiaoshui_card = max_card:getEffectiveId()
					return friend
				end
			end
		end
	end

	local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and zhugeliang:objectName() ~= self.player:objectName() then
		if max_point >= 7 then
			self.Qiaoshui_card = max_card:getEffectiveId()
			return zhugeliang
		end
	end

	if next(self.friends_noself) then
		for index = #self.friends_noself, 1, -1 do
			local friend = self.friends_noself[index]
			if not friend:isKongcheng() then
				if max_point >= 7 then
					self.Qiaoshui_card = max_card:getEffectiveId()
					return friend
				end
			end
		end
	end

	if trick_num == 0 or (trick_num <= 2 and self.player:hasSkill("ZongshiJY")) and not self:isValuableCard(max_card) then
		for _, enemy in ipairs(self.enemies) do
			if not (self:needKongcheng(enemy) and enemy:getHandcardNum() == 1) and not enemy:isKongcheng() and self:hasLoseHandcardEffective(enemy) then
				self.Qiaoshui_card = max_card:getEffectiveId()
				return enemy
			end
		end
	end
	return nil
end
sgs.ai_skill_choice.Qiaoshui = function(self, choices, data)
	local use = data:toCardUse()
	self.Qiaoshui_extra_target = nil
	self.Qiaoshui_remove_target = nil
	self.Qiaoshui_collateral = nil
	if use.card:isKindOf("Collateral") then
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardCollateral(use.card, dummy_use)
		if dummy_use.card and dummy_use.to:length() == 2 then
			local first = dummy_use.to:at(0):objectName()
			local second = dummy_use.to:at(1):objectName()
			self.Qiaoshui_collateral = { first, second }
			return "add"
		else
			self.Qiaoshui_collateral = nil
		end
	elseif use.card:isKindOf("Analeptic") then
	elseif use.card:isKindOf("Peach") then
		self:sort(self.friends_noself, "hp")
		for _, friend in ipairs(self.friends_noself) do
			if friend:isWounded() and not self:needToLoseHp(friend, nil, nil, nil, true) and not self.player:isProhibited(friend, use.card) and use.card:isAvailable(friend) then
				self.Qiaoshui_extra_target = friend
				return "add"
			end
		end
	elseif use.card:isKindOf("ExNihilo") then
		local friend = self:findPlayerToDraw(false, 2)
		if friend and self:hasTrickEffective(use.card, friend, self.player) and use.card:isAvailable(friend) then
			self.Qiaoshui_extra_target = friend
			return "add"
		end
		self:sort(self.friends, "handcard")
		for _, friend in ipairs(self.friends) do
			if not self:needKongcheng(friend, true) and self:hasTrickEffective(use.card, friend, self.player) and use.card:isAvailable(friend) then
				self.Qiaoshui_extra_target = friend
				return "add"
			end
		end
	elseif use.card:isKindOf("GodSalvation") then
		self:sort(self.enemies, "hp")
		for _, enemy in ipairs(self.enemies) do
			if enemy:isWounded() and self:hasTrickEffective(use.card, enemy, self.player) then
				self.Qiaoshui_remove_target = enemy
				return "remove"
			end
		end
	elseif use.card:isKindOf("AmazingGrace") then
		self:sort(self.enemies)
		for _, enemy in ipairs(self.enemies) do
			if self:hasTrickEffective(use.card, enemy, self.player) --[[and not hasManjuanEffect(enemy)]]
				and not self:needKongcheng(enemy, true) then
				self.Qiaoshui_remove_target = enemy
				return "remove"
			end
		end
	elseif use.card:isKindOf("AOE") and not use.card:isKindOf("BurningCamps") then
		self:sort(self.friends_noself)
		--[[local lord = self.room:getLord()
		if lord and lord:objectName() ~= self.player:objectName() and self:isFriend(lord) and self:isWeak(lord) then
			self.Qiaoshui_remove_target = lord
			return "remove"
		end]]
		for _, friend in ipairs(self.friends_noself) do
			if self:hasTrickEffective(use.card, friend, self.player) then
				self.Qiaoshui_remove_target = friend
				return "remove"
			end
		end
	elseif use.card:isKindOf("Snatch") or use.card:isKindOf("Dismantlement") then
		local trick = sgs.Sanguosha:cloneCard(use.card:objectName(), use.card:getSuit(), use.card:getNumber())
		trick:setSkillName("Qiaoshui")
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardSnatchOrDismantlement(trick, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.Qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	elseif use.card:isKindOf("Slash") then
		local slash = sgs.Sanguosha:cloneCard(use.card:objectName(), use.card:getSuit(), use.card:getNumber())
		slash:setSkillName("Qiaoshui")
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardSlash(slash, dummy_use)  --todo
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.Qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	elseif use.card:isKindOf("BurningCamps") then  --只能减少（无意义）
	elseif use.card:isKindOf("FightTogether") then  --只能减少
		local big_kingdoms = self.player:getBigKingdoms("AI")
		local targetBig = false  --若为false则目标为小势力
		local isBig = false  --若为false则自己为小势力
		if #big_kingdoms == 1 and big_kingdoms[1]:startsWith("sgs") then
			if table.contains(big_kingdoms, use.to:first():objectName()) then targetBig = true end
			if table.contains(big_kingdoms, self.player:objectName()) then isBig = true end
		else
			if use.to:first():hasShownOneGeneral() then
				local kingdom = (use.to:first():getRole() == "careerist") and "careerist" or use.to:first():getKingdom()
				if table.contains(big_kingdoms, kingdom) then targetBig = true end
			end
			if self.player:hasShownOneGeneral() then
				local kingdom = (self.player:getRole() == "careerist") and "careerist" or self.player:getKingdom()
				if table.contains(big_kingdoms, kingdom) then isBig = true end
			end
		end
		
		local targets = sgs.QList2Table(use.to)
		self:sort(targets)
		if targetBig == isBig then
			for _,p in ipairs(targets) do
				if (p:hasArmorEffect("IronArmor") and not p:isChained()) then continue end
				if p:isChained() then  --敌人将摸牌
					self.Qiaoshui_remove_target = p
					return "remove"
				end
			end
		else
			for _,p in ipairs(targets) do
				if (p:hasArmorEffect("IronArmor") and not p:isChained()) then continue end
				if not p:isChained() and self:isFriendWith(p) then  --队友将被连
					self.Qiaoshui_remove_target = p
					return "remove"
				end
			end
			for _,p in ipairs(targets) do
				if (p:hasArmorEffect("IronArmor") and not p:isChained()) then continue end
				if not p:isChained() and self:isFriend(p) then
					self.Qiaoshui_remove_target = p
					return "remove"
				end
			end
		end
	elseif use.card:isKindOf("AllianceFeast") then  --只能增加一个目标数为1的势力或减少
		local willRemove = false
		if (use.to:length() > 1) and table.contains(self.enemies, use.to:last()) then
			willRemove = true
			for _, enemy in sgs.qlist(use.to) do
				if (enemy:objectName() ~= self.player:objectName()) and enemy:isWounded() then
					self.Qiaoshui_remove_target = enemy
					return "remove"
				end
			end
		end
		
		local kingdom_reps = {}
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if not self.player:isFriendWith(p) and p:hasShownOneGeneral() and self:hasTrickEffective(use.card, p, self.player) and not use.to:contains(p) and use.card:targetFilter(sgs.PlayerList(), p, self.player) then
				local single_target = true
				if p:getRole() ~= "careerist" then
					for _,p2 in sgs.qlist(self.room:getOtherPlayers(p)) do
						if (p2:getRole() ~= "careerist") and p2:hasShownOneGeneral() and (p2:getKingdom() == p:getKingdom()) and not self.player:isProhibited(p2, use.card) then
							single_target = false
							break
						end
					end
				end
				if single_target then table.insert(kingdom_reps, p) end
			end
		end
		if next(kingdom_reps) ~= nil then
			for _, friend in ipairs(self.friends_noself) do
				if table.contains(kingdom_reps, friend) and self:hasTrickEffective(use.card, friend, self.player) then
					self.Qiaoshui_extra_target = friend
					return "add"
				end
			end
			for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if not self:isEnemy(target) and table.contains(kingdom_reps, target) and self:hasTrickEffective(use.card, target, self.player) then
					self.Qiaoshui_extra_target = target
					return "add"
				end
			end
		end
		
		if willRemove then
			self.Qiaoshui_remove_target = use.to:at(1)
			return "remove"
		end
	elseif use.card:isKindOf("ImperialOrder") then  --（无意义）
	elseif use.card:isKindOf("AwaitExhausted") then  --（无意义）
	elseif use.card:isKindOf("ThreatenEmperor") then
		local friends = {}
		for _, friend in ipairs(self.friends_noself) do
			if self:hasTrickEffective(use.card, friend, self.player) and use.card:isAvailable(friend) and friend:getCardCount(true) >= 1 and friend:canDiscard(friend, "he") then
				table.insert(friends, friend)
			end
		end
		if next(friends) then
			self:sort(friends, "defense")
			for _, friend in ipairs(friends) do
				if self:needToThrowArmor(friend) then
					self.Qiaoshui_extra_target = friend
					return "add"
				end
			end
			local AssistTarget = self:AssistTarget()  --从这里开始基本抄放权
			if AssistTarget and table.contains(friends, AssistTarget) and not self:willSkipPlayPhase(AssistTarget) then
				self.Qiaoshui_extra_target = AssistTarget
				return "add"
			end
			self:sort(friends, "handcard")
			friends = sgs.reverse(friends)
			for _, target in ipairs(friends) do
				if target:hasShownSkills("zhiheng|" .. sgs.priority_skill .. "|shensu") and (not self:willSkipPlayPhase(target) or target:hasShownSkill("shensu")) then
					self.Qiaoshui_extra_target = target
					return "add"
				end
			end
			self.Qiaoshui_extra_target = friends[1]
			return "add"
		end
	else  --铁索连环、决斗、火攻（源码有的）；远交近攻、知己知彼、水淹七军、调虎离山  （为了处理current_targets，每个锦囊都得重写一遍，简直丧病……）
		local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
		for _, p in sgs.qlist(use.to) do
			table.insert(dummy_use.current_targets, p:objectName())
		end
		self:useCardByClassName(use.card, dummy_use)
		if dummy_use.card and dummy_use.to:length() > 0 then
			self.Qiaoshui_extra_target = dummy_use.to:first()
			return "add"
		end
	end
	self.Qiaoshui_extra_target = nil
	self.Qiaoshui_remove_target = nil
	return "cancel"
end
sgs.ai_skill_playerchosen.QiaoshuiTarget = function(self, targets)
	if not self.Qiaoshui_extra_target and not self.Qiaoshui_remove_target then self.room:writeToConsole("Qiaoshui player chosen error!!") end
	return self.Qiaoshui_extra_target or self.Qiaoshui_remove_target
end
sgs.ai_skill_use["@@Qiaoshui"] = function(self, prompt) -- extra target for Collateral
	if not self.Qiaoshui_collateral then self.room:writeToConsole("Qiaoshui player chosen error!!") end
	return "#ExtraCollateralCard:.:" .. self.qiaoshui_collateral[1] .. "+" .. self.qiaoshui_collateral[2] .. "&"
end
function sgs.ai_cardneed.Qiaoshui(to, card, self)
	if sgs.ai_cardneed.bignumber(to, card, self) then return true end
	return isCard("ExNihilo", card, to) or isCard("BefriendAttacking", card, to) or isCard("Snatch", card, to) or isCard("Dismantlement", card, to) or isCard("Duel", card, to) or isCard("Drowning", card, to) or (isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0)
end
sgs.Qiaoshui_keep_value = {
	Peach       = 7.2,
	BefriendAttacking = 5.8,
	ExNihilo    = 5.7,
	Snatch      = 5.7,
	Dismantlement = 5.6,
	SavageAssault=5.4,
	Duel        = 5.3,
	ArcheryAttack = 5.2,
	Drowning    = 5.2,
	FireAttack  = 4.9
}

-- 纵适
sgs.ai_skill_invoke.ZongshiJY = function(self, data)
	if not self:willShowForDefence() then return end
	return not self:needKongcheng(self.player, true)
end

----------------------------------------------------------------------------------------------------

-- YJ 206 李儒

-- 绝策
sgs.ai_skill_playerchosen.Juece = function(self, targetlist)
	if not self:willShowForAttack() then return end
	local targets = sgs.QList2Table(targetlist)
	self:sort(targets)
	local friends, enemies = {}, {}
	for _, target in ipairs(targets) do
		if self:cantbeHurt(target, self.player) or not self:damageIsEffective(target, nil, self.player) then continue end
		if self:isEnemy(target) then table.insert(enemies, target)
		elseif self:isFriend(target) then table.insert(friends, target) end
	end
	for _, enemy in ipairs(enemies) do
		if not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player) then return enemy end
	end
	for _, friend in ipairs(friends) do
		if self:getDamagedEffects(friend, self.player) and self:needToLoseHp(friend, self.player) then return friend end
	end
	return nil
end
sgs.ai_playerchosen_intention.Juece = function(self, from, to)
	if self:damageIsEffective(to, nil, from) and not self:getDamagedEffects(friend, self.player) and not self:needToLoseHp(friend, self.player) then
		sgs.updateIntention(from, to, 10)
	end
end

-- 灭计
local mieji_skill = {}
mieji_skill.name = "Mieji"
table.insert(sgs.ai_skills, mieji_skill)
mieji_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	for _, enemy in ipairs(self.enemies) do				--为绝策加入的防止给牌
		if enemy:isKongcheng() then enemy:setFlags("preventgivecard") end
	end
	if self.player:hasUsed("#MiejiCard") or self.player:isKongcheng() then return end
	return sgs.Card_Parse("#MiejiCard:.:&Mieji")
end
sgs.ai_skill_use_func["#MiejiCard"] = function(card, use, self)
	local nextAlive = self.player:getNextAlive()
	local hasLightning, hasIndulgence, hasSupplyShortage
	local tricks = nextAlive:getJudgingArea()
	if not tricks:isEmpty() and not nextAlive:containsTrick("YanxiaoCard") and not nextAlive:hasSkill("qianxi") then
		local trick = tricks:at(tricks:length() - 1)
		if self:hasTrickEffective(trick, nextAlive) then
			if trick:isKindOf("Lightning") then hasLightning = true
			elseif trick:isKindOf("Indulgence") then hasIndulgence = true
			elseif trick:isKindOf("SupplyShortage") then hasSupplyShortage = true
			end
		end
	end
	
	local big_kingdoms = self.player:getBigKingdoms("AI")
	local kindom = nextAlive:getKingdom()
	local fobitThreatenEmperor
	for _, k in ipairs(big_kingdoms) do		--检查下家是否大势力
		if k:match(kindom) and self:isEnemy(nextAlive) and not (hasLightning or hasIndulgence or hasSupplyShortage or nextAlive:hasSkill("qianxi")) then fobitThreatenEmperor = true end
	end

	local putcard, TEcard
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isBlack() and card:isKindOf("TrickCard") then
			if hasLightning and card:getSuit() == sgs.Card_Spade and card:getNumber() >= 2 and card:getNumber() <= 9 then
				if self:isEnemy(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if hasSupplyShortage and card:getSuit() == sgs.Card_Club then
				if self:isFriend(nextAlive) then
					putcard = card break
				else continue
				end
			end
			if not putcard then
				if not card:isKindOf("ThreatenEmperor") or not fobitThreatenEmperor then  --防止把挟天子给大势力敌人
					putcard = card break
				end
			end
		end
	end

	local target
	for _, enemy in ipairs(self.enemies) do
		--if self:needKongcheng(enemy) and enemy:getHandcardNum() <= 2 then continue end
		if self:doNotDiscard(enemy, "he", true, 2, true) then continue end
		if not enemy:isNude()  then
			target = enemy break
		end
	end
	if not target then
		for _, friend in ipairs(self.friends_noself) do
			if self:needKongcheng(friend) and friend:getHandcardNum() < 2 and not friend:isKongcheng() then
				target = friend break
			end
		end
	end

	if putcard and target then
		use.card = sgs.Card_Parse("#MiejiCard:"..putcard:getEffectiveId() .. ":&Mieji")
		if use.to then use.to:append(target) end
		return
	end

end
sgs.ai_use_priority.MiejiCard = sgs.ai_use_priority.Dismantlement + 1
sgs.dynamic_value.control_card.MiejiCard = true
sgs.ai_card_intention["#MiejiCard"] = function(self, card, from, tos)
	for _, to in ipairs(tos) do
		if self:needKongcheng(to) and to:getHandcardNum() <= 2 then continue end
		sgs.updateIntention(from, to, 10)
	end
end
sgs.ai_skill_cardask["@@MiejiDiscard!"] = function(self, prompt)
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	local trick = {}
	local nontrick = {}
	local discard = {}
	for _,card in ipairs(cards) do
		if self.player:isJilei(card) then continue end  --源码忘加了。。
		if card:isKindOf("TrickCard") then
			table.insert(trick, card)
		else
			table.insert(nontrick, card)
		end
	end
	if #cards <= 2 then return "." end
	if self:needToThrowArmor() and #nontrick >= 2 then
		table.insert(discard, self.player:getArmor())
		if nontrick[1] ~= discard[1] then
			table.insert(discard, nontrick[1])
		else
			table.insert(discard, nontrick[2])
		end
	end
	if self.player:hasSkills(sgs.lose_equip_skill) and self.player:getEquips():length() > 0 and #nontrick >= 2 then
		local ecards = sgs.QList2Table(self.player:getEquips())
		self:sortByKeepValue(ecards)
		table.insert(discard, ecards[1])
		if nontrick[1] ~= discard[1] then
			table.insert(discard, nontrick[1])
		else
			table.insert(discard, nontrick[2])
		end
	end
	if #trick == 0 then
		for _,card in ipairs(nontrick) do
			table.insert(discard, card)
			if #discard == 2 or #discard == #nontrick then
				break
			end
		end
	end
	if #nontrick == 0 and #trick >= 1 then
		table.insert(discard, trick[1])
	end
	if #discard > 0 then
		return "$"..table.concat(discard:getEffectiveId(), "+")
	end
return "."
end
sgs.ai_cardneed.Mieji = function(to, card, self)
	return card:isBlack() and (card:getTypeId() == sgs.Card_TypeTrick)
end
sgs.ai_suit_priority.Mieji = "diamond|heart|club|spade"

-- 焚城
local fencheng_skill = {}
fencheng_skill.name = "Fencheng"
table.insert(sgs.ai_skills, fencheng_skill)
fencheng_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:getMark("@burn") == 0 then return false end
	return sgs.Card_Parse("#FenchengCard:.:&Fencheng")
end
sgs.ai_skill_use_func["#FenchengCard"] = function(card, use, self)
	local value = 0
	if self.player:hasShownSkill("baoling") then value = value + 3 end
	local neutral = 0
	local damage = { from = self.player, damage = 2, nature = sgs.DamageStruct_Fire }
	local lastPlayer = self.player
	for i, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		damage.to = p
		if self:damageIsEffective_(damage) then
			--if sgs.evaluatePlayerRole(p, self.player) == "neutral" then neutral = neutral + 1 end
			if not self:isFriend(p) and not self:isEnemy(p) then neutral = neutral + 1 end
			local v = 4
			if (self:getDamagedEffects(p, self.player) or self:needToLoseHp(p, self.player)) and getCardsNum("Peach", p, self.player) + p:getHp() > 2 then
				v = v - 6
			elseif lastPlayer:objectName() ~= self.player:objectName() and lastPlayer:getCardCount(true) < p:getCardCount(true) then
				v = v - 4
			elseif lastPlayer:objectName() == self.player:objectName() and not p:isNude() then
				v = v - 4
			end
			if self:isFriend(p) then
				value = value - v - p:getHp() + 2
			elseif self:isEnemy(p) then
				value = value + v + p:getLostHp() - 1
			end
			if p:isLord() and p:getHp() <= 2
				and (self:isEnemy(p, lastPlayer) and p:getCardCount(true) <= lastPlayer:getCardCount(true)
					or lastPlayer:objectName() == self.player:objectName() and (not p:canDiscard(p, "he") or p:isNude())) then
				if not self:isEnemy(p) then
					if self:getCardsNum("Peach") + getCardsNum("Peach", p, self.player) + p:getHp() <= 2 then return end
				else
					use.card = card
					return
				end
			end
		end
	end

	if neutral > self.player:aliveCount() / 2 then return end
	if value > 0 then
		use.card = card
	end
end
sgs.ai_use_priority.FenchengCard = 9.1
sgs.ai_skill_discard.Fencheng = function(self, discard_num, min_num, optional, include_equip)  --原项目
	local cards = {}
	local thenext = self.player:getNextAlive()
	local thenextnext = thenext:getNextAlive()
	local selfnum = self.player:getCardCount(true)
	local nextnum = thenext:getCardCount(true)
	local hecards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByKeepValue(hecards)
	local chainedprevent		--被铁索则千万要避免
	if self.player:isChained() then
		for _, p in ipairs(self.friends_noself) do
			if self:isFriendWith(p) and not self:isGoodChainTarget(self.player, p, sgs.DamageStruct_Fire, 2) then
				chainedprevent = true
				break
			end
		end
	end
	if chainedprevent and self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then
		for i = 1, min_num do
			table.insert(cards, hecards[i]:getEffectiveId())
		end
		return cards
	end
	if thenext:hasFlag("FenchengUsing") then
		for i = 1, min_num do
			table.insert(cards, hecards[i]:getEffectiveId())
		end
		return cards
	end
	if self:isWeak() and self.player:hasArmorEffect("Breastplate") then		--危险但是有护心境就不弃牌
		return {}
	end
	if self:isFriend(thenext) and not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}	end	--下家是朋友，且自身不受伤
	if self:isFriendWith(thenext) then								--下家是同势力
		if nextnum >= min_num + 1 or not self:damageIsEffective(thenext, sgs.DamageStruct_Fire) then	--下家够弃牌，自己弃最小量
			for i = 1, min_num do
				table.insert(cards, hecards[i]:getEffectiveId())
			end
			return cards
		end
		if self:isWeak(thenext) and nextnum ~= 0 and not self:isWeak() then		--下家会没命，自己替下家挡
			return {}
		end
	end
	if self:isEnemy(thenext) then													--下家是敌人的场合
		if (not self:damageIsEffective(thenext, sgs.DamageStruct_Fire)) or (thenext:hasArmorEffect("SilverLion") and thenext:getHp() >= 2) then			--如果敌人不会受伤
			if not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}
			else
				for i = 1, min_num do												--自己弃最小量
					table.insert(cards, hecards[i]:getEffectiveId())
				end
				return cards
			end
		else
			if self:isFriendWith(thenextnext) or thenextnext:hasFlag("FenchengUsing") then	--如果下家的下家是同势力，或者下家是最后一名响应者
				if selfnum >= nextnum and nextnum >= min_num + 1 then				--手牌够先坑掉下家
					for i = 1, nextnum do
						table.insert(cards, hecards[i]:getEffectiveId())
					end
					return cards
				end
				if not self:damageIsEffective(self.player, sgs.DamageStruct_Fire) then return {}	--如果自己不受伤，都放过
				else
					for i = 1, min_num do											--自己会受伤就弃最小量
						table.insert(cards, hecards[i]:getEffectiveId())
					end
					return cards
				end
			end
		end
	end
	for i = 1, min_num,1 do
		table.insert(cards, hecards[i]:getEffectiveId())
	end
	return cards
end

----------------------------------------------------------------------------------------------------

-- YJ 207 刘封

-- 陷嗣
sgs.ai_skill_playerchosen.Xiansi = function(self)
	if not self:willShowForAttack() then return {} end
	local canSlash_enemies = false  --是否有敌人可以打到刘封
	local crossbow_effect
	
	local isHuashen = false
	--[[if self.player:hasShownSkill("huashen") then
		local huashens = self.player:getTag("Huashens"):toList()
		for _, q in sgs.qlist(huashens) do
			if sgs.Sanguosha:getGeneral(q:toString()) and sgs.Sanguosha:getGeneral(q:toString()):hasSkill("Xiansi") then
				isHuashen = true
				break
			end
		end
	end]]
	if not isHuashen then
		for _, enemy in ipairs(self.enemies) do
			if enemy:inMyAttackRange(self.player) or (self:hasCrossbowEffect(enemy) or getKnownCard(enemy, self.player, "Crossbow") > 0) then  --防止敌人裸模武器然后突突突
				canSlash_enemies = true
			end
			if enemy:inMyAttackRange(self.player) and (self:hasCrossbowEffect(enemy) or getKnownCard(enemy, self.player, "Crossbow") > 0) then
				crossbow_effect = true
				break
			end
		end
	end
	local max_num = 999
	if canSlash_enemies then  --如果敌人都打不到刘封，可以放心发动
		if crossbow_effect then max_num = 3
		elseif self:getCardsNum("Jink") < 1 or self:isWeak() then max_num = 5 end
	end
	if self.player:getPile("counter"):length() >= max_num then return {} end
	local rest_num = math.min(2, max_num - self.player:getPile("counter"):length())
	local targets = {}

	local add_player = function(player, isfriend)
		if player:getHandcardNum() == 0 or player:objectName() == self.player:objectName() then return #targets end
		--if self:objectiveLevel(player) == 0 and player:isLord() and sgs.current_mode_players["rebel"] > 1 then return #targets end
		if #targets == 0 then
			table.insert(targets, player:objectName())
		elseif #targets == 1 then
			if player:objectName() ~= targets[1] then
				table.insert(targets, player:objectName())
			end
		end
		if isfriend and isfriend == 1 then
			self.player:setFlags("AI_XiansiToFriend_" .. player:objectName())
		end
		return #targets
	end
	
	local convertToSPlayer = function(targets)
		local result = {}
		for _,name in pairs(targets) do
			table.insert(result, findPlayerByObjectName(name))
		end
		return result
	end

	local player = self:findPlayerToDiscard("he", true, false)
	if player then
		if rest_num == 1 then return convertToSPlayer({player}) end
		add_player(player, self:isFriend(player) and 1 or nil)
		local another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(player))
		if another then
			add_player(another, self:isFriend(another) and 1 or nil)
			return convertToSPlayer(targets)
		end
	end
	
	local zhugeliang = sgs.findPlayerByShownSkillName("kongcheng")
	local luxun = self.room:findPlayerBySkillName("Lianying")-- or self.room:findPlayerBySkillName("noslianying")
	local dengai = sgs.findPlayerByShownSkillName("tuntian")
	--local jiangwei = self.room:findPlayerBySkillName("zhiji")

	--[[if jiangwei and self:isFriend(jiangwei) and jiangwei:getMark("zhiji") == 0 and jiangwei:getHandcardNum()== 1
		and self:getEnemyNumBySeat(self.player, jiangwei) <= (jiangwei:getHp() >= 3 and 1 or 0) then
		if add_player(jiangwei, 1) == rest_num then return "@XiansiCard=.->" .. table.concat(targets, "+") end
	end]]
	--[[if dengai and dengai:hasSkill("zaoxian") and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0)
		and dengai:getMark("zaoxian") == 0 and dengai:getPile("field"):length() == 2 and add_player(dengai, 1) == rest_num then
		return targets
	end]]

	if zhugeliang and self:isFriend(zhugeliang) and zhugeliang:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, zhugeliang) > 0 then
		if zhugeliang:getHp() <= 2 then
			if add_player(zhugeliang, 1) == rest_num then return convertToSPlayer(targets) end
		else
			local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), zhugeliang:objectName())
			local cards = sgs.QList2Table(zhugeliang:getHandcards())
			if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
				if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
					if add_player(zhugeliang, 1) == rest_num then return convertToSPlayer(targets) end
				end
			end
		end
	end

	if luxun and self:isFriend(luxun) and luxun:getHandcardNum() == 1 and self:getEnemyNumBySeat(self.player, luxun) > 0 then
		local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), luxun:objectName())
		local cards = sgs.QList2Table(luxun:getHandcards())
		if #cards == 1 and (cards[1]:hasFlag("visible") or cards[1]:hasFlag(flag)) then
			if cards[1]:isKindOf("TrickCard") or cards[1]:isKindOf("Slash") or cards[1]:isKindOf("EquipCard") then
				if add_player(luxun, 1) == rest_num then return convertToSPlayer(targets) end
			end
		end
	end

	if luxun and add_player(luxun, (self:isFriend(luxun) and 1 or nil)) == rest_num then
		return convertToSPlayer(targets)
	end

	if dengai and self:isFriend(dengai) and (not self:isWeak(dengai) or self:getEnemyNumBySeat(self.player, dengai) == 0) and add_player(dengai, 1) == rest_num then
		return convertToSPlayer(targets)
	end

	if #targets == 1 then
		local target = findPlayerByObjectName(self.room, targets[1])
		if target then
			local another
			if rest_num > 1 then another = self:findPlayerToDiscard("he", true, false, self.room:getOtherPlayers(target)) end
			if another then
				add_player(another, self:isFriend(another) and 1 or nil)
				return convertToSPlayer(targets)
			else
				return convertToSPlayer(targets)
			end
		end
	end
	return {}
end
sgs.ai_card_intention.XiansiCard = function(self, card, from, tos)  --todo：重写（参见奋威）
	--[[local lord = self.room:getLord()
	if sgs.evaluatePlayerRole(from) == "neutral" and sgs.evaluatePlayerRole(tos[1]) == "neutral"
		and (not tos[2] or sgs.evaluatePlayerRole(tos[2]) == "neutral") and lord and not lord:isNude()
		and self:doNotDiscard(lord, "he", true) and from:aliveCount() >= 4 then
		sgs.updateIntention(from, lord, -35)
		return
	end]]
	if from:getState() == "online" then
		for _, to in ipairs(tos) do
			if (self.player:hasShownSkills("kongcheng", to) and to:getHandcardNum() == 1) --[[or to:hasShownSkills("tuntian+zaoxian")]] then
			else
				sgs.updateIntention(from, to, 80)
			end
		end
	else
		for _, to in ipairs(tos) do
			local intention = from:hasFlag("AI_XiansiToFriend_" .. to:objectName()) and -5 or 80
			sgs.updateIntention(from, to, intention)
		end
	end
end
local getXiansiCard = function(pile)
	if #pile > 1 then return pile[1], pile[2] end
	return nil
end
local xiansi_slash_skill = {}
xiansi_slash_skill.name = "Xiansi_slash"
table.insert(sgs.ai_skills, xiansi_slash_skill)
--[[function sgs.ai_cardsview_value.Xiansi_slash(self, class_name, player)  --Gave up halfway
	if class_name == "Slash" and sgs.Sanguosha:getCurrentCardUseReason() == sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then
		if player:hasFlag("slashTargetFixToOne") then
			local target
			for _, p in sgs.qlist(self.room:getOtherPlayers(player)) do
				if p:hasFlag("SlashAssignee") then target = p break end
			end
			local no_distance = sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_DistanceLimit, self.player, slash) > 50 or self.player:hasFlag("slashNoDistanceLimit")
			local targets = {}
			local use = { to = sgs.SPlayerList() }
											self.room:sendCompulsoryTriggerLog(self.player, "02.75", false)
			if self.player:canSlash(target, slash, not no_distance) then use.to:append(target) else return "." end

											self.room:sendCompulsoryTriggerLog(self.player, "03", false)
			if target:hasShownSkill("Xiansi") and target:getPile("counter"):length() > 1
				and not (self:needKongcheng() and self.player:isLastHandCard(slash, true)) then
											self.room:sendCompulsoryTriggerLog(self.player, "04", false)
				--return "#XiansiSlashCard:.:" .. target:objectName() .. "&->" .. target:objectName()
				--return "#XiansiSlashCard:.:" .. target:objectName() .. "&"
				local ints = sgs.QList2Table(target:getPile("counter"))
				local a, b = getXiansiCard(ints)
				if a and b then
					return "#XiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&->" .. target:objectName()
				end
			end
			return "@AocaiCard=.:slash"
		end
	end
end]]
xiansi_slash_skill.getTurnUseCard = function(self)
	if not self:slashIsAvailable() then return end
	local liufeng = sgs.findPlayerByShownSkillName("Xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return end
	local ints = sgs.QList2Table(liufeng:getPile("counter"))
	local a, b = getXiansiCard(ints)
	if a and b then
		return sgs.Card_Parse("#XiansiSlashCard:" .. tostring(a) .. "+" .. tostring(b) .. ":&")
	end
end
sgs.ai_skill_use_func["#XiansiSlashCard"] = function(card, use, self)
	local liufeng = sgs.findPlayerByShownSkillName("Xiansi")
	if not liufeng or liufeng:getPile("counter"):length() <= 1 or not self.player:canSlash(liufeng) then return "." end
	local slash = sgs.Sanguosha:cloneCard("slash")

	if self:slashIsAvailable() and self:isFriend(liufeng) and (not self:slashIsEffective(slash, liufeng, self.player) or liufeng:hasShownSkill("xiangle")) then
		sgs.ai_use_priority.XiansiSlashCard = 0.1
		use.card = card
		if use.to then use.to:append(liufeng) end
		return
	else
		sgs.ai_use_priority.XiansiSlashCard = 2.6
		local dummy_use = { to = sgs.SPlayerList() }
		self:useCardSlash(slash, dummy_use)
		if dummy_use.card then
			if (dummy_use.card:isKindOf("GodSalvation") or dummy_use.card:isKindOf("Analeptic") or dummy_use.card:isKindOf("Weapon"))
				and self:getCardsNum("Slash") > 0 then
				use.card = dummy_use.card
				--if use.to then use.to:append(liufeng) end  --会导致对刘封使用酒的bug（什么鬼）
				if dummy_use.to then use.to = dummy_use.to end
				return
			else
				if dummy_use.card:isKindOf("Slash") and dummy_use.to:length() > 0 then
					local lf
					for _, p in sgs.qlist(dummy_use.to) do
						if p:objectName() == liufeng:objectName() then
							lf = true
							break
						end
					end
					if lf and self.player:hasSkill("duanbing") and self:willShowForAttack() and not self.player:hasFlag("HalberdUse") then  --短兵必须选择刘封为额定目标，额外目标必须距离1
						local slash_targets = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_ExtraTarget, self.player, dummy_use.card)
						if dummy_use.to and dummy_use.to:length() > slash_targets then
							local hasDist1 = false
							for _, p in sgs.qlist(dummy_use.to) do
								if p:objectName() ~= liufeng:objectName() and self.player:distanceTo(p) == 1 then
									hasDist1 = true
									break
								end
							end
							if not hasDist1 then lf = nil end
						end
					end
					if lf then
						use.card = card
						if use.to then use.to:append(liufeng) end
						return
					end
				end
			end
		end
	end
	if not use.card then
		sgs.ai_use_priority.XiansiSlashCard = 2.0
		if self:slashIsAvailable() and self:isEnemy(liufeng)
			and not self:slashProhibit(slash, liufeng) and self:slashIsEffective(slash, liufeng) and sgs.isGoodTarget(liufeng, self.enemies, self) then
			use.card = card
			if use.to then use.to:append(liufeng) end
			return
		end
	end
end
sgs.ai_card_intention.XiansiSlashCard = function(self, card, from, tos)
	local slash = sgs.Sanguosha:cloneCard("slash")
	if not self:slashIsEffective(slash, tos[1], from) then
		sgs.updateIntention(from, tos[1], -30)
	else
		return sgs.ai_card_intention.Slash(self, slash, from, tos)
	end
end

----------------------------------------------------------------------------------------------------

-- YJ 208 满宠

-- 峻刑
local junxing_skill = {}
junxing_skill.name = "Junxing"
table.insert(sgs.ai_skills, junxing_skill)
junxing_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
	if self.player:isKongcheng() or self.player:hasUsed("#JunxingCard") then return nil end
	return sgs.Card_Parse("#JunxingCard:.:&Junxing")
end
sgs.ai_skill_use_func["#JunxingCard"] = function(card, use, self)
	-- find enough cards
	local unpreferedCards = {}
	local cards = sgs.QList2Table(self.player:getHandcards())
	local use_slash_num = 0
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if card:isKindOf("Slash") then
			local will_use = false
			if use_slash_num <= sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, card) then
				local dummy_use = { isDummy = true }
				self:useBasicCard(card, dummy_use)
				if dummy_use.card then
					will_use = true
					use_slash_num = use_slash_num + 1
				end
			end
			if not will_use then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local num = self:getCardsNum("Jink") - 1
	if self.player:getArmor() then num = num + 1 end
	if num > 0 then
		for _, card in ipairs(cards) do
			if card:isKindOf("Jink") and num > 0 then
				table.insert(unpreferedCards, card:getId())
				num = num - 1
			end
		end
	end
	for _, card in ipairs(cards) do
		if card:isKindOf("EquipCard") then
			local dummy_use = { isDummy = true }
			self:useEquipCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	for _, card in ipairs(cards) do
		if card:isNDTrick() or card:isKindOf("Lightning") then
			local dummy_use = { isDummy = true }
			self:useTrickCard(card, dummy_use)
			if not dummy_use.card then table.insert(unpreferedCards, card:getId()) end
		end
	end
	local use_cards = {}
	for index = #unpreferedCards, 1, -1 do
		if not self.player:isJilei(sgs.Sanguosha:getCard(unpreferedCards[index])) then table.insert(use_cards, unpreferedCards[index]) end
	end
	if #use_cards == 0 then return end

	-- to friends
	self:sort(self.friends_noself, "defense")
	for _, friend in ipairs(self.friends_noself) do
		if not self:toTurnOver(friend, #use_cards, "Junxing") then
			use.card = sgs.Card_Parse("#JunxingCard:" .. table.concat(use_cards, "+") .. ":&Junxing")
			if use.to then use.to:append(friend) end
			return
		end
	end
	if #use_cards > 3 then
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.notActive_cardneed_skill) and not friend:hasShownSkills(sgs.Active_cardneed_skill) and not friend:hasShownSkills(sgs.Active_priority_skill) and self:getOverflow(friend) <= 2 then
				use.card = sgs.Card_Parse("#JunxingCard:" .. table.concat(use_cards, "+") .. ":&Junxing")
				if use.to then use.to:append(friend) end
				return
			end
		end
	end

	-- to enemies
	local basic, trick, equip
	for _, id in ipairs(use_cards) do
		local typeid = sgs.Sanguosha:getEngineCard(id):getTypeId()
		if not basic and typeid == sgs.Card_TypeBasic then basic = id
		elseif not trick and typeid == sgs.Card_TypeTrick then trick = id
		elseif not equip and typeid == sgs.Card_TypeEquip then equip = id
		end
		if basic and trick and equip then break end
	end
	self:sort(self.enemies, "handcard")
	local other_enemy
	for _, enemy in ipairs(self.enemies) do
		local id = nil
		if self:toTurnOver(enemy, 1) then
			if getKnownCard(enemy, self.player, "BasicCard") == 0 then id = equip or trick end
			if not id and getKnownCard(enemy, self.player, "TrickCard") == 0 then id = equip or basic end
			if not id and getKnownCard(enemy, self.player, "EquipCard") == 0 then id = trick or basic end
			if id then
				use.card = sgs.Card_Parse("#JunxingCard:" .. id .. ":&Junxing")
				if use.to then use.to:append(enemy) end
				return
			elseif not other_enemy then
				other_enemy = enemy
			end
		end
	end
	if other_enemy then
		use.card = sgs.Card_Parse("#JunxingCard:" .. use_cards[1] .. ":&Junxing")
		if use.to then use.to:append(other_enemy) end
		return
	end
	
	for _, friend in ipairs(self.friends_noself) do
		if friend:hasShownSkill("Dawu") then
			local fog_count = 0
			for _,friend2 in ipairs(self.friends) do
				if friend2:getMark("@fog_ShenZhuGeLiang") > 0 then
					fog_count = fog_count + (friend2:isWeak() and 2 or 1)
				end
			end
			if fog_count >= 2 then
				use.card = sgs.Card_Parse("#JunxingCard:" .. table.concat(use_cards, "+") .. ":&Junxing")
				if use.to then use.to:append(friend) end
				return
			end
		end
	end
end
sgs.ai_use_priority.JunxingCard = 1.2
sgs.ai_card_intention["#JunxingCard"] = function(self, card, from, tos)
	local to = tos[1]
	if not to:faceUp() then
		sgs.updateIntention(from, to, -80)
	else
		if to:getHandcardNum() <= 1 and card:subcardsLength() >= 3 then
			sgs.updateIntention(from, to, -40)
		else
			sgs.updateIntention(from, to, 80)
		end
	end
end
sgs.ai_skill_cardask["@Junxing-discard"] = function(self, data, pattern)
	local manchong = sgs.findPlayerByShownSkillName("Junxing")
	if manchong and self:isFriend(manchong) then return "." end

	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByKeepValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end

-- 御策
sgs.ai_skill_cardask["@Yuce-show"] = function(self, data)
	if not self:willShowForMasochism() then return false end
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if not damage.from or damage.from:isDead() then return "." end
	if self:isFriend(damage.from) then return "$" .. self.player:handCards():first() end
	local flag = string.format("%s_%s_%s", "visible", self.player:objectName(), damage.from:objectName())
	local types = { sgs.Card_TypeBasic, sgs.Card_TypeEquip, sgs.Card_TypeTrick }
	for _, card in sgs.qlist(damage.from:getHandcards()) do
		if card:hasFlag("visible") or card:hasFlag(flag) then
			table.removeOne(types, card:getTypeId())
		end
		if #types == 0 then break end
	end
	if #types == 0 then types = { sgs.Card_TypeBasic } end
	for _, card in sgs.qlist(self.player:getHandcards()) do
		for _, cardtype in ipairs(types) do
			if card:getTypeId() == cardtype then return "$" .. card:getEffectiveId() end
		end
	end
	return "$" .. self.player:handCards():first()
end
sgs.ai_skill_cardask["@Yuce-discard"] = function(self, data, pattern, target)
	if target and self:isFriend(target) then return "." end
	local types = pattern:split("|")[1]:split(",")
	local cards = sgs.QList2Table(self.player:getHandcards())
	self:sortByUseValue(cards)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	return "."
end
sgs.ai_damage_effect.Yuce = function(self, damage)
	local to = damage.to
	local from = damage.from
	local damagecount = damage.damage or 1
	if to:hasShownSkill("Yuce") and not to:isKongcheng() and to:getHp() > 1 then
		if not from then return true
        elseif self:isFriend(to, from) then return false
        else
            if from:objectName() ~= self.player:objectName() then
                if from:getHandcardNum() <= 2 then return (damagecount > 1) end
            else
                if ((getKnownCard(to, self.player, "TrickCard", false, "h") + getKnownCard(to, self.player, "EquipCard", false, "h") < to:getHandcardNum())
                    and (getCardsNum("TrickCard", from, self.player) + getCardsNum("EquipCard", from, self.player) < 1))
                    or getCardsNum("BasicCard", from, self.player) < 2 then  --注意国战getCardsNum不包括装备
                    return (damagecount > 1)  --原来是return false
                end
            end
        end
    end
	return true
end
function sgs.ai_cardneed.Yuce(to, card)
	return to:getCards("h"):length() == 0
end

----------------------------------------------------------------------------------------------------

-- YJ 209 潘璋马忠

-- 夺刀
sgs.ai_skill_cardask["@Duodao-get"] = function(self, data)
	if not self:willShowForAttack() and not self:willShowForDefence() then return "." end
	local function getLeastValueCard(from)
		if self:needToThrowArmor() then return "$" .. self.player:getArmor():getEffectiveId() end
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByKeepValue(cards)
		for _, c in ipairs(cards) do
			if self:getKeepValue(c) < 8 and not self.player:isJilei(c) and not self:isValuableCard(c) then return "$" .. c:getEffectiveId() end
		end
		local offhorse_avail, weapon_avail
		for _, enemy in ipairs(self.enemies) do
			if self:canAttack(enemy, self.player) then
				if not offhorse_avail and self.player:getOffensiveHorse() and self.player:distanceTo(enemy, 1) <= self.player:getAttackRange() then
					offhorse_avail = true
				end
				if not weapon_avail and self.player:getWeapon() and self.player:distanceTo(enemy) == 1 then
					weapon_avail = true
				end
			end
			if offhorse_avail and weapon_avail then break end
		end
		if offhorse_avail and not self.player:isJilei(self.player:getOffensiveHorse()) then return "$" .. self.player:getOffensiveHorse():getEffectiveId() end
		if weapon_avail and not self.player:isJilei(self.player:getWeapon()) and self:evaluateWeapon(self.player:getWeapon()) < self:evaluateWeapon(from:getWeapon()) then
			return "$" .. self.player:getWeapon():getEffectiveId()
		end
	end
	local damage = data:toDamage()
	if not damage.from or not damage.from:getWeapon() then
		if self:needToThrowArmor() then
			return "$" .. self.player:getArmor():getEffectiveId()
		elseif self.player:getHandcardNum() == 1 and self:needKongcheng() --[[(self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0))]] then
			return "$" .. self.player:handCards():first()
		end
	else
		if self:isFriend(damage.from) then
			if damage.from:hasSkills("xiaoji") and self:isWeak(damage.from) then
				local str = getLeastValueCard(damage.from)
				if str then return str end
			else
				if self:getCardsNum("Slash") == 0 or self:willSkipPlayPhase() then return "." end
				local invoke = false
				local range = sgs.weapon_range[damage.from:getWeapon():getClassName()] or 0
				if self.player:hasSkill("Anjian") then
					for _, enemy in ipairs(self.enemies) do
						if not enemy:inMyAttackRange(self.player) and not self.player:inMyAttackRange(enemy) and self.player:distanceTo(enemy) <= range then
							invoke = true
							break
						end
					end
				end
				if not invoke and self:evaluateWeapon(damage.from:getWeapon()) > 8 then invoke = true end
				if invoke then
					local str = getLeastValueCard(damage.from)
					if str then return str end
				end
			end
		else
			--[[if damage.from:hasSkill("nosxuanfeng") then
				for _, friend in ipairs(self.friends) do
					if self:isWeak(friend) then return "." end
				end
			else]]
				--[[if hasManjuanEffect(self.player) then
					if self:needToThrowArmor() and not self.player:isJilei(self.player:getArmor()) then
						return "$" .. self.player:getArmor():getEffectiveId()
					elseif self.player:getHandcardNum() == 1
							and (self.player:hasSkill("kongcheng") or (self.player:hasSkill("zhiji") and self.player:getMark("zhiji") == 0))
							and not self.player:isJilei(self.player:getHandcards():first()) then
						return "$" .. self.player:handCards():first()
					end
				else]]
					local str = getLeastValueCard(damage.from)
					if str then return str end
				--end
			--end
		end
	end
	return "."
end

-- 暗箭
sgs.ai_skill_invoke.Anjian = function(self, data)
	if not self:willShowForAttack() then return false end
	local enemy = data:toPlayer()
	if self:isFriend(enemy) then return false end
	local damage = self.player:getTag("AnjianDamage"):toDamage()
	local damage_copy = damage
	damage_copy.damage = damage_copy.damage + 1
	if self:objectiveLevel(enemy) > 3 and self:damageIsEffective_(damage_copy)
		and (not enemy:hasArmorEffect("SilverLion") or self.player:hasWeapon("QinggangSword")) then
		return true
	end
	return false
end
function sgs.ai_cardneed.Anjian(to, card, self)  --抄裸衣
	local slash_num = 0
	local target
	local slash = sgs.cloneCard("slash")

	local cards = to:getHandcards()
	local need_slash = true
	for _, c in sgs.qlist(cards) do
		if sgs.cardIsVisible(c, to, self.player) then
			if isCard("Slash", c, to) then
				need_slash = false
				break
			end
		end
	end

	self:sort(self.enemies, "defenseSlash")
	for _, enemy in ipairs(self.enemies) do
		if to:canSlash(enemy) and not self:slashProhibit(slash ,enemy) and self:slashIsEffective(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2 then
			target = enemy
			break
		end
	end

	if need_slash and target and isCard("Slash", card, to) then return true end
end
sgs.Anjian_keep_value = {
	DefensiveHorse  = 6,
	FireSlash       = 5.6,
	Slash           = 5.4,
	ThunderSlash    = 5.5,
	Axe             = 5,
	Triblade        = 4.9,
	Blade           = 4.9,
	Spear           = 4.9,
	Fan             = 4.8,
	KylinBow        = 4.7,
	Halberd         = 4.6,
	MoonSpear       = 4.5,
	SPMoonSpear     = 4.5,
	OffensiveHorse  = 4
}

----------------------------------------------------------------------------------------------------

-- YJ 210 虞翻

-- 纵玄																todo：队友全满血不用放装备；改用cardneedplayer写
local function getBackToId(self, cards)
	local cards_id = {}
	for _, card in ipairs(cards) do
		table.insert(cards_id, card:getEffectiveId())
	end
	return cards_id
end
sgs.ai_skill_invoke.Zongxuan = function(self, data)  --试着完全搬运观星，结果搬运到一半弃疗了，因为实在太复杂而且看不懂有木有啊！！！！！:( 所以现在乱七八糟
	--if not self:willShowForDefence() then return false end
	if self.top_draw_pile_id then return false end
	--if self.player:getPhase() >= sgs.Player_Finish then return false end  --todo：处理回合外的情况
	
	local list = self.player:property("ZongxuanToGet"):toString():split("+")
	--local bottom = getIdToCard(self, cards)
	local bottom = {}
	for _, card_id_str in ipairs(list) do
		local card = sgs.Sanguosha:getCard(tonumber(card_id_str))
		table.insert(bottom, card)
	end
	self:sortByUseValue(bottom, true)  --这是按自己的useValue排，而我还不会按别人的。。
	local up = {}
	
	local canZhiyan = (self.player:hasSkills("Zhiyan") and (self.player:getPhase() >= sgs.Player_Play) and (self.player:getPhase() <= sgs.Player_Discard) and not self.player:isSkipped(sgs.Player_Finish))
	local current = global_room:getCurrent()
	if not current then
		current = global_room:getAlivePlayers():first()
	end
	local next_player  --来自观星（目前无法处理放权连破挟天子等情况）
	if current:getPhase() ~= sgs.Player_NotActive then
		for _, p in sgs.qlist(global_room:getOtherPlayers(current)) do
			if p:faceUp() then next_player = p break end
		end
		next_player = next_player or current:faceUp() and current or current:getNextAlive()
	else
		if current:faceUp() then 
			next_player = current
		else
			for _, p in sgs.qlist(global_room:getOtherPlayers(current)) do
				if p:faceUp() then next_player = p break end
			end
			next_player = next_player or current:faceUp() and current or current:getNextAlive()
		end
	end
	
	--乱七八糟的一段，写出来自己都不知道啥意思或者干啥用。。。弃疗了
	local current_will_judge = ((current:getPhase() < sgs.Player_Judge) and not current:getJudgingArea():isEmpty() and not current:hasShownSkills("qiaobian|shensu") and not current:isSkipped(sgs.Player_Judge)) 
								or (current:getPhase() == sgs.Player_NotActive)
	if current_will_judge and (current:getPhase() < sgs.Player_Start) then
		current_will_judge = current_will_judge and not next_player:hasShownSkills("luoshen|guanxing|yizhi|qianxi|yinghun_sunjian|yinghun_sunce")
								and not (next_player:hasShownSkills("shenzhi") and next_player:isWounded())
	end
	local current_will_draw = ((current:getPhase() < sgs.Player_Draw) and not current_will_judge and not current:hasShownSkills("tuxi|qiaobian|xunxun") and not current:isSkipped(sgs.Player_Draw))
								or (current:getPhase() == sgs.Player_NotActive)
	local next_will_judge = next_player and (not next_player:hasShownSkills("qiaobian|shensu") and not current_will_judge and not current_will_draw)
								and not current:hasShownSkills("Jujian|Miji|Jingce|shengxi")
								and not next_player:hasShownSkills("luoshen|guanxing|yizhi|qianxi|yinghun_sunjian|yinghun_sunce")
								and not (next_player:hasShownSkills("shenzhi") and next_player:isWounded())
	local next_judging_player = current_will_judge and current or (next_will_judge and next_player or nil)
	
	if next_judging_player then
		local judge = sgs.QList2Table(next_judging_player:getJudgingArea())
		judge = sgs.reverse(judge)
	else
		local judge = {}
	end
	
	local has_lightning, self_has_judged
	local judged_list = {}
	local willSkipDrawPhase, willSkipPlayPhase
	local is_friend_judging = next_judging_player and self:isFriend(next_judging_player) or false
	if judge and next(judge) then
		local lightning_index
		for judge_count, need_judge in ipairs(judge) do
			judged_list[judge_count] = 0
			if need_judge:isKindOf("Lightning") then
				lightning_index = judge_count
				has_lightning = need_judge
				continue
			elseif need_judge:isKindOf("Indulgence") then
				willSkipPlayPhase = true
				if next_judging_player:isSkipped(sgs.Player_Play) then continue end
			elseif need_judge:isKindOf("SupplyShortage") then
				willSkipDrawPhase = true
				if next_judging_player:isSkipped(sgs.Player_Draw) then continue end
			end
			local judge_str = sgs.ai_judgestring[need_judge:objectName()]
			if not judge_str then
				self.room:writeToConsole(debug.traceback())
				judge_str = sgs.ai_judgestring[need_judge:getSuitString()]
			end
			for index, for_judge in ipairs(bottom) do
				local suit = for_judge:getSuitString()
				if next_judging_player:hasShownSkill("hongyan") and suit == "spade" then suit = "heart" end
				if (is_friend_judging and (judge_str == suit)) or (not is_friend_judging and (judge_str ~= suit)) then
					table.insert(up, for_judge)
					table.remove(bottom, index)
					judged_list[judge_count] = 1
					self_has_judged = true
					if need_judge:isKindOf("SupplyShortage") then willSkipDrawPhase = false
					elseif need_judge:isKindOf("Indulgence") then willSkipPlayPhase = false
					end
					break
				end
			end
		end

		if lightning_index then
			for index, for_judge in ipairs(bottom) do
				local cardNumber = for_judge:getNumber()
				local cardSuit = for_judge:getSuitString()
				if self.player:hasSkill("hongyan") and cardSuit == "spade" then cardSuit = "heart" end
				if (is_friend_judging and not (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade")) or (not is_friend_judging and (for_judge:getNumber() >= 2 and cardNumber <= 9 and cardSuit == "spade")) then
					local i = lightning_index > #up and 1 or lightning_index
					table.insert(up, i , for_judge)
					table.remove(bottom, index)
					judged_list[lightning_index] = 1
					self_has_judged = true
					break
				end
			end
			if judged_list[lightning_index] == 0 then
				if #up >= lightning_index then
					for i = 1, #up - lightning_index + 1 do
						table.insert(bottom, table.remove(up))
					end
				end
				up = getBackToId(self, up)
				bottom = getBackToId(self, bottom)
				self.player:setTag("AI_ZongxuanDrawPileCards", sgs.QVariant(table.concat(up, "+")))
				if canZhiyan then self.player:setFlags("AI_DoNotInvokeZhiyan") end
				return true
			end
		end

		if not self_has_judged and #judge > 0 then
			--return {}, cards
			if canZhiyan then self.player:setFlags("AI_DoNotInvokeZhiyan") end
			return false
		end

		--完全不懂
		--[[local index
		if willSkipDrawPhase then
			for i = #judged_list, 1, -1 do
				if judged_list[i] == 0 then index = i
				else break
				end
			end
		end]]

		for i = 1, #judged_list do
			if judged_list[i] == 0 then
				--[[if i == index then
					up = getBackToId(self, up)
					bottom = getBackToId(self, bottom)
					return up, bottom
				end]]
				table.insert(up, i, table.remove(bottom, 1))
			end
		end

	end
	
	--本来想在这里继续插入观星的内容，最后放弃了
	
	if (#up == 0) and not self:willShowForDefence() then return false end
	local willZhiyan = false
	local zhiyan_card
	if canZhiyan and not self.player:hasFlag("AI_DoNotInvokeZhiyan") then  --最后处理
		local valuable
		for _, card in ipairs(bottom) do
			if card:isKindOf("EquipCard") then
				for _, friend in ipairs(self.friends) do
					if not (card:isKindOf("Armor") and not friend:getArmor() and friend:hasShownSkills(sgs.viewhas_armor_skill))
						and (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse")
							or (card:isKindOf("Weapon") and self:evaluateWeapon(card) > self:evaluateWeapon(friend:getWeapon()) - 1) or friend:hasShownSkills(sgs.lose_equip_skill)) then
						--self.top_draw_pile_id = card_id
						--self.player:setTag("AI_ZongxuanDrawPileCards", sgs.QVariant(tostring(card_id)))
						zhiyan_card = card
						willZhiyan = true
						--return true
						--return "@ZongxuanCard=" .. card_id
					end
				end
			elseif self:isValuableCard(card) and not valuable then
				valuable = card
				willZhiyan = true
			end
		end
		if valuable and not zhiyan_card then
			zhiyan_card = valuable
			willZhiyan = true
		end
	end
	local result = {}
	if willZhiyan then
		--[[self.top_draw_pile_id = valuable
		self.player:setTag("AI_ZongxuanDrawPileCards", sgs.QVariant(tostring(valuable)))
		return true]]
		table.insert(result, zhiyan_card:getId())
	elseif canZhiyan and (next(up) ~= nil) and not self.player:hasFlag("AI_DoNotInvokeZhiyan") then
		self.player:setFlags("AI_DoNotInvokeZhiyan")
	end
	for _,card in ipairs(up) do
		table.insert(result, card:getId())
	end
	if #result > 0 then
		self.top_draw_pile_id = result[1]
		self.player:setTag("AI_ZongxuanDrawPileCards", sgs.QVariant(table.concat(result, "+")))
		return true
	end
	return false
end
sgs.ai_skill_movecards.Zongxuan = function(self, upcards, downcards, min_num, max_num)  --todo：借鉴灭计/涯角/【攻心】（应该简单点）
	local zongxuan_cards = self.player:getTag("AI_ZongxuanDrawPileCards"):toString():split(":")
	self.player:removeTag("AI_ZongxuanDrawPileCards")
	local upcards_copy = table.copyFrom(upcards)
	local down = {}
	for _,id_str in ipairs(zongxuan_cards) do
		table.insert(down, tonumber(id_str))
		table.removeAll(upcards_copy, tonumber(id_str))
	end
	return upcards_copy, down
end

-- 直言
sgs.ai_skill_playerchosen.Zhiyan = function(self, targets)
	if self.player:hasFlag("AI_DoNotInvokeZhiyan") then
		self.player:setFlags("-AI_DoNotInvokeZhiyan")
		return nil
	end
	if self.top_draw_pile_id then
		local card = sgs.Sanguosha:getCard(self.top_draw_pile_id)
		if card:isKindOf("EquipCard") then
			self:sort(self.friends, "hp")
			for _, friend in ipairs(self.friends) do
				if (not self:getSameEquip(card, friend) or card:isKindOf("DefensiveHorse") or card:isKindOf("OffensiveHorse") or friend:hasShownSkills(sgs.lose_equip_skill) or (card:isKindOf("Armor") and self:needToThrowArmor(friend)))
					and not (card:isKindOf("Armor") and (friend:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, friend) < 0) and not self:needToThrowArmor(friend)) then  --evaluateArmor和needToThrowArmor这里可能有点问题
					return friend
				end
			end
			if not (card:isKindOf("Armor") and (self.player:hasSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card) < 0))
				and not (card:isKindOf("Weapon") and self.player:getWeapon() and self:evaluateWeapon(card) < self:evaluateWeapon(self.player:getWeapon()) - 1) then
				return self.player
			end
			--找了一圈都没找到，只能替换装备了
			for _, friend in ipairs(self.friends) do
				if self:isWeak(friend) or (friend:isWounded() and (card:isKindOf("Weapon") and self:evaluateWeapon(card) > self:evaluateWeapon(friend:getWeapon()) - 1))
					and not (card:isKindOf("Armor") and (friend:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, friend) < 0) and not self:needToThrowArmor(friend))
					and not (card:isKindOf("Treasure") and friend:getTreasure() and friend:getPile("wooden_ox"):length() > 1) then
					return friend
				end
			end
			if self.player:isWounded() and not (card:isKindOf("Armor") and (self.player:hasSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card) < 0)) then
				return self.player
			end
			--坑一波敌人
			for _, enemy in ipairs(self.enemy) do
				if (card:isKindOf("Armor") and (enemy:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, enemy) < 0) and not self:needToThrowArmor(enemy))
					or (card:isKindOf("Treasure") and enemy:getTreasure() and enemy:getPile("wooden_ox"):length() > 2) then
					return enemy
				end
			end
		else
			local cards = { card }
			local card, player = self:getCardNeedPlayer(cards)
			if player then
				return player
			else
				self:sort(self.friends)
				for _, friend in ipairs(self.friends) do
					if not self:needKongcheng(friend, true) --[[and not hasManjuanEffect(friend)]] then return friend end
				end
			end
		end
	else
		if not self:willShowForDefence() then return nil end
		self:sort(self.friends)
		for _, friend in ipairs(self.friends) do
			if not self:needKongcheng(friend, true) --[[and not hasManjuanEffect(friend)]] then return friend end
		end
	end
	return nil
end
--sgs.ai_playerchosen_intention.Zhiyan = -60
sgs.ai_playerchosen_intention.Zhiyan = function(self, from, to)
	if self.top_draw_pile_id then
		local card = sgs.Sanguosha:getCard(self.top_draw_pile_id)
	end
	if not card then
		sgs.updateIntention(from, to, -60)
	elseif not (card:isKindOf("Armor") and (to:hasShownSkills(sgs.viewhas_armor_skill) or self:evaluateArmor(card, to) < 0) and not self:needToThrowArmor(to))
		and not (card:isKindOf("Treasure") and to:getTreasure() and to:getPile("wooden_ox"):length() > 2) then
		sgs.updateIntention(from, to, -60)
	end
end

----------------------------------------------------------------------------------------------------

-- YJ 211 朱然

-- 胆守
local danshou_skill = {}
danshou_skill.name = "Danshou"
table.insert(sgs.ai_skills, danshou_skill)
danshou_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	local times = self.player:getMark("Danshou") + 1
	if times < self.player:getCardCount(true) then
		return sgs.Card_Parse("#DanshouCard:.:&Danshou")
	end
end
sgs.ai_skill_use_func["#DanshouCard"] = function(card, use, self)
	local times = self.player:getMark("Danshou") + 1
	local cards = self.player:getCards("he")
	local jink_num = self:getCardsNum("Jink")
	local to_discard = {}
	for _, id in sgs.qlist(self.player:getPile("wooden_ox")) do
		cards:append(sgs.Sanguosha:getCard(id))
	end
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local has_weapon = false
	local DisWeapon = false
	local DisOffensiveHorse = false
	for _, card in ipairs(cards) do
		if card:isKindOf("Weapon") and card:isBlack() then has_weapon = true end
	end
	for _, card in ipairs(cards) do
		if self.player:canDiscard(self.player, card:getEffectiveId()) and ((self:getUseValue(card) < sgs.ai_use_value.Dismantlement + 1) or self:getOverflow() > 0) then
			local shouldUse = true
			if card:isKindOf("Armor") then
				if not self.player:getArmor() then shouldUse = false
				elseif self.player:hasEquip(card) and not (card:isKindOf("SilverLion") and self.player:isWounded()) then shouldUse = false
				end
			end
			if card:isKindOf("Weapon") and self.player:getHandcardNum() > 2 then
				if not self.player:getWeapon() then shouldUse = false
				elseif self.player:hasEquip(card) and not has_weapon then shouldUse = false
				else DisWeapon = true
				end
			end
			if card:isKindOf("Weapon") and self.player:hasEquip(card) then  --源码漏掉的距离判断
				DisWeapon = true
			end
			if card:isKindOf("OffensiveHorse") and self.player:hasEquip(card) then
				DisOffensiveHorse = true
			end
			if card:isKindOf("Slash") then
				local dummy_use = { isDummy = true }
				if self:getCardsNum("Slash") == 1 then
					self:useBasicCard(card, dummy_use)
					if dummy_use.card then shouldUse = false end
				end
			end
			if self:getUseValue(card) > sgs.ai_use_value.Dismantlement + 1 and card:isKindOf("TrickCard") then
				local dummy_use = { isDummy = true }
				self:useTrickCard(card, dummy_use)
				if dummy_use.card then shouldUse = false end
			end
			if isCard("Peach", card, self.player) then
				if times ~= 3 then shouldUse = false end
			end
			if isCard("Jink", card, self.player) then
				if jink_num <= 1 and times == 1 then shouldUse = false
				else jink_num = jink_num - 1 end
			end
			if shouldUse then
				table.insert(to_discard, card:getEffectiveId())
				if #to_discard == times then break end
			end
		end
	end

	local distance_fix = 0
	if DisWeapon then distance_fix = self.player:getWeapon():getRealCard():toWeapon():getRange() - self.player:getAttackRange(false) end
	if DisOffensiveHorse then distance_fix = distance_fix + 1 end
	local target
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if (self.player:distanceTo(p, distance_fix) <= self.player:getAttackRange()) and (self.player:distanceTo(p) ~= -1) or table.contains(self.player:property("in_my_attack_range"):toString():split("+"), p:objectName()) then  --基本来自lua中的inMyAttackRangeFromV2
			if times == 1 or times == 2 then
				if self.player:canDiscard(p, "he") and not p:isNude() then
					if self:isFriend(p) then
						if(self:hasSkills(sgs.lose_equip_skill, p) and not p:getEquips():isEmpty())
						or (self:needToThrowArmor(p) and p:getArmor()) or self:doNotDiscard(p) then
							target = p  break end
					elseif self:isEnemy(p) then
						if times == 2 and self:needToThrowArmor(p) then continue
						elseif (not self:doNotDiscard(p) or self:getDangerousCard(p) or self:getValuableCard(p)) then
							target = p  break end
					end
				end
			elseif times == 3 then
				if self:isEnemy(p) then
					if self:damageIsEffective(p, nil, self.player) and not self:getDamagedEffects(p, self.player)
					and not self:needToLoseHp(p, self.player) and ((self:isWeak(p) and p:getHp() < 3) or self:getOverflow() > 3)  then
						target = p  break end
				end
			elseif times == 4 then
				if self:isFriend(p) and p:isWounded() then
					target = p  break end
			end
		end
	end
	if target and #to_discard == times then
		use.card = sgs.Card_Parse("#DanshouCard:" .. table.concat(to_discard, "+") .. ":&Danshou")
		if use.to then use.to:append(target) end
		return
	end
end
sgs.ai_use_priority.DanshouCard = sgs.ai_use_priority.Dismantlement + 2
sgs.ai_use_value.DanshouCard = sgs.ai_use_value.Dismantlement + 1
sgs.ai_card_intention.DanshouCard = function(self, card, from, tos)
	local num = card:subcardsLength()
	if num == 2 or num == 3 then
		sgs.updateIntentions(from, tos, 10)
	elseif num == 4 then
		sgs.updateIntentions(from, tos, -10)
	end
end
sgs.ai_choicemade_filter.cardChosen.Danshou = sgs.ai_choicemade_filter.cardChosen.snatch
sgs.ai_skill_exchange.Danshou = function(self, pattern, max_num, min_num, expand_pile)
	local to_discard = {}
	local cards = self.player:getHandcards()
	local zhuran = sgs.findPlayerByShownSkillName("Danshou")
	cards = sgs.QList2Table(cards)
	if self:isFriend(zhuran) then  --抄恩怨
		for _, card in ipairs(cards) do
			if isCard("Peach", card, zhuran) and ((not self:isWeak() and self:getCardsNum("Peach") > 0) or self:getCardsNum("Peach") > 1) then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
			if isCard("Analeptic", card, zhuran) and self:getCardsNum("Analeptic") > 1 then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
			if isCard("Jink", card, zhuran) and self:getCardsNum("Jink") > 1 then
				table.insert(to_discard, card:getEffectiveId())
				return to_discard
			end
		end
	end
	self.player:setFlags("Global_AIDiscardExchanging")  --v2中exchange就是用discard进行的
	local to_exchange = self:askForDiscard("Danshou", 1, 1, false, true)
	self.player:setFlags("-Global_AIDiscardExchanging")
	return to_exchange
end

--------------------------------------------一将成名2014--------------------------------------------

-- YJ 301 蔡夫人

-- 窃听
sgs.ai_skill_invoke.Qieting = function(self, data)
	if not self:willShowForDefence() then return false end
	if self:needKongcheng(self.player, true) then
		local target = self.room:getCurrent()
	
		local disable_list = {}
		for i = 0, 4 do
			if target:getEquip(i) and self.player:getEquip(i) then
				table.insert(disable_list, target:getEquip(i):getEffectiveId())
			end
		end
		local id = self:askForCardChosen(target, "e", "dummyReason", sgs.Card_MethodNone, disable_list)  --dummy可确保并非强制
		if not id then
			return false
		end
	end
	return true
end
sgs.ai_skill_choice.Qieting = function(self, choices)
	local target = self.room:getCurrent()
	
	local disable_list = {}
	for i = 0, 4 do
		if target:getEquip(i) and self.player:getEquip(i) then
			table.insert(disable_list, target:getEquip(i):getEffectiveId())
		end
	end
	local id = self:askForCardChosen(target, "e", "dummyReason", sgs.Card_MethodNone, disable_list)  --dummy可确保并非强制
	if id and id ~= -1 then
		for i = 0, 4 do
			if target:getEquip(i) and target:getEquip(i):getEffectiveId() == id and string.find(choices, i) then
				return i
			end
		end
	end
	return "draw"
end

-- 献州
local xianzhou_skill = {}
xianzhou_skill.name = "Xianzhou"
table.insert(sgs.ai_skills, xianzhou_skill)
xianzhou_skill.getTurnUseCard = function(self)
	if not self:willShowForDefence() and not self:willShowForAttack() then return end
	if self.player:getMark("@handover") <= 0 then return end
	if self.player:getEquips():isEmpty() then return end
	
	--下面这些其实是从useEquipCard对枭姬的判断改来的……
	local armor = self.player:getArmor()
	if armor and armor:objectName() == "PeaceSpell" and self.player:getHp() == 1 and not (self.player:hasLordSkill("hongfa") and not self.player:getPile("heavenly_army"):isEmpty()) then
		local peach_num = self:getCardsNum("Analeptic") + (self.player:hasShownSkill("wansha") and self:getCardsNum("Peach") or self:getAllPeachNum())
		if peach_num == 0 then
			return
		end
	end
	if self.player:getWeapon() and self.player:getWeapon():objectName() == "Crossbow" and self:getCardsNum("Slash") > 2 then
		local d_use = {isDummy = true,to = sgs.SPlayerList()}
		local slash = sgs.Sanguosha:cloneCard("slash")
		slash:deleteLater()
		self:useCardSlash(slash,d_use)
		if d_use.card then
			return
		end
	end
	
	return sgs.Card_Parse("#XianzhouCard:.:&Xianzhou")
end
sgs.ai_skill_use_func["#XianzhouCard"] = function(card, use, self)
	local xianzhou_values = {}  --记录献州牌对每个队友的价值（伤害）
	local function cmp_Xianzhou_value(a, b)
		local ar_a = xianzhou_values[a:objectName()]
		local ar_b = xianzhou_values[b:objectName()]
		if ar_a == ar_b then
			if a:getAttackRange() == b:getAttackRange() then
				return sgs.getDefense(a) > sgs.getDefense(b)
			else
				return a:getAttackRange() > b:getAttackRange()
			end
		else
			return ar_a > ar_b
		end
	end
	
	local len = self.player:getEquips():length()
	local weapon, armor = self.player:getWeapon(), self.player:getArmor()
	local lostHp = self.player:getLostHp()
	if armor and armor:isKindOf("SilverLion") then lostHp = lostHp - 1 end
	if armor and armor:isKindOf("PeaceSpell") and not (self.player:hasLordSkill("hongfa") and not self.player:getPile("heavenly_army"):isEmpty()) then lostHp = lostHp + 1 end
	local willBeWounded = (lostHp > 0)
	
	for _,friend in ipairs(self.friends_noself) do  --Initialize Xianzhou value
		local value = 0
		if friend:hasShownSkills(sgs.need_equip_skill) then value = value + 2 end
		if friend:hasShownSkills(sgs.lose_equip_skill) then value = value + 2 end
		if friend:hasShownSkills(sgs.cardneed_skill) then value = value + 1 end
		
		if weapon then
			if not friend:getWeapon() then value = value + self:evaluateWeapon(weapon, friend) / 5
			else value = value + math.max(self:evaluateWeapon(weapon, friend) - self:evaluateWeapon(friend:getWeapon(), friend) - 1, 0) / 5 end
		end
		if armor then
			if not friend:getArmor() then value = value + self:evaluateArmor(armor, friend) / 5
			else value = value + math.max(self:evaluateArmor(armor, friend) - self:evaluateArmor(friend:getWeapon(), friend) - 1, 0) / 5 end
		end
		
		local all_friends = not willBeWounded  --若蔡夫人未受伤则必须选择伤害
		local avail_enemies = {}
		for _, target in sgs.qlist(self.room:getOtherPlayers(friend)) do
			if not friend:inMyAttackRange(target) then continue end
			if not self:isFriend(target) or not self:damageIsEffective(target, nil, friend) or self:getDamagedEffects(target, friend) then
				all_friends = false
			end
			if not self:isEnemy(target) and not (#self.enemies == 0 and self:objectiveLevel(target) > 3) then continue end
			if self:damageIsEffective(target, nil, friend) and not self:getDamagedEffects(target, friend) and not self:needToLoseHp(target, friend) then
				table.insert(avail_enemies, self:isWeak(target) and 1.5 or 1)
			end
		end
		table.sort(avail_enemies)  --升序
		if #avail_enemies > 0 then
			for i = math.max(#avail_enemies - len + 1, 1), #avail_enemies do
				value = value + avail_enemies[i]
			end
		end
		
		xianzhou_values[friend:objectName()] = all_friends and -99 or value
	end
	
	if self:isWeak() and willBeWounded then
		table.sort(self.friends_noself, cmp_Xianzhou_value)
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.need_equip_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.lose_equip_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			if friend:hasShownSkills(sgs.cardneed_skill) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			end
		end
		for _, friend in ipairs(self.friends_noself) do
			--if not hasManjuanEffect(friend) then
				use.card = card
				if use.to then use.to:append(friend) end
				return
			--end
		end
		if sgs.turncount > 2 then  --防止全暗将时期献州（应该有更好的写法，未知）
			self:sort(self.friends)
			for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if self:objectiveLevel(target) > 0 and target:hasShownSkills(sgs.need_equip_skill) then continue end
				local canUse = true
				for _, friend in ipairs(self.friends) do
					if friend:objectName() ~= target:objectName() and target:inMyAttackRange(friend) and self:damageIsEffective(friend, nil, target)
						and not self:getDamagedEffects(friend, target) and not self:needToLoseHp(friend, target) then
						canUse = false
						break
					end
				end
				if canUse then
					use.card = card
					if use.to then use.to:append(target) end
					return
				end
			end
		end
	end
	if --[[not willBeWounded and]] #self.friends_noself > 0 then  --坑掉虚弱的敌人（注意此时必须选择造成伤害）（融合了源码的未受伤和原项目的体力为1）
		local consider_killers = {}
		self:sort(self.friends_noself)
		for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if not self:isEnemy(target) and not (#self.enemies == 0 and self:objectiveLevel(target) > 3) then continue end
			for _, friend in ipairs(self.friends_noself) do
				if friend:objectName() ~= target:objectName() and friend:inMyAttackRange(target) and self:damageIsEffective(target, nil, friend)
					and not self:getDamagedEffects(target, friend) and not self:needToLoseHp(target, friend)
					and ((self:isWeak(target) and not willBeWounded) or (target:getHp() <= 1 and not hasNiepanEffect(target) and not hasBuquEffect(target))) then
					if not table.contains(consider_killers, friend) then table.insert(consider_killers, friend) end
				end
			end
		end
		if #consider_killers > 0 then
			table.sort(consider_killers, cmp_Xianzhou_value)
			use.card = card
			if use.to then use.to:append(consider_killers[1]) end
			return
		end
	end

	if #self.friends_noself == 0 then return end
	if self.player:getEquips():length() > 2 or self.player:getEquips():length() > #self.enemies and sgs.turncount > 2 then
		table.sort(self.friends_noself, cmp_Xianzhou_value)
		if xianzhou_values[self.friends_noself[1]:objectName()] >= self.player:getEquips():length() then
			use.card = card
			if use.to then use.to:append(self.friends_noself[1]) end
			return
		end
	end
end
sgs.ai_use_priority.XianzhouCard = 4.9
sgs.ai_card_intention.XianzhouCard = function(self, card, from, tos)
	if not from:isWounded() then sgs.updateIntentions(from, tos, -10) end
end
sgs.ai_skill_playerchosen.Xianzhou = function(self, targets, max_num, min_num)
	local current = self.player:getTag("XianzhouSource"):toPlayer()
	if not current then return {} end
	if self:isWeak(current) and self:isFriend(current) and not (current:getLostHp() == 1 and max_num > 1) then return {} end
	
	local value = 0  --用于与回血选项比较
	local victims = {}
	self:sort(self.enemies, "hp")
	for _, enemy in ipairs(self.enemies) do
		if self.player:inMyAttackRange(enemy) and self:damageIsEffective(enemy, nil, self.player)
			and not self:getDamagedEffects(enemy, self.player) and not self:needToLoseHp(enemy, self.player)
			and not table.contains(victims, enemy) then
			table.insert(victims, enemy)
			value = value + (self:isWeak(enemy) and 1.5 or 1)
			if #victims == max_num then break end
		end
	end
	if #victims < max_num then  --masochism friends
		self:sort(self.friends_noself)
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self.player:inMyAttackRange(friend) and self:damageIsEffective(friend, nil, self.player)
				and (self:getDamagedEffects(friend, self.player) or self:needToLoseHp(friend, self.player) or friend:hasShownSkills(sgs.masochism_skill))
				and not table.contains(victims, friend) then
				table.insert(victims, friend)
				value = value + 0.7
				if #victims == max_num then break end
			end
		end
	end
	if #victims < max_num then
		for _, target in sgs.qlist(targets) do
			if not self:isFriend(target) and self:isWeak(target) and not table.contains(victims, target) then
				table.insert(victims, target)
				value = value + 0.3
				if #victims == max_num then break end
			end
		end
	end

	if value < math.min(current:getLostHp(), max_num) * 1.2 and self:isFriend(current) then  
		return {}
	end
	if #victims >= min_num then return victims end
	
	--min_num为1（必须选择伤害）
	for _, target in sgs.qlist(targets) do
		if not self:isFriend(target) and not table.contains(victims, target) then
			table.insert(victims, target)
			if #victims == min_num then break end
		end
	end
	if #victims < min_num then
		self:sort(self.friends_noself)
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _, friend in ipairs(self.friends_noself) do
			if self.player:inMyAttackRange(friend) and not self:damageIsEffective(friend, nil, self.player) and not table.contains(victims, friend) then
				table.insert(victims, friend)
				if #victims == min_num then break end
			end
		end
	end
	if #victims < min_num then
		for _, target in sgs.qlist(targets) do
			if not table.contains(victims, target) then
				table.insert(victims, target)
				if #victims == min_num then break end
			end
		end
	end
	
	return victims
end
sgs.ai_choicemade_filter.playerChosen.Xianzhou = function(self, from, promptlist)
	if from:objectName() == promptlist[3] then return end
	local reason = string.gsub(promptlist[2], "%-", "_")
	local tos = promptlist[3]:split("+")
	local to
	local caifuren = from:getTag("XianzhouSource"):toPlayer()
	if caifuren and not caifuren:isWounded() then return end
	
	for _, to_str in ipairs(tos) do
		to = findPlayerByObjectName(to_str)
		if not to then continue end
		if self:damageIsEffective(to, nil, from) and not self:getDamagedEffects(to, from) and not self:needToLoseHp(to, from) and not to:hasShownSkills(sgs.masochism_skill) then
			sgs.updateIntention(from, to, 10)
		end
	end
end
function sgs.ai_cardneed.Xianzhou(to, card, self)
	if to:getMark("@handover") <= 0 then return end
	if to:getEquips():isEmpty() and self:isWeak(to) --[[and not self:willSkipPlayPhase(to)]] then
		return card:isKindOf("EquipCard")  --需要装备牌献州回血
	end
end

--------------------------------------------一将成名2015--------------------------------------------

-- YJ 409 张嶷

-- 怃戎
function SmartAI:findPlayerToDamage(damage, source, nature, targets, include_self, base_value, return_table)  --仅出现于怃戎，暂且先放到这里（日后必有重谢）
    damage = damage or 1
    nature = nature or sgs.DamageStruct_Normal
    source = source or nil
    base_value = base_value or 0
    if include_self == nil then include_self = true    end
    
    local victims
    if targets then
        victims = targets
    else
        victims = include_self and self.room:getOtherPlayers(self.player) or self.room:getAlivePlayers()
    end
    if type(victims) ~= "table" then
        victims = sgs.QList2Table(victims)
    end
    if #victims == 0 then
        if return_table then
            return {}
        else
            return nil
        end
    end
    
    --[[local JinXuanDi = self.room:findPlayerBySkillName("wuling")
    local windEffect = ( JinXuanDi and JinXuanDi:getMark("@wind") > 0 )
    if windEffect and nature == sgs.DamageStruct_Fire then
        damage = damage + 1
    end
    local thunderEffect = ( JinXuanDi and JinXuanDi:getMark("@thunder") > 0 )
    if thunderEffect and nature == sgs.DamageStruct_Thunder then
        damage = damage + 1
    end]]
    
    local isSourceFriend = ( source and self:isFriend(source) )
    local isSourceEnemy = ( source and self:isEnemy(source) )
    
    local function getDamageValue(target, self_only)
        local value = 0
        local isFriend = self:isFriend(target)
        local isEnemy = self:isEnemy(target)
        --local careLord = ( self.role == "renegade" and target:isLord() and self.room:alivePlayerCount() > 2 )
		local willInvokeBreastplate = false
        local count = damage
        if self:damageIsEffective(target, nature, source) then
			--todo：绝情
            --[[if target:hasSkill("chouhai") and target:isKongcheng() then
                count = count + 1
            end]]
            if nature == sgs.DamageStruct_Fire then  --todo：雷电伤害（助祭）
                if target:getMark("@gale") > 0 then
                    count = count + 1
                end
                if target:getMark("@gale_ShenZhuGeLiang") > 0 then
                    count = count + 1
                end
                if target:hasShownSkill("Ranshang") then
                    count = count + 1
                end
			end
			local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
			if jiaren_zidan and jiaren_zidan:isFriendWith(target) then
				count = 1
			end
			if nature == sgs.DamageStruct_Fire then
                if target:hasArmorEffect("Vine") then
                    count = count + 1
                --[[elseif target:hasArmorEffect("bossmanjia") then
                    count = count + 1]]
                end
            end
            if count > 1 and target:hasArmorEffect("silver_lion") then
                count = 1
            end
        else
            count = 0
        end
        if count > 0 then
            value = value + count * 20 --设1牌价值为10，且1体力价值2牌，1回合价值2.5牌，下同
            local hp = target:getHp()
            local deathFlag = false
            if count >= hp then
                deathFlag = ( count >= hp + self:getAllPeachNum(target) )
            end
            if deathFlag then
                value = value + 500
            else
                --if hp >= getBestHp(target) + count then
				if hp >= target:getMaxHp() + count then
                    value = value - 2
                end
                if self:needToLoseHp(target, source) then
                    value = value - 5
                end
                if self:isWeak(target) then
                    value = value + 15
                else
                    value = value + 12 - sgs.getDefense(target)
                end
                if hp <= count then
                    if target:hasShownSkill("Jiushi") and target:faceUp() then
                        value = value + 25
                    end
                end
                if self:getDamagedEffects(target, source) then  --懒得考虑其他卖血流了，直接这样吧
                    if target:hasShownSkill("yiji") then
                        value = value - 20 * count
                    end
                    if target:hasShownSkill("YijiLB") then
                        value = value - 10 * count
                    end
                    if target:hasShownSkill("jieming") then
                        local chaofeng = self:getJiemingChaofeng(target)
                        if chaofeng > 0 then --chaofeng = 5 - draw * 2, draw < 2
                            value = value - ( 5 - chaofeng ) * 5
                        else --chaofeng = - draw * 2, draw >= 2
                            value = value + chaofeng * 5
                        end
                    end
                    if target:hasShownSkill("Guixin") then
                        value = value + 25
                        local others = self.room:getOtherPlayers(target)
                        local x = 0
                        for _,p in sgs.qlist(others) do
                            if not p:isAllNude() then
                                x = x + 1
                                if self:isFriend(p, target) then
                                    if not p:getJudgingArea():isEmpty() then
                                        value = value - 5
                                    end
                                elseif p:isNude() then
                                    value = value + 5
                                end
                            end
                        end
                        --if not hasManjuanEffect(target) then
                            value = value - x * 10
                        --end
                    end
                    if target:hasShownSkill("Chengxiang") then
                        value = value - 15
                    end
                    --[[if target:hasShownSkill("noschengxiang") then
                        value = value - 15
                    end]]
                end
            end
            if isFriend then
                value = - value
            elseif not isEnemy then
                value = value / 2
            end
            if self_only or nature == sgs.DamageStruct_Normal then
            elseif target:isChained() then
                local others = self.room:getOtherPlayers(target)
                for _,p in sgs.qlist(others) do
                    if p:isChained() then
                        local v = values[p:objectName()] or getDamageValue(p, true)
                        value = value + v
                    end
                end
            end
            if self:cantbeHurt(target, source, count) then
                value = value - 800
            end
            --[[if deathFlag and careLord then
                value = value - 1000
            end]]
        end
        return value
    end
    
    local values = {}
    for _,victim in ipairs(victims) do
        values[victim:objectName()] = getDamageValue(victim, false) or 0
    end
    
    local compare_func = function(a, b)
        local valueA = values[a:objectName()] or 0
        local valueB = values[b:objectName()] or 0
        --return valueA >= valueB  --等于时交换会导致不稳定排序，从而崩
		if valueA == valueB then
			return sgs.getDefense(a) < sgs.getDefense(b)
		else
			return valueA > valueB
		end
    end
    
    table.sort(victims, compare_func)
    
    if return_table then
        local result = {}
        for _,victim in ipairs(victims) do
            if values[victim:objectName()] > base_value then
                table.insert(result, victim)
            end
        end
        return result
    end
    
    local victim = victims[1]
    local value = values[victim:objectName()] or 0
    if value > base_value then
        return victim
    end
    
    return nil
end
function getKnownHandcards(player, target)
    local handcards = target:getHandcards()
    
    if player:objectName() == target:objectName() then
        return sgs.QList2Table(handcards), {}
    end
    
    --[[local dongchaee = global_room:getTag("Dongchaee"):toString() or ""
    if dongchaee == target:objectName() then
        local dongchaer = global_room:getTag("Dongchaer"):toString() or ""
        if dongchaer == player:objectName() then
            return sgs.QList2Table(handcards), {}
        end
    end]]
    
    local knowns, unknowns = {}, {}
    local flag = string.format("visible_%s_%s", player:objectName(), target:objectName())
    for _,card in sgs.qlist(handcards) do
        if card:hasFlag("visible") or card:hasFlag(flag) then
            table.insert(knowns, card)
        else
            table.insert(unknowns, card)
        end
    end
    return knowns, unknowns
end
local wurong_skill = {}
wurong_skill.name = "Wurong"
table.insert(sgs.ai_skills, wurong_skill)
wurong_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end
    if self.player:hasUsed("#WurongCard") then
        return nil
    elseif self.player:isKongcheng() then
        return nil
    end
    return sgs.Card_Parse("#WurongCard:.:&Wurong")
end
sgs.ai_skill_use_func["#WurongCard"] = function(card, use, self)
    local handcards = self.player:getHandcards()
    local my_slashes, my_cards = {}, {}
    for _,c in sgs.qlist(handcards) do
        if c:isKindOf("Slash") or (self.player:hasSkill("Shizhi") and self.player:getHp() == 1 and self.player:getMark("CompanionEffect") == 0 and c:isKindOf("Jink")) then
            table.insert(my_slashes, c)
        else
            table.insert(my_cards, c)
        end
    end
    local no_slash = ( #my_slashes == 0 ) 
    local all_slash = ( #my_cards == 0 ) 
    local need_slash, target = nil, nil
	local target_slash, target_no_slash, target_no_limit = nil, nil, nil
	local prioritize_no_slash = false
	
	local all_jink, has_jink, no_jink = {}, {}, {}
	for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		local knowns, unknowns = getKnownHandcards(self.player, p)
		all_jink[p:objectName()] = (#unknowns == 0)
		has_jink[p:objectName()] = false
		no_jink[p:objectName()] = (#unknowns == 0)
		for _,jink in ipairs(knowns) do
			if jink:isKindOf("Jink") then
				no_jink[p:objectName()] = false
				has_jink[p:objectName()] = true
			else
				all_jink[p:objectName()] = false
			end
		end
	end
    
    --自己展示的一定不是【杀】，目标展示的必须是【闪】，方可获得目标一张牌
    if no_slash then
        local others = self.room:getOtherPlayers(self.player)
        local targets = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, others, true)  --旧版要改
        for _,p in ipairs(targets) do
            if not p:isKongcheng() and all_jink[p:objectName()] then
				if not target_no_slash then target_no_slash = p end
				break
            end
        end
		if not target_no_slash then			--放宽条件（毕竟all_jink很难达成，导致原版AI对有没有闪判断太僵硬）
			for _,p in ipairs(targets) do
				--if not p:isKongcheng() and getCardsNum("Jink", p, self.player) > p:getHandcardNum() - 1 then  
				if not p:isKongcheng() and getKnownCard(p, self.player, "Jink", false) > p:getHandcardNum() - 1 then  
					if not target_no_slash then target_no_slash = p end
					break
				end
			end
		end
		if not target_no_slash then
			for _,p in ipairs(targets) do
				if not p:isKongcheng() and not no_jink[p:objectName()] then  
					if not target_no_slash then target_no_slash = p end
					break
				end
			end
		end
    end
    
    --自己展示的一定是【杀】，目标展示的不是【闪】时，可对目标造成1点伤害
	if all_slash and not target_slash then
        local targets = self:findPlayerToDamage(1, self.player, nil, nil, false, 5, true)
        for _,p in ipairs(targets) do
            if not p:isKongcheng() then
                local knowns, unknowns = getKnownHandcards(self.player, p)
                if self:isFriend(p) and not all_jink[p:objectName()] then --队友会配合不展示【闪】的
					if not target_slash then target_slash = p end
                    break
                elseif (self:isEnemy(p) or #self.enemies == 0) and not has_jink[p:objectName()] then
					if not target_slash then target_slash = p end
                    break
                end
            end
        end
    end
    
    --自己展示的不一定是【杀】，可根据目标情况决定展示的牌
	if not target_slash or not target_no_slash or not target_no_limit then
        local friends, enemies, others = {}, {}, {}
        local other_players = self.room:getOtherPlayers(self.player)
        for _,p in sgs.qlist(other_players) do
            if not p:isKongcheng() then
                if self:isFriend(p) then
                    table.insert(friends, p)
                elseif self:isEnemy(p) then
                    table.insert(enemies, p)
                else
                    table.insert(others, p)
                end
            end
        end
        
		if not target_slash then  --New if
			local to_damage = self:findPlayerToDamage(1, self.player, nil, enemies, false, 5, true)
			for _,enemy in ipairs(to_damage) do
				if no_jink[enemy:objectName()] then
					if not target_slash then target_slash = enemy end
					break
				end
			end
			if not target_slash then
				for _,enemy in ipairs(to_damage) do
					--if getCardsNum("Jink", enemy, self.player) < 1 then
					if getKnownCard(enemy, self.player, "Jink", false) < 1 then
						if not target_slash then target_slash = enemy end
						break
					end
				end
			end
			if not target_slash then
				for _,enemy in ipairs(to_damage) do
					if not all_jink[enemy:objectName()] then
						if not target_slash then target_slash = enemy end
						break
					end
				end
			end
		end
        
        --if not target then
		if not target_no_slash then
            local other_players = self.room:getOtherPlayers(self.player)
            local to_obtain = self:findPlayerToDiscard("he", false, sgs.Card_MethodGet, other_players, true)
            for _,p in ipairs(to_obtain) do
                if not p:isKongcheng() then
                    if self:isFriend(p) and has_jink[p:objectName()] then
						if not target_no_slash then
							target_no_slash = p
							if self:needToThrowArmor(p) then prioritize_no_slash = true end
						end
						break
                    elseif (self:isEnemy(p) or #self.enemies == 0) and all_jink[p:objectName()] then
						if not target_no_slash then
							target_no_slash = p 
							if self:getDangerousCard(p) then prioritize_no_slash = true end
						end
						break
                    end
                end
            end
			if not target_no_slash then
				for _,p in ipairs(to_obtain) do
					if not p:isKongcheng() then
						--if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and ((getCardsNum("Jink", p, self.player) > p:getHandcardNum() - 1) or self:getDangerousCard(p)) then
						if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and ((getKnownCard(p, self.player, "Jink", false) > p:getHandcardNum() - 1) or self:getDangerousCard(p)) then
							if not target_no_slash then
								target_no_slash = p 
								if self:getDangerousCard(p) then prioritize_no_slash = true end
							end
							break
						end
					end
				end
			end
			if not target_no_slash then
				for _,p in ipairs(to_obtain) do
					if not p:isKongcheng() then
						if (self:isEnemy(p) or #self.enemies == 0) and not self:isFriend(p) and (not no_jink[p:objectName()] or self:getDangerousCard(p) or self:getValuableCard(p)) then
							if not target_no_slash then
								target_no_slash = p 
								if self:getDangerousCard(p) then prioritize_no_slash = true end
							end
							break
						end
					end
				end
			end
        end
        
		if not target_slash then
            to_damage = self:findPlayerToDamage(1, self.player, nil, friends, false, 25, true)
            for _,friend in ipairs(to_damage) do
                if not all_jink[p:objectName()] then
					if not target_slash then target_slash = friend end
                    break
                end
            end
        end
		
		if not target_slash then
            local victim = self:findPlayerToDamage(1, self.player, nil, others, false, 5)
            if victim and (self:objectiveLevel(victim) > 0 or #self.enemies == 0) then
				if not target_slash then target_slash = victim end
            end
        end
        
        --只是为了看牌……
		if not target_no_limit and #my_cards > 0 and self:getOverflow() > 0 then
            if #enemies > 0 then
                self:sort(enemies, "handcard")
				if not target_no_limit then target_no_limit = enemies[1] end
            elseif #others > 0 then
                --self:sort(others, "threat")  --threat是什么鬼
                self:sort(others, "handcard")
				if others[1] and (self:objectiveLevel(others[1]) > 0 or #self.enemies == 0) then
					if not target_no_limit then target_no_limit = others[1] end
				end
            end
        end
        
		if not target_no_limit and #enemies > 0 then
            self:sort(enemies, "defense")
			if not target_no_limit then target_no_limit = enemies[1] end
        end
    end
    
	if prioritize_no_slash and target_no_slash and not target_no_slash:isKongcheng() and not all_slash then
		target = target_no_slash
		need_slash = false
	elseif target_slash and not target_slash:isKongcheng() and not no_slash then
		target = target_slash
		need_slash = true
	elseif not willShowShizhi(self) then
	elseif target_no_slash and not target_no_slash:isKongcheng() and not all_slash then
		target = target_no_slash
		need_slash = false
	elseif target_no_limit and not target_no_limit:isKongcheng() then
		target = target_no_limit
		need_slash = (math.random(0, 1) == 0)
		if all_slash then need_slash = true
		elseif no_slash then need_slash = false end
	end
	
    if target and not target:isKongcheng() then
        local use_cards = need_slash and my_slashes or my_cards
        if #use_cards > 0 then
            self:sortByUseValue(use_cards, true)
            local card_str = "#WurongCard:"..use_cards[1]:getEffectiveId() .. ":&Wurong"
            local acard = sgs.Card_Parse(card_str)
            use.card = acard
            if use.to then
                use.to:append(target)
            end
        end
    end
end
sgs.ai_use_priority.WurongCard = 3.1
sgs.ai_use_value.WurongCard = 4.5
sgs.ai_skill_exchange.Wurong = function(self, pattern, max_num, min_num, expand_pile)
	local to_discard = {}
	local cards = self.player:getHandcards()
	local zhangni = sgs.findPlayerByShownSkillName("Wurong")
	cards = sgs.QList2Table(cards)
	
	local my_jinks, my_cards = {}, {}
    for _,c in ipairs(cards) do
        if c:isKindOf("Jink") then
            table.insert(my_jinks, c)
        else
            table.insert(my_cards, c)
        end
    end
	self:sortByKeepValue(my_jinks)
	self:sortByKeepValue(my_cards)
	
    local no_jink = (#my_jinks == 0) 
    local all_jink = (#my_cards == 0) 
	
	local knowns, unknowns = getKnownHandcards(self.player, zhangni)
	local zhangni_no_slash, zhangni_all_slash = (#unknowns == 0), (#unknowns == 0)
	for _,c in ipairs(knowns) do
        if c:isKindOf("Slash") then
            zhangni_no_slash = false
        else
            zhangni_all_slash = false
        end
    end
	
	local needDamage, needGetCard = false, false
	local preventDamage, preventGetCard = false, false
	
	if self:isFriend(zhangni) then
		if self:needToLoseHp(self.player, zhangni) or self:getDamagedEffects(self.player, zhangni) then
			needDamage = true
		elseif self:needToThrowArmor() or (self.player:hasSkills(sgs.lose_equip_skill) and not self.player:getEquips():isEmpty()) or self:needKongcheng() then
			needGetCard = true
		end
	else
		if not self:damageIsEffective(self.player, nil, zhangni) then needDamage = true
		elseif self:isWeak() then preventDamage = true
		elseif self.player:hasSkills(sgs.masochism_skill) or self:needToLoseHp(self.player, zhangni) or self:getDamagedEffects(self.player, zhangni) or self:cantbeHurt(self.player, zhangni) then
			needDamage = true
		end
		if self.player:getCards("he"):length() == 1 and self:needKongcheng()  then needGetCard = true
		elseif self:getDangerousCard(self.player) or self:getValuableCard(self.player) then preventGetCard = true
		end
	end
	
	local mustShowJink = needGetCard or (preventDamage and not zhangni_no_slash)
	local preventShowJink = needDamage or (preventGetCard and not zhangni_all_slash)
	
	if mustShowJink and not no_jink then
		return my_jinks[1]:getEffectiveId()
	elseif preventShowJink and not all_jink then
		return my_cards[1]:getEffectiveId()
	else  --杀吧主流是无脑展示闪，但是太那啥。。
		if math.random() < 0.7 and not no_jink then
			return my_jinks[1]:getEffectiveId()
		else
			self:sortByKeepValue(cards)
			return cards[1]:getEffectiveId()
		end
	end
end

-- 矢志
sgs.ai_skill_invoke.Shizhi = false  --需要闪当杀的话用视为技
function willShowShizhi(self)
--本来打算也放到view_as里的，结果会导致嵌套
	if self.player:hasShownSkill("Shizhi") or not self.player:hasSkill("Shizhi") then return true end
	if (self.player:getHp() ~= 1 and not self:isWeak()) or self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then return true end
	local cards = sgs.QList2Table(self.player:getHandcards())
	local jinks = {}
	for _,card in ipairs(cards) do
		if card:isKindOf("Jink") then 
			table.insert(jinks, card)
			if self:isWeak() and self:getCardsNum("Jink") <= 1 and (self:getCardsNum("Peach") + self:getCardsNum("Analeptic") < 1) then
				return false
			end
		end
	end
	if #jinks == 0 then return not self:isWeak() end
	
	self:sortByUseValue(jinks)  --判断价值最高的一张牌是否依然低于杀
	local card = jinks[1]
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	local slash = sgs.Card_Parse(("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id))
	assert(slash)
	local value = self:getUseValue(slash)
	if self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then  --二次转化大法好
		local jink = sgs.Card_Parse(("jink:longdan[%s:%s]=%d&longdan"):format(suit, number, card_id))
		assert(jink)
		value = math.max(value, self:getUseValue(jink))
	end
	return self:getUseValue(card) < value
end
sgs.ai_view_as.Shizhi = function(card, player, card_place)
	if player:getHp() == 1 and not player:hasShownSkill("Shizhi") then
		local suit = card:getSuitString()
		local number = card:getNumberString()
		local card_id = card:getEffectiveId()
		if card_place == sgs.Player_PlaceHand and card:isKindOf("Jink") and not card:hasFlag("using") then
			return ("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id)
		end
	end
end
local shizhi_skill = {}
shizhi_skill.name = "Shizhi"
table.insert(sgs.ai_skills, shizhi_skill)
shizhi_skill.getTurnUseCard = function(self, inclusive)
	if self.player:hasShownSkill("Shizhi") or self.player:getHp() ~= 1 then return end
	if not willShowShizhi(self) then return end
	if self.player:hasSkills("longdan|longdan_ZhaoYun_LB") then return end
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end
	
	local handcards = self.player:getHandcards()
	local real_slashes = {}
	for _,slash in sgs.qlist(handcards) do
		if isCard("Slash", slash, self.player) then table.insert(real_slashes, slash) end
	end
	
	local cards = {}
	for _, card in sgs.qlist(handcards) do
		if card:isKindOf("Jink") and (not self:isWeak() or self:hasCrossbowEffect() or useAll) then  --条件非常苛刻，只有一击必杀才能矢志，因为实在太伤了
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:Shizhi[%s:%s]=%d&Shizhi"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				local hasEffectiveSlash = false
				if #real_slashes > 0 then  --尝试解决手里有真杀还亮矢志的问题
					local use = {to = sgs.SPlayerList(), isDummy = true}
					self:useBasicCard(slash, use)
					if use.card and use.card:isKindOf("Slash") and use.to and not use.to:isEmpty() then
						for _,realslash in ipairs(real_slashes) do
							local use2 = {to = sgs.SPlayerList(), isDummy = true}
							self:useBasicCard(realslash, use2)
							if use2.card and use2.card:isKindOf("Slash") and use2.to and not use2.to:isEmpty() then
								local same_targets = true
								for _,to in sgs.qlist(use.to) do
									if not use2.to:contains(to) then same_targets = false break end
								end
								if same_targets then hasEffectiveSlash = true break end
							end
						end
					end
				end
				if not hasEffectiveSlash then
					table.insert(cards, slash)
				end
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end

--------------------------------------------原创之魂2016--------------------------------------------

-- YC 008 张让

-- 滔乱
function findTaoluanFriend(self, player, exclude_typeid, include_typeids, valuable)  --查找确定有目标牌的队友
	player = player or self.player
	valuable = valuable or false
	if exclude_typeid ~= "" then
		types = {"BasicCard", "TrickCard", "EquipCard"}
		table.removeOne(types, exclude_typeid)
	elseif type(include_typeids) == "table" then
		types = include_typeids
	end
	
	local function typesCount(target)  --计算可以给的牌数
		local sum = 0
		for _,typeid in pairs(types) do
			--sum = sum + getCardsNum(typeid, target, player)  --各种问题
			local unknowns = {}
			for _,card in sgs.qlist(target:getCards("he")) do
				if sgs.cardIsVisible(card, target, player) then
					if card:isKindOf(typeid) then sum = sum + 1 end
				else
					table.insert(unknowns, card)
				end
			end
			if #unknowns >= 1 and typeid == "BasicCard" then
				sum = sum + #unknowns - 1
			end
		end
		return sum
	end
	
	--self:updatePlayers()
	local friends = table.copyFrom(self.friends_noself)  --getFriendsNoself有莫名其妙的bug，既然这里的player注定是self.player，先这样好了
	if not next(friends) or #friends == 0 or (#friends == 1 and not friends[1]) then return nil end
	self:sort(friends, "handcard")
	friends = sgs.reverse(friends)
	for _, friend in ipairs(friends) do
		if typesCount(friend) <= 0 then continue end
		if self:needKongcheng(friend) and (friend:getHandcardNum() == 1) then return friend end
		if not self:hasLoseHandcardEffective(friend) then return friend end
		if friend:hasShownSkills(sgs.lose_equip_skill) and table.contains(types, "EquipCard") then return friend end
		if friend:hasShownSkill("tuntian") then return friend end
	end
	
	local friends_copy = table.copyFrom(friends)
	for _,friend in ipairs(friends_copy) do
		if (self:isWeak(friend) or friend:hasShownSkills(sgs.cardneed_skill)) and friend:getCards("he"):length() <= (valuable and 2 or 3) then
			table.removeAll(friends, friend)
		end
	end
	
	for _, friend in ipairs(friends) do
		if friend:getCards("he"):length() >= 3 and not friend:hasShownSkills(sgs.cardneed_skill) and (typesCount(friend) > (valuable and 0 or 1)) then return friend end
	end
	for _, friend in ipairs(friends) do
		if not friend:hasShownSkills(sgs.cardneed_skill) and (typesCount(friend) > (valuable and 0 or 1)) then return friend end
	end
	for _, friend in ipairs(friends) do
		if friend:getCards("he"):length() >= 3 and (typesCount(friend) > (valuable and 0 or 1)) then return friend end
	end
	for _, friend in ipairs(friends) do
		if typesCount(friend) > (valuable and 0 or 1) then return friend end
	end
	return nil
end
local taoluan_skill = {}
taoluan_skill.name = "Taoluan"
table.insert(sgs.ai_skills, taoluan_skill)
taoluan_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end  --似乎响应出牌在ai_cardsview里，所以这里是攻击端？
	
	--本来是OL滔乱判断第一张牌价值的，这里还是用了，如果滔乱牌价值都低于可使用的第一张牌就不滔乱
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	
	local can_use_not_valuable_basic = findTaoluanFriend(self, self.player, "BasicCard", {}, false)  --预处理（否则太慢）
	local can_use_not_valuable_trick = findTaoluanFriend(self, self.player, "TrickCard", {}, false)
	if not next(self.friends_noself) then return end
	local dorn = {"peach", "analeptic", "god_salvation", "savage_assault", "archery_attack", "duel", "burning_camps"}  --对队友要求放宽松的
	local super_impt = {"peach", "god_salvation"}  --体力为1也能使用的
	
	local allowed = self.player:property("guhuo_box_allowed_elemet"):toString():split("+")
	local choices = {}
	for _, name in ipairs(allowed) do
		local card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, 0)
		card:setCanRecast(false)
		if card and card:isAvailable(self.player) and not self.player:isLocked(card) then
			if self.player:getHp() <= 1 and not table.contains(super_impt, name) then
			elseif not (card:isKindOf("BasicCard") and can_use_not_valuable_basic or can_use_not_valuable_trick) and not table.contains(dorn, name) then
			else
				table.insert(choices, name)
			end
		end
	end
	
	if next(choices) then --如果可以使用
		local to_use = table.copyFrom(choices)
		for _,c in sgs.qlist(self.player:getCards("he")) do
			table.removeAll(to_use, c:objectName())
		end
		
		if next(to_use) then
			local value
			if next(cards) then
				value = math.max(self:getKeepValue(cards[1]), self:getUseValue(cards[1]))
			else
				local slash = sgs.Sanguosha:cloneCard("slash")
				slash:deleteLater()
				value = self:getUseValue(slash)
			end
			local tcard
			
			local cards_to_use = {}
			for _, name in pairs(to_use) do
				c = sgs.Card_Parse((name .. ":Taoluan[%s:%s]=.&%s"):format("no_suit", 0, "Taoluan"))
				assert(c)
				if self:getUseValue(c) > value then
					table.insert(cards_to_use, c)
				end
			end
			self:sortByUseValue(cards_to_use)
			for _, c in ipairs(cards_to_use) do
				local dummy_use = { isDummy = true }
				local dummy_card = sgs.Card_Parse("#TaoluanCard:.:" .. c:objectName() .. "&Taoluan")
				sgs.ai_skill_use_func["#TaoluanCard"](dummy_card, dummy_use, self)  --确保会使用这张牌（防止最高value的牌找出来了却不用的情况）
				if dummy_use.card then
					tcard = c
					break
				end
			end
			if tcard then
				sgs.ai_use_priority.TaoluanCard = self:getDynamicUsePriority(tcard) - 0.1
				return sgs.Card_Parse("#TaoluanCard:.:" .. tcard:objectName() .. "&Taoluan")
			end
		end
	end
end
sgs.ai_skill_use_func["#TaoluanCard"] = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]:split("&")[1]
	local taoluancard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	taoluancard:setSkillName("Taoluan")
	taoluancard:setShowSkill("Taoluan")
	local can_recast = taoluancard:canRecast()
	taoluancard:setCanRecast(false)
	if taoluancard:getTypeId() == sgs.Card_TypeBasic then
		if not use.isDummy and use.card and taoluancard:isKindOf("Slash") and (not use.to or use.to:isEmpty()) then return end  --来自蛊惑（似乎是为了解决使用空杀的问题）
		self:useBasicCard(taoluancard, use)
	else
		assert(taoluancard)
		self:useTrickCard(taoluancard, use)
	end
	if not use.card then return end
	if can_recast and not taoluancard:isKindOf("FightTogether") then   --知己知彼源码有bug（968行忘加rec &&）  todo：在新版本中已修复，无需单独判断
		if not use.to or use.to:length() == 0 then use.card = nil return end
	end
	use.card = card
end
sgs.ai_cardsview["Taoluan"] = function(self, class_name, player)
	if self.Taoluan_testing then return end
	if not self:willShowForDefence() then return end
	if not player:hasSkill("Taoluan") then return end
	if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local classname2objectname = {
		["Slash"] = "slash", ["Jink"] = "jink",
		["Peach"] = "peach", ["Analeptic"] = "analeptic",
		["Nullification"] = "nullification",
		["HegNullification"] = "heg_nullification",
		["FireSlash"] = "fire_slash", ["ThunderSlash"] = "thunder_slash"
	}
	local name = classname2objectname[class_name]
	if not name then return end
	local no_have = true
	local cards = player:getCards("he")
	for _,c in sgs.qlist(cards) do
		if c:isKindOf(class_name) then
			no_have = false
			break
		end
	end
	if not no_have then return end
	if class_name == "Peach" and player:getMark("Global_PreventPeach") > 0 then return end
	
	local has_friends = false
	local card = sgs.Sanguosha:cloneCard(name)
	has_friends = findTaoluanFriend(self, player, card:getTypeId(), {}, card:isKindOf("Nullification") or card:isKindOf("Peach"))
	if not has_friends and self:isWeak(player) and not (card:isKindOf("Peach") and self.player:hasFlag("Global_Dying")) then return end
	local yuji = sgs.findPlayerByShownSkillName("qianhuan") and self.player:isFriendWith(yuji)
	local caiwenji = sgs.findPlayerByShownSkillName("beige") and self.player:isFriendWith(caiwenji) and not caiwenji:isNude()
	if not has_friends and card:isKindOf("Jink") and (yuji or caiwenji) then return end
	
	cards = sgs.QList2Table(cards)
	self.Taoluan_testing = true
	self:sortByUseValue(cards, true)
	self.Taoluan_testing = false
	local allowed = player:property("guhuo_box_allowed_elemet"):toString():split("+")
	if table.contains(allowed, name) then
		return "#TaoluanCard:.:" .. name .. "&Taoluan"
	end
end
sgs.ai_skill_playerchosen.Taoluan = function(self, targets)
	self:updatePlayers()
	local friends = self.friends_noself
	self:sort(friends, "handcard")
	local target = nil
	local taoluan_types = self.player:getTag("TaoluanType"):toString():split(",")
	
	target = findTaoluanFriend(self, self.player, "", taoluan_types, false)
	target = target or findTaoluanFriend(self, self.player, "", taoluan_types, true)
	
	local current = self.room:getCurrent()
	if not target then
		if #friends > 0 then
			local consider_friends = {}
			for i = #friends, 1, -1 do
				friend = friends[i]
				if friend:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. friend:objectName() .. "no" .. typeid) then lack = false end  --来自下面那个函数，张让与OL张让公用
				end
				if lack then continue end
				table.insert(consider_friends, friend)
			end
			--以下照抄findTaoluanFriend
			for _, friend in ipairs(consider_friends) do
				if self:needKongcheng(friend) and (friend:getHandcardNum() == 1) then target = friend break end
				if not self:hasLoseHandcardEffective(friend) then target = friend break end
				if friend:hasShownSkills(sgs.lose_equip_skill) and table.contains(taoluan_types, "EquipCard") then target = friend break end
				if friend:hasShownSkill("tuntian") then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if friend:getCards("he"):length() >= 3 and not self:isWeak(friend) and not friend:hasShownSkills(sgs.cardneed_skill) then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if not self:isWeak(friend) and not friend:hasShownSkills(sgs.cardneed_skill) then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if friend:getCards("he"):length() >= 3 then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				target = friend
				break
			end
		end
	end
	if not target then
		targets = sgs.QList2Table(targets)
		self:sort(targets, "handcard")
		for _, p in ipairs(targets) do
			if self:isEnemy(p) then continue end
			for _,typeid in pairs(taoluan_types) do
				if getCardsNum(typeid, p, self.player) > 0 then
					target = p
					break
				end
			end
		end
		if not target then
			for i = #targets, 1, -1 do
				if self:isEnemy(targets[i]) or targets[i]:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. targets[i]:objectName() .. "no" .. typeid) then lack = false end
				end
				if lack then continue end
				target = targets[i]
				break
			end
		end
		if not target then
			for i = #targets, 1, -1 do
				if targets[i]:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. targets[i]:objectName() .. "no" .. typeid) then lack = false end
				end
				if lack then continue end
				target = targets[i]
				break
			end
		end
		if not target then
			target = targets[math.random(1, #targets)]
		end
	end
	return target
end
sgs.ai_skill_cardask["@Taoluan-give"] = function(self, data, pattern, target)  --张让与OL张让公用，下同
	local types = pattern:split("|")[1]:split(",")
	local function recordTaoluanFail()
		local current = self.room:getCurrent()
		self.room:addPlayerHistory(current, "#Taoluan" .. self.player:objectName() .. "no" .. types[1])
		self.room:addPlayerHistory(current, "#Taoluan" .. self.player:objectName() .. "no" .. types[2])
	end
	
	if target and (self:isEnemy(target) or self:objectiveLevel(target) >= 0) then 
		recordTaoluanFail()
		return "."
	end
	
	if self:needKongcheng(self.player) and (self.player:getHandcardNum() == 1) 
		or not self:hasLoseHandcardEffective(self.player) then
		local cards = sgs.QList2Table(self.player:getHandcards())
		self:sortByUseValue(cards, true)
		for _, card in ipairs(cards) do
			if not self:isValuableCard(card) or self:isFriend(target) then
				for _, classname in ipairs(types) do
					if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
				end
			end
		end
	end
	
	if self.player:hasShownSkills(sgs.lose_equip_skill) and table.contains(types, "EquipCard") then  --感觉写的各种渣
		local cards = sgs.QList2Table(self.player:getEquips())
		self:sortByUseValue(cards, true)
		for _, card in ipairs(cards) do
			if not self:isValuableCard(card) or self:isFriend(target) then
				for _, classname in ipairs(types) do
					if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
				end
			end
		end
	end
	
	local cards = sgs.QList2Table(self.player:getCards("he"))
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if not self:isValuableCard(card) or self:isFriend(target) then
			for _, classname in ipairs(types) do
				if card:isKindOf(classname) then return "$" .. card:getEffectiveId() end
			end
		end
	end
	recordTaoluanFail()
	return "."
end
sgs.ai_skill_choice.Taoluan_saveself = function(self, choices)
	return "analeptic"  --待改进
end
sgs.ai_skill_choice.Taoluan_slash = function(self, choices)
	local use = self.player:getTag("TaoluanSlashData"):toCardUse()
	if not use then return "slash" end
	--以下来自朱雀羽扇（todo：助祭）
	for _, target in sgs.qlist(use.to) do
		if self:isFriend(target) then
			if not self:damageIsEffective(target, sgs.DamageStruct_Fire) then return "fire_slash" end
			if not self:damageIsEffective(target, sgs.DamageStruct_Thunder) then return "thunder_slash" end
			if target:isChained() and self:isGoodChainTarget(target, nil, nil, nil, use.card) then return "fire_slash" end
		else
			if not self:damageIsEffective(target, sgs.DamageStruct_Fire) and not self:damageIsEffective(target, sgs.DamageStruct_Thunder) then return "normal_slash" end
			if target:isChained() and not self:isGoodChainTarget(target, nil, nil, nil, use.card) then return "normal_slash" end
			if target:hasArmorEffect("Vine") or target:getMark("@gale") > 0 then
				return "fire_slash"
			end
			if not self:damageIsEffective(target, sgs.DamageStruct_Fire) then return "thunder_slash" end
			if not self:damageIsEffective(target, sgs.DamageStruct_Thunder) then return "fire_slash" end
		end
	end
	return "normal_slash"
end
sgs.ai_skill_choice.Taoluan_nullification = function(self, choices)
	return "heg_nullification"
end

-------------------------------------------------SP-------------------------------------------------

---------------------------------------------界限突破SP---------------------------------------------

-- J.SP 003 关羽

-- 武圣
sgs.ai_view_as.wusheng_GuanYu_JSP = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getHandPile():contains(card_id)) and (player:getLord() and player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:wusheng_GuanYu_JSP[%s:%s]=%d&wusheng_GuanYu_JSP"):format(suit, number, card_id)
	end
end
local wusheng_skill = {}
wusheng_skill.name = "wusheng_GuanYu_JSP"
table.insert(sgs.ai_skills, wusheng_skill)
wusheng_skill.getTurnUseCard = function(self, inclusive)
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash") < 2 or self.player:hasSkills("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then disCrossbow = true end

	local hecards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getHandPile()) do
		hecards:prepend(sgs.Sanguosha:getCard(id))
	end
	local cards = {}
	for _, card in sgs.qlist(hecards) do
		if (self.player:getLord() and self.player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Slash")
			and ((not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player)) or useAll)
			and (not isCard("Crossbow", card, self.player) or disCrossbow ) then
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:wusheng_GuanYu_JSP[%s:%s]=%d&wusheng_GuanYu_JSP"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				table.insert(cards, slash)
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end
function sgs.ai_cardneed.wusheng_GuanYu_JSP(to, card)
	return sgs.ai_cardneed.wusheng(to, card)
end
sgs.ai_suit_priority.wusheng_GuanYu_JSP = sgs.ai_suit_priority.wusheng

-- 忠义
local zhongyi_skill = {}
zhongyi_skill.name = "Zhongyi"
table.insert(sgs.ai_skills, zhongyi_skill)
zhongyi_skill.getTurnUseCard = function(self)
	if self.player:getMark("@loyal") <= 0 or self.player:isKongcheng() or sgs.turncount <= 1 or not self:willShowForAttack() then return end
	if #self.enemies == 0 then return end

	cards = sgs.QList2Table(self.player:getHandcards())
	local red_card
	self:sortByUseValue(cards, true)
	for _, card in ipairs(cards) do
		if card:isRed() and not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player) and not isCard("BefriendAttacking", card, self.player) then
			red_card = card
			break
		end
	end

	if not red_card then return end

	local value = 0
	local friends = {}
	local hasAnjiang = false
	for _, friend in sgs.qlist(self.room:getAlivePlayers()) do
		if self:isFriendWith(friend) then table.insert(friends, friend) end
		if sgs.isAnjiang(friend) then hasAnjiang = true end
	end
	self:sort(self.enemies)
	local slash = sgs.Sanguosha:cloneCard("slash")
	for _, friend in ipairs(friends) do
		local local_value = 0
		for _, enemy in ipairs(self.enemies) do
			if friend:canSlash(enemy) and not self:slashProhibit(slash, enemy) and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then
				local_value = local_value + 0.8
				if getCardsNum("Jink", enemy) < 1 then local_value = local_value + 0.5 end
				local force_damage_skills = string.gsub(sgs.force_damage_skill, "|liegong", "")
				if friend:hasShownSkills(force_damage_skills)
					or (friend:hasShownSkill("liegong") and (enemy:getHandcardNum() <= friend:getAttackRange() or enemy:getHandcardNum() >= friend:getHp()))
					or friend:hasShownSkills(sgs.fake_force_damage_skill)
					or (friend:hasWeapon("Axe") or getCardsNum("Axe", friend, self.player) > 0) then
					local_value = local_value + 0.5
				end
				if self:isWeak(enemy) then local_value = local_value + 0.5 end
				break
			end
		end
		local slash_num = getCardsNum("Slash", friend)
		if friend == self.player and isCard("Slash", red_card, self.player) then slash_num = slash_num - 1 end
		local need_slash = string.gsub(sgs.need_as_many_slash_skill, "|Juesi", "")  --其实用sgs.need_as_many_slash_skill表示多杀技能并不严谨（决死），但还没有好的替代品
		if slash_num < 1 then local_value = local_value * 0.3
		elseif self:hasCrossbowEffect(friend) or friend:hasShownSkills(need_slash) then local_value = local_value * slash_num end
		if friend:hasShownSkill("shensu") and friend ~= self.player and friend:faceUp() and not self:isWeak(friend) then local_value = local_value * 1.2
		else
			if self:willSkipPlayPhase(friend) or not friend:faceUp() then local_value = local_value * 0.2 end
			if friend:hasShownSkills("shuangren|Mingce|Dangxian_LiaoHua|Dangxian_GuanSuo") and friend ~= self.player then local_value = local_value * 1.2 end
		end
		if friend == self.player and (not self:slashIsAvailable(self.player) or self.player:isLocked(slash)) then local_value = 0 end
		value = value + local_value
	end
	local ratio = value / #self.enemies
	if #friends == 1 and not hasAnjiang then ratio = ratio * 1.2 end
	if self:isWeak() then ratio = ratio * 1.2 end
	--if ratio > 0.85 then return sgs.Card_Parse("#ZhongyiCard:" .. red_card:getEffectiveId() .. ":&Zhongyi") end
	if ratio > 0.7 then return sgs.Card_Parse("#ZhongyiCard:" .. red_card:getEffectiveId() .. ":&Zhongyi") end  --原来是0.85，在国战太高
end
sgs.ai_skill_use_func["#ZhongyiCard"] = function(card, use, self)
	use.card = card
end
sgs.ai_use_priority.ZhongyiCard = 10

-- 怒斩
sgs.ai_skill_invoke.Nuzhan = function(self, data)
	local dat = self.player:getTag("NuzhanData")
	if data:toString() == "trick" then
		local use = dat:toCardUse()
		if use and use.card and use.card:getSkillName() == "wusheng_GuanYu_JSP" then return true end
		return self:willShowForAttack()
	elseif data:toString() == "equip" then
		local damage = dat:toCardUse()
		if damage and damage.card and damage.card:getSkillName() == "wusheng_GuanYu_JSP" then return true end
		if not self:willShowForAttack() then return false end  --开始抄暗箭
		local enemy = damage.to
		if self:isFriend(enemy) then return false end
		local damage_copy = damage
		damage_copy.damage = damage_copy.damage + 1
		if self:objectiveLevel(enemy) > 3 and self:damageIsEffective_(damage_copy)
			and (not enemy:hasArmorEffect("SilverLion") or self.player:hasWeapon("QinggangSword")) then
			return true
		end
	end
	return false
end
function sgs.ai_cardneed.Nuzhan(to, card, self)  --抄裸衣
	local slash_num = 0
	local target
	local slash = sgs.cloneCard("slash")

	self:sort(self.enemies, "defenseSlash")
	for _, enemy in ipairs(self.enemies) do
		if to:canSlash(enemy) and not self:slashProhibit(slash ,enemy) and self:slashIsEffective(slash, enemy) and sgs.getDefenseSlash(enemy, self) <= 2 then
			target = enemy
			break
		end
	end

	if target and isCard("Slash", card, to) then
		return card:isRed() and not card:isKindOf("BasicCard")
	end
end

---------------------------------------------RE修订武将---------------------------------------------

-- RE 004 马岱

-- 潜袭
sgs.ai_skill_invoke.QianxiRE = function(self, data)

	if not self:willShowForAttack() then
		return false
	end

	for _, p in ipairs(self.enemies) do
		if self.player:distanceTo(p) == 1 --[[and not p:isKongcheng()]] then
			return true
		end
	end
	return false
end
sgs.ai_skill_cardask["@QianxiRE"] = function(self, data)
	local enemies = {}
	local slash = self:getCard("Slash") or sgs.Sanguosha:cloneCard("slash")
	if self.player:isNude() or not self.player:canDiscard(self.player, "he") then return "." end
	local needRed = 0
	for _, p in ipairs(self.enemies) do
		if self.player:distanceTo(p) == 1 and not p:isKongcheng() then
			table.insert(enemies, p)
			if p:hasShownSkill("qingguo") and self:slashIsEffective(slash, p) then needRed = needRed - 1.5 end
			if p:hasShownSkill("kanpo") then needRed = needRed - 1 end
			if getKnownCard(p, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, p) and sgs.isGoodTarget(p, self.enemies, self) then needRed = needRed + 1.5 end
			if getKnownCard(p, self.player, "Peach", true, "h") > 0 or p:hasShownSkill("jijiu") then needRed = needRed + 1.2 end
			if getKnownCard(p, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, p) then needRed = needRed + 1 end
			if getKnownCard(p, self.player, "Analeptic", false, "h") > 0 and p:getHp() <= 1 then needRed = needRed - 0.8 end
			if getKnownCard(p, self.player, "Nullification", false, "h") > 0 then needRed = needRed - 0.5 end
		end
	end
	local cards = sgs.QList2Table(self.player:getCards("he"))
	if not next(cards) then return "." end
	self:sortByKeepValue(cards)
	local unpreferedCards = {}
	for _,card in ipairs(cards) do  --将test-ai里的for拆成了两段，体现优先级
		if self.player:isJilei(card) then
		elseif self:getValuableCard(self.player) and self:getValuableCard(self.player) == card:getEffectiveId() then
		--elseif (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or (self:getSameEquip(card, self.player) and not card:isEquipped())   --待优化
		elseif (card:isKindOf("Weapon") and self.player:getHandcardNum() < 3) or (self:getSameEquip(card, self.player) and not self.player:getEquips():contains(card))   --todo：待优化（该替换哪个武器/防具的问题）
			or card:isKindOf("AmazingGrace") or card:isKindOf("Lightning") or card:isKindOf("AllianceFeast") or card:isKindOf("ImperialOrder") or (card:isKindOf("ThreatenEmperor") and not card:isAvailable(self.player)) then
			table.insert(unpreferedCards, card)
		elseif self:needToThrowArmor() and self.player:getArmor():getEffectiveId() == card:getEffectiveId() then
			table.insert(unpreferedCards, card)
		end
	end
	for _,card in ipairs(cards) do
		if self.player:isJilei(card) then
		elseif card:isKindOf("Peach") or card:isKindOf("ExNihilo") or card:isKindOf("BefriendAttacking") then
		elseif self.player:getHp() <= 1 and not hasNiepanEffect(self.player) and card:isKindOf("Analeptic") and self:getCardsNum("Analeptic") <= 1 then
		elseif self:isWeak() and card:isKindOf("Jink") and self:getCardsNum("Jink") <= 1 then
		elseif card:isKindOf("WoodenOx") and self.player:getPile("wooden_ox"):length() > 1 then
		elseif self:getValuableCard(self.player) and self:getValuableCard(self.player) == card:getEffectiveId() then
		else
			table.insert(unpreferedCards, card)
		end
	end
	if #unpreferedCards == 0 then return "$" .. cards[1]:getEffectiveId() end
	for _,card in ipairs(unpreferedCards) do
		if needRed > 0 and card:isRed() then
			return "$" .. card:getEffectiveId()
		elseif needRed < 0 and card:isBlack() then
			return "$" .. card:getEffectiveId()
		end
	end
	for _,card in ipairs(unpreferedCards) do
		if card:isRed() then return "$" .. card:getEffectiveId()end
	end
	for _,card in ipairs(unpreferedCards) do
		return "$" .. card:getEffectiveId()
	end
	return "$" .. cards[1]:getEffectiveId()
end
sgs.ai_skill_playerchosen.QianxiRE = function(self, targets)
	local enemies = {}
	local kongcheng_enemies = {}  --自加，防卖血摸牌系
	local slash = self:getCard("Slash") or sgs.Sanguosha:cloneCard("slash")
	local isRed = (self.player:getTag("QianxiRE"):toString() == "red")

	for _, target in sgs.qlist(targets) do
		if self:isEnemy(target) and not target:isKongcheng() then
			table.insert(enemies, target)
		elseif self:isEnemy(target) then
			table.insert(kongcheng_enemies, target)
		end
	end
	if #enemies == 0 then
		enemies = kongcheng_enemies
	end

	if #enemies == 1 then
		return enemies[1]
	else
		self:sort(enemies, "defense")
		if not isRed then
			for _, enemy in ipairs(enemies) do
				if enemy:hasShownSkill("qingguo") and self:slashIsEffective(slash, enemy) then return enemy end
			end
			for _, enemy in ipairs(enemies) do
				if enemy:hasShownSkill("kanpo") then return enemy end
			end
			for _, enemy in ipairs(enemies) do  --自加
				if getKnownCard(enemy, self.player, "Analeptic", false, "h") > 0 and enemy:getHp() <= 1 then return enemy end
			end
			for _, enemy in ipairs(enemies) do  --自加
				if getKnownCard(enemy, self.player, "Nullification", false, "h") > 0 then return enemy end
			end
			for _, enemy in ipairs(enemies) do
				if enemy:hasShownSkill("guidao") then return enemy end
			end
			for _, enemy in ipairs(enemies) do
				if enemy:hasShownSkills("guicai|GuicaiLB") then return enemy end
			end
		else
			for _, enemy in ipairs(enemies) do
				if getKnownCard(enemy, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, enemy) and sgs.isGoodTarget(enemy, self.enemies, self) then return enemy end
			end
			for _, enemy in ipairs(enemies) do
				if getKnownCard(enemy, self.player, "Peach", true, "h") > 0 or enemy:hasShownSkill("jijiu") then return enemy end
			end
			for _, enemy in ipairs(enemies) do
				if getKnownCard(enemy, self.player, "Jink", false, "h") > 0 and self:slashIsEffective(slash, enemy) then return enemy end
			end
		end
		for _, enemy in ipairs(enemies) do
			if enemy:hasShownSkill("Longhun") then return enemy end
		end
		return enemies[1]
	end
	return targets:first()
end
sgs.ai_playerchosen_intention.QianxiRE = sgs.ai_playerchosen_intention.qianxi

----------------------------------------------------------------------------------------------------

-- RE 006 徐盛

-- 破军
function choosePojunRECards(self, who, max_num, min_num)
	if not who then return {} end
	if not max_num then max_num = who:getHp() end
	max_num = math.min(max_num, who:getCardCount(true))
	local cards = sgs.QList2Table(who:getEquips())
	local handcards = sgs.QList2Table(who:getHandcards())
	local chosen = {}
	local use = self.player:getTag("PojunRECardUse"):toCardUse()
	local slash = use and use.card or sgs.cloneCard("slash")
	local canJink = not self:canLiegong(who, self.player) and not self:canZhaxiang(self.player, nil, slash) and not who:isCardLimited(sgs.cloneCard("Jink"), sgs.Card_MethodUse)
	
	local function needToRemoveArmor()
		if not who:getArmor() then return false end
		if not slash then return false end
		if self:needToThrowArmor(who) then return self:isFriend(who) end
		
		local negativeEffect = (who:getArmor():isKindOf("Vine") and slash:isKindOf("FireSlash"))
		local positiveEffect = (who:getArmor():isKindOf("RenwangShield") and slash:isBlack())
							or (who:getArmor():isKindOf("PeaceSpell") and (slash:isKindOf("FireSlash") or slash:isKindOf("ThunderSlash")))
							or (who:getArmor():isKindOf("Vine") and not (slash:isKindOf("FireSlash") or slash:isKindOf("ThunderSlash")))
							or (who:getArmor():isKindOf("Breastplate") and who:getHp() == 1)
		
		if self:isFriend(who) then
			if negativeEffect and not (isCard("Slash", who:getArmor(), who) and canJink) then return true end
			if positiveEffect then return false end
			return false  --枭姬类单独考虑
		else
			if negativeEffect and not (isCard("Slash", who:getArmor(), who) and canJink) then return false end
			if positiveEffect then return true end
			if who:getArmor():isKindOf("PeaceSpell") and who:getHp() == 1 and self:getAllPeachNum(who) <= 1 and not (who:hasShownSkill("hongfa") and not who:getPile("heavenly_army"):isEmpty()) then return true end
			if isCard("Slash", who:getArmor(), who) and canJink then return true end
			if self:hasSkill(sgs.lose_equip_skill, who) then return false end
			if self:hasSkill(sgs.viewhas_armor_skill, who) then return false end
			if self:getFriendNumBySeat(self.room:getCurrent(), who) > 1 then return true end  --帮队友下敌人防具（注意此函数包括当前回合角色）
			return false
		end
	end
	
	if self:isFriend(who) then
		local consideredEquip = false
		if who:getCards("e"):length() > 0 then
			if needToRemoveArmor() then
				table.insert(chosen, who:getArmor():getEffectiveId())
				consideredEquip = self:hasSkill(sgs.lose_one_equip_skill, who)
				if #chosen == max_num then return chosen end
			end
			if self:hasSkill(sgs.lose_equip_skill, who) and not consideredEquip then
				self:sortByKeepValue(cards)
				for _, card in ipairs(cards) do
					if table.contains(chosen, card:getEffectiveId()) then continue end
					if card:isKindOf("Armor") and not needToRemoveArmor() then continue end
					if card:isKindOf("WoodenOx") and who:getPile("wooden_ox"):length() > 0 then continue end
					table.insert(chosen, card:getEffectiveId())
					consideredEquip = self:hasSkill(sgs.lose_one_equip_skill, who)
					if #chosen == max_num then return chosen end
					if consideredEquip then break end
				end
			end
		end
		local surplus = math.max(who:getHandcardNum() - (max_num - #chosen), 0)  --全选手牌的话剩余牌数
		local max_x = 0  --节命贲育补牌数
		if self:hasSkill("jieming", who) and who:getHp() > 1 and math.max(math.min(who:getMaxHp(), 5) - surplus, 0) > max_x then
			max_x = math.max(math.min(who:getMaxHp(), 5) - surplus, 0)
		end
		if self:hasSkill("Benyu", who) and who:getHp() > 1 and math.max(math.min(self.player:getHandcardNum(), 5) - surplus, 0) > max_x then
			max_x = math.max(math.min(self.player:getHandcardNum(), 5) - surplus, 0)
		end
		if max_x > 0 then
			local id
			for i = 1, math.min(max_num - #chosen, who:getHandcardNum()) do
				id = self:getCardRandomly(who, "h", chosen)
				table.insert(chosen, id)
				if #chosen == max_num then return chosen end
			end
		end
		if min_num > #chosen then  --强制选牌
			for _, card in ipairs(cards) do
				if table.contains(chosen, card:getEffectiveId()) then continue end
				if card:isKindOf("Armor") and not needToRemoveArmor() then continue end
				if card:isKindOf("WoodenOx") and who:getPile("wooden_ox"):length() > 0 then continue end
				table.insert(chosen, card:getEffectiveId())
				if #chosen == min_num then return chosen end
			end
			local id
			for i = #chosen + 1, min_num do
				id = self:askForCardChosen(who, "he", "", sgs.Card_MethodNone, chosen)
				if id == -1 then self.room:writeToConsole("Pojun card chosen error!") return chosen end
				table.insert(chosen, id)
				if #chosen == min_num then return chosen end
			end
		end
		return chosen
	else
		local disableEquips = {}
		if who:getCards("e"):length() > 0 then
			if who:getArmor() and needToRemoveArmor() then
				table.insert(chosen, who:getArmor():getEffectiveId())
				if #chosen == max_num then return chosen end
			elseif who:getArmor() then
				table.insert(disableEquips, who:getArmor():getEffectiveId())
			end
			if who:getTreasure() and who:getTreasure():isKindOf("WoodenOx") and who:getPile("wooden_ox"):length() > 1 then
				table.insert(chosen, who:getTreasure():getEffectiveId())
				if #chosen == max_num then return chosen end
			end
			self:sortByKeepValue(cards, true)
			for _, card in ipairs(cards) do  --移走其他装备的情况，待补充（司敌？）
				if table.contains(chosen, card:getEffectiveId()) or table.contains(disableEquips, card:getEffectiveId()) then continue end
				if isCard("Jink", card, who) and canJink then
					table.insert(chosen, card:getEffectiveId())
					if #chosen == max_num then return chosen end
				end
			end
		end
		
		local handcard_to_remove  --可能会超出max_num
		if self:getLeastHandcardNum(who) > 0 then
			local handcard_to_save = self:getLeastHandcardNum(who)
			if (getKnownCard(who, self.player, "Jink", true) > 0) or (getKnownCard(who, self.player, "Peach", true) + getKnownCard(who, self.player, "Analeptic", true) > 0 and who:getHp() == 1 and not hasBuquEffect(who) and not hasNiepanEffect(who)) then  --即使帮连营也要拿走闪桃的情况
				handcard_to_save = 0
			end
			handcard_to_remove = math.max(who:getHandcardNum() - handcard_to_save, 0)
		else
			handcard_to_remove = who:getHandcardNum()
		end
		if math.max(handcard_to_remove, max_num - #chosen) > 0 then
			local id
			for i = 1, math.max(handcard_to_remove, max_num - #chosen) do
				id = self:getCardRandomly(who, "h", chosen)
				table.insert(chosen, id)
				if #chosen == max_num then return chosen end
			end
		end
		
		if who:getCards("e"):length() > 0 then
			self:sortByKeepValue(cards, true)
			for _, card in ipairs(cards) do
				if table.contains(chosen, card:getEffectiveId()) or table.contains(disableEquips, card:getEffectiveId()) then continue end
				table.insert(chosen, card:getEffectiveId())
				if #chosen == max_num then return chosen end
			end
		end
		
		if min_num > #chosen then  --强制选牌（？）
			local id
			for i = #chosen + 1, min_num do
				id = self:askForCardChosen(who, "he", "", sgs.Card_MethodNone, chosen)
				if id == -1 then self.room:writeToConsole("Pojun card chosen error!") return chosen end
				table.insert(chosen, id)
				if #chosen == min_num then return chosen end
			end
		end
		return chosen
	end
	return chosen
end
sgs.ai_skill_invoke.PojunRE = function(self, data)
	if not self:willShowForAttack() then return false end
	local target = data:toPlayer()
	self.PojunRETarget = target
	local chosen = choosePojunRECards(self, target, math.min(target:getHp(), target:getCardCount(true)), 0)
	return chosen and #chosen > 0
end
sgs.ai_skill_choice.PojunRE_num = function(self, choices)  --For 2.1.0
	local items = choices:split("+")
	local target = self.PojunRETarget
	self.PojunRETarget = nil
	if not target then return "1" end
	local chosen = choosePojunRECards(self, target, #items, 1)
	if not chosen or #chosen == 0 then self.room:writeToConsole("PojunRE choosing card num error!") return "1" end
	self.PojunRENum = #chosen
	return tostring(#chosen)
end
sgs.ai_skill_cardchosen.PojunRE = function(self, who, flags, min_num, max_num, disable_list)  --For 2.1.0 (askForCardsChosen)
	local chosen = choosePojunRECards(self, who, self.PojunRENum, 1)
	if not chosen or #chosen == 0 then
		self.room:writeToConsole("PojunRE choosing card error!")
		return
	end
	for _,id in pairs(chosen) do
		if not table.contains(disable_list, id) then
			self.PojunRENum = self.PojunRENum - 1
			return id
		end
	end
	self.room:writeToConsole("PojunRE choosing card error! (available cards are empty)")
	return
end

-----------------------------------------------OL专属-----------------------------------------------

-- OL 00X 兀突骨

-- 燃殇
sgs.ai_skill_invoke.Ranshang = function(self, data)
	if self.player:getMark("Ranshang") > 1 then return false end
	return self:isWeak() and self.player:getHp() == 1
end

-- 悍勇
function SmartAI:HanyongAoeIsEffective(card, to, source)  --虽然aoeIsEffective也改了，但是这是用于发动悍勇的判断
	local players = self.room:getAlivePlayers()
	players = sgs.QList2Table(players)
	source = source or self.room:getCurrent()

	if to:hasArmorEffect("Vine") then
		return false
	end
	if self.player:isProhibited(to, card) then
        return false
    end
	if to:isLocked(card) then
		return false
	end

	if card:isKindOf("SavageAssault") then
		if to:hasShownSkills("huoshou|juxiang") then
			return false
		end
	end
	
    if to:getMark("@late") > 0 then
        return false
    end

	if to:hasShownSkill("weimu") and card:isBlack() then return false end

	local damageStruct = {}
	damageStruct.to = to
	damageStruct.from = source
	damageStruct.nature = sgs.DamageStruct_Normal
	damageStruct.damage = 2
	if not self:hasTrickEffective(card, to, source) or not self:damageIsEffective_(damageStruct) then
		return false
	end
	return true
end
function SmartAI:getHanyongAoeValue(card, damageNum)  --照抄getAoeValue
	local attacker = self.player
	local good, bad, isEffective_F, isEffective_E = 0, 0, 0, 0
	damageNum = damageNum or 1

	local current = self.room:getCurrent()
	local wansha = current:hasShownSkill("wansha")
	local peach_num = self:getCardsNum("Peach")
	local null_num = self:getCardsNum("Nullification")
	local punish
	local enemies, kills = 0, 0
	for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self.player:isFriendWith(p) and self:evaluateKingdom(p) ~= self.player:getKingdom() then enemies = enemies + 1 end
		if self:isFriend(p) then
			if not wansha then peach_num = peach_num + getCardsNum("Peach", p, self.player) end
			null_num = null_num + getCardsNum("Nullification", p, self.player)
		else
			null_num = null_num - getCardsNum("Nullification", p, self.player)
		end
	end
	if card:isVirtualCard() and card:subcardsLength() > 0 then
		for _, subcardid in sgs.qlist(card:getSubcards()) do
			local subcard = sgs.Sanguosha:getCard(subcardid)
			if isCard("Peach", subcard, self.player) then peach_num = peach_num - 1 end
			if isCard("Nullification", subcard, self.player) then null_num = null_num - 1 end
		end
	end

	local zhiman = self.player:hasSkills("Zhiman_MaSu|Zhiman_GuanSuo")
	local zhimanprevent
	if card:isKindOf("SavageAssault") then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		attacker = menghuo or attacker
		if self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhiman = true end  --似乎源码忘记了ShownSkill
		if not self:isFriend(attacker) and menghuo and menghuo:hasShownSkills("Zhiman_MaSu|Zhiman_GuanSuo") then zhimanprevent = true end  --源码忘记判断menghuo是否存在
	end
	
	local function getAoeValueTo(to)
		local value, sj_num = 0, 0
		if card:isKindOf("ArcheryAttack") then sj_num = getCardsNum("Jink", to, self.player) end
		if card:isKindOf("SavageAssault") then sj_num = getCardsNum("Slash", to, self.player) end

		if self:aoeIsEffective(card, to, self.player) then
			local sameKingdom
			if self:isFriend(to) then
				isEffective_F = isEffective_F + 1
				if self.player:isFriendWith(to) or self:evaluateKingdom(to) == self.player:getKingdom() then sameKingdom = true end
			else
				isEffective_E = isEffective_E + 1
			end
			
			local jink = sgs.cloneCard("jink")
			local slash = sgs.cloneCard("slash")
			local isLimited
			if card:isKindOf("ArcheryAttack") and to:isCardLimited(jink, sgs.Card_MethodResponse) then isLimited = true
			elseif card:isKindOf("SavageAssault") and to:isCardLimited(slash, sgs.Card_MethodResponse) then isLimited = true end
			if card:isKindOf("SavageAssault") and sgs.card_lack[to:objectName()]["Slash"] == 1
				or card:isKindOf("ArcheryAttack") and sgs.card_lack[to:objectName()]["Jink"] == 1
				or sj_num < 1 or isLimited then
				--value = -20
				if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
					if self:isFriend(to) and not zhiman then value = -20 * damageNum end
					if not self:isFriend(to) and damageNum > 1 then value = value - 5 * damageNum end  --源码对敌人的万箭齐发不会给value带来任何变化
				elseif card:isKindOf("SavageAssault") then
					if self:isFriend(to) then
						if zhimanprevent then
							value = - 30
						elseif not zhiman then
							value = - 20 * damageNum
						end
					else
						if zhimanprevent and self:isFriend(to, attacker) then
							value = - 30
						else
							value = - 20 * damageNum
						end
					end
				end
			else
				--value = -10
				if card:isKindOf("ArcheryAttack") then  --以下代码来自新版本AI
					if self:isFriend(to) and not zhiman then value = -10 * damageNum end
					if not self:isFriend(to) and damageNum > 1 then value = value - 5 * damageNum end  --源码对敌人的万箭齐发不会给value带来任何变化
				elseif card:isKindOf("SavageAssault") then
					if self:isFriend(to) then
						if zhimanprevent then
							value = - 20
						elseif not zhiman then
							value = - 10 * damageNum
						end
					else
						if zhimanprevent and self:isFriend(to, attacker) then
							value = - 20
						else
							value = - 10 * damageNum
						end
					end
				end
			end
			-- value = value + math.min(50, to:getHp() * 10)

			if self:getDamagedEffects(to, self.player) and damageNum <= 1 then value = value + 30 end
			if self:needToLoseHp(to, self.player) and damageNum <= 1 then value = value + 20 end

			if card:isKindOf("ArcheryAttack") then
				if to:hasShownSkills("leiji") and (sj_num >= 1 or self:hasEightDiagramEffect(to)) and self:findLeijiTarget(to, 50, self.player) then
					value = value + 20
					if self:hasSuit("spade", true, to) then value = value + 50
					else value = value + to:getHandcardNum() * 10
					end
				elseif self:hasEightDiagramEffect(to) then
					value = value + 5
					if self:getFinalRetrial(to) == 2 then
						value = value - 10
					elseif self:getFinalRetrial(to) == 1 then
						value = value + 10
					end
				end
			end

			if card:isKindOf("ArcheryAttack") and sj_num >= 1 then
				if to:hasShownSkill("xiaoguo") then value = value - 4 end
			elseif card:isKindOf("SavageAssault") and sj_num >= 1 then
				if to:hasShownSkill("xiaoguo") then value = value - 4 end
			end

			if to:getHp() <= damageNum and to:getHp() >= 1 then
				local peach_needed = damageNum - to:getHp() + 1
				if sameKingdom then
					if not zhiman then
						if null_num > 0 then null_num = null_num - 1
						elseif getCardsNum("Analeptic", to, self.player) > peach_needed - 1 then
						elseif not wansha and peach_num > peach_needed - 1 then peach_num = peach_num - peach_needed
						elseif wansha and (getCardsNum("Peach", to, self.player) > peach_needed - 1 or self:isFriend(current) and getCardsNum("Peach", to, self.player) > peach_needed - 1) then
						else
							if not punish then
								punish = true
								value = value - self.player:getCardCount(true) * 10
							end
							value = value - to:getCardCount(true) * 10
						end
					end
				else
					if card:isKindOf("SavageAssault") and zhiman and self:isFriend(to) then
					elseif card:isKindOf("SavageAssault") and zhimanprevent and self:isFriend(to, attacker) then
					else
						kills = kills + 1
						if wansha and (sgs.card_lack[to:objectName()]["Peach"] == 1 or getCardsNum("Peach", to, self.player) <= peach_needed - 1) then
							value = value - sgs.getReward(to) * 10
						end
					end
				end
			end

			if not sgs.isAnjiang(to) and to:isLord() then value = value - self.room:getLieges(to:getKingdom(), to):length() * 5 end

			if to:getHp() > 1 and to:hasShownSkills("jianxiong|JianxiongLB") and damageNum <= 1 then
				value = value + ((card:isVirtualCard() and card:subcardsLength() * 10) or 10)
			end
			if to:getHp() > 1 and to:hasShownSkills("Kuangbao+Shenfen") and damageNum <= 1 then
				value = value + math.min(15, to:getMark("@wrath") * 3)
			end

		else
			value = 0
			if to:hasShownSkill("juxiang") and not card:isVirtualCard() then value = value + 10 end
		end

		return value
	end

	if card:isKindOf("SavageAssault") then
		local menghuo = sgs.findPlayerByShownSkillName("huoshou")
		attacker = menghuo or attacker
	end

	for _, p in sgs.qlist(self.room:getAllPlayers()) do
		if p:objectName() == self.player:objectName() then continue end
		if self:isFriend(p) then
			good = good + getAoeValueTo(p)
			if zhiman then
				--if attacker:canGetCard(p, "j") then
				if not p:getJudgingArea():isEmpty() then
					good = good + 10
				--elseif attacker:canGetCard(p, "e") and p:hasShownSkills(sgs.lose_equip_skill) then
				elseif not p:getEquips():isEmpty() and p:hasShownSkills(sgs.lose_equip_skill) then
					good = good + 10
				end
			end
		else
			bad = bad + getAoeValueTo(p)
			if zhimanprevent and self:isFriend(p, attacker) then
				--if attacker:canGetCard(p, "j") then
				if not p:getJudgingArea():isEmpty() then
					bad = bad + 10
				--elseif attacker:canGetCard(p, "e") and p:hasShownSkills(sgs.lose_equip_skill) then
				elseif not p:getEquips():isEmpty() and p:hasShownSkills(sgs.lose_equip_skill) then
					bad = bad + 10
				end
			end
		end
		if self:aoeIsEffective(card, p, self.player) and self:cantbeHurt(p, attacker) then bad = bad + 250 end
		if kills == enemies then return 998 end
	end

	if isEffective_F == 0 and isEffective_E == 0 then
		return attacker:hasShownSkill("jizhi") and 10 or -100
	elseif isEffective_E == 0 then
		return -100
	end

	if attacker:hasShownSkill("jizhi") then good = good + 10 end
	if attacker:hasShownSkills("Kuangbao+Shenfen") then good = good + 6 * isEffective_E end
	if attacker:hasShownSkill("luanji") then good = good + 5 * isEffective_E end
	if attacker:hasShownSkills("Taoluan|TaoluanOL") then good = good + 5 * isEffective_E end

	return good - bad
end
sgs.ai_skill_invoke.Hanyong = function(self, data)
	if not self:willShowForAttack() then return false end
	local use = data:toCardUse()
	return self:getHanyongAoeValue(use.card, 2) >= self:getAoeValue(use.card)
end

----------------------------------------------------------------------------------------------------

-- OL ??? 蹋顿

-- 乱战
sgs.ai_skill_invoke.Luanzhan = function(self, data)
	if data:toString() == "Mark" then
		return self:willShowForAttack()  --懒得想
	else
		return false
	end
end
sgs.ai_skill_playerchosen.LuanzhanTarget = function(self, targets, max_num, min_num)  --无中、挟天子
	local use = self.player:getTag("LuanzhanCardUse"):toCardUse()
	if use.card:isKindOf("ExNihilo") then  --照抄findPlayerToDraw（原函数只能返回一人）
		local friends = {}
		for _, player in sgs.qlist(targets) do
			if self:isFriend(player) and not (player:hasShownSkill("kongcheng") and player:isKongcheng() and drawnum <= 2)
				and self:hasTrickEffective(use.card, player, self.player) and use.card:isAvailable(player) then
				table.insert(friends, player)
			end
		end
		if #friends == 0 then return {} end
		
		local target_table = {}
		self:sort(friends, "defense")
		for _, friend in ipairs(friends) do
			if friend:getHandcardNum() < 2 and not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end

		local AssistTarget = self:AssistTarget()
		if AssistTarget and (AssistTarget:getHandcardNum() < 10 or self.player:getHandcardNum() > AssistTarget:getHandcardNum()) then
			for _, friend in ipairs(friends) do
				if friend:objectName() == AssistTarget:objectName() and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
					table.insert(target_table, friend)
					if #target_table == max_num then return target_table end
				end
			end
		end

		for _, friend in ipairs(friends) do
			if friend:hasShownSkills(sgs.cardneed_skill) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end

		self:sort(friends, "handcard")
		for _, friend in ipairs(friends) do
			if not self:needKongcheng(friend) and not self:willSkipPlayPhase(friend) and not table.contains(target_table, friend) then
				table.insert(target_table, friend)
				if #target_table == max_num then return target_table end
			end
		end
		return target_table
	elseif use.card:isKindOf("ThreatenEmperor") then
		local friends = {}
		for _, friend in sgs.qlist(targets) do
			if self:isFriend(friend) and self:hasTrickEffective(use.card, friend, self.player) and use.card:isAvailable(friend) and friend:getCardCount(true) >= 1 and friend:canDiscard(friend, "he") then
				table.insert(friends, friend)
			end
		end
		if next(friends) then
			local target_table = {}
			self:sort(friends, "defense")
			for _, friend in ipairs(friends) do
				if self:needToThrowArmor(friend) and not table.contains(target_table, friend) then
					table.insert(target_table, friend)
					if #target_table == max_num then return target_table end
				end
			end
			local AssistTarget = self:AssistTarget()  --从这里开始基本抄放权
			if AssistTarget and table.contains(friends, AssistTarget) and not self:willSkipPlayPhase(AssistTarget) and not table.contains(target_table, AssistTarget) then
				table.insert(target_table, AssistTarget)
				if #target_table == max_num then return target_table end
			end
			self:sort(friends, "handcard")
			friends = sgs.reverse(friends)
			for _, target in ipairs(friends) do
				if target:hasShownSkills("zhiheng|" .. sgs.priority_skill .. "|shensu") and (not self:willSkipPlayPhase(target) or target:hasShownSkill("shensu")) and not table.contains(target_table, target) then
					table.insert(target_table, target)
					if #target_table == max_num then return target_table end
				end
			end
			return target_table
		end
	end
	return {}
end
sgs.ai_skill_use["@@Luanzhan1"] = function(self, prompt)  --借刀
	--抄旧灭计
	local collateral = sgs.Card_Parse(self.player:property("extra_collateral"):toString())
	if not collateral then self.room:writeToConsole("Luanzhan card parse error!!") end
	local dummy_use = { isDummy = true, to = sgs.SPlayerList(), current_targets = {} }
	dummy_use.current_targets = self.player:property("extra_collateral_current_targets"):toString():split("+")
	self:useCardCollateral(collateral, dummy_use)
	if dummy_use.card and dummy_use.to:length() == 2 then
		local first = dummy_use.to:at(0):objectName()
		local second = dummy_use.to:at(1):objectName()
		return "#ExtraCollateralCard:.:&->" .. first .. "+" .. second
	end
end
sgs.ai_skill_use["@@Luanzhan2"] = function(self, prompt)  --联军
	local card = sgs.Card_Parse(self.player:property("extra_af"):toString())
	if not card then self.room:writeToConsole("Luanzhan card parse error!!") end
	local current_targets_names = self.player:property("extra_af_current_targets"):toString():split("+")
	local max_targets = self.player:getMark("LuanzhanCount")
	
	--照抄useCardAllianceFeast（因为没法像借刀一样把current_targets耦合进去）
	if not card:isAvailable(self.player) then return end
	local hegnullcards = self.player:getCards("HegNullification")
	local effect_kingdoms = {}
	local current_target = findPlayerByObjectName(current_targets_names[#current_targets_names])  --因为肯定是同一国，直接找个代表
	if current_target then
		if current_target:getRole() == "careerist" then
			table.insert(effect_kingdoms, current_target:objectName())
		else
			table.insert(effect_kingdoms, current_target:getKingdom())
		end
	end

	for _, target in sgs.qlist(self.room:getOtherPlayers(self.player)) do
		if not self.player:isFriendWith(target) and target:hasShownOneGeneral() and self:hasTrickEffective(card, target, self.player)
			and not(target:getRole() ~= "careerist" and table.contains(effect_kingdoms, target:getKingdom())) then
			if target:getRole() == "careerist" then
				table.insert(effect_kingdoms, target:objectName())
			else
				table.insert(effect_kingdoms, target:getKingdom())
			end
		end
	end
	if #effect_kingdoms == 0 then return end

	--local max_v = 0
	--local winner
	local value_table = {}  --存储每个kingdom的value
	local count_table = {}  --存储每个kingdom的人数
	local rep_table = {}  --存储每个kingdom的一个代表角色
	for _, kingdom in ipairs(effect_kingdoms) do
		local value = 0
		if kingdom:startsWith("sgs") then
			count_table[kingdom] = 1
			--value = value + 1
			--if self.player:hasShownSkills(sgs.cardneed_skill) then value = value + 0.5 end
			local target = findPlayerByObjectName(kingdom)
			rep_table[kingdom] = target
			if self:isFriend(target) then
				value = value + 1
				if target:isWounded() then
					value = value + 1.8
					if target:hasShownSkills(sgs.masochism_skill) then value = value + 1 end
				else
					if target:hasShownSkills(sgs.cardneed_skill) then value = value + 1 end
					if target:isChained() then value = value + 1 end
				end
			elseif self:isEnemy(target) then
				value = value - 1
				if target:isWounded() then
					value = value - 1.8
					if target:hasShownSkills(sgs.masochism_skill) then value = value - 1 end
				else
					if target:hasShownSkills(sgs.cardneed_skill) then value = value - 1 end
					if target:isChained() then value = value - 1 end
				end
			end
		else
			local self_value = 0
			local enemy_value = 0
			count_table[kingdom] = 0
			for _, p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
				if p:hasShownOneGeneral() and p:getRole() ~= "careerist" and p:getKingdom() == kingdom then
					count_table[kingdom] = count_table[kingdom] + 1
					rep_table[kingdom] = p
					--self_value = self_value + 1
					--if self.player:hasShownSkills(sgs.cardneed_skill) then self_value = self_value + 0.5 end
					if self:isFriend(p) and self:hasTrickEffective(card, p, self.player) then
						self_value = self_value + 1
						if p:isWounded() then
							self_value = self_value + 1.8
							if p:hasShownSkills(sgs.masochism_skill) then self_value = self_value + 1 end
						else
							if p:hasShownSkills(sgs.cardneed_skill) then self_value = self_value + 1 end
							if p:isChained() then self_value = self_value + 1 end
						end
					elseif self:isEnemy(p) and self:hasTrickEffective(card, p, self.player) then
						enemy_value = enemy_value + 1
						if p:isWounded() then
							enemy_value = enemy_value + 1.8
							if p:hasShownSkills(sgs.masochism_skill) then enemy_value = enemy_value + 1 end
						else
							if p:hasShownSkills(sgs.cardneed_skill) then enemy_value = enemy_value + 1 end
							if p:isChained() then enemy_value = enemy_value + 1 end
						end
					end
				end
			end
			if self_value >= 3 and enemy_value > 5 and hegnullcards then
				enemy_value = enemy_value / 2
			end
			value = self_value - enemy_value
		end
		--[[if value > max_v then
			winner = kingdom
			max_v = value
		end]]
		value_table[kingdom] = value
	end
	
	local targets = {}
	local target_count = 0
	local max_v = 0
	local winner
	while target_count < max_targets and next(effect_kingdoms) do
		max_v = 0
		winner = nil
		for kingdom, value in pairs(value_table) do
			if value > max_v and count_table[kingdom] + target_count <= max_targets and table.contains(effect_kingdoms, kingdom) then
				max_v = value
				winner = kingdom
			end
		end
		if not winner then break end
		table.removeAll(effect_kingdoms, winner)
		table.insert(targets, rep_table[winner]:objectName())
		target_count = target_count + count_table[winner]
	end
	if next(targets) then
		return "#ExtraAllianceFeastCard:.:&->" .. table.concat(targets, "+")
	end
end
function sgs.ai_cardneed.Luanzhan(to, card, self)
	if to:getMark("LuanzhanCount") <= 0 or (not card:isBlack() and not isCard("Slash", card, to)) then return end
	return isCard("ExNihilo", card, to) or isCard("BefriendAttacking", card, to) or isCard("Snatch", card, to) or isCard("Dismantlement", card, to) or isCard("Duel", card, to) or isCard("Drowning", card, to) or (isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0)
end
sgs.Luanzhan_keep_value = {
	Dismantlement = 5.6,
	Duel        = 5.3,
	Drowning    = 5.2,
}
sgs.ai_suit_priority.Luanzhan = "diamond|heart|club|spade"

----------------------------------------------------------------------------------------------------

-- OL 021 关索

-- 征南
sgs.ai_skill_invoke.Zhengnan = true
sgs.ai_skill_choice.Zhengnan = function(self, choices)
	local items = choices:split("+")
	local eff_items = {}
	for _,skill in ipairs(items) do
		if not self:hasSkill(string.gsub(skill, "_GuanSuo", "")) then
			table.insert(eff_items, skill)
		end
	end
    if #eff_items == 1 then
        return eff_items[1]
	else
		if (self:hasCrossbowEffect() or (self.player:hasSkill("Longyin") and self:getSuitNum("red", true) >= 2)) and table.contains(eff_items, "wusheng_GuanSuo") then 
			return "wusheng_GuanSuo"
		end
		if self:willSkipPlayPhase() and table.contains(eff_items, "Dangxian_GuanSuo") then 
			return "Dangxian_GuanSuo"
		end
		if self.player:getPhase() <= sgs.Player_Play and table.contains(eff_items, "wusheng_GuanSuo") then 
			return "wusheng_GuanSuo"
		end
		
		if table.contains(eff_items, "Dangxian_GuanSuo") then 
			return "Dangxian_GuanSuo"
		end
		if self:getCardsNum("Slash") == 0 and self:getSuitNum("red", true) > 0 and table.contains(eff_items, "wusheng_GuanSuo") then 
			return "wusheng_GuanSuo"
		end
		if table.contains(eff_items, "Zhiman_GuanSuo") then 
			return "Zhiman_GuanSuo"
		end
		if table.contains(eff_items, "wusheng_GuanSuo") then 
			return "wusheng_GuanSuo"
		end
    end
    return eff_items[1]
end

sgs.ai_view_as.wusheng_GuanSuo = function(card, player, card_place)
	local suit = card:getSuitString()
	local number = card:getNumberString()
	local card_id = card:getEffectiveId()
	if (card_place ~= sgs.Player_PlaceSpecial or player:getHandPile():contains(card_id)) and (player:getLord() and player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Peach") and not card:hasFlag("using") then
		return ("slash:wusheng_GuanSuo[%s:%s]=%d&wusheng_GuanSuo"):format(suit, number, card_id)
	end
end
local wusheng_skill = {}
wusheng_skill.name = "wusheng_GuanSuo"
table.insert(sgs.ai_skills, wusheng_skill)
wusheng_skill.getTurnUseCard = function(self, inclusive)
	self:sort(self.enemies, "defense")
	local useAll = false
	for _, enemy in ipairs(self.enemies) do
		if enemy:getHp() == 1 and not enemy:hasArmorEffect("EightDiagram") and self.player:distanceTo(enemy) <= self.player:getAttackRange() and self:isWeak(enemy)
			and getCardsNum("Jink", enemy, self.player) + getCardsNum("Peach", enemy, self.player) + getCardsNum("Analeptic", enemy, self.player) == 0 then
			useAll = true
			break
		end
	end

	local disCrossbow = false
	if self:getCardsNum("Slash") < 2 or self.player:hasSkill("paoxiao|paoxiao_ZhangFei_LB|paoxiao_GuanXingZhangBao") then disCrossbow = true end

	local hecards = self.player:getCards("he")
	for _, id in sgs.qlist(self.player:getHandPile()) do
		hecards:prepend(sgs.Sanguosha:getCard(id))
	end
	local cards = {}
	for _, card in sgs.qlist(hecards) do
		if (self.player:getLord() and self.player:getLord():hasShownSkill("shouyue") or card:isRed()) and not card:isKindOf("Slash")
			and ((not isCard("Peach", card, self.player) and not isCard("ExNihilo", card, self.player)) or useAll)
			and (not isCard("Crossbow", card, self.player) or disCrossbow ) then
			local suit = card:getSuitString()
			local number = card:getNumberString()
			local card_id = card:getEffectiveId()
			local card_str = ("slash:wusheng_GuanSuo[%s:%s]=%d&wusheng_GuanSuo"):format(suit, number, card_id)
			local slash = sgs.Card_Parse(card_str)
			assert(slash)
			if self:slashIsAvailable(self.player, slash) then
				table.insert(cards, slash)
			end
		end
	end

	if #cards == 0 then return end

	self:sortByUsePriority(cards)
	return cards[1]
end
sgs.ai_cardneed.wusheng_GuanSuo = sgs.ai_cardneed.wusheng
sgs.ai_suit_priority.wusheng_GuanSuo = sgs.ai_suit_priority.wusheng

sgs.ai_skill_invoke.Zhiman_GuanSuo = function(self, data)
	local damage = self.player:getTag("Zhiman_GuanSuo_data"):toDamage()
	local target = damage.to
	if not target then self.room:writeToConsole("Zhiman no data") self.room:writeToConsole(debug.traceback()) return false end
	
	local damageNum = damage.damage
	if target:hasShownSkill("mingshi") and not self.player:hasShownAllGenerals() then
		damageNum = damageNum - 1
	end
	if target:hasShownSkills("jgyuhuo_pangtong|jgyuhuo_zhuque") and nature == sgs.DamageStruct_Fire then damageNum = 0 end
	local jiaren_zidan = sgs.findPlayerByShownSkillName("jgchiying")
	if jiaren_zidan and jiaren_zidan:isFriendWith(target) and damageNum > 1 then
		damageNum = 1
	end
	if target:hasArmorEffect("PeaceSpell") and damage.nature ~= sgs.DamageStruct_Normal then damageNum = 0 end
	if target:hasArmorEffect("Vine") and damage.nature == sgs.DamageStruct_Fire and damageNum >= 1 then damageNum = damageNum + 1 end
	if target:hasArmorEffect("Breastplate") and damageNum >= target:getHp() then damageNum = 0 end
	if target:hasArmorEffect("SilverLion") and damageNum > 1 then damageNum = 1 end
	
	local needDamage = false  --防止在有连弩或必杀时还继续制蛮（来自武圣）
	if not self:isFriend(target) and (not self:getDamagedEffects(target, self.player, damage.card and damage.card:isKindOf("Slash")) or self:isWeak(target)) and damageNum > 0 then
		local slash_avail = 1 + sgs.Sanguosha:correctCardTarget(sgs.TargetModSkill_Residue, self.player, sgs.cloneCard("slash")) - self.player:usedTimes("Slash")
		if self:hasCrossbowEffect() then slash_avail = 1000 end
		slash_avail = math.max(math.min(slash_avail, self:getCardsNum("Slash", "he")), 0)
		if target:getArmor() and not target:getArmor():isKindOf("PeaceSpell") and not target:getArmor():isKindOf("SilverLion") and not IgnoreArmor(self.player, target) and slash_avail > 0 then
			if target:getArmor():isKindOf("RenwangShield") then
				local slash_avail_temp = 0
				for _,slash in ipairs(self:getCards("Slash", "he")) do if not slash:isBlack() then slash_avail_temp = slash_avail_temp + 1 end end
				slash_avail = math.min(slash_avail, slash_avail_temp)
			elseif target:getArmor():isKindOf("Vine") then
				slash_avail = math.min(slash_avail, self:getCardsNum("FireSlash", "he"))
			else
				slash_avail = 0
			end
		end
		local save_num = self:getAllPeachNum(target) + getCardsNum("Analeptic", target, self.player)
		if slash_avail > 0 and save_num - damageNum > 0 and not self.player:hasSkills(sgs.force_damage_skill) and target:getMark("Yijue") == 0 then
			save_num = save_num + getCardsNum("Jink", target, self.player)
		end
		if save_num - damageNum <= slash_avail and not hasBuquEffect(target) and not hasNiepanEffect(target) then
			needDamage = true
		end
	end
	
	local promo = self:findPlayerToDiscard("ej", false, false, nil, true)
	if self:isFriend(damage.to) and (table.contains(promo, target) or not self:needToLoseHp(target, self.player)) then return true end
	if not self:isFriend(damage.to) and damageNum > 1 and not target:hasArmorEffect("SilverLion") then return false end  --damageNum
	if needDamage then return false end
	if table.contains(promo, target) then return true end
	
	local canGetEquip = not target:getEquips():isEmpty() and not (target:getEquips():length() == 1 and self:needToThrowArmor(target)) and not target:hasShownSkills(sgs.lose_equip_skill)
	if (target:hasShownSkills(sgs.masochism_skill) or (target:hasShownSkill("tianxiang") and not target:isNude())) and canGetEquip then --[[self.player:speak("因为防止卖血")]] return true end
	if (not self:damageIsEffective_(damage) or damageNum <= 0) and canGetEquip then return true end  --自创
	return false
end
sgs.ai_choicemade_filter.skillInvoke.Zhiman_GuanSuo = function(self, player, promptlist)
	local damage = self.room:getTag("CurrentDamageStruct"):toDamage()
	if damage.from and damage.to then
		if promptlist[#promptlist] == "yes" then
			if not damage.to:hasEquip() and damage.to:getJudgingArea():isEmpty() then
				sgs.updateIntention(damage.from, damage.to, -40)
			end
		elseif self:canAttack(damage.to) then
			sgs.updateIntention(damage.from, damage.to, 30)
		end
	end
end
sgs.ai_choicemade_filter.cardChosen.Zhiman_GuanSuo = function(self, player, promptlist)
	local intention = 10
	local id = promptlist[3]
	local card = sgs.Sanguosha:getCard(id)
	local target = findPlayerByObjectName(promptlist[5])
	if self:needToThrowArmor(target) and self.room:getCardPlace(id) == sgs.Player_PlaceEquip and card:isKindOf("Armor") then
		intention = -intention
	elseif self:doNotDiscard(target) then intention = -intention
	elseif target:hasShownSkills(sgs.lose_equip_skill) and not target:getEquips():isEmpty() and
		self.room:getCardPlace(id) == sgs.Player_PlaceEquip and card:isKindOf("EquipCard") then
			intention = -intention
	elseif self.room:getCardPlace(id) == sgs.Player_PlaceJudge then
		intention = -intention
	end
	sgs.updateIntention(player, target, intention)
end

function sgs.ai_cardneed.Dangxian_GuanSuo(to, card, self)  --对于廖化待补充是否发动当先
	return isCard("Slash", card, to) and getKnownCard(to, self.player, "Slash", true) == 0
end

----------------------------------------------------------------------------------------------------

-- OL ??? 步骘

-- 弘德
sgs.ai_skill_playerchosen.Hongde = function(self, targets)
	if not self:willShowForAttack() and not self:willShowForDefence() then return nil end
	
	local function findHongdeFriend(except)
		local friend = self:findPlayerToDraw(false)
		if friend and (not except or friend:objectName() ~= except:objectName()) then return friend end
		
		local other_friends = self.friends_noself
		if except then table.removeOne(other_friends, except) end
		self:sort(other_friends)
		for _, friend in ipairs(other_friends) do
			if --[[not hasManjuanEffect(friend) and]] not self:needKongcheng(friend, true) then	
				return friend
			end
		end
		return nil
	end
	
	if self.player:getPhase() == sgs.Player_Draw and self.haoshi_target then
		local target = self.haoshi_target
		local otherPlayers = sgs.QList2Table(self.room:getOtherPlayers(self.player))
		self:sort(otherPlayers, "handcard")
		local least_handcard_player = otherPlayers[1]
		
		local friend = findHongdeFriend()
		if not friend then return nil end
		if friend:objectName() ~= target:objectName() then return friend end
		if #otherPlayers > 1 and friend:getHandcardNum() < otherPlayers[2]:getHandcardNum() then return friend end
		
		return findHongdeFriend(friend)
	end
	
	local friend = findHongdeFriend()
	if friend and friend:hasFlag("DimengTarget") and not self.player:hasFlag("DimengTarget") then
		local other_dimeng_target
		for _,p in sgs.qlist(self.room:getOtherPlayers(self.player)) do
			if p:hasFlag("DimengTarget") and p:objectName() ~= friend:objectName() then
				other_dimeng_target = p
			end
		end
		if other_dimeng_target then return other_dimeng_target end
		
		return findHongdeFriend(friend)
	else
		return friend
	end
end
sgs.ai_playerchosen_intention.Hongde = function(self, from, to)
	if not to:hasFlag("DimengTarget") then
		sgs.updateIntention(from, to, -80)
	end
end

-- 定叛
local dingpan_skill = {}
dingpan_skill.name = "Dingpan"
table.insert(sgs.ai_skills, dingpan_skill)
dingpan_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return nil end
	local big_kingdoms = self.player:getBigKingdoms("AI")
	local big_kingdom_count = 0
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if not p:hasShownOneGeneral() then continue end
		if table.contains(big_kingdoms, p:objectName()) or (table.contains(big_kingdoms, p:getKingdom()) and (p:getRole() ~= "careerist")) then
			big_kingdom_count = big_kingdom_count + 1
		end
	end
	if self.player:usedTimes("#DingpanCard") >= math.max(1, big_kingdom_count) then return nil end

	local can_invoke = false
	for _,p in sgs.qlist(self.room:getAlivePlayers()) do
		if p:getEquips():length() > 0 then
			can_invoke = true
		end
	end
	if not can_invoke then return nil end
	return sgs.Card_Parse("#DingpanCard:.:&Dingpan") 
end
sgs.ai_skill_use_func["#DingpanCard"] = function(card, use, self)
	local target
	if self.player:getEquips():length() > 0 and (self.player:hasSkills(sgs.lose_equip_skill .. "|tuntian|lirang") or self:needToThrowArmor()
		or (self.player:hasSkills(sgs.masochism_skill) and not self:isWeak()) or self:needToLoseHp(self.player, self.player)
		or (self.player:getEquips():length() >= 2 and not self:isWeak() and self.player:hasSkill("Hongde") and self.player:getMark("Hongde") < 4 and self:findFriendsByType(sgs.Friend_Draw))
		or not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, self.player) or self:getDamagedEffects(self.player, self.player, false)) then
		target = self.player
	end
	if not target then
		self:sort(self.friends_noself, "defense")
		self.friends_noself = sgs.reverse(self.friends_noself)
		for _,p in ipairs(self.friends_noself) do
			if p:getEquips():length() > 0 and (p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") or self:needToThrowArmor(p)
				or (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) or self:needToLoseHp(p, self.player)
				or not self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) or self:getDamagedEffects(p, self.player, false))
				and not self:willSkipPlayPhase(p) and not self:needKongcheng(p, true) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and p:hasShownSkills(sgs.need_equip_skill)
				and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and not p:hasShownSkills(sgs.cardneed_skill)
				and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if not target then
		self:sort(self.enemies, "defense")
		--self.enemies = sgs.reverse(self.enemies)  --不应该是先选defense最差的吗？
		for _,p in ipairs(self.enemies) do
			if p:getEquips():length() > 0 and not p:hasShownSkills(sgs.lose_equip_skill .. "|tuntian|lirang") and not self:needToThrowArmor(p)
				and not (p:hasShownSkills(sgs.masochism_skill) and not self:isWeak(p)) and not self:needToLoseHp(p, self.player)
				and self:damageIsEffective(p, sgs.DamageStruct_Normal, self.player) and not self:getDamagedEffects(p, self.player, false) and not self:cantbeHurt(p, self.player) then
				target = p
				break
			end
		end
	end
	if target then
		use.card = card
		if use.to then
			use.to:append(target)
			if use.to:length() >= 1 then return end
		end
	end		
end
sgs.ai_use_value.DingpanCard = 5
sgs.ai_use_priority.DingpanCard = 2.62
sgs.ai_skill_choice.Dingpan = function(self, choices, data)
	local buzhi = self.room:findPlayerBySkillName("Dingpan")
	if (self.player:hasSkills(sgs.lose_equip_skill) and (self.player:getHp() > 2 or hasBuquEffect(self.player)))
		or (self.player:hasArmorEffect("SilverLion") and self.player:isWounded() and (self.player:getHp() >= 2 or hasBuquEffect(self.player)))
		or (self.player:hasSkills(sgs.masochism_skill) and not self:isWeak()) or self:needToLoseHp(self.player, buzhi)
		or (self.player:getEquips():length() >= 2 and not self:isWeak() and self.player:hasSkill("Hongde") and self.player:getMark("Hongde") < 4 and self:findFriendsByType(sgs.Friend_Draw))
		or not self:damageIsEffective(self.player, sgs.DamageStruct_Normal, buzhi) or self:getDamagedEffects(self.player, buzhi, false) or self:cantbeHurt(self.player, buzhi)
		or (self:getCardsNum("Peach") > 0 and not self.player:isWounded() and not self:willSkipPlayPhase()) then
		return "damage"
	end
	return "discard"
end

----------------------------------------------------------------------------------------------------

-- OL ??? 李通

-- 推锋
sgs.ai_skill_exchange.Tuifeng = function(self, pattern, max_num, min_num, expand_pile)
	if not self:willShowForMasochism() then return {} end
	local to_discard = {}
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByKeepValue(cards)
	for _,c in ipairs(cards) do
		if not (c:isKindOf("Peach") or c:isKindOf("Analeptic")) then
			table.insert(to_discard, c:getEffectiveId())
			return to_discard
		end
	end
	return {}
end
sgs.ai_need_damaged.Tuifeng = function(self, attacker, player)
	if not player:hasSkill("Tuifeng") then return false end
	local invoke = false
	local hp_limit = 4
	local enemies = self:getEnemies(player)
	if not next(enemies) then return false end
	self:sort(enemies, "hp")
	for _,p in ipairs(enemies) do
		if player:inMyAttackRange(p) and player:canSlash(p) then
			invoke = true
			if self:isWeak(p) then hp_limit = 3 end
			break
		end
	end
	if invoke and player:getCards("he"):length() > 3 and ( player:getHp() >= hp_limit or self:getCardsNum("Peach") > 1) and not self:willSkipPlayPhase(player) then return true end
	return false 
end
function sgs.ai_cardneed.Tuifeng(to, card)
	return to:isNude()
end

----------------------------------------------------------------------------------------------------

-- OL ??? 糜竺

-- 资援
function SmartAI:sortByNumber(cards, inverse)
    local compare_func = function(a, b)
		if a:getNumber() ~= b:getNumber() then
			if not inverse then return a:getNumber() > b:getNumber() end
			return a:getNumber() < b:getNumber()
		else
			if not inverse then return self:getKeepValue(a) > self:getKeepValue(b) end
			return self:getKeepValue(a) > self:getKeepValue(b)
		end
    end
    table.sort(cards, compare_func)
end
function canEqual213(cards, selected, self)
	local x = 13
	while true do
		for k,c in ipairs(cards) do
			if c:getNumber() <= x then
				if c:hasFlag("selected") or c:hasFlag("banned") then continue end
				x = x -c:getNumber()
				if x == 0 then
					table.insert(selected,c)
					c:setFlags("selected")
					return true
				else
					if (k == #cards or cards[#cards]:getNumber() > x )then
						x = x + c:getNumber()
					else 
						table.insert(selected,c)
						c:setFlags("selected")
					end
				end
			end
			if k == #cards then
				if #selected > 0 then
					for _,ca in ipairs(cards) do
						if ca:getId() == selected[#selected]:getId() then
							ca:setFlags("-selected")
							ca:setFlags("banned")
							x = x + ca:getNumber()
							table.remove(selected)
							break
						end
					end
				else
					return false
				end
			end
		end
		if #cards <= 2 then return false end
		if cards[#cards - 1]:hasFlag("banned") then 
			for _,c in ipairs(cards) do
				c:setFlags("-selected")
				c:setFlags("-banned")
			end
			table.remove(cards,1)
			for i = #selected , 1 ,-1 do
				if selected[i] ~= nil then
					table.remove(selected,i)
				end
			end
			x = 13
		end
	end
	return false
end
local ziyuan_skill = {}
ziyuan_skill.name = "Ziyuan"
table.insert(sgs.ai_skills, ziyuan_skill)
ziyuan_skill.getTurnUseCard = function(self)
	if self.player:hasUsed("#ZiyuanCard") then return nil end
	if #self.friends_noself < 1 then return nil end
	self.Ziyuan_give_list = nil
	local cards = self.player:getCards("h")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local to_give = sgs.IntList()
	for _, card in ipairs(cards) do
		if card:getNumber() == 13 then
			to_give:append(card:getEffectiveId())
			self.Ziyuan_give_list = to_give
			return sgs.Card_Parse("#ZiyuanCard:.:&Ziyuan")
		end
	end
	self:sortByNumber(cards, false)
	local selected = {}
	local room = self.room
	local y = canEqual213(cards, selected,self)
	self.room:setPlayerMark(self.player, "RecycleTimes", 0)
	for _,c in ipairs(cards) do
		c:setFlags("-selected")
		c:setFlags("-banned")
	end
	if y then
		for _,p in ipairs(selected) do
			to_give:append(p:getEffectiveId())
		end
		self.Ziyuan_give_list = to_give
		return sgs.Card_Parse("#ZiyuanCard:.:&Ziyuan")
	end
end
sgs.ai_skill_use_func["#ZiyuanCard"] = function(card, use, self)
	sgs.ai_use_priority.ZiyuanCard = 8.3
	self:sort(self.friends_noself, "hp")
	local give = self.Ziyuan_give_list
	local to_give = sgs.QList2Table(give)
	if #to_give == 0 then return end
	
	local to_give_cards = {}
	for _,id in ipairs(to_give) do
		table.insert(to_give_cards, sgs.Sanguosha:getCard(id))
	end
	
	local target
	local _,friend = self:getCardNeedPlayer(to_give_cards, self.friends_noself, "Ziyuan")
	if friend and self:isFriend(friend) --[[and not hasManjuanEffect(friend)]] and (not self:needToLoseHp(friend, nil, nil, nil, true) or self:isWeak(friend)) and not self:needKongcheng(friend, true) then
		target = friend 
	end
	if not target then
		for _,p in ipairs(self.friends_noself) do
			if --[[not hasManjuanEffect(p) and]] (not self:needToLoseHp(p, nil, nil, nil, true) or self:isWeak(p)) and not self:needKongcheng(p, true) then
				target = p
				break
			end
		end
	end
	if not target then
		sgs.ai_use_priority.ZiyuanCard = 0.5
		local _,friend = self:getCardNeedPlayer(to_give_cards, self.friends_noself, "Ziyuan")
		if friend and self:isFriend(friend) --[[and not hasManjuanEffect(friend)]] and not self:needKongcheng(friend, true) then target = friend end
	end
	if not target and not self:isWeak() 
		--[[and (not hasManjuanEffect(self.friends_noself[1]) or self.friends_noself[1]:isWounded() )]]
		and not self:needToLoseHp(self.friends_noself[1], nil, nil, nil, true) and not self:needKongcheng(self.friends_noself[1], true) then
 		target = self.friends_noself[1]
	end
	if target and #to_give > 0 then
		if not self:willShowForDefence() and not self:isWeak(target) then return end
		use.card = sgs.Card_Parse("#ZiyuanCard:" .. table.concat(to_give, "+") .. ":&Ziyuan")
		if use.to then use.to:append(target) end
	end
end
sgs.ai_use_value.ZiyuanCard = 10
sgs.ai_use_priority.ZiyuanCard = 8.3
sgs.ai_card_intention.ZiyuanCard = -100
function sgs.ai_cardneed.Ziyuan(to, card, self)
	if #self:getFriendsNoself(to) > 0 then
		return card:getNumber() == 13
	end
end

-- 巨贾
sgs.ai_skill_invoke["#Jugu_showmaxcards"] = function(self, data)
	if not self:willShowForDefence() then return false end
	if self:needKongcheng(self.player, true) then return false end
	if self:isWeak() then return true end
	local draw_num = (self.player:getMark("Jugu") == 0) and self.player:getMaxHp() or 0
	if self.player:hasShownOneGeneral() and not self.player:hasShownSkill("Jugu") and self.player:getMark("CompanionEffect") == 1 and not self.player:isWounded() then
		draw_num = draw_num + 2  --暂时不考虑一统天下
	end
	if self.player:hasShownOneGeneral() and not self.player:hasShownSkill("Jugu") and self.player:getMark("HalfMaxHpLeft") == 1 then
		draw_num = draw_num + 1
	end
	return (self:getOverflow() > 0 and self.player:getMaxHp() - draw_num > 0) or (self:isWeak() and self.player:getHandcardNum() <= 2)
end

-----------------------------------------------OL修订-----------------------------------------------

-- （YC 008） 张让

-- 滔乱
local taoluanOL_skill = {}
taoluanOL_skill.name = "TaoluanOL"
table.insert(sgs.ai_skills, taoluanOL_skill)
taoluanOL_skill.getTurnUseCard = function(self)
	if not self:willShowForAttack() then return end  --似乎响应出牌在ai_cardsview里，所以这里是攻击端？
	if self.player:isNude() or self.player:getMark("TaoluanOLProhibited") > 0 then return end
	local players = self.player:getAliveSiblings()
	players:append(self.player)
	for _, p in sgs.qlist(players) do
		if p:hasFlag("Global_Dying") then return false end
	end
	
	local cards = self.player:getCards("he")
	cards = sgs.QList2Table(cards)
	self:sortByUseValue(cards, true)
	local suit = cards[1]:getSuit()
	local number = cards[1]:getNumber()
	local card_id = cards[1]:getEffectiveId()
	
	local can_use_not_valuable_basic = findTaoluanFriend(self, self.player, "BasicCard", {}, false)  --预处理（否则太慢）
	local can_use_not_valuable_trick = findTaoluanFriend(self, self.player, "TrickCard", {}, false)
	if not next(self.friends_noself) then return end
	local dorn = {"peach", "analeptic", "god_salvation", "savage_assault", "archery_attack", "duel", "burning_camps"}  --对队友要求放宽松的
	local super_impt = {"peach", "god_salvation"}  --体力为1也能使用的
	
	local allowed = self.player:property("guhuo_box_allowed_elemet"):toString():split("+")
	local choices = {}
	for _, name in ipairs(allowed) do
		local card = sgs.Sanguosha:cloneCard(name, sgs.Card_NoSuit, 0)
		card:setCanRecast(false)
		if card and card:isAvailable(self.player) and not self.player:isLocked(card) then
			if self.player:getHp() <= 1 and not table.contains(super_impt, name) then
			elseif not (card:isKindOf("BasicCard") and can_use_not_valuable_basic or can_use_not_valuable_trick) and not table.contains(dorn, name) then
			else
				table.insert(choices, name)
			end
		end
	end
	
	if next(choices) then --如果可以使用
		local to_use = table.copyFrom(choices)
		for _,c in sgs.qlist(self.player:getCards("he")) do
			table.removeAll(to_use, c:objectName())
		end
		
		if next(to_use) then
			local value
			if next(cards) then
				value = math.max(self:getKeepValue(cards[1]), self:getUseValue(cards[1]))
			else
				local slash = sgs.Sanguosha:cloneCard("slash")
				slash:deleteLater()
				value = self:getUseValue(slash)
			end
			local tcard
			
			local cards_to_use = {}
			for _, name in pairs(to_use) do
				c = sgs.Card_Parse((name .. ":TaoluanOL[%s:%s]=.&%s"):format("no_suit", 0, "TaoluanOL"))
				assert(c)
				if self:getUseValue(c) > value then
					table.insert(cards_to_use, c)
				end
			end
			self:sortByUseValue(cards_to_use)
			for _, c in ipairs(cards_to_use) do
				local dummy_use = { isDummy = true }
				local dummy_card = sgs.Card_Parse("#TaoluanOLCard:" .. card_id .. ":" .. c:objectName() .. "&TaoluanOL")
				sgs.ai_skill_use_func["#TaoluanOLCard"](dummy_card, dummy_use, self)  --确保会使用这张牌（防止最高value的牌找出来了却不用的情况）
				if dummy_use.card then
					tcard = c
					break
				end
			end
			if tcard then
				sgs.ai_use_priority.TaoluanOLCard = self:getDynamicUsePriority(tcard) - 0.1
				return sgs.Card_Parse("#TaoluanOLCard:" .. card_id .. ":" .. tcard:objectName() .. "&TaoluanOL")
			end
		end
	end
end
sgs.ai_skill_use_func["#TaoluanOLCard"] = function(card, use, self)
	local userstring = card:toString()
	userstring = (userstring:split(":"))[4]:split("&")[1]
	local taoluancard = sgs.Sanguosha:cloneCard(userstring, card:getSuit(), card:getNumber())
	taoluancard:setSkillName("TaoluanOL")
	taoluancard:setShowSkill("TaoluanOL")
	local can_recast = taoluancard:canRecast()
	taoluancard:setCanRecast(false)
	if taoluancard:getTypeId() == sgs.Card_TypeBasic then
		if not use.isDummy and use.card and taoluancard:isKindOf("Slash") and (not use.to or use.to:isEmpty()) then return end  --来自蛊惑（似乎是为了解决使用空杀的问题）
		self:useBasicCard(taoluancard, use)
	else
		assert(taoluancard)
		self:useTrickCard(taoluancard, use)
	end
	if not use.card then return end
	if can_recast and not taoluancard:isKindOf("FightTogether") then   --知己知彼源码有bug（968行忘加rec &&）  todo：在新版本中已修复，无需单独判断
		if not use.to or use.to:length() == 0 then use.card = nil return end
	end
	use.card = card
end
sgs.ai_cardsview["TaoluanOL"] = function(self, class_name, player)
	if self.TaoluanOL_testing then return end
	if not self:willShowForDefence() then return end
	if not player:hasSkill("TaoluanOL") or player:isNude() or player:getMark("TaoluanOLProhibited") > 0 then return end
	if sgs.Sanguosha:getCurrentCardUseReason() ~= sgs.CardUseStruct_CARD_USE_REASON_RESPONSE_USE then return end
	local classname2objectname = {
		["Slash"] = "slash", ["Jink"] = "jink",
		["Peach"] = "peach", ["Analeptic"] = "analeptic",
		["Nullification"] = "nullification",
		["HegNullification"] = "heg_nullification",
		["FireSlash"] = "fire_slash", ["ThunderSlash"] = "thunder_slash"
	}
	local name = classname2objectname[class_name]
	if not name then return end
	local no_have = true
	local cards = player:getCards("he")
	for _,c in sgs.qlist(cards) do
		if c:isKindOf(class_name) then
			no_have = false
			break
		end
	end
	if not no_have then return end
	local players = player:getAliveSiblings()
	players:append(player)
	for _, p in sgs.qlist(players) do
		if p:hasFlag("Global_Dying") then return false end
	end
	if class_name == "Peach" and player:getMark("Global_PreventPeach") > 0 then return end
	
	local has_friends = false
	local card = sgs.Sanguosha:cloneCard(name)
	has_friends = findTaoluanFriend(self, player, card:getTypeId(), {}, card:isKindOf("Nullification") or card:isKindOf("Peach"))
	if not has_friends and self:isWeak(player) then return end
	local yuji = sgs.findPlayerByShownSkillName("qianhuan") and self.player:isFriendWith(yuji)
	local caiwenji = sgs.findPlayerByShownSkillName("beige") and self.player:isFriendWith(caiwenji) and not caiwenji:isNude()
	if not has_friends and card:isKindOf("Jink") and (yuji or caiwenji) then return end
	
	cards = sgs.QList2Table(cards)
	self.TaoluanOL_testing = true
	self:sortByUseValue(cards, true)
	self.TaoluanOL_testing = false
	local suit = cards[1]:getSuitString()
	local number = cards[1]:getNumberString()
	local card_id = cards[1]:getEffectiveId()
	local allowed = player:property("guhuo_box_allowed_elemet"):toString():split("+")
	if table.contains(allowed, name) then
		return "#TaoluanOLCard:" .. card_id .. ":" .. name .. "&TaoluanOL"
	end
end
sgs.ai_skill_playerchosen.TaoluanOL = function(self, targets)
	self:updatePlayers()
	local friends = self.friends_noself
	self:sort(friends, "handcard")
	local target = nil
	local taoluan_types = self.player:getTag("TaoluanOLType"):toString():split(",")
	
	target = findTaoluanFriend(self, self.player, "", taoluan_types, false)
	target = target or findTaoluanFriend(self, self.player, "", taoluan_types, true)
	
	local current = self.room:getCurrent()
	if not target then
		if #friends > 0 then
			local consider_friends = {}
			for i = #friends, 1, -1 do
				friend = friends[i]
				if friend:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. friend:objectName() .. "no" .. typeid) then lack = false end  --来自下面那个函数，张让与OL张让公用
				end
				if lack then continue end
				table.insert(consider_friends, friend)
			end
			--以下照抄findTaoluanFriend
			for _, friend in ipairs(consider_friends) do
				if self:needKongcheng(friend) and (friend:getHandcardNum() == 1) then target = friend break end
				if not self:hasLoseHandcardEffective(friend) then target = friend break end
				if friend:hasShownSkills(sgs.lose_equip_skill) and table.contains(taoluan_types, "EquipCard") then target = friend break end
				if friend:hasShownSkill("tuntian") then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if friend:getCards("he"):length() >= 3 and not self:isWeak(friend) and not friend:hasShownSkills(sgs.cardneed_skill) then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if not self:isWeak(friend) and not friend:hasShownSkills(sgs.cardneed_skill) then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				if friend:getCards("he"):length() >= 3 then target = friend break end
			end
			for _, friend in ipairs(consider_friends) do
				target = friend
				break
			end
		end
	end
	if not target then
		targets = sgs.QList2Table(targets)
		self:sort(targets, "handcard")
		for _, p in ipairs(targets) do
			if self:isEnemy(p) then continue end
			for _,typeid in pairs(taoluan_types) do
				if getCardsNum(typeid, p, self.player) > 0 then
					target = p
					break
				end
			end
		end
		if not target then
			for i = #targets, 1, -1 do
				if self:isEnemy(targets[i]) or targets[i]:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. targets[i]:objectName() .. "no" .. typeid) then lack = false end
				end
				if lack then continue end
				target = targets[i]
				break
			end
		end
		if not target then
			for i = #targets, 1, -1 do
				if targets[i]:isNude() then continue end
				local lack = true
				for _,typeid in pairs(taoluan_types) do
					if not current:hasUsed("#Taoluan" .. targets[i]:objectName() .. "no" .. typeid) then lack = false end
				end
				if lack then continue end
				target = targets[i]
				break
			end
		end
		if not target then
			target = targets[math.random(1, #targets)]
		end
	end
	return target
end
--[[
回合外滔乱响应杀（如挑衅）会出现以下错误代码，但是能正常使用
stack traceback:
	lua/ai/standard_cards-ai.lua:391: in function 'slashIsAvailable'
	extensions/ai/from_v2-ai.lua:3545: in function 'useCardSlash'
	extensions/ai/from_v2-ai.lua:3732: in function 'use_func'
	lua/ai/smart-ai.lua:2817: in function <lua/ai/smart-ai.lua:2784>
	[C]: in function 'pcall'
	lua/ai/smart-ai.lua:228: in function <lua/ai/smart-ai.lua:211>
]]

----------------------------------------------武将替换----------------------------------------------

custom_general_values = {}
custom_pair_values = {}

function loadFile(rfilename, isPairValue)
	for str in io.lines(rfilename) do
		local tab = str:split("	")  --“空格”是一个Tab
		local general = tab[1]
		local value = tab[#tab]
		if not isPairValue then
			value = tonumber(value)
			if sgs.Sanguosha:getGeneral(general) and value then
				custom_general_values[general] = value
			end
		else
			local generals = general:split(" ")  --这里是空格
			local values = value:split(" ")  --这里是空格
			if (#generals == 2) and sgs.Sanguosha:getGeneral(generals[1]) and sgs.Sanguosha:getGeneral(generals[2]) 
				and (#values == 2) and tonumber(values[1]) and tonumber(values[2]) then
				custom_pair_values[generals[1] .. "+" .. generals[2]] = tonumber(values[1])  --二维数组出现错误
				custom_pair_values[generals[2] .. "+" .. generals[1]] = tonumber(values[2])
			end
		end
	end
end
function loadValues()
	if hasLoadedValues then return end
	hasLoadedValues = true
	loadFile("ai-selector/general-value.txt", false)  --文件读取代码来自http://tech.it168.com/j/2008-02-17/200802171019138.shtml
	loadFile("ai-selector/pair-value.txt", true)
	loadFile("extensions/ai-selector/from_v2-general-value.txt", false)
	loadFile("extensions/ai-selector/from_v2-pair-value.txt", true)
	--由于在pair-values.txt写入神将的数据会导致AI直接选神将（而不是替换），且不验证是否为同一国的，从而直接成为野心家。因此只能后期手动载入神将和本国的数据
	loadFile("extensions/ai-selector/from_v2-god-pair-value.txt", true)
end
hasLoadedValues = false

function calculateSinglePairValue(self, head, deputy)  --基本抄GeneralSelector::calculateDeputyValue
	if deputy ~= "NIL" and custom_pair_values[head .. "+" .. deputy] and tonumber(custom_pair_values[head .. "+" .. deputy]) then
		return tonumber(custom_pair_values[head .. "+" .. deputy])
	end
	
	local need_high_max_hp_skills = {"zhiheng", "zaiqi", "yinghun_sunjian", "kurou", "KurouLB", "Yeyan"}
	local need_low_max_hp_skills = {"Jingce"}
	
	if deputy == "NIL" then
		local general1 = sgs.Sanguosha:getGeneral(head)
		assert(general1)
		local general1_value = custom_general_values[head] or 0
		local v = general1_value
		
		local kingdom = general1:getKingdom()
		--v = v + math.random(0, 3)  --Simulate kingdom preference  --因为用来对比的肯定都是同一国的，所以这个不公平。。
		
		local max_hp = general1:getMaxHpHead() * 2
		
		if general1:isFemale() then
			if kingdom == "wu" then v = v - 2
			elseif kingdom == "shu" then v = v - 1  --荐言、蜀香结姻
			elseif kingdom ~= "qun" then v = v + 1 end
		elseif kingdom == "qun" then v = v + 1
		end
		
		if max_hp < 8 then
			for _,skill in sgs.qlist(general1:getVisibleSkillList(true, true)) do
				if table.contains(need_high_max_hp_skills, skill:objectName()) then v = v - 5 end
			end
		end
		return v
	end
	
	local general1 = sgs.Sanguosha:getGeneral(head)
	local general2 = sgs.Sanguosha:getGeneral(deputy)
	assert(general1)
	assert(general2)
	local general1_value = custom_general_values[head] or 0
	local general2_value = custom_general_values[deputy] or 0
	local v = general1_value + general2_value
	
	local kingdom = general1:getKingdom()
	--v = v + math.random(0, 3)  --Simulate kingdom preference  --因为用来对比的肯定都是同一国的，所以这个不公平。。
	
	local max_hp = general1:getMaxHpHead() + general2:getMaxHpDeputy()
	if math.mod(max_hp, 2) == 1 then v = v - 1 end
	
	if general1:isCompanionWith(deputy) then v = v + 3 end
	
	if general1:isFemale() then
		if kingdom == "wu" then v = v - 2
		elseif kingdom == "shu" and not general2:hasSkill("Xiefang") then v = v - 1  --荐言、蜀香结姻
		elseif kingdom ~= "qun" then v = v + 1 end
	elseif kingdom == "qun" then v = v + 1
	end
	
	if general1:hasSkill("baoling") and (general2_value > 6) then v = v - 5 end
	
	if max_hp < 8 then
		for _,skill in sgs.qlist(general1:getVisibleSkillList(true, true)) do
			if table.contains(need_high_max_hp_skills, skill:objectName()) then v = v - 5 end
		end
		for _,skill in sgs.qlist(general2:getVisibleSkillList(true, false)) do
			if table.contains(need_high_max_hp_skills, skill:objectName()) then v = v - 5 end
		end
	else
		for _,skill in sgs.qlist(general1:getVisibleSkillList(true, true)) do
			if table.contains(need_low_max_hp_skills, skill:objectName()) then v = v - 2 end
		end
		for _,skill in sgs.qlist(general2:getVisibleSkillList(true, false)) do
			if table.contains(need_low_max_hp_skills, skill:objectName()) then v = v - 2 end
		end
	end
	return v
end

sgs.ai_skill_invoke.sp_convert = function(self, data)
	local disableDeputy = (not self.player:getGeneral2())
	local ori_head = self.player:getActualGeneral1Name()
	local ori_deputy = disableDeputy and "NIL" or self.player:getActualGeneral2Name()
	
	local choices_head = self.player:getTag("SPConvertChoicesHead"):toString():split("+")
	table.insert(choices_head, ori_head)
	table.removeAll(choices_head, "")
	local choices_deputy = (self.player:getTag("SPConvertChoicesDeputy"):toString() or ""):split("+") 
	table.insert(choices_deputy, ori_deputy)
	table.removeAll(choices_deputy, "")
	
	local ori_value = calculateSinglePairValue(self, ori_head, ori_deputy)
	local best_value = -101
	local best_head, best_deputy = "", ""
	local value = -1
	for _, choice_head in pairs(choices_head) do
		for _,choice_deputy in pairs(choices_deputy) do
			if choice_head == ori_head and choice_deputy == ori_deputy then
				continue
			end
			value = calculateSinglePairValue(self, choice_head, choice_deputy)
			if value and (value > best_value) then
				best_value = value
				best_head = choice_head
				best_deputy = choice_deputy
			end
		end
	end
	
	if best_head == "" and best_deputy == "" then return false end
	local prob = 0.5 + math.max(math.min((best_value - ori_value) * 0.12, 0.4), -0.4)
	if math.random() <= prob then
		--DIRTY HACK：为了防止AI停顿，不用askForChoice，直接用Tag传入
		self.player:setTag("SPConvertResultHead", sgs.QVariant((best_head == ori_head) and "" or best_head))
		self.player:setTag("SPConvertResultDeputy", sgs.QVariant((best_deputy == ori_deputy) and "" or best_deputy))
		return true
	end
	return false
end

loadValues()