--[[********************************************************************
	Copyright (c) 2013-2015 Mogara

  This file is part of QSanguosha-Hegemony.

  This game is free software; you can redistribute it and/or
  modify it under the terms of the GNU General Public License as
  published by the Free Software Foundation; either version 3.0
  of the License, or (at your option) any later version.

  This program is distributed in the hope that it will be useful,
  but WITHOUT ANY WARRANTY; without even the implied warranty of
  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
  General Public License for more details.

  See the LICENSE file for more details.

  Mogara
*********************************************************************]]

-- this script to store the basic configuration for game program itself
-- and it is a little different from config.ini

config = {
	kingdoms = { "wei", "qun", "shu", "wu", "god" },
	kingdom_colors = {
		wei = "#547998",
		shu = "#D0796C",
		wu = "#4DB873",
		qun = "#8A807A",
		god = "#96943D",
	},

	skill_colors = {
		compulsory = "#0000FF",
		once_per_turn = "#008000",
		limited = "#FF0000",
		head = "#00FF00",
		deputy = "#00FFFF",
		array = "#800080",
		lord = "#FFA500",
	},

	-- Sci-fi style background
	--dialog_background_color = "#49C9F0";
	--dialog_background_alpha = 75;
	dialog_background_color = "#D6E7DB";
	dialog_background_alpha = 255;

	package_names = {
		"StandardCard",
		"FormationEquip",
		"MomentumEquip" ,
		"StrategicAdvantage",

		"Standard",
		"Formation",
		"Momentum",
		"Test",
		"JiangeDefense"
	},

	easy_text = {
		"太慢了，做两个俯卧撑吧！",
		"快点吧，我等的花儿都谢了！",
		"高，实在是高！",
		"好手段，可真不一般啊！",
		"哦，太菜了。水平有待提高。",
		"你会不会玩啊？！",
		"嘿，一般人，我不使这招。",
		"呵，好牌就是这么打地！",
		"杀！神挡杀神！佛挡杀佛！",
		"你也忒坏了吧？！"
	},

	robot_names = {
		"杰森斯坦森",
		"泰勒斯威夫特",
		"阿黛尔",
		"其实我是贾诩",
		"连清人",
		"孙笨",
		"不！还不可以死。",
		"微笑的甄姬",
		"天妒郭嘉",
		"鬼才司马",
		"瑞奇·马丁",
		"克里斯布朗",
		"蕾哈娜",
		"邹云蛇" ,
		"基佬罗",
		"蔡依林",
		"哈喽大家好我是周杰伦",
		"亚当莱文",
		"亚当杨",
		"温酒斩华雄" ,
		"此乃驱虎吞狼之计" ,
		"Javierrppp" ,
		"Rolando" ,
		"非主流" ,
		"洗剪吹",
		"杀马特",
		"文艺骚年",
		"你是猪吗",
		"艾薇儿·拉维妮",
		"贾斯汀·汀布莱克",
		"丁日",
		"纯黑的尖叫",
		"黑崎一护",
		"旋涡鸣人",
		"斯科菲尔德",
		"卯之花八千流",
		"市丸银",
		"蓝染" ,
		"小甜甜布兰妮",
		"谁能挡我？",
		"亚历山大·沙费纳",
		"身上香",
		"George",
		"Gregoire",
		"Matt Pokora",
		"Luis Fonsi",
		"宇智波鼬",
		"剪刀手刘德华",
		"兰博基尼",
		"玛莎拉蒂",
		"摩托骡拉",
		"诺基亚",
		"苯并芘",
		"Alex Ubago",
		"弹走鱼尾纹",
		"Zayn Malik",
		"杰克·吉伦哈尔",
		"泥垢",
		"斯巴达克斯",
		"艾力岗",
		"纳西尔",
		"克雷斯",
		"妮维雅",
		"甘尼克斯",
		"凯撒"
	},
}
