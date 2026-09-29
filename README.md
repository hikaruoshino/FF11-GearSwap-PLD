```markdown
# PLD.lua (FF11 GearSwap User Script for Paladin / ナイト用GearSwapスクリプト)

[ English | [日本語](#日本語) ]

---

## English

A feature-complete, highly optimized **Paladin (PLD)** GearSwap script for Windower 4 in *FINAL FANTASY XI*.

### 🌟 Key Features
- **Pre-Cast Cure Latency Prevention**:  
  - **/RDM (FC 80% Cap)**: Pre-emptively equips `sets.midcast.Cure` during `precast` to avoid packet latency loss.  
  - **Other Subjobs (FC 69%)**: Equips `sets.precast.FC` during `precast`, swapping to Cure gear right before landing via dynamic timer.
- **Enemy Spell & Status Intercept**: Automatically detects enemy nukes, AoE spells, and status ailments (Sleep, Silence, Paralysis, etc.), swapping to `sets.StatusResist` or `sets.idle.Magical`.
- **Phalanx Fail-Safe**: Swaps to Phalanx Received gear when receiving Phalanx II, with built-in protection against buff expiration logs.

### ⚙️ Required Gear Sets (`PLD_gear.lua`)
- `sets.precast.FC`
- `sets.midcast.Cure`
- `sets.midcast.interruption`
- `sets.idle.Magical`
- `sets.StatusResist`
- `sets.midcast.IncreasedPhalanx`

### 📜 License & Disclaimer
- **License**: Released under the **MIT License**. Free for personal use, modification, and redistribution.
- **Disclaimer**: Provided "as-is" without warranty. Use at your own risk.

---

<a name="日本語"></a>
## 日本語

FINAL FANTASY XI の Windower4 アドオン「GearSwap」で使用する、ナイト（PLD）専用の全自動着替えスクリプトです。

### 🌟 主な機能
- **超高速ケアルのパケット遅延対策**:
  - **サポ赤時 (FC 80%)**: 通信ラグによる着替え失敗を防ぐため、`precast` 時に直接ケアル着弾装備（`sets.midcast.Cure`）を着用。
  - **サポ赤以外 (FC 69%)**: `precast` でFC装備を着用後、着弾直前にタイマーでケアル装備へ着替え。
- **敵魔法・状態異常自動迎撃**: 敵の単体・範囲魔法や状態異常魔法（睡眠・静寂・麻痺・石化等）を判定し、魔回避（`sets.StatusResist`）や魔防（`sets.idle.Magical`）へ自動着替え。
- **被ファランクス受領＆誤作動防止**: ファランクス受領時に一時着替え。「効果が切れた」ログによる誤着替えを完全防止。

### ⚙️ 必要な装備セット（`PLD_gear.lua` 内）
- `sets.precast.FC`（ファストキャスト）
- `sets.midcast.Cure`（ケアル回復量50% + SIRD109%）
- `sets.midcast.interruption`（詠唱中断防止100%）
- `sets.idle.Magical`（魔防・イージス）
- `sets.StatusResist`（魔回避・全状態異常耐性）
- `sets.midcast.IncreasedPhalanx`（被ファランクス+）

### 📜 ライセンスと免責事項
- **ライセンス**: **MITライセンス** に基づいて公開されています。改変・再配布・個人利用は自由です。
- **免責事項**: 本スクリプトの使用によるいかなる問題・損害についても一切の責任を負いません。自己責任でご利用ください。
