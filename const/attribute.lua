-- 属性系统

CONST_ATTR = {
    life = "生命",
    mana = "魔法",
    move = "移动",
    defend = "护甲",
    attack_damage_type = "攻击伤害类型",
    physical = "物理",
    magic = "魔法",
    real = "真实",
    absolute = "绝对",
    fire = "火",
    soil = "土",
    water = "水",
    ice = "冰",
    wind = "风",
    light = "光",
    dark = "暗",
    wood = "木",
    thunder = "雷",
    poison = "毒",
    ghost = "鬼",
    metal = "金",
    dragon = "龙",
    insect = "虫",
    god = "神",
    attack_speed = "攻速",
    attack_speed_space = "攻击间隔",
    attack_white = "攻击力",
    attack_green = "附加攻击力",
    attack_range = "攻击范围",
    sight = "视野范围",
    str_green = "附加力量",
    agi_green = "附加敏捷",
    int_green = "附加智力",
    str_white = "本体力量",
    agi_white = "本体敏捷",
    int_white = "本体智力",
    life_back = "生命恢复",
    mana_back = "魔法恢复",
    resistance = "魔抗",
    toughness = "减伤",
    avoid = "回避",
    aim = "命中",
    punish = "僵直",
    punish_current = "当前僵直",
    meditative = "冥想力",
    help = "救助力",
    hemophagia = "吸血",
    hemophagia_skill = "技能吸血",
    luck = "幸运",
    invincible = "无敌",
    weight = "负重",
    weight_current = "当前负重",
    damage_extent = "伤害增幅",
    damage_rebound = "反弹伤害",
    damage_rebound_oppose = "反伤抵抗",
    cure = "治疗",
    knocking_oppose = "物理暴击抵抗",
    violence_oppose = "魔法暴击抵抗",
    hemophagia_oppose = "吸血抵抗",
    hemophagia_skill_oppose = "技能吸血抵抗",
    split_oppose = "分裂抵抗",
    punish_oppose = "僵直抵抗",
    swim_oppose = "眩晕抵抗",
    broken_oppose = "打断抵抗",
    silent_oppose = "沉默抵抗",
    unarm_oppose = "缴械抵抗",
    fetter_oppose = "缚足抵抗",
    bomb_oppose = "爆破抵抗",
    lightning_chain_oppose = "闪电链抵抗",
    crack_fly_oppose = "击飞抵抗",
    natural_fire = "自然火攻",
    natural_soil = "自然土攻",
    natural_water = "自然水攻",
    natural_ice = "自然冰攻",
    natural_wind = "自然风攻",
    natural_light = "自然光攻",
    natural_dark = "自然暗攻",
    natural_wood = "自然木攻",
    natural_thunder = "自然雷攻",
    natural_poison = "自然毒攻",
    natural_ghost = "自然鬼攻",
    natural_metal = "自然金攻",
    natural_dragon = "自然龙攻",
    natural_insect = "自然虫攻",
    natural_god = "自然神攻",
    natural_fire_oppose = "自然火抗",
    natural_soil_oppose = "自然土抗",
    natural_water_oppose = "自然水抗",
    natural_ice_oppose = "自然冰抗",
    natural_wind_oppose = "自然风抗",
    natural_light_oppose = "自然光抗",
    natural_dark_oppose = "自然暗抗",
    natural_wood_oppose = "自然风抗",
    natural_thunder_oppose = "自然雷抗",
    natural_poison_oppose = "自然毒抗",
    natural_ghost_oppose = "自然鬼抗",
    natural_metal_oppose = "自然金抗",
    natural_dragon_oppose = "自然龙抗",
    natural_insect_oppose = "自然虫抗",
    natural_god_oppose = "自然神抗",
    --
    attack_buff = "攻击增益",
    attack_debuff = "负面攻击",
    skill_buff = "技能增益",
    skill_debuff = "负面技能",
    attack_effect = "攻击特效",
    skill_effect = "技能特效",
    --
    knocking = "物理暴击",
    violence = "魔法暴击",
    split = "分裂",
    swim = "眩晕",
    broken = "打断",
    silent = "沉默",
    unarm = "缴械",
    fetter = "缚足",
    bomb = "爆破",
    lightning_chain = "闪电链",
    crack_fly = "击飞",
    --
    odds = "几率",
    val = "数值",
    during = "持续时间",
    qty = "数量",
    range = "范围",
    reduce = "衰减",
    distance = "距离",
    high = "高度"
}

const_getItemDesc = function(attr)
    local str = ""
    for k, v in pairs(attr) do
        -- 附加单位
        if (k == "attack_speed_space") then
            v = v .. "击每秒"
        end
        if (table.includes(k, {"life_back", "mana_back"})) then
            v = v .. "每秒"
        end
        if
            (table.includes(
                k,
                {
                    "resistance",
                    "avoid",
                    "aim",
                    "knocking",
                    "violence",
                    "knocking_odds",
                    "violence_odds",
                    "hemophagia",
                    "hemophagia_skill",
                    "split",
                    "luck",
                    "invincible",
                    "damage_extent",
                    "damage_rebound",
                    "cure"
                }
            ))
         then
            v = v .. "%"
        end
        local s = string.find(k, "oppose")
        local n = string.find(k, "natural")
        if (s ~= nil or n ~= nil) then
            v = v .. "%"
        end
        --
        str = str .. CONST_ATTR[k] .. "："
        if (type(v) == "table") then
            local temp = ""
            if (table.includes(k, {"attack_damage_type"})) then
                for _, vv in ipairs(v) do
                    if (temp == "") then
                        temp = temp .. CONST_ATTR[vv]
                    else
                        temp = "," .. CONST_ATTR[vv]
                    end
                end
            elseif
                (table.includes(
                    k,
                    {"attack_buff", "attack_debuff", "skill_buff", "skill_debuff", "attack_effect", "skill_effect"}
                ))
             then
                for kk, vv in pairs(v) do
                    temp = temp .. CONST_ATTR[kk]
                    local temp2 = ""
                    for kkk, vvv in pairs(vv) do
                        if (kkk == "during") then
                            vvv = vvv .. "秒"
                        end
                        if (table.includes(kkk, {"odds", "reduce"})) then
                            vvv = vvv .. "%"
                        end
                        if (temp2 == "") then
                            temp2 = temp2 .. CONST_ATTR[kkk] .. "[" .. vvv .. "]"
                        else
                            temp2 = temp2 .. "," .. CONST_ATTR[kkk] .. "[" .. vvv .. "]"
                        end
                    end
                    temp = temp .. temp2
                end
            end
            str = str .. temp
        else
            str = str .. v
        end
        str = str .. "|n"
    end
    return str
end

const_getItemUbertip = function(attr)
    local str = ""
    for k, v in pairs(attr) do
        str = str .. CONST_ATTR[k] .. ":"
        if (type(v) == "table") then
            local temp = ""
            if (k == "attack_damage_type") then
                for _, vv in ipairs(v) do
                    if (temp == "") then
                        temp = temp .. CONST_ATTR[vv]
                    else
                        temp = "," .. CONST_ATTR[vv]
                    end
                end
            end
        else
            str = str .. v
        end
        str = str .. ","
    end
    return str
end
