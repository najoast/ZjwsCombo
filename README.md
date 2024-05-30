# ZjwsCombo
指尖无双技能连击分析工具。

指尖无双的追击技能很有意思，每个技能或普攻都有可能导致以下三种状态：
* 倒地
* 浮空
* 击退

追击技能的一般形式为：如果敌人处于A状态，则造成伤害并使其处于B状态（A和B有可能相等）

举例：
* 孙坚：如果倒地则浮空
* 关羽：如果浮空则浮空

由此，不同武将组合起来，可以形成最高4次连击。
这个游戏里的伤害主要靠连击来打，所以分析阵容的连击变得至关重要。
本工具即是用来分析阵容连击情况的。

虽然目前已经有了一些工具，比如“牛批快查”，但该工具并不能直接指定阵容来分析。
最近我在调整阵容时，急需一个这样的工具，由于逻辑并不复杂，干脆自己动手写了，于是有了此项目。

# 使用方法
```sh
lua Main.lua 关羽 诸葛亮 赵云 周瑜
```

输出：
```
关羽,诸葛亮,赵云,周瑜
-----------------------------------------------------------
4连（共8个）
关羽:浮空->浮空 | 赵云:浮空->倒地 | 诸葛亮:倒地->浮空 | 周瑜:浮空->浮空
关羽:浮空->浮空 | 周瑜:浮空->浮空 | 赵云:浮空->倒地 | 诸葛亮:倒地->浮空
诸葛亮:倒地->浮空 | 关羽:浮空->浮空 | 周瑜:浮空->浮空 | 赵云:浮空->倒地
诸葛亮:倒地->浮空 | 周瑜:浮空->浮空 | 关羽:浮空->浮空 | 赵云:浮空->倒地
赵云:浮空->倒地 | 诸葛亮:倒地->浮空 | 关羽:浮空->浮空 | 周瑜:浮空->浮空
赵云:浮空->倒地 | 诸葛亮:倒地->浮空 | 周瑜:浮空->浮空 | 关羽:浮空->浮空
周瑜:浮空->浮空 | 关羽:浮空->浮空 | 赵云:浮空->倒地 | 诸葛亮:倒地->浮空
周瑜:浮空->浮空 | 赵云:浮空->倒地 | 诸葛亮:倒地->浮空 | 关羽:浮空->浮空
-----------------------------------------------------------
3连（共2个）
诸葛亮:倒地->浮空 | 关羽:浮空->浮空 | 赵云:浮空->倒地
诸葛亮:倒地->浮空 | 周瑜:浮空->浮空 | 赵云:浮空->倒地
-----------------------------------------------------------
2连（共5个）
关羽:浮空->浮空 | 赵云:浮空->倒地
关羽:浮空->浮空 | 周瑜:浮空->浮空
诸葛亮:倒地->浮空 | 赵云:浮空->倒地
周瑜:浮空->浮空 | 关羽:浮空->浮空
周瑜:浮空->浮空 | 赵云:浮空->倒地
-----------------------------------------------------------
```

也可以打开 `Test.lua`，手动编辑要分析的阵容，之后直接执行 `lua Test.lua` 即可。
（由于这种方法可以通过注释的方式调整阵容，我比较倾向于这种方式）

# TODO
- [x] 分析连击的触发情况
- [x] 支持华佗
- [x] 支持命令行传入阵容
- [ ] 阵容推荐（填写拥有的英雄和星级，推荐连击数最高的阵容）
- [ ] 界面
- [ ] 武将阵营
- [ ] 显示合体技
- [x] 任意阵容数量支持
