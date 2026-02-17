# docs/design-system/rules.md
# エキレコ Design System Rules（AI & Human Guardrails）

目的：改修のたびにデザインがブレるのを防ぎ、AI実装でも一貫性を維持する。

---

## 1. MUST（必須ルール）

### 1.1 直書き禁止
画面（feature/page）で以下を直書きしてはいけない。
- Color（`Color(0xFF...)` 等）
- Spacing（`EdgeInsets(...)` の数値直書き）
- Radius（`BorderRadius.circular(13)` 等）
- Typography（`TextStyle(...)` の直書き）

これらは必ず `design_system` の tokens / components 経由で指定する。

---

## 2. MUST NOT（禁止事項）

- 画面側で `TextStyle(...)` を新規作成しない
- 画面側で `EdgeInsets(...)` に数値を入れない
- 画面側で `Color(...)` を生成しない
- 新規UIを作るときに “既存コンポーネントを無視して独自実装” しない

---

## 3. SHOULD（推奨）

### 3.1 Spacing
- 基本は 8dpベースライン（8/16/24/32）
- 例外は `space.sm2(20)` と `space.xl(40)` のみ（v1）

### 3.2 Typography
- Body は 15px を基準とし統一する
- 14px相当を使いたい場合は `type.bodySmall` を追加して明文化してから利用する

### 3.3 Dark Mode
- Dark 用の surface/text/border は tokens に固定値で定義する（Tailwind既成色への依存を避ける）

---

## 4. Change Policy（変更の手順）
新しい見た目が必要になった場合：

1) まず tokens で表現できないか検討  
2) 次に components の variant 追加で表現できないか検討  
3) それでも無理なら、新規 component を design_system に追加  
4) 画面側での例外実装は最後の手段（行うなら rules.md に例外理由を残す）

---

## 5. Review Checklist（PR確認観点）
- [ ] 画面側で tokens の直書きがない
- [ ] 既存コンポーネントが使われている
- [ ] spacing/radius/typography が規定値のみで構成されている
- [ ] dark mode の色が tokens 経由で指定されている
