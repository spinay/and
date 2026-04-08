// CSV → JSON 빌드 스크립트
// 사용법: node scripts/build.mjs
// 입력: seed/ipos.csv
// 출력: data/ipos.json

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import { dirname } from 'node:path';
import { parse } from 'csv-parse/sync';

const INPUT = 'seed/ipos.csv';
const OUTPUT = 'data/ipos.json';

// 어떤 컬럼이 어느 타입인지
const INT_FIELDS = new Set([
  'price_band_low',
  'price_band_high',
  'confirmed_price',
  'min_subscription_qty',
]);
const FLOAT_FIELDS = new Set(['deposit_ratio', 'competition_rate']);
const ARRAY_FIELDS = new Set(['underwriters']);
const DATE_FIELDS = new Set([
  'demand_start',
  'demand_end',
  'subscription_start',
  'subscription_end',
  'refund_date',
  'listing_date',
]);

function coerce(field, raw) {
  // 빈 문자열은 null
  if (raw === undefined || raw === null || raw.trim() === '') {
    return ARRAY_FIELDS.has(field) ? [] : null;
  }
  const v = raw.trim();

  if (INT_FIELDS.has(field)) {
    const n = Number(v.replace(/,/g, ''));
    if (!Number.isFinite(n)) throw new Error(`${field}: 정수 변환 실패 '${v}'`);
    return Math.trunc(n);
  }

  if (FLOAT_FIELDS.has(field)) {
    const n = Number(v.replace(/,/g, ''));
    if (!Number.isFinite(n)) throw new Error(`${field}: 숫자 변환 실패 '${v}'`);
    return n;
  }

  if (ARRAY_FIELDS.has(field)) {
    return v.split(',').map((s) => s.trim()).filter(Boolean);
  }

  if (DATE_FIELDS.has(field)) {
    // CSV에서 'YYYY-MM-DD' 그대로 들어오면 패스. 다른 포맷도 허용.
    if (/^\d{4}-\d{2}-\d{2}$/.test(v)) return v;
    // YYYY/MM/DD 등도 허용
    const m = v.match(/^(\d{4})[./-](\d{1,2})[./-](\d{1,2})$/);
    if (m) {
      const [, y, mo, d] = m;
      return `${y}-${mo.padStart(2, '0')}-${d.padStart(2, '0')}`;
    }
    throw new Error(`${field}: 날짜 형식 인식 실패 '${v}'`);
  }

  return v;
}

function buildIpo(row) {
  const out = {};
  for (const [k, v] of Object.entries(row)) {
    try {
      out[k] = coerce(k, v);
    } catch (e) {
      throw new Error(`[${row.canonical_key ?? '(unknown)'}] ${e.message}`);
    }
  }
  // 필드 순서 고정 (diff 안정성)
  const ordered = {};
  const order = [
    'canonical_key',
    'company_name',
    'sector',
    'business_summary',
    'demand_start',
    'demand_end',
    'subscription_start',
    'subscription_end',
    'refund_date',
    'listing_date',
    'price_band_low',
    'price_band_high',
    'confirmed_price',
    'min_subscription_qty',
    'deposit_ratio',
    'underwriters',
    'status',
    'competition_rate',
    'dart_corp_code',
  ];
  for (const k of order) {
    if (k in out) ordered[k] = out[k];
  }
  return ordered;
}

function main() {
  const csv = readFileSync(INPUT, 'utf-8');
  const rows = parse(csv, {
    columns: true,
    skip_empty_lines: true,
    trim: true,
  });

  const ipos = rows.map(buildIpo);

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

  mkdirSync(dirname(OUTPUT), { recursive: true });
  writeFileSync(OUTPUT, JSON.stringify(result, null, 2) + '\n', 'utf-8');

  console.log(`✓ 빌드 완료: ${OUTPUT} (${ipos.length}개 종목)`);
}

main();
