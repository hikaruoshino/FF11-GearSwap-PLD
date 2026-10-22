------------------------------------------------------------------------------------
-- 【ナイト用: ケアル・全魔法の FC → SIRD → 着弾装備の3段階着替え、敵の魔法・TP技への自動着替え】 PLD.lua (v6.7.2)
-- 
-- 【着替えシーケンス】
-- 1. Precast (詠唱開始時)  : sets.precast.FC (FC は上限 80% として計算)
-- 2. Midcast (詠唱動作中)  : sets.midcast.interruption (詠唱中断率を下げる装備)
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

    -- 敵の TP技の分類表 (mob_tp_moves)。無くても動く (そのときは TP技では着替えない)
    pcall(include, 'mob_tp_moves.lua')
end

-- 可変調整タイマー: 着弾の何秒前にケアル装備へ切り替えるか (//gs c cureadjust <秒数> で変更)
-- 着替えの命令がサーバーに届くまでに 0.3〜0.4 秒ほどかかるので、短すぎるとケアル装備が間に合わない。
-- 実測 (2026-10-12、自分にケアルIV): 0.08 秒 = 2/6 成功 / 0.20 秒 = 7/10 / 0.30 秒 = 10/10 / 0.40 秒 = 5/5
local cure_adjust = 0.30

function job_setup()
    -- user-globals.lua の Interruption を PLD 専用版に差し替え
    -- (user-globals.lua はこのファイルの後に読み込まれ同名関数を上書きするため、job_setup で差し替える)
    Interruption = pld_interruption

    state.Buff['神聖の印']      = buffactive['神聖の印'] or false

    state.IdleMode:options('Normal','kurosu')
    state.OffenseMode:options('Normal','kurosu','Magical')
    state.WeaponskillMode:options('Normal','SubtleBlow')
    state.MainWeapons   = M{'ブルトガング','マレヴォレンス','マリグナスソード'}
    state.SubWeapons    = M{'ドゥバン','イージス'}
    state.Increased     = M(true) -- デフォルトで自動着替えON
    state.KnockBack     = M(false)
    -- 敵の魔法・TP技に合わせて、対魔法装備 (sets.idle.Magical) と状態異常耐性装備 (sets.StatusResist) に着替えるか。
    -- 物理で殴る敵が多い場所 (クロウラーの巣のマスターポイント稼ぎなど) では、着替えると被ダメージが増えるのでオフにする。
    -- 切り替え: //gs c toggle MagicalCut   (被ファランクスの着替えは、オフでも行う)
    -- 待機モードか戦闘モードを kurosu にしている間も、同じく着替えない
    state.MagicalCut    = M(true, 'MagicalCut')
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
function pld_interruption(spell, action, spellMap, eventArgs)
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
    local adjust = cure_adjust
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
        send_command('wait '..cast_time.."; gs equip sets.midcast['"..sjis_name.."']")
    elseif spellMap and sets.midcast and sets.midcast[spellMap] then
        send_command('wait '..cast_time..'; gs equip sets.midcast.'..spellMap)
    elseif spell.english and sets.midcast and sets.midcast[spell.english] then
        send_command('wait '..cast_time.."; gs equip sets.midcast['"..spell.english.."']")
    elseif spell.skill and sets.midcast and sets.midcast[spell.skill] then
        local sjis_skill = windower.to_shift_jis(spell.skill)
        send_command('wait '..cast_time.."; gs equip sets.midcast['"..sjis_skill.."']")
    elseif spell.type and sets.midcast and sets.midcast[spell.type] then
        send_command('wait '..cast_time..'; gs equip sets.midcast.'..spell.type) 
    end
end

------------------------------------------------------------------------------------
-- ★【敵魔法・状態異常自動迎撃＆被ファランクス受領処理】
-- 自分の詠唱中は、自分の魔法の着替え (FC → SIRD → 着弾装備) を優先し、迎撃・被ファランクスの着替えはしない。
-- 自分の行動が終わった時点で、敵の魔法 (またはファランクス) がまだ着弾していなければ、その装備に着替える。
-- 着弾 (または詠唱中断) を確認したら、待機・戦闘の装備に戻す。
------------------------------------------------------------------------------------
local status_keywords = S{
    'スリプル', 'スリプガ', 'サイレス', 'サイレガ', 'パライゾ', 'パライガ', 'パラナ',
    'ブレイク', 'ブレクガ', 'スロウ', 'スロウガ', 'グラビデ', 'グラビガ', 'ブライン', 'ブライガ',
    'ポイズン', 'ポイズンガ', 'バイオ', 'ディア', 'カーズ', 'カースガ', 'アムネジア', 'デス',
    'チャーム', 'バインド', 'バインガ', 'ドレイン', 'アスピル',
    '石化', '睡眠', '静寂', '麻痺', '呪い', 'テラー', '魅了', '病気', '悪霊', 'スタン',
    'sleep', 'silence', 'paralyze', 'break', 'slow', 'gravity', 'blind', 'poison',
    'bio', 'dia', 'curse', 'amnesia', 'death', 'charm', 'bind', 'drain', 'aspir'
}

-- 範囲魔法の見分け方: 名前の末尾 (ランクの数字を除く) が ガ / ジャ か、メテオなどの名前を含むもの。
-- 「ガ」「ga」を含むかで見ると、ゲイン系 (Gain-) やマドリガルなど範囲でない魔法にも反応してしまう
local aoe_suffixes = {'ガ', 'ジャ', 'ga', 'ja'}
local aoe_names = {
    'メテオ', 'コメット', 'アルテマ', 'インパクト', 'フルフル',
    'meteor', 'comet', 'ultima', 'impact'
}

local function has_aoe_suffix(name)
    name = (name:gsub('%s*[ivIV]+$', ''))
    for _, suffix in ipairs(aoe_suffixes) do
        if name:sub(-#suffix) == suffix then return true end
    end
    return false
end

local function is_aoe_spell(spell)
    if not spell then return false end
    local ja, en = spell.ja or '', (spell.en or ''):lower()
    if has_aoe_suffix(ja) or has_aoe_suffix(en) then return true end
    for _, name in ipairs(aoe_names) do
        if ja:find(name, 1, true) or en:find(name, 1, true) then return true end
    end
    return false
end

-- パケットで検知する (チャットのログは Shift-JIS で届き、自分の詠唱にも反応してしまうため使わない)
-- category 8 (詠唱) の param: 24931 = 詠唱開始 / 28787 = 詠唱中断。category 4 = 魔法の着弾
local CAST_BEGIN, CAST_INTERRUPT = 24931, 28787
local PHALANX_IDS = S{106, 107}   -- ファランクス / ファランクスII
-- 学者の範囲ファランクス: 女神降臨の章 (アビリティ 218) のあとのファランクスは、対象が詠唱者自身のまま範囲になる。
-- 詠唱開始のパケットだけでは範囲かどうか分からないので、女神降臨の章を使った人を覚えておく
local JA_CATEGORY = 6             -- アビリティの使用 (act.param がアビリティの番号)
local ACCESSION_ID = 218          -- 女神降臨の章
local ACCESSION_SEC = 60          -- 女神降臨の章の効果時間 (次の魔法で消える)
local accession_until = {}        -- [使った人の ID] = 効果が切れる時刻
-- 敵の詠唱は res の詠唱時間より長いことがある (フリーズ: res 8.5 秒・実測 14.4 秒) ので、倍にして待つ
local CAST_HOLD_RATE = 2          -- 詠唱時間に掛ける倍率 (着弾のパケットが届かないときの保険の期限)
local CAST_MARGIN_SEC = 2         -- さらに足す余裕
local DEFAULT_HOLD_SEC = 20       -- 詠唱時間が分からないときの保険の期限
-- 敵の TP技 (特殊技): category 7 = 構え (param は詠唱と同じ 24931 / 28787)、category 11 = 発動
local TP_HOLD_SEC = 6             -- 構えから発動までの保険の期限 (発動のパケットが届かないとき)

-- 着弾待ちの詠唱: [詠唱した人の ID] = {kind = 'StatusResist' / 'Magical' / 'Phalanx', until_time = 保険の期限}
local pending_casts = {}
local auto_set_on = false         -- 迎撃・被ファランクスの装備を着ているか

local AUTO_SET_COMMAND = {
    StatusResist = 'sets.StatusResist',
    Magical      = 'sets.idle.Magical',
    Phalanx      = 'sets.ReceivedPhalanx',
}

local function auto_set_table(kind)
    if kind == 'StatusResist' then return sets.StatusResist
    elseif kind == 'Magical' then return sets.idle.Magical
    elseif kind == 'Phalanx' then return sets.ReceivedPhalanx
    end
end

-- 敵の魔法・TP技に合わせた着替え (対魔法装備・状態異常耐性装備) をしてよいか。次のどちらかなら着替えない:
--   ・MagicalCut をオフにしている (//gs c toggle MagicalCut)
--   ・待機モードか戦闘モードが kurosu (クロウラーの巣向け。物理で殴る敵が多く、着替えると被ダメージが増える)
local function magical_cut_enabled()
    if state.MagicalCut and not state.MagicalCut.value then return false end
    if state.IdleMode and state.IdleMode.value == 'kurosu' then return false end
    if state.OffenseMode and state.OffenseMode.value == 'kurosu' then return false end
    return true
end

-- 今着るべき装備の種類 (状態異常耐性 > 対魔法 > 被ファランクス)。
-- 期限切れの詠唱と、倒れた・消えた人の詠唱はここで消す
local function current_auto_kind()
    local now = os.clock()
    local found = {}
    for caster_id, cast in pairs(pending_casts) do
        local caster = windower.ffxi.get_mob_by_id(caster_id)
        if now > cast.until_time or not caster or caster.hpp == 0 then
            pending_casts[caster_id] = nil
        else
            found[cast.kind] = true
        end
    end
    -- 対魔法装備と状態異常耐性装備は、MagicalCut がオンで kurosu モードでないときだけ (それ以外は普段の装備のまま受ける)
    local intercept = magical_cut_enabled()
    if found.StatusResist and intercept then return 'StatusResist' end
    if found.Magical and intercept then return 'Magical' end
    if found.Phalanx then return 'Phalanx' end
    return nil
end

-- 今の状況に合わせて着替える。自分の行動中は何もしない (行動の後に job_post_aftercast で着替える)
local function update_auto_set()
    if midaction() then return end
    local kind = current_auto_kind()
    if kind then
        send_command('gs equip ' .. AUTO_SET_COMMAND[kind])
        auto_set_on = true
    elseif auto_set_on then
        auto_set_on = false
        send_command('gs c IdleMelee')
    end
end

local function add_pending(caster_id, kind, spell, hold_sec)
    local hold = hold_sec
        or (spell and spell.cast_time) and (spell.cast_time * CAST_HOLD_RATE + CAST_MARGIN_SEC) or DEFAULT_HOLD_SEC
    pending_casts[caster_id] = {kind = kind, until_time = os.clock() + hold}
    update_auto_set()
    -- 着弾も中断も届かなかったときのため、期限が来たらもう一度確かめる
    coroutine.schedule(update_auto_set, hold + 0.1)
end

local function remove_pending(caster_id)
    if pending_casts[caster_id] then
        pending_casts[caster_id] = nil
        update_auto_set()
    end
end

-- 敵の魔法が自分か範囲に向いていれば、着る装備の種類を返す
local function enemy_cast_kind(spell, target_id, my_id)
    -- res の名前は日本語・英語の両方で調べる (キーワードに両方あるため)
    local spell_name = spell and ((spell.ja or '') .. ' ' .. (spell.en or '')):lower() or ''

    if target_id ~= my_id and not is_aoe_spell(spell) then
        return nil
    end

    for skw in pairs(status_keywords) do
        if spell_name:contains(skw) then
            return 'StatusResist'
        end
    end
    return 'Magical'
end

-- 被ファランクスの装備セットを、このファイル専用の名前 (sets.ReceivedPhalanx) に移す。
-- user-globals.lua にはチャットログで「ファランクス」を見つけて sets.midcast.IncreasedPhalanx に着替え、
-- 3 秒固定で戻す処理がある。それが重なると着弾後も戻らないので、元の名前を空けてそちらを止める
-- (ナイトの被ファランクスは、下のパケット検知が着替えと戻しの両方を受け持つ)
local function take_over_phalanx_set()
    if sets.midcast and sets.midcast.IncreasedPhalanx then
        sets.ReceivedPhalanx = sets.midcast.IncreasedPhalanx
        sets.midcast.IncreasedPhalanx = nil
    end
end

windower.register_event('action', function(act)
    if not act then return end
    take_over_phalanx_set()
    local player = windower.ffxi.get_player()
    if not player or act.actor_id == player.id then return end   -- 自分の詠唱は3段階着替えが受け持つ

    -- act.targets は対象の一覧。1人目の対象と、その行動の param (魔法の番号) を見る
    local target = act.targets and act.targets[1]
    local action = target and target.actions and target.actions[1]

    if act.category == 8 then
        if act.param == CAST_INTERRUPT then
            remove_pending(act.actor_id)
            return
        end
        if act.param ~= CAST_BEGIN or not target or not action then return end

        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        if not actor then return end
        -- res は user-globals.lua によっては読み込まれないので、GearSwap 本体のものを使う
        local spell = gearswap.res.spells[action.param]

        if actor.spawn_type == 16 and not actor.in_party then
            -- 敵 (spawn_type 16) の詠唱開始
            local kind = enemy_cast_kind(spell, target.id, player.id)
            if kind then
                -- //gs debugmode がオンなら、迎撃のきっかけになった魔法をチャットログに出す
                if _settings.debug_mode then
                    add_to_chat(207, '[PLD.lua] 迎撃 (' .. kind .. '): ' .. (spell and spell.ja or '不明な魔法'))
                end
                add_pending(act.actor_id, kind, spell)
            end
        elseif PHALANX_IDS[action.param] then
            -- フェイスなどが自分にファランクスを詠唱し始めた。
            -- または、同じパーティーの人が女神降臨の章のあとに自分自身へ詠唱し始めた (範囲ファランクス)
            local to_me = target.id == player.id
            local accession = accession_until[act.actor_id]
            local aoe = target.id == act.actor_id and actor.in_party
                and accession ~= nil and os.clock() <= accession
            if (to_me or aoe) and sets.ReceivedPhalanx and (not state.Increased or state.Increased.value) then
                add_pending(act.actor_id, 'Phalanx', spell)
            end
        end

    elseif act.category == JA_CATEGORY then
        if act.param == ACCESSION_ID then
            accession_until[act.actor_id] = os.clock() + ACCESSION_SEC
        end

    elseif act.category == 4 then
        -- 魔法の着弾 (敵の魔法・ファランクスとも)。女神降臨の章は魔法 1 回で消える
        accession_until[act.actor_id] = nil
        remove_pending(act.actor_id)

    elseif act.category == 7 then
        -- 敵の TP技の構え。魔法属性は sets.idle.Magical、状態異常は sets.StatusResist に着替える。
        -- 物理の技と、分類表に無い技は着替えない (普段の装備で受ける)
        if act.param == CAST_INTERRUPT then
            remove_pending(act.actor_id)
            return
        end
        if act.param ~= CAST_BEGIN or not target or not action or not mob_tp_moves then return end

        local actor = windower.ffxi.get_mob_by_id(act.actor_id)
        if not actor or actor.spawn_type ~= 16 or actor.in_party then return end

        local move_id = action.param
        local kind = mob_tp_moves.status[move_id] and 'StatusResist'
            or mob_tp_moves.magical[move_id] and 'Magical' or nil
        local for_me = target.id == player.id or mob_tp_moves.aoe[move_id]
        -- //gs debugmode がオンなら、敵の TP技と分類をチャットログに出す (分類表に無い技を見つけるため)
        if _settings.debug_mode then
            local move = gearswap.res.monster_abilities[move_id]
            add_to_chat(207, '[PLD.lua] TP技 ' .. move_id .. ' ' .. (move and move.ja or '不明な技')
                .. ': ' .. (kind or '着替えなし') .. (for_me and '' or ' (対象外)'))
        end
        if kind and for_me then
            add_pending(act.actor_id, kind, nil, TP_HOLD_SEC)
        end

    elseif act.category == 11 then
        -- 敵の TP技の発動
        remove_pending(act.actor_id)
    end
end)

-- 自分の行動が終わったら (Mote の後処理の最後)、着弾待ちの敵の魔法・ファランクスがあればその装備に着替える
function job_post_aftercast(spell, action, spellMap, eventArgs)
    local kind = current_auto_kind()
    if kind then
        equip(auto_set_table(kind))
        auto_set_on = true
    else
        auto_set_on = false
    end
end

------------------------------------------------------------------------------------
-- ★【コマンド拡張】 タイマー可変調整コマンド (//gs c cureadjust <秒数>)
------------------------------------------------------------------------------------
-- user-globals.lua の job_self_command の最後から呼ばれる (job_self_command は上書きされるため使わない)
function custom_self_command(cmdParams, eventArgs)
    if cmdParams[1] and cmdParams[1]:lower() == 'cureadjust' then
        if cmdParams[2] then
            local val = tonumber(cmdParams[2])
            if val then
                cure_adjust = val
                add_to_chat(207, '[PLD.lua] ケアル着替え可変タイマーを ' .. string.format('%.2f', val) .. ' 秒前に設定しました。')
            end
        else
            add_to_chat(207, '[PLD.lua] 現在のケアル着替え可変タイマー: ' .. string.format('%.2f', cure_adjust) .. ' 秒前')
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
    if stateField == 'MagicalCut' then
        add_to_chat(207, '[PLD.lua] 敵の魔法・TP技に合わせた着替え (対魔法・状態異常耐性): ' .. (newValue and 'オン' or 'オフ (普段の装備のまま受ける)'))
        -- 着替えている最中にオフにしたら、すぐ普段の装備に戻す (オンにしたら、着弾待ちの魔法があれば着替える)
        update_auto_set()
    elseif stateField == 'Idle Mode' or stateField == 'Offense Mode' then
        -- kurosu モードでは対魔法装備・状態異常耐性装備に着替えない。モードを変えた時点の状況に合わせ直す
        if newValue == 'kurosu' or oldValue == 'kurosu' then
            add_to_chat(207, '[PLD.lua] 敵の魔法・TP技に合わせた着替え (対魔法・状態異常耐性): '
                .. (magical_cut_enabled() and 'する' or 'しない (kurosu モードまたは MagicalCut オフ)'))
            update_auto_set()
        end
    end
    if user_state_change then
        user_state_change(stateField, newValue, oldValue)
    end
end
