function init_weaponns()
    send_command('gs c set MainWeapons '..windower.to_shift_jis('ブルトガング')..'; wait 1; gs c set SubWeapons '..windower.to_shift_jis('ドゥバン'))
end


function init_gear_sets()
	-- ロックスタイル番号
	lockstyleset = 200
    
	-- 武器
	gear['ブルトガング']	= {name="ブルトガング"}
	gear['サクパタソード']	= {name="サクパタソード"}
	gear['マリグナスソード']	= {name="マリグナスソード"}
    gear['マレヴォレンス']  = { name="マレヴォレンス", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}}
    gear['ドゥバン']		= {name="ドゥバン"}
	gear['イージス'] 		= {name="イージス"}
	gear.Slip  		        = {name="カリブルヌス"}
    
    -- 敵対心装備　128
	sets.Enmity = {
  --  main="ブルトガング",
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
	}

    -- ノックバック
    sets.KnockBack = {back="リパルスマント"}

    sets.BoostHP={
        ammo="ストンチタスラム+1",
        head={ name="ＳＶシャレル+1", augments={'HP+105','VIT+12','Phys. dmg. taken -4',}},
        body="ＲＶサーコート+4",
        hands={ name="ＳＶハントシュ+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
        legs={ name="ＳＶディヒリン+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
        feet={ name="ＳＶシュー+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
        neck={name="アンムーヴカラー+1",priority=14},
        waist={name="プラチナモグベルト",priority=16},
        right_ear={name="アスプロピアス",priority=11},
        left_ear={name="エテオレートピアス",priority=10},
        left_ring={name="ゼラチナスリング+1",priority=12},
        right_ring={name="月明の指輪",priority=13},
        back={"月明の羽衣",priority=15},
    }

    --HP低下装備（自己ケアル用）
    sets.LowHp={
    ammo="ストンチタスラム+1",
    head={ name="ＳＶシャレル+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body="ＣＶキュイラス+3",
    hands="サクパタガントレ",
    legs="ＣＶクウィス+3",
    feet={ name="オディシアグリーヴ", augments={'Attack+30','"Fast Cast"+6','Accuracy+10',}},
    neck="月光の首飾り",
    waist="スローダベルト",
    left_ear="磁界の耳",
    right_ear="アスプロピアス",
    left_ring="月明の指輪",
    right_ring="メランリング",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Cure" potency +10%','Phys. dmg. taken-10%',}},
    }

	-- 待機装備（通常）
	sets.idle = {
    sub="ドゥバン",
    ammo="サピエンスオーブ",
    head="ＣＶアーメット+3",
 --   body="サクロブレスト",
      body="ＣＶキュイラス+3",
    hands="ＣＶガントレ+3",
    legs="ＣＶクウィス+3",
    feet="ＣＶサバトン+3",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="キャリアーサッシュ",
    left_ear="オノワイヤリング+1",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	}

    -- 待機装備（対魔法）ブルト完成で１・２入れ替え
	sets.idle.Magical = {
    main="マリグナスソード",
    sub="イージス",
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="サクロブレスト",
    hands="ＣＶガントレ+3",
    legs="ＣＶクウィス+3",
    feet="ＣＶサバトン+3",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="クリードボードリエ",
    left_ear="オノワイヤリング+1",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ヴェクサーリング+1",
    back="サルブスマント",
	}
	

    -- 待機装備（クロ巣用）
	sets.idle.kurosu = {
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="ＲＶサーコート+4",
    hands="ＣＶガントレ+3",
    legs="ＣＶクウィス+3",
    feet="サクパタレギンス",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="キャリアーサッシュ",
    left_ear="ズワゾピアス+1",
    right_ear={ name="シバリエピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%',}},
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back="フィリドアマント",
	}

	-- 抜刀装備
    sets.engaged = {
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="サクロブレスト",
--      body="ＣＶキュイラス+3",
    hands="ＣＶガントレ+3",
--    hands="サクパタガントレ",
    legs="ＣＶクウィス+3",
    feet="ＣＶサバトン+3",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="キャリアーサッシュ",
    left_ear="オノワイヤリング+1",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	}

    sets.engaged.kurosu = set_combine(sets.idle.kurosu,{
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="ＲＶサーコート+4",
    hands="ＣＶガントレ+3",
    legs="ＣＶクウィス+3",
    feet="サクパタレギンス",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="キャリアーサッシュ",
    left_ear="ズワゾピアス+1",
    right_ear={ name="シバリエピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%',}},
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back="フィリドアマント",
    })

    -- 近接対魔法
    sets.engaged.Magical = set_combine(sets.idle.Magical,{
    main="マリグナスソード",
    sub="イージス",
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="サクロブレスト",
    hands="ＣＶガントレ+3",
    legs="ＣＶクウィス+3",
    feet="ＣＶサバトン+3",
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="クリードボードリエ",
    left_ear="オノワイヤリング+1",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ヴェクサーリング+1",
    back="サルブスマント",
	})

    -- ----------------------------------------------------------------------------------
    -- 状態異常耐性装備（魔回避+700以上 / 全状態異常耐性+70以上 / DT-50% CAP）
    -- ----------------------------------------------------------------------------------
    sets.StatusResist = {
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="サクパタブレスト",
    hands="マカブルガントレ+1",
    legs="ＣＶクウィス+3",
    feet="ＣＶサバトン+3",
    neck="ウォーダチャーム+1",
    waist="キャリアーサッシュ",
    left_ear="ハーティーピアス",
    right_ear="アレテデルルナ+1",
    left_ring="メランリング",
    right_ring="ピュリティーリング",
    back={ name="ルディアノスマント", augments={'MND+20','Eva.+20 /Mag. Eva.+20','MND+10','Enmity+10','Occ. inc. resist. to stat. ailments+10',}},
    }

    -- モード連携用エイリアス
    sets.idle.StatusResist = sets.StatusResist
    sets.engaged.StatusResist = sets.StatusResist

	--監視用バフ
    sets.buff['神聖の印']               = {feet="ＣＶサバトン+3"}
	sets.precast.JA                     = sets.Enmity
	sets.precast.JA['インビンシブル']   = set_combine(sets.Enmity,{legs="ＣＢブリーチズ+3"})
	sets.precast.JA['ホーリーサークル'] = set_combine(sets.Enmity,{feet="ＲＶレギンス+3"})
    sets.precast.JA['シールドバッシュ'] = set_combine(sets.Enmity,{hands="ＣＢガントレ+3"})
	sets.precast.JA['センチネル']       = set_combine(sets.Enmity,{feet="ＣＢレギンス+3"})
	sets.precast.JA['かばう']           = set_combine(sets.Enmity,{head="ＲＶコロネット+1",legs="ＣＢブリーチズ+3"})
	sets.precast.JA['ランパート']       = set_combine(sets.Enmity,{head="ＣＢコロネット+3"})
	sets.precast.JA['マジェスティ']     = sets.Enmity
    sets.precast.JA['フィールティ']     = set_combine(sets.Enmity,{body="ＣＢサーコート+3"})
	sets.precast.JA['シバルリー']       = {
        ammo="クォーツタスラム+1",
        head="ＣＶアーメット+3",
        body="ＲＶサーコート+4",
        hands="ＣＢガントレ+3",
        legs="ＣＶクウィス+3",
        feet="ＣＶサバトン+3",
        neck={ name="騎士の数珠+2", augments={'Path: A',}},
        waist="プラチナモグベルト",
        left_ear={ name="オノワイヤリング+1", augments={'Path: A',}},
        right_ear={ name="シバリエピアス+2", augments={'System: 1 ID: 1676 Val: 0','Accuracy+18','Mag. Acc.+18','Damage taken-7%','STR+11 VIT+11',}},
        left_ring="スティキニリング+1",
        right_ring={ name="メタモルリング+1", augments={'Path: A',}},
        back={ name="ルディアノスマント", augments={'VIT+20','Eva.+20 /Mag. Eva.+20','VIT+10','Enmity+10','Chance of successful block +5',}},
	}
	sets.precast.JA['神聖の印']         = sets.Enmity
	sets.precast.JA['セプルカー']       = sets.Enmity
	sets.precast.JA['パリセード']       = sets.Enmity
	sets.precast.JA['インターヴィーン'] = sets.Enmity

	
	sets.precast.FC = {
    sub="ドゥバン",
    ammo="サピエンスオーブ",
    head={ name="カマインマスク+1", augments={'Accuracy+20','Mag. Acc.+12','"Fast Cast"+4',}},
    body="ＲＶサーコート+4",
    hands={ name="レイライングローブ", augments={'Accuracy+12','Mag. Acc.+14','"Mag.Atk.Bns."+15','"Fast Cast"+2',}},
    legs="トラストブレー",
    feet={ name="オディシアグリーヴ", augments={'Attack+30','"Fast Cast"+6','Accuracy+10',}},
    neck="オルンミラトルク",
    waist="プラチナモグベルト",
    left_ear="アスプロピアス",
    right_ear={ name="シバリエピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%',}},
    left_ring="月明の指輪",
    right_ring="キシャールリング",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Fast Cast"+10','Phys. dmg. taken-10%',}},
    }
    sets.precast.FC.value = 69
	sets.precast.FC.Cure = sets.midcast.Cure

	-- WSダメージ
	sets.precast.WS.Damage = {
		ammo="昏黄の礫",
        head={ name="ニャメヘルム", augments={'Path: B',}},
        body={ name="ニャメメイル", augments={'Path: B',}},
        hands={ name="ニャメガントレ", augments={'Path: B',}},
        legs={ name="ニャメフランチャ", augments={'Path: B',}},
        feet={ name="ニャメソルレット", augments={'Path: B',}},
		neck="フォシャゴルゲット",
		waist="フォシャベルト",
		left_ear="テロスピアス",
        right_ear={ name="シバリエピアス+2", augments={'System: 1 ID: 1676 Val: 0','Accuracy+18','Mag. Acc.+18','Damage taken-7%','STR+11 VIT+11',}},
        left_ring="コーネリアリング",
        right_ring="エパミノダスリング",
		back={name="月明の羽衣",priority=16},
    }

	-- WSクリティカル
	sets.precast.WS.Critical = {
		ammo="昏黄の礫",
		head="サクパタヘルム",
		body="サクパタブレスト",
		hands="サクパタガントレ",
		legs="サクパタクウィス",
		feet="サクパタレギンス",
		neck="フォシャゴルゲット",
		waist="フォシャベルト",
		left_ear="テロスピアス",
        right_ear={ name="シバリエピアス+2", augments={'System: 1 ID: 1676 Val: 0','Accuracy+18','Mag. Acc.+18','Damage taken-7%','STR+11 VIT+11',}},
        left_ring="コーネリアリング",
        right_ring="王将の指輪",
		back={name="月明の羽衣",priority=16},
    }

	-- WS魔攻
	sets.precast.WS.Magic = {
    ammo="ストンチタスラム+1",
    head="ニャメヘルム",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
    neck="シビルスカーフ",
    waist="オルペウスサッシュ",
    left_ear="フリオミシピアス",
    right_ear="ヘカテーピアス",
    left_ring="メタモルリング+1",
    right_ring="コーネリアリング",
    back={ name="ルディアノスマント", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
    }
    
	-- 共通WS定義読み込み
    init_weapon_skill()
    
    -- 個別WS定義
    sets.precast.WS["サンギンブレード"] = set_combine(sets.precast.WS.Magic,{head="妖蟲の髪飾り+1",right_ring="アルコンリング",})
    sets.precast.WS["エナジードレイン"] = set_combine(sets.precast.WS.Magic,{
	ammo="ペムフレドタスラム",
    head="妖蟲の髪飾り+1",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
    neck="シビルスカーフ",
    waist="ルーミネリサッシュ",
    left_ear="フリオミシピアス",
    right_ear="ヘカテーピアス",
    left_ring="メタモルリング+1",
    right_ring="アルコンリング",
    back="無の外装",}
	)
    sets.precast.WS["イオリアンエッジ"] = set_combine(sets.precast.WS.Magic,{
	main={ name="マレヴォレンス", augments={'INT+10','Mag. Acc.+10','"Mag.Atk.Bns."+10','"Fast Cast"+5',}},
    ammo="ペムフレドタスラム",
    head="ニャメヘルム",
    body="ニャメメイル",
    hands="ニャメガントレ",
    legs="ニャメフランチャ",
    feet="ニャメソルレット",
    neck="シビルスカーフ",
    waist="風輪の帯",
    left_ear="フリオミシピアス",
    right_ear="ヘカテーピアス",
    left_ring="メタモルリング+1",
    right_ring="コーネリアリング",
    back={ name="ルディアノスマント", augments={'INT+20','Mag. Acc+20 /Mag. Dmg.+20','INT+10','Weapon skill damage +10%','Phys. dmg. taken-10%',}},
	})
    sets.precast.WS["ロイエ"]           = sets.Enmity

    -- 詠唱中断
	sets.midcast.interruption = {
    ammo="ストンチタスラム+1",
    head="ＣＶアーメット+3",
    body="ＣＶキュイラス+3",
    hands={ name="エスカイトガントレ", augments={'Mag. Evasion+15','Spell interruption rate down +15%','Enmity+7',}},
    legs="ＣＶクウィス+3",
    feet={ name="オディシアグリーヴ", augments={'Attack+30','"Fast Cast"+6','Accuracy+10',}},
    neck="月光の首飾り",
    waist="オドンブラサッシュ",
    left_ear="磁界の耳",
    right_ear={ name="シバリエピアス+1", augments={'System: 1 ID: 1676 Val: 0','Accuracy+12','Mag. Acc.+12','Damage taken-4%',}},
    left_ring="月明の指輪",
    right_ring="メランリング",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Fast Cast"+10','Phys. dmg. taken-10%',}},
	}


    -- フラッシュ
    sets.midcast['フラッシュ'] = set_combine(sets.Enmity,{
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
    })

    -- フォイル
    sets.midcast['フォイル'] = set_combine(sets.Enmity,{
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
    })
	
    -- リアクト
    sets.midcast['リアクト'] = set_combine(sets.Enmity,{
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
    })
	
	-- クルセード
    sets.midcast['クルセード'] = set_combine(sets.Enmity,{
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
    })

    -- バニシュガ
    sets.midcast['バニシュガ'] = set_combine(sets.Enmity,{
    ammo="サピエンスオーブ",
    head="ロースバルブータ+1",
    body="ＲＶサーコート+4",
    hands="ＣＢガントレ+3",
    legs="ＣＢブリーチズ+3",
    feet="ＣＶサバトン+3",
    neck="月光の首飾り",
    waist="クリードボードリエ",
    left_ear="クリプティクピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}},
    })
	
	-- ファランクス
	sets.midcast['ファランクス'] = {
    main="サクパタソード",
    sub="プリュウェン",
    ammo="ストンチタスラム+1",
    head={ name="バロラスマスク", augments={'DEX+10','Accuracy+10','Phalanx +5',}},
    body={ name="バロラスメイル", augments={'STR+10','Haste+3','Phalanx +5','Accuracy+6 Attack+6',}},
    hands={ name="ＳＶハントシュ+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs="サクパタクウィス",
    feet={ name="ＳＶシュー+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="キャリアーサッシュ",
    left_ear="ミミルピアス",
    right_ear="アスプロピアス",
    left_ring="アペリエリング+1",
    right_ring="メランリング",
    back={ name="ウェルドマント", augments={'VIT+3','Enmity+2','Phalanx +5',}},
	}
    
    -- ケアル
	sets.midcast.Cure = {
    ammo="ストンチタスラム+1",
    head={ name="ＳＶシャレル+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    body="ＲＶサーコート+4",
    hands={ name="ＳＶハントシュ+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    legs="ＣＶクウィス+3",
    feet={ name="ＳＶシュー+1", augments={'HP+105','Enmity+9','Potency of "Cure" effect received +15%',}},
    neck={ name="騎士の数珠+2", augments={'Path: A',}},
    waist="スローダベルト",
    left_ear="オノワイヤリング+1",
    right_ear="アスプロピアス",
    left_ring="月明の指輪",
    right_ring="ゼラチナスリング+1",
    back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','"Cure" potency +10%','Phys. dmg. taken-10%',}},
	}

    -- 呼び出しの不一致防止用紐付け
    sets.midcast['ケアルIV']  = sets.midcast.Cure
    sets.midcast['ケアルIII'] = sets.midcast.Cure
    sets.midcast['ケアルII']  = sets.midcast.Cure
    sets.midcast['ケアル']    = sets.midcast.Cure

    sets.midcast['ストンスキン'] = {
        body="アダマンアーマー",
        hands="ストーンマフラ",
        legs="ヘイヴンホーズ",
		feet="サクパタレギンス",
        neck="ストーンゴルゲット",
        waist="ジーゲルサッシュ",
        left_ear="アースクライピアス",
		left_ring="メランリング",
        back={ name="月明の羽衣",priority=16},
    }

    -- 青魔法（ジェタチュラ・ガイストウォール・シープソング・ブランクゲイズ等）
    -- SIRD 109% (100%中断防止) ＋ 敵対心+110 完全両立セット
    sets.midcast.BlueMagic = {
        sub="ドゥバン",              -- 敵対心+10
        ammo="ストンチタスラム+1",  -- SIRD +11%
        head="ＣＶアーメット+3",    -- SIRD +15% / 敵対心+9
        body="ＣＶキュイラス+3",    -- SIRD +15% / 敵対心+10
        hands={ name="エスカイトガントレ", augments={'Mag. Evasion+15','Spell interruption rate down +15%','Enmity+7',}}, -- SIRD +15% / 敵対心+7
        legs="ＣＶクウィス+3",       -- SIRD +15% / 敵対心+9
        feet="ＣＶサバトン+3",       -- 敵対心+9
        neck="月光の首飾り",         -- SIRD +15% / 敵対心+15
        waist="オドンブラサッシュ",   -- SIRD +10%
        left_ear="磁界の耳",         -- SIRD +8%
        right_ear="クリプティクピアス", -- 敵対心+5
        left_ring="月明の指輪",       -- SIRD +5%
        right_ring="アペリエリング+1",-- 敵対心+8
        back={ name="ルディアノスマント", augments={'HP+60','Eva.+20 /Mag. Eva.+20','HP+20','Enmity+10','Phys. dmg. taken-10%',}}, -- 敵対心+10
    }

    -- 指定4魔法への個別紐付け
    sets.midcast['ジェタチュラ']     = sets.midcast.BlueMagic
    sets.midcast['ガイストウォール'] = sets.midcast.BlueMagic
    sets.midcast['シープソング']     = sets.midcast.BlueMagic
    sets.midcast['ブランクゲイズ']   = sets.midcast.BlueMagic

    -- プロテス
    sets.midcast.Protect = {
        right_ring="シェルターリング",
    }

    -- シェル
    sets.midcast.Shell = sets.midcast.Protect 

    -- 被ファランクス
    sets.midcast.IncreasedPhalanx = sets.midcast['ファランクス']

    -- 被プロテス
    sets.midcast.IncreasedProtect = sets.midcast.Protect

    -- 被シェル
    sets.midcast.IncreasedShell = sets.midcast.Shell

    -- 被リジェネ
    sets.midcast.IncreasedRegenerated = {
        neck="サクロゴルゲット",
        waist="スローダベルト",
    }

    -- 被カーズナ
    sets.midcast.IncreasedCursna = {
        neck = "ニカンダネックレス",
        waist = "ギシドゥバサッシュ",
        left_ring="サイダリング",
        right_ring="ピュリティーリング",
    }
end
