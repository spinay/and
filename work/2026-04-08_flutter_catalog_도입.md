# Flutter Catalog 도입 (세션 1B-1)

> 작성일: 2026-04-08
> 목표: dummy_data.dart를 제거하고 catalog 데이터(원격 JSON)를 fetch + 캐시 + 폴백하는 구조로 교체

## GitHub repo

- spinay/and (public)
- raw URL: `https://raw.githubusercontent.com/spinay/and/main/data-pipeline/data/ipos.json`
- 200 응답 확인 완료

## 변경된 파일

### 신규
- `lib/data/repositories/catalog_repository.dart` — 3-tier 데이터 소스
  - L1: SharedPreferences 캐시 (`catalog.ipos.v1`)
  - L2: assets 번들 폴백 (`assets/data/ipos.json`)
  - L3: 네트워크 fetch (백그라운드 refresh)
- `assets/data/ipos.json` — data-pipeline/data/ipos.json의 번들 사본

### 수정
- `lib/data/models/ipo.dart`
  - `IPO.fromJson(Map<String, dynamic>)` 추가
  - `IPOStatusJson` extension (enum ↔ string 매핑)
  - id 필드의 의미를 canonical_key로 통일 (주석)
- `lib/data/repositories/ipo_repository.dart`
  - `CatalogRepository`를 의존
  - sync 인터페이스 그대로 유지 → **화면 코드 변경 0줄**
- `lib/data/repositories/watchlist_repository.dart`
  - 더미 set: `'ipo_2026_001'` → `'2026-04-14_클라우드원'`
- `lib/data/repositories/subscription_repository.dart`
  - 더미 ipoId 마이그레이션
  - `add()` 함수의 **중복 추가 버그 수정** (state가 두 번 갱신되던 문제)
- `lib/main.dart`
  - 앱 시작 시 `catalog.load()` await (캐시/assets 즉시 로드)
  - `catalog.refresh()` 백그라운드 fire-and-forget
  - ProviderScope에서 catalog 인스턴스 override
- `pubspec.yaml`
  - assets에 `assets/data/` 추가

### 삭제
- `lib/data/datasources/local/dummy_data.dart`
- 빈 폴더 정리: `lib/data/datasources/local/`, `lib/data/datasources/remote/`, `lib/data/datasources/`, `lib/data/dto/`

## 핵심 설계 결정

### 1. sync 인터페이스 유지 (화면 코드 변경 0)

`IPORepository.getAll()`은 여전히 동기적으로 `List<IPO>`를 반환한다. 내부적으로는 `CatalogRepository.cache`(메모리)를 보고, 네트워크 fetch는 백그라운드에서 캐시를 갱신한다. 덕분에 모든 화면 코드는 한 줄도 변경하지 않았다.

이 접근의 트레이드오프:
- 장점: 화면 코드 변경 0, 빠른 적용
- 단점: 백그라운드 refresh가 끝나도 화면이 자동으로 다시 그려지지 않음 (다음 빌드부터 반영)
- 1B-2에서 Riverpod state로 정식 연결 시 자연스럽게 해결됨

### 2. 3-tier 데이터 소스

```
load() 호출 시
 ├─ SharedPreferences 캐시 있나? → yes: 사용 (가장 빠름)
 └─ no → assets 번들 폴백 (즉시, 오프라인 OK)

refresh() 호출 시
 └─ 네트워크 fetch → 성공: cache + SharedPreferences 갱신
                  → 실패: 기존 캐시 유지 (UI 깨지지 않음)
```

### 3. canonical_key를 영구 ID로

`IPO.id` 필드의 의미를 `canonical_key`로 통일. 더미 데이터의 watchlist/subscription도 모두 새 형식으로 마이그레이션. 향후 사용자 데이터(청약기록 등)는 이 키로만 catalog와 연결되므로, JSON 갱신 후에도 안정적이다.

## 검증

- `flutter analyze` → **No issues found! (ran in 5.4s)**
- 빌드/런타임 검증은 다음 단계 (사용자가 직접 디바이스에서 확인)

## 다음 세션 (1B-2): Drift 도입 + Riverpod state 연결

### 해야 할 일
1. **Drift 스키마 작성**
   - `personal_db.dart`
   - 테이블: `WatchlistItems`, `SubscriptionRecords`
   - 모두 canonical_key를 외래 참조 (실제 FK는 없음, catalog는 별도 저장소)
2. **build_runner 실행** (`flutter pub run build_runner build`)
3. **WatchlistRepository, SubscriptionRepository를 Drift DAO로 교체**
   - 기존 더미 데이터는 첫 실행 시 시드로 INSERT
4. **CatalogRepository를 AsyncNotifier로 승격**
   - refresh 후 자동 화면 갱신
5. **빌드 + 디바이스 테스트**

## 현재 git 상태

이미 push되어 있음 (사용자가 spinay/and에 셋업). 이번 turn 변경사항은 아직 commit되지 않음.

다음 push 시 trigger될 GitHub Action: `data-pipeline/seed/**` 또는 `data-pipeline/scripts/**` 변경에만 반응하므로, Flutter 변경만 push해도 빌드 안 돌고 안전하다.
