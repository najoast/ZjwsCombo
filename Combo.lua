-- 指尖无双 追击技能组合

local Heroes = require "Config.Heroes"
local Combinations = require "Combinations"

local tinsert = table.insert

local HERO_COUNT_PER_BD = 4

local IDX_Rage         = 1 -- 怒技
local IDX_NormalAttack = 2 -- 普攻
local IDX_Chase1       = 3 -- 追击条件
local IDX_Chase2       = 4 -- 追击结果
local IDX_Name         = 5 -- 英雄名

local Combo = {}

local function GetAllCombinations()
	return Combinations.GenerateAllCombinations(HERO_COUNT_PER_BD)
end

local function AnalysisCombination(heroes, combination)
	local combo = { combination[1] }
	for i = 2, HERO_COUNT_PER_BD do
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

-- 吴国暴击队
local Team2 = {
	"凌统",
	"太史慈",
	"孙坚",
	"周泰",
	-- "鲁肃",
	-- "甘宁",
}

local Team3 = {
	"黄忠",
	"赵云",
	"诸葛亮",
	"张飞",
}

local Team4 = {
	"张角",
	"董卓",
	"袁绍",
	"夏侯惇",
}

-- Team 5
local Team5 = {
	"许禇", -- 魏
	"周泰", -- 吴
	-- "貂蝉", -- 群
	-- "孟获", -- 蜀
	-- "孙策",
	-- "甘宁",
}


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
local function GenerateComboPreview(build, heroes, groupedCombos)
	local report = {
		table.concat(build, ","),
		"-----------------------------------------------------------",
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
			end
			tinsert(report, "-----------------------------------------------------------")
		end
	end
	return table.concat(report, "\n")
end

local function ParseComboTrigger(heroes, combo)
	for _, v in ipairs(combo) do
		local hero = heroes[v]
		tinsert(result, hero[IDX_Name] .. ":" .. hero[IDX_Chase1] .. "->" .. hero[IDX_Chase2])
	end
end

local function GenerateComboDetails(heroes, groupedCombos)
	local report = {}
	for i = #groupedCombos, 2, -1 do
		local combos = groupedCombos[i]
		if #combos > 0 then
			tinsert(report, string.format("%d连（共%d个）", i, #combos))
			for _, combo in ipairs(combos) do
				local result = {}
				for _, v in ipairs(combo) do
					local hero = heroes[v]
					tinsert(result, hero[IDX_Name] .. ":" .. hero[IDX_Chase1] .. "->" .. hero[IDX_Chase2])
				end
				tinsert(report, table.concat(result, " | "))
			end
			tinsert(report, "-----------------------------------------------------------")
		end
	end
	return table.concat(report, "\n")
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
	local combinations = GetAllCombinations()
	local groupedCombos = {{},{},{},{}}
	local heroes = Build2Heroes(build)
	for _, combination in ipairs(combinations) do
		local combo = AnalysisCombination(heroes, combination)
		tinsert(groupedCombos[#combo], combo)
	end
	groupedCombos = RemoveDuplicates(groupedCombos)
	return GenerateComboPreview(build, heroes, groupedCombos)
end

return Combo
