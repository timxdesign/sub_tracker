import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class ProfileRecords extends Table {
  TextColumn get slot => text()();

  TextColumn get fullName => text()();

  TextColumn get email => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column<Object>> get primaryKey => {slot};
}

class SubscriptionRecords extends Table {
  TextColumn get id => text()();

  TextColumn get name => text()();

  TextColumn get category => text()();

  RealColumn get price => real()();

  TextColumn get currencyCode => text()();

  TextColumn get billingCycle => text()();

  DateTimeColumn get nextBillingDate => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get serviceProvider => text().withDefault(const Constant(''))();

  TextColumn get website => text().withDefault(const Constant(''))();

  DateTimeColumn get startDate => dateTime().nullable()();

  @override
  Set<Column<Object>> get primaryKey => {id};
}

@DriftDatabase(tables: [ProfileRecords, SubscriptionRecords])
class AppDatabase extends _$AppDatabase {
  AppDatabase({QueryExecutor? executor}) : super(executor ?? _openConnection());

  AppDatabase.inMemory() : super(NativeDatabase.memory());

  @override
  int get schemaVersion => 1;

  static QueryExecutor _openConnection() {
    return LazyDatabase(() async {
      final directory = await getApplicationSupportDirectory();
      await directory.create(recursive: true);

      final file = File(
        '${directory.path}${Platform.pathSeparator}sub_tracker.sqlite',
      );
      return NativeDatabase.createInBackground(file);
    });
  }
}
