-- 指尖无双 追击技能组合

local Heroes = require "Config.Heroes"
local Combinations = require "Combinations"

local tinsert = table.insert

----------------------------------------------------------------
local HERO_COUNT_PER_BUILD = 4

local IDX_Rage         = 1 -- 怒技
local IDX_NormalAttack = 2 -- 普攻
local IDX_Chase1       = 3 -- 追击条件
local IDX_Chase2       = 4 -- 追击结果
local IDX_Name         = 5 -- 英雄名

-- 分割线
local SPLIT_LINE = "-----------------------------------------------------------"

----------------------------------------------------------------
local Combo = {}

local function GetAllCombinations()
	return Combinations.GenerateAllCombinations(HERO_COUNT_PER_BUILD)
end

local function AnalysisCombination(heroes, combination)
	local combo = { combination[1] }
	for i = 2, HERO_COUNT_PER_BUILD do
		local lastHero = heroes[combination[i-1]]
		local curHero = heroes[combination[i]]
		if lastHero[IDX_Chase2] == "/" then
			break
		end
		if curHero[IDX_Chase1] ~= lastHero[IDX_Chase2] then
			-- print(a, b, c, d, i, curHero[IDX_Z1], lastHero[IDX_Z2])
			break
		end
		tinsert(combo, combination[i])
	end
	return combo
end

local function Build2Heroes(build)
	local heroes = {}
	for _, v in ipairs(build) do
		local hero = Heroes[v]
		hero[IDX_Name] = v
		tinsert(heroes, hero)
	end
	return heroes
end

--[[
	groupedCombos = {
		[1] = {
			{1},{2},{3},...
		},
		[2] = {
			{1,2},
			{1,3},
			{2,3},
			...
		},
		[3] = {
			{1,2,3},
			...
		},
		[4] = {
			{1,2,3,4},
			...
		},
	}
]]

---@param title string
---@param callback fun(combo:table):string @ 每个Combo的回调，返回内容显示在Combo预览下面（缩进一个Tab）
local function GenerateComboReport(build, heroes, groupedCombos, title, callback)
	local report = {
		"阵容：" .. table.concat(build, ","),
		title,
		SPLIT_LINE,
	}
	for i = #groupedCombos, 2, -1 do
		local combos = groupedCombos[i]
		if #combos > 0 then
			-- 连击预览
			tinsert(report, string.format("%d连（共%d个）", i, #combos))
			for _, combo in ipairs(combos) do
				local result = {}
				for _, v in ipairs(combo) do
					local hero = heroes[v]
					tinsert(result, hero[IDX_Name] .. ":" .. hero[IDX_Chase1] .. "->" .. hero[IDX_Chase2])
				end
				tinsert(report, table.concat(result, " | "))
				if callback then
					tinsert(report, callback(combo))
				end
			end
			tinsert(report, SPLIT_LINE)
		end
	end
	return table.concat(report, "\n")
end

local function GenerateComboPreview(build, heroes, groupedCombos)
	return GenerateComboReport(build, heroes, groupedCombos, "连击预览:")
end

-- 判断怒技（大招）是否能触发连击
local function CanTriggerByRage(hero, heroes, combo)
	-- 放怒技时，除了部分英雄有概率能触发连击外，大部分不能触发
	-- 这里简单处理，就假定所有英雄的怒技都不能触发连击

	-- 大招一定不能触发4连
	if #combo >= HERO_COUNT_PER_BUILD then
		return false
	end

	-- 如果自身在combo中，直接返回false
	for _, v in ipairs(combo) do
		if hero[IDX_Name] == heroes[v][IDX_Name] then
			return false
		end
	end

	return hero[IDX_Rage] == heroes[1][IDX_Chase1]
end

local function GenerateComboDetails(build, heroes, groupedCombos)
	return GenerateComboReport(build, heroes, groupedCombos, "连击详情:", function(combo)
		local firstCondition = heroes[combo[1]][IDX_Chase1]
		local triggerRage = {}
		local triggerNormalAtk = {}
		for _, v in ipairs(combo) do
			local hero = heroes[v]
			-- 普攻触发
			if hero[IDX_NormalAttack] == firstCondition then
				tinsert(triggerNormalAtk, hero[IDX_Name])
			end
			-- 怒技触发
			if CanTriggerByRage(hero, heroes, combo) then
				tinsert(triggerRage, hero[IDX_Name])
			end
		end
		-- 生成触发报告
		local report = {}
		local PREFIX = "\t"
		local normalAtkCount = #triggerNormalAtk
		local rageCount = #triggerRage
		tinsert(report, string.format("%s总触发：%d, 普攻触发：%d, 怒技触发：%d", PREFIX, normalAtkCount + rageCount, normalAtkCount, rageCount))
		if normalAtkCount > 0 then
			tinsert(report, string.format("%s普攻触发：%s", PREFIX, table.concat(triggerNormalAtk, " | ")))
		end
		if rageCount > 0 then
			tinsert(report, string.format("%s怒技触发：%s", PREFIX, table.concat(triggerRage, " | ")))
		end
		return table.concat(report, "\n")
	end)
end

local function HashCombo(combo)
	local value = 0
	for i, v in ipairs(combo) do
		value = value + (v * math.pow(10, i - 1))
	end
	return value
end

-- 去重
local function RemoveDuplicates(groupedCombos)
	local uniqueGroupedCombos = {{},{},{},{}}
	for _, combos in ipairs(groupedCombos) do
		local hashMap = {}
		for _, combo in ipairs(combos) do
			local hashValue = HashCombo(combo)
			if not hashMap[hashValue] then
				hashMap[hashValue] = true
				tinsert(uniqueGroupedCombos[#combo], combo)
			end
		end
	end
	return uniqueGroupedCombos
end

function Combo.AnalysisBuild(build)
	if #build ~= HERO_COUNT_PER_BUILD then
		error("指尖无双 追击技能组合: 需要指定" .. HERO_COUNT_PER_BUILD .. "个英雄")
	end
	local combinations = GetAllCombinations()
	local groupedCombos = {{},{},{},{}}
	local heroes = Build2Heroes(build)
	for _, combination in ipairs(combinations) do
		local combo = AnalysisCombination(heroes, combination)
		tinsert(groupedCombos[#combo], combo)
	end
	groupedCombos = RemoveDuplicates(groupedCombos)
	return GenerateComboPreview(build, heroes, groupedCombos), GenerateComboDetails(build, heroes, groupedCombos)
end

return Combo
