# IPO Keeper — Data Pipeline (Phase 0)

공모주 알리미 앱의 데이터 파이프라인. **백엔드/크롤러 없이** Google Sheet → CSV → JSON으로 운영합니다.

## 구성

```
data-pipeline/
├── seed/ipos.csv           ← 운영자가 매일 갱신하는 입력
├── scripts/
│   ├── build.mjs           ← CSV → JSON 변환
│   └── validate.mjs        ← 결과 JSON 검증
├── data/ipos.json          ← 빌드 결과물 (앱이 fetch)
├── docs/
│   ├── SHEET_SCHEMA.md     ← 운영자용 스키마 명세
│   └── JSON_SCHEMA.md      ← 클라이언트용 JSON 명세
├── .github/workflows/
│   └── build.yml           ← push 시 자동 빌드 + 커밋
└── package.json
```

## 운영 흐름

1. Google Sheet 편집 (또는 직접 `seed/ipos.csv` 편집)
2. Sheet → CSV 다운로드 → `seed/ipos.csv`로 덮어쓰기
3. `git commit && git push`
4. GitHub Action이 자동으로:
   - JSON 빌드 (`data/ipos.json`)
   - 검증
   - 결과 commit
5. Flutter 앱이 raw URL에서 fetch

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
