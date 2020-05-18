---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by hunzs.
--- DateTime: 2020/5/8 22:18
---

-- DZAPI vjass启用标志判断
if (cg.HLUA_DZAPI_FLAG == true) then
    hdzapi.enable = true
end

-- 全局秒钟
cj.TimerStart(cj.CreateTimer(), 1.00, true, htime.clock)

-- 预读 preread
local preread_u = cj.CreateUnit(hplayer.player_passive, hslk_global.unit_token, 0, 0, 0)
hattr.regAllAbility(preread_u)
hunit.del(preread_u)

-- register APM
hevent.pool('global', hevent_default_actions.player.apm, function(tgr)
    for i = 1, bj_MAX_PLAYER_SLOTS, 1 do
        cj.TriggerRegisterPlayerUnitEvent(tgr, cj.Player(i - 1), EVENT_PLAYER_UNIT_ISSUED_TARGET_ORDER, nil)
        cj.TriggerRegisterPlayerUnitEvent(tgr, cj.Player(i - 1), EVENT_PLAYER_UNIT_ISSUED_POINT_ORDER, nil)
        cj.TriggerRegisterPlayerUnitEvent(tgr, cj.Player(i - 1), EVENT_PLAYER_UNIT_ISSUED_ORDER, nil)
    end
end)

for i = 1, bj_MAX_PLAYERS, 1 do
    hplayer.players[i] = cj.Player(i - 1)

    -- 英雄模块初始化
    hhero.player_allow_qty[i] = 1
    hhero.player_heroes[i] = {}

    cj.SetPlayerHandicapXP(hplayer.players[i], 0) -- 经验置0

    hplayer.set(hplayer.players[i], "prevGold", 0)
    hplayer.set(hplayer.players[i], "prevLumber", 0)
    hplayer.set(hplayer.players[i], "totalGold", 0)
    hplayer.set(hplayer.players[i], "totalGoldCost", 0)
    hplayer.set(hplayer.players[i], "totalLumber", 0)
    hplayer.set(hplayer.players[i], "totalLumberCost", 0)
    hplayer.set(hplayer.players[i], "goldRatio", 100)
    hplayer.set(hplayer.players[i], "lumberRatio", 100)
    hplayer.set(hplayer.players[i], "expRatio", 100)
    hplayer.set(hplayer.players[i], "sellRatio", 50)
    hplayer.set(hplayer.players[i], "apm", 0)
    hplayer.set(hplayer.players[i], "damage", 0)
    hplayer.set(hplayer.players[i], "beDamage", 0)
    hplayer.set(hplayer.players[i], "kill", 0)
    if
    ((cj.GetPlayerController(hplayer.players[i]) == MAP_CONTROL_USER) and
        (cj.GetPlayerSlotState(hplayer.players[i]) == PLAYER_SLOT_STATE_PLAYING))
    then
        -- his
        his.set(hplayer.players[i], "isComputer", false)
        --
        hplayer.qty_current = hplayer.qty_current + 1
        hplayer.set(hplayer.players[i], "status", hplayer.player_status.gaming)

        hevent.onChat(
            hplayer.players[i], '+', false,
            hevent_default_actions.player.command
        )
        hevent.onChat(
            hplayer.players[i], '-', false,
            hevent_default_actions.player.command
        )
        -- 玩家离开游戏
        hevent.pool(hplayer.players[i], hevent_default_actions.player.leave, function(tgr)
            cj.TriggerRegisterPlayerEvent(tgr, hplayer.players[i], EVENT_PLAYER_LEAVE)
        end)
        -- 玩家取消选择单位
        hevent.onDeSelection(hplayer.players[i], function(evtData)
            hplayer.set(evtData.triggerPlayer, "selection", nil)
        end)
        -- 玩家选中单位
        hevent.pool(hplayer.players[i], hevent_default_actions.player.selection, function(tgr)
            cj.TriggerRegisterPlayerUnitEvent(tgr, hplayer.players[i], EVENT_PLAYER_UNIT_SELECTED, nil)
        end)

        hevent.onSelection(
            hplayer.players[i],
            1,
            function(evtData)
                hplayer.set(evtData.triggerPlayer, "selection", evtData.triggerUnit)
            end
        )
    else
        his.set(hplayer.players[i], "isComputer", true)
        hplayer.set(hplayer.players[i], "status", hplayer.player_status.none)
    end
end

-- 生命魔法恢复
htime.setInterval(
    0.5,
    function()
        for agk, agu in ipairs(hRuntime.attributeGroup.life_back) do
            if (his.deleted(agu) == true) then
                table.remove(hRuntime.attributeGroup.life_back, agk)
            else
                if (his.alive(agu) and hattr.get(agu, "life_back") ~= 0) then
                    hunit.addCurLife(agu, hattr.get(agu, "life_back") * 0.5)
                end
            end
        end
        for agk, agu in ipairs(hRuntime.attributeGroup.mana_back) do
            if (his.deleted(agu) == true) then
                table.remove(hRuntime.attributeGroup.mana_back, agk)
            else
                if (his.alive(agu) and hattr.get(agu, "mana_back") ~= 0) then
                    hunit.addCurMana(agu, hattr.get(agu, "mana_back") * 0.5)
                end
            end
        end
    end
)
-- 没收到伤害时,每1.5秒恢复1.5%硬直
htime.setInterval(
    1.5,
    function()
        for agk, agu in ipairs(hRuntime.attributeGroup.punish) do
            if (his.deleted(agu) == true) then
                table.remove(hRuntime.attributeGroup.punish, agk)
            elseif (his.alive(agu) == true and his.damaging(agu) == false) then
                hattr.set(agu, 0, { punish_current = "+" .. (hattr.get(agu, "punish") * 0.015) })
            end
        end
    end
)
