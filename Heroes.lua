-- 英雄名，阵营，稀有度，大招，普攻，追击条件，追击效果
local Heroes = {
	-- 蜀 SSR
	{"张飞","蜀","SSR","浮空","倒地","倒地","击退"},
	{"关羽","蜀","SSR","浮空","倒地","浮空","浮空"},
	{"赵云","蜀","SSR","倒地","浮空","浮空","倒地"},
	{"刘备","蜀","SSR","倒地","倒地","击退","浮空"},
	{"诸葛亮","蜀","SSR","浮空","浮空","倒地","浮空"},
	{"马超","蜀","SSR","击退","浮空","击退","击退"},
	{"黄忠","蜀","SSR","击退","击退","击退","浮空"},
	-- 蜀 SR
	{"徐庶","蜀","SR","/","击退","击退","/"},
	{"魏延","蜀","SR","/","浮空","击退","/"},
	{"孟获","蜀","SR","倒地","倒地","击退","/"},
	-- 魏 SSR
	{"曹操","魏","SSR","倒地","倒地","倒地","浮空"},
	{"夏侯惇","魏","SSR","击退","浮空","倒地","倒地"},
	{"郭嘉","魏","SSR","浮空","浮空","浮空","倒地"},
	{"夏侯渊","魏","SSR","击退","击退","击退","击退"},
	{"许褚","魏","SSR","击退","倒地","击退","浮空"},
	{"典韦","魏","SSR","击退","倒地","击退","倒地"},
	{"张辽","魏","SSR","浮空","倒地","浮空","击退"},
	-- 魏 SR
	{"张郃","魏","SR","/","击退","击退","/"},
	{"于禁","魏","SR","浮空","浮空","倒地","/"},
	{"徐晃","魏","SR","浮空","倒地","倒地","/"},
	-- 吴 SSR
	{"孙策","吴","SSR","灼烧","浮空","击退","倒地"},
	{"周瑜","吴","SSR","灼烧","浮空","浮空","浮空"},
	{"太史慈","吴","SSR","倒地","击退","浮空","击退"},
	{"孙坚","吴","SSR","倒地","倒地","倒地","浮空"},
	{"大乔","吴","SSR","灼烧","浮空","浮空","击退"},
	{"小乔","吴","SSR","灼烧","击退","浮空","倒地"},
	{"周泰","吴","SSR","浮空","击退","击退","浮空"},
	{"甘宁","吴","SSR","倒地","倒地","倒地","浮空"},
	-- 吴 SR
	{"黄盖","吴","SR","浮空","倒地","倒地","/"},
	{"鲁肃","吴","SR","击退","击退","浮空","/"},
	{"凌统","吴","SR","浮空","浮空","击退","/"},
	-- 群 SSR
	{"吕布","群","SSR","浮空","浮空","浮空","击退"},
	{"张角","群","SSR","/","浮空","浮空","倒地"},
	{"董卓","群","SSR","浮空","倒地","倒地","浮空"},
	{"袁绍","群","SSR","浮空","倒地","倒地","浮空"},
	{"貂蝉","群","SSR","魅惑","倒地","击退","浮空"},
	{"贾诩","群","SSR","浮空","击退","击退","浮空"},
	{"高顺","群","SSR","浮空","击退","击退","击退"},
	{"华佗","群","SSR","回复","倒地","反击","击退"},
	-- 群 SR
	{"颜良","群","SR","击退","浮空","浮空","/"},
	{"文丑","群","SR","浮空","浮空","击退","/"},
	{"司马徽","群","SR","击退","击退","浮空","/"},
}

local Indexes = {
	Name         = 1, -- 英雄名
	Faction      = 2, -- 阵营
	Rarity       = 3, -- 稀有度
	Rage         = 4, -- 大招
	NormalAttack = 5, -- 普攻
	Chase1       = 6, -- 追击条件
	Chase2       = 7, -- 追击结果
}

local HeroMap = {}

local IDX_Name = Indexes.Name

for _, hero in ipairs(Heroes) do
	HeroMap[hero[IDX_Name]] = hero
end

-- 错别字/外号/别名自适应
HeroMap["许诸"] = HeroMap["许褚"]
HeroMap["许禇"] = HeroMap["许褚"]
HeroMap["夏侯淳"] = HeroMap["夏侯惇"]
HeroMap["张合"] = HeroMap["张郃"]
HeroMap["司马微"] = HeroMap["司马徽"]
HeroMap["司马"] = HeroMap["司马徽"]
HeroMap["诸葛"] = HeroMap["诸葛亮"]
HeroMap["骚猪"] = HeroMap["董卓"]

local M = {}

function M.GetArray()
	return Heroes
end

function M.GetMap()
	return HeroMap
end

function M.GetIndexes()
	return Indexes
end

function M.GetHero(name)
	return HeroMap[name]
end

return M
