import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:learn_riverpod/core/model/Vehicle_image_model.dart';
import 'package:learn_riverpod/core/model/dropdown_model.dart';
import 'package:learn_riverpod/core/model/vehicle.dart';
import 'package:learn_riverpod/core/model/vehicle_status.dart';
import 'package:learn_riverpod/core/service/image_upload_service.dart';
import 'package:learn_riverpod/core/utils/logger.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VehicleService {
  final SupabaseClient _client;
  final String _userId;
  final ImageUploadService _imageUploadService;

  VehicleService(this._client, this._userId, this._imageUploadService);

  Future<List<DropdownOption>> getVehicleTypeOptions() async {
    try {
      final response = await _client
          .from('dropdown_options')
          .select()
          .eq('category', 'vehicle_type')
          .order('value');

      if ((response.isEmpty)) {
        return [];
      }

      final options = (response as List)
          .map(
            (option) => DropdownOption(
              id: option['id'],
              value: option['value'],
              displayName: option['display_name'],
            ),
          )
          .toList();

      return options;
    } catch (e) {
      AppLogger.logger.e('Error loading vehicle type options', error: e);
      rethrow;
    }
  }

  Future<List<Vehicle>> getVehicles() async {
    try {
      AppLogger.logger.d('Fetching vehicles data for user: $_userId');

      final response = await _client
          .from('vehicles')
          .select()
          .eq('owner_id', _userId)
          .order('created_at', ascending: false); //time stamp with newest first

      if ((response.isEmpty)) {
        return [];
      }

      List<Vehicle> vehicles = (response as List)
          .map((vehicle) => Vehicle.fromJson(vehicle as Map<String, dynamic>))
          .toList();

      // We don't need to load images here, as we're using the relationship pattern
      return vehicles;
    } catch (e) {
      AppLogger.logger.e('Error loading vehicles', error: e);
      rethrow;
    }
  }

  Future<Vehicle> getVehicleById(String id) async {
    try {
      final response = await _client
          .from('vehicles')
          .select()
          .eq('id', id) //id of the vehicle
          .eq('owner_id', _userId) //owner id of the vehicle
          .single();

      return Vehicle.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error loading vehicle by ID', error: e);
      rethrow;
    }
  }

  Future<List<VehicleImage>> getVehicleImages(String vehicleId) async {
    try {
      final response = await _client
          .from('vehicle_images')
          .select()
          .eq('vehicle_id', vehicleId)
          .order('is_primary', ascending: false)
          .order('created_at', ascending: false);

      if ((response.isEmpty)) {
        return [];
      }

      return (response as List)
          .map((image) => VehicleImage.fromJson(image as Map<String, dynamic>))
          .toList();
    } catch (e) {
      AppLogger.logger.e('Error loading vehicle images', error: e);
      rethrow;
    }
  }

  //Fetches all images linked to a vehicle.
  Future<VehicleImage?> getPrimaryVehicleImage(String vehicleId) async {
    try {
      final images = await getVehicleImages(vehicleId);
      if (images.isEmpty) return null;

      // Try to find a primary image
      final primaryImage = images.firstWhere(
        (image) => image.isPrimary,
        orElse: () => images.first, // Default to the first image
      );

      return primaryImage;
    } catch (e) {
      AppLogger.logger.e('Error getting primary vehicle image', error: e);
      return null;
    }
  }

  Future<Vehicle> addVehicle({
    required String make,
    required String model,
    required String year,
    required String vehicleType,
    String? licensePlate,
    String? vin,
    String? imageUrl,
    String? userId,
  }) async {
    try {
      if (vin != null && vin.length != 17) {
        throw Exception('VIN must be exactly 17 characters');
      }

      final trimmedVehicleType = vehicleType.trim();
      // Convert year from string to integer
      final int? yearInt = int.tryParse(year);
      if (yearInt == null) {
        throw Exception('Year must be a valid number');
      }

      //Inserting the vehicle into the database
      final response = await _client
          .from('vehicles')
          .insert({
            'make': make,
            'model': model,
            'year': yearInt, // Store as integer
            'vehicle_type': trimmedVehicleType,
            if (licensePlate != null) 'license_plate': licensePlate,
            if (vin != null) 'vin': vin.toUpperCase(),
            // The 'image_url' column doesn't exist in the vehicles table
            'owner_id': userId ?? _userId,
          })
          .select()
          .single();

      Vehicle vehicle = Vehicle.fromJson(response);

      // If an image URL was provided, also add it to vehicle_images
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await addVehicleImage(
          vehicleId: vehicle.id,
          imageUrl: imageUrl,
          isPrimary: true,
        );
      }

      return vehicle;
    } catch (e) {
      AppLogger.logger.e('Error adding vehicle', error: e);
      rethrow;
    }
  }

  Future<void> deleteVehicle(String id) async {
    try {
      // The vehicle_images will be automatically deleted due to CASCADE constraint
      await _client
          .from('vehicles')
          .delete()
          .eq('id', id)
          .eq('owner_id', _userId);
    } catch (e) {
      AppLogger.logger.e('Error deleting vehicle', error: e);
      rethrow;
    }
  }

  Future<Vehicle> updateVehicle({
    required String id,
    String? make,
    String? model,
    String? year,
    String? vehicleType,
    String? licensePlate,
    String? vin,
    String? imageUrl,
    VehicleStatus? status,
  }) async {
    try {
      if (vin != null && vin.length != 17) {
        throw Exception('VIN must be exactly 17 characters');
      }

      // Convert year from string to integer if provided
      int? yearInt;
      if (year != null) {
        yearInt = int.tryParse(year);
        if (yearInt == null) {
          throw Exception('Year must be a valid number');
        }
      }

      final response = await _client
          .from('vehicles')
          .update({
            if (make != null) 'make': make,
            if (model != null) 'model': model,
            if (yearInt != null) 'year': yearInt, // Store as integer
            if (vehicleType != null) 'vehicle_type': vehicleType,
            if (licensePlate != null) 'license_plate': licensePlate,
            if (vin != null) 'vin': vin.toUpperCase(),
            // The 'image_url' column doesn't exist in the vehicles table
            if (status != null) 'status': status.value,
          })
          .eq('id', id)
          .eq('owner_id', _userId)
          .select()
          .single();

      Vehicle vehicle = Vehicle.fromJson(response);

      // If a new primary image URL was provided, update the vehicle_images
      if (imageUrl != null && imageUrl.isNotEmpty) {
        // Check if this image already exists in vehicle_images
        final existingImages = await _client
            .from('vehicle_images')
            .select()
            .eq('vehicle_id', id)
            .eq('image_url', imageUrl);

        if (existingImages.isEmpty) {
          // Add new image and set as primary
          await addVehicleImage(
            vehicleId: id,
            imageUrl: imageUrl,
            isPrimary: true,
          );
        } else {
          // Update existing image to be primary
          await _client
              .from('vehicle_images')
              .update({'is_primary': false})
              .eq('vehicle_id', id);

          await _client
              .from('vehicle_images')
              .update({'is_primary': true})
              .eq('vehicle_id', id)
              .eq('image_url', imageUrl);
        }
      }

      return vehicle;
    } catch (e) {
      AppLogger.logger.e('Error updating vehicle', error: e);
      rethrow;
    }
  }

  Future<Vehicle> uploadAndAddVehicleImage({
    required String vehicleId,
    required XFile file,
    bool isPrimary = false,
    String? caption,
  }) async {
    try {
      // Upload the image first
      String imageUrl = await uploadImage(file);

      // Add the image to the vehicle_images table
      await addVehicleImage(
        vehicleId: vehicleId,
        imageUrl: imageUrl,
        isPrimary: isPrimary,
        caption: caption,
      );

      // No need to update the vehicles table as image_url column doesn't exist

      // Reload the vehicle
      final vehicle = await getVehicleById(vehicleId);
      return vehicle;
    } catch (e) {
      AppLogger.logger.e('Error uploading and adding vehicle image', error: e);
      rethrow;
    }
  }

  Future<VehicleImage> addVehicleImage({
    required String vehicleId,
    required String imageUrl,
    bool isPrimary = false,
    String? caption,
  }) async {
    try {
      // If this is the primary image, update all other images to not be primary
      if (isPrimary) {
        await _client
            .from('vehicle_images')
            .update({'is_primary': false})
            .eq('vehicle_id', vehicleId);
      }

      // Add the new image
      final response = await _client
          .from('vehicle_images')
          .insert({
            'vehicle_id': vehicleId,
            'image_url': imageUrl,
            'is_primary': isPrimary,
            if (caption != null) 'caption': caption,
          })
          .select()
          .single();

      return VehicleImage.fromJson(response);
    } catch (e) {
      AppLogger.logger.e('Error adding vehicle image', error: e);
      rethrow;
    }
  }

  Future<Vehicle> setVehicleImageAsPrimary({
    required String vehicleId,
    required String imageId,
  }) async {
    try {
      // First, get the image details
      final imageResponse = await _client
          .from('vehicle_images')
          .select()
          .eq('id', imageId)
          .eq('vehicle_id', vehicleId)
          .single();

      VehicleImage.fromJson(imageResponse);

      // Update all images to not be primary
      await _client
          .from('vehicle_images')
          .update({'is_primary': false})
          .eq('vehicle_id', vehicleId);

      // Set the selected image as primary
      await _client
          .from('vehicle_images')
          .update({'is_primary': true})
          .eq('id', imageId);

      // No need to update the vehicles table as image_url column doesn't exist

      // Return updated vehicle
      return getVehicleById(vehicleId);
    } catch (e) {
      AppLogger.logger.e('Error setting vehicle image as primary', error: e);
      rethrow;
    }
  }

  Future<Vehicle> deleteVehicleImage({
    required String vehicleId,
    required String imageId,
  }) async {
    try {
      // Check if this is the primary image
      final imageResponse = await _client
          .from('vehicle_images')
          .select()
          .eq('id', imageId)
          .eq('vehicle_id', vehicleId)
          .single();

      final image = VehicleImage.fromJson(imageResponse);
      final isPrimary = image.isPrimary;

      // Delete the image
      await _client
          .from('vehicle_images')
          .delete()
          .eq('id', imageId)
          .eq('vehicle_id', vehicleId);

      // If this was the primary image, set a new primary image if available
      if (isPrimary) {
        final remainingImages = await _client
            .from('vehicle_images')
            .select()
            .eq('vehicle_id', vehicleId)
            .order('created_at', ascending: false)
            .limit(1);

        if (remainingImages.isNotEmpty) {
          final newPrimaryImage = VehicleImage.fromJson(remainingImages[0]);

          // Set as primary
          await _client
              .from('vehicle_images')
              .update({'is_primary': true})
              .eq('id', newPrimaryImage.id);

          // No need to update the vehicles table as image_url column doesn't exist
        }
      }

      // Return updated vehicle
      return getVehicleById(vehicleId);
    } catch (e) {
      AppLogger.logger.e('Error deleting vehicle image', error: e);
      rethrow;
    }
  }

  Future<String> uploadImage(XFile file) async {
    return _imageUploadService.uploadImage(
      file,
      'vehicle_photos',
      'vehicles/$_userId',
    );
  }
}
