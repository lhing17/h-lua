--[[
    物理暴击
    options = {
        whichUnit = unit, --目标单位，必须
        odds = 0, --几率，必须
        damage = 0, --原始伤害，必须
        percent = 0, --暴击比例，必须
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.physical} --伤害的类型,注意是table（可选）
    }
]]
hskill.knocking = function(options)
    if (options.whichUnit == nil) then
        print_err("knocking: -whichUnit")
        return
    end
    local odds = options.odds or 0
    local damage = options.damage or 0
    local percent = options.percent or 0
    if (odds <= 0 or damage <= 0 or percent <= 0) then
        print_err("knocking: -odds -damage -percent")
        return
    end
    local targetUnit = options.whichUnit
    local targetOppose = hattr.get(targetUnit, "knocking_oppose")
    odds = odds - targetOppose
    if (odds <= 0) then
        return
    end
    if (math.random(1, 100) <= odds) then
        local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
        local damageType = options.damageType or { CONST_DAMAGE_TYPE.physical }
        local effect = options.effect or "war3mapImported\\eff_crit.mdl"
        heffect.toUnit(effect, targetUnit, 0.5)
        --暴！
        local val = damage * percent * 0.01
        hskill.damage(
            {
                sourceUnit = options.sourceUnit,
                targetUnit = targetUnit,
                damage = val,
                damageString = "物暴",
                damageStringColor = "ef3215",
                damageKind = damageKind,
                damageType = damageType
            }
        )
        --@触发物理暴击事件
        hevent.triggerEvent(
            options.sourceUnit,
            CONST_EVENT.knocking,
            {
                triggerUnit = options.sourceUnit,
                targetUnit = targetUnit,
                damage = val,
                odds = odds,
                percent = percent
            }
        )
        --@触发被物理暴击事件
        hevent.triggerEvent(
            targetUnit,
            CONST_EVENT.beKnocking,
            {
                triggerUnit = options.sourceUnit,
                sourceUnit = targetUnit,
                damage = val,
                odds = odds,
                percent = percent
            }
        )
    end
end

--[[
    魔法暴击
    options = {
        whichUnit = unit, --目标单位，必须
        odds = 100, --几率，必须
        damage = 0, --原始伤害，必须
        percent = 0, --暴击比例，必须
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {CONST_DAMAGE_TYPE.magic} --伤害的类型,注意是table（可选）
    }
]]
hskill.violence = function(options)
    if (options.whichUnit == nil) then
        print_err("violence: -whichUnit")
        return
    end
    local odds = options.odds or 0
    local damage = options.damage or 0
    local percent = options.percent or 0
    if (odds <= 0 or damage <= 0 or percent <= 0) then
        print_err("violence: -odds -damage -percent")
        return
    end
    local targetUnit = options.whichUnit
    local targetOppose = hattr.get(targetUnit, "violence_oppose")
    odds = odds - targetOppose
    if (odds <= 0) then
        return
    end
    if (math.random(1, 100) <= odds) then
        local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
        local damageType = options.damageType or { CONST_DAMAGE_TYPE.magic }
        local effect = options.effect or "war3mapImported\\eff_demon_explosion.mdl"
        heffect.toUnit(effect, targetUnit, 0.5)
        --暴！
        local val = damage * percent * 0.01
        hskill.damage(
            {
                sourceUnit = options.sourceUnit,
                targetUnit = targetUnit,
                damage = val,
                damageString = "魔爆",
                damageStringColor = "15bcef",
                damageKind = damageKind,
                damageType = damageType
            }
        )
        --@触发魔法暴击事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.violence,
            {
                triggerUnit = options.sourceUnit,
                targetUnit = targetUnit,
                damage = val,
                odds = odds,
                percent = percent
            }
        )
        --@触发被魔法暴击事件
        hevent.triggerEvent(
            targetUnit,
            CONST_EVENT.beViolence,
            {
                triggerUnit = targetUnit,
                sourceUnit = targetUnit,
                damage = val,
                odds = odds,
                percent = percent
            }
        )
    end
end

--[[
    分裂
    options = {
        whichUnit = unit, --目标单位，必须
        odds = 100, --几率，必须
        damage = 0, --原始伤害，必须
        percent = 0, --几率比例，必须
        range = 0, --分裂范围，必须
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.split = function(options)
    if (options.whichUnit == nil) then
        print_err("split: -whichUnit")
        return
    end
    local odds = options.odds or 0
    local damage = options.damage or 0
    local percent = options.percent or 0
    local range = options.range or 0
    if (odds <= 0 or damage <= 0 or percent <= 0 or range <= 0) then
        print_err("split: -odds -damage -percent -range")
        return
    end
    local targetUnit = options.whichUnit
    local targetOppose = hattr.get(targetUnit, "split_oppose")
    odds = odds - targetOppose
    if (odds <= 0) then
        return
    end
    if (math.random(1, 100) <= odds) then
        local g = hgroup.createByUnit(
            targetUnit,
            range,
            function(filterUnit)
                local flag = true
                if (his.death(filterUnit)) then
                    flag = false
                end
                if (his.enemy(filterUnit, whichUnit)) then
                    flag = false
                end
                if (his.building(filterUnit)) then
                    flag = false
                end
                return flag
            end
        )
        local splitDamage = damage * percent * 0.01
        local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
        local damageType = options.damageType or {}
        hgroup.loop(
            g,
            function(eu)
                if (eu ~= targetUnit) then
                    hskill.damage(
                        {
                            sourceUnit = options.sourceUnit,
                            targetUnit = eu,
                            damage = splitDamage,
                            damageString = "分裂",
                            damageStringColor = "ff6347",
                            damageKind = damageKind,
                            damageType = damageType,
                            effect = options.effect
                        }
                    )
                end
            end,
            true
        )
        -- @触发分裂事件
        hevent.triggerEvent(
            sourceUnit,
            CONST_EVENT.split,
            {
                triggerUnit = options.sourceUnit,
                targetUnit = targetUnit,
                damage = splitDamage,
                range = range,
                percent = percent
            }
        )
        -- @触发被分裂事件
        hevent.triggerEvent(
            targetUnit,
            CONST_EVENT.beSpilt,
            {
                triggerUnit = targetUnit,
                sourceUnit = options.sourceUnit,
                damage = splitDamage,
                range = range,
                percent = percent
            }
        )
    end
end

--[[
    打断
    options = {
        whichUnit = unit, --目标单位，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.broken = function(options)
    if (options.whichUnit == nil) then
        return
    end
    local u = options.whichUnit
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    --计算抵抗
    local oppose = hattr.get(u, "broken_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        damage = damage * (1 - oppose * 0.01)
    end
    local cu = hunit.create(
        {
            register = false,
            unitId = hskill.SKILL_TOKEN,
            whichPlayer = hplayer.player_passive,
            x = hunit.x(u),
            y = hunit.y(u)
        }
    )
    cj.UnitAddAbility(cu, hskill.SKILL_BREAK[0.05])
    cj.SetUnitAbilityLevel(cu, hskill.SKILL_BREAK[0.05], 1)
    cj.IssueTargetOrder(cu, "thunderbolt", u)
    hunit.del(cu, 0.3)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "打断",
                damageStringColor = "F0F8FF",
                damageKind = damageKind,
                damageType = damageType
            }
        )
    end
    -- @触发打断事件
    hevent.triggerEvent(
        sourceUnit,
        CONST_EVENT.broken,
        {
            triggerUnit = sourceUnit,
            targetUnit = u,
            odds = odds,
            damage = damage
        }
    )
    -- @触发被打断事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beBroken,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            odds = odds,
            damage = damage
        }
    )
end

--[[
    眩晕! 注意这个方法对中立被动无效
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.swim = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    --计算抵抗
    local oppose = hattr.get(u, "swim_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    local damageString = "眩晕"
    local damageStringColor = "4169E1"
    local swimTimer = hskill.get(u, "swimTimer")
    if (swimTimer ~= nil and htime.getRemainTime(swimTimer) > 0) then
        if (during <= htime.getRemainTime(swimTimer)) then
            return
        else
            htime.delTimer(swimTimer)
            hskill.set(u, "swimTimer", nil)
            cj.UnitRemoveAbility(u, hskill.BUFF_SWIM)
            damageString = "劲眩"
            damageStringColor = "64e3f2"
        end
    end
    local cu = hunit.create(
        {
            register = false,
            unitId = hskill.SKILL_TOKEN,
            whichPlayer = hplayer.player_passive,
            x = hunit.x(u),
            y = hunit.y(u)
        }
    )
    --判断during的时候是否小于0.5秒，使用眩晕0.05-0.5的技能，大于0.5使用无限眩晕法
    if (during < 0.05) then
        during = 0.05
    end
    his.set(u, "isSwim", true)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    if (during <= 0.5) then
        during = 0.05 * math.floor(during / 0.05) --必须是0.05的倍数
        cj.UnitAddAbility(cu, hskill.SKILL_BREAK[during])
        cj.SetUnitAbilityLevel(cu, hskill.SKILL_BREAK[during], 1)
        cj.IssueTargetOrder(cu, "thunderbolt", u)
        hunit.del(cu, 0.4)
    else
        --无限法
        cj.UnitAddAbility(cu, hskill.SKILL_SWIM_UNLIMIT)
        cj.SetUnitAbilityLevel(cu, hskill.SKILL_SWIM_UNLIMIT, 1)
        cj.IssueTargetOrder(cu, "thunderbolt", u)
        hunit.del(cu, 0.4)
        hskill.set(
            u,
            "swimTimer",
            htime.setTimeout(
                during,
                function(t)
                    htime.delTimer(t)
                    cj.UnitRemoveAbility(u, hskill.BUFF_SWIM)
                    his.set(u, "isSwim", false)
                end
            )
        )
    end
    -- @触发眩晕事件
    hevent.triggerEvent(
        sourceUnit,
        CONST_EVENT.swim,
        {
            triggerUnit = sourceUnit,
            targetUnit = u,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    -- @触发被眩晕事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beSwim,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageKind = damageKind,
                damageType = damageType,
                damageString = damageString,
                damageStringColor = damageStringColor
            }
        )
    end
end

--[[
    沉默
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.silent = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    --计算抵抗
    local oppose = hattr.get(u, "silent_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    local level = hskill.get(u, "silentLevel", 0) + 1
    if (level <= 1) then
        htextTag.style(htextTag.create2Unit(u, "沉默", 6.00, "ee82ee", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.create2Unit(u, math.floor(level) .. "重沉默", 6.00, "ee82ee", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    hskill.set(u, "silentLevel", level)
    if (table.includes(u, hRuntime.skill.silentUnits) == false) then
        table.insert(hRuntime.skill.silentUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "head", -1)
        hskill.set(u, "silentEffect", eff)
    end
    his.set(u, "isSilent", true)
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "沉默",
                damageKind = damageKind,
                damageType = damageType
            }
        )
    end
    -- @触发沉默事件
    hevent.triggerEvent(
        sourceUnit,
        CONST_EVENT.silent,
        {
            triggerUnit = sourceUnit,
            targetUnit = u,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    -- @触发被沉默事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beSilent,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    htime.setTimeout(
        during,
        function(t)
            htime.delTimer(t)
            hskill.set(u, "silentLevel", hskill.get(u, "silentLevel", 0) - 1)
            if (hskill.get(u, "silentLevel") <= 0) then
                heffect.del(hskill.get(u, "silentEffect"))
                if (table.includes(u, hRuntime.skill.silentUnits)) then
                    table.delete(u, hRuntime.skill.silentUnits)
                end
                his.set(u, "isSilent", false)
            end
        end
    )
end

--[[
    缴械
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.unarm = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    --计算抵抗
    local oppose = hattr.get(u, "unarm_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    local level = hskill.get(u, "unarmLevel", 0) + 1
    if (level <= 1) then
        htextTag.style(htextTag.create2Unit(u, "缴械", 6.00, "ffe4e1", 10, 1.00, 10.00), "scale", 0, 0.2)
    else
        htextTag.style(
            htextTag.create2Unit(u, math.floor(level) .. "重缴械", 6.00, "ffe4e1", 10, 1.00, 10.00),
            "scale",
            0,
            0.2
        )
    end
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    hskill.set(u, "unarmLevel", level)
    if (table.includes(u, hRuntime.skill.unarmUnits) == false) then
        table.insert(hRuntime.skill.unarmUnits, u)
        local eff = heffect.bindUnit("Abilities\\Spells\\Other\\Silence\\SilenceTarget.mdl", u, "weapon", -1)
        hskill.set(u, "unarmEffect", eff)
    end
    his.set(u, "isUnArm", true)
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "缴械",
                damageKind = damageKind,
                damageType = damageType
            }
        )
    end
    -- @触发缴械事件
    hevent.triggerEvent(
        sourceUnit,
        CONST_EVENT.unarm,
        {
            triggerUnit = sourceUnit,
            targetUnit = u,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    -- @触发被缴械事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beUnarm,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    htime.setTimeout(
        during,
        function(t)
            htime.delTimer(t)
            hskill.set(u, "unarmLevel", hskill.get(u, "unarmLevel", 0) - 1)
            if (hskill.get(u, "unarmLevel") <= 0) then
                heffect.del(hskill.get(u, "unarmEffect"))
                if (table.includes(u, hRuntime.skill.unarmUnits)) then
                    table.delete(u, hRuntime.skill.unarmUnits)
                end
                his.set(u, "isUnArm", false)
            end
        end
    )
end

--[[
    缚足
    options = {
        whichUnit = unit, --目标单位，必须
        during = 0, --持续时间，必须
        odds = 100, --几率，可选
        damage = 0, --伤害，可选
        sourceUnit = nil, --来源单位，可选
        effect = nil, --特效，可选
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.fetter = function(options)
    if (options.whichUnit == nil or options.during == nil or options.during <= 0) then
        return
    end
    local u = options.whichUnit
    local during = options.during
    local odds = options.odds or 100
    local damage = options.damage or 0
    local sourceUnit = options.sourceUnit or nil
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    --计算抵抗
    local oppose = hattr.get(u, "fetter_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        during = during * (1 - oppose * 0.01)
        damage = damage * (1 - oppose * 0.01)
    end
    htextTag.style(htextTag.create2Unit(u, "缚足", 6.00, "ffa500", 10, 1.00, 10.00), "scale", 0, 0.2)
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, u, "origin", during)
    end
    hattr.set(
        u,
        during,
        {
            move = "-522"
        }
    )
    if (damage > 0) then
        hskill.damage(
            {
                sourceUnit = sourceUnit,
                targetUnit = u,
                damage = damage,
                damageString = "缚足",
                damageKind = damageKind,
                damageType = damageType
            }
        )
    end
    -- @触发缚足事件
    hevent.triggerEvent(
        sourceUnit,
        CONST_EVENT.fetter,
        {
            triggerUnit = sourceUnit,
            targetUnit = u,
            odds = odds,
            damage = damage,
            during = during
        }
    )
    -- @触发被缚足事件
    hevent.triggerEvent(
        u,
        CONST_EVENT.beFetter,
        {
            triggerUnit = u,
            sourceUnit = sourceUnit,
            odds = odds,
            damage = damage,
            during = during
        }
    )
end

--[[
    爆破
    options = {
        damage = 0, --伤害（必须有，小于等于0直接无效）
        range = 1, --范围（可选）
        whichUnit = nil, --目标单位（挑选，单位时会自动选择与此单位同盟的单位）
        whichGroup = nil, --目标单位组（挑选，优先级更高）
        sourceUnit = nil, --伤害来源单位（可选）
        odds = 100, --几率（可选）
        effect = nil --目标位置特效（可选）
        effectSingle = nil --个体的特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.bomb = function(options)
    if (options.damage == nil or options.damage <= 0) then
        return
    end
    local odds = options.odds or 100
    local range = options.range or 1
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or {}
    local whichGroup
    if (options.whichGroup ~= nil) then
        whichGroup = options.whichGroup
    elseif (options.whichUnit ~= nil) then
        whichGroup = hgroup.createByUnit(
            options.whichUnit,
            range,
            function(filterUnit)
                local flag = true
                if (his.enemy(options.whichUnit, filterUnit)) then
                    flag = false
                end
                if (his.death(filterUnit)) then
                    flag = false
                end
                if (his.building(filterUnit)) then
                    flag = false
                end
                return flag
            end
        )
    else
        print_err("lost bomb target")
        return
    end
    hgroup.loop(
        whichGroup,
        function(eu)
            --计算抵抗
            local oppose = hattr.get(eu, "bomb_oppose")
            local tempOdds = odds - oppose --(%)
            local damage = options.damage
            if (tempOdds <= 0) then
                return
            else
                if (math.random(1, 1000) > tempOdds * 10) then
                    return
                end
                damage = damage * (1 - oppose * 0.01)
            end
            hskill.damage(
                {
                    sourceUnit = options.sourceUnit,
                    targetUnit = eu,
                    damage = damage,
                    damageKind = damageKind,
                    damageType = damageType,
                    damageString = "爆破",
                    damageStringColor = "FF6347"
                }
            )
            -- @触发爆破事件
            hevent.triggerEvent(
                options.sourceUnit,
                CONST_EVENT.bomb,
                {
                    triggerUnit = options.sourceUnit,
                    targetUnit = eu,
                    odds = odds,
                    damage = options.damage,
                    range = range
                }
            )
            -- @触发被爆破事件
            hevent.triggerEvent(
                eu,
                CONST_EVENT.beBomb,
                {
                    triggerUnit = eu,
                    sourceUnit = options.sourceUnit,
                    odds = odds,
                    damage = options.damage,
                    range = range
                }
            )
        end,
        true
    )
end

--[[
    闪电链
    options = {
        damage = 0, --伤害（必须有，小于等于0直接无效）
        whichUnit = [unit], --第一个的目标单位（必须有）
        prevUnit = [unit], --上一个的目标单位（必须有，用于构建两点间闪电特效）
        sourceUnit = nil, --伤害来源单位（可选）
        lightningType = [hlightning.type], -- 闪电效果类型（可选 详情查看 hlightning.type
        odds = 100, --几率（可选）
        qty = 1, --传递的最大单位数（可选，默认1）
        change = 0, --增减率（可选，默认不增不减为0，范围建议[-1.00，1.00]）
        range = 300, --寻找下一目标的作用范围（可选，默认300）
        isRepeat = false, --是否允许同一个单位重复打击（临近2次不会同一个）
        effect = nil, --目标位置特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
        damageType = {"thunder"}, --伤害的类型,注意是table（可选）
        index = 1,--隐藏的参数，用于暗地里记录是第几个被电到的单位
        repeatGroup = [group],--隐藏的参数，用于暗地里记录单位是否被电过
    }
]]
hskill.lightningChain = function(options)
    if (options.damage == nil or options.damage <= 0) then
        print_err("lightningChain -damage")
        return
    end
    if (options.whichUnit == nil) then
        print_err("lightningChain -whichUnit")
        return
    end
    local odds = options.odds or 100
    local damage = options.damage
    --计算抵抗
    local oppose = hattr.get(options.whichUnit, "lightning_chain_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        damage = damage * (1 - oppose * 0.01)
    end
    local whichUnit = options.whichUnit
    local prevUnit = options.prevUnit
    local lightningType = options.lightningType or hlightning.type.shan_dian_lian_ci
    local change = options.change or 0
    local range = options.range or 500
    local isRepeat = options.isRepeat or false
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or { "thunder" }
    options.qty = options.qty or 1
    options.qty = options.qty - 1
    if (options.qty < 0) then
        options.qty = 0
    end
    if (options.index == nil) then
        options.index = 1
    else
        options.index = options.index + 1
    end
    hlightning.unit2unit(lightningType, prevUnit, whichUnit, 0.25)
    if (options.effect ~= nil) then
        heffect.bindUnit(options.effect, whichUnit, "origin", 0.5)
    end
    hskill.damage(
        {
            sourceUnit = options.sourceUnit,
            targetUnit = whichUnit,
            damage = damage,
            damageKind = damageKind,
            damageType = damageType,
            damageString = "电链",
            damageStringColor = "87cefa"
        }
    )
    -- @触发闪电链成功事件
    hevent.triggerEvent(
        options.sourceUnit,
        CONST_EVENT.lightningChain,
        {
            triggerUnit = options.sourceUnit,
            targetUnit = whichUnit,
            odds = odds,
            damage = damage,
            range = range,
            index = options.index
        }
    )
    -- @触发被闪电链事件
    hevent.triggerEvent(
        whichUnit,
        CONST_EVENT.beLightningChain,
        {
            triggerUnit = whichUnit,
            sourceUnit = options.sourceUnit,
            odds = odds,
            damage = damage,
            range = range,
            index = options.index
        }
    )
    if (options.qty > 0) then
        if (isRepeat ~= true) then
            if (options.repeatGroup == nil) then
                options.repeatGroup = {}
            end
            hgroup.addUnit(options.repeatGroup, whichUnit)
        end
        local g = hgroup.createByUnit(
            whichUnit,
            range,
            function(filterUnit)
                local flag = true
                if (his.death(filterUnit)) then
                    flag = false
                end
                if (his.enemy(filterUnit, whichUnit)) then
                    flag = false
                end
                if (his.building(filterUnit)) then
                    flag = false
                end
                if (his.unit(whichUnit, filterUnit)) then
                    flag = false
                end
                if (isRepeat ~= true and hgroup.includes(options.repeatGroup, filterUnit)) then
                    flag = false
                end
                return flag
            end
        )
        if (hgroup.isEmpty(g)) then
            return
        end
        options.whichUnit = hgroup.getClosest(g, hunit.x(whichUnit), hunit.y(whichUnit))
        options.damage = options.damage * (1 + change)
        options.prevUnit = whichUnit
        options.odds = 9999 --闪电链只要开始能延续下去就是100%几率了
        hgroup.clear(g, true, false)
        if (options.damage > 0) then
            htime.setTimeout(
                0.35,
                function(t)
                    htime.delTimer(t)
                    hskill.lightningChain(options)
                end
            )
        end
    else
        if (options.repeatGroup ~= nil) then
            options.repeatGroup = nil
        end
    end
end

--[[
    击飞
    options = {
        damage = 0, --伤害（必须有，但是这里可以等于0）
        whichUnit = [unit], --目标单位（必须有）
        sourceUnit = [unit], --伤害来源单位（可选）
        odds = 100, --几率（可选,默认100）
        distance = 0, --击退距离，可选，默认0
        high = 100, --击飞高度，可选，默认100
        during = 0.5, --击飞过程持续时间，可选，默认0.5秒
        effect = nil, --特效（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.crackFly = function(options)
    if (options.damage == nil or options.damage < 0) then
        return
    end
    if (options.whichUnit == nil) then
        return
    end
    local odds = options.odds or 100
    local damage = options.damage or 0
    --计算抵抗
    local oppose = hattr.get(options.whichUnit, "crack_fly_oppose")
    odds = odds - oppose --(%)
    if (odds <= 0) then
        return
    else
        if (math.random(1, 1000) > odds * 10) then
            return
        end
        if (damage > 0) then
            damage = damage * (1 - oppose * 0.01)
        end
    end
    local distance = options.distance or 0
    local high = options.high or 100
    local during = options.during or 0.5
    if (during < 0.5) then
        during = 0.5
    end
    --不二次击飞
    if (his.get(options.whichUnit, "isCrackFly") == true) then
        return
    end
    his.set(options.whichUnit, "isCrackFly", true)
    --镜头放大模式下，距离缩小一半
    if (hcamera.getModel(hunit.getOwner(options.whichUnit)) == "zoomin") then
        distance = distance * 0.5
        high = high * 0.5
    end
    local tempObj = {
        odds = 99999,
        whichUnit = options.whichUnit,
        during = during
    }
    hskill.unarm(tempObj)
    hskill.silent(tempObj)
    hattr.set(
        options.whichUnit,
        during,
        {
            move = "-9999"
        }
    )
    if (type(options.effect) == "string" and string.len(options.effect) > 0) then
        heffect.bindUnit(options.effect, options.whichUnit, "origin", during)
    end
    hunit.setCanFly(options.whichUnit)
    cj.SetUnitPathing(options.whichUnit, false)
    local originHigh = cj.GetUnitFlyHeight(options.whichUnit)
    local originFacing = hunit.getFacing(options.whichUnit)
    local originDeg
    if (options.sourceUnit ~= nil) then
        originDeg = math.getDegBetweenUnit(options.sourceUnit, options.whichUnit)
    else
        originDeg = math.random(0, 360)
    end
    local cost = 0
    -- @触发击飞事件
    hevent.triggerEvent(
        options.sourceUnit,
        CONST_EVENT.crackFly,
        {
            triggerUnit = options.sourceUnit,
            targetUnit = options.whichUnit,
            odds = odds,
            damage = damage,
            high = high,
            distance = distance
        }
    )
    -- @触发被击飞事件
    hevent.triggerEvent(
        options.whichUnit,
        CONST_EVENT.beCrackFly,
        {
            triggerUnit = options.whichUnit,
            sourceUnit = options.sourceUnit,
            odds = odds,
            damage = damage,
            high = high,
            distance = distance
        }
    )
    htime.setInterval(
        0.05,
        function(t)
            local dist = 0
            local z = 0
            local timerSetTime = htime.getSetTime(t)
            if (cost > during) then
                if (damage > 0) then
                    hskill.damage(
                        {
                            sourceUnit = options.sourceUnit,
                            targetUnit = options.whichUnit,
                            effect = options.effect,
                            damage = damage,
                            damageKind = options.damageKind,
                            damageType = options.damageType,
                            damageString = "击飞",
                            damageStringColor = "808000"
                        }
                    )
                end
                cj.SetUnitFlyHeight(options.whichUnit, originHigh, 10000)
                cj.SetUnitPathing(options.whichUnit, true)
                his.set(options.whichUnit, "isCrackFly", false)
                -- 默认是地面，创建沙尘
                local tempEff = "Objects\\Spawnmodels\\Undead\\ImpaleTargetDust\\ImpaleTargetDust.mdl"
                if (his.water(options.whichUnit) == true) then
                    -- 如果是水面，创建水花
                    tempEff = "Abilities\\Spells\\Other\\CrushingWave\\CrushingWaveDamage.mdl"
                end
                heffect.toUnit(tempEff, options.whichUnit, 0)
                htime.delTimer(t)
                return
            end
            cost = cost + timerSetTime
            if (cost < during * 0.35) then
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.35 / timerSetTime)
                if (dist > 0) then
                    local pxy = math.polarProjection(
                        hunit.x(options.whichUnit),
                        hunit.y(options.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(options.whichUnit, originFacing)
                    if (his.borderMap(pxy.x, pxy.y) == false) then
                        hunit.portal(options.whichUnit, pxy.x, pxy.y)
                    end
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(options.whichUnit, cj.GetUnitFlyHeight(options.whichUnit) + z, z / timerSetTime)
                end
            else
                dist = distance / (during * 0.5 / timerSetTime)
                z = high / (during * 0.65 / timerSetTime)
                if (dist > 0) then
                    local pxy = math.polarProjection(
                        hunit.x(options.whichUnit),
                        hunit.y(options.whichUnit),
                        dist,
                        originDeg
                    )
                    cj.SetUnitFacing(options.whichUnit, originFacing)
                    if (his.borderMap(pxy.x, pxy.y) == false) then
                        hunit.portal(options.whichUnit, pxy.x, pxy.y)
                    end
                end
                if (z > 0) then
                    cj.SetUnitFlyHeight(options.whichUnit, cj.GetUnitFlyHeight(options.whichUnit) - z, z / timerSetTime)
                end
            end
        end
    )
end

--[[
    范围眩晕
    options = {
        range = 0, --眩晕范围（必须有）
        during = 0, --眩晕持续时间（必须有）
        odds = 100, --对每个单位的独立几率（可选,默认100）
        effect = "", --特效（可选）
        whichUnit = [unit], --中心单位（可选）
        whichLoc = [location], --目标点（可选）
        x = [point], --目标坐标X（可选）
        y = [point], --目标坐标Y（可选）
        filter = [function], --必须有
        damage = 0, --伤害（可选，但是这里可以等于0）
        sourceUnit = [unit], --伤害来源单位（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.rangeSwim = function(options)
    local range = options.range or 0
    local during = options.during or 0
    local damage = options.damage or 0
    if (range <= 0 or during <= 0) then
        print_err("hskill.rangeSwim:-range -during")
        return
    end
    local odds = options.odds or 100
    local effect = options.effect or "Abilities\\Spells\\Orc\\WarStomp\\WarStompCaster.mdl"
    local x, y
    if (options.x ~= nil or options.y ~= nil) then
        x = options.x
        y = options.y
    elseif (options.whichUnit ~= nil) then
        x = hunit.x(options.whichUnit)
        y = hunit.y(options.whichUnit)
    elseif (options.whichLoc ~= nil) then
        x = cj.GetLocatonX(options.whichLoc)
        y = cj.GetLocatonY(options.whichLoc)
    end
    if (x == nil or y == nil) then
        print_err("hskill.rangeSwim:-x -y")
        return
    end
    local filter = options.filter
    if (type(filter) ~= "function") then
        print_err("filter must be function")
        return
    end
    heffect.toXY(effect, x, y, 0)
    local g = hgroup.createByXY(x, y, range, filter)
    if (g == nil) then
        print_err("rangeSwim has not target")
        return
    end
    if (hgroup.count(g) <= 0) then
        return
    end
    hgroup.loop(
        g,
        function(eu)
            hskill.swim(
                {
                    odds = odds,
                    whichUnit = eu,
                    during = during,
                    damage = damage,
                    sourceUnit = options.sourceUnit,
                    damageKind = options.damageKind,
                    damageType = options.damageType
                }
            )
        end,
        true
    )
end

--[[
    剑刃风暴
    options = {
        range = 0, --范围（必须有）
        frequency = 0, --伤害频率（必须有）
        during = 0, --持续时间（必须有）
        filter = [function], --必须有
        damage = 0, --每次伤害（必须有）
        sourceUnit = [unit], --伤害来源单位（必须有）
        effect = "", --特效（可选）
        effectSingle = "", --单体砍中特效（可选）
        animation = "spin", --单位附加动作，常见的spin（可选）
        damageKind = CONST_DAMAGE_KIND.skill --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
    }
]]
hskill.whirlwind = function(options)
    local range = options.range or 0
    local frequency = options.frequency or 0
    local during = options.during or 0
    local damage = options.damage or 0
    if (range <= 0 or during <= 0 or frequency <= 0) then
        print_err("hskill.whirlwind:-range -during -frequency")
        return
    end
    if (during < frequency) then
        print_err("hskill.whirlwind:-during < frequency")
        return
    end
    if (damage < 0 or options.sourceUnit == nil) then
        print_err("hskill.whirlwind:-damage -sourceUnit")
        return
    end
    if (options.filter == nil) then
        print_err("hskill.whirlwind:-filter")
        return
    end
    local filter = options.filter
    if (type(filter) ~= "function") then
        print_err("filter must be function")
        return
    end
    --不二次
    if (his.get(options.sourceUnit, "isWhirlwind") == true) then
        return
    end
    his.set(options.sourceUnit, "isWhirlwind", true)
    if (options.effect ~= nil) then
        heffect.bindUnit(options.effect, options.sourceUnit, "origin", during)
    end
    if (options.animation) then
        cj.AddUnitAnimationProperties(options.sourceUnit, options.animation, true)
    end
    local time = 0
    htime.setInterval(
        frequency,
        function(t)
            time = time + frequency
            if (time > during) then
                htime.delTimer(t)
                if (options.animation) then
                    cj.AddUnitAnimationProperties(options.sourceUnit, options.animation, false)
                end
                his.set(options.sourceUnit, "isWhirlwind", false)
                return
            end
            if (options.animation) then
                hunit.animate(options.sourceUnit, options.animation)
            end
            local g = hgroup.createByUnit(options.sourceUnit, range, filter)
            if (g == nil) then
                return
            end
            if (hgroup.count(g) <= 0) then
                return
            end
            hgroup.loop(
                g,
                function(eu)
                    hskill.damage(
                        {
                            sourceUnit = options.sourceUnit,
                            targetUnit = eu,
                            effect = options.effectSingle,
                            damage = damage,
                            damageKind = options.damageKind,
                            damageType = options.damageType
                        }
                    )
                end,
                true
            )
        end
    )
end

--[[
    剃(前冲型直线攻击)
    options = {
        arrowUnit = nil, -- 前冲的单位（有就是自身冲击，没有就是马甲特效冲击）
        sourceUnit, --伤害来源（必须有！不管有没有伤害）
        targetUnit, --冲击的目标单位（可选的，有单位目标，那么冲击到单位就结束）
        x, --冲击的x坐标（可选的，对点冲击，与某目标无关）
        y, --冲击的y坐标（可选的，对点冲击，与某目标无关）
        speed = 10, --冲击的速度（可选的，默认10，0.02秒的移动距离,大概1秒500px)
        acceleration = 0, --冲击加速度（可选的，每个周期都会增加0.02秒一次)
        filter = [function], --必须有
        tokenArrow = nil, --前冲的特效（x,y时认为必须！自身冲击就是bind，否则为马甲本身，如冲击波的波）
        tokenArrowScale = 1.00, --前冲的特效作为马甲冲击时的模型缩放
        tokenArrowOpacity = 1.00, --前冲的特效作为马甲冲击时的模型透明度[0-1]
        tokenArrowHeight = 0.00, --前冲的特效作为马甲冲击时的离地高度
        effectMovement = nil, --移动过程，每个间距的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
        effectEnd = nil, --到达最后位置时的特效（可选的，采用的0秒删除法，请使用explode类型的特效）
        damageMovement = 0, --移动过程中的伤害（可选的，默认为0）
        damageMovementRange = 0, --移动过程中的伤害（可选的，默认为0，易知0范围是无效的所以有伤害也无法体现）
        damageMovementRepeat = false, --移动过程中伤害是否可以重复造成（可选的，默认为不能）
        damageMovementDrag = false, --移动过程是否拖拽敌人（可选的，默认为不能）
        damageEnd = 0, --移动结束时对目标的伤害（可选的，默认为0）
        damageEndRange = 0, --移动结束时对目标的伤害范围（可选的，默认为0，此处0范围是有效的，会只对targetUnit生效，除非unit不存在）
        damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
        damageEffect = nil, --伤害特效（可选）
        oneHitOnly = false, --是否打击一次就立刻失效（类似格挡，这个一次和只攻击一个单位不是一回事）
        onEnding = [function], --结束时触发的动作
        extraInfluence = [function] --对选中的敌人的额外影响，会回调该敌人单位，可以对其做出自定义行为
    }
]]
hskill.leap = function(options)
    if (options.sourceUnit == nil) then
        print_err("leap: -sourceUnit")
        return
    end
    if (type(options.filter) ~= "function") then
        print_err("leap: -filter")
        return
    end
    if (options.arrowUnit == nil and options.tokenArrow == nil) then
        print_err("leap: -not arrow")
    end
    if (options.targetUnit == nil and options.x == nil and options.y == nil) then
        print_err("leap: -target")
        return
    end
    local frequency = 0.02
    local acceleration = options.acceleration or 0
    local speed = options.speed or 10
    if (speed > 150) then
        speed = 150 -- 最大速度
    elseif (speed <= 1) then
        speed = 1 -- 最小速度
    end
    local filter = options.filter
    local sourceUnit = options.sourceUnit
    local prevUnit = options.prevUnit or sourceUnit
    local damageMovement = options.damageMovement or 0
    local damageMovementRange = options.damageMovementRange or 0
    local damageMovementRepeat = options.damageMovementRepeat or false
    local damageMovementDrag = options.damageMovementDrag or false
    local damageEnd = options.damageEnd or 0
    local damageEndRange = options.damageEndRange or 0
    local extraInfluence = options.extraInfluence
    local arrowUnit = options.arrowUnit
    local tokenArrow = options.tokenArrow
    local tokenArrowScale = options.tokenArrowScale or 1.00
    local tokenArrowOpacity = options.tokenArrowOpacity or 1.00
    local tokenArrowHeight = options.tokenArrowHeight or 0
    local oneHitOnly = options.oneHitOnly or false
    --这里要注意：targetUnit比xy优先
    local leapType
    local initFacing = 0
    if (options.arrowUnit ~= nil) then
        leapType = "unit"
    else
        leapType = "point"
    end
    if (options.targetUnit ~= nil) then
        initFacing = math.getDegBetweenUnit(prevUnit, options.targetUnit)
    elseif (options.x ~= nil and options.y ~= nil) then
        initFacing = math.getDegBetweenXY(hunit.x(prevUnit), hunit.y(prevUnit), options.x, options.y)
    else
        print_err("leapType: -unknow")
        return
    end
    local repeatGroup
    if (damageMovement > 0 and damageMovementRepeat ~= true) then
        repeatGroup = {}
    end
    if (arrowUnit == nil) then
        local cxy = math.polarProjection(hunit.x(prevUnit), hunit.y(prevUnit), 100, initFacing)
        arrowUnit = hunit.create(
            {
                register = false,
                whichPlayer = hunit.getOwner(sourceUnit),
                unitId = hskill.SKILL_LEAP,
                x = cxy.x,
                y = cxy.y,
                facing = initFacing,
                modelScale = tokenArrowScale,
                opacity = tokenArrowOpacity,
                qty = 1
            }
        )
        if (tokenArrowHeight > 0) then
            hunit.setFlyHeight(arrowUnit, tokenArrowHeight, 9999)
        end
    end
    cj.SetUnitFacing(arrowUnit, firstFacing)
    --绑定一个无限的effect
    local tempEffectArrow
    if (tokenArrow ~= nil) then
        tempEffectArrow = heffect.bindUnit(tokenArrow, arrowUnit, "origin", -1)
    end
    --无敌加无路径
    cj.SetUnitPathing(arrowUnit, false)
    if (leapType == "unit") then
        hunit.setInvulnerable(arrowUnit, true)
        cj.SetUnitVertexColor(arrowUnit, 255, 255, 255, 255 * tokenArrowOpacity)
    end
    --开始冲鸭
    htime.setInterval(
        frequency,
        function(t)
            local ax = hunit.x(arrowUnit)
            local ay = hunit.y(arrowUnit)
            if (his.death(sourceUnit)) then
                htime.delTimer(t)
                if (tempEffectArrow ~= nil) then
                    heffect.del(tempEffectArrow)
                end
                if (repeatGroup ~= nil) then
                    repeatGroup = nil
                end
                if (leapType == "unit") then
                    hunit.setInvulnerable(arrowUnit, false)
                    cj.SetUnitPathing(arrowUnit, true)
                    cj.SetUnitVertexColor(arrowUnit, 255, 255, 255, 255)
                else
                    hunit.kill(arrowUnit, 0)
                end
                if (type(options.onEnding) == "function") then
                    options.onEnding(ax, ay)
                end
                return
            end
            local tx = 0
            local ty = 0
            if (options.targetUnit ~= nil) then
                tx = hunit.x(options.targetUnit)
                ty = hunit.y(options.targetUnit)
            else
                tx = options.x
                ty = options.y
            end
            local fac = math.getDegBetweenXY(ax, ay, tx, ty)
            local txy = math.polarProjection(ax, ay, speed, fac)
            if (acceleration ~= 0) then
                speed = speed + acceleration
            end
            if (his.borderMap(txy.x, txy.y) == false) then
                hunit.portal(arrowUnit, txy.x, txy.y)
            else
                speed = 0
            end
            cj.SetUnitFacing(arrowUnit, fac)
            if (options.effectMovement ~= nil) then
                heffect.toXY(options.effectMovement, txy.x, txy.y, 0)
            end
            if (damageMovementRange > 0) then
                local g = hgroup.createByUnit(
                    arrowUnit,
                    damageMovementRange,
                    function(filterUnit)
                        local flag = filter(filterUnit)
                        if (damageMovementRepeat ~= true and hgroup.includes(repeatGroup, filterUnit)) then
                            flag = false
                        end
                        return flag
                    end
                )
                if (hgroup.count(g) > 0) then
                    if (oneHitOnly == true) then
                        hunit.kill(arrowUnit, 0)
                    end
                    hgroup.loop(
                        g,
                        function(eu)
                            if (damageMovementRepeat ~= true and repeatGroup ~= nil) then
                                hgroup.addUnit(repeatGroup, eu)
                            end
                            if (damageMovement > 0) then
                                hskill.damage(
                                    {
                                        sourceUnit = sourceUnit,
                                        targetUnit = eu,
                                        damage = damageMovement,
                                        damageKind = options.damageKind,
                                        damageType = options.damageType,
                                        effect = options.damageEffect
                                    }
                                )
                            end
                            if (damageMovementDrag == true) then
                                hunit.portal(eu, txy.x, txy.y)
                            end
                            if (type(extraInfluence) == "function") then
                                extraInfluence(eu)
                            end
                        end,
                        true
                    )
                end
            end
            local distance = math.getDistanceBetweenXY(hunit.x(arrowUnit), hunit.y(arrowUnit), tx, ty)
            if (distance <= speed or speed <= 0 or his.death(arrowUnit) == true) then
                htime.delTimer(t)
                if (tempEffectArrow ~= nil) then
                    heffect.del(tempEffectArrow)
                end
                if (repeatGroup ~= nil) then
                    repeatGroup = nil
                end
                if (options.effectEnd ~= nil) then
                    heffect.toXY(options.effectEnd, txy.x, txy.y, 0)
                end
                if (damageEndRange == 0 and options.targetUnit ~= nil) then
                    if (damageEnd > 0) then
                        hskill.damage(
                            {
                                sourceUnit = options.sourceUnit,
                                targetUnit = options.targetUnit,
                                damage = damageEnd,
                                damageKind = options.damageKind,
                                damageType = options.damageType,
                                effect = options.damageEffect
                            }
                        )
                    end
                    if (type(extraInfluence) == "function") then
                        extraInfluence(options.targetUnit)
                    end
                elseif (damageEndRange > 0) then
                    local g = hgroup.createByUnit(arrowUnit, damageEndRange, filter)
                    hgroup.loop(
                        g,
                        function(eu)
                            if (damageEnd > 0) then
                                hskill.damage(
                                    {
                                        sourceUnit = options.sourceUnit,
                                        targetUnit = eu,
                                        damage = damageEnd,
                                        damageKind = options.damageKind,
                                        damageType = options.damageType,
                                        effect = options.damageEffect
                                    }
                                )
                            end
                            if (type(extraInfluence) == "function") then
                                extraInfluence(eu)
                            end
                        end,
                        true
                    )
                end
                if (leapType == "unit") then
                    hunit.setInvulnerable(arrowUnit, false)
                    cj.SetUnitPathing(arrowUnit, true)
                    cj.SetUnitVertexColor(arrowUnit, 255, 255, 255, 255)
                    hunit.portal(arrowUnit, txy.x, txy.y)
                else
                    hunit.kill(arrowUnit, 0)
                end
                if (type(options.onEnding) == "function") then
                    options.onEnding(txy.x, txy.y)
                end
            end
        end
    )
end

--[[
    剃[爪子状]，参数与leap一致，额外有两个参数，设置角度
    * 需要注意一点的是，pow会自动将对单位跟踪的效果转为对坐标系(不建议使用unit)
    options = {
        qty = 0, --数量
        deg = 15, --角度
        hskill.leap.options
    }
]]
hskill.leapPow = function(options)
    local qty = options.qty or 0
    local deg = options.deg or 15
    if (qty <= 1) then
        print_err("leapPow: -qty")
        return
    end
    if (options.sourceUnit == nil) then
        print_err("leapPow: -sourceUnit")
        return
    end
    if (type(options.filter) ~= "function") then
        print_err("leapPow: -filter")
        return
    end
    if (options.tokenArrow == nil) then
        print_err("leapPow: -not arrow")
    end
    if (options.targetUnit == nil and options.x == nil and options.y == nil) then
        print_err("leapPow: -target")
        return
    end
    local x, y
    if (options.targetUnit ~= nil) then
        x = hunit.x(options.targetUnit)
        y = hunit.y(options.targetUnit)
    else
        x = options.x
        y = options.y
    end
    local sx = hunit.x(options.sourceUnit)
    local sy = hunit.y(options.sourceUnit)
    local facing = math.getDegBetweenXY(sx, sy, x, y)
    local distance = math.getDistanceBetweenXY(sx, sy, x, y)
    local firstDeg = facing + (deg * (qty - 1) * 0.5)
    for i = 1, qty, 1 do
        local angle = firstDeg - deg * (i - 1)
        local txy = math.polarProjection(sx, sy, distance, angle)
        hskill.leap(
            {
                arrowUnit = options.arrowUnit,
                sourceUnit = options.sourceUnit,
                targetUnit = nil,
                x = txy.x,
                y = txy.y,
                speed = options.speed,
                acceleration = options.acceleration,
                filter = options.filter,
                tokenArrow = options.tokenArrow,
                tokenArrowScale = options.tokenArrowScale,
                tokenArrowOpacity = options.tokenArrowOpacity,
                tokenArrowHeight = options.tokenArrowHeight,
                effectMovement = options.effectMovement,
                effectEnd = options.effectEnd,
                damageMovement = options.damageMovement,
                damageMovementRange = options.damageMovementRange,
                damageMovementRepeat = options.damageMovementRepeat,
                damageMovementDrag = options.damageMovementDrag,
                damageEnd = options.damageEnd,
                damageEndRange = options.damageEndRange,
                damageKind = options.damageKind,
                damageType = options.damageType,
                damageEffect = options.damageEffect,
                oneHitOnly = options.oneHitOnly,
                onEnding = options.onEnding,
                extraInfluence = options.extraInfluence
            }
        )
    end
end

--[[
    剃[选区型]，参数与leap一致，额外有两个参数，设置范围
    * 需要注意一点的是，pow会自动将对单位跟踪的效果转为对坐标系(不建议使用unit)
    options = {
        targetRange = 0, --以目标点为中心的选区范围
        hskill.leap.options
    }
]]
hskill.leapRange = function(options)
    local targetRange = options.targetRange or 0
    if (targetRange <= 0) then
        print_err("leapRange: -targetRange")
        return
    end
    if (options.sourceUnit == nil) then
        print_err("leapRange: -sourceUnit")
        return
    end
    if (type(options.filter) ~= "function") then
        print_err("leapRange: -filter")
        return
    end
    if (options.targetUnit == nil and options.x == nil and options.y == nil) then
        print_err("leapRange: -target")
        return
    end
    local filter = options.filter
    local x, y
    if (options.targetUnit ~= nil) then
        x = hunit.x(options.targetUnit)
        y = hunit.y(options.targetUnit)
        options.x = nil
        options.y = nil
    else
        x = options.x
        y = options.y
    end
    local g = hgroup.createByXY(x, y, targetRange, filter)
    hgroup.loop(
        g,
        function(eu)
            local tmp = {
                arrowUnit = options.arrowUnit,
                sourceUnit = options.sourceUnit,
                speed = options.speed,
                acceleration = options.acceleration,
                filter = options.filter,
                tokenArrow = options.tokenArrow,
                tokenArrowScale = options.tokenArrowScale,
                tokenArrowOpacity = options.tokenArrowOpacity,
                tokenArrowHeight = options.tokenArrowHeight,
                effectMovement = options.effectMovement,
                effectEnd = options.effectEnd,
                damageMovement = options.damageMovement,
                damageMovementRange = options.damageMovementRange,
                damageMovementRepeat = options.damageMovementRepeat,
                damageMovementDrag = options.damageMovementDrag,
                damageEnd = options.damageEnd,
                damageEndRange = options.damageEndRange,
                damageKind = options.damageKind,
                damageType = options.damageType,
                damageEffect = options.damageEffect,
                oneHitOnly = options.oneHitOnly,
                onEnding = options.onEnding,
                extraInfluence = options.extraInfluence
            }
            if (options.targetUnit ~= nil) then
                tmp.targetUnit = eu
            else
                tmp.x = hunit.x(eu)
                tmp.y = hunit.y(eu)
            end
            hskill.leap(tmp)
        end,
        true
    )
end

--[[
    反射弹跳
    options = {
        qty = 1, --（跳跃次数，默认1）
        range = 0, --（选目标范围，默认0无效）
        hskill.leap.options
    }
]]
hskill.leapReflex = function(options)
    local qty = options.qty or 1
    local range = options.range or 0
    if (range <= 0) then
        print_err("reflex: -range")
        return
    end
    if (options.sourceUnit == nil) then
        print_err("reflex: -sourceUnit")
        return
    end
    if (type(options.filter) ~= "function") then
        print_err("reflex: -filter")
        return
    end
    if (options.arrowUnit == nil and options.tokenArrow == nil) then
        print_err("reflex: -not arrow")
    end
    if (options.targetUnit == nil) then
        print_err("reflex: -target")
        return
    end
    options.x = nil
    options.y = nil
    options.onEnding = function(x, y)
        qty = qty - 1
        if (qty >= 1) then
            local g = hgroup.createByXY(x, y, range, options.filter)
            local closer = hgroup.getClosest(g, x, y)
            if (closer ~= nil) then
                options.prevUnit = options.targetUnit
                options.targetUnit = closer
                hskill.leap(options)
            end
        end
    end
    hskill.leap(options)
end

--[[
    矩形打击
    options = {
        damage = 0, --伤害（必须有，默认0无效）
        sourceUnit, --伤害来源（必须有！不管有没有伤害）
        x, --初始的x坐标（必须有，对点冲击，从该处开始打击）
        y, --初始的y坐标（必须有，对点冲击，从该处开始打击）
        deg, --方向（必须有）
        range = 0, --打击范围（必须有，默认为0无效）
        distance = 0, --打击距离（必须有，默认为0无效）
        frequency = 0, --打击频率（必须有，默认0瞬间打击全部形状）
        filter = [function], --必须有
        effect = nil, --打击特效
        effectScale = 1.30, --打击特效缩放
        effectOffset = 0, --打击特效偏移量（distance+offset才是展示特效距离）
        damageKind = CONST_DAMAGE_KIND.skill, --伤害的种类（可选）
        damageType = {} --伤害的类型,注意是table（可选）
        damageEffect = nil, --伤害特效（可选）
        oneHitOnly = true, --是否每个敌人只打击一次（可选,默认true）
        extraInfluence = [function] --对击中的敌人的额外影响，会回调该敌人单位，可以对其做出自定义行为
    }
]]
hskill.rectangleStrike = function(options)
    if (options.sourceUnit == nil) then
        print_err("rectangleStrike: -sourceUnit")
        return
    end
    if (options.x == nil or options.y == nil) then
        print_err("rectangleStrike: -xy")
        return
    end
    if (options.deg == nil) then
        print_err("rectangleStrike: -deg")
        return
    end
    if (options.filter == nil) then
        print_err("rectangleStrike: -filter")
        return
    end
    local damage = options.damage or 0
    local range = options.range or 0
    local distance = options.distance or 0
    if (damage <= 0 or range <= 0 or distance <= 0) then
        print_err("rectangleStrike: -data")
        return
    end
    local frequency = options.frequency or 0
    local damageKind = options.damageKind or CONST_DAMAGE_KIND.skill
    local damageType = options.damageType or { CONST_DAMAGE_TYPE.common }
    local oneHitOnly = options.oneHitOnly
    local effectScale = options.effectScale or 1.30
    local effectOffset = options.effectOffset or 0
    if (oneHitOnly == nil) then
        oneHitOnly = true
    end
    if (frequency <= 0) then
        local i = 0
        local tg = {}
        while (true) do
            i = i + 1
            local d = i * range * 0.33
            if (d >= distance) then
                break
            end
            local txy = math.polarProjection(options.x, options.y, d, options.deg)
            if (options.effect ~= nil and d - effectOffset < distance) then
                local effUnitDur = 0.6
                local effUnit = hunit.create(
                    {
                        register = false,
                        whichPlayer = hplayer.player_passive,
                        unitId = hskill.SKILL_LEAP,
                        x = txy.x,
                        y = txy.y,
                        facing = options.deg,
                        modelScale = effectScale,
                        opacity = 1.00,
                        qty = 1,
                        during = effUnitDur
                    }
                )
                heffect.bindUnit(options.effect, effUnit, "origin", effUnitDur)
            end
            hgroup.loop(
                hgroup.createByXY(txy.x, txy.y, range, options.filter),
                function(eu)
                    if (hgroup.includes(tg, eu) == false) then
                        hgroup.addUnit(tg, eu)
                    end
                end,
                true
            )
        end
        if (hgroup.count(tg) > 0) then
            hskill.damageGroup(
                {
                    frequency = 0,
                    times = 1,
                    effect = options.damageEffect,
                    whichGroup = tg,
                    damage = damage,
                    sourceUnit = options.sourceUnit,
                    damageKind = damageKind,
                    damageType = damageType,
                    extraInfluence = options.extraInfluence
                }
            )
        end
        tg = nil
    else
        local i = 0
        htime.setInterval(
            frequency,
            function(t)
                i = i + 1
                local d = i * range * 0.5
                if (d >= distance) then
                    htime.delTimer(t)
                    return
                end
                local txy = math.polarProjection(options.x, options.y, d, options.deg)
                if (options.effect ~= nil and d - effectOffset < distance) then
                    local effUnitDur = 0.6
                    local effUnit = hunit.create(
                        {
                            register = false,
                            whichPlayer = hplayer.player_passive,
                            unitId = hskill.SKILL_LEAP,
                            x = txy.x,
                            y = txy.y,
                            facing = options.deg,
                            modelScale = effectScale,
                            opacity = 1.00,
                            qty = 1,
                            during = effUnitDur
                        }
                    )
                    heffect.bindUnit(options.effect, effUnit, "origin", effUnitDur)
                end
                local g = hgroup.createByXY(txy.x, txy.y, range, options.filter)
                if (hgroup.count(g) > 0) then
                    hskill.damageGroup(
                        {
                            frequency = 0,
                            times = 1,
                            effect = options.damageEffect,
                            whichGroup = g,
                            damage = damage,
                            sourceUnit = options.sourceUnit,
                            damageKind = damageKind,
                            damageType = damageType,
                            extraInfluence = options.extraInfluence
                        }
                    )
                end
                g = nil
            end
        )
    end
end

--[[
    变身
    options = {
        whichUnit, --哪个单位
        during, --持续时间
        toUnitId, --目标单位ID(可选)
        toAbilityId, --目标替换技能ID(可选,与toUnitId互斥)
        backAbilityId, --返回时的替换技能ID(可选,与toUnitId互斥)
        effectStart = nil, --开始中心特效
        effectEnd = nil, --结束中心特效
        attr = {} --属性变动
    }
]]
hskill.shapeshift = function(options)
    if (options.whichUnit == nil) then
        print_err("shapeshift: -whichUnit")
        return
    end
    if (options.toUnitId == nil and options.toAbilityId == nil and options.backAbilityId == nil) then
        print_err("shapeshift: -target")
        return
    end
    local during = options.during or 0
    if (during <= 0) then
        print_err("shapeshift: -during too small")
        return
    end
    local deDur = 0.2
    local attr = options.attr or {}
    if (options.effectStart ~= nil) then
        heffect.bindUnit(options.effectStart, options.whichUnit, "origin", 2.5)
    end
    local toAbilityId = options.toAbilityId
    local backAbilityId = options.backAbilityId
    if (toAbilityId == nil or backAbilityId == nil) then
        toAbilityId = hslk_global.skill_shapeshift[options.toUnitId].toAbilityId
        backAbilityId = hslk_global.skill_shapeshift[options.toUnitId].backAbilityId
    end
    cj.UnitAddAbility(options.whichUnit, toAbilityId)
    cj.UnitRemoveAbility(options.whichUnit, toAbilityId)
    hattr.reRegister(options.whichUnit)
    htime.setTimeout(
        deDur,
        function(t)
            htime.delTimer(t)
            if (options.attr ~= nil) then
                hattr.set(options.whichUnit, during, options.attr)
            end
            htime.setTimeout(
                during + deDur,
                function(t)
                    htime.delTimer(t)
                    if (options.effectEnd ~= nil) then
                        heffect.bindUnit(options.effectEnd, options.whichUnit, "origin", 2.5)
                    end
                    cj.UnitAddAbility(options.whichUnit, backAbilityId)
                    cj.UnitRemoveAbility(options.whichUnit, backAbilityId)
                    hattr.reRegister(options.whichUnit)
                end
            )
        end
    )
end
