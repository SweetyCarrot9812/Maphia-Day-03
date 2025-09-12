import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'vehicle_models.g.dart';

// Enums for vehicle tracking system
@HiveType(typeId: 80)
enum VehicleStatus {
  @HiveField(0)
  active,
  @HiveField(1)
  inactive,
  @HiveField(2)
  maintenance,
  @HiveField(3)
  out_of_service
}

@HiveType(typeId: 81)
enum VehicleType {
  @HiveField(0)
  bus,
  @HiveField(1)
  van,
  @HiveField(2)
  car,
  @HiveField(3)
  mini_bus
}

@HiveType(typeId: 82)
enum DriverStatus {
  @HiveField(0)
  available,
  @HiveField(1)
  on_route,
  @HiveField(2)
  break_time,
  @HiveField(3)
  off_duty
}

@HiveType(typeId: 83)
enum RouteStatus {
  @HiveField(0)
  planned,
  @HiveField(1)
  in_progress,
  @HiveField(2)
  completed,
  @HiveField(3)
  cancelled,
  @HiveField(4)
  delayed
}

@HiveType(typeId: 84)
enum AlertType {
  @HiveField(0)
  speeding,
  @HiveField(1)
  geofence_exit,
  @HiveField(2)
  geofence_enter,
  @HiveField(3)
  maintenance_due,
  @HiveField(4)
  fuel_low,
  @HiveField(5)
  route_deviation,
  @HiveField(6)
  emergency
}

@HiveType(typeId: 85)
enum GeofenceType {
  @HiveField(0)
  school,
  @HiveField(1)
  pickup_point,
  @HiveField(2)
  safe_zone,
  @HiveField(3)
  restricted_zone
}

// Core data models
@HiveType(typeId: 86)
@JsonSerializable()
class Vehicle {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String licensePlate;
  
  @HiveField(2)
  final VehicleType type;
  
  @HiveField(3)
  final VehicleStatus status;
  
  @HiveField(4)
  final String make;
  
  @HiveField(5)
  final String model;
  
  @HiveField(6)
  final int year;
  
  @HiveField(7)
  final int capacity; // Number of passengers
  
  @HiveField(8)
  final String? driverId;
  
  @HiveField(9)
  final double fuelCapacity; // in liters
  
  @HiveField(10)
  final double currentFuelLevel;
  
  @HiveField(11)
  final DateTime lastMaintenanceDate;
  
  @HiveField(12)
  final DateTime nextMaintenanceDate;
  
  @HiveField(13)
  final int odometer; // Total distance traveled
  
  @HiveField(14)
  final String color;
  
  @HiveField(15)
  final String? imageUrl;
  
  @HiveField(16)
  final Map<String, dynamic> metadata;
  
  @HiveField(17)
  final DateTime createdAt;
  
  @HiveField(18)
  final DateTime updatedAt;

  const Vehicle({
    required this.id,
    required this.licensePlate,
    required this.type,
    required this.status,
    required this.make,
    required this.model,
    required this.year,
    required this.capacity,
    this.driverId,
    required this.fuelCapacity,
    required this.currentFuelLevel,
    required this.lastMaintenanceDate,
    required this.nextMaintenanceDate,
    required this.odometer,
    required this.color,
    this.imageUrl,
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Vehicle.fromJson(Map<String, dynamic> json) => _$VehicleFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleToJson(this);

  Vehicle copyWith({
    String? id,
    String? licensePlate,
    VehicleType? type,
    VehicleStatus? status,
    String? make,
    String? model,
    int? year,
    int? capacity,
    String? driverId,
    double? fuelCapacity,
    double? currentFuelLevel,
    DateTime? lastMaintenanceDate,
    DateTime? nextMaintenanceDate,
    int? odometer,
    String? color,
    String? imageUrl,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Vehicle(
      id: id ?? this.id,
      licensePlate: licensePlate ?? this.licensePlate,
      type: type ?? this.type,
      status: status ?? this.status,
      make: make ?? this.make,
      model: model ?? this.model,
      year: year ?? this.year,
      capacity: capacity ?? this.capacity,
      driverId: driverId ?? this.driverId,
      fuelCapacity: fuelCapacity ?? this.fuelCapacity,
      currentFuelLevel: currentFuelLevel ?? this.currentFuelLevel,
      lastMaintenanceDate: lastMaintenanceDate ?? this.lastMaintenanceDate,
      nextMaintenanceDate: nextMaintenanceDate ?? this.nextMaintenanceDate,
      odometer: odometer ?? this.odometer,
      color: color ?? this.color,
      imageUrl: imageUrl ?? this.imageUrl,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 87)
@JsonSerializable()
class Driver {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String phoneNumber;
  
  @HiveField(3)
  final String email;
  
  @HiveField(4)
  final String licenseNumber;
  
  @HiveField(5)
  final DateTime licenseExpiryDate;
  
  @HiveField(6)
  final DriverStatus status;
  
  @HiveField(7)
  final String? currentVehicleId;
  
  @HiveField(8)
  final int experienceYears;
  
  @HiveField(9)
  final double rating; // 1.0 to 5.0
  
  @HiveField(10)
  final String? profileImageUrl;
  
  @HiveField(11)
  final List<String> certifications;
  
  @HiveField(12)
  final DateTime hireDate;
  
  @HiveField(13)
  final Map<String, dynamic> emergencyContact;
  
  @HiveField(14)
  final Map<String, dynamic> metadata;
  
  @HiveField(15)
  final DateTime createdAt;
  
  @HiveField(16)
  final DateTime updatedAt;

  const Driver({
    required this.id,
    required this.name,
    required this.phoneNumber,
    required this.email,
    required this.licenseNumber,
    required this.licenseExpiryDate,
    required this.status,
    this.currentVehicleId,
    required this.experienceYears,
    required this.rating,
    this.profileImageUrl,
    this.certifications = const [],
    required this.hireDate,
    this.emergencyContact = const {},
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Driver.fromJson(Map<String, dynamic> json) => _$DriverFromJson(json);
  Map<String, dynamic> toJson() => _$DriverToJson(this);

  Driver copyWith({
    String? id,
    String? name,
    String? phoneNumber,
    String? email,
    String? licenseNumber,
    DateTime? licenseExpiryDate,
    DriverStatus? status,
    String? currentVehicleId,
    int? experienceYears,
    double? rating,
    String? profileImageUrl,
    List<String>? certifications,
    DateTime? hireDate,
    Map<String, dynamic>? emergencyContact,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Driver(
      id: id ?? this.id,
      name: name ?? this.name,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      licenseNumber: licenseNumber ?? this.licenseNumber,
      licenseExpiryDate: licenseExpiryDate ?? this.licenseExpiryDate,
      status: status ?? this.status,
      currentVehicleId: currentVehicleId ?? this.currentVehicleId,
      experienceYears: experienceYears ?? this.experienceYears,
      rating: rating ?? this.rating,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      certifications: certifications ?? this.certifications,
      hireDate: hireDate ?? this.hireDate,
      emergencyContact: emergencyContact ?? this.emergencyContact,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 88)
@JsonSerializable()
class GPSLocation {
  @HiveField(0)
  final double latitude;
  
  @HiveField(1)
  final double longitude;
  
  @HiveField(2)
  final double? altitude;
  
  @HiveField(3)
  final double? speed; // km/h
  
  @HiveField(4)
  final double? heading; // degrees
  
  @HiveField(5)
  final double? accuracy; // meters
  
  @HiveField(6)
  final DateTime timestamp;

  const GPSLocation({
    required this.latitude,
    required this.longitude,
    this.altitude,
    this.speed,
    this.heading,
    this.accuracy,
    required this.timestamp,
  });

  factory GPSLocation.fromJson(Map<String, dynamic> json) => _$GPSLocationFromJson(json);
  Map<String, dynamic> toJson() => _$GPSLocationToJson(this);
}

@HiveType(typeId: 89)
@JsonSerializable()
class Route {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final String vehicleId;
  
  @HiveField(3)
  final String driverId;
  
  @HiveField(4)
  final RouteStatus status;
  
  @HiveField(5)
  final List<RoutePoint> waypoints;
  
  @HiveField(6)
  final DateTime scheduledStartTime;
  
  @HiveField(7)
  final DateTime scheduledEndTime;
  
  @HiveField(8)
  final DateTime? actualStartTime;
  
  @HiveField(9)
  final DateTime? actualEndTime;
  
  @HiveField(10)
  final double estimatedDistance; // in km
  
  @HiveField(11)
  final double? actualDistance;
  
  @HiveField(12)
  final int estimatedDuration; // in minutes
  
  @HiveField(13)
  final int? actualDuration;
  
  @HiveField(14)
  final List<String> studentIds; // Students on this route
  
  @HiveField(15)
  final Map<String, dynamic> metadata;
  
  @HiveField(16)
  final DateTime createdAt;
  
  @HiveField(17)
  final DateTime updatedAt;

  const Route({
    required this.id,
    required this.name,
    required this.vehicleId,
    required this.driverId,
    required this.status,
    required this.waypoints,
    required this.scheduledStartTime,
    required this.scheduledEndTime,
    this.actualStartTime,
    this.actualEndTime,
    required this.estimatedDistance,
    this.actualDistance,
    required this.estimatedDuration,
    this.actualDuration,
    this.studentIds = const [],
    this.metadata = const {},
    required this.createdAt,
    required this.updatedAt,
  });

  factory Route.fromJson(Map<String, dynamic> json) => _$RouteFromJson(json);
  Map<String, dynamic> toJson() => _$RouteToJson(this);

  Route copyWith({
    String? id,
    String? name,
    String? vehicleId,
    String? driverId,
    RouteStatus? status,
    List<RoutePoint>? waypoints,
    DateTime? scheduledStartTime,
    DateTime? scheduledEndTime,
    DateTime? actualStartTime,
    DateTime? actualEndTime,
    double? estimatedDistance,
    double? actualDistance,
    int? estimatedDuration,
    int? actualDuration,
    List<String>? studentIds,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Route(
      id: id ?? this.id,
      name: name ?? this.name,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      status: status ?? this.status,
      waypoints: waypoints ?? this.waypoints,
      scheduledStartTime: scheduledStartTime ?? this.scheduledStartTime,
      scheduledEndTime: scheduledEndTime ?? this.scheduledEndTime,
      actualStartTime: actualStartTime ?? this.actualStartTime,
      actualEndTime: actualEndTime ?? this.actualEndTime,
      estimatedDistance: estimatedDistance ?? this.estimatedDistance,
      actualDistance: actualDistance ?? this.actualDistance,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      actualDuration: actualDuration ?? this.actualDuration,
      studentIds: studentIds ?? this.studentIds,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

@HiveType(typeId: 90)
@JsonSerializable()
class RoutePoint {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final GPSLocation location;
  
  @HiveField(2)
  final String name;
  
  @HiveField(3)
  final String type; // pickup, dropoff, waypoint
  
  @HiveField(4)
  final int sequence; // Order in route
  
  @HiveField(5)
  final DateTime? estimatedArrival;
  
  @HiveField(6)
  final DateTime? actualArrival;
  
  @HiveField(7)
  final List<String> studentIds; // Students at this point
  
  @HiveField(8)
  final Map<String, dynamic> metadata;

  const RoutePoint({
    required this.id,
    required this.location,
    required this.name,
    required this.type,
    required this.sequence,
    this.estimatedArrival,
    this.actualArrival,
    this.studentIds = const [],
    this.metadata = const {},
  });

  factory RoutePoint.fromJson(Map<String, dynamic> json) => _$RoutePointFromJson(json);
  Map<String, dynamic> toJson() => _$RoutePointToJson(this);
}

@HiveType(typeId: 91)
@JsonSerializable()
class VehicleTracking {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String vehicleId;
  
  @HiveField(2)
  final GPSLocation currentLocation;
  
  @HiveField(3)
  final String? currentRouteId;
  
  @HiveField(4)
  final double currentSpeed; // km/h
  
  @HiveField(5)
  final double fuelLevel; // percentage
  
  @HiveField(6)
  final int engineHours;
  
  @HiveField(7)
  final bool isEngineOn;
  
  @HiveField(8)
  final Map<String, dynamic> diagnostics;
  
  @HiveField(9)
  final DateTime lastUpdate;

  const VehicleTracking({
    required this.id,
    required this.vehicleId,
    required this.currentLocation,
    this.currentRouteId,
    required this.currentSpeed,
    required this.fuelLevel,
    required this.engineHours,
    required this.isEngineOn,
    this.diagnostics = const {},
    required this.lastUpdate,
  });

  factory VehicleTracking.fromJson(Map<String, dynamic> json) => _$VehicleTrackingFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleTrackingToJson(this);

  VehicleTracking copyWith({
    String? id,
    String? vehicleId,
    GPSLocation? currentLocation,
    String? currentRouteId,
    double? currentSpeed,
    double? fuelLevel,
    int? engineHours,
    bool? isEngineOn,
    Map<String, dynamic>? diagnostics,
    DateTime? lastUpdate,
  }) {
    return VehicleTracking(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      currentLocation: currentLocation ?? this.currentLocation,
      currentRouteId: currentRouteId ?? this.currentRouteId,
      currentSpeed: currentSpeed ?? this.currentSpeed,
      fuelLevel: fuelLevel ?? this.fuelLevel,
      engineHours: engineHours ?? this.engineHours,
      isEngineOn: isEngineOn ?? this.isEngineOn,
      diagnostics: diagnostics ?? this.diagnostics,
      lastUpdate: lastUpdate ?? this.lastUpdate,
    );
  }
}

@HiveType(typeId: 92)
@JsonSerializable()
class Geofence {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  
  @HiveField(2)
  final GeofenceType type;
  
  @HiveField(3)
  final GPSLocation center;
  
  @HiveField(4)
  final double radius; // in meters
  
  @HiveField(5)
  final bool isActive;
  
  @HiveField(6)
  final List<String> vehicleIds; // Vehicles to monitor
  
  @HiveField(7)
  final Map<String, dynamic> alertSettings;
  
  @HiveField(8)
  final Map<String, dynamic> metadata;
  
  @HiveField(9)
  final DateTime createdAt;

  const Geofence({
    required this.id,
    required this.name,
    required this.type,
    required this.center,
    required this.radius,
    required this.isActive,
    this.vehicleIds = const [],
    this.alertSettings = const {},
    this.metadata = const {},
    required this.createdAt,
  });

  factory Geofence.fromJson(Map<String, dynamic> json) => _$GeofenceFromJson(json);
  Map<String, dynamic> toJson() => _$GeofenceToJson(this);
}

@HiveType(typeId: 93)
@JsonSerializable()
class VehicleAlert {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String vehicleId;
  
  @HiveField(2)
  final String? driverId;
  
  @HiveField(3)
  final AlertType type;
  
  @HiveField(4)
  final String title;
  
  @HiveField(5)
  final String description;
  
  @HiveField(6)
  final String severity; // low, medium, high, critical
  
  @HiveField(7)
  final GPSLocation? location;
  
  @HiveField(8)
  final bool isResolved;
  
  @HiveField(9)
  final DateTime? resolvedAt;
  
  @HiveField(10)
  final String? resolvedBy;
  
  @HiveField(11)
  final Map<String, dynamic> metadata;
  
  @HiveField(12)
  final DateTime createdAt;

  const VehicleAlert({
    required this.id,
    required this.vehicleId,
    this.driverId,
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    this.location,
    required this.isResolved,
    this.resolvedAt,
    this.resolvedBy,
    this.metadata = const {},
    required this.createdAt,
  });

  factory VehicleAlert.fromJson(Map<String, dynamic> json) => _$VehicleAlertFromJson(json);
  Map<String, dynamic> toJson() => _$VehicleAlertToJson(this);

  VehicleAlert copyWith({
    String? id,
    String? vehicleId,
    String? driverId,
    AlertType? type,
    String? title,
    String? description,
    String? severity,
    GPSLocation? location,
    bool? isResolved,
    DateTime? resolvedAt,
    String? resolvedBy,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
  }) {
    return VehicleAlert(
      id: id ?? this.id,
      vehicleId: vehicleId ?? this.vehicleId,
      driverId: driverId ?? this.driverId,
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      severity: severity ?? this.severity,
      location: location ?? this.location,
      isResolved: isResolved ?? this.isResolved,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      resolvedBy: resolvedBy ?? this.resolvedBy,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}