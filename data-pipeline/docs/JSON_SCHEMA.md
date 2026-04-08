# JSON 출력 스키마 — Flutter 앱이 읽는 형식

빌드 결과: `data/ipos.json`

배포 위치 (Phase 0): GitHub raw URL
```
https://raw.githubusercontent.com/<user>/<repo>/main/data-pipeline/data/ipos.json
```

## 최상위 형태

```json
{
  "version": "2026-04-08T15:30:00.000Z",
  "count": 5,
  "ipos": [ /* IPO[] */ ]
}
```

| 필드 | 타입 | 설명 |
|---|---|---|
| `version` | ISO timestamp | 빌드 시각. 클라이언트가 이걸 기준으로 캐시 무효화 |
| `count` | int | `ipos.length` (검증 편의용) |
| `ipos` | IPO[] | 전체 종목 |

## IPO 객체

```json
{
  "canonical_key": "2026-04-14_클라우드원",
  "company_name": "클라우드원",
  "sector": "IT/소프트웨어",
  "business_summary": "기업용 SaaS 솔루션 전문기업...",
  "demand_start": "2026-04-07",
  "demand_end": "2026-04-08",
  "subscription_start": "2026-04-14",
  "subscription_end": "2026-04-15",
  "refund_date": "2026-04-17",
  "listing_date": "2026-04-21",
  "price_band_low": 12000,
  "price_band_high": 14000,
  "confirmed_price": 13500,
  "min_subscription_qty": 10,
  "deposit_ratio": 0.5,
  "underwriters": ["미래에셋증권", "NH투자증권"],
  "status": "subscribing",
  "competition_rate": 892.3,
  "dart_corp_code": null
}
```

## 규칙

- 모든 키는 **snake_case**
- 날짜는 **`YYYY-MM-DD` 문자열** (Dart에서 `DateTime.parse` 가능)
- 빈 값은 `null` (CSV의 빈 셀 → null로 변환)
- `underwriters`만 string[]. CSV의 콤마 구분 문자열을 배열로 분해
- 정렬: `subscription_start` 오름차순, 같으면 `company_name`

## 클라이언트 캐싱 가이드

1. 처음: fetch → SharedPreferences에 `version` + JSON 통째 저장
2. 다음 fetch: `version` 비교, 같으면 캐시 사용
3. 네트워크 실패: 마지막 캐시 사용 (오프라인 동작)
4. 파싱 실패: 캐시 보존, 사용자에게는 조용히 실패 (앱 죽이지 않음)
