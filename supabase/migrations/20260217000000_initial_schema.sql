-- ============================================================
-- 初期スキーマ: 位置情報ベースの匿名駅掲示板
-- 作成日: 2026-02-17
-- ============================================================

-- ============================================================
-- 1. テーブル定義
-- ============================================================

-- ------------------------------------------------------------
-- 駅テーブル
-- 駅の基本情報と位置座標を保持する
-- ------------------------------------------------------------
CREATE TABLE stations (
    id         uuid             PRIMARY KEY DEFAULT gen_random_uuid(),
    name       text             NOT NULL,
    latitude   double precision NOT NULL,
    longitude  double precision NOT NULL,
    prefecture text             NOT NULL,
    line_name  text             NOT NULL,
    created_at timestamptz      NOT NULL    DEFAULT now()
);

-- ------------------------------------------------------------
-- スレッドテーブル
-- 駅ごとの掲示板スレッドを管理する
-- ------------------------------------------------------------
CREATE TABLE threads (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    station_id uuid        NOT NULL REFERENCES stations (id) ON DELETE CASCADE,
    title      text        NOT NULL,
    body       text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now(),
    post_count integer     NOT NULL DEFAULT 0
);

-- ------------------------------------------------------------
-- 投稿テーブル
-- スレッドへの返信投稿を管理する
-- ------------------------------------------------------------
CREATE TABLE posts (
    id         uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    thread_id  uuid        NOT NULL REFERENCES threads (id) ON DELETE CASCADE,
    body       text        NOT NULL,
    created_at timestamptz NOT NULL DEFAULT now()
);

-- ------------------------------------------------------------
-- 通報テーブル
-- スレッドまたは投稿に対する通報を管理する
-- ------------------------------------------------------------
CREATE TABLE reports (
    id           uuid        PRIMARY KEY DEFAULT gen_random_uuid(),
    content_type text        NOT NULL CHECK (content_type IN ('thread', 'post')),
    content_id   uuid        NOT NULL,
    reason       text        NOT NULL,
    details      text,
    created_at   timestamptz NOT NULL DEFAULT now()
);

-- ============================================================
-- 2. インデックス
-- ============================================================

-- スレッド取得時に station_id で絞り込むため
CREATE INDEX idx_threads_station_id ON threads (station_id);

-- 投稿取得時に thread_id で絞り込むため
CREATE INDEX idx_posts_thread_id ON posts (thread_id);

-- 近隣駅検索の高速化のため（緯度・経度の複合インデックス）
CREATE INDEX idx_stations_lat_lng ON stations (latitude, longitude);

-- ============================================================
-- 3. 投稿数カウントトリガー
-- 投稿が追加されたら対応スレッドの post_count をインクリメントする
-- ============================================================

CREATE OR REPLACE FUNCTION increment_post_count()
RETURNS trigger
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
    UPDATE threads
       SET post_count = post_count + 1
     WHERE id = NEW.thread_id;
    RETURN NEW;
END;
$$;

CREATE TRIGGER trg_increment_post_count
    AFTER INSERT ON posts
    FOR EACH ROW
    EXECUTE FUNCTION increment_post_count();

-- ============================================================
-- 4. RPC: 近隣駅検索（Haversine 公式）
-- PostGIS 不要で緯度経度から距離を算出する
-- ============================================================

CREATE OR REPLACE FUNCTION get_nearby_stations(
    lat           double precision,
    lng           double precision,
    radius_meters integer DEFAULT 5000
)
RETURNS TABLE (
    id         uuid,
    name       text,
    latitude   double precision,
    longitude  double precision,
    prefecture text,
    line_name  text,
    distance   double precision
)
LANGUAGE sql
STABLE
AS $$
    SELECT * FROM (
        SELECT
            s.id,
            s.name,
            s.latitude,
            s.longitude,
            s.prefecture,
            s.line_name,
            -- Haversine 公式による距離計算（メートル単位）
            6371000.0 * 2.0 * asin(sqrt(
                sin(radians(s.latitude - lat) / 2.0) ^ 2
                + cos(radians(lat))
                  * cos(radians(s.latitude))
                  * sin(radians(s.longitude - lng) / 2.0) ^ 2
            )) AS distance
        FROM stations s
        WHERE
            -- 事前フィルタ: おおよその緯度経度範囲で絞り込み（パフォーマンス向上）
            s.latitude  BETWEEN lat - (radius_meters::double precision / 111000.0)
                            AND lat + (radius_meters::double precision / 111000.0)
            AND
            s.longitude BETWEEN lng - (radius_meters::double precision / (111000.0 * cos(radians(lat))))
                            AND lng + (radius_meters::double precision / (111000.0 * cos(radians(lat))))
    ) nearby
    WHERE distance <= radius_meters::double precision
    ORDER BY distance;
$$;

-- ============================================================
-- 5. Row Level Security（RLS）
-- 匿名ユーザー（anon）向けのポリシーを設定する
-- ============================================================

-- --- stations: 参照のみ許可 ---
ALTER TABLE stations ENABLE ROW LEVEL SECURITY;

CREATE POLICY "stations_select_anon"
    ON stations
    FOR SELECT
    TO anon
    USING (true);

-- --- threads: 参照・作成を許可 ---
ALTER TABLE threads ENABLE ROW LEVEL SECURITY;

CREATE POLICY "threads_select_anon"
    ON threads
    FOR SELECT
    TO anon
    USING (true);

CREATE POLICY "threads_insert_anon"
    ON threads
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- --- posts: 参照・作成を許可 ---
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

CREATE POLICY "posts_select_anon"
    ON posts
    FOR SELECT
    TO anon
    USING (true);

CREATE POLICY "posts_insert_anon"
    ON posts
    FOR INSERT
    TO anon
    WITH CHECK (true);

-- --- reports: 作成のみ許可（通報内容は一般ユーザーに非公開） ---
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;

CREATE POLICY "reports_insert_anon"
    ON reports
    FOR INSERT
    TO anon
    WITH CHECK (true);
