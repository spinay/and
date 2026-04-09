# 작업 완료 보고서

**작업일**: 2026-04-10
**프로젝트**: IPO Keeper (공모주 알리미 앱)

---

## 완료된 작업 요약

| 항목 | 상태 | 비고 |
|------|------|------|
| 1D-1: Release APK 빌드 | ✅ 완료 | 59MB, `~/Desktop/ipo_keeper.apk` |
| 1D-2-a: Sheet → JSON 빌드 스크립트 교체 | ✅ 완료 | `data-pipeline/scripts/build.mjs` |
| 1D-2-b: 17건 실제 공모주 데이터 빌드 + validate 통과 | ✅ 완료 | `data/ipos.json` |
| 1D-2-c: workflow cron(매일 KST 09시) + 수동 트리거 | ✅ 완료 | `.github/workflows/build.yml` |
| 1D-2-d: 앱 assets 폴백 번들 갱신 | ✅ 완료 | `assets/data/ipos.json` |
| 1D-2-e: legacy `seed/ipos.csv` 제거 + README 업데이트 | ✅ 완료 | — |

---

## 상세 내용

### 1D-1. Release APK 빌드
- `flutter build apk --release` 성공 (61.9MB)
- `~/Desktop/ipo_keeper.apk`로 복사 (59MB) — 실 디바이스 설치 준비

### 1D-2-a. Sheet → JSON 빌드 스크립트 교체
**파일**: `data-pipeline/scripts/build.mjs` (전면 재작성)

기존: `seed/ipos.csv` 더미 5건을 읽어 JSON 변환
변경: Google Sheet CSV export URL을 직접 fetch → 시트 컬럼 → 앱 catalog 포맷으로 변환

**시트 컬럼 → catalog 매핑**:
- 회사명 → `company_name`
- 청약일 → `subscription_start`, `subscription_end = +1일` (시트는 단일 날짜만)
- 환불일/상장일/수요예측일 → 그대로
- 공모가 → `confirmed_price`
- 최소청약수량 → `min_subscription_qty` (비어있으면 10)
- 주관사 → 축약명("삼성","미래","NH"…) → 풀네임 매핑 (15개 증권사 사전)
- 업종 → `sector`
- canonical_key 자동생성 (`{청약일}_{회사명}`)
- "배정안됨"/"정산일"/"종목코드"는 개인 메모 컬럼이라 catalog에서 제외

**파싱 처리**:
- 한국식 날짜 `2025년 12월 16일` → `2025-12-16`
- 화살표 표기 `2026년 5월 11일 → 2026년 5월 15일` → 마지막 날짜 채택
- 빈 회사명/빈 청약일 행 자동 skip
- KST 기준 today와 비교해 status 자동 결정 (활성 → upcoming/forecasting/subscribing/waitingListing/listed/closed)

**환경변수**: `SHEET_CSV_URL`로 URL 오버라이드 가능 (기본값 하드코딩)

**부수효과**: `seed/ipos-sheet.csv`로 시트 raw 백업도 동시에 저장 (롤백/diff용)

### 1D-2-b. 빌드 + validate 통과
- 17건 변환 성공 (시트 19행 - 빈 행 2개)
- `validate.mjs` 검증 통과 — canonical_key 형식, 날짜 정합성, status enum 등 모두 OK
- 결과 검증 (오늘 2026-04-10 기준):
  - 케이뱅크/리브스메드/카나프테라퓨틱스 등 → `listed`
  - 채비(수요예측 시작 4/10) → `forecasting`
  - 코스모로보틱스/마키나락스/폴레드/피스피스 → `upcoming`

### 1D-2-c. workflow 트리거 변경
**파일**: `data-pipeline/.github/workflows/build.yml`

```yaml
on:
  push:
    branches: [main]
    paths:
      - 'data-pipeline/scripts/**'
      - 'data-pipeline/.github/workflows/build.yml'
  schedule:
    - cron: '0 0 * * *'   # 매일 KST 09:00 (UTC 00:00)
  workflow_dispatch:
```

- `seed/**` paths 트리거 제거 (이제 시트가 source)
- cron으로 매일 자동 동기화
- commit 대상에 `seed/ipos-sheet.csv` (백업) 추가

### 1D-2-d. 앱 assets 번들 갱신
- `ipo_keeper/assets/data/ipos.json`에 새 17건 JSON 복사
- 첫 실행 + 네트워크 장애 시 폴백으로 사용됨

### 1D-2-e. 정리
- `data-pipeline/seed/ipos.csv` (구 더미 5건) 삭제 — 더 이상 build에서 안 읽음
- `README.md` 업데이트 — Sheet 기반 운영 흐름으로 다시 작성

---

## 미해결 / 후속 과제

- **sector 필드**: 시트의 "업종" 컬럼이 모두 "IPO"로 채워져 있음 — 운영자가 시트에서 실제 업종 분류 채워넣을 수 있음
- **business_summary**: 시트에 컬럼 없음 — 필요해지면 시트 컬럼 추가하거나 별도 입력 UI
- **수요예측 종료일**: 시트는 시작일만 — 필요하면 컬럼 추가
- **subscription_end 추정 (+1일)**: 일부 종목은 청약 기간이 다를 수 있음 — 시트에 종료일 컬럼 추가하면 정확해짐

---

## 커밋 이력

이 세션의 변경은 아직 커밋되지 않음. 사용자 승인 대기 중.

변경 파일:
- `data-pipeline/scripts/build.mjs` (재작성)
- `data-pipeline/.github/workflows/build.yml` (트리거 변경)
- `data-pipeline/README.md` (운영 흐름 갱신)
- `data-pipeline/data/ipos.json` (17건 신규)
- `data-pipeline/seed/ipos-sheet.csv` (시트 백업, 신규)
- `data-pipeline/seed/ipos.csv` (삭제)
- `ipo_keeper/assets/data/ipos.json` (17건 갱신)
