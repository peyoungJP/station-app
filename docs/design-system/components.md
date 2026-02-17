# docs/design-system/components.md
# エキレコ Components v1.0（仕様）

このドキュメントは「UI部品のカタログ」です。  
画面は **コンポーネントを組み合わせるだけ**にし、見た目の値は tokens を参照します。

---

## 1. AppTopBar（iOSステータスバー相当のプレースホルダ）
- Height: 48
- PaddingX: space.md（※現行HTMLはpx-6=24。Flutterでは `space.md=24` を利用）
- Text: type.caption 相当（9:41など）
- Icons: Material Icons Round

---

## 2. AppHeader（ブランドヘッダー）
### 構成
- 左：IconContainer（40x40）
  - bg: color.primary
  - radius: radius.xs（12）
  - icon: white
- 右：タイトル群
  - Title: type.h1
  - Subtitle: type.micro / primary 70% / uppercase / tracking wide（Flutterでは letterSpacing を固定）

---

## 3. AppButton
### 共通
- Width: full
- Radius: radius.full
- PaddingY: space.sm（16）
- Text: type.bodyStrong（ボタンは太字）
- Optional Leading Icon: Material Icons Round

### Variants
#### 3.1 Primary
- bg: color.primary
- fg: white
- elevation: elevation.primaryGlow

#### 3.2 Secondary
- bg: color.secondary
- fg: color.text.main
- elevation: elevation.0

#### 3.3 Ghost / Tertiary（キャンセル）
- bg: color.primary.10
- fg: color.primary
- elevation: elevation.0

---

## 4. AppCard（Surface）
### 共通
- bg: color.surface
- border: color.border
- radius: radius.card（16）
- elevation: elevation.1

### Padding
- Compact: space.sm（16）
- Comfortable: space.md（24）

---

## 5. PostCard（投稿カード）
AppCardをベースに、以下の構成。

### Header
- Avatar（40x40、radius.full、bg: secondary 30%）
- UserName: type.bodyStrong
- Meta: type.micro（駅名・距離など）

### Body
- type.body（lineHeight=1.6）
- 文章は複数行前提

### Footer（Actions）
- icon + count
- 色は muted（color.text.subtle 相当）

---

## 6. Avatar（匿名アバター）
### 共通
- Size: 48x48
- Radius: full
- bg: tinted(100) / fg: tinted(500) のペアでテーマ化
- icon: Material Icons Round

### 推奨カラーペア（例）
- orange100 + orange500
- pink100 + pink500
- green100 + green500
- purple100 + purple500
