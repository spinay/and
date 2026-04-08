# Data Pipeline Phase 0 셋업 완료

> 작성일: 2026-04-08
> 목표: 백엔드/크롤러 없이 CSV → JSON 빌드 파이프라인 구축

## 만든 것

`/Users/mii/Documents/IPO/and/data-pipeline/` 디렉토리 신설.

```
data-pipeline/
├── seed/ipos.csv              ← 운영 입력 (5개 시드)
├── scripts/
│   ├── build.mjs              ← CSV → JSON 변환
│   └── validate.mjs           ← 결과 JSON 검증
├── data/ipos.json             ← 빌드 결과물 (앱이 fetch)
├── docs/
│   ├── SHEET_SCHEMA.md        ← 운영자용 컬럼 명세
│   └── JSON_SCHEMA.md         ← 클라이언트용 JSON 명세
├── .github/workflows/build.yml ← push 시 자동 빌드 + 커밋
├── package.json
├── .gitignore
└── README.md
```

## 핵심 결정 사항

1. **CSV-in-repo 방식 선택** (Sheet API 직접 호출 X)
   - 이유: secrets 셋업 불필요, 단순함, 운영자가 매일 5분 작업 가능
   - 흐름: Sheet 편집 → CSV 다운로드 → seed/ipos.csv 덮어쓰기 → push → Action이 JSON 빌드

2. **canonical_key 도입**: `YYYY-MM-DD_종목명` 형식
   - 사용자 청약기록의 영구 연결키
   - 현재 dummy_data의 `id` (예: `ipo_2026_001`)를 모두 canonical_key로 마이그레이션

3. **검증 게이트가 곧 미니 CMS**
   - 필수 필드, 날짜 형식, sub_end >= sub_start, 가격 정합성, canonical_key 형식, 중복 키, status enum, count 일치
   - 검증 실패 → Action 실패 → JSON commit 안 됨 → 잘못된 데이터가 앱에 도달 불가

4. **배포 = GitHub raw URL**
   - Phase 0에서는 raw.githubusercontent로 충분 (CDN 캐싱 자동)
   - 트래픽 늘면 Cloudflare Pages로 이전

5. **JSON 출력 규칙**
   - snake_case (Dart는 fromJson에서 camelCase로 매핑)
   - 날짜는 `YYYY-MM-DD` 문자열 (DateTime.parse 가능)
   - 빈 값은 `null`, underwriters만 `string[]`
   - 정렬: subscription_start asc, company_name asc

## 검증 결과

```
✓ 빌드 완료: data/ipos.json (5개 종목)
✓ 검증 통과 (5개 종목)
```

5개 시드 종목 모두 정상 빌드. 기존 dummy_data와 동일한 데이터로 대체.

## 다음 세션 (1B): Flutter 앱 변경

### 해야 할 일
1. **IPO 모델에 fromJson 추가** (`lib/data/models/ipo.dart`)
   - snake_case JSON → camelCase Dart 매핑
   - canonical_key를 id로 사용하도록 교체
2. **CatalogRepository 신설** (`lib/data/repositories/catalog_repository.dart`)
   - dio로 raw URL fetch
   - SharedPreferences에 version + JSON 캐시
   - 네트워크 실패 시 캐시 폴백
3. **dummy_data.dart 제거 및 IPORepository 교체**
   - getAll() → CatalogRepository에서 받기
4. **로컬 DB 분리** (`lib/data/local/personal_db.dart`)
   - Drift로 watchlist + subscription_record 테이블
   - canonical_key를 외래키로 사용 (catalog 갱신과 무관하게 살아남음)

### 아직 미정인 것
- GitHub repo 이름/URL: 사용자가 정해서 raw URL을 결정해야 함
- 그 전까지는 catalog_repository에 임시 URL 또는 로컬 assets로 fallback

## 운영 시작 체크리스트 (사용자가 직접 해야 할 것)

- [ ] `/Users/mii/Documents/IPO/and/`를 git repo로 만들기 (`git init`)
- [ ] GitHub에 private repo 생성 후 push
- [ ] Actions 권한 설정 (Settings → Actions → General → Workflow permissions = Read and write)
- [ ] raw URL 확인: `https://raw.githubusercontent.com/<USER>/<REPO>/main/data-pipeline/data/ipos.json`
- [ ] 그 URL을 다음 세션에서 catalog_repository에 박아넣기

## 운영 절차 (반복)

매일 (또는 신규 종목 발견 시):
1. Google Sheet 편집 (또는 직접 CSV 편집)
2. CSV 다운로드 → `seed/ipos.csv` 덮어쓰기
3. `git commit && git push`
4. 1~2분 후 자동 배포 완료
