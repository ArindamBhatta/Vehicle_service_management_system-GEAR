import 'package:learn_riverpod/core/model/shop_model.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ShopService {
  final SupabaseClient _client; // Make client an instance variable

  // Constructor to inject SupabaseClient
  ShopService(this._client);

  /// Get all shops
  Future<List<Shop>> getAllShops() async {
    try {
      final response = await _client.from('shops').select().order('name');

      return (response as List).map((e) => Shop.fromJson(e)).toList();
    } catch (e) {
      AppLogger.logger.e('Error getting all shops', error: e);
      return [];
    }
  }

  /// Get a shop by ID
  Future<Shop?> getShopById(String shopId) async {
    try {
      final response = await _client
          .from('shops')
          .select()
          .eq('id', shopId)
          .single();

      return Shop.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error getting shop by ID', error: e);
      return null;
    }
  }

  /// Get shops owned by a user
  Future<List<Shop>> getShopsByOwnerId(String ownerId) async {
    try {
      final response = await _client
          .from('shops')
          .select()
          .eq('owner_id', ownerId)
          .order('name');

      return (response as List).map((e) => Shop.fromJson(e)).toList();
    } catch (e) {
      AppLogger.logger.e('Error getting shops by owner ID', error: e);
      return [];
    }
  }

  /// Get shops where user is an employee
  Future<List<Shop>> getShopsByEmployeeId(String employeeId) async {
    try {
      final response = await _client
          .from('shops')
          .select()
          .contains('employee_ids', [employeeId])
          .order('name');

      return (response as List).map((e) => Shop.fromJson(e)).toList();
    } catch (e) {
      AppLogger.logger.e('Error getting shops by employee ID', error: e);
      return [];
    }
  }

  /// Create or update a shop
  Future<Shop?> upsertShop(Shop shop) async {
    try {
      final shopData = shop.toJson();

      final response = await _client
          .from('shops')
          .upsert(shopData)
          .select()
          .single();

      return Shop.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error upserting shop', error: e);
      return null;
    }
  }

  /// Delete a shop
  Future<bool> deleteShop(String shopId) async {
    try {
      await _client.from('shops').delete().eq('id', shopId);

      return true;
    } catch (e) {
      AppLogger.logger.e('Error deleting shop', error: e);
      return false;
    }
  }

  /// Add an employee to a shop
  Future<Shop?> addEmployeeToShop(String shopId, String employeeId) async {
    try {
      final shop = await getShopById(shopId);

      if (shop == null) {
        return null;
      }

      if (shop.employeeIds.contains(employeeId)) {
        return shop;
      }

      final updatedEmployeeIds = [...shop.employeeIds, employeeId];
      final updatedShop = shop.copyWith(employeeIds: updatedEmployeeIds);

      return await upsertShop(updatedShop);
    } catch (e) {
      AppLogger.logger.e('Error adding employee to shop', error: e);
      return null;
    }
  }

  /// Remove an employee from a shop
  Future<Shop?> removeEmployeeFromShop(String shopId, String employeeId) async {
    try {
      final shop = await getShopById(shopId);

      if (shop == null) {
        return null;
      }

      if (!shop.employeeIds.contains(employeeId)) {
        return shop;
      }

      final updatedEmployeeIds = shop.employeeIds
          .where((id) => id != employeeId)
          .toList();
      final updatedShop = shop.copyWith(employeeIds: updatedEmployeeIds);

      return await upsertShop(updatedShop);
    } catch (e) {
      AppLogger.logger.e('Error removing employee from shop', error: e);
      return null;
    }
  }
}
