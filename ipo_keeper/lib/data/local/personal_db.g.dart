// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'personal_db.dart';

// ignore_for_file: type=lint
class $WatchlistItemsTable extends WatchlistItems
    with TableInfo<$WatchlistItemsTable, WatchlistItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WatchlistItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _canonicalKeyMeta = const VerificationMeta(
    'canonicalKey',
  );
  @override
  late final GeneratedColumn<String> canonicalKey = GeneratedColumn<String>(
    'canonical_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  @override
  List<GeneratedColumn> get $columns => [canonicalKey, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'watchlist_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<WatchlistItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('canonical_key')) {
      context.handle(
        _canonicalKeyMeta,
        canonicalKey.isAcceptableOrUnknown(
          data['canonical_key']!,
          _canonicalKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_canonicalKeyMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {canonicalKey};
  @override
  WatchlistItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WatchlistItem(
      canonicalKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}canonical_key'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $WatchlistItemsTable createAlias(String alias) {
    return $WatchlistItemsTable(attachedDatabase, alias);
  }
}

class WatchlistItem extends DataClass implements Insertable<WatchlistItem> {
  final String canonicalKey;
  final DateTime createdAt;
  const WatchlistItem({required this.canonicalKey, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['canonical_key'] = Variable<String>(canonicalKey);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  WatchlistItemsCompanion toCompanion(bool nullToAbsent) {
    return WatchlistItemsCompanion(
      canonicalKey: Value(canonicalKey),
      createdAt: Value(createdAt),
    );
  }

  factory WatchlistItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WatchlistItem(
      canonicalKey: serializer.fromJson<String>(json['canonicalKey']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'canonicalKey': serializer.toJson<String>(canonicalKey),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  WatchlistItem copyWith({String? canonicalKey, DateTime? createdAt}) =>
      WatchlistItem(
        canonicalKey: canonicalKey ?? this.canonicalKey,
        createdAt: createdAt ?? this.createdAt,
      );
  WatchlistItem copyWithCompanion(WatchlistItemsCompanion data) {
    return WatchlistItem(
      canonicalKey: data.canonicalKey.present
          ? data.canonicalKey.value
          : this.canonicalKey,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItem(')
          ..write('canonicalKey: $canonicalKey, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(canonicalKey, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WatchlistItem &&
          other.canonicalKey == this.canonicalKey &&
          other.createdAt == this.createdAt);
}

class WatchlistItemsCompanion extends UpdateCompanion<WatchlistItem> {
  final Value<String> canonicalKey;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const WatchlistItemsCompanion({
    this.canonicalKey = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WatchlistItemsCompanion.insert({
    required String canonicalKey,
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : canonicalKey = Value(canonicalKey);
  static Insertable<WatchlistItem> custom({
    Expression<String>? canonicalKey,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (canonicalKey != null) 'canonical_key': canonicalKey,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WatchlistItemsCompanion copyWith({
    Value<String>? canonicalKey,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return WatchlistItemsCompanion(
      canonicalKey: canonicalKey ?? this.canonicalKey,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (canonicalKey.present) {
      map['canonical_key'] = Variable<String>(canonicalKey.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WatchlistItemsCompanion(')
          ..write('canonicalKey: $canonicalKey, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionRecordsTable extends SubscriptionRecords
    with TableInfo<$SubscriptionRecordsTable, SubscriptionRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _ipoIdMeta = const VerificationMeta('ipoId');
  @override
  late final GeneratedColumn<String> ipoId = GeneratedColumn<String>(
    'ipo_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ipoNameMeta = const VerificationMeta(
    'ipoName',
  );
  @override
  late final GeneratedColumn<String> ipoName = GeneratedColumn<String>(
    'ipo_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _brokerMeta = const VerificationMeta('broker');
  @override
  late final GeneratedColumn<String> broker = GeneratedColumn<String>(
    'broker',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _appliedQtyMeta = const VerificationMeta(
    'appliedQty',
  );
  @override
  late final GeneratedColumn<int> appliedQty = GeneratedColumn<int>(
    'applied_qty',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _depositAmountMeta = const VerificationMeta(
    'depositAmount',
  );
  @override
  late final GeneratedColumn<int> depositAmount = GeneratedColumn<int>(
    'deposit_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _allocatedQtyMeta = const VerificationMeta(
    'allocatedQty',
  );
  @override
  late final GeneratedColumn<int> allocatedQty = GeneratedColumn<int>(
    'allocated_qty',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _refundAmountMeta = const VerificationMeta(
    'refundAmount',
  );
  @override
  late final GeneratedColumn<int> refundAmount = GeneratedColumn<int>(
    'refund_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellPriceMeta = const VerificationMeta(
    'sellPrice',
  );
  @override
  late final GeneratedColumn<int> sellPrice = GeneratedColumn<int>(
    'sell_price',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sellQtyMeta = const VerificationMeta(
    'sellQty',
  );
  @override
  late final GeneratedColumn<int> sellQty = GeneratedColumn<int>(
    'sell_qty',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profitAmountMeta = const VerificationMeta(
    'profitAmount',
  );
  @override
  late final GeneratedColumn<int> profitAmount = GeneratedColumn<int>(
    'profit_amount',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _profitRateMeta = const VerificationMeta(
    'profitRate',
  );
  @override
  late final GeneratedColumn<double> profitRate = GeneratedColumn<double>(
    'profit_rate',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _memoMeta = const VerificationMeta('memo');
  @override
  late final GeneratedColumn<String> memo = GeneratedColumn<String>(
    'memo',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    ipoId,
    ipoName,
    broker,
    appliedQty,
    depositAmount,
    allocatedQty,
    refundAmount,
    sellPrice,
    sellQty,
    profitAmount,
    profitRate,
    status,
    memo,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('ipo_id')) {
      context.handle(
        _ipoIdMeta,
        ipoId.isAcceptableOrUnknown(data['ipo_id']!, _ipoIdMeta),
      );
    } else if (isInserting) {
      context.missing(_ipoIdMeta);
    }
    if (data.containsKey('ipo_name')) {
      context.handle(
        _ipoNameMeta,
        ipoName.isAcceptableOrUnknown(data['ipo_name']!, _ipoNameMeta),
      );
    } else if (isInserting) {
      context.missing(_ipoNameMeta);
    }
    if (data.containsKey('broker')) {
      context.handle(
        _brokerMeta,
        broker.isAcceptableOrUnknown(data['broker']!, _brokerMeta),
      );
    }
    if (data.containsKey('applied_qty')) {
      context.handle(
        _appliedQtyMeta,
        appliedQty.isAcceptableOrUnknown(data['applied_qty']!, _appliedQtyMeta),
      );
    }
    if (data.containsKey('deposit_amount')) {
      context.handle(
        _depositAmountMeta,
        depositAmount.isAcceptableOrUnknown(
          data['deposit_amount']!,
          _depositAmountMeta,
        ),
      );
    }
    if (data.containsKey('allocated_qty')) {
      context.handle(
        _allocatedQtyMeta,
        allocatedQty.isAcceptableOrUnknown(
          data['allocated_qty']!,
          _allocatedQtyMeta,
        ),
      );
    }
    if (data.containsKey('refund_amount')) {
      context.handle(
        _refundAmountMeta,
        refundAmount.isAcceptableOrUnknown(
          data['refund_amount']!,
          _refundAmountMeta,
        ),
      );
    }
    if (data.containsKey('sell_price')) {
      context.handle(
        _sellPriceMeta,
        sellPrice.isAcceptableOrUnknown(data['sell_price']!, _sellPriceMeta),
      );
    }
    if (data.containsKey('sell_qty')) {
      context.handle(
        _sellQtyMeta,
        sellQty.isAcceptableOrUnknown(data['sell_qty']!, _sellQtyMeta),
      );
    }
    if (data.containsKey('profit_amount')) {
      context.handle(
        _profitAmountMeta,
        profitAmount.isAcceptableOrUnknown(
          data['profit_amount']!,
          _profitAmountMeta,
        ),
      );
    }
    if (data.containsKey('profit_rate')) {
      context.handle(
        _profitRateMeta,
        profitRate.isAcceptableOrUnknown(data['profit_rate']!, _profitRateMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    } else if (isInserting) {
      context.missing(_statusMeta);
    }
    if (data.containsKey('memo')) {
      context.handle(
        _memoMeta,
        memo.isAcceptableOrUnknown(data['memo']!, _memoMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      ipoId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipo_id'],
      )!,
      ipoName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ipo_name'],
      )!,
      broker: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}broker'],
      ),
      appliedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_qty'],
      ),
      depositAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}deposit_amount'],
      ),
      allocatedQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}allocated_qty'],
      ),
      refundAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}refund_amount'],
      ),
      sellPrice: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_price'],
      ),
      sellQty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sell_qty'],
      ),
      profitAmount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}profit_amount'],
      ),
      profitRate: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}profit_rate'],
      ),
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      memo: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}memo'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SubscriptionRecordsTable createAlias(String alias) {
    return $SubscriptionRecordsTable(attachedDatabase, alias);
  }
}

class SubscriptionRow extends DataClass implements Insertable<SubscriptionRow> {
  final int id;
  final String ipoId;
  final String ipoName;
  final String? broker;
  final int? appliedQty;
  final int? depositAmount;
  final int? allocatedQty;
  final int? refundAmount;
  final int? sellPrice;
  final int? sellQty;
  final int? profitAmount;
  final double? profitRate;

  /// [SubscriptionStatus.name] 값 그대로 저장
  final String status;
  final String? memo;
  final DateTime createdAt;
  const SubscriptionRow({
    required this.id,
    required this.ipoId,
    required this.ipoName,
    this.broker,
    this.appliedQty,
    this.depositAmount,
    this.allocatedQty,
    this.refundAmount,
    this.sellPrice,
    this.sellQty,
    this.profitAmount,
    this.profitRate,
    required this.status,
    this.memo,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['ipo_id'] = Variable<String>(ipoId);
    map['ipo_name'] = Variable<String>(ipoName);
    if (!nullToAbsent || broker != null) {
      map['broker'] = Variable<String>(broker);
    }
    if (!nullToAbsent || appliedQty != null) {
      map['applied_qty'] = Variable<int>(appliedQty);
    }
    if (!nullToAbsent || depositAmount != null) {
      map['deposit_amount'] = Variable<int>(depositAmount);
    }
    if (!nullToAbsent || allocatedQty != null) {
      map['allocated_qty'] = Variable<int>(allocatedQty);
    }
    if (!nullToAbsent || refundAmount != null) {
      map['refund_amount'] = Variable<int>(refundAmount);
    }
    if (!nullToAbsent || sellPrice != null) {
      map['sell_price'] = Variable<int>(sellPrice);
    }
    if (!nullToAbsent || sellQty != null) {
      map['sell_qty'] = Variable<int>(sellQty);
    }
    if (!nullToAbsent || profitAmount != null) {
      map['profit_amount'] = Variable<int>(profitAmount);
    }
    if (!nullToAbsent || profitRate != null) {
      map['profit_rate'] = Variable<double>(profitRate);
    }
    map['status'] = Variable<String>(status);
    if (!nullToAbsent || memo != null) {
      map['memo'] = Variable<String>(memo);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SubscriptionRecordsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionRecordsCompanion(
      id: Value(id),
      ipoId: Value(ipoId),
      ipoName: Value(ipoName),
      broker: broker == null && nullToAbsent
          ? const Value.absent()
          : Value(broker),
      appliedQty: appliedQty == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedQty),
      depositAmount: depositAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(depositAmount),
      allocatedQty: allocatedQty == null && nullToAbsent
          ? const Value.absent()
          : Value(allocatedQty),
      refundAmount: refundAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(refundAmount),
      sellPrice: sellPrice == null && nullToAbsent
          ? const Value.absent()
          : Value(sellPrice),
      sellQty: sellQty == null && nullToAbsent
          ? const Value.absent()
          : Value(sellQty),
      profitAmount: profitAmount == null && nullToAbsent
          ? const Value.absent()
          : Value(profitAmount),
      profitRate: profitRate == null && nullToAbsent
          ? const Value.absent()
          : Value(profitRate),
      status: Value(status),
      memo: memo == null && nullToAbsent ? const Value.absent() : Value(memo),
      createdAt: Value(createdAt),
    );
  }

  factory SubscriptionRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionRow(
      id: serializer.fromJson<int>(json['id']),
      ipoId: serializer.fromJson<String>(json['ipoId']),
      ipoName: serializer.fromJson<String>(json['ipoName']),
      broker: serializer.fromJson<String?>(json['broker']),
      appliedQty: serializer.fromJson<int?>(json['appliedQty']),
      depositAmount: serializer.fromJson<int?>(json['depositAmount']),
      allocatedQty: serializer.fromJson<int?>(json['allocatedQty']),
      refundAmount: serializer.fromJson<int?>(json['refundAmount']),
      sellPrice: serializer.fromJson<int?>(json['sellPrice']),
      sellQty: serializer.fromJson<int?>(json['sellQty']),
      profitAmount: serializer.fromJson<int?>(json['profitAmount']),
      profitRate: serializer.fromJson<double?>(json['profitRate']),
      status: serializer.fromJson<String>(json['status']),
      memo: serializer.fromJson<String?>(json['memo']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'ipoId': serializer.toJson<String>(ipoId),
      'ipoName': serializer.toJson<String>(ipoName),
      'broker': serializer.toJson<String?>(broker),
      'appliedQty': serializer.toJson<int?>(appliedQty),
      'depositAmount': serializer.toJson<int?>(depositAmount),
      'allocatedQty': serializer.toJson<int?>(allocatedQty),
      'refundAmount': serializer.toJson<int?>(refundAmount),
      'sellPrice': serializer.toJson<int?>(sellPrice),
      'sellQty': serializer.toJson<int?>(sellQty),
      'profitAmount': serializer.toJson<int?>(profitAmount),
      'profitRate': serializer.toJson<double?>(profitRate),
      'status': serializer.toJson<String>(status),
      'memo': serializer.toJson<String?>(memo),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SubscriptionRow copyWith({
    int? id,
    String? ipoId,
    String? ipoName,
    Value<String?> broker = const Value.absent(),
    Value<int?> appliedQty = const Value.absent(),
    Value<int?> depositAmount = const Value.absent(),
    Value<int?> allocatedQty = const Value.absent(),
    Value<int?> refundAmount = const Value.absent(),
    Value<int?> sellPrice = const Value.absent(),
    Value<int?> sellQty = const Value.absent(),
    Value<int?> profitAmount = const Value.absent(),
    Value<double?> profitRate = const Value.absent(),
    String? status,
    Value<String?> memo = const Value.absent(),
    DateTime? createdAt,
  }) => SubscriptionRow(
    id: id ?? this.id,
    ipoId: ipoId ?? this.ipoId,
    ipoName: ipoName ?? this.ipoName,
    broker: broker.present ? broker.value : this.broker,
    appliedQty: appliedQty.present ? appliedQty.value : this.appliedQty,
    depositAmount: depositAmount.present
        ? depositAmount.value
        : this.depositAmount,
    allocatedQty: allocatedQty.present ? allocatedQty.value : this.allocatedQty,
    refundAmount: refundAmount.present ? refundAmount.value : this.refundAmount,
    sellPrice: sellPrice.present ? sellPrice.value : this.sellPrice,
    sellQty: sellQty.present ? sellQty.value : this.sellQty,
    profitAmount: profitAmount.present ? profitAmount.value : this.profitAmount,
    profitRate: profitRate.present ? profitRate.value : this.profitRate,
    status: status ?? this.status,
    memo: memo.present ? memo.value : this.memo,
    createdAt: createdAt ?? this.createdAt,
  );
  SubscriptionRow copyWithCompanion(SubscriptionRecordsCompanion data) {
    return SubscriptionRow(
      id: data.id.present ? data.id.value : this.id,
      ipoId: data.ipoId.present ? data.ipoId.value : this.ipoId,
      ipoName: data.ipoName.present ? data.ipoName.value : this.ipoName,
      broker: data.broker.present ? data.broker.value : this.broker,
      appliedQty: data.appliedQty.present
          ? data.appliedQty.value
          : this.appliedQty,
      depositAmount: data.depositAmount.present
          ? data.depositAmount.value
          : this.depositAmount,
      allocatedQty: data.allocatedQty.present
          ? data.allocatedQty.value
          : this.allocatedQty,
      refundAmount: data.refundAmount.present
          ? data.refundAmount.value
          : this.refundAmount,
      sellPrice: data.sellPrice.present ? data.sellPrice.value : this.sellPrice,
      sellQty: data.sellQty.present ? data.sellQty.value : this.sellQty,
      profitAmount: data.profitAmount.present
          ? data.profitAmount.value
          : this.profitAmount,
      profitRate: data.profitRate.present
          ? data.profitRate.value
          : this.profitRate,
      status: data.status.present ? data.status.value : this.status,
      memo: data.memo.present ? data.memo.value : this.memo,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRow(')
          ..write('id: $id, ')
          ..write('ipoId: $ipoId, ')
          ..write('ipoName: $ipoName, ')
          ..write('broker: $broker, ')
          ..write('appliedQty: $appliedQty, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('allocatedQty: $allocatedQty, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('sellQty: $sellQty, ')
          ..write('profitAmount: $profitAmount, ')
          ..write('profitRate: $profitRate, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    ipoId,
    ipoName,
    broker,
    appliedQty,
    depositAmount,
    allocatedQty,
    refundAmount,
    sellPrice,
    sellQty,
    profitAmount,
    profitRate,
    status,
    memo,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionRow &&
          other.id == this.id &&
          other.ipoId == this.ipoId &&
          other.ipoName == this.ipoName &&
          other.broker == this.broker &&
          other.appliedQty == this.appliedQty &&
          other.depositAmount == this.depositAmount &&
          other.allocatedQty == this.allocatedQty &&
          other.refundAmount == this.refundAmount &&
          other.sellPrice == this.sellPrice &&
          other.sellQty == this.sellQty &&
          other.profitAmount == this.profitAmount &&
          other.profitRate == this.profitRate &&
          other.status == this.status &&
          other.memo == this.memo &&
          other.createdAt == this.createdAt);
}

class SubscriptionRecordsCompanion extends UpdateCompanion<SubscriptionRow> {
  final Value<int> id;
  final Value<String> ipoId;
  final Value<String> ipoName;
  final Value<String?> broker;
  final Value<int?> appliedQty;
  final Value<int?> depositAmount;
  final Value<int?> allocatedQty;
  final Value<int?> refundAmount;
  final Value<int?> sellPrice;
  final Value<int?> sellQty;
  final Value<int?> profitAmount;
  final Value<double?> profitRate;
  final Value<String> status;
  final Value<String?> memo;
  final Value<DateTime> createdAt;
  const SubscriptionRecordsCompanion({
    this.id = const Value.absent(),
    this.ipoId = const Value.absent(),
    this.ipoName = const Value.absent(),
    this.broker = const Value.absent(),
    this.appliedQty = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.allocatedQty = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.sellQty = const Value.absent(),
    this.profitAmount = const Value.absent(),
    this.profitRate = const Value.absent(),
    this.status = const Value.absent(),
    this.memo = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SubscriptionRecordsCompanion.insert({
    this.id = const Value.absent(),
    required String ipoId,
    required String ipoName,
    this.broker = const Value.absent(),
    this.appliedQty = const Value.absent(),
    this.depositAmount = const Value.absent(),
    this.allocatedQty = const Value.absent(),
    this.refundAmount = const Value.absent(),
    this.sellPrice = const Value.absent(),
    this.sellQty = const Value.absent(),
    this.profitAmount = const Value.absent(),
    this.profitRate = const Value.absent(),
    required String status,
    this.memo = const Value.absent(),
    required DateTime createdAt,
  }) : ipoId = Value(ipoId),
       ipoName = Value(ipoName),
       status = Value(status),
       createdAt = Value(createdAt);
  static Insertable<SubscriptionRow> custom({
    Expression<int>? id,
    Expression<String>? ipoId,
    Expression<String>? ipoName,
    Expression<String>? broker,
    Expression<int>? appliedQty,
    Expression<int>? depositAmount,
    Expression<int>? allocatedQty,
    Expression<int>? refundAmount,
    Expression<int>? sellPrice,
    Expression<int>? sellQty,
    Expression<int>? profitAmount,
    Expression<double>? profitRate,
    Expression<String>? status,
    Expression<String>? memo,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (ipoId != null) 'ipo_id': ipoId,
      if (ipoName != null) 'ipo_name': ipoName,
      if (broker != null) 'broker': broker,
      if (appliedQty != null) 'applied_qty': appliedQty,
      if (depositAmount != null) 'deposit_amount': depositAmount,
      if (allocatedQty != null) 'allocated_qty': allocatedQty,
      if (refundAmount != null) 'refund_amount': refundAmount,
      if (sellPrice != null) 'sell_price': sellPrice,
      if (sellQty != null) 'sell_qty': sellQty,
      if (profitAmount != null) 'profit_amount': profitAmount,
      if (profitRate != null) 'profit_rate': profitRate,
      if (status != null) 'status': status,
      if (memo != null) 'memo': memo,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SubscriptionRecordsCompanion copyWith({
    Value<int>? id,
    Value<String>? ipoId,
    Value<String>? ipoName,
    Value<String?>? broker,
    Value<int?>? appliedQty,
    Value<int?>? depositAmount,
    Value<int?>? allocatedQty,
    Value<int?>? refundAmount,
    Value<int?>? sellPrice,
    Value<int?>? sellQty,
    Value<int?>? profitAmount,
    Value<double?>? profitRate,
    Value<String>? status,
    Value<String?>? memo,
    Value<DateTime>? createdAt,
  }) {
    return SubscriptionRecordsCompanion(
      id: id ?? this.id,
      ipoId: ipoId ?? this.ipoId,
      ipoName: ipoName ?? this.ipoName,
      broker: broker ?? this.broker,
      appliedQty: appliedQty ?? this.appliedQty,
      depositAmount: depositAmount ?? this.depositAmount,
      allocatedQty: allocatedQty ?? this.allocatedQty,
      refundAmount: refundAmount ?? this.refundAmount,
      sellPrice: sellPrice ?? this.sellPrice,
      sellQty: sellQty ?? this.sellQty,
      profitAmount: profitAmount ?? this.profitAmount,
      profitRate: profitRate ?? this.profitRate,
      status: status ?? this.status,
      memo: memo ?? this.memo,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (ipoId.present) {
      map['ipo_id'] = Variable<String>(ipoId.value);
    }
    if (ipoName.present) {
      map['ipo_name'] = Variable<String>(ipoName.value);
    }
    if (broker.present) {
      map['broker'] = Variable<String>(broker.value);
    }
    if (appliedQty.present) {
      map['applied_qty'] = Variable<int>(appliedQty.value);
    }
    if (depositAmount.present) {
      map['deposit_amount'] = Variable<int>(depositAmount.value);
    }
    if (allocatedQty.present) {
      map['allocated_qty'] = Variable<int>(allocatedQty.value);
    }
    if (refundAmount.present) {
      map['refund_amount'] = Variable<int>(refundAmount.value);
    }
    if (sellPrice.present) {
      map['sell_price'] = Variable<int>(sellPrice.value);
    }
    if (sellQty.present) {
      map['sell_qty'] = Variable<int>(sellQty.value);
    }
    if (profitAmount.present) {
      map['profit_amount'] = Variable<int>(profitAmount.value);
    }
    if (profitRate.present) {
      map['profit_rate'] = Variable<double>(profitRate.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (memo.present) {
      map['memo'] = Variable<String>(memo.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('ipoId: $ipoId, ')
          ..write('ipoName: $ipoName, ')
          ..write('broker: $broker, ')
          ..write('appliedQty: $appliedQty, ')
          ..write('depositAmount: $depositAmount, ')
          ..write('allocatedQty: $allocatedQty, ')
          ..write('refundAmount: $refundAmount, ')
          ..write('sellPrice: $sellPrice, ')
          ..write('sellQty: $sellQty, ')
          ..write('profitAmount: $profitAmount, ')
          ..write('profitRate: $profitRate, ')
          ..write('status: $status, ')
          ..write('memo: $memo, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$PersonalDb extends GeneratedDatabase {
  _$PersonalDb(QueryExecutor e) : super(e);
  $PersonalDbManager get managers => $PersonalDbManager(this);
  late final $WatchlistItemsTable watchlistItems = $WatchlistItemsTable(this);
  late final $SubscriptionRecordsTable subscriptionRecords =
      $SubscriptionRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    watchlistItems,
    subscriptionRecords,
  ];
}

typedef $$WatchlistItemsTableCreateCompanionBuilder =
    WatchlistItemsCompanion Function({
      required String canonicalKey,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });
typedef $$WatchlistItemsTableUpdateCompanionBuilder =
    WatchlistItemsCompanion Function({
      Value<String> canonicalKey,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$WatchlistItemsTableFilterComposer
    extends Composer<_$PersonalDb, $WatchlistItemsTable> {
  $$WatchlistItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WatchlistItemsTableOrderingComposer
    extends Composer<_$PersonalDb, $WatchlistItemsTable> {
  $$WatchlistItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WatchlistItemsTableAnnotationComposer
    extends Composer<_$PersonalDb, $WatchlistItemsTable> {
  $$WatchlistItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get canonicalKey => $composableBuilder(
    column: $table.canonicalKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$WatchlistItemsTableTableManager
    extends
        RootTableManager<
          _$PersonalDb,
          $WatchlistItemsTable,
          WatchlistItem,
          $$WatchlistItemsTableFilterComposer,
          $$WatchlistItemsTableOrderingComposer,
          $$WatchlistItemsTableAnnotationComposer,
          $$WatchlistItemsTableCreateCompanionBuilder,
          $$WatchlistItemsTableUpdateCompanionBuilder,
          (
            WatchlistItem,
            BaseReferences<_$PersonalDb, $WatchlistItemsTable, WatchlistItem>,
          ),
          WatchlistItem,
          PrefetchHooks Function()
        > {
  $$WatchlistItemsTableTableManager(_$PersonalDb db, $WatchlistItemsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WatchlistItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WatchlistItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WatchlistItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> canonicalKey = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchlistItemsCompanion(
                canonicalKey: canonicalKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String canonicalKey,
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WatchlistItemsCompanion.insert(
                canonicalKey: canonicalKey,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WatchlistItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$PersonalDb,
      $WatchlistItemsTable,
      WatchlistItem,
      $$WatchlistItemsTableFilterComposer,
      $$WatchlistItemsTableOrderingComposer,
      $$WatchlistItemsTableAnnotationComposer,
      $$WatchlistItemsTableCreateCompanionBuilder,
      $$WatchlistItemsTableUpdateCompanionBuilder,
      (
        WatchlistItem,
        BaseReferences<_$PersonalDb, $WatchlistItemsTable, WatchlistItem>,
      ),
      WatchlistItem,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionRecordsTableCreateCompanionBuilder =
    SubscriptionRecordsCompanion Function({
      Value<int> id,
      required String ipoId,
      required String ipoName,
      Value<String?> broker,
      Value<int?> appliedQty,
      Value<int?> depositAmount,
      Value<int?> allocatedQty,
      Value<int?> refundAmount,
      Value<int?> sellPrice,
      Value<int?> sellQty,
      Value<int?> profitAmount,
      Value<double?> profitRate,
      required String status,
      Value<String?> memo,
      required DateTime createdAt,
    });
typedef $$SubscriptionRecordsTableUpdateCompanionBuilder =
    SubscriptionRecordsCompanion Function({
      Value<int> id,
      Value<String> ipoId,
      Value<String> ipoName,
      Value<String?> broker,
      Value<int?> appliedQty,
      Value<int?> depositAmount,
      Value<int?> allocatedQty,
      Value<int?> refundAmount,
      Value<int?> sellPrice,
      Value<int?> sellQty,
      Value<int?> profitAmount,
      Value<double?> profitRate,
      Value<String> status,
      Value<String?> memo,
      Value<DateTime> createdAt,
    });

class $$SubscriptionRecordsTableFilterComposer
    extends Composer<_$PersonalDb, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipoId => $composableBuilder(
    column: $table.ipoId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ipoName => $composableBuilder(
    column: $table.ipoName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedQty => $composableBuilder(
    column: $table.appliedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get allocatedQty => $composableBuilder(
    column: $table.allocatedQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sellQty => $composableBuilder(
    column: $table.sellQty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get profitAmount => $composableBuilder(
    column: $table.profitAmount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get profitRate => $composableBuilder(
    column: $table.profitRate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionRecordsTableOrderingComposer
    extends Composer<_$PersonalDb, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipoId => $composableBuilder(
    column: $table.ipoId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ipoName => $composableBuilder(
    column: $table.ipoName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get broker => $composableBuilder(
    column: $table.broker,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedQty => $composableBuilder(
    column: $table.appliedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get allocatedQty => $composableBuilder(
    column: $table.allocatedQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellPrice => $composableBuilder(
    column: $table.sellPrice,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sellQty => $composableBuilder(
    column: $table.sellQty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get profitAmount => $composableBuilder(
    column: $table.profitAmount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get profitRate => $composableBuilder(
    column: $table.profitRate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get memo => $composableBuilder(
    column: $table.memo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionRecordsTableAnnotationComposer
    extends Composer<_$PersonalDb, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get ipoId =>
      $composableBuilder(column: $table.ipoId, builder: (column) => column);

  GeneratedColumn<String> get ipoName =>
      $composableBuilder(column: $table.ipoName, builder: (column) => column);

  GeneratedColumn<String> get broker =>
      $composableBuilder(column: $table.broker, builder: (column) => column);

  GeneratedColumn<int> get appliedQty => $composableBuilder(
    column: $table.appliedQty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get depositAmount => $composableBuilder(
    column: $table.depositAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get allocatedQty => $composableBuilder(
    column: $table.allocatedQty,
    builder: (column) => column,
  );

  GeneratedColumn<int> get refundAmount => $composableBuilder(
    column: $table.refundAmount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get sellPrice =>
      $composableBuilder(column: $table.sellPrice, builder: (column) => column);

  GeneratedColumn<int> get sellQty =>
      $composableBuilder(column: $table.sellQty, builder: (column) => column);

  GeneratedColumn<int> get profitAmount => $composableBuilder(
    column: $table.profitAmount,
    builder: (column) => column,
  );

  GeneratedColumn<double> get profitRate => $composableBuilder(
    column: $table.profitRate,
    builder: (column) => column,
  );

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get memo =>
      $composableBuilder(column: $table.memo, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SubscriptionRecordsTableTableManager
    extends
        RootTableManager<
          _$PersonalDb,
          $SubscriptionRecordsTable,
          SubscriptionRow,
          $$SubscriptionRecordsTableFilterComposer,
          $$SubscriptionRecordsTableOrderingComposer,
          $$SubscriptionRecordsTableAnnotationComposer,
          $$SubscriptionRecordsTableCreateCompanionBuilder,
          $$SubscriptionRecordsTableUpdateCompanionBuilder,
          (
            SubscriptionRow,
            BaseReferences<
              _$PersonalDb,
              $SubscriptionRecordsTable,
              SubscriptionRow
            >,
          ),
          SubscriptionRow,
          PrefetchHooks Function()
        > {
  $$SubscriptionRecordsTableTableManager(
    _$PersonalDb db,
    $SubscriptionRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubscriptionRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubscriptionRecordsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$SubscriptionRecordsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> ipoId = const Value.absent(),
                Value<String> ipoName = const Value.absent(),
                Value<String?> broker = const Value.absent(),
                Value<int?> appliedQty = const Value.absent(),
                Value<int?> depositAmount = const Value.absent(),
                Value<int?> allocatedQty = const Value.absent(),
                Value<int?> refundAmount = const Value.absent(),
                Value<int?> sellPrice = const Value.absent(),
                Value<int?> sellQty = const Value.absent(),
                Value<int?> profitAmount = const Value.absent(),
                Value<double?> profitRate = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<String?> memo = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SubscriptionRecordsCompanion(
                id: id,
                ipoId: ipoId,
                ipoName: ipoName,
                broker: broker,
                appliedQty: appliedQty,
                depositAmount: depositAmount,
                allocatedQty: allocatedQty,
                refundAmount: refundAmount,
                sellPrice: sellPrice,
                sellQty: sellQty,
                profitAmount: profitAmount,
                profitRate: profitRate,
                status: status,
                memo: memo,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String ipoId,
                required String ipoName,
                Value<String?> broker = const Value.absent(),
                Value<int?> appliedQty = const Value.absent(),
                Value<int?> depositAmount = const Value.absent(),
                Value<int?> allocatedQty = const Value.absent(),
                Value<int?> refundAmount = const Value.absent(),
                Value<int?> sellPrice = const Value.absent(),
                Value<int?> sellQty = const Value.absent(),
                Value<int?> profitAmount = const Value.absent(),
                Value<double?> profitRate = const Value.absent(),
                required String status,
                Value<String?> memo = const Value.absent(),
                required DateTime createdAt,
              }) => SubscriptionRecordsCompanion.insert(
                id: id,
                ipoId: ipoId,
                ipoName: ipoName,
                broker: broker,
                appliedQty: appliedQty,
                depositAmount: depositAmount,
                allocatedQty: allocatedQty,
                refundAmount: refundAmount,
                sellPrice: sellPrice,
                sellQty: sellQty,
                profitAmount: profitAmount,
                profitRate: profitRate,
                status: status,
                memo: memo,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubscriptionRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$PersonalDb,
      $SubscriptionRecordsTable,
      SubscriptionRow,
      $$SubscriptionRecordsTableFilterComposer,
      $$SubscriptionRecordsTableOrderingComposer,
      $$SubscriptionRecordsTableAnnotationComposer,
      $$SubscriptionRecordsTableCreateCompanionBuilder,
      $$SubscriptionRecordsTableUpdateCompanionBuilder,
      (
        SubscriptionRow,
        BaseReferences<
          _$PersonalDb,
          $SubscriptionRecordsTable,
          SubscriptionRow
        >,
      ),
      SubscriptionRow,
      PrefetchHooks Function()
    >;

class $PersonalDbManager {
  final _$PersonalDb _db;
  $PersonalDbManager(this._db);
  $$WatchlistItemsTableTableManager get watchlistItems =>
      $$WatchlistItemsTableTableManager(_db, _db.watchlistItems);
  $$SubscriptionRecordsTableTableManager get subscriptionRecords =>
      $$SubscriptionRecordsTableTableManager(_db, _db.subscriptionRecords);
}
