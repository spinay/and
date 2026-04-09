# IPO Keeper — Data Pipeline (Phase 0)

공모주 알리미 앱의 데이터 파이프라인. **백엔드/크롤러 없이** Google Sheet → JSON으로 운영합니다.

## 구성

```
data-pipeline/
├── seed/ipos-sheet.csv     ← 시트 raw 백업 (build 시 자동 덮어씀)
├── scripts/
│   ├── build.mjs           ← Sheet fetch → JSON 변환
│   └── validate.mjs        ← 결과 JSON 검증
├── data/ipos.json          ← 빌드 결과물 (앱이 fetch)
├── docs/
│   ├── SHEET_SCHEMA.md     ← 운영자용 스키마 명세
│   └── JSON_SCHEMA.md      ← 클라이언트용 JSON 명세
├── .github/workflows/
│   └── build.yml           ← cron(매일 KST 09시) + 수동 + scripts push 시 빌드
└── package.json
```

## 운영 흐름

1. Google Sheet 편집 (회사명/공모가/청약일/환불일/상장일/수요예측일/주관사/...)
2. 다음 중 하나로 빌드 트리거:
   - 자동: 매일 KST 09:00에 cron이 시트 fetch
   - 수동: GitHub Actions → "Build IPO data" → Run workflow
3. Action이 자동으로:
   - 시트 CSV fetch (`seed/ipos-sheet.csv`로 백업)
   - JSON 빌드 (`data/ipos.json`)
   - 검증
   - 결과 commit
4. Flutter 앱이 raw URL에서 fetch

> 시트 URL은 `scripts/build.mjs`의 `DEFAULT_SHEET_URL` 또는 `SHEET_CSV_URL` 환경변수.

## 로컬 개발

```sh
cd data-pipeline
npm install
npm run all   # build + validate
```

## 앱이 읽는 URL

push 후 다음 URL에서 fetch:
```
https://raw.githubusercontent.com/<USER>/<REPO>/main/data-pipeline/data/ipos.json
```

> Phase 0에서는 raw.githubusercontent가 충분합니다. CDN 캐싱(약 5분)이 자동으로 들어옵니다. 트래픽이 늘면 Cloudflare Pages 등으로 이전.

## 검증 항목

`scripts/validate.mjs`에서 자동 검증:

- 필수 필드 존재
- 날짜 형식 (YYYY-MM-DD)
- `subscription_end >= subscription_start`
- 가격 정합성 (band_low ≤ confirmed ≤ band_high)
- canonical_key 형식 + 중복 없음
- status enum 일치
- count 일치

검증 실패 → Action 실패 → JSON commit 안 됨. **잘못된 데이터가 절대 앱에 도달하지 않음.**

## 다음 단계

- Phase 0 검증 끝나면 → Phase 1: Express + Postgres 백엔드로 catalog 이관
- 사용자 데이터(청약기록 등)는 계속 앱 로컬 DB에 보관
- 크롤러는 가장 마지막 단계 (또는 영영 안 만들 수도 있음)
