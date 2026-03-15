/**
 * k6 負荷テスト — 駅掲示板 API
 *
 * 実行コマンド:
 *   k6 run \
 *     --env SUPABASE_TEST_URL=https://xxx.supabase.co \
 *     --env SUPABASE_TEST_ANON_KEY=eyJ... \
 *     test/load/load_test.js
 *
 * CI では GitHub Secrets から環境変数を注入する。
 * テスト用 Supabase プロジェクトの seed.sql が投入済みであること（setup() が stations を取得するため）。
 *
 * しきい値:
 *   - p(95) < 2000ms  : 95パーセンタイルのレスポンスタイムが 2秒未満
 *   - error_rate < 1% : エラー率が 1% 未満
 */

import http from 'k6/http';
import { check, sleep } from 'k6';
import { Rate } from 'k6/metrics';

// カスタムメトリクス: エラー率
const errorRate = new Rate('error_rate');

// 環境変数（CI では --env で渡される）
const SUPABASE_URL = __ENV.SUPABASE_TEST_URL || '';
const SUPABASE_KEY = __ENV.SUPABASE_TEST_ANON_KEY || '';

// テスト設定: 仮想ユーザー数・ランプアップ・定常状態・ランダウン
export const options = {
  stages: [
    { duration: '10s', target: 5 },   // 10秒でVU5まで増加（ウォームアップ）
    { duration: '20s', target: 10 },  // 20秒間VU10で定常状態
    { duration: '10s', target: 0 },   // 10秒でVU0まで減少（クールダウン）
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'], // 95パーセンタイルが 2000ms 未満
    error_rate: ['rate<0.01'],          // エラー率 1% 未満
  },
};

/**
 * setup(): テスト実行前に1回だけ呼ばれる。
 * seed.sql 投入済みの stations テーブルから最初の station_id を取得する。
 * 取得できない場合はフォールバック値を返す。
 */
export function setup() {
  if (!SUPABASE_URL || !SUPABASE_KEY) {
    console.warn('SUPABASE_TEST_URL / SUPABASE_TEST_ANON_KEY が未設定です。スキップします。');
    return { stationId: null };
  }

  const headers = {
    apikey: SUPABASE_KEY,
    Authorization: `Bearer ${SUPABASE_KEY}`,
    'Content-Type': 'application/json',
  };

  // stations テーブルから1件取得
  const res = http.get(
    `${SUPABASE_URL}/rest/v1/stations?select=id&limit=1`,
    { headers }
  );

  if (res.status === 200) {
    const body = JSON.parse(res.body);
    if (body && body.length > 0) {
      console.log(`setup: station_id = ${body[0].id}`);
      return { stationId: body[0].id };
    }
  }

  // seed.sql 未投入の場合は固定値にフォールバック
  console.warn('stations テーブルからデータを取得できませんでした。フォールバック値を使用します。');
  return { stationId: 'test-station-1' };
}

/**
 * default(): 各仮想ユーザーが繰り返し実行するシナリオ。
 * 1. 駅一覧の取得（GET /rest/v1/stations）
 * 2. スレッド一覧の取得（GET /rest/v1/threads）
 */
export default function (data) {
  if (!SUPABASE_URL || !SUPABASE_KEY) {
    // 設定がない場合はスキップ（CI が Secrets 未設定の場合でも fail しない）
    errorRate.add(0);
    return;
  }

  const headers = {
    apikey: SUPABASE_KEY,
    Authorization: `Bearer ${SUPABASE_KEY}`,
    'Content-Type': 'application/json',
  };

  const stationId = data.stationId || 'test-station-1';

  // シナリオ 1: 近傍駅 RPC の呼び出し
  // 注意: マイグレーションSQLの関数名は get_nearby_stations（_location ではない）
  const rpcRes = http.post(
    `${SUPABASE_URL}/rest/v1/rpc/get_nearby_stations`,
    JSON.stringify({ lat: 35.6812, lng: 139.7671, radius_km: 0.5 }),
    { headers }
  );

  const rpcOk = check(rpcRes, {
    'RPC get_nearby_stations ステータスが 200': (r) => r.status === 200,
    'RPC レスポンスタイムが 2000ms 未満': (r) => r.timings.duration < 2000,
  });
  errorRate.add(!rpcOk);

  sleep(0.5);

  // シナリオ 2: スレッド一覧の取得
  const threadsRes = http.get(
    `${SUPABASE_URL}/rest/v1/threads?station_id=eq.${stationId}&select=*&order=created_at.desc&limit=20`,
    { headers }
  );

  const threadsOk = check(threadsRes, {
    'GET /threads ステータスが 200': (r) => r.status === 200,
    'GET /threads レスポンスタイムが 2000ms 未満': (r) => r.timings.duration < 2000,
  });
  errorRate.add(!threadsOk);

  sleep(0.5);
}
