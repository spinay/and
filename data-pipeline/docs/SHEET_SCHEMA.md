# Sheet 스키마 — 운영자용

> 매일 이 시트만 보면서 운영합니다. 시트를 CSV로 내보낸 뒤 `seed/ipos.csv`를 덮어쓰고 push 하면 GitHub Action이 JSON을 만들어 배포합니다.

## 컬럼 정의

| # | 컬럼명 | 한글명 | 타입 | 필수 | 예시 | 설명 |
|---|---|---|---|---|---|---|
| 1 | `canonical_key` | 식별키 | string | ✓ | `2026-04-14_클라우드원` | `청약시작일_종목명`. **절대 변경 금지** (앱의 청약기록이 이 키로 연결됨) |
| 2 | `company_name` | 종목명 | string | ✓ | `클라우드원` | 한글 종목명 |
| 3 | `sector` | 업종 | string | | `IT/소프트웨어` | 자유 텍스트 |
| 4 | `business_summary` | 사업요약 | string | | `기업용 SaaS...` | 1~2문장. 직접 작성 (출처 텍스트 그대로 복사 금지) |
| 5 | `demand_start` | 수요예측 시작 | date | | `2026-04-07` | YYYY-MM-DD |
| 6 | `demand_end` | 수요예측 종료 | date | | `2026-04-08` | |
| 7 | `subscription_start` | 청약 시작 | date | ✓ | `2026-04-14` | |
| 8 | `subscription_end` | 청약 종료 | date | ✓ | `2026-04-15` | `>= subscription_start` |
| 9 | `refund_date` | 환불일 | date | | `2026-04-17` | |
| 10 | `listing_date` | 상장일 | date | | `2026-04-21` | |
| 11 | `price_band_low` | 공모가 하단 | int | | `12000` | 원 단위, 콤마 없이 |
| 12 | `price_band_high` | 공모가 상단 | int | | `14000` | |
| 13 | `confirmed_price` | 확정 공모가 | int | | `13500` | 확정 후 입력 |
| 14 | `min_subscription_qty` | 최소청약수량 | int | ✓ | `10` | 보통 10 |
| 15 | `deposit_ratio` | 증거금률 | float | ✓ | `0.5` | 보통 0.5 (50%) |
| 16 | `underwriters` | 주간사 | string | ✓ | `미래에셋증권,NH투자증권` | 콤마 구분, 공백 없음 |
| 17 | `status` | 상태 | enum | ✓ | `subscribing` | 아래 enum 참고 |
| 18 | `competition_rate` | 경쟁률 | float | | `892.3` | 청약 종료 후 입력 (선택) |
| 19 | `dart_corp_code` | DART 기업코드 | string | | `00126380` | 검증용. 모르면 비워둠 |

## status enum

| 값 | 의미 | 언제 |
|---|---|---|
| `upcoming` | 청약 예정 | 수요예측 전 |
| `forecasting` | 수요예측 중 | 수요예측 시작~종료 |
| `subscribing` | 청약 중 | 청약 시작~종료 |
| `waitingListing` | 상장 대기 | 청약 종료~상장일 전 |
| `listed` | 상장 완료 | 상장일 이후 |
| `closed` | 종료 | 상장 1주일 후 등 운영자 판단 |

## 일일 운영 절차 (5분)

1. Google Sheet 열기
2. 신규 종목은 새 행 추가, 기존 종목 상태 변경은 해당 셀 수정
3. **`canonical_key`는 절대 손대지 않음**
4. `파일 → 다운로드 → CSV` 로 내보내기
5. 다운로드한 파일을 `data-pipeline/seed/ipos.csv`로 덮어쓰기
6. `git add seed/ipos.csv && git commit -m "data: update YYYY-MM-DD" && git push`
7. GitHub Action이 자동으로 JSON 빌드 & 배포 (1~2분)

## 절대 하지 말 것

- canonical_key 변경 (사용자 청약기록과의 연결이 끊김)
- business_summary에 외부 사이트 텍스트 복사 (저작권)
- 검증 실패한 PR을 강제 머지

## 검증되는 항목 (자동)

- 모든 필수 필드 존재
- 날짜 형식 (YYYY-MM-DD)
- `subscription_end >= subscription_start`
- `confirmed_price` 가 있으면 `price_band_low <= confirmed_price <= price_band_high`
- `canonical_key` 형식: `YYYY-MM-DD_이름`
- 중복 키 없음
- status 값이 enum에 포함됨
