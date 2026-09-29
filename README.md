# PLD.lua (FF11 GearSwap User Script for Paladin)

FINAL FANTASY XI の Windower4 アドオン「GearSwap」で使用する、ナイト（PLD）専用の全自動着替えスクリプトです。  
FC（ファストキャスト）69%〜80%の超高速環境下におけるパケット通信ラグ対策、敵からの魔法・状態異常自動迎撃、および被ファランクス着替え誤作動防止を完備しています。

---

## 🌟 主な機能と特徴

### 1. 超高速ケアルのパケット遅延対策（サポ赤/非サポ赤 自動分岐）
- **サポ赤時（FC 80%キャップ / 詠唱0.50秒）**:
  通信ラグによる `midcast` 着替え遅延（ケアル回復量0%着弾）を防ぐため、`precast`（詠唱開始前）の瞬間に **直接ケアル回復量＆高HP＆SIRD109%装備（`sets.midcast.Cure`）を先回り着用** します。
- **サポ赤以外時（FC 69% / 詠唱0.77秒）**:
  `precast` でFC装備（`sets.precast.FC`）を着用して最速詠唱開始し、着弾直前タイミングで自動的にケアル着弾装備へ切り替えます。

### 2. 敵魔法・状態異常の自動迎撃システム（パケット＆テキスト二重監視）
- 自分単体対象および範囲（ガ系/ジャ系/メテオ等）の魔法詠唱を即時検知。
- **状態異常系魔法（睡眠/静寂/麻痺/石化/呪い等）**: 魔回避・全状態異常耐性特化装備（`sets.StatusResist`）へ自動着替え。
- **攻撃系精霊・範囲魔法**: 魔防・イージス装備（`sets.idle.Magical`）へ自動着替え。
- 敵同士のバフや他PTメンバー宛ての単体魔法は自動除外（無駄な着替えを防止）。

### 3. 被ファランクス自動受領 ＆ 切れ時誤作動防止
- フェイスや他者からのファランクス受領時のみ、一時的に被ファランクス装備（`sets.midcast.IncreasedPhalanx`）へ着替え、2.5秒後に通常装備（`IdleMelee`）へ復帰。
- 「ファランクスの効果が切れた」という消失ログを完全除外しているため、**バフ切断時にカットの低い装備に着替えてしまう事故を100%防止**します。

---

## ⚙️ 必要な装備セット定義（`PLD_gear.lua` 側）

本スクリプトを動作させるには、`PLD_gear.lua`（または `PLD_gear.txt`）内に以下の装備セットが定義されている必要があります。

- `sets.precast.FC`（ファストキャスト装備）
- `sets.midcast.Cure`（ケアル回復量50%/HPブースト/SIRD109%装備）
- `sets.midcast.interruption`（詠唱中断防止100%装備）
- `sets.idle.Magical`（魔防・イージス待機装備）
- `sets.StatusResist`（魔回避・全状態異常耐性特化装備）
- `sets.midcast.IncreasedPhalanx`（被ファランクス+装備）

---

## 📥 ファイル配置方法

Windower4 の GearSwap フォルダ内に配置してください：

```text
Windower4/addons/GearSwap/data/PLD.lua
（または Windower4/addons/GearSwap/data/<キャラクター名>_PLD.lua）


## 📜 ライセンスと免責事項

### 1. ライセンス (License)
- 本スクリプトは **MIT ライセンス** のもとで公開されています。
- 個人利用、スクリプトの改変、学習、および再配布はご自由に行っていただけます。

### 2. 免責事項 (Disclaimer)
- 本スクリプトの導入・使用によって生じたいかなる損害や不利益についても、製作者は一切の責任を負いかねます。
- ご自身の環境に合わせてコードを確認・調整の上、自己責任でご利用ください。

# PLD.lua (FFXI GearSwap User Script for Paladin)

A feature-complete, highly optimized **Paladin (PLD)** GearSwap script for Windower 4 in *FINAL FANTASY XI*.  
Designed for high-end content, this script solves fast-cast packet latency issues, features automated spell and status ailment intercept swaps, and includes fail-safe logic for receiving external Phalanx buffs.

---

## 🌟 Key Features

### 1. Pre-Cast Cure Latency Prevention (Auto-Branching by Subjob)
- **Subjob /RDM (FC 80% Cap / 0.50s Cast Time)**:  
  Due to server-client packet latency on ultra-fast cast speeds, gear swaps executed during `midcast` often fail to arrive before spell landing (resulting in 0% Cure Potency). When subbing RDM, the script **pre-emptively equips Cure Potency / High-HP / SIRD 109% gear (`sets.midcast.Cure`) during `precast`** to guarantee 100% full-potency landings.
- **Other Subjobs (FC ~69% / 0.77s Cast Time)**:  
  Equips Fast Cast gear (`sets.precast.FC`) during `precast` for maximum casting speed, then automatically swaps to Cure gear right before impact using a dynamic timer.

### 2. Automated Enemy Spell & Status Intercept System (Packet & Chat Dual Monitoring)
- Real-time packet-level detection for single-target and Area-of-Effect (AoE) spells (Ga/Ja spells, Meteor, Comet, Ultima, Impact, etc.) cast by enemies.
- **Status Ailment Spells (Sleep, Silence, Paralysis, Break, Curse, Amnesia, etc.)**:  
  Auto-swaps to Magic Evasion & All Status Resistance gear (`sets.StatusResist`).
- **Nuke & Offensive AoE Spells**:  
  Auto-swaps to Magic Defense & Aegis gear (`sets.idle.Magical`).
- **Smart Filtering**: Ignores enemy self-buffs or single-target spells directed at other party members/Trusts.

### 3. Phalanx Receiver & Expiration Fail-Safe
- Temporarily equips Phalanx Received gear (`sets.midcast.IncreasedPhalanx`) when receiving Phalanx II from Trusts or party members, returning to `IdleMelee` after 2.5 seconds.
- **Expiration Guard**: Specifically filters out "Phalanx wears off" text logs to **prevent accidental gear swaps to low-defense gear when buffs expire**.

---

## ⚙️ Required Gear Sets (`PLD_gear.lua`)

To utilize all features, define the following gear sets in your `PLD_gear.lua` (or `PLD_gear.txt`):

```lua
sets.precast.FC               -- Fast Cast Gear (Targeting 69%+)
sets.midcast.Cure             -- Cure Potency 50% + High HP + SIRD 109%
sets.midcast.interruption     -- Spell Interruption Rate Down (SIRD 100%+)
sets.idle.Magical             -- Magic Defense / Aegis Idle Gear
sets.StatusResist             -- Magic Evasion / All Status Resistance Gear
sets.midcast.IncreasedPhalanx -- Phalanx Received + Gear
