import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/ipo.dart';

/// 공모주 catalog 데이터 저장소.
///
/// 책임:
/// - 원격 JSON 데이터를 fetch (data-pipeline이 GitHub에 배포한 ipos.json)
/// - 로컬 캐시 (SharedPreferences) 에 저장
/// - 네트워크 실패 시 캐시 폴백, 캐시도 없으면 assets 번들 폴백
/// - 사용자 데이터(청약기록·즐겨찾기)와는 무관 (그쪽은 personal DB)
///
/// [StateNotifier]로 노출해 state가 바뀌면 화면이 자동 재빌드된다.
/// 화면은 이 저장소를 직접 보지 않고 [IPORepository]를 통해서만 접근한다.
class CatalogRepository extends StateNotifier<List<IPO>> {
  CatalogRepository({Dio? dio})
      : _dio = dio ?? Dio(),
        super(const []);

  static const String remoteUrl =
      'https://raw.githubusercontent.com/spinay/and/main/data-pipeline/data/ipos.json';
  static const String _prefsKey = 'catalog.ipos.v1';
  static const String _assetPath = 'assets/data/ipos.json';

  final Dio _dio;
  String? _version;

  /// 읽기 전용 접근자. 화면 코드는 [ipoListProvider] 쪽을 watch하면 된다.
  List<IPO> get cache => state;
  String? get version => _version;

  /// 앱 시작 시 1회 호출. 캐시 → assets 폴백 순서로 즉시 데이터를 만든다.
  /// 네트워크는 건드리지 않는다 (느리므로).
  Future<void> load() async {
    // 1. SharedPreferences 캐시 시도
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_prefsKey);
      if (raw != null) {
        final parsed = _parsePayload(raw);
        if (parsed != null) {
          _apply(parsed);
          return;
        }
      }
    } catch (_) {
      // SharedPreferences 실패 → assets로 진행
    }

    // 2. assets 번들 폴백
    try {
      final raw = await rootBundle.loadString(_assetPath);
      final parsed = _parsePayload(raw);
      if (parsed != null) _apply(parsed);
    } catch (_) {
      // assets도 실패 → 빈 캐시 유지
    }
  }

  /// 네트워크에서 최신 catalog를 받아 캐시를 갱신한다.
  /// 실패 시 기존 캐시는 그대로 유지 (UI 깨지지 않음).
  /// 반환값: 새 데이터로 갱신됐으면 true.
  Future<bool> refresh() async {
    try {
      final res = await _dio.get<String>(
        remoteUrl,
        options: Options(
          responseType: ResponseType.plain,
          receiveTimeout: const Duration(seconds: 10),
          sendTimeout: const Duration(seconds: 10),
        ),
      );
      final body = res.data;
      if (body == null || body.isEmpty) return false;

      final parsed = _parsePayload(body);
      if (parsed == null) return false;

      // 같은 version이면 굳이 캐시 갱신 안 함
      if (parsed.version == _version) return false;

      _apply(parsed);

      // 캐시 저장 (실패해도 메모리는 이미 갱신됨)
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_prefsKey, body);
      } catch (_) {}

      return true;
    } catch (_) {
      return false;
    }
  }

  /// 캐시 무효화 (테스트/디버그용)
  Future<void> clearCache() async {
    state = const [];
    _version = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefsKey);
    } catch (_) {}
  }

  // ─── private ──────────────────────────────────────────────

  void _apply(_CatalogPayload payload) {
    state = payload.ipos;
    _version = payload.version;
  }

  _CatalogPayload? _parsePayload(String body) {
    try {
      final json = jsonDecode(body) as Map<String, dynamic>;
      final list = (json['ipos'] as List?) ?? const [];
      final ipos = list
          .whereType<Map<String, dynamic>>()
          .map((e) {
            try {
              return IPO.fromJson(e);
            } catch (_) {
              return null;
            }
          })
          .whereType<IPO>()
          .toList();
      return _CatalogPayload(
        version: json['version'] as String?,
        ipos: ipos,
      );
    } catch (_) {
      return null;
    }
  }
}

class _CatalogPayload {
  final String? version;
  final List<IPO> ipos;
  _CatalogPayload({required this.version, required this.ipos});
}

/// 앱 전역에서 공유하는 단일 인스턴스.
/// state가 바뀌면 이걸 watch하는 모든 화면이 자동 갱신된다.
final catalogRepositoryProvider =
    StateNotifierProvider<CatalogRepository, List<IPO>>(
  (ref) => CatalogRepository(),
);
