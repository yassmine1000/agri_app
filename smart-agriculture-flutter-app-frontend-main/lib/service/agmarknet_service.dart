import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:smart_agri_app/config.dart';
import 'package:smart_agri_app/models/market/geography.dart';

import '../models/market/commodity.dart';
import '../models/market/market.dart';
import '../models/market/price.dart';

class AgmarknetService {
  final Dio _dio = Dio();

  AgmarknetService() {
    _dio.options.baseUrl = 'https://api.ceda.ashoka.edu.in/v1/agmarknet/';
    _dio.options.headers['Accept'] = 'application/json';
    _dio.options.headers['Authorization'] = 'Bearer ${Config.agmarknetAPIKey}';
  }

  Future<List<Commodity>> getCommodities() async {
    try {
      final response = await _dio.get('commodities');
      final commodityResponse = CommodityResponse.fromJson(response.data['output']);
      return commodityResponse.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching commodities: $e');
      }
      rethrow;
    }
  }


  Future<List<Geography>> getGeographies() async {
    try {
      final response = await _dio.get('geographies');
      final geographyResponse = GeographyResponse.fromJson(response.data['output']);
      return geographyResponse.data;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching geographies: $e');
      }
      rethrow;
    }
  }

  Future<List<Market>> getMarkets({
    required int commodityId,
    required int stateId,
    required int districtId,
  }) async {
    try {
      final response = await _dio.post(
        'markets',
        data: {
          "commodity_id": commodityId,
          "state_id": stateId,
          "district_id": districtId,
          "indicator": "price",
        },
      );
      final marketResponse = MarketResponse.fromJson(response.data['output']);
      return marketResponse.data;
    } catch (e) {
      if (kDebugMode) {
        print('error fetching markets: $e');
      }
      rethrow;
    }
  }

  Future<List<PriceData>> getPrices({
    required int commodityId,
    required int stateId,
    required List<int> districtId,
    required List<int> marketId,
    required String fromDate,
    required String toDate,
  }) async {
    try {
      final response = await _dio.post(
        'prices',
        data: {
          "commodity_id": commodityId,
          "state_id": stateId,
          "district_id": districtId,
          "market_id": marketId,
          "from_date": fromDate,
          "to_date": toDate,
        },
      );
      final priceResponse = PriceResponse.fromJson(response.data['output']);
      return priceResponse.data;
    } catch (e) {
      if (kDebugMode) {
        print('error fetching prices: $e');
      }
      rethrow;
    }
  }
}
