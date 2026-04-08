// JSON 검증 스크립트
// 사용법: node scripts/validate.mjs data/ipos.json
// 실패 시 exit code 1로 종료해서 GitHub Action을 멈춥니다.

import { readFileSync } from 'node:fs';

const VALID_STATUS = new Set([
  'upcoming',
  'forecasting',
  'subscribing',
  'waitingListing',
  'listed',
  'closed',
]);

const REQUIRED_FIELDS = [
  'canonical_key',
  'company_name',
  'subscription_start',
  'subscription_end',
  'min_subscription_qty',
  'deposit_ratio',
  'underwriters',
  'status',
];

const errors = [];
const warnings = [];

function err(key, msg) {
  errors.push(`[${key}] ${msg}`);
}
function warn(key, msg) {
  warnings.push(`[${key}] ${msg}`);
}

function isYmd(s) {
  return typeof s === 'string' && /^\d{4}-\d{2}-\d{2}$/.test(s);
}

function parseYmd(s) {
  if (!isYmd(s)) return null;
  const [y, m, d] = s.split('-').map(Number);
  const dt = new Date(Date.UTC(y, m - 1, d));
  if (
    dt.getUTCFullYear() !== y ||
    dt.getUTCMonth() !== m - 1 ||
    dt.getUTCDate() !== d
  ) {
    return null;
  }
  return dt;
}

function validateOne(ipo) {
  const k = ipo.canonical_key ?? '(unknown)';

  // 필수 필드
  for (const f of REQUIRED_FIELDS) {
    const v = ipo[f];
    if (v === undefined || v === null || v === '' || (Array.isArray(v) && v.length === 0)) {
      err(k, `필수 필드 누락: ${f}`);
    }
  }

  // canonical_key 형식
  if (ipo.canonical_key && !/^\d{4}-\d{2}-\d{2}_.+/.test(ipo.canonical_key)) {
    err(k, `canonical_key 형식 오류: 'YYYY-MM-DD_이름' 형식이어야 함`);
  }

  // 날짜 필드
  const dateFields = [
    'demand_start',
    'demand_end',
    'subscription_start',
    'subscription_end',
    'refund_date',
    'listing_date',
  ];
  for (const f of dateFields) {
    if (ipo[f] != null && !isYmd(ipo[f])) {
      err(k, `${f} 날짜 형식 오류: '${ipo[f]}' (YYYY-MM-DD 필요)`);
    }
  }

  // sub_end >= sub_start
  const subStart = parseYmd(ipo.subscription_start);
  const subEnd = parseYmd(ipo.subscription_end);
  if (subStart && subEnd && subEnd < subStart) {
    err(k, `subscription_end가 subscription_start보다 빠름`);
  }

  // 청약시작일이 canonical_key의 날짜와 일치하는지
  if (ipo.canonical_key && ipo.subscription_start) {
    const keyDate = ipo.canonical_key.split('_')[0];
    if (keyDate !== ipo.subscription_start) {
      warn(k, `canonical_key 날짜(${keyDate})와 subscription_start(${ipo.subscription_start}) 불일치`);
    }
  }

  // 가격 검증
  const lo = ipo.price_band_low;
  const hi = ipo.price_band_high;
  const cf = ipo.confirmed_price;
  if (lo != null && hi != null && lo > hi) {
    err(k, `price_band_low(${lo}) > price_band_high(${hi})`);
  }
  if (cf != null && lo != null && cf < lo) {
    warn(k, `confirmed_price(${cf}) < price_band_low(${lo})`);
  }
  if (cf != null && hi != null && cf > hi) {
    warn(k, `confirmed_price(${cf}) > price_band_high(${hi})`);
  }
  for (const f of ['price_band_low', 'price_band_high', 'confirmed_price']) {
    if (ipo[f] != null && (!Number.isInteger(ipo[f]) || ipo[f] <= 0)) {
      err(k, `${f}는 양의 정수여야 함: ${ipo[f]}`);
    }
  }

  // status enum
  if (ipo.status && !VALID_STATUS.has(ipo.status)) {
    err(k, `status 값 오류: '${ipo.status}' (허용: ${[...VALID_STATUS].join(', ')})`);
  }

  // 청약수량/증거금률
  if (ipo.min_subscription_qty != null && (!Number.isInteger(ipo.min_subscription_qty) || ipo.min_subscription_qty <= 0)) {
    err(k, `min_subscription_qty는 양의 정수여야 함`);
  }
  if (ipo.deposit_ratio != null && (typeof ipo.deposit_ratio !== 'number' || ipo.deposit_ratio <= 0 || ipo.deposit_ratio > 1)) {
    err(k, `deposit_ratio는 0 < x <= 1: ${ipo.deposit_ratio}`);
  }

  // underwriters
  if (ipo.underwriters && !Array.isArray(ipo.underwriters)) {
    err(k, `underwriters는 배열이어야 함`);
  }
}

function main() {
  const path = process.argv[2] ?? 'data/ipos.json';
  let raw;
  try {
    raw = JSON.parse(readFileSync(path, 'utf-8'));
  } catch (e) {
    console.error(`[FATAL] JSON 파싱 실패: ${path}\n${e.message}`);
    process.exit(1);
  }

  if (!raw.ipos || !Array.isArray(raw.ipos)) {
    console.error(`[FATAL] ipos 배열 없음`);
    process.exit(1);
  }

  // 중복 키
  const seen = new Set();
  for (const ipo of raw.ipos) {
    if (seen.has(ipo.canonical_key)) {
      err(ipo.canonical_key, `중복된 canonical_key`);
    }
    seen.add(ipo.canonical_key);
  }

  // count 일치
  if (raw.count !== raw.ipos.length) {
    err('top', `count(${raw.count})와 ipos.length(${raw.ipos.length}) 불일치`);
  }

  // 각 종목 검증
  for (const ipo of raw.ipos) {
    validateOne(ipo);
  }

  // 결과 출력
  if (warnings.length > 0) {
    console.warn(`\n[WARN] ${warnings.length}건`);
    for (const w of warnings) console.warn('  ' + w);
  }

  if (errors.length > 0) {
    console.error(`\n[FAIL] ${errors.length}건의 검증 오류`);
    for (const e of errors) console.error('  ' + e);
    console.error(`\n${raw.ipos.length}개 종목 중 ${errors.length}건 실패\n`);
    process.exit(1);
  }

  console.log(`✓ 검증 통과 (${raw.ipos.length}개 종목)`);
}

main();
