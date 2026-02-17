# docs/design-system/tokens.md
# エキレコ Design Tokens v1.0（Flutter向け）

このドキュメントは、UI実装で参照する唯一の“見た目の数値辞書”です。  
画面実装で Color / Spacing / Radius / Typography を直書きしないこと。

---

## 1. Color Tokens

### 1.1 Brand
| Token | Value (Light) | Value (Dark) | Notes |
|---|---:|---:|---|
| color.primary | #4299F0 | #4299F0 | Primary Blue |
| color.secondary | #A8E6CF | #A8E6CF | Secondary Mint |

### 1.2 Semantic
| Token | Value (Light) | Value (Dark) | Notes |
|---|---:|---:|---|
| color.bg.canvas | #F8F9FA | #101922 | 画面背景（body） |
| color.surface | #FFFFFF | #1E293B | `bg-white` / `dark:bg-slate-800` 相当 |
| color.text.main | #2F3542 | #F3F4F6 | `text-text-main` / `dark:text-gray-100` 相当 |
| color.text.muted | #6B7280 | #9CA3AF | `text-gray-500` / `dark:text-gray-400` 相当 |
| color.text.subtle | #9CA3AF | #9CA3AF | `text-gray-400` 相当 |
| color.border | #F3F4F6 | #334155 | `border-gray-100` / `dark:border-slate-700` 相当 |

### 1.3 Alpha / Utility
| Token | Value | Notes |
|---|---:|---|
| color.primary.10 | rgba(66,153,240,0.10) | `bg-primary/10` |
| color.primary.20 | rgba(66,153,240,0.20) | `shadow-primary/20`, `border-primary/20` 相当 |
| color.shadow.base | rgba(0,0,0,0.05) | elevation の基本影 |

---

## 2. Typography Tokens

### 2.1 Font Family
| Token | Value |
|---|---|
| font.family.base | "Plus Jakarta Sans", "Zen Maru Gothic", sans-serif |

### 2.2 Type Scale（統一ルール）
**Body の基準を 15px に統一**（HTMLが15pxを明示しているため）。  
`text-sm(14px)` は今後 **原則使わない**（必要なら `type.bodySmall` を新設して明文化）。

| Token | Size | Weight | Line Height | Usage |
|---|---:|---:|---:|---|
| type.h1 | 24 | 700 | 1.25 | 画面タイトル |
| type.h2 | 18 | 700 | 1.25 | セクション見出し |
| type.body | 15 | 400 | 1.60 | 本文 |
| type.bodyStrong | 15 | 700 | 1.50 | 強調（ユーザー名など） |
| type.caption | 12 | 500 | 1.40 | 補助情報 |
| type.micro | 10 | 600 | 1.30 | ラベル/距離/メタ |

---

## 3. Spacing Tokens（8dp Baseline）

### 3.1 Baseline
8dpベースラインを採用。基本は **8/16/24/32** の4段。

| Token | Value | Usage |
|---|---:|---|
| space.xs | 8 | 最小余白 / アイコン周り |
| space.sm | 16 | 標準余白（左右マージンなど） |
| space.md | 24 | セクション内の区切り |
| space.lg | 32 | 大きな区切り（ヘッダーなど） |

### 3.2 例外（明文化）
現行HTMLには `px-5(20px)` と `mb-10(40px)` が存在するため、**8dp基準を崩さずに運用できるよう “例外トークン” を追加**する。

| Token | Value | Reason |
|---|---:|---|
| space.sm2 | 20 | 現行の `px-5` を再現するため |
| space.xl | 40 | 現行の `mb-10` を再現するため |

> ルール：例外トークンは増やしすぎない（v1では sm2 と xl まで）

---

## 4. Radius Tokens

Flutter側で迷わないよう、Radiusは **12 / 16 / full** を基本とし、必要に応じて lg を使う。

| Token | Value | Usage |
|---|---:|---|
| radius.xs | 12 | rounded-xl 相当（小さいコンテナ） |
| radius.card | 16 | Card / Surface |
| radius.lg | 32 | 大きいコンテナ |
| radius.full | 9999 | ピルボタン / アバター |

---

## 5. Elevation / Shadow Tokens

| Token | Shadow |
|---|---|
| elevation.0 | none |
| elevation.1 | blur=10, offset=(0,0), color=color.shadow.base |
| elevation.primaryGlow | blur=??, color=color.primary.20（用途：Primaryボタンの強調） |

> blur/offsetはFlutter実装時に `BoxShadow` として固定値化すること。
