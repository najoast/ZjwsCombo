-- 指尖无双 追击技能组合

local Heroes = require "Heroes"
local Combinations = require "Combinations"
local CombinationSkills = require "CombinationSkills"

local tinsert = table.insert

----------------------------------------------------------------

local MIN_HEROES_COUNT = 2

local Indexes = Heroes.GetIndexes()

local IDX_Name         = Indexes.Name
local IDX_Rage         = Indexes.Rage
local IDX_NormalAttack = Indexes.NormalAttack
local IDX_Chase1       = Indexes.Chase1
local IDX_Chase2       = Indexes.Chase2
local IDX_Faction      = Indexes.Faction

-- 分割线
local SPLIT_LINE = "-----------------------------------------------------------"

local VALID_CHASES = {
	["浮空"] = true,
	["倒地"] = true,
	["击退"] = true,
}

----------------------------------------------------------------
local Combo = {}

local function AnalysisCombination(heroes, combination)
	local combo = { combination[1] }
	for i = MIN_HEROES_COUNT, #heroes do
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
	for _, heroName in ipairs(build) do
		local hero = Heroes.GetHero(heroName)
		if not hero then
			return string.format("英雄[%s]不存在", tostring(heroName))
		end
		hero[IDX_Name] = heroName
		tinsert(heroes, hero)
	end
	return nil, heroes
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

local function BuildStr(build)
	local str = ""
	for _, heroName in ipairs(build) do
		local hero = Heroes.GetHero(heroName)
		str = str .. string.format("%s(%s)  ", hero[IDX_Name], hero[IDX_Faction])
	end
	return str
end

--- 生成连击报告
---@param title string
---@param lineCallback fun(combo:table):string @ 每个Combo的回调，返回内容显示在Combo 行尾
---@param sectionCallback fun(combo:table):string @ 每段Combos的回调，返回内容显示在段首（段是以几连划分的，比如4连是一段，3连是一段）
local function GenerateComboReport(build, heroes, groupedCombos, title, lineCallback, sectionCallback)
	local report = { "阵容：" .. BuildStr(build) }
	local combinationSkill, desc = CombinationSkills.AnalysisCombinationSkill(build)
	if combinationSkill then
		tinsert(report, string.format("合体技：%s (%s)", combinationSkill, desc))
	end
	tinsert(report, title)
	tinsert(report, SPLIT_LINE)

	for i = #groupedCombos, MIN_HEROES_COUNT, -1 do
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
				local line = table.concat(result, " | ")
				if lineCallback then
					-- tinsert(report, callback(combo))
					line = line .. (lineCallback(combo) or "")
				end
				tinsert(report, line)
			end
			if sectionCallback then
				tinsert(report, sectionCallback(i, combos))
			end
			tinsert(report, SPLIT_LINE)
		end
	end
	return table.concat(report, "\n")
end

local function GenerateComboPreview(build, heroes, groupedCombos)
	return GenerateComboReport(build, heroes, groupedCombos, "连击预览:")
end

-- 判断大招是否能触发追击
local function CanTriggerByRage(hero, firstCondition)
	-- 放大招时，并不能稳定触发追击，因为大招有持续时间，在持续时间内是不参与追击的，
	-- 但如果大招快放完时触发了效果，那就可以参与追击。

	local rageEffect = hero[IDX_Rage]
	if not VALID_CHASES[rageEffect] then
		return false
	end

	return rageEffect == firstCondition
end

local function NewGroupedCombos(n)
	local groupedCombos = {}
	for _ = 1, n do
		tinsert(groupedCombos, {})
	end
	return groupedCombos
end

local function GenerateComboDetails(build, heroes, groupedCombos)
	local totalTriggerCount = 0

	local function LineCallback(combo)
		print(table.concat(combo, " "))
		local firstCondition = heroes[combo[1]][IDX_Chase1]
		local triggerRage = {}
		local triggerNormalAtk = {}
		for _, v in ipairs(combo) do
			local hero = heroes[v]
			-- 普攻触发
			print("==>", #combo, hero[IDX_NormalAttack], firstCondition)
			if hero[IDX_NormalAttack] == firstCondition then
				tinsert(triggerNormalAtk, hero[IDX_Name])
			end
			-- 大招触发
			if CanTriggerByRage(hero, firstCondition) then
				tinsert(triggerRage, hero[IDX_Name])
			end
		end
		-- 生成触发报告
		local normalAtkCount = #triggerNormalAtk
		local rageCount = #triggerRage
		local triggerCount = normalAtkCount + rageCount
		local triggerReport = {}
		if firstCondition == "反击" then
			tinsert(triggerReport, "触发:等于对面阵容的追击触发次数")
		else
			tinsert(triggerReport, "触发:" .. triggerCount)
		end
		totalTriggerCount = totalTriggerCount + triggerCount
		-- 总触发4,普攻触发3,大招触发1,普攻:关羽/诸葛亮/赵云,大招:周瑜
		if triggerCount > 0 then
			if normalAtkCount > 0 then
				tinsert(triggerReport, "普攻" .. normalAtkCount .. ":" .. table.concat(triggerNormalAtk, "/"))
			end
			if rageCount > 0 then
				tinsert(triggerReport, "大招" .. rageCount .. ":" .. table.concat(triggerRage, "/"))
			end
		end
		return " (" .. table.concat(triggerReport,",") .. ")"
	end

	local function SectionCallback(i)
		local count = totalTriggerCount
		totalTriggerCount = 0
		return i .. "连总触发:" .. count
	end

	return GenerateComboReport(build, heroes, groupedCombos, "连击详情:", LineCallback, SectionCallback)
end

local function HashCombo(combo)
	local value = 0
	for i, v in ipairs(combo) do
		value = value + (v * 10^(i-1))
	end
	return value
end

-- 去重
local function RemoveDuplicates(groupedCombos)
	local uniqueGroupedCombos = NewGroupedCombos(#groupedCombos)
	for i = 1, #groupedCombos do
		local combos = groupedCombos[i]
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

local function IsValidBuild(build)
	if #build < MIN_HEROES_COUNT then
		return "至少" .. MIN_HEROES_COUNT .."个英雄"
	end
	local m = {}
	for _, v in ipairs(build) do
		if not m[v] then
			m[v] = true
		else
			return "英雄[" .. v .. "]重复"
		end
	end
end

function Combo.AnalysisBuild(build)
	local err = IsValidBuild(build)
	if err then
		return err
	end

	local combinations = Combinations.GenerateAllCombinations(#build)
	local groupedCombos = NewGroupedCombos(#build)
	local err, heroes = Build2Heroes(build)
	if err then
		return err
	end

	for _, combination in ipairs(combinations) do
		local combo = AnalysisCombination(heroes, combination)
		tinsert(groupedCombos[#combo], combo)
	end
	groupedCombos = RemoveDuplicates(groupedCombos)
	-- return GenerateComboPreview(build, heroes, groupedCombos) .. "\n\n" .. GenerateComboDetails(build, heroes, groupedCombos)
	return GenerateComboDetails(build, heroes, groupedCombos)
end

return Combo
