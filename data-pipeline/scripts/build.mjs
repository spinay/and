// Google Sheet → JSON 빌드 스크립트
//
// 입력: 환경변수 SHEET_CSV_URL (없으면 아래 기본 URL)
//      운영용 시트 (회사명/공모가/청약일/환불일/상장일/주관사/...)
// 출력: data/ipos.json (앱이 fetch하는 catalog 포맷)
//      seed/ipos-sheet.csv (시트 raw 백업, diff/롤백용)
//
// 시트 컬럼 구조:
//   회사명, 공모가, 배정안됨, 상장일, 상태, 수요예측일, 업종,
//   정산일, 종목코드, 주관사, 청약일, 최소청약수량, 환불일
//
// 변환 규칙:
//   - 빈 회사명 행 skip
//   - canonical_key = `${청약일YYYY-MM-DD}_${회사명}`
//   - 청약일 단일 → subscription_start = 그 날, subscription_end = +1일
//   - 수요예측일 "5월 11일 → 5월 15일" → 마지막 날짜만 사용
//   - 공모가 → confirmed_price (정수)
//   - 최소청약수량 비어있으면 10
//   - 증거금률 기본 0.5
//   - 주관사 축약명 → 풀네임 매핑
//   - 상태 "활성" → 오늘 날짜 기준 자동 결정
//   - "배정안됨" / "정산일" / "종목코드"는 catalog에 들어가지 않음 (개인 메모 컬럼)

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { parse } from 'csv-parse/sync';

const DEFAULT_SHEET_URL =
  'https://docs.google.com/spreadsheets/d/187cuaPUAes3da9p509iUhJnU75ZRIFvBwNiyWiacgMo/export?format=csv&gid=0';

const OUTPUT_JSON = 'data/ipos.json';
const BACKUP_CSV = 'seed/ipos-sheet.csv';

// 주관사 축약 → 풀네임
const UNDERWRITER_MAP = {
  '삼성': '삼성증권',
  '미래': '미래에셋증권',
  '한국': '한국투자증권',
  'NH': 'NH투자증권',
  '신한': '신한투자증권',
  'KB': 'KB증권',
  '대신': '대신증권',
  '키움': '키움증권',
  '유진': '유진투자증권',
  '유안타': '유안타증권',
  '하나': '하나증권',
  '현대차': '현대차증권',
  '교보': '교보증권',
  '하이': '하이투자증권',
  'IBK': 'IBK투자증권',
  'DB': 'DB금융투자',
  'SK': 'SK증권',
};

// ─── 유틸 ─────────────────────────────────────────────────

/**
 * "2025년 12월 16일" → "2025-12-16"
 * "2026년 5월 11일 → 2026년 5월 15일" → "2026-05-15" (마지막)
 * 빈 값/파싱 실패 → null
 */
function parseKoreanDate(raw) {
  if (raw == null) return null;
  let s = String(raw).trim();
  if (!s) return null;

  // "→" / "->" 가 있으면 마지막 토큰만 사용
  if (s.includes('→')) s = s.split('→').pop().trim();
  if (s.includes('->')) s = s.split('->').pop().trim();

  // "YYYY년 M월 D일" 매칭
  const m = s.match(/(\d{4})\s*년\s*(\d{1,2})\s*월\s*(\d{1,2})\s*일/);
  if (m) {
    const [, y, mo, d] = m;
    return `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
  }

  // "YYYY-MM-DD" 그대로
  if (/^\d{4}-\d{2}-\d{2}$/.test(s)) return s;

  // "YYYY/MM/DD" 또는 "YYYY.MM.DD"
  const m2 = s.match(/^(\d{4})[./-](\d{1,2})[./-](\d{1,2})$/);
  if (m2) {
    const [, y, mo, d] = m2;
    return `${y}-${String(mo).padStart(2, '0')}-${String(d).padStart(2, '0')}`;
  }

  return null;
}

/** YYYY-MM-DD에 day 더하기 */
function addDays(ymd, days) {
  if (!ymd) return null;
  const [y, m, d] = ymd.split('-').map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d + days));
  const yy = dt.getUTCFullYear();
  const mm = String(dt.getUTCMonth() + 1).padStart(2, '0');
  const dd = String(dt.getUTCDate()).padStart(2, '0');
  return `${yy}-${mm}-${dd}`;
}

function parseIntSafe(raw) {
  if (raw == null) return null;
  const s = String(raw).trim();
  if (!s) return null;
  const n = Number(s.replace(/,/g, ''));
  return Number.isFinite(n) ? Math.trunc(n) : null;
}

/** "삼성, 미래" → ["삼성증권", "미래에셋증권"] */
function parseUnderwriters(raw) {
  if (raw == null) return [];
  const s = String(raw).trim();
  if (!s) return [];
  return s
    .split(/[,/·]/)
    .map((t) => t.trim())
    .filter(Boolean)
    .map((t) => UNDERWRITER_MAP[t] ?? t);
}

/**
 * 오늘 날짜 기준으로 enum 상태를 결정한다.
 * sheet의 "활성" 컬럼은 단순 on/off 플래그라 그대로 못 쓴다.
 */
function deriveStatus({ today, demandStart, subStart, subEnd, listingDate }) {
  // 상장됨
  if (listingDate && today >= listingDate) return 'listed';

  // 청약 종료 후 ~ 상장 전
  if (subEnd && today > subEnd) {
    return listingDate ? 'waitingListing' : 'closed';
  }

  // 청약 진행 중
  if (subStart && subEnd && today >= subStart && today <= subEnd) {
    return 'subscribing';
  }

  // 수요예측 진행 중 (있는 경우만)
  if (demandStart && today >= demandStart && subStart && today < subStart) {
    return 'forecasting';
  }

  // 그 외는 모두 예정
  return 'upcoming';
}

/** 시트 행 → catalog ipo 객체 */
function rowToIpo(row, today) {
  const company = (row['회사명'] ?? '').trim();
  if (!company) return null;

  const subStart = parseKoreanDate(row['청약일']);
  if (!subStart) {
    // 청약일 없는 행은 canonical_key를 만들 수 없으므로 skip
    return null;
  }

  const subEnd = addDays(subStart, 1);
  const refundDate = parseKoreanDate(row['환불일']);
  const listingDate = parseKoreanDate(row['상장일']);
  const demandStart = parseKoreanDate(row['수요예측일']);
  const confirmedPrice = parseIntSafe(row['공모가']);
  const minQty = parseIntSafe(row['최소청약수량']) ?? 10;
  const sector = (row['업종'] ?? '').trim();
  const underwriters = parseUnderwriters(row['주관사']);

  const status = deriveStatus({
    today,
    demandStart,
    subStart,
    subEnd,
    listingDate,
  });

  return {
    canonical_key: `${subStart}_${company}`,
    company_name: company,
    sector,
    business_summary: '',
    demand_start: demandStart,
    demand_end: null,
    subscription_start: subStart,
    subscription_end: subEnd,
    refund_date: refundDate,
    listing_date: listingDate,
    price_band_low: null,
    price_band_high: null,
    confirmed_price: confirmedPrice,
    min_subscription_qty: minQty,
    deposit_ratio: 0.5,
    underwriters,
    status,
    competition_rate: null,
    dart_corp_code: null,
  };
}

// ─── main ────────────────────────────────────────────────

async function fetchSheetCsv(url) {
  const res = await fetch(url, { redirect: 'follow' });
  if (!res.ok) {
    throw new Error(`시트 fetch 실패: ${res.status} ${res.statusText}`);
  }
  return await res.text();
}

function todayYmdSeoul() {
  // KST 기준 YYYY-MM-DD
  const now = new Date();
  const kst = new Date(now.getTime() + 9 * 60 * 60 * 1000);
  const y = kst.getUTCFullYear();
  const m = String(kst.getUTCMonth() + 1).padStart(2, '0');
  const d = String(kst.getUTCDate()).padStart(2, '0');
  return `${y}-${m}-${d}`;
}

async function main() {
  const url = process.env.SHEET_CSV_URL ?? DEFAULT_SHEET_URL;
  console.log(`✓ 시트 fetch: ${url}`);

  const csv = await fetchSheetCsv(url);

  // 백업 저장
  mkdirSync(dirname(BACKUP_CSV), { recursive: true });
  writeFileSync(BACKUP_CSV, csv, 'utf-8');

  const rows = parse(csv, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
  });

  const today = todayYmdSeoul();
  const ipos = [];
  let skipped = 0;
  for (const row of rows) {
    const ipo = rowToIpo(row, today);
    if (ipo) {
      ipos.push(ipo);
    } else {
      skipped++;
    }
  }

  // 정렬: subscription_start asc, company_name asc
  ipos.sort((a, b) => {
    const da = a.subscription_start ?? '';
    const db = b.subscription_start ?? '';
    if (da !== db) return da < db ? -1 : 1;
    return a.company_name.localeCompare(b.company_name, 'ko');
  });

  const result = {
    version: new Date().toISOString(),
    count: ipos.length,
    ipos,
  };

  mkdirSync(dirname(OUTPUT_JSON), { recursive: true });
  writeFileSync(OUTPUT_JSON, JSON.stringify(result, null, 2) + '\n', 'utf-8');

  console.log(
    `✓ 빌드 완료: ${OUTPUT_JSON} (${ipos.length}개 종목, skip ${skipped})`,
  );
}

main().catch((e) => {
  console.error(`[FATAL] ${e.message}`);
  process.exit(1);
});
