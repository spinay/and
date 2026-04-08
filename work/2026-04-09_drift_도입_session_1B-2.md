# Session 1B-2: Drift 도입 + Riverpod state 정식 연결

> 작성일: 2026-04-09
> 목표: WatchlistRepository / SubscriptionRepository를 Drift로 교체하고, CatalogRepository를 StateNotifier로 승격해 refresh 후 UI가 자동 갱신되게 만든다.

## 변경 파일

### 신규
- `lib/data/local/personal_db.dart` — Drift 스키마
  - 테이블: `WatchlistItems`, `SubscriptionRecords`
  - 둘 다 canonical_key로 catalog 참조 (실제 FK는 없음)
  - DAO 메서드: watch/get/add/remove/insert/update/delete
- `lib/data/local/personal_db.g.dart` — build_runner 자동 생성 (54KB)
- `lib/data/repositories/personal_db_provider.dart` — 전역 DB provider (main.dart에서 override)

### 수정
- `lib/data/repositories/watchlist_repository.dart`
  - `StateNotifier<Set<String>>` → 일반 class + Drift DAO 호출
  - `watchlistProvider`는 `StreamProvider<Set<String>>`로 변경 (자동 갱신)
  - `isWatchedProvider`는 AsyncValue의 `maybeWhen`으로 처리
- `lib/data/repositories/subscription_repository.dart`
  - `StateNotifier<List<Subscription>>` → Drift 기반 class
  - `SubscriptionRow` ↔ `Subscription` 매퍼 내부 구현
  - 새로운 `subscriptionListProvider` (StreamProvider) 추가
  - 기존 `subscriptionRepositoryProvider`는 repository 핸들만 노출
  - 더미 시드는 main.dart로 이동
- `lib/data/repositories/catalog_repository.dart`
  - 일반 class → `StateNotifier<List<IPO>>` 승격
  - `load()` / `refresh()` 내부에서 `state = ...`로 알림
  - `catalogRepositoryProvider`를 StateNotifierProvider로 변경
  - 효과: **refresh 후 watch 중인 화면이 자동 재빌드**
- `lib/data/repositories/ipo_repository.dart`
  - `CatalogRepository` 직접 참조 → `ref.watch(catalogRepositoryProvider)` state 수신
  - catalog state가 바뀌면 이 하위 provider들도 자동 재계산
- `lib/main.dart`
  - `PersonalDb()` 인스턴스 생성 + `_seedIfEmpty()` 호출
  - `catalogRepositoryProvider`, `personalDbProvider` 두 개 override
- 화면 코드 수정 (3개 파일, 5줄)
  - `ipo_detail_screen.dart`: `watchlistProvider.notifier.toggle()` → `watchlistRepositoryProvider.toggle()`
  - `ipo_list_screen.dart`: 동일
  - `home_screen.dart` / `my_ipo_screen.dart` / `profit_screen.dart`: `ref.watch(subscriptionRepositoryProvider)` → `ref.watch(subscriptionListProvider).valueOrNull ?? const <Subscription>[]`

## 핵심 설계 결정

### 1. Catalog는 StateNotifier, Personal은 Stream
- **Catalog**: 데이터 소스가 JSON(동기 메모리)이라 `StateNotifier<List<IPO>>`가 가장 자연스러움. `state = payload.ipos` 한 줄로 UI 전파.
- **Personal**: Drift는 reactive query (`watch()`)를 네이티브로 지원하므로 `StreamProvider` + Drift watch가 가장 깨끗함. 추가 레이어 없음.

### 2. canonical_key는 일급 외래키
`WatchlistItems.canonicalKey`, `SubscriptionRecords.ipoId`가 모두 같은 canonical_key 형식. catalog가 원격에서 재배포돼도 personal DB는 이 키로만 참조하므로 영향 없음. Day 1 원칙 관철.

### 3. ipoName 스냅샷
`SubscriptionRecords.ipoName`은 청약 당시의 이름을 복사 저장. catalog에서 종목명이 변경되거나 종목 자체가 삭제돼도 "내가 청약했던 그때 이름"을 유지.

### 4. 화면 코드 최소 변경
- 관심종목 toggle: 3줄만 수정 (`.notifier` → `Repository` 직접 호출)
- 청약 리스트: 3줄만 수정 (`List<Subscription>` → `AsyncValue<...>.valueOrNull ?? []`)
- catalog watch: **0줄 수정** (StateNotifierProvider로 바꿔도 `ref.watch` 결과 타입은 동일)

### 5. 시드 로직은 일시적
`main.dart._seedIfEmpty()`는 개발/데모용. 1C에서 "청약 기록 추가" UX가 들어오면 제거 예정.

## 검증

- `flutter analyze` → **No issues found! (ran in 4.3s)**
- `flutter build macos --debug` → 빌드 성공
- 앱 실행 → 크래시 없음, Flutter/Drift 에러 로그 없음
- **SQLite 직접 검증**:
  ```
  $ sqlite3 ~/Library/Containers/com.ipokeeper.ipoKeeper/Data/Documents/personal_db.sqlite ".tables"
  subscription_records  watchlist_items
  
  $ sqlite3 ... "SELECT * FROM watchlist_items;"
  2026-04-14_클라우드원|1775689247
  2026-04-16_바이오넥스트|1775689247
  
  $ sqlite3 ... "SELECT id, ipo_id, ipo_name, status FROM subscription_records;"
  1|2026-04-07_그린에너지솔루션|그린에너지솔루션|refunded
  2|2026-04-14_클라우드원|클라우드원|applied
  ```

## 다음 세션 (1C): 핵심 UX

1. **오늘 할 일 카드 고도화**
   - 청약 시작/마감/환불/상장 이벤트를 분류해서 카드로 표시
   - "청약기록 추가하기" CTA 연결
2. **청약 기록 추가/수정 화면**
   - 현재는 시드로만 들어있고, 사용자가 만들 수 없음
   - 종목 선택 → 증권사 → 청약 수량 → 증거금 → 저장
3. **상태 자동 전이**
   - 환불일 지나면 applied → refunded
   - 상장일 지나면 refunded → listed
4. **로컬 알림**
   - 청약 시작 D-1, 환불일 당일, 상장일 당일
   - `flutter_local_notifications` + `timezone` 이미 설치됨
5. **수익 누적 카드**
   - `profit_screen.dart` 보강, 월별 차트

## 현재 git 상태

이번 세션 변경사항(1B-2)은 아직 commit되지 않음.
1B-1은 이전 세션에서도 commit 안 한 상태이므로, 지금 한 번에 커밋할 것인지 분리할 것인지 확인 필요.
