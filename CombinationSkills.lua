local Heroes = require "Heroes"

local IDX_Faction = Heroes.GetIndexes().Faction

local COMBINATION_SKILLS = {
	-- S3
	["君临天下"] = {
		desc = "上阵曹操、1名魏国和1名群雄将领时激活合体，迅速建造铜雀台进行狂欢，造成(大量)伤害",
		condition = {
			required = {"曹操","魏","群"},
		},
		priority = 2,
	},
	["地表最强"] = {
		desc = "上阵4名展示的将领时激活合体，汇聚血色巨刀，造成(大量)伤害，必定暴击",
		condition = {
			optional = {
				min = 4,
				heroes = {"吕布","关羽","张飞","赵云","黄忠","马超","甘宁","典韦","张辽","夏侯渊","许褚","孙策","孙坚","太史慈","刑道荣"},
			},
		},
		priority = 2,
	},
	["倾城绝艳"] = {
		desc = "上阵4名展示的将领时激活合体，在战场中尽情舞蹈，造成(大量)伤害，并附带魅惑效果",
		condition = {
			optional = {
				min = 4,
				heroes = {"黄月英","甄姬","大乔","小乔","孙尚香","貂蝉","蔡文姬"},
			},
		},
		priority = 2,
	},
	["富甲天下"] = {
		desc = "上阵孙权、1名吴国和1名群雄将领时激活合体，向天空撒币，造成(大量)伤害",
		condition = {
			required = {"孙权","吴","群"},
		},
		priority = 2,
	},
	-- S2
	["龙吟九天"] = {
		desc = "上阵4名展示的将领时激活合体，召唤大量神龙攻击敌方，造成(大量)伤害，并附带中毒效果，持续(中量)时间",
		condition = {
			optional = {
				min = 4,
				heroes = {"荀彧","曹仁","曹操","郭嘉","夏侯惇","典韦","张辽"},
			},
		},
		priority = 1,
	},
	["孙刘联盟"] = {
		desc = "上阵诸葛亮、1名蜀国和1名吴国时激活合体，幻化出火凤与白虎攻击所有敌方，造成(大量)伤害",
		condition = {
			required = {"诸葛亮","蜀","吴"},
		},
		priority = 1,
	},
	["火凤燎原"] = {
		desc = "上阵4名展示的将领时激活合体，化身为火凤焚烧所有敌方，造成(大量)伤害，并附带灼烧效果，持续(少量)时间",
		condition = {
			optional = {
				min = 4,
				heroes = {"庞统","孙策","周瑜","周泰","甘宁","小乔","黄盖"},
			},
		},
		priority = 1,
	},
	["龙舞蝶"] = {
		desc = "上阵吕布和貂蝉时激活合体，幻化出金龙与蝴蝶攻击范围内敌方，造成(大量)伤害，并附带魅惑效果，持续少量时间",
		condition = {
			required = {"吕布","貂蝉"},
		},
		priority = 1,
	},
	["五虎上将"] = {
		desc = "上阵4名五虎将领时激活合体，化身为白虎连续攻击敌方，造成(大量)伤害，并获得霸体状态，持续(大量)时间",
		condition = {
			optional = {
				min = 4,
				heroes = {"张飞","关羽","赵云","马超","黄忠"},
			},
		},
		priority = 1,
	},
	["群英荟萃"] = {
		desc = "化身为龙卷风摧毁敌方，造成大量伤害",
		condition = {
			required = {"群","群","群"},
		},
		priority = 0,
	},
	["江东豪杰"] = {
		desc = "化身为龙卷风摧毁敌方，造成大量伤害",
		condition = {
			required = {"吴","吴","吴"},
		},
		priority = 0,
	},
	["魏武雄狮"] = {
		desc = "化身为龙卷风摧毁敌方，造成大量伤害",
		condition = {
			required = {"魏","魏","魏"},
		},
		priority = 0,
	},
	["蜀汉之志"] = {
		desc = "化身为龙卷风摧毁敌方，造成大量伤害",
		condition = {
			required = {"蜀","蜀","蜀"},
		},
		priority = 0,
	},
}

local function DuplicateTable(t)
	local newTable = {}
	for k, v in pairs(t) do
		newTable[k] = v
	end
	return newTable
end

--- 是否满足 required 条件
---@param heroName2Faction table<string, string> @ 英雄名称与阵营的映射表
---@param conditions string[] @ 条件, 每一项可以是单个英雄名称，也可以是阵营名称
---@param minMatchedCount number @ 最少匹配的条件数量
local function IsConditionMatched(heroName2Faction, conditions, minMatchedCount)
	if not conditions or #conditions == 0 or minMatchedCount == 0 then
		return true, heroName2Faction
	end

	-- 优先满足指定武将，再满足指定阵营
	-- 实现时是把武将配置在阵营前面，遍历时优先满足前面的条件
	local restHeroes = DuplicateTable(heroName2Faction)
	local matchedCount = 0
	for _, condition in ipairs(conditions) do
		for heroName, faction in pairs(restHeroes) do
			if heroName == condition or faction == condition then
				matchedCount = matchedCount + 1
				restHeroes[heroName] = nil
				break
			end
		end
	end

	return matchedCount >= minMatchedCount, restHeroes
end

--- 可能同时满足多个技能的条件，从这些条件中根据优先级高低选择一个技能
--- 如果相同优先级的技能有多个，随缘了（跟pairs的遍历顺序有关，不稳定）
---@param skills string[] @ 技能名称
local function SelectOneSkill(skills)
	if #skills == 0 then
		return
	end

	table.sort(skills, function(a, b)
		return COMBINATION_SKILLS[a].priority > COMBINATION_SKILLS[b].priority
	end)

	return skills[1]
end

-- 把 desc 里的 ( 替换为 <p style="color:red">, 把 ) 替换为 </p>
local function ReplaceBrackets(desc)
	return desc:gsub("%(", "<font color=\"green\">"):gsub("%)", "</font>")
end

local M = {}

--- 分析组合技
---@param build string[] @ 英雄列表
function M.AnalysisCombinationSkill(build)
	local heroName2Faction = {}
	for _, heroName in ipairs(build) do
		local hero = Heroes.GetHero(heroName)
		heroName2Faction[heroName] = hero[IDX_Faction]
	end

	local matchedSkills = {}
	for skillName, skillConfig in pairs(COMBINATION_SKILLS) do
		local condition = skillConfig.condition

		local isMatched
		local restHeroes = heroName2Faction
		if condition.required then
			isMatched, restHeroes = IsConditionMatched(restHeroes, condition.required, #condition.required)
			if not isMatched then
				goto continue
			end
		end
		if condition.optional then
			isMatched = IsConditionMatched(restHeroes, condition.optional.heroes, condition.optional.min)
			if not isMatched then
				goto continue
			end
		end

		table.insert(matchedSkills, skillName)
		::continue::
	end

	local skill = SelectOneSkill(matchedSkills)
	if skill then
		return skill, ReplaceBrackets(COMBINATION_SKILLS[skill].desc)
	end
end

return M
