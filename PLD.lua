------------------------------------------------------------------------------------
-- 【ナイト専用・ケアル＆全魔法 完全SIRD100%防衛＆FC動的3段階着替え対応】 PLD.lua (v6.2)
-- 
-- 【着替えシーケンス】
-- 1. Precast (詠唱開始時)  : sets.precast.FC (FC80%キャップ対応で高速詠唱開始)
-- 2. Midcast (詠唱動作中)  : sets.midcast.interruption (詠唱中断率100%ダウン/SIRD100%で被ダメージガード)
-- 3. 着弾直前 (動的タイマー後) : sets.midcast.Cure / 各種着弾装備 (ケアル回復量・敵対心等)
------------------------------------------------------------------------------------

function get_sets()
    mote_include_version = 2
    include('Mote-Include.lua')
    set_language('japanese')
    
    -- 装備定義ファイル (PLD_gear.lua) の自動インクルード
    local status, err = pcall(include, 'PLD_gear.lua')
    if not status then
        pcall(include, player.name .. '_gear.lua')
    end
end

function job_setup()
    state.Buff['神聖の印']      = buffactive['神聖の印'] or false

    state.IdleMode:options('Normal','kurosu')
    state.OffenseMode:options('Normal','kurosu','Magical')
    state.WeaponskillMode:options('Normal','SubtleBlow')
    state.MainWeapons   = M{'ブルトガング','マレヴォレンス','マリグナスソード'}
    state.SubWeapons    = M{'ドゥバン','イージス'}
    state.Increased     = M(true) -- デフォルトで自動着替えON
    state.KnockBack     = M(false)

    -- 可変調整タイマーのデフォルト値 (0.08秒前着替え)
    state.CureAdjust    = M('0.08')
end

function user_unload()
    -- キーバインド非使用のため記述なし
end

------------------------------------------------------------------------------------
-- ★【Precast】全魔法共通で FC装備 (sets.precast.FC) を最速着用して詠唱開始
------------------------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    if string.find(spell.type, 'Magic') then
        -- ケアル含むすべての魔法でまず FC 装備を確実に着用！
        if sets.precast and sets.precast.FC then
            equip(sets.precast.FC)
            eventArgs.handled = true
        end
    end
end

------------------------------------------------------------------------------------
-- ★【Midcast】Mote-Include の自動着替えをバイパスし Interruption 関数に一元化
------------------------------------------------------------------------------------
function job_midcast(spell, action, spellMap, eventArgs)
    if string.find(spell.type, 'Magic') then
        eventArgs.handled = true
    end
end

------------------------------------------------------------------------------------
-- ★【Interruption 関数】SIRD100%即時着用 ＆ FC動的逆算着弾タイマー
-- シーケンス: sets.precast.FC -> sets.midcast.interruption -> sets.midcast.Cure (等)
------------------------------------------------------------------------------------
function Interruption(spell, action, spellMap, eventArgs)
    if not spell or not spell.type or not string.find(spell.type, 'Magic') then
        return
    end

    -- 1) FC (ファストキャスト) 率の動的算出
    local fc_val = 69
    if sets.precast and sets.precast.FC and sets.precast.FC.value then
        fc_val = sets.precast.FC.value
    end
    local fc = fc_val / 100

    if player.sub_job == '赤' then
        fc = fc + 0.15
    elseif player.main_job == '赤' then
        fc = fc + 0.38
    end

    if fc >= 0.80 then
        fc = 0.80
    end

    eventArgs.handled = true

    -- 2) 実効詠唱時間の計算 (基底時間 * (1 - FC) - 可変調整マージン)
    local base_cast = spell.cast_time or 2.5
    local adjust = tonumber(state.CureAdjust and state.CureAdjust.value) or 0.08
    local cast_time = (base_cast * (1 - fc)) - adjust

    if cast_time < 0.05 then
        cast_time = 0.05
    end

    -- 3) 【中間ステップ】まず速攻で SIRD 100% 装備 (sets.midcast.interruption) を着用！
    if sets.midcast and sets.midcast.interruption then
        equip(sets.midcast.interruption)
    end

    -- 4) 【最終ステップ】逆算された cast_time 秒後に各魔法の着弾装備 (sets.midcast.Cure等) へ切り替え
    local sjis_name = windower.to_shift_jis(spell.name)

    if spell.english:find('Cure') or spell.name:contains('ケアル') or (spellMap and spellMap == 'Cure') then
        send_command('wait '..cast_time..'; gs equip sets.midcast.Cure')
    elseif sets.midcast and sets.midcast[spell.name] then
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..sjis_name..'']')
    elseif spellMap and sets.midcast and sets.midcast[spellMap] then
        send_command('wait '..cast_time..'; gs equip sets.midcast.'..spellMap)
    elseif spell.english and sets.midcast and sets.midcast[spell.english] then
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..spell.english..'']')
    elseif spell.skill and sets.midcast and sets.midcast[spell.skill] then
        local sjis_skill = windower.to_shift_jis(spell.skill)
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..sjis_skill..'']')
    elseif spell.type and sets.midcast and sets.midcast[spell.type] then
        send_command('wait '..cast_time..'; gs equip sets.midcast.'..spell.type) 
    end
end

------------------------------------------------------------------------------------
-- ★【敵魔法・状態異常自動迎撃＆被ファランクス受領処理】
------------------------------------------------------------------------------------
local is_auto_swapping = false

local status_keywords = S{
    'スリプル', 'スリプガ', 'サイレス', 'サイレガ', 'パライゾ', 'パライガ', 'パラナ',
    'ブレイク', 'ブレクガ', 'スロウ', 'スロウガ', 'グラビデ', 'グラビガ', 'ブライン', 'ブライガ',
    'ポイズン', 'ポイズンガ', 'バイオ', 'ディア', 'カーズ', 'カースガ', 'アムネジア', 'デス',
    'チャーム', 'バインド', 'バインガ', 'ドレイン', 'アスピル',
    '石化', '睡眠', '静寂', '麻痺', '呪い', 'テラー', '魅了', '病気', '悪霊', 'スタン',
    'sleep', 'silence', 'paralyze', 'break', 'slow', 'gravity', 'blind', 'poison',
    'bio', 'dia', 'curse', 'amnesia', 'death', 'charm', 'bind', 'drain', 'aspir'
}

local aoe_keywords = S{
    'ガ', 'ジャ', 'メテオ', 'コメット', 'アルテマ', 'インパクト', 'フルフル',
    'ga', 'ja', 'meteor', 'comet', 'ultima', 'impact'
}

-- ① パケットレベルでの敵魔法ターゲット検知
windower.register_event('action', function(act)
    if not act or is_auto_swapping then return end

    if act.category == 8 then
        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        if not actor or actor.is_npc == false or actor.in_party then return end

        local target_id = act.targets and act.targets.id
        local my_id = windower.ffxi.get_player().id

        local spell_id = act.targets and act.targets.actions and act.targets.actions.param
        local spell = res and res.spells and res.spells[spell_id]
        local spell_name = spell and spell.name:lower() or ''

        local is_target_me = (target_id == my_id)
        local is_aoe = false

        for kw in pairs(aoe_keywords) do
            if spell_name:contains(kw) then
                is_aoe = true
                break
            end
        end

        if not is_target_me and not is_aoe then
            return
        end

        local is_status = false
        for skw in pairs(status_keywords) do
            if spell_name:contains(skw) then
                is_status = true
                break
            end
        end

        is_auto_swapping = true
        if is_status then
            send_command('gs equip sets.StatusResist; wait 3.5; gs c IdleMelee;')
        else
            send_command('gs equip sets.idle.Magical; wait 3.5; gs c IdleMelee;')
        end

        coroutine.schedule(function()
            is_auto_swapping = false
        end, 4)
    end
end)

-- ② テキストログ検知（フェイス等の被ファランクス受領 ＆ 敵攻撃ログ）
windower.register_event('incoming text', function(original, modified, mode)
    if not original or original == '' or is_auto_swapping then return modified, mode end

    local my_name = windower.ffxi.get_player().name

    -- 効果消失ログは処理スキップ
    if original:contains('効果が切れた') or original:contains('が切れた') or 
       original:lower():contains('wears off') or original:lower():contains('lost') then
        return modified, mode
    end

    -- 被ファランクス自動受領
    if not state.Increased or state.Increased.value then
        local sjis_phalanx = "t@NX"
        local is_phalanx_spell = original:contains(sjis_phalanx) or 
                                 (windower.to_shift_jis and original:contains(windower.to_shift_jis('ファランクス'))) or
                                 original:lower():contains('phalanx')

        if is_phalanx_spell and (original:contains('唱えた') or original:contains('詠唱') or original:contains('実行') or original:lower():contains('casts')) then
            is_auto_swapping = true
            send_command('gs equip sets.midcast.IncreasedPhalanx; wait 2.5; gs c IdleMelee;')
            coroutine.schedule(function()
                is_auto_swapping = false
            end, 3)
            return modified, mode
        end
    end

    -- 敵魔法・技ログ検知
    if original:contains('唱えた') or original:contains('詠唱') or original:contains('実行') then
        local is_me = original:contains(my_name)
        local is_aoe = false
        for kw in pairs(aoe_keywords) do
            if original:contains(kw) then
                is_aoe = true
                break
            end
        end

        if not is_me and not is_aoe then
            return modified, mode
        end

        local is_status = false
        for skw in pairs(status_keywords) do
            if original:contains(skw) then
                is_status = true
                break
            end
        end

        is_auto_swapping = true
        if is_status then
            send_command('gs equip sets.StatusResist; wait 3.5; gs c IdleMelee;')
        else
            send_command('gs equip sets.idle.Magical; wait 3.5; gs c IdleMelee;')
        end

        coroutine.schedule(function()
            is_auto_swapping = false
        end, 4)
    end

    return modified, mode
end)

------------------------------------------------------------------------------------
-- ★【コマンド拡張】 タイマー可変調整コマンド (//gs c cureadjust <秒数>)
------------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1]:lower() == 'cureadjust' then
        if cmdParams[2] then
            local val = tonumber(cmdParams[2])
            if val then
                state.CureAdjust:set(string.format('%.2f', val))
                add_to_chat(207, windower.to_shift_jis('[PLD.lua] ケアル着替え可変タイマーを ' .. string.format('%.2f', val) .. ' 秒前に設定しました。'))
            end
        else
            add_to_chat(207, windower.to_shift_jis('[PLD.lua] 現在のケアル着替え可変タイマー: ' .. tostring(state.CureAdjust.value) .. ' 秒前'))
        end
        eventArgs.handled = true
    end
end

------------------------------------------------------------------------------------
-- Mote / user-globals 連携カスタマイズ処理
------------------------------------------------------------------------------------
function job_customize_idle_set(idleSet)
    if state.SubWeapons.value == "ドゥバン" then
        idleSet = idleSet
    else
        idleSet = set_combine(idleSet,sets.idle.Magical)
    end
    return idleSet
end

function job_customize_melee_set(meleeSet)
    if state.SubWeapons.value == "ドゥバン" then
        meleeSet = set_combine(meleeSet,sets.engaged)
    else
        meleeSet = set_combine(meleeSet,sets.engaged.Magical)
    end
    
    if state.KnockBack.value then
        meleeSet = set_combine(meleeSet,sets.KnockBack)
    end
    return meleeSet
end

function job_state_change(stateField, newValue, oldValue)
    if user_state_change then
        user_state_change(stateField, newValue, oldValue)
    end
end
