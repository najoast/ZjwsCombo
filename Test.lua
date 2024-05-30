-- 指尖无双 追击技能组合

local Combo = require "Combo"

local Team1 = {
	"关羽",
	"诸葛亮",
	"赵云",
	"周瑜",
	"诸葛亮",
	"袁绍",
}

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

print(Combo.AnalysisBuild(Team1))
