// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $ProfileRecordsTable extends ProfileRecords
    with TableInfo<$ProfileRecordsTable, ProfileRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfileRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _slotMeta = const VerificationMeta('slot');
  @override
  late final GeneratedColumn<String> slot = GeneratedColumn<String>(
    'slot',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [slot, fullName, email, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profile_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<ProfileRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('slot')) {
      context.handle(
        _slotMeta,
        slot.isAcceptableOrUnknown(data['slot']!, _slotMeta),
      );
    } else if (isInserting) {
      context.missing(_slotMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
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
  Set<GeneratedColumn> get $primaryKey => {slot};
  @override
  ProfileRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ProfileRecord(
      slot: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slot'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ProfileRecordsTable createAlias(String alias) {
    return $ProfileRecordsTable(attachedDatabase, alias);
  }
}

class ProfileRecord extends DataClass implements Insertable<ProfileRecord> {
  final String slot;
  final String fullName;
  final String email;
  final DateTime createdAt;
  const ProfileRecord({
    required this.slot,
    required this.fullName,
    required this.email,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['slot'] = Variable<String>(slot);
    map['full_name'] = Variable<String>(fullName);
    map['email'] = Variable<String>(email);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ProfileRecordsCompanion toCompanion(bool nullToAbsent) {
    return ProfileRecordsCompanion(
      slot: Value(slot),
      fullName: Value(fullName),
      email: Value(email),
      createdAt: Value(createdAt),
    );
  }

  factory ProfileRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ProfileRecord(
      slot: serializer.fromJson<String>(json['slot']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String>(json['email']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'slot': serializer.toJson<String>(slot),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String>(email),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ProfileRecord copyWith({
    String? slot,
    String? fullName,
    String? email,
    DateTime? createdAt,
  }) => ProfileRecord(
    slot: slot ?? this.slot,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
    createdAt: createdAt ?? this.createdAt,
  );
  ProfileRecord copyWithCompanion(ProfileRecordsCompanion data) {
    return ProfileRecord(
      slot: data.slot.present ? data.slot.value : this.slot,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ProfileRecord(')
          ..write('slot: $slot, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(slot, fullName, email, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ProfileRecord &&
          other.slot == this.slot &&
          other.fullName == this.fullName &&
          other.email == this.email &&
          other.createdAt == this.createdAt);
}

class ProfileRecordsCompanion extends UpdateCompanion<ProfileRecord> {
  final Value<String> slot;
  final Value<String> fullName;
  final Value<String> email;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const ProfileRecordsCompanion({
    this.slot = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfileRecordsCompanion.insert({
    required String slot,
    required String fullName,
    required String email,
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  }) : slot = Value(slot),
       fullName = Value(fullName),
       email = Value(email),
       createdAt = Value(createdAt);
  static Insertable<ProfileRecord> custom({
    Expression<String>? slot,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (slot != null) 'slot': slot,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfileRecordsCompanion copyWith({
    Value<String>? slot,
    Value<String>? fullName,
    Value<String>? email,
    Value<DateTime>? createdAt,
    Value<int>? rowid,
  }) {
    return ProfileRecordsCompanion(
      slot: slot ?? this.slot,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (slot.present) {
      map['slot'] = Variable<String>(slot.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
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
    return (StringBuffer('ProfileRecordsCompanion(')
          ..write('slot: $slot, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubscriptionRecordsTable extends SubscriptionRecords
    with TableInfo<$SubscriptionRecordsTable, SubscriptionRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubscriptionRecordsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _priceMeta = const VerificationMeta('price');
  @override
  late final GeneratedColumn<double> price = GeneratedColumn<double>(
    'price',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _currencyCodeMeta = const VerificationMeta(
    'currencyCode',
  );
  @override
  late final GeneratedColumn<String> currencyCode = GeneratedColumn<String>(
    'currency_code',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _billingCycleMeta = const VerificationMeta(
    'billingCycle',
  );
  @override
  late final GeneratedColumn<String> billingCycle = GeneratedColumn<String>(
    'billing_cycle',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nextBillingDateMeta = const VerificationMeta(
    'nextBillingDate',
  );
  @override
  late final GeneratedColumn<DateTime> nextBillingDate =
      GeneratedColumn<DateTime>(
        'next_billing_date',
        aliasedName,
        false,
        type: DriftSqlType.dateTime,
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _serviceProviderMeta = const VerificationMeta(
    'serviceProvider',
  );
  @override
  late final GeneratedColumn<String> serviceProvider = GeneratedColumn<String>(
    'service_provider',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _websiteMeta = const VerificationMeta(
    'website',
  );
  @override
  late final GeneratedColumn<String> website = GeneratedColumn<String>(
    'website',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _startDateMeta = const VerificationMeta(
    'startDate',
  );
  @override
  late final GeneratedColumn<DateTime> startDate = GeneratedColumn<DateTime>(
    'start_date',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    price,
    currencyCode,
    billingCycle,
    nextBillingDate,
    createdAt,
    description,
    serviceProvider,
    website,
    startDate,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subscription_records';
  @override
  VerificationContext validateIntegrity(
    Insertable<SubscriptionRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('price')) {
      context.handle(
        _priceMeta,
        price.isAcceptableOrUnknown(data['price']!, _priceMeta),
      );
    } else if (isInserting) {
      context.missing(_priceMeta);
    }
    if (data.containsKey('currency_code')) {
      context.handle(
        _currencyCodeMeta,
        currencyCode.isAcceptableOrUnknown(
          data['currency_code']!,
          _currencyCodeMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_currencyCodeMeta);
    }
    if (data.containsKey('billing_cycle')) {
      context.handle(
        _billingCycleMeta,
        billingCycle.isAcceptableOrUnknown(
          data['billing_cycle']!,
          _billingCycleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_billingCycleMeta);
    }
    if (data.containsKey('next_billing_date')) {
      context.handle(
        _nextBillingDateMeta,
        nextBillingDate.isAcceptableOrUnknown(
          data['next_billing_date']!,
          _nextBillingDateMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_nextBillingDateMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('service_provider')) {
      context.handle(
        _serviceProviderMeta,
        serviceProvider.isAcceptableOrUnknown(
          data['service_provider']!,
          _serviceProviderMeta,
        ),
      );
    }
    if (data.containsKey('website')) {
      context.handle(
        _websiteMeta,
        website.isAcceptableOrUnknown(data['website']!, _websiteMeta),
      );
    }
    if (data.containsKey('start_date')) {
      context.handle(
        _startDateMeta,
        startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SubscriptionRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SubscriptionRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      price: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}price'],
      )!,
      currencyCode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}currency_code'],
      )!,
      billingCycle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}billing_cycle'],
      )!,
      nextBillingDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_billing_date'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      serviceProvider: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}service_provider'],
      )!,
      website: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website'],
      )!,
      startDate: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}start_date'],
      ),
    );
  }

  @override
  $SubscriptionRecordsTable createAlias(String alias) {
    return $SubscriptionRecordsTable(attachedDatabase, alias);
  }
}

class SubscriptionRecord extends DataClass
    implements Insertable<SubscriptionRecord> {
  final String id;
  final String name;
  final String category;
  final double price;
  final String currencyCode;
  final String billingCycle;
  final DateTime nextBillingDate;
  final DateTime createdAt;
  final String description;
  final String serviceProvider;
  final String website;
  final DateTime? startDate;
  const SubscriptionRecord({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.currencyCode,
    required this.billingCycle,
    required this.nextBillingDate,
    required this.createdAt,
    required this.description,
    required this.serviceProvider,
    required this.website,
    this.startDate,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['price'] = Variable<double>(price);
    map['currency_code'] = Variable<String>(currencyCode);
    map['billing_cycle'] = Variable<String>(billingCycle);
    map['next_billing_date'] = Variable<DateTime>(nextBillingDate);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['description'] = Variable<String>(description);
    map['service_provider'] = Variable<String>(serviceProvider);
    map['website'] = Variable<String>(website);
    if (!nullToAbsent || startDate != null) {
      map['start_date'] = Variable<DateTime>(startDate);
    }
    return map;
  }

  SubscriptionRecordsCompanion toCompanion(bool nullToAbsent) {
    return SubscriptionRecordsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      price: Value(price),
      currencyCode: Value(currencyCode),
      billingCycle: Value(billingCycle),
      nextBillingDate: Value(nextBillingDate),
      createdAt: Value(createdAt),
      description: Value(description),
      serviceProvider: Value(serviceProvider),
      website: Value(website),
      startDate: startDate == null && nullToAbsent
          ? const Value.absent()
          : Value(startDate),
    );
  }

  factory SubscriptionRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SubscriptionRecord(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      price: serializer.fromJson<double>(json['price']),
      currencyCode: serializer.fromJson<String>(json['currencyCode']),
      billingCycle: serializer.fromJson<String>(json['billingCycle']),
      nextBillingDate: serializer.fromJson<DateTime>(json['nextBillingDate']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      description: serializer.fromJson<String>(json['description']),
      serviceProvider: serializer.fromJson<String>(json['serviceProvider']),
      website: serializer.fromJson<String>(json['website']),
      startDate: serializer.fromJson<DateTime?>(json['startDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'price': serializer.toJson<double>(price),
      'currencyCode': serializer.toJson<String>(currencyCode),
      'billingCycle': serializer.toJson<String>(billingCycle),
      'nextBillingDate': serializer.toJson<DateTime>(nextBillingDate),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'description': serializer.toJson<String>(description),
      'serviceProvider': serializer.toJson<String>(serviceProvider),
      'website': serializer.toJson<String>(website),
      'startDate': serializer.toJson<DateTime?>(startDate),
    };
  }

  SubscriptionRecord copyWith({
    String? id,
    String? name,
    String? category,
    double? price,
    String? currencyCode,
    String? billingCycle,
    DateTime? nextBillingDate,
    DateTime? createdAt,
    String? description,
    String? serviceProvider,
    String? website,
    Value<DateTime?> startDate = const Value.absent(),
  }) => SubscriptionRecord(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    price: price ?? this.price,
    currencyCode: currencyCode ?? this.currencyCode,
    billingCycle: billingCycle ?? this.billingCycle,
    nextBillingDate: nextBillingDate ?? this.nextBillingDate,
    createdAt: createdAt ?? this.createdAt,
    description: description ?? this.description,
    serviceProvider: serviceProvider ?? this.serviceProvider,
    website: website ?? this.website,
    startDate: startDate.present ? startDate.value : this.startDate,
  );
  SubscriptionRecord copyWithCompanion(SubscriptionRecordsCompanion data) {
    return SubscriptionRecord(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      price: data.price.present ? data.price.value : this.price,
      currencyCode: data.currencyCode.present
          ? data.currencyCode.value
          : this.currencyCode,
      billingCycle: data.billingCycle.present
          ? data.billingCycle.value
          : this.billingCycle,
      nextBillingDate: data.nextBillingDate.present
          ? data.nextBillingDate.value
          : this.nextBillingDate,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      description: data.description.present
          ? data.description.value
          : this.description,
      serviceProvider: data.serviceProvider.present
          ? data.serviceProvider.value
          : this.serviceProvider,
      website: data.website.present ? data.website.value : this.website,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRecord(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('serviceProvider: $serviceProvider, ')
          ..write('website: $website, ')
          ..write('startDate: $startDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    price,
    currencyCode,
    billingCycle,
    nextBillingDate,
    createdAt,
    description,
    serviceProvider,
    website,
    startDate,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SubscriptionRecord &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.price == this.price &&
          other.currencyCode == this.currencyCode &&
          other.billingCycle == this.billingCycle &&
          other.nextBillingDate == this.nextBillingDate &&
          other.createdAt == this.createdAt &&
          other.description == this.description &&
          other.serviceProvider == this.serviceProvider &&
          other.website == this.website &&
          other.startDate == this.startDate);
}

class SubscriptionRecordsCompanion extends UpdateCompanion<SubscriptionRecord> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> category;
  final Value<double> price;
  final Value<String> currencyCode;
  final Value<String> billingCycle;
  final Value<DateTime> nextBillingDate;
  final Value<DateTime> createdAt;
  final Value<String> description;
  final Value<String> serviceProvider;
  final Value<String> website;
  final Value<DateTime?> startDate;
  final Value<int> rowid;
  const SubscriptionRecordsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.price = const Value.absent(),
    this.currencyCode = const Value.absent(),
    this.billingCycle = const Value.absent(),
    this.nextBillingDate = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.description = const Value.absent(),
    this.serviceProvider = const Value.absent(),
    this.website = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubscriptionRecordsCompanion.insert({
    required String id,
    required String name,
    required String category,
    required double price,
    required String currencyCode,
    required String billingCycle,
    required DateTime nextBillingDate,
    required DateTime createdAt,
    this.description = const Value.absent(),
    this.serviceProvider = const Value.absent(),
    this.website = const Value.absent(),
    this.startDate = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name),
       category = Value(category),
       price = Value(price),
       currencyCode = Value(currencyCode),
       billingCycle = Value(billingCycle),
       nextBillingDate = Value(nextBillingDate),
       createdAt = Value(createdAt);
  static Insertable<SubscriptionRecord> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<double>? price,
    Expression<String>? currencyCode,
    Expression<String>? billingCycle,
    Expression<DateTime>? nextBillingDate,
    Expression<DateTime>? createdAt,
    Expression<String>? description,
    Expression<String>? serviceProvider,
    Expression<String>? website,
    Expression<DateTime>? startDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (price != null) 'price': price,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (billingCycle != null) 'billing_cycle': billingCycle,
      if (nextBillingDate != null) 'next_billing_date': nextBillingDate,
      if (createdAt != null) 'created_at': createdAt,
      if (description != null) 'description': description,
      if (serviceProvider != null) 'service_provider': serviceProvider,
      if (website != null) 'website': website,
      if (startDate != null) 'start_date': startDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubscriptionRecordsCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<String>? category,
    Value<double>? price,
    Value<String>? currencyCode,
    Value<String>? billingCycle,
    Value<DateTime>? nextBillingDate,
    Value<DateTime>? createdAt,
    Value<String>? description,
    Value<String>? serviceProvider,
    Value<String>? website,
    Value<DateTime?>? startDate,
    Value<int>? rowid,
  }) {
    return SubscriptionRecordsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      currencyCode: currencyCode ?? this.currencyCode,
      billingCycle: billingCycle ?? this.billingCycle,
      nextBillingDate: nextBillingDate ?? this.nextBillingDate,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      serviceProvider: serviceProvider ?? this.serviceProvider,
      website: website ?? this.website,
      startDate: startDate ?? this.startDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (price.present) {
      map['price'] = Variable<double>(price.value);
    }
    if (currencyCode.present) {
      map['currency_code'] = Variable<String>(currencyCode.value);
    }
    if (billingCycle.present) {
      map['billing_cycle'] = Variable<String>(billingCycle.value);
    }
    if (nextBillingDate.present) {
      map['next_billing_date'] = Variable<DateTime>(nextBillingDate.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (serviceProvider.present) {
      map['service_provider'] = Variable<String>(serviceProvider.value);
    }
    if (website.present) {
      map['website'] = Variable<String>(website.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<DateTime>(startDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubscriptionRecordsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('price: $price, ')
          ..write('currencyCode: $currencyCode, ')
          ..write('billingCycle: $billingCycle, ')
          ..write('nextBillingDate: $nextBillingDate, ')
          ..write('createdAt: $createdAt, ')
          ..write('description: $description, ')
          ..write('serviceProvider: $serviceProvider, ')
          ..write('website: $website, ')
          ..write('startDate: $startDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $ProfileRecordsTable profileRecords = $ProfileRecordsTable(this);
  late final $SubscriptionRecordsTable subscriptionRecords =
      $SubscriptionRecordsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    profileRecords,
    subscriptionRecords,
  ];
}

typedef $$ProfileRecordsTableCreateCompanionBuilder =
    ProfileRecordsCompanion Function({
      required String slot,
      required String fullName,
      required String email,
      required DateTime createdAt,
      Value<int> rowid,
    });
typedef $$ProfileRecordsTableUpdateCompanionBuilder =
    ProfileRecordsCompanion Function({
      Value<String> slot,
      Value<String> fullName,
      Value<String> email,
      Value<DateTime> createdAt,
      Value<int> rowid,
    });

class $$ProfileRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $ProfileRecordsTable> {
  $$ProfileRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfileRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $ProfileRecordsTable> {
  $$ProfileRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get slot => $composableBuilder(
    column: $table.slot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfileRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $ProfileRecordsTable> {
  $$ProfileRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get slot =>
      $composableBuilder(column: $table.slot, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$ProfileRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ProfileRecordsTable,
          ProfileRecord,
          $$ProfileRecordsTableFilterComposer,
          $$ProfileRecordsTableOrderingComposer,
          $$ProfileRecordsTableAnnotationComposer,
          $$ProfileRecordsTableCreateCompanionBuilder,
          $$ProfileRecordsTableUpdateCompanionBuilder,
          (
            ProfileRecord,
            BaseReferences<_$AppDatabase, $ProfileRecordsTable, ProfileRecord>,
          ),
          ProfileRecord,
          PrefetchHooks Function()
        > {
  $$ProfileRecordsTableTableManager(
    _$AppDatabase db,
    $ProfileRecordsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfileRecordsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfileRecordsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfileRecordsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> slot = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfileRecordsCompanion(
                slot: slot,
                fullName: fullName,
                email: email,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String slot,
                required String fullName,
                required String email,
                required DateTime createdAt,
                Value<int> rowid = const Value.absent(),
              }) => ProfileRecordsCompanion.insert(
                slot: slot,
                fullName: fullName,
                email: email,
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

typedef $$ProfileRecordsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ProfileRecordsTable,
      ProfileRecord,
      $$ProfileRecordsTableFilterComposer,
      $$ProfileRecordsTableOrderingComposer,
      $$ProfileRecordsTableAnnotationComposer,
      $$ProfileRecordsTableCreateCompanionBuilder,
      $$ProfileRecordsTableUpdateCompanionBuilder,
      (
        ProfileRecord,
        BaseReferences<_$AppDatabase, $ProfileRecordsTable, ProfileRecord>,
      ),
      ProfileRecord,
      PrefetchHooks Function()
    >;
typedef $$SubscriptionRecordsTableCreateCompanionBuilder =
    SubscriptionRecordsCompanion Function({
      required String id,
      required String name,
      required String category,
      required double price,
      required String currencyCode,
      required String billingCycle,
      required DateTime nextBillingDate,
      required DateTime createdAt,
      Value<String> description,
      Value<String> serviceProvider,
      Value<String> website,
      Value<DateTime?> startDate,
      Value<int> rowid,
    });
typedef $$SubscriptionRecordsTableUpdateCompanionBuilder =
    SubscriptionRecordsCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<String> category,
      Value<double> price,
      Value<String> currencyCode,
      Value<String> billingCycle,
      Value<DateTime> nextBillingDate,
      Value<DateTime> createdAt,
      Value<String> description,
      Value<String> serviceProvider,
      Value<String> website,
      Value<DateTime?> startDate,
      Value<int> rowid,
    });

class $$SubscriptionRecordsTableFilterComposer
    extends Composer<_$AppDatabase, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextBillingDate => $composableBuilder(
    column: $table.nextBillingDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubscriptionRecordsTableOrderingComposer
    extends Composer<_$AppDatabase, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get price => $composableBuilder(
    column: $table.price,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextBillingDate => $composableBuilder(
    column: $table.nextBillingDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get website => $composableBuilder(
    column: $table.website,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startDate => $composableBuilder(
    column: $table.startDate,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubscriptionRecordsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SubscriptionRecordsTable> {
  $$SubscriptionRecordsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<double> get price =>
      $composableBuilder(column: $table.price, builder: (column) => column);

  GeneratedColumn<String> get currencyCode => $composableBuilder(
    column: $table.currencyCode,
    builder: (column) => column,
  );

  GeneratedColumn<String> get billingCycle => $composableBuilder(
    column: $table.billingCycle,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get nextBillingDate => $composableBuilder(
    column: $table.nextBillingDate,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serviceProvider => $composableBuilder(
    column: $table.serviceProvider,
    builder: (column) => column,
  );

  GeneratedColumn<String> get website =>
      $composableBuilder(column: $table.website, builder: (column) => column);

  GeneratedColumn<DateTime> get startDate =>
      $composableBuilder(column: $table.startDate, builder: (column) => column);
}

class $$SubscriptionRecordsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SubscriptionRecordsTable,
          SubscriptionRecord,
          $$SubscriptionRecordsTableFilterComposer,
          $$SubscriptionRecordsTableOrderingComposer,
          $$SubscriptionRecordsTableAnnotationComposer,
          $$SubscriptionRecordsTableCreateCompanionBuilder,
          $$SubscriptionRecordsTableUpdateCompanionBuilder,
          (
            SubscriptionRecord,
            BaseReferences<
              _$AppDatabase,
              $SubscriptionRecordsTable,
              SubscriptionRecord
            >,
          ),
          SubscriptionRecord,
          PrefetchHooks Function()
        > {
  $$SubscriptionRecordsTableTableManager(
    _$AppDatabase db,
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
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<double> price = const Value.absent(),
                Value<String> currencyCode = const Value.absent(),
                Value<String> billingCycle = const Value.absent(),
                Value<DateTime> nextBillingDate = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> serviceProvider = const Value.absent(),
                Value<String> website = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionRecordsCompanion(
                id: id,
                name: name,
                category: category,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                nextBillingDate: nextBillingDate,
                createdAt: createdAt,
                description: description,
                serviceProvider: serviceProvider,
                website: website,
                startDate: startDate,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                required String category,
                required double price,
                required String currencyCode,
                required String billingCycle,
                required DateTime nextBillingDate,
                required DateTime createdAt,
                Value<String> description = const Value.absent(),
                Value<String> serviceProvider = const Value.absent(),
                Value<String> website = const Value.absent(),
                Value<DateTime?> startDate = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubscriptionRecordsCompanion.insert(
                id: id,
                name: name,
                category: category,
                price: price,
                currencyCode: currencyCode,
                billingCycle: billingCycle,
                nextBillingDate: nextBillingDate,
                createdAt: createdAt,
                description: description,
                serviceProvider: serviceProvider,
                website: website,
                startDate: startDate,
                rowid: rowid,
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
      _$AppDatabase,
      $SubscriptionRecordsTable,
      SubscriptionRecord,
      $$SubscriptionRecordsTableFilterComposer,
      $$SubscriptionRecordsTableOrderingComposer,
      $$SubscriptionRecordsTableAnnotationComposer,
      $$SubscriptionRecordsTableCreateCompanionBuilder,
      $$SubscriptionRecordsTableUpdateCompanionBuilder,
      (
        SubscriptionRecord,
        BaseReferences<
          _$AppDatabase,
          $SubscriptionRecordsTable,
          SubscriptionRecord
        >,
      ),
      SubscriptionRecord,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$ProfileRecordsTableTableManager get profileRecords =>
      $$ProfileRecordsTableTableManager(_db, _db.profileRecords);
  $$SubscriptionRecordsTableTableManager get subscriptionRecords =>
      $$SubscriptionRecordsTableTableManager(_db, _db.subscriptionRecords);
}
