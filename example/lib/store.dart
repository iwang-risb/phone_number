import 'dart:async';
import 'dart:developer';

import 'package:flutter/services.dart';
import 'package:phone_number/phone_number.dart';
import 'package:phone_number_example/models/parse_result.dart';
import 'package:phone_number_example/models/region.dart';

class Store {
  final PhoneNumberUtil plugin;

  Store(this.plugin);

  List<Region>? _regions;

  FutureOr<List<Region>> getRegions() async {
    if (_regions == null) {
      final regions = await plugin.allSupportedRegions();

      // Filter out regions with more than 2 characters
      _regions = regions
          .where((e) => e.code.length <= 2)
          .map((e) => Region(e.code, e.prefix, e.name))
          .toList(growable: false);

      _regions!.sort((a, b) => a.name.compareTo(b.name));
    }
    return _regions ?? [];
  }

  FutureOr<ParseResult> parse(String string, {Region? region}) async {
    log("parse $string for region: ${region?.code}");
    try {
      final result = await plugin.parse(string, regionCode: region?.code);
      return ParseResult(result);
    } on PlatformException catch (e) {
      return ParseResult.error(e.code);
    }
  }

  FutureOr<String?> format(String string, Region region) async {
    log("format $string for region: ${region.code}");
    try {
      final result = await plugin.format(string, region.code);
      return result;
    } on PlatformException catch (e) {
      return e.code;
    }
  }

  FutureOr<bool> validate(String string, {Region? region}) async {
    log("validate $string for region: ${region?.code}");
    try {
      final result = await plugin.validate(string, regionCode: region?.code);
      return result;
    } on PlatformException catch (e) {
      log(e.toString());
      return false;
    }
  }

  FutureOr<String?> carrierRegionCode() async {
    log("fetching carrierRegionCode");
    try {
      final result = await plugin.carrierRegionCode();
      return result;
    } on PlatformException catch (e) {
      log(e.toString());
      return null;
    }
  }
}
