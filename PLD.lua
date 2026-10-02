------------------------------------------------------------------------------------
-- 【ナイト専用・サポ赤別FC自動分岐＆敵魔法自動迎撃対応版】 PLD.lua
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

    state.IdleMode:options('Normal','kurosu','StatusResist')
    state.OffenseMode:options('Normal','kurosu','Magical','StatusResist')
    state.WeaponskillMode:options('Normal','SubtleBlow')
    state.MainWeapons   = M{'ブルトガング','マレヴォレンス','マリグナスソード'}
    state.SubWeapons    = M{'ドゥバン','イージス'}
    state.Increased     = M(true) -- デフォルトで自動着替えON
    state.KnockBack     = M(false)
    state.CureAdjust    = M('0.08', '0.02', '0.05', '0.10', '0.12') -- 回線・高負荷用タイマー可変調整
end

function user_unload()
    -- キーバインド非使用のため記述なし
end

------------------------------------------------------------------------------------
-- ★【サポ赤別 FC分岐処理】precast (詠唱開始前) のケアル先回り着替え
------------------------------------------------------------------------------------
function job_precast(spell, action, spellMap, eventArgs)
    if spell.english:find('Cure') or spell.name:contains('ケアル') or (spellMap and spellMap == 'Cure') then
        if player.sub_job == '赤' then
            -- 【サポ赤時: FC 80% / 詠唱0.50秒】
            -- 超高速詠唱のため通信ラグで midcast 着替えが間に合わないため、
            -- precast の瞬間に直接 sets.midcast.Cure（高HP＋ケアル回復量＋SIRD109%）を着用
            equip(sets.midcast.Cure)
            eventArgs.handled = true
        else
            -- 【サポ赤以外時: FC 69% / 詠唱0.77秒】
            -- 詠唱時間にコンマ数秒の余裕があるため、precast は FC装備（sets.precast.FC）を着て詠唱開始
            -- その後、Interruption 関数のタイマーで sets.midcast.Cure へ着替える
            equip(sets.precast.FC)
            eventArgs.handled = true
        end
    end
end

------------------------------------------------------------------------------------
-- ★【二重着替え防止】Mote-Include 標準の default_midcast 自動着替えをバイパス
------------------------------------------------------------------------------------
function job_midcast(spell, action, spellMap, eventArgs)
    if string.find(spell.type, 'Magic') then
        eventArgs.handled = true
    end
end

------------------------------------------------------------------------------------
-- ★ Interruption 関数（自詠唱魔法の動的タイマー処理）
------------------------------------------------------------------------------------
function Interruption(spell, action, spellMap, eventArgs)
    local fc_val = 69
    if sets.precast.FC and sets.precast.FC.value then
        fc_val = sets.precast.FC.value
    end

    local fc = fc_val / 100

    if player.sub_job == '赤' then
        fc = fc + 15/100
    elseif player.main_job == '赤' then
        fc = fc + 38/100
    end
    
    if fc >= 80/100 then
        fc = 80/100
    end
    
    eventArgs.handled = true

    -- ★ ケアル系の処理
    if spell.english:find('Cure') or spell.name:contains('ケアル') or (spellMap and spellMap == 'Cure') then
        if player.sub_job == '赤' then
            -- サポ赤時は job_precast で直接着用済みのため維持
            equip(sets.midcast.Cure)
            return
        end
    end
    
    -- 回線ラグ・高負荷用タイマーマージン（デフォルト 0.08秒）
    local adjust = tonumber(state.CureAdjust and state.CureAdjust.value) or 0.08
    local cast_time = (spell.cast_time * (1 - fc)) - adjust

    if cast_time < 0.05 then cast_time = 0.05 end

    -- 1) まず詠唱中断防止装備(SIRD 100%)を着用
    equip(sets.midcast.interruption)

    -- 2) 計算された着弾直前タイミングで各魔法の着弾装備へ切り替え
    local sjis_name = windower.to_shift_jis(spell.name)
    if spell.english:find('Cure') or spell.name:contains('ケアル') or (spellMap and spellMap == 'Cure') then
        send_command('wait '..cast_time..'; gs equip sets.midcast.Cure')
    elseif sets.midcast[spell.name] then
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..sjis_name..'']')
    elseif spellMap and sets.midcast[spellMap] then
        send_command('wait '..cast_time..'; gs equip sets.midcast.'..spellMap)
    elseif sets.midcast[spell.english] then
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..spell.english..'']')
    elseif sets.midcast[spell.skill] then
        local sjis_skill = windower.to_shift_jis(spell.skill)
        send_command('wait '..cast_time..'; gs equip sets.midcast[''..sjis_skill..'']')
    elseif sets.midcast[spell.type] then
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
        local sjis_phalanx = "\x83\x74\x83\x40\x83\x89\x83\x93\x83\x4e\x83\x58"
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
-- セルフコマンド制御（タイマー調整等）
------------------------------------------------------------------------------------
function job_self_command(cmdParams, eventArgs)
    if cmdParams[1] == 'cureadjust' then
        if cmdParams[2] then
            state.CureAdjust:set(cmdParams[2])
            add_to_chat(122, 'ケアル着替えタイマーを ' .. cmdParams[2] .. ' 秒前に設定しました。')
        else
            add_to_chat(122, '現在のケアル着替えタイマー: ' .. state.CureAdjust.value .. ' 秒前')
        end
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
